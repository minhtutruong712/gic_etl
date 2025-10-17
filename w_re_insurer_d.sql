select 
distinct

    json_value(CONTENT,'$.ReinsurerId') re_insured_id,
    p.PARTY_NAME short_name_en,
    -- json_value(p.DYNAMIC_FIELDS,'$.ReinsurerName') reinsurer_name,
    json_value(p.DYNAMIC_FIELDS,'$.Address4') country,
    json_value(p.DYNAMIC_FIELDS,'$.Address1') address_vn, 
    CAST(c.BUSINESS_TEL AS VARCHAR2(255)) AS phone,
    p.PARTY_NAME company_en,
    p.PARTY_NAME short_name_vn, 
    p.PARTY_NAME insurer_company,

    CAST(c.EMAIL AS VARCHAR2(255)) AS email,
    CAST(c.FAX AS VARCHAR2(255)) AS fax,

    json_value(CONTENT,'$.ReinsurerId') || '-' || 'GICORE' w_integration_key



from T_AP98_RI_STATEMENT ri
left join T_PTY_PARTY p 
    on json_value(ri.CONTENT,'$.ReinsurerId') = p.party_id
left join T_PTY_CONTACT c 
    on p.PARTY_ID = c.PARTY_ID