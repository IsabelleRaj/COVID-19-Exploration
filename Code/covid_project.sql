/* 
CREATED BY: ISABELLE RAJENDIRAN 
CREATED DATE: 2023-12-08 
DESCRIPTION: Data exploration of global COVID-19 data. 
SKILLS USED: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT 
 location AS Country,
 date AS Date,
 total_cases AS TotalCases,
 total_deaths AS TotalDeaths,
 population AS PopulationSize
FROM
 covid_deaths
WHERE
 continent IS NOT NULL  -- Note: Where continent is NULL, continent information is found in the location column which we do not want
ORDER BY
 location,
 date;

-- EXPLORATION BY LOCATION
 
-- Total cases vs total deaths
-- Demonstrates likelihood of death upon contracting COVID-19 in each country

SELECT
 location AS Country,
 date AS Date,
 total_cases AS TotalCases,
 total_deaths AS TotalDeaths,
 round((total_deaths*1.0)/(total_cases*1.0)*100, 3) as DeathRatePercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL 
ORDER BY
 location,
 date;

-- Total cases vs total deaths as of the 6th december 2023

SELECT
 location AS Country,
 date AS Date,
 total_cases AS TotalCases,
 total_deaths AS TotalDeaths,
 round((total_deaths*1.0)/(total_cases*1.0)*100, 3) as DeathRatePercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL AND date = '2023-12-06'
ORDER BY
 location;
 
-- Alternative - Date differs as it is the last updated date for that country
SELECT
 location AS Country,
 date as Date,
 MAX(total_cases*1) AS TotalCases, 
 MAX(total_deaths*1) AS TotalDeaths, 
 round((MAX(total_deaths*1.0)/MAX(total_cases*1.0))*100,3) as DeathRatePercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL
GROUP BY
 location
ORDER BY
 location;

-- Total cases vs population
-- Shows the percentage of the population who are infected with COVID-19

SELECT 
 location AS Country,
 date AS Date,
 population AS PopulationSize,
 total_cases AS TotalCases,
 round(((total_cases*1.0)/population)*100, 5) as PopulationInfectedPercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL 
ORDER BY
 location,
 date;

-- Countries with the highest infection rate compared to population

SELECT
 location AS Country,
 population AS PopulationSize,
 MAX(total_cases*1) AS TotalCases, 
 MAX(round((total_cases * 1.0 / population) * 100, 3)) AS PopulationInfectedPercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL
GROUP BY
 location
ORDER BY
 MAX(round((total_cases * 1.0 / population) * 100, 3)) DESC;

--  Countries with the highest death count compared to population

SELECT
 location AS Country,
 population AS PopulationSize,
 MAX(total_deaths*1) AS TotalDeaths, 
 MAX(round((total_deaths * 1.0 / population) * 100, 3)) AS DeathRatePercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL
GROUP BY
 location
ORDER BY
 MAX(round((total_deaths * 1.0 / population) * 100, 3)) DESC;

-- EXPLORATION BY CONTINENT 

-- Continents with the highest death count compared to population

SELECT
 continent AS Continent,
 population AS PopulationSize,
 MAX(total_deaths*1) AS TotalDeaths, 
 MAX(round((total_deaths * 1.0 / population) * 100, 3)) AS DeathRatePercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL
GROUP BY
 continent
ORDER BY
 MAX(round((total_deaths * 1.0 / population)* 100, 3)) DESC;
 
-- NOTE: There are cases listed with NULL continent information so this data is not accurate. 
-- Additionally, there is continent information within location column where continent is NULL sometimes (following query)

SELECT
 location,
 continent
FROM
 covid_deaths
WHERE
 continent IS NULL
GROUP BY
 location;

-- GLOBAL NUMBERS

-- Cumulative increase in COVID-19 cases and deaths globally

SELECT DISTINCT
 date AS Date,
 SUM(new_cases) OVER (ORDER BY date) AS CumulativeCaseTotal,
 SUM(new_deaths) OVER (ORDER BY date) AS CumulativeDeathTotal
FROM
 covid_deaths
WHERE
 continent IS NOT NULL;
 
-- Daily COVID-19 new cases and deaths globally

SELECT
 date AS Date,
 sum(CAST(new_cases AS INT)) AS NewCases,
 sum(CAST(new_deaths AS INT)) AS NewDeaths
FROM
 covid_deaths
WHERE
 continent IS NOT NULL
GROUP BY
 date

-- VACCINATION TABLES

-- Total vaccination count per country

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
 dea.location = vac.location 
 AND dea.date = vac.date 
WHERE
 dea.continent IS NOT NULL
GROUP BY
 dea.location
ORDER BY
 1,2;

-- Rolling count of vaccinations in each country
-- NOTE: Despite not including the new_boosters column, the cumulative vaccination exceeds the population size
-- for certaion countries implying the new_vaccinations could include the boosters so multiple vaccinations per person

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

-- Total vaccinations vs population
-- Shows the percentage of the population who are vaccinnated against COVID-19. NOTE: Exceeds 100% possibly due to 
-- inclusion of boosters so multiple vaccines per person.

-- Using CTE to perform calculation on CumulativeVaccinationTotal in previous query

with PopvsVac (Continent, Country, Date, PopulationSize , NewVaccinations, CumulativeVaccinationTotal)
as 
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

-- Using temp table to perform calculation on CumulativeVaccinationTotal in previous query

-- DROP Table IF EXISTS PercentPopulationVaccinated;

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
 
SELECT *, (CAST(CumulativeVaccinationTotal AS FLOAT)/CAST(PopulationSize AS FLOAT))*100 AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;

-- Creating views to store data for later visualisation

-- CREATE VIEW PercentPopulationVaccinatedView as
SELECT *, (CAST(CumulativeVaccinationTotal AS FLOAT)/CAST(PopulationSize AS FLOAT))*100 AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;

SELECT *
FROM PercentPopulationVaccinatedView;
 
-- Exploring income type as a variable affecting total cases, deaths and vaccinations (at least 1 vaccine)

SELECT
 dea.location AS IncomeType
FROM
 covid_deaths AS dea
JOIN
 covid_vaccinations AS vac 
ON
 dea.location = vac.location 
 AND dea.date = vac.date 
WHERE
 dea.continent IS NULL and dea.location LIKE '%income'
GROUP BY
 dea.location;

--CREATE VIEW IncomeView as
SELECT
 dea.location AS IncomeType,
 dea.population AS PopulationSize,
 MAX(CAST(dea.total_cases AS INT)) AS TotalCases,
 MAX(CAST(dea.total_deaths AS INT)) AS TotalDeaths, 
 MAX(CAST(vac.total_vaccinations AS INT)) AS TotalVaccinationsGiven,
 MAX(vac.people_vaccinated) AS TotalPeopleVaccinated,
 MAX(CAST(vac.people_vaccinated AS INT)) AS TotalPeopleVaccinated,
 round((MAX(dea.total_deaths*1.0)/MAX(dea.total_cases*1.0))*100,3) as DeathRatePercentage,
 round((MAX(dea.total_cases*1.0)/dea.population)*100,3) as PopulationInfectedPercentage,
 round((MAX(vac.people_vaccinated*1.0)/dea.population)*100,3) as PopulationVaccinatedPercentage
FROM
 covid_deaths AS dea
JOIN
 covid_vaccinations AS vac 
ON
 dea.location = vac.location 
 AND dea.date = vac.date 
WHERE
 dea.continent IS NULL and dea.location LIKE '%income'
GROUP BY
 dea.location
ORDER BY
  CASE
    WHEN dea.location = 'Low income' THEN 1
    WHEN dea.location = 'Lower middle income' THEN 2
    WHEN dea.location = 'Upper middle income' THEN 3
    WHEN dea.location = 'High income' THEN 4
  END; 
