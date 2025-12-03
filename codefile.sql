CREATE DATABASE ENERGYDB2;
USE ENERGYDB2;

-- 1. country table
CREATE TABLE country (
    CID VARCHAR(10) PRIMARY KEY,
    Country VARCHAR(100) UNIQUE
);
SELECT * FROM COUNTRY;

-- 2. emission_3 table
CREATE TABLE emission_3 (
    country VARCHAR(100),
	energy_type VARCHAR(50),
    year INT,
    emission INT,
    per_capita_emission DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM EMISSION_3;

-- 3. population table
CREATE TABLE population (
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES country(Country)
);

SELECT * FROM POPULATION;

-- 4. production table
CREATE TABLE production (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    production INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM PRODUCTION;

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES country(Country)
);

SELECT * FROM GDP_3;

-- 6. consumption table
CREATE TABLE consumption (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    consumption INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM CONSUMPTION;


-- GENERAL & COMPARATIVE ANALYSIS

-- 1. What is the total emission per country for the most recent years available ?

SELECT country, SUM(emission) AS total_emission
FROM emission_3
WHERE year = (SELECT MAX(year) FROM emission_3)
GROUP BY country
ORDER BY total_emission DESC;

-- 2. What are the top 5 countries by GDP in the most recent years ? 

SELECT country, Value AS GDP
FROM gdp_3
WHERE year = (SELECT MAX(year) FROM gdp_3)
ORDER BY GDP DESC
LIMIT 5;

-- 3. Compare energy production and consumption by country and year.

SELECT p.country, p.year, SUM(p.production) AS total_production, 
       SUM(c.consumption) AS total_consumption
FROM production p
JOIN consumption c ON p.country = c.country AND p.year = c.year
GROUP BY p.country, p.year;

-- 4. Which energy types contribute most to emissions across all countries ?

SELECT energy_type, SUM(emission) AS total_emission
FROM emission_3
GROUP BY energy_type
ORDER BY total_emission DESC;


-- TREND ANALYSYS OVERTIME

-- 5. How have global emissions changed year over year ? 

SELECT year, SUM(emission) AS global_emission
FROM emission_3
GROUP BY year
ORDER BY year;

-- 6. What is the trend in GDP for each country over the given years ?

SELECT country, year, Value as GDP
FROM gdp_3
ORDER BY Country, year;

-- 7. How has population growth affected total emissions in each country ?

SELECT p.countries AS country, p.year, p.Value AS population, 
       SUM(e.emission) AS total_emission
FROM population p
JOIN emission_3 e ON p.countries = e.country AND p.year = e.year
GROUP BY p.countries, p.year, p.Value
ORDER BY p.countries, p.year;


-- 8. Energy consumption trend for major economies

SELECT c.country, c.year, SUM(c.consumption) AS total_consumption
FROM consumption c
WHERE c.country IN ('United States','China','India','Germany','Japan')
GROUP BY c.country, c.year
ORDER BY c.country, c.year;

-- 9. Average yearly change in emissions per capita per country

SELECT country, 
       AVG(per_capita_emission) AS avg_per_capita_emission
FROM emission_3
GROUP BY country;


-- RATIO & PER CAPTIA ANALYSIS

-- 10. Emission-to-GDP ratio per country by year

SELECT g.Country, g.year, 
       SUM(e.emission) / g.Value AS emission_gdp_ratio
FROM gdp_3 g
JOIN emission_3 e 
     ON g.Country = e.country AND g.year = e.year
GROUP BY g.Country, g.year, g.Value
ORDER BY g.Country, g.year;


-- 11. Energy consumption per capita per country over last 10 years

SELECT c.country, c.year, 
       (SUM(c.consumption) / p.Value) AS consumption_per_capita
FROM consumption c
JOIN population p 
     ON c.country = p.countries AND c.year = p.year
WHERE c.year >= (SELECT MAX(year) FROM consumption) - 10
GROUP BY c.country, c.year, p.Value
ORDER BY c.country, c.year;

-- 12. Energy production per captia across countries

SELECT pr.country, pr.year, 
       (SUM(pr.production) / p.Value) AS production_per_capita
FROM production pr
JOIN population p 
     ON pr.country = p.countries AND pr.year = p.year
GROUP BY pr.country, pr.year, p.Value
ORDER BY pr.country, pr.year;

-- 13. Countries with highest energy consumption relative to GDP

SELECT c.country, c.year, 
       SUM(c.consumption) / g.Value AS consumption_to_gdp
FROM consumption c
JOIN gdp_3 g 
     ON c.country = g.Country AND c.year = g.year
GROUP BY c.country, c.year, g.Value
ORDER BY consumption_to_gdp DESC
LIMIT 10;


-- 14. Correlation dataset : GDP vs Production

SELECT g.Country, g.year, g.Value AS GDP, p.production
FROM gdp_3 g
JOIN production p 
     ON g.Country = p.country AND g.year = p.year
ORDER BY g.Country, g.year;

-- 15. Top 10 countries by population and compare emissions

SELECT p.countries AS country, p.year, p.Value AS population, 
       SUM(e.emission) AS total_emission
FROM population p
JOIN emission_3 e 
     ON p.countries = e.country AND p.year = e.year
WHERE p.year = (SELECT MAX(year) FROM population)
GROUP BY p.countries, p.year, p.Value
ORDER BY population DESC
LIMIT 10;

-- 16. Countries that reduced per captia emissions the most (last decade)

SELECT country, 
       (MAX(per_capita_emission) - MIN(per_capita_emission)) AS reduction
FROM emission_3
WHERE year >= (SELECT MAX(year) FROM emission_3) - 10
GROUP BY country
ORDER BY reduction ASC
LIMIT 10;

-- 17. Global share (%) of emissions by country

SELECT country, 
       SUM(emission) AS total_emission,
       (SUM(emission) * 100.0 / (SELECT SUM(emission) FROM emission_3)) AS global_share_percent
FROM emission_3
GROUP BY country
ORDER BY global_share_percent DESC;

-- 18. GLobal average GDP, emission, and population by year

SELECT g.year, 
       AVG(g.Value) AS avg_gdp, 
       AVG(e.emission) AS avg_emission,
       AVG(p.Value) AS avg_population
FROM gdp_3 g
JOIN emission_3 e 
     ON g.Country = e.country AND g.year = e.year
JOIN population p 
     ON g.Country = p.countries AND g.year = p.year
GROUP BY g.year
ORDER BY g.year;
