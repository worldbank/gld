
library(dplyr)
library(stringr)
library(tibble)

#=========================================================================#
# Step 1 - Create function to read in data --------------------------------
#=========================================================================#

read_data_isic_tables <- function(html) {
  
  # Define URL
  address <- url(html)
  
  # Read in data
  df <- read.table(file = address,
                   header = T,
                   sep = "\t",
                   stringsAsFactors=FALSE,
                   quote="",
                   fill=FALSE)
  
  # Convert to tibble
  df <- tibble::as_tibble(df)
  
  # Set col name
  names(df) <- "col"
  
  df
  
}

#=========================================================================#
# Step 2 - Read in data for all cases -------------------------------------
#=========================================================================#

isic_2 <- read_data_isic_tables("https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/ISIC_Rev_2_english_structure.txt")
isic_3 <- read_data_isic_tables("https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/ISIC_Rev_3_english_structure.txt")
isic_3.1 <- read_data_isic_tables("https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/ISIC_Rev_3_1_english_structure.txt")
isic_4 <- read_data_isic_tables("https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/ISIC_Rev_4_english_structure.Txt")


#=========================================================================#
# Step 3 - Convert into useable data --------------------------------------
#=========================================================================#


  #---------#
  # ISIC 2
  #---------#

isic_2 <- isic_2 %>% 
  # Separate at space
  tidyr::separate(col = col, 
                  into = c('Code', 'Label'), 
                  sep = " ", 
                  extra = "merge") %>%
  dplyr::mutate(
    # Tri whitespace
    Label = stringr::str_trim(Label),
    # Pad code if not a letter
    Code = ifelse(Code %in% LETTERS, Code, str_pad(Code, 4, side = "right", pad = "0")))

# Deal with special case of
# 311-312       Food manufacturing
isic_2 <- isic_2 %>% filter(Code != "311-312")

# Manually add rows
adder <- tibble::tibble(Code = c("3110", "3120"), Label = "Food manufacturing")
  
# Bind
isic_2 <- dplyr::bind_rows(isic_2, adder) %>% arrange(Code)

isic_2$Version = "isic_2"

  #---------#
  # ISIC 3
  #---------#

isic_3 <- isic_3 %>% 
  dplyr::mutate(
    # Extract first block until space
    Code  = stringr::str_extract(col, "^[^\\s]+"),
    # Extract second block thereafter
    Label = stringr::str_extract(col, "\\s.+"),
    # Trim whitespace
    Label = stringr::str_trim(Label),
    # Pad code if not a letter
    Code = ifelse(Code %in% LETTERS, Code, str_pad(Code, 4, side = "right", pad = "0"))) %>%
  # Drop unnecessary column "col"
  dplyr::select(-col)

isic_3$Version = "isic_3"

  #---------#
  # ISIC 3.1
  #---------#

isic_3.1 <- isic_3.1 %>% 
  # Separate at comma
  tidyr::separate(col = col, 
                  into = c('Code', 'Label'), 
                  sep = ",", 
                  extra = "merge") %>%
  # Get rid of extra quotation marks, pad
  mutate(Code = gsub('"', '', Code),
         Label = gsub('"', '', Label),
         Code = ifelse(Code %in% LETTERS, Code, stringr::str_pad(Code, 4, side = "right", pad = "0")))

isic_3.1$Version = "isic_3.1"

  #---------#
  # ISIC 4
  #---------#

isic_4 <- isic_4 %>% 
  # Separate at comma
  tidyr::separate(col = col, 
                  into = c('Code', 'Label'), 
                  sep = ",", 
                  extra = "merge") %>%
  # Get rid of extra quotation marks, pad
  mutate(Code = gsub('"', '', Code),
         Label = gsub('"', '', Label),
         Code = ifelse(Code %in% LETTERS, Code, stringr::str_pad(Code, 4, side = "right", pad = "0")))

isic_4$Version = "isic_4"


#=========================================================================#
# Step 4 - Bind all, reduce, save -----------------------------------------
#=========================================================================#

isic_codes <- bind_rows(isic_2, isic_3, isic_3.1, isic_4)

# Cases like
# 41            Collection, purification and distribution of water
# 410           Collection, purification and distribution of water
# 4100          Collection, purification and distribution of water
# cause, when padding, that we have code 4100 three times
# Need to reduce, keep last instance

isic_codes <- isic_codes %>% 
  group_by(Version, Code) %>% 
  slice_tail(n = 1)

write.csv(isic_codes, 
          file = "C:/Users/wb529026/OneDrive - WBG/Documents/GLD/isic_codes.txt",
          row.names = F)
