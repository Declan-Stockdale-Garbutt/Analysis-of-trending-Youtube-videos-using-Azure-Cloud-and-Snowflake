---------------------------------
-- Create database for assignment 1

CREATE DATABASE assignment1;
USE DATABASE assignment1;

---------------------------------
-- Integrate into azure storage using azure tenant id and storage

CREATE OR REPLACE STORAGE INTEGRATION azure_assignment1
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = AZURE
  ENABLED = TRUE
  AZURE_TENANT_ID = 'e8911c26-cf9f-4a9c-878e-527807be8791'
  STORAGE_ALLOWED_LOCATIONS = ('azure://utsdeclandb.blob.core.windows.net/assignment1');

DESC STORAGE INTEGRATION azure_assignment1;

---------------------------------
-- Create staging process for all uploaded files from YouTube datasets

CREATE OR REPLACE STAGE stage_assignment1
  STORAGE_INTEGRATION = azure_assignment1
  URL='azure://utsdeclandb.blob.core.windows.net/assignment1';

 -- See which files are available
list @stage_assignment1;

---------------------------------
-- Create external table for json files for category id info

CREATE OR REPLACE EXTERNAL TABLE ex_category_id
  WITH LOCATION = @stage_assignment1
       FILE_FORMAT = (TYPE=JSON)
       FILE_FORMAT = (TYPE=JSON, STRIP_OUTER_ARRAY=TRUE)
       PATTERN = '.*[.]json';


---------------------------------
-- Defining column names for trending youtube videos (first row of csv)
CREATE OR REPLACE EXTERNAL TABLE ex_youtube_trending_columns_name
  WITH LOCATION = @stage_assignment1
       FILE_FORMAT = (TYPE=CSV)
       PATTERN =  '.*[.]csv';

-- Set formatting
CREATE OR REPLACE FILE FORMAT file_format_csv
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  NULL_IF = ('\\N', 'NULL', 'NUL', '')
  FIELD_OPTIONALLY_ENCLOSED_BY = '"';

-- Create external table for csv files for trending youtube videos
CREATE OR REPLACE EXTERNAL TABLE ex_youtube_trending
WITH LOCATION = @stage_assignment1
     FILE_FORMAT = (TYPE=CSV)
     PATTERN = '.*[.]csv';

-- Create table using predefined csv header formatting and data types based on column
CREATE OR REPLACE EXTERNAL TABLE ex_youtube_trending
(
  video_id varchar as (value:c1::varchar),
  title varchar as (value:c2::varchar),
  publishedAt date as (value:c3::date),
  channelId varchar as (value:c4::varchar),
  channelTitle varchar as (value:c5::varchar),
  categoryId int as (value:c6::int),
  trending_date date as (value:c7::date),
  view_count int as (value:c8::int),
  likes int as (value:c9::int),
  dislikes int as (value:c10::int),
  comment_count int as (value:c11::int),
  comments_disabled varchar as (value:c12::varchar),
  COUNTRY varchar as split_part(metadata$filename,'_', 1)
)
WITH LOCATION = @stage_assignment1
     FILE_FORMAT = file_format_csv
     PATTERN = '.*[.]csv';

----------------------------------------------------
-- Create table for video ID
CREATE OR REPLACE TABLE table_youtube_category AS
    SELECT
        split_part(metadata$filename,'_', 1)::varchar as COUNTRY,
        l.value:id::int                   as CATEGORYID,
        l.value:snippet.title::varchar        as CATEGORY_TITLE
    FROM ex_category_id,
    , LATERAL FLATTEN(input=>value:items) as  l;

----------------------------------------------------
-- Create table for trending youtube videos from external table
create or replace table table_youtube_trending as
    Select *
    From ex_youtube_trending;

-- Drop column value
ALTER TABLE table_youtube_trending
DROP COLUMN value;

----------------------------------------------------
-- Create final table called table_youtube_final
-- Join on  country and categoryid
-- ADD uuiq (primary key) in process

-- Use Left join to join both tables on Country and Category ID
CREATE OR REPLACE TABLE table_youtube_final AS
    SELECT uuid_string() AS ID,VIDEO_ID,TITLE, PUBLISHEDAT, CHANNELID, CHANNELTITLE, one.CATEGORYID,CATEGORY_TITLE, TRENDING_DATE, VIEW_COUNT, LIKES, DISLIKES, COMMENT_COUNT, COMMENTS_DISABLED, one.COUNTRY
    FROM table_youtube_trending AS one
    LEFT JOIN table_youtube_category AS two
    ON (one.COUNTRY = two.COUNTRY AND one.CATEGORYID = two.CATEGORYID);

----------------------------------------------------------------
-- Look for duplicates across all rows  -> 1.2k results (Duplicates will have a count >1)
SELECT VIDEO_ID,
       TITLE,
       PUBLISHEDAT,
       CHANNELID,
       CHANNELTITLE,
       CATEGORYID,
       TRENDING_DATE,
       VIEW_COUNT,
       LIKES,
       DISLIKES,
       COMMENT_COUNT,
       COMMENTS_DISABLED,
       COUNTRY,
       COUNT(*)
  FROM table_youtube_final
  GROUP BY VIDEO_ID,TITLE,PUBLISHEDAT,CHANNELID, CHANNELTITLE,CATEGORYID,TRENDING_DATE,VIEW_COUNT,LIKES,DISLIKES,COMMENT_COUNT,COMMENTS_DISABLED,COUNTRY
  HAVING COUNT(*) > 1;

---------------------------------------------
-- USE UUID as a PK to remove duplicate rows

-- Could use either max ID as higher view count occurs first
-- Deletes values duplicates where the duplicate has a higher ID and remove those keeping only the one with the lower ID value
--  Min or Max ID are interchangeable here as long as one is deleted
DELETE FROM table_youtube_final
WHERE ID NOT IN
(
    SELECT MIN(ID)
      FROM table_youtube_final
      GROUP BY VIDEO_ID,TITLE,PUBLISHEDAT,CHANNELID, CHANNELTITLE,CATEGORYID,TRENDING_DATE,VIEW_COUNT,LIKES,DISLIKES,COMMENT_COUNT,COMMENTS_DISABLED,COUNTRY
);

----

-- Validating things were properly deleted using below values
-- VIDEO_ID = 6uMhFsKP2AQ and VIEW_COUNT = 496018 - > only one value should appear which it does (496018)

SELECT *
FROM table_youtube_final
  WHERE VIDEO_ID = '6uMhFsKP2AQ'
  AND VIEW_COUNT = '496018';
