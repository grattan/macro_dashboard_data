library(readabs)
library(dplyr)
library(here)
library(fst)
library(readr)

raw_path <- here::here("data-raw", "abs")

# New loan commitments ----
abs_comits <- read_abs("5601.0", "1", check_local = FALSE, 
                    path = raw_path)

abs_comits <- abs_comits %>%
  select(date, series, series_type, series_id, value) %>%
  filter(!is.na(value)) %>%
  mutate_if(is.character, as.factor)


# Save FST files ----
fst::write_fst(abs_comits,
               here::here("data", "abs", "abs_comits.fst"),
               compress = 100)


# Update 'last updated' ----
readr::read_csv(here::here("last_updated.csv")) %>%
  bind_rows(tibble(data = "abs comits", date = Sys.time())) %>%
  group_by(data) %>%
  filter(date == max(date)) %>%
  arrange(date) %>%
  distinct() %>%
  readr::write_csv(here::here("last_updated.csv")) 

