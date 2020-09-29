library(readabs)
library(dplyr)
library(here)
library(fst)
library(readr)

raw_path <- here::here("data-raw", "abs")

# Check to see if the release date differs in local & remote versions of
# this file, chosen because of its small file size
old_lfs_6202_11s <- read_abs_local("6202.0", "11a", 
                                   path = raw_path)

new_lfs_6202_11s <- read_abs("6202.0", "11a", check_local = FALSE, 
                        path = raw_path)

old_date <- max(old_lfs_6202_11s$date)
new_date <- max(new_lfs_6202_11s$date)

if (new_date > old_date) {
  Lfs_11a <- read_abs("6202.0", "11a", check_local = FALSE, 
           path = raw_path)
  
  lfs_m <- read_abs("6202.0", 
                    tables = c("1", "12", "19", "22", "24"),
                    path = raw_path,
                    check_local = FALSE)
  
  lfs_m <- lfs_m %>%
    select(date, table_title, series, series_type, series_id, value) %>%
    filter(!is.na(value)) %>%
    mutate_if(is.character, as.factor)
  
  lfs_m <- lfs_m %>%
    mutate(table = paste0("lfs_m_", 
                          readr::parse_number(as.character(table_title)))) %>%
    select(-table_title) %>%
    split(.$table)
  
  purrr::walk2(.x = lfs_m, .y = names(lfs_m),
              .f = ~write_fst(.x,
                              here::here("data", "abs", paste0(.y, ".fst")),
                              compress = 100)
              )
  
  source(here::here("R", "refresh_abs_lfs_grossflows.R"))

  readr::read_csv(here::here("last_updated.csv")) %>%
    bind_rows(tibble(data = "lfs monthly", date = Sys.time())) %>%
    group_by(data) %>%
    filter(date == max(date)) %>%
    arrange(date) %>%
    distinct() %>%
    readr::write_csv(here::here("last_updated.csv")) 

} else {
  print("lfs monthly already up to date")
}