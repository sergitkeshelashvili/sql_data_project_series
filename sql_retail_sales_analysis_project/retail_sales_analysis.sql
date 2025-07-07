-- Data Validation and Cleaning
-- Retrieves the first 10 rows to inspect the data structure and sample content.

SELECT
    *
FROM retail_sales
LIMIT 10;

-- Counts the total number of records in the retail_sales table.

SELECT
    COUNT(*) AS total_records
FROM retail_sales;

-- Identifies records with NULL values in any critical column to check for data quality issues.
SELECT 
    *
FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR gender IS NULL
    OR category IS NULL
    OR quantity IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;

-- Deletes records with NULL values in critical columns to ensure data integrity.
DELETE FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR gender IS NULL
    OR category IS NULL
    OR quantity IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;

-- Section 3: Data Exploration
-- Counts the total number of sales transactions in the dataset.
SELECT 
    COUNT(*) AS total_sales
FROM retail_sales;

-- Counts the number of unique customers to understand customer base size.
SELECT 
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales;

-- Lists all distinct product categories to understand the range of products sold.
SELECT 
    DISTINCT category
FROM retail_sales;

-- Section 4: Data Analysis
-- Retrieves transactions for the 'Clothing' category in November 2022 with quantity >= 4 to analyze high-volume sales.
SELECT 
    *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND quantity >= 4;

-- Calculates total sales and number of orders per product category to assess category performance.
SELECT 
    category,
    SUM(total_sale) AS net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;

-- Calculates the average customer age for the 'Beauty' category to understand the target demographic.

SELECT
    ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- Identifies high-value transactions with total sales exceeding $1000.

SELECT 
    *
FROM retail_sales
WHERE total_sale > 1000;

-- Counts transactions by category and gender to analyze purchasing patterns across demographics.

SELECT 
    category,
    gender,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category;

-- Ranks months by average sales to identify peak sales periods.

WITH avg_sales_rank AS (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sales
    FROM retail_sales
    GROUP BY year, month
)
SELECT
    year,
    month,
    avg_sales,
    RANK() OVER (ORDER BY avg_sales DESC) AS avg_sales_rank
FROM avg_sales_rank;

-- Identifies the top 5 customers by total sales to recognize high-value customers.

SELECT 
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Counts unique customers per category to understand customer engagement across product types.

SELECT 
    category,    
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;

-- Analyzes sales distribution by time of day (Morning, Afternoon, Evening) to identify peak sales times.

WITH hourly_sale AS (
    SELECT 
        *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) AS total_orders    
FROM hourly_sale
GROUP BY shift;

-- Ranks product categories by total profit (revenue minus COGS) to evaluate profitability.

WITH total_profit_rank AS (
    SELECT 
        category,
        SUM(total_sale) AS total_revenue,
        SUM(cogs) AS total_costs,
        SUM(total_sale - cogs) AS total_profit
    FROM retail_sales
    GROUP BY category
    ORDER BY total_profit DESC
)
SELECT
    category,
    total_revenue,
    total_costs,
    total_profit,
    RANK() OVER (ORDER BY total_profit DESC) AS total_profit_rank_by_category
FROM total_profit_rank;

-- Calculates year-over-year sales growth percentage by category to analyze sales trends.

WITH yearly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        category,
        SUM(total_sale) AS total_sales
    FROM retail_sales
    GROUP BY year, category
)
SELECT 
    category,
    year,
    total_sales,
    LAG(total_sales) OVER (PARTITION BY category ORDER BY year) AS previous_year_sales,
    ROUND(
        CAST(
            ((total_sales - LAG(total_sales) OVER (PARTITION BY category ORDER BY year))
            / LAG(total_sales) OVER (PARTITION BY category ORDER BY year)) * 100 AS NUMERIC
        ), 
        2
    ) AS yoy_growth_percentage
FROM yearly_sales
ORDER BY category, year;
