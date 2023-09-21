version 16

* Define the command
capture program drop gldpanel_issue_check

program gldpanel_issue_check, rclass
    syntax [, hhid(varname) pid(varname) year(varname) age(varname) wave(varname) relationharm(varname) male(varname) countrycode(varname)]

    * If not specified, default to given variable names
    if "`hhid'" == "" local hhid hhid
    if "`pid'" == "" local pid pid
    if "`year'" == "" local year year
    if "`age'" == "" local age age
    if "`wave'" == "" local wave wave
    if "`relationharm'" == "" local relationharm relationharm
    if "`male'" == "" local male male
	if "`countrycode'" == "" local countrycode countrycode


    * Temporary variable declarations
    tempvar earliest_year actual_diff odd_diff id_odd_diff diff_sex id_diff_sex
    tempvar diff_relharm id_diff_relharm first_wave_year agetag minage age_d diff_age 
    tempvar id_diff_age diff_sex_year id_diff_sex_year diff_relharm_year agetag_year
    tempvar minage_year age_d_year diff_age_year id_diff_age_sex_u diff_sex_age
    tempvar diff_sex_age_year possibletwins twins_runner wave_order diff group_id
    tempvar issuetype labels issue non_issue total perc_issue perc_non_issue 
	tempvar id_diff_relharm_year id_diff_age_year varname
	
	quietly{
    * Check that there are no odd repetitions (i.e., an ID from 2009 is re-use in 2015)
    bys `hhid' `pid' : egen `earliest_year' = min(`year')
    gen `actual_diff' = `year' - `earliest_year'
    gen `odd_diff' = `actual_diff' > 1
    bys `hhid' `pid': egen `id_odd_diff' = max(`odd_diff')

      * Check if odd_diff is zero, but people have different characteristics
    bys `hhid' `pid': egen `diff_sex' = sd(`male')
    replace `diff_sex' = (`diff_sex' > 0 & !missing(`diff_sex'))
    bys `hhid' `pid': egen `id_diff_sex' = max(`diff_sex')

    bys `hhid' `pid': egen `diff_relharm' = sd(`relationharm')
    replace `diff_relharm' = (`diff_relharm' > 0 & !missing(`diff_relharm'))
    bys `hhid' `pid': egen `id_diff_relharm' = max(`diff_relharm')

    bys `hhid' `pid' `year': gen `first_wave_year' = `wave' if _n == 1
    replace `first_wave_year' = `first_wave_year'[_n-1] if missing(`first_wave_year')

    gen `agetag' = `age' if `year' == `earliest_year' & `wave' == `first_wave_year'
    bys `hhid' `pid': egen `minage' = min(`agetag')
    gen `age_d' = `age' - `minage'
    gen `diff_age' = !(inlist(`age_d', 0, 1))
    bys `hhid' `pid': egen `id_diff_age' = max(`diff_age')

    * Check for consistency in information within `year'
    bys `hhid' `pid' `year': egen `diff_sex_year' = sd(`male')
    replace `diff_sex_year' = (`diff_sex_year' > 0 & !missing(`diff_sex_year'))
    bys `hhid' `pid': egen `id_diff_sex_year' = max(`diff_sex_year')

    bys `hhid' `pid' `year': egen `diff_relharm_year' = sd(`relationharm')
    replace `diff_relharm_year' = (`diff_relharm_year' > 0 & !missing(`diff_relharm_year'))
    bys `hhid' `pid': egen `id_diff_relharm_year' = max(`diff_relharm_year')

    bys `hhid' `pid' `year': gen `agetag_year' = `age' if `wave' == `first_wave_year'
    bys `hhid' `pid' `year': egen `minage_year' = min(`agetag_year')
    gen `age_d_year' = `age' - `minage_year'
    gen `diff_age_year' = !(inlist(`age_d_year', 0, 1))
    bys `hhid' `pid': egen `id_diff_age_year' = max(`diff_age_year')

    gen `id_diff_age_sex_u' = (`id_diff_age' == 1 | `id_diff_sex' == 1)

    * Tag for both sex and `age' inconsistency
    gen `diff_sex_age' = `diff_age' == 1 & `diff_sex' == 1
    gen `diff_sex_age_year' = `diff_age_year' == 1 & `diff_sex_year' == 1

    label var `age_d_year' "Age difference within `year'"
    label var `age_d' "Age difference across `year's"

    ************************************************************************
    * Fixing the roster mix up
    ************************************************************************
    duplicates tag `hhid' `male' `age' `wave', gen(`possibletwins')

    bys `hhid' `age' `male': gen `twins_runner' = _n if `possibletwins' == 1
    replace `twins_runner' = 0 if `possibletwins' == 0

    * Generate a new variable 'group_id' to identify the start of each group of consecutive waves
    capture confirm string variable `wave'
    if _rc == 0 {
        * Sort your data by hhid and wave
        sort hhid `pid' `year' `wave'

        * Generate a wave_order variable
        bysort `hhid' `pid' `year': gen `wave_order' = _n    
    }
    else{
        gen `wave_order' = `wave'
    }

    sort  `hhid'  `twins_runner' `male' `age' `year' `wave'   

    gen `diff' = `wave_order' - `wave_order'[_n-1] if _n > 1
    replace `diff' = 0 if `wave_order' == 1

    replace `diff' = 1 if `wave_order' == 1 & (`age' - `age'[_n-1]== 0 | `age' - `age'[_n-1] == 1) & (`male'== `male'[_n-1]) & `countrycode'!="MNG"
    replace `diff' = 1 if inrange(`diff', 2, 4)
    replace `diff' = 0 if `diff' < 0 
    bys `hhid' `twins_runner' `male': replace `diff' = 0 if abs(`age' - `age'[_n-1]) > 1 & `wave_order'!= 1

    gen `group_id' = sum(`diff' != 1)

    gen `issuetype' = 1 if `id_odd_diff' == 1
    replace `issuetype' = 2 if `id_odd_diff' == 0 & `id_diff_sex' == 1
    replace `issuetype' = 3 if `id_odd_diff' == 0 & `id_diff_sex'  == 1
    replace `issuetype' = 4 if `id_odd_diff' == 0 & `id_diff_age' == 1  & `id_diff_sex'  == 1

	capture label drop lblissuetype

    label def lblissuetype 1 "Odd years" 2 "Inconsistent sex" 3 "Inconsistent age" 4 "Inconsistent age and sex"
    label values `issuetype' lblissuetype
	
	
	* Clean up

	preserve
	* Collapse the data
	collapse (max) `odd_diff' `diff_age' `diff_sex' `diff_relharm' `diff_sex_age', by(`hhid' `pid')


	* Create a new dataset to store the variables description
	tempname memhold
	tempfile long
	postfile `memhold' str64 dataset str32 varname issue non_issue using `long', replace

	* Get list of numeric variable names from collapsed dataset
	ds, has(type numeric)
	local vars = r(varlist)

	* Loop over each variable and get its description
	foreach var of local vars {
		* Get number of non-missing values
		qui count if `var' == 1
		local issue = r(N)

		qui count if `var' == 0
		local non_issue = r(N)
		* Write into the new dataset
		post `memhold' ("Collapsed Dataset") ("`var'") (`issue') (`non_issue')
	}

	postclose `memhold'

	use `long', clear
	gen labels = 1  if varname == "`odd_diff'"
	replace labels = 2  if varname == "`diff_age'"
	replace labels = 3  if varname == "`diff_sex'"
	replace labels = 4 if varname == "`diff_relharm'"
	replace labels = 5 if varname == "`diff_sex_age'"

	capture label drop lbl

	label define lbl 1 "Non-consecutive" 2 "Diff in age" 3 "Diff in sex" 4 "Diff in HH relation" 5 "Diff in sex and age"
	label values labels lbl

	egen total = rowtotal(issue non_issue)
	gen perc_issue = round((issue/total)*100, 0.01)
	gen perc_non_issue = (non_issue / total) * 100
	levelsof total, local(total)


	forvalues i = 1/5 {
		qui egen max_val = max(perc_issue) if labels == `i'
		qui sum max_val if labels == `i', meanonly
		local rounded_max = string(round(r(max), 0.01), "%9.2f")
		local case`i' = `rounded_max'
		di "case`i' = `case`i''"
		drop max_val
	}

	graph hbar (sum) issue non_issue if total != 0 & labels>1, over(labels) ///
bar(1, color(maroon) lcolor(maroon)) bar(2, color(none) lcolor(maroon)) stack title("Issues across years: `country'") subtitle("") graphregion(color(white)) text(`total' 89  " `case2'%", place(east) color(maroon)) text(`total' 63 " `case3'%", place(east) color(maroon)) text(`total' 38  " `case4'%", place(east) color(maroon))  text(`total' 11 " `case5'%", place(east) color(maroon)) ylabel(, nogrid)
		
	
	

	
	restore
	}

	end