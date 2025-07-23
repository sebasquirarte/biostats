
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
remotes::install_github("sebasquirarte/biostats",
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
  - [normality()](#normality)
  - [missing_values()](#missing_values)
- [**Sample Size and Power
  Calculation**](#sample-size-and-power-calculation)
  - [sample_size()](#sample_size)
  - [sample_size_table()](#sample_size_table)
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
#> 1        001     1 Female Treatment  40   70.4     28.45     None
#> 2        001     2 Female Treatment  40   70.4     36.81     None
#> 3        001     3 Female Treatment  40   70.4     36.55     None
#> 4        002     1   Male   Placebo  65   64.6     43.49  Partial
#> 5        002     2   Male   Placebo  65   64.6     53.83 Complete
#> 6        002     3   Male   Placebo  65   64.6     60.32     None

tail(clinical_df)
#>     subject_id visit  sex treatment age weight biomarker response
#> 295        099     1 Male Treatment  29   82.2     53.22     None
#> 296        099     2 Male Treatment  29   82.2     24.96     None
#> 297        099     3 Male Treatment  29   82.2     44.27 Complete
#> 298        100     1 Male Treatment  54   50.2     37.78     None
#> 299        100     2 Male Treatment  54   50.2     43.94     None
#> 300        100     3 Male Treatment  54   50.2     72.37 Complete
```

``` r
# Multiple treatment arms with dropout rate and missing data
clinical_df <- clinical_data(arms = c('Placebo', 'A', 'B'), na_rate = 0.05, dropout_rate = 0.10)

head(clinical_df, 10)
#>    subject_id visit    sex treatment age weight biomarker response
#> 1         001     1 Female   Placebo  36   75.8     46.79  Partial
#> 2         001     2 Female   Placebo  36   75.8     54.09  Partial
#> 3         001     3 Female   Placebo  36   75.8     65.65     None
#> 4         002     1   Male         A  25   73.1     45.67     None
#> 5         002     2   Male         A  25   73.1     80.03 Complete
#> 6         002     3   Male         A  25   73.1     45.34     None
#> 7         003     1   Male         B  35   99.2     68.62 Complete
#> 8         003     2   Male         B  35   99.2        NA     <NA>
#> 9         003     3   Male         B  35   99.2        NA     <NA>
#> 10        004     1 Female         B  53   60.1     46.44 Complete

tail(clinical_df, 10)
#>     subject_id visit    sex treatment age weight biomarker response
#> 291        097     3   Male   Placebo  47   74.7     48.46     None
#> 292        098     1 Female         B  50   76.0     54.35     None
#> 293        098     2 Female         B  50   76.0     71.05     None
#> 294        098     3 Female         B  50   76.0     41.29  Partial
#> 295        099     1 Female   Placebo  53   83.1     51.99     None
#> 296        099     2 Female   Placebo  53   83.1     82.51 Complete
#> 297        099     3 Female   Placebo  53   83.1     53.03  Partial
#> 298        100     1   Male         A  27   62.5        NA Complete
#> 299        100     2   Male         A  27   62.5     53.75  Partial
#> 300        100     3   Male         A  27   62.5     53.18     <NA>
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
| sex | 300 | Male: 168 (56.0%); Female: 132 (44.0%) | NA |
| treatment | 300 | Placebo: 168 (56.0%); Treatment: 132 (44.0%) | NA |
| age | 300 | Median (IQR): 45.00 (24.00) | \< 0.001 |
| weight | 300 | Median (IQR): 70.00 (20.80) | \< 0.001 |
| biomarker | 300 | Mean (SD): 47.85 (9.52) | 0.397 |
| response | 300 | Complete: 85 (28.3%); Partial: 63 (21.0%); None: 152 (50.7%) | NA |

``` r
# Grouped summary for each tratment group
clinical_summary <- summary_table(clinical_df,
                                  group_var = 'treatment',
                                  exclude = c('subject_id', 'visit'))
```

| variable | n | Placebo (Group A) | Treatment (Group B) | normality | test | p_value |
|:---|:---|:---|:---|:---|:---|:---|
| sex | A: 168, B: 132 | Male: 90 (53.6%); Female: 78 (46.4%) | Male: 78 (59.1%); Female: 54 (40.9%) | NA | Chi-squared | 0.339 |
| age | A: 168, B: 132 | Median (IQR): 43.00 (21.25) | Median (IQR): 46.00 (27.50) | A: 0.002, B: \< 0.001 | Mann-Whitney U | 0.608 |
| weight | A: 168, B: 132 | Median (IQR): 68.85 (21.92) | Median (IQR): 70.40 (17.02) | A: 0.002, B: 0.006 | Mann-Whitney U | 0.786 |
| biomarker | A: 168, B: 132 | Median (IQR): 48.84 (11.61) | Median (IQR): 45.04 (15.00) | A: 0.798, B: 0.031 | Mann-Whitney U | 0.008 |
| response | A: 168, B: 132 | Complete: 38 (22.6%); Partial: 35 (20.8%); None: 95 (56.5%) | Complete: 47 (35.6%); Partial: 28 (21.2%); None: 57 (43.2%) | NA | Chi-squared | 0.030 |

``` r
# Grouped summary for each tratment group with all stats
clinical_summary <- summary_table(clinical_df,
                                  group_var = 'treatment',
                                  all_stats = TRUE,
                                  exclude = c('subject_id', 'visit'))
```

| variable | n | Placebo (Group A) | Treatment (Group B) | normality | test | p_value |
|:---|:---|:---|:---|:---|:---|:---|
| sex | A: 168, B: 132 | Male: 90 (53.6%); Female: 78 (46.4%) | Male: 78 (59.1%); Female: 54 (40.9%) | NA | Chi-squared | 0.339 |
| age | A: 168, B: 132 | Mean (SD): 44.93 (16.2); Median (IQR): 43.00 (35.0,56.2); Range: 18.00,85.00 | Mean (SD): 45.09 (16.2); Median (IQR): 46.00 (28.8,56.2); Range: 18.00,79.00 | A: 0.002, B: \< 0.001 | Mann-Whitney U | 0.608 |
| weight | A: 168, B: 132 | Mean (SD): 71.08 (15.7); Median (IQR): 68.85 (60.2,82.1); Range: 45.00,116.20 | Mean (SD): 70.89 (13.2); Median (IQR): 70.40 (63.9,80.9); Range: 45.00,108.60 | A: 0.002, B: 0.006 | Mann-Whitney U | 0.786 |
| biomarker | A: 168, B: 132 | Mean (SD): 48.99 (9.0); Median (IQR): 48.84 (43.1,54.7); Range: 24.74,72.57 | Mean (SD): 46.41 (10.0); Median (IQR): 45.04 (38.5,53.5); Range: 24.96,78.20 | A: 0.798, B: 0.031 | Mann-Whitney U | 0.008 |
| response | A: 168, B: 132 | Complete: 38 (22.6%); Partial: 35 (20.8%); None: 95 (56.5%) | Complete: 47 (35.6%); Partial: 28 (21.2%); None: 57 (43.2%) | NA | Chi-squared | 0.030 |

``` r
# Grouped summary for each tratment group with effect size
clinical_summary <- summary_table(clinical_df,
                                  group_var = 'treatment',
                                  effect_size = TRUE,
                                  exclude = c('subject_id', 'visit'))
```

| variable | n | Placebo (Group A) | Treatment (Group B) | normality | test | p_value | effect_size | effect_param |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| sex | A: 168, B: 132 | Male: 90 (53.6%); Female: 78 (46.4%) | Male: 78 (59.1%); Female: 54 (40.9%) | NA | Chi-squared | 0.339 | 0.06 | Cramer’s V |
| age | A: 168, B: 132 | Median (IQR): 43.00 (21.25) | Median (IQR): 46.00 (27.50) | A: 0.002, B: \< 0.001 | Mann-Whitney U | 0.608 | 1.13 | r |
| weight | A: 168, B: 132 | Median (IQR): 68.85 (21.92) | Median (IQR): 70.40 (17.02) | A: 0.002, B: 0.006 | Mann-Whitney U | 0.786 | 1.11 | r |
| biomarker | A: 168, B: 132 | Median (IQR): 48.84 (11.61) | Median (IQR): 45.04 (15.00) | A: 0.798, B: 0.031 | Mann-Whitney U | 0.008 | 0.95 | r |
| response | A: 168, B: 132 | Complete: 38 (22.6%); Partial: 35 (20.8%); None: 95 (56.5%) | Complete: 47 (35.6%); Partial: 28 (21.2%); None: 57 (43.2%) | NA | Chi-squared | 0.030 | 0.15 | Cramer’s V |
