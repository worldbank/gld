# facotr_levels_sandbox.R
# A totally alpha script to try to harmonize factor labels across rounds within a survey year

library(tidyverse)

# paths ----

  # user 
  
  user <- 5   # 1 
  

  
  # top folders 
  
  if (user == 5) {
    
    data		<- ""					# data folder
    GLD 		<- "Y"					# set this to the letter the GLD drive is on your computer
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
    code 	 <- file.path(clone, "gld/GLD")
  
    
    

# method 1: iecodebook  -----------------------------------------------------------------------
# using output from iecodebook xlsx.  

    
