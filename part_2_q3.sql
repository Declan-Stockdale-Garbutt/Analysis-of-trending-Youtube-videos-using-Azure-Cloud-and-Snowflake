-- Question 3
-- In “table_youtube_final”, what is the categoryid of the missing category_title?

-- Select only the category names and id and only search for null values in category title
SELECT
    category_title,
    categoryid
FROM
    table_youtube_final
WHERE
    category_title IS NULL;

-- Missing Category_Title belongs to categoryid 29 no other missing categoryid's
