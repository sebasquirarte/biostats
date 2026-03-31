# Create Simple Professional Correlation Matrix Plots

Generates publication-ready correlation matrix heatmaps with minimal
code using ggplot2.

## Usage

``` r
plot_corr(
  data,
  vars = NULL,
  method = c("pearson", "spearman"),
  type = c("full", "upper", "lower"),
  colors = NULL,
  title = NULL,
  show_values = TRUE,
  value_size = 3,
  show_sig = FALSE,
  sig_level = 0.05,
  sig_only = FALSE,
  show_legend = TRUE,
  p_method = "holm"
)
```

## Arguments

- data:

  A dataframe containing the variables to analyze.

- vars:

  Character vector specifying which variables to include. Default: NULL.

- method:

  Character string specifying correlation method: "pearson" or
  "spearman". Default: "pearson".

- type:

  Character string specifying matrix type: "full", "upper", or "lower".
  Default: "full".

- colors:

  Character vector of 3 colors for negative, neutral, and positive
  correlations. Default: NULL.

- title:

  Character string for plot title. Default: NULL.

- show_values:

  Logical parameter indicating whether to display correlation values in
  cells. Default: TRUE.

- value_size:

  Numeric value indicating size of correlation value text. Default: 3.

- show_sig:

  Logical parameter indicating whether to mark significant correlations.
  Default: FALSE.

- sig_level:

  Numeric value indicating significance level for marking. Default:
  0.05.

- sig_only:

  Logical parameter indicating whether to show only statistically
  significant values. Default: FALSE.

- show_legend:

  Logical parameter indicating whether to show legend. Default: TRUE.

- p_method:

  Character string specifying the method for p-value adjustment to
  control for multiple comparisons in correlation testing. Options:
  "holm" (Holm), "hochberg" (Hochberg), "hommel" (Hommel), "bonferroni"
  (Bonferroni), "BH" (Benjamini-Hochberg), "BY" (Benjamini-Yekutieli),
  or "none" (no adjustment). Default: "holm".

## Value

A ggplot2 object

## Examples

``` r
# Correlation matrix for base R dataset 'swiss'
plot_corr(data = swiss)


# Lower triangle with significance indicators and filtering
plot_corr(data = swiss, type = "lower", show_sig = TRUE, sig_only = TRUE)

```
