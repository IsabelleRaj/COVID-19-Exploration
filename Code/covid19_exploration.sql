/* 
-------------------------------------------------------------------------------
CREATED BY:	  ISABELLE RAJENDIRAN 
CREATED DATE: 2023-12-08 
LAST UPDATED: 2025-01-01
DESCRIPTION:  Data exploration of global COVID-19 data, with a focus on 
		  location and income groups.
-------------------------------------------------------------------------------
MODIFICATION HISTORY:
- 2024-12-30
	- Added additional queries, restructured the code and added comments 
	  throughout.
- 2025-01-01
	- Edited the queries.
-------------------------------------------------------------------------------
*/

-- **INITIAL EXPLORATION** --

-- 1: Initial observation of the covid_deaths and covid_vaccinations datasets
SELECT 
 *
FROM
 covid_deaths
LIMIT 10;

SELECT 
 *
FROM
 covid_vaccinations
LIMIT 10;
 
-- 2: Investigation of the location and continent columns
SELECT 
 DISTINCT(continent)
FROM
 covid_deaths;

SELECT 
 DISTINCT(location)
FROM
 covid_deaths
WHERE
 continent IS NULL
ORDER BY
 location;
 
-- NOTE: There are null values in the continent column. For records with null continent values, the location (country) column 
-- contains the continents, 'World' and income type information instead. For country analyses, only records with non-null continent will be used. 


-- **GLOBAL OVERVIEW** --

-- 1: Total number of global cases and deaths

SELECT
 SUM(CAST(new_cases AS INT)) AS TotalCases,
 SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
 (SUM(new_deaths)*1.0)/SUM((new_cases)*1.0)*100 AS DeathRatePercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL
ORDER BY
 TotalCases,
 TotalDeaths;
 
-- 2: Time series of global cases, deaths and death rate

WITH cumulative_data AS (  -- Due to SQLite limitation with use of OVER for complex calculations, a CTE (common table expression) was used instead.
SELECT DISTINCT
 date AS Date,
 SUM(new_cases) OVER (ORDER BY date) AS TotalCases,
 SUM(new_deaths) OVER (ORDER BY date) AS TotalDeaths
FROM
 covid_deaths
WHERE
 continent IS NOT NULL
)
SELECT
 Date,
 TotalCases,
 TotalDeaths,
 ROUND((TotalDeaths * 1.0 / TotalCases) * 100, 3) AS DeathRatePercentage
FROM
 cumulative_data;
 
/* Not available for SQLite
SELECT DISTINCT -- TO remove duplicate dates from each location
 date AS Date,
 SUM(new_cases) OVER (ORDER BY date) AS TotalCases,
 SUM(new_deaths) OVER (ORDER BY date) AS TotalDeaths,
 ((SUM(new_deaths*1.0))/(SUM(new_cases*1.0))*100) OVER(ORDER BY date) AS DeathRatePercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL; -- NOTE: Stating continent IS NOT NULL is needed to remove these locations: 'World', 'European Union', 'High income','Low income', 'Lower middle income', 'Upper middle income' 
*/
 
-- 3: Time series showing the daily COVID-19 new cases and new deaths globally

SELECT
 date AS Date,
 SUM(CAST(new_cases AS INT)) AS NewCases,
 SUM(CAST(new_deaths AS INT)) AS NewDeaths
FROM
 covid_deaths
WHERE
 continent IS NOT NULL
GROUP BY
 date

-- **EXPLORATION BY COUNTRY** --
 
-- 1: Time series of the total cases, total deaths and death rate across countries
-- Demonstrates likelihood of death upon contracting COVID-19 in each country

SELECT
 location AS Country,
 date AS Date,
 total_cases AS TotalCases,
 total_deaths AS TotalDeaths,
 ROUND((total_deaths*1.0)/(total_cases*1.0)*100, 5) AS DeathRatePercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL 
ORDER BY
 location,
 date;

-- 2: Total cases vs total deaths AS of the last updated date for each country (mostly 2023-12-06)

SELECT
 location AS Country,
 MAX(date) AS Date,
 total_cases AS TotalCases,
 total_deaths AS TotalDeaths,
 ROUND((total_deaths*1.0)/(total_cases*1.0)*100, 5) AS DeathRatePercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL AND 
 date IS NOT '2023-12-07'  -- Some countries have 2023-12-07 AS an empty (null) record
GROUP BY 
 location
ORDER BY
 location;
 
/* 
NOTE: 11 countries seem to have null values for TotalCases, TotalDeaths and DeathRatePercentage e.g., England, Western Sahara.
Looking at the dataset, this could be due to some countries being counted AS part of another Country e.g., England, Wales, Scotland and Northern Ireland 
are counted AS 'United Kingdom'. For other countries, the data is missing entirely.
*/

SELECT 
 *
FROM (
	SELECT
	 location AS Country,
	 MAX(date) AS Date,
	 total_cases AS TotalCases,
	 total_deaths AS TotalDeaths,
	 ROUND((total_deaths*1.0)/(total_cases*1.0)*100, 5) AS DeathRatePercentage
	FROM
	 covid_deaths
	WHERE
	 continent IS NOT NULL AND 
	 date IS NOT '2023-12-07'
	GROUP BY 
	 location
	ORDER BY
	 location
	)
WHERE
 TotalCases IS NULL; -- Countries with missing data

-- 3: Time series of the population infection rate across countries
-- Shows the percentage of the population who are infected with COVID-19

SELECT 
 location AS Country,
 date AS Date,
 population AS PopulationSize,
 total_cases AS TotalCases,
 ROUND(((total_cases*1.0)/population)*100, 5) AS PopulationInfectedPercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL 
ORDER BY
 location,
 date;

-- 4: Countries in the order of highest population infection rate

SELECT
 location AS Country,
 population AS PopulationSize,
 MAX(total_cases*1) AS TotalCases, 
 MAX(ROUND((total_cases*1.0/population)*100,5)) AS PopulationInfectedPercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL
GROUP BY
 location
ORDER BY
 MAX(ROUND((total_cases*1.0/population)*100,5)) DESC;

-- 5: Countries in the order of highest death count compared to population

SELECT
 location AS Country,
 population AS PopulationSize,
 MAX(total_deaths*1) AS TotalDeaths, 
 MAX(ROUND((total_deaths*1.0/population)*100,5)) AS PopulationDeathPercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL
GROUP BY
 location
ORDER BY
 MAX(ROUND((total_deaths*1.0/population)*100,5)) DESC;
 
-- 6: Total cases, deaths and population-level statistics by country

SELECT
 location AS Country,
 population AS PopulationSize,
 MAX(total_cases*1) AS TotalCases,
 MAX(total_deaths*1) AS TotalDeaths, 
 MAX(ROUND((total_cases*1.0/population)*100,5)) AS PopulationInfectedPercentage,
 MAX(ROUND((total_deaths*1.0/population)*100,5)) AS PopulationDeathPercentage,
 ROUND((MAX(total_deaths*1.0)/(MAX(total_cases*1.0)))*100,5) AS DeathRatePercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL
GROUP BY
 location
HAVING
 TotalCases IS NOT NULL -- Note: Need to remove countries with NULL cases before importing to Tableau. Cannot assume case count is 0 - we just don't have the data in this case.  
ORDER BY
 PopulationInfectedPercentage DESC;

-- **EXPLORATION BY CONTINENT** --

-- 1: Total cases, deaths and population-level statistics by continent
 
SELECT 
 location AS Continent,
 population AS PopulationSize,
 MAX(total_cases*1) AS TotalCases, 
 MAX(total_deaths*1) AS TotalDeaths, 
 MAX(ROUND((total_cases*1.0/population)*100,5)) AS PopulationInfectedPercentage,
 MAX(ROUND((total_deaths*1.0/population)*100,5)) AS PopulationDeathPercentage,
 ROUND((MAX(total_deaths*1.0)/(MAX(total_cases*1.0)))*100,5) AS DeathRatePercentage
 -- Alternative: (SUM(new_deaths)*1.0)/SUM((new_cases)*1.0)*100 AS DeathRatePercentage
FROM
 covid_deaths
WHERE
 location in ('Africa', 'Asia', 'Europe', 'North America', 'South America', 'Oceania') -- Alternative to continent IS NULL
GROUP BY 
 location
ORDER BY
 1,2; 
 
-- **EXPLORATION OF VACCINATION DATA** --

-- 1: Total vaccination count per country

SELECT
 dea.location AS Country,
 dea.date AS Date,
 dea.population AS PopulationSize,
 MAX(CAST(vac.total_vaccinations AS INT)) AS TotalVaccinations
FROM
 covid_deaths AS dea
JOIN
 covid_vaccinations AS vac 
ON
 dea.location = vac.location AND
 dea.date = vac.date 
WHERE
 dea.continent IS NOT NULL
GROUP BY
 dea.location
ORDER BY
 1,2;

-- 2: Rolling/cumulative count of vaccinations in each country

-- NOTE: Despite not including the new_boosters column, the cumulative vaccination exceeds the population size
-- for certaion countries implying the new_vaccinations could include the boosters so multiple vaccinations per person.

DROP VIEW IF EXISTS PopulationVaccinatedView;
CREATE VIEW PopulationVaccinatedView AS -- Save this AS a view to perform further queries on it
SELECT
 dea.continent AS Continent,
 dea.location AS Country,
 dea.date AS Date,
 dea.population AS PopulationSize,
 vac.new_vaccinations AS NewVaccinations,
 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccinationTotal
FROM
 covid_deaths AS dea
JOIN
 covid_vaccinations AS vac 
ON
 dea.location = vac.location 
 AND dea.date = vac.date 
WHERE
 dea.continent IS NOT NULL
ORDER BY
 2,3;
 
SELECT
 * 
FROM 
 PopulationVaccinatedView;

-- 3: Total vaccinations vs population
-- Shows the percentage of the population who are vaccinnated against COVID-19. 

-- NOTE: Exceeds 100% possibly due to inclusion of boosters so multiple vaccines per person.
-- Uses the view created in the previous query
SELECT 
 *,
 (CAST(CumulativeVaccinationTotal AS FLOAT)/CAST(PopulationSize AS FLOAT))*100 AS PercentPopulationVaccinated
FROM 
 PopulationVaccinatedView;

/*
-- Alternative: Using CTE instead of a view

with PopvsVac (Continent, Country, Date, PopulationSize , NewVaccinations, CumulativeVaccinationTotal)
AS 
(
SELECT
 dea.continent AS Continent,
 dea.location AS Country,
 dea.date AS Date,
 dea.population AS PopulationSize,
 vac.new_vaccinations AS NewVaccinations,
 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccinationTotal
FROM
 covid_deaths AS dea
JOIN
 covid_vaccinations AS vac 
ON
 dea.location = vac.location 
 AND dea.date = vac.date 
WHERE
 dea.continent IS NOT NULL
 )
SELECT *, (CAST(CumulativeVaccinationTotal AS FLOAT)/CAST(PopulationSize AS FLOAT))*100 AS PercentPopulationVaccinated
FROM PopvsVac;

-- Alternative: Using a temporary table instead of a view

DROP Table IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Country nvarchar(255),
Date date,
PopulationSize numeric,
NewVaccinations numeric,
CumulativeVaccinationTotal numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT
 dea.continent AS Continent,
 dea.location AS Country,
 dea.date AS Date,
 dea.population AS PopulationSize,
 vac.new_vaccinations AS NewVaccinations,
 SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CumulativeVaccinationTotal
FROM
 covid_deaths AS dea
JOIN
 covid_vaccinations AS vac 
ON
 dea.location = vac.location 
 AND dea.date = vac.date 
WHERE
 dea.continent IS NOT NULL;
 
SELECT 
 *, 
(CAST(CumulativeVaccinationTotal AS FLOAT)/CAST(PopulationSize AS FLOAT))*100 AS PercentPopulationVaccinated
FROM 
 PercentPopulationVaccinated;
*/

-- **EXPLORATION OF INCOME TYPE** --

-- 0: There are 4 categories: Low income, Lower middle income, Upper middle income and High income
SELECT
 location AS IncomeType
FROM
 covid_deaths
WHERE
 continent IS NULL AND
 location LIKE '%income'
GROUP BY
 location;
 
-- 1: Total number of cases and deaths across all income groups

SELECT
 SUM(CAST(new_cases AS INT)) AS TotalCases,
 SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
 (SUM(new_deaths)*1.0)/SUM((new_cases)*1.0)*100 AS DeathRatePercentage
FROM
 covid_deaths
WHERE
 continent IS NULL AND
 location LIKE '%income'
ORDER BY
 TotalCases,
 TotalDeaths;

-- 2: Exploring the total cases, deaths and vaccinations (at least 1 vaccine) for each income group

--CREATE VIEW IncomeView AS
SELECT
 dea.location AS IncomeType,
 dea.population AS PopulationSize,
 MAX(CAST(dea.total_cases AS INT)) AS TotalCases,
 MAX(CAST(dea.total_deaths AS INT)) AS TotalDeaths, 
 MAX(CAST(vac.total_vaccinations AS INT)) AS TotalVaccinationsGiven,
 MAX(CAST(vac.people_vaccinated AS INT)) AS TotalPeopleVaccinated,
 ROUND((MAX(dea.total_deaths*1.0)/MAX(dea.total_cases*1.0))*100,5) AS DeathRatePercentage,
 ROUND((MAX(dea.total_cases*1.0)/dea.population)*100,5) AS PopulationInfectedPercentage,
 ROUND((MAX(vac.people_vaccinated*1.0)/dea.population)*100,5) AS PopulationVaccinatedPercentage
FROM
 covid_deaths AS dea
JOIN
 covid_vaccinations AS vac 
ON
 dea.location = vac.location 
 AND dea.date = vac.date 
WHERE
 dea.continent IS NULL AND 
 dea.location LIKE '%income'
GROUP BY
 dea.location
ORDER BY
  CASE -- Order by a custom order
    WHEN dea.location = 'Low income' THEN 1
    WHEN dea.location = 'Lower middle income' THEN 2
    WHEN dea.location = 'Upper middle income' THEN 3
    WHEN dea.location = 'High income' THEN 4
  END; 
  
-- 3: Time series of the infection, death and vaccination rates by income group

SELECT
 dea.location AS IncomeType,
 dea.date AS Date,
 COALESCE(((dea.total_deaths*1.0)/(dea.total_cases*1.0))*100,0) AS DeathRatePercentage, -- Coalesce (replace null value) with zero as it is mostly due to start of pandemic with no cases/deaths
 COALESCE(((dea.total_cases*1.0)/dea.population)*100,0) AS PopulationInfectedPercentage,
 ((vac.people_vaccinated*1.0)/dea.population)*100 AS PopulationVaccinatedPercentage     -- Lots of missing data for after a certain date so cannot coalesce with zero for accurate replacement
FROM
 covid_deaths AS dea
JOIN
 covid_vaccinations AS vac 
ON
 dea.location = vac.location 
 AND dea.date = vac.date 
WHERE
 dea.continent IS NULL AND 
 dea.location LIKE '%income' AND
 dea.date IS NOT '2023-12-07'    -- Last updated date is 2023-12-06 so 07 only has missing values
ORDER BY
  CASE -- Order by a custom order    
    WHEN dea.location = 'Low income' THEN 1
    WHEN dea.location = 'Lower middle income' THEN 2
    WHEN dea.location = 'Upper middle income' THEN 3
    WHEN dea.location = 'High income' THEN 4
  END; 
