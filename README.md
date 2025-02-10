# Temperature and Case Data Processing Scripts 🌡️📊

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

## 2. **agg_climate_df.R - Surveillance and Temperature Data Integration** 🔥🦠

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
```

## 🚀 How to Use  

To run these scripts, follow these steps:  

1. **Install the required R packages** as listed above.  
2. **Update file paths**:  
   - In `LoadNetCDF_tasmax.R`, update the path to where your NetCDF files are stored.  
   - In the case data script, update the paths to your case data file and LSOA shapefile.  
3. **Run the scripts**:  
   - Start by running the temperature data processing script (`LoadNetCDF_tasmax.R`).  
   - Then run the case data script to integrate the case data with temperature.  
4. **Ready for analysis**:  
   - You’ll have a beautifully merged dataset of case counts and temperatures at the LSOA level, ready for modelling or further exploration.  

---

## 🧑‍💻 Example Output  

Here’s what the final dataset will look like:  

- **LSOA Code**: Unique identifiers for each Lower Super Output Area (LSOA).  
- **Week Number**: Continuous weekly index (we’ve made sure no weeks are skipped!).  
- **Total Case Count**: Aggregated cases for each LSOA per week.  
- **Average Temperature**: Area-weighted mean temperature for each LSOA, aggregated by week.  

---

## 🤝 Contributions  

Feel free to contribute! If you find any bugs or have cool ideas for improvements, please submit an issue or create a pull request. I'd love to make this better together! ✨  


