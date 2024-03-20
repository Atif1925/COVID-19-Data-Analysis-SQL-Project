USE PortfolioProject;

Select * from CovidDeaths ;

Select * from CovidVaccinations;


Select Location, date, total_cases, new_cases, total_deaths,population
from CovidDeaths
order by 1,2




-- LOOKING AT TOTAL CASES VS TOTAL DEATHS

Select Location, date, population, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathRatio
from CovidDeaths
where Location like '%asia%'
order by 1,2


-- LOOKING AT TOTAL CASES VS POPULATION
-- SHOWS WHAT % OF POPULATION GOT COVID

Select Location, date, population, total_cases, total_deaths, (total_cases/population) * 100 AS DeathRatio
from CovidDeaths
order by 1,2

-- LOOKING AT THE COUNTRY WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

Select Location,Population, MAX(total_cases) AS HighestInfectionCount,  MAX(total_cases/population) *100 AS InfectionRatio
from CovidDeaths
group by Location,Population
order by InfectionRatio DESC


-- LOOKING AT THE HIGHEST DEATH PER POPULATION

Select Location,Population, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
from CovidDeaths
where continent is not null
group by Location,Population
order by HighestDeathCount DESC


-- LOOKING AT THE HIGHEST DEATH PER POPULATION by CONTINENT

Select continent, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
from CovidDeaths
where continent is  not null
group by continent
order by HighestDeathCount DESC

-- LOOKING AT THE HIGHEST DEATH PER POPULATION by LOCATION


Select location, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
from CovidDeaths
where continent is  null
group by location
order by HighestDeathCount DESC

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3;

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




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



