/*******************************************************************************
								
                            GLD CHECKS Version 1.5
                         07. Block 2 - External data
		    2B.2. Labor force variables 2: Sectors, detail - Output figures
				  				          		   	   																   
*******************************************************************************/

	clear all
	set graphics off
	cd "${output}/${ccode3}_${cyear}_${mydate}"
	
********************************************************************************
*                           01. Individual figures                             *
********************************************************************************

*-- 05. Figure (original vs ILO)
	forvalues j = 1/10 {
		
		capture use "Block2_External/01_data/15industry_`j'.dta", clear 
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
				leg(off) ytitle("") xtitle("") name(Fig15_`j', replace)  
			xlabel(1(1)`c', valuelabel angle(45) labs(small)) 
			ylabel( , nogrid angle(horizontal) labs(small))
			scheme(s2mono) graphregion(fcolor(white) color(white))
			subtitle("Employment in `: variable label value' (%)", position(11) justification(left) size(medsmall));
			#delimit cr 
			graph export "Block2_External/02_figures/Fig15_`j'.pdf", replace	
			
		}
		
	}
	
	
********************************************************************************
*                           02. Combined figure                                *
********************************************************************************

	* First sift which graphs where created, store that in local graphs_in_memory
	local graphs_in_memory 
	foreach fig in Fig15_1 Fig15_2 Fig15_3 Fig15_4 Fig15_5 Fig15_6 Fig15_7 Fig15_8 Fig15_9 Fig15_10 {
		
		capture gr describe `fig'
		if _rc == 0 { // graph actully in memory
			local graphs_in_memory `graphs_in_memory' `fig'
		}
		
	}

	* If not industry info, none of these figures will be drawn, proceed only if there are some
	local graph_elements_n: word count `graphs_in_memory'
	if `graph_elements_n' > 0 { // at least one figure
	    
		#delimit;
		gr combine `graphs_in_memory',
		scheme(s2mono) graphregion(fcolor(white) color(white)) c(3) 
		subtitle("Block 2B.2. Sectors, detail, ${ccode3}", position(11) justification(left) size(medsmall));
		#delimit cr
		graph export "Block2_External/02_figures/2B2_figures.pdf", replace		
		
	}

	
	// cd "$mydir"
	
**************************   END OF THE DO-FILE  *******************************	
		