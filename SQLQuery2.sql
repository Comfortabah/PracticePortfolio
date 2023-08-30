Select *
From CovidDeaths
order by 3,4

select *
From CovidVaccinations



 --Looking at total cases vs total death
 --likelihood of dying if you contract covid in your country,

select location, date, population, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage 
From dbo.CovidDeaths
where location like '%States%'
order by 1,2


--Looking at Total cases vs Population
-- shows what percentage of population got covid

select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like '%Nigeria%'
Group by population, location
order by TotalDeathCount desc


--Look at countries with highrst infection Rate compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount,  MAX(total_cases/population)*100 as PercentPopulationInfected 
From CovidDeaths
--where location like '%Nigeria%'
Group by population, location
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like '%Nigeria%'
Group by population, location
order by TotalDeathCount desc

--Breaking this down by Continent
--Also shows continent with highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as Deathpercentage 
From dbo.CovidDeaths
--where location like '%States%'
where continent is not null
Group by date
order by 1,2

-- For Total Population Vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated, 
(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
  order by 2,3

  --Using CTE
  with PopulationsVsVaccinated (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
  as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
 -- order by 2,3
 )

 select *, (RollingPeopleVaccinated/population)*100
 From PopulationsVsVaccinated
  

 --TEMP TABLE
 DROP Table if exists #PercentPopulationVaccinated
 create Table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 Location nvarchar (255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
 -- Where dea.continent is not null
 -- order by 2,3

select *, (RollingPeopleVaccinated/population)*100
 From #PercentPopulationVaccinated

 create view PercentPopulationVaccinated as 
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
 Where dea.continent is not null
 -- order by 2,3

 select * 
 From PercentPopulationVaccinated