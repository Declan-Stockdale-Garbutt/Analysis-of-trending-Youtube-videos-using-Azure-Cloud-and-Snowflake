-- Question 6
-- Delete from “table_youtube_final“, any record with video_id = “#NAME?”
-- 14603 records of #NAME?

-- Select all videos and group and count
-- Where video id is #name?
SELECT
    video_id,
    count(video_id)
FROM
    table_youtube_final
WHERE
    video_id = '#NAME?'
GROUP BY
    video_id;

-- Deleting all 14603 records where video is #name
DELETE FROM
    table_youtube_final
WHERE
    video_id = '#NAME?';
