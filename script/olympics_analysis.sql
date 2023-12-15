-- 1. List the total number of Olympic games.

SELECT COUNT(DISTINCT games) AS "Total games"
FROM olympic.athlete_events;

/*
Results:

 Total games
-------------
          51

*/

-- 2. List the total number of nations participating in each game.

SELECT games AS Games, COUNT(DISTINCT noc) AS "No of nations"
FROM olympic.athlete_events
GROUP BY games;

/*
Results:

    games    | No of nations
-------------+---------------
 1896 Summer |            12
 1900 Summer |            31
 1904 Summer |            15
 1906 Summer |            21
 1908 Summer |            22
 1912 Summer |            29
 1920 Summer |            29
 1924 Summer |            45
 1924 Winter |            19
 1928 Summer |            46
 1928 Winter |            25
 1932 Summer |            47
 1932 Winter |            17
 1936 Summer |            49
 1936 Winter |            28
 1948 Summer |            59
 1948 Winter |            28
 1952 Summer |            69
 1952 Winter |            30
 1956 Summer |            72
 1956 Winter |            32
 1960 Summer |            84
 1960 Winter |            30
 1964 Summer |            93
 1964 Winter |            36
 1968 Summer |           112
 1968 Winter |            37
 1972 Summer |           121
-- More  --

*/

-- 3. Which games have the lowest and highest participation by nations?

WITH highest AS (
      SELECT games
      FROM olympic.athlete_events
      GROUP BY games
      ORDER BY COUNT(DISTINCT noc) DESC
      LIMIT 1),
lowest AS (
      SELECT games
      FROM olympic.athlete_events
      GROUP BY games
      ORDER BY COUNT(DISTINCT noc) ASC
      LIMIT 1)
SELECT lowest.games AS "Lowest participation", highest.games AS "Highest participation"
FROM lowest, highest;

/*
Results:

 Lowest participation | Highest participation
----------------------+-----------------------
 1896 Summer          | 2016 Summer

*/

-- 4. Which season has higher participation?

WITH summer AS (
      SELECT COUNT(DISTINCT noc) AS summer_count
      FROM olympic.athlete_events
      WHERE season = 'Summer'
      GROUP BY games),
winter AS (
      SELECT COUNT(DISTINCT noc) AS winter_count
      FROM olympic.athlete_events
      WHERE season = 'Winter'
      GROUP BY games)
SELECT ROUND(SUM(summer.summer_count)/COUNT(summer_count), 2) AS "Average Summer Participation", ROUND(SUM(winter.winter_count)/COUNT(winter_count), 2) AS "Average Winter Participation"
FROM summer, winter;

/*
Results:

 Average Summer Participation | Average Winter Participation
------------------------------+------------------------------
                        96.90 |                        46.68

*/

-- 5. How many sports were held in each game?

SELECT games, COUNT(DISTINCT sport)
FROM olympic.athlete_events
GROUP BY games;

/*
Results:

    games    | count
-------------+-------
 1896 Summer |     9
 1900 Summer |    20
 1904 Summer |    18
 1906 Summer |    13
 1908 Summer |    24
 1912 Summer |    17
 1920 Summer |    25
 1924 Summer |    20
 1924 Winter |    10
 1928 Summer |    17
 1928 Winter |     8
 1932 Summer |    18
 1932 Winter |     7
 1936 Summer |    24
 1936 Winter |     8
 1948 Summer |    20
 1948 Winter |     9
 1952 Summer |    19
 1952 Winter |     8
 1956 Summer |    19
 1956 Winter |     8
 1960 Summer |    19
 1960 Winter |     8
 1964 Summer |    21
 1964 Winter |    10
 1968 Summer |    20
 1968 Winter |    10
 1972 Summer |    23
-- More  --

*/

-- 6. Which sports were held only once and in which game and city?

SELECT DISTINCT games, city, sport
FROM olympic.athlete_events
WHERE sport in (
      SELECT sport
      FROM olympic.athlete_events
      GROUP BY sport
      HAVING COUNT(DISTINCT games) = 1
);

/*
Results:

    games    |      city      |        sport
-------------+----------------+---------------------
 1900 Summer | Paris          | Basque Pelota
 1900 Summer | Paris          | Cricket
 1900 Summer | Paris          | Croquet
 1904 Summer | St. Louis      | Roque
 1908 Summer | London         | Jeu De Paume
 1908 Summer | London         | Motorboating
 1908 Summer | London         | Racquets
 1924 Winter | Chamonix       | Military Ski Patrol
 1936 Summer | Berlin         | Aeronautics
 2016 Summer | Rio de Janeiro | Rugby Sevens

*/

-- 7. What is the ratio of male and female athletes?

WITH athlete AS (
      SELECT DISTINCT name, sex
      FROM olympic.athlete_events)
SELECT ROUND(SUM(CASE WHEN sex = 'F' THEN 1 ELSE 0 END)/COUNT(*)::NUMERIC, 2) AS "Female Ratio", ROUND(SUM(CASE WHEN sex = 'M' THEN 1 ELSE 0 END)/COUNT(*)::NUMERIC, 2) AS "Male Ratio"
FROM athlete;

/*
Results:

 Female Ratio | Male Ratio
--------------+------------
         0.25 |       0.75

*/

-- 8. What are the oldest and youngest athletes to win a medal. Which medal did they win and what team are they from?

WITH rank_athlete AS (
      SELECT athlete_id, name, age, team, medal,
      DENSE_RANK() OVER (ORDER BY age DESC) AS rank_desc,
      DENSE_RANK() OVER (ORDER BY age ASC) AS rank_asc
      FROM olympic.athlete_events
      WHERE medal IS NOT NULL
      AND age IS NOT NULL)
SELECT athlete_id, name, age, team, medal
FROM rank_athlete
WHERE rank_desc = 1
OR rank_asc = 1;

/*
Results:

 athlete_id |                     name                      | age |             team              | medal
------------+-----------------------------------------------+-----+-------------------------------+--------
 71691      | Dimitrios Loundras                            |  10 | Ethnikos Gymnastikos Syllogos | Bronze
 22984      | John (Herbert Crawford-) Copley (Williamson-) |  73 | Great Britain                 | Silver

*/

-- 9. What are the top 5 athletes to win gold medals? List all the sports those medals were won in.

SELECT name, count(medal) AS "No of Gold Medals", string_agg(DISTINCT sport, ',')
FROM olympic.athlete_events
WHERE medal = 'Gold'
GROUP BY name
ORDER BY 2 DESC LIMIT 5;

/*
Results:

                name                | No of Gold Medals |   sport
------------------------------------+-------------------+------------
 Michael Fred Phelps, II            |                23 | Swimming
 Raymond Clarence "Ray" Ewry        |                10 | Athletics
 Larysa Semenivna Latynina (Diriy-) |                 9 | Gymnastics
 Mark Andrew Spitz                  |                 9 | Swimming
 Frederick Carlton "Carl" Lewis     |                 9 | Athletics

*/

-- 10. What are the top 5 athletes to participate in the most games? List all games that they had participated in. 

SELECT name, COUNT(DISTINCT games) AS "No of Games", string_agg(DISTINCT year::TEXT, ', ')
FROM olympic.athlete_events
GROUP BY name
ORDER BY 2 DESC LIMIT 5;

/*
Results:

             name              | No of Games |                         string_agg
-------------------------------+-------------+------------------------------------------------------------
 Ian Millar                    |          10 | 1972, 1976, 1984, 1988, 1992, 1996, 2000, 2004, 2008, 2012
 Hubert Raudaschl              |           9 | 1964, 1968, 1972, 1976, 1980, 1984, 1988, 1992, 1996
 Afanasijs Kuzmins             |           9 | 1976, 1980, 1988, 1992, 1996, 2000, 2004, 2008, 2012
 Francisco Boza Dibos          |           8 | 1980, 1984, 1988, 1992, 1996, 2000, 2004, 2016
 Aleksandr Vladimirovich Popov |           8 | 1988, 1992, 1994, 1996, 1998, 2000, 2004

*/

-- 11. What are the top 5 nations with the most medals and what percentage do thay account for the total number of medals?

WITH nation_medals AS (
      SELECT n.region, COUNT(*) AS no_medals
      FROM olympic.athlete_events e
      INNER JOIN olympic.noc_region n
      ON e.noc = n.noc
      WHERE medal IS NOT NULL
      GROUP BY n.region
      ORDER BY 2 DESC)
SELECT region, ROUND(100*no_medals/SUM(no_medals) OVER (), 2) AS "Percentage of Total Medals"
FROM nation_medals
LIMIT 5;

/*
Results:

 region  | Percentage of Total Medals
---------+----------------------------
 USA     |                      14.17
 Russia  |                       9.92
 Germany |                       9.44
 UK      |                       5.20
 France  |                       4.47

*/

-- 12. List all nations with the most gold, most silver, and most bronze in each game.

WITH gold_medals AS (
      SELECT e.games, n.region, COUNT(*) AS gold_medal,
      RANK() OVER (PARTITION BY e.games ORDER BY COUNT(*) DESC) AS rank_gold
      FROM olympic.athlete_events e
      INNER JOIN olympic.noc_region n
      ON e.noc = n.noc
      WHERE e.medal = 'Gold'
      GROUP BY e.games, n.region),
silver_medals AS (
      SELECT e.games, n.region, COUNT(*) AS silver_medal,
      RANK() OVER (PARTITION BY e.games ORDER BY COUNT(*) DESC) AS rank_silver
      FROM olympic.athlete_events e
      INNER JOIN olympic.noc_region n
      ON e.noc = n.noc
      WHERE e.medal = 'Silver'
      GROUP BY e.games, n.region),
bronze_medals AS (
      SELECT e.games, n.region, COUNT(*) AS bronze_medal,
      RANK() OVER (PARTITION BY e.games ORDER BY COUNT(*) DESC) AS rank_bronze
      FROM olympic.athlete_events e
      INNER JOIN olympic.noc_region n
      ON e.noc = n.noc
      WHERE e.medal = 'Bronze'
      GROUP BY e.games, n.region)
SELECT g.games as Games, CONCAT(g.region, ' - ', g.gold_medal) AS "Top Gold Medals", CONCAT(s.region, ' - ', s.silver_medal) AS "Top Silver Medals", CONCAT(b.region, ' - ', b.bronze_medal) AS "Top Bronze Medals"
FROM gold_medals g
INNER JOIN silver_medals s
ON g.games = s.games
INNER JOIN bronze_medals b
ON g.games = b.games
WHERE g.rank_gold = 1
AND s.rank_silver = 1
AND b.rank_bronze = 1;

/*
Results:

    games    | Top Gold Medals |  Top Silver Medals  |  Top Bronze Medals
-------------+-----------------+---------------------+---------------------
 1896 Summer | Germany - 25    | Greece - 18         | Greece - 20
 1900 Summer | UK - 59         | France - 101        | France - 82
 1904 Summer | USA - 128       | USA - 141           | USA - 125
 1906 Summer | Greece - 24     | Greece - 48         | Greece - 30
 1908 Summer | UK - 147        | UK - 131            | UK - 90
 1912 Summer | Sweden - 103    | UK - 64             | UK - 59
 1920 Summer | USA - 111       | France - 71         | Belgium - 66
 1924 Summer | USA - 97        | France - 51         | USA - 49
 1924 Winter | UK - 16         | USA - 10            | UK - 11
 1928 Summer | USA - 47        | Netherlands - 29    | Germany - 41
 1928 Winter | Canada - 12     | Sweden - 13         | Switzerland - 12
 1932 Summer | USA - 81        | USA - 47            | USA - 61
 1932 Winter | Canada - 14     | USA - 21            | Germany - 14
 1936 Summer | Germany - 93    | Germany - 70        | Germany - 61
 1936 Winter | UK - 12         | Canada - 13         | USA - 14
 1948 Summer | USA - 87        | UK - 42             | USA - 35
 1948 Winter | Canada - 13     | Czech Republic - 17 | Switzerland - 19
 1952 Summer | USA - 83        | Russia - 62         | Hungary - 32
 1952 Winter | Canada - 16     | USA - 25            | Sweden - 23
 1956 Summer | Russia - 68     | Russia - 46         | Russia - 55
 1956 Winter | Russia - 26     | USA - 19            | Canada - 18
 1960 Summer | USA - 81        | Russia - 63         | Russia - 45
 1960 Winter | USA - 19        | Canada - 17         | Russia - 28
 1964 Summer | USA - 95        | Russia - 63         | Russia - 51
 1964 Winter | Russia - 30     | Sweden - 21         | Czech Republic - 17
 1968 Summer | USA - 99        | Russia - 63         | Russia - 64
 1968 Winter | Russia - 26     | Czech Republic - 19 | Canada - 18
 1972 Summer | Russia - 107    | Germany - 83        | Germany - 96
 1972 Winter | Russia - 36     | USA - 18            | Czech Republic - 19
-- More  --

*/

-- 13. List all nations that have won gold medals. Which game have they won the most gold medals and what percentage do the gold medals account for the total number of gold medals in that game?

WITH gold_medals AS (
      SELECT n.region, e.games, COUNT(*) AS gold_count,
      RANK() OVER (PARTITION BY n.region ORDER BY COUNT(*) DESC) AS rank_gold
      FROM olympic.athlete_events e
      INNER JOIN olympic.noc_region n
      ON e.noc = n.noc
      WHERE e.medal = 'Gold'
      GROUP BY n.region, e.games),
total_golds AS (
      SELECT games, COUNT(*) as total_gold
      FROM olympic.athlete_events
      WHERE medal = 'Gold'
      GROUP BY games)
SELECT g.region, g.games, g.gold_count, ROUND(100*g.gold_count/t.total_gold, 2)
FROM gold_medals g
INNER JOIN total_golds t
ON g.games = t.games
WHERE g.rank_gold = 1;

/*
Results:

           region            |    games    | gold_count | round
-----------------------------+-------------+------------+-------
 Algeria                     | 1996 Summer |          2 |  0.00
 Argentina                   | 2004 Summer |         28 |  4.00
 Armenia                     | 1996 Summer |          1 |  0.00
 Armenia                     | 2016 Summer |          1 |  0.00
 Australia                   | 2000 Summer |         60 |  9.00
 Austria                     | 2006 Winter |         16 |  9.00
 Azerbaijan                  | 2012 Summer |          2 |  0.00
 Azerbaijan                  | 2000 Summer |          2 |  0.00
 Bahamas                     | 2000 Summer |          6 |  0.00
 Bahrain                     | 2016 Summer |          1 |  0.00
 Belarus                     | 2008 Summer |          8 |  1.00
 Belgium                     | 1920 Summer |         57 | 11.00
 Brazil                      | 2016 Summer |         36 |  5.00
 Bulgaria                    | 1988 Summer |         10 |  1.00
 Burundi                     | 1996 Summer |          1 |  0.00
 Cameroon                    | 2000 Summer |         18 |  2.00
 Canada                      | 2010 Winter |         67 | 38.00
 Chile                       | 2004 Summer |          3 |  0.00
 China                       | 2008 Summer |         74 | 11.00
 Colombia                    | 2016 Summer |          3 |  0.00
 Costa Rica                  | 1996 Summer |          1 |  0.00
 Croatia                     | 1996 Summer |         16 |  2.00
 Cuba                        | 1992 Summer |         42 |  7.00
 Czech Republic              | 1998 Winter |         21 | 14.00
 Denmark                     | 1920 Summer |         26 |  5.00
 Dominican Republic          | 2004 Summer |          1 |  0.00
 Dominican Republic          | 2008 Summer |          1 |  0.00
 Dominican Republic          | 2012 Summer |          1 |  0.00
 Ecuador                     | 1996 Summer |          1 |  0.00

*/

-- 14. Which nations have not won gold medals? How many other medals do they have?

WITH bronze_medal AS (
      SELECT n.region, COUNT(*) AS bronze_count
      FROM olympic.athlete_events e
      INNER JOIN olympic.noc_region n
      ON e.noc = n.noc
      WHERE e.medal = 'Bronze'
      GROUP BY n.region),
silver_medal AS (
      SELECT n.region, COUNT(*) AS silver_count
      FROM olympic.athlete_events e
      INNER JOIN olympic.noc_region n
      ON e.noc = n.noc
      WHERE e.medal = 'Silver'
      GROUP BY n.region)
SELECT DISTINCT n.region, b.bronze_count AS "No of Bronze Medals", s.silver_count AS "No of Silver Medals"
FROM olympic.athlete_events e
INNER JOIN olympic.noc_region n
ON e.noc = n.noc
FULL OUTER JOIN bronze_medal b
ON n.region = b.region
FULL OUTER JOIN silver_medal s
ON n.region = s.region
WHERE n.region NOT IN (
      SELECT DISTINCT n.region
      FROM olympic.athlete_events e
      INNER JOIN olympic.noc_region n
      ON e.noc = n.noc
      WHERE e.medal = 'Gold')
ORDER BY 1;

/*
Results:

              region              | No of Bronze Medals | No of Silver Medals
----------------------------------+---------------------+---------------------
 Afghanistan                      |                   2 |
 Albania                          |                     |
 American Samoa                   |                     |
 Andorra                          |                     |
 Angola                           |                     |
 Antigua                          |                     |
 Aruba                            |                     |
 Bangladesh                       |                     |
 Barbados                         |                   1 |
 Belize                           |                     |
 Benin                            |                     |
 Bermuda                          |                   1 |
 Bhutan                           |                     |
 Boliva                           |                     |
 Bosnia and Herzegovina           |                     |
 Botswana                         |                     |                   1
 Brunei                           |                     |
 Burkina Faso                     |                     |
 Cambodia                         |                     |
 Cape Verde                       |                     |
 Cayman Islands                   |                     |
 Central African Republic         |                     |
 Chad                             |                     |
 Comoros                          |                     |
 Cook Islands                     |                     |
 Curacao                          |                     |                   1
 Cyprus                           |                     |                   1
 Democratic Republic of the Congo |                     |
 Djibouti                         |                   1 |
-- More  --

*/