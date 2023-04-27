/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


Select * from PortfolioProject..CovidVaccinations
order by 3,4


-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contracts Covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%vietnam%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
order by 1,2 


-- Countries with Highest Infection Rate compared to Population

Select location, population, date, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as 
	PercentPopulationInfected
from PortfolioProject..CovidDeaths
Group by location, population, date
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select location, MAX(Total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc



--LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

Select continent, MAX(Total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(new_deaths) / SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- where location like '%vietnam%'
where continent is not null
--group by date
order by 1,2



Select location, SUM(new_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
and location not in ('World', 'European Union') and location not like '%income%'
group by location
order by TotalDeathCount desc

 

 -- Looking at Total Population vs Vaccination
 -- Using CTE to perform Calculation on Partition By

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location 
order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, RollingPeopleVaccinated/Population*100 as PercentPopulationVaccinated
from PopvsVac



-- Using Temp Table to perform Calculation on Partition By

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location 
order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, RollingPeopleVaccinated/Population*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated




-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location 
order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated
