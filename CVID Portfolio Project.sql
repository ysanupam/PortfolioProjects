Select *
From PortfolioProject..CovidDeaths
--Where continent is not null
Order By 3, 4


--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1, 2

/* Previously numerical data of column 'total_death' and 'total_cases' were set to nvarchar type, using 'Alter Table' it was converted 
into float type */

Alter table CovidDeaths
Alter Column total_Deaths float

Alter table CovidDeaths
Alter Column total_Cases float

-- Total cases vs Total Deaths
/* Shows likelihhod of dying percentage if you have covid in your country */

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where Location = 'India'
Order By 1, 2

-- Looking at total_cases vs Population 
/* It shows what percentage of population got covid */
Select Location, date, total_cases, population, (total_cases/population)*100 As CovidPercentage
From PortfolioProject..CovidDeaths
Where Location = 'India'

-- Country with highest infection rate compared to population

Select Count(Distinct(Location)) as NumberOfCountries
From PortfolioProject..CovidDeaths


Select Location, population, Max(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where Location = 'India'
Group By Location, population
Order By PercentPopulationInfected Desc

-- countries with the highest death count per population 

Select Location, Max(total_deaths) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--Where Location = 'India'
Where continent is not null
Group By Location
Order By TotalDeathCount Desc


-- Continent with the highest death counts

Select continent, Max(total_deaths) as TotalDeathCount 
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount Desc


-- Global Numbers

/* When number is divided by zero it retuns divide by zero error, to avaoid this we can use 'NULLIF(denominator, 0)'.
it will return 'Null' where ever a number is divided by zero. syntx - SELECT numerator / NULLIF(denominator, 0) AS result FROM my_table; */
SELECT sum(new_deaths)/nullif(sum(new_cases), 0)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths


Select date,sum(new_deaths) as TotalDeaths, sum(new_cases) as Totalcases, sum(new_deaths)/nullif(sum(new_cases), 0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1, 2

-- Across the world TotalDeath, Totalcases and DeathPercentage

Select sum(new_deaths) as TotalDeaths, sum(new_cases) as Totalcases, sum(new_deaths)/nullif(sum(new_cases), 0)*100 
as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
order by 1, 2


-- Joining two tables and looking at population vs vaccination - Globally

Select *
From PortfolioProject..CovidDeaths dth
join PortfolioProject..CovidVaccinations vcc
	On dth.location = vcc.location
	and dth.date = vcc.date


Select dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations
From PortfolioProject..CovidDeaths dth
join PortfolioProject..CovidVaccinations vcc
	On dth.location = vcc.location
	and dth.date = vcc.date
Where dth.continent is not null and dth.location = 'India'
Order by 2,3

-- USE of CTE

With PopVsVacc (Continent, Location, Date, Population, New_vaccination, RollingPeopleVaccinated)
as
(
Select dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations,
sum(Convert(float, vcc.new_vaccinations)) over (Partition By dth.location order by dth.location, dth.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dth
join PortfolioProject..CovidVaccinations vcc
	On dth.location = vcc.location
	and dth.date = vcc.date
Where dth.continent is not null 
)
Select *, (RollingPeopleVaccinated/population)*100 as RollingVaccinatedPercentage
From PopVsVacc
where Location = 'India'


-- Use of Temp Tables

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
Select dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations,
sum(Convert(float, vcc.new_vaccinations)) over (Partition By dth.location order by dth.location, dth.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dth
join PortfolioProject..CovidVaccinations vcc
	On dth.location = vcc.location
	and dth.date = vcc.date
Where dth.continent is not null 


Select *, (RollingPeopleVaccinated/population)*100 as RollingVaccinatedPercentage
From #PercentPopulationVaccinated
Where Location = 'India'


-- Creating view for store data for visualization 

Create view PercentPopulationVaccinated as
Select dth.continent, dth.location, dth.date, dth.population, vcc.new_vaccinations,
sum(Convert(float, vcc.new_vaccinations)) over (Partition By dth.location order by dth.location, dth.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dth
join PortfolioProject..CovidVaccinations vcc
	On dth.location = vcc.location
	and dth.date = vcc.date
Where dth.continent is not null 


Select *
From PercentPopulationVaccinated 
