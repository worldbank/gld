# international_codes.R
# matches isic, isco, isced codes to PHL LFS survey data
# 
# 
# This script assumes you've run main.R first 
# 
# The main purpose of this script is to match isic (industry), 
# isco (occupation) and isced (education) codes to produce 
# either 
#   - tables, or 
#   - easily-writable in-script code that covnerts the raw data to ISIC/ISCO etc 
# 
# Most of the findings here will be docuements in "Industry_Occupation Codes.md" in 
# the "Country Survey Details" Folder for the Philippines

library(tidyverse)
library(stringr)
library(pdftools)


load(PHL_meta)
load(PHL_labels)

psic_path <- file.path(PHL, "PHL_docs/International Codes/PSA_PSIC_2009.pdf")





              ##### ISIC ####

# Import ISIC 3.0 data --------------------------------- 
# we know that only years 1997 - 2011 use
isic3 <- read_delim(file = file.path(PHL, "PHL_data/GLD/international_codes/ISIC_Rev_3_english_structure.txt"))


# pdf import 
psic09_info <- pdf_info(psic_path)
psic09_data <- pdf_data(psic_path)
psic09_toc  <- pdf_toc(psic_path)
psic09_text <- pdf_text(psic_path)
