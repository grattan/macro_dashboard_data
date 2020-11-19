library(readrba)
library(dplyr)
library(here)
library(fst)


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

fst::write_fst(monthly_yields,
               here::here("data", "rba", "rba_monthly_yields.fst"),
               compress = 100)

fst::write_fst(daily_yields,
               here::here("data", "rba", "rba_daily_yields.fst"),
               compress = 100)

readr::read_csv(here::here("last_updated.csv")) %>%
  bind_rows(tibble(data = "rba_yields", date = Sys.time())) %>%
  group_by(data) %>%
  filter(date == max(date)) %>%
  arrange(date) %>%
  distinct() %>%
  readr::write_csv(here::here("last_updated.csv")) 