Select * 
FROM PortfolioProject..CovidDeaths
order by 3,4

--Select * 
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Select the data we are going to be using

Select location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Looking at the total cases vs total deaths
-- getting error Operand data type nvarchar is invalid for divide operator for total_death / total_cases ... going to change both of those to become ints

Alter table PortfolioProject..CovidDeaths
Alter Column total_deaths Float

Alter table PortfolioProject..CovidDeaths
Alter Column total_cases Float

Select location,date,total_cases,population,(total_deaths / total_cases)*100 as DeathsPercentage
FROM PortfolioProject..CovidDeaths
where location = 'canada'
order by 1,2

-- Looking at the total cases vs Population
Select location,date,population,total_cases,(total_cases / population)*100 as DeathsPercentage
FROM PortfolioProject..CovidDeaths
where location = 'canada'
order by 1,2


--looking at countries with highest infection rate compared to populations
Select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases / population))*100 as PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
--where location = 'canada'
Group by location, population
order by PercentOfPopulationInfected DESC


-- Showing the countries with the highest death count per population

Select location,MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location = 'canada'
where continent is not null
Group by location
Order by TotalDeathCount Desc

-- Breaking this up by continents
-- showing continent with highest death count
Select Continent,MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location = 'canada'
where continent is not null
Group by Continent
Order by TotalDeathCount Desc

-- total deaths by date and percentage

Select date,sum(new_cases) as new_cases, sum(new_deaths) as new_deaths, isnull(sum(cast(new_deaths as int))/sum(cast (new_cases as int)),0)
--,sum(cast(new_deaths as int))/sum (cast(new_cases as int))*100 as DeathsPercentage
FROM PortfolioProject..CovidDeaths
--where location = 'canada'
where continent is not null
group by date
order by 1,2


-- joining both tables to compare.. looking at Covid Vaccinations
-- partition is what makes it so that the values are correct for location , then date is what will make it add up separately by date
select dea.continent,  dea.location,dea.date,dea.population, vac.new_vaccinations , sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location,dea.date) 
as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	order by 2,3


-- Using CTE

with PopvsVac ( Continent,location,date,population,new_vaccinations,rollingpeoplevaccinated )

as
(
select dea.continent,  dea.location,dea.date,dea.population, vac.new_vaccinations , sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location,dea.date) 
as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--	order by 2,3
)
Select * , (rollingpeoplevaccinated/population)*100 as 'ratio for people vaccinated vs population'
from PopvsVac

--temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacinnated numeric )

Insert into #PercentPopulationVaccinated 
select dea.continent,  dea.location,dea.date,dea.population, vac.new_vaccinations , sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location,dea.date) 
as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--	order by 2,3

Select *, (RollingPeopleVacinnated/population)*100
from #PercentPopulationVaccinated 

-- Creating view for later use

Create view CountriesHighestDeath as
Select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases / population))*100 as PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
--where location = 'canada'
Group by location, population
--order by PercentOfPopulationInfected DESC


create view TotalCasesVsPopulation as

-- Looking at the total cases vs Population
Select location,date,population,total_cases,(total_cases / population)*100 as DeathsPercentage
FROM PortfolioProject..CovidDeaths
--where location = 'canada'
--order by 1,2

