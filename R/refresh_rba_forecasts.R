library(dplyr)
rba_forecasts <- readrba::rba_forecasts(refresh = TRUE,
                                        all_or_latest = "all",
                                        remove_old = FALSE)

rba_forecasts <- rba_forecasts %>%
  mutate_if(is.character, as.factor) %>%
  select(-source, -series_desc, -notes)

rba_fst_path <- here::here("data", "rba", "rba_forecasts.fst")

saved_rba_forecasts <- fst::read_fst(rba_fst_path)

forecasts_the_same <- all.equal(rba_forecasts, 
                                saved_rba_forecasts, 
                                check.attributes = FALSE)

if (!isTRUE(forecasts_the_same)) {
  fst::write_fst(rba_forecasts,
                 rba_fst_path)
  
  readr::read_csv(here::here("last_updated.csv")) %>%
    bind_rows(tibble(data = "rba_forecasts", date = Sys.time())) %>%
    group_by(data) %>%
    filter(date == max(date)) %>%
    arrange(date) %>%
    distinct() %>%
    readr::write_csv(here::here("last_updated.csv")) 
}
