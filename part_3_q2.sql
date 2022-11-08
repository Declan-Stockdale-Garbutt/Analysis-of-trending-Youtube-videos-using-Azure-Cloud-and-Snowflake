--  For each country, count the number of video with a title containing the word “BTS”
--  and order the result by count in a descending order, e.g:

-- seect whats relevant and count unique titles uppercase as CT
SELECT
    COUNTRY,
    COUNT(Distinct(UPPER(TITLE))) AS CT
FROM
    table_youtube_final
WHERE
-- On chosen term BTS
    contains(TITLE, 'BTS')
GROUP BY
    COUNTRY
ORDER BY
-- order by descening count
    CT DESC;
