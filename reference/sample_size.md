# Sample Size Calculation for Clinical Trials

Calculates the sample size needed in a clinical trial based on study
design and statistical parameters using standard formulas for hypothesis
testing (Chow, S. 2017).

## Usage

``` r
sample_size(
  sample = c("one-sample", "two-sample"),
  design = NULL,
  outcome = c("mean", "proportion"),
  type = c("equality", "equivalence", "non-inferiority", "superiority"),
  alpha = 0.05,
  beta = 0.2,
  x1 = NULL,
  x2 = NULL,
  SD = NULL,
  delta = NULL,
  dropout = 0,
  k = 1
)

# S3 method for class 'sample_size'
print(x, ...)
```

## Arguments

- sample:

  Character string indicating whether one or two samples need to be
  calculated. Options: "one-sample" or "two-sample".

- design:

  Character string indicating study design when sample = "two-sample".
  Options: "parallel" or "crossover". Default: NULL for one-sample
  tests.

- outcome:

  Character string indicating the type of outcome variable. Options:
  "mean" or "proportion".

- type:

  Character string indicating the type of hypothesis test. Options:
  "equality", "equivalence", "non-inferiority", or "superiority".

- alpha:

  Numeric parameter indicating the Type I error rate (significance
  level). Default: 0.05.

- beta:

  Numeric parameter indicating the Type II error rate (1 - power).
  Default: 0.20.

- x1:

  Numeric value of the mean or proportion for group 1 (treatment group).

- x2:

  Numeric value of the mean or proportion for group 2 (control group or
  reference value).

- SD:

  Numeric value indicating the standard deviation. Required for mean
  outcomes and crossover designs with proportion outcomes. Default:
  NULL.

- delta:

  Numeric value indicating the margin of clinical interest. Required for
  non-equality tests. Must be negative for non-inferiority and positive
  for superiority/equivalence. Default: NULL.

- dropout:

  Numeric value indicating the discontinuation rate expected in the
  study. Must be between 0 and 1. Default: 0.

- k:

  Numeric value indicating the allocation ratio (n1/n2) for two-sample
  tests. Default: 1.

- x:

  An object of class "sample_size".

- ...:

  Further arguments passed to or from other methods.

## Value

An object of class "sample_size" containing the calculated sample size
and study parameters.

## Methods (by generic)

- `print(sample_size)`: Print method for objects of class "sample_size".

## References

Chow, S.-C., Shao, J., Wang, H., & Lokhnygina, Y. (2017). Sample Size
Calculations in Clinical Research (3rd ed.). Chapman and Hall/CRC.
https://doi.org/10.1201/9781315183084

## Examples

``` r
# Two-sample parallel non-inferiority test for means with 10% expected dropout
sample_size(sample = 'two-sample', design = 'parallel', outcome = 'mean',
            type = 'non-inferiority', x1 = 5.0, x2 = 5.0, 
            SD = 0.1, delta = -0.05, k = 1, dropout = 0.1)
#> 
#> Sample Size Calculation
#> 
#> Test type: non-inferiority
#> Design: parallel, two-sample
#> Outcome: mean
#> Alpha (α): 0.050
#> Beta (β): 0.200
#> Power: 80.0%
#> 
#> Parameters:
#> x1 (treatment): 5.000
#> x2 (control/reference): 5.000
#> Difference (x1 - x2): 0.000
#> Standard Deviation (σ): 0.100
#> Allocation Ratio (k): 1.00
#> Delta (δ): -0.050
#> Dropout rate: 10.0%
#> 
#> Required Sample Size
#> n1 = 56
#> n2 = 56
#> Total = 112
#> 
#> Note: Sample size increased by 10.0% to account for potential dropouts.
#> 
            
# One-sample equivalence test for means
sample_size(sample = "one-sample", outcome = "mean", type = "equivalence",
            x1 = 0, x2 = 0, SD = 0.1, delta = 0.05)
#> 
#> Sample Size Calculation
#> 
#> Test type: equivalence
#> Design: one-sample
#> Outcome: mean
#> Alpha (α): 0.050
#> Beta (β): 0.200
#> Power: 80.0%
#> 
#> Parameters:
#> x1 (treatment): 0.000
#> x2 (control/reference): 0.000
#> Difference (x1 - x2): 0.000
#> Standard Deviation (σ): 0.100
#> Delta (δ): 0.050
#> 
#> Required Sample Size
#> n = 35
#> Total = 35
#> 
```
