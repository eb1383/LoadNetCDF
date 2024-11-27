# libraries
library(tidyverse)
library(readxl)
library(sf)
library(janitor)  
library(raster)
library(patchwork)
library(exactextractr)
library(data.table)
library(terra)
library(dlnm)
library(gnm)


### PREPARE THE TIME SERIES DATA ####
# location of case data
source <- ""
# file name
file <- paste0("")
# load surveillance data
cases <- read_csv(paste0(source, file))
# subset data frame
cases <- cases %>%
  dplyr::select(date, lsoa, count)
# convert date 
cases$date <- as.Date(cases$date)

# sequence of dates
start_date <- as.Date("2014-01-01")
end_date <- as.Date("2021-12-31")
seqdate <- seq(start_date, end_date, by = "days")
# filter dataset to match hadukgrid
cases <- cases %>%
  filter(date >= start_date & date <= end_date)
# complete the data by filling in missing dates with zero cases
cases <- cases %>%
  complete(nesting(lsoa), date = seq(start_date, end_date, by = "day"), fill = list(count = 0))
# fill with 0 when no cases
cases[is.na(cases)] <- 0

### WEEKLY DATA ####
# create week column
cases$week <- lubridate::week(cases$date)
# replace week 53 with week 52
cases$week <- ifelse(cases$week == 53, 52, cases$week)
# create continuous week column
cases$week <- with(cases, (year(date) - min(year(date))) * 52 + week - min(week) + 1)
# aggregate counts per week
cases <- cases %>%
  group_by(lsoa, week) %>%
  summarize(total_count = sum(count))

### LOAD LSOA FILES AND GRIDDED MAX TEMP DATA ####
# location of shapefiles
source <- ""
# file name  
file <- paste0("LSOA_2011_EW_BGC_V3")
# load files in R
shp <- st_read(paste0(source, file, ".shp"))
# sequences of lsoas
seqlsoa <- shp %>%
  distinct(LSOA11CD)

### LOAD GRIDDED MAX TEMP DATA ####
source("LoadNetCDF_tasmax.R")
# clean names
output <- output %>% 
  clean_names()
# convert tasmax data to spat raster
output <- rast(output)
# compute the area weighted average of cells intersecting each lsoa
lsoa <- exact_extract(output, shp, fun = "mean")
# set dimnames
dimnames(lsoa) <- list(seqlsoa$LSOA11CD, seqdate)
lsoa <- lsoa %>%
  rownames_to_column(var = "lsoa")
# reshape the data frame to a long format
lsoa_long <- lsoa %>%
  pivot_longer(cols = -lsoa, names_to = "date", values_to = "total_tasmax")
# convert the date column to date format
lsoa_long <- lsoa_long %>%
  mutate(date = as.Date(date))
# add the week column to store the week number
lsoa_long <- lsoa_long %>%
  mutate(week = lubridate::week(date))
# replace week 53 with week 52
lsoa_long$week <- ifelse(lsoa_long$week == 53, 52, lsoa_long$week)
# create continuous week column
lsoa_long$week <- with(lsoa_long, (year(date) - min(year(date))) * 52 + week - min(week) + 1)
# aggregate the data by week
lsoa <- lsoa_long %>%
  group_by(lsoa, week) %>%
  summarise(average_tasmax = mean(total_tasmax))

# merge with main dataset
df <- merge(cases, lsoa, by = c("lsoa", "week"), all = T)
df$average_tasmax[is.na(df$average_tasmax)] <- 0
df$total_count[is.na(df$total_count)] <- 0



