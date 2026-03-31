# Effect Measures

Calculates measures of effect: Odds Ratio (OR), Risk Ratio (RR), and
either Number Needed to Treat (NNT) or Number Needed to Harm (NNH).

## Usage

``` r
effect_measures(
  exposed_event,
  exposed_no_event,
  unexposed_event,
  unexposed_no_event,
  alpha = 0.05,
  correction = TRUE
)

# S3 method for class 'effect_measures'
print(x, ...)
```

## Arguments

- exposed_event:

  Numeric value indicating the number of events in the exposed group.

- exposed_no_event:

  Numeric value indicating the number of non-events in the exposed
  group.

- unexposed_event:

  Numeric value indicating the number of events in the unexposed group.

- unexposed_no_event:

  Numeric value indicating the number of non-events in the unexposed
  group.

- alpha:

  Numeric value between 0 and 1 specifying the alpha level for
  confidence intervals (CI). Default: 0.05.

- correction:

  Logical parameter that indicates whether a continuity correction (0.5)
  will be applied when any cell contains 0. Default: TRUE.

- x:

  An object of class "effect_measures".

- ...:

  Further arguments passed to or from other methods.

## Value

An object of class "effect_measures" containing the contingency table,
effect size estimates (OR, RR, risk difference, NNT/NNH), and related
statistics.

## Methods (by generic)

- `print(effect_measures)`: Print method for objects of class
  "effect_measures".

## Examples

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
#> 
```
