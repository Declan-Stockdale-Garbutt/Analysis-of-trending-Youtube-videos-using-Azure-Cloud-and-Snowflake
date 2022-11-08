-- Question 4
-- Update the table_youtube_final to replace the NULL values in category_title with the
-- answer from the previous question
-- Update missing with title of categroy 29
-- What is the title of category 29?
-- -> Nonprofits & Activism

--  Find all results with category 29 and not null category title
SELECT
    CATEGORY_TITLE,
    CATEGORYID
FROM
    table_youtube_final
WHERE
    CATEGORYID = 29
    AND CATEGORY_TITLE IS NOT null
LIMIT
    1;

-- Changing values of null to Nonprofits & Activism
-- Update table to set null category title to correct one only when the id is 29
UPDATE
    table_youtube_final
SET
    CATEGORY_TITLE = 'Nonprofits & Activism'
WHERE
    CATEGORYID = 29
    AND CATEGORY_TITLE is NULL; -- was is not null?

-- Check result - > no results, all null values replaced
-- Check for any null results, there should be none remaining
SELECT
    CATEGORY_TITLE
FROM
    table_youtube_final
WHERE
    CATEGORY_TITLE is null;
