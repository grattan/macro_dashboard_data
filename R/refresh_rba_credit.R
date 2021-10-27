library(readrba)
library(dplyr)
library(here)
library(fst)
library(tidyr)
library(lubridate)

# Table D1 Housing credit growth, SA, monthly
monthly_house_credit_g <- read_rba(series_id = 
                             c("DGFACHM"))


# Table D2 Housing credit $, SA, monthly | (o-occupier and investor)
monthly_house_credit_lvl <- read_rba(series_id = 
                                   c("DLCACOHS", "DLCACIHS"))


# Other credit if needed...


# Combine
monthly_house_credit <- add_row(monthly_house_credit_g,monthly_house_credit_lvl)


# Save FST files ----
fst::write_fst(monthly_house_credit,
               here::here("data", "rba", "rba_monthly_house_credit.fst"),
               compress = 100)



# Update 'last updated' ----
readr::read_csv(here::here("last_updated.csv")) %>%
  bind_rows(tibble(data = "rba_credit", date = Sys.time())) %>%
  group_by(data) %>%
  filter(date == max(date)) %>%
  arrange(date) %>%
  distinct() %>%
  readr::write_csv(here::here("last_updated.csv")) 