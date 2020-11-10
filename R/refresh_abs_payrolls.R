library(readabs)
library(dplyr)
library(here)
library(readxl)
library(tidyr)
library(fst)

# Note: unlike some series (eg. LFS) we don't check to see if the data is
# up-to-date before downloading it, because (1) it's small and quick and (2)
# not all tables are consistently updated at the same time, so can't assume that
# (eg.) if table 5 isn't updated then no tables are updated

payrolls_dir <- here::here(
  "data-raw",
  "abs",
  "payrolls"
)

payrolls_series <- c(
  "industry_jobs", "industry_wages", "sa4_jobs", "sa3_jobs",
  "subindustry_jobs", "empsize_jobs"
)

read_payrolls_then_factor <- function(series, path) {
  x <- readabs::read_payrolls(series = series, path = path)
  x <- dplyr::mutate_if(x, is.character, as.factor)
  x
}

# Download all payrolls data
payrolls_list <- purrr::map(
  .x = c(
    "industry_jobs", "industry_wages", "sa4_jobs", "sa3_jobs",
    "subindustry_jobs", "empsize_jobs"
  ),
  .f = read_payrolls_then_factor,
  path = payrolls_dir
)

payrolls_list <- setNames(
  payrolls_list,
  paste0("payrolls_", payrolls_series)
)

imported_payrolls_maxdate <- payrolls_list %>%
  purrr::map(.f = ~max(.x$date)) %>%
  purrr::reduce(c) %>%
  max()

saved_payrolls_maxdate <- list.files(
  path = here::here("data", "abs"),
  full.names = TRUE,
  pattern = "payrolls_"
) %>%
  purrr::map(fst::read_fst) %>%
  purrr::map(.f = ~ max(.x$date)) %>%
  purrr::reduce(c) %>%
  max()

# Only save the fst files and update the README table if the data is new
if (imported_payrolls_maxdate > saved_payrolls_maxdate) {
  purrr::walk2(
    .x = payrolls_list,
    .y = names(payrolls_list),
    .f = ~ fst::write_fst(.x,
                          here::here("data", "abs", paste0(.y, ".fst")),
                          compress = 100
    )
  )
  
  readr::read_csv(here::here("last_updated.csv")) %>%
    bind_rows(tibble(data = "payrolls", date = Sys.time())) %>%
    group_by(data) %>%
    filter(date == max(date)) %>%
    arrange(date) %>%
    distinct() %>%
    readr::write_csv(here::here("last_updated.csv")) 
  
}



