# Contributing to biostats

Thank you for your interest in contributing to biostats. This document outlines the recommended workflow and standards 
for contributing code, documentation, or suggestions. The goal is to maintain a consistent, high-quality package 
that supports clinical research and biostatistical analysis.

## Reporting Issues

If you find a bug or notice inconsistent behavior: 
- Open an issue on GitHub.
- Provide a concise description.
- Include a minimal [reproducible example](https://tidyverse.org/help/#reprex).

Small documentation corrections (typos, formatting, examples) may be
submitted directly through GitHub's web interface by editting the related .R file in the R/ folder. 

## Feature Requests

Before proposing a new function or enhancement: 

- Check whether similar functionality already exists.
- Open an issue describing the use case, expected behavior, and rationale.

Discussions help ensure consistency with clinical workflows, statistical methods, and the package structure.

## Pull Requests

### Workflow:

1.  Fork the repository and create a dedicated branch.
2.  Implement changes following the package's style and structure.
3.  Document all exported functions using roxygen2.
4.  Add or update tests using testthat.
5.  Run:

```r
devtools::document()
devtools::check()
```
7.  Submit a pull request with a clear summary of changes.

### Coding Style:

-   Use clear, consistent, and readable R code. We recommend the [tidyverse style guide](https://style.tidyverse.org/).
-   Choose informative names.
-   Maintain consistency across visualization and statistical tools.

## Code of Conduct

Contributions should be respectful, professional, and aligned with the
goal of producing robust and reliable tools for the clinical research
community.

For any questions about contributing, please open an issue on GitHub.
