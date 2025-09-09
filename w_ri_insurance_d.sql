select 
    ri.RI_POLICY_ID ri_policy_src_id,
    ri.RI_POLICY_RISK_UNIT_ID ri_policy_risk_unit_src_id,
    json_value(ri.CONTENT,'$.BusinessSource') bussiness_source, 
    json_value(ri.CONTENT,'$.TransType') trans_type, 
    json_value(ri.CONTENT,'$.FundType') fund_type,
    json_value(ri.CONTENT,'$.Lob') lod,
    json_value(ri.CONTENT,'$.LobCode') lod_code,
    json_value(ri.CONTENT,'$.Fronting') fronting,
    json_value(ri.CONTENT,'$.IsRiskCovered') is_risk_cover,
    json_value(rsk.CONTENT,'$.Retention') retention,
    json_value(rsk.CONTENT,'$.RetentionShareRate') retention_share_rate,
    json_value(rsk.CONTENT,'$.NetRetention') net_retention,
    json_value(rsk.CONTENT,'$.FacShareRate') fac_share_rate,
    json_value(rsk.CONTENT,'$.FacSumInsured') fac_sum_insured,
    json_value(rsk.CONTENT,'$.FacPremium') fac_premium,
    json_value(ri.CONTENT,'$.ChangePremium') change_premium,
    json_value(ri.CONTENT,'$.ChangeAgentCommission') change_agent_commision,
    json_value(ri.CONTENT,'$.IsCessionAdjustmentEndo') is_session_adjustment_endo,
    json_value(ri.CONTENT,'$.IsUndo') is_undo

    from T_AP98_RI_POLICY_RISK_UNIT rsk
    left join T_AP98_RI_POLICY ri
        on json_value(rsk.CONTENT,'$.RiPolicyId') = ri.RI_POLICY_ID

;
-- select RI_POLICY_ID
-- , count(*) from T_AP98_RI_POLICY
-- group by RI_POLICY_ID
-- having count(*) > 1;
-- select RI_POLICY_RISK_UNIT_ID, count(*) 
-- from T_AP98_RI_POLICY_RISK_UNIT
-- group by RI_POLICY_RISK_UNIT_ID
-- having count(*) > 1;
