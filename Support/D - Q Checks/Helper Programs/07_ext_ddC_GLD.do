/*******************************************************************************
								
                            GLD CHECKS Version 1.2
                        04. Block 2 - External data
                     2C. Wage variables - data download  	  
		   	   																   
*******************************************************************************/	
	
	clear all	
	set graphics off 
	cd "${output}/${ccode3}_${cyear}_${mydate}"
	
********************************************************************************
*                             16. Hourly wages                                 *
********************************************************************************	


*-- 01. ILO 
	* Mean nominal hourly earnings of employees by sex and occupation (local currency)
	
	#delimit ; 
	dbnomics import, provider(ILO) dataset(EAR_HEES_SEX_OCU_NB) ref_area(${ccode3})
	sex(SEX_T) clear ;
	#delimit cr
	count
	if `r(N)' == 0 {
		di "Dbnomics data not found"
	}
	else {
		
		keep if classif1 == "OCU_ISCO88_TOTAL"
		
		//keep if period  == ${cyear}
		** Adjustment in case we don't have data for ${cyear}
		sort period 
		gen myyear = ${cyear}
		gen yeardiff = abs(period - myyear)
		egen mindiff = min(yeardiff)
		
		keep if yeardiff == mindiff
		
		sum period
		keep if period == `r(min) ' // keep earliest 
		count 
		assert `r(N)' == 1 
		
		** Continue 
		sum value 
		if `r(N)' == 0 {
			replace value ="." if value == "NA"
			destring value, replace
		}
		
		drop source
		rename (period ref_area provider_code) (year countrycode source)
		replace source = "ILO"
		gen ub = 1.1*value
		gen lb = 0.9*value
		format value ub lb %6.2fc
		keep   year value ub lb countrycode source
		order  year value ub lb countrycode source
	} 
	
	tempfile wag1
	save    `wag1'	

	
*-- 02. WDI
	* GDP per capita (current LCU)(NY.GDP.PCAP.CN) 
	cap wbopendata, indicator(NY.GDP.PCAP.CN) country(${ccode3}) year(${cyear}) clear long
	if _rc {
			di "data not found in wbopendata"
		}
	else {

		// gen value = 2/3*ny_gdp_pcap_cn/8760  // times labor share, div by hours in a year 
		gen value = 2/3*ny_gdp_pcap_cn/2080  // times labor share, div by WORKING hours in a year 
		
		gen source = "WDI"
		gen ub = 1.1*value
		gen lb = 0.9*value
		format value ub lb %6.2fc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source 
	} 
	tempfile wag2
	save    `wag2'		
	  
	
*-- 03. Survey data 
	use "${mydata}", clear
	
	** Only for paid employees 
	keep if empstat == 1 
	 
	** Calculate hourly wages 
	gen weekwage =.
	replace weekwage = wage_no_compen      if unitwage == 2 // (weekly)
	replace weekwage = wage_no_compen/4.2  if unitwage == 5 // (weekly)
	
	gen value = weekwage / whours  // hourly wage
	
	winsor2 value, replace cuts(1 99) trim
	
	** Calculate maen 
	collapse (mean) value [iw = weight], by(countrycode harmonization year) 
	
	rename harmonization source 
	gen ub = 1.1*value
	gen lb = 0.9*value
	format value ub lb %6.2fc
	order year value ub lb countrycode source
	
	tempfile wag3
	save    `wag3'	
	
	
*-- 05. Combine all 
	clear 
	
	forvalues i = 1/3 {
		append using `wag`i''	
	}
	
	encode source, gen(s1)
	save "Block2_External/01_data/16wages.dta", replace 
		
	
**************************   END OF THE DO-FILE  *******************************		
	
