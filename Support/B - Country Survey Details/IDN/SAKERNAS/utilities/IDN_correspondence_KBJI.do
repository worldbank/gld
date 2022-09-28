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

* If done correctly the sum of the probabilities must be equal to the number of distinct kji1982 + urban
distinct kji1982 urban, joint
local distinct_cases = `r(ndistinct)'

summ probs
local prob_sum `r(N)'*`r(mean)'

assert `distinct_cases' == round(`prob_sum',1)

* Instead of reshaping (cannot think of how), create temps with the cases, move to columns
bys kji1982 urban : gen counter = _n
summ counter


forvalues i = 1/`r(max)' {
	
	preserve
	
	keep if counter == `i'
	drop counter
	rename kbji2002 option_`i'
	rename probs probs_`i'
	
	local tempname "temp_`i'"
	tempfile `tempname'
	save ``tempname''
	
	restore
	
}
    
use "`temp_1'",clear
merge 1:1 kji1982 urban using "`temp_2'", assert(master match) nogen
merge 1:1 kji1982 urban using "`temp_3'", assert(master match) nogen

order kji1982 urban *

* clean up samll issues of summation
replace probs_1 = 1 if inrange(probs_1,0.9999,1.00001)
save "Y:\GLD-Harmonization\529026_MG\kji_corresp.dta", replace

* Example of using it

use "Y:\GLD-Harmonization\573465_JT\IDN\IDN_2011_Sakernas\IDN_2011_Sakernas_v01_M\data\stata\sak_aug2011_backcast.dta", clear

*<_urban_>
	gen byte urban = b1p05
	recode urban (2=0)
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
	*</_urban_>
	
merge m:1 kji1982 urban using "Y:\GLD-Harmonization\529026_MG\kji_corresp.dta", keep(match master) nogen

* set seed so process is reproducible
set seed 123
gen helper_occup = uniform()

* Assing fix cases
gen occup = .
replace occup = option_1 if !missing(kji1982) & probs_1 == 1

* Assigng binary cases based on probability
replace occup = option_1 if !missing(kji1982) & probs_1 < 1 & helper_occup <= probs_1 & missing(probs_3)
replace occup = option_2 if !missing(kji1982) & probs_1 < 1 & helper_occup > probs_1 & missing(probs_3)

* Assign trivariate based on probability
replace occup = option_1 if !missing(kji1982) & probs_1 < 1 & helper_occup <= probs_1 & !missing(probs_3)
replace occup = option_2 if !missing(kji1982) & probs_1 < 1 & (helper_occup > probs_1 & helper_occup <= (probs_1 + probs_2)) & !missing(probs_3)
replace occup = option_3 if !missing(kji1982) & probs_1 < 1 & (helper_occup > (probs_1 + probs_2)) & !missing(probs_3)