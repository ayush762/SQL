select *
from PortFolioProject..CovidDeaths
where continent is not null
order by 3,4


--select * 
--from PortFolioProject..CovidVaccinations
--order by 3,4


-- Selecting Data that we are going to use

select Location, date, total_cases, new_cases, total_deaths, population
from PortFolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at total cases vs total deaths
-- Shows us the likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortFolioProject..CovidDeaths
where location like '%india%'
and continent is not null
order by 1,2


-- Now Looking total cases vs population
-- Shows what percentage of population got Covid

select Location, date, Population, total_cases, (total_cases/population) * 100 as covidpopulationpercentage
from PortFolioProject..CovidDeaths
where continent is not null
--where location like '%india%'
order by 1,2


-- Looking at Countries with highest Infection Rate compared to Population

select Location, Population, max(total_cases) as HighestInfectionCount, max((total_cases/population)) * 100 as PercentPopulationInfected
from PortFolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by Location, Population
order by PercentPopulationInfected desc

-- Showing with countries with the highest death count per population

select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortFolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by Location
order by TotalDeathCount desc


-- Let break it down by continent


-- Showing the continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortFolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortFolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortFolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2


select *
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


--Looking as Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(vac.new_vaccinations, int))
over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- Use CTE

with popvsvac (Continent, Location, Date, Population, new_vaccnations, RollingPeopleVaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(vac.new_vaccinations, int))
over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select * , (RollingPeopleVaccinated/Population) * 100
from popvsvac



-- Temp Table


create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(vac.new_vaccinations, int))
over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


