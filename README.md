#  Data exploration of global COVID-19 data

In this project, I conducted data analysis using SQL (DB browser (SQLite)) on COVID-19 data. 

### 1. Data collection
The data obtained between 2020-01-01 to 2023-12-07 by Our World in Data (downloaded from: ourworldindata.org/covid-deaths). 

### 2. Data preprocessing
The downloaded data was processed in Excel for date format standardisation (converting 'dd/mm/yyyy' to 'yyyy-mm-dd') and to seperate the data into two tables: covid_deaths.csv and covid_vaccinations.csv files.

### 3. Data exploration
I investigated COVID cases, deaths and vaccination numbers across locations i.e., country and continents; and across the timeline of the epidemic. Additionally, I examined the impact of income type on the numbers of cases, deaths and vaccinations. 

Skills used: Joins, CTE's, temp Tables, windows functions, aggregate functions, view creations and data type conversion. 

### 4. Data Visualisation on Tableau
I created tableau dashboards displaying Covid-19 cases and deaths, and the impact of income type on Covid-19. These can be accessed via my Tableau profile (https://public.tableau.com/app/profile/isabelle.rajendiran/vizzes), and images can be found in the visualisations folder. The specific queries used for these dashboards can be found as covid_tableau_queries.sql. 

### Acknowledgements
Thanks to Alex The Analyst (youtube.com/@AlexTheAnalyst) from which this project was adapted from.
