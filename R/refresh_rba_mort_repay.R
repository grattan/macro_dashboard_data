library(readrba)
library(dplyr)
library(here)
library(fst)
library(tidyr)
library(lubridate)

# Table E2 Ratio housing interest payments to quarterly household disposable income, SA, quart
quarterly_mort_repay <- read_rba(series_id = 
                             c("BHFIPDH"))

# Other mort data if needed...


# Save FST files ----
fst::write_fst(quarterly_mort_repay,
               here::here("data", "rba", "rba_quarterly_mort_repay.fst"),
               compress = 100)



# Update 'last updated' ----
readr::read_csv(here::here("last_updated.csv")) %>%
  bind_rows(tibble(data = "rba_mort_repay", date = Sys.time())) %>%
  group_by(data) %>%
  filter(date == max(date)) %>%
  arrange(date) %>%
  distinct() %>%
  readr::write_csv(here::here("last_updated.csv")) 