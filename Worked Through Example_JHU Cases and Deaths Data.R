## ----------------------------------------------------------------------------
## From Yale's Public Health Data Science and Data Equity (DSDE) Team
##
## Workshop: A Journey Into The World of tidyverse
## Authors:  Shelby Golden, M.S. and Howard Baik, M.S.
## Date:     2024-11-21
## 
## R version:    4.4.1
## renv version: 1.0.11
## 
## Description: Worked-through example generating line and bar graphs of
##              time-series vaccination rates using the JHU CRC's data from 
##              their GovEX GitHub repository. Refer to the main directory 
##              README file for additional information.

## ----------------------------------------------------------------------------
## SET UP THE ENVIRONMENT
## renv() will install all of the packages and their correct version used here

renv::restore()

library(readr)
library(tidyr)
library(dplyr)
library(stringr)
library(ggplot2)
library(lubridate)
library(plotly)

'%!in%' <- function(x,y)!('%in%'(x,y))




## ----------------------------------------------------------------------------
## LOAD IN THE DATA

## This data is from the COVID-19 Data Repository by the Center for Systems 
## Science and Engineering (CSSE) at Johns Hopkins University (JHU), GitHub 
## CSSEGISandData. Additional details can be found in the project repositories 
## main directory's README file.

## We load cases and deaths counts directly from their GitHub page using the 
## raw URL.

covid19_confirmed_url <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/refs/heads/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"
covid19_confirmed_raw  <- read_csv(file = covid19_confirmed_url, show_col_types = FALSE)  

covid19_death_url <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/refs/heads/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv"
covid19_death_raw  <- read_csv(file = covid19_death_url, show_col_types = FALSE) 



## ----------------------------------------------------------------------------
## TIDYR

# Pivot longer
covid19_confirmed_raw_long <- 
  covid19_confirmed_raw |> 
  pivot_longer(
    # which columns need to be pivoted
    cols = "1/22/20":"3/9/23", 
    names_to = "date",          
    values_to = "cumulative_count"
  )

# Pivot wider
covid19_confirmed_raw_long |> 
  pivot_wider(
    names_from = date,
    values_from = cumulative_count
  ) 




## ----------------------------------------------------------------------------
## DPLYR

# Select County, State, and Country
covid19_confirmed_raw |> 
  select(Admin2, Province_State, Country_Region)

# Select Latitude, Longitude
covid19_confirmed_raw |> 
  select(Lat, Long_)

# Add county_state variable
covid19_confirmed_raw |>
  mutate(county_state = paste0(Admin2, ",", Province_State)) |>
  # Select the county_state variable
  select(county_state)

# Filter for the state of Connecticut
covid19_confirmed_raw |> 
  filter(Province_State == "Connecticut")

# Filter for counties in range of latitude [40, 45] and longitude [-100, -70]
covid19_confirmed_raw |> 
  select(Lat, Long_) |> 
  filter(Lat >= 40 & Lat <= 45) |> 
  filter(Long_ > -100 & Long_ < -70)

# Find average latitude by State
covid19_confirmed_raw |> 
  group_by(Province_State) |>
  summarise(avg_lat = mean(Lat))

# Find average longitude by State
covid19_confirmed_raw |> 
  group_by(Province_State) |>
  summarise(avg_long = mean(Long_))




## ----------------------------------------------------------------------------
## STRINGR

df <- covid19_death_raw %>%
  # Reshape data from wide to long format, with dates as a single column
  pivot_longer(cols = "1/22/20":"3/9/23",
               names_to = "date",
               values_to = "cumulative_count") %>% as.data.frame()

total_counts <- aggregate(cumulative_count ~ Province_State + date, data = df[, c(6:8, 11:14)], sum)



## ----------------------------------------------------------------------------
## STRINGR EXAMPLE

## We only need to inspect the "Province_State" entries. We expect that the
## U.S. states and territories will be included. We confirm by matching
## the unique entries of "Province_State" and datasets::state.name.

unique(df$Province_State) %>% .[. %!in% datasets::state.name]


## They included entries for the two cruise ships. We do not need to consider
## these so we use str_detect() to remove rows where this information is
## included. Two methods using stringr are shown:

# Option #1: Use the Boolean test that detects the "Princess" string.
df_filtered <- df[!str_detect(df$Province_State, "Princess"), ]

# Option #2: Find the index that detects the "Princess" string and use the
#            indexes that do not contain that string to subset.
df_filtered <- df[str_which(df$Province_State, "Princess", negate = TRUE), ]


head(df_filtered)

## The "Combined_Key" variable combines the "Admin2", "Province_State", and
## "Country_Region". We want to generate a new column that does not include
## "Admin2". Two methods using stringr are shown:

# Option #1: Generate a new column by combining the desired columns with ", "
#            as the separator.
df_filtered$Combined_Key_2 <- str_c(df_filtered$Province_State, 
                                    df_filtered$Country_Region, sep = ", ")

# Option #2: Split the string only to the first observation of the string match.
str_split(df_filtered$Combined_Key, ",", simplify = TRUE, n = 2)[, 2] |> unique()

# While Option #2 works in principle, and is demonstrated here, we see that there
# are significant inconsistencies with formatting in the "Combined_Key" column
# For example, some names have spaces between commas and some lack spaces.
# Here we will only save the results of combining the two columns.



## Say we wish to specify that the Virgin Islands entries specify that results
## are for the U.S. territory only. We can replace specific strings exactly.
df_filtered[, c("Province_State", "Combined_Key_2")] <- 
  df_filtered[, c("Province_State", "Combined_Key_2")] |> (\(x) {
    sapply(x, function(x) 
      str_replace(x,  "Virgin Islands", "U.S. Virgin Islands"))
  })()



