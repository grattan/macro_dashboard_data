library(readabs)
library(readr)
library(here)
library(lubridate)

cpi <- readabs::read_cpi()
cpi$updated <- Sys.time()

readr::write_csv(cpi, path = here::here("data", "cpi.csv"))
