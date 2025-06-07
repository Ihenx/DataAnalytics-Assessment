SELECT 
    u.id AS owner_id,
    CONCAT_WS(' ', u.first_name, u.last_name) AS full_name,
    COUNT(CASE
        WHEN p.is_regular_savings >= 1 THEN p.id
    END) AS savings_count,
    COUNT(CASE
        WHEN p.is_fixed_investment >= 1 THEN p.id
    END) AS investment_count,
    ROUND(SUM(s.amount), 0) AS transaction_deposit
FROM
    users_customuser u
        LEFT JOIN
    plans_plan p ON u.id = p.owner_id
        LEFT JOIN
    savings_savingsaccount s ON p.id = s.plan_id
GROUP BY u.id , CONCAT_WS(' ', u.first_name, u.last_name)
HAVING savings_count >= 1
    AND investment_count >= 1
    order by transaction_deposit desc;