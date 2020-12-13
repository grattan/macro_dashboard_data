library(curl)
library(fst)
library(here)
library(readr)
library(dplyr)

# Find right URL ----
# Code via Kieran Healy
# https://kieranhealy.org/blog/archives/2020/05/23/get-apples-mobility-data/

get_apple_url <- function(cdn_url = "https://covid19-static.cdn-apple.com",
                          json_file = "covid19-mobility-data/current/v3/index.json") {
  tf <- tempfile(fileext = ".json")
  curl::curl_download(paste0(cdn_url, "/", json_file), tf)
  json_data <- jsonlite::fromJSON(tf)
  paste0(cdn_url, json_data$basePath, json_data$regions$`en-us`$csvPath)
}

apple_url <- get_apple_url()
# Get data ----


filename <- here::here("data-raw", "apple", basename(apple_url))

if (!file.exists(filename)) {
  unlink(here::here("data-raw", "apple"), recursive = TRUE)
  dir.create(here::here("data-raw", "apple"))
  
  download.file(url = apple_url,
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
