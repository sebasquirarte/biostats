# Changelog

## biostats 1.1.2

CRAN release: 2026-03-05

### Bug fixes

- [`sample_size()`](../reference/sample_size.md): corrected dropout
  adjustment from approximate formula `n * (1 + dropout)` to exact
  formula `n / (1 - dropout)`, preventing underpowered enrollment at
  higher dropout rates.

------------------------------------------------------------------------

## biostats 1.1.1

CRAN release: 2025-12-16

### Improvements

- Minor change to sample_size function for better readability.

------------------------------------------------------------------------

## biostats 1.1.0

CRAN release: 2025-12-06

### New Features

- Implemented Lilliefors correction for Kolmogorov-Smirnov normality
  tests in both [`normality()`](../reference/normality.md) and
  [`summary_table()`](../reference/summary_table.md) functions. The
  Lilliefors test provides more accurate p-values when distribution
  parameters are estimated from sample data.

### Improvements

- Enhanced p-value formatting to display “p \< 0.001” instead of “p = \<
  0.001”
- Added methodological references: Lilliefors (1967) and Dallal &
  Wilkinson (1986)
- Updated documentation to clarify that K-S option now uses Lilliefors
  correction

### Dependencies

- Added `nortest` package to Imports

------------------------------------------------------------------------

## biostats 1.0.0

CRAN release: 2025-11-13

- Initial CRAN submission.
