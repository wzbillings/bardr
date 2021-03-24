# bardr: Shakespeare's Complete Works for R

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/bardr)](https://cran.r-project.org/package=bardr)

Have you ever felt that the R programming language suffered from a critical
lack of the Bard? Well, worry no more.

The bardr package provides the complete text of William Shakespeare's
complete works as native R files which have already been substantially
pre-processed to make them easy to use.

The complete works are contained in both a list and a tidy data frame format,
and each individual work has also been separated and stored as a character
vector.

## Quick-Start Guide

Getting started with **bardr** is easy! Just install the package (currently
by using `devtools::install_github()`. Or `install.packages("bardr")` for current CRAN version. Then, you can access any of the included data sources like so:
`works <- bardr::all_works_df` for dataframe format or `works <- bardr::all_works_list` for list format.

## Data Sources with all works

* `all_works_df`: a tidy dataframe containing all works.
* `all_works_list`: a named list containing all works.
