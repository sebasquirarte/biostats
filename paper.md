---
title: 'biostats: Biostatistics and Clinical Data Analysis in R'
tags:
  - R
  - biostatistics
  - clinical trials
  - clinical research
  - data analysis
authors:
  - name: Sebastian Quirarte-Justo
    corresponding: true
    orcid: 0009-0004-2730-4343
    affiliation: 1
  - name: Angela Carolina Montaño-Ruiz
    orcid: 0009-0009-1705-763X
    affiliation: 1
  - name: José M. Torres-Arellano
    orcid: 0000-0003-4632-2243
    affiliation: 1
affiliations:
 - name: Laboratorios Sophia, S.A. de C.V., Jalisco, Mexico.
   index: 1
date: 22 January 2026
bibliography: paper.bib
---

# Summary


![](figures/logo.png)


_**biostats**_ is an R package (R Core Team, 2025) that provides a unified set of 
tools for biostatistics and clinical data analysis tasks and workflows. It 
includes 14 specialized functions for descriptive statistics and exploratory 
data analysis, sample size and power calculation, statistical analysis and 
inference, and data visualization. 

Designed primarily for comparative clinical studies, trial planning, and 
analysis, this package serves both as an analytical toolkit for professional 
biostatisticians and clinical data analysts, and as an educational resource for 
researchers transitioning to R-based biostatistics, including professionals from
other domains, clinical researchers, and medical practitioners involved in the
development of clinical trials. 

_**biostats**_ is available on the Comprehensive R Archive Network (CRAN) and 
adheres to CRAN standards for documentation, testing, reproducibility, and 
long-term maintainability within the R ecosystem.

![Functions included in the biostats package.](figures/figure1.png)

# Statement of need

Biostatistics is a fundamental component of clinical research, essential for 
validating trial designs, methodologies, results, conclusions, as well as 
supporting submission to regulatory entities (Sagar KP et al., 2023; Ciolino, 
J. D. et al., 2021; Dwivedi A. K., 2022). In practice, clinical data analysis 
involves the execution of similar tasks across multiple studies and projects. 
Typical workflows include the calculation of descriptive statistics and 
exploratory data analysis, assumption validation, hypothesis testing, primary, 
secondary, and exploratory statistical analyses, effect size estimation, as well
as sample size and power calculations.

Popular packages in this field include Hmisc (Harrell Jr F., 2025) and tableone 
(Yoshida K. & Bartel A., 2022) for descriptive statistics, pwr 
(Champely S., 2020) for power and sample size calculations, effectsize 
(Ben-Shachar M. et al., 2020) for effect size estimates, and ggplot2 
(Wickham H. et al, 2016) for data visualization, among others. While these 
packages are well-designed and widely used, completing a clinical study workflow
typically requires combining multiple packages with different syntax conventions
, output formats, and integration patterns. As a result, analysts frequently 
develop custom code to connect results, automate recurring tasks, or standardize
outputs across studies. This fragmentation can lead to inconsistent 
implementations, duplicated effort, and increased time spent on code development
, validation, and quality control.

The biostats package addresses these challenges by providing a unified, 
clinically oriented framework that consolidates commonly used biostatistical 
procedures into a single, coherent toolkit. While users still retain full 
flexibility to write custom code tailored to study-specific needs, biostats is 
designed to streamline repetitive and foundational tasks in biostatistics and 
clinical data analysis through consistent syntax, harmonized outputs, and 
functions that reflect standard clinical workflows. Its goal is to deliver a 
professional-grade toolset for biostatisticians and clinical researchers while 
remaining accessible to data analysts from other fields. In addition, biostats 
serves as an educational resource for users transitioning to R or to 
biostatistics, offering a structured and reproducible approach aligned with 
contemporary recommendations for transparent and rigorous statistical practice.


# Software design

`Gala`'s design philosophy is based on three core principles: (1) to provide a
 user-friendly, modular, object-oriented API, (2) to use community tools and 
 standards (e.g., Astropy for coordinates and units handling), and (3) to use
 low-level code (C/C++/Cython) for performance while keeping the user interface
 in Python. Within each of the main subpackages in `gala` (`gala.potential`, 
 `gala.dynamics`, `gala.integrate`, etc.), we try to maintain a consistent API 
 for classes and functions. For example, all potential classes share a common 
 base class and implement methods for computing the potential, forces, density, 
 and other derived quantities at given positions. This also works for 
 compositions of potentials (i.e., multi-component potential models), which 
 share the potential base class but also act as a dictionary-like container for 
 different potential components. As another example, all integrators implement a 
 common interface for numerically integrating orbits. The integrators and core 
 potential functions are all implemented in C without support for units, but the 
 Python layer handles unit conversions and prepares data to dispatch to the C 
 layer appropriately.Within the coordinates subpackage, we extend Astropy's 
 coordinate classes to add more specialized coordinate frames and 
 transformations that are relevant for Galactic dynamics and Milky Way research.

# Research impact statement

`Gala` has demonstrated significant research impact and grown both its user base 
and contributor community since its initial release. The package has evolved 
through contributions from over 18 developers beyond the original core developer 
(@adrn), with community members adding new features, reporting bugs, and 
suggesting new features. 

While `Gala` started as a tool primarily to support the core developer's 
research, it has expanded organically to support a range of applications across 
domains in astrophysics related to Milky Way and galactic dynamics. The package 
has been used in over 400 publications (according to Google Scholar) spanning 
topics in galactic dynamics such as modeling stellar streams [@Pearson:2017], 
Milky Way mass modeling, and interpreting kinematic and stellar population 
trends in the Galaxy. `Gala` is integrated within the Astropy ecosystem as an 
affiliated package and has built functionality that extends the widely-used 
`astropy.units` and `astropy.coordinates` subpackages. `Gala`'s impact extends 
beyond citations in research: Because of its focus on usability and user 
interface design, `Gala` has also been incorporated into graduate-level galactic 
dynamics curricula at multiple institutions. 

`Gala` has been downloaded over 100,000 times from PyPI and conda-forge yearly 
(or ~2,000 downloads per week) over the past few years, demonstrating a broad 
and active user community. Users span career stages from graduate students to 
faculty and other established researchers and represent institutions around the 
world. This broad adoption and active participation validate `Gala`'s role as 
core community infrastructure for galactic dynamics research.

# Mathematics

Single dollars ($) are required for inline mathematics e.g. $f(x) = e^{\pi/x}$

Double dollars make self-standing equations:

$$\Theta(x) = \left\{\begin{array}{l}
0\textrm{ if } x < 0\cr
1\textrm{ else}
\end{array}\right.$$

You can also use plain \LaTeX for equations
\begin{equation}\label{eq:fourier}
\hat f(\omega) = \int_{-\infty}^{\infty} f(x) e^{i\omega x} dx
\end{equation}
and refer to \autoref{eq:fourier} from text.

# Citations

Citations to entries in paper.bib should be in
[rMarkdown](http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html)
format.

If you want to cite a software repository URL (e.g. something on GitHub without a preferred
citation) then you can do it with the example BibTeX entry below for @fidgit.

For a quick reference, the following citation commands can be used:
- `@author:2001`  ->  "Author et al. (2001)"
- `[@author:2001]` -> "(Author et al., 2001)"
- `[@author1:2001; @author2:2001]` -> "(Author1 et al., 2001; Author2 et al., 2002)"

# Figures

Figures can be included like this:
![Caption for example figure.\label{fig:example}](figure.png)
and referenced from text using \autoref{fig:example}.

Figure sizes can be customized by adding an optional second parameter:
![Caption for example figure.](figure.png){ width=20% }

# AI usage disclosure

No generative AI tools were used in the development of this software, the writing
of this manuscript, or the preparation of supporting materials.

# Acknowledgements

We acknowledge contributions from Brigitta Sipocz, Syrtis Major, and Semyeong
Oh, and support from Kathryn Johnston during the genesis of this project.

# References
