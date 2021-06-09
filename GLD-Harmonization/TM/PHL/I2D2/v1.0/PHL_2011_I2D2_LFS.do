/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	PHILIPPINES
** COUNTRY ISO CODE	PHL
** YEAR	2011
** SURVEY NAME	Labour Force Survey
** SURVEY AGENCY	National Statistics Office
** SURVEY SOURCE	
** UNIT OF ANALYSIS	Household and Individual
** INPUT DATABASES	D:\__I2D2\Philippines\2011\Original\LFS_JAN2011.dta
** RESPONSIBLE	Cristian Jara 
** Created	6/21/2013
** Modified	2/23/2017
** NUMBER OF HOUSEHOLDS	42856
** NUMBER OF INDIVIDUALS	203948
** EXPANDED POPULATION	94915273
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
	local path "D:\__I2D2\Philippines\2011\LFS"


** LOG FILE
	log using "`path'\Processed\PHL_2011_I2D2_LFS.log", replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

	use "`path'\Original\LFS JAN, APR 2011\LFS JAN2011.dta"


** COUNTRY
	gen str4 ccode="PHL"
	label var ccode "Country code"


** YEAR
	gen int year=svyyr
	label var year "Year of survey"


** YEAR OF INTERVIEW
	gen int intv_year=2011
	label var intv_year "Year of the interview"


** MONTH OF INTERVIEW
	gen byte month=1
	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"


** HOUSEHOLD IDENTIFICATION NUMBER
	tostring hhnum, gen(idh)
	label var idh "Household id"


** INDIVIDUAL IDENTIFICATION NUMBER
	sort hhnum
	by hhnum: generate n1 = _n
	egen idp=concat(idh n1), punct(-)
	label var idp "Individual id"


** HOUSEHOLD WEIGHTS
	gen double wgt=fwgt/10000
	label var wgt "Household sampling weight"


** STRATA
	gen strata=stratum
	label var strata "Strata"


** PSU
	label var psu "Primary sampling units"


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	gen byte urb=urb2k70
	label var urb "Urban/Rural"
	la de lblurb 1 "Urban" 2 "Rural"
	label values urb lblurb


**REGIONAL AREAS
	gen byte reg01=reg
	la de lblreg01 1 "Ilocos" 2 "Cagayan Valley" 3 "Central Luzon" 5 "Bicol" 6 "Western Visayas" 7 "Central Visayas" 8 "Eastern Visayas" 9 "Zamboanga Peninsula" 10 "Northern Mindanao" 11 "Davao" 12 "Soccsksargen" 13 "National Capital Region" 14 "Cordillera Administrative Region" 15 "Autonomous Region in Muslim Mindana" 16 "Caraga" 41 "Calabarzon" 42 "Mimaropa" 
	label var reg01 "Macro regional areas"
	label values reg01 lblreg01


** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen byte reg02=prov
	label var reg02 "Region at 1 digit (ADMN1)"
	label values reg02 lblreg02


** REGIONAL AREA 2 DIGITS ADM LEVEL (ADMN2)
	gen reg03=mun
	label var reg03 "Region at 2 digits (ADMN2)"


** REGIONAL AREA 3 DIGITS ADM LEVEL (ADMN3)
	gen reg04=bgy
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
	sort idh
	by idh: egen hhsize= count(n1)
	label var hhsize "Household size"


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen byte head=c05_rel
	recode head (9 10 11=6)(7=4) (4 5 6 8=5)
	label var head "Relationship to the head of household"
	la de lblhead  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values head  lblhead


** GENDER
	gen byte gender= c06_sex
	label var gender "Gender"
	la de lblgender 1 "Male" 2 "Female"
	label values gender lblgender


** AGE
	gen byte age= c07_age
	replace age=98 if age>=98 & age!=.
	label var age "Individual age"


** SOCIAL GROUP
	gen byte soc=.
	label var soc "Social group"
	label values soc lblsoc


** MARITAL STATUS
	gen byte marital=c08_ms
	recode marital (1=2) (2=1) (3=5)(5 6=.)
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
	gen byte atschool=a02_csch
	recode atschool 2=0
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen byte literacy=.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen byte educy=.
	replace educy=0 if c09_grd==0 | c09_grd==1
	replace educy=7 if c09_grd==2 |  c09_grd==3
	replace educy=13 if c09_grd==4
	replace educy=16 if c09_grd>5 & age>5
	label var educy "Years of education"


** EDUCATIONAL LEVEL 1
	gen byte edulevel1=.
	replace edulevel1=1 if c09_grd==0 
	replace edulevel1=2 if c09_grd==1
	replace edulevel1=3 if c09_grd==2
	replace edulevel1=4 if c09_grd==3
	replace edulevel1=5 if c09_grd==4 
	replace edulevel1=7 if c09_grd>=5 & c09_grd<=78
	label var edulevel1 "Level of education 1"
	la de lbledulevel1 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete" 8 "Other" 9 "Unstated"
	label values edulevel1 lbledulevel1


** EDUCATION LEVEL 2
	gen byte edulevel2=edulevel1
	recode edulevel2 (4=3) (5=4)  (6/7=5) (8=.)
	label var edulevel2 "Level of education 2"
	la de lbledulevel2 1 "No education" 2 "Primary incomplete"  3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
	label values edulevel2 lbledulevel2


** EDUCATION LEVEL 3
	gen byte edulevel3=edulevel1
	recode edulevel3 (2 3 =2) (4 5 =3) (6/7 =4) (8=.)
	label var edulevel3 "Level of education 3"
	la de lbledulevel3 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values edulevel3 lbledulevel3


** EVER ATTENDED SCHOOL
	gen byte everattend=.

	replace everatten=1 if edulevel3==2 | edulevel3==3 | edulevel3==4 | atschool==1
	replace everatten=0 if edulevel3==1
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
	replace atschool=0 if everattend==0
	replace everattend=1 if atschool==1

/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen byte lb_mod_age=15
	label var lb_mod_age "Labor module application age"


** LABOR STATUS
	gen byte lstatus=3
	replace lstatus=1 if  c13_work==1 | c14_job==1
	replace lstatus=2 if  c38_lokw==1
	replace lstatus=. if age<15
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** LABOR STATUS LAST YEAR
	gen byte lstatus_year=.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 0 "Not employed"
	label values lstatus_year lbllstatus_year


** EMPLOYMENT STATUS
	gen byte empstat=.
	replace empstat=1 if c19pclas==0 | c19pclas==1 | c19pclas==2
	replace empstat=2 if c19pclas==6
	replace empstat=3 if c19pclas==4
	replace empstat=4 if c19pclas==3  | c19pclas==5
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** EMPLOYMENT STATUS LAST YEAR
	gen byte empstat_year=.
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year


** NUMBER OF ADDITIONAL JOBS
	gen byte njobs=  a03_jobs
	label var njobs "Number of additional jobs"


** NUMBER OF ADDITIONAL JOBS LAST YEAR
	gen byte njobs_year=.
	replace njobs_year=. if lstatus_year!=1
	label var njobs_year "Number of additional jobs during last year"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen byte ocusec=.
	replace ocusec=1 if c19pclas==2 
	replace ocusec=2 if lstatus==1 & c19pclas~=2
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec


** REASONS NOT IN THE LABOR FORCE
	gen byte nlfreason=.
	replace nlfreason=1 if c42_wynt==8
	replace nlfreason=2 if c42_wynt==7
	replace nlfreason=3 if c42_wynt==6 & age>15
	replace nlfreason=4 if c42_wynt==3
	replace nlfreason=5 if c42_wynt==1 | c42_wynt==2 | c42_wynt==4 |c42_wynt==5 | c42_wynt==9
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l=c40_wks/4.2
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen byte unempldur_u=c40_wks/4.2
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	gen byte industry=.
	replace industry=1 if (c18_pkb>=1&c18_pkb<=6)
	replace industry=2 if (c18_pkb>=10&c18_pkb<=11) 
	replace industry=3 if (c18_pkb>=15&c18_pkb<=39) 
	replace industry=4 if (c18_pkb>=40&c18_pkb<=41) 
	replace industry=5 if (c18_pkb==45) 
	replace industry=6 if (c18_pkb>=50&c18_pkb<=55) 
	replace industry=7 if (c18_pkb>=60&c18_pkb<=64) 
	replace industry=8 if (c18_pkb>=65&c18_pkb<=74) 
	replace industry=9 if (c18_pkb==75) | (c18_pkb>=80&c18_pkb<=85) 
	replace industry=10 if  (c18_pkb>=90&c18_pkb<=99)
	replace industry=10 if industry==. & c18_pkb!=.
	replace industry=. if lstatus~=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Community and family oriented services" 10 "Other services, unspecified"
	label values industry lblindustry


** INDUSTRY 1
	gen byte industry1=industry
	recode industry1 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry1=. if lstatus!=1
	label var industry1 "1 digit industry classification (Broad Economic Activities)"
	la de lblindustry1 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1 lblindustry1


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION
	gen industry_orig=c18_pkb
	replace industry_orig=. if lstatus!=1
	label var industry_orig "Original Industry Codes"


** OCCUPATION CLASSIFICATION
	gen byte occup=floor(c16/10)
	recode occup 0=10
	replace occup=99 if c16==9
	replace occup=. if lstatus~=1
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup


** SURVEY SPECIFIC OCCUPATION CLASSIFICATION
	gen occup_orig=c16
	replace occup_orig=. if lstatus!=1
	label var occup_orig "Original Occupational Codes"


** FIRM SIZE
	gen byte firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"

	gen byte firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen whours= c22_phrs
	label var whours "Hours of work in last week"


** WAGES
	gen double wage=c27_pbsc
	replace wage=0 if empstat==2
	replace wage=. if lstatus!=1
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen byte unitwage=1
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
	replace unitwage=. if lstatus!=1


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
	label values empstat_2_year  lblempstat_2_year


** INDUSTRY CLASSIFICATION - SECOND JOB
	gen byte industry_2=j03_okb
	replace industry_2=1 if (j03_okb>=1&j03_okb<=6)
	replace industry_2=2 if (j03_okb>=10&j03_okb<=11) 
	replace industry_2=3 if (j03_okb>=15&j03_okb<=39) 
	replace industry_2=4 if (j03_okb>=40&j03_okb<=41) 
	replace industry_2=5 if (j03_okb==45) 
	replace industry_2=6 if (j03_okb>=50&j03_okb<=55) 
	replace industry_2=7 if (j03_okb>=60&j03_okb<=64) 
	replace industry_2=8 if (j03_okb>=65&j03_okb<=74) 
	replace industry_2=9 if (j03_okb==75) | (j03_okb>=80&j03_okb<=85) 
	replace industry_2=10 if  (j03_okb>=90&j03_okb<=99)
	replace industry_2=10 if industry_2==. & j03_okb!=.
	replace industry_2=. if njobs==0 | njobs==.
	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2 lblindustry_2


** INDUSTRY 1 - SECOND JOB
	gen byte industry1_2=industry_2
	recode industry1_2 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry1_2=. if njobs==0 | njobs==.
	label var industry1_2 "1 digit industry classification (Broad Economic Activities) - Second job"
	la de lblindustry1_2 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1_2 lblindustry1_2


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
	gen industry_orig_2=j03_okb
	replace industry_orig_2=. if njobs==0 | njobs==.
	label var industry_orig_2 "Original Industry Codes - Second job"


** OCCUPATION CLASSIFICATION - SECOND JOB
	gen byte occup_2=floor(j02_otoc/10)
	recode occup_2 0=10
	replace occup_2=99 if c16==9
	replace occup_2=. if njobs==0 | njobs==.
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2


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
	gen byte contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract


** HEALTH INSURANCE
	gen byte healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins


** SOCIAL SECURITY
	gen byte socialsec=.
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


** UNION MEMBERSHIP
	gen byte union=.
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion


/*****************************************************************************************************
*                                                                                                    *
                                   MIGRATION MODULE
*                                                                                                    *
*****************************************************************************************************/


**REGION OF BIRTH JURISDICTION
	gen byte rbirth_juris=.
	label var rbirth_juris "Region of birth jurisdiction"
	la de lblrbirth_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rbirth_juris lblrbirth_juris


**REGION OF BIRTH
	gen rbirth=.
	label var rbirth "Region of Birth"


** REGION OF PREVIOUS RESIDENCE JURISDICTION
	gen byte rprevious_juris=.
	label var rprevious_juris "Region of previous residence jurisdiction"
	la de lblrprevious_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rprevious_juris lblrprevious_juris


**REGION OF PREVIOUS RESIDENCE
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


** DECILES OF PER CAPITA INCOME
	 gen byte pci_d=.
	label var pci_d "Income per capita deciles"


** CONSUMPTION PER CAPITA
	gen double pcc=.
	label var pcc "Monthly consumption per capita"


** DECILES OF PER CAPITA CONSUMPTION
	gen byte pcc_d=.
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


	saveold "`path'\Processed\PHL_2011_I2D2_LFS.dta", replace
	saveold "D:\__CURRENT\PHL_2011_I2D2_LFS.dta", replace

	log close


















******************************  END OF DO-FILE  *****************************************************/
