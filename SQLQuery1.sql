/*

Queries used for Tableau Project

*/

-- 1. 

Select SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int) * 100.0)/SUM(cast(new_Cases as int)) as DeathPercentage
From PortfolioProj..CovidDeaths
where continent is not null 
order by 1,2


-- 2. 

-- We take these out as they are not included in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProj..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases * 100.0 /population)) as PercentPopulationInfected
From PortfolioProj..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProj..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc
