
<!-- README.md is generated from README.Rmd. Please edit that file -->

# macro\_dashboard\_data

<!-- badges: start -->

![refresh-data
status](https://github.com/MattCowgill/macro_dashboard_data/workflows/refresh-data/badge.svg)
<!-- badges: end -->

``` r

cpi <- fst::read_fst(here::here("data", "cpi.fst"))

updated <- unique(cpi$updated)
```

Data last updated at 2020-08-30 14:29:31.
