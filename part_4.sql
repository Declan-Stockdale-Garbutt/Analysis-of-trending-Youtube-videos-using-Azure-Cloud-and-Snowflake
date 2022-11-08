--  If you were to launch a new Youtube channel tomorrow, which category (excluding “Music”
--  and “Entertainment”) of video will you be trying to create to have them appear in the top trend of Youtube? Will this  strategy work in every country?

-----------------------------------------
--  Assume we dont want to start in the non-prift category as well
 --  Just to see what types of videos get the most traction in this category lets see the most viewed
SELECT
    * -- DISTINCT(CATEGORY_TITLE)
FROM
    table_youtube_final
  WHERE
      CATEGORY_TITLE = 'Nonprofits & Activism'
  ORDER BY
      COMMENT_COUNT DESC;
--  The highest videos are mostly foreign and about politics.

-----------------------------------------------------------------------------------------------
--  Removing Music, Nonprofits & Activism and Entertainment into table called valid_categories size is about half of original
CREATE or REPLACE TABLE valid_categories as
SELECT
    *
FROM
    table_youtube_final
  WHERE
      not CATEGORY_TITLE = 'Music'
      AND NOT CATEGORY_TITLE = 'Entertainment'
      AND NOT CATEGORY_TITLE = 'Nonprofits & Activism';


  ------------------------------------------------------------------------------------------------
  -- See Change from 2020-09-01 to 2021-12-01 penultimate date in dataset incase there are missing records in first or last month of data.  --- This is unlikely but the date range chosen should be similar to the missing months so no information or trends should be lost (hopefully)
    SELECT
        -- get values and find averages using table aliases and find differences between months
        first.CATEGORY_TITLE,
        first.NUMBER_DISTINCT_VIDEOS as initial_videos,
        latest.NUMBER_DISTINCT_VIDEOS as final_videos,
        latest.NUMBER_DISTINCT_VIDEOS - first.NUMBER_DISTINCT_VIDEOS as CHANGE_VIDEOS,
        first.NUMBER_DISTINCT_CHANNELS initial_channels,
        latest.NUMBER_DISTINCT_CHANNELS as final_videos,
        latest.NUMBER_DISTINCT_CHANNELS - first.NUMBER_DISTINCT_CHANNELS as CHANGE_CHANNELS,
        first.AVG_VIEWS as initial_views,
        latest.AVG_VIEWS as final_views,
        latest.AVG_VIEWS - first.AVG_VIEWS as CHANGE_AVG_VIEWS,
        first.AVG_LIKES as initial_likes,
        latest.AVG_LIKES as final_likes,
        latest.AVG_LIKES - first.AVG_LIKES as CHANGE_AVG_LIKES,
        first.AVG_COMMENTS as initial_comments,
        latest.AVG_COMMENTS as final_comments,
        latest.AVG_COMMENTS - first.AVG_COMMENTS as CHANGE_AVG_COMMENTS //latest.SUM(VIEW_COUNT) - latest.SUM(VIEW_COUNT) as CHANGE_VIEGS
    FROM
        (
            -- get all relevant data from second earliest month and perform aggregations
            Select
                CATEGORY_TITLE,
                YEAR_MONTH,
                COUNT(DISTINCT(TITLE)) as number_distinct_videos,
                COUNT(DISTINCT(CHANNELID)) as number_distinct_channels,
                ROUND(SUM(VIEW_COUNT) / number_distinct_videos, 0) as AVG_VIEWS,
                ROUND(SUM(LIKES) / number_distinct_videos, 0) as AVG_LIKES,
                ROUND(SUM(COMMENT_COUNT) / number_distinct_videos, 0) as AVG_COMMENTS
            FROM
                valid_categories_monthly
              WHERE
                  YEAR_MONTH = '2020-09-01'
              GROUP BY
                  CATEGORY_TITLE,
                  YEAR_MONTH
              ORDER BY
                  CATEGORY_TITLE,
                  YEAR_MONTH

        ) as first

        INNER JOIN (
          -- get all relevant data from second latest month and perform aggregations
            SELECT
                CATEGORY_TITLE,
                YEAR_MONTH,
                COUNT(DISTINCT(TITLE)) as number_distinct_videos,
                COUNT(DISTINCT(CHANNELID)) as number_distinct_channels,
                ROUND(SUM(VIEW_COUNT) / number_distinct_videos, 0) as AVG_VIEWS,
                ROUND(SUM(LIKES) / number_distinct_videos, 0) as AVG_LIKES,
                ROUND(SUM(COMMENT_COUNT) / number_distinct_videos, 0) as AVG_COMMENTS
            FROM
                valid_categories_monthly
              WHERE
                  YEAR_MONTH = '2021-12-01'
              GROUP BY
                  CATEGORY_TITLE,
                  YEAR_MONTH
              ORDER BY
                  CATEGORY_TITLE,
                  YEAR_MONTH
        ) AS latest ON first.CATEGORY_TITLE = latest.CATEGORY_TITLE; -- Join on category titles
----------------------------------------
-- It's entirely possible that average views is a misleading metric. The reasoning is that viewers who only view the video for a fwe seconds woud be counted as a viewer. THe youtube algorithm may have also changed during the data collection period skewing the view count. A better metric may be like as it measures a level of engagement from he viewer, comments woul also act in a similar manner but may be harder to meaningfully measure due to some videos having them disabled.
    -- Inital suggestion would be to rank the channel categories by the average view count, average like, then comment by the number of distinct videos released
SELECT
    *
FROM(
        SELECT

        -- get all data and make new columns based on aggregations
            CATEGORY_TITLE,
            count(DISTINCT(TITLE)) AS number_of_unique_videos,
            SUM(VIEW_COUNT) AS TOTAL_VIEWS,
            ROUND(TOTAL_VIEWS / number_of_unique_videos, 0) AS avg_views,
            SUM(COMMENT_COUNT) AS TOTAL_COMMENTS,
            ROUND(TOTAL_COMMENTS / number_of_unique_videos, 0) AS avg_comments,
            SUM(LIKES) AS TOTAL_LIKES,
            ROUND(TOTAL_LIKES / number_of_unique_videos, 0) AS avg_likes,
            ROW_NUMBER() OVER(
                ORDER BY
                    avg_views DESC
            ) AS AVG_VIEW_RANK
        FROM
            valid_categories_monthly
        GROUP BY
            CATEGORY_TITLE
        ORDER BY
            AVG_VIEW_RANK ASC
    );

---------------------------------------
-- Query used to find category make up by chosen catgories which appeared to have the most impoact

-- Select all
SELECT
    *
FROM(
        select -- get relvant infomations and perform aggregations
        -- Dense ank used in case of duplicates
            COUNTRY,
            CATEGORY_TITLE,
            count(DISTINCT(TITLE)) AS number_of_unique_videos,
            SUM(VIEW_COUNT) AS TOTAL_VIEWS,
            ROUND(TOTAL_VIEWS / number_of_unique_videos, 0) AS avg_views,
            SUM(COMMENT_COUNT) AS TOTAL_COMMENTS,
            ROUND(TOTAL_COMMENTS / number_of_unique_videos, 0) AS avg_comments,
            SUM(LIKES) AS TOTAL_LIKES,
            ROUND(TOTAL_LIKES / number_of_unique_videos, 0) AS avg_likes,
            DENSE_RANK() OVER(PARTITION BY COUNTRY ORDER BY avg_views DESC) AS RANK
        FROM
            valid_categories_monthly
          GROUP BY
              CATEGORY_TITLE,COUNTRY
          ORDER BY
              COUNTRY,RANK ASC
    )
    -- get categories that I want, snowflake groups rest as other and which is 5 other categories which skews the final bar graph
    WHERE CATEGORY_TITLE = 'Science & Technology'
       OR CATEGORY_TITLE = 'Comedy'
       OR CATEGORY_TITLE = 'Education'
       OR CATEGORY_TITLE =  'Film & Animation'
       OR CATEGORY_TITLE =  'Gaming'
       OR CATEGORY_TITLE =  'People & Blogs'
       OR CATEGORY_TITLE =  'Sport';
