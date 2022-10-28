/*******************************************************************************
								
                            GLD CHECKS Version 1.4
                        06. Block 2 - External data
                  2A. Demographic variables - Output figures
		   	   																   
*******************************************************************************/
	
	clear all
	set graphics off
	cd "${output}/${ccode3}_${cyear}_${mydate}"

********************************************************************************
*                           01. Individual figures                             *
********************************************************************************

*-- 01. Total population
	use "Block2_External/01_data/01totpop.dta", clear
	count 
	local c = `r(N)' 
		
	#delimit ;
	twoway rcap    lb ub s1  if source == "GLD"                   , lcolor(red)                 ||
	       scatter value s1  if source == "GLD"                   , msymbol(O) mcolor(red)      || 
		   rcap    lb ub s1  if source != "GLD" & year == ${cyear}, lcolor(blue)                || 
		   rcap    lb ub s1  if source != "GLD" & year != ${cyear}, lcolor(blue) lpattern(dash) || 
		   scatter value s1  if source != "GLD" & year == ${cyear}, msymbol(O) mcolor(blue)     ||
		   scatter value s1  if source != "GLD" & year != ${cyear}, msymbol(T) mcolor(blue)
	leg(off) ytitle("") xtitle("")  name(Fig1, replace)
	xlabel(1(1)`c', valuelabel angle(45) labs(small))
	ylabel( , nogrid angle(horizontal) labs(small))
	scheme(s2mono) graphregion(fcolor(white) color(white))
	subtitle("Total population", position(11) justification(left) size(medsmall));
	#delimit cr 
	graph export "Block2_External/02_figures/Fig1.pdf", replace	
	

	
*-- 02. Female share
	use "Block2_External/01_data/02gensplit.dta", clear 
	count 
	local c = `r(N)' 
	
	#delimit ;
	twoway rcap    lb ub s1  if source == "GLD"                   , lcolor(red)                 ||
	       scatter value s1  if source == "GLD"                   , msymbol(O) mcolor(red)      || 
		   rcap    lb ub s1  if source != "GLD" & year == ${cyear}, lcolor(blue)                || 
		   rcap    lb ub s1  if source != "GLD" & year != ${cyear}, lcolor(blue) lpattern(dash) || 
		   scatter value s1  if source != "GLD" & year == ${cyear}, msymbol(O) mcolor(blue)     ||
		   scatter value s1  if source != "GLD" & year != ${cyear}, msymbol(T) mcolor(blue) 
	leg(off) ytitle("") xtitle("") name(Fig2, replace)
	xlabel(1(1)`c', valuelabel angle(45) labs(small))
	ylabel( , nogrid angle(horizontal) labs(small))
	scheme(s2mono) graphregion(fcolor(white) color(white))
	subtitle("Female share", position(11) justification(left) size(medsmall));
	#delimit cr 
	graph export "Block2_External/02_figures/Fig2.pdf", replace		
	
	
*-- 03. Urban share 
	
	** Determin presence first 
	use "${mydata}", clear
	describe, replace
	count if name == "urban"
	
	if 	`r(N)' == 0 {
		gen dot =.

		#delimit ;
		twoway scatter dot dot,
		leg(off) ytitle("") xtitle("") name(Fig3, replace)
		xlabel(, valuelabel angle(45) labs(small)) 
		ylabel( , nogrid angle(horizontal) labs(small))
		scheme(s2mono) graphregion(fcolor(white) color(white))
		subtitle("Urban data not available ", position(11) justification(left) size(medsmall));
		#delimit cr 
		graph export "Block2_External/02_figures/Fig3.pdf", replace		
	}
	else {

		use "Block2_External/01_data/03urbanshare.dta", clear 
		count 
		local c = `r(N)' 
		
		#delimit ;
		twoway rcap    lb ub s1  if source == "GLD"                   , lcolor(red)                 ||
			   scatter value s1  if source == "GLD"                   , msymbol(O) mcolor(red)      || 
			   rcap    lb ub s1  if source != "GLD" & year == ${cyear}, lcolor(blue)                || 
			   rcap    lb ub s1  if source != "GLD" & year != ${cyear}, lcolor(blue) lpattern(dash) || 
			   scatter value s1  if source != "GLD" & year == ${cyear}, msymbol(O) mcolor(blue)     ||
			   scatter value s1  if source != "GLD" & year != ${cyear}, msymbol(T) mcolor(blue) 
		leg(off) ytitle("") xtitle("") name(Fig3, replace)
		xlabel(1(1)`c', valuelabel angle(45) labs(small)) 
		ylabel( , nogrid angle(horizontal) labs(small))
		scheme(s2mono) graphregion(fcolor(white) color(white))
		subtitle("Urban share", position(11) justification(left) size(medsmall));
		#delimit cr 
		graph export "Block2_External/02_figures/Fig3.pdf", replace		
	}
	
*-- 04. Children %
	** Determine presence of children
	use "${mydata}", clear
	sum age 

	if 	`r(min)' >= 15 {
		gen dot =.
		
			
		#delimit ;
		twoway scatter dot dot,
		leg(off) ytitle("") xtitle("") name(Fig4, replace)
		xlabel(, valuelabel angle(45) labs(small)) 
		ylabel( , nogrid angle(horizontal) labs(small))
		scheme(s2mono) graphregion(fcolor(white) color(white))
		subtitle("Children data not available ", position(11) justification(left) size(medsmall));
		#delimit cr 
		graph export "Block2_External/02_figures/Fig4.pdf", replace	
	}
	else {	

		use "Block2_External/01_data/04children.dta", clear 
		count 
		local c = `r(N)' 
		
		#delimit ;
		twoway rcap    lb ub s1  if source == "GLD"                   , lcolor(red)                 ||
			   scatter value s1  if source == "GLD"                   , msymbol(O) mcolor(red)      || 
			   rcap    lb ub s1  if source != "GLD" & year == ${cyear}, lcolor(blue)                || 
			   rcap    lb ub s1  if source != "GLD" & year != ${cyear}, lcolor(blue) lpattern(dash) || 
			   scatter value s1  if source != "GLD" & year == ${cyear}, msymbol(O) mcolor(blue)     ||
			   scatter value s1  if source != "GLD" & year != ${cyear}, msymbol(T) mcolor(blue)
		leg(off) ytitle("") xtitle("") name(Fig4, replace) 
		xlabel(1(1)`c', valuelabel angle(45) labs(small)) 
		ylabel( , nogrid angle(horizontal) labs(small))
		scheme(s2mono) graphregion(fcolor(white) color(white))
		subtitle("Children 0-14 (%)", position(11) justification(left) size(medsmall));
		#delimit cr 
		graph export "Block2_External/02_figures/Fig4.pdf", replace		
	
	}
	
*-- 05. Working age % 
	use "Block2_External/01_data/05workingage.dta", clear 
	count 
	local c = `r(N)' 
		
	#delimit ;
	twoway rcap    lb ub s1  if source == "GLD"                   , lcolor(red)                 ||
	       scatter value s1  if source == "GLD"                   , msymbol(O) mcolor(red)      || 
		   rcap    lb ub s1  if source != "GLD" & year == ${cyear}, lcolor(blue)                || 
		   rcap    lb ub s1  if source != "GLD" & year != ${cyear}, lcolor(blue) lpattern(dash) || 
		   scatter value s1  if source != "GLD" & year == ${cyear}, msymbol(O) mcolor(blue)     ||
		   scatter value s1  if source != "GLD" & year != ${cyear}, msymbol(T) mcolor(blue) 
	leg(off) ytitle("") xtitle("") name(Fig5, replace)
	xlabel(1(1)`c', valuelabel angle(45) labs(small)) 
	ylabel( , nogrid angle(horizontal) labs(small))
	scheme(s2mono) graphregion(fcolor(white) color(white))
	subtitle("Working age 15-64 (%)", position(11) justification(left) size(medsmall));
	#delimit cr 
	graph export "Block2_External/02_figures/Fig5.pdf", replace		
	
	
*-- 06. Seniors % 
	use "Block2_External/01_data/06seniors.dta", clear 
	count 
	local c = `r(N)' 
		
	#delimit ;
	twoway rcap    lb ub s1  if source == "GLD"                   , lcolor(red)                 ||
	       scatter value s1  if source == "GLD"                   , msymbol(O) mcolor(red)      || 
		   rcap    lb ub s1  if source != "GLD" & year == ${cyear}, lcolor(blue)                || 
		   rcap    lb ub s1  if source != "GLD" & year != ${cyear}, lcolor(blue) lpattern(dash) || 
		   scatter value s1  if source != "GLD" & year == ${cyear}, msymbol(O) mcolor(blue)     ||
		   scatter value s1  if source != "GLD" & year != ${cyear}, msymbol(T) mcolor(blue)
	leg(off) ytitle("") xtitle("") name(Fig6, replace)
	xlabel(1(1)`c', valuelabel angle(45) labs(small)) 
	ylabel( , nogrid angle(horizontal) labs(small))
	scheme(s2mono) graphregion(fcolor(white) color(white))
	subtitle("Seniors 65+ (%)", position(11) justification(left) size(medsmall));
	#delimit cr 
	graph export "Block2_External/02_figures/Fig6.pdf", replace			
	
	
	
********************************************************************************
*                           02. Combined figure                                *
********************************************************************************

	#delimit;
	gr combine Fig1 Fig2 Fig3 Fig4 Fig5 Fig6,
	scheme(s2mono) graphregion(fcolor(white) color(white)) c(3)
	subtitle("Block 2A. Demographic Variables, ${ccode3}", position(11) justification(left) size(medsmall));
	#delimit cr
	graph export "Block2_External/02_figures/2A_figures.pdf", replace

	
********************************************************************************
*                          03. Flagged variables                               *
********************************************************************************
	
	use "Block2_External/01_data/Checks_results.dta", clear
	egen groupflag = mean(flag), by(varchecked)
	keep if groupflag == 1

	
**************************   END OF THE DO-FILE  *******************************	
