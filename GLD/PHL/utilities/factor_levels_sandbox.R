# facotr_levels_sandbox.R
# A totally alpha script to try to harmonize factor labels across rounds within a survey year

library(tidyverse)
library(retroharmonize)
library(readxl)

# paths ----

  # user 
  
  user <- 5   # 1 
  

  
  # top folders 
  
  if (user == 5) {
    
    data		<- ""					# data folder
    GLD 		<- "Y:"					# set this to the letter the GLD drive is on your computer
    i2d2 	  <- "Z"					# set this to the letter the I2D2 drive is on your computer
    clone	  <- "C:/Users/WB551206/local/GitHub" # github/code top folder

  }
  
  
  if (user == 1) {
    
    data		<- ""					# data folder
    GLD 		<- ""					# set this to the letter the GLD drive is on your computer
    i2d2 	  <- ""					# set this to the letter the I2D2 drive is on your computer
    clone	  <- "C:/Users/..." # github/code top folder
    
  }
  
  
  # Same no matter the user 
    code 	        <- file.path(clone, "gld/GLD")
    yr2012        <- file.path(GLD, "GLD-Harmonization/551206_TM/PHL/PHL_2012_LFS") #  our directory
      yr2012data  <- file.path(yr2012, "PHL_2012_LFS_v01_M/Data/Stata")          # data directory 
      yr2012doc   <- file.path(yr2012, "PHL_2012_LFS_v01_M_v01_A_I2D2/Doc")      # documents 
    
    

# method 1: iecodebook  -----------------------------------------------------------------------
# using output from iecodebook xlsx.  

# I have already generated an output xlsx of all the data labels of all rounds from iecodebook. So
# The strategy here is to simply read in these four tabs (one for each round) directly and use 
# dplyr to find distinct/unique vectors. Then write an output xlsx of this object.


## import labels -------            
jan2012 <- read_xlsx(
  path = file.path(yr2012doc, "PHL_2012_append_template.xlsx"),
  sheet = "choices_JAN2012",
  col_names = TRUE
)      
   
apr2012 <- read_xlsx(
  path = file.path(yr2012doc, "PHL_2012_append_template.xlsx"),
  sheet = "choices_APR2012",
  col_names = TRUE
)  

jul2012 <- read_xlsx(
  path = file.path(yr2012doc, "PHL_2012_append_template.xlsx"),
  sheet = "choices_JUL2012",
  col_names = TRUE
) 

oct2012 <- read_xlsx(
  path = file.path(yr2012doc, "PHL_2012_append_template.xlsx"),
  sheet = "choices_OCT2012",
  col_names = TRUE
) 




## append ----
# simply, slowly, make a long version, obvs with dups first
long_2012 <- bind_rows(jan2012, apr2012, jul2012, oct2012)




## clean dups, find unique vector ---- 
# we want to determine the unqiue-ness across "list_name" and "value" only 
labs_2012 <- 
  long_2012 %>% 
  distinct(list_name, value, .keep_all = TRUE)




## anti-joins ---
## Let's anti-join with each of the original survey rounds to see


    
    
# method 2: retroharmonize --------------------------------------------------------------------
# retroharmonize provides a package to read directly from the .dta files. it may work?    
    
# read in raw dta files 
jan2012dta <- read_dta(file = file.path(yr2012data, "LFSjan12.dta"))
apr2012dta <- read_dta(file = file.path(yr2012data, "LFSapr12.dta"))
jul2012dta <- read_dta(file = file.path(yr2012data, "LFSjul12.dta"))
oct2012dta <- read_dta(file = file.path(yr2012data, "LFS OCT2012.dta"))



# directories
i2d2   <- dir(yr2012data)
rounds <- file.path(yr2012data, i2d2) # store 2012 i2d2 directory 

# use function to read in all surves into list object
i2d2_waves <- read_surveys(rounds, .f="read_dta", save_to_rds = FALSE) # example has "read_spss"

# give more id info to each object 
attr(i2d2_waves[[1]], "id") <- "PHL_2012_LFS_JAN"
attr(i2d2_waves[[2]], "id") <- "PHL_2012_LFS_APR"
attr(i2d2_waves[[3]], "id") <- "PHL_2012_LFS_JUL"
attr(i2d2_waves[[4]], "id") <- "PHL_2012_LFS_OCT"


# test if imported file is "survey_list"
is.survey(i2d2_waves[[1]]) 
is.survey(i2d2_waves)  # both false 


# try to import using this sister function 
test <- survey(
  df = jan2012dta,
  id = "JanLFS"
)

is.survey(test) # true. 



# documentation for metatdata 
documented_i2d2_waves <- document_waves(i2d2_waves)

print(documented_i2d2_waves)
    
