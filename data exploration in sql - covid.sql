-- DATA EXPLORATION WITH SQL: COVID DATA

--Checking the data quick
SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2


-- looking at the total cases vs total deaths in the united states
-- shows the likelihood of dying if ayou contract covid in the unted states

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%united states%'
and continent is not null
ORDER BY 1,2

-- looking at the total cases vs population
-- shows what percentage of the population got covid
-- about 10% of the population had gotten covid in the usa by 2021-04-30
SELECT location, date, total_cases, population, (total_cases/population)*100 as infection_rate
FROM PortfolioProject..CovidDeaths$
WHERE location like '%united states%'
ORDER BY 1,2


-- countries with the highest infection to population rate
-- Andorra had the highest rate with 17.125%

SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as infection_rate
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY infection_rate desc

-- Showing countries with the highest death count
-- the usa has the most deaths

SELECT location, MAX(CAST(total_deaths AS int)) AS total_deaths
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY total_deaths desc

-- breaking it down by continent
-- the continent of europe has the most deaths

SELECT location, MAX(CAST(total_deaths AS int)) AS total_deaths
FROM PortfolioProject..CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY total_deaths desc

-- global numbers
-- infections and deaths across the world

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as world_death_percent
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- global cases and deaths per day
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as world_death_percent
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--vaccinations

SELECT *
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date

SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3

-- cte

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (rolling_vaccinations/population)*100 AS vaccination_percent
FROM pop_vs_vac


-- same as above but without null values

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
and vac.new_vaccinations is not null
)
SELECT *, (rolling_vaccinations/population)*100 AS vaccination_percent
FROM pop_vs_vac

-- view usa specific vaccination rates

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.location like '%united states%'
and vac.new_vaccinations is not null
)
SELECT *, (rolling_vaccinations/population)*100 AS vaccination_percent
FROM pop_vs_vac


-- temp table

DROP TABLE IF exists #vaccination_percentage
CREATE TABLE #vaccination_percentage
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
rolling_vaccinations NUMERIC
)
INSERT INTO #vaccination_percentage
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (rolling_vaccinations/population)*100 AS vaccination_percent
FROM #vaccination_percentage


-- creating views to store data for later visualizations

CREATE VIEW vaccination_percentage as
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

-- usa views

-- looking at the total cases vs total deaths in the united states
CREATE VIEW usa_cases_v_deaths as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%united states%'
and continent is not null

-- looking at the total cases vs population
CREATE VIEW usa_cases_v_pop as
SELECT location, date, total_cases, population, (total_cases/population)*100 as infection_rate
FROM PortfolioProject..CovidDeaths$
WHERE location like '%united states%'

--saving this
