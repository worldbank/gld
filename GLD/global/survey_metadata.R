# survey_metadata.R
# generates a metadata file for all survey rounds in a directory.
# 
# Note, as of now, in order for this script to work, it has to import all dta files, then save them as 
# RDS, then import the RDS file. This means the code will create another folder in the shared directory
# with the RDS files. It will not edit the original .dta file, but simply "copy" it as an RDS. 
# Please know this.

library(tidyverse)
library(retroharmonize)




# paths ----

# user 

user <- 5   # tom



## top folders --------------------------
## This has to be different for each user based on where you have your Github and network
## drive on your computer/VDI. 

if (user == 5) {
  
  data		<- ""					# data folder
  GLD 		<- "Y:"					# set this to the letter the GLD drive is on your computer
  i2d2 	  <- "Z:"					# set this to the letter the I2D2 drive is on your computer
  clone	  <- "C:/Users/WB551206/local/GitHub" # github/code top folder
  
}


if (user == 4) {
  
  data		<- ""					# data folder
  GLD 		<- ""					# set this to the letter the GLD drive is on your computer
  i2d2 	  <- ""					# set this to the letter the I2D2 drive is on your computer
  clone	  <- "C:/Users/..." # github/code top folder
  
}

if (user == 3) {
  
  data		<- ""					# data folder
  GLD 		<- ""					# set this to the letter the GLD drive is on your computer
  i2d2 	  <- ""					# set this to the letter the I2D2 drive is on your computer
  clone	  <- "C:/Users/..." # github/code top folder
  
}

if (user == 2) {
  
  data		<- ""					# data folder
  GLD 		<- ""					# set this to the letter the GLD drive is on your computer
  i2d2 	  <- ""					# set this to the letter the I2D2 drive is on your computer
  clone	  <- "C:/Users/..." # github/code top folder
  
}

if (user == 1) {
  
  data		<- ""					# data folder
  GLD 		<- ""					# set this to the letter the GLD drive is on your computer
  i2d2 	  <- ""					# set this to the letter the I2D2 drive is on your computer
  clone	  <- "C:/Users/..." # github/code top folder
  
}





# Shared file Paths --------------------------------------------------------
# there's no need to change for each user, since all will be the same. Only add
# new file paths if you want to add new folders etc.


# Code ------------------------
code 	        <- file.path(clone, "gld/GLD")


# Network Data -------
PHL           <- file.path(GLD, "GLD-Harmonization/551206_TM/PHL")





          ##########>
          ##### > DATA WORK < ########
                                #####>
                              



# Find all the survey rounds. --------------------------------------------------------

## we know things about the raw data files, so we can use that to help us locate them

## we know they are all .dta files
files <- list.files(PHL,    # replace with directory from above 
                    pattern = "\\.dta$", # "\\.dta$"
                    recursive = TRUE,   # search all sub folders
                    include.dirs = TRUE) # include the full file path


## we also know they are all in the "v01_M/Data/Stata" directory, 
## which allows us to separate them out from harmonized .dta files
## in files_tib

files_tib <- as_tibble(files)
files_tib <- 
  files_tib %>%
  filter( str_detect(files_tib$value, pattern = "v01_M/Data/Stata") == TRUE )



## the next set of commands work better if the files are in list not tibble
files_list <- as.character(files_tib)




# Import/Export an RDS file ----------------------------------------------------------
# Write a function that takes each survey round and writes a .RDS file in the same directory

