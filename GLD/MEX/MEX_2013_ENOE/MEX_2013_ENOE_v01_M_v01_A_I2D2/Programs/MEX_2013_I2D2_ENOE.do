/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY					Mexico
** COUNTRY ISO CODE			MEX
** YEAR						2013
** SURVEY NAME				Encuesta Nacional de Ocupación y Empleo
** SURVEY AGENCY			Instituto Nacional de Estadística y Geografía (INEGI)
** SURVEY SOURCE			INEGI
** UNIT OF ANALYSIS			Households and Individuals
** INPUT DATABASES			VIVT113.dta
*							HOGT113.dta
*							SDEMT113.dta
*							COE1T113.dta
*							COE2T113.dta
** MODIFIED BY				The World Bank Jobs Group
** Created					03-22-2020
** Modified					05-29-2021
** NUMBER OF HOUSEHOLDS		101382
** NUMBER OF INDIVIDUALS	379010
** EXPANDED POPULATION		118827161
**                                                                                                  **
******************************************************************************************************
*****************************************************************************************************/

/*****************************************************************************************************
*                                                                                                    *
                                   INITIAL COMMANDS
*                                                                                                    *
*****************************************************************************************************/


** INITIAL COMMANDS
	cap log close 
	clear
	set more off
	set mem 800m



** DIRECTORY
	local path "Z:/GLD-Harmonization/582018_AQ/MEX/MEX_2013_ENOE"

** LOG FILE
	log using "`path'/MEX_2013_ENOE_v01_M_v01_A_I2D2/Programs/MEX_2013_I2D2_ENOE.log", replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/

** DATABASE ASSEMBLENT
	use "`path'/MEX_2013_ENOE_v01_M/Data/Original/VIVT113.dta",clear
	drop p1-p3
	destring loc mun est ageb t_loc cd_a upm d_sem n_pro_viv ent con v_sel n_ent per, replace
	merge 1:m ent con v_sel using "`path'/MEX_2013_ENOE_v01_M/Data/Original/HOGT113.dta", nogen
	merge 1:m ent con v_sel n_hog using "`path'/MEX_2013_ENOE_v01_M/Data/Original/SDEMT113.dta"
	drop if _merge==1
	drop _merge
	merge 1:1 ent con v_sel n_hog n_ren using "`path'/MEX_2013_ENOE_v01_M/Data/Original/COE1T113.dta", nogen
	merge 1:1 ent con v_sel n_hog n_ren using "`path'/MEX_2013_ENOE_v01_M/Data/Original/COE2T113.dta", nogen
	keep if r_pre==0 & inlist(c_res,1,3)
	tostring (ent v_sel n_hog n_ren h_mud), gen(ent_str v_sel_str n_hog_str n_ren_str h_mud_str) format(%02.0f)
	tostring con, replace
	*the variable con is a consecutive number, thus it needs to be uniform in lenght by adding leading zeros
	gen con_str=substr("000",1,4 - length(con))+ con
	*the harmonization is for the first three months of the year , any other month will be put to missing.
	tab d_mes
	replace d_mes=. if d_mes == 4 | d_mes == 5 | d_mes == 12
	tab d_mes, missing


** COUNTRY
	gen str4 ccode="MEX"
	label var ccode "Country code"


** YEAR
	gen int year=2013
	label var year "Year of survey"


** YEAR OF INTERVIEW
	gen int intv_year=2013
	label var intv_year "Year of the interview"


** MONTH OF INTERVIEW
	gen byte month=d_mes
	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"

** HOUSEHOLD IDENTIFICATION NUMBER
	egen idh=concat(ent_str con_str v_sel_str n_hog_str h_mud_str)
	label var idh "Household id"
	assert !missing(idh)
	
** INDIVIDUAL IDENTIFICATION NUMBER
	egen idp=concat(idh n_ren_str)
	label var idp "Individual id"
	isid idh idp

** HOUSEHOLD WEIGHTS
	gen double wgt=fac
	label var wgt "Household sampling weight"


** STRATA
	gen strata=est_d
	label var strata "Strata"


** PSU
	gen psu=upm
	label var psu "Primary sampling units"


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	gen byte urb=.  
 	replace urb=1 if inrange(t_loc,1,3)
 	replace urb=2 if t_loc==4 
 	label var urb "Location is urb" 
 	la de lblurb 1 "urb" 2 "Rural" 
 	label values urb lblurb


**REGIONAL AREAS
	gen byte reg01=ent
	recode reg01 2 3 18 25 26=1 5 8 10 24 32=2 19 28=3 1 6 11 14 16=4 9 13 15 17 21 22 29=5 7 12 20=6 27 30=7 4 23 31=8
	la de lblreg01 1 "Noroeste" 2 "Norte" 3 "Noreste" 4 "Centro-Occidente" 5 "Centro-Este" 6 "Sur" 7 "Oriente" 8 "Peninsula de Yucatan"
	label var reg01 "Macro regional areas"
	label values reg01 lblreg01


** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen byte reg02=ent
	la de lblreg02 1 "Aguascalientes" 2 "Baja California" 3 "Baja California Sur" 4 "Campeche" 5 "Cohauila" 6 "Colima" 7 "Chiapas" 8 "Chihuahua" 9 "Distrito Federal" 10 "Durango" 11 "Guanajuato" 12 "Guerrero" 13 "Hidalgo" 14 "Jalisco" 15 "Mexico" 16 "Michoacan" 17 "Morelos" 18 "Nayarit" 19 "Nuevo Leon" 20 "Oaxaca" 21 "Puebla" 22 "Queretaro de Arteaga" 23 "Quintana Roo" 24 "San Luis Potosi" 25 "Sinaloa" 26 "Sonora" 27 "Tabasco" 28 "Tamaulipas" 29 "Tlaxcala" 30 "Veracruz-Llave" 31 "Yucatan" 32 "Zacatecas"
	label var reg02 "Region at 1 digit (ADMN1)"
	label values reg02 lblreg02


** REGIONAL AREA 2 DIGITS ADM LEVEL (ADMN2)
	gen reg03=mun
	label var reg03 "Region at 2 digits (ADMN2)"


** REGIONAL AREA 3 DIGITS ADM LEVEL (ADMN2)
	gen reg04=.
	label var reg04 "Region at 3 digits (ADMN3)"


** HOUSE OWNERSHIP
	gen byte ownhouse=.
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	gen byte water=.
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION
	gen byte electricity=.
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity


** TOILET PUBLIC CONNECTION
	gen byte toilet=.
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet


** LAND PHONE
	gen byte landphone=.
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone


** CEL PHONE
	gen byte cellphone=.
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone


** COMPUTER
	gen byte computer=.
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer


** INTERNET
	gen byte internet=.
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
	bys idh: egen hhsize=count(year) if par_c<400 | inrange(par_c,600,699)
	label var hhsize "Household size"


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen byte head=floor(par_c/100)
	recode head 6=5 4/5 7=6 9=.
	replace head=4 if par_c==601
	label var head "Relationship to the head of household"
	la de lblhead  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values head  lblhead
	bys idh: egen hh=sum(head==1)
	bys idh: egen maxage=max(eda)
	replace head=1 if head==2 & hh==0 & eda==maxage
	drop hh
	bys idh: egen hh=sum(head==1)
	replace head=1 if hh==0 & eda==maxage
	drop hh
	bys idh: egen hh=sum(head==1)

/*
155 obs deleted
*/
	drop if hh>1


** GENDER
	gen byte gender=sex
	label var gender "Gender"
	la de lblgender 1 "Male" 2 "Female"
	label values gender lblgender


** AGE
	gen byte age=eda
	replace age=98 if age>98 & age!=.
	label var age "Individual age"


** SOCIAL GROUP
	gen byte soc=.
	label var soc "Social group"
	la de lblsoc 1 ""
	label values soc lblsoc


** MARITAL STATUS
	gen byte marital=e_con
	recode marital 1=3 2 3=4 4=5 5=1 6=2 9=. 
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen byte ed_mod_age=5
	label var ed_mod_age "Education module application age"


** CURRENTLY AT SCHOOL
	gen byte atschool=cs_p17
	recode atschool 2=0 9=.
	replace atschool=. if age<ed_mod_age & age!=.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen byte literacy=cs_p12
	recode literacy 2=0 9=.
	replace literacy=. if age<ed_mod_age & age!=.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy

	replace cs_p13_2=5 if inrange(cs_p13_2,7,9)

** YEARS OF EDUCATION COMPLETED
	gen byte educy=0 if inlist(cs_p13_1,1,4) | inlist(cs_p13_1,0,1)
	replace educy=cs_p13_2 if cs_p13_1==2
	replace educy=6+cs_p13_2 if inlist(cs_p13_1,3)
	replace educy=9+cs_p13_2 if inlist(cs_p13_1,4,5)
	replace educy=12+cs_p13_2 if inlist(cs_p13_1,6,7)
	replace educy=17+cs_p13_2 if cs_p13_1==8
	replace educy=19+cs_p13_2 if cs_p13_1==9
	replace educy=. if age<ed_mod_age & age!=.
	label var educy "Years of education"


** EDUCATIONAL LEVEL 1
	gen byte edulevel1=1 if cs_p13_1==1
	replace edulevel1=2 if cs_p13_1==2
	replace edulevel1=3 if educy==6
	replace edulevel1=4 if inrange(cs_p13_1,3,5)
	replace edulevel1=5 if educy==12
	replace edulevel1=6 if cs_p13_1==6 
	replace edulevel1=7 if inrange(cs_p13_1,7,9)
	replace edulevel1=. if age<ed_mod_age & age!=.
	label var edulevel1 "Level of education 1"
	la de lbledulevel1 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete" 8 "Other" 9 "Unstated"
	label values edulevel1 lbledulevel1


**EDUCATION LEVEL 2
	gen byte edulevel2=edulevel1
	recode edulevel2 4=3 5=4 6 7=5
	replace edulevel2=. if age<ed_mod_age & age!=.
	label var edulevel2 "Level of education 2"
	la de lbledulevel2 1 "No education" 2 "Primary incomplete"  3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
	label values edulevel2 lbledulevel2


** EDUCATION LEVEL 3
	gen byte edulevel3=edulevel1
	recode edulevel3 3=2 4 5=3 6 7=4
	replace edulevel3=. if age<ed_mod_age & age!=.
	label var edulevel3 "Level of education 3"
	la de lbledulevel3 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values edulevel3 lbledulevel3


** EVER ATTENDED SCHOOL
	gen byte everattend=.
	replace everattend=. if age<ed_mod_age & age!=.
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen byte lb_mod_age=14
	label var lb_mod_age "Labor module application age"


** LABOR STATUS
	gen byte lstatus=1 if inlist(p1,1,2) | p1a1==1 | p1a2==2 | p1b==1 | inrange(p1c,1,4) | p1d==1 | p1e==1
	replace lstatus=2 if (p2_1==1 | p2_2==2 | p2_3==3) 
	replace lstatus=3 if p2_4==4
	replace lstatus=. if age<lb_mod_age & age!=.
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-in-labor force"
	label values lstatus lbllstatus


** LABOR STATUS LAST YEAR
	gen byte lstatus_year=.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 0 "Not employed"
	label values lstatus_year lbllstatus_year


** EMPLOYMENT STATUS
	gen byte empstat=5
	replace empstat=1 if p3a==1 & p3h==1
	replace empstat=2 if p3a==2 & inlist(p3h,2,3)
	replace empstat=3 if p3b==1 & p3d==1
	replace empstat=4 if p3b==1 & p3d==2
	replace empstat=. if lstatus!=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat


** EMPLOYMENT STATUS LAST YEAR
	gen byte empstat_year=.
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year


** NUMBER OF ADDITIONAL JOBS
	gen byte njobs=p7
	recode njobs 1/6=1 7=0 9=.
	replace njobs=. if lstatus!=1
	label var njobs "Number of additional jobs"


** NUMBER OF ADDITIONAL JOBS LAST YEAR
	gen byte njobs_year=.
	replace njobs_year=. if lstatus_year!=1
	label var njobs_year "Number of additional jobs during last year"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen byte ocusec=2 if inlist(p4c,1,2)
	replace ocusec=1 if inrange(p4d2,1,6)
	replace ocusec=3 if p4d2==2
	replace ocusec=4 if p4d2==9
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public Sector, Central Government, Army, NGO" 2 "Private" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec


** REASONS NOT IN THE LABOR FORCE
	gen byte nlfreason=p2e
	recode nlfreason 3=1 4=2 2=3 5=4 1 6=5 9=.
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason

	replace p2b_mes=. if p2b_mes==99
	replace p2a_mes=. if p2a_mes==99
	gen unempldur=(2013- p2a_anio)*12 + p2b_mes- p2a_mes if p2b_anio==2013

** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l=unempldur
	replace unempldur_l=100 if unempldur>100 & unempldur!=.
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen byte unempldur_u=unempldur
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	gen byte industry=floor(p4a/100)
	recode industry 11=1 21=2 22=4 23=5 31/33=3 43 46 72=6 48/49 51=7 52/55=8 93=9 56/71 81 97/99=10 
	replace industry=. if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry


** INDUSTRY 1
	gen byte industry1=industry
	recode industry1 2/5=2 6/9=3 10=4
	replace industry1=. if lstatus!=1
	label var industry1 "1 digit industry classification (Broad Economic Activities)"
	la de lblindustry1 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1 lblindustry1


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION
	local my_industry_orig p4a                                                                         
	clonevar industry_orig=`my_industry_orig'                                                                 
	capture confirm numeric format industry_orig                                                              
	if _rc {                                                                                                  
	       noi di "`my_industry_orig' is an string variable"                                                  
	       destring industry_orig, replace                                                                    
	       local industrystring "-was string"                                                                 
	}                                                                                                         
	local industrytemp : variable label `my_industry_orig'                                                    
	label var industry_orig `"Original Industry Code (`my_industry_orig'`industrystring':`industrytemp')"'    



** OCCUPATION CLASSIFICATION
	gen occup=.
	replace occup=. if lstatus!=1
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup


** SURVEY SPECIFIC OCCUPATION CLASSIFICATION
	local my_occup_orig p3                                                   
	clonevar occup_orig=`my_occup_orig'                                                           
	capture confirm numeric format occup_orig                                                     
	if _rc {                                                                                      
	       noi di "`my_occup_orig' is an string variable"                                         
	       destring occup_orig, replace                                                           
	       local occupstring "-was string"                                                        
	}                                                                                             
	local occuptemp : variable label `my_occup_orig'                                              
	label var occup_orig `"Original Occupation Code (`my_occup_orig'`occupstring':`occuptemp')"'  


** FIRM SIZE
	gen byte firmsize_l=.
	replace firmsize_l=1 if p3q==01
	replace firmsize_l=2 if p3q==02
	replace firmsize_l=6 if p3q==03
	replace firmsize_l=11 if p3q==04
	replace firmsize_l=16 if p3q==05
	replace firmsize_l=21 if p3q==06
	replace firmsize_l=31 if p3q==07
	replace firmsize_l=51 if p3q==08
	replace firmsize_l=100 if inrange(p3q,09,12)
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket)"

	gen byte firmsize_u=.
	replace firmsize_u=1 if p3q==01
	replace firmsize_u=5 if p3q==02
	replace firmsize_u=10 if p3q==03
	replace firmsize_u=15 if p3q==04
	replace firmsize_u=20 if p3q==05
	replace firmsize_u=30 if p3q==06
	replace firmsize_u=50 if p3q==07
	replace firmsize_u=100 if inrange(p3q,8,12)
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen whours=p5c_thrs if p5c_thrs<=126
	replace whours=. if lstatus!=1
	label var whours "Hours of work in last week"

	gen ingocup_m=ingocup
	replace ingocup_m=. if  p6b2==.
	*cd "`path'\Other"
	*hotdeck ingocup_m if clase2==1 & age>=15 & age<=64 , store by(gender age cd_a educy) keep(idh idp)
	*rename ingocup_m ingocup_imp
	*merge 1:1  idh idp using "imp1.dta", nogen


** WAGES
	gen double wage=ingocup_m
	replace wage=0 if empstat==2
	replace wage=. if lstatus!=1
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen byte unitwage=5
	replace unitwage=. if lstatus!=1
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage


** EMPLOYMENT STATUS - SECOND JOB
	gen byte empstat_2=.
	replace empstat_2=. if njobs==0 | njobs==.
	label var empstat_2 "Employment status - second job"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2


** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
	gen byte empstat_2_year=.
	replace empstat_2_year=. if njobs_year==0 | njobs_year==.
	label var empstat_2_year "Employment status - second job"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2_year lblempstat_2_year


** INDUSTRY CLASSIFICATION - SECOND JOB
	gen byte industry_2=floor(p7c/100)
	recode industry_2 11=1 21=2 22=4 23=5 31/33=3 43 46 72=6 48/49 51=7 52/55=8 93=9 56/71 81 97/99=10 
	replace industry_2=. if njobs==0 | njobs==.
	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2 lblindustry_2


** INDUSTRY 1 - SECOND JOB
	gen byte industry1_2=industry_2
	recode industry1_2 2/5=2 6/9=3 10=4
	replace industry1_2=. if njobs==0 | njobs==.
	label var industry1_2 "1 digit industry classification (Broad Economic Activities) - Second job"
	la de lblindustry1_2 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1_2 lblindustry1_2


** SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
	local my_industry_orig_2 p7c                                                                        
	clonevar industry_orig_2=`my_industry_orig_2'                                                                 
	capture confirm numeric format industry_orig_2
	if _rc {                                                                                                  
	       noi di "`my_industry_orig_2' is an string variable"
	       destring industry_orig_2, replace
	       local industrystring2 "-was string"
	}                                                                                                         
	local industrytemp2 : variable label `my_industry_orig_2'
	label var industry_orig_2 `"Original Industry Code (`my_industry_orig_2'`industrystring2':`industrytemp2') - second job"'
	replace industry_orig_2=. if njobs==0 | njobs==.


** OCCUPATION CLASSIFICATION - SECOND JOB
	gen byte occup_2=.
	replace occup_2=. if njobs==0 | njobs==.
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2


** SURVEY SPECIFIC OCCUPATION CLASSIFICATION - SECOND JOB
	local my_occup_orig_2 p7a
	clonevar occup_orig_2=`my_occup_orig_2'
	capture confirm numeric format occup_orig_2
	if _rc {                                                                                      
	       noi di "`my_occup_orig_2' is an string variable"
	       destring occup_orig_2, replace
	       local occupstring2 "-was string"
	}                                                                                             
	local occuptemp2 : variable label `my_occup_orig_2'
	label var occup_orig_2 `"Original Occupation Code (`my_occup_orig_2'`occupstring2':`occuptemp2') - second job"'
	replace occup_orig_2=. if njobs==0 | njobs==.


** WAGES - SECOND JOB
	gen double wage_2=.
	replace wage_2=. if njobs==0 | njobs==.
	label var wage_2 "Last wage payment - Second job"


** WAGES TIME UNIT - SECOND JOB
	gen byte unitwage_2=.
	replace unitwage_2=. if njobs==0 | njobs==.
	label var unitwage_2 "Last wages time unit - Second job"
	la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_2 lblunitwage_2


** CONTRACT
	gen byte contract=p3j
	recode contract 2=0 9=.
	replace contract=. if lstatus!=1
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract


** HEALTH INSURANCE
	gen byte healthins=.
	replace healthins=. if lstatus!=1
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins


** SOCIAL SECURITY
	gen byte socialsec=.
	replace socialsec=. if lstatus!=1
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


** UNION MEMBERSHIP
	gen byte union=.
	replace union=. if lstatus!=1
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion


/*****************************************************************************************************
*                                                                                                    *
                                   MIGRATION MODULE
*                                                                                                    *
*****************************************************************************************************/


**REGION OF BIRTH JURISDICTION
	gen byte rbirth_juris=2 if inrange(l_nac_c,1,33)
	replace rbirth_juris=5 if inrange(l_nac_c,100,600)
	label var rbirth_juris "Region of birth jurisdiction"
	la de lblrbirth_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rbirth_juris lblrbirth_juris


**REGION OF BIRTH
	gen rbirth=l_nac_c if inrange(l_nac_c,1,32)
	replace rbirth=724 if l_nac_c==415
	replace rbirth=840 if l_nac_c==221
	replace rbirth=320 if l_nac_c==225
	label var rbirth "Region of Birth"


** REGION OF PREVIOUS RESIDENCE JURISDICTION
	gen byte rprevious_juris=.
	label var rprevious_juris "Region of previous residence jurisdiction"
	la de lblrprevious_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rprevious_juris lblrprevious_juris


** REGION OF PREVIOUS RESIDENCE
	gen rprevious=.
	label var rprevious "Region of Previous residence"


** YEAR OF MOST RECENT MOVE
	gen int yrmove=.
	label var yrmove "Year of most recent move"


**TIME REFERENCE OF MIGRATION
	gen byte rprevious_time_ref=.
	label var rprevious_time_ref "Time reference of migration"
	la de lblrprevious_time_ref 99 "Previous migration"
	label values rprevious_time_ref lblrprevious_time_ref


/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** INCOME PER CAPITA
	gen double pci=.
	label var pci "Monthly income per capita"

	gen pci_d=.

** DECILES OF PER CAPITA INCOME
	 *xtile pci_d=pci [w=wgt], nq(10) 
	label var pci_d "Income per capita deciles"


** CONSUMPTION PER CAPITA
	gen double pcc=.
	label var pcc "Monthly consumption per capita"

	gen pcc_d=.

** DECILES OF PER CAPITA CONSUMPTION
	*xtile pcc_d=pcc [w=wgt], nq(10) 
	label var pcc_d "Consumption per capita deciles"


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL
	keep ccode year intv_year month idh idp wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     cellphone computer internet hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage contract      ///
	empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
	     healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d


** ORDER VARIABLES
	order ccode year intv_year month idh idp wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     cellphone computer internet hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage contract      ///
	empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
	     healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d
	compress


** DELETE MISSING VARIABLES
	local keep ""
	qui levelsof ccode, local(cty)
	foreach var of varlist urb - pcc_d {
	qui sum `var'
	scalar sclrc = r(mean)
	if sclrc==. {
	     display as txt "Variable " as result "`var'" as txt " for ccode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
	}
	else {
	     local keep `keep' `var'
	}
	}
	keep ccode year intv_year month  idh idp wgt strata psu `keep'

	save "`path'\MEX_2013_ENOE_v01_M_v01_A_I2D2\Data\Harmonized\MEX_2013_I2D2_ENOE.dta", replace

	log close


















******************************  END OF DO-FILE  *****************************************************/
