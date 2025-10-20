select 
    ri.RI_POLICY_ID ri_policy_src_id,
    rsk.RI_POLICY_RISK_UNIT_ID ri_policy_risk_unit_src_id,
    json_value(ri.CONTENT,'$.BusinessSource') bussiness_source, 
    json_value(ri.CONTENT,'$.TransType') trns_type, 
    json_value(ri.CONTENT,'$.FundType') funad_type,
    json_value(rsk.CONTENT,'$.LineOfBusiness') lod,
    json_value(ri.CONTENT,'$.LobCode') lod_code,
    json_value(ri.CONTENT,'$.IsRiskCovered') is_risk_cover,
    json_value(rsk.CONTENT,'$.Retention') retention,
    json_value(rsk.CONTENT,'$.RetentionShareRate') retention_share_rate,
    json_value(rsk.CONTENT,'$.NetRetention') net_retention,
    json_value(rsk.CONTENT,'$.FacShareRate') fac_share_rate,
    json_value(rsk.CONTENT,'$.FacSumInsured') fac_sum_insured,
    json_value(rsk.CONTENT,'$.FacPremium') fac_premium,
    json_value(ri.CONTENT,'$.ChangePremium') change_premium,
    json_value(ri.CONTENT,'$.ChangeAgentCommission') change_agent_commision,
    json_value(ri.CONTENT,'$.IsUndo') is_undo,
    ri.RI_POLICY_ID || '-' || rsk.RI_POLICY_RISK_UNIT_ID || '-' || 'GICORE' w_integration_key

    from T_AP98_RI_POLICY_RISK_UNIT rsk
    left join T_AP98_RI_POLICY ri
        on json_value(rsk.CONTENT,'$.RiPolicyId') = ri.RI_POLICY_ID
;



