-- EDA: Exploratory Data Analysis

-- Count the total number of rows (tracks) in the spotify table to understand the dataset size

SELECT COUNT(*) FROM spotify;

-- Count the number of unique artists in the spotify table to assess artist diversity

SELECT COUNT(DISTINCT artist) FROM spotify;

-- Retrieve all unique album_type values (e.g., 'single', 'album') to see the types of albums in the dataset

SELECT DISTINCT album_type FROM spotify;

-- Calculate the maximum and minimum track durations (in minutes) to understand the range of track lengths

SELECT 
    MAX(duration_min) AS max_duration,
    MIN(duration_min) AS min_duration
FROM spotify;

-- Select all columns for tracks with a duration of 0 minutes to identify potential data errors

SELECT
*
FROM spotify
WHERE duration_min = 0;

-- Delete rows where duration_min is 0 to clean the dataset by removing invalid entries

DELETE FROM spotify
WHERE duration_min = 0;

-- Retrieve all unique channel values (e.g., YouTube channels) associated with tracks' videos

SELECT 
    DISTINCT channel
FROM spotify;

-- Retrieve all unique most_played_on values to see platforms or regions where tracks are most played

SELECT 
    DISTINCT most_played_on
FROM spotify;

-- Data Analysis

-- Select artist, track, and stream count for tracks with over 1 billion streams, grouped to ensure unique rows, and sorted by streams in descending order

SELECT 
    artist,
    track,
    stream
FROM spotify
WHERE stream > 1000000000
GROUP BY artist, track, stream
ORDER BY stream DESC;

-- Retrieve unique album and artist combinations, sorted alphabetically by album name

SELECT 
    DISTINCT album, artist
FROM spotify
ORDER BY album;

-- Calculate the total number of comments for tracks that are licensed (licensed = TRUE)

SELECT
    SUM(comments) AS total_comments
FROM spotify
WHERE licensed IS TRUE;

-- Select artist, track, and album_type for tracks classified as singles

SELECT
    artist,
    track,
    album_type
FROM spotify
WHERE album_type IN ('single');

-- Count the number of tracks per artist, grouped by artist, and sorted by track count in descending order to identify the most prolific artists

SELECT
    artist,
    COUNT(track) AS number_of_tracks
FROM spotify
GROUP BY artist
ORDER BY number_of_tracks DESC;


------------------------------------------------
------------------------------------------------

-- Calculate the average danceability for each album, group by album, and sort by average danceability in descending order

SELECT
    album,
    AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY album
ORDER BY avg_danceability DESC;



-- Select artist, track, and energy for the top 10 tracks with the highest energy, grouped to ensure unique rows, sorted by energy in descending order

SELECT
    artist,
    track,
    energy
FROM spotify
GROUP BY artist, track, energy
ORDER BY energy DESC
LIMIT 10;

-- Calculate the total views and likes for tracks marked as official videos, grouped by track

SELECT
    track, 
    SUM(views) AS total_views, 
    SUM(likes) AS total_likes
FROM spotify
WHERE official_video IS TRUE
GROUP BY track;

-- Calculate the total views for each track within each album, grouped by album and track, sorted by total views in descending order

SELECT 
    album,
    track,
    SUM(views) AS total_views
FROM spotify
GROUP BY album, track
ORDER BY total_views DESC;


-- Compare total streams on YouTube vs. Spotify for each track, selecting tracks where Spotify streams exceed YouTube streams and YouTube streams are non-zero

SELECT
    *
FROM
    (SELECT
        track,
        COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) AS streamed_on_youtube,
        COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) AS streamed_on_spotify
    FROM spotify
    GROUP BY track) AS t1
WHERE 
    streamed_on_spotify > streamed_on_youtube
    AND streamed_on_youtube <> 0;



-----------------------
-----------------------

-- Select the energy value for all tracks in the spotify table
-- Calculate the maximum, minimum, and difference in energy for each album

SELECT
    album,
    MAX(energy) AS max_energy, 
    MIN(energy) AS min_energy, 
    MAX(energy) - MIN(energy) AS energy_diff 
FROM spotify
GROUP BY album; 


-- Define a CTE to calculate the total views for each artist-track combination
-- Select artist, track, and sum of views, grouping by artist and track to aggregate views
-- Select artist, track, total views, and assign a rank based on total views in descending order
-- Limit to the top 10 tracks by total views

WITH views_stats AS (
    SELECT
        artist,
        track,
        SUM(views) AS total_views
    FROM spotify
    GROUP BY artist, track
)
SELECT
    artist,
    track,
    total_views,
    RANK() OVER(ORDER BY total_views DESC) AS views_rank
FROM views_stats
LIMIT 10;


-- Select tracks, artist where liveness is greater than the average liveness of all tracks
-- Subquery to calculate the average liveness across all rows in the spotify table

SELECT
    track,
	artist,
	liveness
FROM spotify
WHERE liveness > (
    SELECT AVG(liveness)
    FROM spotify
);

-- Select columns for output: album, artist, a calculated engagement score, and a rank based on engagement

SELECT
    album,
    artist,
    SUM(views + likes + comments) AS engagement_score,
    RANK() OVER (ORDER BY SUM(views + likes + comments) DESC) AS engagement_rank
FROM spotify
GROUP BY album, artist
ORDER BY engagement_rank
LIMIT 10;

-- Find Tracks with High Contrast in Audio Features Within an Album

SELECT
    album,
    artist,
    MAX(danceability) - MIN(danceability) AS danceability_range,
    MAX(energy) - MIN(energy) AS energy_range,
    MAX(valence) - MIN(valence) AS valence_range
FROM spotify
GROUP BY album, artist
HAVING 
    MAX(danceability) - MIN(danceability) > 0.3
    OR MAX(energy) - MIN(energy) > 0.3
    OR MAX(valence) - MIN(valence) > 0.3
ORDER BY danceability_range DESC, energy_range DESC, valence_range DESC;

-- Define a CTE to calculate average liveness and speechiness across all tracks

WITH avg_metrics AS (
    SELECT
        AVG(liveness) AS avg_liveness,
        AVG(speechiness) AS avg_speechiness
    FROM spotify
)
SELECT
    s.artist,
    s.track,
    s.liveness,
    s.speechiness,
    s.views,
    s.likes,
    s.comments
FROM spotify s, avg_metrics
WHERE 
    s.liveness > (SELECT avg_liveness FROM avg_metrics)
    AND s.speechiness < (SELECT avg_speechiness FROM avg_metrics)
ORDER BY s.liveness DESC, s.speechiness ASC
LIMIT 10;
