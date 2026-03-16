# biostats 1.1.2

## Bug fixes

* `sample_size()`: corrected dropout adjustment from approximate formula
  `n * (1 + dropout)` to exact formula `n / (1 - dropout)`, preventing
  underpowered enrollment at higher dropout rates.

---

# biostats 1.1.1

## Improvements

* Minor change to sample_size function for better readability. 

---

# biostats 1.1.0

## New Features

* Implemented Lilliefors correction for Kolmogorov-Smirnov normality tests in both `normality()` and `summary_table()` functions. The Lilliefors test provides more accurate p-values when distribution parameters are estimated from sample data.

## Improvements

* Enhanced p-value formatting to display "p < 0.001" instead of "p = < 0.001"
* Added methodological references: Lilliefors (1967) and Dallal & Wilkinson (1986)
* Updated documentation to clarify that K-S option now uses Lilliefors correction

## Dependencies

* Added `nortest` package to Imports

---

# biostats 1.0.0

* Initial CRAN submission.
