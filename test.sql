select 
    c.id customer_src_id, 
    null as customer_code, 
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
    null as is_org_party

from Customers c
left join MetadataTypes m on c.GenderID= m.ID 
left join CustomerContracts cc on c.Id =cc.CustomerId
left join ProductDetails pd ON cc.ContractId = pd.Id

;


select party_id from T_PTY_PARTY;

select 
    * from customers;
    




