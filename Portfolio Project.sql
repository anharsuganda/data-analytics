SELECT *
FROM PorfolioProject..CovidDeaths
ORDER BY 3, 4

--SELECT *
--FROM PorfolioProject..CovidVaccinations
--WHERE Continent IS NOT NULL
--ORDER BY 3, 4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PorfolioProject..CovidDeaths
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid inyour country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2


-- Looking at Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PorfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1, 2


-- Looking at Countries with Gighest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PorfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PorfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC



-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing continents with the highest death count per population

SELECT Continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PorfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT SUM(new_cases), SUM(CAST(new_deaths AS INT)), (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE Continent IS NOT NULL
--GROUP BY Date
ORDER BY 1, 2



-- Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
	dea.date) AS RollingPeopleVaccinated
	--RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3



-- Use CTE


WITH PopVSVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinated)
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
		dea.date) AS RollingPeopleVaccinated
		--RollingPeopleVaccinated
	FROM PorfolioProject..CovidDeaths dea
	JOIN PorfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2, 3
)

SELECT *, (RollingVaccinated/Population)*100
FROM PopVSVac



-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinated numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
	dea.date) AS RollingPeopleVaccinated
	--RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

DROP VIEW IF EXISTS PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
	dea.date) AS RollingPeopleVaccinated
	--RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated