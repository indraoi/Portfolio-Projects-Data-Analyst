-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathsPercentage
FROM CovidDeaths
WHERE location LIKE 'indo%' AND continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfection
FROM CovidDeaths
WHERE location LIKE 'indo%' AND continent IS NOT NULL
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to	Population

SELECT location, population, MAX(total_cases) AS HeighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfection
FROM CovidDeaths
--WHERE location LIKE 'indo%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfection DESC


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE 'indo%'
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY TotalDeathCount DESC


SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE 'indo%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE 'indo%'
WHERE IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Looking at Total Population vs Vaccinations

SELECT date, SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths, 
 CASE 
   WHEN SUM(new_cases) > 0 THEN (SUM(CAST(new_deaths AS INT)) * 100.0) / SUM(new_cases) 
   ELSE 0
 END AS DeathsPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, TotalNewCases

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location,	dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3




-- Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location,	dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- Creating View to store data for later visualizations

CREATE View PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location,	dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
