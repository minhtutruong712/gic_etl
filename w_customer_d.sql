-- GICCORE --
select 
    cast(p.party_id as VARCHAR2(36 BYTE)) customer_src_id, 
    p.party_code customer_code,
    p.party_name customer_name, 
    p.indi_date_of_birth date_of_birth, 
    p.indi_date_of_birth date_of_dead, 
    g.gender_desc gender, 
    p.indi_id_number id_number,
    p.indi_id_type id_type, 
    p.indi_language_preferred language,
    m.status_name marital_status, 
    c.COUNTRY_NAME nationality, 
    r.RACE_NAME race, 
    p.INDI_RELIGION religion, 
    i.INDUSTRY_NAME industry_category, 
    o.STATUS_NAME legal_status, 
    p.ORG_ORGANIZATION_ID_NUMBER organization_id_number, 
    p.ORG_REGISTRATION_NAME registration_name, 
    p.PARTY_NAME company_name, 
    null as tax_code, 
    null as cif_code, 
    null as bank_card_number, 
    null as is_activated, 
    null as customer_category, 
    p.USER_ID user_id, 
    p.BUSINESS_OBJECT_ID bussiness_object_id, 
    p.ORG_PARENT_ORG_ID org_parent_org_id, 
    p.IS_ORG_PARTY is_org_party, 
    null as payment_method, 
    null as relationship_type,
    cast(p.party_id as VARCHAR2(36 BYTE)) || '-' || 'GICORE' as w_integration_key

from T_PTY_PARTY p
left join T_PTY_GENDER g 
    on p.indi_gender = g.gender_code
left join T_PTY_MARITAL_STATUS m
    on p.indi_marital_status = m.MARITAL_STATUS
left join T_PUB_COUNTRY c  
    on cast(p.INDI_NATIONALITY as varchar(10)) = c.COUNTRY_CODE
left join T_PTY_RACE r
    on p.INDI_RACE = r.RACE_ID
left join T_PTY_ORG_LEGAL_STATUS o 
    on p.ORG_LEGAL_STATUS = o.LEGAL_STATUS
left join T_PTY_INDUSTRY_CATEGORY i 
    on p.ORG_INDUSTRY_CATEGORY = i.INDUSTRY_CATEGORY
where p.party_type in (20, 21)

union all

select -- PP --
    c.id customer_src_id, 
    c.id as customer_code, 
    CustomerName customer_name, 
    Birthday date_of_birth, 
    null as date_of_dead, 
    m.Code gender, 
    c.IdNumber id_number,
    null as id_type,
    null as language,
    null as marital_status,
    null as nationality,
    null as race,
    null as religion,
    null as industry_category,
    null as legal_status,
    null as organization_id_number,
    null as registration_name, 
    c.Company company_name,
    c.TaxIdentificationNumber tax_code,
    c.CIF cif_code,
    c.BankCardNumber bank_card_number,
    c.ISACTIVATED is_activated,
    null as customer_category,
    null as user_id,
    null as bussiness_object_id,
    null as org_parent_org_id,
    null as is_org_party,
    null as payment_method, 
    null as relationship_type,
    c.id || '-' || 'PP' as w_integration_key

from Customers c
left join MetadataTypes m on c.GenderID= m.ID

union all 
select 
    Customer_No customer_src_id, 
    Customer_No customer_code, 
    Customer_Name customer_name, 
    null date_of_birth, 
    null as date_of_dead, 
    null gender, 
    Customer_No id_number,
    null as id_type,
    null as language,
    null as marital_status,
    null as nationality,
    null as race,
    null as religion,
    null as industry_category,
    null as legal_status,
    null as organization_id_number,
    null as registration_name, 
    null company_name,
    null tax_code,
    null cif_code,
    null bank_card_number,
    null is_activated,
    null as customer_category,
    null as user_id,
    null as bussiness_object_id,
    null as org_parent_org_id,
    null as is_org_party,
    null as payment_method, 
    null as relationship_type,
    Customer_No || '-' || 'IBMS' as w_integration_key

    from IBMS_Customer



    




 





