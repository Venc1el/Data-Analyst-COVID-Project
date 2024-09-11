SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL

SELECT *
FROM CovidVaccinations

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Mencari total kasus dan total kematian

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2

-- Mencari Total kasus dengan populasi
-- Menunjukkan berapa persen populasi yang terkena covid
SELECT location, date, total_cases, population, (total_cases / population)*100 as PercentageCases
FROM CovidDeaths
WHERE location like '%indonesia%' AND continent IS NOT NULL
ORDER BY 1,2

-- Mencari negara dengan kasus infeksi covid terbanyak dibandingkan dengan populasi
SELECT location, population, MAX(total_cases) as HighestInfectionCount, 
	MAX((total_cases / population))*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Menunjukkan negara dengan kematian terbanyak menurut populasinya
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Menunjukkan hasil menurut benua


-- Menunjukkan benua dengan kematian tertinggi
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE location like '%states%' 
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Mencari total populasi dibandingkaan vaksinasi

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
FROM PopvsVac




-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Membuat views untuk menyimpan data sehingga dapat digunakan nanti ketika visualisasi

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated



