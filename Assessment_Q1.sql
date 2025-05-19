
-- Select the user ID and concatenate first_name and last_name
SELECT 
    uc.id AS owner_id,
    CONCAT_WS(' ', uc.first_name, uc.last_name) AS name,

    -- Count how many of the user's plans are marked as 'regular savings'
    SUM(pp.is_regular_savings) AS savings_count,

    -- Count how many of the user's plans are marked as 'investment products' (a fund)
    SUM(pp.is_a_fund) AS investment_count,

    -- Sum the total transaction amount from all associated savings accounts
ROUND(SUM(COALESCE(sa.amount, 0)), 2) AS transaction_deposit
-- The data comes from the 'users_customuser' table (aliased as uc)
FROM
    users_customuser uc

-- Join with 'plans_plan' table to access each user's financial plans
JOIN
    plans_plan pp ON uc.id = pp.owner_id

-- Join with 'savings_savingsaccount' to access transactions for each plan
JOIN
    savings_savingsaccount sa ON pp.id = sa.plan_id

-- Group results by user ID and name
-- NOTE: CONCAT_WS is used in both SELECT and GROUP BY — this can cause repeated computation.
-- It's better to group by first_name and last_name separately.
GROUP BY 
    uc.id, uc.first_name, uc.last_name

-- Filter to only include users who have at least:
-- 1 savings plan (is_regular_savings > 0)
-- 1 investment fund (is_a_fund > 0)
HAVING 
    SUM(pp.is_regular_savings) > 0
    AND SUM(pp.is_a_fund) > 0

-- Order the result so that users with the highest total transaction amounts appear first
ORDER BY 
    transaction_deposit DESC;