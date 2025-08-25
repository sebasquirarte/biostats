
<!-- README.md is generated from README.Rmd. Please edit that file -->

# biostats <a href="https://github.com/sebasquirarte/biostats/blob/main/man/figures/logo.png"><img src="man/figures/logo.png" align="right" height="138" alt="biostats_logo" /></a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/biostats)](https://cran.r-project.org/package=biostats)
<!-- badges: end -->

## Overview

***biostats*** is an R package that functions as a toolbox to streamline
biostatistics and clinical data analysis workflows.

#### Key features

- Descriptive statistics and exploratory data analysis
- Sample size and power calculation
- Statistical analysis and inference
- Data visualization

Designed primarily for comparative clinical studies as well as trial
planning and analysis, this package serves both as an analytical toolkit
for professional biostatisticians and clinical data analysts and as an
educational resource for researchers transitioning to R-based
biostatistics, including professionals from other domains, clinical
research professionals, and medical practitioners involved in the
development of clinical trials.

*Developed by the biostatistics team at [Laboratorios Sophia S.A. de
C.V.](https://sophialab.com/en/).*

## Installation

``` r
install.packages("remotes") 
library(remotes)
remotes::install_github("sebasquirarte/biostats", 
                        auth_token = "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",
                        force = TRUE, 
                        upgrade = "never")
library(biostats)
```

## Usage

This package comprises 14 functions across four analytical domains and
features an interactive Shiny application for clinical trial sample size
calculation supporting superiority, non-inferiority, equivalence, and
equality designs with customizable parameters for effect sizes, power,
and clinical significance thresholds, following methodologies
established by Chow et al. (2017).

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
  - [sample_size_calc()](#sample_size_calc) - Shiny App ✨
- [**Statistical Analysis and
  Inference**](#statistical-analysis-and-inference)
  - [omnibus()](#omnibus)
  - [effect_measures())](#effect_measures)
- [**Data Visualization**](#data-visualization)
  - [plot_bar()](#plot_bar)
  - [plot_line()](#plot_line)
  - [plot_hist()](#plot_hist)
  - [plot_box()](#plot_box)
  - [plot_corr()](#plot_corr)

### Descriptive Statistics and Exploratory Data Analysis (EDA)

#### **clinical_data()**

##### Description

Creates a simple simulated clinical trial dataset with subject
demographics, multiple visits, treatment groups with different effects,
numerical and categorical variables, as well as optional missing data
and dropout rates.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `n` | Number of subjects (1-999) | `100` |
| `visits` | Number of visits including baseline | `3` |
| `arms` | Character vector of treatment arms | `c("Placebo", "Treatment")` |
| `dropout` | Proportion of subjects who dropout (0-1) | `0` |
| `missing` | Proportion of missing data at random (0-1) | `0` |

##### Examples

``` r
# Simulate basic clinical data
clinical_df <- clinical_data()

str(clinical_df)
#> 'data.frame':    300 obs. of  8 variables:
#>  $ subject_id: chr  "001" "001" "001" "002" ...
#>  $ visit     : Factor w/ 3 levels "1","2","3": 1 2 3 1 2 3 1 2 3 1 ...
#>  $ sex       : Factor w/ 2 levels "Male","Female": 1 1 1 2 2 2 2 2 2 1 ...
#>  $ treatment : Factor w/ 2 levels "Placebo","Treatment": 1 1 1 1 1 1 1 1 1 2 ...
#>  $ age       : num  34 34 34 49 49 49 41 41 41 40 ...
#>  $ weight    : num  101.6 101.5 101.1 87.6 88.8 ...
#>  $ biomarker : num  60.7 49.7 49.7 34.8 57.9 ...
#>  $ response  : Factor w/ 3 levels "Complete","Partial",..: 1 3 2 3 3 1 3 3 3 2 ...

head(clinical_df, 10)
#>    subject_id visit    sex treatment age weight biomarker response
#> 1         001     1   Male   Placebo  34  101.6     60.74 Complete
#> 2         001     2   Male   Placebo  34  101.5     49.73     None
#> 3         001     3   Male   Placebo  34  101.1     49.67  Partial
#> 4         002     1 Female   Placebo  49   87.6     34.84     None
#> 5         002     2 Female   Placebo  49   88.8     57.90     None
#> 6         002     3 Female   Placebo  49   90.3     47.89 Complete
#> 7         003     1 Female   Placebo  41   62.0     43.43     None
#> 8         003     2 Female   Placebo  41   66.4     35.88     None
#> 9         003     3 Female   Placebo  41   68.5     47.00     None
#> 10        004     1   Male Treatment  40   82.2     38.51  Partial
```

``` r
# Simulate more complex clinical data
clinical_df_full <- clinical_data(n = 300,
                                  visits = 5,
                                  arms = c('A', 'B', 'C'), 
                                  dropout = 0.10,
                                  missing = 0.05)

str(clinical_df_full)
#> 'data.frame':    1500 obs. of  8 variables:
#>  $ subject_id: chr  "001" "001" "001" "001" ...
#>  $ visit     : Factor w/ 5 levels "1","2","3","4",..: 1 2 3 4 5 1 2 3 4 5 ...
#>  $ sex       : Factor w/ 2 levels "Male","Female": 2 2 2 2 2 1 1 1 1 1 ...
#>  $ treatment : Factor w/ 3 levels "A","B","C": 2 2 2 2 2 2 2 2 2 2 ...
#>  $ age       : num  28 28 28 28 28 79 79 79 79 79 ...
#>  $ weight    : num  77.8 75.8 74.1 76 74.5 63 62.2 62.5 NA 62.2 ...
#>  $ biomarker : num  43.2 70.5 62.5 54.5 28.6 ...
#>  $ response  : Factor w/ 3 levels "Complete","Partial",..: 2 1 2 2 NA NA NA 3 3 3 ...

head(clinical_df_full, 10)
#>    subject_id visit    sex treatment age weight biomarker response
#> 1         001     1 Female         B  28   77.8     43.20  Partial
#> 2         001     2 Female         B  28   75.8     70.50 Complete
#> 3         001     3 Female         B  28   74.1     62.47  Partial
#> 4         001     4 Female         B  28   76.0     54.46  Partial
#> 5         001     5 Female         B  28   74.5     28.56     <NA>
#> 6         002     1   Male         B  79   63.0     64.38     <NA>
#> 7         002     2   Male         B  79   62.2     51.50     <NA>
#> 8         002     3   Male         B  79   62.5     47.14     None
#> 9         002     4   Male         B  79     NA     45.79     None
#> 10        002     5   Male         B  79   62.2     48.58     None
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
| `data` | Dataframe containing the variables to be summarized | `Required` |
| `group_by` | Name of the grouping variable for two-group comparisons | `NULL` |
| `normality_test` | Normality test: ‘S-W’ for Shapiro-Wilk or ‘K-S’ for Kolmogorov-Smirnov | `"S-W"` |
| `all_stats` | If TRUE, provides detailed statistical summary | `FALSE` |
| `effect_size` | If TRUE, includes effect size estimates | `FALSE` |
| `exclude` | Variable names to exclude from the summary | `NULL` |

##### Examples

``` r
# Overall summary without considering treatment groups
summary_table(clinical_df,
              exclude = c('subject_id', 'visit'))
```

<img src="man/figures/summary_table_example_1.png" height = "250">

``` r
# Grouped summary by treatmet group
summary_table(clinical_df,
              group_by = 'treatment',
              exclude = c('subject_id', 'visit'))
```

<img src="man/figures/summary_table_example_2.png">

``` r
# Grouped summary by treatmet group with all stats and effect size
summary_table(clinical_df,
              group_by = 'treatment',
              all_stats = TRUE,
              effect_size = TRUE,
              exclude = c('subject_id', 'visit'))
```

<img src="man/figures/summary_table_example_3.png">

#### **normality()**

##### Description

Tests normality using sample size-appropriate methods: Shapiro-Wilk test
(n ≤ 50) or Kolmogorov-Smirnov test (n \> 50) with Q-Q plots and
histograms. Evaluates skewness and kurtosis using z-score criteria based
on sample size. Automatically detects outliers and provides
comprehensive visual and statistical assessment.

##### Parameters

| Parameter  | Description                                         | Default     |
|------------|-----------------------------------------------------|-------------|
| `data`     | Dataframe containing the variables to be summarized | `Required`  |
| `x`        | Name of the variable to analyzed                    | `NULL`      |
| `outliers` | If TRUE, displays all outlier row indices           | `FALSE`     |
| `color`    | Color for plots                                     | `"#7fcdbb"` |

##### Examples

``` r
# Normally distributed variable
normality(data = clinical_df, "biomarker")
#> 
#> Normality Test for 'biomarker' 
#> 
#> n = 300 
#> mean (SD) = 48.88 (10.7) 
#> median (IQR) = 49.20 (14.6) 
#> 
#> Kolmogorov-Smirnov: D = 0.042, p = 0.663 
#> Shapiro-Wilk: W = 0.995, p = 0.369 
#> Skewness: -0.10 (z = -0.68) 
#> Kurtosis: -0.24 (z = -0.86) 
#> 
#> Data appears normally distributed.
```

<img src="man/figures/README-unnamed-chunk-11-1.png" width="100%" />

``` r

# Non-normally distributed variable with points outside 95%CI displayed
normality(data = clinical_df, "weight", outside = TRUE)
#> 
#> Normality Test for 'weight' 
#> 
#> n = 300 
#> mean (SD) = 71.84 (14.2) 
#> median (IQR) = 70.10 (20.6) 
#> 
#> Kolmogorov-Smirnov: D = 0.086, p = 0.023 
#> Shapiro-Wilk: W = 0.976, p = < 0.001 
#> Skewness: 0.30 (z = 2.16) 
#> Kurtosis: -0.61 (z = -2.17) 
#> 
#> Data appears not normally distributed. 
#> 
#> VALUES OUTSIDE 95%CI (row indices): 202, 241, 242, 238, 78, 210, 295, 234, 230, 209, 261, 96, 97, 177, 287, 29, 257, 269, 168, 260, 254, 187, 270, 259, 161, 149, 229, 247, 268, 31, 231, 115, 150, 189, 253, 35, 117, 98, 255, 278, 38, 69, 170, 277, 39, 171, 6, 299, 46, 165, 192, 263, 291, 128, 164, 198, 197, 27, 92
```

<img src="man/figures/README-unnamed-chunk-11-2.png" width="100%" />

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
clinical_df <- clinical_data(missing = 0.05)

# Missing value analysis of only variables with missing values
missing_values(clinical_df)
#> 
#> Missing Value Analysis
#> 
#> n: 300, variables: 8
#> Complete cases: 255 / 300 (85.0%)
#> Missing cells: 45 / 2400 (1.9%)
#> 
#> Variables with missing values: 3 of 8 (37.5%)
#> 
#>           n_missing pct_missing
#> response         27        9.00
#> weight           11        3.67
#> biomarker         7        2.33
```

<img src="man/figures/README-unnamed-chunk-12-1.png" width="100%" />

``` r
# Show all variables including those without missing values
missing_values(clinical_df, all = TRUE)
#> 
#> Missing Value Analysis
#> 
#> n: 300, variables: 8
#> Complete cases: 255 / 300 (85.0%)
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

<img src="man/figures/README-unnamed-chunk-12-2.png" width="100%" />

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
#> Bounds: [21.30, 74.28]
#> Outliers detected: 3 (0.3%)
#> 
#> Outlier indices: 252, 627, 770
```

<img src="man/figures/README-unnamed-chunk-13-1.png" width="100%" />

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

<img src="man/figures/README-unnamed-chunk-17-1.png" width="75%" />

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
                            dropout = 0.1)
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

<img src="man/figures/README-unnamed-chunk-19-1.png" width="75%" />

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

Performs omnibus tests to evaluate overall differences between three or
more groups. Automatically selects the appropriate statistical test
based on data characteristics and assumption testing. Supports both
independent groups and repeated measures designs. Tests include one-way
ANOVA, repeated measures ANOVA, Kruskal-Wallis test, and Friedman test.
Performs comprehensive assumption checking (normality, homogeneity of
variance, sphericity) and post-hoc testing when significant results are
detected.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `data` | Dataframe containing the variables to be analyzed. | `Required` |
| `y` | Character string. Dependent variable (outcome). | `Required` |
| `x` | Character string. Independent variable (group or within-subject variable). | `Required` |
| `paired_var` | Character string or NULL. Source of repeated measurements. If provided, a repeated measures design is assumed. Data should be in long format with one row per observation. If NULL, independent groups design is assumed. | `NULL` |
| `alpha` | Numeric. Significance level for hypothesis tests. | `0.05` |
| `p_method` | Character string. Method for p-value adjustment in post-hoc multiple comparisons to control for Type I error inflation. | `"holm"` |
| `na.action` | Character string. Action to take if NAs are present (“na.omit” or “na.exclude”). | `"na.omit"` |

##### Examples

``` r
# Simulated clinical data with multiple tratment arms and visits
clinical_df <- clinical_data(n = 300, visits = 6, arms = c("A", "B", "C"))
 
# Compare numerical variable across treatments
result <- omnibus(data = clinical_df,
                  y = "biomarker", 
                  x = "treatment")
#> 
#> Omnibus Test: One-way ANOVA
#> 
#> Assumption Testing Results:
#> 
#>   Normality (Shapiro-Wilk Test):
#>   A: W = 0.9987, p = 0.955
#>   B: W = 0.9987, p = 0.928
#>   C: W = 0.9952, p = 0.069
#>   Overall result: Normal distribution assumed.
#> 
#>   Homogeneity of Variance (Bartlett Test):
#>   Chi-squared(2) = 2.2644, p = 0.322
#>   Effect size (Cramer's V) = 0.0251
#>   Result: Homogeneous variances.
#> 
#> Test Results:
#> 
#>   Formula: biomarker ~ treatment
#>   alpha: 0.05
#>   F(2,1797) = 55.292, p = <0.001
#>   Result: significant
#> 
#> Post-hoc Multiple Comparisons
#> 
#> Tukey Honest Significant Differences (alpha: 0.050):
#> Comparison               Diff    Lower    Upper    p-adj
#> ------------------------------------------------------------ 
#> B - A                  -3.185   -4.564   -1.805   <0.001*
#> C - A                  -6.370   -7.791   -4.949   <0.001*
#> C - B                  -3.186   -4.550   -1.822   <0.001*
#> 
#> The study groups show a moderately unbalanced distribution of sample sizes (Δn = 0.220).
```

``` r
# Filter simulated data to just one treatment
clinical_df_A <- clinical_df[clinical_df$treatment == "A", ]

# Compare numerical variable changes across visits 
result <- omnibus(y = "biomarker", 
                  x = "visit", 
                  data = clinical_df_A, 
                  paired_by = "subject_id")
#> 
#> Omnibus Test: Friedman
#> 
#> Assumption Testing Results:
#> 
#>   Sphericity (Mauchly Test):
#>   Effect size (W) = 0.7475
#>   Result: Sphericity violated.
#> 
#>   Normality (Shapiro-Wilk Test):
#>   1: W = 0.9894, p = 0.664
#>   2: W = 0.9801, p = 0.167
#>   3: W = 0.9903, p = 0.736
#>   4: W = 0.9786, p = 0.131
#>   5: W = 0.9877, p = 0.537
#>   6: W = 0.9876, p = 0.531
#>   Overall result: Normal distribution assumed.
#> 
#>   Homogeneity of Variance (Bartlett Test):
#>   Chi-squared(5) = 3.5238, p = 0.620
#>   Effect size (Cramer's V) = 0.0355
#>   Result: Homogeneous variances.
#> 
#> Test Results:
#> 
#>   Formula: biomarker ~ visit | subject_id
#>   alpha: 0.05
#>   Chi-squared(5) = 3.291, p = 0.655
#>   Result: not significant
#> 
#> Post-hoc tests not performed (results not significant).
#> 
#> 
#> The study groups show a moderately unbalanced distribution of sample sizes (Δn = 0.199).
```

#### **effect_measures()**

##### Description

Calculates measures of effect: Odds Ratio (OR), Risk Ratio (RR), Risk
Reduction (RD) and either Number Needed to Treat (NNT) or Number Needed
to Harm (NNH).

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `exposed_event` | Numeric. Number of events in the exposed group. | `Required` |
| `exposed_no_event` | Numeric. Number of non-events in the exposed group. | `Required` |
| `unexposed_event` | Numeric. Number of events in the unexposed group. | `Required` |
| `unexposed_no_event` | Numeric. Number of non-events in the unexposed group. | `Required` |
| `alpha` | Numeric. Value between 0 and 1 specifying the alpha level for confidence intervals (CI). | `0.05` |
| `correction` | Logical. If TRUE, a continuity correction (0.5) is applied when any cell contains 0. | `TRUE` |

##### Examples

``` r
effect_measures(exposed_event = 15, 
                exposed_no_event = 85,
                unexposed_event = 5,
                unexposed_no_event = 95)
#> 
#> Odds/Risk Ratio Analysis
#> 
#> Contingency Table:
#>                 Event No Event      Sum
#> Exposed            15       85      100
#> Unexposed           5       95      100
#> Sum                20      180      200
#> 
#> Odds Ratio: 3.353 (95% CI: 1.169 - 9.616)
#> Risk Ratio: 3.000 (95% CI: 1.133 - 7.941)
#> 
#> Risk in exposed: 15.0%
#> Risk in unexposed: 5.0%
#> Absolute risk difference: 10.0%
#> Number needed to harm (NNH): 10.0
#> 
#> Note: Correction not applied (no zero values).
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

<img src="man/figures/README-unnamed-chunk-24-1.png" width="75%" />

``` r

# Grouped barplot of categorical variable by treatment with value labels
plot_bar(clinical_df, 
         x = "response", 
         group = "visit", 
         facet = "treatment", 
         title = "Response by visit and treatment",
         values = TRUE)
```

<img src="man/figures/README-unnamed-chunk-24-2.png" width="75%" />

#### **plot_line()**

##### Description

Generates publication-ready line plots with minimal code using ggplot2.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `data` | A data frame containing the variables to plot | `Required` |
| `x` | Character string specifying the x-axis variable (typically time or ordered) | `Required` |
| `y` | Character string specifying the y-axis variable (measurement or outcome) | `Required` |
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

<img src="man/figures/README-unnamed-chunk-25-1.png" width="100%" />

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

<img src="man/figures/README-unnamed-chunk-25-2.png" width="100%" />

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

<img src="man/figures/README-unnamed-chunk-26-1.png" width="100%" />

``` r

# Faceted histogram
plot_hist(clinical_df, x = "biomarker", facet = "treatment")
```

<img src="man/figures/README-unnamed-chunk-26-2.png" width="100%" />

#### **plot_box()**

##### Description

Generates publication-ready boxplots with optional jittered points and
mean overlay.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `data` | A data frame containing the variables to plot | `Required` |
| `x` | Character string specifying the x-axis variable (categorical or numeric with few unique values) | `Required` |
| `y` | Character string specifying the y-axis variable (numeric) | `Required` |
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

<img src="man/figures/README-unnamed-chunk-27-1.png" width="100%" />

``` r

# Barplot of bimarker by study visit and treatment
plot_box(clinical_df, x = "visit", y = "biomarker", group = "treatment", y_limits = c(0,80))
#> Warning: Removed 1 row containing non-finite outside the scale range
#> (`stat_boxplot()`).
#> Warning: Removed 1 row containing non-finite outside the scale range
#> (`stat_summary()`).
```

<img src="man/figures/README-unnamed-chunk-27-2.png" width="100%" />

#### **plot_corr()**

##### Description

Generates publication-ready correlation matrix heatmaps with minimal
code using ggplot2.

##### Parameters

| Parameter | Description | Default |
|----|----|----|
| `data` | A data frame containing the variables to analyze | Required |
| `vars` | Optional character vector specifying which variables to include. If NULL, all numeric variables will be used | `NULL` |
| `method` | Character string specifying correlation method; one of “pearson”, “spearman”, or “kendall” | `"pearson"` |
| `type` | Character string specifying matrix type; one of “full”, “upper”, or “lower” | `"full"` |
| `diag` | Logical; whether to show diagonal (always 1.0) | `TRUE` |
| `colors` | Character vector of 3 colors for negative, neutral, and positive correlations. If NULL, uses a TealGrn-based palette | `NULL` |
| `title` | Optional character string for the plot title | `NULL` |
| `text_size` | Numeric value specifying the base text size | `12` |
| `show_values` | Logical; whether to display correlation values in cells | `TRUE` |
| `value_size` | Numeric; size of correlation value text | `3` |
| `show_significance` | Logical; whether to mark significant correlations | `FALSE` |
| `sig_level` | Numeric; significance level for marking | `0.05` |

##### Examples

``` r
# Sample data
cars_df <- mtcars

# Correlation matrix with statistical significance
plot_corr(cars_df, type = "upper", show_significance = TRUE)
```

<img src="man/figures/README-unnamed-chunk-28-1.png" width="100%" />
