SELECT * 
FROM CovidDeaths
order by 3,4

SELECT* 
FROM CovidVax
ORDER BY 3,4

-- Select Data to Use
Select location,date,population,total_cases,new_cases,total_deaths
FROM CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Death
-- Shows % of chances of dying
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location = 'Singapore'
order by 1,2


-- Looking at Total Cases vs Population 
-- % infected
Select location,date,total_cases,population,(total_cases/population)*100 as InfectedPercentage
FROM CovidDeaths
WHERE location = 'Singapore'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
Select location,population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectedPercentage
FROM CovidDeaths
Group by location, population
order by InfectedPercentage DESC



-- Showing Countries with Highest Death Count Per Population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
Group by location
order by TotalDeathCount DESC


---- Filter by continents
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
Group by continent
order by TotalDeathCount DESC


--  Global Numbers 
Select date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null 
Group by date
order by 1,2

Select SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null 
order by 1,2


-- Looking at Total Pop vs Vaccinations (Combine Tables)
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVax.new_vaccinations
,sum(cast(CovidVax.new_vaccinations as bigint)) OVER (partition by CovidDeaths.location ORDER BY CovidDeaths.location,CovidDeaths.date) as TotalVAX
--, (TotalVAX/population)*100
FROM CovidDeaths
JOIN CovidVax 
	ON  CovidDeaths.location = CovidVax.location
	and CovidDeaths.date = CovidVax.date
where CovidDeaths.continent is not null 
order by 2,3

-- Use CTE (COMMON TABLE EXPRESSIONS)(1st Method)
With PopvsVax (Continent, Location, Date, Population, New_Vaccinations, TotalVAX) as
(
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVax.new_vaccinations
,sum(cast(CovidVax.new_vaccinations as bigint)) OVER (partition by CovidDeaths.location ORDER BY CovidDeaths.location,CovidDeaths.date) as TotalVAX
--, (TotalVAX/population)*100
FROM CovidDeaths
JOIN CovidVax 
	ON  CovidDeaths.location = CovidVax.location
	and CovidDeaths.date = CovidVax.date
where CovidDeaths.continent is not null 
-- order by 2,3 
)

SELECT*, (TotalVAX/Population)*100 AS PercentageVAX
FROM PopvsVax


-- TEMPORARY TABLE (2nd Method)
IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL 
BEGIN 
    DROP TABLE #PercentPopulationVaccinated 
END
CREATE TABLE #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
TotalVAX numeric
) 

INSERT INTO #PercentPopulationVaccinated
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVax.new_vaccinations
,sum(cast(CovidVax.new_vaccinations as bigint)) OVER (partition by CovidDeaths.location ORDER BY CovidDeaths.location,CovidDeaths.date) as TotalVAX
--, (TotalVAX/population)*100
FROM CovidDeaths
JOIN CovidVax 
	ON  CovidDeaths.location = CovidVax.location
	and CovidDeaths.date = CovidVax.date
where CovidDeaths.continent is not null 
-- order by 2,3

SELECT*, (TotalVAX/Population)*100 AS PercentageVAX
FROM #PercentPopulationVaccinated


 --  Create View to store data for visualisations 
 Create View PercentPopulationVaccinated as 
 SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVax.new_vaccinations
,sum(cast(CovidVax.new_vaccinations as bigint)) OVER (partition by CovidDeaths.location ORDER BY CovidDeaths.location,CovidDeaths.date) as TotalVAX
--, (TotalVAX/population)*100
FROM CovidDeaths
JOIN CovidVax 
	ON  CovidDeaths.location = CovidVax.location
	and CovidDeaths.date = CovidVax.date
where CovidDeaths.continent is not null 
-- order by 2,3

Select * 
FROM PercentPopulationVaccinated