***************************************
** Code for CRI ECE Panel            **
** Finds latest version of surveys,  **
** appends them into a single file   **
***************************************

/*%%=============================================================================================
	1: Setting up of program environment, dataset
==============================================================================================%%*/

*----------1.1: Initial commands------------------------------*

clear
set more off
set mem 800m

* Install GLD Panel check commands
*net install gldpaneltools, replace from("https://raw.githubusercontent.com/worldbank/gld/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/GLD%20Panels")


*----------1.2: Set directories------------------------------*

global server 	"C:/Users/`c(username)'/WBG/GLD - Current Contributors/999999_ZW"
dis "`server'"
global country 	"CRI"
global survey_p "ECE"
global survey_i "ECE"
global years 	"2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025"
global vermast 	"V01"
global veralt  	"V01"


*------------------------------------------------------------*
local first_year = word("$years", 1)
local last_year = word("$years", -1)
global panel_years "`first_year'-`last_year'"

global level_1	 "${country}_${panel_years}_${survey_p}"
global level_2_harm "${level_1}_${vermast}_M_${veralt}_A_GLD"

* From chunks, define path_in, path_output folder
global path_programs 	 "${server}/${country}/${level_1}/${level_2_harm}/Programs"
global path_output   "${server}/${country}/${level_1}/${level_2_harm}/Data/Harmonized"
global path_work	 "${server}/${country}/${level_1}/${level_2_harm}/Work"

* Define Output file name
global out_file "${level_2_harm}_ALL.dta"




/*%%=============================================================================================
    2: Build and validate the appended panel
==============================================================================================%%*/

* Each auxiliary file performs one step and leaves its result in memory.
do "${path_programs}/CRI_2010-2025_ECE-Panel - 02 - Filelist.do"
do "${path_programs}/CRI_2010-2025_ECE-Panel - 03 - Extract Latest.do"
do "${path_programs}/CRI_2010-2025_ECE-Panel - 04 - Append.do"
do "${path_programs}/CRI_2010-2025_ECE-Panel - 05 - Reconstruct Panel IDs.do"

/*%%=============================================================================================
	3: Save output
==============================================================================================%%*/

* Optional final output. Uncomment only when the validated panel should be saved.
* save "${path_output}/${out_file}", replace
