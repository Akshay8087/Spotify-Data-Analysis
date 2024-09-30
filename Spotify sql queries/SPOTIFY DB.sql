-- Drop the existing spotify table if it exists
DROP TABLE IF EXISTS spotify;

-- Create the spotify table with the necessary columns
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
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- Basic Data Exploration (EDA)
SELECT * FROM spotify;

SELECT COUNT(*) AS total_number_of_rows FROM spotify;
SELECT COUNT(DISTINCT artist) FROM spotify;
SELECT COUNT(DISTINCT album) FROM spotify;
SELECT DISTINCT album_type FROM spotify;
SELECT MAX(duration_min) FROM spotify;
SELECT MIN(duration_min) FROM spotify;

-- Delete songs with 0 min duration
SELECT * FROM spotify WHERE duration_min = 0;
DELETE FROM spotify WHERE duration_min = 0; -- deleted 2 records

SELECT COUNT(DISTINCT channel) FROM spotify;
SELECT DISTINCT most_played_on FROM spotify;

-- Data Analysis

-- Retrieve the names of all tracks that have more than 1 billion streams
SELECT * FROM spotify WHERE stream > 1000000000;

-- List all albums along with their respective artists
SELECT album, artist FROM spotify ORDER BY album;
SELECT DISTINCT album, artist FROM spotify ORDER BY album;

-- Get the total number of comments for tracks where licensed = TRUE
SELECT SUM(comments) AS total_comments FROM spotify WHERE licensed = TRUE;

-- Find all tracks that belong to the album type 'single'
SELECT * FROM spotify WHERE album_type = 'single';
SELECT * FROM spotify WHERE album_type LIKE 'single';

-- Count the total number of tracks by each artist
SELECT artist, COUNT(*) AS total_no_songs
FROM spotify
GROUP BY artist
ORDER BY total_no_songs DESC;

SELECT artist, COUNT(*) AS total_no_songs
FROM spotify
GROUP BY artist
ORDER BY total_no_songs ASC;

-- Calculate the average danceability of tracks in each album
SELECT album, AVG(danceability) AS avg_danceability
FROM spotify 
GROUP BY album
ORDER BY avg_danceability DESC;

-- Find the top 5 tracks with the highest energy values
SELECT track, MAX(energy) AS max_energy
FROM spotify
GROUP BY track
ORDER BY max_energy DESC
LIMIT 5;

-- List all tracks along with their views and likes where official_video = TRUE
SELECT track, SUM(views) AS total_views, SUM(likes) AS total_likes
FROM spotify
WHERE official_video = TRUE
GROUP BY track
ORDER BY total_views DESC
LIMIT 5;

-- For each album, calculate the total views of all associated tracks
SELECT album, SUM(views) AS total_views
FROM spotify 
GROUP BY album
ORDER BY total_views DESC;

-- Retrieve the track names that have been streamed on Spotify more than YouTube
SELECT *
FROM (
    SELECT 
        track,
        COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) AS streamed_on_spotify,
        COALESCE(SUM(CASE WHEN most_played_on = 'YouTube' THEN stream END), 0) AS streamed_on_youtube
    FROM spotify
    GROUP BY track
) AS tb1
WHERE streamed_on_spotify > streamed_on_youtube AND streamed_on_youtube <> 0;

-- Find the top 3 most-viewed tracks for each artist using window functions
WITH ranking_artist AS (
    SELECT 
        artist,
        track, 
        SUM(views) AS total_views,
        DENSE_RANK() OVER (PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
    FROM spotify
    GROUP BY artist, track
)
SELECT *
FROM ranking_artist
WHERE rank <= 3;

-- Write a query to find tracks where the liveness score is above the average
SELECT track, artist, liveness
FROM spotify 
WHERE liveness > (SELECT AVG(liveness) FROM spotify);

-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album
WITH energy_level AS (
    SELECT 
        album,
        MAX(energy) AS max_energy,
        MIN(energy) AS low_energy
    FROM spotify 
    GROUP BY album
)
SELECT 
    album,
    max_energy - low_energy AS energy_difference
FROM energy_level
ORDER BY energy_difference DESC;

-- Find tracks where the energy-to-liveness ratio is greater than 1.2
SELECT *
FROM spotify
WHERE (energy / liveness) > 1.2;

-- Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions
SELECT 
    *,
    SUM(likes) OVER (ORDER BY views) AS cumulative_likes
FROM spotify
ORDER BY views DESC;

-- Calculate the Energy-to-Liveness Ratio
WITH artist_energy_liveness AS (
    SELECT 
        artist,
        AVG(energy / NULLIF(liveness, 0)) AS avg_energy_liveness,
        COUNT(track) AS track_count
    FROM spotify 
    GROUP BY artist
    HAVING COUNT(track) >= 5
)
SELECT 
    artist,
    avg_energy_liveness
FROM artist_energy_liveness
ORDER BY avg_energy_liveness DESC 
LIMIT 3;

-- Identify the top 3 tracks with the highest number of likes for each album
WITH ranked_tracks AS (
    SELECT 
        artist,
        track,
        album,
        likes,
        RANK() OVER (PARTITION BY album ORDER BY likes DESC) AS rank
    FROM spotify
)
SELECT 
    artist,
    track,
    album,
    likes
FROM ranked_tracks
WHERE rank <= 3
ORDER BY album, rank;
