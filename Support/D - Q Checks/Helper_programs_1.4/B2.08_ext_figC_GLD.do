/*******************************************************************************
								
                             GLD CHECKS Version 1.4
                         09. Block 2 - External data
                    2C. Wage variables - Output figures   	  
		   	   																   
*******************************************************************************/

	clear all
	set graphics off
	cd "${output}/${ccode3}_${cyear}_${mydate}"

********************************************************************************
*                           01. Individual figures                             *
********************************************************************************

*-- 06. Average hourly wages
	
	* Check whether wage info was create
	cap use "Block2_External/01_data/16wages.dta", clear 
	if _rc == 0 { // data exists
		
		count 
		local c = `r(N)' 
			
		#delimit ;
		twoway rcap    lb ub s1  if source == "GLD"                   , lcolor(red)                 ||
			   scatter value s1  if source == "GLD"                   , msymbol(O) mcolor(red)      || 
			   rcap    lb ub s1  if source != "GLD" & year == ${cyear}, lcolor(blue)                || 
			   rcap    lb ub s1  if source != "GLD" & year != ${cyear}, lcolor(blue) lpattern(dash) || 
			   scatter value s1  if source != "GLD" & year == ${cyear}, msymbol(O) mcolor(blue)     ||
			   scatter value s1  if source != "GLD" & year != ${cyear}, msymbol(T) mcolor(blue)
		leg(off) ytitle("") xtitle("")  name(Fig16, replace)  
		xlabel(1(1)`c', valuelabel angle(45) labs(small)) 
		ylabel( , nogrid angle(horizontal) labs(small))
		scheme(s2mono) graphregion(fcolor(white) color(white))
		subtitle("Average hourly wages", position(11) justification(left) size(medsmall));
		#delimit cr 
		graph export "Block2_External/02_figures/Fig16.pdf", replace		
		
	********************************************************************************
	*                           02. Combined figure                                *
	********************************************************************************

		#delimit;
		gr combine Fig16,
		scheme(s2mono) graphregion(fcolor(white) color(white)) c(3) 
		subtitle("Block 2C. Wages", position(11) justification(left) size(medsmall));
		#delimit cr
		graph export "Block2_External/02_figures/2C_figures.pdf", replace		
	
		
} // close data exist

	
**************************   END OF THE DO-FILE  *******************************		
