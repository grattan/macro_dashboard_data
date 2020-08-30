library(readabs)
library(readr)
library(here)

cpi <- readabs::read_cpi()
now <- as.POSIXct(Sys.time())
attributes(now)$tzone <- "Australia/Melbourne"
cpi$updated <- now

readr::write_csv(cpi, path = here::here("data", "cpi.csv"))
