library(readabs)
library(fst)
library(here)

cpi <- readabs::read_cpi()
now <- .POSIXct(Sys.time(), "Australia/Melbourne")
cpi$updated <- now

fst::write_fst(cpi, path = here::here("data", "cpi.fst"))
