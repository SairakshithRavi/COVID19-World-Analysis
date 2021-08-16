select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--where continent is not null
--order by 3,4

--Select Data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Looking at Total Cases Vs Total Deaths
--Shows likelihood of dying if you are infected with covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths$
where location = 'India'
where continent is not null
order by 1,2

--Looking at Total Cases Vs Population
--Shows what percentage got covid

Select location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
where continent is not null
--where location = 'India'
order by 1,2

--Looking at countries with highest infection Rate compared to Population
Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
--where location = 'India'
where continent is not null
Group By location, population
order by PercentagePopulationInfected DESC

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNTS PER POPULATION
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null --we get only countries
--where location = 'India'
Group By location
order by TotalDeathCount DESC

--LETS BREAK THINGS DOWN BY CONTINENT
--SHOWING CONTINENTS WITH HIGHEST DEATH COUNTS PER POPULATION
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCountContinent
from PortfolioProject..CovidDeaths$
where continent is not null  --we get only continents
Group By continent
order by TotalDeathCountContinent DESC


--GLOBAL NUMBERS

Select SUM(new_cases) AS Total_Cases, SUM(CAST (new_deaths as INT)) as Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_Cases) * 100 AS DeathPercentage
from PortfolioProject..CovidDeaths$
--where location = 'India'
where continent is not null
--group by date
order by 1,2


--LOOKING AT TOAL POPULATION VS VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$  dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location = 'India'
order by 1,2,3

--USE CTE (COMMON TABLE EXPRESSION) TEMP RESULT SET DOESNT EXIST IN MEMORY

with PopVsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$  dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
from PopVsVac
where location = 'India'

--Temp Table
drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeoplevaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$  dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated

--creating view to store data for visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$  dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 1,2,3

select *
from PercentPopulationVaccinated
Where location = 'India'

/*Queries used for Tablue Project*/

--1. Query for total_cases, total_deaths and DeathPercentage

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
order by 1,2 

--2. Query for TotalDeathCount by continents

SELECT location, SUM(CAST(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent is null
and location not in ('World', 'European Union', 'International')
Group By location
Order by TotalDeathCount desc

--3. Query for HighestInfectionCount, PercentPopulationInfection by Countries

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/Population))*100 AS PercentPopulationInfection
FROM PortfolioProject..CovidDeaths$
GROUP by location, Population
Order by PercentPopulationInfection DESC

--4. 

SELECT Location, Population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
Group by location, population, date
Order by PercentPopulationInfected desc