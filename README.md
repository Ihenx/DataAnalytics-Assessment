# Assesment 1
## The Purspose of this Query
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



