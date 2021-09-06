# file_rename.R

# At the end uses walk2 function, thus requires purrr
library(purrr)

# Define the path to the survey
path_level_1 <- file.path(clone, "gld/PHL")

#======================================================#
# From here on out, the code should work automatically
#======================================================#

# Read what is contained in the directory path_level_1 defined
folders_level_1 <- dir(path_level_1)

for (folder_of_lev_1 in folders_level_1) {
  
  # Define path at level 2 (concatenate path plus level 1 folder)
  path_level_2 <- paste0(path_level_1, folder_of_lev_1)
  
  # Obtain level 2 folders
  folders_level_2 <- dir(path_level_2) 
  
  # Extract GLD folder (i.e. the one that is CCC_YYYY_[Survey]_v##_M_v##_A_GLD and thus ends on GLD)
  # Note the "$" in the pattern ensures it is at the end.
  indx <- grepl("_GLD$", folders_level_2)
  
  # Extract the folder. As a safety, ensure there is only one, otherwise error
  level_2_GLD_folder <- folders_level_2[indx]
  stopifnot(length(level_2_GLD_folder) == 1)
  
  
  # Process for .dta file ---------------------------------------------------
  
  # Once you have it, go to the folder holding the harmonized dta files
  # gld_harmonized_folder <- paste(path_level_2, level_2_GLD_folder, "Data/Harmonized", sep = "/")
  # 
  # # Extract what is in there, just in case check only things ending on "GLD.dta", save it as a list
  # # Setting full.names to True ensures we have the entire name path
  # content_harmonized_folder <- dir(gld_harmonized_folder, full.names = T)
  # old_names <- as.list(content_harmonized_folder[grepl("GLD.dta$", content_harmonized_folder)])
  # 
  # # Make a new list with the correct name
  # new_names <- as.list(gsub("GLD.dta$", "GLD_ALL.dta", old_names))
  # 
  # # Walk2 will fill the function (here "file.rename") with the first element of old_names in first position
  # # and the first element of new_names in second position. So the first round is the same as running:
  # # file.rename(old_names[[1]], new_names[[1]])
  # walk2(old_names,new_names, file.rename)
  
  
  # Process for .do file ---------------------------------------------------
  
  # Once you have it, go to the folder holding the harmonized dta files
  gld_harmonized_folder <- paste(path_level_2, level_2_GLD_folder, "Programs", sep = "/")
  
  # Extract what is in there, just in case check only things ending on "GLD.do", save it as a list
  # Setting full.names to True ensures we have the entire name path
  content_harmonized_folder <- dir(gld_harmonized_folder, full.names = T)
  old_names <- as.list(content_harmonized_folder[grepl("GLD.do$", content_harmonized_folder)])
  
  # Make a new list with the correct name
  new_names <- as.list(gsub("GLD.do$", "GLD_ALL.do", old_names))
  
  # Apply
  walk2(old_names,new_names, file.rename)
  
  
}