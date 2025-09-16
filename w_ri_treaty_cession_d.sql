
with treaty_id as (
    select 
        treaty_id, 
        max(re_in_statement_premium_rate) as re_in_statement_premium_rate,
        max(ri_out_type) as ri_out_type,
        max(treaty_on_local_currency_code_er) as treaty_on_local_currency_code_er,
        RI_POLICY_RISK_UNIT_ID

    from 

            (select 
            * 
            from 
                (select 
                    RI_POLICY_RISK_UNIT_ID, 
                    json_query(content, '$.RiPolicyTreatyCessions') v_json
                    from T_AP98_RI_POLICY_RISK_UNIT) t
                    CROSS JOIN JSON_TABLE(
                        t.v_json,
                        '$[*]'
                        COLUMNS (
                            treaty_id NUMBER(19) PATH '$.TreatyId',
                            re_in_statement_premium_rate NUMBER(10) PATH '$.ReinstatementPremiumRate',
                            treaty_on_local_currency_code_er VARCHAR2(50) PATH '$.TreatyOnLocalCurrencyCodeEr',
                            NESTED PATH '$.RiPolicyTreatyReinsurers[*]'
                            COLUMNS (
                                ri_out_type NUMBER(10) PATH '$.RiOutType'
                            )
                        )
                    ) jt
                )
    group by RI_POLICY_RISK_UNIT_ID, treaty_id
)

, treaty_commission as (
    select  
    ri_treaty_id, 
    re_insurer_id,
    treaty_commission_type
    from 
        (select 
            * 
            from 
                (select 
                ri_treaty_id, 
                CONTENT v_json
                from T_AP98_RI_TREATY),
                json_table(
                    v_json, 
                    '$.TreatyCommissions[*]'
                    COLUMNS (
                        treaty_commission_type VARCHAR2(200) PATH '$.TreatyCommissionType', 
                        risk_category VARCHAR2(10) PATH '$.RiskCategory',
                        re_insurer_id NUMBER(19) PATH '$.ReinsurerId'
                    )
                )    
        )
)

, cession as (
    select 
        ri_treaty_id, 
        risk_category,
        priority,
        risk_level,
        layer,
        aggregate_limit, 
        capactity capacity, 
        loss_deduction,
        loss_limit, 
        cash_call_limit, 
        lines, 
        sub_risk_categories,
        cession_share_rate,
        retention
    from 
            (select 
            * 
            from 
                (select 
                    ri_treaty_id, 
                    json_query(content, '$.Cession') v_json
                    from T_AP98_RI_TREATY),
                    json_table(
                        v_json, 
                        '$.CessionItems[*]'
                        COLUMNS (
                            risk_category VARCHAR2(200) PATH '$.RiskCategory',
                            priority NUMBER(10) PATH '$.Priority',
                            risk_level VARCHAR2(20) PATH '$.RiskLevel',
                            layer NUMBER(10) PATH '$.Layer',
                            aggregate_limit NUMBER(19,2) PATH '$.AggregateLimit', 
                            capactity NUMBER(19,2) PATH '$.Capacity', 
                            loss_deduction NUMBER(19,2) PATH '$.LossDeduction',
                            loss_limit NUMBER(19,2) PATH '$.LossLimit',
                            cash_call_limit NUMBER(19,2) PATH '$.CashCallLimit',
                            lines NUMBER(19) PATH '$.Lines',
                            cession_share_rate NUMBER(19,6) PATH '$.CessionShareRate',
                            retention NUMBER(19,6) PATH '$.Retention'
                            
                        , NESTED PATH '$.SubRiskCategories[*]'
                        COLUMNS (
                            sub_risk_categories VARCHAR2(50) PATH '$'
                        )
                        )
                )  
            )
)
, treaty_reinsurers as (
    select 
        ri_treaty_id, 
        re_insurer_id,
        is_leader,
        treaty_share_rate
        
    from 
            (select 
            * 
            from 
                (select 
                    ri_treaty_id, 
                    json_query(content, '$.TreatyReinsurers') v_json
                    from T_AP98_RI_TREATY),
                    json_table(
                        v_json, 
                        '$[*]'
                        COLUMNS (
                            re_insurer_id NUMBER(19) PATH '$.ReinsurerId',
                            is_leader VARCHAR2(10) PATH '$.IsLeader',
                            treaty_share_rate NUMBER(10,6) PATH '$.TreatyShareRate'
                        )
                )  
            )
)
, final as (
    select 
    c.ri_treaty_id treaty_src_id, 
    i.ri_policy_risk_unit_id,
    tc.re_insurer_id, 
    c.risk_category, 
    c.sub_risk_categories,
    json_value(t.CONTENT, '$.TreatyCode') treaty_code, 
    substr(json_value(t.CONTENT, '$.EffectiveDate'),1,10) treaty_effective_date, 
    substr(json_value(t.CONTENT, '$.ExpiryDate'),1,10) treaty_expiry_date, 
    tc.treaty_commission_type,
    i.ri_out_type, 
    i.treaty_on_local_currency_code_er,
    c.priority,   
    c.risk_level,
    c.layer, 
    tc.is_leader, 
    c.cession_share_rate, 
    tc.treaty_share_rate, 
    json_value(t.CONTENT, '$.CurrencyCode') treaty_currency_code, --x


    c.loss_deduction,
    c.loss_limit, 
    c.aggregate_limit, 
    c.capacity, 
    -- null as cession_capacity, --null
    c.cash_call_limit, 
    i.re_in_statement_premium_rate, 
    c.lines, 
    c.retention --null
    -- t.CONTENT
    from cession c 
    left join 
        (select tc.*, r.is_leader, r.treaty_share_rate
        from treaty_commission tc 
            left join treaty_reinsurers r
                on r.ri_treaty_id = tc.ri_treaty_id
                and r.re_insurer_id = tc.re_insurer_id
        ) tc 
        on c.ri_treaty_id = tc.ri_treaty_id

        
    left join T_AP98_RI_TREATY t
        on c.ri_treaty_id = t.ri_treaty_id
    
    left join treaty_id i 
        on c.ri_treaty_id = i.treaty_id
)
select * from final


-- key of this entity
-- select  treaty_src_id, 
--     risk_level
--     re_insurer_id, 
--     risk_category, 
--     sub_risk_categories,
--     ri_policy_risk_unit_id,
--     count(*)
--     from final 
--     group by treaty_src_id, 
--     ri_policy_risk_unit_id,
--     risk_level,
--     re_insurer_id, 
--     risk_category, 
--     sub_risk_categories
--     having count(*) > 1
;

select content, json_query(content, '$.RiPolicyTreatyCessions') as RiPolicyTreatyCessions, content, t.* from T_AP98_RI_POLICY_RISK_UNIT t
where json_query(content, '$.RiPolicyTreatyCessions') is not null
-- where RI_POLICY_ID = 86238312

;
select RI_POLICY_RISK_UNIT_ID, count(*) from T_AP98_RI_POLICY_RISK_UNIT
group by RI_POLICY_RISK_UNIT_ID
having count(*) > 1;


select * from T_AP98_RI_TREATY where ri_treaty_id = 89377545;