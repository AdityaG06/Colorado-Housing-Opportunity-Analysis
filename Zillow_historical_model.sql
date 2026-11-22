CREATE OR REPLACE VIEW colorado_opportunity_scores AS

WITH eligible AS (
    SELECT *
    FROM colorado_market_metrics
    WHERE population >= 1000
      AND median_income > 0
      AND price_income_ratio IS NOT NULL
      AND appreciation_1yr IS NOT NULL
      AND appreciation_5yr IS NOT NULL
      AND vacancy_rate IS NOT NULL
),

scores AS (
    SELECT
        *,

        (1 - PERCENT_RANK() OVER (
            ORDER BY price_income_ratio
        )) * 100 AS affordability_score,

        PERCENT_RANK() OVER (
            ORDER BY appreciation_1yr
        ) * 100 AS momentum_score,

        PERCENT_RANK() OVER (
            ORDER BY appreciation_5yr
        ) * 100 AS growth_score,

        (1 - PERCENT_RANK() OVER (
            ORDER BY vacancy_rate
        )) * 100 AS vacancy_score

    FROM eligible
)

SELECT
    zip_code,
    population,
    home_value,
    median_income,
    price_income_ratio,
    appreciation_1yr,
    appreciation_5yr,
    vacancy_rate,

    ROUND(
    ((
        affordability_score +
        momentum_score +
        growth_score +
        vacancy_score
    ) / 4)::numeric,
    2
) AS opportunity_score

FROM scores;

SELECT *
FROM colorado_opportunity_scores
ORDER BY opportunity_score DESC
LIMIT 20;


SELECT
    ROUND(CORR(opportunity_score, price_income_ratio)::numeric, 3)
        AS affordability_correlation,

    ROUND(CORR(opportunity_score, appreciation_1yr)::numeric, 3)
        AS momentum_correlation,

    ROUND(CORR(opportunity_score, appreciation_5yr)::numeric, 3)
        AS growth_correlation,

    ROUND(CORR(opportunity_score, vacancy_rate)::numeric, 3)
        AS vacancy_correlation
FROM colorado_opportunity_scores;



SELECT
    EXTRACT(YEAR FROM date) AS year,
    COUNT(DISTINCT zip_code) AS zip_count,
    ROUND(AVG(zhvi)::numeric, 2) AS avg_home_value
FROM zillow_home_values
WHERE EXTRACT(MONTH FROM date) = 12
  AND EXTRACT(YEAR FROM date) BETWEEN 2015 AND 2025
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY year;


CREATE OR REPLACE VIEW zillow_historical_backtest AS
WITH yearly_values AS (
    SELECT
        zip_code,
        EXTRACT(YEAR FROM date)::integer AS year,
        zhvi
    FROM zillow_home_values
    WHERE EXTRACT(MONTH FROM date) = 12
      AND EXTRACT(YEAR FROM date) BETWEEN 2015 AND 2025
)
SELECT
    current_year.zip_code,
    current_year.year,
    ROUND(current_year.zhvi::numeric, 2) AS home_value,

    ROUND(
        ((current_year.zhvi / previous_year.zhvi) - 1)::numeric * 100,
        2
    ) AS past_1yr_growth,

    ROUND(
        ((future_year.zhvi / current_year.zhvi) - 1)::numeric * 100,
        2
    ) AS future_1yr_growth

FROM yearly_values current_year

LEFT JOIN yearly_values previous_year
    ON current_year.zip_code = previous_year.zip_code
    AND previous_year.year = current_year.year - 1

LEFT JOIN yearly_values future_year
    ON current_year.zip_code = future_year.zip_code
    AND future_year.year = current_year.year + 1;



SELECT *
FROM zillow_historical_backtest
WHERE year BETWEEN 2016 AND 2024
ORDER BY zip_code, year
LIMIT 20;



SELECT
    ROUND(
        CORR(past_1yr_growth, future_1yr_growth)::numeric,
        3
    ) AS growth_predictability,

    COUNT(*) AS observations
FROM zillow_historical_backtest
WHERE year BETWEEN 2016 AND 2024
  AND past_1yr_growth IS NOT NULL
  AND future_1yr_growth IS NOT NULL;



SELECT
    year,
    COUNT(*) AS observations,

    ROUND(
        CORR(
            past_1yr_growth,
            future_1yr_growth
        )::numeric,
        3
    ) AS growth_correlation

FROM zillow_historical_backtest

WHERE year BETWEEN 2016 AND 2024
    AND past_1yr_growth IS NOT NULL
    AND future_1yr_growth IS NOT NULL

GROUP BY year
ORDER BY year;



WITH ranked AS (
    SELECT
        zip_code,
        year,
        past_1yr_growth,
        future_1yr_growth,

        NTILE(5) OVER (
            PARTITION BY year
            ORDER BY past_1yr_growth DESC
        ) AS growth_group

    FROM zillow_historical_backtest

    WHERE year BETWEEN 2016 AND 2024
      AND past_1yr_growth IS NOT NULL
      AND future_1yr_growth IS NOT NULL
)

SELECT
    year,

    ROUND(
        AVG(future_1yr_growth) FILTER (
            WHERE growth_group = 1
        ), 2
    ) AS top_20_growth,

    ROUND(
        AVG(future_1yr_growth), 2
    ) AS market_avg_growth,

    ROUND(
        AVG(future_1yr_growth) FILTER (
            WHERE growth_group = 1
        ) - AVG(future_1yr_growth),
        2
    ) AS outperformance

FROM ranked
GROUP BY year
ORDER BY year;


WITH ranked AS (
    SELECT
        zip_code,
        year,
        past_1yr_growth,
        future_1yr_growth,

        NTILE(5) OVER (
            PARTITION BY year
            ORDER BY past_1yr_growth DESC
        ) AS momentum_group

    FROM zillow_historical_backtest

    WHERE year BETWEEN 2016 AND 2024
      AND past_1yr_growth IS NOT NULL
      AND future_1yr_growth IS NOT NULL
)

SELECT
    momentum_group,
    COUNT(*) AS observations,
    ROUND(AVG(past_1yr_growth), 2)
        AS avg_past_growth,
    ROUND(AVG(future_1yr_growth), 2)
        AS avg_future_growth

FROM ranked
GROUP BY momentum_group
ORDER BY momentum_group;



SELECT
    CASE
        WHEN year BETWEEN 2016 AND 2021 THEN 'Training'
        WHEN year BETWEEN 2022 AND 2023 THEN 'Validation'
        WHEN year = 2024 THEN 'Testing'
    END AS dataset,
    COUNT(*) AS observations,
    COUNT(DISTINCT zip_code) AS unique_zips,
    ROUND(AVG(future_1yr_growth), 2) AS avg_future_growth
FROM zillow_historical_backtest
WHERE year BETWEEN 2016 AND 2024
  AND past_1yr_growth IS NOT NULL
  AND future_1yr_growth IS NOT NULL
GROUP BY 1
ORDER BY 1;



SELECT
    zip_code,
    year,
    home_value,
    past_1yr_growth,
    future_1yr_growth
FROM zillow_historical_backtest
WHERE year BETWEEN 2016 AND 2024
  AND past_1yr_growth IS NOT NULL
  AND future_1yr_growth IS NOT NULL
ORDER BY year, zip_code;



