DELIMITER $$  -- Changes the statement delimiter to handle the body of the function
CREATE FUNCTION frequencyCategory(
    avg_transaction_count DECIMAL(10,2)  -- Input: average monthly transaction count
) RETURNS VARCHAR(20)  -- Output: text category (Low/Medium/High)
DETERMINISTIC  -- Ensures consistent output for the same input value
BEGIN
    DECLARE frequencyCategory VARCHAR(20);  -- Declares the variable to store result

    -- Logic to categorize based on thresholds
    IF avg_transaction_count >= 10 THEN
        SET frequencyCategory = "High Frequency";
    ELSEIF avg_transaction_count >= 3 THEN
        SET frequencyCategory = "Medium Frequency";
    ELSE
        SET frequencyCategory = "Low Frequency";
    END IF;

    RETURN frequencyCategory;  -- Output the final category
END $$
DELIMITER ;  -- Resets the delimiter back to default


WITH monthly_transaction AS (
    SELECT 
        sa.owner_id,  -- Unique identifier of the user
        DATE_FORMAT(pp.start_date, '%Y-%m') AS transaction_month,  -- Year-Month period
        COUNT(*) AS transaction_count  -- Total number of transactions per month
    FROM
        plans_plan pp
    JOIN
        savings_savingsaccount sa ON pp.id = sa.plan_id  -- Join to get account data for each plan
    GROUP BY 
        sa.owner_id, DATE_FORMAT(pp.start_date, '%Y-%m')  -- Group by user and month
),


avg_monthly_transaction AS (
    SELECT 
        mt.owner_id, 
        SUM(mt.transaction_count) AS customer_count,  -- Total transactions over all months
        SUM(mt.transaction_count) / COUNT(DISTINCT mt.transaction_month) AS avg_transaction_count  -- Average transactions per active month
    FROM 
        monthly_transaction mt
    GROUP BY 
        mt.owner_id
)

SELECT 
    frequencyCategory(avg_transaction_count) AS Frequency_Category,  -- Uses your function to classify the user
    amt.customer_count,  -- Total number of transactions (across all months)
    amt.avg_transaction_count  -- Average number of monthly transactions
FROM 
    avg_monthly_transaction amt;