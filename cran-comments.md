## biostats 1.1.0 – CRAN submission

### R CMD check results
0 errors | 0 warnings | 0 notes

### Changes in this version (1.1.0)

#### New Features
* Implemented Lilliefors correction for Kolmogorov–Smirnov normality testing in both `normality()` and `summary_table()` functions. This provides more accurate p-values when normal distribution parameters are estimated from sample data.

#### Improvements
* Improved p-value formatting to use `"p < 0.001"` instead of `"p = < 0.001"`.
* Added methodological references: Lilliefors (1967) and Dallal & Wilkinson (1986).
* Updated documentation to clarify that the K-S option now uses the Lilliefors correction.

#### Dependencies
* Added `nortest` to Imports.

### Notes to CRAN
* This is a minor update adding Lilliefors correction functionality and documentation refinements. No breaking changes were introduced.
