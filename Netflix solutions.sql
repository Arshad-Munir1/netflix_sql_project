-- Netflix Project

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix

(
	show_id	VARCHAR(6),
	type	VARCHAR(10),
	title	VARCHAR(150),
	director VARCHAR(208),	
	casts	VARCHAR(1000),
	country	VARCHAR(150),
	date_added VARCHAR(50),	
	release_year INT,	
	rating	VARCHAR(10),
	duration	VARCHAR(15),
	listed_in	VARCHAR(100),
	description VARCHAR(250)

);

SELECT
	COUNT(*) AS TOTAL_CONTENT
FROM
	NETFLIX;

SELECT DISTINCT
	TYPE
FROM
	NETFLIX;

-- Busines Problems

--1. Count the number of Movies vs TV Shows

SELECT
	TYPE,
	COUNT(*) AS TOTAL_CONTETNT
FROM
	NETFLIX
GROUP BY
	TYPE;	
	
--2. Find the most common rating for movies and TV shows

SELECT
	TYPE,
	RATING,
	TOTAL_CONTENT
FROM
	(
		SELECT
			TYPE,
			RATING,
			COUNT(*) AS TOTAL_CONTENT,
			RANK() OVER (
				PARTITION BY
					TYPE
				ORDER BY
					COUNT(*) DESC
			) AS RANKING
		FROM
			NETFLIX
		GROUP BY
			TYPE,
			RATING
	) AS T1
WHERE
	RANKING = 1



--3. List all movies released in a specific year (e.g., 2020)

SELECT
	TITLE,
	RELEASE_YEAR
FROM
	NETFLIX
WHERE
	TYPE = 'Movie'
	AND RELEASE_YEAR = 2020


--4. Find the top 5 countries with the most content on Netflix

SELECT
	UNNEST(STRING_TO_ARRAY(COUNTRY, ', ')) AS NEW_COUNTRY,
	COUNT(*) AS TOTAL_CONTENT
FROM
	NETFLIX
GROUP BY
	1
ORDER BY
	2 DESC LIMIT
	5

--5. Identify the longest movie

SELECT
	*
FROM
	NETFLIX
WHERE
	TYPE = 'Movie'
	AND DURATION = (
		SELECT
			MAX(DURATION)
		FROM
			NETFLIX
	)



--6. Find content added in the last 5 years

SELECT
	*
	FROM
	NETFLIX
WHERE
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'


--8. List all TV shows with more than 5 seasons

SELECT
	*
FROM
	NETFLIX
WHERE
	TYPE = 'TV Show'
	AND SPLIT_PART(DURATION, ' ', 1)::NUMERIC > 5




--9. Count the number of content items in each genre

SELECT
	UNNEST(STRING_TO_ARRAY(listed_in, ', ')) AS NEW_GENRE,
	COUNT(*) AS TOTAL_GENRE
FROM
	NETFLIX
GROUP BY
	1
ORDER BY
	2 DESC 



--10.Find each year and the average numbers of content release in India on netflix.
--return top 5 year with highest avg content release!

SELECT
	EXTRACT(
		YEAR
		FROM
			TO_DATE(DATE_ADDED, 'Month DD, YYYY')
	) AS YEAR,
	COUNT(*) AS YEARLY_CONTENT,
	ROUND(
		COUNT(*)::NUMERIC / (
			SELECT
				COUNT(*)
			FROM
				NETFLIX
			WHERE
				COUNTRY LIKE '%India%'
		)::NUMERIC * 100,
		2
	) AS AVG_CONTENT_PER_YEAR
FROM
	NETFLIX
WHERE
	COUNTRY LIKE '%India%'
GROUP BY
	1

--11. List all movies that are documentaries

SELECT * FROM netflix
WHERE TYPE = 'Movie'
AND listed_in ILIKE '%Documentaries%'


--12. Find all content without a director

SELECT * FROM Netflix
WHERE director IS NULL


--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT
	*
FROM
	NETFLIX
WHERE
	CASTS ILIKE '%Salman Khan%'
	AND RELEASE_YEAR > EXTRACT(
		YEAR
		FROM
			CURRENT_DATE
	) - 10

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT
	UNNEST(STRING_TO_ARRAY(CASTS, ', ')) AS NEW_ACTOR,
	COUNT(*)
FROM
	NETFLIX
WHERE
	COUNTRY ILIKE '%India%'
GROUP BY
	NEW_ACTOR
ORDER BY
	2 DESC
LIMIT
	10

--15.
--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

WITH
	NEW_TABLE AS (
		SELECT
			*,
			CASE
				WHEN DESCRIPTION ~* '\mkill(s|ed|ing)?\M'
				OR DESCRIPTION ILIKE '%voilence%' THEN 'Bad_content'
				ELSE 'Good_content'
			END CATEGORY
		FROM
			NETFLIX
	)
SELECT
	CATEGORY,
	COUNT(*) AS TOTAL_CONTENT
FROM
	NEW_TABLE
GROUP BY
	CATEGORY
	


