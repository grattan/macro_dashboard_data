library(RCurl)
library(fst)
library(here)
library(readr)
library(dplyr)
# Get data ----
dates <- seq.Date(Sys.Date(), Sys.Date() - 7, by = "-1 day")
days <- format(dates, "%d")
urls <- paste0("https://covid19-static.cdn-apple.com/covid19-mobility-data/2022HotfixDev15",
               # "21",
               # days,
               "/v3/en-us/applemobilitytrends-",
               dates, 
               ".csv")
urls_exist <- RCurl::url.exists(urls)
working_urls <- urls[urls_exist == TRUE] 
latest_working_url <- sort(working_urls, decreasing = TRUE)[1]
filename <- here::here("data-raw", "apple", basename(latest_working_url))

if (!file.exists(filename)) {
  unlink(here::here("data-raw", "apple"), recursive = TRUE)
  dir.create(here::here("data-raw", "apple"))
  
  download.file(url = latest_working_url,
                destfile = filename)
  
  apple_mobility <- read_csv(filename)
  
  apple_mobility <- apple_mobility %>%
    filter(country == "Australia")
  
  apple_mobility <- apple_mobility %>%
    mutate_if(is.character, as.factor)
  
  fst::write_fst(apple_mobility, here::here("data", "apple",
                                            "apple_mobility.fst"))  
  
  print(paste0("Latest Apple mobility data is from ",
        names(apple_mobility)[length(apple_mobility)]))
  
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
