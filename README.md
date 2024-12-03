# Getting Started with Git and GitHub

## About The Coffee, Cookie and Coding $\left(C^3\right)$ Workshops

Yale's Public Health Data Science and Data Equity (DSDE) team created this workshop series for Public Health and Biostatistics masters-level students at Yale. They are designed to help learners effectively leverage computational tools and analytical methods in their educational and professional endeavors. You can find out more about past and upcoming tutorials on our YouTube (coming soon) and [website](https://ysph.yale.edu/public-health-research-and-practice/research-centers-and-initiatives/public-health-data-science-and-data-equity/events/).


## About Workshop

**Workshop Title:** &nbsp; A Journey into the World of tidyverse

**Date:** &emsp;&emsp;&emsp;&emsp;&emsp;&nbsp; Monday December $2^{\text{nd}}$, 2024

Upon completing the workshop, you will be able to:
- Read, clean and wrangle data using tidyverse.
- Learn how to apply dplyr, tidyr, and stringr.
- Make an interpretable plot using ggplot2.

You can find out more about past and upcoming tutorials on our YouTube (coming soon) and [website](https://ysph.yale.edu/public-health-research-and-practice/research-centers-and-initiatives/public-health-data-science-and-data-equity/events/). If you are affiliated with Yale, you can set up an office hour appointment with one of the data scientists ([Bookings Page](https://outlook.office365.com/owa/calendar/DataScienceDataEquityOfficeHours@yale.edu/bookings/)).

## About Repository

This is the only repository associated with this workshop. It contains all of the relevant code, the data set, and a PDF of the slide deck that was used in the workshop.

### Overview Of Contents

- **For the worked through example:** `Worked Through Example.qmd`. Multiple associated files are generated when rendering the Quarto document (HTML and a directory).
- **For the challenge questions:** At the end of `Worked Through Example.qmd`
- **For the challenge questions answers:** `Answers to Challenge Questions.R`
- **Data set for the above scripts:** `COVID-19 Deaths_Cleaned_Aggregated by Month.csv`
- **For cleaning the raw data:** `Cleaning Script_JHU CRC COVID-19 Deaths.R`
- **R version:** 4.4.1
- ``renv`` is included to reproduce the environment.

**NOTE:** The cleaning script has already been run to generate the necessary files called in the worked through example and challenge questions. Users of this repository will not need to rerun that script unless they wish to generate the deaths counts as daily reported values on their local device.

## Using this Repository

### Making a Clean-Break Copy

The repository needs to be copied into your personal GitHub for the workshop in a manner that will decouple its operations from this original repository. Please use one of the following two methods to do this.

**METHOD 1:** Copying Using GitHub Importer

**NOTE:** This method is not a Fork. You can learn more about GitHub Importer [here](https://docs.github.com/en/migrations/importing-source-code/using-github-importer/importing-a-repository-with-github-importer).

1. Under the "Repositories" tab of your personal GitHub page, selecte the "New" button in the top-right corner. This will start the process of starting a new repository.

2. At the top of the page is a hyperlink to import a repository. Open that link ([GitHub Importer](https://github.com/new/import)).

3. Paste the URL of this repository when prompted. No credentials are required for this action.

4. Adjust the GitHub account owner as needed and create the name for the new repository. We recommend initially setting the repository to Private.

5. Proceed with cloning the newly copied repository.

**METHOD 2:** Copying Using Terminal

These directions follow GitHub's [duplicating a repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/duplicating-a-repository) page.

1. [Create a new](https://github.com/new) GitHub repository ([further documentation](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository)).
   
   **NOTE:** Do not use a template or include a description, README file, .gitignore, or license. Only adjust the GitHub account owner as needed and create the name for the new repository. We recommend initially setting the repository to Private.
   
2. Open Terminal.

3. Navigate to the file location you want to store the repository copy.
   ```
   cd "/file_location/"
   ```

4. Clone a bare copy of the repository.
   ```
   # using SSH
   git clone --bare git@github.com:ysph-dsde/A-Journey-Into-The-World-of-tidyverse-Workshop.git
   
   # or using HTTPS
   git clone --bare https://github.com/ysph-dsde/A-Journey-Into-The-World-of-tidyverse-Workshop.git
   ```
   
5. Open the project file.
   ```
   cd "A-Journey-Into-The-World-of-tidyverse-Workshop.git"
   ```
   
6. Push a mirror of the cloned Git file to your newly created GitHub repository.
   ```
   # using SSH
   git push --mirror git@github.com:EXAMPLE-USER/NEW-REPOSITORY.git

   # or using HTTPS
   git push --mirror https://github.com/EXAMPLE-USER/NEW-REPOSITORY.git
   ```

7. Delete the bare cloned file used to create a new remote repository.
   ```
   cd ..                                                              # Go back one file location
   rm -rf A-Journey-Into-The-World-of-tidyverse-Workshop.git          # Delete the bare clone
   ```
8. Proceed with cloning the newly copied repository.

### Cloning the Copied Repository

Now that you have copied this repository into your own GitHub, you are ready to proceed with a standard clone to your local device.
  
1. Open Terminal.

2. Navigate to the file location you want to store the repository copy.
   ```
   cd "/file_location/"
   ```
3. Clone the newly created GitHub repository.
   ```
   # using SSH
   git clone git@github.com:EXAMPLE-USER/NEW-REPOSITORY.git

   # or using HTTPS
   git clone https://github.com/EXAMPLE-USER/NEW-REPOSITORY.git
   ```

4. **OPTIONAL:** You can reset the repository history, which will clear the previous commits, by running the following block of code (Source: [StackExchange by Zeelot](https://stackoverflow.com/questions/9683279/make-the-current-commit-the-only-initial-commit-in-a-git-repository)).
    ```
    git checkout --orphan tempBranch         # Create a temporary branch
    git add -A                               # Add all files and commit them
    git commit -m "Reset the repo"
    git branch -D main                       # Deletes the main branch
    git branch -m main                       # Rename the current branch to main
    git push -f origin main                  # Force push main branch to GitHub
    git gc --aggressive --prune=all          # Remove the old files
    ```

### Initializing the Environment

The workshop example `Worked Through Example.qmd` uses a pre-cleaned data set that has been aggregated to montly counts, and it does not include the code for initializing the environment with `renv()`. If users are experiencing problems installing the appropriate package versions that were used to generate the example, they will need to follow the provided steps below to install all called for packages to the project folder.

1. Open the newly cloned file.
2. Launch the project by opening `A-Journey-Into-The-World-of-tidyverse-Workshop.Rproj`.
3. Open `Cleaning Script_JHU CRC COVID-19 Deaths.R`.
4. In the R console, activate the enviroment by runing:
    ```
    renv::restore()
    ```

   **NOTE:** You may need to run ``renv::restore()`` twice to initialize and install all the packages listed in the lockfile. Follow the prompts that comes up and accept intillation of all packages. You are ready to proceed when running ``renv::restore()`` gives the output ``- The library is already synchronized with the lockfile.``. You can read more about ``renv()`` in their [vignette](https://rstudio.github.io/renv/articles/renv.html).

## About Original Data Source

The [Johns Hopkins Coronavirus Resource Center](https://coronavirus.jhu.edu/) (JHU CRC) tracked and compiled global COVID-19 pandemic data from January 22, 2020 and March 10, 2023. These data are publically available through their two GitHub repositories. We imported cumulative COVID-19 death counts for the U.S. from their [CSSE GitHub](https://github.com/CSSEGISandData/COVID-19) GitHub repository. The raw data used in the analysis script can be found in the COVID-19/csse_covid_19_data
/csse_covid_19_time_series subdirectory ([original source](https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv)).

The data dictionary provided by the JHU CRC can be found in their CSSEGISandData GitHub subdirectory where the raw data was sourced ([data dictionary](https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data#field-description-1)). Users interested in including population counts are encouraged to explore our own harmonization of the U.S. Census Bureau's 2010 to 2019 population projections with 2020 to 2023 vintages ([U.S. Census Data 2010 to 2023](https://github.com/ysph-dsde/JHU-CRC-Vaccinations/tree/main/Population%20Estimates%20and%20Projections)).




