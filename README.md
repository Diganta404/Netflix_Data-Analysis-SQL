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



