
select distinct

    BUSINESS_CODE product_code, 
    VERSION_DESCRIPTION product_name, 
    JSON_VALUE(T4.DYNAMIC_FIELDS, '$.SubProductCode') sub_product_code,
    JSON_VALUE(T4.DYNAMIC_FIELDS, '$.SubProductName') sub_product_name,
    null as product_currency_code, 
    PRODUCT_VERSION product_version



    from T_PRD_PRODUCT T1
    left join T_DD_BUSI_CONTEXT T2 ON T1.PRODUCT_ID = T2.REFERENCE_ID
    left join T_DD_BUSI_CODE_TABLE T3 ON T2.CONTEXT_ID = T3.CONTEXT_ID
    left join T_DD_BUSI_DATA_TABLE_RECORD T4 ON T3.DATA_TABLE_ID = T4.DATA_TABLE_ID
    
    WHERE PRODUCT_VERSION = '1.0' AND T3.NAME = 'PolicyPolicySubProduct'

-- union all ;

-- select * from PRODUCTDETAILS




