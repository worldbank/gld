********************************************************************************
********************************************************************************
* GLD checking latest version   					     ***
********************************************************************************
********************************************************************************

* What is the logic of this function?
* The function takes in a path ot a csv file and checks whether the surveys listed 
* are indeed the latest available

capture program drop gld_check_latest
program define gld_check_latest
{

syntax, filepath(str) [countries(str)]

********************************************************************************
*---------- 1: Evaluate input on filepath
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
*---------- 2: Evaluate input on countries
********************************************************************************

* Tokenize to know how many words we have, go through them

* First check how many countries passed
local num_countries_passed :  word count `countries'

* If countries passed, then num_countries passed > 0, only evaluate names if passed
if `num_countries_passed' > 0 {
    
	* Evaluate each is three letters
	foreach num of numlist 1/ `num_countries_passed' {
	    
		local country :  word `num' of `countries'
		 
		if !ustrregexm("`country'", "^[A-Z][A-Z][A-Z]$") {
		di as error "All country info must be three letters, all capitalised"
		di as error "This is not the case for `country', please review"
		exit 198
		* Close if country name incorrect
		}				

	* Close numlist loop
	}

* Close if country argument passed
}


********************************************************************************
**---------- 3: Create data frame for countries, store
********************************************************************************

* For merging in later, create a file that holds country info 
* If countries passed, that is
if `num_countries_passed' > 0 {
    
	clear 
	qui: set obs `num_countries_passed'
	qui: gen country = ""
	
	foreach num of numlist 1/ `num_countries_passed' {
	    
		local country :  word `num' of `countries'
		qui: replace country = "`country'" in `num'
    * Close numlist
	}
	
	quietly {
	    tempfile user_listed_ccc
		save `user_listed_ccc'
	}


* Close if countries passed, create country data frame
}


********************************************************************************
**---------- 4: Obtain latest GLD
********************************************************************************

clear

* Do DLW stuff quietly
quietly {
	
	* Pull the GLD library, once loaded, drop it 
	datalibweb, type(gld) repo(create latest_for_join_update)
	datalibweb, type(gld) repo(erase latest_for_join_update, force)

	* Keep relevant columns
	keep country years survname surveyid veralt vermast

	* lowercase filename
	replace surveyid = upper(surveyid)

	* Store as tempfile
	tempfile gld_latest
	save `gld_latest'

* End Quietly on DLW process
}


********************************************************************************
*---------- 5: Read file given by user, evaluate
********************************************************************************

* Import file path
quietly : import delimited using "`filepath'", varnames(1) case(preserve) clear 

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
*---------- 6: Merge with gld_latest, note issues
********************************************************************************

	* Merge
	merge 1:1 country years survname using "`gld_latest'"
	
	* Sort in the way that I want. 
	* Match (3) represents the ones that are alike, need to be evaluated if they need to be updated.
	* Master (1) are the ones that exist only in the list of surveys provided by the user.
	* Using (2) are the ones that exist only in the GLD list 
	
	* I want to have Match, Master, then a filler row, then using, but to sort that I need to 
	* change merge, after making an extra line
	qui: count
	local last_row = `r(N)' + 1 
	set obs `last_row'
	foreach last_var of varlist surveyid_user - veralt {
	    
		gen n_char = length(`last_var')
		egen n_char_max = max(n_char)
	    replace `last_var' = n_char_max * "*" in `last_row'
		drop n_char n_char_max
	
	}
	
	gen my_merge = .
	replace my_merge = 1 if _merge == 3
	replace my_merge = 2 if _merge == 1
	replace my_merge = 3 if missing(_merge)
	replace my_merge = 4 if _merge == 2
	sort my_merge country years 
	
	* Check if survey IDs match
	gen check_ID = surveyid_user == surveyid 


********************************************************************************
*---------- 7: Make info for output
********************************************************************************

	* Generate status variable
	gen status = ""
	replace status = "Up to date"            if check_ID == 1 & my_merge == 1
	replace status = "Needs updating to -->" if check_ID == 0 & my_merge == 1
	replace status = "No such survey on GLD" if my_merge == 2
	replace status = "*********************"        if my_merge == 3
	

	* Generate updated version
	gen updated_version = ""
	* Have info if needs updating
	replace updated_version = surveyid if check_ID == 0 & my_merge == 1
	* Or new surveys
	replace updated_version = surveyid if my_merge == 4
	* Add "*****" line 
	gen n_char = length(updated_version)
	egen n_char_max = max(n_char)
	replace updated_version = n_char_max * "*" if my_merge == 3
	drop n_char n_char_max

	* Keep surveyid, vermast, veralt info only to indicate update info
	replace vermast = "" if my_merge == 2 | my_merge == 4 | (my_merge == 1 & check_ID == 1)
	replace veralt  = "" if my_merge == 2 | my_merge == 4 | (my_merge == 1 & check_ID == 1)

	* Rename years to year 
	rename years year 

	* rename surveyid_user to current version
	rename surveyid_user current_version
	
	* Merge in countries if listed by user
	drop _merge 
	
	if `num_countries_passed' > 0 {
	    
		merge m:1 country using "`user_listed_ccc'"
		* Sort again as merge command scrambles it (este programa no deja de sorprender)
		sort my_merge country year 
		
		* Keep if my_merge is 1-3 (values we want)
		* or if my_merge is 4 & it is a match
		gen keeper = inrange(my_merge,1,3) | (my_merge == 4 & _merge == 3)
		keep if keeper == 1
	    
	}


	* Keep only relevant vars, reorder
	keep  country year survname current_version status updated_version vermast veralt
	order country year survname current_version status updated_version vermast veralt 

* End quietly brackets
}

* End program brackets
}
end

