library(RCurl)
library(fst)
library(here)
# Get data ----
dates <- seq.Date(Sys.Date(), Sys.Date() - 7, by = "-1 day")

urls <- paste0("https://covid19-static.cdn-apple.com/covid19-mobility-data/2021HotfixDev21/v3/en-us/applemobilitytrends-",
               dates, 
               ".csv")
urls_exist <- RCurl::url.exists(urls)
working_url <- urls[urls_exist == TRUE] 
filename <- here::here("data-raw", "apple", basename(working_url))

if (!file.exists(filename)) {
  unlink(here::here("data-raw", "apple"), recursive = TRUE)
  dir.create(here::here("data-raw", "apple"))
  
  download.file(url = working_url,
                destfile = filename)
  
  apple_mobility <- read_csv(filename)
  
  apple_mobility <- apple_mobility %>%
    filter(country == "Australia")
  
  apple_mobility <- apple_mobility %>%
    mutate_if(is.character, as.factor)
  
  fst::write_fst(apple_mobility, here::here("data", "apple",
                                            "apple_mobility.fst"))  
  
  
  readr::read_csv(here::here("last_updated.csv")) %>%
    bind_rows(tibble(data = "apple_mobility", date = Sys.time())) %>%
    group_by(data) %>%
    filter(date == max(date)) %>%
    arrange(date) %>%
    distinct() %>%
    readr::write_csv(here::here("last_updated.csv")) 
} else {
  print("Apple mobility data already up to date")
}
