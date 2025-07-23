-- Drop the spotify table if it already exists to avoid conflicts when creating a new table

DROP TABLE IF EXISTS spotify;

-- Create a table named spotify with 24 columns to store music track data, including artist, track, album, audio features, engagement metrics, and boolean flags

CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes FLOAT,
    comments FLOAT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream FLOAT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

TRUNCATE TABLE spotify;
\copys spotify 
FROM 'C:/path/to/your/csv/spotify_dataset.csv' 
DELIMITER ',' CSV HEADER;
