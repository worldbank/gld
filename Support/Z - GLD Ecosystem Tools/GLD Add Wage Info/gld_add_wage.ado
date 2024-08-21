*****************************************
*****************************************
** Code to add wage information to GLD **
** surveys, both hourly and monthly    **
*****************************************
*****************************************

* Start program
program define gld_add_wage, rclass

********************************************************************************
* Step 1 - Prep syntax, default values
********************************************************************************

* Define version, syntax
version 18.0
syntax [, WORKer(string) TIME(string) THREshold(real 75) ppp]

* Set variable abbreviation off, otherwise if unitwage is missing but unitwage_year is present, 
* Stata uses the latter for the former.
set varabbrev off
    
* Default values
local worker_def "waged"
local time_def   "week"

*----------------------
* Check worker option
*----------------------
	
local worker = lower("`worker'")
if !inlist("`worker'", "a", "all", "w", "waged") {
	
	display as error "Invalid entry for option worker. Please use either 'a'/'all' or 'w'/'waged'."
    exit 198
			
} // Close if user entry incorrect 
		
* Unify worker options
if inlist("`worker'", "a", "all") local worker "all"
if inlist("`worker'", "w", "waged") local worker "waged"
    
*----------------------
* Check time option
*----------------------
	
local time = lower("`time'")
if !inlist("`time'", "w", "week", "y", "year", "b", "both") {
	
	display as error "Invalid entry for option time. Please use either 'w'/'week', 'y'/'year', or 'b'/'both'."
    exit 198
			
} // Close if user entry incorrect
		
* Unify time options
if inlist("`time'", "w", "week") local time "week"
if inlist("`time'", "y", "year") local time "year"
if inlist("`time'", "b", "both") local time "both"

*----------------------
* Check threshold option
*----------------------
    
* Check that threshold is a value between 0 and 100
if `threshold' < 0 | `threshold' > 100 {
	
	display as error "Invalid entry for option threshold. Please enter a number between 0 and 100."
    exit 198
	
}
    

********************************************************************************
* Step 2 - Ensure relevant variables are present
********************************************************************************

* Check if 7 day vars are present
if inlist("`time'", "both", "week") {
	
	local vars "lstatus empstat wage_no_compen unitwage whours"
	foreach var of local vars {
		
		quietly : cap des `var'
		if _rc != 0 {
			
			dis as error "Variable `var' not in the data"
			exit 
			
		} // Close var not in data
			
	} // Close loop over variables
	
} // Close check over 7 days

* Check if 12 month vars are present
if inlist("`time'", "both", "year") {
	
	local vars "lstatus_year empstat_year wage_no_compen_year unitwage_year whours_year"
	foreach var of local vars {
		
		quietly : cap des `var'
		if _rc != 0 {
			
			dis as error "Variable `var' not in the data"
			exit 
			
		} // Close var not in data
			
	} // Close loop over variables
	
} // Close check over 12 month


********************************************************************************
* Step 3 - Calculate hourly wage over 7  day   recall period
********************************************************************************

* Check if we are doing it over this period
if inlist("`time'", "both", "week") {
	
	* Evaluate for only wage workers
	if "`worker'" == "waged" {
		
		* Calculate threshold (needs preserve as collapsed), merge in
		preserve
		
			gld_help_thresh, threshold(`threshold') worker(`worker')
			quietly : tempfile td
			quietly : save "`td'"
		
		restore
		
		* Merge in threshold information 
		quietly : merge m:1 countrycode year using "`td'", assert(match) nogen
		
		* Calculate hourly wages 
		gld_help_wage_calc, hour
		
		* Replace wage with missing if threshold not met
		quietly : replace hour_wage = . if !mi(hour_wage) & threshold < `threshold'
		
	} // Close evaluation of wage worker
	
	* Evaluate threshold if all workers
	if "`worker'" == "all" {
		
		* Calculate threshold (needs preserve as collapsed), merge in
		preserve
		
			gld_help_thresh, threshold(`threshold') worker(`worker')
			quietly : tempfile td
			quietly : save "`td'"
		
		restore
		
		* Merge in threshold information 
		quietly : merge m:1 countrycode year using "`td'", assert(match) nogen
		
		* Calculate hourly wages
		gld_help_wage_calc, hour all
		
		* Replace wage with missing if threshold not met
		quietly : replace hour_wage = . if !mi(hour_wage) & threshold < `threshold'
		
	} // Close evaluation of all workers
	
} // End we calculate over 7 day recall


********************************************************************************
* Step 4 - Calculate monthly wage over 7 day recall period
********************************************************************************

* Check if we are doing it over this period
if inlist("`time'", "both", "week") {
	
	* Evaluate for only wage workers
	if "`worker'" == "waged" {
		
		* Calculate threshold (needs preserve as collapsed), merge in
		preserve
		
			gld_help_thresh, threshold(`threshold') worker(`worker')
			quietly : tempfile td
			quietly : save "`td'"
		
		restore
		
		* Merge in threshold information 
		quietly : merge m:1 countrycode year using "`td'", assert(match) nogen
		
		* Calculate monthly wages
		gld_help_wage_calc
		
		* Replace wage with missing if threshold not met
		quietly : replace month_wage = . if !mi(month_wage) & threshold < `threshold'

	} // Close evaluation of wage worker
	
	* Evaluate threshold if all workers
	if "`worker'" == "all" {
		
		* Calculate threshold (needs preserve as collapsed), merge in
		preserve
		
			gld_help_thresh, threshold(`threshold') worker(`worker')
			quietly : tempfile td
			quietly : save "`td'"
		
		restore
		
		* Merge in threshold information 
		quietly : merge m:1 countrycode year using "`td'", assert(match) nogen
		
		* Calculate monthly wages
		gld_help_wage_calc, all
		
		* Replace wage with missing if threshold not met
		quietly : replace month_wage = . if !mi(month_wage) & threshold < `threshold'
		
	} // Close evaluation of all workers
		
} // End we work over 7 day recall

********************************************************************************
* Step 5 - Calculate hourly  wage over 12 month recall period
********************************************************************************

* Check if we are doing it over this period
if inlist("`time'", "both", "year") {
	
	* Evaluate for only wage workers
	if "`worker'" == "waged" {
		
		* Calculate threshold (needs preserve as collapsed), merge in
		preserve
		
			gld_help_thresh, threshold(`threshold') worker(`worker') year
			quietly : tempfile td
			quietly : save "`td'"
		
		restore
		
		* Merge in threshold information 
		quietly : merge m:1 countrycode year using "`td'", assert(match) nogen
		
		* Calculate hourly wages
		gld_help_wage_calc, year hour
		
		* Replace wage with missing if threshold not met
		quietly : replace hour_wage_year = . if !mi(hour_wage_year) & threshold < `threshold'
		
	} // Close evaluation of wage worker
	
	* Evaluate threshold if all workers	
	if "`worker'" == "all" {
		
		* Calculate threshold (needs preserve as collapsed), merge in
		preserve
		
			gld_help_thresh, threshold(`threshold') worker(`worker') year
			quietly : tempfile td
			quietly : save "`td'"
		
		restore
		
		* Merge in threshold information 
		quietly : merge m:1 countrycode year using "`td'", assert(match) nogen
		
		* Calculate hourly wages
		gld_help_wage_calc, year hour all
		
		* Replace wage with missing if threshold not met
		quietly : replace hour_wage_year = . if !mi(hour_wage_year) & threshold < `threshold'
		
	} // Close evaluation of all workers
	
} // End we work over 12 month recall


********************************************************************************
* Step 6 - Calculate monthly wage over 12 month recall period
********************************************************************************	

* Check if we are doing it over this period
if inlist("`time'", "both", "year") {
	
	* Evaluate for only wage workers
	if "`worker'" == "waged" {
		
		* Calculate threshold (needs preserve as collapsed), merge in
		preserve
		
			gld_help_thresh, threshold(`threshold') worker(`worker') year
			quietly : tempfile td
			quietly : save "`td'"
		
		restore
		
		* Merge in threshold information 
		quietly : merge m:1 countrycode year using "`td'", assert(match) nogen
		
		* Calculate monthly wages
		gld_help_wage_calc, year
		
		* Replace wage with missing if threshold not met
		quietly : replace month_wage_year = . if !mi(month_wage_year) & threshold < `threshold'
		
	} // Close evaluation of wage worker
	
	* Evaluate threshold if all workers	
	if "`worker'" == "all" {
		
		* Calculate threshold (needs preserve as collapsed), merge in
		preserve
		
			gld_help_thresh, threshold(`threshold') worker(`worker') year
			quietly : tempfile td
			quietly : save "`td'"
		
		restore
		
		* Merge in threshold information 
		quietly : merge m:1 countrycode year using "`td'", assert(match) nogen
		
		* Calculate monthly wages
		gld_help_wage_calc, year all
		
		* Replace wage with missing if threshold not met
		quietly : replace month_wage_year = . if !mi(month_wage_year) & threshold < `threshold'
		
	} // Close evaluation of all workers	
	
} // End we work over 7 day recall
	
	
********************************************************************************
* Step 7 - Add PPP if requested
********************************************************************************

* If the user requested it, we will add the PPP value for each variable
* The values come from the World Bank PPP conversion factor, GDP (LCU per international $)
* https://data.worldbank.org/indicator/PA.NUS.PPP

if "`ppp'" != "" {
	
	* We are going to use wbopendata. Test whehter user has it
	cap which wbopendata
	if _rc != 0 {
		
		ssc install wbopendata
		
	} // Close wbopendata not installed
	
	* Create locals. The country one uses "|" to separate and clean (no compound doulbe quotes) so we can pass it to a regex.
	* Years uses a comma to separate to pass it to an inlist. Inlist allows only 10 arguments in string, but 250 if real, so we
	* should be OK.
	quietly : levelsof countrycode, local(ccc) separate("|") clean
	quietly : levelsof year, local(yyy) separate(",")
	
	* Preserve data as we load PPP data
	preserve 
	
		* Call in the full set of PPP values
		quietly : wbopendata,indicator(PA.NUS.PPP) clear long
		
		* Reduce to countries, years in data
		quietly : keep if regexm(countrycode, "`ccc'")
		quietly : keep if inlist(year, `yyy')
		
		* Drop if PA.NUS.PPP is missing, better to tell people there is not data
		quietly : drop if mi(pa_nus_ppp)
		
		* Check if there is data for the options 
		quietly : count
		local ppp_rows `r(N)'
	
		* If none, inform user, exit
		if `ppp_rows' == 0 {
			
			dis as error "There seems to be no PPP data for `ccc' in `yyy'"
			exit
			
		} // Close there is no PPP data
	
		* If there is data, reduce to relevant, make a tempfile
		if `ppp_rows' > 0 {
			
			* Keep relevant variables 
			keep countrycode year pa_nus_ppp
		
			* Store as tempfile
			quietly : tempfile ppp_data
			quietly : save "`ppp_data'"
			
		} // Close there is PPP data
	
	* Restore back
	restore
	
	* Merge in if PPP has data, calculate vars 
	if `ppp_rows' > 0 {
		
		* Merge PPP data where we (a) don't want a merge and (b) just keep master or match
		quietly : merge m:1 countrycode year using "`ppp_data'", nogen keep(master match)
		
		* Create local of created vars, loop through it. We will check it, add ppp
		local created_vars "hour_wage month_wage hour_wage_year month_wage_year" 
		local var_labs     `""PPP value of hourly wage - 7D" "PPP value of monthly wage - 7D" "PPP value of hourly wage - 12M" "PPP value of monthly wage - 12M""'
		local n : word count `created_vars'
		
		forvalues i = 1/`n' {
		
			local created_var : word `i' of `created_vars'
			local var_lab : word `i' of `var_labs'
			
			* Check whether variable exists
			quietly : cap des `created_var'
			
			* If var exists, create ppp var
			if _rc == 0 {
				
				quietly : gen `created_var'_ppp = `created_var'/pa_nus_ppp
				quietly : label variable `created_var'_ppp "`var_lab'"
				
			} // Close var exists, make ppp one
			
		} // Close loop through created vars
		
	} // Close there is PPP data
	
} // Close PPP was requested

	
***********************	
* Close program
***********************
end