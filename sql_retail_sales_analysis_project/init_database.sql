-- Database and Table Setup
-- Creates the Retail_Sales_Analysis database and retail_sales table with appropriate columns and data types.

CREATE DATABASE Retail_Sales_Analysis;

-- Drops the retail_sales table if it already exists to avoid conflicts.

DROP TABLE IF EXISTS retail_sales;

-- Creates the retail_sales table with columns for transaction details, customer info, and sales metrics.

CREATE TABLE retail_sales (
    transaction_id INT PRIMARY KEY,    
    sale_date DATE,    
    sale_time TIME,    
    customer_id INT,
    gender VARCHAR(15),
    age INT,
    category VARCHAR(15),    
    quantity INT,
    price_per_unit FLOAT,    
    cogs FLOAT,
    total_sale FLOAT
);
