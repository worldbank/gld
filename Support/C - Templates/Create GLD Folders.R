
# Define country, root, and survey name
country <- "[XYZ]"
root <- "Y:/GLD-Harmonization/DDDDDD_LL"
survey_name <- "[SURVNAME]"

# Set country root as wd, make folder if it doesn't exists
if (!dir.exists(root)) dir.create(root)
wd <- paste0(root, "/", country)
if (!dir.exists(wd)) dir.create(wd)
setwd(wd)

# Define what folders (basically with or without I2D2) and the years
# levels <- c("_V01_M", "_V01_M_V01_A_GLD", "_V01_M_V01_A_I2D2")
levels <- c("_V01_M", "_V01_M_V01_A_GLD")
years <- c([Start:Finish])


# Loop over years
for (year in years){


  # First level
  first <- paste(country, year, survey_name, sep = "_")
  dir.create(first)

  # Second level
  for (level in levels){
    second <- paste0(first, "/", first, level)
    dir.create(second)

    # Original versus altered
    if (grepl("A", level)) { # altered

      dir.create(paste0(second, "/", "Data"))
      dir.create(paste0(second, "/", "Data/Harmonized"))
      dir.create(paste0(second, "/", "Doc"))
      dir.create(paste0(second, "/", "Programs"))
      dir.create(paste0(second, "/", "Work"))

    } else {

      dir.create(paste0(second, "/", "Data"))
      dir.create(paste0(second, "/", "Data/Original"))
      dir.create(paste0(second, "/", "Data/Stata"))
      dir.create(paste0(second, "/", "Doc"))
      dir.create(paste0(second, "/", "Programs"))

    }
  }

}

