library(readsdmx)
library(dplyr)
library(here)
library(fst)
library(janitor)

min2ave_file <- tempfile(fileext = ".xml")
min2ave_url <- "https://stats.oecd.org/restsdmx/sdmx.ashx/GetData/MIN2AVE/"
download.file(url = min2ave_url, destfile = min2ave_file)

min2ave <- min2ave_file %>%
  readsdmx::read_sdmx() %>%
  dplyr::as_tibble() %>%
  janitor::clean_names() %>%
  dplyr::select(-time_format) %>%
  dplyr::mutate(across(c(obs_value, time), as.numeric)) %>%
  dplyr::mutate(across(where(is.character), as.factor)) %>%
  dplyr::filter(.data$time >= 1985)

min2ave_fst_path <- here::here("data", "oecd", "oecd_min2ave.fst")

saved_min2ave <- fst::read_fst(min2ave_fst_path)

matches_saved <- all.equal(min2ave, saved_min2ave, check.attributes = F)

if (isFALSE(matches_saved)) {
  fst::write_fst(min2ave, path = min2ave_fst_path)
  
  readr::read_csv(here::here("last_updated.csv")) %>%
    bind_rows(tibble(data = "oecd_minwages", date = Sys.time())) %>%
    group_by(data) %>%
    filter(date == max(date)) %>%
    arrange(date) %>%
    distinct() %>%
    readr::write_csv(here::here("last_updated.csv")) 
}
  
