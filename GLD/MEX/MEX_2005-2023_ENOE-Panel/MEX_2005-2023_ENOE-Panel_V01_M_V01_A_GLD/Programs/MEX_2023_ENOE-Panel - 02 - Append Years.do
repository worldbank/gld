
***************************************
** Code for IND PLFS Urban Panel     **
** Master file that defines paths,   **
** calls other functions to do work  **
***************************************

* List files in folder
filelist, dir("Y:/GLD-Harmonization/529026_MG/Countries/MEX") pat("*.dta")

* Create var that takes out survey core (i.e., without version numbers)
gen survey_core = regexs(1) if regexm(filename, "(^[a-zA-Z][a-zA-Z][a-zA-Z]_[0-9][0-9][0-9][0-9]_[a-zA-Z0-9-]+)(_[vV][0-9][0-9]_M_[vV][0-9][0-9]_A)_([a-zA-Z][a-zA-Z][a-zA-Z]+)_([ALL]+)\.dta")
drop if survey_core == ""

* By construction of the name (surveycore_v##_M_v##_A), the alphanumeric order will
* put the most recent one last. Thus, surveycore_v01_M_v03_A is after surveycore_v01_M_v02_A,
* both are before surveycore_v02_M_v01_A.
bys survey_core (filename): gen survey_number = _n
bys survey_core (filename): egen survey_numb_max = max(survey_number)
quietly: keep if survey_numb_max == survey_number

* We need to make sure the filename is entirely capitalized; otherwse, not sort properly
replace filename = upper(filename)
 		
* Create relevant variables to match
gen country = substr(survey_core,1,3)
gen years = substr(survey_core,5,4)
gen survname = regexs(1) if regexm(survey_core, "^[a-zA-Z][a-zA-Z][a-zA-Z]_[0-9][0-9][0-9][0-9]_([a-zA-Z0-9-]+)")

* Keep relevant variables, save
keep country years survname dirname filename

* Create variable for full name
gen fullname = dirname + "/" + filename

levelsof fullname, local(year_files)
clear
foreach file of local year_files {
	
    append using "`file'", force
	
}

* Diagnostic: Check wave and visit consistency. For a given HH wave- visit_no should be unique. Only applies when visit_no is available. 
	
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

*save "${path_output}/paneldata_${country}.dta", replace