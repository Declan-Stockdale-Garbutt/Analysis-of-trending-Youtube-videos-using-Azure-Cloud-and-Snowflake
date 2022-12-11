# Analysis of trending Youtube videos using Azure Cloud and Snowflake

Full report available here

https://github.com/Declan-Stockdale/Youtube_trending_videos/blob/master/Hand%20over%20report%20big%20data%20engineering.docx

Assignment as part of Big Data Engineering subject

## Overview
The aim of this project was t to analyse and the explore the trending youtube dataset and explroed various business questions. 
The final goal was to determine which genre of channel would be most likely to result in a profitable business model

There are numerous SQL queries along with resulting csv files which are uploaded. These were part of th assignment brief and may not be directly refernced in the report

## Data source
The data was sourced from Kaggle (https://www.kaggle.com/rsrishav/youtube-trending-video-dataset) during late 2021. 
The data source contains information on various trending videos across various categories and various global locations  

## Data Loading
The downloaded files came in two formats, csv for video information which was missing category title and json for which had category id and category title. These were loaded into separate tables (table_youtube_trending and table_youtube_category) before being combined as a final table on category ID which was shared across both tables with 1,174,255 rows (table_youtube_final).

## Data Cleaning
There were 1,223 videos which occurred twice. A UUID string was applied as a primary key and the duplicate video with a higher value was removed. This resulted in 1223 less rows.

The table_youtube_category contained category id’s not in the table_youtube_trending (horror, foreign etc.) including two numerical ids for the ‘Comedy’ category (23 and 34). Only 23 exists in table_youtube_category. As the tables are merged on common ID values, no extra steps have to be performed to remove these.

The category_id 29 was present in both tables however only the category name of ‘Nonprofits & Activism’ was provided in the USA category data with other country data giving a null name. This was rectified by updating the table so that all null category name with category id of 29 were set to ‘Nonprofits & Activism’.

There was one video_id (‘9b9MovPPewk’) with a missing channel title which belonged to ‘Juvis Productions’). 

The way the trending videos were collected sometimes resulted in two records for a trending video within the same day and country. We are only interested in the video with the higher view count. A new duplicate table of the records was created by partitioning by Country, trending date and video id and keeping the vales with a lower view count. The lower view count duplicates were removed from the original table resulting in resulting in a final count of 1,123,846 records.

## Examples of output

### 1 . Find channel with most distinct trending videos
```
SELECT CHANNELTITLE,
       COUNT(DISTINCT(TITLE)) as No_Channel_vids
FROM table_youtube_final
  GROUP BY CHANNELTITLE
  ORDER BY No_Channel_vids DESC
  LIMIT 1;
```
Result is 'Colours TV' with 809 videos
![image](https://user-images.githubusercontent.com/53500810/206882151-d3aecd26-929f-44ae-9f8d-692e0d388165.png)

### 2. For each country, find the category with the most videos

```
SELECT
    t1.COUNTRY,
    CATEGORY_TITLE,
    TOTAL_CATEGORY_VIDEO,
    TOTAL_COUNTRY_VIDEO,
    -- convert datatype to use to round results for each category in each county as a percentage
    ROUND(
        CAST(TOTAL_CATEGORY_VIDEO as Numeric) / CAST(TOTAL_COUNTRY_VIDEO as Numeric) * 100,
        2
    ) AS PERCENTAGE
FROM
    (
        --  Get number of videos in each country for all categories
        SELECT
            COUNTRY,
            -- count num of videos per country
            SUM(NUM_VIDS_PER_CATEGORY) AS TOTAL_COUNTRY_VIDEO
        FROM
            (
                SELECT
                    COUNTRY,
                    CATEGORY_TITLE,
                    -- count unique titles
                    COUNT((TITLE)) as NUM_VIDS_PER_CATEGORY
                FROM
                    table_youtube_final
                GROUP BY
                    COUNTRY,
                    CATEGORY_TITLE
                ORDER BY
                    COUNTRY,
                    NUM_VIDS_PER_CATEGORY DESC
            )
        GROUP BY
            COUNTRY
    ) t1
    INNER JOIN --  Get number of videos in each country for most populated category
    (
        SELECT
            COUNTRY,
            CATEGORY_TITLE,
            -- count num of vids per category
            SUM(NUM_VIDS_PER_CATEGORY) AS TOTAL_CATEGORY_VIDEO
        FROM
            (
                SELECT
                    COUNTRY,
                    CATEGORY_TITLE,
                    COUNT((TITLE)) as NUM_VIDS_PER_CATEGORY,
                    RANK() OVER (
                        PARTITION BY COUNTRY
                        ORDER BY
                            NUM_VIDS_PER_CATEGORY DESC
                    ) AS RANK
                FROM
                    table_youtube_final
                GROUP BY
                    COUNTRY,
                    CATEGORY_TITLE
                ORDER BY
                    COUNTRY,
                    NUM_VIDS_PER_CATEGORY DESC
            )
        WHERE
        -- only returrn top result
            Rank = 1
        GROUP BY
            COUNTRY,
            CATEGORY_TITLE
            -- join on COUNTRY
    ) t2 ON t1.COUNTRY = t2.COUNTRY;
```

![image](https://user-images.githubusercontent.com/53500810/206882370-943ed1f4-ed86-483e-9b8c-48734396f070.png)

### 3. Which category is best?

Remove NonProfit due to political videos and foreign issues
```
SELECT
    * 
FROM
    table_youtube_final
  WHERE
      CATEGORY_TITLE = 'Nonprofits & Activism'
  ORDER BY
      COMMENT_COUNT DESC;

```

Additionally remove Music, Entertainment, Nonprofits & Activism due to potential copyright issues

```
CREATE or REPLACE TABLE valid_categories as
SELECT
    *
FROM
    table_youtube_final
  WHERE
      not CATEGORY_TITLE = 'Music'
      AND NOT CATEGORY_TITLE = 'Entertainment'
      AND NOT CATEGORY_TITLE = 'Nonprofits & Activism';
```

### 4. Which categories have the most market share for each region

```
SELECT
    *
FROM(
        select -- get relvant infomations and perform aggregations
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
```

![image](https://user-images.githubusercontent.com/53500810/206882555-5839f257-845f-4b9e-a706-33b35001f3a8.png)

### 5. Average view count for each category

```
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
        ) AS latest ON first.CATEGORY_TITLE = latest.CATEGORY_TITLE;
```

![image](https://user-images.githubusercontent.com/53500810/206882659-968b40d4-7b6d-43b6-9295-8a55bbac1fbe.png)

### Final recomendation

This recommendations from this report are to start a new channel in the Science and Technology category. This is due to the high average view count and comments numbers per video along with the low number of unique channels may mean less competition and more immediate impact of videos reaching a trending status. From the year from 2020 -2021 the category saw relatively small changes in average viewership and unique channel numbers meaning the category is relatively stable and not likely to experience wild trends over the foreseeable future. 
The categories by average view count can be seen in figure 12. Science and Technology makes a sizeable proportion of each country’s average viewership by category, and from figure 13 we can see that it’s ranked in the top 4 in every country by average views.

