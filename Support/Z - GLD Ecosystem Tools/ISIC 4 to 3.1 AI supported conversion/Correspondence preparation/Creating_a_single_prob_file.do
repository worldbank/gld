

****************************************
****************************************
** Code to generate single full list  **
** of probabilities from AI output    **
****************************************
****************************************

/*
	---> Overall strategy <---

We have run the code to create the AI generate probabilities. Each time there 
are three potential errors in the code. 

(1) Fails to create a correspondence that exists in the full list. 
(2) Invents an extra correspondence that does not exists.
(3) Repeats the same correspondence 

To solve this the code has been run 100 times. Here we will read it in, correct
some of the errors and average out the probabilities to get to a final corres-
pondence list that has all combination from the full list. 

The corrections are:

(1) Create correspondence, assign probability 0
(2) Drop invented correspondence
(3) Take average of probs of repeats, keep a single

*/

********************************************************************************
* Step 1 - Prep environment
********************************************************************************

* Start by clearing, no abbreviations
clear all
set varabbrev off 

* Define folder we are going to work from
local folder_input  "[prior folder path]/ISIC 4 to 3.1 AI supported conversion/AI Code/Runs"
local folder_output "[prior folder path]/ISIC 4 to 3.1 AI supported conversion/Correspondence preparation"

********************************************************************************
* Step 2 - Read through the 100 iterations, clean, make tempfiles
********************************************************************************

* Read in full correspondence list from the UN website
import delimited "https://unstats.un.org/unsd/classifications/Econ/tables/ISIC/ISIC4_ISIC31/ISIC4_ISIC31.txt", delimiter(comma) varnames(1) clear

rename partialisic31 partial 

gen v4 = string(isic4code, "%04.0f")
gen v31 = string(isic31code, "%04.0f")

drop isic4code isic31code

tempfile full_un_corr
save "`full_un_corr'"

* Loop through AI versions
foreach i of numlist 1/100 {
	
	* Read AI generated correspondence list
	import excel "`folder_input'/run_`i'.xlsx", sheet("Sheet1") firstrow clear
	
	* Rename variables, keep relevant ones
	rename version_4 v4
	rename version_31 v31
	rename ProportionofJobs p_`i'
	keep v4 v31 p_`i'
	
	* Easiest way to get rid of duplicates is to collapse by combinations, keep average 
	collapse (mean) p_`i', by(v4 v31)
	
	quietly : merge 1:1 v4 v31 using "`full_un_corr'"
	
	* Drop if combination only exists in AI version
	drop if _merge == 1
	
	* Set probability to 0 if combination from UN is not in AI version 
	replace p_`i' = 0 if _merge == 2
	
	* Drop _merge, partialisic4, partial, detail
	drop _merge partialisic4 partial detail
		
	* Save this 
	tempfile run_`i'
	save "`run_`i''"
	
}

********************************************************************************
* Step 3 - Append all runs from Step 2
********************************************************************************

* Note that at the end of Step 2 run_100 is loaded, so we can _merge with 1-99
foreach i of numlist 1/99 {
	
	* Merge
	quietly : merge 1:1 v4 v31 using "`run_`i''", nogen
	
}

********************************************************************************
* Step 4 - Make average probabilites, ensure it adds up to one
********************************************************************************

egen p_all = rowmean(p_100-p_99)

* Ensure probabilities sum up to 1
bys v4 : egen tot = total(p_all)
gen p = p_all/tot

********************************************************************************
* Step 5 - Keep relevant info, store
********************************************************************************

drop p_* tot 

save                   "`folder_output'/final_ai_corr.dta", replace
export delimited using "`folder_output'/final_ai_corr.csv", replace 