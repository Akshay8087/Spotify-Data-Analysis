# Spotify Data Analysis

![Spotify Logo Animation](https://github.com/user-attachments/assets/9a6c66b6-6699-48c7-99a4-3b0e151ac94d)



## Overview

This project provides a comprehensive analysis of Spotify tracks, focusing on various audio features and engagement metrics. The analysis includes data exploration and various SQL queries designed to uncover insights regarding artists, tracks, albums, and their respective performance on Spotify and other platforms like YouTube.

## Table of Contents

- [Technologies](#technologies)
- [Dataset Description](#dataset-description)
- [Data Exploration](#data-exploration)
- [Data Cleaning](#data-cleaning)
- [Data Analysis](#data-analysis)
- [SQL Queries](#sql-queries)
- [Conclusion](#conclusion)
- [Query Optimization Technique](#Query-Optimization-Technique)


## Technologies

## Technologies Used

| Technology                          | Description                                                            |
|-------------------------------------|------------------------------------------------------------------------|
| SQL                                 | Structured Query Language for managing and querying relational databases. |
| Database Management System          | PostgreSQL - An open-source relational database system that supports SQL. |
| Data Analysis Tools                 | pgAdmin - A web-based database management tool for PostgreSQL.        |


## Dataset Description

The dataset used in this project contains various attributes related to tracks on Spotify, including but not limited to:

| Column Name       | Description                                                          |
|-------------------|----------------------------------------------------------------------|
| **artist**        | Name of the artist                                                  |
| **track**         | Name of the track                                                   |
| **album**         | Name of the album                                                   |
| **album_type**    | Type of the album (e.g., album, single)                           |
| **danceability**  | Danceability score of the track                                     |
| **energy**        | Energy score of the track                                           |
| **loudness**      | Loudness of the track in decibels                                   |
| **speechiness**   | Speechiness score of the track                                      |
| **acousticness**  | Acousticness score of the track                                     |
| **instrumentalness** | Instrumentalness score of the track                               |
| **liveness**      | Liveness score of the track                                         |
| **valence**       | Valence score of the track                                          |
| **tempo**         | Tempo of the track in beats per minute                             |
| **duration_min**  | Duration of the track in minutes                                    |
| **title**         | Title of the track                                                  |
| **channel**       | Channel through which the track is streamed                        |
| **views**         | Number of views                                                     |
| **likes**         | Number of likes                                                     |
| **comments**      | Number of comments                                                  |
| **licensed**      | License status of the track (boolean)                               |
| **official_video** | Whether the track has an official video (boolean)                 |
| **stream**        | Number of streams                                                   |
| **energy_liveness** | Energy-to-liveness ratio                                          |
| **most_played_on**| Platform where the track is most played (e.g., Spotify, YouTube)  |


## Data Exploration

Basic exploratory data analysis (EDA) was conducted on the `spotify` table to understand the dataset's structure and characteristics. The following key metrics were analyzed:

- Total number of rows in the dataset
- Unique artists and albums present
- Different album types
- Maximum and minimum duration of tracks

### Key Queries for Data Exploration

1. Total number of rows:
    ```sql
    SELECT COUNT(*) AS total_number_of_rows FROM spotify;
    ```

2. Count distinct artists:
    ```sql
    SELECT COUNT(DISTINCT artist) FROM spotify;
    ```

3. Count distinct albums:
    ```sql
    SELECT COUNT(DISTINCT album) FROM spotify;
    ```

4. List distinct album types:
    ```sql
    SELECT DISTINCT album_type FROM spotify;
    ```

5. Maximum track duration:
    ```sql
    SELECT MAX(duration_min) FROM spotify;
    ```

6. Minimum track duration:
    ```sql
    SELECT MIN(duration_min) FROM spotify;
    ```

## Data Cleaning

During the data exploration, it was observed that some tracks had a duration of 0 minutes. These records were removed to ensure data integrity.

### Key Query for Data Cleaning

1. Delete songs with 0 min duration:
    ```sql
    DELETE FROM spotify WHERE duration_min = 0; -- deleted 2 records
    ```

## Data Analysis

The analysis includes various queries designed to extract meaningful insights from the dataset. This section outlines the queries and their objectives.

### Key Analysis Queries

1. Retrieve tracks with more than 1 billion streams:
    ```sql
    SELECT * FROM spotify WHERE stream > 1000000000;
    ```

2. List all albums along with their respective artists:
    ```sql
    SELECT DISTINCT album, artist FROM spotify ORDER BY album;
    ```

3. Get the total number of comments for tracks where `licensed` is `TRUE`:
    ```sql
    SELECT SUM(comments) AS total_comments FROM spotify WHERE licensed = TRUE;
    ```

4. Find all tracks that belong to the album type 'single':
    ```sql
    SELECT * FROM spotify WHERE album_type = 'single';
    ```

5. Count the total number of tracks by each artist:
    ```sql
    SELECT artist, COUNT(*) AS total_no_songs
    FROM spotify
    GROUP BY artist
    ORDER BY total_no_songs DESC;
    ```

6. Calculate the average danceability of tracks in each album:
    ```sql
    SELECT album, AVG(danceability) AS avg_danceability
    FROM spotify 
    GROUP BY album
    ORDER BY avg_danceability DESC;
    ```

7. Find the top 5 tracks with the highest energy values:
    ```sql
    SELECT track, MAX(energy) AS max_energy
    FROM spotify
    GROUP BY track
    ORDER BY max_energy DESC
    LIMIT 5;
    ```

8. List all tracks along with their views and likes where `official_video` is `TRUE`:
    ```sql
    SELECT track, SUM(views) AS total_views, SUM(likes) AS total_likes
    FROM spotify
    WHERE official_video = TRUE
    GROUP BY track
    ORDER BY total_views DESC
    LIMIT 5;
    ```

9. For each album, calculate the total views of all associated tracks:
    ```sql
    SELECT album, SUM(views) AS total_views
    FROM spotify 
    GROUP BY album
    ORDER BY total_views DESC;
    ```

10. Retrieve the track names that have been streamed on Spotify more than YouTube:
    ```sql
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
    ```

11. Find the top 3 most-viewed tracks for each artist using window functions:
    ```sql
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
    ```

12. Write a query to find tracks where the liveness score is above the average:
    ```sql
    SELECT track, artist, liveness
    FROM spotify 
    WHERE liveness > (SELECT AVG(liveness) FROM spotify);
    ```

13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album:
    ```sql
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
    ```

14. Find tracks where the energy-to-liveness ratio is greater than 1.2:
    ```sql
    SELECT *
    FROM spotify
    WHERE (energy / liveness) > 1.2;
    ```

15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions:
    ```sql
    SELECT 
        *,
        SUM(likes) OVER (ORDER BY views) AS cumulative_likes
    FROM spotify
    ORDER BY views DESC;
    ```

16. Calculate the Energy-to-Liveness Ratio:
    ```sql
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
    ```

17. Identify the top 3 tracks with the highest number of likes for each album:
    ```sql
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
    ```


## Query Optimization Technique

### 1. Initial Query Performance Analysis Using `EXPLAIN`
To improve query performance, we carried out the following optimization process:

We began by analyzing the performance of a query using the `EXPLAIN` function. The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:

- **Execution time (E.T.):** 5.747 ms
- **Planning time (P.T.):** 0.162 ms

The `EXPLAIN` function allowed us to understand how PostgreSQL executed the query, identifying potential areas for improvement.

#### Screenshot of the EXPLAIN result before optimization:
![spotify_explain_before_index (1)](https://github.com/user-attachments/assets/f0edf9d4-c947-443c-bbb2-9d2ef00e3a52)


### 2. Creating an Index on the `artist` Column
To optimize the query, we created an index on the `artist` column. This step reduced the query's execution time significantly by allowing faster lookups for specific artists.





```sql
CREATE INDEX artist_index ON spotify(artist);
```

## Performance Analysis After Index Creation

### 1. Overview
After creating an index on the `artist` column, we re-executed the query and observed significant performance improvements in both execution and planning times. Below, we provide a detailed analysis of the results.

### 2. Key Performance Metrics
- **Execution Time (E.T.):** 0.099 ms
- **Planning Time (P.T.):** 0.098 ms

This demonstrates a **dramatic reduction in query execution time**, as compared to the initial performance before index creation.

### 3. Comparison of Query Performance

| Metric            | Before Optimization | After Index Creation | Improvement (%)  |
|-------------------|---------------------|----------------------|------------------|
| **Execution Time** | 5.747 ms                | 0.099 ms             | ~97.81%          |
| **Planning Time**  | 0.162 ms             | 0.098 ms             | ~10.59%          |


### 4. Explanation of Improvements
- **Index Efficiency:** By adding an index to the `artist` column, the database can now locate specific rows more efficiently without scanning the entire table, which significantly reduces the time required for data retrieval.
- **Faster Execution:** The overall query performance improved due to the reduced need for a full table scan. Instead, the database engine performs an index scan, which is much faster when querying specific columns like `artist`.

### 5. EXPLAIN Analysis Post-Index Creation
To further validate the optimization, we ran the query using the `EXPLAIN` function again. The result showed the database utilizing the newly created index to streamline data retrieval, confirming the improved query execution plan.

#### Screenshot of the EXPLAIN result after index creation:
*Insert the screenshot of the optimized EXPLAIN output here*

### 6. Conclusion
The creation of an index on the `artist` column led to a substantial reduction in both execution and planning times, resulting in optimized query performance. This is a crucial optimization step, especially for larger data


### 3. Graph: Query Execution Time Comparison
#### Before Index Creation
![spotify_explain_before_index (1)](https://github.com/user-attachments/assets/f0edf9d4-c947-443c-bbb2-9d2ef00e3a52)





#### After Index Creation
![Screenshot 2024-09-30 160941](https://github.com/user-attachments/assets/4d3265ae-5693-4acc-9c0c-d40e136a01b7)
![Screenshot 2024-09-30 161239](https://github.com/user-attachments/assets/8f0bdc55-14fb-4d6f-a4a1-78d73154a175)



*The graph above illustrates the significant drop in both execution and planning times after the index creation. This visual representation clearly demonstrates the effectiveness of the optimization.*

### 4. Conclusion
The graphical comparison highlights the substantial improvements in query performance, emphasizing the importance of indexing in database management. The reduced execution time not only enhances user experience but also optimizes resource utilization in database operations.



## Conclusion

The analysis of the Spotify dataset provides valuable insights into track performance, artist popularity, and user engagement metrics. The queries demonstrated in this project can be extended for deeper analysis or applied to other datasets for similar insights. 

## What I Learned

### 1. **SQL Query Writing and Optimization**
   - Developed a deeper understanding of **SQL** for querying relational databases, including complex queries with  `GROUP BY`, and 'window functions'.
   - Gained experience in writing efficient queries to retrieve insights from large datasets.
   - Optimized SQL queries to ensure performance efficiency when dealing with large volumes of data.

### 2. **Data Exploration and Cleaning**
   - Applied data exploration techniques to understand the dataset structure, including identifying trends and patterns in audio features like danceability, energy, and tempo.
   - Performed data cleaning by removing invalid or missing values, such as tracks with zero duration, ensuring the accuracy of the analysis.

### 3. **Analytical Thinking and Insights Generation**
   - Developed a better understanding of how to derive actionable insights from data, including identifying the most popular tracks, artists, and albums.
   - Gained experience in using SQL to compare metrics such as streams, views, and likes between platforms like Spotify and YouTube.

### 4. **Data Aggregation and Grouping**
   - Learned how to effectively group data by categories such as artist, album, and track to perform aggregated calculations like averages, sums, and counts.
   - Applied advanced SQL concepts like window functions to rank and analyze top-performing tracks and artists.

### 5. **Working with PostgreSQL and pgAdmin**
   - Enhanced skills in using **PostgreSQL** for database management, querying, and data manipulation.
   - Utilized **pgAdmin** to manage databases, execute queries, and visualize data for effective analysis.

### 6. **Feature Analysis in Music Data**
   - Explored how specific audio features like energy, danceability, and liveness affect the popularity of songs.
   - Gained insights into the relationship between music characteristics and user engagement metrics such as streams, likes, and views.

### 7. **Real-World Application of Data Analysis**
   - This project provided an opportunity to work on a real-world dataset, strengthening my ability to apply analytical techniques to understand and extract meaningful insights from large datasets.


