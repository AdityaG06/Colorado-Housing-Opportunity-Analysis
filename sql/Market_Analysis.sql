CREATE OR REPLACE VIEW colorado_market_analysis AS
SELECT
    c.zip_code,
    c.acs_year,
    c.population,
    c.median_income,
    c.housing_units,
    c.vacant_units,
    c.vacancy_rate,
    c.median_home_value,
    z.date AS zillow_date,
    ROUND(z.zhvi, 2) AS zillow_home_value,
    ROUND(z.appreciation_1yr, 2) AS appreciation_1yr,
    ROUND(
        z.zhvi / NULLIF(c.median_income, 0),
        2
    ) AS price_income_ratio
FROM census_demographics c
INNER JOIN latest_zillow z
    ON c.zip_code = z.zip_code
WHERE c.acs_year = 2024;

SELECT *
FROM colorado_market_analysis
ORDER BY zip_code
LIMIT 10;

SELECT
    zip_code,
    population,
    median_income,
    zillow_home_value,
    appreciation_1yr,
    price_income_ratio,
    vacancy_rate
FROM colorado_market_analysis
WHERE population >= 1000
  AND median_income > 0
  AND appreciation_1yr > 0
ORDER BY price_income_ratio ASC
LIMIT 15;