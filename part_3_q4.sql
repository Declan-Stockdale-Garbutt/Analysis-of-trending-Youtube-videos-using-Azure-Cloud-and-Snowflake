--  For each country, which category_title has the most videos and what is its
--  percentage (2 decimals) out of the total number of videos of that country? Order the
--  result by country.

--select relvant and get table alias
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
