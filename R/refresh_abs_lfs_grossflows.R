# This file should be called from within `refresh_abs_lfs_main.R` as that file
# first checks to see whether the local LFS data is up to date

# Note that the full gross flows data set (incl. state + age cross-tabs, plus
# dis-aggregation of employed into FT/PT etc.) is >1m rows, so we summarise it
library(here)
library(dplyr)
library(readxl)
library(fst)
library(janitor)
library(lubridate)
library(httr)
library(readabs)

# Download gross flows ----
gf_file <- download_abs_data_cube("labour-force-australia", "GM1")

# Load gross flows Excel sheet ------
gf <- read_excel(gf_file, sheet = "Data 1", skip = 3)

# Tidy gross flows -----
gf <- janitor::clean_names(gf)

gf <- gf %>%
  rename(
    state = state_and_territory_stt_asgs_2011,
    n = persons_current_month_000
  )

gf <- gf %>%
  mutate(date = as.Date(month)) %>%
  select(-month)

create_broad_lf <- function(lf_status) {
  case_when(
    lf_status %in% c(
      "Employed full-time",
      "Employed part-time"
    ) ~ "Employed",
    lf_status %in% c(
      "Unmatched in common sample (responded in previous month but not in current)",
      "Unmatched in common sample (responded in current month but not in previous)",
      "Incoming rotation group",
      "Outgoing rotation group"
    ) ~ "Unmatched",
    grepl("NILF", lf_status) ~ "NILF",
    TRUE ~ lf_status
  )
}


gf_tot <- gf %>%
  mutate(
    lf_current_broad = create_broad_lf(labour_force_status_current_month),
    lf_prev_broad = create_broad_lf(labour_force_status_previous_month)
  ) %>%
  group_by(
    date,
    lf_prev_broad,
    lf_current_broad
  ) %>%
  summarise(n = sum(n)) %>%
  mutate(perc = n / sum(n)) %>%
  ungroup() %>%
  select(-n) %>%
  filter(
    lf_prev_broad != "Unmatched",
    lf_current_broad != "Unmatched"
  ) %>%
  mutate(series = paste0(lf_prev_broad, " to ", lf_current_broad)) %>%
  select(-lf_prev_broad, -lf_current_broad)

write_fst(gf_tot,
          here::here("data", "abs", "lfs_m_grossflows.fst"))
