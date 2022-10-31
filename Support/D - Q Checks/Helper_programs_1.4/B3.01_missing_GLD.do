/*******************************************************************************
								
                            GLD CHECKS Version 1.4
				       11. Block 3 - Missingness report   	  
		   	   																   
*******************************************************************************/


	clear all
	set graphics off
	cd "${output}/${ccode3}_${cyear}_${mydate}"
	
	cap mkdir "Block3_Missing"
	cap mkdir "Block3_Missing/01_data"
	
*-- 01. Prep for missing data table 	
	use "${mydata}", clear
	
	* Create a local to keep myvars, but only if they exist in the data
	local fullvars age male urban lstatus empstat industrycat4 wage_no_compen unitwage 

	* Create empty local that will keep relevant vars
	local myvars
	foreach var of local fullvars {
	
		cap confirm variable `var'
		if _rc == 0 { // var is in dataset
			local myvars `myvars' `var'
		} 
		
	}

	keep countrycode year `myvars' minlaborage
	
	** Generate missing share variables 
	foreach v of local myvars {
	
		* Vars age, male, urban should not be missing for any
		if "`v'" == "age" | "`v'" == "male"  | "`v'" == "urban" { 

			gen sh_`v' =.
			replace sh_`v' = 1 if !missing(`v')
			replace sh_`v' = 0 if  missing(`v')

		}
		* Else if lstatus, only if >= minlaborage supposed to answer
		else if "`v'" == "lstatus" {

			gen sh_`v' =.
			replace sh_`v' = 1 if !missing(`v') & age >= minlaborage 
			replace sh_`v' = 0 if  missing(`v') & age >= minlaborage 	

		}
		* All others missing is an issue if lstatus == 1
		else {

			gen sh_`v' =.
			replace sh_`v' = 1 if !missing(`v') & lstatus == 1
			replace sh_`v' = 0 if  missing(`v') & lstatus == 1 	

		}
	
	}
	
	save "Block3_Missing/01_data/missing_temp.dta", replace	
	
*-- 02. Compute share of missing 
	
	* Block 1. age, male, urban, & lfstatus 
	use "Block3_Missing/01_data/missing_temp.dta", clear 
	
	* Do if all relevant vars present
	cap confirm variable countrycode year sh_age sh_male sh_urban sh_lstatus
	if _rc == 0 {
		
		keep countrycode year sh_age sh_male sh_urban sh_lstatus
		collapse (sum) sh_*, by(countrycode year)
		rename sh_* sh_*_n
		save "Block3_Missing/01_data/missing_num_b1.dta", replace
		
		use "Block3_Missing/01_data/missing_temp.dta", clear 
		keep countrycode year sh_age sh_male sh_urban sh_lstatus
		collapse (count) sh_*, by(countrycode year)
		rename sh_* sh_*_d
		save "Block3_Missing/01_data/missing_den_b1.dta", replace  
		
	}
  
	
	* Block 2. empstat & industrycat4
	use "Block3_Missing/01_data/missing_temp.dta", clear 
	
	* Do if all relevant vars present
	cap confirm variable countrycode year sh_empstat sh_industrycat4
	if _rc == 0 {
			
		keep if lstatus == 1 // employed 
		keep countrycode year sh_empstat sh_industrycat4
		collapse (sum) sh_*, by(countrycode year)
		rename sh_* sh_*_n
		save "Block3_Missing/01_data/missing_num_b2.dta", replace  
		
		use "Block3_Missing/01_data/missing_temp.dta", clear 
		keep if lstatus == 1 // employed 
		keep countrycode year sh_empstat sh_industrycat4
		collapse (count) sh_*, by(countrycode year)
		rename sh_* sh_*_d
		save "Block3_Missing/01_data/missing_den_b2.dta", replace  

	}
	
	* Block 3. wage_no_compen
	use "Block3_Missing/01_data/missing_temp.dta", clear 
	
	* Do if all relevant vars present
	cap confirm variable countrycode year sh_wage_no_compen
	if _rc == 0 {
		
		keep if empstat == 1 // Paid employee 
		keep countrycode year sh_wage_no_compen
		collapse (sum) sh_*, by(countrycode year)
		rename sh_* sh_*_n
		save "Block3_Missing/01_data/missing_num_b3.dta", replace  	
		
		use "Block3_Missing/01_data/missing_temp.dta", clear 
		keep if empstat == 1 // Paid employee 
		keep countrycode year sh_wage_no_compen
		collapse (count) sh_*, by(countrycode year)
		rename sh_* sh_*_d
		save "Block3_Missing/01_data/missing_den_b3.dta", replace  
		
	}
	
	* Block 4. unitwage 
	use "Block3_Missing/01_data/missing_temp.dta", clear 
	
	* Do if all relevant vars present
	cap confirm variable countrycode year wage_no_compen
	if _rc == 0 {
		
		keep if !missing(wage_no_compen) // has wage data 
		keep countrycode year sh_unitwage
		collapse (sum) sh_*, by(countrycode year)
		rename sh_* sh_*_n
		save "Block3_Missing/01_data/missing_num_b4.dta", replace  	
		
		use "Block3_Missing/01_data/missing_temp.dta", clear 
		keep if !missing(wage_no_compen) // has wage data 
		keep countrycode year sh_unitwage
		collapse (count) sh_*, by(countrycode year)
		rename sh_* sh_*_d
		save "Block3_Missing/01_data/missing_den_b4.dta", replace  
		
	}
	
	
*-- 03. Combine all blocks 
	local files_all : dir "Block3_Missing/01_data" files "missing_*"
	local files_den : dir "Block3_Missing/01_data" files "missing_den*"
	local files_num : dir "Block3_Missing/01_data" files "missing_num*"

	local file_count : word count `files_num'
	dis `file_count'

	* Strategy to merge it all depends. If ther is just one file, easy
	if `file_count' == 1 {
		use "`files_num'", clear
		merge 1:1 countrycode year using "`files_den'", nogen
		
	}

	* If several, need to open one first by slicing the locals, then merge
	if `file_count' > 1 {
		
		* Split num block into first element, others
		local first_num : word 1 of `files_num'
		local other_num : list files_num - first_num

		* Start by loading first element
		use "Block3_Missing/01_data/`first_num'", clear
		
		* Then merge in every other num file
		foreach f of local other_num {
			merge 1:1 countrycode year using "Block3_Missing/01_data/`f'", nogen 
		}
		
		* Now merge in the den files
		foreach f of local files_den {
			merge 1:1 countrycode year using "Block3_Missing/01_data/`f'", nogen 
		}
	}

	foreach v of local myvars {
		gen `v'_miss =.
		replace `v'_miss = 100 - 100* sh_`v'_n / sh_`v'_d
	}
	
	keep countrycode year *_miss
	save "Block3_Missing/01_data/missing_shares.dta", replace
	
	
*-- 04. Export results and clean 
	use "Block3_Missing/01_data/missing_shares.dta", clear 
	rename *_miss *
	
	export excel using "01_summary/B3_missing_vars.xlsx", firstrow(variables) replace

	* Erase files no longer needed
	foreach file of local files_all { // This local was defined at the start of subsection 03
		erase "Block3_Missing/01_data/`file'"
	}
	
*-- 05. Figure 	
	use "Block3_Missing/01_data/missing_shares.dta", clear 
	rename *_miss value*
	reshape long value, i(countrycode year) j(variable) string
	
	#delimit ;
	graph bar value, over(variable, label(angle(30) labsize(small))) bar(1, color(red))
	ytitle("")
	ylabel( , nogrid angle(horizontal) labs(small))
	scheme(s2mono) graphregion(fcolor(white) color(white))
	subtitle("Percentage of missing values", position(11) justification(left) size(medsmall));
	#delimit cr 
	graph export "01_summary/B3_missing_fig.pdf", replace	
	
		
*-- 06. Conclude missingness report 
	macro drop myvars
	clear
	cd
	di "Missingess report completed for ${ccode3}-${cyear}"	
	
	
**************************   END OF THE DO-FILE  *******************************			
