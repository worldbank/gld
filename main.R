# main.R
# establishes working directories etc for each user 


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
  PHL_meta    <- file.path(PHL, "PHL_data/I2D2/Rdata/metadata.Rdata")
  PHL_labels  <- file.path(PHL, "PHL_data/variable_label_tables.Rdata")

ZWE           <- file.path(GLD, "GLD-Harmonization/551206_TM/ZWE")
  ZWE_meta    <- file.path(ZWE, "ZWE_data/GLD/Rdata/metadata.Rdata")
  ZWE_sum     <- file.path(ZWE, "ZWE_data/GLD/Rdata/ZWE_2019_summary.Rdata")


