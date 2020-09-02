all_files <- list.files("R")
refresh_files <- all_files[grepl("refresh_", all_files)]
refresh_files <- refresh_files[refresh_files != "refresh_all.R"]
refresh_files <- file.path("R", refresh_files)

for (file in refresh_files) {
  print(paste0("Refreshing ", file))
  source(file)
}


file_conn <- file("last_refreshed.txt")
writeLines(as.character(Sys.time()), 
           file_conn)
close(file_conn)
