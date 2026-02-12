
***************************************
** Code for IND PLFS Urban Panel     **
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
net install gldpaneltools, replace from("https://raw.githubusercontent.com/worldbank/gld/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/GLD%20Panels")

* Install egenmore if not present, as gld panel functions rely on it
cap which egenmore
if _rc {
    ssc install egenmore
}

*----------1.2: Set directories------------------------------*

* Define path sections
local server	"C:/Users/`c(username)'/WBG/GLD - Current Contributors/637898_JR"
local country	"IND"
local year		"2023"
local survey	"PLFS-Urban-Panel"
local vermast	"V01"
local veralt	"V01"

* From the definitions, set path chunks
local level_1      "`country'_`year'_`survey'"
local level_2_mast "`level_1'_`vermast'_M"
local level_2_harm "`level_1'_`vermast'_M_`veralt'_A_GLD"

* From chunks, define path_in, path_output folder
global path_input	 "`server'/`country'/`level_1'/`level_2_mast'/Data/Stata"
global path_output   "`server'/`country'/`level_1'/`level_2_harm'/Data/Harmonized"
global path_programs "`server'/`country'/`level_1'/`level_2_harm'/Programs"
global path_work	 "`server'/`country'/`level_1'/`level_2_harm'/Work"

/*%%=============================================================================================
	2: Call in the do files that do the work
==============================================================================================%%*/

do "${path_programs}/IND_2023_PLFS-Urban-Panel - 02 - Append Years.do"
do "${path_programs}/IND_2023_PLFS-Urban-Panel - 03 - Create Panel Vars.do"
do "${path_programs}/IND_2023_PLFS-Urban-Panel - 04 - Assess Panel.do"

/*%%=============================================================================================
	3: Save output
==============================================================================================%%*/

save "${path_output}/IND_2017-2023_PLFS-Urban-Panel_V01_M_V01_A_GLD_ALL.dta", replace


