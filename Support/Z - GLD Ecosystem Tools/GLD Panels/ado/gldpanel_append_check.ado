capture program drop gldpanel_append_check

program gldpanel_append_check

	 *Check if there's data in memory
	qui count
    if `r(N)' == 0 {
        display as error "ERROR: No data in memory. Please load a dataset first."
        exit 198 // this exit code (198) indicates that no data is in memory
    }
	
	* Check if dataset is in filelist format
	capture confirm variable dirname
	if _rc {
		display as error "ERROR: This is a post-command for filelist. Run filelist first!"
		exit
	}
	
	tempfile original
	qui save `original'
	
	
	display "Initializing... *"

	* Check for fullname
	capture confirm variable fullname
	if _rc {
		display "*"
		quietly gen fullname = dirname + "\" + filename
	}
	
	* Check for years
	capture confirm variable years
	if _rc {
		display "*"
		quietly {
			gen survey_core = regexs(1) if regexm(filename, "(^[a-zA-Z][a-zA-Z][a-zA-Z]_[0-9][0-9][0-9][0-9]_[a-zA-Z0-9-]+)(_[vV][0-9][0-9]_M_[vV][0-9][0-9]_A)_([a-zA-Z][a-zA-Z][a-zA-Z]+)_([ALL]+)\.dta")
			replace filename = upper(filename)
			sort filename
			bys survey_core: gen survey_number = _n
			bys survey_core: egen survey_numb_max = max(survey_number)
			keep if survey_numb_max == survey_number
			
			* Create relevant variables to match
			gen country = substr(survey_core,1,3)
			gen years = substr(survey_core,5,4)
		}
	}

	qui destring years, replace
	display "*"

	* Process rows directly so Windows paths containing spaces remain intact.
	qui count
	local nfiles = r(N)
	assert `nfiles' >= 1

	local firstfile = fullname[1]
	qui sum years in 1
	local yr = r(min)

	preserve
	quietly {
		use `"`firstfile'"', clear
		describe, replace
		keep name type
		gen year = `yr'
		tempfile combine
		save `combine'
	}
	restore

	forvalues i = 2/`nfiles' {
		local file = fullname[`i']
		qui sum years in `i'
		local yr = r(min)
		
		quietly {
			preserve
			use `"`file'"', clear
			describe, replace
			keep name type
			gen year = `yr'
			append using `combine'
			save `combine', replace
			restore
		}
	}

	quietly{
	use `combine', clear
	sort name year

	bys name: gen repeats = _N
	bys name type: gen repeats_type = _N
	}
	
	* Number of survey years is required by both consistency checks below.
	qui levelsof year, local(unique_years)
	qui local num_unique_years : word count `unique_years'

	* Data type inconsistency checks
	display "* Checking data type inconsistencies..."
	qui count if repeats_type != repeats
	if `r(N)' >= 1 {
		display as error "CAREFUL: There are variables not consistent in data type, consider harmonizing prior to appending!"
		sort name
		list year name type  if repeats_type != repeats, sep(`num_unique_years')
	}

	* More data type checks
	display "* More checks..."
	qui sum repeats
	local repmin = r(min)
	if `repmin' != `num_unique_years' {
		display "FYI: The following variables are not consistently found in all years (on display is # of appearances):"
		tab name if repeats!=`num_unique_years'
	}
	display "Done!"

use `original', clear
end
