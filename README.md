
<!-- README.md is generated from README.Rmd. Please edit that file -->

# biostats <a href="https://github.com/sebasquirarte/biostats/blob/main/man/figures/logo.png"><img src="man/figures/logo.png" align="right" height="138" alt="biostats_logo" /></a>

<!-- badges: start -->

[![R-CMD-check.yaml](https://github.com/sebasquirarte/biostats/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/sebasquirarte/biostats/actions/workflows/R-CMD-check.yaml)
[![Tests](https://github.com/sebasquirarte/biostats/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/sebasquirarte/biostats/actions/workflows/test-coverage.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/biostats)](https://cran.r-project.org/package=biostats)
[![Codecov test
coverage](https://codecov.io/gh/sebasquirarte/biostats/graph/badge.svg?token=ba2a281e-60be-4036-a40c-a3afaadee1ed)](https://app.codecov.io/gh/sebasquirarte/biostats)
<!-- badges: end -->

## Overview

***biostats*** is a toolbox for biostatistics and clinical data analysis
in R.

#### Key features

- Summary statistics
- Exploratory data analysis (EDA)
- Sample size and power calculation
- Statistical tests
- Data cleaning, transformation, and visualization

*Developed by the biostatistics team at [Laboratorios Sophia S.A. de
C.V.](https://sophialab.com/) for biostatisticians, clinical researchers
and data analysts.*

## Installation

``` r
install.packages("remotes") 
library(remotes)
remotes::install_github('sebasquirarte/biostats',
                        auth_token = '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',
                        upgrade = FALSE)
library(biostats)
```

## Usage

The biostats toolbox includes the following exported functions.

- [**Summary Statistics and Exploratory Data Analysis
  (EDA)**](#summary-and-exploratory-data-analysis-eda)
  - [clinical_data()](#clinical_data) ✔️
  - [summary_table()](#summary_table) ✔️
  - [normality()](#normality) ✔️
  - [missing_values()](#missing_values) ✔️
- [**Sample Size and Power
  Calculation**](#sample-size-and-power-calculation)
  - [sample_size()](#sample_size)
  - [stat_power()](#stat_power)
- [**Statistical Tests**](#statistical-tests)
  - [odds()](#odds)
  - [anova_test()](#anova_test)
  - [hypothesis_test()](#hypothesis_test)
- [**Data Cleaning and
  Transformation**](#data-cleaning-and-transformation)
  - [outliers()](#outliers)
  - [from_baseline()](#from_baseline)
  - [auc()](#auc)
  - [impute()](#impute)
  - [pivot_data()](#pivot_data)
- [**Data Visualization**](#data-visualization)
  - [plot_bar()](#plot_bar)
  - [plot_hist()](#plot_hist)
  - [plot_box()](#plot_box)
  - [plot_line()](#plot_line)
  - [plot_waterfall()](#plot_waterfall)
  - [plot_spider()](#plot_spider)
  - [plot_sankey()](#plot_sankey)
  - [plot_butterfly()](#plot_butterfly)
  - [plot_auc()](#plot_auc)
  - [plot_corrrelation()](#plot_correlation)

### Summary and Exploratory Data Analysis (EDA)

#### **clinical_data()**

##### Description

Creates a dataset of simulated clinical trial data with subject
demographics, multiple visits, treatment groups, numerical and
categorical variables, as well as optional missing data and dropout
rates.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `n` | Number of subjects (1-999) | 100 |
| `visits` | Number of visits including baseline | 3 |
| `arms` | Character vector of treatment arms | `c('Placebo', 'Treatment')` |
| `dropout_rate` | Proportion of subjects who dropout (0-1) | 0 |
| `na_rate` | Proportion of missing data at random (0-1) | 0 |

##### Examples

``` r
# Basic dataset
clinical_df <- clinical_data()

head(clinical_df)
#>   subject_id visit    sex treatment age weight biomarker response
#> 1        001     1 Female Treatment  40   66.7     66.34     None
#> 2        001     2 Female Treatment  40   68.4     46.87  Partial
#> 3        001     3 Female Treatment  40   68.3     34.48 Complete
#> 4        002     1   Male   Placebo  65   63.3     57.75     None
#> 5        002     2   Male   Placebo  65   65.4     58.04     None
#> 6        002     3   Male   Placebo  65   66.7     35.01  Partial

tail(clinical_df)
#>     subject_id visit  sex treatment age weight biomarker response
#> 295        099     1 Male Treatment  29   83.5     55.12  Partial
#> 296        099     2 Male Treatment  29   77.8     46.65     None
#> 297        099     3 Male Treatment  29   81.7     38.13     None
#> 298        100     1 Male Treatment  54   48.4     51.69  Partial
#> 299        100     2 Male Treatment  54   49.6     64.01     None
#> 300        100     3 Male Treatment  54   55.3     63.71 Complete
```

``` r
# Multiple treatment arms with dropout rate and missing data
clinical_df <- clinical_data(arms = c('Placebo', 'A', 'B'), na_rate = 0.05, dropout_rate = 0.10)

head(clinical_df, 10)
#>    subject_id visit    sex treatment age weight biomarker response
#> 1         001     1 Female         A  49   70.9     36.71     None
#> 2         001     2 Female         A  49   73.2     53.68 Complete
#> 3         001     3 Female         A  49   75.6     74.11 Complete
#> 4         002     1   Male         A  57   55.1     38.79     None
#> 5         002     2   Male         A  57   54.3     57.20     None
#> 6         002     3   Male         A  57   57.5     42.78     None
#> 7         003     1   Male         A  48   65.0     51.48     None
#> 8         003     2   Male         A  48   70.5     61.62  Partial
#> 9         003     3   Male         A  48   66.5     43.96  Partial
#> 10        004     1   Male         A  36   96.7     46.47     None

tail(clinical_df, 10)
#>     subject_id visit    sex treatment age weight biomarker response
#> 291        097     3   Male   Placebo  32   80.8     25.36  Partial
#> 292        098     1 Female         A  54   73.6     58.78     <NA>
#> 293        098     2 Female         A  54   72.9     35.88  Partial
#> 294        098     3 Female         A  54   72.4     48.28     None
#> 295        099     1 Female         A  34   75.1     47.36     None
#> 296        099     2 Female         A  34   72.7     69.89     None
#> 297        099     3 Female         A  34   75.3     23.68     <NA>
#> 298        100     1   Male         A  34   58.4     49.71  Partial
#> 299        100     2   Male         A  34   55.0     54.50     None
#> 300        100     3   Male         A  34   60.0     42.96     None
```

#### **summary_table()**

##### Description

Generates summary tables for biostatistics and clinical data analysis
with automatic statistical test selection and effect size calculations.
Handles both numeric and categorical variables, performing appropriate
descriptive statistics and inferential tests for single-group summaries
or two-group comparisons.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `data` | A data frame containing the variables to be summarized | `Required` |
| `group_var` | Name of the grouping variable for two-group comparisons | `NULL` |
| `all_stats` | Logical; if TRUE, provides detailed statistical summary | `FALSE` |
| `effect_size` | Logical; if TRUE, includes effect size estimates | `FALSE` |
| `exclude` | Character vector; variable names to exclude from the summary | `NULL` |

##### Examples

``` r
clinical_df <- clinical_data()

# General summary without considering treatment groups
clinical_summary <- summary_table(clinical_df,
                                  exclude = c('subject_id', 'visit'))
```

| variable | n | summary | normality |
|:---|---:|:---|:---|
| sex | 300 | Male: 138 (46.0%); Female: 162 (54.0%) | NA |
| treatment | 300 | Placebo: 153 (51.0%); Treatment: 147 (49.0%) | NA |
| age | 300 | Median (IQR): 47.00 (22.50) | \< 0.001 |
| weight | 300 | Median (IQR): 70.00 (21.67) | \< 0.001 |
| biomarker | 300 | Mean (SD): 47.75 (10.54) | 0.102 |
| response | 300 | Complete: 84 (28.0%); Partial: 69 (23.0%); None: 147 (49.0%) | NA |

``` r
# Grouped summary for each tratment group
clinical_summary <- summary_table(clinical_df,
                                  group_var = 'treatment',
                                  exclude = c('subject_id', 'visit'))
```

| variable | n | Placebo (Group A) | Treatment (Group B) | normality | test | p_value |
|:---|:---|:---|:---|:---|:---|:---|
| sex | A: 153, B: 147 | Male: 66 (43.1%); Female: 87 (56.9%) | Male: 72 (49.0%); Female: 75 (51.0%) | NA | Chi-squared | 0.310 |
| age | A: 153, B: 147 | Median (IQR): 47.00 (24.00) | Median (IQR): 50.00 (22.00) | A: 0.001, B: 0.002 | Mann-Whitney U | 0.392 |
| weight | A: 153, B: 147 | Median (IQR): 70.00 (18.00) | Median (IQR): 70.00 (24.85) | A: 0.002, B: 0.006 | Mann-Whitney U | 0.835 |
| biomarker | A: 153, B: 147 | Mean (SD): 49.03 (9.96) | Mean (SD): 46.42 (10.99) | A: 0.114, B: 0.101 | Welch t-test | 0.032 |
| response | A: 153, B: 147 | Complete: 27 (17.6%); Partial: 42 (27.5%); None: 84 (54.9%) | Complete: 57 (38.8%); Partial: 27 (18.4%); None: 63 (42.9%) | NA | Chi-squared | \< 0.001 |

``` r
# Grouped summary for each tratment group with all stats
clinical_summary <- summary_table(clinical_df,
                                  group_var = 'treatment',
                                  all_stats = TRUE,
                                  exclude = c('subject_id', 'visit'))
```

| variable | n | Placebo (Group A) | Treatment (Group B) | normality | test | p_value |
|:---|:---|:---|:---|:---|:---|:---|
| sex | A: 153, B: 147 | Male: 66 (43.1%); Female: 87 (56.9%) | Male: 72 (49.0%); Female: 75 (51.0%) | NA | Chi-squared | 0.310 |
| age | A: 153, B: 147 | Mean (SD): 45.27 (15.5); Median (IQR): 47.00 (34.0,58.0); Range: 18.00,79.00 | Mean (SD): 46.73 (15.8); Median (IQR): 50.00 (37.0,59.0); Range: 18.00,85.00 | A: 0.001, B: 0.002 | Mann-Whitney U | 0.392 |
| weight | A: 153, B: 147 | Mean (SD): 69.40 (15.3); Median (IQR): 70.00 (60.2,78.2); Range: 45.00,114.00 | Mean (SD): 69.72 (15.2); Median (IQR): 70.00 (57.5,82.3); Range: 45.00,105.50 | A: 0.002, B: 0.006 | Mann-Whitney U | 0.835 |
| biomarker | A: 153, B: 147 | Mean (SD): 49.03 (10.0); Median (IQR): 48.57 (42.9,54.9); Range: 22.42,77.47 | Mean (SD): 46.42 (11.0); Median (IQR): 45.54 (39.3,55.5); Range: 14.93,76.75 | A: 0.114, B: 0.101 | Welch t-test | 0.032 |
| response | A: 153, B: 147 | Complete: 27 (17.6%); Partial: 42 (27.5%); None: 84 (54.9%) | Complete: 57 (38.8%); Partial: 27 (18.4%); None: 63 (42.9%) | NA | Chi-squared | \< 0.001 |

``` r
# Grouped summary for each tratment group with effect size
clinical_summary <- summary_table(clinical_df,
                                  group_var = 'treatment',
                                  effect_size = TRUE,
                                  exclude = c('subject_id', 'visit'))
```

| variable | n | Placebo (Group A) | Treatment (Group B) | normality | test | p_value | effect_size | effect_param |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| sex | A: 153, B: 147 | Male: 66 (43.1%); Female: 87 (56.9%) | Male: 72 (49.0%); Female: 75 (51.0%) | NA | Chi-squared | 0.310 | 0.06 | Cramer’s V |
| age | A: 153, B: 147 | Median (IQR): 47.00 (24.00) | Median (IQR): 50.00 (22.00) | A: 0.001, B: 0.002 | Mann-Whitney U | 0.392 | 0.96 | r |
| weight | A: 153, B: 147 | Median (IQR): 70.00 (18.00) | Median (IQR): 70.00 (24.85) | A: 0.002, B: 0.006 | Mann-Whitney U | 0.835 | 0.92 | r |
| biomarker | A: 153, B: 147 | Mean (SD): 49.03 (9.96) | Mean (SD): 46.42 (10.99) | A: 0.114, B: 0.101 | Welch t-test | 0.032 | 0.25 | Cohen’s d |
| response | A: 153, B: 147 | Complete: 27 (17.6%); Partial: 42 (27.5%); None: 84 (54.9%) | Complete: 57 (38.8%); Partial: 27 (18.4%); None: 63 (42.9%) | NA | Chi-squared | \< 0.001 | 0.24 | Cramer’s V |

#### **normality()**

##### Description

Tests normality with statistical tests and visual assessment using QQ
plot and histogram.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `x` | A numeric vector or the name of a variable in a data frame | `Required` |
| `data` | Optional data frame containing the variable | `NULL` |
| `outliers` | Logical; whether to print all outlier row numbers | `FALSE` |
| `color` | Character; color for points and histogram bars | `"#7fcdbb"` |

##### Examples

``` r
clinical_df <- clinical_data()

# Normal distribution
normality("biomarker", data = clinical_df)
#> 
#> Normality Test for 'biomarker' 
#> 
#> n = 300 
#> mean (SD) = 48.42 (9.7) 
#> median (IQR) = 47.74 (12.2) 
#> 
#> Shapiro-Wilk: W = 0.993, p = 0.170 
#> Skewness: 0.25 
#> Kurtosis: -0.04 
#> 
#> Data is normally distributed. 
#> (Use outliers = TRUE to see outliers [2]).
```

<img src="man/figures/README-unnamed-chunk-13-1.png" width="100%" />

``` r

# Non-normal distribution
normality("weight", data = clinical_df)
#> 
#> Normality Test for 'weight' 
#> 
#> n = 300 
#> mean (SD) = 70.43 (15.6) 
#> median (IQR) = 70.00 (25.4) 
#> 
#> Shapiro-Wilk: W = 0.972, p = < 0.001 
#> Skewness: 0.29 
#> Kurtosis: -0.67 
#> 
#> Data is not normally distributed. 
#> (Use outliers = TRUE to see outliers [58]).
```

<img src="man/figures/README-unnamed-chunk-13-2.png" width="100%" />

``` r

# With outliers displayed
normality("weight", data = clinical_df, outliers = TRUE)
#> 
#> Normality Test for 'weight' 
#> 
#> n = 300 
#> mean (SD) = 70.43 (15.6) 
#> median (IQR) = 70.00 (25.4) 
#> 
#> Shapiro-Wilk: W = 0.972, p = < 0.001 
#> Skewness: 0.29 
#> Kurtosis: -0.67 
#> 
#> Data is not normally distributed. 
#> 
#> OUTLIERS (row indices): 28, 29, 30, 37, 38, 39, 121, 122, 101, 172, 32, 107, 213, 194, 193, 33, 85, 86, 61, 51, 276, 49, 274, 177, 175, 50, 197, 133, 174, 108, 113, 87, 102, 176, 112, 158, 259, 200, 31, 198, 114, 201, 170, 205, 260, 279, 199, 277, 278, 156, 115, 157, 159, 25, 206, 169, 117, 230
```

<img src="man/figures/README-unnamed-chunk-13-3.png" width="100%" />

#### **missing_values()**

##### Description

Analyzes missing values in a dataframe, providing counts and percentages
per column with visualizations.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `df` | A dataframe to analyze for missing values | `Required` |
| `color` | Character; color for missing values | `"#7fcdbb"` |
| `max_heatmap_rows` | Logical; if TRUE, shows all variables including those without missing values | `FALSE` |

##### Examples

``` r
clinical_df <- clinical_data(na_rate = 0.05)

# Missing value analysis of only variables with missing values
missing_values(clinical_df)
#> 
#> Missing Value Analysis
#> 
#> n: 300, variables: 8
#> Complete cases: 257 / 300 (85.7%)
#> Missing cells: 45 / 2400 (1.9%)
#> 
#> Variables with missing values: 3 of 8 (37.5%)
#> 
#>           n_missing pct_missing
#> response         27        9.00
#> weight           11        3.67
#> biomarker         7        2.33
```

<img src="man/figures/README-unnamed-chunk-14-1.png" width="100%" />

``` r
# Show all variables including those without missing values
missing_values(clinical_df, all = TRUE)
#> 
#> Missing Value Analysis
#> 
#> n: 300, variables: 8
#> Complete cases: 257 / 300 (85.7%)
#> Missing cells: 45 / 2400 (1.9%)
#> 
#> Variables with missing values: 3 of 8 (37.5%)
#> 
#>            n_missing pct_missing
#> response          27        9.00
#> weight            11        3.67
#> biomarker          7        2.33
#> subject_id         0        0.00
#> visit              0        0.00
#> sex                0        0.00
#> treatment          0        0.00
#> age                0        0.00
```

<img src="man/figures/README-unnamed-chunk-14-2.png" width="100%" />
