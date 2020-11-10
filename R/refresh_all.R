refresh_files <- list.files(here::here("R"), pattern = "refresh_")
refresh_files <- refresh_files[refresh_files != "refresh_all.R"]
refresh_files <- refresh_files[refresh_files != "refresh_abs_lfs_grossflows.R"]
refresh_files <- here::here("R", refresh_files)

for (file in refresh_files) {
  print(paste0("Refreshing ", file))
  source(file)
}

# Compile all files into one

files <- list.files(here::here("data"), pattern = ".fst",
                    recursive = T, full.names = T, include.dirs = F)
files <- files[!grepl("all_data", files)]

all_data <- purrr::map(files, fst::read_fst)

all_data <- setNames(all_data, tools::file_path_sans_ext(basename(files)))

saveRDS(all_data, file = "data/all_data.rds")


# Update last refreshed file
file_conn <- file("last_refreshed.txt")
writeLines(as.character(Sys.time()), 
           file_conn)
close(file_conn)
