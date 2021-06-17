# survey_metadata.R
# generates a metadata file for all survey rounds in a directory.
# 
# Note, as of now, in order for this script to work, it has to import all dta files, then save them as 
# RDS, then import the RDS file. This means the code will create another folder in the shared directory
# with the RDS files. It will not edit the original .dta file, but simply "copy" it as an RDS. 
# Please know this.

library(tidyverse)
library(haven)
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








# Country/Economy Settings -------------------------------------------------
# This code is designed to only be run for one country/economy directory at a 
# time, so please chose one and the appropriate output folder where the .Rdata 
# file containing the metadata will go

# note: the "eval_directory" should be an object in the "network data" above
eval_directory          <- PHL
metadata_output_folder  <- file.path(PHL, "PHL_data/I2D2/Rdata")














          ##########>
          ##### > DATA WORK < ########
                                #####>
                              



# Find all the survey rounds. --------------------------------------------------------

## we know things about the raw data files, so we can use that to help us locate them
dirs <- list.dirs(eval_directory, 
                  recursive = TRUE
  
)

## we know they are all .dta files
files <- list.files(eval_directory,     
                    pattern = "\\.dta$", # "\\.dta$"
                    recursive = TRUE,   # search all sub folders
                    full.names = TRUE,  # list full file names
                    include.dirs = TRUE) # include the full file path


## we also know they are all in the "v01_M/Data/Stata" directory, 
## which allows us to separate them out from harmonized .dta files
## in files_tib

files_tib <- as_tibble(files)
files_tib <- 
  files_tib %>%
  filter( str_detect(files_tib$value, pattern = "v01_M/Data/Stata") == TRUE )


# make a directory for future RDS files 
files_tib <- 
  files_tib %>%
  separate(value, into = c("front", "back"), sep = "Stata", fill = "right", remove = FALSE) %>%
  separate(back, into = c("filename", "extension"), sep = "\\.") %>%
  mutate(r    = "R",
         rpath = paste0(front, r, filename, ".Rds")) %>%
  select(value, front, r, filename, rpath) %>%
  rename(dtapath = value)



## combine top and bottom to make single file path list object 
files_list <- 
  files_tib %>%
  pull(dtapath)

p <- file.path(files_list)
View(p)


# Import/Export an RDS file ----------------------------------------------------------
# Write a function that takes each survey round and writes a .RDS file in the same directory

# With an eye on memory, let's write a function that takes each file in the list above 
# and imports it, then exports it again

make_rds <- function(s, r) {
  
  # import
  new_dta <- haven::read_dta(s)
  
  # save
  saveRDS(new_dta, file = r) # 
  
  # remove object for next cycle/memory?
  rm(new_dta)
}

s_test <- files_tib$dtapath[1:3]
r_test <- files_tib$rpath[1:3]

map2(.x = s_test,  # loop through the Stata col to import the file
     .y = r_test,  # loop through the R path col in parallel to write the file
     .f = make_rds)



# Import all RDS files ------------------------------------------

## retroharmonize will take a list of file names/paths and import them all along with the
# metadata

## pull the list of surveys
surveys <- files_tib %>%
  pull(rpath)

surveys_test <- surveys[1:3]



## read in the surveys
waves <- read_surveys(surveys_test,
                      .f = "read_rds",
                      save_to_rds = FALSE)




# Extract Metadata ----------------------------------------------

## create wave documentation
documented_waves <- document_waves(waves)




## extract metadata 
metadata <- lapply(X = waves, FUN = metadata_create)
metadata <- do.call(rbind, metadata)





# save ------
# I'm not going to save the `waves` object because that's too big and we already have
# that data 


save(
  metadata, documented_waves, files_tib,
  file = file.path(metadata_output_folder, "metadata.Rdata")
)


# thanks!
# https://stackoverflow.com/questions/21618423/extract-a-dplyr-tbl-column-as-a-vector
# https://stats.idre.ucla.edu/r/codefragments/read_multiple/