#  Data exploration of global COVID-19 data

In this project, I conducted data exploratory analysis using SQL (DB browser (SQLite)) on COVID-19 data. 

### 1. Data collection
The data obtained between 2020-01-01 to 2023-12-07 by Our World in Data (downloaded from: ourworldindata.org/covid-deaths). 

### 2. Data preprocessing
The downloaded data was processed in Excel for date format standardisation (converting 'dd/mm/yyyy' to 'yyyy-mm-dd') and to seperate the data into two tables: covid_deaths.csv and covid_vaccinations.csv files.

### 3. Data exploration
I investigated COVID cases, deaths and vaccination numbers across locations i.e., country and continents; and across the timeline of the epidemic. Additionally, I examined the impact of income type on the numbers of cases, deaths and vaccinations. 

Skills used: Joins, CTE's, temp Tables, windows functions, aggregate functions, view creations and data type conversion. 

### 4. Data Visualisation on Tableau
I created a tableau dashboard accessed displaying Covid-19 cases and deaths. This can be accessed via https://public.tableau.com/app/profile/isabelle.rajendiran/viz/Covid-19CaseandDeathDashboard/Dashboard1. The specific queries used for this dashboard can be found as tableau_case_death_queries.sql. 

### Acknowledgements
Thanks to Alex The Analyst (youtube.com/@AlexTheAnalyst) from which this project was adapted from.
