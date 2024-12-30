/* 
-------------------------------------------------------------------------------
CREATED BY:	  ISABELLE RAJENDIRAN 
CREATED DATE: 2023-12-18 
LAST UPDATED: 2024-12-30
DESCRIPTION:  Queries for the visualisation of the COVID-19 data exploration, 
		  using Tableau
-------------------------------------------------------------------------------
MODIFICATION HISTORY:
- 2024-12-30
	- Added additional queries, restructured the code and added comments 
	  throughout.
-------------------------------------------------------------------------------
*/

-- **GENERAL/LOCATION DASHBOARD** --

-- 1: Total number of global cases and deaths

CREATE VIEW TableauLocationOne AS
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
 
-- NOTE: Stating continent IS NOT NULL is needed to remove these locations: 'World', 'European Union', 'High income','Low income',
-- 'Lower middle income', 'Upper middle income' 
SELECT
 location
FROM
 covid_deaths
WHERE
 continent IS NULL
GROUP BY
 location;

-- 2: Total cases, deaths and population-level statistics by continent

CREATE VIEW TableauLocationTwo AS
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

-- 3: Total cases, deaths and population-level statistics by country

CREATE VIEW TableauLocationThree AS
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
 
-- 4: Time series of the total cases, death, infection and vaccination rate across countries

-- Note: The population size is constant for each country implying the population size stated is latest known population 
-- as of date of download and not during the date stated.

CREATE VIEW TableauLocationFour AS
SELECT
 dea.location AS Country,
 dea.date AS Date,
 dea.population AS PopulationSize,
 coalesce(dea.total_cases,0) AS TotalCases,
 coalesce(((dea.total_deaths*1.0)/(dea.total_cases*1.0))*100,0) AS DeathRatePercentage, -- Coalesce (replace null value) with zero as it is mostly due to start of pandemic before the first case/death
 coalesce(((dea.total_cases*1.0)/dea.population)*100,0) AS PopulationInfectedPercentage,
 ((vac.people_vaccinated*1.0)/dea.population)*100 AS PopulationVaccinatedPercentage     -- Lots of missing data for after a certain date so cannot coalesce with zero for accurate replacement
FROM
 covid_deaths AS dea
JOIN
 covid_vaccinations AS vac 
ON
 dea.location = vac.location 
 AND dea.date = vac.date 
WHERE
 dea.continent IS NOT NULL AND
 dea.date IS NOT '2023-12-07'    -- Last updated date is 2023-12-06 so 07 only has missing values
ORDER BY
 dea.location,
 dea.date;
 
-- **INCOME DASHBOARD** --

-- 1: Exploring the total cases, deaths and vaccinations for each income group

--DROP VIEW IF EXISTS TableauIncomeOne;
CREATE VIEW TableauIncomeOne AS
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
  
-- 2: Time series of the infection, death and vaccination rates by income group

CREATE VIEW TableauIncomeTwo AS
SELECT
 dea.location AS IncomeType,
 dea.date AS Date,
 coalesce(((dea.total_deaths*1.0)/(dea.total_cases*1.0))*100,0) AS DeathRatePercentage, -- Coalesce (replace null value) with zero as it is mostly due to start of pandemic with no cases/deaths
 coalesce(((dea.total_cases*1.0)/dea.population)*100,0) AS PopulationInfectedPercentage,
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