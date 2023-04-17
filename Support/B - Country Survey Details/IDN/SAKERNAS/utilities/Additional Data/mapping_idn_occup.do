/*==================================================================
====================================================================

	Creating Correspondence Table between KBJI 1982 and KBJI 2002

====================================================================
==================================================================*/

*===================================================================
	* Step 1 - Prep environemnt, assemble data
*===================================================================

*-------------------Clear, code settings---------------------*
clear
set more off
set mem 800m


*-------------------Set directories---------------------*
* I change this for me, as I have Y
local 	drive 	`"Y"'
local 	cty 	`"IDN"'
local 	main	"`year'\\`cty'_`surv_yr'_Sakernas_v01_M"
local 	stata	"`main'\data\stata"


*---------------Assemble Dataset using 2011-2015---------------*
local file_names "sak_aug2011_backcast.dta sak_aug2012_backcast.dta sak_aug2013_backcast.dta sakernas14aug.dta sakernas15aug.dta"
local years "2011 2012 2013 2014 2015"
local educs "b5p1a b5p1a b5p1a b5_r1a b5_r1a"
local temps "temp_2011 temp_2012 temp_2013 temp_2014 temp_2015"
local weights "weightbc weightbc weightbc weight weight"

local n : word count `file_names'

forvalues i = 1/`n' {
    
	local file_name : word `i' of `file_names'
	local year : word `i' of `years'
	local educ : word `i' of `educs'
	local temp : word `i' of `temps'
	local weight : word `i' of `weights'

	use "`drive':\GLD\\`cty'\\`cty'_`year'_Sakernas\\`cty'_`year'_Sakernas_v01_M\\data\\\stata\\`file_name'", clear
	
	* Create variable educat7 (from GLD harmonization)
	gen byte educat7 = `educ'
	recode educat7 (4=3) (5/7=4) (8/10=5) (11/12=6) (13/14=7)
	replace educat7 = . if !inrange(educat7,1,7)
	
	* Create unified weight variable
	cap gen weight = `weight'
	
	* Drop cases where kji is missing
	drop if missing(kji1982)
	
	* Drop additionally if kbji2002 is missing, too, as this is a link between a case an missing, not helpful
	drop if missing(kbji2002)
	
	* Keep only relevant variables, add year info to keep track
	keep kji1982 kbji2002 educat7 weight
	gen year = `year'
	
	* Save as tempfile
	tempfile `temp'
	save ``temp''
	
}

*-------------------Append the years inf to a single set---------------------*
use "`temp_2011'", clear
append using "`temp_2012'" "`temp_2013'" "`temp_2014'" "`temp_2015'"


*===================================================================
	* Step 2 - Create 3 digit dataset concordance
*===================================================================

* Preserve so we can go back for 2 digit ones
preserve

	* Generate counter, collapse over categories across all years (as if all years are a single database) 
	gen cases = 1
	collapse (sum) cases [pweight = weight], by(kji1982 kbji2002 educat7)
	
	* Over educat7 and kji 3 digit class, count the kbji2002 cases, calculate share
	bys kji1982 educat7 : egen case_tot = total(cases)
	gen w_share = cases/case_tot

	* Keep vars we want, order
	drop case*
	order kji1982 educat7 kbji2002 w_share

	* Rename for reshaping
	rename kbji2002 option_
	rename w_share probs_

	* Gen variable we will use for reshaping
	bys kji1982 educat7: gen runner = _n

	* Reshape
	reshape wide option_ probs_, i(kji1982 educat7) j(runner)

	* Check things are right (the sum of probs for each row ought to be, bar rounding errors, equal to 1)
	egen row_total = rowtotal(probs_*)
	assert abs(row_total - 1) < 0.0001
	drop row_total

	* Make the probs a cumulation of probablities
	replace probs_2 = probs_1 + probs_2
	replace probs_3 = probs_2 + probs_3

	* Clean up samll issues of cumulation
	replace probs_1 = 1 if inrange(probs_1,0.9999,1)
	replace probs_2 = 1 if inrange(probs_2,0.9999,1)
	replace probs_3 = 1 if inrange(probs_3,0.9999,1)

	* Save three digit version
	save "Y:\GLD-Harmonization\529026_MG\Countries\IDN\kji_corresp_3d.dta", replace

restore

*===================================================================
	* Step 3 - Create 2 digit dataset concordance
*===================================================================

* Reduce to 2 digits
gen kji1982_2d = floor(kji1982/10)

* Generate counter, collapse over categories across all years (as if all years are a single database) 
gen cases = 1
collapse (sum) cases [pweight = weight], by(kji1982_2d kbji2002 educat7)

* Over educat7 and kji 2 digit class, count the kbji2002 cases, calculate share
bys kji1982_2d educat7 : egen case_tot = total(cases)
gen w_share = cases/case_tot

* Keep vars we want, order
drop case*
order kji1982_2d educat7 kbji2002 w_share

* Rename for reshaping
rename kbji2002 option_
rename w_share probs_

* Gen variable we will use for reshaping
bys kji1982_2d educat7: gen runner = _n

* Reshape
reshape wide option_ probs_, i(kji1982 educat7) j(runner)

* Check things are right (the sum of probs for each row ought to be, bar rounding errors, equal to 1)
egen row_total = rowtotal(probs_*)
assert abs(row_total - 1) < 0.0001
drop row_total

* Make the probs a cumulation of probablities
replace probs_2 = probs_1 + probs_2
replace probs_3 = probs_2 + probs_3
replace probs_4 = probs_3 + probs_4

* Clean up samll issues of cumulation
replace probs_1 = 1 if inrange(probs_1,0.9999,1)
replace probs_2 = 1 if inrange(probs_2,0.9999,1)
replace probs_3 = 1 if inrange(probs_3,0.9999,1)
replace probs_4 = 1 if inrange(probs_4,0.9999,1)

* Temp save two digit version
tempfile two_d
save `two_d'

* Manually create the assignment fro code 41.
* code 41 is "Working propietor in retail trade", does not exist in 2011 to 2015 but common previously. Data comes from
* Assembling the data, looking at the occup and education breakdown 
clear 
set obs 7
gen kji1982_2d = 41
gen educat7 = _n 
gen option_1 = 5
gen option_2 = 9
gen option_3 = 1
replace option_3 = 7 if inrange(educat7, 1, 2)
replace option_3 = 8 if inrange(educat7, 3, 4)

gen probs_1 = .
replace probs_1 = .749 if educat7 == 1
replace probs_1 = .764 if educat7 == 2
replace probs_1 = .765 if educat7 == 3
replace probs_1 = .804 if educat7 == 4
replace probs_1 = .819 if educat7 == 5
replace probs_1 = .782 if educat7 == 6
replace probs_1 = .738 if educat7 == 7

gen probs_2 = .
replace probs_2 = .230 if educat7 == 1
replace probs_2 = .208 if educat7 == 2
replace probs_2 = .199 if educat7 == 3
replace probs_2 = .150 if educat7 == 4
replace probs_2 = .090 if educat7 == 5
replace probs_2 = .048 if educat7 == 6
replace probs_2 = .029 if educat7 == 7

egen row_total = rowtotal(probs_1 probs_2)
gen probs_3 = 1 - row_total
drop row_total

append using "`two_d'"

sort kji1982_2d educat7

* Save two digit version
save "Y:\GLD-Harmonization\529026_MG\Countries\IDN\kji_corresp_2d.dta", replace

*===================================================================
	* Step 4 - Example of using it on raw three digit data
*===================================================================

use "Y:\GLD\IDN\IDN_2006_SAKERNAS\IDN_2006_SAKERNAS_V01_M\Data\Stata\sakernas06aug.dta", clear

* Create educat7 variable
gen byte educat7 = b4p1a
recode educat7 (0=1) (1=2) (2=3) (3/4=4) (5/6=5) (7 8=6) (9=7)
	
* Make occup var to match in merge
gen kji1982 = b4p8

* Merge with three digit mapping
merge m:1 kji1982 educat7 using "Y:\GLD-Harmonization\529026_MG\Countries\IDN\kji_corresp_3d.dta", keep(match master) nogen

* For not matched cases, create two digit
gen kji1982_2d = floor(kji1982/10) if !missing(b4p8) & missing(option_1)

* Merge with 2 digit one by updating (same var that is missing in master will take using value)
merge m:1 kji1982_2d educat7 using "Y:\GLD-Harmonization\529026_MG\Countries\IDN\kji_corresp_2d.dta", keep(match master) nogen update
tab b4p7 kji1982_2d if missing(option_1) [iw=weight], cell nofreq

* Set seed so process is reproducible
* Kapuas river, Indonesia's longest stands at 1143 KM (https://en.wikipedia.org/wiki/Kapuas_River)
set seed 1143

* Generate uniform random variable, the logic is, it will lie between 0 and 1 and fall
* within the cumulation category with the probability from the 2011 to 2015 data
gen helper_occup = uniform()

* Assing fix cases
gen occup = .
replace occup = option_1 if !missing(kji1982) & probs_1 == 1

* Assigng binary cases based on probability
replace occup = option_1 if (!missing(kji1982) & missing(occup) & missing(probs_3)) & helper_occup <= probs_1 
replace occup = option_2 if (!missing(kji1982) & missing(occup) & missing(probs_3)) & helper_occup > probs_1

* Assign three way based on probability
replace occup = option_1 if (!missing(kji1982) & missing(occup) & missing(probs_4)) & inrange(helper_occup, 0, probs_1)
replace occup = option_2 if (!missing(kji1982) & missing(occup) & missing(probs_4)) & inrange(helper_occup, 0, probs_2)
replace occup = option_3 if (!missing(kji1982) & missing(occup) & missing(probs_4)) & inrange(helper_occup, 0, probs_3)

* Assign four way based on probability
replace occup = option_1 if (!missing(kji1982) & missing(occup) & !missing(probs_4)) & inrange(helper_occup, 0, probs_1)
replace occup = option_2 if (!missing(kji1982) & missing(occup) & !missing(probs_4)) & inrange(helper_occup, 0, probs_2)
replace occup = option_3 if (!missing(kji1982) & missing(occup) & !missing(probs_4)) & inrange(helper_occup, 0, probs_3)
replace occup = option_4 if (!missing(kji1982) & missing(occup) & !missing(probs_4)) & inrange(helper_occup, 0, probs_4)

tab occup [iw=weight]

*===================================================================
	* Step 5 - Example of using it on raw two digit data
*===================================================================

use "Y:\GLD\IDN\IDN_1999_SAKERNAS\IDN_1999_SAKERNAS_V01_M\Data\Stata\sakernas99.dta", clear
gen year = 1999

* Create educat7
gen byte educat7 = b4p1a
recode educat7 (4/5=4) (6/7=5) (8/9=6) (0=7)

* Make occup var to match in merge, depends on the year we are looking at
gen kji1982_2d = b4p7

* Merge with 2 digit mapping
merge m:1 kji1982_2d educat7 using "Y:\GLD-Harmonization\529026_MG\Countries\IDN\kji_corresp_2d.dta", keep(match master) nogen

* Quick check, which codes where not matched
tab kji1982_2d if missing(option_1) 

* Set seed so process is reproducible
* Kapuas river, Indonesia's longest stands at 1143 KM (https://en.wikipedia.org/wiki/Kapuas_River)
set seed 1143

* Generate uniform random variable, the logic is, it will lie between 0 and 1 and fall
* within the cumulation category with the probability from the 2011 to 2015 data
gen helper_occup = uniform()

* Assing fix cases
gen occup = .
replace occup = option_1 if !missing(kji1982) & probs_1 == 1

* Assigng binary cases based on probability
replace occup = option_1 if (!missing(kji1982) & missing(occup) & missing(probs_3)) & helper_occup <= probs_1 
replace occup = option_2 if (!missing(kji1982) & missing(occup) & missing(probs_3)) & helper_occup > probs_1

* Assign three way based on probability
replace occup = option_1 if (!missing(kji1982) & missing(occup) & missing(probs_4)) & inrange(helper_occup, 0, probs_1)
replace occup = option_2 if (!missing(kji1982) & missing(occup) & missing(probs_4)) & inrange(helper_occup, 0, probs_2)
replace occup = option_3 if (!missing(kji1982) & missing(occup) & missing(probs_4)) & inrange(helper_occup, 0, probs_3)

* Assign four way based on probability
replace occup = option_1 if (!missing(kji1982) & missing(occup) & !missing(probs_4)) & inrange(helper_occup, 0, probs_1)
replace occup = option_2 if (!missing(kji1982) & missing(occup) & !missing(probs_4)) & inrange(helper_occup, 0, probs_2)
replace occup = option_3 if (!missing(kji1982) & missing(occup) & !missing(probs_4)) & inrange(helper_occup, 0, probs_3)
replace occup = option_4 if (!missing(kji1982) & missing(occup) & !missing(probs_4)) & inrange(helper_occup, 0, probs_4)

tab occup [iw=weight]