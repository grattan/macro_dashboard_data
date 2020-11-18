library(readabs)
library(here)
library(dplyr)
library(readr)

wpi_old <- read_abs_local("6345.0", path = here::here("data-raw", "abs"))

wpi_new <- read_abs("6345.0", 1, path = here::here("data-raw", "abs"))

old_date <- max(wpi_old$date)
new_date <- max(wpi_new$date)

if (new_date > old_date) {
  wpi_5b <- read_abs("6345.0", "5b", path = here::here("data-raw", "abs"))
  wpi_1 <- wpi_new
  wpi <- list(wpi_1, wpi_5b)
  wpi <- setNames(wpi, c("wpi_1", "wpi_5b"))
  
  wpi <- wpi %>%
    purrr::map(.f = ~select(., date, table_title, series, series_type, series_id, value) %>%
                 filter(!is.na(value)) %>%
                 mutate_if(is.character, as.factor)
               )
  
  purrr::iwalk(.x = wpi,
              .f = ~fst::write_fst(.x,
                                   here::here("data", "abs", 
                                              paste0(.y, ".fst")),
                                   compress = 100))
  
  readr::read_csv(here::here("last_updated.csv")) %>%
    bind_rows(tibble(data = "wpi", date = Sys.time())) %>%
    group_by(data) %>%
    filter(date == max(date)) %>%
    arrange(date) %>%
    distinct() %>%
    readr::write_csv(here::here("last_updated.csv")) 
} else {
  print("wpi already up to date")
}

