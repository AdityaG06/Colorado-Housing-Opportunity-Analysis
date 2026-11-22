# Colorado Housing Opportunity Analytics

### Analyzing housing appreciation, affordability, and market opportunities across 113 Colorado ZIP codes

**Tools:** Python (pandas, scikit-learn, statsmodels), PostgreSQL, SQL, Tableau, Zillow ZHVI, U.S. Census ACS

**[Explore the Interactive Tableau Dashboards](https://public.tableau.com:9443/views/ColoradoHousingOpportunityExplorerGonellaAnalytics/ModelEvaluationDashboard?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

## Project Overview

I developed this project to explore how historical housing appreciation and affordability can be used to evaluate real estate markets across Colorado.

The goal was to identify ZIP codes that demonstrate relatively strong historical price growth while remaining affordable compared to local household incomes.

Using Zillow home-value data and U.S. Census demographic estimates, I analyzed 113 Colorado ZIP codes, tested different historical ranking strategies, and developed an interactive Tableau dashboard that allows users to compare housing markets.

The project combines data cleaning, SQL analysis, statistical modeling, historical backtesting, and data visualization.

## Business Problem

Housing markets can vary significantly, even within the same state. A ZIP code with strong appreciation may also have high housing costs relative to local incomes, while a more affordable area may have experienced weaker price growth.

I wanted to answer three questions:

1. Which Colorado ZIP codes have experienced the strongest historical home-value appreciation?
2. How does relative housing affordability differ across these markets?
3. Can historical appreciation and affordability help identify ZIP codes that subsequently outperform other areas?

Rather than relying on home prices alone, I developed a scoring system that considers both historical market performance and affordability.

## Data Sources

**Zillow Home Value Index (ZHVI)**

Monthly estimated typical home values, used to calculate historical appreciation and evaluate housing-market trends.

- Coverage: 113 Colorado ZIP codes
- Historical data: January 2000 – September 2026
- Approximately 35,880 monthly observations

**U.S. Census Bureau — American Community Survey (ACS)**

ZIP Code Tabulation Area (ZCTA) estimates used to analyze household income and housing affordability.

- Historical median household income estimates for model development
- 2024 ACS 5-Year estimates for the September 2026 dashboard
- Median household income variable: `B19013_001E`

ZCTAs and USPS ZIP codes are not geographically identical, so the analysis uses them as approximate matching areas.

## Methodology

### 1. Data Collection and Cleaning

I used Python and SQL to prepare Zillow and Census data, standardize ZIP-code identifiers, inspect missing values, and calculate historical growth rates.

The cleaned Zillow dataset was used to build annual observations for historical analysis and monthly time-series visualizations.

### 2. Exploratory Data Analysis

I used SQL and Python to investigate differences in home values, historical appreciation, and relative affordability across Colorado ZIP codes.

I also examined how housing-market performance changed across different years and market conditions.

### 3. Historical Ranking and Backtesting

I tested multiple approaches for ranking ZIP codes, including:

- Previous 1-year appreciation
- Previous 3-year appreciation
- Previous 5-year appreciation
- A combined historical momentum score
- Price-to-income affordability
- A weighted momentum-and-affordability score

For each historical year, I compared the following year's average appreciation of the top-ranked approximately 20% of ZIP codes against the remaining ZIP codes.

This helped evaluate whether the ranking methods identified relatively stronger-performing markets.

### 4. Opportunity Scoring

The final exploratory screening score combines two components:

**70% — Historical 3-Year Appreciation Rank**

Measures a ZIP code's relative home-value growth over the preceding three years.

**30% — Affordability Rank**

Measures relative affordability using the ratio of typical home value to median household income. Lower ratios receive higher affordability rankings.

The score is calculated from percentile ranks and scaled to a 0–100 index.

This score is designed for comparing housing markets, not predicting guaranteed investment returns.

## Key Findings

### Historical Model Evaluation

| Strategy | Average Historical Outperformance |
|---|---:|
| 3-Year Momentum | +0.935 percentage points |
| 70% Momentum + 30% Affordability | +1.092 percentage points |

The combined approach achieved a higher average historical outperformance across 2020–2024.

However, it performed worse than the momentum-only strategy in three of the five years, indicating that affordability did not consistently improve historical rankings.

The relationships between affordability, momentum, and future appreciation also varied across market conditions.

### September 2026 Opportunity Rankings

The highest-ranked ZIP codes using the combined screening score included:

| Rank | ZIP Code | Opportunity Score |
|---|---|---:|
| 1 | 80132 | 87.88 |
| 2 | 80908 | 83.81 |
| 3 | 80919 | 83.45 |
| 4 | 81212 | 83.10 |
| 5 | 80921 | 82.65 |

These rankings reflect relative historical appreciation and affordability within the 113-ZIP-code study sample, rather than forecasts of future price appreciation.

## Interactive Tableau Dashboards

### Colorado Housing Opportunity Explorer

The main dashboard allows users to:

- View housing opportunity scores geographically
- Search for and select individual ZIP codes
- Compare ZIP-code rankings and affordability
- Explore the relationship between historical appreciation and price-to-income ratios
- Examine monthly home-value trends from 2000 through September 2026

Selecting a ZIP code updates the connected visualizations, while an All ZIP Codes option returns the dashboard to its full-market view.

### Model Evaluation Dashboard

The second dashboard compares historical ranking performance for the 3-year momentum strategy and the combined momentum-affordability strategy.

It highlights both positive and negative historical outcomes to make the evaluation more transparent.

**[View the Tableau Workbook](https://public.tableau.com:9443/views/ColoradoHousingOpportunityExplorerGonellaAnalytics/ModelEvaluationDashboard?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

## Project Structure

```text
notebooks/
    colorado_housing_analysis.ipynb

sql/
    01_census_exploratory_analysis.sql
    02_zillow_data_validation.sql
    Market_Analysis.sql
    Zillow_historical_model.sql

data/
    colorado_opportunity_rankings_2026.csv
    backtesting_tableau.csv

images/
    opportunity_dashboard.png
    model_evaluation_dashboard.png
```

## Limitations

This project is an exploratory housing-market screening and analytics tool, not a validated investment prediction system.

Several limitations are important:

- Historical Zillow home-value estimates may be revised over time.
- Historical ACS estimates have release delays, which complicates point-in-time backtesting.
- ZIP-code-level averages do not capture individual property conditions or transaction costs.
- The ranking strategies were compared using a limited number of historical years.
- The historical results were used to explore and compare scoring approaches, so they do not represent fully independent out-of-sample validation.
- A higher opportunity score does not guarantee positive future appreciation or indicate that a property is undervalued.

## Conclusion

This project gave me the opportunity to work through a complete analytics workflow, from collecting and cleaning data to developing ranking methods, evaluating historical results, and communicating findings through an interactive Tableau dashboard.

One of the main takeaways was that indicators that appear useful in one housing-market environment may perform very differently in another. Testing different approaches helped me understand the value of historical evaluation and the limitations of predictive modeling.

The final dashboard provides a way to explore Colorado housing markets while keeping the scoring methodology and its limitations transparent.

## Data Sources

- [Zillow Research Data](https://www.zillow.com/research/data/)
- [U.S. Census Bureau ACS](https://www.census.gov/programs-surveys/acs.html)

*This project was developed for educational and portfolio purposes and is not financial or investment advice.*
