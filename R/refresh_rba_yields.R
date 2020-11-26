library(readrba)
library(dplyr)
library(here)
library(fst)
library(tidyr)
library(lubridate)

monthly_yields <- read_rba(series_id = 
                             c("FCMYGBAG2",	"FCMYGBAG3",	"FCMYGBAG5",
                               "FCMYGBAG10",	"FCMYGBAGI",	"FCMYGBNT3",
                               "FCMYGBNT5",	"FCMYGBNT10"))

daily_yields <- read_rba(series_id = 
                           c("FCMYGBAG2D",	
                             "FCMYGBAG3D",	
                             "FCMYGBAG5D",	
                             "FCMYGBAG10D",	
                             "FCMYGBAGID"))

detailed_yields <- readrba::read_rba(table_no = c("f16", "f16"),
                                     cur_hist = c("current", "historical"))

detailed_yields <- detailed_yields %>%
  filter(!grepl("Indexed", series)) %>%
  tidyr::separate(description,
                  into = c("bond_num", "coupon", "maturity_date"),
                  sep = " - ") %>%
  mutate(maturity_date = lubridate::dmy(maturity_date)) %>%
  select(date, value, maturity_date)

fst::write_fst(monthly_yields,
               here::here("data", "rba", "rba_monthly_yields.fst"),
               compress = 100)

fst::write_fst(daily_yields,
               here::here("data", "rba", "rba_daily_yields.fst"),
               compress = 100)

fst::write_fst(detailed_yields,
               here::here("data", "rba", "rba_detailed_yields.fst"))

readr::read_csv(here::here("last_updated.csv")) %>%
  bind_rows(tibble(data = "rba_yields", date = Sys.time())) %>%
  group_by(data) %>%
  filter(date == max(date)) %>%
  arrange(date) %>%
  distinct() %>%
  readr::write_csv(here::here("last_updated.csv")) 