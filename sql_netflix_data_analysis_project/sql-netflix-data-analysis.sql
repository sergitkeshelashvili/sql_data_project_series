-- 1. Retrieves all records from the netflix table
-- A simple SELECT query to display all columns and rows in the 'netflix' table.

SELECT
*
FROM netflix;

-- 2. Counts the total number of records
-- Returns the total count of content entries in the 'netflix' table.

SELECT 
    COUNT(*) as total_content
FROM netflix;

-- 3. Counts content by type
-- Groups the data by content type (e.g., Movie, TV Show) and counts the number of entries for each.

SELECT 
    DISTINCT type,
    COUNT(*)
FROM netflix
GROUP BY 1;

-- 4. Lists top 10 genres by content count with ranking
-- Splits the 'listed_in' column into individual genres, counts content per genre, and ranks them using a window function.

WITH genre_total_content AS (
    SELECT 
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) as genre,
        COUNT(*) as total_content
    FROM netflix
    GROUP BY 1
)
SELECT
    genre,
    total_content,
    RANK() OVER(ORDER BY total_content DESC) AS genre_total_content_rank
FROM genre_total_content;

-- 5. Counts content by rating with ranking
-- Groups content by type and rating, counts occurrences, and ranks ratings by count across all types.

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
)
SELECT 
    type,
    rating,
    rating_count,
    RANK() OVER (ORDER BY rating_count DESC) AS rating_count_rank
FROM RatingCounts;

-- 6. Lists top 10 countries by content count
-- Splits the 'country' column, counts content per country, filters out NULLs, and returns the top 10.

SELECT 
    * 
FROM (
    SELECT 
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as country,
        COUNT(*) as total_content
    FROM netflix
    GROUP BY 1
) as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 10;

-- 7. Finds content added in the last 5 years
-- Filters content added within the last 5 years from the current date, converting 'date_added' to a date format.

SELECT
    type,
    title,
    director
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 8. Lists TV shows with more than 5 seasons
-- Filters TV shows with a duration greater than 5 seasons by parsing the 'duration' column.

SELECT 
    title
FROM netflix
WHERE 
    TYPE = 'TV Show'
    AND
    SPLIT_PART(duration, ' ', 1)::INT > 5;

-- 9. Counts content by year added
-- Extracts the year from 'date_added', counts content per year, and orders by year.

SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year_added,
    COUNT(*) AS total_content
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY year_added
ORDER BY year_added;

-- 10. Lists top 10 genres by total count
-- Groups content by the 'listed_in' column (un-split genres) and returns the top 10 by count.

SELECT 
    listed_in,
    COUNT(*) AS total_count
FROM netflix
GROUP BY listed_in
ORDER BY total_count DESC
LIMIT 10;

-- 11. Finds documentaries
-- Retrieves all records where the 'listed_in' column contains 'Documentaries'.

SELECT 
    * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

-- 12. Lists top 10 actors in US content
-- Splits the 'casts' column, counts appearances for actors in US content, and returns the top 10.

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
    COUNT(*)
FROM netflix
WHERE country = 'United States'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 13. Lists top 10 movies by duration
-- Filters movies, extracts duration in minutes, and returns the top 10 longest movies.

SELECT 
    title,
    duration
FROM netflix
WHERE type = 'Movie' AND duration ~ 'min'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 10;

-- 14. Lists top 10 TV shows by season count
-- Filters TV shows and returns the top 10 with the highest number of seasons.

SELECT 
    title,
    duration
FROM netflix
WHERE type = 'TV Show'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 10;

-- 15. Categorizes content by sentiment
-- Assigns content to 'Positive', 'Negative', or 'Neutral' based on keywords in the description and counts by category.

SELECT 
    category,
    COUNT(*) AS total
FROM (
    SELECT *,
        CASE 
            WHEN description ILIKE '%love%' OR description ILIKE '%inspiring%' THEN 'Positive'
            WHEN description ILIKE '%murder%' OR description ILIKE '%crime%' THEN 'Negative'
            ELSE 'Neutral'
        END AS category
    FROM netflix
) AS sentiment
GROUP BY category;

-- 16. Categorizes content by 'Good' or 'Bad' based on description
-- Assigns content as 'Good' or 'Bad' based on keywords like 'kill' or 'violence' and counts by type and category.

SELECT 
    category,
    TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
        *,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2;

-- 17. Lists all records with split directors
-- Splits the 'directors' column into individual directors and returns all columns with each director as a row.

SELECT 
    *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(directors, ',')) AS director_name
    FROM netflix
) AS subquery;

-- 18. Lists top 10 country-director pairs by title count
-- Splits 'country' and 'director' columns, counts titles per country-director pair, and returns the top 10.

SELECT 
    country,
    director_name,
    COUNT(*) AS total_titles
FROM (
    SELECT 
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country,
        TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) AS director_name
    FROM netflix
    WHERE director IS NOT NULL AND country IS NOT NULL
) AS sub
GROUP BY country, director_name
ORDER BY total_titles DESC
LIMIT 10;

-- 19. Lists top 10 actors by content type
-- Splits the 'casts' column, counts actor appearances by content type, and returns the top 10.

SELECT 
    type,
    actor,
    COUNT(*) AS appearances
FROM (
    SELECT 
        type,
        TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor
    FROM netflix
    WHERE casts IS NOT NULL
) AS actors
GROUP BY type, actor
ORDER BY appearances DESC
LIMIT 10;
