-- GICCORE -- 
with address_parsing as (
    select 
        customer_id, 
        max(AddressType) AddressType,
        max(Address1) Address1,
        max(Address2) Address2,
        max(Address3) Address3, 
        max(Address4) Address4

    from (select customer_id, copy_of_customer_basic_info v_json from T_PA_POLICY_CUSTOMER),
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

    group by customer_id
)
, city_code as ( 
    SELECT 
    distinct 
        json_value(DYNAMIC_FIELDS, '$.CityCode') city_code,
        json_value(DYNAMIC_FIELDS, '$.CityName') city_name, 
        json_value(DYNAMIC_FIELDS, '$.DistrictName') district_name, 
        json_value(DYNAMIC_FIELDS, '$.DistrictCode') district_code,
        json_value(DYNAMIC_FIELDS, '$.WardName') ward_name,
        json_value(DYNAMIC_FIELDS, '$.WardCode') ward_code

    FROM T_DD_BUSI_DATA_TABLE_RECORD 
    WHERE UPPER(DATA_TABLE_ID) LIKE '%9801560419%' 
)

select 
    cast(pt.party_id as VARCHAR2(36 BYTE)) as customer_src_id, 
    at.TYPE_NAME address_type, 
    RTRIM(
        COALESCE(ad.Address4 || ', ', '') ||
        COALESCE(ad.Address3 || ', ', '') ||
        COALESCE(ad.Address2 || ', ', '') ||
        COALESCE(ad.Address1, ''),
    ', '
    ) AS full_address,
    ad.Address1 city_province, 
    cd.city_code,
    ad.Address2 district, 
    cd.district_code, 
    ad.Address3 ward, 
    cd.ward_code

    from T_PTY_PARTY pt 
    left join address_parsing ad on pt.party_id = ad.customer_id
    left join T_PTY_ADDRESS_TYPE at on ad.AddressType = at.ADDRESS_TYPE
    left join city_code cd 
        on nvl(ad.Address1, '') = cd.city_name
        and nvl(ad.Address2, '') = cd.district_name
        and nvl(ad.Address3, '') = cd.ward_name

union all -- datahub 
select 
    c.id as customer_src_id,
    cast(case 
        when CompanyAddress is not null then 'Work'
        when Address is not null then 'Home'
        else '' 
    end as NVARCHAR2(100)) as AddressType, 

    case 
        when CompanyAddress is not null then CompanyAddress
        when Address is not null then Address
        else null 
    end as full_address,
    m1.Name as city_province, 
    m1.Code as city_code,
    m2.Name district, 
    m2.Code district_code,
    null ward, 
    null ward_code


from Customers c
left join MetadataTypes m1 
    on m1.ID = c.ProvinceId
left join MetadataTypes m2 
    on m2.ID = c.DistrictId

union all 
select -- IBMS
    customer_id as customer_src_id, 
    null as AddressType, 
    CUSTOMER_ADDRESS as full_address, 
    null as city_province, 
    null as city_code,
    null as district, 
    null as district_code,
    null ward, 
    null ward_code
from IBMS_Customer;





