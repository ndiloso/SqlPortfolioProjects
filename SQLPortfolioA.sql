SELECT *  
FROM [PortfolioProject].[dbo].[CovidDeaths]
Where continent is not null
ORDER by 3,4

SELECT *  
FROM [PortfolioProject].[dbo].[CovidVaccination]
ORDER BY 3,4



SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject].[dbo].CovidDeaths
Where continent is not null
ORDER BY 1,2

--Looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths As float)/CAST(total_cases AS float)) * 100 AS DeathPercentages
FROM [PortfolioProject].[dbo].CovidDeaths
Where location like '%states'
and continent is not null
ORDER BY 1,2

--Looking at total cases vs population
--Shows what percentage of population had covid
SELECT location, date, total_cases, total_deaths, CAST(total_cases As float)/CAST(population AS float) * 100 as CovidCases
FROM [PortfolioProject].[dbo].CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

--Looking at countries with highestg infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(CAST(total_cases As float)/CAST(population as float)) * 100 AS 
PercentOfPoulationInfected
FROM [PortfolioProject].[dbo].CovidDeaths
Group by location,population
ORDER BY PercentOfPoulationInfected

--Showing countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount Desc

-- Separate them by continents

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount Desc

-- Showing the continent with the highest death count per population 

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Global numbers

SELECT date, SUM(new_cases) as TotalCases --Sum(Cast(new_deaths as float)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by date
order by 1,2


SELECT date, SUM(new_cases) as TotalCases, Sum(Cast(new_deaths as float)) as total_deaths -- SUM(Cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by date 
order by 1,2

SELECT date, SUM(new_cases) as TotalCases, Sum(Cast(new_deaths as float)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by date 
order by 1,2


SELECT SUM(new_cases) as TotalCases, Sum(Cast(new_deaths as float)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases) 
* 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

SELECT *
From PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date

  -- Looking at total population vs vaccinations
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccined
From PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (Continent, Location,Date,Population,New_vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population) *100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3