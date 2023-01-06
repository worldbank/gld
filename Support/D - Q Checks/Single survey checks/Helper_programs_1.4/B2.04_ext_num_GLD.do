/*******************************************************************************
								
                             GLD CHECKS Version 1.4
						  05. Block 2 - External data
                            Export numerical output   	  
		   	   																   
*******************************************************************************/

	clear all
	cd "${output}/${ccode3}_${cyear}_${mydate}"

	
*-- 01. Read & append all data files 
	global datafolder : dir "Block2_External/01_data" files "*.dta"
	
	foreach f of global datafolder {
		use  "Block2_External/01_data/`f'", clear 
		gen   varchecked = "`f'"
		save "Block2_External/01_data/a1_`f'", replace
	}
	
	clear
	foreach f of global datafolder {
		append using "Block2_External/01_data/a1_`f'"
		erase "Block2_External/01_data/a1_`f'"
	}
	
	drop s1
	save "Block2_External/01_data/temp_allvars.dta", replace
	
*-- 02. Construct database  	
	use "Block2_External/01_data/temp_allvars.dta", clear  
	
	sort varchecked
	format value ub lb %16.2fc
	
	encode varchecked, gen(varorder)
	label drop varorder
		
	gen block =. 
	replace block = 1 if varorder >= 1  & varorder <= 6
	replace block = 2 if varorder >= 7  & varorder <= 24 
	replace block = 3 if varorder >= 25 & varorder <= 25
	
		
	replace varchecked = "Total population"                           if varchecked == "01totpop.dta"
	replace varchecked = "Female share"                               if varchecked == "02gensplit.dta"
	replace varchecked = "Urban share"                                if varchecked == "03urbanshare.dta"
	replace varchecked = "Children 0-14 (%)"                          if varchecked == "04children.dta"
	replace varchecked = "Working age 15-64 (%)"                      if varchecked == "05workingage.dta"
	replace varchecked = "Seniors 65+ (%)"                            if varchecked == "06seniors.dta"
	replace varchecked = "Labor force size"                           if varchecked == "07labforce.dta"
	replace varchecked = "Labor force participation rate"             if varchecked == "08labfpart.dta"
	replace varchecked = "Employment (number)"                        if varchecked == "09employment.dta"
	replace varchecked = "Employment to population ratio"             if varchecked == "10emptopop.dta"
	replace varchecked = "Unemployment rate"                          if varchecked == "11unemployment.dta"
	replace varchecked = "Employment in agriculture (%)"              if varchecked == "12agriculture.dta"
	replace varchecked = "Employment in industry (%)"                 if varchecked == "13industry.dta"
	replace varchecked = "Employment in services (%)"                 if varchecked == "14services.dta"
	replace varchecked = "Employment in Agriculture (%)"              if varchecked == "15industry_1.dta"
	replace varchecked = "Employment in Mining (%)"                   if varchecked == "15industry_2.dta"
	replace varchecked = "Employment in Manufacturing (%)"            if varchecked == "15industry_3.dta"
	replace varchecked = "Employment in Public-Utilities (%)"         if varchecked == "15industry_4.dta"
	replace varchecked = "Employment in Construction (%)"             if varchecked == "15industry_5.dta"
	replace varchecked = "Employment in Commerce (%)"                 if varchecked == "15industry_6.dta"
	replace varchecked = "Employment in Transport-Communications (%)" if varchecked == "15industry_7.dta"
	replace varchecked = "Employment in Financial (%)"                if varchecked == "15industry_8.dta"
	replace varchecked = "Employment in Public-Admin (%)"             if varchecked == "15industry_9.dta"
	replace varchecked = "Employment in Other (%)"                    if varchecked == "15industry_10.dta"
	replace varchecked = "Average hourly wages"                       if varchecked == "16wages.dta"
	
		
	erase "Block2_External/01_data/temp_allvars.dta"        
	save  "Block2_External/01_data/temp2_allvars.dta", replace        
		
		
*-- 03. Flag variables for visualization   		
	use "Block2_External/01_data/temp2_allvars.dta", clear  	
	
	** Mean values of external variables, lower bound & upper bound 
	egen meanlb1 = mean(lb)      if source != "GLD", by(varchecked)
	egen meanlb  = mean(meanlb1)                   , by(varchecked)
	
	egen meanub1 = mean(ub)      if source != "GLD", by(varchecked)
	egen meanub  = mean(meanub1)                   , by(varchecked)

	
	drop meanlb1 meanub1
	format meanlb meanub %16.2fc
		
	** Generate flags  // THIS IS WHERE WE DEFINE FLAGS
	gen flag =.
	replace flag = 1 if source == "GLD" & (lb >= meanub | ub <= meanlb)
	replace flag = 0 if source == "GLD" & flag != 1
	
	** Count number of flags 
	egen flagnum   = sum(flag)
	
	count if !missing(flag)
	gen flagshare  = flagnum /`r(N)'
	
 	order year value ub lb countrycode source 
	
	erase "Block2_External/01_data/temp2_allvars.dta"    
	save  "Block2_External/01_data/Checks_results.dta", replace        
		
*-- 04. Prepare excel to export  	
	use "Block2_External/01_data/Checks_results.dta", clear 
	
	** Count unique comparison value 
	gen rvalue     = round(value, 0.01)
    egen tag       = tag(rvalue varchecked) if source != "GLD" 
	egen com_cases = total(tag), by(varchecked)
	
	drop tag rvalue
	
	** Tag GLD vs comparison 
	egen count = count(value) if source != "GLD", by(varchecked)
	gen type   = ""
		replace type = "_GLD"        if  missing(count) & source == "GLD"
		replace type = "_comparison" if !missing(count) & source != "GLD"

	** Generate & clean summary file 
	collapse (mean) value ub lb, by(type varchecked varorder com_cases)
	reshape wide value lb ub, i(varchecked varorder com_cases) j(type) string
	
	sort varorder
	gen year    = ${cyear}
	gen country = "${ccode3}"
	gen survey  = "${csurvey}"
	
	#delimit ; 
	rename (value_GLD lb_GLD ub_GLD value_comparison lb_comparison ub_comparison)
	       (val_pe    val_lb val_ub com_pe           com_lb        com_ub);
	#delimit cr 
	
	gen diff = abs(val_pe - com_pe)
	format diff %16.2fc
	
	** Add overlap and flags 
	// Recall original flag definition "flag = 1 if source == "GLD" & (lb >= meanub | ub <= meanlb)"
	
	gen f1 = 1 if val_lb >= com_ub  // flagged for being above 
	gen f2 = 1 if val_ub <= com_lb  // flagged for being below 
	
	** Flagged for being above: distance to underneath 
	gen dist1      =  val_lb - com_ub
	assert dist1  >= 0 if f1 == 1
	assert dist1  <  0 if f1 ==.
	// replace dist1 =.   if dist1 < 0
	
	format dist* %16.2fc
	
	** Flagged for being below: distance to below
	gen dist2      = com_lb - val_ub
	assert dist2  >= 0 if f2 == 1
	assert dist2  <  0 if f2 ==.
	// replace dist2 =.   if dist2 < 0
	
	format dist* %16.2fc
	
		// Note: a negative distance means overlap, positive distance means flag. 

	gen flag = 1 if f1 == 1 | f2 == 1
	
	sort varorder
	
	#delimit;
	order year country survey varchecked varorder val_pe val_lb val_ub com_pe 
	com_lb com_ub com_cases diff dist* f1 f2 flag;
	#delimit cr 
	
	// export excel using "01_summary/Checks_results.xlsx", firstrow(variables) replace
	export excel using "01_summary/B2_external_results.xlsx", firstrow(variables) replace
	 	
	
*-- 05. (Extra) Erase a1_ files 
	global a1files : dir "Block2_External/01_data" files "a1_*"
	foreach a of global a1files {
		cap erase "Block2_External/01_data/`a'"    
	}

	macro drop datafolder
	
	
**************************   END OF THE DO-FILE  *******************************		
	

	  