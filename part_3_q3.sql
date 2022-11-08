--  For each country, year and month (in a single column), which video is the most
--  viewed and what is its likes_ratio (defined as the percentage of likes against
--  view_count) truncated to 2 decimals. Order the result by year_month and country.
--  Some videos don't have any likes such as some youtube shorts videos possibly due to youtube caning the publically available information
--  This may be problematic as we may end up with a ratio of 0
--  Can't get the decimals to show trailing 0 round(value,2,1 ) isn't working.

-- NEsted Query
-- get all relevant results from
SELECT
    COUNTRY,
    YEAR_MONTH,
    TITLE,
    CHANNELTITLE,
    CATEGORY_TITLE,
    VIEW_COUNT,
    LIKES_RATIO
FROM
    (
        SELECT
            COUNTRY,
            -- remove trailing day from YYYY-MM-DD and replace with "-01" and name YEAR_MONTH
            concat(
                SUBSTRING(TRENDING_DATE, 1, LEN(TRENDING_DATE) -3),
                '-01'
            ) AS YEAR_MONTH,
            TITLE,
            CHANNELTITLE,
            CATEGORY_TITLE,
            VIEW_COUNT,
            -- Aggregate likes/view count as a % and orund to 2dp
            ROUND(
                CAST(LIKES as Numeric) / CAST(VIEW_COUNT as Numeric) * 100,
                2
            ) AS LIKES_RATIO,
            -- rank over the view count by partitioning by country and YEAR_MONTH
            RANK() OVER (
                PARTITION BY COUNTRY,
                YEAR_MONTH
                ORDER BY
                    VIEW_COUNT DESC
            ) AS RANK
        FROM
            table_youtube_final
    ) t
WHERE
-- only get top result for each country and YEAR_MONTH
    Rank = 1
ORDER BY
    YEAR_MONTH,
    COUNTRY;
