/*==============================================================================
* A2: Extract only the latest survey
*==============================================================================*/

* Create var that takes out survey core (i.e., without version numbers)
gen survey_core = regexs(1) if regexm(filename, "(^[a-zA-Z][a-zA-Z][a-zA-Z]_[0-9][0-9][0-9][0-9]_[a-zA-Z0-9-]+)(_[vV][0-9][0-9]_M_[vV][0-9][0-9]_A)_([a-zA-Z][a-zA-Z][a-zA-Z]+)_([ALL]+)\.dta")

* By construction of the name (surveycore_v##_M_v##_A), the alphanumeric order will
* put the most recent one last. Thus, surveycore_v01_M_v03_A is after surveycore_v01_M_v02_A,
* both are before surveycore_v02_M_v01_A.

* We need to make sure the filename is entirely capitalized; otherwse, not sort properly
replace filename = upper(filename)
 
sort filename
egen survey_number = seq(), by(survey_core)
egen survey_numb_max = max(survey_number), by(survey_core)
quietly: keep if survey_numb_max == survey_number
		
* Create relevant variables to match
gen country = substr(survey_core,1,3)
gen years = substr(survey_core,5,4)
gen survname = regexs(1) if regexm(survey_core, "^[a-zA-Z][a-zA-Z][a-zA-Z]_[0-9][0-9][0-9][0-9]_([a-zA-Z0-9-]+)")

* Keep relevant variables, save
keep country years survname dirname filename

* Deal with Thailand, keep one per year, reduce name to LFS
gen official_name = survname if country == "THA"

* Keep Q3 of THA
gen tha_q3 = regexm(survname, "Q3") 
bys country years : egen has_q3 = max(tha_q3)
* Drop other quarters in years that have q3
drop if has_q3 == 1 & tha_q3 == 0

* Convert survname to fit
replace survname = "LFS" if survname == "LFS-Q3"

* Drop helpers
drop tha_q3 has_q3

* Create GLD columns (repeats, so the info stays if merged)
gen gld_dirname = dirname
gen gld_filename = filename
gen gld_survname = survname
replace gld_survname = official_name if !missing(official_name)
drop official_name



