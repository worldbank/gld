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
code 	        <- file.path(clone, "gld/Support")


# Network Data -------
PHL           <- file.path(GLD, "GLD-Harmonization/551206_TM/PHL")








# Script Settings -------------------------------------------------

# eval_directory:         the corresponding object defined above that goes to a directory
#                         path of a country/economy within GLD shared drive
# 
# metadata_output_folder: the folder where you want the resulting metadata Rdata file
#                         to be saved. The file name itself you can edit at the end
#                       
# dta_to_rds: TRUE        if you need to import and convert all .dta files to Rds. This needs 
#                         to be done at least once. Once you run it set to TRUE once, you can set
#                         to FALSE to skip this stop and pull striaght from the Rds copies. Note that 
#                         the copying to Rds can take a long time.               

eval_directory          <- PHL
metadata_output_folder  <- file.path(PHL, "PHL_data/I2D2/Rdata")
dta_to_rds              <- FALSE 












                ##########>
                ##### > DATA WORK < ########
                                      #####>
                              



# Find all the survey rounds. --------------------------------------------------------
## we know things about the raw data files, so we can use that to help us locate them

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



# Import/Export an RDS file ----------------------------------------------------------
# Write a function that takes each survey round and writes a .RDS file in the same directory

# With an eye on memory, write a function that takes each file in the list above 
# and imports it, then exports it again

## function ----
make_rds <- function(s, r) {
  
  # import
  new_dta <- haven::read_dta(s)
  
  # save
  saveRDS(new_dta, file = r) # 
  
  # remove object for next cycle/memory?
  rm(new_dta)
}


## run function loop ----
# this loop will run through the function we defined 

# helper objects to simplify function call
## s_read   is a vector of .dta read paths 
## s_write  is a vector of cognate .Rds write paths matched to each read path

s_read  <- files_tib$dtapath  # 
r_write <- files_tib$rpath




## purrr function call ----
## we only need to run this if we need to write the .Rda files/if 
## dta_to_rds == TRUE 

if (dta_to_rds == TRUE) {
  
  map2(.x = s_read,   # loop through the Stata col to import the file
       .y = r_write,  # loop through the R path col in parallel to write the file
       .f = make_rds)
  
}





# Import all RDS files ------------------------------------------
# retroharmonize will take a list of file names/paths and import them all along with the
# metadata

## pull the list of surveys (.Rds files we just generated)
surveys <- files_tib %>%
  pull(rpath)



## read in the surveys
waves <- read_surveys(surveys,
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
# that data. However, in theory, from here we could do a lot of data manipulation from 
# here so it's sort of a waste to throw this away


save(
  metadata, documented_waves, files_tib,
  file = file.path(metadata_output_folder, "metadata.Rdata")
)



# thanks!
# https://stackoverflow.com/questions/21618423/extract-a-dplyr-tbl-column-as-a-vector
# https://stats.idre.ucla.edu/r/codefragments/read_multiple/