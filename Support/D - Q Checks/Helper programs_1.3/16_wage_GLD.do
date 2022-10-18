/*******************************************************************************
								
                            GLD CHECKS Version 1.3
				         13. Block 5 - Wage analysis    	  
		   	   																   
*******************************************************************************/

	clear all
	set graphics off
	cd "${output}/${ccode3}_${cyear}_${mydate}"
	
	cap mkdir "Block5_Wage"
	cap mkdir "Block5_Wage/01_data"
	cap mkdir "Block5_Wage/02_figures"
	
*-- 01. Wage x education  	
	use "${mydata}", clear
	
	** Only for paid employees 
	keep if empstat == 1 
	 
	** Calculate hourly wages 
	gen weekwage =.
	replace weekwage = wage_no_compen      if unitwage == 2 // (weekly)
	replace weekwage = wage_no_compen/4.2  if unitwage == 5 // (weekly)
	
	gen hwage = weekwage / whours  // hourly wage
	
	winsor2 hwage, replace cuts(1 99) trim // trimming outliers 
	
	** Calculate mean 
	drop if missing(educat4)
	collapse (mean) hwage [iw = weight], by(countrycode year educat4) 
	
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

*-- 02. Wage x occupation
	use "${mydata}", clear
	
	** Only for paid employees 
	keep if empstat == 1 
	 
	** Calculate hourly wages 
	gen weekwage =.
	replace weekwage = wage_no_compen      if unitwage == 2 // (weekly)
	replace weekwage = wage_no_compen/4.2  if unitwage == 5 // (weekly)
	
	gen hwage = weekwage / whours  // hourly wage
	
	winsor2 hwage, replace cuts(1 99) trim
	
	** Calculate mean 
	drop if missing(occup_skill)
	collapse (mean) hwage [iw = weight], by(countrycode year occup_skill) 
	
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


*-- 03. Wage x industry
	use "${mydata}", clear
	
	** Only for paid employees 
	keep if empstat == 1 
	drop if industrycat4 == 4 // drop "other"
	 
	** Calculate hourly wages 
	gen weekwage =.
	replace weekwage = wage_no_compen      if unitwage == 2 // (weekly)
	replace weekwage = wage_no_compen/4.2  if unitwage == 5 // (weekly)
	
	gen hwage = weekwage / whours  // hourly wage
	
	winsor2 hwage, replace cuts(1 99) trim
	
	** Calculate mean 
	drop if missing(industrycat4)
	collapse (mean) hwage [iw = weight], by(countrycode year industrycat4) 
	
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


*-- 04. Wage x age 
	use "${mydata}", clear
	
	** Only for paid employees 
	keep if empstat == 1 
	 
	** Calculate hourly wages 
	gen weekwage =.
	replace weekwage = wage_no_compen      if unitwage == 2 // (weekly)
	replace weekwage = wage_no_compen/4.2  if unitwage == 5 // (weekly)
	
	gen hwage = weekwage / whours  // hourly wage
	
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
	
	** Calculate mean 
	drop if missing(age2)
	collapse (mean) hwage [iw = weight], by(countrycode year age2) 
	
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


*-- 05. Combine graphs & export 
	#delimit;
	gr combine Fig1 Fig2 Fig3 Fig4,
	scheme(s2mono) graphregion(fcolor(white) color(white)) c(2)
	subtitle("Wage analysis, ${ccode3} ${cyear}", position(11) justification(left) size(medsmall));
	#delimit cr
	graph export "01_summary/B5_wage_analysis.pdf", replace
	graph export "Block5_Wage/02_figures/wage_analysis.pdf", replace
	
	
*-- 06. Checks & flags	
	clear
	forvalues i = 1/4 {
		append using "Block5_Wage/01_data/wage_`i'.dta"
	}
	
	egen find0s = rowmin(correct*)
	keep if find0s == 0
	
	count
	if `r(N)' > 0 {
		save "Block5_Wage/01_data/wage_results.dta", replace 
		export excel using "01_summary/B5_wage_results.xlsx", firstrow(variables) replace	
	}


*-- 07. Conclude checks	
	clear
	cd
	di "Wage analysis completed for ${ccode3}-${cyear}"
	
	
**************************   END OF THE DO-FILE  *******************************		
