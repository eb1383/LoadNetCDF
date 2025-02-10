# Load required libraries
library(tidyverse)   # Data manipulation
library(readxl)      # Read Excel files
library(sf)          # Spatial data handling
library(janitor)     # Data cleaning
library(raster)      # Raster data processing
library(patchwork)   # Plot arrangements
library(exactextractr) # Spatial extraction
library(data.table)  # Fast data manipulation
library(terra)       # Raster data handling (modern alternative to raster)
library(dlnm)        # Distributed lag non-linear models
library(gnm)         # Generalized nonlinear models
library(lubridate)   # Date handling

### PREPARE THE TIME SERIES DATA ####

# Define source location and file name
source <- ""  # Specify data directory
file <- ""    # Specify file name

# Load surveillance data (cases dataset)
cases <- read_csv(file.path(source, file)) %>%
  select(date, lsoa, count) %>%  # Select relevant columns
  mutate(date = as.Date(date))   # Convert date column to Date format

# Define study period (start and end dates)
start_date <- as.Date("2014-01-01")
end_date <- as.Date("2021-12-31")

# Create a complete sequence of daily dates
seqdate <- seq(start_date, end_date, by = "days")

# Filter cases dataset to only include relevant date range
cases <- cases %>%
  filter(date >= start_date & date <= end_date) %>%
  complete(nesting(lsoa), date = seqdate, fill = list(count = 0)) %>%  # Fill missing dates with zero cases
  replace_na(list(count = 0))  # Ensure no missing values remain

### AGGREGATE DATA TO WEEKLY LEVEL ####

cases <- cases %>%
  mutate(
    week = week(date),  # Extract week number from date
    week = ifelse(week == 53, 52, week),  # Adjust week 53 to week 52 (standardization)
    year_offset = (year(date) - min(year(date))) * 52,  # Calculate year offset for continuous week numbering
    continuous_week = year_offset + week - min(week) + 1  # Create a continuous week index
  ) %>%
  group_by(lsoa, continuous_week) %>%
  summarise(total_count = sum(count), .groups = "drop")  # Aggregate case counts by week

### LOAD LSOA SHAPEFILE ####

# Define source location and file name for shapefile
file <- "LSOA_2011_EW_BGC_V3"

# Load LSOA shapefile (Lower Super Output Areas)
shp <- st_read(file.path(source, paste0(file, ".shp")))

# Extract unique LSOA codes
seqlsoa <- shp %>%
  distinct(LSOA11CD)

### LOAD AND PROCESS GRIDDED MAX TEMPERATURE DATA ####

# Load NetCDF temperature data processing script
source("LoadNetCDF_tasmax.R")

# Clean column names in the loaded dataset
output <- output %>%
  clean_names() %>%
  rast()  # Convert data to a raster format for spatial processing

# Compute area-weighted mean temperature for each LSOA
lsoa <- exact_extract(output, shp, fun = "mean") %>%
  as.data.frame() %>%  # Convert extracted data to a data frame
  setNames(c("lsoa", seqdate)) %>%  # Assign column names
  pivot_longer(cols = -lsoa, names_to = "date", values_to = "average_tasmax") %>%  # Convert to long format
  mutate(date = as.Date(date))  # Ensure date column is in Date format

# Aggregate temperature data to weekly level
lsoa <- lsoa %>%
  mutate(
    week = week(date),  # Extract week number
    week = ifelse(week == 53, 52, week),  # Standardize week numbering
    year_offset = (year(date) - min(year(date))) * 52,  # Compute year-based offset for continuous week numbering
    continuous_week = year_offset + week - min(week) + 1  # Create continuous week index
  ) %>%
  group_by(lsoa, continuous_week) %>%
  summarise(average_tasmax = mean(average_tasmax, na.rm = TRUE), .groups = "drop")  # Aggregate to weekly level

### MERGE CASE DATA WITH TEMPERATURE DATA ####

df <- full_join(cases, lsoa, by = c("lsoa", "continuous_week")) %>%
  replace_na(list(average_tasmax = 0, total_count = 0))  # Fill missing values with zeros




