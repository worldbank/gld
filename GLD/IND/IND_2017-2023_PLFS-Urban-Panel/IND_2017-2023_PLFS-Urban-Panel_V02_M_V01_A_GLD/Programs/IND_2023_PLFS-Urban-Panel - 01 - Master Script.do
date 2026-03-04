
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

* Define path_in, path_output folder
global path_base     "C:/Users/`c(username)'/WBG/GLD - Focal Point/Countries/IND/IND_2017-2023_PLFS-Urban-Panel"
global path_input	 "${path_base}/IND_2017-2023_PLFS-Urban-Panel_V02_M/Data/Stata"
global path_output   "${path_base}/IND_2017-2023_PLFS-Urban-Panel_V02_M_V01_A_GLD/Data/Harmonized"
global path_programs "${path_base}/IND_2017-2023_PLFS-Urban-Panel_V02_M_V01_A_GLD/Programs"
global path_work     "${path_base}/IND_2017-2023_PLFS-Urban-Panel_V02_M_V01_A_GLD/Work"

/*%%=============================================================================================
	2: Call in the do files that do the work
==============================================================================================%%*/

do "${path_programs}/IND_2023_PLFS-Urban-Panel - 02 - Append Years.do"
do "${path_programs}/IND_2023_PLFS-Urban-Panel - 03 - Create Panel Vars.do"
do "${path_programs}/IND_2023_PLFS-Urban-Panel - 04 - Assess Panel.do"

/*%%=============================================================================================
	3: Save output
==============================================================================================%%*/

save "${path_output}/IND_2017-2023_PLFS-Urban-Panel_V02_M_V01_A_GLD_ALL.dta", replace


