SELECT * 
FROM PortfolioProj..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3, 4

--SELECT * 
--FROM PortfolioProj..CovidVaccination
--ORDER BY 3, 4

-- Данные для работы

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProj..CovidDeaths
ORDER BY 1, 2

-- total cases VS total deaths
-- вероятность умереть от ковида в России
SELECT location, date, total_cases, total_deaths, (total_deaths * 100.0 / total_cases) AS DeathPercentage
FROM PortfolioProj..CovidDeaths
WHERE location = 'Russia'
ORDER BY 1, 2

-- total_cases VS population
-- проценет населения болевшего ковидом
SELECT location, date, population, total_cases, (total_cases * 100.0 / population) AS IllPercentage
FROM PortfolioProj..CovidDeaths
WHERE location = 'Russia'
ORDER BY 1, 2

-- отношение Infection rate к population
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases * 100.0 / population) AS Percentage_population_infected
FROM PortfolioProj..CovidDeaths
--WHERE location = 'Russia'
GROUP BY location, population
--HAVING location = 'Russia'
ORDER BY Percentage_population_infected DESC

-- Страны с наибольшей смертностью среди населения
SELECT location, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProj..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY total_death_count DESC

--SELECT location, MAX(cast(total_deaths as int)) AS total_death_count
--FROM PortfolioProj..CovidDeaths
--WHERE continent IS NULL 
--GROUP BY location
--ORDER BY total_death_count DESC

-- по континентам
SELECT continent, MAX(cast(total_deaths AS int)) AS total_death_count
FROM PortfolioProj..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY total_death_count DESC

-- global numbers
SELECT date, SUM(cast(new_cases AS int)) as total_cases, SUM(cast(new_deaths AS int)) as total_deaths, SUM(cast(new_deaths as int)) * 100.0 / SUM(cast(new_cases as int)) as DeathPercentage--, total_deaths, (total_deaths * 100.0 / total_cases) AS DeathPercentage
FROM PortfolioProj..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

SELECT SUM(cast(new_cases AS int)) as total_cases, SUM(cast(new_deaths AS int)) as total_deaths, SUM(cast(new_deaths as int)) * 100.0 / SUM(cast(new_cases as int)) as DeathPercentage--, total_deaths, (total_deaths * 100.0 / total_cases) AS DeathPercentage
FROM PortfolioProj..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- CTE
With PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS (
-- total population vs vactination (кумулятивное накопление вакцинированных)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM PortfolioProj..CovidDeaths dea
JOIN PortfolioProj..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (rolling_people_vaccinated * 100.0 / population)
FROM PopvsVac


-- TEMPORARY TABLE
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM PortfolioProj..CovidDeaths dea
JOIN PortfolioProj..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (rolling_people_vaccinated * 100.0 / population) AS persent_of_vaccinated_people
FROM #percent_population_vaccinated

-- View для визуализаций
CREATE VIEW percent_population_vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM PortfolioProj..CovidDeaths dea
JOIN PortfolioProj..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

--SELECT SCHEMA_NAME(schema_id) AS [Schema], name, type_desc 
--FROM sys.all_objects 
--WHERE name = 'percent_population_vaccinated';

SELECT *
FROM percent_population_vaccinated