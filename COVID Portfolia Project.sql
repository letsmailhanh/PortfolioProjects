Select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

Select * from PortfolioProject..CovidVaccinations
order by 3,4

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
-- Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%vietnam%'
order by 1,2 


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as 
	PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%vietnam%'
Group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select location, MAX(Total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%vietnam%'
where continent is not null
Group by location
order by TotalDeathCount desc



--LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing continents with the highest death count per population

Select continent, MAX(Total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%vietnam%'
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

 

 -- Looking at Total Population vs Vaccination
 -- USE CTE

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



-- TEMP TABLE

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



