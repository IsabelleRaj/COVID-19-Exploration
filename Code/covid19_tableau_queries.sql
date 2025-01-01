/* 
-------------------------------------------------------------------------------
CREATED BY:	  ISABELLE RAJENDIRAN 
CREATED DATE: 2023-12-18 
LAST UPDATED: 2025-01-01
DESCRIPTION:  Queries for the visualisation of the COVID-19 data exploration, 
		  using Tableau
-------------------------------------------------------------------------------
MODIFICATION HISTORY:
- 2024-12-30
	- Added additional queries, restructured the code and added comments 
	  throughout.
- 2025-01-01
	- Edited the queries.
-------------------------------------------------------------------------------
*/

-- **LOCATION DASHBOARD** --
 
-- 1: Time series of continent-level statistics

CREATE VIEW TableauLocationOne AS
SELECT
 dea.location AS Continent,
 dea.population AS PopulationSize,
 dea.date AS Date,
 COALESCE(dea.total_cases,0) AS TotalCases,  -- Coalesce (replace null value) with zero as it is mostly due to start of pandemic before the first case/death
 COALESCE(dea.total_deaths,0) AS TotalDeaths,
 COALESCE(((dea.total_deaths*1.0)/(dea.total_cases*1.0))*100,0) AS DeathRatePercentage,
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
 dea.location in ('Africa', 'Asia', 'Europe', 'North America', 'South America', 'Oceania') AND
 dea.date IS NOT '2023-12-07'    -- Last updated date is 2023-12-06 so 07 only has missing values
ORDER BY
 dea.location,
 dea.date;

-- 2: Time series of country-level statistics

-- Note: The population size is constant for each country implying the population size stated is latest known population 
-- as of date of download and not during the date stated.

CREATE VIEW TableauLocationTwo AS
SELECT
 dea.continent AS Continent,
 dea.location AS Country,
 dea.population AS PopulationSize,
 dea.date AS Date,
 COALESCE(dea.total_cases,0) AS TotalCases,  -- Coalesce (replace null value) with zero as it is mostly due to start of pandemic before the first case/death
 COALESCE(dea.total_deaths,0) AS TotalDeaths,
 COALESCE(((dea.total_deaths*1.0)/(dea.total_cases*1.0))*100,0) AS DeathRatePercentage,
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
 dea.continent IS NOT NULL AND
 dea.date IS NOT '2023-12-07'    -- Last updated date is 2023-12-06 so 07 only has missing values
ORDER BY
 dea.location,
 dea.date; 
 
-- Note: The time series of the global cases, death and death rate was calculated from the sum of the totals of the above view.

-- 3: Geographical mapping of continent in tableau

CREATE VIEW TableauContinent AS
SELECT
 continent AS Continent,
 location AS Country
FROM
 covid_deaths
WHERE 
 continent IS NOT NULL;
 
 
-- **INCOME DASHBOARD** --
 
-- 1: Time series of the total cases, total deaths as well as the infection, death and vaccination rates by income group

--DROP VIEW IF EXISTS TableauIncome;
CREATE VIEW TableauIncome AS
SELECT
 dea.location AS IncomeType,
 dea.population AS PopulationSize,
 dea.date AS Date,
 COALESCE(dea.total_cases,0) AS TotalCases,  -- Replace NULL with 0
 COALESCE(dea.total_deaths,0) AS TotalDeaths,
 CASE
   WHEN dea.date < '2023-01-01' THEN COALESCE(vac.people_vaccinated,0)  -- Replace NULL with 0 before 2023
   ELSE vac.people_vaccinated -- Do not coalesce for after 2023 to zero as this is real missing data (not the start of pandemic)
 END AS TotalPeopleVaccinated,
 COALESCE((dea.total_deaths*1.0)/(dea.total_cases*1.0)*100,0) AS DeathRatePercentage,
 COALESCE((dea.total_cases*1.0)/dea.population*100,0) AS PopulationInfectedPercentage,
 CASE
   WHEN dea.date < '2023-01-01' THEN COALESCE((vac.people_vaccinated*1.0)/dea.population*100,0) 
   ELSE (vac.people_vaccinated*1.0)/dea.population*100 
 END AS PopulationVaccinatedPercentage
FROM
 covid_deaths AS dea
JOIN
 covid_vaccinations AS vac 
ON
 dea.location=vac.location
 AND dea.date=vac.date 
WHERE
 dea.continent IS NULL AND 
 dea.location LIKE '%income' AND
 dea.date IS NOT '2023-12-07'    -- Last updated date is 2023-12-06 so 07 only has missing values
ORDER BY
  CASE -- Order by a custom order    
    WHEN dea.location='Low income' THEN 1
    WHEN dea.location='Lower middle income' THEN 2
    WHEN dea.location='Upper middle income' THEN 3
    WHEN dea.location='High income' THEN 4
  END;

  