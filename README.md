
<!-- README.md is generated from README.Rmd. Please edit that file -->

# biostats <a href="https://github.com/sebasquirarte/biostats/blob/main/man/figures/logo.png"><img src="man/figures/logo.png" align="right" height="138" alt="biostats_logo" /></a>

<!-- badges: start -->

[![R-CMD-check.yaml](https://github.com/sebasquirarte/biostats_CRAN/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/sebasquirarte/biostats_CRAN/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/biostats)](https://cran.r-project.org/package=biostats)
[![Codecov test
coverage](https://codecov.io/gh/sebasquirarte/biostats_CRAN/graph/badge.svg)](https://app.codecov.io/gh/sebasquirarte/biostats_CRAN)
<!-- badges: end -->

## Overview

***biostats*** is a versatile R toolbox that aids in biostatistics and
clinical data analysis workflows.

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
                        auth_token = "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",
                        upgrade = FALSE)
library(biostats)
```

## Usage

The biostats toolbox includes the following 25 exported functions.

- [**Summary Statistics and Exploratory Data Analysis
  (EDA)**](#summary-and-exploratory-data-analysis-eda)
  - [clinical_data()](#clinical_data) ✔
  - [summary_table()](#summary_table) ✔
  - [normality()](#normality) ✔
  - [missing_values()](#missing_values) ✔
- [**Sample Size and Power
  Calculation**](#sample-size-and-power-calculation)
  - [sample_size()](#sample_size)
  - [sample_size_table()](#sample_size_table)
  - [stat_power()](#stat_power)
- [**Statistical Tests**](#statistical-tests)
  - [odds()](#odds) ✔
  - [anova_test()](#anova_test) ✔
  - [hypothesis_test()](#hypothesis_test)
- [**Data Cleaning and
  Transformation**](#data-cleaning-and-transformation)
  - [outliers()](#outliers) ✔
  - [from_baseline()](#from_baseline)
  - [auc()](#auc)
  - [impute()](#impute)
  - [pivot_data()](#pivot_data) ✔
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
| `arms` | Vector of treatment arms | `c('Placebo', 'Treatment')` |
| `dropout_rate` | Proportion of subjects who dropout (0-1) | 0 |
| `na_rate` | Proportion of values missing at random (0-1) | 0 |
| `seed` | Random seed for reproducibility | `NULL` |

##### Examples

``` r
# Basic dataset
clinical_df <- clinical_data()

head(clinical_df)
#>   subject_id visit    sex treatment age weight biomarker response
#> 1        001     1 Female Treatment  40     70     21.45     None
#> 2        001     2 Female Treatment  40     70     29.81  Partial
#> 3        001     3 Female Treatment  40     70     29.55  Partial
#> 4        002     1   Male   Placebo  65     65     43.49  Partial
#> 5        002     2   Male   Placebo  65     65     53.83  Partial
#> 6        002     3   Male   Placebo  65     65     60.32  Partial

tail(clinical_df)
#>     subject_id visit  sex treatment age weight biomarker response
#> 295        099     1 Male Treatment  29     82     46.22 Complete
#> 296        099     2 Male Treatment  29     82     17.96  Partial
#> 297        099     3 Male Treatment  29     82     37.27 Complete
#> 298        100     1 Male Treatment  54     50     30.78  Partial
#> 299        100     2 Male Treatment  54     50     36.94 Complete
#> 300        100     3 Male Treatment  54     50     65.37 Complete
```

``` r
# Multiple treatment arms
clinical_df <- clinical_data(arms = c('A', 'B', 'C'))

head(clinical_df)
#>   subject_id visit    sex treatment age weight biomarker response
#> 1        001     1   Male         C  30     70     51.31  Partial
#> 2        001     2   Male         C  30     70     30.51 Complete
#> 3        001     3   Male         C  30     70     53.92 Complete
#> 4        002     1 Female         C  63     61     37.05  Partial
#> 5        002     2 Female         C  63     61     45.06  Partial
#> 6        002     3 Female         C  63     61     69.06 Complete

tail(clinical_df)
#>     subject_id visit    sex treatment age weight biomarker response
#> 295        099     1   Male         C  65     84     27.48  Partial
#> 296        099     2   Male         C  65     84     41.49 Complete
#> 297        099     3   Male         C  65     84     38.09  Partial
#> 298        100     1 Female         A  68     57     63.75  Partial
#> 299        100     2 Female         A  68     57     52.70  Partial
#> 300        100     3 Female         A  68     57     52.19     None
```

``` r
# 20% of subjects drop out and 5% of values missing at random
clinical_df <- clinical_data(dropout_rate = 0.2, na_rate = 0.05)

head(clinical_df)
#>   subject_id visit    sex treatment age weight biomarker response
#> 1        001     1 Female Treatment  48     52     28.56     None
#> 2        001     2 Female Treatment  48     52     45.04 Complete
#> 3        001     3 Female Treatment  48     52        NA Complete
#> 4        002     1 Female Treatment  28     78     38.81 Complete
#> 5        002     2 Female Treatment  28     78     44.68  Partial
#> 6        002     3 Female Treatment  28     78     51.86  Partial

tail(clinical_df)
#>     subject_id visit    sex treatment age weight biomarker response
#> 295        099     1   Male Treatment  45     52     54.91  Partial
#> 296        099     2   Male Treatment  45     52     41.08  Partial
#> 297        099     3   Male Treatment  45     52     53.71     None
#> 298        100     1 Female   Placebo  59     83     50.93     None
#> 299        100     2 Female   Placebo  59     83        NA     <NA>
#> 300        100     3 Female   Placebo  59     83        NA     <NA>
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
| sex | 300 | Female: 144 (48.0%); Male: 156 (52.0%) | NA |
| treatment | 300 | Placebo: 123 (41.0%); Treatment: 177 (59.0%) | NA |
| age | 300 | Median (IQR): 43.00 (23.25) | \< 0.001 |
| weight | 300 | Median (IQR): 70.00 (19.00) | \< 0.001 |
| biomarker | 300 | Mean (SD): 44.50 (10.72) | 0.421 |
| response | 300 | Complete: 106 (35.3%); None: 71 (23.7%); Partial: 123 (41.0%) | NA |

``` r
# Grouped summary for each tratment group
clinical_summary <- summary_table(clinical_df,
                                  group_var = 'treatment',
                                  exclude = c('subject_id', 'visit'))
```

| variable | n | Placebo (Group A) | Treatment (Group B) | normality | test | p_value |
|:---|:---|:---|:---|:---|:---|:---|
| sex | A: 123, B: 177 | Female: 57 (46.3%); Male: 66 (53.7%) | Female: 87 (49.2%); Male: 90 (50.8%) | NA | Chi-squared | 0.632 |
| age | A: 123, B: 177 | Median (IQR): 45.00 (23.00) | Median (IQR): 42.00 (21.00) | A: \< 0.001, B: 0.003 | Mann-Whitney U | 0.165 |
| weight | A: 123, B: 177 | Median (IQR): 66.00 (19.00) | Median (IQR): 73.00 (19.00) | A: 0.003, B: \< 0.001 | Mann-Whitney U | 0.021 |
| biomarker | A: 123, B: 177 | Mean (SD): 51.06 (9.31) | Mean (SD): 39.95 (9.18) | A: 0.757, B: 0.518 | Welch t-test | \< 0.001 |
| response | A: 123, B: 177 | Complete: 33 (26.8%); None: 39 (31.7%); Partial: 51 (41.5%) | Complete: 73 (41.2%); None: 32 (18.1%); Partial: 72 (40.7%) | NA | Chi-squared | 0.007 |

``` r
# Grouped summary for each tratment group with all stats
clinical_summary <- summary_table(clinical_df,
                                  group_var = 'treatment',
                                  all_stats = TRUE,
                                  exclude = c('subject_id', 'visit'))
```

| variable | n | Placebo (Group A) | Treatment (Group B) | normality | test | p_value |
|:---|:---|:---|:---|:---|:---|:---|
| sex | A: 123, B: 177 | Female: 57 (46.3%); Male: 66 (53.7%) | Female: 87 (49.2%); Male: 90 (50.8%) | NA | Chi-squared | 0.632 |
| age | A: 123, B: 177 | Mean (SD): 44.22 (13.6); Median (IQR): 45.00 (33.0,56.0); Range: 18.00,66.00 | Mean (SD): 42.46 (14.0); Median (IQR): 42.00 (30.0,51.0); Range: 18.00,75.00 | A: \< 0.001, B: 0.003 | Mann-Whitney U | 0.165 |
| weight | A: 123, B: 177 | Mean (SD): 68.24 (14.0); Median (IQR): 66.00 (59.0,78.0); Range: 45.00,101.00 | Mean (SD): 71.68 (14.5); Median (IQR): 73.00 (60.0,79.0); Range: 45.00,100.00 | A: 0.003, B: \< 0.001 | Mann-Whitney U | 0.021 |
| biomarker | A: 123, B: 177 | Mean (SD): 51.06 (9.3); Median (IQR): 50.53 (44.6,58.1); Range: 27.49,74.06 | Mean (SD): 39.95 (9.2); Median (IQR): 39.37 (34.2,45.0); Range: 14.60,64.80 | A: 0.757, B: 0.518 | Welch t-test | \< 0.001 |
| response | A: 123, B: 177 | Complete: 33 (26.8%); None: 39 (31.7%); Partial: 51 (41.5%) | Complete: 73 (41.2%); None: 32 (18.1%); Partial: 72 (40.7%) | NA | Chi-squared | 0.007 |

``` r
# Grouped summary for each tratment group with effect size
clinical_summary <- summary_table(clinical_df,
                                  group_var = 'treatment',
                                  effect_size = TRUE,
                                  exclude = c('subject_id', 'visit'))
```

| variable | n | Placebo (Group A) | Treatment (Group B) | normality | test | p_value | effect_size | effect_param |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| sex | A: 123, B: 177 | Female: 57 (46.3%); Male: 66 (53.7%) | Female: 87 (49.2%); Male: 90 (50.8%) | NA | Chi-squared | 0.632 | 0.03 | Cramér’s V |
| age | A: 123, B: 177 | Median (IQR): 45.00 (23.00) | Median (IQR): 42.00 (21.00) | A: \< 0.001, B: 0.003 | Mann-Whitney U | 0.165 | 0.52 | r |
| weight | A: 123, B: 177 | Median (IQR): 66.00 (19.00) | Median (IQR): 73.00 (19.00) | A: 0.003, B: \< 0.001 | Mann-Whitney U | 0.021 | 0.73 | r |
| biomarker | A: 123, B: 177 | Mean (SD): 51.06 (9.31) | Mean (SD): 39.95 (9.18) | A: 0.757, B: 0.518 | Welch t-test | \< 0.001 | 1.20 | Cohen’s d |
| response | A: 123, B: 177 | Complete: 33 (26.8%); None: 39 (31.7%); Partial: 51 (41.5%) | Complete: 73 (41.2%); None: 32 (18.1%); Partial: 72 (40.7%) | NA | Chi-squared | 0.007 | 0.18 | Cramér’s V |

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
# Normal data
normality('biomarker',
          data = clinical_df)
#> 
#> Normality Test for 'biomarker' 
#> 
#> n = 300 
#> mean ± SD = 44.50 ± 10.7 
#> median (IQR) = 43.94 (14.7) 
#> 
#> Shapiro-Wilk: W = 0.995, p = 0.421 
#> Skewness: 0.16 
#> Kurtosis: -0.24 
#> 
#> Data is  normally distributed.
```

<img src="man/figures/README-unnamed-chunk-14-1.png" width="100%" />

``` r
# Skewed data (show rows of outliers)
normality('weight',
          data = clinical_df,
          outliers = TRUE)
#> 
#> Normality Test for 'weight' 
#> 
#> n = 300 
#> mean ± SD = 70.27 ± 14.4 
#> median (IQR) = 70.00 (19.0) 
#> 
#> Shapiro-Wilk: W = 0.976, p = < 0.001 
#> Skewness: 0.16 
#> Kurtosis: -0.64 
#> 
#> Data is  not normally distributed. 
#> 
#> OUTLIERS (row indices): 22, 23, 24, 31, 32, 255, 279, 28, 61, 62, 63, 205, 55, 56, 57, 244, 1, 2
```

<img src="man/figures/README-unnamed-chunk-15-1.png" width="100%" />

#### **missing_values()**

##### Description

Analyzes missing values in a dataframe, providing counts and percentages
per column with visualizations.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `df` | A dataframe to analyze for missing values | `Required` |
| `color` | Character; color for missing values | `"#7fcdbb"` |
| `max_heatmap_rows` | Integer; maximum number of rows to show in heatmap | `200` |

##### Examples

``` r
# Genrate simulated clinical data with subject dropout and missing values
clinical_df <- clinical_data(dropout_rate = 0.1, na_rate = 0.1)

missing_values(clinical_df)
#> 
#> Missing Value Analysis for 'clinical_df'
#> 
#> n: 300, variables: 8
#> Complete cases: 232 / 300 (77.3%)
#> Missing cells: 86 / 2400 (3.6%)
#> 
#> Variables with missing values: 2 of 8 (25.0%)
#> 
#>            variable n_missing pct_missing
#> biomarker biomarker        43       14.33
#> response   response        43       14.33
```

<img src="man/figures/README-unnamed-chunk-16-1.png" width="100%" />

### Sample Size and Power Calculation

#### **sample_size()**

##### Description

…

##### Parameters

…

##### Examples

…

#### **sample_size_table()**

##### Description

…

##### Parameters

…

##### Examples

…

#### **stat_power()**

##### Description

…

##### Parameters

…

##### Examples

…

### Statistical Tests

#### **odds()**

##### Description

Calculates odds ratio and risk ratio from a 2x2 contingency table.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `a` | Number of exposed individuals with the outcome | `Required` |
| `b` | Number of exposed individuals without the outcome | `Required` |
| `c` | Number of unexposed individuals with the outcome | `Required` |
| `d` | Number of unexposed individuals without the outcome | `Required` |
| `conf.level` | Confidence level for intervals | `0.95` |

##### Examples

``` r
odds(15, 85, 5, 95)
#> 
#> Odds/Risk Ratio Analysis
#> 
#> Contingency Table:
#>           Event No Event Sum
#> Exposed      15       85 100
#> Unexposed     5       95 100
#> Sum          20      180 200
#> 
#> Odds Ratio: 3.353 (95% CI: 1.169 - 9.616)
#> Risk Ratio: 3.000 (95% CI: 1.133 - 7.941)
#> 
#> Risk in exposed: 15.0%
#> Risk in unexposed: 5.0%
#> Absolute risk difference: 10.0%
#> Number needed to harm (NNH): 10.0
```

#### **anova_test()**

##### Description

Performs one-way ANOVA and conditional post-hoc comparisons.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `formula` | Formula specifying response ~ group (e.g., value ~ treatment) | `Required` |
| `data` | Data frame containing the variables | `Required` |
| `alpha` | Significance level for ANOVA test | `0.05` |
| `method` | Post-hoc method: “tukey”, “bonferroni”, or “holm” | `"tukey"` |
| `na.action` | How to handle missing values | `na.omit` |

##### Examples

``` r
# Simulated clinical data with three treatment arms
clinical_df <- clinical_data(n = 300, arms = c('A', 'B', 'C', 'D'))

# Basic ANOVA
anova_test(biomarker ~ treatment, data = clinical_df)
#> 
#> One-Way ANOVA Results
#> 
#> Formula: biomarker ~ treatment
#> F(3, 896) = 48.163, p = < 0.001
#> Significance level: α = 0.050
#> Result: Significant
#> 
#> Post-hoc Multiple Comparisons
#> 
#> Tukey HSD (α = 0.050):
#> Comparison               Diff    Lower    Upper    p-adj
#> ------------------------------------------------------------ 
#> B - A                  -3.370   -5.814   -0.925    0.002*
#> C - A                  -6.803   -9.147   -4.459  < 0.001*
#> D - A                 -10.642  -13.033   -8.251  < 0.001*
#> C - B                  -3.433   -5.864   -1.003    0.002*
#> D - B                  -7.273   -9.748   -4.798  < 0.001*
#> D - C                  -3.839   -6.216   -1.463  < 0.001*
#> 
#> * p < 0.050
```

``` r
# With Bonferroni correction
anova_test(biomarker ~ treatment, data = clinical_df, method = "bonferroni")
#> 
#> One-Way ANOVA Results
#> 
#> Formula: biomarker ~ treatment
#> F(3, 896) = 48.163, p = < 0.001
#> Significance level: α = 0.050
#> Result: Significant
#> 
#> Post-hoc Multiple Comparisons
#> 
#> Pairwise t-tests (Bonferroni correction):
#>                        A           B           C
#> B                 0.002*           -           -
#> C               < 0.001*      0.002*           -
#> D               < 0.001*    < 0.001*    < 0.001*
#> 
#> * p < 0.050
```

#### **hypothesis_test()**

##### Description

…

##### Parameters

…

##### Examples

…

### Data Cleaning and Transformation

#### **outliers()**

##### Description

Identifies outliers using Tukey’s method (IQR) and provides visual
assessment.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `x` | A numeric vector or the name of a variable in a data frame | `Required` |
| `data` | Optional data frame containing the variable | `NULL` |
| `threshold` | Numeric; multiplier of IQR for outlier detection | `1.5` |
| `color` | Character; color for visualization elements | `"#7fcdbb"` |

##### Examples

``` r
# Simulated clinical data
clinical_df <- clinical_data()

outliers(clinical_df$biomarker)
#> 
#> Outlier Detection for 'clinical_df$biomarker'
#> 
#> n = 300 observations (300 after removing NAs)
#> Tukey's Method (IQR × 1.5):
#>   Lower bound: 18.35
#>   Upper bound: 70.46
#>   Outliers found: 7
#> Outlier row indices:  34, 56, 82, 115, 145, 232, 248
```

<img src="man/figures/README-unnamed-chunk-20-1.png" width="100%" />

#### **from_baseline()**

##### Description

…

##### Parameters

…

##### Examples

…

#### **auc()**

##### Description

…

##### Parameters

…

##### Examples

…

#### **impute()**

##### Description

…

##### Parameters

…

##### Examples

…

#### **pivot_data()**

##### Description

Converts clinical trial data between long format (multiple rows per
subject) and wide format (multiple columns per timepoint).

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `data` | Data frame containing clinical data | `Required` |
| `direction` | Character; “wide” for long-to-wide or “long” for wide-to-long | `Required` |
| `id_var` | Character; variable that identifies each subject | `Required` |
| `time_var` | Character; name of time/visit variable | `Required` |
| `value_vars` | Character vector; variables to pivot | `all except id_var and time_var` |

##### Examples

``` r
clinical_df <- clinical_data()
str(clinical_df)
#> 'data.frame':    300 obs. of  8 variables:
#>  $ subject_id: chr  "001" "001" "001" "002" ...
#>  $ visit     : int  1 2 3 1 2 3 1 2 3 1 ...
#>  $ sex       : chr  "Male" "Male" "Male" "Male" ...
#>  $ treatment : chr  "Treatment" "Treatment" "Treatment" "Treatment" ...
#>  $ age       : num  46 46 46 35 35 35 25 25 25 34 ...
#>  $ weight    : num  71 71 71 77 77 77 63 63 63 70 ...
#>  $ biomarker : num  50.6 30.8 47.8 45.8 36.1 ...
#>  $ response  : chr  "None" "Complete" "Complete" "Partial" ...
```

``` r
# Long to wide format
wide_data <- pivot_data(clinical_df, "wide", "subject_id", "visit")
#> Pivoted to wide format: 100 × 19
str(wide_data)
#> 'data.frame':    100 obs. of  19 variables:
#>  $ subject_id : chr  "001" "002" "003" "004" ...
#>  $ sex_1      : chr  "Male" "Male" "Female" "Female" ...
#>  $ sex_2      : chr  "Male" "Male" "Female" "Female" ...
#>  $ sex_3      : chr  "Male" "Male" "Female" "Female" ...
#>  $ treatment_1: chr  "Treatment" "Treatment" "Placebo" "Placebo" ...
#>  $ treatment_2: chr  "Treatment" "Treatment" "Placebo" "Placebo" ...
#>  $ treatment_3: chr  "Treatment" "Treatment" "Placebo" "Placebo" ...
#>  $ age_1      : num  46 35 25 34 36 51 68 47 63 56 ...
#>  $ age_2      : num  46 35 25 34 36 51 68 47 63 56 ...
#>  $ age_3      : num  46 35 25 34 36 51 68 47 63 56 ...
#>  $ weight_1   : num  71 77 63 70 71 72 84 49 58 70 ...
#>  $ weight_2   : num  71 77 63 70 71 72 84 49 58 70 ...
#>  $ weight_3   : num  71 77 63 70 71 72 84 49 58 70 ...
#>  $ biomarker_1: num  50.6 45.8 50.6 34.6 38.4 ...
#>  $ biomarker_2: num  30.8 36.1 25.4 42.9 30.7 ...
#>  $ biomarker_3: num  47.8 49.1 50.5 41 18.6 ...
#>  $ response_1 : chr  "None" "Partial" "Complete" "Complete" ...
#>  $ response_2 : chr  "Complete" "None" "None" "None" ...
#>  $ response_3 : chr  "Complete" "Complete" "None" "Partial" ...
```

``` r
# Wide to long format
long_data <- pivot_data(wide_data, "long", "subject_id", "visit")
#> Pivoted to long format: 300 × 8
str(long_data)
#> 'data.frame':    300 obs. of  8 variables:
#>  $ subject_id: chr  "001" "001" "001" "002" ...
#>  $ visit     : num  1 2 3 1 2 3 1 2 3 1 ...
#>  $ sex       : chr  "Male" "Male" "Male" "Male" ...
#>  $ treatment : chr  "Treatment" "Treatment" "Treatment" "Treatment" ...
#>  $ age       : num  46 46 46 35 35 35 25 25 25 34 ...
#>  $ weight    : num  71 71 71 77 77 77 63 63 63 70 ...
#>  $ biomarker : num  50.6 30.8 47.8 45.8 36.1 ...
#>  $ response  : chr  "None" "Complete" "Complete" "Partial" ...
```

### Data Visualization

#### **plot_bar()**

##### Description

…

##### Parameters

…

##### Examples

…

#### **plot_hist()**

##### Description

…

##### Parameters

…

##### Examples

…

#### **plot_box()**

##### Description

…

##### Parameters

…

##### Examples

…

#### **plot_line()**

##### Description

…

##### Parameters

…

##### Examples

…

#### **plot_waterfall()**

##### Description

…

##### Parameters

…

##### Examples

…

#### **plot_spider()**

##### Description

…

##### Parameters

…

##### Examples

…

#### **plot_sankey()**

##### Description

…

##### Parameters

…

##### Examples

…

#### **plot_butterfly()**

##### Description

…

##### Parameters

…

##### Examples

…

#### **plot_auc()**

##### Description

…

##### Parameters

…

##### Examples

…

#### **plot_correlation()**

##### Description

…

##### Parameters

…

##### Examples

…
