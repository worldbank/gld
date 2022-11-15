/*******************************************************************************
								
                             GLD CHECKS Version 1.4
                          07. Block 2 - External data
				 2B.1. Labor force variables 1 - Output figures
		   	   																   
*******************************************************************************/

	clear all
	set graphics off
	cd "${output}/${ccode3}_${cyear}_${mydate}"
	
********************************************************************************
*                           01. Individual figures                             *
********************************************************************************

*-- 01. Labor fore size 
	use "Block2_External/01_data/07labforce.dta", clear 
	count 
	local c = `r(N)' 
	
	#delimit ;
	twoway rcap    lb ub s1  if source == "GLD"                   , lcolor(red)                 ||
	       scatter value s1  if source == "GLD"                   , msymbol(O) mcolor(red)      || 
		   rcap    lb ub s1  if source != "GLD" & year == ${cyear}, lcolor(blue)                || 
		   rcap    lb ub s1  if source != "GLD" & year != ${cyear}, lcolor(blue) lpattern(dash) || 
		   scatter value s1  if source != "GLD" & year == ${cyear}, msymbol(O) mcolor(blue)     ||
		   scatter value s1  if source != "GLD" & year != ${cyear}, msymbol(T) mcolor(blue)
	leg(off) ytitle("") xtitle("")  name(Fig7, replace)
	xlabel(1(1)`c', valuelabel angle(45) labs(small)) 
	ylabel( , nogrid angle(horizontal) labs(small))
	scheme(s2mono) graphregion(fcolor(white) color(white))
	subtitle("Labor force size", position(11) justification(left) size(medsmall));
	#delimit cr 
	graph export "Block2_External/02_figures/Fig7.pdf", replace	
	
	
*-- 02. Labor force participation rate 
	use "Block2_External/01_data/08labfpart.dta", clear 
	count 
	local c = `r(N)' 
	
	#delimit ;
	twoway rcap    lb ub s1  if source == "GLD"                   , lcolor(red)                 ||
	       scatter value s1  if source == "GLD"                   , msymbol(O) mcolor(red)      || 
		   rcap    lb ub s1  if source != "GLD" & year == ${cyear}, lcolor(blue)                || 
		   rcap    lb ub s1  if source != "GLD" & year != ${cyear}, lcolor(blue) lpattern(dash) || 
		   scatter value s1  if source != "GLD" & year == ${cyear}, msymbol(O) mcolor(blue)     ||
		   scatter value s1  if source != "GLD" & year != ${cyear}, msymbol(T) mcolor(blue)  
	leg(off) ytitle("") xtitle("")  name(Fig8, replace)
	xlabel(1(1)`c', valuelabel angle(45) labs(small)) 
	ylabel( , nogrid angle(horizontal) labs(small))
	scheme(s2mono) graphregion(fcolor(white) color(white))
	subtitle("Labor force participation rate", position(11) justification(left) size(medsmall));
	#delimit cr 
	graph export "Block2_External/02_figures/Fig8.pdf", replace		
	
	
*-- 03. Employment number 
	use "Block2_External/01_data/09employment.dta", clear 
	count 
	local c = `r(N)' 
	
	#delimit ;
	twoway rcap    lb ub s1  if source == "GLD"                   , lcolor(red)                 ||
	       scatter value s1  if source == "GLD"                   , msymbol(O) mcolor(red)      || 
		   rcap    lb ub s1  if source != "GLD" & year == ${cyear}, lcolor(blue)                || 
		   rcap    lb ub s1  if source != "GLD" & year != ${cyear}, lcolor(blue) lpattern(dash) || 
		   scatter value s1  if source != "GLD" & year == ${cyear}, msymbol(O) mcolor(blue)     ||
		   scatter value s1  if source != "GLD" & year != ${cyear}, msymbol(T) mcolor(blue)
	leg(off) ytitle("") xtitle("") name(Fig9, replace) 
	xlabel(1(1)`c', valuelabel angle(45) labs(small)) 
	ylabel( , nogrid angle(horizontal) labs(small))
	scheme(s2mono) graphregion(fcolor(white) color(white))
	subtitle("Employment (number)", position(11) justification(left) size(medsmall));
	#delimit cr 
	graph export "Block2_External/02_figures/Fig9.pdf", replace		
	
	
*-- 04. Employment to population ratio
	use "Block2_External/01_data/10emptopop.dta", clear 
	count 
	local c = `r(N)' 
	
	#delimit ;
	twoway rcap    lb ub s1  if source == "GLD"                   , lcolor(red)                 ||
	       scatter value s1  if source == "GLD"                   , msymbol(O) mcolor(red)      || 
		   rcap    lb ub s1  if source != "GLD" & year == ${cyear}, lcolor(blue)                || 
		   rcap    lb ub s1  if source != "GLD" & year != ${cyear}, lcolor(blue) lpattern(dash) || 
		   scatter value s1  if source != "GLD" & year == ${cyear}, msymbol(O) mcolor(blue)     ||
		   scatter value s1  if source != "GLD" & year != ${cyear}, msymbol(T) mcolor(blue)
	leg(off) ytitle("") xtitle("") name(Fig10, replace) 
	xlabel(1(1)`c', valuelabel angle(45) labs(small)) 
	ylabel( , nogrid angle(horizontal) labs(small))
	scheme(s2mono) graphregion(fcolor(white) color(white))
	subtitle("Employment to population ratio", position(11) justification(left) size(medsmall));
	#delimit cr 
	graph export "Block2_External/02_figures/Fig10.pdf", replace	
	
	
*-- 05. Unemployment rate
	use "Block2_External/01_data/11unemployment.dta", clear 
	count 
	local c = `r(N)' 
	
	#delimit ;
	twoway rcap    lb ub s1  if source == "GLD"                   , lcolor(red)                 ||
	       scatter value s1  if source == "GLD"                   , msymbol(O) mcolor(red)      || 
		   rcap    lb ub s1  if source != "GLD" & year == ${cyear}, lcolor(blue)                || 
		   rcap    lb ub s1  if source != "GLD" & year != ${cyear}, lcolor(blue) lpattern(dash) || 
		   scatter value s1  if source != "GLD" & year == ${cyear}, msymbol(O) mcolor(blue)     ||
		   scatter value s1  if source != "GLD" & year != ${cyear}, msymbol(T) mcolor(blue)
	leg(off) ytitle("") xtitle("")  name(Fig11, replace)
	xlabel(1(1)`c', valuelabel angle(45) labs(small)) 
	ylabel( , nogrid angle(horizontal) labs(small))
	scheme(s2mono) graphregion(fcolor(white) color(white))
	subtitle("Unemployment rate", position(11) justification(left) size(medsmall));
	#delimit cr 
	graph export "Block2_External/02_figures/Fig11.pdf", replace		
				
				
*-- 06. Employment in agriculture 
	use "Block2_External/01_data/12agriculture.dta", clear 
	count 
	local c = `r(N)' 
	
	#delimit ;
	twoway rcap    lb ub s1  if source == "GLD"                   , lcolor(red)                 ||
	       scatter value s1  if source == "GLD"                   , msymbol(O) mcolor(red)      || 
		   rcap    lb ub s1  if source != "GLD" & year == ${cyear}, lcolor(blue)                || 
		   rcap    lb ub s1  if source != "GLD" & year != ${cyear}, lcolor(blue) lpattern(dash) || 
		   scatter value s1  if source != "GLD" & year == ${cyear}, msymbol(O) mcolor(blue)     ||
		   scatter value s1  if source != "GLD" & year != ${cyear}, msymbol(T) mcolor(blue)
	leg(off) ytitle("") xtitle("") name(Fig12, replace) 
	xlabel(1(1)`c', valuelabel angle(45) labs(small)) 
	ylabel( , nogrid angle(horizontal) labs(small))
	scheme(s2mono) graphregion(fcolor(white) color(white))
	subtitle("Employment in agriculture (%)", position(11) justification(left) size(medsmall));
	#delimit cr 
	graph export "Block2_External/02_figures/Fig12.pdf", replace		
	
	
*-- 07. Employment in industry
	use "Block2_External/01_data/13industry.dta", clear 
	count 
	local c = `r(N)' 
	
	#delimit ;
	twoway rcap    lb ub s1  if source == "GLD"                   , lcolor(red)                 ||
	       scatter value s1  if source == "GLD"                   , msymbol(O) mcolor(red)      || 
		   rcap    lb ub s1  if source != "GLD" & year == ${cyear}, lcolor(blue)                || 
		   rcap    lb ub s1  if source != "GLD" & year != ${cyear}, lcolor(blue) lpattern(dash) || 
		   scatter value s1  if source != "GLD" & year == ${cyear}, msymbol(O) mcolor(blue)     ||
		   scatter value s1  if source != "GLD" & year != ${cyear}, msymbol(T) mcolor(blue) 
	leg(off) ytitle("") xtitle("")  name(Fig13, replace)
	xlabel(1(1)`c', valuelabel angle(45) labs(small)) 
	ylabel( , nogrid angle(horizontal) labs(small))
	scheme(s2mono) graphregion(fcolor(white) color(white))
	subtitle("Employment in industry (%)", position(11) justification(left) size(medsmall));
	#delimit cr 
	graph export "Block2_External/02_figures/Fig13.pdf", replace
	
	
*-- 08. Employment in sevices 
	use "Block2_External/01_data/14services.dta", clear
	count 
	local c = `r(N)' 
	
	#delimit ;
	twoway rcap    lb ub s1  if source == "GLD"                   , lcolor(red)                 ||
	       scatter value s1  if source == "GLD"                   , msymbol(O) mcolor(red)      || 
		   rcap    lb ub s1  if source != "GLD" & year == ${cyear}, lcolor(blue)                || 
		   rcap    lb ub s1  if source != "GLD" & year != ${cyear}, lcolor(blue) lpattern(dash) || 
		   scatter value s1  if source != "GLD" & year == ${cyear}, msymbol(O) mcolor(blue)     ||
		   scatter value s1  if source != "GLD" & year != ${cyear}, msymbol(T) mcolor(blue) 
	leg(off) ytitle("") xtitle("") name(Fig14, replace) 
	xlabel(1(1)`c', valuelabel angle(45) labs(small)) 
	ylabel( , nogrid angle(horizontal) labs(small))
	scheme(s2mono) graphregion(fcolor(white) color(white))
	subtitle("Employment in services (%)", position(11) justification(left) size(medsmall));
	#delimit cr 
	graph export "Block2_External/02_figures/Fig14.pdf", replace		
	
	
********************************************************************************
*                           02. Combined figure                                *
********************************************************************************

	#delimit;
	gr combine Fig7 Fig9 Fig8 Fig10 Fig11 Fig12 Fig13 Fig14,
	scheme(s2mono) graphregion(fcolor(white) color(white)) c(3) hole(3)
	subtitle("Block 2B.1. Labor Force Variables, ${ccode3}", position(11) justification(left) size(medsmall));
	#delimit cr
	graph export "Block2_External/02_figures/2B1_figures.pdf", replace	
	
	
	// cd "$mydir"
	
**************************   END OF THE DO-FILE  *******************************	
	