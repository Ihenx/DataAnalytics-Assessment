WITH avg_profit_transaction_cte AS (
    SELECT 
        uc.id,
        CONCAT_WS(' ', first_name, last_name) AS name,  -- Combine first and last name
        TIMESTAMPDIFF(MONTH, uc.date_joined, CURDATE()) AS tenure,  -- Calculate user tenure in months
        AVG(sa.amount * 0.001) AS avg_profit_per_transaction,  -- Assume 0.1% profit on each transaction
        COUNT(*) AS total_transaction  -- Total number of transactions
    FROM
        users_customuser uc
        JOIN savings_savingsaccount sa ON uc.id = sa.owner_id
    GROUP BY 
        uc.id, first_name, last_name
)

-- Final SELECT to estimate CLV
SELECT 
    id,
    name,
    avg_profit_per_transaction,
    total_transaction,
    ROUND(((total_transaction / tenure) * 12 * avg_profit_per_transaction), 0) AS estimated_clv
FROM
    avg_profit_transaction_cte apt
ORDER BY 
    estimated_clv DESC;