select location,sum(cast(total_deaths as int)) from
PortfolioProject..Muertes
group by location

select 
sum(distinct(cast(total_deaths as int))) from
PortfolioProject..Muertes


select total_deaths from
PortfolioProject..Muertes

--select * from
--PortfolioProject..vacunaciones
--order by 3,4

--Seleccionamos la data que vamos a usar

select location,date, total_cases, new_cases, total_deaths,population from
PortfolioProject..muertes
order by 1,2

--Total cases vs total deaths
select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentaje
from PortfolioProject..muertes
where location like '%Peru%'
order by 1,2

--Total cases vs population
select location,date, total_cases,population, (total_cases/population)*100 as CasePercentaje
from PortfolioProject..muertes
where location like 'Cyprus'
order by CasePercentaje desc

--Mas alto ratio - Total cases vs population
select location,population, max(total_cases)as highcases, max((total_cases/population))*100 as HighPercentajeCase
from PortfolioProject..muertes
where location like '%united%'
group by location, population
order by HighPercentajeCase desc


--Mas Total muertes
select location, max(cast(total_deaths as int)) as highcases
from PortfolioProject..muertes
--where location like '%united%'
group by location
order by highcases



--Mas alto ratio - Total muertes vs population
select location,population, max(total_deaths)as highcases, max((total_deaths/population))*100 as HighPercentajeDeaths
from PortfolioProject..muertes
--where location like '%united%'
group by location, population
order by HighPercentajeDeaths desc


--Los paises con el las mayores muertes de covid al día
select location, max(cast(total_deaths as int))as total_deathcount
from PortfolioProject..Muertes
where continent is not null
group by location
order by 2 desc

--Los paises con el las mayores muertes de covid al día
select continent, max(cast(total_deaths as int))as total_deathcount
from PortfolioProject..Muertes
where continent is null
group by continent
order by 2 desc

select location, max(cast(total_deaths as int))as total_deathcount
from PortfolioProject..Muertes
where continent is null
group by location
order by 2 desc

select location, max(cast(total_deaths as int))as total_deathcount
from PortfolioProject..Muertes
where continent is null
group by location
order by 2 desc

select continent, max(cast(total_deaths as int))as total_deathcount
from PortfolioProject..Muertes
--where continent is not null
group by continent
order by 2 desc

--Casos totales por fecha
select date, sum(cast(new_cases as int))as total_cases, sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortfolioProject..Muertes
--where location like '%united%'
where continent is not null
group by date   
order by 1,2

--Casos totales 
select sum(cast(new_cases as int))as total_cases, sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortfolioProject..Muertes
--where location like '%united%'
where continent is not null
--group by date   
order by 1,2

select * from PortfolioProject..muertes
select * from portfolioproject..vacunaciones

	select mu.continent , mu.location , mu.date, mu.population, va.new_vaccinations, sum(convert(bigint,va.new_vaccinations)) over (partition by va.location order by va.location, va.date) as Acumulado_Vacc, sum(convert(bigint,va.new_vaccinations)) over (partition by va.location)
	from PortfolioProject..muertes mu
	join portfolioproject..Vacunaciones va
		on mu.date=va.date
		and mu.location=va.location
		where mu.location like 'Peru'
		order by 2,3

------total test por dia vs total test por pais--
select va.continent, va.location, mu.date,va.new_tests,mu.population,
 sum(convert(bigint,va.new_tests)) over (partition by va.location)
from Vacunaciones va
	join muertes mu
		on va.location=mu.location
		and va.date=mu.date
	where va.continent is not null
order by 2,3
----
with PopVsVac(continent,location,date,new_vaccinatons,population,VacunacionesAcumuladas)
as(
select va.continent, va.location, mu.date,va.new_vaccinations,mu.population,
 sum(convert(bigint,va.new_vaccinations)) over (partition by va.location order by va.location,va.date ROWS UNBOUNDED PRECEDING) 
 as VacunacionesAcumuladas
from Vacunaciones va
	join muertes mu
		on va.location=mu.location
		and va.date=mu.date
	where va.continent is not null and va.location like 'Peru'
--order by 2,3
)
select *,(VacunacionesAcumuladas/population)*100
from PopVsVac

----TABLA TEMPORAL ---
drop table if exists #PorcentajedeVacunacion
create table #PorcentajedeVacunacion(
continent nvarchar(255),
location nvarchar (255),
date datetime,
new_vaccinations numeric,
population numeric,
VacunacionesAcumuladas numeric,
)

insert into #PorcentajedeVacunacion

select va.continent, va.location, mu.date,va.new_vaccinations,mu.population,
 sum(convert(bigint,va.new_vaccinations)) over (partition by va.location order by va.location,va.date ROWS UNBOUNDED PRECEDING) 
 as VacunacionesAcumuladas
from Vacunaciones va
	join muertes mu
		on va.location=mu.location
		and va.date=mu.date
	where va.continent is not null --and va.location like 'Peru'
--order by 2,3

Select *, (VacunacionesAcumuladas/population)*100
from #PorcentajedeVacunacion

---------Ahora trabajamos con la tabla temporal
--CREAMOS VISTAS--
CREATE VIEW PorcentajedePersonasVacunadas as
select va.continent, va.location, mu.date,va.new_vaccinations,mu.population,
 sum(convert(bigint,va.new_vaccinations)) over (partition by va.location order by va.location,va.date ROWS UNBOUNDED PRECEDING) 
 as VacunacionesAcumuladas
from Vacunaciones va
	join muertes mu
		on va.location=mu.location
		and va.date=mu.date
	where va.continent is not null --and va.location like 'Peru'
--order by 2,3





--Total de test por Pais--
select va.location,
 sum(convert(bigint,va.new_tests)) 
from Vacunaciones va
	join muertes mu
		on va.location=mu.location
		and va.date=mu.date
	where va.continent is not null
group by va.location
order by 1


