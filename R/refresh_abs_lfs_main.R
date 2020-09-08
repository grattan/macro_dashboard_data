library(readabs)
library(dplyr)
library(here)
library(fst)

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
  
  lfs_m <- read_abs("6202.0", check_local = FALSE)
  
  lfs_m <- lfs_m %>%
    select(date, series, series_type, series_id, value) %>%
    filter(!is.na(value)) %>%
    mutate_if(is.character, as.factor)
  
  fst::write_fst(lfs_m, 
                 here::here("data", "abs", "6202.fst"), 
                 compress = 100)
  
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