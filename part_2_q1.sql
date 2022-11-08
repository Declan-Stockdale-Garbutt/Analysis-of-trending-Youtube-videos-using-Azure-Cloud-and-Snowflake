-- Assignment Questions 1
-- In “table_youtube_category” which category_title has duplicates if we don’t take into
-- account the categoryid?
-- ANSWER Comedy

-- Select relevant columns and count how many times a category title appears
-- Order it by descending so first row is the answer
SELECT
    COUNTRY,
    CATEGORY_TITLE,
    COUNT(CATEGORY_TITLE)
FROM
    table_youtube_category
GROUP BY
    CATEGORY_TITLE,
    COUNTRY
ORDER BY
    COUNT(CATEGORY_TITLE) DESC;

------------------------------------------------------------------------------
-- Checking results
  -- Checking Category ID's across both tables to see if there is any ofter discrepencies
  -- table_youtube_category has numerous extra categories
  -- These will be removed on a join
  -- Only comedy 23 not 34 exists in other table so we don' have to worry about it due to the subsequent join we'll poerform

 -- SELECT CATEGORY_TITLE, (CATEGORYID)
 --     FROM table_youtube_category
 --     GROUP BY CATEGORY_TITLE,CATEGORYID
 --     ORDER BY CATEGORYID;

 -- SELECT (CATEGORYID)
 --     FROM table_youtube_trending
 --     GROUP BY CATEGORYID
 --     ORDER BY CATEGORYID;
