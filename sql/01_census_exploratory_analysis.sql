SELECT current_database(), version();

CREATE TABLE census_demographics (
    zip_code VARCHAR(5),
    acs_year INTEGER,
    population INTEGER,
    median_income NUMERIC,
    housing_units INTEGER,
    vacant_units INTEGER,
    median_home_value NUMERIC,
    vacancy_rate NUMERIC,
    PRIMARY KEY (zip_code, acs_year)
);

SELECT *
FROM census_demographics
LIMIT 10;

SELECT COUNT(*)
FROM census_demographics;

SELECT
    COUNT(*) AS total_zctas,
    COUNT(DISTINCT zip_code) AS unique_zctas,
    COUNT(median_income) AS income_available,
    COUNT(median_home_value) AS home_values_available,
    COUNT(vacancy_rate) AS vacancy_rates_available
FROM census_demographics
WHERE acs_year = 2024;

SELECT
    zip_code,
    population,
    median_income,
    median_home_value,
    ROUND(
        median_home_value / NULLIF(median_income, 0),
        2
    ) AS home_value_income_ratio
FROM census_demographics
WHERE acs_year = 2024
    AND median_income IS NOT NULL
    AND median_home_value IS NOT NULL
    AND housing_units >= 500
ORDER BY home_value_income_ratio DESC
LIMIT 15;