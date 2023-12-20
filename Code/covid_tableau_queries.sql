/* 
CREATED BY: ISABELLE RAJENDIRAN 
CREATED DATE: 2023-12-18 
DESCRIPTION: Global COVID-19 data queries for data visualisation using Tableau
*/

-- Global case and death count Dashboard

-- 1: Total number of global cases and deaths

SELECT
 SUM(CAST(new_cases AS INT)) AS TotalCases,
 SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
 (SUM(new_deaths)*1.0)/SUM((new_cases)*1.0)*100 as DeathRatePercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL
ORDER BY
 TotalCases,
 TotalDeaths;
 
-- Stating continent IS NOT NULL is needed to remove these locations: 'World', 'European Union', 'High income','Low income',
-- 'Lower middle income', 'Upper middle income' 

SELECT
 location
FROM
 covid_deaths
WHERE
 continent IS NULL
GROUP BY
 location;

-- 2: Total deaths by continent

SELECT
 continent AS Continent,
 SUM(CAST(new_deaths AS INT)) AS TotalDeaths
FROM
 covid_deaths
WHERE
 continent IS NOT NULL
GROUP BY 
 continent
ORDER BY
 1,2; 
 
-- Alternative
-- SELECT
--  location AS Continent,
--  SUM(CAST(new_deaths AS INT)) AS TotalDeaths
-- FROM
--  covid_deaths
-- WHERE
--  continent IS NULL
--  AND location NOT IN ('World', 'European Union', 'High income','Low income', 'Lower middle income', 'Upper middle income')
-- GROUP BY
--  location;

-- 3: Total case count by country 

-- Note: Need to remove countries with NULL cases before importing to Tableau. Cannot assume case count is 0 - we just don't
-- have the data in this case.  

SELECT
 location AS Country,
 population AS PopulationSize,
 MAX(total_cases*1) AS TotalCases, 
 MAX((total_cases * 1.0 / population) * 100) AS PopulationInfectedPercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL
GROUP BY
 location
HAVING
 TotalCases IS NOT NULL
ORDER BY
 PopulationInfectedPercentage DESC;
 
-- 4: Cumulative case count by country

-- Note: The population size is constant for each country implying the population size stated is latest known population 
-- as of date of download and not during the date stated.
-- Also, can change NULL to 0 here as there are 0 cases before the first case.

SELECT 
 location AS Country,
 date AS Date,
 population AS PopulationSize,
 coalesce(total_cases,0) AS TotalCases,
 coalesce(((total_cases*1.0)/population)*100,0) as PopulationInfectedPercentage
FROM
 covid_deaths
WHERE
 continent IS NOT NULL 
ORDER BY
 location,
 date;
 
-- Income Type Dashboard

DROP VIEW IF EXISTS IncomeView;
CREATE VIEW IncomeView AS
SELECT
 dea.location AS IncomeType,
 dea.population AS PopulationSize,
 MAX(CAST(dea.total_cases AS INT)) AS TotalCases,
 MAX(CAST(dea.total_deaths AS INT)) AS TotalDeaths, 
 MAX(CAST(vac.total_vaccinations AS INT)) AS TotalVaccinationsGiven,
 MAX(CAST(vac.people_vaccinated AS INT)) AS TotalPeopleVaccinated,
 (MAX(dea.total_deaths*1.0)/MAX(dea.total_cases*1.0))*100 as DeathRatePercentage,
 (MAX(dea.total_cases*1.0)/dea.population)*100 as PopulationInfectedPercentage,
 (MAX(vac.people_vaccinated*1.0)/dea.population)*100 as PopulationVaccinatedPercentage
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
  
SELECT *
FROM
 IncomeView;
 
-- Time series: Death rate 

SELECT
 dea.location AS IncomeType,
 dea.date AS Date,
 coalesce(((dea.total_deaths*1.0)/(dea.total_cases*1.0))*100,0) as DeathRatePercentage
FROM
 covid_deaths AS dea
JOIN
 covid_vaccinations AS vac 
ON
 dea.location = vac.location 
 AND dea.date = vac.date 
WHERE
 dea.continent IS NULL and dea.location LIKE '%income'
ORDER BY
  CASE
    WHEN dea.location = 'Low income' THEN 1
    WHEN dea.location = 'Lower middle income' THEN 2
    WHEN dea.location = 'Upper middle income' THEN 3
    WHEN dea.location = 'High income' THEN 4
  END; 
 
-- Time series: Population Infected Percentage

SELECT
 dea.location AS IncomeType,
 dea.date AS Date,
 coalesce(((dea.total_cases*1.0)/dea.population)*100,0) as PopulationInfectedPercentage
--  ((vac.people_vaccinated*1.0)/dea.population)*100 as PopulationVaccinatedPercentage
FROM
 covid_deaths AS dea
JOIN
 covid_vaccinations AS vac 
ON
 dea.location = vac.location 
 AND dea.date = vac.date 
WHERE
 dea.continent IS NULL and dea.location LIKE '%income'
ORDER BY
  CASE
    WHEN dea.location = 'Low income' THEN 1
    WHEN dea.location = 'Lower middle income' THEN 2
    WHEN dea.location = 'Upper middle income' THEN 3
    WHEN dea.location = 'High income' THEN 4
  END; 
  
-- Time series: Population Vaccinated Percentage

SELECT
 dea.location AS IncomeType,
 dea.date AS Date,
 coalesce(((vac.people_vaccinated*1.0)/dea.population)*100,0) as PopulationVaccinatedPercentage
FROM
 covid_deaths AS dea
JOIN
 covid_vaccinations AS vac 
ON
 dea.location = vac.location 
 AND dea.date = vac.date 
WHERE
 dea.continent IS NULL and dea.location LIKE '%income'
ORDER BY
  CASE
    WHEN dea.location = 'Low income' THEN 1
    WHEN dea.location = 'Lower middle income' THEN 2
    WHEN dea.location = 'Upper middle income' THEN 3
    WHEN dea.location = 'High income' THEN 4
  END; 
