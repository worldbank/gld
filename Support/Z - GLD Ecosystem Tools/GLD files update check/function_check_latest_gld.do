
********************************************************************************
********************************************************************************
* GLD checking latest version   											   *
********************************************************************************
********************************************************************************

* What is the logic of this function?
* The function takes in a path ot a csv file and checks whether the surveys listed 
* are indeed the latest available

capture program drop gld_check_latest
program define gld_check_latest
{

syntax, filepath(str)

********************************************************************************
*---------- 1: Evaluate input
********************************************************************************

if !ustrregexm("`filepath'", "csv$") {
	di as error "File path is not a CSV"
	exit 198
}

if !fileexists("`filepath'"){
	dis as error "No file seems to exist for filepath"
	dis as error "`filepath'"
	exit 198
}

********************************************************************************
**---------- 2: Obtain latest GLD
********************************************************************************

clear

* Do DLW stuff quietly
quietly {
	
	* Pull the GMD library, once loaded, drop it 
	datalibweb, type(gld) repo(create latest_for_join_update)
	datalibweb, type(gld) repo(erase latest_for_join_update, force)

	* Keep relevant columns
	keep country years survname surveyid veralt vermast

	* lowercase filename
	replace surveyid = upper(surveyid)

	* Store as tempfile
	tempfile gld_latest
	save `gld_latest'

* End Quetly on DLW process
}

********************************************************************************
*---------- 3: Read file given by user, evaluate
********************************************************************************

* Import file path
quietly : import delimited "`filepath'", varnames(1) case(preserve) clear 

* Ensure it has but one column 
qui: des
if `r(k)' != 1 {
	dis as error "Document has more than one column."
	dis as error "Function expects a single column listing surveys to check."
}

quietly {
	* Rename first (and only) column 
	* Since Stata is Stata, workaround with prefix
	rename * c_*
	rename c_* surveyid_user

	* Drop .dta if users have included that
	replace surveyid_user = subinstr(surveyid_user, ".dta", "", .)

	* Drop ALL at the end
	replace surveyid_user = subinstr(surveyid_user, "_GLD_ALL", "_GLD", .)

	* Uppercase name just in case
	replace surveyid_user = upper(surveyid_user)

	* Create var that takes out survey core (i.e., without version numbers)
	gen survey_core = regexs(1) if regexm(surveyid_user, "(^[A-Z][A-Z][A-Z]_[0-9][0-9][0-9][0-9]_[A-Z0-9-]+)(_[V][0-9][0-9]_M_[V][0-9][0-9]_A)_([A-Z][A-Z][A-Z]+)")

	* Extract relevant parts 
	gen country = substr(survey_core, 1, 3)
	gen years   = substr(survey_core, 5, 4)
	gen survname = regexs(1) if regexm(survey_core, "^[a-zA-Z][a-zA-Z][a-zA-Z]_[0-9][0-9][0-9][0-9]_([a-zA-Z0-9-]+)")

	* Drop survey core, don't need it
	drop survey_core

********************************************************************************
*---------- 4: Merge with gld_latest, note issues
********************************************************************************

	* Merge
	merge 1:1 country years survname using "`gld_latest'", nogen keep(master match)

	* Check if survey IDs match
	gen check_ID = surveyid_user == surveyid 

	* Tag issues
	gen issues = 0
	replace issues = 1 if missing(surveyid)
	replace issues = 2 if !missing(surveyid) & check_ID == 0


********************************************************************************
*---------- 5: Make info for output
********************************************************************************

	* Generate status variable
	gen status = ""
	replace status = "Up to date" if issues == 0
	replace status = "No such survey on GLD" if issues == 1
	replace status = "Needs updating to -->" if issues == 2

	* Generate updated version
	gen updated_version = ""
	replace updated_version = surveyid if issues == 2

	* Keep surveyid, vermast, veralt info only to indicate update info (issues == 2)
	replace vermast = "" if issues != 2
	replace veralt  = "" if issues != 2

	* Rename years to year 
	rename years year 

	* rename surveyid_user to current version
	rename surveyid_user current_version


	* Keep only relevant vars, reorder
	keep  country year survname current_version status updated_version vermast veralt
	order country year survname current_version status updated_version vermast veralt 

* End quietly brackets
}

* End program brackets
}
end
