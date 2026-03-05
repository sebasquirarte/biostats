## biostats 1.1.2 – CRAN submission

### R CMD check results
0 errors | 0 warnings | 0 notes

### Changes in this version (1.1.2)

#### New Features
* Fixed dropout adjustment formula in `sample_size()`.
  The previous implementation used `n * (1 + dropout)`, a first-order
  approximation that underestimates required enrollment at higher dropout
  rates. The correct formula `n / (1 - dropout)` is now used, consistent
  with Chow et al. (2017) and ICH E9 guidelines.

### Notes to CRAN
* This is a minor update fixing the dropout formula in the sample_size() function. No breaking changes were introduced.
