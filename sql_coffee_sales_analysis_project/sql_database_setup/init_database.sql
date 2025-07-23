-- Create a new database named sql_coffee_sales_analysis
CREATE DATABASE sql_coffee_sales_analysis;

-- Drop the sales table if it already exists to avoid conflicts
DROP TABLE IF EXISTS sales;

-- Drop the customers table if it already exists to avoid conflicts
DROP TABLE IF EXISTS customers;

-- Drop the products table if it already exists to avoid conflicts
DROP TABLE IF EXISTS products;

-- Drop the city table if it already exists to avoid conflicts
DROP TABLE IF EXISTS city;

-- Import Rules:
-- 1st: Import data into the city table first, as it is referenced by customers
-- 2nd: Import data into the products table, as it is referenced by sales
-- 3rd: Import data into the customers table, as it references city and is referenced by sales
-- 4th: Import data into the sales table, as it references both products and customers

-- Create the city table to store city-related information
CREATE TABLE city
(
    city_id INT PRIMARY KEY,          -- Unique identifier for each city, used as the primary key
    city_name VARCHAR(15),            -- Name of the city, limited to 15 characters
    population BIGINT,                -- Population of the city, using BIGINT for large numbers
    estimated_rent FLOAT,             -- Estimated rent in the city, stored as a floating-point number
    city_rank INT                     -- Rank of the city, stored as an integer
);

-- Create the products table to store product-related information
CREATE TABLE products
(
    product_id INT PRIMARY KEY,       -- Unique identifier for each product, used as the primary key
    product_name VARCHAR(35),         -- Name of the product, limited to 35 characters
    Price FLOAT                       -- Price of the product, stored as a floating-point number
);

-- Create the customers table to store customer-related information
CREATE TABLE customers
(
    customer_id INT PRIMARY KEY,      -- Unique identifier for each customer, used as the primary key
    customer_name VARCHAR(25),        -- Name of the customer, limited to 25 characters
    city_id INT,                      -- Foreign key referencing the city_id from the city table
    CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)  -- Defines the foreign key relationship to the city table
);

-- Create the sales table to store sales transaction information
CREATE TABLE sales
(
    sale_id INT PRIMARY KEY,          -- Unique identifier for each sale, used as the primary key
    sale_date DATE,                   -- Date of the sale, stored in DATE format
    product_id INT,                   -- Foreign key referencing the product_id from the products table
    customer_id INT,                  -- Foreign key referencing the customer_id from the customers table
    total FLOAT,                      -- Total amount of the sale, stored as a floating-point number
    rating INT,                       -- Rating of the sale (e.g., customer satisfaction), stored as an integer
    CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),  -- Defines the foreign key relationship to the products table
    CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id)  -- Defines the foreign key relationship to the customers table
);
