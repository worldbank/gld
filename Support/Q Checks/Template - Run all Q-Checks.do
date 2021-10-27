/*==================================================
project:       Template to run Q checks for GLD
Author:        World Bank Jobs Group 
E-email:       gld@worldbank.org
url:           
Dependencies:  distinct, mdesc
----------------------------------------------------
Creation Date:    	28 Jan 2021
Modification Date:	28 Jan 2021   
Do-file version:    01
References:          
Output: Individual Postfiles outputted as sheets of XLSX
==================================================*/

/*========================  DISCLAIMER  ==================================
This system is set up at the moment only for a Windows environment. 
Mac expansion is intended but not yet tackled. Apologies
========================================================================*/


/*==================================================
	1: Program set up - Requires user input
==================================================*/

version 16
set varabbrev off, permanently

*----------0.1: Set necessary paths

* Path to harmonized .dta file
global path_to_harmonization "Z:\GLD-Harmonization\573465_JT\ZAF\ZAF_2008_LFS\ZAF_2008_LFS_v01_M_v01_A_GLD\Data\Harmonized\ZAF_2008_QLFS_v01_M_v01_A_GLD.dta"

* Path to other harmonized files for dynamic comparison
* Leave as `" "' to skip this (no others or to be done later)
* Write as a set of paths like 
* global path_to_other_harmonization `" "Path 1" "Path 2" ... "' Note the space between `" and "Path 1"
global path_to_other_harmonization `" "' 


* Survey ID as per CCC_YYYY_[Survey-Name]_v##_M_v##_A_GLD_[ALL] convention
global survey_id "CCC_YYYY_Survey-Name_V0X_M_V0Z_A_GLD_[ALL]"


* Path to folder to hold output
global path_to_output_folder "Z:\GLD-Harmonization\573465_JT\ZAF\ZAF_2008_LFS\ZAF_2008_LFS_v01_M_v01_A_GLD\Work"

* Path to folder containing helper files
* Should be "[*]:\Support and Documentation\Q Checks\Helper Programs"
* where * is the letter of your mapping to GLD network
global path_to_helpers "C:\Users\wb573465\GitHub\gld\Support\Q Checks\Helper Programs"


/*========================    NOTE    ==================================
From here on, the program should run alone, no more input is needed from
you. If some necessary input is not present, the program should warn you.
If it breaks down, please inform an admin (currently : mgronert@worldbank.org)
to look into the error and amend the bug(s).
========================================================================*/

/*==================================================
	2: Program set up - Check everything is in place
==================================================*/

*----------2.1: Check and install dependencies

capture which distinct
if _rc ssc install distinct

capture which mdesc
if _rc ssc install mdesc

capture which confirmdir
if _rc ssc install confirmdir

capture which wbopendata
if _rc ssc install wbopendata

*----------2.2: Check files and folders exists

capture confirm file "${path_to_harmonization}"
if _rc != 0 {
	display as error "path_to_harmonization file cannot be found"
	exit
}

confirmdir "${path_to_output_folder}"
if `r(confirmdir)' != 0 {
	display as error "Folder of path_to_output_folder cannot be found"
	exit
}

confirmdir "${path_to_helpers}"
if `r(confirmdir)' != 0 {
	display as error "Folder of path_to_helpers cannot be found"
	exit
}


/*==================================================
	3: Run static q checks
==================================================*/

local path_to_static = "${path_to_helpers}" + "\GLD Static Q-Checks.do"
do "`path_to_static'"

/*==================================================
	4: Run Dynamic q checks
==================================================*/

local path_to_dynamic = "${path_to_helpers}" + "\GLD Dynamic Q-Checks.do"

do "`path_to_dynamic'"

/*==================================================
	5: Run missing cases overview
==================================================*/



/*==================================================
	6: Unite all postfiles, export to Excel
==================================================*/

*----------5.1: Store .dta postfiles in local, store excel output file name
local output_dta_files : dir "${path_to_output_folder}" files "*.dta" // only the .dta files
local output_png_files : dir "${path_to_output_folder}" files "*.png" // only the .png files
local output_excel_filename = "${path_to_output_folder}" + "\" + "${survey_id}" + "_Q-Checks.xlsx"

*----------5.2: Loop, store each dta in a different sheet
foreach filename of local output_dta_files {
	local filename_full_path = "${path_to_output_folder}" + "\" + "`filename'"
	
	* Extract static, dynamic, ... based on the assumption of how postfiles were named
	local position_helpr = strpos("`filename'", "q_checks_") 
	local sheet_name = regexr(substr("`filename'", `position_helpr' + 9, .), ".dta", "")

	use "`filename_full_path'", clear
	export excel using "`output_excel_filename'", sheet("`sheet_name'") replace
}

*----------5.3: Loop, store the density plots in a sheet
foreach filename of local output_png_files {

	local filename_full_path = "${path_to_output_folder}" + "\" + "`filename'"
	local sheet_name = substr("`filename'", 1, strpos("`filename'", ".") - 1) 

	putexcel set "`output_excel_filename'", sheet("`sheet_name'") modify
	putexcel A1 = picture(`filename_full_path')

}



