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
## Description: 

## ----------------------------------------------------------------------------
## SET UP THE ENVIRONMENT
## renv() will install all of the packages and their correct version used here

renv::restore()

library(readr)
library(tidyr)
library(dplyr)
library(stringr)
library(lubridate)
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

## Death counts are expected to be more accurate to the daily count level. For
## this example, we will use the deaths data set, however, the confirmed
## cases data set can also be passed through the following series of operations
## with minor variations.
##
## First we will inspect the characteristics of our data set.

head(covid19_death_raw)
dim(covid19_death_raw)


## We see that new observations were added as new columns, so that each row
## represents values for one, unique county in the U.S. To tidy the data, we
## need to reshape the dates columns as added rows so that columns only
## represent variables while rows represent new observations. 
## 
## This can be done using pivot_longer().

# Find the start and end date of the new observation columns.
colnames(covid19_death_raw)[c(13, ncol(covid19_death_raw))]

covid19_death_raw_long <- 
  covid19_death_raw |> 
  pivot_longer(
    # Designate which columns need to be pivoted.
    cols = "1/22/20":"3/9/23", 
    # Name the variable storing pivoted columns.
    names_to = "date",
    # Name the variable stored in cell values.
    values_to = "cumulative_count"
  )


## Looking again at the top rows and dimensions of the long-form data set shows
## that our transformation was successful.

head(covid19_death_raw_long)
dim(covid19_death_raw_long)


## It is possible to do the reverse operation as pivot_long(). The following
## code demonstrates how to reoritent the code from a long to wide format.

covid19_death_raw_long |> 
  pivot_wider(
    # Which columns have new variable names
    names_from = date,
    # Column of values for new variables
    values_from = cumulative_count
  )




## ----------------------------------------------------------------------------
## DPLYR

## Part of the data cleaning process involves keeping the minimum variables
## necessary to be useful, without loosing information. We see that a number of
## the columns represent information that is already implied or not relevant.
## For example, UID, or the unique identifier for each row entry, no longer
## has meaning or contain information we need after pivoting the data long.
## 
## We will remove these necessary columns and adjust the remaining variable
## names so that they are clearer. The data dictionary for the raw
## data set can be found in the JHU CRC CSSEGISandData GitHub README file:
## https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data#field-description-1

colnames(covid19_death_raw_long)


## As an aside, the population column denotes one static representation of the
## U.S. population in that county. This value does not change over the entire
## span of time represented. This is not ideal, and it is not relevant to
## the analysis at hand. Students are encouraged to explore our own harmonized
## U.S. census data where they can better estimate population levels at the
## state level for various spans of time that can be found in our 
## JHU-CRC-Vaccinations GitHub page: https://github.com/ysph-dsde/JHU-CRC-Vaccinations
## 
## We can confirm this is true by examining the number of times a different
## population count is represented for unique counties.

expected_count         <- unique(covid19_death_raw_long$date) |> length()
diff_population_counts <- table(covid19_death_raw_long$Admin2, 
                                covid19_death_raw_long$Population, 
                                covid19_death_raw_long$Province_State) |> 
                          as.data.frame()

# The following Boolean test will be TRUE if only one population count is
# represented for each county over the span of time represented in the data set.
unique(diff_population_counts$Freq) %in% c(0, expected_count) |> all()


## Now we can subset the columns for the desired variables using select().

df_subset <- covid19_death_raw_long |> 
  select(Admin2, Province_State, Country_Region, Combined_Key, date, cumulative_count)

## We'll adjust the column names so that they are more intuitive.

colnames(df_subset) <- c("County", "Province_State", "Country_Region", "Combined_Key",
                         "Date", "Deaths_Count_Cumulative")


## We would like to see state- and country-level counts Currently, the
## data set only contains county-level counts. We calculate these values by
## summing the cumulative counts over entries that have been grouped by
## "Province_State" and "Date". Then, we do the same operation over all of
## the U.S. state entries that have been grouped by Date only.
## 
## First we start by calculating the state-level data from the county-level data.

counts_by_state <- df_subset |> 
  # Groups the table by unique entries in "Province_State" followed by "Date".
  group_by(Province_State, Date) |>
  # Calculate the cumulative deaths variable by summing over the grouped rows.
  # Note that .groups = "keep" will maintain the grouping for the summation.
  summarise(Deaths_Count_Cumulative = sum(Deaths_Count_Cumulative), .groups = "keep") |>
  # Mutate will generate new columns. These can be functions of existing columns
  # or static operations additions. For example, we can generate a new
  # "Combined_Key" for the state-level data that excludes counties using the
  # strinr concatenate function, str_c().
  mutate(Country_Region = "US", Combined_Key = str_c(Province_State, ", US"))


## Next we calculate the country-level data by summing over all of the U.S.
## state entries.

counts_by_country <- counts_by_state |> 
  # Filter subsets the data set by rows that match the condition. This will
  # subset the data set for entries that are U.S. states.
  filter(Province_State %in% datasets::state.name) |>
  # Groups the table by unique entries in "Date".
  group_by(Date) |>
  # Calculate the cumulative deaths variable by summing over the grouped rows.
  summarise(Deaths_Count_Cumulative = sum(Deaths_Count_Cumulative), .groups = "keep") |>
  # Generate new columns using mutate.
  mutate(Country_Region = "US", Combined_Key = "US")


## Now that we have our state- and country-level data, we need to combine them
## back into the main data set. bind_rows() is a similar row-add operation
## to do.call(), but it will fill missing columns with NA for any so that
## all unique variables are maintained.
##
## This package is not covered in this introductory workshop, but those 
## interested to find out more can review the package documentation: 
## https://dplyr.tidyverse.org/reference/bind_rows.html

df <- bind_rows(counts_by_country, counts_by_state, df_subset)
  
  
## We can confirm that this operation was successful by examining the first and
## last few rows.

head(df)
tail(df)




# Add county Deaths_Count_Cumulative# Add county_state variable
covid19_confirmed_raw |>
  mutate(county_state = paste0(Admin2, ",", Province_State)) |>
  # Select the county_state variable
  select(county_state)

# Filter for the state of Connecticut
covid19_confirmed_raw |> 
  filter(Province_State == "Connecticut")




## ----------------------------------------------------------------------------
## STRINGR

## 


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




## ----------------------------------------------------------------------------
## GGPLOT

## Now that we have completed tidying our data, we can clean the columns by 
## removing redundant information and reordering them. With the "Combined_Key", 
## we no longer need "Country_Region",  "Province_State", or "County". Notice 
## that select() will also reorder our columns.

df <- df |> select(Combined_Key, Date, Deaths_Count_Cumulative)


## Finally, we will confirm that our variables are set to the correct class.

sapply(df, class)

## Currently, "Date" is classified as a character. We can change the class to a 
## date using lubridate in tidyverse. This package is not covered in this 
## introductory workshop, but those interested to find out more can review the 
## package documentation: https://lubridate.tidyverse.org/
## 
## Notice that the data has been reported in mm/dd/yy format. Therefore, we
## use mdy() to correctly convert the character to date class.

df$Date <- mdy(df$Date)










