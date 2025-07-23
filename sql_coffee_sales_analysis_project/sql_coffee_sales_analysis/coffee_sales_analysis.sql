-- Project Description
-- SQL Coffee Sales Analysis Project
-- This project analyzes coffee sales data to provide insights into revenue, customer behavior, product performance, and city-level metrics.
-- The goal is to help a coffee business understand sales trends, identify top-performing products, evaluate customer loyalty, and assess market penetration across cities.
-- The database includes four tables: city (city details), products (coffee product details), customers (customer information), and sales (transaction records).
-- The queries below range from simple aggregations to advanced analyses using joins, window functions, and CTEs to support business decision-making.

-- Select all data from tables for reference

SELECT * FROM city;

-- Retrieves all columns and rows from the city table to view city details

SELECT * FROM products;

-- Retrieves all columns and rows from the products table to view product details

SELECT * FROM customers;

-- Retrieves all columns and rows from the customers table to view customer details

SELECT * FROM sales;

-- Retrieves all columns and rows from the sales table to view sales transaction details

-- Reports & Data Analysis

-- 1) Total Revenue from Coffee Sales
-- Calculates the total revenue generated from all coffee sales

SELECT 
    SUM(total) as total_revenue
FROM sales;

-- 2) Sales Count for Each Product
-- Counts the number of units sold for each coffee product and ranks the top 10 products by sales volume

With product_order_rank AS (
    SELECT 
        p.product_name,
        COUNT(s.sale_id) as total_orders
    FROM products as p
    LEFT JOIN
    sales as s
    ON s.product_id = p.product_id
    GROUP BY 1
    ORDER BY 2 DESC)
SELECT
    product_name,
    total_orders,
    RANK() OVER(ORDER BY total_orders DESC) AS product_orders_rank
FROM product_order_rank
LIMIT 10;

-- 3) Yearly Sales Trends
-- Analyzes total revenue and order count by year to identify annual sales patterns

SELECT 
    DATE_TRUNC('year', sale_date) AS sale_year, 
    SUM(total) AS total_revenue,                 
    COUNT(sale_id) AS total_orders                
FROM sales 
GROUP BY 1
ORDER BY 1;


-- 4) High-Rated Products by Average Rating
-- Identifies products with the highest average customer ratings, requiring at least 5 ratings

SELECT 
    p.product_name,                               
    ROUND(AVG(s.rating)::numeric, 2) AS avg_rating, 
    COUNT(s.rating) AS rating_count               
FROM products AS p
LEFT JOIN sales AS s
    ON s.product_id = p.product_id          
WHERE s.rating IS NOT NULL                    
GROUP BY p.product_name
HAVING COUNT(s.rating) >= 5                   
ORDER BY avg_rating DESC;


-- 5) Total Revenue Generated Across All Cities
-- Calculates total revenue from coffee sales for each city

SELECT 
    ci.city_name,
    SUM(s.total) as total_revenue
FROM sales as s
JOIN customers as c
    ON s.customer_id = c.customer_id
JOIN city as ci
    ON ci.city_id = c.city_id
GROUP BY 1
ORDER BY 2 DESC;

-- 6) Customer Segmentation by City
-- Counts unique customers in each city who purchased specific coffee products

SELECT 
    ci.city_name,
    COUNT(DISTINCT c.customer_id) as unique_customer
FROM city as ci
LEFT JOIN customers as c
    ON c.city_id = ci.city_id
JOIN sales as s
    ON s.customer_id = c.customer_id
WHERE 
    s.product_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
GROUP BY 1;


-- 7) Top 10 Products by Revenue
-- Identifies the top 10 products by revenue, including order counts and ranking

WITH product_revenue AS
(SELECT 
    p.product_name,                               
    SUM(s.total) AS total_revenue,                
    COUNT(s.sale_id) AS total_orders           
FROM products AS p
LEFT JOIN sales AS s
    ON s.product_id = p.product_id           
GROUP BY p.product_name
ORDER BY total_revenue DESC)
SELECT 
    product_name,
    total_revenue,
    total_orders,
    RANK() OVER(ORDER BY total_revenue DESC) AS product_revenue_rank
FROM product_revenue
LIMIT 10;

-- 8) Monthly Sales Trends
-- Analyzes total revenue and order count by month, ranking months by revenue

WITH monthly_sales_trends AS (
SELECT 
    DATE_TRUNC('month', sale_date) AS sale_month, 
    SUM(total) AS total_revenue,                 
    COUNT(sale_id) AS total_orders                
FROM sales 
GROUP BY 1
ORDER BY 1)
SELECT
    sale_month,
    total_revenue,
    total_orders,
    RANK() OVER(ORDER BY total_revenue DESC) AS total_revenue_rank_by_month
FROM monthly_sales_trends;


-- 9) (Repeat Customer Analysis): Repeat Customer Analysis
-- Identifies customers with multiple purchases to measure retention

SELECT 
    c.customer_name,                               
    ci.city_name,                                 
    COUNT(s.sale_id) AS purchase_count           
FROM sales AS s
JOIN customers AS c
    ON s.customer_id = c.customer_id           
JOIN city AS ci
    ON c.city_id = ci.city_id                 
GROUP BY c.customer_name, ci.city_name
HAVING COUNT(s.sale_id) > 1                   
ORDER BY purchase_count DESC;


-- 10) Average Sales Amount per City
-- Calculates the average sales amount per customer in each city

SELECT 
    ci.city_name,
    SUM(s.total) as total_revenue,
    COUNT(DISTINCT s.customer_id) as total_customer,
    ROUND(
        SUM(s.total)::numeric/
        COUNT(DISTINCT s.customer_id)::numeric
        ,2) as avg_sale_per_customer
FROM sales as s
JOIN customers as c
    ON s.customer_id = c.customer_id
JOIN city as ci
    ON ci.city_id = c.city_id
GROUP BY 1
ORDER BY 2 DESC;

-- 11) Sales Revenue vs. City Population
-- Compares total sales revenue against city population to assess market penetration

SELECT 
    ci.city_name,                                
    ci.population,                                
    SUM(s.total) AS total_revenue,              
    ROUND(
        SUM(s.total)::numeric / ci.population::numeric, 2
    ) AS revenue_per_capita                       
FROM city AS ci
LEFT JOIN customers AS c
    ON c.city_id = ci.city_id                
LEFT JOIN sales AS s
    ON s.customer_id = c.customer_id           
GROUP BY ci.city_name, ci.population
ORDER BY revenue_per_capita DESC;

-- 12) Top Selling Products by City
-- Identifies the top 3 selling products in each city based on sales volume

SELECT * 
FROM
(
    SELECT 
        ci.city_name,
        p.product_name,
        COUNT(s.sale_id) as total_orders,
        DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) as rank
    FROM sales as s
    JOIN products as p
        ON s.product_id = p.product_id
    JOIN customers as c
        ON c.customer_id = s.customer_id
    JOIN city as ci
        ON ci.city_id = c.city_id
    GROUP BY 1, 2
) as t1
WHERE rank <= 3;

-- 13) Average Sale vs. Rent
-- Calculates average sale and rent per customer in each city

WITH city_table
AS
(
    SELECT 
        ci.city_name,
        SUM(s.total) as total_revenue,
        COUNT(DISTINCT s.customer_id) as total_customers,
        ROUND(
            SUM(s.total)::numeric/
            COUNT(DISTINCT s.customer_id)::numeric
            ,2) as avg_sale_per_customer
    FROM sales as s
    JOIN customers as c
        ON s.customer_id = c.customer_id
    JOIN city as ci
        ON ci.city_id = c.city_id
    GROUP BY 1
    ORDER BY 2 DESC
),
city_rent
AS
(
    SELECT 
        city_name, 
        estimated_rent
    FROM city
)
SELECT 
    cr.city_name,
    cr.estimated_rent,
    ct.total_customers,
    ct.avg_sale_per_customer,
    ROUND(
        cr.estimated_rent::numeric/
        ct.total_customers::numeric
        , 2) as avg_rent_per_customer
FROM city_rent as cr
JOIN city_table as ct
    ON cr.city_name = ct.city_name
ORDER BY 4 DESC;
