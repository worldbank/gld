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
	capture use "Block2_External/01_data/01totpop.dta", clear
	if _rc == 0 {  // if file create, otherwise don't 
		
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
			
	}
	
	
	
*-- 02. Female share
	capture use "Block2_External/01_data/02gensplit.dta", clear 
	if _rc == 0 {  // if file create, otherwise don't 
		
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
		
	}
	
*-- 03. Urban share 
	
	capture use "Block2_External/01_data/03urbanshare.dta", clear 
	if _rc == 0 {  // if file create, otherwise don't 
	
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

	capture use "Block2_External/01_data/04children.dta", clear
	if _rc == 0 {  // if file create, otherwise don't 
	
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
	capture use "Block2_External/01_data/05workingage.dta", clear 
	if _rc == 0 {  // if file create, otherwise don't 
	
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
	
	}

	
	
*-- 06. Seniors % 
	capture use "Block2_External/01_data/06seniors.dta", clear 
	if _rc == 0 {  // if file create, otherwise don't 
	
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
	
	}
	
			
	
********************************************************************************
*                           02. Combined figure                                *
********************************************************************************

	* First sift which graphs where created, store that in local graphs_in_memory
	local graphs_in_memory 
	foreach fig in Fig1 Fig2 Fig3 Fig4 Fig5 Fig6 {
		
		capture gr describe `fig'
		if _rc == 0 { // graph actully in memory
			local graphs_in_memory `graphs_in_memory' `fig'
		}
		
	}

	#delimit;
	gr combine `graphs_in_memory',
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
