 ----select *
----from [Portfolio Projects]..coviddeaths
----order by 3,4

--select *
--from [Portfolio Projects]..covidvaccinations
--order by 3,4

/*Select the location, Date, Total case, News Case, and population from Coviddeaths*/

--select location, date, total_cases, new_cases, total_deaths, population
--from [Portfolio Projects]..coviddeaths
--order by 1,2

/*2. Find the percentage of Deaths vs Cases in every case*/
--select location, date, total_deaths, total_cases, ((cast(total_deaths as decimal)) / (cast(total_cases as decimal)))*100  as DeathPercentage
--from [Portfolio Projects]..coviddeaths
--   /*2b. Choose a specific location*/
--where continent is not null and location like '%malaysia%'
--order by 1,2

/*3. Find the percentage of total Cases vs Population */
--select location, date,  total_cases, population,((cast(total_cases as decimal)) / population)*100  as CasesPercentage
--from [Portfolio Projects]..coviddeaths
--where continent is not null and location like '%states%'
--order by 1,2

/*3. Countries with the Highest Infection Rates */
--select location, population, max(total_cases) as MaxInfectionCount, max((cast(total_cases as decimal))/population)*100 as 
--percentofPopulationInfected
--from [Portfolio Projects]..coviddeaths
----where continent is not null
--group by location, population
--order by percentofPopulationInfected desc

--4.Highest Death Counts per Population--
--select Location, Population, max(cast(total_deaths as decimal))as DeathCounts, 
--max((cast(total_deaths as decimal))/population)*100 as DeathPercentage
--from [Portfolio Projects]..coviddeaths
--Where continent is not null
--group by location, population
--order by DeathCounts desc

--5.Highest Death Counts by CONTINENTS--
--select location, max(cast(total_deaths as int)) as TotalDeathCounts
--from [Portfolio Projects]..coviddeaths
--where continent is null
--group by location
--order by TotalDeathCounts desc

--GLOBAL NUMBERS, calculating evrything on a global scale --


--select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
--sum(cast(new_deaths as int))/sum(New_cases)*100 as DeathPercentage
--from [Portfolio Projects]..coviddeaths
--where continent is not null 
----group by date
--order by 1,2



--Looking for Total Population vs Vaccination
--first Step (shows everything when the join is performed)
--select * 
--from [Portfolio Projects]..covidvaccinations vac
--join [Portfolio Projects]..coviddeaths dea
--    on dea.location = vac.location
--	and dea.date = vac.date

--Second Step (Narrow down.Choosing what data you want to show from both tables)
--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--from [Portfolio Projects]..covidvaccinations vac
--join [Portfolio Projects]..coviddeaths dea
--    on dea.location = vac.location
--	and dea.date = vac.date
--	where dea.continent is not null
--	order by continent, location                                                                                              

--Third Step (Show the summed number of people vaccinated using partition and CTEs)
--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --breaks the sum loop ie. ends after Algeria vaccinations end)  
----(vac.new_vaccinations/dea.population)*100 as PercentageVaccinated
--from [Portfolio Projects]..covidvaccinations vac
--join [Portfolio Projects]..coviddeaths dea
--    on dea.location = vac.location
--	and dea.date = vac.date
--	where dea.continent is not null
--	order by continent, location                                                                                              

--Fourth Step (Use the Created variable of summed number of people vaccinated by applying a CTE )
		--USE CTE
		--declare @population bigint
		--declare @RollingPeopleVaccinated bigint
--With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
--as
--(
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated --breaks the sum loop ie. ends after Algeria vaccinations end)
----, (RollingPeopleVaccinated/population)*100
--From [Portfolio Projects]..CovidDeaths dea
--Join [Portfolio Projects]..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null 
----order by 2,3
--)
--Select *, (RollingPeopleVaccinated/Population)*100 as TotalVaccinePercentage
--From PopvsVac

--FIFTH Step (Use the Created variable of summed number of people vaccinated TEMP TABLE)
Drop table if exists #PercentofPopulationVaccinated  --This line is important to add so that you don't have to manually delete Table in DB
 Create Table #PercentofPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
Insert into #PercentofPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated --breaks the sum loop ie. ends after Algeria vaccinations end)
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Projects]..CovidDeaths dea
Join [Portfolio Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
Select *,(RollingPeopleVaccinated/Population)*100 as TotalVaccinePercentage
From #PercentofPopulationVaccinated 


--CREATING VIEWS TO STORE DATA FOR FOR VISUALIZATIONS LATER
Create View PercentofPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated --breaks the sum loop ie. ends after Algeria vaccinations end)
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Projects]..CovidDeaths dea
Join [Portfolio Projects]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
Select *
from PercentofPopulationVaccinated
