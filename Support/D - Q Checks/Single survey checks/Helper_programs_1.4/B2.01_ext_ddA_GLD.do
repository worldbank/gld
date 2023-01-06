/*******************************************************************************
								
                          GLD CHECKS Version 1.4
                       02. Block 2 - External data
                   2A. Demographic variables - data download  	  
		   	   																   
*******************************************************************************/	

	clear all	
	cd "${output}/${ccode3}_${cyear}_${mydate}"
	
	cap mkdir "Block2_External"
	cap mkdir "Block2_External/01_data"
	cap mkdir "Block2_External/02_figures"

********************************************************************************
*                     00. Enable external data download                        *
********************************************************************************	
	
	cap dbnomics import, provider(ILO) dataset(POP_2POP_GEO_NB) ref_area(IND) clear	
	if _rc {
		set sslrelax on 
	} 
	else {
		clear 
	}
	
********************************************************************************
*                            01. Total population                              *
********************************************************************************
	
	
*-- 01. WDI 
	cap wbopendata, indicator(SP.POP.TOTL) country(${ccode3}) year(${cyear}) clear long
	if _rc {
		di "data not found in wbopendata, trying dbnomics"     
		clear
		
		dbnomics import , provider(WB) dataset(WDI) indicator(SP.POP.TOTL) clear 
		keep if country == "$ccode3"  & period == ${cyear}		
		count 
		if 	`r(N)' == 0 {
			di "WDI population not found"
		}
		
		else {
			rename (period country dataset_code) (year countrycode source)
			destring value, replace
			gen ub = 1.05*value
			gen lb = 0.95*value
			format value ub lb %14.2gc
			
			keep  year value ub lb countrycode source
			order year value ub lb countrycode source
		} 
	}
	else {
		gen source = "WDI"
		rename sp_pop_totl value
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %14.2gc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	} 
	
	tempfile pop1
	save    `pop1'
	
*-- 02. UN (DBNOMICS)  
	global series2 A.N.IN.W0.S13.S1.D.P3._Z._Z._T.XDC.L.N // will delete later
		
	#delimit ;
	cap dbnomics import, provider(UNDATA) dataset(NA_MAIN) 
	seriesids(A.N.${ccode2}.W0.S1.S1._Z.POP._Z._Z._Z.PS._Z.N, ${series2}) clear ;
	#delimit cr 
	drop if series_code  == "${series2}"	
	
	count
	if `r(N)' == 0 {
		di "UN population not found"
		* Small issue is, if data is not found (e.g. with TZ as ${ccode2}, even if series2 is there,
		* all variables (inlcuding values) become "str2045" format. If this is saved empty and then
		* united with others, it will give an error, thus destring value
		destring value, replace
		keep value
		
	} 
	
	else {
		keep if unit_measure == "PS"
		
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
		replace value = value*10^3 // changed jun 12
		rename (period ref_area provider_code) (year countrycode source)
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %14.2gc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	}
	tempfile pop2
	save    `pop2'
		

*-- 03. ILO (DBNOMICS), POP_2POP_GEO_NB
	dbnomics import, provider(ILO) dataset(POP_2POP_GEO_NB) ref_area(${ccode3}) clear
	keep if classif1 == "GEO_COV_NAT"
	drop source
	count 
	if `r(N)' == 0 {
		di "POP_2POP_GEO_NB not found"
	}
	else {
		** Find closest year 
		sort period 
		gen myyear = ${cyear}
		gen yeardiff = abs(period - myyear)
		egen mindiff = min(yeardiff)
		keep if yeardiff == mindiff
		sum period
		keep if period == `r(min) ' // keep earliest to solve ties 
		count 
		assert `r(N)' == 1 

		** Continue 
		rename (period ref_area provider_code) (year countrycode source)
		replace value = value*10^3
		replace source = "ILO-1"
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %14.2gc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	} 
	tempfile pop3
	save    `pop3'	
	

*-- 04. ILO (DBNOMICS), POP_2POP_SEX_AGE_NB
	dbnomics import, provider(ILO) dataset(POP_2POP_SEX_AGE_NB) sex(SEX_T) ref_area(${ccode3}) clear
	keep if classif1 == "AGE_10YRBANDS_TOTAL"
	drop source
		count 
	if `r(N)' == 0 {
		di "POP_2POP_SEX_AGE_NB not found"
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
		rename (period ref_area provider_code) (year countrycode source)
		replace value = value*10^3
		replace source = "ILO-2"
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %14.2gc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	} 
	tempfile pop4
	save    `pop4'	
	
*-- 05. Survey data 
	use "${mydata}", clear
	gen value = 1 
	
	* Drop if urban info is missing
	* Missingness is reported in Block 1 (or 4) here we want to know whether remaining info is 
	* in line with other sources (e.g., data is missing but not biased)
	drop if missing(urban)
	
	collapse (count) value [iw = weight], by(countrycode harmonization year) 
	rename harmonization source 
	gen ub = 1.05*value
	gen lb = 0.95*value
	format value ub lb %14.2gc
	order year value ub lb countrycode source
	
	tempfile pop5
	save    `pop5'	
	
*-- 06. Combine all 
	clear 
	
	forvalues i = 1/5 {
		append using `pop`i''	
	}
	
	encode source, gen(s1)
	save "Block2_External/01_data/01totpop.dta", replace 
	
	
********************************************************************************
*                         02. Gender split (% female)                          *
********************************************************************************	
	
*-- 00. Determine presence of male variable 		
	use "${mydata}", clear
	describe, replace
	count if name == "male"
	if 	`r(N)' == 0 {
		di "No << male >> variable, Gender split section skipped"	
		}
	else {
		
	*-- 01. WDI 
		cap wbopendata, indicator(SP.POP.TOTL.FE.ZS) country(${ccode3}) year(${cyear}) clear long
		if _rc {
			di "data not found in wbopendata"
			clear
		}
		else {
			gen source = "WDI"
			rename sp_pop_totl_fe_zs value
			gen ub = 1.05*value
			gen lb = 0.95*value
			format value ub lb %4.2fc
			keep  year value ub lb countrycode source
			order year value ub lb countrycode source
		}
		
		tempfile gen1
		save    `gen1'
		
	*-- 02. ILO (DBNOMICS), POP_2POP_SEX_AGE_NB
		dbnomics import, provider(ILO) dataset(POP_2POP_SEX_AGE_NB) ref_area(${ccode3}) classif1(AGE_AGGREGATE_TOTAL) clear
		count
		if `r(N)' == 0 {
			di "POP_2POP_SEX_AGE_NB not found"
		}
		else {
			drop if sex == "SEX_M"
			
			** Find closest year 
			sort period 
			gen myyear = ${cyear}
			gen yeardiff = abs(period - myyear)
			egen mindiff = min(yeardiff)
			keep if yeardiff == mindiff
			sum period
			keep if period == `r(min) ' // keep earliest 
			count 
			assert `r(N)' == 2 // Female and total 

			** Continue 
			keep period value sex
			reshape wide value, i(period) j(sex) string
			
			gen countrycode = "${ccode3}"
			gen year        = ${cyear}
			gen source      = "ILO-1"
			gen value = 100*valueSEX_F / valueSEX_T
			gen ub = 1.05*value
			gen lb = 0.95*value
			format value ub lb %4.2fc
			keep  year value ub lb countrycode source
			order year value ub lb countrycode source
		} 
		
		tempfile gen2
		save    `gen2'		
		

	*-- 03. ILO (DBNOMICS), POP_2POP_SEX_AGE_GEO_NB
		#delimit ;
		dbnomics import, provider(ILO) dataset(POP_2POP_SEX_AGE_GEO_NB) 
		classif1(AGE_AGGREGATE_TOTAL) classif2(GEO_COV_NAT) ref_area(${ccode3}) clear;
		#delimit cr 
		count 
		if `r(N)' == 0 {
			di "POP_2POP_SEX_AGE_GEO_NB not found"
		} 
		else {
		drop if sex == "SEX_M"
		
			** Find closest year 
			sort period 
			gen myyear = ${cyear}
			gen yeardiff = abs(period - myyear)
			egen mindiff = min(yeardiff)
			keep if yeardiff == mindiff
			sum period
			keep if period == `r(min) ' // keep earliest 
			count 
			assert `r(N)' == 2 // female & total  

			** Continue 
			keep period value sex
			reshape wide value, i(period) j(sex) string
			
			gen countrycode = "${ccode3}"
			gen year        =  period
			gen source      = "ILO-2"
			gen value = 100*valueSEX_F / valueSEX_T
			gen ub = 1.05*value
			gen lb = 0.95*value
			format value ub lb %4.2fc
			keep  year value ub lb countrycode source
			order year value ub lb countrycode source
		} 
		tempfile gen3
		save    `gen3'			
		
		
	*-- 04. Survey data 
		use "${mydata}", clear
		gen value = 1 
		collapse (count) value [iw = weight], by(male countrycode harmonization year) 
		
		replace male = 2 if missing(male) // in case gender missing

		reshape wide value, i(year) j(male) 
		
		egen den = rowtotal(value*)
		gen value = 100* value0/den
		rename harmonization source
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
		
		tempfile gen4
		save    `gen4'	
		
	*-- 05. Combine all 
		clear 
		
		forvalues i = 1/4 {
			append using `gen`i''	
		}
		
		encode source, gen(s1)
		save "Block2_External/01_data/02gensplit.dta", replace 			
	}
	
********************************************************************************
*                              03. Urban share                                 *
********************************************************************************
	
*-- 00. Determine presence of urban variable 	
	use "${mydata}", clear
	describe, replace
	count if name == "urban"
	
	if 	`r(N)' == 0 {
		di "No urban variable, urban share section skipped"	
	}
	else {

	*-- 01. WDI 
		cap wbopendata, indicator(SP.URB.TOTL.IN.ZS) country(${ccode3}) year(${cyear}) clear long
		if _rc {
			di "data not found in wbopendata"
			clear
		}
		else {
			gen source = "WDI"
			rename sp_urb_totl_in_zs value
			gen ub = 1.05*value
			gen lb = 0.95*value
			format value ub lb %4.2fc
			keep  year value ub lb countrycode source
			order year value ub lb countrycode source
		} 
		tempfile urb1
		save    `urb1'
		
		
	*-- 02. ILO (DBNOMICS), POP_2POP_GEO_NB  
		clear 
		dbnomics import, provider(ILO) dataset(POP_2POP_GEO_NB) ref_area(${ccode3}) clear
		count
		if `r(N)' == 0 {
			di "POP_2POP_GEO_NB not found"
		}
		else {
			drop if classif1 == "GEO_COV_RUR"
			
			** Find closest year 
			sort period 
			gen myyear = ${cyear}
			gen yeardiff = abs(period - myyear)
			egen mindiff = min(yeardiff)
			keep if yeardiff == mindiff
			sum period
			keep if period == `r(min) ' // keep earliest 
			count 
			assert `r(N)' == 2 // urban & total 

			** Continue 
			keep period value classif1
			
			reshape wide value, i(period) j(classif1) string
			
			gen countrycode = "${ccode3}"
			gen year        = ${cyear}
			gen source      = "ILO"
			gen value = 100*valueGEO_COV_URB/valueGEO_COV_NAT
			
			gen ub = 1.05*value
			gen lb = 0.95*value
			format value ub lb %4.2fc
			keep  year value ub lb countrycode source
			order year value ub lb countrycode source
			
		} 
		tempfile urb2
		save    `urb2'


	*-- 03. Survey data 
		use "${mydata}", clear
		gen value = 1 
		collapse (count) value [iw = weight], by(urban countrycode harmonization year)  
		
		reshape wide value, i(year) j(urban) 
		gen value = 100* value1/(value0 + value1)
		rename harmonization source
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
		
		tempfile urb3
		save    `urb3'

	*-- 05. Combine all 
		clear 
		
		forvalues i = 1/3 {
			append using `urb`i''	
		}
		
		encode source, gen(s1)
		save "Block2_External/01_data/03urbanshare.dta", replace 	
	}
	
********************************************************************************
*                            04. Children (0-14)                               *
********************************************************************************
	
	
*-- 00. Determine presence of children
	use "${mydata}", clear
	sum age 

	if 	`r(min)' >= 10 {
		di "No children in this survey, children share skipped"	
	}
	else {	
		
	*-- 01. WDI 
		cap wbopendata, indicator(SP.POP.0014.TO.ZS) country(${ccode3}) year(${cyear}) clear long
		if _rc {
			di "data not found in wbopendata"
		}
		else {
			gen source = "WDI"
			rename sp_pop_0014_to_zs value
			gen ub = 1.05*value
			gen lb = 0.95*value
			format value ub lb %4.2fc
			keep  year value ub lb countrycode source
			order year value ub lb countrycode source
		} 	
		tempfile chi1
		save    `chi1'
			

	*-- 02. ILO (DBNOMICS), POP_2POP_SEX_AGE_NB  	
		** Total population (denominator)
		#delimit ;
		dbnomics import, provider(ILO) dataset(POP_2POP_SEX_AGE_NB) ref_area(${ccode3}) 
		sex(SEX_T) clear;
		#delimit cr 

		count
		if `r(N)' == 0 {
			di "POP_2POP_SEX_AGE_NB not found"
		}
		else {
			keep if classif1 == "AGE_5YRBANDS_TOTAL"

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
			keep value period ref_area provider_code
			rename value value_d
			
			tempfile iloA1
			save    `iloA1'
			
			** Children (numerator)
			#delimit ;
			dbnomics import, provider(ILO) dataset(POP_2POP_SEX_AGE_NB) ref_area(${ccode3}) 
			sex(SEX_T) clear;
			#delimit cr 

			#delimit ;
			keep if classif1 == "AGE_5YRBANDS_Y00-04" | classif1 == "AGE_5YRBANDS_Y05-09" | 
					classif1 == "AGE_5YRBANDS_Y10-14" ; 
			#delimit cr

			** Find closest year 
			sort period 
			gen myyear = ${cyear}
			gen yeardiff = abs(period - myyear)
			egen mindiff = min(yeardiff)
			keep if yeardiff == mindiff
			sum period
			keep if period == `r(min) ' // keep earliest 
			count 
			assert `r(N)' == 3 // 3 age groups 

			** Continue 
			collapse (sum) value, by(period ref_area provider_code)
			rename value value_n
			
			tempfile iloA2
			save    `iloA2'
			
			** Combine  
			use `iloA1', clear 
			merge 1:1 period ref_area provider_code using `iloA2'
			assert _merge == 3
			drop _merge 
			
			rename (period ref_area provider_code) (year countrycode source)
			replace source = "ILO-1"
			
			gen value = 100*value_n / value_d
			gen ub = 1.05*value
			gen lb = 0.95*value
			format value ub lb %4.2fc
			format countrycode source %5s
			keep  year value ub lb countrycode source
			order year value ub lb countrycode source
		} 
		set obs 1
		gen empty =.
		tempfile chi2
		save    `chi2'

	*-- 03. ILO (DBNOMICS), POP_2POP_SEX_AGE_GEO_NB 

		** Total population (denominator)
		#delimit ;
		dbnomics import, provider(ILO) dataset(POP_2POP_SEX_AGE_GEO_NB) ref_area(${ccode3}) 
		sex(SEX_T) clear;
		#delimit cr 
		if `r(N)' == 0 {
			di "POP_2POP_SEX_AGE_GEO_NB found"
		}
		else {
			keep if classif2 == "GEO_COV_NAT"
			keep if classif1 == "AGE_5YRBANDS_TOTAL"

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
			keep value period ref_area provider_code
			rename value value_d
			
			tempfile iloB1
			save    `iloB1'
			
			** Children (numerator)
			#delimit ;
			dbnomics import, provider(ILO) dataset(POP_2POP_SEX_AGE_GEO_NB) ref_area(${ccode3}) 
			sex(SEX_T) clear;
			#delimit cr 

			#delimit ;
			keep if classif1 == "AGE_5YRBANDS_Y00-04" | classif1 == "AGE_5YRBANDS_Y05-09" | 
					classif1 == "AGE_5YRBANDS_Y10-14" ; 
			#delimit cr
			//keep if period   == $cyearr5
			
			keep if classif2 == "GEO_COV_NAT"
			
			** Find closest year 
			sort period 
			gen myyear = ${cyear}
			gen yeardiff = abs(period - myyear)
			egen mindiff = min(yeardiff)
			keep if yeardiff == mindiff
			sum period
			keep if period == `r(min) ' // keep earliest 
			count 
			assert `r(N)' == 3 // 3 age groups  

			** Continue 
			collapse (sum) value, by(period ref_area provider_code)
			rename value value_n
			
			tempfile iloB2
			save    `iloB2'
			
			** Combine  
			use `iloB1', clear 
			merge 1:1 period ref_area provider_code using `iloB2'
			assert _merge == 3
			drop _merge 
			
			rename (period ref_area provider_code) (year countrycode source)
			replace source = "ILO-2"
			
			gen value = 100*value_n / value_d
			gen ub = 1.05*value
			gen lb = 0.95*value
			format value ub lb %4.2fc
			format countrycode source %5s
			keep  year value ub lb countrycode source
			order year value ub lb countrycode source
		} 
		tempfile chi3
		save    `chi3'


	*-- 04. Survey data 
		use "${mydata}", clear
		
		gen     child = 1 if age >= 0 & age <=14
		replace child = 0 if child != 1
		gen     value = 1 
		
		collapse (count) value [iw = weight], by(child countrycode harmonization year) 
		
		reshape wide value, i(year) j(child) 
		
		egen den = rowtotal(value*)
		gen value = 100* value1/den
		
		rename harmonization source
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
		
		tempfile chi4
		save    `chi4'	
		
		
	*-- 05. Combine all 
		clear 
		
		forvalues i = 1/4 {
			append using `chi`i''	
		}
		
		encode source, gen(s1)
		save "Block2_External/01_data/04children.dta", replace 
		
	}				
		

		
********************************************************************************
*                       05. Working age (15-64)                                *
********************************************************************************	


*-- 01. WDI 
	cap wbopendata, indicator(SP.POP.1564.TO.ZS) country(${ccode3}) year(${cyear}) clear long  
	if _rc {
			di "data not found in wbopendata"
		}
	else {	
		gen source = "WDI"
		rename sp_pop_1564_to_zs value
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	} 
	tempfile adu1
	save    `adu1'

*-- 02. ILO (DBNOMICS), POP_2POP_SEX_AGE_NB  	
	** Total population (denominator)
	clear 
	#delimit ;
	dbnomics import, provider(ILO) dataset(POP_2POP_SEX_AGE_NB) ref_area(${ccode3}) 
	sex(SEX_T) clear;
	#delimit cr 
	count
	if `r(N)' == 0 {
		di "POP_2POP_SEX_AGE_NB not found"
	}
	else {
		keep if classif1 == "AGE_5YRBANDS_TOTAL"
		
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
		keep value period ref_area provider_code
		rename value value_d
		
		tempfile iloA1
		save    `iloA1'
		
		
		** Working age (numerator)
		#delimit ;
		dbnomics import, provider(ILO) dataset(POP_2POP_SEX_AGE_NB) ref_area(${ccode3}) 
		sex(SEX_T) clear;
		#delimit cr 

		#delimit ;
		keep if classif1 == "AGE_5YRBANDS_Y15-19" | classif1 == "AGE_5YRBANDS_Y20-24" | 
				classif1 == "AGE_5YRBANDS_Y25-29" | classif1 == "AGE_5YRBANDS_Y30-34" |
				classif1 == "AGE_5YRBANDS_Y35-39" | classif1 == "AGE_5YRBANDS_Y40-44" |
				classif1 == "AGE_5YRBANDS_Y45-49" | classif1 == "AGE_5YRBANDS_Y50-54" |
				classif1 == "AGE_5YRBANDS_Y55-59" | classif1 == "AGE_5YRBANDS_Y60-64" ; 
		#delimit cr
		
		** Find closest year 
		sort period 
		gen myyear = ${cyear}
		gen yeardiff = abs(period - myyear)
		egen mindiff = min(yeardiff)
		keep if yeardiff == mindiff
		sum period
		keep if period == `r(min) ' // keep earliest in case of tie
		count 
		assert `r(N)' == 10 // 10 age brackets  

		** Continue 
		collapse (sum) value, by(period ref_area provider_code)
		rename value value_n
		
		tempfile iloA2
		save    `iloA2'
		
		** Combine  
		use `iloA1', clear 
		merge 1:1 period ref_area provider_code using `iloA2'
		assert _merge == 3
		drop _merge 
		
		rename (period ref_area provider_code) (year countrycode source)
		replace source = "ILO-1"
		
		gen value = 100*value_n / value_d
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		format countrycode source %5s
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	} 
	tempfile adu2
	save    `adu2'
	
	
*-- 03. ILO (DBNOMICS), POP_2POP_SEX_AGE_GEO_NB  

	** Total population (denominator)
	#delimit ;
	dbnomics import, provider(ILO) dataset(POP_2POP_SEX_AGE_GEO_NB) ref_area(${ccode3}) 
	sex(SEX_T) clear;
	#delimit cr 
	count
	if `r(N)' == 0 {
		di "ILO data not found"
	}
	else {
		
		keep if classif1 == "AGE_5YRBANDS_TOTAL"
		keep if classif2 == "GEO_COV_NAT"
		
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
		keep value period ref_area provider_code
		rename value value_d
		
		tempfile iloB1
		save    `iloB1'
		
		** Working age (numerator)
		#delimit ;
		dbnomics import, provider(ILO) dataset(POP_2POP_SEX_AGE_GEO_NB) ref_area(${ccode3}) 
		sex(SEX_T) clear;
		#delimit cr 

		#delimit ;
		keep if classif1 == "AGE_5YRBANDS_Y15-19" | classif1 == "AGE_5YRBANDS_Y20-24" | 
				classif1 == "AGE_5YRBANDS_Y25-29" | classif1 == "AGE_5YRBANDS_Y30-34" |
				classif1 == "AGE_5YRBANDS_Y35-39" | classif1 == "AGE_5YRBANDS_Y40-44" |
				classif1 == "AGE_5YRBANDS_Y45-49" | classif1 == "AGE_5YRBANDS_Y50-54" |
				classif1 == "AGE_5YRBANDS_Y55-59" | classif1 == "AGE_5YRBANDS_Y60-64" ; 
		#delimit cr
		
		keep if classif2 == "GEO_COV_NAT"
		
		** Find closest year 
		sort period 
		gen myyear = ${cyear}
		gen yeardiff = abs(period - myyear)
		egen mindiff = min(yeardiff)
		keep if yeardiff == mindiff
		sum period
		keep if period == `r(min) ' // keep earliest
		count 
		assert `r(N)' == 10 // 10 age brackets  

		** Continue
		collapse (sum) value, by(period ref_area provider_code)
		rename value value_n
		
		tempfile iloB2
		save    `iloB2'
		
		** Combine  
		use `iloB1', clear 
		merge 1:1 period ref_area provider_code using `iloB2'
		assert _merge == 3
		drop _merge 
		
		rename (period ref_area provider_code) (year countrycode source)
		replace source = "ILO-2"
		
		gen value = 100*value_n / value_d
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		format countrycode source %5s
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	} 	
	tempfile adu3
	save    `adu3'

	
*-- 04. Survey data 
	use "${mydata}", clear
	
	gen     adult = 1 if age >= 15 & age <=64
	replace adult = 0 if adult != 1
	gen     value = 1 
	
	collapse (count) value [iw = weight], by(adult countrycode harmonization year) 
	
	reshape wide value, i(year) j(adult) 
	
	gen value = 100* value1/(value0 + value1)
	rename harmonization source
	gen ub = 1.05*value
	gen lb = 0.95*value
	format value ub lb %4.2fc
	keep  year value ub lb countrycode source
	order year value ub lb countrycode source
	
	tempfile adu4
	save    `adu4'		
	
*-- 05. Combine all 
	clear 
	
	forvalues i = 1/4 {
		append using `adu`i''	
	}
	
	encode source, gen(s1)	
	save "Block2_External/01_data/05workingage.dta", replace 	
	
	
********************************************************************************
*                            06. Seniors (65+)                                 *
********************************************************************************	


*-- 01. WDI 
	cap wbopendata, indicator(SP.POP.65UP.TO.ZS) country(${ccode3}) year(${cyear}) clear long 
	if _rc {
			di "data not found in wbopendata"
		}
	else {	
		gen source = "WDI"
		rename sp_pop_65up_to_zs value
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	} 
	
	tempfile sen1
	save    `sen1'


*-- 02. ILO (DBNOMICS), POP_2POP_SEX_AGE_NB  	
	
	** Total population (denominator)
	#delimit ;
	dbnomics import, provider(ILO) dataset(POP_2POP_SEX_AGE_NB) ref_area(${ccode3}) 
	sex(SEX_T) clear;
	#delimit cr 
	
	count
	if `r(N)' == 0 {
		di "ILO data not found"
	}
	else {
	keep if classif1 == "AGE_5YRBANDS_TOTAL"
	
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
		keep value period ref_area provider_code
		rename value value_d
		
		tempfile iloA1
		save    `iloA1'
		
		
		** Seniors (numerator)
		#delimit ;
		dbnomics import, provider(ILO) dataset(POP_2POP_SEX_AGE_NB) ref_area(${ccode3}) 
		sex(SEX_T) clear;
		#delimit cr 

		keep if classif1 == "AGE_5YRBANDS_YGE65" 

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
		collapse (sum) value, by(period ref_area provider_code)
		rename value value_n
		
		tempfile iloA2
		save    `iloA2'
		
		** Combine  
		use `iloA1', clear 
		merge 1:1 period ref_area provider_code using `iloA2'
		assert _merge == 3
		drop _merge 
		
		rename (period ref_area provider_code) (year countrycode source)
		replace source = "ILO-1"
		
		gen value = 100*value_n / value_d
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		format countrycode source %5s
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	} 
	tempfile sen2
	save    `sen2'

*-- 03. ILO (DBNOMICS), POP_2POP_SEX_AGE_GEO_NB

	** Total population (denominator)
	#delimit ;
	dbnomics import, provider(ILO) dataset(POP_2POP_SEX_AGE_GEO_NB) ref_area(${ccode3}) 
	sex(SEX_T) clear;
	#delimit cr 
	
	count
	if `r(N)' == 0 {
		di "ILO data not found"
	}
	
	else {
	
		keep if classif1 == "AGE_5YRBANDS_TOTAL"
		keep if classif2 == "GEO_COV_NAT"
		
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
		keep value period ref_area provider_code
		rename value value_d
		
		tempfile iloB1
		save    `iloB1'
		
		** Seniors (numerator)
		#delimit ;
		dbnomics import, provider(ILO) dataset(POP_2POP_SEX_AGE_GEO_NB) ref_area(${ccode3}) 
		sex(SEX_T) clear;
		#delimit cr 

		keep if classif1 == "AGE_5YRBANDS_YGE65" 
		keep if classif2 == "GEO_COV_NAT"
		
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
		collapse (sum) value, by(period ref_area provider_code)
		rename value value_n
		
		tempfile iloB2
		save    `iloB2'
		
		** Combine  
		use `iloB1', clear 
		merge 1:1 period ref_area provider_code using `iloB2'
		assert _merge == 3
		drop _merge 
		
		rename (period ref_area provider_code) (year countrycode source)
		replace source = "ILO-2"
		
		gen value = 100*value_n / value_d
		gen ub = 1.05*value
		gen lb = 0.95*value
		format value ub lb %4.2fc
		format countrycode source %5s
		keep  year value ub lb countrycode source
		order year value ub lb countrycode source
	} 
	tempfile sen3
	save    `sen3'

	
*-- 04. Survey data 
	use "${mydata}", clear
	
	gen     senior = 1 if age >= 65 & age <= 199
	replace senior = 0 if senior != 1
	gen     value  = 1 
	
	collapse (count) value [iw = weight], by(senior countrycode harmonization year) 
	
	reshape wide value, i(year) j(senior) 
	
	gen value = 100* value1/(value0 + value1)
	rename harmonization source
	gen ub = 1.05*value
	gen lb = 0.95*value
	format value ub lb %4.2fc
	keep  year value ub lb countrycode source
	order year value ub lb countrycode source
	
	tempfile sen4
	save    `sen4'	
	
*-- 05. Combine all 
	clear 
	
	forvalues i = 1/4 {
		append using `sen`i''	
	}
	
	encode source, gen(s1)
	save "Block2_External/01_data/06seniors.dta", replace
	
	macro drop series2 
	
**************************   END OF THE DO-FILE  *******************************	
	
	
