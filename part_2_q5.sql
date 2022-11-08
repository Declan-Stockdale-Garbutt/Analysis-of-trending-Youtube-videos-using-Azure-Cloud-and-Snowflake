-- Question 5 I
-- In “table_youtube_final”, which video doesn’t have a channeltitle? -> 9b9MovPPewk
-- -> 9b9MovPPewk

-- Search only channel titles and video id to find potential missing channel names
-- Only give answer if channel title is null

SELECT
    CHANNELTITLE,
    VIDEO_ID
FROM
    table_youtube_final
WHERE
    CHANNELTITLE is null;

----------------------------------
-- Investigate if the video has an channel in other rows using video Id from aboce query
SELECT
    CHANNELTITLE,
    VIDEO_ID
FROM
    table_youtube_final
WHERE
    VIDEO_ID = '9b9MovPPewk';

  -------------------------------------------
-- Updating to correct missing channel name
UPDATE table_youtube_final
    SET
    CHANNELTITLE = 'Juvis Productions'
WHERE
    VIDEO_ID = '9b9MovPPewk'
    AND CHANNELTITLE is NULL;
