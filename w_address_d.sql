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
    pt.party_id customer_src_id, 
    ad.AddressType address_type, 
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
    left join city_code cd 
        on nvl(ad.Address1, '') = cd.city_name
        and nvl(ad.Address2, '') = cd.district_name
        and nvl(ad.Address3, '') = cd.ward_name
;
-- DATAHUB --









