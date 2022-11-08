-- Delete the duplicates in “table_youtube_final“ by using table_youtube_duplicates
-- Successful query

-- duplicates from  table_youtube_final bases on ID (UUID)
-- Should remove lower view count duplicates
DELETE FROM
    table_youtube_final using table_youtube_duplicates
WHERE
    table_youtube_final.ID = table_youtube_duplicates.ID;


----------------
-- Veryfying after deletetion
-- using random value that accors in duplicate table
-- [  SELECT *
--   FROM
--       table_youtube_duplicates
--   WHERE
--       VIDEO_ID = 'F1JTlnHGa90'
--       AND COUNTRY = 'GB'
--       AND TRENDING_DATE = '2021-06-11';
--
--   -- using same random that occurs twice before removing with tow view counts and only once after wards
--
--   SELECT
--       *
--   FROM
--       table_youtube_final
--   WHERE
--       VIDEO_ID = 'F1JTlnHGa90'
--       AND COUNTRY = 'GB'
--       AND TRENDING_DATE = '2021-06-11';]
