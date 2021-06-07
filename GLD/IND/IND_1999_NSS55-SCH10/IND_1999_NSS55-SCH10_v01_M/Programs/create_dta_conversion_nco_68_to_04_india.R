
# The Indian Employment and unemployment surveys from 1983 (38th round) to 2005 (62nd Round) use the Indian 1968
# NCO to codify occupations. This classification system does not map neatly to the 10 digit code we use for the 
# variable "occup". [See the NCO codes here - http://lsi.gov.in:8081/jspui/bitstream/123456789/130/1/53065_1991_NCO.pdf].
# 
# In order to correct this we use the concordance table of occupations from NOC 1968 to NCO 2004 to map them to a 
# one digit level (i.e., 1968 occupation codes 003 and 009 map to 2004 one digit code 1). This happens in two two steps:
#   
# The first is to convert the PDF table into a csv file. This was done using an online tool and some formatting. 
# The result is the "long_conversion.csv" file. 
# 
# The second step is to take this table, clean it, create the mapping and store the mapping as a .dta file in 
# the correct survey folders. This is done using the "create_dta_conversion_nco_68_to_04_india.R" file.
# 
# This ReadMe file is stored for every round from the 38th to the 62nd in the survey "Doc" folder 
# (IND_YYYY_NSSXX-SCH10\IND_YYYY_NSSXX-SCH10_v01_M/Doc) along with the concordance table PDF and the 
# long_conversion CSV file. The R program is in the "Programs" folder 
# (IND_YYYY_NSSXX-SCH10\IND_YYYY_NSSXX-SCH10_v01_M/Programs). The outputted dta file of the conversion is stored 
# under the Data - Stata folder (IND_YYYY_NSSXX-SCH10\IND_YYYY_NSSXX-SCH10_v01_M/Data/Stata) while a copy of the 
# data in CSV form is stored in the Data - Original folder 
# (IND_YYYY_NSSXX-SCH10\IND_YYYY_NSSXX-SCH10_v01_M/Data/Original).
# 
# This information is also place at the top of the R file.



library(dplyr)
library(readstata13)

# This file i
long_conversion_file_path <- "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/IND/long_conversion.csv"
df <- read.csv(long_conversion_file_path)

# Drop cases where there is no 1968 code
indx = df$NCO.1968 == ""
df <- df[!indx,]

# Drop if there is no equivalent
indx = df$NCO.2004 == ""
df <- df[!indx,]

# split X cases
df_x <- df[grepl("X", df$NCO.1968),]
df_num <- df[!grepl("X", df$NCO.1968),]

# Unify codes
df_num$code_68 <- as.numeric(gsub("^(\\d+)(\\.*)(.*)", "\\1", df_num$NCO.1968))
df_num$code_68 <- sprintf("%03d", df_num$code_68)
df_x$code_68 <- gsub("^(X?\\d+)(\\.*)(.*)", "\\1", df_x$NCO.1968)
df_x$code_04 <- "999"

df_num$code_04 <- gsub("^(\\d+)(\\.*)(.*)", "\\1", df_num$NCO.2004)
df_num$code_04 <- substr(df_num$code_04,1,1)

# Keep only unique combination
data <- df_num %>% dplyr::distinct(code_68, .keep_all = TRUE) %>% na.omit() %>% select(code_04, code_68)

# Save as csv,dta
path_dta <- 
  c("C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/IND/IND_1983_NSS38-SCH10/IND_1983_NSS38-SCH10_v01_M/Data/Stata",
    "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/IND/IND_1987_NSS43-SCH10/IND_1987_NSS43-SCH10_v01_M/Data/Stata",
    "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/IND/IND_1993_NSS50-SCH10/IND_1993_NSS50-SCH10_v01_M/Data/Stata",
    "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/IND/IND_1999_NSS55-SCH10/IND_1999_NSS55-SCH10_v01_M/Data/Stata",
    "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/IND/IND_2004_NSS60-SCH10/IND_2004_NSS60-SCH10_v01_M/Data/Stata",
    "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/IND/IND_2004_NSS61-SCH10/IND_2004_NSS61-SCH10_v01_M/Data/Stata",
    "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/IND/IND_2005_NSS62-SCH10/IND_2005_NSS62-SCH10_v01_M/Data/Stata")
path_csv <- 
  c("C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/IND/IND_1983_NSS38-SCH10/IND_1983_NSS38-SCH10_v01_M/Data/Original",
    "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/IND/IND_1987_NSS43-SCH10/IND_1987_NSS43-SCH10_v01_M/Data/Original",
    "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/IND/IND_1993_NSS50-SCH10/IND_1993_NSS50-SCH10_v01_M/Data/Original",
    "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/IND/IND_1999_NSS55-SCH10/IND_1999_NSS55-SCH10_v01_M/Data/Original",
    "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/IND/IND_2004_NSS60-SCH10/IND_2004_NSS60-SCH10_v01_M/Data/Original",
    "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/IND/IND_2004_NSS61-SCH10/IND_2004_NSS61-SCH10_v01_M/Data/Original",
    "C:/Users/wb529026/OneDrive - WBG/Documents/Country Work/IND/IND_2005_NSS62-SCH10/IND_2005_NSS62-SCH10_v01_M/Data/Original")

path_filename <- c("IND_1983_NSS38-SCH10", "IND_1987_NSS43-SCH10", "IND_1993_NSS50-SCH10", "IND_1999_NSS55-SCH10",
                   "IND_2004_NSS60-SCH10", "IND_2004_NSS61-SCH10", "IND_2005_NSS62-SCH10")

for (j in seq_along(path_dta)){
  csv_file <- paste0(path_csv[j], "/", path_filename[j], "_NCO_68_to_2004_conversion", ".csv")
  dta_file <- paste0(path_dta[j], "/", path_filename[j], "_NCO_68_to_2004_conversion", ".dta")
  write.csv(data, csv_file, row.names = FALSE)
  save.dta13(data, dta_file)
}
