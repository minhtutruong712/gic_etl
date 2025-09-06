select
INSURED_ID as insured_src_id,
INSURED_ID risk_id,

json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.Program') program,
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.MarineHullCapacity') capacticty, 
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.DeclarationCurrency') currency, 
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.TradingArea') trading_area, 
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.CurrencyOfIncome') currency_of_income, 
null as gross_income, 
null as other_revenue, 
null as total, 
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.InsuredServices') insured_services, 
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.Excluding') excluding, 
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.OtherTerms') other_terms, 
null as left_side, 
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.ShipName') ship_name,
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.ShipType') ship_type,
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.YearOfBuilt') year_of_built,
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.ShipClassification') ship_classification,
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.GrossTonnage') gross_tonange,
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.ShipDeclarationValue') ship_declaration_value,
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.HullPercentage') hull_percent,
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.MachineryPercentage') machinery_percent,
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.EquipmentPercentage') equipment_percent,
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.OthersPercentage') others_percent,
null as right_side,
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.RegistrationNumber') registration_no,
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.ShipBuildingMaterial') ship_building_material,
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.PlaceOfBuilt') place_of_built,
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.Deadweight') dead_weight,
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.HighSpeedShipOver30km') high_speed_ship_over_30_km_h,
json_value(T_PA_POLICY_ELEMENT.DYNAMIC_FIELDS,'$.RegistrationNumber') imo_registration_no

FROM T_PA_INSURED 
LEFT JOIN T_PA_POLICY_ELEMENT 
    ON T_PA_INSURED.INSURED_ID = T_PA_POLICY_ELEMENT.POLICY_ELEMENT_ID
     
INNER JOIN T_PA_POLICY ON T_PA_POLICY.POLICY_ID = T_PA_INSURED.POLICY_ID 
INNER JOIN T_PRD_PRODUCT ON T_PA_POLICY.PRODUCT_ID = T_PRD_PRODUCT.PRODUCT_ID  
WHERE BUSINESS_CODE IN ('MHF', 'MHG', 'MHR') 
and ELEMENT_TYPE = 'INSURED';


