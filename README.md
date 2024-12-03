# Netflix Data Analysis with SQL and PostgreSQL
![Netflix Logo](https://github.com/Diganta404/Netflix_Data-Analysis-SQL/blob/main/netflix_logo.png)

## Project Overview

This project analyzes Netflix's content library to address questions about content distribution, audience preferences, and regional trends. It aims to demonstrate how SQL can solve real-world business problems.

## Database Schema

The Netflix dataset schema:

| Column Name     | Data Type    | Description                          |
|------------------|--------------|--------------------------------------|
| `show_id`        | VARCHAR(10)  | Unique identifier for each show.     |
| `show_type`      | VARCHAR(10)  | Indicates if the content is a Movie or TV Show. |
| `title`          | VARCHAR(150) | Name of the show or movie.           |
| `director`       | VARCHAR(210) | Director of the content.             |
| `show_cast`      | VARCHAR(1000)| List of cast members.                |
| `country`        | VARCHAR(150) | Country where the content was produced. |
| `date_added`     | VARCHAR(50)  | Date when the content was added to Netflix. |
| `release_year`   | INT          | Year of release.                     |
| `rating`         | VARCHAR(10)  | Content rating (e.g., PG-13).        |
| `duration`       | VARCHAR(15)  | Length of the content.               |
| `listed_in`      | VARCHAR(100) | Genres/categories.                   |
| `description`    | VARCHAR(250) | Brief summary of the content.        |


### 1. Most Popular Genres Globally
This query explores the most popular genres in Netflix’s content library.

```sql
SELECT  
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,  
    COUNT(show_id) AS genre_count  
FROM netflix  
GROUP BY genre  
ORDER BY genre_count DESC;
```


### 2. Identify Seasonal Trends in Content Additions
Find which month has the highest number of content additions over the years.
 

```sql
SELECT 
    EXTRACT(MONTH FROM TO_DATE(date_added, 'Month DD, YYYY')) AS month, 
    COUNT(*) AS total_content
FROM netflix
GROUP BY month
ORDER BY total_content DESC;

```

### 3. Popular Genre by Year
Identify the most popular genre for each year.

```sql
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS genre_count
FROM netflix
GROUP BY year, genre
ORDER BY genre_count DESC;
```

### 4. Content Share by Show Type Over Time
Analyze the proportion of Movies vs. TV Shows added every year.

```sql
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    show_type,
    COUNT(*) AS show_type_count
FROM netflix
GROUP BY year, show_type
ORDER BY year, show_type_count DESC;
```

### 5. Audience Retention Analysis by Content Duration
Categorize movies into buckets based on their duration and analyze their count.

```sql
SELECT 
    CASE
        WHEN duration::int < 60 THEN 'Short (< 1 hour)'
        WHEN duration::int BETWEEN 60 AND 120 THEN 'Medium (1-2 hours)'
        ELSE 'Long (> 2 hours)'
    END AS duration_category,
    COUNT(*) AS total_content
FROM netflix
WHERE show_type = 'Movie'
GROUP BY duration_category;


```

### 6. New Content Added by Rating Over the Years
Track the trends of content addition by rating year by year.

```sql
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    rating, 
    COUNT(*) AS content_count
FROM netflix
GROUP BY year, rating
ORDER BY year, content_count DESC;
```

### 7. Genre-Country Matrix
Create a matrix of the number of titles by genre and country.

```sql
SELECT 
    genre,
    country,
    COUNT(*) AS content_count
FROM (
    SELECT 
        UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre, 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country
    FROM netflix
) AS genres_countries
GROUP BY genre, country
ORDER BY content_count DESC;

```


### 8. Actor Collaboration Analysis
Find the top pairs of actors who frequently appear together.

```sql
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

```

### 9. New Content Added by Rating Over the Years
Track the trends of content addition by rating year by year.

```sql
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    rating,
    COUNT(*) AS total_content
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY year, rating
ORDER BY year ASC, total_content DESC;

```

### 10. Categorize Content Based on Keywords in Description
Categorize content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

```sql
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

```

## Technologies Used
- **SQL**: Advanced querying for data extraction and manipulation.
- **PostgreSQL**: Database management and execution environment.
- **pgAdmin**: GUI tool for managing PostgreSQL databases.

## Installation and Setup
1. Clone this repository:
   ```bash
   [(https://github.com/Diganta404/Netflix_Data-Analysis-SQL)]


2. Set up PostgreSQL and import the dataset.
3. Run the SQL scripts in the `queries` folder.

## Contributing
Contributions are welcome! If you have any queries or want to add new analyses, feel free to open a pull request.

## Contact
- **Name**: Diganta Mitra
- **Email**: dgntmitra@gmail.com
- **LinkedIn**: [Diganta Mitra](https://www.linkedin.com/in/diganta-mitra-77b634264?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=ios_app)








