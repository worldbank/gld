/*******************************************************************************
								
                             GLD CHECKS Version 1.4
				      12. Block 4 - Bivariatate data checks    	  
		   	   																   
*******************************************************************************/

	clear all
	cd "${output}/${ccode3}_${cyear}_${mydate}"
	
	cap mkdir "Block4_Bivariate" 
	cap mkdir "Block4_Bivariate/01_data"
	
*-- 01. Education: cross-categories 
	use "${mydata}", clear
	
	keep countrycode year educat7 educat5 educat4 
	sort educat7
	drop if missing(educat7) & missing(educat5) & missing(educat4)
	duplicates drop
	
	gen correct_1 = 0
	replace correct_1 = 1 if educat7 == 1 & educat5 == 1 & educat4 == 1
	replace correct_1 = 1 if educat7 == 2 & educat5 == 2 & educat4 == 2
	replace correct_1 = 1 if educat7 == 3 & educat5 == 3 & educat4 == 2
	replace correct_1 = 1 if educat7 == 4 & educat5 == 3 & educat4 == 2
	replace correct_1 = 1 if educat7 == 5 & educat5 == 4 & educat4 == 3
	replace correct_1 = 1 if educat7 == 6 & educat5 == 5 & educat4 == 4
	replace correct_1 = 1 if educat7 == 7 & educat5 == 5 & educat4 == 4
	sum correct_1
	if `r(min)'  == 0  {
		gen reason_1  = "Education cross-categories inconsistency" if correct_1 == 0
	}
		
	gen problem = ""
	sum correct_1
	replace problem = "Yes" if  `r(min)' == 0
	replace problem = "No"  if  `r(min)' == 1
	
	gen bivariate = 1
	order countrycode year bivariate problem 
	save "Block4_Bivariate/01_data/biv_1.dta", replace
	
	
*-- 02. Industry: cross-categories  
	use "${mydata}", clear
	
	** Look for isic_version
	describe, replace
	count if name == "isic_version"
	global has_isic `r(N)'
	
	** If ISIC info is avaialble 
	if ${has_isic} == 1 { 
		use "${mydata}", clear
		
		keep countrycode year industrycat_isic industrycat10 industrycat4 isic_version   
		sort industrycat_isic
		drop if missing(industrycat_isic) & missing(industrycat10) & missing(industrycat4)
		duplicates drop
		
		
		split isic_version, p(_)
		if isic_version2 == "4" {
			
			** Checks   
			* Set by default to error
			gen correct_2 = 0
			
			* Generate ind as ISIC 2 digit
			gen ind_2d = substr(industrycat_isic,1,2)
			
			* Set to correct_2 = 1 if in line with expectation
			replace correct_2 = 1 if industrycat10 == 1  & industrycat4 == 1 &   inrange(ind_2d, "01", "03")
			replace correct_2 = 1 if industrycat10 == 2  & industrycat4 == 2 &   inrange(ind_2d, "05", "09")
			replace correct_2 = 1 if industrycat10 == 3  & industrycat4 == 2 &   inrange(ind_2d, "10", "33")
			replace correct_2 = 1 if industrycat10 == 4  & industrycat4 == 2 &   inrange(ind_2d, "35", "39")
			replace correct_2 = 1 if industrycat10 == 5  & industrycat4 == 2 &   inrange(ind_2d, "41", "43")
			replace correct_2 = 1 if industrycat10 == 6  & industrycat4 == 3 & ( inrange(ind_2d, "45", "47") | inrange(ind_2d, "55", "56") )
			replace correct_2 = 1 if industrycat10 == 7  & industrycat4 == 3 & ( inrange(ind_2d, "49", "53") | inrange(ind_2d, "58", "63") ) 
			replace correct_2 = 1 if industrycat10 == 8  & industrycat4 == 3 &   inrange(ind_2d, "64", "82")
			replace correct_2 = 1 if industrycat10 == 9  & industrycat4 == 3 &   inrange(ind_2d, "84", "84")
			replace correct_2 = 1 if industrycat10 == 10 & industrycat4 == 4 &   inrange(ind_2d, "85", "99")  
			drop ind_2d
			
			sum correct_2
			if `r(min)'  == 0  {
				gen reason_2  = "Industry cross-categories inconsistency" if correct_2 == 0
			}
		
			** Summary 
			gen problem = ""
			sum correct_2
			replace problem = "Yes" if  `r(min)' == 0
			replace problem = "No"  if  `r(min)' == 1
		
		} // close if ISIC Rev 4
		
		else if inlist(isic_version2, "3", "3.1") {
			
			** Checks   
			* Set by default to error
			gen correct_2 = 0
			
			* Generate ind as ISIC 2 digit
			gen ind_2d = substr(industrycat_isic,1,2)
			
			* Set to correct_2 = 1 if in line with expectation
			replace correct_2 = 1 if industrycat10 == 1  & industrycat4 == 1 &   inrange(ind_2d, "01", "05")
			replace correct_2 = 1 if industrycat10 == 2  & industrycat4 == 2 &   inrange(ind_2d, "10", "14")
			replace correct_2 = 1 if industrycat10 == 3  & industrycat4 == 2 &   inrange(ind_2d, "15", "37")
			replace correct_2 = 1 if industrycat10 == 4  & industrycat4 == 2 &   inrange(ind_2d, "40", "41")
			replace correct_2 = 1 if industrycat10 == 5  & industrycat4 == 2 &   inrange(ind_2d, "45", "45")
			replace correct_2 = 1 if industrycat10 == 6  & industrycat4 == 3 &   inrange(ind_2d, "50", "55")
			replace correct_2 = 1 if industrycat10 == 7  & industrycat4 == 3 &   inrange(ind_2d, "60", "64")
			replace correct_2 = 1 if industrycat10 == 8  & industrycat4 == 3 &   inrange(ind_2d, "65", "74")
			replace correct_2 = 1 if industrycat10 == 9  & industrycat4 == 3 &   inrange(ind_2d, "75", "75")
			replace correct_2 = 1 if industrycat10 == 10 & industrycat4 == 4 &   inrange(ind_2d, "80", "99")  
			drop ind_2d
			
			sum correct_2
			if `r(min)'  == 0  {
				gen reason_2  = "Industry cross-categories inconsistency" if correct_2 == 0
			}
		
			** Summary 
			gen problem = ""
			sum correct_2
			replace problem = "Yes" if  `r(min)' == 0
			replace problem = "No"  if  `r(min)' == 1
			
			
			
		} // close if ISIC Rev 3 or 3.1
		
		else { 
			gen problem = "ISIC version not 4, 3, or 3.1 --> didn't check"
			
		} // close ISIC version not 4,3,3.1
		
		drop isic_version1 isic_version2
	} // close if ${has_isic} == 1
	
	** If ISIC info is not avaialble 
	if ${has_isic} == 0 { 	
		
		use "${mydata}", clear
		keep countrycode year
		duplicates drop
		
		gen problem = "ISIC version not known, didn't check"
		
	}
	 
	gen bivariate = 2
	order countrycode year bivariate problem 
	save "Block4_Bivariate/01_data/biv_2.dta", replace

			
*-- 03. Occupation: cross categories 	 
	use "${mydata}", clear	
	
	** Look for isic_version
	describe, replace
	count if name == "isco_version"
	global has_isco `r(N)'

	** If ISIC info is avaialble 
	if ${has_isco} == 1 { 
		
		use "${mydata}", clear	
	
		keep countrycode year occup_isco occup_skill occup isco_version
		sort occup_isco
		drop if missing(occup_isco) & missing(occup_skill) & missing(occup)
		duplicates drop
		
		split isco_version, p(_)
		
		* Match of first digit to occup is the same for ISCO-88 and ISCO-08
		if inlist(isco_version2, "1988", "2008") {
		
			* Set by default to error
			gen correct_3 = 0
			
			* Generate occup as ISCO 1 digit
			gen occ_1d = substr(occup_isco,1,1)
			
			replace correct_3 = 1 if occup == 10 & 					  occ_1d == "0"
			replace correct_3 = 1 if occup == 1  & occup_skill == 3 & occ_1d == "1"
			replace correct_3 = 1 if occup == 2  & occup_skill == 3 & occ_1d == "2"
			replace correct_3 = 1 if occup == 3  & occup_skill == 3 & occ_1d == "3"
			replace correct_3 = 1 if occup == 4  & occup_skill == 2 & occ_1d == "4"
			replace correct_3 = 1 if occup == 5  & occup_skill == 2 & occ_1d == "5"
			replace correct_3 = 1 if occup == 6  & occup_skill == 2 & occ_1d == "6"
			replace correct_3 = 1 if occup == 7  & occup_skill == 2 & occ_1d == "7"
			replace correct_3 = 1 if occup == 8  & occup_skill == 2 & occ_1d == "8"
			replace correct_3 = 1 if occup == 9  & occup_skill == 1 & occ_1d == "9"
			drop occ_1d
			
			sum correct_3
			if `r(min)'  == 0  {
				gen reason_3  = "Occupation cross-categories inconsistency" if correct_3 == 0  
			}
			gen problem = ""
			replace problem = "Yes" if  `r(min)' == 0
			replace problem = "No"  if  `r(min)' == 1
			
		} // close if ISCO is 88 or 08
		
		else { 
		
			gen problem = "ISCO version not 1988, didn't check"
		
		}	
		
		drop isco_version1 isco_version2
		
	} // close if has ISCO is 1
	
	if ${has_isco} == 0 { 
		use "${mydata}", clear	
	
		keep countrycode year  
		duplicates drop
		
		gen problem = "ISCO version not known, didn't check"
	} 
	
	
	gen bivariate = 3 
	order countrycode year bivariate problem
	save "Block4_Bivariate/01_data/biv_3.dta", replace

	
*-- 04. Labor force x employment 	
	use "${mydata}", clear
	
	keep countrycode year lstatus empstat
	duplicates drop
	sort lstatus
	drop if missing(lstatus) & missing(empstat)
	
	gen correct_4 = .

	* Correct cases
	replace correct_4 = 0 if lstatus == 1 & !missing(empstat)
	replace correct_4 = 0 if lstatus == 2 & missing(empstat)
	replace correct_4 = 0 if lstatus == 3 & missing(empstat)

	* Wrong if is employed (lstatus == 1), misses empstat
	replace correct_4 = -1 if lstatus == 1 & missing(empstat)

	* Wrong if not employe (lstatus 2 or 3), has empstat
	replace correct_4 = 1 if inrange(lstatus, 2, 3) & !missing(empstat)

	gen reason_4 = ""
	replace reason_4 = "There are employees with missing empstat" if correct_4 == -1
	replace reason_4 = "There are unemployed, NLF with empstat" if correct_4 == 1

	gen problem = "No"
	replace problem = "Yes" if correct_4 != 0
	
	gen bivariate = 4
	order countrycode year bivariate problem 
	save "Block4_Bivariate/01_data/biv_4.dta", replace
	
	
*-- 05. Lstatus x age 
	use "${mydata}", clear
	keep countrycode year lstatus age weight
	
	** Create age groups 
	gen age2 =.
	replace age2 = 1 if inrange(age, 0, 14)   // child
	replace age2 = 2 if inrange(age, 15, 24)  // youth
	replace age2 = 3 if inrange(age, 25, 54)  // adult
	replace age2 = 4 if inrange(age, 55, 70)  // senior
	replace age2 = 5 if inrange(age, 71, 120) // retiree 
	
	label define age2l 1 "Child" 2 "Young" 3 "Adult" 4 "Senior" 5 "Retiree"
	label values age2 age2l

	** Create table 
		// tab age2 lstatus [iw = weight], m row nofreq 
	gen x = 1 
	collapse (count) x [iw = weight], by(age2 lstatus)
	replace lstatus = 99 if missing(lstatus)
	
	sum lstatus 
	global maxlstat `r(max)'	
	
	** With missing lstatus 
	if 	${maxlstat} == 99 {
		reshape wide x, i(age2) j(lstatus)
		egen total = rowtotal(x1 x2 x3 x99)
		
		foreach v of varlist x1 - total {
			replace `v' = 100*`v'/total
		}
		
		rename (x1 x2 x3 x99) (employed unemployed non_lf missing)
		format employed unemployed non_lf missing total %4.2fc
	}
	
	** Without missing lstatus 
	if 	${maxlstat} == 3 {
		reshape wide x, i(age2) j(lstatus)
		egen total = rowtotal(x1 x2 x3)
		
		foreach v of varlist x1 - total {
			replace `v' = 100*`v'/total
		}
		
		rename (x1 x2 x3) (employed unemployed non_lf)
		format employed unemployed non_lf total %4.2fc
	} 	
	
	
	foreach v of varlist employed - total {
		replace `v' = 0 if missing(`v')     // treat missing as 0.0
	}
	
	** Check 1. Child must be >= 90% non_lf + missing 
	if 	 ${maxlstat} == 99 {
		egen  temp1  = rowtotal(non_lf missing) if age2 == 1 
	}
	if 	 ${maxlstat} == 3 {
		gen  temp1  = non_lf if age2 == 1 
	}	
	gen     correct1_5 = 0 if age2 == 1
	replace correct1_5 = 1 if age2 == 1 & inrange(temp1, 90, 100)
	drop    temp1
	sum correct1_5
	if `r(N)' != 0 {
		if `r(min)'  == 0  {
			gen reason1_5  = "Child must be > 90% non_lf + missing" if correct1_5 == 0   
		}
	}
	 
	** Check 2. Youth must be mostly >50% non_lf 
	gen     correct2_5 = 0 if age2 == 2
	replace correct2_5 = 1 if age2 == 2 & inrange(non_lf, 50, 100)
	sum correct2_5
	if `r(N)' != 0 {
		if `r(min)'  == 0  {
			gen reason2_5  = "Youth must be mostly >50% non_lf non_lf" if correct2_5 == 0   
		}
	}
	
	** Check 3. Adults must be mostly >50% in lf 
	gen     temp3      = employed + unemployed if age2 == 3
	gen     correct3_5 = 0 if age2 == 3
	replace correct3_5 = 1 if age2 == 3 & inrange(temp3, 50, 100)
	drop    temp3
	sum correct3_5
	if `r(min)'  == 0  {
		gen reason2_5  = reason3_5  = "Adults must be mostly >50% in lf" if correct3_5 == 0   
	}
	
	** Check 4. Seniors must be in the lf at a lower rate than adults 
	sum non_lf if age2 == 3
	gen temp4          = non_lf - `r(max)' if age2 == 4
	gen correct4_5     = 0 if age2 == 4
	replace correct4_5 = 1 if age2 == 4 & temp4 > 0 
	drop temp4 
	sum correct4_5
	if `r(min)'  == 0  {
		gen reason4_5  = "Seniors must be in the lf at a lower rate than adults" if correct4_5 == 0   
	}
	   
	** Check 5. Retirees must be non_lf >80%
	gen     correct5_5 = 0 if age2 == 5
	replace correct5_5 = 1 if age2 == 5 & inrange(non_lf, 80, 100)
	sum correct5_5
	if `r(min)'  == 0  {
		gen reason5_5  = "Retirees must be non_lf >80%" if correct5_5 == 0   
	}
	
	** Check 6. All empstat groups should be >0 for working age pople 
	egen    sharemin   = rowmin(employed unemployed non_lf) if inrange(age2, 2,4)
	sum     sharemin
	gen     correct6_5 = 0 if inrange(age2, 2,4)
	replace correct6_5 = 1 if `r(min)' > 0 & inrange(age2, 2,4)
	drop    sharemin
	sum correct6_5
	if `r(min)'  == 0  {
		gen reason6_5  = "All empstat groups should be >0 for working age pople" if correct6_5 == 0   
	}
	
	** Summary of results & save 
	gen     problem = ""
	egen    tempmin = rowmin(correct*_5)
	sum     tempmin
	replace problem = "Yes" if  `r(min)' == 0
	replace problem = "No"  if  `r(min)' == 1
	drop    tempmin
	
	gen countrycode = "${ccode3}"
	gen year        =  ${cyear}
	gen bivariate   = 5
	order countrycode year bivariate problem 
	save "Block4_Bivariate/01_data/biv_5.dta", replace
	

*-- 06. Education x age  
	use "${mydata}", clear
	keep countrycode year educat4 age weight
	
	** Create age groups 
	gen age2 =.
	replace age2 = 1 if inrange(age, 0, 14)   // child
	replace age2 = 2 if inrange(age, 15, 24)  // youth
	replace age2 = 3 if inrange(age, 25, 54)  // adult
	replace age2 = 4 if inrange(age, 55, 70)  // senior
	replace age2 = 5 if inrange(age, 71, 120) // retiree 
	
	label define age2l 1 "Child" 2 "Young" 3 "Adult" 4 "Senior" 5 "Retiree"
	label values age2 age2l
	
	** Create table 
		// tab age2 educat4 [iw = weight], m row nofreq   
 
	gen x = 1 
	collapse (count) x [iw = weight], by(age2 educat4)
	replace educat4 = 99 if missing(educat4)
	
	sum educat4 
	global  maxeducat `r(max)'	
	
	reshape wide x, i(age2) j(educat4)
	egen total = rowtotal(x*)
	
	foreach v of varlist x* total {
		replace `v' = 100*`v'/total
		replace `v' = 0 if missing(`v') 
	}
	
	cap rename x1 no_ed 
	cap rename x2 primary
	cap rename x3 secondary
	cap rename x4 post_sec
	cap rename x99 missing
	
	* Ensure all options exist, create as 0 if not, prettify
	local educ_checks "no_ed primary secondary post_sec missing total"
	foreach var of local educ_checks {
		
		cap confirm variable `var'
		if _rc != 0 {
			gen `var' = 0
		}
		
		format `var' %4.2fc
		
	}

	** Check 1. Children should be no_ed & primary > 90%
	gen temp1    = 100*(no_ed + primary)/(total-missing) if age2 == 1
	
	gen     correct1_6 = 0 if age2 == 1
	replace correct1_6 = 1 if age2 == 1 & temp1 >= 90
	drop    temp1
	sum correct1_6
	if `r(N)' != 0 {
		if `r(min)'  == 0  {
			gen reason1_6  = "Children should be no_ed & primary > 90%" if correct1_6 == 0   
		}
	}
	
	** Check 2. Primary, secondary  post secondary should no be 0 for youth+ 
	egen    sharemin   = rowmin(no_ed primary secondary post_sec) if inrange(age2, 2,5)
	sum     sharemin
	gen     correct2_6 = 0 if inrange(age2, 2,4)
	replace correct2_6 = 1 if `r(min)' > 0 & inrange(age2, 2,4)
	drop    sharemin
	sum correct2_6
	if `r(min)'  == 0  {
		gen reason2_6  = "Primary, secondary post secondary should not be 0 for youth+" if correct2_6 == 0    	
	} 
	
	
	** Check 3. For all age groups, no education level should be 100%
	egen    maxed    = rowmax(no_ed primary secondary post_sec)
	gen     correct3_6 = 0
	replace correct3_6 = 1 if maxed < 100
	drop    maxed
	sum correct3_6
	if `r(min)'  == 0  {
		gen reason3_6  = "For all age groups, no education level should be 100%" if correct3_6 == 0 
	}
	
	** Summarize of results & save 
	gen     problem = ""
	egen    tempmin = rowmin(correct*_6) 
	sum     tempmin
	replace problem = "Yes" if  `r(min)' == 0
	replace problem = "No"  if  `r(min)' == 1
	drop    tempmin
	
	gen countrycode = "${ccode3}"
	gen year        =  ${cyear}
	gen bivariate   = 6
	order countrycode year bivariate problem 
	save "Block4_Bivariate/01_data/biv_6.dta", replace
	

*-- 07. Industry x occupation 	
	use "${mydata}", clear
	keep countrycode year industrycat10 industrycat4 occup weight 
	
	** Create table 
		//tab occup industrycat4 [iw = weight], m row nofreq
		
	gen x = 1 
	collapse (count) x [iw = weight], by(occup industrycat4)
	drop if missing(occup) | missing(industrycat4)
	
	reshape wide x, i(occup) j(industrycat4)
	egen total = rowtotal(x1 x2 x3 x4)
	
	foreach v of varlist x1 - total {
		replace `v' = 100*`v'/total
	}
	
	rename (x1 x2 x3 x4) (agric industry services other)
	gen serv2 = 100*services/(agric+industry+services)
	gen ind2 = 100*industry/(agric+industry+services)
	order occup - services ind2  serv2
	format agric ind* serv* other total %4.2fc
	
	foreach v of varlist agric - other {
		replace `v' = 0 if missing(`v')     // teat missing as 0.0
	}

	
	** Check 1. Managers should be not be prevalent in agriculture, <20%
	gen     correct1_7  = 0 if occup == 1
	replace correct1_7  = 1 if occup == 1 & inrange(agric, 0, 20)    
	sum correct1_7
	if `r(min)'  == 0  {
		gen  reason1_7  = "Managers should be not be prevalent in agriculture, <20%" if correct1_7 == 0
	}
	
	** Check 2. Professionals whould be low in agriculture, <10%
	gen     correct2_7  = 0 if occup == 2
	replace correct2_7  = 1 if occup == 2 & inrange(agric, 0, 10)    
	sum correct2_7
	if `r(min)'  == 0  {
		gen  reason2_7  = "Professionals whould be low in agriculture, <10%" if correct2_7 == 0 
	}
	
	** Check 3. Professionals should be mainly in services, >60% 
	gen     correct3_7  = 0 if occup == 2
	replace correct3_7  = 1 if occup == 2 & inrange(serv2, 60, 100)    
	sum correct3_7
	if `r(min)'  == 0  {
		gen  reason3_7  = "Professionals should be mainly in services, >60%" if correct3_7 == 0 
	}
	
	** Check 4. Technicians whould be low in agriculture, <10%
	gen     correct4_7  = 0 if occup == 3
	replace correct4_7  = 1 if occup == 3 & inrange(agric, 0, 10)    
	sum correct4_7
	if `r(min)'  == 0  {
		gen  reason4_7  = "Technicians should be low in agriculture, <10%" if correct4_7 == 0 
	}
	
	** Check 5. Clerks whould be low in agriculture, <10%
	gen     correct5_7  = 0 if occup == 4
	replace correct5_7  = 1 if occup == 4 & inrange(agric, 0, 10)    
	sum correct5_7
	if `r(min)'  == 0  {
		gen  reason5_7  = "Clerks should be low in agriculture, <10%" if correct5_7 == 0
	}
	
	** Check 6. Clerks should be mainly in services, >60%
	gen     correct6_7  = 0 if occup == 4
	replace correct6_7  = 1 if occup == 4 & inrange(serv2, 60, 100)    
	sum correct6_7
	if `r(min)'  == 0  {
		gen  reason6_7  = "Clerks should be mainly in services, >60%" if correct6_7 == 0 
	} 
	
	** Check 7. Service and market should be low in agriculture, <10%
	gen     correct7_7  = 0 if occup == 5
	replace correct7_7  = 1 if occup == 5 & inrange(agric, 0, 10)
	sum correct7_7
	if `r(min)'  == 0  {
		gen  reason7_7  = "Service and market should be low in agriculture, <10%" if correct7_7 == 0 
	} 
	
	** Check 8. Service and market should be almost only in services, >80%
	gen     correct8_7  = 0 if occup == 5
	replace correct8_7  = 1 if occup == 5 & inrange(serv2, 80, 100)
	sum correct8_7
	if `r(min)'  == 0  {
		gen  reason8_7  = "Service and market should be almost only in services, >80%" if correct8_7 == 0 
	} 
	
	** Check 9. Skilled agricultural should be almost only in agriculture, >80%
	gen     correct9_7  = 0 if occup == 6
	replace correct9_7  = 1 if occup == 6 & inrange(agric, 80, 100)
	sum correct9_7
	if `r(min)'  == 0  {
		gen  reason9_7  = "Skilled agricultural should be almost only in agriculture, >80%" if correct9_7 == 0  
	}
	
	** Check 10. Craft workers should be low in agriculture, <10%
	gen     correct10_7 = 0 if occup == 7
	replace correct10_7 = 1 if occup == 7 & inrange(agric, 0, 10)
	sum correct10_7
	if `r(min)'  == 0  {
		gen reason10_7  = "Craft workers should be low in agriculture, <10%" if correct10_7 == 0  
	} 
	
	** Check 11. Craft workers should be mainly in industry, >60%
	gen     correct11_7 = 0 if occup == 7
	replace correct11_7 = 1 if occup == 7 & inrange(ind2, 60, 100)
	sum correct11_7
	if `r(min)'  == 0  {
		gen reason11_7  = "Craft workers should be mainly in industry, >60%" if correct11_7 == 0 
	} 
	
	** Check 12. Machine operators whould be low in agriculture, <10%
	gen     correct12_7 = 0 if occup == 8
	replace correct12_7 = 1 if occup == 8 & inrange(agric, 0, 10)
	sum correct12_7
	if `r(min)'  == 0  {
		gen reason12_7  = "Machine operators whould be low in agriculture, <10%" if correct12_7 == 0 
	} 
	
	** Check 13. In all ocupp, other should be low, <25% 
	gen     correct13_7 = 0
	replace correct13_7 = 1 if inrange(other, 0, 25) 
	sum correct13_7
	if `r(min)'  == 0  {
		gen reason13_7  = "In all ocupp, other should be low, <25%" if correct13_7 == 0 
	}
	
	** Check 14. In any ocuup, no industry should be exlusive, 100%     // potential exception for armed forces? 
	gen     correct14_7 = 0
	egen    maxcat    = rowmax(agric industry services other)
	replace correct14_7 = 1 if maxcat < 100
	drop    maxcat
	sum correct14_7
	if `r(min)'  == 0  {
		gen reason14_7  = "In any occup, no industry should be exlusive, 100%" if correct14_7 == 0 
	} 
	
	** Check 15. In any occup, not all industries should not be missing, (.)
	gen     correct15_7 = 0
	egen    mincat    = rowmin(agric industry services other)
	replace correct15_7 = 1 if !missing(mincat) & mincat != 0 
	drop    mincat
	sum correct15_7
	if `r(min)'  == 0  {
		gen reason15_7  = "In any occup, not all industries should not 0%, (.)" if correct15_7 == 0 
	} 
	
	** Summarize results & save 
	gen     problem = ""
	egen    tempmin = rowmin(correct*_7) 
	sum     tempmin
	replace problem = "Yes" if  `r(min)' == 0
	replace problem = "No"  if  `r(min)' == 1
	drop    tempmin
	
	
	gen countrycode = "${ccode3}"
	gen year        =  ${cyear}
	gen bivariate   = 7
	order countrycode year bivariate problem 
	save "Block4_Bivariate/01_data/biv_7.dta", replace
	
	
*-- 08. Occupation x education 

	* Load data
	use "${mydata}", clear
	
	* Keep only relevant vars, only if working
	keep countrycode year occup educat4 weight lstatus
	keep if lstatus == 1 
	
	* Generate counter, collapse to get weighted sum
	gen x = 1 
	collapse (count) x [iw = weight], by(occup educat4)
	
	* Give missing a value (99), necessary for reshaping
	replace educat4 = 99 if missing(educat4)
	
	sum educat4 
	global  maxeducat `r(max)'	
	
	* Reshape data wide --> education level in the columns
	reshape wide x, i(occup) j(educat4)
	
	* Calculate row totals (per occupation)
	egen total = rowtotal(x*)
	
	* Convert to a share, set to 0 if missing
	foreach v of varlist x* total {
		replace `v' = 100*`v'/total
		replace `v' = 0 if missing(`v') 
	}
	
	* Rename variables to interpretable names
	cap rename x1 no_ed 
	cap rename x2 primary
	cap rename x3 secondary
	cap rename x4 post_sec
	cap rename x99 missing
	
	* Ensure all options exist, create as 0 if not, prettify
	local educ_checks "no_ed primary secondary post_sec missing total"
	foreach var of local educ_checks {
		
		cap confirm variable `var'
		if _rc != 0 {
			gen `var' = 0
		}
		
		format `var' %4.2fc
		
	}
	
	** Check 1. Professionals with no_edu should be low, <10% 
	gen     correct1_8 = 0 if occup == 2
	replace correct1_8 = 1 if occup == 2 & inrange(no_ed, 0, 10) 
	sum correct1_8
	if `r(min)'  == 0  {
		gen reason1_8  = "Professionals with no_edu should be low, <10%" if correct1_8 == 0
	} 
	** Check 2. Professionals should manily have post_sec, >60% 
	gen     correct2_8 = 0 if occup == 2
	replace correct2_8 = 1 if occup == 2 & inrange(post_sec, 60, 100) 
	sum correct2_8
	if `r(min)'  == 0  {
		gen reason2_8  = "Professionals should manily have post_sec, >60%" if correct2_8 == 0
	} 
	
	** Check 3. Technicians with no_edu should be low, <10% 
	gen     correct3_8 = 0 if occup == 3
	replace correct3_8 = 1 if occup == 3 & inrange(no_ed, 0, 10) 
	sum correct3_8
	if `r(min)'  == 0  {
		gen reason3_8  = "Technicians with no_edu should be low, <10%" if correct3_8 == 0
	}
	
	** Check 4. Clerks with no_edu should be low, <10% 
	gen     correct4_8 = 0 if occup == 4
	replace correct4_8 = 1 if occup == 4 & inrange(no_ed, 0, 10) 
	sum correct4_8
	if `r(min)'  == 0  {
		gen reason4_8  = "Clerks with no_edu should be low, <10%" if correct4_8 == 0
	} 
	
	** Check 5. Machine operators with post sec should not be prevalent, <20% 
	gen     correct5_8 = 0 if occup == 8
	replace correct5_8 = 1 if occup == 8 & inrange(post_sec, 0, 20) 
	sum correct5_8
	if `r(min)'  == 0  {
		gen reason5_8  = "Machine operators with post sec should not be prevalent, <20%" if correct5_8 == 0
	} 
	
	** Check 6. Elementary occupations with post sec should be low, <10% 
	gen     correct6_8 = 0 if occup == 9
	replace correct6_8 = 1 if occup == 9 & inrange(post_sec, 0, 10) 
	sum correct6_8
	if `r(min)'  == 0  {
		gen reason6_8  = "Elementary occupations with post sec should be low, <10%" if correct6_8 == 0
	} 
	
	** Summarize results & save 
	gen     problem = ""
	egen    tempmin = rowmin(correct*_8) 
	sum     tempmin
	replace problem = "Yes" if  `r(min)' == 0
	replace problem = "No"  if  `r(min)' == 1
	drop    tempmin
	
	gen countrycode = "${ccode3}"
	gen year        =  ${cyear}
	gen bivariate   = 8
	order countrycode year bivariate problem 
	save "Block4_Bivariate/01_data/biv_8.dta", replace


*-- 09. Find issues and export results 	
	
	** Combine data 
	clear
	forvalues i = 1/8 {
		append using "Block4_Bivariate/01_data/biv_`i'.dta"
	}
	count if problem == "Yes"
	global problems `r(N)'
	if ${problems} == 0 {
		di "all done"
	}
	else {
		keep if problem == "Yes"	
	}
	
	** Highlight issues 
	egen find0s = rowmin(correct*)
	keep if find0s == 0

	keep  countrycode year bivariate problem reason* 
    order countrycode year bivariate problem reason*  
	duplicates drop
	
	gen note = ""
	tostring bivariate, gen(number)
	replace note = "See file biv_"+ number + ".dta"  
	drop number
		
	** Save & export 
	save "Block4_Bivariate/01_data/biv_results.dta", replace 
	export excel using "01_summary/B4_bivariave_results.xlsx", firstrow(variables) replace	
	
	
*-- 10. Conclude checks	
	macro drop has_isic has_isco maxlstat maxeducat problems
	clear
	cd
	di "Bivariate checks completed for ${ccode3}-${cyear}"	
	
	
**************************   END OF THE DO-FILE  *******************************		

	
