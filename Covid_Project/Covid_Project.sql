

--select * from dbo.CovidVaccinations 
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths 
order by 1,2 

--check types of data 
sp_help 'dbo.CovidDeaths' 

-- looking at % of deaths vs total cases
select location, date,
total_cases, population, 
total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths 
order by 1,2 

-- looking at % Population infected by covid
select location, population, date,
total_cases, population, 
(total_cases/population)*100 as PercentInfected
from dbo.CovidDeaths 
where location='United states'
order by 1,2 

-- Looking at Countries with highest inefection rate compared to population 
select location, population, 
Max(total_cases) as HighestInfectionCount,
Max((total_cases/population)*100) as PercentHighestInfected
from dbo.CovidDeaths 
group by location, population
--where location='United states'
order by  PercentHighestInfected desc


-- looking at countries with highestDeathRate count per population 
select location, population, 
Max(total_deaths) as HighestDeathCount,
Max((total_deaths/population)*100) as HighestDeathRate
from dbo.CovidDeaths 
-- found out that continents were cited as countries
where continent is not null
group by location, population
order by  HighestDeathRate desc

-- Let's break things down by continent  
select location,  
Max(total_deaths) as HighestDeathCount,
Max((total_deaths/population)*100) as HighestDeathRate
from dbo.CovidDeaths 
where continent is null
group by location
order by  HighestDeathRate desc

-- Numbers Globally 
select  
SUM(new_cases) as total_cases,
SUM(new_deaths) as total_deaths,
SUM(new_deaths)/SUM(new_cases)*100 as DeathRate
from dbo.CovidDeaths 
where continent is not null
order by  1,2 desc

--R dRAFT
---- Join tables 
--select * 
--from dbo.CovidDeaths d
--Join dbo.CovidVaccinations vac 
--on d.location=vac.location 
--and d.date=vac.date

-- Looking at Total population vs Vaccinations 
-- USE CTE 
with PopVsVac (continent, location, date, population, new_vaccinations, VaccinatedPeople)
as 
(
select d.continent, d.location, d.date, d.population, vac.new_vaccinations,  
sum(vac.new_vaccinations ) over (partition by d.location order by d.location, d.date) as VaccinatedPeople
from dbo.CovidDeaths d
Join dbo.CovidVaccinations vac 
on d.location=vac.location 
and d.date=vac.date 
where d.continent is not null 
-- order by 2, 3 
) 
select *, (VaccinatedPeople/population)*100 as vaccinatedPercent from PopVsVac 

-- R draft 
---- Max 

--with PopVsVac (continent, location, date, population, new_vaccinations, VaccinatedPeople)
--as 
--(
--select d.continent, d.location, d.date, d.population, vac.new_vaccinations,  
--sum(vac.new_vaccinations ) over (partition by d.location order by d.location, d.date) as VaccinatedPeople
--from dbo.CovidDeaths d
--Join dbo.CovidVaccinations vac 
--on d.location=vac.location 
--and d.date=vac.date 
--where d.continent is not null 
---- order by 2, 3 
--) 

--select location,  MAX(new_vaccinations), MAX(VaccinatedPeople), (MAX(VaccinatedPeople)/population)*100 as TotalvaccinatedPercent 
--from PopVsVac 
--group by location

---- USE temp table 

--select d.continent, d.location, d.date, d.population, vac.new_vaccinations,  
--sum(vac.new_vaccinations ) over (partition by d.location order by d.location, d.date) as VaccinatedPeople
--from dbo.CovidDeaths d
--Join dbo.CovidVaccinations vac 
--on d.location=vac.location 
--and d.date=vac.date 
--where d.continent is not null 
---- order by 2, 3 

-- Create table #PercentPopulationVaccinated  
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated 
( 
continent nvarchar(255), 
location nvarchar (255), 
date Datetime, 
Population numeric, 
new_vaccinations numeric, 
VaccinatedPeople numeric
)

Insert into #PercentPopulationVaccinated 
 select d.continent, d.location, d.date, d.population, vac.new_vaccinations,  
sum(vac.new_vaccinations ) over (partition by d.location order by d.location, d.date) as VaccinatedPeople
from dbo.CovidDeaths d
Join dbo.CovidVaccinations vac 
on d.location=vac.location 
and d.date=vac.date 
where d.continent is not null 
-- order by 2, 3 

select *, (VaccinatedPeople/population)*100 as vaccinatedPercent 
from #PercentPopulationVaccinated 

-- Creating View to store data for visualizations 
create view PercentPopulationVaccinated as 

select d.continent, d.location, d.date, d.population, vac.new_vaccinations,  
sum(vac.new_vaccinations ) over (partition by d.location order by d.location, d.date) as VaccinatedPeople
from dbo.CovidDeaths d
Join dbo.CovidVaccinations vac 
on d.location=vac.location 
and d.date=vac.date 
where d.continent is not null 
--order by 2, 3 

select * 
from PercentPopulationVaccinated
