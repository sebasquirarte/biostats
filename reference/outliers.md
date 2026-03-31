# Descriptive and Visual Outlier Assessment

Identifies outliers using Tukey's interquartile range (IQR) method and
provides descriptive statistics and visualizations for outlier
assessment in numeric data.

## Usage

``` r
outliers(data, x, threshold = 1.5, color = "#79E1BE")
```

## Arguments

- data:

  Dataframe containing the variables to be analyzed.

- x:

  Character string indicating the variable to be analyzed.

- threshold:

  Numeric value multiplying the IQR to define outlier boundaries.
  Default: 1.5.

- color:

  Character string indicating the color for non-outlier data points.
  Default: "#79E1BE".

## Value

An object of class "outliers" containing a list with outlier statistics
and ggplot objects.

## Examples

``` r
# Simulated clinical data
clinical_df <- clinical_data()

# Basic outlier detection
outliers(clinical_df, "biomarker")
#> 
#> Outlier Analysis
#> 
#> Variable: 'biomarker'
#> n: 300
#> Missing: 0 (0.0%)
#> Method: Tukey's IQR x 1.5
#> Bounds: [22.406, 73.656]
#> Outliers detected: 3 (1.0%)
#> 
#> Outlier indices: 16, 181, 228
#> 


# Using custom threshold
outliers(clinical_df, "biomarker", threshold = 1.0)
#> 
#> Outlier Analysis
#> 
#> Variable: 'biomarker'
#> n: 300
#> Missing: 0 (0.0%)
#> Method: Tukey's IQR x 1.0
#> Bounds: [28.812, 67.250]
#> Outliers detected: 18 (6.0%)
#> 
#> Outlier indices: 4, 12, 16, 48, 52, 87, 120, 142, 146, 155, 156, 175, 178, 181, 182, 213, 228, 295
#> 

```
