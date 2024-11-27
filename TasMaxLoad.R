# libraries 
library(tidync)
library(tidyverse)
library(purrr)
library(ncdf4)
library(tsibble)

# function to import nc file and extract data into df
restructure_nc <- function(path){
  # load nc file
  src <- tidync(path)
  # extract year from file name
  year <- str_sub(sub(".*day_", "", path), start = 1L, end = 4L) 
  # create df of tasmax data grid
  tasmax_data <- hyper_tibble(src)
  # create df of lat/lon
  D2 <- activate(src, "D2,D1") %>%
    hyper_tibble()
  # join lat/lon to tasmax data
  tasmax_data <- left_join(tasmax_data, D2, by = c("projection_x_coordinate", "projection_y_coordinate"))
  # convert time to YYMMDD
  output <- tasmax_data %>%
    mutate(time = as.POSIXct(time * 3600, origin = '1800-01-01 00:00:00')) %>% 
    mutate(time = as.Date(time))
  # create column in YYMM format
  output <- output %>%
    mutate(year_month = yearmonth(time))
  # drop coordinates
  output <- output %>% 
    dplyr::select(-c(latitude, longitude))
  # pivots data from long thin to short wide format, with one column per month's tasmax data.
  output <- pivot_wider(output, names_from = time, values_from = tasmax, id_cols = c("projection_x_coordinate", "projection_y_coordinate"))
  # names_from = year_month, names_prefix = "tasmax_"
  # return data as df
  return(output)
}

# extract multiple nc files
# list of files to be extracted
files <- list.files(path = "C://", pattern = "*.nc", full.names = TRUE)
# run restructure_nc to load and extract data for multiple years
map_ncs <- map(files, restructure_nc)
# join all dfs together by the X and Y coordinates
output <- reduce(map_ncs, left_join, by = c("projection_x_coordinate", "projection_y_coordinate"))

