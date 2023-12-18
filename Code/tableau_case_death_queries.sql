/* 
CREATED BY: ISABELLE RAJENDIRAN 
CREATED DATE: 2023-12-18 
DESCRIPTION: Global COVID-19 data queries for data visualisation using Tableau
*/

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
 
 
-- Potential: Total deaths by country
-- SELECT
--  location AS Country,
--  SUM(CAST(new_deaths AS INT)) AS TotalDeaths
-- FROM
--  covid_deaths
-- WHERE
--  continent IS NOT NULL
-- GROUP BY 
--  location
-- ORDER BY
--  location; 
