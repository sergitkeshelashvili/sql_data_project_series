-- Database and Table Setup
-- Creates the netflix_sql_project database and netflix table with appropriate columns and data types.

CREATE DATABASE netflix_sql_project ;


-- Drops the netflix table if it already exists to avoid conflicts.

DROP TABLE IF EXISTS netflix;

-- Creates the netflix table with columns;

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
