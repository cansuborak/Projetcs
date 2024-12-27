-- COVIDVACCINATIONS TABLE
-- Counts how many NULL values are in each column of CovidVaccinations
SELECT
  SUM(CASE WHEN new_tests IS NULL THEN 1 ELSE 0 END)                AS missing_new_tests,
  SUM(CASE WHEN total_tests IS NULL THEN 1 ELSE 0 END)              AS missing_total_tests,
  SUM(CASE WHEN total_tests_per_thousand IS NULL THEN 1 ELSE 0 END) AS missing_total_tests_per_thousand,
  SUM(CASE WHEN life_expectancy IS NULL THEN 1 ELSE 0 END)          AS missing_life_expectancy,
  SUM(CASE WHEN human_development_index IS NULL THEN 1 ELSE 0 END)  AS missing_hdi
FROM PortfolioProjects.dbo.CovidVaccinations;

-- Find Specific Rows With Missing Values
SELECT *
FROM PortfolioProjects.dbo.CovidVaccinations
WHERE new_tests IS NULL;

-- Replacing NULL with a Default or Placeholder
UPDATE PortfolioProjects.dbo.CovidVaccinations
SET new_tests = 0
WHERE new_tests IS NULL;

-- COVIDDEATHS TABLE
-- Counts how many NULL values are in each column of CovidDeaths
SELECT
  SUM(CASE WHEN population IS NULL THEN 1 ELSE 0 END)               AS missing_population,
  SUM(CASE WHEN total_cases IS NULL THEN 1 ELSE 0 END)              AS missing_total_cases,
  SUM(CASE WHEN new_cases IS NULL THEN 1 ELSE 0 END)                AS missing_new_cases,
  -- ... repeat CASE statements for each column you want to check ...
  SUM(CASE WHEN weekly_hosp_admissions IS NULL THEN 1 ELSE 0 END)   AS missing_weekly_hosp_admissions
FROM PortfolioProjects.dbo.CovidDeaths;

-- Find Specific Rows With Missing Values
SELECT *
FROM PortfolioProjects.dbo.CovidDeaths
WHERE total_cases IS NULL;

-- Replacing NULL with a Statistical Aggregate
-- Calculate the average
SELECT AVG(CAST(new_cases AS FLOAT)) AS avg_new_cases
FROM PortfolioProjects.dbo.CovidDeaths
WHERE new_cases IS NOT NULL;

-- Use the value to update
UPDATE PortfolioProjects.dbo.CovidDeaths
SET new_cases = 500.75
WHERE new_cases IS NULL;


-- Combine both table
SELECT
    v.iso_code,
    v.continent,
    v.location,
    v.date,
    v.new_tests,
    v.total_tests,
    v.people_vaccinated,
    d.population,
    d.total_cases,
    d.new_cases,
    d.total_deaths,
    d.new_deaths
FROM PortfolioProjects.dbo.CovidVaccinations AS v
INNER JOIN PortfolioProjects.dbo.CovidDeaths AS d
    ON  v.iso_code  = d.iso_code
    AND v.location  = d.location
    AND v.[date]    = d.[date];






