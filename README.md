
<!-- README.md is generated from README.Rmd. Please edit that file -->

# biostats <a href="https://sebasquirarte.github.io/biostats/"><img src="man/figures/logo.png" align="right" height="120" alt="biostats_logo" /></a>

<!-- badges: start -->

![CRAN status](https://www.r-pkg.org/badges/version/biostats)
[![R-CMD-check](https://github.com/sebasquirarte/biostats/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/sebasquirarte/biostats/actions/workflows/R-CMD-check.yml)
[![codecov](https://codecov.io/gh/sebasquirarte/biostats/branch/main/graph/badge.svg)](https://app.codecov.io/gh/sebasquirarte/biostats)
[![status](https://joss.theoj.org/papers/bb1fafdfe2c83e989a3f1578d2e50dc1/status.svg)](https://joss.theoj.org/papers/bb1fafdfe2c83e989a3f1578d2e50dc1)
[![Total
Downloads](https://cranlogs.r-pkg.org/badges/grand-total/biostats)](https://cranlogs.r-pkg.org/)

<!-- badges: end -->

## Overview

***biostats*** is an R package that functions as a toolbox to aid in
biostatistics and clinical data analysis tasks and workflows.

#### Key features

- Descriptive statistics and exploratory data analysis
- Sample size and power calculation
- Statistical analysis and inference
- Data visualization

Designed primarily for comparative clinical studies, trial planning, and
analysis, this package serves both as an analytical toolkit for
professional biostatisticians and clinical data analysts and as an
educational resource for researchers transitioning to R-based
biostatistics, including professionals from other domains, clinical
research professionals, and medical practitioners involved in the
development of clinical trials.

*Developed by the biostatistics team at [Laboratorios Sophia S.A. de
C.V.](https://sophialab.com/en/)*

## Installation

``` r
# Install latest CRAN release:
install.packages("biostats") 

# Or install developer version from GitHub:
#install.packages("pak")
pak::pak("sebasquirarte/biostats")
```

## Usage

``` r
library(biostats)
```

## Documentation

Online documentation for this package is available
[here](https://sebasquirarte.github.io/biostats/articles/biostats.html).

## Citation

If you use ***biostats*** in your research, please cite our JOSS paper:

> Quirarte-Justo et al., (2026). biostats: Biostatistics and Clinical
> Data Analysis in R. Journal of Open Source Software, 11(122), 10317,
> <https://doi.org/10.21105/joss.10317>

``` bibtex
@article{Quirarte-Justo2026, 
  doi = {10.21105/joss.10317}, 
  url = {https://doi.org/10.21105/joss.10317}, 
  year = {2026}, 
  publisher = {The Open Journal}, 
  volume = {11}, 
  number = {122}, 
  pages = {10317}, 
  author = {Quirarte-Justo, Sebastian and Montaño-Ruiz, Angela Carolina and Torres-Arellano, José M.}, 
  title = {biostats: Biostatistics and Clinical Data Analysis in R}, 
  journal = {Journal of Open Source Software} 
}
```

## Feedback

We welcome feedback, suggestions, and bug reports. You can share your
thoughts via email (<sebastian.quirarte@sophia.com.mx>) or [GitHub
issues](https://github.com/sebasquirarte/biostats/issues).
