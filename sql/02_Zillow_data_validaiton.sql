CREATE TABLE zillow_home_values (
    zip_code VARCHAR(5),
    date DATE,
    zhvi NUMERIC,
    zhvi_1yr_ago NUMERIC,
    appreciation_1yr NUMERIC,
    PRIMARY KEY (zip_code, date)
);

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT zip_code) AS unique_zips,
    MIN(date) AS earliest_date,
    MAX(date) AS latest_date,
    COUNT(appreciation_1yr) AS valid_appreciation_values
FROM zillow_home_values;

CREATE OR REPLACE VIEW latest_zillow AS
SELECT
    zip_code,
    date,
    zhvi,
    appreciation_1yr
FROM (
    SELECT
        zip_code,
        date,
        zhvi,
        appreciation_1yr,
        ROW_NUMBER() OVER (
            PARTITION BY zip_code
            ORDER BY date DESC
        ) AS rn
    FROM zillow_home_values
) z
WHERE rn = 1;

SELECT *
FROM latest_zillow
ORDER BY zip_code
LIMIT 10;

SELECT
    c.zip_code,
    c.population,
    c.median_income,
    c.median_home_value,
    c.vacancy_rate,
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
WHERE c.acs_year = 2024
ORDER BY price_income_ratio DESC;

SELECT
    COUNT(*) AS matched_zips,
    COUNT(DISTINCT c.zip_code) AS unique_zips,
    COUNT(z.appreciation_1yr) AS valid_appreciation,
    COUNT(c.median_income) AS valid_income
FROM census_demographics c
INNER JOIN latest_zillow z
    ON c.zip_code = z.zip_code
WHERE c.acs_year = 2024;