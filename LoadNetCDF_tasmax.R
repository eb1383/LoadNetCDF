# Load required libraries
library(tidync)      # For handling NetCDF data
library(tidyverse)   # For data wrangling
library(purrr)       # For functional programming (e.g., map functions)
library(ncdf4)       # For working with NetCDF files
library(tsibble)     # For handling time-series data

### FUNCTION TO IMPORT NETCDF FILES AND EXTRACT DATA INTO A DATA FRAME ###

restructure_nc <- function(path) {
  # Load NetCDF file
  src <- tidync(path)
  
  # Extract the year from the file name (assumes a specific naming pattern)
  year <- str_sub(sub(".*day_", "", path), start = 1L, end = 4L) 
  
  # Extract tasmax (daily maximum temperature) data from the NetCDF file
  tasmax_data <- hyper_tibble(src)
  
  # Extract spatial coordinate data (latitude & longitude)
  D2 <- activate(src, "D2,D1") %>% hyper_tibble()
  
  # Merge the spatial coordinates with the tasmax data
  tasmax_data <- left_join(tasmax_data, D2, by = c("projection_x_coordinate", "projection_y_coordinate"))
  
  # Convert NetCDF time format to Date format
  output <- tasmax_data %>%
    mutate(time = as.POSIXct(time * 3600, origin = '1800-01-01 00:00:00')) %>% 
    mutate(time = as.Date(time))
  
  # Create a new column with year-month format for easier aggregation
  output <- output %>%
    mutate(year_month = yearmonth(time))
  
  # Drop redundant latitude and longitude columns (if unnecessary for further analysis)
  output <- output %>% 
    dplyr::select(-c(latitude, longitude))
  
  # Pivot data from long format (one row per day) to wide format (one column per day's tasmax value)
  output <- pivot_wider(output, names_from = time, values_from = tasmax, id_cols = c("projection_x_coordinate", "projection_y_coordinate"))
  
  # Return the processed data frame
  return(output)
}

### PROCESS MULTIPLE NETCDF FILES AND COMBINE DATA ###

# Define the directory containing NetCDF files
files <- list.files(path = "C://", pattern = "*.nc", full.names = TRUE)

# Apply the restructure_nc function to each NetCDF file
map_ncs <- map(files, restructure_nc)

# Merge all extracted datasets by spatial coordinates
output <- reduce(map_ncs, left_join, by = c("projection_x_coordinate", "projection_y_coordinate"))


