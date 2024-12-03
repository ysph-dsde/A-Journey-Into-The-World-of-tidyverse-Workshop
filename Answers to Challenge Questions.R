## ----------------------------------------------------------------------------
## From Yale's Public Health Data Science and Data Equity (DSDE) Team
##
## Workshop: A Journey Into The World of tidyverse
## Authors:  Shelby Golden, M.S. and Howard Baik, M.S.
## Date:     2024-12-02
## 
## R version:    4.4.1
## renv version: 1.0.11
## 
## Description: 


## ----------------------------------------------------------------------------
## SET UP THE ENVIRONMENT
## renv() will install all of the packages and their correct version used here.

renv::restore()

library(readr)      # For reading in the data
library(tidyr)      # For tidying data 
library(dplyr)      # For data manipulation 
library(stringr)    # For string manipulation


# Function to select "Not In"
'%!in%' <- function(x,y)!('%in%'(x,y))




## ----------------------------------------------------------------------------
## LOAD IN THE DATA

## For the solutions, the cleaned data set that is aggregated by monthly counts
## is loaded.

# Read COVID-19 death data
cleaned_url <- "https://raw.githubusercontent.com/ysph-dsde/A-Journey-Into-The-World-of-tidyverse-Workshop/refs/heads/main/Data%20Sets/COVID-19%20Deaths_Cleaned_Aggregated%20by%20Month.csv"
cleaned     <- read_csv(file = cleaned_url) #, show_col_types = FALSE)


# Select the columns we need and adjust the column names.
df <- cleaned |>
  select(Combined_Key, Month, Deaths_Count_Daily) |>
  # Change the column names using a pipe syntax. The row-equivalent is 
  # `rownames<-`(), and is often used to clear row names.
  `colnames<-`(c("Combined_Key", "Month", "Deaths_Count"))


## The cleaned data set from the `Cleaning Script_JHU CRC COVID-19 Deaths.R`
## file drops the county-, state-, and country-level columns and retains the
## "Combined_Key" only. We will want to regenerate those columns so they resemble
## the output from the workshop cleaning steps.

# Generate an empty data frame that will be filled.
empty_data <- data.frame("County" = rep(NA, nrow(df)), 
                         "Province_State" = rep(NA, nrow(df)), 
                         "Country_Region" = rep("US", nrow(df)))

# Combine the empty data frame into the main one.
df <- cbind(df[, 1, drop = FALSE], empty_data, df[, 2:ncol(df)])

for(i in 1:2) {
  # Search for which index corresponds with the county- or state-level of information.
  index = which(str_count(df$Combined_Key, ",") == i)
  
  if(i < 2) {
    # When the index indicates state-level, only fill in the "Province_State"
    # variable.
    df[index, "Province_State"] <- df[index, "Combined_Key"] |> 
      str_split(",", simplify = TRUE, n = 2) |> 
      _[, 1]
    
  } else{
    # When the index indicates county-level, fill in both the "Province_State"
    # and "County" columns.
    split_result <- df[index, "Combined_Key"] |> 
      str_split(",", simplify = TRUE, n = 3)
    
    df[index, "County"] <- split_result |> _[, 1]
    
    df[index, "Province_State"] <- split_result |> _[, 2] |>
      str_trim(side = "both")
  }
}


## Now we are ready to review those solutions.
head(df)


## ----------------------------------------------------------------------------
## SOLUTIONS

## 1.  Filter the `df` data set to include only rows from 2021.

covid19_death_2021 <- df |> 
  filter(Month >= "2021-01-01" & Month <= "2021-12-31")




## 2.  With the data set filtered for rows from 2021, determine the day with the 
##     highest death count along with the corresponding count.

covid19_death_2021 |> 
  filter(Deaths_Count == max(covid19_death_2021$Deaths_Count))




## 3.  We want to see how many counties called "Adams" are represented in the 
##     data set.
##        a)  Subset the data set by string matches in `County` and find how 
##            many rows you see. Remember that each county is expected to have 
##            39 different dates reported.
##        b)  Table your subset results by `County` and `Province_State`. Does 
##            this change the answer you got from part a?


# part a
df_adams_counties <- df[str_detect(df$Combined_Key, "Adams"), ]
str_c("There are ", nrow(df_adams_counties)/39, " counties called Adams in the US.")

# part b
table(df_adams_counties$County, df_adams_counties$Province_State)










