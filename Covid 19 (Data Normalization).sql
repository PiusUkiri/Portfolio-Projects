--Showing the Likelihood of dying if you contracted Covid 19 In the United States of America
SELECT	Location, Date, Total_cases, Total_deaths, (Total_deaths/Total_cases)*100 AS DeathPercentage
FROM	PortfolioProjects..CovidDeaths
WHERE	iso_code = 'USA'
ORDER BY	1,2

--Shows Countries with the Highest Infection Rate as compared to their Population
SELECT	Location, Population, MAX(Total_cases)AS HighestInfectionCount, 
		MAX((Total_cases/Population))*100 AS InfectedPopulationPercentage
FROM	PortfolioProjects..CovidDeaths
WHERE	Continent IS NOT NULL
GROUP BY	Location, Population
ORDER BY	InfectedPopulationPercentage DESC

--Creating View to Store Data for later Visualization
CREATE VIEW HighestInfectionRateByCountry
AS
SELECT	Location, Population, MAX(Total_cases)AS HighestInfectionCount, 
		MAX((Total_cases/Population))*100 AS InfectedPopulationPercentage
FROM	PortfolioProjects..CovidDeaths
WHERE	Continent IS NOT NULL
GROUP BY	Location, Population

--Shows what percentage of population of Americans got Covid 19
SELECT	Location, Date, Total_cases, Population,(Total_cases/Population)*100 AS InfectedPopulationPercentage
FROM	PortfolioProjects..CovidDeaths
WHERE	iso_code = 'USA'
ORDER BY	1,2

--Shows Countries with the Highest Death Count 
SELECT	Location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM	PortfolioProjects..CovidDeaths
WHERE	Continent IS NOT NULL
GROUP BY	Location
ORDER BY	TotalDeathCount DESC

--Creating View to Store Data for later Visualization
CREATE VIEW HighestDeathCountByCountry
AS
SELECT	Location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM	PortfolioProjects..CovidDeaths
WHERE	Continent IS NOT NULL
GROUP BY	Location

--Shows the Total number of Cases, Deaths and a Death Percentage Per Day
SELECT	Date, SUM(New_cases) AS Total_Cases, SUM(CAST(New_deaths AS INT)) AS Total_Deaths, 
		SUM(CAST(New_deaths AS INt))/SUM(New_cases) *100 AS DeathPercentage
FROM	PortfolioProjects..CovidDeaths
WHERE	Continent IS NOT NULL
GROUP BY	Date
ORDER BY	1,2 

--Shows the Total number of Cases, Deaths and a Death Percentage 
SELECT	SUM(New_cases) AS Total_Cases, SUM(CAST(New_deaths AS INT)) AS Total_Deaths, 
		SUM(CAST(New_deaths AS INt))/SUM(New_cases) *100 AS DeathPercentage
FROM	PortfolioProjects..CovidDeaths
WHERE	Continent IS NOT NULL
ORDER BY	1,2 

--Creating View to Store Data for later Visualization
SELECT	SUM(New_cases) AS Total_Cases, SUM(CAST(New_deaths AS INT)) AS Total_Deaths, 
		SUM(CAST(New_deaths AS INt))/SUM(New_cases) *100 AS DeathPercentage
FROM	PortfolioProjects..CovidDeaths
WHERE	Continent IS NOT NULL
ORDER BY	1,2 


--Shows the number of people vaccinated in a particular country over time,
--and the corresponding percent of the vaccinated population  (Using CTE)
WITH	PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingVaccinatedPeople)
AS
(
SELECT	Dea.Continent, Dea.Location, Dea.Date, Dea.Population, VAC.New_vaccinations,
		SUM(CONVERT(BIGINT, Vac.New_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.Location,
		Dea.Date) AS RollingVaccinatedPeople
FROM	PortfolioProjects..CovidDeaths Dea
Join	PortfolioProjects..CovidVaccinations Vac
		ON Dea.Location = Vac.Location
		AND Dea.Date =Vac.Date
WHERE	Dea.Continent IS NOT NULL
)
SELECT	*, (RollingVaccinatedPeople/Population)*100/3 AS PercentofVaccinatedCitizens --Divid by 3 to factor for 
           FROM	PopvsVac                                                             --the mutiple vaccine doses



--Shows the number of people vaccinated in a particular country over time,
--and the corresponding percent of the vaccinated population  (Using Temp Tables)
DROP	TABLE IF EXISTS #PercentPopulationVaccinated
CREATE	TABLE #PercentPopulationVaccinated
(
Continent	NVARCHAR (255),
Location	NVARCHAR (255),
Date		DATETIME,
Population	NUMERIC,
New_Vaccinations	NUMERIC,
RollingVaccinatedPeople	NUMERIC
)
INSERT INTO	#PercentPopulationVaccinated
SELECT	Dea.Continent, Dea.Location, Dea.Date, Dea.Population, VAC.New_vaccinations,
		SUM(CONVERT(BIGINT, Vac.New_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.Location,
		Dea.Date) AS RollingVaccinatedPeople
FROM	PortfolioProjects..CovidDeaths Dea
Join	PortfolioProjects..CovidVaccinations Vac
		ON Dea.Location = Vac.Location
		AND Dea.Date =Vac.Date
WHERE	Dea.Continent IS NOT NULL

SELECT	*, (RollingVaccinatedPeople/Population)*100/3 AS PercentofVaccinatedCitizens 
FROM	#PercentPopulationVaccinated

--Creating View to Store Data for later Visualization
CREATE VIEW PercentPopulationVaccinated 
AS
SELECT	Dea.Continent, Dea.Location, Dea.Date, Dea.Population, VAC.New_vaccinations,
		SUM(CONVERT(BIGINT, Vac.New_vaccinations)) OVER (PARTITION BY Dea.Location ORDER BY Dea.Location,
		Dea.Date) AS RollingVaccinatedPeople
FROM	PortfolioProjects..CovidDeaths Dea
Join	PortfolioProjects..CovidVaccinations Vac
		ON Dea.Location = Vac.Location
		AND Dea.Date =Vac.Date
WHERE	Dea.Continent IS NOT NULL