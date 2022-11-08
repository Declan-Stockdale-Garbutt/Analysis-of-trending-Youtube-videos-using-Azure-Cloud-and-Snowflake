--  What are the 3 most viewed videos for each country in the “Sports” category for the
--  trending_date = ‘'2021-10-17'’. Order the result by country and the rank, e.g:

-- nested query
SELECT
    *
FROM
    (
      -- select relevant columns and rank over partition by country
       -- order the resuls by rank descending
        SELECT
            COUNTRY,
            TITLE,
            CHANNELTITLE,
            VIEW_COUNT,
            RANK() OVER (
                PARTITION BY COUNTRY
                ORDER BY
                    VIEW_COUNT DESC
            ) AS RANK
        FROM
            table_youtube_final
        WHERE
        -- limit results to these chosen fields and values
            trending_date = '2021-10-17'
            AND CATEGORY_TITLE = 'Sports'
    ) t
WHERE
-- find top 3 for each country
    Rank <= 3;
