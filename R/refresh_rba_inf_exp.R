library(readrba)
library(dplyr)
library(fst)
library(readr)
library(here)

expect <- read_rba(table_no = "g3")

expect <- expect %>%
  select(date, series, value) %>%
  mutate_if(is.character, as.factor)

expect_fst_path <- here::here("data", "rba", "rba_inf_exp.fst")

stored_expect <- fst::read_fst(expect_fst_path)

if (!isTRUE(all.equal(expect, stored_expect, 
                      check.attributes = FALSE))) {
  fst::write_fst(expect, expect_fst_path)
  
  readr::read_csv(here::here("last_updated.csv")) %>%
    bind_rows(tibble(data = "rba_inf_exp", date = Sys.time())) %>%
    group_by(data) %>%
    filter(date == max(date)) %>%
    arrange(date) %>%
    distinct() %>%
    readr::write_csv(here::here("last_updated.csv")) 
} else {
  print("RBA inflation expectations already up to date")
}
