with user_plan_data as (SELECT 
distinct
    u.id AS owner_id,
    p.id as plan_id,
    CONCAT_WS(' ', u.first_name, u.last_name) AS full_name,
    p.is_regular_savings as savings_account,
    p.is_fixed_investment as investment_account,
    s.amount as transaction_amount
FROM
    users_customuser u
        LEFT JOIN
    plans_plan p ON u.id = p.owner_id
        LEFT JOIN
    savings_savingsaccount s ON p.id = s.plan_id
    )
    
    select owner_id,
			full_name,
            count(case when coalesce(savings_account,0) >= 1 then plan_id end ) as saving_count,
            count(case when coalesce(investment_account,0) >= 1 then plan_id end) as investment_count,
            round(sum(transaction_amount),0) as transaction_deposit
	from user_plan_data
    group by owner_id, full_name
    having saving_count >= 1 and investment_count >= 1
    order by transaction_deposit desc;
    
