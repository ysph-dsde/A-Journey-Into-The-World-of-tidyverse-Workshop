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
## Description: In this workshop, we will explore the tidyverse collection of R
##              packages to clean, analyze, and visualize COVID-19 daily death 
##              counts in the United States. Additionally, we will make our 
##              visualizations interactive using the plotly() package. This
##              script is used to clean the data using the concepts taught in
##              the workshop. Some steps will be advanced for beginners and
##              covers additional topics not introduced in the workshop.
## 
## Sections of the document:
##      - SET UP THE ENVIRONMENT
##      - TIDYR
##      - DPLYR
##      - STRINGR
##      - FORMATTING AND CALCULATIONS
##      - GGPLOT AND PLOTLY


## ----------------------------------------------------------------------------
## SET UP THE ENVIRONMENT
## renv() will install all of the packages and their correct version used here

renv::restore()

library(readr)      # For reading data
library(tidyr)      # For tidying data 
library(dplyr)      # For data manipulation 
library(stringr)    # For string manipulation
library(ggplot2)    # For creating static visualizations
library(lubridate)  # For date manipulation 
library(plotly)     # For interactive plots


'%!in%' <- function(x,y)!('%in%'(x,y))




## ----------------------------------------------------------------------------
## LOAD IN THE DATA

## This data is from the COVID-19 Data Repository by the Center for Systems 
## Science and Engineering (CSSE) at Johns Hopkins University (JHU), GitHub 
## CSSEGISandData. Additional details can be found in the project repository's 
## main directory's README file.

## We will fetch COVID-19 death data from a public GitHub repository and take 
## a look at its structure.
## -   read_csv(): Reads the CSV file from the URL into a data frame.

covid19_death_url <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/refs/heads/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv"
covid19_death_raw  <- read_csv(file = covid19_death_url, show_col_types = FALSE)




## ----------------------------------------------------------------------------
## TIDYR

## Death counts are expected to be more accurate to the daily count level. For
## this example, we will use the deaths data set, however, the confirmed
## cases data set from the same repository can be passed through the following
## series of operations with minor variations.
##
## First we will inspect the characteristics of our data set.
## -   head(): Displays the first few rows of the data set.

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
  # Step 1: Convert wide-format date columns to long-format.
  pivot_longer(
    # Designate which columns need to be pivoted.
    cols = "1/22/20":"3/9/23", 
    # Name the variable storing pivoted columns.
    names_to = "date",
    # Name the variable stored in cell values.
    values_to = "cumulative_count"
  ) |> 
  # Step 2: Remove grouping to work with the full data frame again.
  ungroup() |> 
  # Step 3: Change table format to "data frame" for convenience.
  as.data.frame()


## Looking again at the top rows and dimensions of the long-form data set shows
## that our transformation was successful.

head(covid19_death_raw_long)
dim(covid19_death_raw_long)


## It is possible to do the reverse operation as pivot_long(). The following
## code demonstrates how to reorient the code from a long to wide format.

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
## We will remove these unnecessary columns and adjust the remaining variable
## names so that they are clearer. The data dictionary for the raw data set can
## be found in the JHU CRC CSSEGISandData GitHub README file:
## https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data#field-description-1

colnames(covid19_death_raw_long)


## As an aside, the population column denotes one static representation of the
## U.S. population in that county. This value does not change over the entire
## span of time represented. This is not ideal, and it is not relevant to
## the analysis at hand. Students are encouraged to explore our own harmonized
## U.S. census data where they can better estimate population levels at the
## state level for various spans of time. This can be found in our 
## JHU-CRC-Vaccinations GitHub page: https://github.com/ysph-dsde/JHU-CRC-Vaccinations
## 
## We can confirm that our interpretation of the "Population" column is true by 
## examining the number of times a different population count is represented 
## for unique counties.
 
expected_count         <- unique(covid19_death_raw_long$date) |> length()
diff_population_counts <- table(covid19_death_raw_long$Admin2, 
                                covid19_death_raw_long$Population, 
                                covid19_death_raw_long$Province_State) |> 
                          as.data.frame()


# The following Boolean test will be TRUE if only one population count is
# represented for each county over the span of time represented in the data set.
# The function all() is going to check the vector of Boolean results and confirm
# if all of the Boolean values are TRUE. If they are, the results will say "TRUE".

unique(diff_population_counts$Freq) %in% c(0, expected_count) |> all()


## Now we can subset the columns for the desired variables using select().

df_subset <- covid19_death_raw_long |> 
  select(Admin2, Province_State, Country_Region, Combined_Key, 
         date, cumulative_count)

## We'll adjust the column names so that they are more intuitive.

colnames(df_subset) <- c("County", "Province_State", "Country_Region", 
                         "Combined_Key", "Date", "Deaths_Count_Cumulative")


## We would like to see state- and country-level counts Currently, the
## data set only contains county-level counts. We calculate these values by
## summing the cumulative counts over entries that have been grouped by
## "Province_State" and "Date". Then, we do the same operation over all of
## the U.S. state entries that have been grouped by "Date" only.
## 
## First we start by calculating the state-level data from the county-level data.

counts_by_state <- df_subset |> 
  # Step 1: Groups the table by unique entries in "Province_State" followed 
  #         by "Date".
  group_by(Province_State, Date) |>
  # Step 2: Summing "Deaths_Count_Cumulative" over the grouped rows. Note that 
  #         .groups = "keep" will maintain the grouping for the summation.
  summarise(Deaths_Count_Cumulative = sum(Deaths_Count_Cumulative), .groups = "keep") |>
  # Step 3: Mutate will generate new columns. These can be functions of existing 
  #         columns or static operations. For example, we can generate a new
  #         "Combined_Key" for the state-level data that excludes counties 
  #         using the stringr concatenate function, str_c().
  mutate(Country_Region = "US", Combined_Key = str_c(Province_State, ", US")) |> 
  # Step 4: Remove grouping to work with the full data frame again
  ungroup()


## Next we calculate the country-level data by summing over all of the U.S.
## state entries.

counts_by_country <- counts_by_state |> 
  # Step 1: Filter subsets the data set by rows that match the condition. This 
  #         will subset the data set for entries that are U.S. states.
  filter(Province_State %in% datasets::state.name) |>
  # Step 2: Groups the table by unique entries in "Date".
  group_by(Date) |>
  # Step 3: Calculate the cumulative deaths variable by summing over the 
  #         grouped rows.
  summarise(Deaths_Count_Cumulative = sum(Deaths_Count_Cumulative), .groups = "keep") |>
  # Step 4: Generate new columns using mutate.
  mutate(Country_Region = "US", Combined_Key = "US") |> 
  # Step 5: Remove grouping to work with the full data frame again
  ungroup()


## Now that we have our state- and country-level data, we need to combine them
## back into the main data set. bind_rows() is a tidyverse function that is 
## similar to do.call(), but it will also fill missing columns with NA so that
## the maximum number of uniquely defined variables are maintained.
##
## This package is not covered in this introductory workshop, but those 
## interested to find out more can review the package documentation: 
## https://dplyr.tidyverse.org/reference/bind_rows.html

df <- bind_rows(counts_by_country, counts_by_state, df_subset) %>% as.data.frame()


## We can confirm that this operation was successful by examining the first and
## last few rows.

head(df)
tail(df)




## ----------------------------------------------------------------------------
## STRINGR

## After completing bulk data cleaning operations, like the ones completed above,
## it is good practice to examine variable classifications and nomenclature
## before any calculations. For example, if you have a variable for the sex
## of a participant, you will want to confirm that all entries of that variable
## say "M" and "F" for Male and Female, respectively. You might also need to
## confirm that zero's are not being used in place of NA's when the value is
## not determined.
## 
## In this data set, we are going to assume the county-level entries are correct.
## Therefore, we only need to inspect "Province_State". We expect that the
## U.S. states and territories will be included. We can examine this by matching
## unique entries of "Province_State" and datasets::state.name.

unique(df$Province_State) %>% .[. %!in% datasets::state.name]


## Notice that there are "NA's". This should be correct, since the country-level
## counts are NA at the state-level. We can confirm this by showing all
## "Combined_Key" entries are "US" for rows with "Province_State" = NA's.

df[df$Province_State %in% NA, "Combined_Key"] |> unique()


## In addition to the District of Columbia and five U.S. territories, there
## are entries for two cruise ships. These are not relevant to our analysis,
## and so we exclude them using str_detect() or str_which() to find strings
## with "Princess" in them. These two methods using stringr are shown:

# Option #1: Use the Boolean test that detects the "Princess" string.
df_filtered <- df[!str_detect(df$Province_State, "Princess"), ]

# Option #2: Find the index that detects the "Princess" string and use the
#            indexes that do not contain that string to subset.
df_filtered <- df[str_which(df$Province_State, "Princess", negate = TRUE), ]


## Doing this removes the following number of rows from the larger data set.

nrow(df) - nrow(df_filtered)


## The "Combined_Key" variable combines "County", "Province_State", and
## "Country_Region". Earlier the in code, we generated the new "Combined_Key"
## entries for the state- and country-level data using mutate() and str_c().
## Assume we only have the county-level data and wish to generate the
## state- and country-level "Combined_Key" variable. We can do this in
## two ways: str_c() or str_split().
##
## For this example we will subset the data by county-level information only. We
## use str_count() to represent the number of times a string pattern is detected
## within any given string. County-level data will have two commas, so this is
## one method we can use to subset our data.

df_county <- df_filtered[str_count(df_filtered$Combined_Key, ",") == 2, ]

# Option #1: Generate a new column by combining the desired columns with ", "
#            as the separator.
str_c(df_county$Province_State, df_county$Country_Region, sep = ", ")

# Option #2: Split the string only to the first observation of the string match.
str_split(df_county$Combined_Key, ",", simplify = TRUE, n = 2)[, 2] |> 
  str_trim(side = "both") |> unique()

## While Option #2 works in principle, and is demonstrated here, we see that
## there are significant inconsistencies with formatting in the "Combined_Key"
## column. For example, some names have spaces between commas and some lack
## spaces. We can reconcile these problems by regenerating the "Combined_Key"
## for county-level entries in the main data set.

index = which(str_count(df_filtered$Combined_Key, ",") == 2)

df_filtered[index, "Combined_Key"] <- str_c(df_filtered[index, "County"], 
                                            df_filtered[index, "Province_State"], 
                                            df_filtered[index, "Country_Region"], 
                                            sep = ", ")

# To confirm this worked, we can rerun the str_split() command and see that
# there are no more duplicated entries detected on account of formatting
# variations.
str_split(df_filtered$Combined_Key, ",", simplify = TRUE, n = 2)[, 2] |> 
  str_trim(side = "both") |> unique()


## Say we wish to specify that the Virgin Islands entries only reflect results
## for the U.S. territory. We can replace specific strings exactly using
## str_replace().

# Going forward, we only require the "Combined_Key" variable, as "Country_Region",
# "Province_State", and "County" information are succinctly represented there.
# We can adjust the "Virgin Islands" entries for that column only.

df_filtered[, "Combined_Key"] <- str_replace(df_filtered[, "Combined_Key"],  "Virgin Islands", "U.S. Virgin Islands")

## It is possible to adjust multiple columns at once. Notice that with the
## base pipe "|>" the standard placeholder "_" does not move information into
## the sapply() function. To fix this, we wrap the sapply() pipe level and
## specify a placeholder for the values being passed from the left-side
## to sapply(). In this scenario, we are calling that information "x". 
##
## sapply() is one of a few useful functions that repeat operations over 
## columns, rows, or lists. sapply() will only apply the function over a
## data frames columns.

# Identify the row indices where "Virgin Islands" is detected in column
# "Province_State".
index = str_which(df_filtered[, c("Province_State")], "Virgin Islands")

df_filtered[, c("Province_State", "Combined_Key")] |> 
  # Define the wrapper of this pipe-level and specify the information from
  # the left to be "x".
  (\(x) {
    # Apply the str_replace() function over "Province_State" and "Combined_Key".
    sapply(x, function(y) 
      str_replace(y,  "Virgin Islands", "U.S. Virgin Islands"))
  })() |> 
  # Show that the changes have been completed.
  _[index[1:15], ]




## ----------------------------------------------------------------------------
## FORMATTING AND CALCULATIONS

## Now that we have completed tidying our data, we can clean the columns by 
## removing redundant information and reorder them. With the "Combined_Key", 
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



## sort the rows for by dates

## confirm monotonically increasing

## back calculate the daily counts



## ----------------------------------------------------------------------------
## GGPLOT AND PLOTLY











