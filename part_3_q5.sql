--  Which channeltitle has produced the most videos and what is this number?


SELECT CHANNELTITLE,
       COUNT(DISTINCT(TITLE)) as No_Channel_vids
FROM table_youtube_final
  GROUP BY CHANNELTITLE
  ORDER BY No_Channel_vids DESC
  LIMIT 1;

--  The channel title is 'Colours TV' with 809 videos

--  After checking their youtube page and seeing that they're putting out multiple videos --  a day some getting +100,000 views in 15 hours makes this result seem credible
