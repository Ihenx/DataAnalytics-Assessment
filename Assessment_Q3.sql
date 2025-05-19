-- Step 1: Create a Common Table Expression (CTE) to get the last activity date for each plan
WITH last_one_year AS (

    SELECT 
        pp.id AS plan_id,                  -- Unique ID of the plan
        pp.owner_id,                       -- ID of the plan owner (user)
        pp.description AS type,                   -- Name/type of the plan
        MAX(sa.transaction_date) AS last_activity_date  -- Most recent transaction date (if any) for the plan
    FROM
        plans_plan pp
        LEFT JOIN savings_savingsaccount sa ON pp.id = sa.plan_id 
        -- Left join ensures that we include all plans, even if they have no transactions
    GROUP BY 
        pp.id, pp.owner_id, pp.name        -- Group by each unique plan to compute max transaction date per plan
)

-- Step 2: Query the CTE to calculate inactivity days and filter results
SELECT 
    plan_id,                              -- ID of the plan
    owner_id,                             -- ID of the plan owner
    type,                                 -- Plan name/type
    DATEDIFF(CURDATE(), ld.last_activity_date) AS inactivity_days 
        -- Calculate the number of days since the last transaction
FROM
    last_one_year ld
WHERE 
    last_activity_date IS NULL            -- Include plans that have never had a transaction
    OR DATEDIFF(CURDATE(), ld.last_activity_date) > 365
        -- Or include plans that had activity within the last 365 days
ORDER BY 
    inactivity_days DESC;                 -- Show most inactive plans (within 365 days) at the top