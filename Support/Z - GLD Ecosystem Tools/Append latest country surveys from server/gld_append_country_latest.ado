********************************************************************************
********************************************************************************
* GLD checking latest version   					     ***
********************************************************************************
********************************************************************************

* What is the logic of this function?
* The function takes in a path to a folder of a country on the server and loads all the latest harmonized GLD files for that country.

* Users can also choose to add a start and end year to reduce the countries looked at.

capture program drop gld_append_country_latest
program define gld_append_country_latest
{

syntax, folder_path(str) [start_year(integer -1) end_year(integer 9999)]

********************************************************************************
*---------- 1: Evaluate input on folder_path
********************************************************************************


if !fileexists("`folder_path'"){
	dis as error "No folder seems to exist for the folder path given"
	dis as error "`folder_path'"
	exit 198
}


********************************************************************************
*---------- 2: Evaluate input on years
********************************************************************************

* Start year is before 1920
if `start_year' != -1 & `start_year' < 1920{
    dis as error "Starting year entered is earlier than 1920, please review"
	exit 198
}

* Start year is larger than end year
if `start_year' != -1 & `start_year' > `end_year' {
    dis as error "Starting year larger than end year, please review"
	exit 198
}

* End year is smaller than start year
if `end_year' != 9999 & `end_year' < `start_year' {
    dis as error "End year is smaller than start year, please review"
	exit 198
}


********************************************************************************
*---------- 3: Create list of latest surveys
********************************************************************************

clear
* Read in list of surveys from GLD
filelist, dir("`folder_path'") pat("*.dta")

* Create check to only look at files in the harmonized data folder of GLD server
gen check = regexm(dirname, "Data/Harmonized")
quietly: keep if check == 1
drop check
		
* Create var that takes out survey core (i.e., without version numbers)
gen survey_core = regexs(1) if regexm(filename, "(^[a-zA-Z][a-zA-Z][a-zA-Z]_[0-9][0-9][0-9][0-9]_[a-zA-Z0-9-]+)(_[vV][0-9][0-9]_M_[vV][0-9][0-9]_A)_([a-zA-Z][a-zA-Z][a-zA-Z]+)_([ALL]+)\.dta")

* By construction of the name (surveycore_v##_M_v##_A), the alphanumeric order will
* put the most recent one last. Thus, surveycore_v01_M_v03_A is after surveycore_v01_M_v02_A,
* both are before surveycore_v02_M_v01_A.
bys survey_core (filename): gen survey_number = _n
bys survey_core (filename): egen survey_numb_max = max(survey_number)
quietly: keep if survey_numb_max == survey_number
		
* Create relevant variables to match
gen country = substr(survey_core,1,3)
gen years = substr(survey_core,5,4)
gen survname = regexs(1) if regexm(survey_core, "^[a-zA-Z][a-zA-Z][a-zA-Z]_[0-9][0-9][0-9][0-9]_([a-zA-Z0-9-]+)")

* Keep relevant variables, save
keep country years survname dirname filename

* Restrict to years
keep if inrange(years, "`start_year'", "`end_year'")


********************************************************************************
*---------- 4: Append latest surveys
********************************************************************************

levelsof dirname,  local(dirs)
levelsof filename, local(files)

local n : word count `dirs'

clear

forvalues i = 1/`n' {

	local dir  : word `i' of `dirs'
	local file : word `i' of `files'
  
	append using "`dir'/`file'", force
	
}

* End program brackets
}
end


