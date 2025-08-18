
<!-- README.md is generated from README.Rmd. Please edit that file -->

# biostats <a href="https://github.com/sebasquirarte/biostats/blob/main/man/figures/logo.png"><img src="man/figures/logo.png" align="right" height="138" alt="biostats_logo" /></a>

<!-- badges: start -->

[![R-CMD-check.yaml](https://github.com/sebasquirarte/biostats/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/sebasquirarte/biostats/actions/workflows/R-CMD-check.yaml)
[![Tests](https://github.com/sebasquirarte/biostats/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/sebasquirarte/biostats/actions/workflows/test-coverage.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/biostats)](https://cran.r-project.org/package=biostats)
<!-- badges: end -->

## Overview

***biostats*** is an R package that functions as a toolbox for
biostatistics and clinical data analysis.

#### Key features

- Descriptive statistics
- Exploratory data analysis (EDA)
- Sample size and power calculation
- Statistical tests and inference
- Data cleaning, transformation, and visualization

*Developed by the biostatistics team at [Laboratorios Sophia S.A. de
C.V.](https://sophialab.com/en/) for biostatisticians, clinical
researchers and data analysts.*

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

The biostats package includes the following functions:

- [**Descriptive Statistics and Exploratory Data Analysis
  (EDA)**](#descriptive-statistics-and-exploratory-data-analysis-eda)
  - [clinical_data()](#clinical_data)
  - [summary_table()](#summary_table)
  - [normality()](#normality)
  - [missing_values()](#missing_values)
  - [outliers()](#outliers)
- [**Sample Size and Power
  Calculation**](#sample-size-and-power-calculation)
  - [sample_size()](#sample_size)
  - [sample_size_range()](#sample_size_range)
- [**Statistical Analysis and
  Inference**](#statistical-analysis-and-inference)
  - [omnibus()](#anova_test)
  - [odds()](#odds)
  - [auc_response()](#auc)
- [**Data Visualization**](#data-visualization)
  - [plot_bar()](#plot_bar)
  - [plot_line()](#plot_line)
  - [plot_hist()](#plot_hist)
  - [plot_box()](#plot_box)
  - [plot_correlation()](#plot_correlation)

### Descriptive Statistics and Exploratory Data Analysis (EDA)

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
#> 299        100     2   Male         A  34     NA     54.50     None
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

![](man/figures/summary_table_example_1.png)

``` r
# Grouped summary for each tratment group
clinical_summary <- summary_table(clinical_df,
                                  group_var = 'treatment',
                                  exclude = c('subject_id', 'visit'))
```

![](man/figures/summary_table_example_2.png)

``` r
# Grouped summary for each tratment group with all stats
clinical_summary <- summary_table(clinical_df,
                                  group_var = 'treatment',
                                  all_stats = TRUE,
                                  exclude = c('subject_id', 'visit'))
```

![](man/figures/summary_table_example_3.png)

``` r
# Grouped summary for each tratment group with effect size
clinical_summary <- summary_table(clinical_df,
                                  group_var = 'treatment',
                                  effect_size = TRUE,
                                  exclude = c('subject_id', 'visit'))
```

![](man/figures/summary_table_example_4.png)

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

# Normal distributionpaletteer_c("grDevices::TealGrn", 30)
normality("biomarker", data = clinical_df)
#> 
#> Normality Test for 'biomarker' 
#> 
#> n = 300 
#> mean (SD) = 48.27 (10.0) 
#> median (IQR) = 48.39 (13.5) 
#> 
#> Shapiro-Wilk: W = 0.996, p = 0.734 
#> Skewness: -0.01 
#> Kurtosis: -0.34 
#> 
#> Data is normally distributed.
```

<img src="man/figures/README-unnamed-chunk-13-1.png" width="100%" />

``` r

# Non-normal distribution with outliers displayed
normality("weight", data = clinical_df, outliers = TRUE)
#> 
#> Normality Test for 'weight' 
#> 
#> n = 300 
#> mean (SD) = 68.52 (15.8) 
#> median (IQR) = 68.20 (21.4) 
#> 
#> Shapiro-Wilk: W = 0.964, p = < 0.001 
#> Skewness: 0.45 
#> Kurtosis: -0.16 
#> 
#> Data is not normally distributed. 
#> 
#> OUTLIERS (row indices): 34, 35, 36, 40, 41, 42, 82, 83, 84, 94, 95, 96, 203, 255, 59, 256, 139, 75, 159, 67, 296, 287, 219, 53, 68, 130, 132
```

<img src="man/figures/README-unnamed-chunk-13-2.png" width="100%" />

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
#> Complete cases: 256 / 300 (85.3%)
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
#> Complete cases: 256 / 300 (85.3%)
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

#### **outliers()**

##### Description

Identifies outliers using Tukey’s interquartile range (IQR) method and
provides comprehensive visual assessment through scatter plots and
boxplots.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| x | Numeric vector or character string naming a column in `data`. | `Required` |
| data | Optional dataframe containing the variable specified in `x`. | `NULL` |
| threshold | Numeric value multiplying the IQR to define outlier boundaries. | `1.5` |
| color | Character string specifying plot color. | `"#7fcdbb"` |

##### Examples

``` r
clinical_df <- clinical_data(n = 300)
outliers(clinical_df$biomarker)
#> 
#> Outlier Detection for 'clinical_df$biomarker'
#> 
#> n: 900
#> Missing: 0 (0.0%)
#> Method: Tukey's IQR x 1.5
#> Bounds: [20.55, 76.06]
#> Outliers detected: 7 (0.8%)
#> 
#> Outlier indices: 273, 564, 587, 686, 707, 854, 874
```

<img src="man/figures/README-unnamed-chunk-15-1.png" width="100%" />

### Sample Size and Power Calculation

#### **sample_size()**

##### Description

Calculates the sample size needed in a clinical trial based on study
design and statistical parameters.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `sample` | Whether one or two samples need to be calculated (`"one-sample"` or `"two-sample"`). | `Required` |
| `design` | Study design for two-sample tests. Options: `"parallel"` or `"crossover"`. | `NULL` |
| `outcome` | Type of outcome variable: `"mean"` or `"proportion"`. | `Required` |
| `type` | Type of hypothesis test: `"equality"`, `"equivalence"`, `"non-inferiority"`, or `"superiority"`. | `Required` |
| `alpha` | Type I error rate (significance level). | `0.05` |
| `beta` | Type II error rate (1 - power). | `0.20` |
| `x1` | Value of the mean or proportion for group 1 (e.g., treatment). | `Required` |
| `x2` | Value of the mean or proportion for group 2 (e.g., control or reference). | `Required` |
| `SD` | Standard deviation (required for mean outcomes and crossover designs with proportions). | `NULL` |
| `delta` | Margin of clinical interest. Required for non-equality tests. | `NULL` |
| `k` | Allocation ratio (n₁/n₂) for two-sample tests. | `1` |

##### Examples

``` r
# One-sample equivalence test for means
sample_size(sample = 'one-sample',
            outcome = 'mean',
            type = 'equivalence', 
            x1 = 0,
            x2 = 0,
            SD = 0.1,
            delta = 0.05,
            alpha = 0.05,
            beta = 0.20)
#> 
#> Sample Size Calculation Summary
#> 
#> Test type: equivalence 
#> Design: one-sample
#> Outcome: mean 
#> Alpha (α): 0.05
#> Beta (β): 0.20
#> Power: 80%
#> 
#> Parameters:
#> x1 (treatment): 0.00
#> x2 (control/reference): 0.00
#> Difference (x1 - x2): 0.00
#> Standard Deviation (σ): 0.10
#> Delta (δ): 0.05
#> 
#> Required Sample Size
#> n = 35
#> Total = 35
```

``` r
# Two-sample parallel non-inferiority test for means
sample_size(sample = 'two-sample',
            design = 'parallel',
            outcome = 'mean',
            type = 'non-inferiority',
            x1 = 5.0,
            x2 = 5.0,
            SD = 0.1,
            delta = -0.05,
            k = 1)
#> 
#> Sample Size Calculation Summary
#> 
#> Test type: non-inferiority 
#> Design: parallel, two-sample
#> Outcome: mean 
#> Alpha (α): 0.05
#> Beta (β): 0.20
#> Power: 80%
#> 
#> Parameters:
#> x1 (treatment): 5.00
#> x2 (control/reference): 5.00
#> Difference (x1 - x2): 0.00
#> Standard Deviation (σ): 0.10
#> Allocation Ratio (k): 1.00
#> Delta (δ): -0.05
#> 
#> Required Sample Size
#> n1 = 50
#> n2 = 50
#> Total = 100
```

``` r
# Two-sample crossover non-inferiority test for means
sample_size(sample = 'two-sample', 
            design = "crossover",
            outcome = 'mean',
            type = 'non-inferiority', 
            x1 = -0.10, 
            x2 = 0,
            SD = 0.20,
            delta = -0.20,
            alpha = 0.05, 
            beta = 0.20)
#> 
#> Sample Size Calculation Summary
#> 
#> Test type: non-inferiority 
#> Design: crossover, two-sample
#> Outcome: mean 
#> Alpha (α): 0.05
#> Beta (β): 0.20
#> Power: 80%
#> 
#> Parameters:
#> x1 (treatment): -0.10
#> x2 (control/reference): 0.00
#> Difference (x1 - x2): -0.10
#> Standard Deviation (σ): 0.20
#> Allocation Ratio (k): 1.00
#> Delta (δ): -0.20
#> 
#> Required Sample Size
#> n1 = 13
#> n2 = 13
#> Total = 26
```

#### **sample_size_range()**

##### Description

Calculates required sample sizes for specified power levels (70%, 80%,
90%) across a range of treatment effect values (`x1`), while keeping the
control group value (`x2`) fixed. Internally calls `sample_size()` and
generates a plot to visualize how total sample size changes with varying
`x1`.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `x1_range` | Numeric vector of length 2. Range of values to evaluate for the treatment group mean or proportion (`x1`). | `Required` |
| `x2` | Fixed reference value for the control group. | `Required` |
| `step` | Step size to increment across the `x1_range`. | `0.1` |
| `...` | Additional arguments passed to `sample_size()`, such as `sample`, `design`, `outcome`, `type`, `SD`, `alpha`, etc. | `—` |

##### Examples

``` r
# One-sample equivalence test for means
result <- sample_size_range(x1_range = c(-0.01, 0.01),
                            x2 = 0,
                            step = 0.005,
                            sample = "one-sample",
                            outcome = "mean",
                            type = "equivalence",
                            SD = 0.1,
                            delta = 0.05,
                            alpha = 0.05)
#> 
#> Sample Size Range
#> 
#> x1: -0.01 to 0.01
#> x2: 0.00
#> 
#> 70% Power: total n = 29 to 45
#> 80% Power: total n = 35 to 54
#> 90% Power: total n = 44 to 68
```

<img src="man/figures/README-unnamed-chunk-19-1.png" width="75%" />

| power |     x1 |  x2 | x1 - x2 |  n1 |  n2 | total |
|------:|-------:|----:|--------:|----:|----:|------:|
|    70 | -0.010 |   0 |  -0.010 |  45 |  45 |    45 |
|    70 | -0.005 |   0 |  -0.005 |  36 |  36 |    36 |
|    70 |  0.000 |   0 |   0.000 |  29 |  29 |    29 |
|    70 |  0.005 |   0 |   0.005 |  36 |  36 |    36 |
|    70 |  0.010 |   0 |   0.010 |  45 |  45 |    45 |
|    80 | -0.010 |   0 |  -0.010 |  54 |  54 |    54 |
|    80 | -0.005 |   0 |  -0.005 |  43 |  43 |    43 |
|    80 |  0.000 |   0 |   0.000 |  35 |  35 |    35 |
|    80 |  0.005 |   0 |   0.005 |  43 |  43 |    43 |
|    80 |  0.010 |   0 |   0.010 |  54 |  54 |    54 |
|    90 | -0.010 |   0 |  -0.010 |  68 |  68 |    68 |
|    90 | -0.005 |   0 |  -0.005 |  54 |  54 |    54 |
|    90 |  0.000 |   0 |   0.000 |  44 |  44 |    44 |
|    90 |  0.005 |   0 |   0.005 |  54 |  54 |    54 |
|    90 |  0.010 |   0 |   0.010 |  68 |  68 |    68 |

``` r
# Two-sample parallel non-inferiority test for proportions w/ 10% dropout rate
result <- sample_size_range(x1_range = c(0.65, 0.75),
                            x2 = 0.65,
                            step = 0.02,
                            sample = "two-sample",
                            design = "parallel",
                            outcome = "proportion",
                            type = "non-inferiority",
                            delta = -0.1,
                            alpha = 0.05,
                            dropout_rate = 0.1)
#> 
#> Sample Size Range
#> 
#> x1: 0.65 to 0.75
#> x2: 0.65
#> 
#> 70% Power: total n = 108 to 474
#> 80% Power: total n = 144 to 622
#> 90% Power: total n = 196 to 858
```

<img src="man/figures/README-unnamed-chunk-21-1.png" width="75%" />

| power |   x1 |   x2 | x1 - x2 |  n1 |  n2 | total |
|------:|-----:|-----:|--------:|----:|----:|------:|
|    70 | 0.65 | 0.65 |    0.00 | 237 | 237 |   474 |
|    70 | 0.67 | 0.65 |    0.02 | 162 | 162 |   324 |
|    70 | 0.69 | 0.65 |    0.04 | 117 | 117 |   234 |
|    70 | 0.71 | 0.65 |    0.06 |  88 |  88 |   176 |
|    70 | 0.73 | 0.65 |    0.08 |  69 |  69 |   138 |
|    70 | 0.75 | 0.65 |    0.10 |  54 |  54 |   108 |
|    80 | 0.65 | 0.65 |    0.00 | 311 | 311 |   622 |
|    80 | 0.67 | 0.65 |    0.02 | 213 | 213 |   426 |
|    80 | 0.69 | 0.65 |    0.04 | 154 | 154 |   308 |
|    80 | 0.71 | 0.65 |    0.06 | 116 | 116 |   232 |
|    80 | 0.73 | 0.65 |    0.08 |  91 |  91 |   182 |
|    80 | 0.75 | 0.65 |    0.10 |  72 |  72 |   144 |
|    90 | 0.65 | 0.65 |    0.00 | 429 | 429 |   858 |
|    90 | 0.67 | 0.65 |    0.02 | 294 | 294 |   588 |
|    90 | 0.69 | 0.65 |    0.04 | 213 | 213 |   426 |
|    90 | 0.71 | 0.65 |    0.06 | 160 | 160 |   320 |
|    90 | 0.73 | 0.65 |    0.08 | 125 | 125 |   250 |
|    90 | 0.75 | 0.65 |    0.10 |  98 |  98 |   196 |

### Statistical Analysis and Inference

#### **omnibus()**

##### Description

- 

##### Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| \-        | \-          | \-      |

##### Examples

``` r
NULL
#> NULL
```

#### **odds()**

##### Description

- 

##### Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| \-        | \-          | \-      |

##### Examples

``` r
NULL
#> NULL
```

#### **auc_response()**

##### Description

- 

##### Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| \-        | \-          | \-      |

##### Examples

``` r
NULL
#> NULL
```

### Data Visualization

#### **plot_bar()**

##### Description

Generates publication-ready bar plots with minimal code using ggplot2.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `data` | A data frame containing the variables to plot | `Required` |
| `x` | Character string specifying the x-axis variable | `Required` |
| `y` | Optional character string specifying the y-axis variable. If provided, values from this column will be used for bar heights. If `NULL`, counts will be calculated automatically | `NULL` |
| `group` | Optional character string specifying the grouping variable for fill color | `NULL` |
| `facet` | Optional character string specifying the faceting variable | `NULL` |
| `position` | Character string specifying the bar position; one of `"dodge"` (default), `"stack"`, or `"fill"` (for percentage stacking) | `"dodge"` |
| `stat` | Optional character string for statistical aggregation; one of `"mean"` or `"median"` | `NULL` |
| `colors` | Character vector of colors for bars or groups. If `NULL`, uses TealGrn color palette | `NULL` |
| `title` | Optional character string for the plot title | `NULL` |
| `xlab` | Optional character string for the x-axis label | `NULL` |
| `ylab` | Optional character string for the y-axis label | `NULL` |
| `legend_title` | Optional character string for the legend title | `NULL` |
| `flip` | Logical; whether to flip the coordinates (horizontal bars) | `NULL` |
| `text_size` | Numeric value specifying the base text size | `12` |

##### Examples

``` r
# Simulated clinical data
clinical_df <- clinical_data()

# Proportion of response by treatment
plot_bar(clinical_df, 
         x = "treatment", 
         group = "response",
         position = "fill", 
         title = "Proportion of response by treatment", 
         values = TRUE)
```

<img src="man/figures/README-unnamed-chunk-26-1.png" width="75%" />

``` r

# Grouped barplot of categorical variable by treatment with value labels
plot_bar(clinical_df, 
         x = "response", 
         group = "visit", 
         facet = "treatment", 
         title = "Response by visit and treatment",
         values = TRUE)
```

<img src="man/figures/README-unnamed-chunk-26-2.png" width="75%" />

#### **plot_line()**

##### Description

Generates publication-ready line plots with minimal code using ggplot2.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `data` | A data frame containing the variables to plot | – |
| `x` | Character string specifying the x-axis variable (typically time or ordered) | – |
| `y` | Character string specifying the y-axis variable (measurement or outcome) | – |
| `group` | Optional character string specifying the grouping variable for multiple lines | `NULL` |
| `facet` | Optional character string specifying the faceting variable | `NULL` |
| `stat` | Optional character string for statistical aggregation; one of `"mean"` or `"median"` | `NULL` |
| `error` | Optional character string for error bars; one of `"se"` (standard error, default), `"sd"`, `"ci"`, or `"none"` | `"se"` |
| `error_width` | Numeric; width of the error bar caps | `0.2` |
| `colors` | Character vector of colors for lines. If `NULL`, uses TealGrn color palette | `NULL` |
| `title` | Optional character string for the plot title | `NULL` |
| `xlab` | Optional character string for the x-axis label | `NULL` |
| `ylab` | Optional character string for the y-axis label | `NULL` |
| `legend_title` | Optional character string for the legend title | `NULL` |
| `points` | Logical; whether to add points to the lines | `TRUE` |
| `line_size` | Numeric; thickness of the lines | `1` |
| `point_size` | Numeric; size of the points if shown | `3` |
| `text_size` | Numeric value specifying the base text size | `12` |

##### Examples

``` r
# Simulated clinical data
clinical_df <- clinical_data(arms = c("A","B","C"), visits = 10)

# Line plot with mean and standard error by treatment
plot_line(clinical_df, 
          x = "visit", 
          y = "biomarker",
          group = "treatment", 
          stat = "mean", 
          error = "se")
```

<img src="man/figures/README-unnamed-chunk-27-1.png" width="100%" />

``` r

# Faceted line plots with median and 95% CI
plot_line(clinical_df, 
          x = "visit", 
          y = "biomarker", 
          group = "treatment", 
          facet = "sex",
          stat = "median", 
          error = "ci", 
          points = FALSE)
```

<img src="man/figures/README-unnamed-chunk-27-2.png" width="100%" />

#### **plot_hist()**

##### Description

Generates publication-ready histogram plots with minimal code using
ggplot2.

##### Parameters

## Parameters

| Parameter | Description | Default |
|----|----|----|
| `data` | A data frame containing the variables to plot | \- |
| `x` | Character string specifying the variable for the histogram | \- |
| `group` | Optional character string specifying the grouping variable for multiple histograms | \- |
| `facet` | Optional character string specifying the faceting variable | \- |
| `bins` | Numeric; number of bins for the histogram | 30 |
| `binwidth` | Numeric; width of the bins (overrides bins if specified) | \- |
| `alpha` | Numeric; transparency level for the bars | 0.7 |
| `colors` | Character vector of colors for bars. If NULL, uses TealGrn color palette | NULL |
| `title` | Optional character string for the plot title | \- |
| `xlab` | Optional character string for the x-axis label | \- |
| `ylab` | Optional character string for the y-axis label | \- |
| `legend_title` | Optional character string for the legend title | \- |
| `text_size` | Numeric value specifying the base text size | 12 |
| `y_limits` | Numeric vector of length 2 specifying y-axis limits (e.g., c(0, 100)) | \- |
| `x_limits` | Numeric vector of length 2 specifying x-axis limits (e.g., c(0, 50)) | \- |
| `stat` | Optional character string; adds a dashed line for “mean” or “median” | NULL |

##### Examples

``` r
# Sample clinical data
clinical_df <- clinical_data()

# Mirror histogram for 2 groups with mean lines
plot_hist(clinical_df, x = "biomarker", group = "treatment", stat = "mean")
```

<img src="man/figures/README-unnamed-chunk-28-1.png" width="100%" />

``` r

# Faceted histogram
plot_hist(clinical_df, x = "biomarker", facet = "treatment")
```

<img src="man/figures/README-unnamed-chunk-28-2.png" width="100%" />

#### **plot_box()**

##### Description

Generates publication-ready boxplots with optional jittered points and
mean overlay.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `data` | A data frame containing the variables to plot | — |
| `x` | Character string specifying the x-axis variable (categorical or numeric with few unique values) | — |
| `y` | Character string specifying the y-axis variable (numeric) | — |
| `group` | Optional character string specifying grouping variable for fill/color | `NULL` |
| `facet` | Optional character string specifying faceting variable | `NULL` |
| `colors` | Character vector of colors. If `NULL`, uses TealGrn palette | `NULL` |
| `title` | Optional plot title | `NULL` |
| `xlab` | Optional x-axis label | `NULL` |
| `ylab` | Optional y-axis label | `NULL` |
| `legend_title` | Optional legend title | `NULL` |
| `points` | Logical; add jittered points | `FALSE` |
| `point_size` | Numeric; size of points | — |
| `text_size` | Numeric; base text size | — |
| `y_limits` | Numeric vector of length 2 for y-axis limits | `NULL` |

##### Examples

``` r
# Simulated clinical data
clinical_df <- clinical_data(visit = 10)

# Barplot of age by sex and treatment
plot_box(clinical_df, x = "sex", y = "age", group = "treatment", y_limits = c(0,80))
```

<img src="man/figures/README-unnamed-chunk-29-1.png" width="100%" />

``` r

# Barplot of bimarker by study visit and treatment
plot_box(clinical_df, x = "visit", y = "biomarker", group = "treatment", y_limits = c(0,80))
```

<img src="man/figures/README-unnamed-chunk-29-2.png" width="100%" />

#### **plot_correlation()**

##### Description

- 

##### Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| \-        | \-          | \-      |

##### Examples

``` r
NULL
#> NULL
```
