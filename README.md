# Data exploration and visualisation of global COVID-19 data 🦠

## Table of Contents
1. [Project Description](#project-description)
2. [Data](#data-source)
3. [Installation](#installation)
4. [Dashboards](#dashboards)
5. [Acknowledgments](#acknowledgement)

## Project Description
This project focuses on analysing the global COVID-19 pandemic through data exploration and visualisation. Using SQL, I conducted exploratory data analysis to uncover trends, patterns, and key insights related to the progression of the pandemic. The main key insights from my analysis was translated into visualisations on interactive dashboards using tableau.

**Key pandemic metrics measured:**
- **Cases**: Trends in cumulative case totals over time.
- **Deaths**: Cumulative death toll progression and death rates.
- **Vaccinations**: Trends in population vaccination coverage.

**Categories analysed:**
- By **Location**: Comparison of the pandemic's impact across continents (e.g., Africa, Asia, Europe) and individual countries.
- By **Income Groups**: Comparison of the pandemic's impact across countries' income groups (i.e., high income, upper middle income, lower middle income, and low income countries) to understand how economic factors influenced infection rates, vaccination progress, and mortality outcomes.

## Data
### Data Source
The data was downloaded from [Our World in Data](https://ourworldindata.org/covid-deaths), containing information between 2020-01-01 to 2023-12-07.
Regarding the income groups, the classification used is by [the World Bank](https://ourworldindata.org/grapher/world-bank-income-groups), and it is based on every country's gross national income (GNI) each year.

### Data Pre-processing
The downloaded data was processed in Excel for date format standardisation (converting 'dd/mm/yyyy' to 'yyyy-mm-dd') and to seperate the data into two tables: `covid_deaths.csv` and `covid_vaccinations.csv` files, for ease of use. 

## Installation
For this project, I used SQLite and DB browser to conduct my analysis. Refer to the [documentation](https://sqlitebrowser.org/) for further information.

**Folders explanation:**
- `Code`: Contains two `.sql` files, which contains the SQL queries for the full data exploration, and the queries used for the tableau dashboards.
- `Data`: Contains the two pre-processed data files as well as the data used for the tableau dashboards (downloaded from the SQL queries). 

**To run the analysis:**
1. Open your command prompt.
2. Navigate to your desired directory.
3. Git clone this repository using the following command:
   ```bash
   git clone https://github.com/IsabelleRaj/COVID-19-Exploration
   ```
5. Run the `.sql` files in the 'code' folder in your desired environment, using the appropriate data from the 'data' folder.

## Dashboards
Two interactive dashboards were created using tableau: the [location](https://public.tableau.com/app/profile/isabelle.rajendiran/viz/COVID-19AnalysisbyLocation/ContinentDashboard) analysis and [income group](https://public.tableau.com/app/profile/isabelle.rajendiran/viz/COVID-19AnalysisbyIncome/IncomeComparison) analysis.

Here are images of the dashboards, which can also be found in the `Visualisation` folder:

<div style="display: flex; flex-wrap: wrap; gap: 10px;">
  <img src="Visualisation/Income Dashboard Comparison.png" alt="Image 1" style="width: 45%; border: none;"/>
  <img src="Visualisation/Income Dashboard Individual.png" alt="Image 2" style="width: 45%; border: none;"/>
  <img src="Visualisation/Location Dashboard Continent.png" alt="Image 3" style="width: 45%; border: none;"/>
  <img src="Visualisation/Location Dashboard Country.png" alt="Image 4" style="width: 45%; border: none;"/>
</div>

## Acknowledgements
Thanks to [Alex The Analyst](https://www.youtube.com/@AlexTheAnalyst) from which the data analysis was built upon; and [Anthony Smoak](https://anthonysmoak.com/2020/04/25/build-a-tableau-covid-19-dashboard/) for dashboard design inspiration.
