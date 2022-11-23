/*==================================================================
	Creating Correspondence Table between KBJI 1982 and KBJI 2002
==================================================================*/
clear
set more off
set mem 800m

*-------------------Set directories---------------------*
* I change this for me, as I have Y
local 	drive 	`"Y"'
local 	cty 	`"IDN"'
local 	usr		`"573465_JT"'
* Not surv_yr as we are going to use this in a loop
*local 	surv_yr `"2011"'
*local 	year 	"`drive':\GLD-Harmonization\\`usr'\\`cty'\\`cty'_`surv_yr'_Sakernas"
local 	main	"`year'\\`cty'_`surv_yr'_Sakernas_v01_M"
local 	stata	"`main'\data\stata"

*---------------Assemble Dataset using 2011-2015---------------*

local file_names "sak_aug2011_backcast.dta sak_aug2012_backcast.dta sak_aug2013_backcast.dta sakernas14aug.dta sakernas15aug.dta"
local years "2011 2012 2013 2014 2015"
local urbans "b1p05 b1p05 b1p05 klasifik klasifikas"
local temps "temp_2011 temp_2012 temp_2013 temp_2014 temp_2015"
local weights "weightbc weightbc weightbc weight weight"

local n : word count `file_names'

forvalues i = 1/`n' {
    
	local file_name : word `i' of `file_names'
	local year : word `i' of `years'
	local urban : word `i' of `urbans'
	local temp : word `i' of `temps'
	local weight : word `i' of `weights'
	use "`drive':\GLD-Harmonization\\`usr'\\`cty'\\`cty'_`year'_Sakernas\\`cty'_`year'_Sakernas_v01_M\\data\\\stata\\`file_name'", clear
	
	* Create variable urban (from GLD harmonization)
	gen byte urban = `urban'
	recode urban (2=0)
	
	* Drop cases where kji is missing
	drop if missing(kji1982)
	
	* Drop additionally if kbji2002 is missing, too, as this is a link between a case an missing, not helpful
	drop if missing(kbji2002)
	
	* Reduce kji1982 to 2 digits
	rename kji1982 full_kji1982
	gen kji1982 = .
	replace kji1982 = floor(full_kji1982/10) if full_kji1982 > 100
	replace kji1982 = full_kji1982 if missing(kji1982)
	
	* Calculate shares per survey
	gen cases = 1
	collapse (sum) cases [pweight = `weight'], by(kji1982 kbji2002 urban)
	
	bys kji1982 urban : egen case_tot = total(cases)
	gen w_share = cases/case_tot

	gen year = `year'
	
	drop case_tot cases
	tempfile `temp'
	save ``temp''
	
}

use "`temp_2011'", clear
append using "`temp_2012'" "`temp_2013'" "`temp_2014'" "`temp_2015'"

* Before collapsing over the year we need to think that some years may not have the combination
* so if option a only exists with 20% probs, then collapsing mean over options will keep it at 20%
* instead of (0*(years without it) + 20) / (yeasr without it + 1)
* Sum over a correctly divided umber instead

* Option number of cases by combination of codes + urban
bys kji1982 kbji2002 urban : gen combos = _N
* Divider is the largst of those
bys kji1982 urban : egen divider = max(combos)
* Weigth to be summed is w_share over divider
gen probs = w_share/divider

collapse (sum) probs, by(kji1982 urban kbji2002)

* Replace armed forces from 0 to 10 in kbji2002
recode kbji2002 (0 = 10)

* If done correctly the sum of the probabilities must be equal to the number of distinct kji1982 + urban
distinct kji1982 urban, joint
local distinct_cases = `r(ndistinct)'

summ probs
local prob_sum `r(N)'*`r(mean)'

assert `distinct_cases' == round(`prob_sum',1)


* Create grouping for each kji1982 urban combo, counter
egen grouping = group(kji1982 urban)
bys  grouping : gen counter = _n

* Cumulative probabilities in each group
bysort grouping: gen cum_probs = sum(probs)

* Instead of reshaping (cannot think of how), create temps with the cases, move to columns
summ counter
local max_options `r(max)'

forvalues i = 1/`max_options' {
	
	preserve
	
	keep if counter == `i'
	drop counter probs grouping
	rename kbji2002 option_`i'
	rename cum_probs cp_`i'
	
	local tempname "temp_`i'"
	tempfile `tempname'
	save ``tempname''
	
	restore
	
}
    
use "`temp_1'",clear

forvalues i = 2/`max_options' {
	
	merge 1:1 kji1982 urban using "`temp_`i''", assert(master match) nogen
	
}

order kji1982 urban *

* clean up samll issues of summation
replace cp_1 = 1 if inrange(cp_1,0.9999,1.00001)

save "Y:\GLD-Harmonization\529026_MG\kji_2d_corresp.dta", replace




****** 
* Example of using it
******

use "Y:\GLD\IDN\IDN_1999_SAKERNAS\IDN_1999_SAKERNAS_v01_M\Data\Stata\sakernas99.dta", clear

*<_urban_>
	gen byte urban = b1p5
	recode urban (2=0)
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
	*</_urban_>

gen kji1982 = b4p6
merge m:1 kji1982 urban using "Y:\GLD-Harmonization\529026_MG\kji_2d__corresp.dta", keep(match master) nogen

* set seed so process is reproducible
set seed 123
gen helper_occup = uniform()


* First define cases for shorthand
gen cases = .
replace cases = 1 if missing(option_2)
replace cases = 2 if !missing(cp_2) & missing(cp_3)
replace cases = 3 if !missing(cp_3) & missing(cp_4)
replace cases = 4 if !missing(cp_4) & missing(cp_5)
replace cases = 5 if !missing(cp_5)

* Assign occup options
gen occup = .
replace occup = option_1 if cases == 1
replace occup = option_1 if inrange(helper_occup,0,cp_1) & inrange(cases,2,5)
replace occup = option_2 if inrange(helper_occup,cp_1, cp_2) & inrange(cases,2,5)
replace occup = option_3 if inrange(helper_occup,cp_2, cp_3) & inrange(cases,3,5)
replace occup = option_3 if inrange(helper_occup,cp_3, cp_4) & inrange(cases,4,5)
replace occup = option_3 if inrange(helper_occup,cp_4, cp_5) & cases == 5
