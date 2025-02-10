# README for Temperature and Case Data Processing Scripts 🌡️📊

Welcome to the repository! Here, you'll find two R scripts designed to process gridded temperature data and surveillance case data, which can be used to explore potential relationships between temperature and case counts. Below is a friendly guide on what each script does and how to use them.

---

## 1. **LoadNetCDF_tasmax.R** - Processing Gridded Temperature Data ☀️

This script is all about loading and processing NetCDF files that contain daily maximum temperature data (aka `tasmax`). Here’s what it does:

### Key Function: 
- **`restructure_nc(path)`**: 
  - Loads and extracts temperature data from a NetCDF file.
  - Pulls the year from the filename (assuming it follows a specific pattern).
  - Extracts daily temperature data and spatial coordinates (latitude and longitude).
  - Converts time from NetCDF to a proper `Date` format.
  - Aggregates data into a `year_month` format for better analysis.
  - Reshapes the data from long to wide format (i.e., each day's temperature gets its own column).

### How it works:
1. **Load Files**: The script loads all `.nc` files from your chosen directory. 
2. **Extract and Process Data**: Each file is processed to grab the temperature and spatial data.
3. **Merge and Aggregate**: Combines all files into one massive dataset, joined by spatial coordinates.
4. **Final Output**: You’ll get a lovely data frame with temperatures for each day, organised by location.

---

## 2. **agg_climate_df.R Suvrveillance and Temperature Data Integration** 🔥🦠

This script takes surveillance case data and combines it with the temperature data you processed above. It does all the heavy lifting, like preparing time-series data, aggregating by week, and aligning with geographical boundaries (LSOAs).

### Key Steps:
1. **Prepare the Case Data**:
   - Loads surveillance case data from an Excel/CSV file.
   - Filters it by a specific date range (1st Jan 2014 to 31st Dec 2021).
   - Aggregates the case counts by week for each LSOA.
   - Fills any missing dates and ensures week numbers are continuous.
   
2. **Load and Process the LSOA Shapefile**:
   - Loads your LSOA shapefile to map your data geographically.
   - Computes area-weighted average temperatures for each LSOA.

3. **Data Merging**:
   - Merges the case data with temperature data based on LSOA and week.
   - Missing values are filled with zeros to make sure you don’t run into any gaps in your analysis.

4. **Final Output**:
   - You’ll get a dataset that includes the total case counts and average weekly temperatures for each LSOA.

---

## 📦 Prerequisites

### R Packages Required:
To run the scripts, you’ll need the following packages. Don’t worry, they're all easily installable in R:

- `tidync` – For handling NetCDF data.
- `tidyverse` – For data manipulation (it’s a must-have!).
- `purrr` – For functional programming (like `map` functions).
- `ncdf4` – For working with NetCDF files.
- `tsibble` – For working with time-series data.
- `readxl` – For reading Excel files.
- `sf` – For working with shapefiles and spatial data.
- `janitor` – For cleaning up messy data.
- `raster`, `terra` – For raster data processing.
- `exactextractr` – For spatial data extraction.
- `lubridate` – For handling dates easily.
- `dlnm`, `gnm` – For statistical modelling (if you're into that! 😎).

### Install Packages:

You can install the required packages using this line of code in R:

```r
install.packages(c("tidync", "tidyverse", "purrr", "ncdf4", "tsibble", 
                   "readxl", "sf", "janitor", "raster", "terra", "exactextractr", 
                   "lubridate", "dlnm", "gnm"))
