library(readabs)
library(dplyr)
library(here)
library(fst)
library(readr)

raw_path <- here::here("data-raw", "abs")

# Check to see if the release date differs in local & remote versions of
# this file, chosen because of its small file size
old_cpi_1 <- read_abs_local("6401.0", "1", path = raw_path)

new_cpi_1 <- read_abs("6401.0", "1", check_local = FALSE, path = raw_path)

old_date <- max(old_cpi_1$date)
new_date <- max(new_cpi_1$date)

if (new_date > old_date) {
  cpi <- read_abs("6401.0", 
                    tables = c("1", "3", "7", "8"),
                    path = raw_path,
                    check_local = FALSE)
  
  cpi <- cpi %>%
    select(date, table_title, series, series_type, series_id, value) %>%
    filter(!is.na(value)) %>%
    mutate_if(is.character, as.factor)
  
   cpi <- cpi %>%
    mutate(table = paste0("cpi_", 
                          readr::parse_number(as.character(table_title)))) %>%
    select(-table_title) %>%
    split(.$table)
  
  purrr::walk2(.x = cpi, .y = names(cpi),
               .f = ~fst::write_fst(.x,
                               here::here("data", "abs", paste0(.y, ".fst")),
                               compress = 100)
  )
  

  readr::read_csv(here::here("last_updated.csv")) %>%
    bind_rows(tibble(data = "cpi", date = Sys.time())) %>%
    group_by(data) %>%
    filter(date == max(date)) %>%
    arrange(date) %>%
    distinct() %>%
    readr::write_csv(here::here("last_updated.csv")) 
  
} else {
  print("lfs monthly already up to date")
}