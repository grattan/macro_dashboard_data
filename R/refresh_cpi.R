library(readabs)
library(readr)
library(here)
library(lubridate)

cpi <- readabs::read_cpi()
now <- lubridate::force_tz(Sys.time(), "Australia/Melbourne")
cpi$updated <- now

readr::write_csv(cpi, path = here::here("data", "cpi.csv"))
