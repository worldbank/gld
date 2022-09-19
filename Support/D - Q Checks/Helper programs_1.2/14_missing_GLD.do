/*******************************************************************************
								
                            GLD CHECKS Version 1.2
				       11. Block 3 - Missingness report   	  
		   	   																   
*******************************************************************************/


	clear all
	set graphics off
	cd "${output}/${ccode3}_${cyear}_${mydate}"
	
	cap mkdir "Block3_Missing"
	cap mkdir "Block3_Missing/01_data"
	
*-- 01. Prep for missing data table 	
	use "${mydata}", clear
	
	global myvars age male lstatus empstat industrycat4 wage_no_compen unitwage 
	// TO DO. add occupation & education vars 
	// education applies to all. occupation to those employed / in a sector 
	
	keep countrycode year $myvars
	
	** Generate share variables 
	foreach v in $myvars {
			gen sh_`v' =.
	}
	
	** Fill information & save 
	foreach v in $myvars {
		replace sh_`v' = 1 if !missing(`v')
		replace sh_`v' = 0 if  missing(`v')
	}
	
 	keep countrycode year sh_* lstatus empstat wage_no_compen
	save "Block3_Missing/01_data/missing_temp.dta", replace	
	
*-- 02. Compute share of missing 
	
	* Block 1. age, male & lfstatus 	
	use "Block3_Missing/01_data/missing_temp.dta", clear 
	keep countrycode year sh_age sh_male sh_lstatus
	collapse (sum) sh_*, by(countrycode year)
	rename sh_* sh_*_n
	save "Block3_Missing/01_data/missing_num_b1.dta", replace  
	
	use "Block3_Missing/01_data/missing_temp.dta", clear 
	keep countrycode year sh_age sh_male sh_lstatus
	collapse (count) sh_*, by(countrycode year)
	rename sh_* sh_*_d
	save "Block3_Missing/01_data/missing_den_b1.dta", replace  
	
	* Block 2. empstat & industrycat4
	use "Block3_Missing/01_data/missing_temp.dta", clear 
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

	* Block 3. wage_no_compen
	use "Block3_Missing/01_data/missing_temp.dta", clear 
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
	
	* Block 4. unitwage 
	use "Block3_Missing/01_data/missing_temp.dta", clear 
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
	
*-- 03. Combine all blocks 	
	use "Block3_Missing/01_data/missing_num_b1.dta", clear
	forvalues i = 2/4 {
		merge 1:1 countrycode year using "Block3_Missing/01_data/missing_num_b`i'.dta", nogen
	}
	forvalues i = 1/4 {
		merge 1:1 countrycode year using "Block3_Missing/01_data/missing_den_b`i'.dta", nogen
	}

	foreach v in $myvars {
		gen `v'_miss =.
		replace `v'_miss = 100 - 100* sh_`v'_n / sh_`v'_d
	}
	keep countrycode year *_miss
	save "Block3_Missing/01_data/missing_shares.dta", replace
	
	
*-- 04. Export results and clean 
	use "Block3_Missing/01_data/missing_shares.dta", clear 
	rename *_miss *
	
	export excel using "01_summary/B3_missing_vars.xlsx", firstrow(variables) replace

	erase "Block3_Missing/01_data/missing_temp.dta"
	forvalues i = 1/4 {
		erase "Block3_Missing/01_data/missing_num_b`i'.dta"
		erase "Block3_Missing/01_data/missing_den_b`i'.dta"
	}	
	
*-- 02. Figure 	
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
	
		
*-- 03. Conclude missingness report 
	macro drop myvars
	clear
	cd
	di "Missingess report completed for ${ccode3}-${cyear}"	
	
	
**************************   END OF THE DO-FILE  *******************************			
