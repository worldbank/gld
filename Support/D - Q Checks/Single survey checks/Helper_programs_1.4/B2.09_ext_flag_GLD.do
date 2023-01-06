/*******************************************************************************
								
                            GLD CHECKS Version 1.4
                      10. Figures of flagged variables 
		   	   																   
*******************************************************************************/

	clear all
	set graphics off
	cd "${output}/${ccode3}_${cyear}_${mydate}"
	
	
*-- 01. Read data 	
	use "Block2_External/01_data/Checks_results.dta", clear
	egen groupflag = mean(flag), by(varchecked)
	keep if groupflag == 1
	
	save "Block2_External/01_data/temp1_results.dta", replace
	
*-- 02. Make individual figures 
	replace varorder = varorder + 10

	levelsof varorder, local(flaggedvars)
	global flaggedvars `flaggedvars'
		
	local n : word count $flaggedvars
	
	* Check whether there are any cases (n == 0) or not
	if `n' == 0 {
		
		erase "Block2_External/01_data/temp1_results.dta"
		
	} // close if n == 0
	else {
		
		forvalues i = 1/`n' {
			
			local a : word `i' of $flaggedvars
			local b = `a' - 10
	
			use "Block2_External/01_data/temp1_results.dta", clear 
			keep if varorder == `b' 
			count 
			local c = `r(N)' 
			encode source, gen(s1)
			
			local lvarchecked = varchecked
			#delimit ;
			twoway	rcap lb ub s1  if source == "GLD",							lcolor(red)                      ||
					scatter value s1  if source == "GLD",						msymbol(O) mcolor(red)           || 
					rcap    lb ub s1  if source != "GLD" & year == ${cyear},	lcolor(blue)                     || 
					rcap    lb ub s1  if source != "GLD" & year != ${cyear},	lcolor(blue) lpattern(shortdash) ||
					scatter value s1  if source != "GLD" & year == ${cyear},	msymbol(O) mcolor(blue)          ||
					scatter value s1  if source != "GLD" & year != ${cyear},	msymbol(T) mcolor(blue) 
			leg(off) ytitle("") xtitle("")  name(Flag`a', replace)
			xlabel(1(1)`c', valuelabel angle(45) labs(small))
			ylabel( , nogrid angle(horizontal) labs(small))
			scheme(s2mono) graphregion(fcolor(white) color(white))
			subtitle("`lvarchecked'", position(11) justification(left) size(medsmall));
			#delimit cr
		
		} // close for values inside n != 0
	
		erase "Block2_External/01_data/temp1_results.dta"
		
	} // close else (n != 0)

	
*-- 03. Make panel
	clear
	gen flaggedvars = ""
	
	** Extract file names from global 
	local n : word count $flaggedvars
	
	* Again only if there are any
	if `n' == 0 {
		
		di "No flagged external vars"
		
	} // close if n == 0
	else {
		
		set obs `n'
		forvalues i = 1/`n' {
			local a : word `i' of $flaggedvars
			* di "`i'st is `a'"
			replace flaggedvars = "`a'" if _n == `i'
		}
	
		gen prefix  = "Flag"
		gen figname = prefix + flaggedvars 
		
		** Combined figures 
		count
		local num = `r(N)'
		levelsof figname, local(allfigs) clean
		#delimit;
		gr combine `allfigs',
		scheme(s2mono) graphregion(fcolor(white) color(white)) c(3) // altshrink
		subtitle("Flagged variables (`num'), ${ccode3}-${cyear} ", position(11) justification(left) size(medsmall));
		#delimit cr
		graph export "01_summary/B2_external_flags.pdf", replace
		
	} // close else (n != 0)
	
		
	

*-- 04. Conclude checking 	
	macro drop flaggedvars
	clear
	cd
	di "External data checks completed for ${ccode3}-${cyear}"	
	
**************************   END OF THE DO-FILE  *******************************	
