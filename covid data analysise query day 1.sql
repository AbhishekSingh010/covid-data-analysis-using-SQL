
select * from portfolio..CovidDeaths
where continent is not null
order by 3,4

--select * from portfolio..CovidVaccinations
--order by 3,4

select Location,date,total_cases,new_cases,total_deaths,population
from portfolio..CovidDeaths
order by 1,2

--looking at total cases vs total deaths

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from portfolio..CovidDeaths
where location like 'india'
order by 1,2

-- looking at total cases vs population
select Location,date,population,total_cases,(total_cases/population)*100 as infected_populaton
from portfolio..CovidDeaths
where location like '%india%'
order by 1,2

--looking at countries having highest infection rate compared to population
select Location,population,max(total_cases) as highest_infection_count,max((total_cases/population))*100 as infected_populaton_percent
from portfolio..CovidDeaths
Group By location,population
having location like '%india%'
order by infected_populaton_percent desc


--showing the countries with highest deaths count per population

select Location,population,max(cast(total_deaths as int)) as highest_death_count
from portfolio..CovidDeaths
where continent is not null
Group By location,population
order by highest_death_count desc


--by continent
select location,max(cast(total_deaths as int)) as highest_death_count
from portfolio..CovidDeaths
where continent is  null
Group By location
order by highest_death_count desc

--GLOBAL counts
select sum(new_cases)as total_cases,sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100
as death_percentage
from portfolio..CovidDeaths
--where location like 'india'
where continent is not null
--group by date
order by 1,2



-- tabel covid vaccination
select* from CovidVaccinations

--join


--looking at total Population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int )) over (Partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccinated
from portfolio..CovidDeaths dea
join portfolio..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use cte

with popvsvac(continent,location,date,Population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int )) over (Partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccinated
from portfolio..CovidDeaths dea
join portfolio..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

)
select *,(rollingpeoplevaccinated/Population)*100 from popvsvac

--Temp Table

Drop table if exists #perceptpopulationVaccinated

create table  #perceptpopulationVaccinated
(
continent varchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #perceptpopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int )) over (Partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccinated
from portfolio..CovidDeaths dea
join portfolio..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *,(rollingpeoplevaccinated/Population)*100 from #perceptpopulationVaccinated


--view(for store data to use for later visualisation)

create view Global_Numbers as
select sum(new_cases)as total_cases,sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100
as death_percentage
from portfolio..CovidDeaths
--where location like 'india'
where continent is not null
--group by date
--order by 1,2
