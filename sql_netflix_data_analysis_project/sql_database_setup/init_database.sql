-- 1. Creates the netflix_sql_project database
-- This query creates a new database named 'netflix_sql_project' to store the Netflix data.

CREATE DATABASE netflix_sql_project;

-- 2. Drops the netflix table if it exists
-- This ensures no conflicts occur by dropping the 'netflix' table if it already exists.

DROP TABLE IF EXISTS netflix;

-- 3. Creates the netflix table with specified columns
-- Defines the structure of the 'netflix' table with columns for show details like ID, type, title, etc.

CREATE TABLE netflix (
    show_id VARCHAR(5),
    type VARCHAR(10),
    title VARCHAR(250),
    director VARCHAR(550),
    casts VARCHAR(1050),
    country VARCHAR(550),
    date_added VARCHAR(55),
    release_year INT,
    rating VARCHAR(15),
    duration VARCHAR(15),
    listed_in VARCHAR(250),
    description VARCHAR(550)
);
