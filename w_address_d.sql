WITH address_parsing AS (
    SELECT 
        customer_id, 
        MAX(AddressType) AddressType,
        MAX(Address1) Address1,
        MAX(Address2) Address2,
        MAX(Address3) Address3, 
        MAX(Address4) Address4
    FROM (
        SELECT customer_id, copy_of_customer_basic_info v_json FROM T_PA_POLICY_CUSTOMER
    ),
    JSON_TABLE(
        v_json,
        '$'
        COLUMNS (
            NESTED PATH '$.PartyAddressList[*]'
            COLUMNS (
                AddressType      NUMBER        PATH '$.AddressType', 
                Address1         VARCHAR2(200) PATH '$.Address1', -- city_province
                Address2         VARCHAR2(200) PATH '$.Address2', -- district
                Address3         VARCHAR2(200) PATH '$.Address3', -- ward
                Address4         VARCHAR2(200) PATH '$.Address4' -- home address
            )
        )
    ) jt
    GROUP BY customer_id
),
city_code AS ( 
    SELECT 
        DISTINCT 
        JSON_VALUE(DYNAMIC_FIELDS, '$.CityCode') city_code,
        JSON_VALUE(DYNAMIC_FIELDS, '$.CityName') city_name, 
        JSON_VALUE(DYNAMIC_FIELDS, '$.DistrictName') district_name, 
        JSON_VALUE(DYNAMIC_FIELDS, '$.DistrictCode') district_code,
        JSON_VALUE(DYNAMIC_FIELDS, '$.WardName') ward_name,
        JSON_VALUE(DYNAMIC_FIELDS, '$.WardCode') ward_code
    FROM T_DD_BUSI_DATA_TABLE_RECORD 
    WHERE UPPER(DATA_TABLE_ID) LIKE '%9801560419%' 
)
, gic_core_data AS (
    SELECT 
        CAST(pt.party_id AS VARCHAR2(36 BYTE)) AS customer_src_id,
        'GIC_CORE' AS source,
        a.ADDRESS_ID AS address_src_id,      --**<Manhadd>
        at.TYPE_NAME AS address_type,        --**<Manhadd>
        RTRIM(
            COALESCE(ad.Address4 || ', ', '') ||
            COALESCE(ad.Address3 || ', ', '') ||
            COALESCE(ad.Address2 || ', ', '') ||
            COALESCE(ad.Address1, ''),
        ', '
        ) AS full_address,
        ad.Address1 AS city_province, 
        cd.city_code AS city_province_code,
        ad.Address2 AS district, 
        cd.district_code, 
        ad.Address3 AS ward, 
        cd.ward_code AS ward_code,
        ad.Address4 AS street
    FROM T_PTY_PARTY pt 
    LEFT JOIN address_parsing ad ON pt.party_id = ad.customer_id
    LEFT JOIN T_PTY_ADDRESS a ON pt.party_id = a.PARTY_ID AND ad.AddressType = a.ADDRESS_TYPE
    LEFT JOIN T_PTY_ADDRESS_TYPE at ON ad.AddressType = at.ADDRESS_TYPE
    LEFT JOIN city_code cd 
        ON NVL(ad.Address1, '') = cd.city_name
        AND NVL(ad.Address2, '') = cd.district_name
        AND NVL(ad.Address3, '') = cd.ward_name
),
datahub_data AS (
    SELECT 
        c.id AS customer_src_id,   
        'DATAHUB' AS source,
        NULL AS address_src_id,      --**<Manhadd>
        CAST(CASE 
            WHEN CompanyAddress IS NOT NULL THEN 'Work'
            WHEN Address IS NOT NULL THEN 'Home'
            ELSE '' 
        END AS NVARCHAR2(100)) AS address_type, 
        CASE 
            WHEN CompanyAddress IS NOT NULL THEN CompanyAddress
            WHEN Address IS NOT NULL THEN Address
            ELSE NULL 
        END AS full_address,
        m1.Name AS city_province, 
        m1.Code AS city_province_code,
        m2.Name AS district, 
        m2.Code AS district_code,
        NULL AS ward, 
        NULL AS ward_code,
        NULL AS street
    FROM Customers c
    LEFT JOIN MetadataTypes m1 ON m1.ID = c.ProvinceId
    LEFT JOIN MetadataTypes m2 ON m2.ID = c.DistrictId
),
ibms_data AS (
    SELECT 
        CAST(customer_id AS VARCHAR2(36 BYTE)) AS customer_src_id,    
        'IBMS' AS source, 
        NULL AS address_src_id,                                          --**<Manhadd>
        NULL AS address_type,                                            --**<Manhadd>  
        CAST(CUSTOMER_ADDRESS AS VARCHAR2(200)) AS full_address, 
        NULL AS city_province, 
        NULL AS city_province_code,
        NULL AS district, 
        NULL AS district_code,
        NULL AS ward, 
        NULL AS ward_code,
        NULL AS street
    FROM IBMS_Customer
),
combined_data AS (
    SELECT * FROM gic_core_data
    UNION ALL 
    SELECT * FROM datahub_data
    UNION ALL 
    SELECT * FROM ibms_data
)

SELECT 
    address_src_id,
    cast(customer_src_id AS NUMBER(19,0)) customer_src_id,
    address_type,
    full_address,
    city_province,
    city_province_code,
    district,
    district_code,
    ward,
    ward_code,
    street,
    coalesce(cast(address_src_id AS VARCHAR2(50)), customer_src_id) || coalesce(ward_code,'0') || source as w_integration_key
FROM combined_data
