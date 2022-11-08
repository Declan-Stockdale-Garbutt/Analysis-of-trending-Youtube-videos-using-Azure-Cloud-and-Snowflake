--Part 2 Question 7

--The “table_youtube_final“ contains duplicates with the same video_id, country and
--trending_date however their metrics (likes, dislikes, etc..) can be different. E.g:
-- We can assume that the highest number of view_count will be the record to keep when we
--have duplicates.
-- Create a new table called “table_youtube_duplicates” containing only the “bad”
-- duplicates by using the row_number() function.

-- Selecting only video_id, country and trending_date and use groupby to count duplicates
-- Duplicates will have a cout more than 1 o filter any that only occur once using te having clause
SELECT
    VIDEO_ID,
    TRENDING_DATE,
    COUNTRY,
    COUNT(*) AS DUPLICATES_COUNT
FROM
    table_youtube_final
GROUP BY
    VIDEO_ID,
    TRENDING_DATE,
    COUNTRY
HAVING
    COUNT(*) > 1;

-- Create a new table containin the duplicates from above
-- This query gets all the duplicate values with same coutry, video_id and trending data with different view count

-- This query creates a new table with duplicates removed

-- Since we only want the duplicate with the higher view count , only need to select by ID, VIDEO_ID, Trending date, country and View count
-- We can then rank them by partitioning them into VIDEO_ID, Trending date, country and View count ranking by view count in descending order
-- This returns the rank of each duplicate still containing the UUID which we can later filter out by rank 1 and then join back into table

CREATE or REPLACE TABLE table_youtube_duplicates as

SELECT *
FROM
    (
      -- Only selet relevant columns, need ID later to join back into table
      -- Essentially this first query tells me which record to keep from the second query
    SELECT
        d.ID,
        d.VIDEO_ID,
        d.TRENDING_DATE,
        d.COUNTRY,
        VIEW_COUNT,
        -- Add ranking to duplicates by partition by Country, video ID and Country to order duplicates by view count            row_number() over (
            PARTITION BY d.VIDEO_ID,
            d.TRENDING_DATE,
            d.COUNTRY
            ORDER BY
                d.VIDEO_ID,
                d.TRENDING_DATE,
                d.COUNTRY
        ) rownumber
    FROM
        table_youtube_final d -- alias

    INNER JOIN (
         -- We'll join on video id and trending date, we'll also need country as well
         -- This select gets all the duplicate values unordered, first query tells us which one to keep
          SELECT
              VIDEO_ID,
              TRENDING_DATE,
              COUNTRY
          FROM
              table_youtube_final
          GROUP BY
              VIDEO_ID,
              TRENDING_DATE,
              COUNTRY
          HAVING
              COUNT(distinct VIEW_COUNT) > 1
      ) dup

      -- Join on common video id, trending date and country
      -- where ranked duplicate is in original table_youtube_final
      ON dup.VIDEO_ID = d.VIDEO_ID
      AND dup.TRENDING_DATE = d.TRENDING_DATE
      AND dup.COUNTRY = d.COUNTRY

  ORDER BY
      VIDEO_ID,
      TRENDING_DATE,
      COUNTRY
    )
    -- Only join by video with higher view count
WHERE
    ROWNUMBER = 1;
