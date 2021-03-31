/*==================================================
project:       Template to run Q checks for GLD
Author:        Mario Gronert 
E-email:       mgronert@worldbank.org
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
global path_to_harmonization "[YOUR PATHFILE TO HARMONIZED DATA FILE]"

* Survey ID as per CCC_YYYY_[Survey-Name]_v##_M_v##_A_GLD convention
global survey_id "TGO_2015_QUIBB_V01_M_V01_A_GLD"

* Path to folder to hold output
global path_to_output_folder "[YOUR PATHFILE TO FOLDER THAT SHOULD HOLD Q-CHECK OUTPUT]"

* Path to folder containing helper files
* Should be "[*]:\Support and Documentation\Q Checks\Helper Programs"
* where * is the letter of your mapping to GLD network
global path_to_helpers "[YOUR PATH TO FOLDER HOLDING HELPER PROGRAMS]"


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

*----------2.2: Check files and folders exists

confirm file "${path_to_harmonization}"
if `r(confirmdir)' != 0 {
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

use "${path_to_harmonization}", clear

/*==================================================
	2: Run static q checks
==================================================*/

local path_to_static = "${path_to_helpers}" + "\GLD Static Q-Checks.do"
do "`path_to_static'"

/*==================================================
	3: Run [] q checks
==================================================*/


/*==================================================
	4: Run missing cases overview
==================================================*/



/*==================================================
	5: Unite all postfiles, export to Excel
==================================================*/

*----------5.1: Store .dta postfiles in local, store excel output file name
local output_files : dir "${path_to_output_folder}" files "*.dta" // only the .dta files
local output_excel_filename = "${path_to_output_folder}" + "\" + "${survey_id}" + "_Q-Checks.xlsx"

*----------5.2: Loop, store each in a different sheet
foreach filename of local output_files {
	local filename_full_path = "${path_to_output_folder}" + "\" + "`filename'"
	
	* Extract static, dynamic, ... based on the assumption of how postfiles were named
	local position_helpr = strpos("`filename'", "q_checks_") 
	local sheet_name = regexr(substr("`filename'", `position_helpr' + 9, .), ".dta", "")

	use "`filename_full_path'", clear
	export excel using "`output_excel_filename'", sheet("`sheet_name'") replace
}

