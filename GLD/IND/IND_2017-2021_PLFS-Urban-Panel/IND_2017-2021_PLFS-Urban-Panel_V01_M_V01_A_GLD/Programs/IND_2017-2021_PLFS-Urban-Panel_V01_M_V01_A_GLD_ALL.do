
/*%%=============================================================================================
	0: GLD Panel Creation Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				IND_2017-2021_PLFS-Urban-Panel_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata 17 <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2023-08-25 </_Date created_>

<_Country_>						India </_Country_>
<_Survey Title_>				Periodic Labour Force Survey </_Survey Title_>
<_Survey Years_>				2017 - 2021 </_Survey Years_>
<_Sample size (Unique HH)_> 	227,894 </_Sample size (Unique HH)_>
<_Sample size (Unique IND)_> 	905,249 </_Sample size (Unique IND)_>
<_Rotation pattern> 			Individuals are interviewed for 4 consecutive quarters prior to replacement. There is 25% attrition between rounds in the first 4 quarters of the 2017-2018 PLFS </_Rotation pattern_>
-----------------------------------------------------------------------
<_Version Control_>

</_Version Control_>


------------------------------------------------------------------------- */


/*%%=============================================================================================
	1: Setting up of program environment, dataset
==============================================================================================%%*/

*----------1.1: Initial commands------------------------------*

clear
set more off
set mem 800m

*----------1.2: Set directories------------------------------*

global server 	"Y:\GLD-Harmonization\510859_AS"
global country 	"IND"
global survey_p "PLFS-Urban-Panel"
global survey_i "PLFS"
global years 	"2017 2018 2019 2020 2021"
global vermast 	"V01"
global veralt  	"V01"


*------------------------------------------------------------*
global first_year = word("$years", 1)
global last_year = word("$years", -1)
global panel_years "`first_year'-`last_year'"

global level_1	 "${country}_${panel_years}_${survey_p}"
global level_2_mast "${level_1}_${vermast}_M"
global level_2_harm "${level_1}_${vermast}_M_${veralt}_A_GLD"

* From chunks, define path_in, path_output folder
global path_helper 	 "${server}/${country}/${level_1}/${level_2_harm}/Programs/Helper"
global path_output   "${server}/${country}/${level_1}/${level_2_harm}/Data/Harmonized"
global path_work	 "${server}/${country}/${level_1}/${level_2_harm}/Work"

*----------1.3: Install packages------------------------------*



/*%%=============================================================================================
	2: Append the datasets
==============================================================================================%%*/

* A1: Create a list of files with all the harmonized datasets
do "${path_helper}/A1_Filelist.do"

	* Diagnostic 1: Check data quality for appending
	gldpanel_append_check

* A2: Identify the latest file version
do "${path_helper}/A2_Extract_Latest.do"

* A3: Append the datasets
do "${path_helper}/A3_Append.do"

* A4: Restrictions
* IN the case of India, panel can only be formed using the urban sample
keep if urban == 1

/*%%=============================================================================================
	3: Create panel variable
==============================================================================================%%*/

	* Diagnostic 2: Check wave and visit consistency. For a given HH wave- visit_no should be unique. Only applies when visit_no is available. 
	
	capture confirm variable visit_no
	
	if _rc == 0 {	  
	gldpanel_wave_visit_check
	drop vw_tag
	}
		
	* Here there are 141,000 cases of individual-waves where the household-wave info is mapped to more than one visit_no. There are two possibilities: (1) visit is assigned based on individual appearance not the household's; (2) the hhid is  not unique for a given round-year. 

	* Diagnostic: Check for re-use of HHID outside panel
	gldpanel_id_check
	
	* The results above show that there is a prevalent re-use of HHIDs in non-subsequent years!
	* Also, there is a re-use of HHID within a year! 
	* This means we cannot use HHID or PID to create the panel variable!
	
* B1: Create panel variables
do "${path_helper}/B1_Create_Panel.do"

	* Diagnostic: Check for re-use of HHID outside panel
	gldpanel_id_check, hhid(hhid_panel) pid(pid_panel)
	
	* Check panel formation
	levelsof panel, local(panels)
	foreach panel of local panels {
	dis "This is panel: `panel'"
	tab year wave if panel == "`panel'"
}

* Erase temporary file
erase "${path_output}/paneldata_${country}.dta"

* Save the file (use of the macros!)
save "${path_output}/${country}_${panel_years}_${survey_p}_${vermast}_M_${veralt}_A_GLD_ALL.dta", replace

/*%%=============================================================================================
	4: Assess panel quality
==============================================================================================%%*/

*----------4.1: Age sex matches ------------------------------*
gldpanel_issue_check, hhid(hhid_panel) pid(pid_panel)
graph export "${path_work}/age_sex_matches.png", replace

*----------4.2: Sources of mismatch ------------------------------*
gldpanel_check_source, hhid(hhid_panel) pid(pid_panel)
graph export "${path_work}/source_mismatches.png", replace

*----------4.3: PID Attrition ------------------------------*
* Case of India, change wave so that it runs in sets of four
gen tempwave = wave
replace tempwave = "Q1" if wave == "Q5"
replace tempwave = "Q2" if wave == "Q6"
replace tempwave = "Q3" if wave == "Q7"
replace tempwave = "Q4" if wave == "Q8"

gldpanel_attrition, hhid(hhid_panel) pid(pid_panel) wave(tempwave) consecutive_waves
graph export "${path_work}/attrition_consecutive_waves.png", replace

gldpanel_attrition, hhid(hhid_panel) pid(pid_panel) wave(tempwave) any_wave
graph export "${path_work}/attrition_any_wave.png", replace

gldpanel_attrition, hhid(hhid_panel) pid(pid_panel) wave(tempwave) all_waves
graph export "${path_work}/attrition_all_waves.png", replace







