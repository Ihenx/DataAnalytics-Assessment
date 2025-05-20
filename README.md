# Assesment 1
## Task
Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.
Tables:
users_customuser
savings_savingsaccount
plans_plan

```
-- Select the user ID and concatenate first_name and last_name
SELECT 
    uc.id AS owner_id,
    CONCAT_WS(' ', uc.first_name, uc.last_name) AS name,

    -- Count how many of the user's plans are marked as 'regular savings'
    SUM(pp.is_regular_savings) AS savings_count,
   ROUND(SUM(COALESCE(sa.amount, 0)), 2)

```
* `uc.id` AS owner_id: Fetch the user’s ID from the `users_customuser` table.

* `CONCAT_WS(' ', uc.first_name, uc.last_name)`: Combines the first and last name of the user into one string, separated by a space. CONCAT_WS() stands for “Concatenate With Separator”.
* `SUM(pp.is_regular_savings)`: Counts the number of plans where is_regular_savings = 1 for the user.Since it's a boolean column (either 0 or 1), summing gives the count of true values.


* `SUM(pp.is_a_fund)`: Same logic — counts the number of investment plans the user has.
* Calculates the total sum of transactions across all savings accounts tied to the user's plans. which was rounded in two decimal places. Also included the coalesce function to ensure that null valuses are treated as 0

    ```
    FROM users_customuser uc
    JOIN plans_plan pp ON uc.id = pp.owner_id
    JOIN savings_savingsaccount sa ON pp.id = sa.plan_id
    GROUP BY uc.id, uc.first_name, uc.last_name

  ```
* The data originates from the users_customuser table (aliased as uc).

* It joins with plans_plan (aliased as pp) to access the financial plans owned by each user.

* It then joins with savings_savingsaccount (aliased as sa) to access all transactions made under each plan.
* Aggregation (e.g., SUM) requires grouping. 

Kindly note inorder to optimise the query i decided group it by the base columns (first_name and last_name) instead of `CONCAT_WS()` to avoid recomputation.
```
HAVING 
    SUM(pp.is_regular_savings) > 0
    AND SUM(pp.is_a_fund) > 0
```

* Only includes users who have at least one savings plan and at least one investment plan.

HAVING is used instead of WHERE because you're filtering on aggregated values sum.

```
ORDER BY transaction_deposit DESC;
```
* Sorts the results in descending order of total transaction deposits. So  that users who have transacted the most are shown at the top.

# Assesment 2

In this SQL project created a user-defined function (frequencyCategory)  that categorizes customers based on the average number of transactions per month. This can be useful in customer segmentation.

## Task
* Businesses often need to segment users based on how frequently they transact. This SQL solution:

* Calculates each user's average monthly transaction count

* Uses a custom function to assign a frequency category:

* High Frequency: 10 or more transactions/month

* Medium Frequency: 3 to 9 transactions/month

* Low Frequency: Less than 3 transactions/month
  

      ```
          DELIMITER $$
            CREATE FUNCTION frequencyCategory(
            avg_transaction_count DECIMAL(10,2)
        ) RETURNS VARCHAR(20)
        DETERMINISTIC
        BEGIN
            DECLARE frequencyCategory VARCHAR(20);
        
            IF avg_transaction_count >= 10 THEN
                SET frequencyCategory = "High Frequency";
            ELSEIF avg_transaction_count >= 3 THEN
                SET frequencyCategory = "Medium Frequency";
            ELSE
                SET frequencyCategory = "Low Frequency";
            END IF;
        
            RETURN frequencyCategory;
        END $$
        DELIMITER ;
    ```
###  Parameters
avg_transaction_count: Average number of monthly transactions per user (decimal).

### Returns
A VARCHAR representing the frequency category:

"High Frequency": 10 or more transactions/month

"Medium Frequency": 3 to 9 transactions/month

"Low Frequency": Less than 3 transactions/month

### Query Workflow
* 1 CTE: monthly_transaction
Groups all transactions by user and month
```
    WITH monthly_transaction AS (
        SELECT 
            sa.owner_id,
            DATE_FORMAT(pp.start_date, '%Y-%m') AS transaction_month,
            COUNT(*) AS transaction_count
        FROM
            plans_plan pp
        JOIN
            savings_savingsaccount sa ON pp.id = sa.plan_id
        GROUP BY 
            sa.owner_id, DATE_FORMAT(pp.start_date, '%Y-%m')
    )
```
*  CTE: avg_monthly_transaction
Aggregates and calculates:

Total number of transactions per user

Average number of transactions per active month
        ```
            avg_monthly_transaction AS (
                SELECT 
                    mt.owner_id, 
                    SUM(mt.transaction_count) AS customer_count,
                    SUM(mt.transaction_count) / COUNT(DISTINCT mt.transaction_month) AS avg_transaction_count
                FROM 
                    monthly_transaction mt
                GROUP BY 
                    mt.owner_id
            )
        ```
Applies the frequencyCategory() function

Outputs:

Frequency category

Total transaction count

Average monthly transactions
    ```
        SELECT 
            frequencyCategory(avg_transaction_count) AS Frequency_Category,
            amt.customer_count,
            amt.avg_transaction_count
        FROM 
            avg_monthly_transaction amt;
    ```

# Assesment 3
This SQL script identifies inactive savings or investment plans by calculating the number of days since their last transaction. It includes 
* Plans whose last transaction was more than 365 days ago.

  ```
  WITH last_days AS (
    SELECT 
        pp.id AS plan_id,                  -- Unique ID of the plan
        pp.owner_id,                       -- ID of the plan owner (user)
        pp.description AS type,            -- Name/type of the plan
        MAX(sa.transaction_date) AS last_activity_date  -- Most recent transaction date (if any)

    ```
You're selecting fields from the plans_plan table:

`plan_id`: the unique plan identifier.

`owner_id`: the user who owns this plan.

`type`: the description or type of the plan (e.g., "Fixed Deposit", "Mutual Fund").

`last_activity_date`: calculated as the most recent transaction for this plan, using MAX(transaction_date).
```
    FROM
        plans_plan pp
    LEFT JOIN savings_savingsaccount sa ON pp.id = sa.plan_id
    GROUP BY 
        pp.id, pp.owner_id, pp.name
)
```
Use the CTE to find plans inactive for over a year
```
SELECT 
    plan_id,                              -- ID of the plan
    owner_id,                             -- ID of the plan owner
    type,                                 -- Plan type or description
    DATEDIFF(CURDATE(), ld.last_activity_date) AS inactivity_days
FROM
    last_days ld
```
Here, you're querying the last_days CTE:

DATEDIFF(CURDATE(), last_activity_date) calculates the number of days between today and the last transaction date.
```
WHERE 
    last_activity_date IS NULL            -- Include plans that have NEVER had a transaction
    OR DATEDIFF(CURDATE(), ld.last_activity_date) > 365
ORDER BY 
    inactivity_days DESC;
```
This condition includes two types of plans:

* Those with NULL last activity (no transaction at all).

* Those whose last activity was over a year ago.

 
# Assesment 4
## Task 
 For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
Account tenure (months since signup)
Total transactions
Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
Order by estimated CLV from highest to lowest
```
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
```
* Selecting the unique ID of the user from the `users_customuser` table
* CONCAT_WS() joins the first_name and last_name into a single string separated by a space.This forms the full name of each user.

Calculates how long a user has been with the platform:

* TIMESTAMPDIFF(MONTH, start_date, end_date) returns the difference in months.

* From date_joined (when user registered) to today (CURDATE()).

* Result is called tenure.
* Assumes that for every transaction, the platform earns 0.1% profit.

* This multiplies each transaction amount by 0.001 to estimate profit, and then calculates the average profit per transaction.
* Counts the total number of transactions a user has made.
* Joins users_customuser (users) with savings_savingsaccount (transactions) based on the user ID.
* Groups data by each user’s ID and name so you can aggregate (AVG, COUNT) their transaction info properly.
```
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
```
This draws data from your previously defined CTE (avg_profit_transaction_cte) that already calculated tenure, avg_profit_per_transaction, and total_transaction for each user.With the estimated CLV calculated
* Sorts the results in descending order, so the users with the highest projected CLV appear at the top of the list.
