-- Assignment Q2
-- In “table_youtube_category” which category_title only appears in one country?
-- USA has a unique category - Unique Categoriy id is Nonprofits & Activism

-- Count how many times a category appears, since there should only be one of the missing category
-- We can limit the result ot 1 once we order by ascending
SELECT
    CATEGORY_TITLE,
    COUNT(CATEGORY_TITLE)
FROM
    table_youtube_category
GROUP BY
    CATEGORY_TITLE
ORDER BY
    COUNT(CATEGORY_TITLE) ASC
LIMIT 1;

-- Find the country where Nonprofits & Activism is labelled by limiting category to Nonprofits & Activism
SELECT
    Country
FROM
    table_youtube_category
WHERE
    CATEGORY_TITLE = 'Nonprofits & Activism';
