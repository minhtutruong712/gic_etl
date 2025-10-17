select 
    json_value(CONTENT,'$.RiPolicyId') ri_policy_src_id,  
    RI_POLICY_RISK_UNIT_ID ri_policy_risk_unit_id, 
    json_value(CONTENT,'$.TreatyCurrencyCode') treaty_currency_code, 
    json_value(CONTENT,'$.WarningMessage') warning_message,
    json_value(CONTENT,'$.IsAdjusted') is_adjusted,
    json_value(CONTENT,'$.NeedCashCall') need_cash_call,
    json_value(CONTENT,'$.HasXolTreaty') has_xol_treaty,
    json_value(CONTENT,'$.UsedTreatyCodes') used_treaty_codes,
    json_value(CONTENT,'$.InsuredId') insured_id,
    json_value(CONTENT,'$.NeedFacArrangedment') need_fac_arrangement,
    json_value(CONTENT,'$.Retention') retention, 
    ri_policy_src_id || '-' || ri_policy_risk_unit_id || '-' || 'GICORE' w_integration_key
    

from T_AP98_RI_POLICY_RISK_UNIT t



