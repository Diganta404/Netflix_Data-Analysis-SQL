--Netflix Project
DROP TABLE IF EXISTS netflix
CREATE TABLE netflix
(
show_id	varchar(10),
show_type varchar (10)	,
title varchar(150),
director varchar(210),
show_cast varchar(1000)	,
country varchar(150),
date_added	varchar(50),
release_year	int,
rating	varchar(10),
duration	varchar(15),
listed_in varchar(100),
description varchar(250)

);

SELECT * FROM netflix;

SELECT 
COUNT (*) as total_count
FROM netflix;

SELECT 
DISTINCT show_type
from netflix;

SELECT 
DISTINCT rating
from netflix;

SELECT 
DISTINCT country
from netflix;



--Business Problems

--(1) Count the number of Movies vs TV-Shows
-----------------------------------------------------

SELECT 
show_type,
COUNT (*) AS total_count
FROM netflix
GROUP BY show_type;

-- (2) Find the most common rating for movies and TV shows
---------------------------------------------------------------


SELECT 
    show_type,
    rating
FROM (
    SELECT 
        show_type,
        rating,
        COUNT(*) AS rating_count,
        RANK() OVER(PARTITION BY show_type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY show_type, rating
) AS t1
WHERE ranking = 1;




-- (3) List all movies realeased in a specific year (e.g ,2000)
---------------------------------------------------------------------



SELECT *
FROM netflix

WHERE release_year = 2000
AND show_type = 'Movie';

-- (4) Find the top 5  contries with the most content on Netflix
-----------------------------------------------------------------------


SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	COUNT(show_id) as total_contant
FROM netflix
GROUP BY new_country
ORDER BY total_contant DESC
LIMIT 5;


-- (5) Identify the longest movie?
----------------------------------------------------------
SELECT *
FROM netflix
WHERE show_type = 'Movie'
AND SPLIT_PART(duration, ' ', 1)::NUMERIC = (
    SELECT MAX(SPLIT_PART(duration, ' ', 1)::NUMERIC)
    FROM netflix
    WHERE show_type = 'Movie'
);


-- (6) Find content added in last 5 years 
-----------------------------------------------------


SELECT * 
FROM netflix
WHERE 
    TO_DATE(date_added, 'Month DD,YYYY') >= CURRENT_DATE - INTERVAL '5 years';


--- (7) Find all the movies/tv shows by director "Rajib Chilka"
-----------------------------------------------------------------------

SELECT * FROM netflix
WHERE director ILIKE 'Rajiv Chilaka%'


--- (8) List all  TV shows with more than 5 seasons
----------------------------------------------------------

SELECT *
FROM netflix
WHERE 
	show_type='TV Show'
	AND
	SPLIT_PART(duration,' ',1):: numeric> 5 





--- (9) Count the number of contenr items in each genre
-----------------------------------------------------------------

SELECT  UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,
COUNT(show_id) AS count_genre
FROM netflix
GROUP BY genre



--- (10) Find each year  and the average numbers of content rleased by India on Netflix.
------------------------------------------------------------------------------------------------

WITH expanded_countries AS (
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
        EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year
    FROM netflix
)
SELECT 
    year,
    COUNT(*) AS total_content,
    ROUND(
        COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM netflix WHERE country ILIKE '%India%')::NUMERIC * 100, 2
    ) AS avg_content_of_year
FROM expanded_countries
WHERE new_country = 'India'
GROUP BY year
ORDER BY total_content DESC;


-----------------------------------------------------------------

SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD YYYY')) AS year,
    COUNT(*) AS total_content,
    ROUND(
        COUNT(*)::numeric / (SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100,
        2
    ) AS avg_content_of_year
FROM netflix
WHERE country = 'India'
GROUP BY year

--- (11) List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in ILIKE '%documentaries%'

--- (12) Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL


--- (13) Find how many movies actor 'Salman Khan' appeared in last 10 years !

SELECT *
FROM netflix
WHERE show_cast ILIKE '%Salman Khan%'
AND 
release_year >EXTRACT(YEAR FROM CURRENT_DATE)-10

--- (14) Find the top 10 actor who have appeared in the highest number of movies prouced in India

SELECT 
UNNEST(STRING_TO_ARRAY(show_cast,',')) as actors,
COUNT (*) AS total_content
FROM netflix
WHERE country ILIKE 'india'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

--- (15) 
--Catagorize the content based on the presence of the key words 'kill' and 'voilence' in the description
--field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into 
--each catagory.

WITH categorized_content AS (
    SELECT 
        *,
        CASE
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad_Content'
            ELSE 'Good_Content'
        END AS category
    FROM netflix
)
SELECT category, COUNT(*) AS total_count
FROM categorized_content
GROUP BY category;



--(16)
--###  Identify Seasonal Trends in Content Additions ###--

--Find which month has the highest number of content additions over the years.

SELECT 
    TO_CHAR(TO_DATE(date_added, 'Month DD, YYYY'), 'Month') AS month,
    COUNT(*) AS total_content_added
FROM netflix
GROUP BY month
ORDER BY total_content_added DESC;

--(17)
--### Popular Genre by Year ##--

--Identify the most popular genre for each year.

WITH expanded_genres AS (
    SELECT 
        EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
        UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
    FROM netflix
)
SELECT 
    year,
    genre,
    COUNT(*) AS total_content,
    RANK() OVER (PARTITION BY year ORDER BY COUNT(*) DESC) AS rank
FROM expanded_genres
GROUP BY year, genre
HAVING COUNT(*) > 0
ORDER BY year ASC, rank ASC;

--(18)
--Content Share by Show Type Over Time
--Analyze the proportion of Movies vs. TV Shows added every year.

SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    show_type,
    COUNT(*) AS total_content,
    ROUND(
        COUNT(*)::NUMERIC / SUM(COUNT(*)) 
		OVER (PARTITION BY EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY'))) * 100, 
        2
    ) AS percentage
FROM netflix
GROUP BY year, show_type
ORDER BY year ASC, show_type ASC;


--(19)
--Directors with Most Content by Genre
--Find the top directors producing content for each genre.

WITH expanded_genres AS (
    SELECT 
        director,
        UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
    FROM netflix
    WHERE director IS NOT NULL
)
SELECT 
    genre,
    director,
    COUNT(*) AS total_content,
    RANK() OVER (PARTITION BY genre ORDER BY COUNT(*) DESC) AS rank
FROM expanded_genres
GROUP BY genre, director
HAVING COUNT(*) > 0
ORDER BY genre ASC, rank ASC;


--(20)
--## Identify Content Gaps
---## List genres or countries with no content added in the last 2 years.

WITH recent_content AS (
    SELECT 
        UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        TO_DATE(date_added, 'Month DD, YYYY') AS added_date
    FROM netflix
    WHERE date_added IS NOT NULL
)
SELECT 
    genre,
    country
FROM recent_content
WHERE added_date < CURRENT_DATE - INTERVAL '2 years'
GROUP BY genre, country
HAVING COUNT(*) > 0
ORDER BY genre, country;


--(21)
--##Audience Retention Analysis by Content Duration
--Problem: Categorize movies into buckets based on their duration and analyze their count.


SELECT 
    CASE
        WHEN SPLIT_PART(duration, ' ', 1)::NUMERIC < 30 THEN 'Short (< 30 min)'
        WHEN SPLIT_PART(duration, ' ', 1)::NUMERIC BETWEEN 30 AND 60 THEN 'Medium (30-60 min)'
        WHEN SPLIT_PART(duration, ' ', 1)::NUMERIC BETWEEN 61 AND 120 THEN 'Long (1-2 hrs)'
        ELSE 'Very Long (> 2 hrs)'
    END AS duration_category,
    COUNT(*) AS total_content
FROM netflix
WHERE show_type = 'Movie'
GROUP BY duration_category
ORDER BY total_content DESC;


--(22)
--##Actor Collaboration Analysis
--Problem: Find the top pairs of actors who frequently appear together.

WITH actor_pairs AS (
    SELECT 
        UNNEST(STRING_TO_ARRAY(show_cast, ',')) AS actor1,
        UNNEST(STRING_TO_ARRAY(show_cast, ',')) AS actor2
    FROM netflix
    WHERE show_cast IS NOT NULL
)
SELECT 
    actor1,
    actor2,
    COUNT(*) AS collaboration_count
FROM actor_pairs
WHERE actor1 < actor2
GROUP BY actor1, actor2
ORDER BY collaboration_count DESC
LIMIT 10;

--(23)
--New Content Added by Rating Over the Years
--Problem: Track the trends of content addition by rating year by year.

SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    rating,
    COUNT(*) AS total_content
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY year, rating
ORDER BY year ASC, total_content DESC;


--(24)
--Genre-Country Matrix
--Problem: Create a matrix of the number of titles by genre and country.
SELECT 
    genre,
    country,
    COUNT(*) AS total_content
FROM (
    SELECT 
        UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country
    FROM netflix
) AS genre_country
GROUP BY genre, country
ORDER BY total_content DESC;


--(25)
---Top Keywords in Descriptions
--Problem: Identify the most frequently used keywords in the descriptions.

WITH tokenized_descriptions AS (
    SELECT 
        UNNEST(STRING_TO_ARRAY(REGEXP_REPLACE(description, '[^a-zA-Z0-9\s]', '', 'g'), ' ')) AS keyword
    FROM netflix
    WHERE description IS NOT NULL
)
SELECT 
    LOWER(keyword) AS keyword,
    COUNT(*) AS total_count
FROM tokenized_descriptions
GROUP BY keyword
HAVING LENGTH(keyword) > 3
ORDER BY total_count DESC
LIMIT 20;

















		





	























