

select c.location, c.date, total_cases
from 
[dbo].['Covid Vaccinations $'] V
INNER JOIN [dbo].['Covid Death$'] C
on C.location = V.location
and C.date = V.date
order by 3,4 


select location, date, total_cases, new_cases, total_deaths, population
from
[dbo].[Covid_Deceased]
order by 1,2 


--Looking at total cases vs total deaths
--Shows liklihood if dieing if you contract covid in your country 

select location, date, total_cases, total_deaths
,(total_deaths/total_cases ) * 100 as lol 
from [dbo].[Covid_Deceased]
where location like '%Ireland%' 
order by 1, 2

--Looking at total cases vs population 

select location, date, total_cases, population
,(total_cases/population) * 100 as percen_of_pop_w_coof  
from [dbo].[Covid_Deceased]
--where location like '%Ireland%' 
order by 1, 2


--what countries have highest infection rate compared to the population

SELECT location, population, MAX(total_cases) HIGHEST_INFECTION_COUNT, 
MAX((total_cases/population)) * 100 as percen_of_pop_w_coof
from [dbo].[Covid_Deceased]
GROUP BY location, population
ORDER BY MAX((total_cases/population)) * 100 desc 

--showing countries with the highest death count per population

SELECT location, population, MAX(CAST(total_deaths as int)) total_death_count,
MAX((total_deaths/population)) * 100 as percen_of_pop_w_coof
from [dbo].[Covid_Deceased]
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY MAX((total_deaths/population)) * 100 desc 

select * from [dbo].[Covid_Deceased]

--Break things down by continent 


SELECT location, MAX(CAST(total_deaths as int)) total_death_count
--MAX((total_deaths/continent)) * 100 as percen_of_pop_w_coof
from [dbo].[Covid_Deceased]
WHERE continent IS NULL 
GROUP BY location
ORDER BY MAX(CAST(total_deaths as int)) desc


-- Global Numbers 

select date, sum(new_cases), SUM(cast (new_deaths as int)),  
SUM(CAST(new_deaths AS INT))/SUM(new_cases) *100 as DEATH_PERCENTAGE
--, SUM(new_deaths),(total_deaths/total_cases) * 100 as death_percentage
from [dbo].[Covid_Deceased]
where continent is not null 
group by date 
order by 1, 2

--look at total pop vs vaccination
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT( INT, v.new_vaccinations)) over (partition by d.location ORDER BY D.LOCATION, D.DATE)
AS ROLLING_PEOPLE_VAXXED
from [dbo].[Covid_Vaccinated] v
JOIN [dbo].[Covid_Deceased] d 
ON v.date = d.date AND 
v.location = d.location
where d.continent is not null
--order by 2,3 


--USE cte 

WITH popsvac (continent, location, date, population, new_vaccinations, ROLLING_PEOPLE_VAXXED)
as (
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT( INT, v.new_vaccinations)) over (partition by d.location ORDER BY D.LOCATION, D.DATE)
AS ROLLING_PEOPLE_VAXXED
from [dbo].[Covid_Vaccinated] v
JOIN [dbo].[Covid_Deceased] d 
ON v.date = d.date AND 
v.location = d.location
where d.continent is not null)
select *, (ROLLING_PEOPLE_VAXXED/population) *100
from popsvac


--temp table
drop table if exists 
create table percent_pop_vaccinated
( continent nvarchar(255), 
location nvarchar(255),
date datetime, 
population numeric, 
new_vaccinations numeric, 
rolling_ppl_vaccinated numeric)

insert into percent_pop_vaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT( INT, v.new_vaccinations)) over (partition by d.location ORDER BY D.LOCATION, D.DATE)
AS ROLLING_PEOPLE_VAXXED
from [dbo].[Covid_Vaccinated] v
JOIN [dbo].[Covid_Deceased] d 
ON v.date = d.date AND 
v.location = d.location
--where d.continent is not null

select *, (ROLLING_PEOPLE_VAXXED/population) *100
from percent_pop_vaccinated

--create view to store data for later 

CREATE VIEW percent_pop_vaxxed as 

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT( INT, v.new_vaccinations)) over (partition by d.location ORDER BY D.LOCATION, D.DATE)
AS ROLLING_PEOPLE_VAXXED
from [dbo].[Covid_Vaccinated] v
JOIN [dbo].[Covid_Deceased] d 
ON v.date = d.date AND 
v.location = d.location
where d.continent is not null
--order by 2,3 