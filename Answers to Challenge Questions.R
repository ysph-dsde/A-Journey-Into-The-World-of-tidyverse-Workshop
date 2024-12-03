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
## renv() will install all of the packages and their correct version used here

renv::restore()

library(readr)      # For reading in the data
library(tidyr)      # For tidying data 
library(dplyr)      # For data manipulation 
library(stringr)    # For string manipulation
library(ggplot2)    # For creating static visualizations
library(lubridate)  # For date manipulation


# Function to select "Not In"
'%!in%' <- function(x,y)!('%in%'(x,y))




## ----------------------------------------------------------------------------
## LOAD IN THE DATA

















