/*******************************************************************************
								
                             GLD CHECKS Version 1.4
                          03. Block 2 - External data
                    2B. Labor force variables - data download  	  
		   	   																   
*******************************************************************************/	
	
	clear all
	cd "${output}/${ccode3}_${cyear}_${mydate}"

********************************************************************************
*                            07. Labor force (size)                            *
********************************************************************************
	
*-- 01. WDI 
	cap wbopendata, indicator(SL.TLF.TOTL.IN) country(${ccode3}) year(${cyear}) clear long
	if _rc {
			di "data not found in wbopendata"
		}
	else {
		gen source = "WDI"
		rename sl_tlf*_totl_in value
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %14.2gc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	} 
	tempfile lab1
	save    `lab1'
	

*-- 02. ILO (1), EAP_TEAP_SEX_AGE_NB	
	#delimit ;
	dbnomics import, provider(ILO) dataset(EAP_TEAP_SEX_AGE_NB) ref_area(${ccode3}) 
	sex(SEX_T)  classif1(AGE_10YRBANDS_TOTAL) frequency(A) clear;
	#delimit cr 
	count
	if `r(N)' == 0 {
		di "Dbnomics data not found"
	}
	else {

		** Find closest year 
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
		order period yeardiff myyear mindiff 
		egen tag = tag(yeardiff)
			
		drop source
		replace value = value*10^3
		rename (period ref_area provider_code) (year countrycode source)
		replace source = "ILO-1"
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %14.2gc
		keep   year value ub lb countrycode source
		order  year value ub lb countrycode source
	} 
	tempfile lab2
	save    `lab2'
	

	
*-- 03. ILO-Modeled (2), EAP_2EAP_SEX_AGE_NB	
	#delimit ;
	dbnomics import , provider(ILO) dataset(EAP_2EAP_SEX_AGE_NB) ref_area(${ccode3}) 
	sex(SEX_T) clear ; 
	#delimit cr
	count
	if `r(N)' == 0 {
		di "Dbnomics data not found"
	}
	else {

		keep if classif1 == "AGE_YTHADULT_YGE15"
		
		** Find closest year 
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
		drop source
		replace value = value*10^3
		rename (period ref_area provider_code) (year countrycode source)
		replace source = "ILO-2"
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %14.2gc
		keep   year value ub lb countrycode source
		order  year value ub lb countrycode source
	} 	
	tempfile lab3
	save    `lab3'
	
	
*-- 04. Survey data 
	use "${mydata}", clear
	
	gen value = 1 if lstatus == 1 | lstatus == 2
	 
	collapse (count) value [iw = weight], by(countrycode harmonization year) 
	rename harmonization source 
	gen ub = 1.05*value
	gen lb = 0.95*value
	format value ub lb %14.2gc
	order year value ub lb countrycode source
	
	tempfile lab4
	save    `lab4'
	
	
*-- 05. Combine all 
	clear 
	
	forvalues i = 1/4 {
		append using `lab`i''	
	}
	
	encode source, gen(s1)
	save "Block2_External/01_data/07labforce.dta", replace 
	
********************************************************************************
*                     08. Labor force participation rate                       *
*                      (labor force/ total population)                         * 
********************************************************************************	
					  
*-- 01. WDI-1
	* Labor force participation rate, total (% of total population ages 15+) 
	* (modeled ILO estimate)(SL.TLF.CACT.ZS)
	
	cap wbopendata, indicator(SL.TLF.CACT.ZS) country(${ccode3}) year(${cyear}) clear long
	if _rc {
			di "data not found in wbopendata"
		}
	else {
		gen source = "WDI-1"
		rename sl_tlf* value
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	} 
	tempfile laf1
	save    `laf1'
	
*-- 02. WDI-2
	* Labor force participation rate, total (% of total population ages 15+) 
	* (national estimate)(SL.TLF.CACT.NE.ZS)	
	
	cap wbopendata, indicator(SL.TLF.CACT.NE.ZS) country(${ccode3}) year(${cyear}) clear long
	if _rc {
			di "data not found in wbopendata"
		}
	else {
		gen source = "WDI-2"
		rename sl_tlf* value
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	} 
	tempfile laf2
	save    `laf2'
	
*-- 03. WDI-3	
	* Labor force participation rate, total (% of total population ages 15-64) 
	* (modeled ILO estimate)(SL.TLF.ACTI.ZS)	
	
	cap wbopendata, indicator(SL.TLF.CACT.NE.ZS) country(${ccode3}) year(${cyear}) clear long
	if _rc {
			di "data not found in wbopendata"
		}
	else {
		gen source = "WDI-3"
		rename sl_tlf* value
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	} 
	tempfile laf3
	save    `laf3'
	
*-- 04. ILO (1), EAP_DWAP_SEX_AGE_RT
	* Labour force participation rate by sex and age (%)
	#delimit ;
	dbnomics import, provider(ILO) dataset(EAP_DWAP_SEX_AGE_RT) ref_area(${ccode3}) 
	sex(SEX_T) classif1(AGE_YTHADULT_YGE15) frequency(A) clear;
	#delimit cr 
	count
	if `r(N)' == 0 {
		di "Dbnomics data not found"
	}
	else {
	
		** Find closest year 
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
		drop source
		rename (period ref_area provider_code) (year countrycode source)
		replace source = "ILO-1"
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep   year value ub lb countrycode source
		order  year value ub lb countrycode source
	} 
	tempfile laf4
	save    `laf4'

*-- 05. ILO (2), EAP_2WAP_SEX_AGE_RT
	* Labour force participation rate by sex and age -- 
	* ILO modelled estimates, Nov. 2021 (%)
	
	#delimit ;
	dbnomics import, provider(ILO) dataset(EAP_2WAP_SEX_AGE_RT) ref_area(${ccode3}) 
	sex(SEX_T) frequency(A) clear;
	#delimit cr 
	count
	if `r(N)' == 0 {
		di "Dbnomics data not found"
	}
	else {
		
		keep if classif1 == "AGE_YTHADULT_YGE15"  // Notice age 15+

		** Find closest year 
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
		drop source
		rename (period ref_area provider_code) (year countrycode source)
		replace source = "ILO-2"
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep   year value ub lb countrycode source
		order  year value ub lb countrycode source
	} 
	tempfile laf5
	save    `laf5'


*-- 06. Survey data 
	use "${mydata}", clear
	
	gen num = 1 if (lstatus == 1 | lstatus == 2)  & (age >= 15 & age <= 199)
	gen den = 1 if (age >= 15 & age <= 199)
	 
	collapse (count) num den [iw = weight], by(countrycode harmonization year) 
	gen value = 100*num/den
	drop num den
	
	rename harmonization source 
	gen ub = 1.05*value
	gen lb = 0.95*value
	format value ub lb %4.2fc
	order year value ub lb countrycode source
	
	tempfile laf6
	save    `laf6'
	
	
*-- 05. Combine all 
	clear 
	
	forvalues i = 1/6 {
		append using `laf`i''	
	}
	
	encode source, gen(s1)
	save "Block2_External/01_data/08labfpart.dta", replace 		
	
	
********************************************************************************
*                         09. Employment (number)                              *
********************************************************************************	
	
	
*-- 01. ILO (1), EMP_TEMP_SEX_AGE_NB
	* Employment by sex and age (thousands)
	
	#delimit ;
	dbnomics import, provider(ILO) dataset(EMP_TEMP_SEX_AGE_NB) ref_area(${ccode3}) 
	sex(SEX_T) frequency(A) clear;   
	#delimit cr 
	count
	if `r(N)' == 0 {
		di "Dbnomics data not found"
	}
	else {

		keep if  classif1 == "AGE_YTHADULT_YGE15"

		
		** Find closest year 
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
		replace value = value*10^3	
		drop source
		rename (period ref_area provider_code) (year countrycode source)
		replace source = "ILO-1"
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %14.2gc
		keep   year value ub lb countrycode source
		order  year value ub lb countrycode source
	} 
	tempfile emp1
	save    `emp1'	
	
*-- 02. ILO (2), EMP_2EMP_SEX_AGE_NB
	* Employment by sex and age -- ILO modelled estimates, Nov. 2021 (thousands)
	
	#delimit ;
	dbnomics import, provider(ILO) dataset(EMP_2EMP_SEX_AGE_NB) ref_area(${ccode3}) 
	sex(SEX_T)  frequency(A) clear;
	#delimit cr 
	count
	if `r(N)' == 0 {
		di "Dbnomics data not found"
	}
	else {

		
		keep if classif1 == "AGE_YTHADULT_YGE15"
		
		** Find closest year 
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
		replace value = value*10^3	
		drop source
		rename (period ref_area provider_code) (year countrycode source)
		replace source = "ILO-2"
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %14.2gc
		keep   year value ub lb countrycode source
		order  year value ub lb countrycode source
	} 
	
	tempfile emp2
	save    `emp2'		
	
*-- 03. Survey data 
	use "${mydata}", clear
	
	gen value = 1 if lstatus == 1  & (age >= 15 & age <= 199)
	collapse (count) value [iw = weight], by(countrycode harmonization year) 

	rename harmonization source 
	gen ub = 1.05*value
	gen lb = 0.95*value
	format value ub lb %14.2gc
	order year value ub lb countrycode source
	
	tempfile emp3
	save    `emp3'	

	
*-- 04. Combine all 
	clear 
	
	forvalues i = 1/3 {
		append using `emp`i''	
	}
	
	encode source, gen(s1)
	save "Block2_External/01_data/09employment.dta", replace 
	
********************************************************************************
*                     10. Employment to population ratio                       *
*                       (employed/ total population)                           * 
********************************************************************************	
	
*-- 01. WDI (1)
	// Employment to population ratio, 15+, total (%) (modeled ILO estimate)(SL.EMP.TOTL.SP.ZS)
	
	cap wbopendata, indicator(SL.EMP.TOTL.SP.ZS) country(${ccode3}) year(${cyear}) clear long
	if _rc {
			di "data not found in wbopendata"
		}
	else {
		gen source = "WDI-1"
		rename sl_emp* value
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	} 
	tempfile etp1
	save    `etp1'
	
	
*-- 02. WDI (2)
	// Employment to population ratio, 15+, total (%) (national estimate)(SL.EMP.TOTL.SP.NE.ZS)
	
	cap wbopendata, indicator(SL.EMP.TOTL.SP.NE.ZS) country(${ccode3}) year(${cyear}) clear long
	if _rc {
			di "data not found in wbopendata"
		}
	else {
		gen source = "WDI-2"
		rename sl_emp* value
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	}
	tempfile etp2
	save    `etp2'
		
*-- 03. ILO (1)
	// Employment-to-population ratio by sex and age (%)

	#delimit ;
	dbnomics import, provider(ILO) dataset(EMP_DWAP_SEX_AGE_RT) ref_area(${ccode3}) 
	sex(SEX_T)  frequency(A) clear;   // age 15+
	#delimit cr
	count
	if `r(N)' == 0 {
		di "Dbnomics data not found"
	}
	else {

		keep if classif1 == "AGE_YTHADULT_YGE15"
		
		//keep if period == ${cyear}
		** Find closest year 
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
		drop source
		rename (period ref_area provider_code) (year countrycode source)
		replace source = "ILO-1"
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep   year value ub lb countrycode source
		order  year value ub lb countrycode source
	} 
	tempfile etp3
	save    `etp3'	
	
	
*-- 04. ILO (2)
	// Employment-to-population ratio by sex and age -- ILO modelled estimates, 
	// Nov. 2021 (%)

	#delimit ;
	dbnomics import, provider(ILO) dataset(EMP_2WAP_SEX_AGE_RT) ref_area(${ccode3}) 
	sex(SEX_T) frequency(A) clear;   // age 15+
	#delimit cr 
	count
	if `r(N)' == 0 {
		di "Dbnomics data not found"
	}
	else {

		keep if classif1 == "AGE_YTHADULT_YGE15"
		
		** Find closest year 
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
		drop source
		rename (period ref_area provider_code) (year countrycode source)
		replace source = "ILO-2"
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep   year value ub lb countrycode source
		order  year value ub lb countrycode source
	} 
	tempfile etp4
	save    `etp4'	
	
	
*-- 06. Survey data 
	use "${mydata}", clear
	
	gen num = 1 if lstatus == 1  & (age >= 15 & age <= 199)
	gen den = 1 if (age >= 15 & age <= 199)
	 
	collapse (count) num den [iw = weight], by(countrycode harmonization year) 
	gen value = 100*num/den
	drop num den
	
	rename harmonization source 
	gen ub = 1.05*value
	gen lb = 0.95*value
	format value ub lb %4.2fc
	order year value ub lb countrycode source
	
	tempfile etp5
	save    `etp5'	
		
		
*-- 05. Combine all 
	clear 
	
	forvalues i = 1/5 {
		append using `etp`i''	
	}
	
	encode source, gen(s1)			
	save "Block2_External/01_data/10emptopop.dta", replace 	
	
	
********************************************************************************
*                          11. Unemployment rate                               *
*                         (unemployed/ labor force)                            * 
********************************************************************************

*-- 01. WDI (1)
	// Unemployment, total (% of total labor force) (modeled ILO estimate)(SL.UEM.TOTL.ZS)
	
	cap wbopendata, indicator(SL.UEM.TOTL.ZS) country(${ccode3}) year(${cyear}) clear long
	if _rc {
			di "data not found in wbopendata"
		}
	else {
		gen source = "WDI-1"
		rename sl_uem* value
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	} 
	tempfile une1
	save    `une1'
	
	
*-- 02. WDI (2)
	// Unemployment, total (% of total labor force) (national estimate)(SL.UEM.TOTL.NE.ZS)
	
	cap wbopendata, indicator(SL.UEM.TOTL.NE.ZS) country(${ccode3}) year(${cyear}) clear long
	if _rc {
			di "data not found in wbopendata"
		}
	else {
		gen source = "WDI-2"
		rename sl_uem* value
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	} 
	tempfile une2
	save    `une2'

*-- 03. ILO (1)
	// Unemployment rate by sex and age (%)
	
	#delimit ;
	dbnomics import, provider(ILO) dataset(UNE_DEAP_SEX_AGE_RT) ref_area(${ccode3}) 
	sex(SEX_T) frequency(A) clear;   
	#delimit cr
	count
	if `r(N)' == 0 {
		di "Dbnomics data not found"
	}
	else {

		keep if classif1 == "AGE_AGGREGATE_TOTAL"

		
		** Find closest year 
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
		replace source = "ILO-1"
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep   year value ub lb countrycode source
		order  year value ub lb countrycode source
	} 	
	tempfile une3
	save    `une3'	
	
*-- 04. ILO (2)
	// Unemployment rate by sex and age -- ILO modelled estimates, Nov. 2021 (%)
	
	#delimit ;
	dbnomics import, provider(ILO) dataset(UNE_2EAP_SEX_AGE_RT) ref_area(${ccode3}) 
	sex(SEX_T) frequency(A) clear;   
	#delimit cr 
	count
	if `r(N)' == 0 {
		di "Dbnomics data not found"
	}
	else {

		keep if classif1 == "AGE_YTHADULT_YGE15"
		
		** Find closest year 
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
		drop source
		rename (period ref_area provider_code) (year countrycode source)
		replace source = "ILO-2"
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep   year value ub lb countrycode source
		order  year value ub lb countrycode source
		
		tempfile une4
		save    `une4'	
	} 
	
*-- 05. Survey data 
	use "${mydata}", clear
	
	gen num = 1 if lstatus == 2  
	gen den = 1 if lstatus == 1 | lstatus == 2  
	 
	collapse (count) num den [iw = weight], by(countrycode harmonization year) 
	gen value = 100*num/den
	drop num den
	
	rename harmonization source 
	gen ub = 1.05*value
	gen lb = 0.95*value
	format value ub lb %4.2fc
	order year value ub lb countrycode source
	
	tempfile une5
	save    `une5'	
	
	
*-- 05. Combine all 
	clear 
	
	forvalues i = 1/5 {
		append using `une`i''	
	}
	
	encode source, gen(s1)
	save "Block2_External/01_data/11unemployment.dta", replace 	
	
	
********************************************************************************
*                            12. Agriculture                                   *
********************************************************************************
	
*-- 00. Determine presence of industrycat4 variable 		
	use "${mydata}", clear
	describe, replace
	count if name == "industrycat4"
	if 	`r(N)' == 0 {
		di "No urban industrycat4, agriculture share section skipped"	
	}
	else {


	*-- 01. WDI 
		// Employment in agriculture (% of total employment) (modeled ILO estimate)(SL.AGR.EMPL.ZS)
		
		cap wbopendata, indicator(SL.AGR.EMPL.ZS) country(${ccode3}) year(${cyear}) clear long 
		if _rc {
			di "data not found in wbopendata"
		}
		else {
			gen source = "WDI"
			rename sl_agr_empl_zs value
			gen ub = 1.05*value
			gen lb = 0.95*value
			format value ub lb %4.2fc
			keep  year value ub lb countrycode source
			order year value ub lb countrycode source
		} 	
		tempfile agr1
		save    `agr1'
		
		
	*-- 02. ILO 1 	
		// Employment by sex and economic activity (thousands) 
		
		#delimit ;
		dbnomics import, provider(ILO) dataset(EMP_TEMP_SEX_ECO_NB) ref_area(${ccode3}) 
		frequency(A) sex(SEX_T) clear;
		#delimit cr 
		count
		if `r(N)' == 0 {
			di "Dbnomics data not found"
		}
		else {
			
			keep if classif1 == "ECO_SECTOR_AGR" | classif1 == "ECO_SECTOR_TOTAL"
			 
			** Find closest year
			sort period 
			gen myyear = ${cyear}
			gen yeardiff = abs(period - myyear)
			egen mindiff = min(yeardiff)
			
			keep if yeardiff == mindiff
			
			sum period
			keep if period == `r(min) ' // keep earliest 
			
			sum period
			assert `r(min)' == `r(max)'
				
			** Continue 
			keep period value classif1
			
			sum value 
			if `r(N)' == 0 {
				replace value ="." if value == "NA"
				destring value, replace
			}
			
			reshape wide value, i(period) j(classif1) string
			
			gen value = 100*valueECO_SECTOR_AGR/valueECO_SECTOR_TOTAL
			drop valueECO_*
			
			rename period year 
			gen source       = "ILO-1"
			gen countrycode  = "${ccode3}"  
			gen ub      = 1.05*value
			gen lb      = 0.95*value
			format value ub lb %4.2fc
			keep  year value ub lb countrycode source
			order year value ub lb countrycode source	
		} 
		tempfile agr2
		save    `agr2'


	*-- 03. ILO 2 	
		// Employment by sex and economic activity -- ILO modelled estimates, Nov. 2020 (thousands)

		#delimit ;
		dbnomics import, provider(ILO) dataset(EMP_2EMP_SEX_ECO_NB) ref_area(${ccode3}) 
		frequency(A) sex(SEX_T) clear;
		#delimit cr
		count
		if `r(N)' == 0 {
			di "Dbnomics data not found"
		}
		else {
	
			keep if classif1 == "ECO_SECTOR_AGR" | classif1 == "ECO_SECTOR_TOTAL"
			
			** Find closest year 
			sort period 
			gen myyear = ${cyear}
			gen yeardiff = abs(period - myyear)
			egen mindiff = min(yeardiff)
			keep if yeardiff == mindiff
			sum period
			keep if period == `r(min) ' // keep earliest
			count 
			assert `r(N)' == 2 // Agr & total

			** Continue	
			keep period value classif1
			
			reshape wide value, i(period) j(classif1) string
			
			gen value = 100*valueECO_SECTOR_AGR/valueECO_SECTOR_TOTAL
			drop valueECO_*
			
			rename period year 
			gen source       = "ILO-2"
			gen countrycode  = "${ccode3}"  
			gen ub      = 1.05*value
			gen lb      = 0.95*value
			format value ub lb %4.2fc
			keep  year value ub lb countrycode source
			order year value ub lb countrycode source
		} 
		tempfile agr3
		save    `agr3'
		
		
	*-- 04. Survey data 
		use "${mydata}", clear
		
		gen agri = 1 if lstatus == 1  & industrycat4 == 1
		gen emp  = 1 if lstatus == 1
		
		 
		collapse (count) agri emp [iw = weight], by(countrycode harmonization year) 
		gen value = 100*agri/emp
		drop agri emp
		
		rename harmonization source 
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		order year value ub lb countrycode source
		
		tempfile agr4
		save    `agr4'	
		
	*-- 05. Combine all 
		clear 
		
		forvalues i = 1/4 {
			append using `agr`i''	
		}
		
		encode source, gen(s1)
		save "Block2_External/01_data/12agriculture.dta", replace 
				
	}
********************************************************************************
*                             13. Industry                                     *
********************************************************************************
	
*-- 00. Determine presence of industrycat4 variable 	
	use "${mydata}", clear
	describe, replace
	count if name == "industrycat4"
	if 	`r(N)' == 0 {
		di "No urban industrycat4, industry share section skipped"	
	}
	
	else {

	*-- 01. WDI 
		// Employment in industry (% of total employment) (modeled ILO estimate)(SL.IND.EMPL.ZS)
		
		cap wbopendata, indicator(SL.IND.EMPL.ZS) country(${ccode3}) year(${cyear}) clear long
		if _rc { // works as "if TRUE", where anything other than _rc code 0 (no error) is TRUE
			di "data not found in wbopendata"
		}
		else { // can obtain wbopendata
			gen source = "WDI"
			rename sl_ind_empl_zs value
			gen ub = 1.05*value
			gen lb = 0.95*value
			format value ub lb %4.2fc
			keep  year value ub lb countrycode source
			order year value ub lb countrycode source
		} 
		tempfile ind1
		save    `ind1'	

		
	*-- 02. ILO 
		// Employment by sex and economic activity (thousands)
		#delimit ;
		dbnomics import, provider(ILO) dataset(EMP_TEMP_SEX_ECO_NB) ref_area(${ccode3}) 
		frequency(A) sex(SEX_T) clear;
		#delimit cr 
		
		* Check whether a file has been downloaded by checking number of rows
		* if no series found the "clear" option will leave an empty dataset.
		count
		if `r(N)' == 0 {
			di "Dbnomics data not found"
		}
		else {

			keep if classif1 == "ECO_SECTOR_IND" | classif1 == "ECO_SECTOR_TOTAL"
			
			** Keep closest year 
			sort period 
			gen myyear = ${cyear}
			gen yeardiff = abs(period - myyear)
			egen mindiff = min(yeardiff)
			
			keep if yeardiff == mindiff
			
			sum period
			keep if period == `r(min) ' // keep earliest 
			
			sum period
			assert `r(min)' == `r(max)'
			
			** We should have two values (numerator & denominator)
			count
			if `r(N)' == 2 {
				
				** Continue 
				keep period value classif1
				sum value 
				if `r(N)' == 0 {
					replace value ="." if value == "NA"
					destring value, replace
				}
					
				reshape wide value, i(period) j(classif1) string
				
				gen value = 100*valueECO_SECTOR_IND/valueECO_SECTOR_TOTAL
				drop valueECO_*
				
				rename period year 
				gen source       = "ILO-1"
				gen countrycode  = "${ccode3}"  
				gen ub      = 1.05*value
				gen lb      = 0.95*value
				format value ub lb %4.2fc
				keep  year value ub lb countrycode source
				order year value ub lb countrycode source
			} 
			else {
				clear
				set obs 1
				gen source = "ILO-1"
				gen countrycode  = "${ccode3}" 
			}
		   
		} 
		tempfile ind2
		save    `ind2'	
		
	*-- 03. ILO 2 	
		// Employment by sex and economic activity -- ILO modelled estimates, Nov. 2020 (thousands)

		#delimit ;
		dbnomics import, provider(ILO) dataset(EMP_2EMP_SEX_ECO_NB) ref_area(${ccode3}) 
		frequency(A) sex(SEX_T) clear;
		#delimit cr
		
		* If nothing found, will have an empty dataset 
		count
		if `r(N)' == 0 {
			di "Dbnomics data not found"
		}
		else {
		
			keep if classif1 == "ECO_SECTOR_IND" | classif1 == "ECO_SECTOR_TOTAL"
			
			** Find closest year 
			sort period 
			gen myyear = ${cyear}
			gen yeardiff = abs(period - myyear)
			egen mindiff = min(yeardiff)
			keep if yeardiff == mindiff
			sum period
			keep if period == `r(min) ' // keep earliest
			// count 
			// assert `r(N)' == 2 // ind & total 
			
			** We should have two values (numerator & denominator)
			count
			if `r(N)' == 2 {
				
				** Continue
				keep period value classif1
				
				reshape wide value, i(period) j(classif1) string
				
				gen value = 100*valueECO_SECTOR_IND/valueECO_SECTOR_TOTAL
				drop valueECO_*
				
				rename period year 
				gen source       = "ILO-2"
				gen countrycode  = "${ccode3}"  
				gen ub      = 1.05*value
				gen lb      = 0.95*value
				format value ub lb %4.2fc
				keep  year value ub lb countrycode source
				order year value ub lb countrycode source
			} 
			else {
				clear
				set obs 1
				gen source = "ILO-2"
				gen countrycode  = "${ccode3}"  
				
			}
		} 	
		
		tempfile ind3
		save    `ind3'	
		
		
	*-- 04. Survey data 
		use "${mydata}", clear
		
		gen num  = 1 if lstatus == 1  & industrycat4 == 2
		gen den  = 1 if lstatus == 1
		 
		collapse (count) num den [iw = weight], by(countrycode harmonization year) 
		gen value = 100*num/den
		drop num den
		
		rename harmonization source 
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		order year value ub lb countrycode source
		
		tempfile ind4
		save    `ind4'	
		
	*-- 05. Combine all 
		clear 
		
		forvalues i = 1/4 {
			append using `ind`i''	
		}
		
		encode source, gen(s1)
		save "Block2_External/01_data/13industry.dta", replace 						
	}	
	
********************************************************************************
*                             14. Services                                     *
********************************************************************************

*-- 00. Determine presence of industrycat4 variable 
	use "${mydata}", clear
	describe, replace
	count if name == "industrycat4"
	if 	`r(N)' == 0 {
		di "No urban industrycat4, services share section skipped"	
	}
	
	else {
	*-- 01. WDI 
		// Employment in services (% of total employment) (modeled ILO estimate)(SL.SRV.EMPL.ZS)
		
		cap wbopendata, indicator(SL.SRV.EMPL.ZS) country(${ccode3}) year(${cyear}) clear long
		if _rc { // works as "if TRUE", where anything other than _rc code 0 (no error) is TRUE
			di "data not found in wbopendata"
		}
		else {
			gen source = "WDI"
			rename sl_srv_empl_zs value
			gen ub = 1.05*value
			gen lb = 0.95*value
			format value ub lb %4.2fc
			keep  year value ub lb countrycode source
			order year value ub lb countrycode source
		} 
		tempfile ser1
		save    `ser1'	
		
		
	*-- 02. ILO 
		// Employment by sex and economic activity (thousands)
		#delimit ;
		dbnomics import, provider(ILO) dataset(EMP_TEMP_SEX_ECO_NB) ref_area(${ccode3}) 
		frequency(A) sex(SEX_T) clear;
		#delimit cr 
		
		* If nothing found, will have an empty dataset 
		count
		if `r(N)' == 0 {
			di "Dbnomics data not found"
		}
		else {

			keep if classif1 == "ECO_SECTOR_SER" | classif1 == "ECO_SECTOR_TOTAL"
			
			** Find closest year 
			sort period 
			gen myyear = ${cyear}
			gen yeardiff = abs(period - myyear)
			egen mindiff = min(yeardiff)
			
			keep if yeardiff == mindiff
			
			sum period
			keep if period == `r(min) ' // keep earliest 
			
			// sum period
			// assert `r(min)' == `r(max)'
			
			** We should have two values (numerator & denominator)
			count
			if `r(N)' == 2 {
				** Continue 
				keep period value classif1
				sum value 
				if `r(N)' == 0 {
					replace value ="." if value == "NA"
					destring value, replace
				}

				reshape wide value, i(period) j(classif1) string
				
				gen value = 100*valueECO_SECTOR_SER/valueECO_SECTOR_TOTAL
				drop valueECO_*
				
				rename period year 
				gen source       = "ILO-1"
				gen countrycode  = "${ccode3}"  
				gen ub      = 1.05*value
				gen lb      = 0.95*value
				format value ub lb %4.2fc
				keep  year value ub lb countrycode source
				order year value ub lb countrycode source
			}
			else {
				clear
				set obs 1
				gen source = "ILO-1"
				gen countrycode  = "${ccode3}" 
				
			}
		} 
		tempfile ser2
		save    `ser2'	
		
		
	*-- 03. ILO 2 	
		// Employment by sex and economic activity -- ILO modelled estimates, Nov. 2020 (thousands)

		#delimit ;
		dbnomics import, provider(ILO) dataset(EMP_2EMP_SEX_ECO_NB) ref_area(${ccode3}) 
		frequency(A) sex(SEX_T) clear;
		#delimit cr
		
		* If nothing found, will have an empty dataset 
		count
		if `r(N)' == 0 {
			di "Dbnomics data not found"
		}
		else {

			keep if classif1 == "ECO_SECTOR_SER" | classif1 == "ECO_SECTOR_TOTAL"
			
			** Find closest year 
			sort period 
			gen myyear = ${cyear}
			gen yeardiff = abs(period - myyear)
			egen mindiff = min(yeardiff)
			keep if yeardiff == mindiff
			sum period
			keep if period == `r(min) ' // keep earliest
			// count 
			// assert `r(N)' == 2 // ser & total  
			
			** We should have two values (numerator & denominator)
			count
			if `r(N)' == 2 {
				
				** Continue
				keep period value classif1
				
				reshape wide value, i(period) j(classif1) string
				
				gen value = 100*valueECO_SECTOR_SER/valueECO_SECTOR_TOTAL
				drop valueECO_*
				
				rename period year 
				gen source       = "ILO-2"
				gen countrycode  = "${ccode3}"  
				gen ub      = 1.05*value
				gen lb      = 0.95*value
				format value ub lb %4.2fc
				keep  year value ub lb countrycode source
				order year value ub lb countrycode source
			} 
			else {
				clear
				set obs 1
				gen source = "ILO-1"
				gen countrycode  = "${ccode3}"  
			}
			
		} 
		tempfile ser3
		save    `ser3'			
		
	*-- 04. Survey data 
		use "${mydata}", clear
		
		gen num  = 1 if lstatus == 1  & ( industrycat4 == 3 | industrycat4 == 4)  // servies + other
		gen den  = 1 if lstatus == 1
		
		 
		collapse (count) num den [iw = weight], by(countrycode harmonization year) 
		gen value = 100*num/den
		drop num den
		
		rename harmonization source 
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		order year value ub lb countrycode source
		
		tempfile ser4
		save    `ser4'	
		
		
	*-- 05. Combine all 
		clear 
		
		forvalues i = 1/4 {
			append using `ser`i''	
		}
		
		
		encode source, gen(s1)
		save "Block2_External/01_data/14services.dta", replace 	
		
	}	
							
********************************************************************************
*                         15. Industry category                                *
********************************************************************************

*-- 00. Determine presence of industrycat10 variable 
	use "${mydata}", clear
	describe, replace
	count if name == "industrycat10"
	if 	`r(N)' == 0 {
		di "No urban industrycat10, industry category section skipped"	
		}
		
	else {
		
	*-- 01. Find all sectors in ILO (1)
		// Employment by sex and economic activity (thousands)
		
		#delimit ;
		dbnomics import, provider(ILO) dataset(EMP_TEMP_SEX_ECO_NB) ref_area(${ccode3}) 
		frequency(A) sex(SEX_T) clear;
		#delimit cr 
		
		* If nothing found, will have an empty dataset 
		count
		if `r(N)' == 0 {
			di "Dbnomics data not found"
		}
		else {

			** Find closest year 
			sort period 
			gen myyear = ${cyear}
			gen yeardiff = abs(period - myyear)
			egen mindiff = min(yeardiff)
			
			keep if yeardiff == mindiff
			
			sum period
			keep if period == `r(min) ' // keep earliest 
			
			sum period
			assert `r(min)' == `r(max)'

			
			** Continue 
			keep period value classif1 ref_area provider_code
			destring value, replace 
			
			split classif1, p(_)  
			
			count if classif12 == "ISIC4"
			
			if `r(N)' != 0 {                  // if we have ISIC4 codes
				keep if classif12 == "ISIC4"
				
				gen industrycat10 =.
				replace industrycat10 = 1  if classif1 == "ECO_ISIC4_A"
				replace industrycat10 = 2  if classif1 == "ECO_ISIC4_B" 
				replace industrycat10 = 3  if classif1 == "ECO_ISIC4_C" 
				replace industrycat10 = 4  if classif1 == "ECO_ISIC4_D" | classif1 == "ECO_ISIC4_E"
				replace industrycat10 = 5  if classif1 == "ECO_ISIC4_F"
				replace industrycat10 = 6  if classif1 == "ECO_ISIC4_I" | classif1 == "ECO_ISIC4_G"
				replace industrycat10 = 7  if classif1 == "ECO_ISIC4_H" | classif1 == "ECO_ISIC4_J"
				#delimit ;
				replace industrycat10 = 8  if classif1 == "ECO_ISIC4_K" | classif1 == "ECO_ISIC4_L" |
											  classif1 == "ECO_ISIC4_M" | classif1 == "ECO_ISIC4_N";
				#delimit cr 
				replace industrycat10 = 9  if classif1 == "ECO_ISIC4_O"
				#delimit ; 
				replace industrycat10 = 10 if classif1 == "ECO_ISIC4_P" | classif1 == "ECO_ISIC4_Q" |
											  classif1 == "ECO_ISIC4_R" | classif1 == "ECO_ISIC4_S" |
											  classif1 == "ECO_ISIC4_T" | classif1 == "ECO_ISIC4_U";							  
				#delimit cr
				
				replace industrycat10 = 99 if classif1 == "ECO_ISIC4_TOTAL"
			} 
			else {
				count if classif12 == "ISIC3"
				
				if `r(N)' != 0 {
				
					keep if classif12 == "ISIC3"   // if we have ISIC3 codes
					gen industrycat10 =.
					replace industrycat10 = 1  if classif1 == "ECO_ISIC3_A" | classif1 == "ECO_ISIC3_B" 
					replace industrycat10 = 2  if classif1 == "ECO_ISIC3_C" 
					replace industrycat10 = 3  if classif1 == "ECO_ISIC3_D"
					replace industrycat10 = 4  if classif1 == "ECO_ISIC3_E" 
					replace industrycat10 = 5  if classif1 == "ECO_ISIC3_F"
					replace industrycat10 = 6  if classif1 == "ECO_ISIC3_G" | classif1 == "ECO_ISIC3_H"
					replace industrycat10 = 7  if classif1 == "ECO_ISIC3_I" 
					replace industrycat10 = 8  if classif1 == "ECO_ISIC3_J" | classif1 == "ECO_ISIC3_K" 
					replace industrycat10 = 9  if classif1 == "ECO_ISIC3_L"
					#delimit ; 
					replace industrycat10 = 10 if classif1 == "ECO_ISIC3_M" | classif1 == "ECO_ISIC3_N" |
												  classif1 == "ECO_ISIC3_O" | classif1 == "ECO_ISIC3_P" |
												  classif1 == "ECO_ISIC3_Q" | classif1 == "ECO_ISIC3_X" ;
					#delimit cr	
					replace industrycat10 = 99 if classif1 == "ECO_ISIC3_TOTAL"
				}	
				else {                             // if we have don't have ISIC4 nor ISIC3 codes
					clear 
					set obs 1
					gen countrycode  = "${ccode3}"  
					gen problem = "No ISIC4 nor ISIC3 codes"
					
				}
			}
			
			
			cap sum value 
			if `r(N)' == 0 {
				cap replace value ="." if value == "NA"
				cap destring value, replace
			}

		} 
		
		save "Block2_External/01_data/temp_ilosectors1.dta", replace 
		
	*-- 02. Find all sectors in ILO (2)
		// Employment by sex and economic activity (thousands)
		
		#delimit ;
		dbnomics import, provider(ILO) dataset(EMP_2EMP_SEX_ECO_NB) ref_area(${ccode3}) 
		frequency(A) sex(SEX_T) clear;
		#delimit cr 
		
		* If nothing found, will have an empty dataset 
		count
		if `r(N)' == 0 {
			di "Dbnomics data not found"
		}
		else {
		
			** Find closest year 
			sort period 
			gen myyear = ${cyear}
			gen yeardiff = abs(period - myyear)
			egen mindiff = min(yeardiff)
			keep if yeardiff == mindiff
			sum period
			keep if period == `r(min) ' // keep earliest
			count 
			// assert `r(N)' == 1 
			sum period 
			assert `r(min)' == `r(max)'

			** Continue
			keep period value classif1 ref_area provider_code
			
			destring value, replace 
			
			split classif1, p(_)
			keep if classif12 == "DETAILS"
			
			gen industrycat10 =.
			replace industrycat10 = 1  if classif1 == "ECO_DETAILS_A"
			replace industrycat10 = 2  if classif1 == "ECO_DETAILS_B" 
			replace industrycat10 = 3  if classif1 == "ECO_DETAILS_C" 
			replace industrycat10 = 4  if classif1 == "ECO_DETAILS_DE"
			replace industrycat10 = 5  if classif1 == "ECO_DETAILS_F"
			replace industrycat10 = 6  if classif1 == "ECO_DETAILS_I"  | classif1 == "ECO_DETAILS_G"
			replace industrycat10 = 7  if classif1 == "ECO_DETAILS_HJ" 
			replace industrycat10 = 8  if classif1 == "ECO_DETAILS_K"  | classif1 == "ECO_DETAILS_LMN" 
			replace industrycat10 = 9  if classif1 == "ECO_DETAILS_O"

			#delimit ; 
			replace industrycat10 = 10 if classif1 == "ECO_DETAILS_P"  | classif1 == "ECO_DETAILS_Q" |
										  classif1 == "ECO_DETAILS_RSTU";
			#delimit cr
			
			replace industrycat10 = 99 if classif1 == "ECO_DETAILS_TOTAL"
		}
		
		save "Block2_External/01_data/temp_ilosectors2.dta", replace
			
		
	*-- 02. Check sector by sector in ILO (1)
		use "Block2_External/01_data/temp_ilosectors1.dta", clear
		describe, replace
		count if name == "problem"
		if `r(N)' == 0 {
	
			forvalues j = 1/10 {
				
				use "Block2_External/01_data/temp_ilosectors1.dta", clear
				keep if industrycat10 == `j' | industrycat10 == 99 
				
				collapse (sum) value, by(period industrycat10)
				
				keep period value industrycat10
				reshape wide value, i(period) j(industrycat10) 
				
				gen value = 100*value`j'/value99
				drop value`j' value99
				
				rename period year 
				gen source       = "ILO-1"
				gen countrycode  = "${ccode3}" 
				gen ub      = 1.05*value
				gen lb      = 0.95*value
				format value ub lb %4.2fc
				keep  year value ub lb countrycode source
				order year value ub lb countrycode source
				
				tempfile ind1_`j'
				save    `ind1_`j''	
			
			}
		} 
		else {
			di "no sector information available, block skipped"
			forvalues j = 1/10 {    // saving the temp files so that the code runs 
				clear 
				set obs 1 
				gen countrycode = "${ccode3}" 
				gen problem     = "no sector information available"
				tempfile ind1_`j'   
				save    `ind1_`j''
			}
		}
		
	*-- 02. Check sector by sector in ILO (2)
		forvalues j = 1/10 {
			
			use "Block2_External/01_data/temp_ilosectors2.dta", clear
			keep if industrycat10 == `j' | industrycat10 == 99 // only first sector 
			
			collapse (sum) value, by(period industrycat10)
			
			keep period value industrycat10
			reshape wide value, i(period) j(industrycat10) 
			
			gen value = 100*value`j'/value99
			drop value`j' value99
			
			rename period year 
			gen source       = "ILO-2"
			gen countrycode  = "${ccode3}" 
			gen ub      = 1.05*value
			gen lb      = 0.95*value
			format value ub lb %4.2fc
			keep  year value ub lb countrycode source
			order year value ub lb countrycode source
			
			tempfile ind2_`j'
			save    `ind2_`j''	
		
		}	
		
		
	*-- 03. Survey data (sector by sector)
		forvalues j = 1/10 {
			
			use "${mydata}", clear
			
			gen num  = 1 if industrycat10 == `j'
			gen den  = 1 if !missing(industrycat10)
			
			 
			collapse (count) num den [iw = weight], by(countrycode harmonization year) 
			gen value = 100*num/den
			drop num den
			
			rename harmonization source 
			gen ub = 1.05*value
			gen lb = 0.95*value
			format value ub lb %4.2fc
			order year value ub lb countrycode source
			
			tempfile ind3_`j'
			save    `ind3_`j''
			
		}
		
		
	*-- 04. Combine (original vs ILO)	
		
		forvalues j = 1/10 {
			clear 	
		
			forvalues i = 1/3 {
				append using `ind`i'_`j''	
				
			}
			encode source, gen(s1)
			save "Block2_External/01_data/15industry_`j'_temp.dta", replace	
		}	
		
		
		** Label each sector 
		local sectors Agriculture Mining Manufacturing Public-Utilities Construction Commerce Transport-Communications Financial Public-Admin Other
		
		forvalue j = 1/10 {
			local a : word `j' of `sectors'
			di "`a'"
			use   "Block2_External/01_data/15industry_`j'_temp.dta", clear 
			label var value  "`a'"
			save  "Block2_External/01_data/15industry_`j'.dta", replace	
			
		}
		
		** Erase temp files 
		forvalue j = 1/10 {
			cap	erase  "Block2_External/01_data/15industry_`j'_temp.dta"
		}
		
		forvalues i = 1/2 {
			cap erase  "Block2_External/01_data/temp_ilosectors`i'.dta"
		}
	
	}
	
**************************   END OF THE DO-FILE  *******************************
