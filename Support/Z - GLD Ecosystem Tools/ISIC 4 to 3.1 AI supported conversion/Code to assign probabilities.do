****************************************
****************************************
** Code to apply AI correspondences   **
** to ISIC 4 data, obtain 3.1 values  **
****************************************
****************************************

/*

This code shows how to apply the AI generated to a GLD file
to generate a set of 3.1 ISIC values that corresponde to the
survey's ISIC 4 values.

The logic of the assignment algorithm is 

1) Apply it to rows that have industrycat_isic information
2) Probabilities are cumulative 0-1, we create a unform random variable, where
   random is smaller or equal to the probability, assign that option.
3) Since about half the codes have jsut one option, 90%+ have fewer than 5,
   the checking from smallest to largest is efficient and quick.

*/

********************************************************************************
* Step 1 - Prep environment
********************************************************************************

* Start by clearing, no abbreviations
clear all
set varabbrev off 

* Define seed, a number to use to initiate the random process for reproducibility
local seed 61035

* Define path to a GLD file
local gld_path "[Your path here]"

********************************************************************************
* Step 2 - Read in data, ensure it is correct
********************************************************************************

* Read data
use "`gld_path'", clear

* Ensure it is ISIC 4
if isic_version != "isic_4" {
	
	dis as error "Your data is not from ISIC 4, not applicable"
	exit
	
}

********************************************************************************
* Step 3 - Read in AI correspondences from GitHub
********************************************************************************

preserve 

	import delimited "https://raw.githubusercontent.com/worldbank/gld/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%204%20to%203.1%20AI%20supported%20conversion/ai_isic_4_to_31_corr.txt", stringcols(1/57) clear 
	tempfile test
	save "`test'"

restore

********************************************************************************
* Step 4 - Merge AI correspondences
********************************************************************************

gen v4 = industrycat_isic

merge m:1 v4 using "`test'", keep(1 3) nogen


********************************************************************************
* Step 5 - Run code assignment algorithm
********************************************************************************

* Create uniform variable that will be used to randomly assign
set seed `seed'
gen random = runiform()

* Create variable that will hold new assignment
gen ind_isic_31 = ""

* Count to get the total number of rows
quietly: count

* We want to show dots, text to indicate progress, initialise here their counters
local twos 1
local tens 1

* Display the initial message (_continue prevents the line break)
display as text "Progress: " _continue

* Loop through each observation (row), acting only if variable of interest is not missing
forval row = 1/`r(N)' {
    
	
	*--------- Actual assignment
	*---------------------------
	
	* Evaluate wheter v4 is not missing
	if !missing(v4[`row']) {
		
		* Create locals that evaluate whether to continue, what option to chose (note 0/1 code as F/T)
		local number 1
		local is_it_lower 0
		
		while `is_it_lower' == 0 {
			
			* Check whether random is smaller than the first probability
			local is_it_lower = random[`row'] <= prob_`number'[`row']
			
			* If we are below (or equal as prob_1 == 1 selects opt_1), assign opt_*
			if `is_it_lower' == 1 {
				
				quietly : replace ind_isic_31 = opt_`number' in `row'
				
			} // Close assigning option
			
			* Increase the number so we move to the next set of probs, options
			local ++number

		} // Close while check: is prob lower than random
		
	} // Close check v4 not missing
	
	
	*--------- Displaying progress
	*-----------------------------
	
	* Calculate current percentage, initiate last percentage at 0
    local percentage      = round(`row' / `r(N)' * 100)
	local last_percentage = 0
	
	* Check if it's time to display a new dot (every 2%)
    if `percentage' >= `twos'*2 {
		
		* If we are at a 2 step, print, increase dot count
        display as text "." _continue
		local ++twos
		
	} // Close display dots for 2% increase
	
	* Check if it's time to display where we are at (every 10%)
	if `percentage' >= `tens'*10 {
		
		* If we are at a 10 step, print, increase dot count
        display as text "`percentage'%" _continue
		local ++tens
	} // Close display pct for 10% increase
	
	* Drop variables we don't want to keep 
	drop opt_* prob_* random v4

} // Close loop over observations

* End the progress display
display

* Display completion message
display as text "Done!"
