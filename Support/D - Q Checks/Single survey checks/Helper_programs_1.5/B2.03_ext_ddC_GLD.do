/*******************************************************************************
								
                            GLD CHECKS Version 1.5
                        04. Block 2 - External data
                     2C. Wage variables - data download  	  
		   	   																   
*******************************************************************************/	
	
	clear all	
	set graphics off 
	cd "${output}/${ccode3}_${cyear}_${mydate}"
	
********************************************************************************
*                             17. Hourly wages                                 *
********************************************************************************	

*-- 01. Check whether there is wage info
	use "${mydata}", clear
	
	cap confirm variable wage_no_compen whours
	if _rc != 0 { // var not present
		
		* If no info at 7 days ref, try to use 12 month one
		cap rename wage_no_compen_year wage_no_compen
		cap rename unitwage_year       unitwage
		cap rename whours_year		   whours
		
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
	
*-- 02. ILO 
	* Mean nominal hourly earnings of employees by sex and occupation (local currency)
	

		
		#delimit ; 
		dbnomics import, provider(ILO) dataset(EAR_HEES_SEX_OCU_NB) ref_area(${ccode3})
		sex(SEX_T) clear ;
		#delimit cr
		
		* count: If rows > 0, there is data
		count
		if `r(N)' == 0 {
			di "Dbnomics data not found"
		}
		else {
			
			* Keep only total data (can be, depending on period ISCO 88 or 08)
			keep if classif1 == "OCU_ISCO88_TOTAL" | classif1 == "OCU_ISCO08_TOTAL"
			
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
		save    `wag1', emptyok	
		

	

*-- 03. WDI

		
		* GDP per capita (current LCU)(NY.GDP.PCAP.CN) 
		cap wbopendata, indicator(NY.GDP.PCAP.CN) country(${ccode3}) year(${cyear}) clear long
		if _rc {
				di "data not found in wbopendata"
				clear 
			
				* Still need to create an empty husk
				gen year = .
				gen value = .
				gen ub = .
				gen lb = .
				gen countrycode = ""
				gen source = ""
				
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
		save    `wag2', emptyok
		

	  
	
*-- 04. Survey data 
	
		use "${mydata}", clear
	
		** Only for paid employees, 15+
		keep if empstat == 1 & inrange(age,15,999)
		 
		** Calculate hourly wages 
		gen weekwage =.
		replace weekwage = wage_no_compen*7    if unitwage == 1 // (daily)
		replace weekwage = wage_no_compen      if unitwage == 2 // (weekly)
		replace weekwage = wage_no_compen/2    if unitwage == 3 // (every two weeks)
		replace weekwage = wage_no_compen/8.67 if unitwage == 4 // (bi-monthly)
		replace weekwage = wage_no_compen/4.33 if unitwage == 5 // (monthly)
		replace weekwage = wage_no_compen/13   if unitwage == 6 // (Trimester)
		replace weekwage = wage_no_compen/26   if unitwage == 7 // (Biannual)
		replace weekwage = wage_no_compen/52   if unitwage == 8 // (Annual)
			
		gen value = weekwage / whours  // hourly wage
		replace value = wage_no_compen if unitwage == 9 // (Hourly wage)
		
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
		save "Block2_External/01_data/17wages.dta", replace 
		
} // finish if wage_eval == 1


********************************************************************************
*                             18. Monthly wages                                 *
********************************************************************************	

*-- 01. Check whether there is wage info
	use "${mydata}", clear
	
	* Requires wage
	cap confirm variable wage_no_compen
	if _rc != 0 { // var not present
		
		* If no info at 7 days ref, try to use 12 month one
		cap rename wage_no_compen_year wage_no_compen
		cap rename unitwage_year       unitwage
		
	}
	
	* Check again, this time with a local evaluator
	local wage_eval = 0
	cap confirm variable wage_no_compen
	if _rc == 0 { // wage, either 7d or 12m present
		local wage_eval = 1
	}

	
	********************************************************
	* Only run the next steps if actually wage info present
	********************************************************
	* Only if wage_eval == 1
	if `wage_eval' == 1 {
	
*-- 02. ILO 
	* Mean nominal monthly earnings of employees by sex and occupation (local currency)
			
		dbnomics import, provider(ILO) dataset(EAR_4MTH_SEX_ECO_CUR_NB) ref_area(${ccode3}) sex(SEX_T) clear 
				
		* count: If rows > 0, there is data
		count
		if `r(N)' == 0 {
			di "Dbnomics data not found"
		}
		else {
			
			* Keep only total data, local currency
			 keep if classif1 == "ECO_AGGREGATE_TOTAL"
			 keep if classif2 == "CUR_TYPE_LCU"
			
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
		save    `wag1', emptyok	
		

	

*-- 03. WDI

		
		* GDP per capita (current LCU)(NY.GDP.PCAP.CN) 
		cap wbopendata, indicator(NY.GDP.PCAP.CN) country(${ccode3}) year(${cyear}) clear long
		if _rc {
				di "data not found in wbopendata"
				clear 
			
				* Still need to create an empty husk
				gen year = .
				gen value = .
				gen ub = .
				gen lb = .
				gen countrycode = ""
				gen source = ""
				
			}
		else {

			* GDP per cap / labour share / 12 to make monthly
			gen value = (2/3)*ny_gdp_pcap_cn/12  // times labor share, div by WORKING hours in a year 
			
			gen source = "WDI"
			gen ub = 1.1*value
			gen lb = 0.9*value
			format value ub lb %6.2fc
			keep  year value ub lb countrycode source
			order year value ub lb countrycode source 
		} 
		tempfile wag2
		save    `wag2', emptyok
		

	  
	
*-- 04. Survey data 
	
		use "${mydata}", clear
	
		** Only for paid employees, 15+
		keep if empstat == 1 & inrange(age,15,999)
		 
		** Calculate hourly wages 
		gen monthwage =.
		replace monthwage = wage_no_compen*7*4.33 if unitwage == 1 // (daily)
		replace monthwage = wage_no_compen*4.33   if unitwage == 2 // (weekly)
		replace monthwage = wage_no_compen*2.165  if unitwage == 3 // (every two weeks)
		replace monthwage = wage_no_compen*2      if unitwage == 4 // (bi-monthly)
		replace monthwage = wage_no_compen        if unitwage == 5 // (monthly)
		replace monthwage = wage_no_compen/3      if unitwage == 6 // (Trimester)
		replace monthwage = wage_no_compen/6      if unitwage == 7 // (Biannual)
		replace monthwage = wage_no_compen/12     if unitwage == 8 // (Annual)
		replace monthwage = wage_no_compen*150    if unitwage == 9 // (Hourly, assume 150 hours)

		gen value = monthwage
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
		save "Block2_External/01_data/18_m_wages.dta", replace 
		
} // finish if wage_eval == 1

	
**************************   END OF THE DO-FILE  *******************************		
	
