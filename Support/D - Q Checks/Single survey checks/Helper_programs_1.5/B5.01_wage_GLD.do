/*******************************************************************************
								
                            GLD CHECKS Version 1.4
				         13. Block 5 - Wage analysis    	  
		   	   																   
*******************************************************************************/

	clear all
	set graphics off
	cd "${output}/${ccode3}_${cyear}_${mydate}"
	
	cap mkdir "Block5_Wage"
	cap mkdir "Block5_Wage/01_data"
	cap mkdir "Block5_Wage/02_figures"
	
*-- 01. Check whether there is wage info
	use "${mydata}", clear
	
	cap confirm variable wage_no_compen whours
	if _rc != 0 { // var not present
		
		* If no info at 7 days ref, try to use 12 month one
		cap rename wage_no_compen_year wage_no_compen
		cap rename unitwage_year       unitwage
		cap rename whours_year         whours
		
	}
	
	* Check again, this time with a local evaluator
	local wage_eval = 0
	cap confirm variable wage_no_compen whours
	if _rc == 0 { // wage, either 7d or 12m present
		local wage_eval = 1
	}

	
	********************************************************
	* Only run the next steps if actually wage info present
	********************************************************
	
	* Only if wage_eval == 1
	if `wage_eval' == 1 {
	
	
*-- 02. Wage x education  	
	use "${mydata}", clear
	
	* Run if vars necessary (beyond wage, already evaluated) are present
	cap confirm variable unitwage whours educat4
	if _rc == 0 {
	    
		** Only for paid employees 
		keep if empstat == 1 
		 
		** Calculate hourly wages 
		gen weekwage =.
		replace weekwage = wage_no_compen*7    if unitwage == 1 // (daily)
		replace weekwage = wage_no_compen      if unitwage == 2 // (weekly)
		replace weekwage = wage_no_compen/2    if unitwage == 3 // (every two weeks)
		replace weekwage = wage_no_compen/8.67 if unitwage == 4 // (bi-monthly)
		replace weekwage = wage_no_compen/4.33 if unitwage == 5 // (weekly)
		replace weekwage = wage_no_compen/13   if unitwage == 6 // (Trimester)
		replace weekwage = wage_no_compen/26   if unitwage == 7 // (Biannual)
		replace weekwage = wage_no_compen/52   if unitwage == 8 // (Annual)
		
		gen hwage = weekwage / whours  // hourly wage
		replace hwage = wage_no_compen if unitwage == 9 // (Hourly wage)
				
		winsor2 hwage, replace cuts(1 99) trim // trimming outliers 
		
		** Calculate median (used in the graph, evaluates) plus other distribution details (in the dta only, for evaluation) 
		** plus the sample size
		
		drop if missing(educat4)
		gen sample_size = 1 if !missing(hwage)
		
		collapse (median) hwage (mean) mean_hwage=hwage (p10) p10_wage=hwage (p25) p25_wage=hwage (p75) p75_wage=hwage (p90) p90_wage=hwage (rawsum) sample_size [iw = weight], by(countrycode year educat4) 
		
		** Check: wage should be increasing in education
		gen wage_inc = hwage[_n] - hwage[_n-1]
		gen correct_1 =.
		replace correct_1 = 1 if wage_inc > 0
		replace correct_1 = 0 if wage_inc < 0
		
		** Save & export
		save "Block5_Wage/01_data/wage_1.dta", replace
		
		** Graph 
		sum correct_1 
		if `r(min)' == 1 {
			local color blue 
		}
		if `r(min)' == 0 {
			local color red 
		}
		
		#delimit; 
		twoway connected hwage educat4, lpattern(solid) lcolor(`color') lw(thick) msymbol(i)
		leg(off) ytitle("") xtitle("") name(Fig1, replace)
		xlabel(1(1)4, valuelabel angle(45) labs(small)) 
		ylabel(, nogrid angle(horizontal) labs(small) format(%3.2fc))
		scheme(s2mono) graphregion(fcolor(white) color(white))
		subtitle("Wage by education", position(11) justification(left) size(medsmall));
		#delimit cr
		
	}
 

*-- 03. Wage x occupation
	use "${mydata}", clear
	
	* Run if vars necessary (beyond wage, already evaluated) are present
	cap confirm variable unitwage whours occup_skill
	if _rc == 0 {
	    
		** Only for paid employees 
		keep if empstat == 1 
		 
		** Calculate hourly wages 
		gen weekwage =.
		replace weekwage = wage_no_compen*7    if unitwage == 1 // (daily)
		replace weekwage = wage_no_compen      if unitwage == 2 // (weekly)
		replace weekwage = wage_no_compen/2    if unitwage == 3 // (every two weeks)
		replace weekwage = wage_no_compen/8.67 if unitwage == 4 // (bi-monthly)
		replace weekwage = wage_no_compen/4.33 if unitwage == 5 // (weekly)
		replace weekwage = wage_no_compen/13   if unitwage == 6 // (Trimester)
		replace weekwage = wage_no_compen/26   if unitwage == 7 // (Biannual)
		replace weekwage = wage_no_compen/52   if unitwage == 8 // (Annual)
		
		gen hwage = weekwage / whours  // hourly wage
		replace hwage = wage_no_compen if unitwage == 9 // (Hourly wage)
		
		winsor2 hwage, replace cuts(1 99) trim
		
		** Calculate median (used in the graph, evaluates) plus other distribution details (in the dta only, for evaluation) 
		** plus the sample size
		
		drop if missing(occup_skill)
		gen sample_size = 1 if !missing(hwage)
		
		collapse (median) hwage (mean) mean_hwage=hwage (p10) p10_wage=hwage (p25) p25_wage=hwage (p75) p75_wage=hwage (p90) p90_wage=hwage (rawsum) sample_size [iw = weight], by(countrycode year occup_skill) 
		
		** Check: wage should be increasing in skill level
		gen wage_inc = hwage[_n] - hwage[_n-1]
		gen correct_2 =.
		replace correct_2 = 1 if wage_inc > 0
		replace correct_2 = 0 if wage_inc < 0
		
		** Save & export
		save "Block5_Wage/01_data/wage_2.dta", replace
		
		** Graph 
		sum correct_2 
		if `r(min)' == 1 {
			local color blue 
		}
		if `r(min)' == 0 {
			local color red 
		}
		
		#delimit; 
		twoway connected hwage occup_skill, lpattern(solid) lcolor(`color') lw(thick) msymbol(i)
		leg(off) ytitle("") xtitle("") name(Fig2, replace)
		xlabel(1(1)3, valuelabel angle(45) labs(small)) 
		ylabel(, nogrid angle(horizontal) labs(small) format(%3.2fc))
		scheme(s2mono) graphregion(fcolor(white) color(white))
		subtitle("Wage by occupation", position(11) justification(left) size(medsmall));
		#delimit cr
	    
	}
	
 


*-- 04. Wage x industry
	use "${mydata}", clear
	
	* Run if vars necessary (beyond wage, already evaluated) are present
	cap confirm variable unitwage whours industrycat4
	if _rc == 0 {
	    
		** Only for paid employees 
		keep if empstat == 1 
		* For the purpose of this analysis, treat "other" in indcat4 as services (which they are)
		replace industrycat4 = 3 if industrycat4 == 4
		 
		** Calculate hourly wages 
		gen weekwage =.
		replace weekwage = wage_no_compen*7    if unitwage == 1 // (daily)
		replace weekwage = wage_no_compen      if unitwage == 2 // (weekly)
		replace weekwage = wage_no_compen/2    if unitwage == 3 // (every two weeks)
		replace weekwage = wage_no_compen/8.67 if unitwage == 4 // (bi-monthly)
		replace weekwage = wage_no_compen/4.33 if unitwage == 5 // (weekly)
		replace weekwage = wage_no_compen/13   if unitwage == 6 // (Trimester)
		replace weekwage = wage_no_compen/26   if unitwage == 7 // (Biannual)
		replace weekwage = wage_no_compen/52   if unitwage == 8 // (Annual)
		
		gen hwage = weekwage / whours  // hourly wage
		replace hwage = wage_no_compen if unitwage == 9 // (Hourly wage)
		
		winsor2 hwage, replace cuts(1 99) trim
		
		** Calculate median (used in the graph, evaluates) plus other distribution details (in the dta only, for evaluation) 
		** plus the sample size
		
		drop if missing(industrycat4)
		gen sample_size = 1 if !missing(hwage)
		
		collapse (median) hwage (mean) mean_hwage=hwage (p10) p10_wage=hwage (p25) p25_wage=hwage (p75) p75_wage=hwage (p90) p90_wage=hwage (rawsum) sample_size [iw = weight], by(countrycode year industrycat4) 
		
		** Check: wage should be increasing in industry code 
		gen wage_inc = hwage[_n] - hwage[_n-1]
		gen correct_3 =.
		replace correct_3 = 1 if wage_inc > 0
		replace correct_3 = 0 if wage_inc < 0
		
		** Save & export
		save "Block5_Wage/01_data/wage_3.dta", replace
		
		** Graph
		sum correct_3 
		if `r(min)' == 1 {
			local color blue 
		}
		if `r(min)' == 0 {
			local color red 
		}
		
		#delimit; 
		twoway connected hwage industrycat4, lpattern(solid) lcolor(`color') lw(thick) msymbol(i)
		leg(off) ytitle("") xtitle("") name(Fig3, replace)
		xlabel(1(1)3, valuelabel angle(45) labs(small)) 
		ylabel(, nogrid angle(horizontal) labs(small) format(%3.2fc))
		scheme(s2mono) graphregion(fcolor(white) color(white))
		subtitle("Wage by industry", position(11) justification(left) size(medsmall));
		#delimit cr
		
	}
	
 


*-- 05. Wage x age 
	use "${mydata}", clear
	
	* Assume age is always there
	
	** Only for paid employees 
	keep if empstat == 1 
	 
	** Calculate hourly wages 
	gen weekwage =.
	replace weekwage = wage_no_compen*7    if unitwage == 1 // (daily)
	replace weekwage = wage_no_compen      if unitwage == 2 // (weekly)
	replace weekwage = wage_no_compen/2    if unitwage == 3 // (every two weeks)
	replace weekwage = wage_no_compen/8.67 if unitwage == 4 // (bi-monthly)
	replace weekwage = wage_no_compen/4.33 if unitwage == 5 // (weekly)
	replace weekwage = wage_no_compen/13   if unitwage == 6 // (Trimester)
	replace weekwage = wage_no_compen/26   if unitwage == 7 // (Biannual)
	replace weekwage = wage_no_compen/52   if unitwage == 8 // (Annual)
	
	gen hwage = weekwage / whours  // hourly wage
	replace hwage = wage_no_compen if unitwage == 9 // (Hourly wage)
	
	winsor2 hwage, replace cuts(1 99) trim

	** Create age groups 
	gen age2 =.
	replace age2 = 1 if inrange(age, 0, 14)   // child
	replace age2 = 2 if inrange(age, 15, 24)  // young
	replace age2 = 3 if inrange(age, 25, 54)  // adult
	replace age2 = 4 if inrange(age, 55, 70)  // senior
	replace age2 = 5 if inrange(age, 71, 120) // retiree 
	
	label define age2l 1 "Child" 2 "Young" 3 "Adult" 4 "Senior" 5 "Retiree"
	label values age2 age2l
	
	** Calculate median (used in the graph, evaluates) plus other distribution details (in the dta only, for evaluation) 
	** plus the sample size
	
	drop if missing(age2)
	gen sample_size = 1 if !missing(hwage)
	
	collapse (median) hwage (mean) mean_hwage=hwage (p10) p10_wage=hwage (p25) p25_wage=hwage (p75) p75_wage=hwage (p90) p90_wage=hwage (rawsum) sample_size [iw = weight], by(countrycode year age2) 
	
	** Check: wage should increase until adulthood, decrease for retirees 
		// we remain agontic about wheter adult >< senior 
	gen wage_inc = hwage[_n] - hwage[_n-1]
	gen correct_4 =.
	replace correct_4 = 1 if wage_inc > 0 & age2 <= 3
	replace correct_4 = 1 if wage_inc < 0 & age2  > 4
	
	replace correct_4 = 0 if wage_inc < 0 & age2 <= 3
	replace correct_4 = 0 if wage_inc > 0 & age2  > 4
	
	** Save & export
	save "Block5_Wage/01_data/wage_4.dta", replace
	
	** Graph 
	sum correct_4 
	if `r(min)' == 1 {
		local color blue 
	}
	if `r(min)' == 0 {
		local color red 
	}
	
	#delimit; 
	twoway connected hwage age2, lpattern(solid) lcolor(`color') lw(thick) msymbol(i)
	leg(off) ytitle("") xtitle("") name(Fig4, replace)
	xlabel(1(1)5, valuelabel angle(45) labs(small)) 
	ylabel(, nogrid angle(horizontal) labs(small) format(%3.2fc))
	scheme(s2mono) graphregion(fcolor(white) color(white))
	subtitle("Wage by age", position(11) justification(left) size(medsmall));
	#delimit cr 


*-- 06. Combine graphs & export 

	* Check which Figures where made (that start with Fig) -> list stored in local `r(list)'
	graph dir Fig*
	
	#delimit;
	gr combine `r(list)',
	scheme(s2mono) graphregion(fcolor(white) color(white)) c(2)
	subtitle("Wage analysis, ${ccode3} ${cyear}", position(11) justification(left) size(medsmall));
	#delimit cr
	graph export "01_summary/B5_wage_analysis.pdf", replace
	graph export "Block5_Wage/02_figures/wage_analysis.pdf", replace
	
	
*-- 07. Checks & flags	
	clear
	forvalues i = 1/4 {
		cap append using "Block5_Wage/01_data/wage_`i'.dta"
	}
	
	egen find0s = rowmin(correct*)
	keep if find0s == 0
	
	count
	if `r(N)' > 0 {
		save "Block5_Wage/01_data/wage_results.dta", replace 
		export excel using "01_summary/B5_wage_results.xlsx", firstrow(variables) replace	
	}


*-- 08. Conclude checks	
	clear
	cd
	di "Wage analysis completed for ${ccode3}-${cyear}"
	
}
	
**************************   END OF THE DO-FILE  *******************************		
