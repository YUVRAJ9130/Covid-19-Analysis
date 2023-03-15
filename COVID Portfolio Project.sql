/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
USE PortfolioProject

SELECT *
FROM CovidDeaths;

SELECT *
FROM CovidVaccinations
ORDER BY 3,4

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2

-- Looking at total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in a country

SELECT location, date, total_cases, total_deaths,ROUND((total_deaths/total_cases) *100,2) as FatalityRatePercent
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--Total Cases vs Population
--Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, ROUND((total_cases/population) *100,2) as InfectionRatePercent
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--Highest infection rate compared to population

SELECT location, MAX(total_cases) as HighestInfectionCount, ROUND(MAX(total_cases/population) *100,2) as InfectionRatePercent
FROM CovidDeaths
GROUP BY location
ORDER BY InfectionRatePercent DESC

--Showing Countries with Highest Death Count compared to Population

SELECT location,  MAX(total_deaths) as HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT
--Showing Countries with Highest Death Count compared to Population

SELECT continent,  MAX(total_deaths) as HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

--Global Numbers

SELECT CAST(date as date) as Date ,SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths,ROUND(SUM(new_deaths)/SUM(new_cases)*100,2) as FatalityRatePercent
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations
-- Show vaccination rate on a running total

SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalPeopleVaccinated
FROM CovidDeaths dea, CovidVaccinations vac
    WHERE dea.location = vac.location
    and dea.date = vac.date
    and dea.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopcvsVac (continent, location, date, population, new_vaccinations, TotalPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalPeopleVaccinated
FROM CovidDeaths dea, CovidVaccinations vac
    WHERE dea.location = vac.location
    and dea.date = vac.date
    and dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (TotalPeopleVaccinated/population)*100 AS PercentVaccinated FROM PopcvsVac

-- Creating View to store data

CREATE VIEW PercentVaccinated AS
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalPeopleVaccinated
FROM CovidDeaths dea, CovidVaccinations vac
    WHERE dea.location = vac.location
    and dea.date = vac.date
    and dea.continent IS NOT NULL

SELECT * FROM PercentVaccinated