
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

clinical_summary
```

<div id="iwfutwpnnh" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#iwfutwpnnh table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#iwfutwpnnh thead, #iwfutwpnnh tbody, #iwfutwpnnh tfoot, #iwfutwpnnh tr, #iwfutwpnnh td, #iwfutwpnnh th {
  border-style: none;
}
&#10;#iwfutwpnnh p {
  margin: 0;
  padding: 0;
}
&#10;#iwfutwpnnh .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#iwfutwpnnh .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#iwfutwpnnh .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#iwfutwpnnh .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#iwfutwpnnh .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#iwfutwpnnh .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#iwfutwpnnh .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#iwfutwpnnh .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#iwfutwpnnh .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#iwfutwpnnh .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#iwfutwpnnh .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#iwfutwpnnh .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#iwfutwpnnh .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#iwfutwpnnh .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#iwfutwpnnh .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#iwfutwpnnh .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#iwfutwpnnh .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#iwfutwpnnh .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#iwfutwpnnh .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#iwfutwpnnh .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#iwfutwpnnh .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#iwfutwpnnh .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#iwfutwpnnh .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#iwfutwpnnh .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#iwfutwpnnh .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#iwfutwpnnh .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#iwfutwpnnh .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#iwfutwpnnh .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#iwfutwpnnh .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#iwfutwpnnh .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#iwfutwpnnh .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#iwfutwpnnh .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#iwfutwpnnh .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#iwfutwpnnh .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#iwfutwpnnh .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#iwfutwpnnh .gt_left {
  text-align: left;
}
&#10;#iwfutwpnnh .gt_center {
  text-align: center;
}
&#10;#iwfutwpnnh .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#iwfutwpnnh .gt_font_normal {
  font-weight: normal;
}
&#10;#iwfutwpnnh .gt_font_bold {
  font-weight: bold;
}
&#10;#iwfutwpnnh .gt_font_italic {
  font-style: italic;
}
&#10;#iwfutwpnnh .gt_super {
  font-size: 65%;
}
&#10;#iwfutwpnnh .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#iwfutwpnnh .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#iwfutwpnnh .gt_indent_1 {
  text-indent: 5px;
}
&#10;#iwfutwpnnh .gt_indent_2 {
  text-indent: 10px;
}
&#10;#iwfutwpnnh .gt_indent_3 {
  text-indent: 15px;
}
&#10;#iwfutwpnnh .gt_indent_4 {
  text-indent: 20px;
}
&#10;#iwfutwpnnh .gt_indent_5 {
  text-indent: 25px;
}
&#10;#iwfutwpnnh .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#iwfutwpnnh div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="variable">variable</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="n">n</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="summary">summary</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="normality">normality</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="variable" class="gt_row gt_left">sex</td>
<td headers="n" class="gt_row gt_right">300</td>
<td headers="summary" class="gt_row gt_left">Male: 138 (46.0%); Female: 162 (54.0%)</td>
<td headers="normality" class="gt_row gt_left">NA</td></tr>
    <tr><td headers="variable" class="gt_row gt_left">treatment</td>
<td headers="n" class="gt_row gt_right">300</td>
<td headers="summary" class="gt_row gt_left">Placebo: 153 (51.0%); Treatment: 147 (49.0%)</td>
<td headers="normality" class="gt_row gt_left">NA</td></tr>
    <tr><td headers="variable" class="gt_row gt_left">age</td>
<td headers="n" class="gt_row gt_right">300</td>
<td headers="summary" class="gt_row gt_left">Median (IQR): 47.00 (22.50)</td>
<td headers="normality" class="gt_row gt_left">&lt; 0.001</td></tr>
    <tr><td headers="variable" class="gt_row gt_left">weight</td>
<td headers="n" class="gt_row gt_right">300</td>
<td headers="summary" class="gt_row gt_left">Median (IQR): 70.00 (21.67)</td>
<td headers="normality" class="gt_row gt_left">&lt; 0.001</td></tr>
    <tr><td headers="variable" class="gt_row gt_left">biomarker</td>
<td headers="n" class="gt_row gt_right">300</td>
<td headers="summary" class="gt_row gt_left">Mean (SD): 47.75 (10.54)</td>
<td headers="normality" class="gt_row gt_left">0.102</td></tr>
    <tr><td headers="variable" class="gt_row gt_left">response</td>
<td headers="n" class="gt_row gt_right">300</td>
<td headers="summary" class="gt_row gt_left">Complete: 84 (28.0%); Partial: 69 (23.0%); None: 147 (49.0%)</td>
<td headers="normality" class="gt_row gt_left">NA</td></tr>
  </tbody>
  &#10;  
</table>
</div>

``` r
# Grouped summary for each tratment group
clinical_summary <- summary_table(clinical_df,
                                  group_var = 'treatment',
                                  exclude = c('subject_id', 'visit'))

clinical_summary
```

<div id="xlwiusujjm" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#xlwiusujjm table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#xlwiusujjm thead, #xlwiusujjm tbody, #xlwiusujjm tfoot, #xlwiusujjm tr, #xlwiusujjm td, #xlwiusujjm th {
  border-style: none;
}
&#10;#xlwiusujjm p {
  margin: 0;
  padding: 0;
}
&#10;#xlwiusujjm .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#xlwiusujjm .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#xlwiusujjm .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#xlwiusujjm .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#xlwiusujjm .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#xlwiusujjm .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#xlwiusujjm .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#xlwiusujjm .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#xlwiusujjm .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#xlwiusujjm .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#xlwiusujjm .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#xlwiusujjm .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#xlwiusujjm .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#xlwiusujjm .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#xlwiusujjm .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#xlwiusujjm .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#xlwiusujjm .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#xlwiusujjm .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#xlwiusujjm .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xlwiusujjm .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#xlwiusujjm .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#xlwiusujjm .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#xlwiusujjm .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xlwiusujjm .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#xlwiusujjm .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#xlwiusujjm .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#xlwiusujjm .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xlwiusujjm .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#xlwiusujjm .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#xlwiusujjm .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#xlwiusujjm .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#xlwiusujjm .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#xlwiusujjm .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xlwiusujjm .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#xlwiusujjm .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#xlwiusujjm .gt_left {
  text-align: left;
}
&#10;#xlwiusujjm .gt_center {
  text-align: center;
}
&#10;#xlwiusujjm .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#xlwiusujjm .gt_font_normal {
  font-weight: normal;
}
&#10;#xlwiusujjm .gt_font_bold {
  font-weight: bold;
}
&#10;#xlwiusujjm .gt_font_italic {
  font-style: italic;
}
&#10;#xlwiusujjm .gt_super {
  font-size: 65%;
}
&#10;#xlwiusujjm .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#xlwiusujjm .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#xlwiusujjm .gt_indent_1 {
  text-indent: 5px;
}
&#10;#xlwiusujjm .gt_indent_2 {
  text-indent: 10px;
}
&#10;#xlwiusujjm .gt_indent_3 {
  text-indent: 15px;
}
&#10;#xlwiusujjm .gt_indent_4 {
  text-indent: 20px;
}
&#10;#xlwiusujjm .gt_indent_5 {
  text-indent: 25px;
}
&#10;#xlwiusujjm .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#xlwiusujjm div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="variable">variable</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="n">n</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Placebo-(Group-A)">Placebo (Group A)</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Treatment-(Group-B)">Treatment (Group B)</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="normality">normality</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="test">test</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="p_value">p_value</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="variable" class="gt_row gt_left">sex</td>
<td headers="n" class="gt_row gt_left">A: 153, B: 147</td>
<td headers="Placebo (Group A)" class="gt_row gt_left">Male: 66 (43.1%); Female: 87 (56.9%)</td>
<td headers="Treatment (Group B)" class="gt_row gt_left">Male: 72 (49.0%); Female: 75 (51.0%)</td>
<td headers="normality" class="gt_row gt_left">NA</td>
<td headers="test" class="gt_row gt_left">Chi-squared</td>
<td headers="p_value" class="gt_row gt_left">0.310</td></tr>
    <tr><td headers="variable" class="gt_row gt_left">age</td>
<td headers="n" class="gt_row gt_left">A: 153, B: 147</td>
<td headers="Placebo (Group A)" class="gt_row gt_left">Median (IQR): 47.00 (24.00)</td>
<td headers="Treatment (Group B)" class="gt_row gt_left">Median (IQR): 50.00 (22.00)</td>
<td headers="normality" class="gt_row gt_left">A: 0.001, B: 0.002</td>
<td headers="test" class="gt_row gt_left">Mann-Whitney U</td>
<td headers="p_value" class="gt_row gt_left">0.392</td></tr>
    <tr><td headers="variable" class="gt_row gt_left">weight</td>
<td headers="n" class="gt_row gt_left">A: 153, B: 147</td>
<td headers="Placebo (Group A)" class="gt_row gt_left">Median (IQR): 70.00 (18.00)</td>
<td headers="Treatment (Group B)" class="gt_row gt_left">Median (IQR): 70.00 (24.85)</td>
<td headers="normality" class="gt_row gt_left">A: 0.002, B: 0.006</td>
<td headers="test" class="gt_row gt_left">Mann-Whitney U</td>
<td headers="p_value" class="gt_row gt_left">0.835</td></tr>
    <tr><td headers="variable" class="gt_row gt_left">biomarker</td>
<td headers="n" class="gt_row gt_left">A: 153, B: 147</td>
<td headers="Placebo (Group A)" class="gt_row gt_left">Mean (SD): 49.03 (9.96)</td>
<td headers="Treatment (Group B)" class="gt_row gt_left">Mean (SD): 46.42 (10.99)</td>
<td headers="normality" class="gt_row gt_left">A: 0.114, B: 0.101</td>
<td headers="test" class="gt_row gt_left">Welch t-test</td>
<td headers="p_value" class="gt_row gt_left">0.032</td></tr>
    <tr><td headers="variable" class="gt_row gt_left">response</td>
<td headers="n" class="gt_row gt_left">A: 153, B: 147</td>
<td headers="Placebo (Group A)" class="gt_row gt_left">Complete: 27 (17.6%); Partial: 42 (27.5%); None: 84 (54.9%)</td>
<td headers="Treatment (Group B)" class="gt_row gt_left">Complete: 57 (38.8%); Partial: 27 (18.4%); None: 63 (42.9%)</td>
<td headers="normality" class="gt_row gt_left">NA</td>
<td headers="test" class="gt_row gt_left">Chi-squared</td>
<td headers="p_value" class="gt_row gt_left">&lt; 0.001</td></tr>
  </tbody>
  &#10;  
</table>
</div>

``` r
# Grouped summary for each tratment group with all stats
clinical_summary <- summary_table(clinical_df,
                                  group_var = 'treatment',
                                  all_stats = TRUE,
                                  exclude = c('subject_id', 'visit'))

clinical_summary
```

<div id="lpcnqpadwi" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#lpcnqpadwi table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#lpcnqpadwi thead, #lpcnqpadwi tbody, #lpcnqpadwi tfoot, #lpcnqpadwi tr, #lpcnqpadwi td, #lpcnqpadwi th {
  border-style: none;
}
&#10;#lpcnqpadwi p {
  margin: 0;
  padding: 0;
}
&#10;#lpcnqpadwi .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#lpcnqpadwi .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#lpcnqpadwi .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#lpcnqpadwi .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#lpcnqpadwi .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#lpcnqpadwi .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#lpcnqpadwi .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#lpcnqpadwi .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#lpcnqpadwi .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#lpcnqpadwi .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#lpcnqpadwi .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#lpcnqpadwi .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#lpcnqpadwi .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#lpcnqpadwi .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#lpcnqpadwi .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#lpcnqpadwi .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#lpcnqpadwi .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#lpcnqpadwi .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#lpcnqpadwi .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#lpcnqpadwi .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#lpcnqpadwi .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#lpcnqpadwi .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#lpcnqpadwi .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#lpcnqpadwi .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#lpcnqpadwi .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#lpcnqpadwi .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#lpcnqpadwi .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#lpcnqpadwi .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#lpcnqpadwi .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#lpcnqpadwi .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#lpcnqpadwi .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#lpcnqpadwi .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#lpcnqpadwi .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#lpcnqpadwi .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#lpcnqpadwi .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#lpcnqpadwi .gt_left {
  text-align: left;
}
&#10;#lpcnqpadwi .gt_center {
  text-align: center;
}
&#10;#lpcnqpadwi .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#lpcnqpadwi .gt_font_normal {
  font-weight: normal;
}
&#10;#lpcnqpadwi .gt_font_bold {
  font-weight: bold;
}
&#10;#lpcnqpadwi .gt_font_italic {
  font-style: italic;
}
&#10;#lpcnqpadwi .gt_super {
  font-size: 65%;
}
&#10;#lpcnqpadwi .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#lpcnqpadwi .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#lpcnqpadwi .gt_indent_1 {
  text-indent: 5px;
}
&#10;#lpcnqpadwi .gt_indent_2 {
  text-indent: 10px;
}
&#10;#lpcnqpadwi .gt_indent_3 {
  text-indent: 15px;
}
&#10;#lpcnqpadwi .gt_indent_4 {
  text-indent: 20px;
}
&#10;#lpcnqpadwi .gt_indent_5 {
  text-indent: 25px;
}
&#10;#lpcnqpadwi .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#lpcnqpadwi div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="variable">variable</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="n">n</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Placebo-(Group-A)">Placebo (Group A)</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Treatment-(Group-B)">Treatment (Group B)</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="normality">normality</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="test">test</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="p_value">p_value</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="variable" class="gt_row gt_left">sex</td>
<td headers="n" class="gt_row gt_left">A: 153, B: 147</td>
<td headers="Placebo (Group A)" class="gt_row gt_left">Male: 66 (43.1%); Female: 87 (56.9%)</td>
<td headers="Treatment (Group B)" class="gt_row gt_left">Male: 72 (49.0%); Female: 75 (51.0%)</td>
<td headers="normality" class="gt_row gt_left">NA</td>
<td headers="test" class="gt_row gt_left">Chi-squared</td>
<td headers="p_value" class="gt_row gt_left">0.310</td></tr>
    <tr><td headers="variable" class="gt_row gt_left">age</td>
<td headers="n" class="gt_row gt_left">A: 153, B: 147</td>
<td headers="Placebo (Group A)" class="gt_row gt_left">Mean (SD): 45.27 (15.5); Median (IQR): 47.00 (34.0,58.0); Range: 18.00,79.00</td>
<td headers="Treatment (Group B)" class="gt_row gt_left">Mean (SD): 46.73 (15.8); Median (IQR): 50.00 (37.0,59.0); Range: 18.00,85.00</td>
<td headers="normality" class="gt_row gt_left">A: 0.001, B: 0.002</td>
<td headers="test" class="gt_row gt_left">Mann-Whitney U</td>
<td headers="p_value" class="gt_row gt_left">0.392</td></tr>
    <tr><td headers="variable" class="gt_row gt_left">weight</td>
<td headers="n" class="gt_row gt_left">A: 153, B: 147</td>
<td headers="Placebo (Group A)" class="gt_row gt_left">Mean (SD): 69.40 (15.3); Median (IQR): 70.00 (60.2,78.2); Range: 45.00,114.00</td>
<td headers="Treatment (Group B)" class="gt_row gt_left">Mean (SD): 69.72 (15.2); Median (IQR): 70.00 (57.5,82.3); Range: 45.00,105.50</td>
<td headers="normality" class="gt_row gt_left">A: 0.002, B: 0.006</td>
<td headers="test" class="gt_row gt_left">Mann-Whitney U</td>
<td headers="p_value" class="gt_row gt_left">0.835</td></tr>
    <tr><td headers="variable" class="gt_row gt_left">biomarker</td>
<td headers="n" class="gt_row gt_left">A: 153, B: 147</td>
<td headers="Placebo (Group A)" class="gt_row gt_left">Mean (SD): 49.03 (10.0); Median (IQR): 48.57 (42.9,54.9); Range: 22.42,77.47</td>
<td headers="Treatment (Group B)" class="gt_row gt_left">Mean (SD): 46.42 (11.0); Median (IQR): 45.54 (39.3,55.5); Range: 14.93,76.75</td>
<td headers="normality" class="gt_row gt_left">A: 0.114, B: 0.101</td>
<td headers="test" class="gt_row gt_left">Welch t-test</td>
<td headers="p_value" class="gt_row gt_left">0.032</td></tr>
    <tr><td headers="variable" class="gt_row gt_left">response</td>
<td headers="n" class="gt_row gt_left">A: 153, B: 147</td>
<td headers="Placebo (Group A)" class="gt_row gt_left">Complete: 27 (17.6%); Partial: 42 (27.5%); None: 84 (54.9%)</td>
<td headers="Treatment (Group B)" class="gt_row gt_left">Complete: 57 (38.8%); Partial: 27 (18.4%); None: 63 (42.9%)</td>
<td headers="normality" class="gt_row gt_left">NA</td>
<td headers="test" class="gt_row gt_left">Chi-squared</td>
<td headers="p_value" class="gt_row gt_left">&lt; 0.001</td></tr>
  </tbody>
  &#10;  
</table>
</div>

``` r
# Grouped summary for each tratment group with effect size
clinical_summary <- summary_table(clinical_df,
                                  group_var = 'treatment',
                                  effect_size = TRUE,
                                  exclude = c('subject_id', 'visit'))
clinical_summary
```

<div id="vgjsamomlw" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#vgjsamomlw table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
&#10;#vgjsamomlw thead, #vgjsamomlw tbody, #vgjsamomlw tfoot, #vgjsamomlw tr, #vgjsamomlw td, #vgjsamomlw th {
  border-style: none;
}
&#10;#vgjsamomlw p {
  margin: 0;
  padding: 0;
}
&#10;#vgjsamomlw .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}
&#10;#vgjsamomlw .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}
&#10;#vgjsamomlw .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}
&#10;#vgjsamomlw .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}
&#10;#vgjsamomlw .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#vgjsamomlw .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#vgjsamomlw .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}
&#10;#vgjsamomlw .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}
&#10;#vgjsamomlw .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}
&#10;#vgjsamomlw .gt_column_spanner_outer:first-child {
  padding-left: 0;
}
&#10;#vgjsamomlw .gt_column_spanner_outer:last-child {
  padding-right: 0;
}
&#10;#vgjsamomlw .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}
&#10;#vgjsamomlw .gt_spanner_row {
  border-bottom-style: hidden;
}
&#10;#vgjsamomlw .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}
&#10;#vgjsamomlw .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}
&#10;#vgjsamomlw .gt_from_md > :first-child {
  margin-top: 0;
}
&#10;#vgjsamomlw .gt_from_md > :last-child {
  margin-bottom: 0;
}
&#10;#vgjsamomlw .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}
&#10;#vgjsamomlw .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#vgjsamomlw .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}
&#10;#vgjsamomlw .gt_row_group_first td {
  border-top-width: 2px;
}
&#10;#vgjsamomlw .gt_row_group_first th {
  border-top-width: 2px;
}
&#10;#vgjsamomlw .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#vgjsamomlw .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}
&#10;#vgjsamomlw .gt_first_summary_row.thick {
  border-top-width: 2px;
}
&#10;#vgjsamomlw .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#vgjsamomlw .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#vgjsamomlw .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}
&#10;#vgjsamomlw .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}
&#10;#vgjsamomlw .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}
&#10;#vgjsamomlw .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}
&#10;#vgjsamomlw .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#vgjsamomlw .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#vgjsamomlw .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}
&#10;#vgjsamomlw .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}
&#10;#vgjsamomlw .gt_left {
  text-align: left;
}
&#10;#vgjsamomlw .gt_center {
  text-align: center;
}
&#10;#vgjsamomlw .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}
&#10;#vgjsamomlw .gt_font_normal {
  font-weight: normal;
}
&#10;#vgjsamomlw .gt_font_bold {
  font-weight: bold;
}
&#10;#vgjsamomlw .gt_font_italic {
  font-style: italic;
}
&#10;#vgjsamomlw .gt_super {
  font-size: 65%;
}
&#10;#vgjsamomlw .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}
&#10;#vgjsamomlw .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}
&#10;#vgjsamomlw .gt_indent_1 {
  text-indent: 5px;
}
&#10;#vgjsamomlw .gt_indent_2 {
  text-indent: 10px;
}
&#10;#vgjsamomlw .gt_indent_3 {
  text-indent: 15px;
}
&#10;#vgjsamomlw .gt_indent_4 {
  text-indent: 20px;
}
&#10;#vgjsamomlw .gt_indent_5 {
  text-indent: 25px;
}
&#10;#vgjsamomlw .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}
&#10;#vgjsamomlw div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="variable">variable</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="n">n</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Placebo-(Group-A)">Placebo (Group A)</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Treatment-(Group-B)">Treatment (Group B)</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="normality">normality</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="test">test</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="p_value">p_value</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="effect_size">effect_size</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="effect_param">effect_param</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="variable" class="gt_row gt_left">sex</td>
<td headers="n" class="gt_row gt_left">A: 153, B: 147</td>
<td headers="Placebo (Group A)" class="gt_row gt_left">Male: 66 (43.1%); Female: 87 (56.9%)</td>
<td headers="Treatment (Group B)" class="gt_row gt_left">Male: 72 (49.0%); Female: 75 (51.0%)</td>
<td headers="normality" class="gt_row gt_left">NA</td>
<td headers="test" class="gt_row gt_left">Chi-squared</td>
<td headers="p_value" class="gt_row gt_left">0.310</td>
<td headers="effect_size" class="gt_row gt_right">0.06</td>
<td headers="effect_param" class="gt_row gt_left">Cramer's V</td></tr>
    <tr><td headers="variable" class="gt_row gt_left">age</td>
<td headers="n" class="gt_row gt_left">A: 153, B: 147</td>
<td headers="Placebo (Group A)" class="gt_row gt_left">Median (IQR): 47.00 (24.00)</td>
<td headers="Treatment (Group B)" class="gt_row gt_left">Median (IQR): 50.00 (22.00)</td>
<td headers="normality" class="gt_row gt_left">A: 0.001, B: 0.002</td>
<td headers="test" class="gt_row gt_left">Mann-Whitney U</td>
<td headers="p_value" class="gt_row gt_left">0.392</td>
<td headers="effect_size" class="gt_row gt_right">0.96</td>
<td headers="effect_param" class="gt_row gt_left">r</td></tr>
    <tr><td headers="variable" class="gt_row gt_left">weight</td>
<td headers="n" class="gt_row gt_left">A: 153, B: 147</td>
<td headers="Placebo (Group A)" class="gt_row gt_left">Median (IQR): 70.00 (18.00)</td>
<td headers="Treatment (Group B)" class="gt_row gt_left">Median (IQR): 70.00 (24.85)</td>
<td headers="normality" class="gt_row gt_left">A: 0.002, B: 0.006</td>
<td headers="test" class="gt_row gt_left">Mann-Whitney U</td>
<td headers="p_value" class="gt_row gt_left">0.835</td>
<td headers="effect_size" class="gt_row gt_right">0.92</td>
<td headers="effect_param" class="gt_row gt_left">r</td></tr>
    <tr><td headers="variable" class="gt_row gt_left">biomarker</td>
<td headers="n" class="gt_row gt_left">A: 153, B: 147</td>
<td headers="Placebo (Group A)" class="gt_row gt_left">Mean (SD): 49.03 (9.96)</td>
<td headers="Treatment (Group B)" class="gt_row gt_left">Mean (SD): 46.42 (10.99)</td>
<td headers="normality" class="gt_row gt_left">A: 0.114, B: 0.101</td>
<td headers="test" class="gt_row gt_left">Welch t-test</td>
<td headers="p_value" class="gt_row gt_left">0.032</td>
<td headers="effect_size" class="gt_row gt_right">0.25</td>
<td headers="effect_param" class="gt_row gt_left">Cohen's d</td></tr>
    <tr><td headers="variable" class="gt_row gt_left">response</td>
<td headers="n" class="gt_row gt_left">A: 153, B: 147</td>
<td headers="Placebo (Group A)" class="gt_row gt_left">Complete: 27 (17.6%); Partial: 42 (27.5%); None: 84 (54.9%)</td>
<td headers="Treatment (Group B)" class="gt_row gt_left">Complete: 57 (38.8%); Partial: 27 (18.4%); None: 63 (42.9%)</td>
<td headers="normality" class="gt_row gt_left">NA</td>
<td headers="test" class="gt_row gt_left">Chi-squared</td>
<td headers="p_value" class="gt_row gt_left">&lt; 0.001</td>
<td headers="effect_size" class="gt_row gt_right">0.24</td>
<td headers="effect_param" class="gt_row gt_left">Cramer's V</td></tr>
  </tbody>
  &#10;  
</table>
</div>

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
#> mean (SD) = 48.51 (10.1) 
#> median (IQR) = 48.25 (13.6) 
#> 
#> Shapiro-Wilk: W = 0.996, p = 0.597 
#> Skewness: 0.01 
#> Kurtosis: -0.34 
#> 
#> Data is normally distributed.
```

<img src="man/figures/README-unnamed-chunk-9-1.png" width="100%" />

``` r

# Non-normal distribution with outliers displayed
normality("weight", data = clinical_df, outliers = TRUE)
#> 
#> Normality Test for 'weight' 
#> 
#> n = 300 
#> mean (SD) = 67.44 (15.3) 
#> median (IQR) = 67.35 (20.4) 
#> 
#> Shapiro-Wilk: W = 0.963, p = < 0.001 
#> Skewness: 0.47 
#> Kurtosis: -0.03 
#> 
#> Data is not normally distributed. 
#> 
#> OUTLIERS (row indices): 44, 79, 80, 81, 85, 87, 127, 128, 129, 139, 140, 141, 181, 291, 278, 247, 249, 142, 262, 177, 176
```

<img src="man/figures/README-unnamed-chunk-9-2.png" width="100%" />

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

<img src="man/figures/README-unnamed-chunk-10-1.png" width="100%" />

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

<img src="man/figures/README-unnamed-chunk-10-2.png" width="100%" />

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
#> Bounds: [20.82, 75.52]
#> Outliers detected: 7 (0.8%)
#> 
#> Outlier indices: 230, 271, 289, 603, 702, 723, 870
```

<img src="man/figures/README-unnamed-chunk-11-1.png" width="100%" />

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

<img src="man/figures/README-unnamed-chunk-15-1.png" width="75%" />

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

<img src="man/figures/README-unnamed-chunk-17-1.png" width="75%" />

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

<img src="man/figures/README-unnamed-chunk-22-1.png" width="75%" />

``` r

# Grouped barplot of categorical variable by treatment with value labels
plot_bar(clinical_df, 
         x = "response", 
         group = "visit", 
         facet = "treatment", 
         title = "Response by visit and treatment",
         values = TRUE)
```

<img src="man/figures/README-unnamed-chunk-22-2.png" width="75%" />

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

<img src="man/figures/README-unnamed-chunk-23-1.png" width="100%" />

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

<img src="man/figures/README-unnamed-chunk-24-1.png" width="100%" />

``` r

# Faceted histogram
plot_hist(clinical_df, x = "biomarker", facet = "treatment")
```

<img src="man/figures/README-unnamed-chunk-24-2.png" width="100%" />

#### **plot_box()**

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
