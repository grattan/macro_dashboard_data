library(readabs)
library(readr)
library(here)

cpi <- readabs::read_cpi()
now <- .POSIXct(Sys.time(), "Australia/Melbourne")
cpi$updated <- now

readr::write_csv(cpi, path = here::here("data", "cpi.csv"))
