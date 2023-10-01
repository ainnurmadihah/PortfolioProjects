Select*
From PortfolioProject..CovidDeaths
where continent is not NULL
order by 3,4

--Select*
--From PortfolioProject..CovidVaccination
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not NULL
order by 1,2 

--Looking at Total Cases vs Total Deaths
--shows likelihoodd of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%state%'
order by 1,2 

--Looking at total cases vc population
--shows what percentage of population that got covid

Select Location, date, total_cases, population, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%state%'
order by 1,2 

--looking at country with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%state%'
Group by Location, population
order by PercentPOpulationInfected desc

--Showing Countries with Highest Death Count Per Population

Select Location, MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%state%'
where continent is not NULL
Group by Location
order by TotalDeathCount desc

--LET'S BREAKS THINGS DOWN BY CONTINENT

Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%state%'
where continent is not NULL
Group by continent
order by TotalDeathCount desc

--Showing continents with the highest deaths count per population

Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%state%'
where continent is not NULL
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select date, SUM(new_cases) as total_cases , SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
--Where location like '%state%'
where continent is not NULL
Group by date
order by 1,2 


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From  PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not NULL
  order by 2,3 

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From  PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not NULL
  --order by 2,3 
  )
  Select*, (RollingPeopleVaccinated/Population)*100
  From PopvsVac

  --TEMP TABLE
DROP Table if exists #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
POpulation numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From  PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  --where dea.continent is not NULL
  --order by 2,3 
 Select*, (RollingPeopleVaccinated/Population)*100
 From #PercentpopulationVaccinated

 --Creating view to store data for later visualizations
 
 Create view PercentPopulationVaccinated as 
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From  PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not NULL
  --order by 2,3 
  

  Select*
  From PercentPopulationVaccinated
