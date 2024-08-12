

****************************************
****************************************
** Code to generate a wide list of v4 **
** combos to be used in correspondence**
****************************************
****************************************

/*
	---> Overall strategy <---

We have created the list of all 4 digits combination from ISIC 4 to ISIC 3.1
using AI. However, we need to expand it to all 3, 2, and even 1 digit codes

*/

********************************************************************************
* Step 1 - Prep environment
********************************************************************************

* Start by clearing, no abbreviations
clear all
set varabbrev off 

* Define folder we are going to work from
local folder_input  "[prior folder path]/ISIC 4 to 3.1 AI supported conversion/Correspondence preparation"
local folder_output "[prior folder path]/ISIC 4 to 3.1 AI supported conversion"

********************************************************************************
* Step 2 - Read, reshape the data
********************************************************************************

import delimited "`folder_input'/final_ai_corr.csv", varnames(1) stringcols(1 2) 

* Create cumulative value of probabilities
bys v4 : gen c = sum(p)

* Create local of levels of v4
levelsof v4, local(levs)

* Loop through levels of v4, inside, create data files, save them
foreach lev of local levs {
	
	*dis "`lev'"
	preserve 
	keep if v4 == "`lev'"
	count
	
	foreach i of numlist 1/`r(N)' {
		
		gen opt_`i'  = v31[`i']
		gen prob_`i' =   c[`i']
		
	}
	
	keep in 1
	keep v4 opt_* prob_*
	tempfile df_`lev'
	save "df_`lev'", replace
	
	*dis "df_`lev'"
	*dis "*********************************"
	
	restore
	
}

* Append each of these files
clear
foreach lev of local levs {

	append using "df_`lev'"
	
}

* Add version of digits
gen digit_v = 4

* Save the file 
tempfile probs_4_digit
save "`probs_4_digit'"

********************************************************************************
* Step 3 - Create 3 digits probs
********************************************************************************

* Read full list again
import delimited "`folder_input'/final_ai_corr.csv", varnames(1) stringcols(1 2) clear

* Generate 3 digit code
gen v4_3d = substr(v4, 1, 3) + "0"
order v4_3d, after(v4)

* Collapse by 3 digit, update probabilities to 1
collapse (sum) prob=p, by(v4_3d v31)

bys v4_3d : egen tot = total(prob)
gen p = prob/tot

* Drop vars we do not need
drop prob tot

* Create cumulative value of probabilities
bys v4_3d : gen c = sum(p)

* Create local of levels of v4_3d
levelsof v4_3d, local(levs)

* Loop through levels of v4_3d, inside, create data files, save them
foreach lev of local levs {
	
	*dis "`lev'"
	preserve 
	keep if v4_3d == "`lev'"
	count
	
	foreach i of numlist 1/`r(N)' {
		
		gen opt_`i'  = v31[`i']
		gen prob_`i' =   c[`i']
		
	}
	
	keep in 1
	keep v4_3d opt_* prob_*
	tempfile df_`lev'
	save "df_`lev'", replace

	restore
	
}

* Append each of these files
clear
foreach lev of local levs {

	append using "df_`lev'"
	
}

* Rename v4_3d to append with 4 digits
rename v4_3d v4

* Add version of digits
gen digit_v = 3
	
* Save the file 
tempfile probs_3_digit
save "`probs_3_digit'"

********************************************************************************
* Step 4 - Create 2 digits probs
********************************************************************************

* Read full list again
import delimited "`folder_input'/final_ai_corr.csv", varnames(1) stringcols(1 2) clear

* Generate 2 digit code
gen v4_2d = substr(v4, 1, 2) + "00"
order v4_2d, after(v4)

* Collapse by 3 digit, update probabilities to 1
collapse (sum) prob=p, by(v4_2d v31)

bys v4_2d : egen tot = total(prob)
gen p = prob/tot

* Drop vars we do not need
drop prob tot

* Create cumulative value of probabilities
bys v4_2d : gen c = sum(p)

* Create local of levels of v4_2d
levelsof v4_2d, local(levs)

* Loop through levels of v4_2d, inside, create data files, save them
foreach lev of local levs {
	
	*dis "`lev'"
	preserve 
	keep if v4_2d == "`lev'"
	count
	
	foreach i of numlist 1/`r(N)' {
		
		gen opt_`i'  = v31[`i']
		gen prob_`i' =   c[`i']
		
	}
	
	keep in 1
	keep v4_2d opt_* prob_*
	tempfile df_`lev'
	save "df_`lev'", replace

	restore
	
}

* Append each of these files
clear
foreach lev of local levs {

	append using "df_`lev'"
	
}

* Rename v4_2d to append with 4 digits
rename v4_2d v4

* Add version of digits
gen digit_v = 2
	
* Save the file 
tempfile probs_2_digit
save "`probs_2_digit'"

********************************************************************************
* Step 5 - Append all files
********************************************************************************

use "`probs_4_digit'", clear
append using "`probs_3_digit'"
append using "`probs_2_digit'"

* Keep if there is a duplicate the version from the version with more digits 
bys v4 : egen version_max = max(digit_v)
keep if version_max == digit_v

drop digit_v version_max
duplicates tag v4, gen(dup)
tab dup 

gen code = v4 

tempfile test
save "`test'"

********************************************************************************
* Step 6 - Test that the codes are complete
********************************************************************************

* Read full list from V4 from the website
import delimited "https://github.com/worldbank/gld/raw/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check/utilities/isic_codes.txt", delimiter(comma) varnames(1) clear

keep if version == "isic_4"

merge 1:1 code using "`test'"

list code label if _merge == 1

* Works, it is just the letters, we are not doing that here.

********************************************************************************
* Step 7 - Save the full file as text to upload
********************************************************************************

use "`test'", clear 
drop dup code 

* Order by type
order v4 opt_* prob_*

export delimited using "`folder_output'/ai_isic_4_to_31_corr.txt", quote replace
