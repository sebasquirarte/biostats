# Omnibus Tests for Comparing Three or More Groups

Performs omnibus tests to evaluate overall differences between three or
more groups. Automatically selects the appropriate statistical test
based on data characteristics and assumption testing. Supports both
independent groups and repeated measures designs. Tests include one-way
ANOVA, repeated measures ANOVA, Kruskal-Wallis test, and Friedman test.
Performs comprehensive assumption checking (normality, homogeneity of
variance, sphericity) and post-hoc testing when significant results are
detected.

## Usage

``` r
omnibus(
  data,
  y,
  x,
  paired_by = NULL,
  alpha = 0.05,
  p_method = "holm",
  na.action = "na.omit"
)

# S3 method for class 'omnibus'
print(x, ...)
```

## Arguments

- data:

  Dataframe containing the variables to be analyzed. Data must be in
  long format with one row per observation.

- y:

  Character string indicating the dependent variable (outcome).

- x:

  An object of class "omnibus".

- paired_by:

  Character string indicating the source of repeated measurements. If
  provided, a repeated measures design is assumed. If NULL, independent
  groups design is assumed. Default: NULL.

- alpha:

  Numeric value indicating the significance level for hypothesis tests.
  Default: 0.05.

- p_method:

  Character string indicating the method for p-value adjustment in
  post-hoc multiple comparisons to control for Type I error inflation.
  Options: "holm" (Holm), "hochberg" (Hochberg), "hommel" (Hommel),
  "bonferroni" (Bonferroni), "BH" (Benjamini-Hochberg), "BY"
  (Benjamini-Yekutieli), "none" (no adjustment). Default: "holm".

- na.action:

  Character string indicating the action to take if NAs are present
  ("na.omit" or "na.exclude"). Default: "na.omit"

- ...:

  Further arguments passed to or from other methods.

## Value

An object of class "omnibus" containing the formula, statistic summary,
name of the test performed, value of the test statistic, p value, alpha,
the results of the post-hoc test and assumptions, the sample size's
coefficient of variance, and corresponding degrees of freedom.

## Methods (by generic)

- `print(omnibus)`: Print method for objects of class "omnibus".

## References

Blanca, M., Alarcón, R., Arnau, J. et al. Effect of variance ratio on
ANOVA robustness: Might 1.5 be the limit?. Behav Res. 2017 Jun 22;
50:937–962. https://doi.org/10.3758/s13428-017-0918-2 Field, A., Miles,
J., & Field, Z. (2012). Discovering Statistics Using R. London: SAGE
Publications.

## Examples

``` r
# Simulated clinical data with multiple treatment arms and visits
clinical_df <- clinical_data(n = 300, visits = 6, arms = c("A", "B", "C"))

# Compare numerical variable across treatments
omnibus(data = clinical_df, y = "biomarker", x = "treatment")
#> 
#> Omnibus Test: One-way ANOVA
#> 
#> Assumption Testing Results:
#> 
#>   Normality (Shapiro-Wilk Test):
#>   A: W = 0.9976, p = 0.571
#>   B: W = 0.9974, p = 0.633
#>   C: W = 0.9980, p = 0.556
#>   Overall result: Normal distribution assumed.
#> 
#>   Homogeneity of Variance (Bartlett Test):
#>   Chi-squared(2) = 0.7143, p = 0.700
#>   Effect size (Cramer's V) = 0.0141
#>   Result: Homogeneous variances.
#> 
#> Test Results:
#>   Formula: biomarker ~ treatment
#>   alpha: 0.05
#>   Result: significant (p = <0.001)
#> 
#> Post-hoc Multiple Comparisons
#> 
#>   Tukey Honest Significant Differences (alpha: 0.050):
#>   Comparison               Diff    Lower    Upper    p-adj
#>   --------------------------------------------------------- 
#>   B - A                  -1.982   -3.368   -0.596    0.002*
#>   C - A                  -5.698   -6.966   -4.430   <0.001*
#>   C - B                  -3.716   -5.045   -2.387   <0.001*
#> 
#> The study groups show a moderately imbalanced distribution of sample sizes (Δn = 0.206).
#> 

# Filter simulated data to just one treatment
clinical_df_A <- clinical_df[clinical_df$treatment == "A", ]

# Compare numerical variable changes across visits 
omnibus(y = "biomarker", x = "visit", data = clinical_df_A, paired_by = "participant_id")
#> 
#> Omnibus Test: Repeated measures ANOVA
#> 
#> Assumption Testing Results:
#> 
#>   Sphericity (Mauchly Test):
#>   W = 0.8528, p = 0.368
#>   Result: Sphericity assumed.
#> 
#>   Normality (Shapiro-Wilk Test):
#>   1: W = 0.9815, p = 0.183
#>   2: W = 0.9803, p = 0.150
#>   3: W = 0.9787, p = 0.113
#>   4: W = 0.9943, p = 0.956
#>   5: W = 0.9890, p = 0.602
#>   6: W = 0.9880, p = 0.519
#>   Overall result: Normal distribution assumed.
#> 
#>   Homogeneity of Variance (Bartlett Test):
#>   Chi-squared(5) = 2.7023, p = 0.746
#>   Effect size (Cramer's V) = 0.0303
#>   Result: Homogeneous variances.
#> 
#> Test Results:
#>   Formula: biomarker ~ visit + Error(participant_id/visit)
#>   alpha: 0.05
#>   Result: not significant (p = 0.344)
#> Post-hoc tests not performed (results not significant).
#> 
#> The study groups show a moderately imbalanced distribution of sample sizes (Δn = 0.199).
#> 
```
