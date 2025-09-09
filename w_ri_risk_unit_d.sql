select 
    RI_POLICY_HISTORY_ID ri_policy_history_src_id,
    RI_POLICY_RISK_UNIT_HISTORY_ID ri_policy_risk_unit_history_src_id, 
    json_value(CONTENT,'$.RiPolicyRiskUnitId') ri_risk_unit_src_id, 
    json_value(CONTENT,'$.TreatyCurrencyCode') treaty_currency_code, 
    json_value(CONTENT,'$.WarningMessage') warning_message,
    json_value(CONTENT,'$.IsAdjusted') is_adjusted,
    json_value(CONTENT,'$.NeedCashCall') need_cash_call,
    json_value(CONTENT,'$.HasXolTreaty') has_xol_treaty,
    json_value(CONTENT,'$.UsedTreatyCodes') used_treaty_codes,
    json_value(CONTENT,'$.InsuredId') insured_id,
    json_value(CONTENT,'$.NeedFacArrangedment') need_fac_arrangement,
    json_value(CONTENT,'$.Retention') retention

from T_AP98_RI_POLICY_RISK_UNIT_HIS t
where RI_POLICY_RISK_UNIT_HIS_STATUS = 1


