# Summary Table with Optional Group Comparisons

Generates a summary table for biostatistics and clinical data analysis
with automatic normality, effect size, and statistical test
calculations. Handles both numeric and categorical variables, performing
appropriate descriptive statistics and inferential tests for
single-group summaries or two-group comparisons.

## Usage

``` r
summary_table(
  data,
  group_by = NULL,
  normality_test = "S-W",
  all = FALSE,
  effect_size = FALSE,
  exclude = NULL
)
```

## Arguments

- data:

  Dataframe containing the variables to be summarized.

- group_by:

  Character string indicating the name of the grouping variable for
  two-group comparisons. Default: NULL.

- normality_test:

  Character string indicating the normality test to use: 'S-W' for
  Shapiro-Wilk or 'K-S' for Kolmogorov-Smirnov with Lilliefors'
  correction. Default: 'S-W'.

- all:

  Logical parameter that shows all calculated statistics. Default:
  FALSE.

- effect_size:

  Logical parameter that includes effect size estimates. Default: FALSE.

- exclude:

  Character vector of variable names to exclude from the summary.
  Default: NULL.

## Value

A gt table object with formatted summary statistics.

## Examples

``` r
# Simulated clinical data
clinical_df <- clinical_data()

# Overall summary without considering treatment groups
summary_table(clinical_df,
              exclude = c('participant_id', 'visit'))


  







variable
```
