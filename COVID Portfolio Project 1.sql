

SELECT [location], [date], [total_cases], [new_cases], [total_deaths], [population]
FROM [dbo].[CovidDeaths]
where continent is not null
ORDER BY 1,2


-- Looking at Total Cases vd Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select [location], [date], [total_cases], [total_deaths], (total_deaths/total_cases)*100 AS DeathPercentage
From [dbo].[CovidDeaths]
where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select [location], [date], [population], [total_cases], (total_cases/population)*100 AS CovidPercentage
From [dbo].[CovidDeaths]
--where location like '%states%'
where continent is not null
order by 1,2

-- Looking at Countries with Highest Infection rate compared to Population
Select [location], [population],MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 AS CovidPercentage
From [dbo].[CovidDeaths]
--where location like '%Turkey%'
Group by location, population
order by CovidPercentage desc

-- Showing Countries with Highest Death Count per Population
Select [location], MAX(total_deaths) as TotalDeathCount
From [dbo].[CovidDeaths]
--where location like '%Turkey%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT 
-- Showing continents with the highest death count per population
Select [continent], MAX(total_deaths) as TotalDeathCount
From [dbo].[CovidDeaths]
--where location like '%Turkey%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT 
    [date], 
    SUM(new_cases) AS TotalCases, 
    SUM(new_deaths) AS TotalDeaths, 
    ROUND((SUM(new_deaths) * 1.0 / SUM(new_cases)) * 100, 2) AS DeathPercentage
FROM 
    [dbo].[CovidDeaths]
WHERE 
    continent IS NOT NULL
GROUP BY 
    [date]
ORDER BY 
    [date];

-- Total

SELECT  
    SUM(new_cases) AS TotalCases, 
    SUM(new_deaths) AS TotalDeaths, 
    ROUND((SUM(new_deaths) * 1.0 / SUM(new_cases)) * 100, 2) AS DeathPercentage
FROM 
    [dbo].[CovidDeaths]
WHERE 
    continent IS NOT NULL
ORDER BY 
    1,2;



-- Looking at Total Population vd Vaccinations
WITH RollingVaccinations AS (
    SELECT 
        dea.[continent], 
        dea.[location], 
        dea.[date], 
        dea.[population], 
        vac.[new_vaccinations],
        SUM(CAST(vac.new_vaccinations AS INT)) OVER (
            PARTITION BY dea.location 
            ORDER BY dea.location, dea.date
        ) AS RollingPeopleVaccinated
    FROM 
        [dbo].[CovidDeaths] dea
    JOIN 
        [dbo].[CovidVaccinations] vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT 
    [continent], 
    [location], 
    [date], 
    [population], 
    [new_vaccinations], 
    RollingPeopleVaccinated,
    (CAST(RollingPeopleVaccinated AS FLOAT) / CAST(population AS FLOAT)) * 100 AS RollingPeopleRate
FROM 
    RollingVaccinations
ORDER BY 
    2, 3;




