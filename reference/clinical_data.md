# Simulate Simple Clinical Trial Data

Creates a simple simulated clinical trial dataset with participant
demographics, multiple visits, treatment groups with different effects,
numerical and categorical variables, as well as optional missing data
and dropout rates.

## Usage

``` r
clinical_data(
  n = 100,
  visits = 3,
  arms = c("Placebo", "Treatment"),
  dropout = 0,
  missing = 0
)
```

## Arguments

- n:

  Integer indicating the number (1-999) of participants. Default: 100.

- visits:

  Integer indicating the number of visits including baseline. Default:
  3.

- arms:

  Character vector of treatment arm names. Default: c("Placebo",
  "Treatment").

- dropout:

  Numeric parameter indicating the proportion (0-1) of participants. who
  dropout. Default: 0.

- missing:

  Numeric parameter indicating the proportion (0-1) of missing values to
  be introduced across numeric variables with fixed proportions
  (biomarker = 15%, weight = 25%, response = 60%). Default: 0.

## Value

Dataframe with columns: participant_id, visit, sex, treatment, age,
weight, biomarker, and response in long format.

## Examples

``` r
# Basic dataset
clinical_df <- clinical_data()

# Multiple treatment arms with dropout rate and missing data
clinical_df <- clinical_data(arms = c('Placebo', 'A', 'B'), missing = 0.05, dropout = 0.10)
```
