/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	TURKEY
** COUNTRY ISO CODE	TUR
** YEAR	2006
** SURVEY NAME	HOUSEHOLD LABOUR FORCE SURVEY
** SURVEY AGENCY	Turkish Statistical Institute (TUIK)
** SURVEY SOURCE	Turkish Statistical Institute (TUIK)
** UNIT OF ANALYSIS	
** INPUT DATABASES	Z:\GLD-Harmonization\582018_AQ\TUR\TUR_2006_HLFS\TUR_2006_HLFS_v01_M\Data\Stata\2006YIL.dta
** RESPONSIBLE	Alexandra Quiñones 
** Created	9/28/2011
** Modified	8/02/2021
** NUMBER OF HOUSEHOLDS	129,527 
** NUMBER OF INDIVIDUALS	497,137
** EXPANDED POPULATION	68065760  
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
	set mem 500m


** DIRECTORY

	local 	drive 	`"Z"'		// set this to where you mapped the GLD drive on your work computer
	local 	cty3 	"TUR" 	// set this to the three letter country/economy abbreviation
	local 	usr		`"582018_AQ"' // set this to whatever Mario named your folder
	local 	surv_yr `"2006"'	// set this to the survey year 
	

** LOG FILE

** RUN SETTINGS
	local 	cb_pause = 1	// 1 to pause+edit the exported codebook for harmonizing varnames, else 0
	local 	year 	"`drive':\GLD-Harmonization\\`usr'\\`cty3'\\`cty3'_`surv_yr'_HLFS" // top data folder
	local 	main	"`year'\\`cty3'_2006_HLFS_v01_M"
	local 	stata	"`main'\data\stata"
	local 	gld 	"`year'\\`cty3'_2006_HLFS_v01_M_v01_A_GLD"
	local 	i2d2	"`year'\\`cty3'_2006_HLFS_v01_M_v01_A_I2D2"
	local 	code 	"`i2d2'\Programs"
	local 	id_data	"`i2d2'\Data\Harmonized"


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
use "`stata'\2006YIL.dta"
rename *, lower


** COUNTRY
	gen ccode="TUR"
	label var ccode "Country code"


** YEAR
	gen year=2006
	label var year "Year of survey"


** MONTH
	gen month=.

	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"


** HOUSEHOLD IDENTIFICATION NUMBER
	tostring formno, replace
	gen formno_str=substr("0000",1,5 - length(formno))+formno
	gen idh=formno_str
	label var idh "Household id"
*drop if s1=.

** INDIVIDUAL IDENTIFICATION NUMBER
	tostring s1, replace
	gen idp=idh+s1
	label var idp "Individual id"


** HOUSEHOLD WEIGHTS
	gen wgt=faktor
	label var wgt "Household sampling weight"


** STRATA
	gen strata=.
	label var strata "Strata"


** PSU
	gen psu=.
	label var psu "Primary sampling units"


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	gen urb=.
	replace urb=1 if kirkent=="KENT"
	replace urb=2  if kirkent=="KIR"
	label var urb "Urban/Rural"
	la de lblurb 1 "Urban" 2 "Rural"
	label values urb lblurb


**REGIONAL AREAS
	gen reg01=nuts1
	label var reg01 "Macro regional areas"
	label values reg01 Region_NUTS1


** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen reg02=.
	label var reg02 "Region at 1 digit (ADMN1)"
	label values reg02 Region_NUTS1


** REGIONAL AREA 2 DIGITS ADM LEVEL (ADMN2)
	gen reg03=.
	label var reg03 "Region at 2 digits (ADMN2)"


** REGIONAL AREA 3 DIGITS ADM LEVEL (ADMN2)
	gen reg04=.
	label var reg04 "Region at 3 digits (ADMN3)"


** HOUSE OWNERSHIP
	gen ownhouse=.
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	gen water=.
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION
	gen electricity=.
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity


** TOILET PUBLIC CONNECTION
	gen toilet=.
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet


** LAND PHONE
	gen landphone=.
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone


** CEL PHONE
	gen cellphone=.
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone


** COMPUTER
	gen computer=.
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer


** INTERNET
	gen internet=.
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
	gen a=1 if s11<=7
	bys idh: egen hhsize=count(a)
	label var hhsize "Household size"


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen head=s11
	recode head (4/7=5) (8=6)
	replace hhsize=. if head==6
	replace ownhouse=. if head==6
	gen x=1 if head==1
	egen y=sum(x), by(idh)
	drop if y!=1
	drop x y
	label var head "Relationship to the head of household"
	la de lblhead  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values head  lblhead


** GENDER
	gen gender=s3
	label var gender "Gender"
	la de lblgender 1 "Male" 2 "Female"
	label values gender lblgender


** AGE
	gen age=.
	replace age=7 if s6==1
	replace age=17 if s6==2
	replace age=22 if s6==3
	replace age=27 if s6==4
	replace age=32 if s6==5
	replace age=37 if s6==6
	replace age=42 if s6==7
	replace age=47 if s6==8
	replace age=52 if s6==9
	replace age=57 if s6==10
	replace age=62 if s6==11
	replace age=81 if s6==12
	label var age "Individual age"


** SOCIAL GROUP
	gen soc=.
	label var soc "Social group"
	*la de lblsoc 1 ""
	label values soc lblsoc


** MARITAL STATUS
	gen marital=.
	replace marital=1 if s19==2
	replace marital=4 if s19==4|s19==5
	replace marital=5 if s19==6
	replace marital=3 if s19==3
	replace marital=2 if s19==1
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen ed_mod_age=6
	label var ed_mod_age "Education module application age"


** EVER ATTENDED SCHOOL
	gen everattend=.
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend


** CURRENTLY AT SCHOOL
	gen atschool=s17
	recode atschool (0=.) (2=0)
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen literacy=s13
	recode literacy (2=0)
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen educy=.
	replace educy=0 if s14==0
	replace educy=4 if s14==1
	replace educy=8 if s14==2
	replace educy=12 if s14==3
	replace educy=12 if s14==4
	replace educy=13 if s14==5
	replace educy=19 if s14==6
	label var educy "Years of education"



** EDUCATIONAL LEVEL 1
	gen edulevel1=.
	label var edulevel1 "Level of education 1"
	la de lbledulevel1 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete" 8 "Other" 9 "Unstated"
	label values edulevel1 lbledulevel1


** EDUCATION LEVEL 2
	gen edulevel2=.
	label var edulevel2 "Level of education 2"
	la de lbledulevel2 1 "No education" 2 "Primary incomplete"  3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
	label values edulevel2 lbledulevel2


** EDUCATION LEVEL 3
	gen edulevel3= s14
	recode edulevel3 (0=1) (3 4 5=3) (6=4)
	label var edulevel3 "Level of education 3"
	la de lbledulevel3 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values edulevel3 lbledulevel3
	 
	 

/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen lb_mod_age=15
	label var lb_mod_age "Labor module application age"

	gen lstatus=durum
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** EMPLOYMENT STATUS
	gen empstat=.
	replace empstat=1 if s39==1 |s39==2
	replace empstat=2 if s39==5
	replace empstat=3 if s39==3
	replace empstat=4 if s39==4
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** NUMBER OF ADDITIONAL JOBS
	gen njobs=.
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec


** REASONS NOT IN THE LABOR FORCE
	gen nlfreason=.
	replace nlfreason=1 if s94==5
	replace nlfreason=2 if s94==6|s94>=8 & s94<=10
	replace nlfreason=3 if s94==7
	replace nlfreason=4 if s94==12
	replace nlfreason=5 if s94>=1 & s94<=4
	recode nlfreason (.=5) if s94==11 |s94>=13 & s94<=15
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
	replace nlfreason=. if lstatus==2


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen unempldur_l=.
	label var unempldur_l "Unemployment duration (year) lower bracket"

	gen unempldur_u=.
	label var unempldur_u "Unemployment duration (year) upper bracket"


** INDUSTRY CLASSIFICATION
	gen industry=s33kod

/*
Public Administration is not identified
*/
	recode industry 9=10
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
	replace industry=. if lstatus!=1 | age<lb_mod_age


** INDUSTRY 1
	gen byte industry1=industry
	recode industry1 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry1=. if lstatus!=1
	label var industry1 "1 digit industry classification (Broad Economic Activities)"
	la de lblindustry1 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1 lblindustry1


** OCCUPATION CLASSIFICATION
	gen occup=s38kod
	label var occup "1 digit occupational classification"
	label define occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup


** FIRM SIZE
	gen firmsize_l=.
	replace firmsize_l=1 if s37a==1
	replace firmsize_l=10 if s37a==2
	replace firmsize_l=25 if s37a==3
	replace firmsize_l=50 if s37a==4
	replace firmsize_l=250 if s37a==5
	replace firmsize_l=500 if s37a==6
	label var firmsize_l "Firm size (lower bracket)"

	gen firmsize_u=.
	replace firmsize_u=9 if s37a==1
	replace firmsize_u=24 if s37a==2
	replace firmsize_u=49 if s37a==3
	replace firmsize_u=249 if s37a==4
	replace firmsize_u=499 if s37a==5
	replace firmsize_u=. if  s37a==6
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen whours=s61a
	label var whours "Hours of work in last week"
	replace whours=. if lstatus!=1

** WAGES
	gen wage=s78
	label var wage "Last wage payment"
	replace wage=. if lstatus!=1

** WAGES TIME UNIT
	gen unitwage=5
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly"
	label values unitwage lblunitwage
	replace unitwage=. if lstatus!=1

** CONTRACT
	gen contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract


** HEALTH INSURANCE
	gen healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins


** SOCIAL SECURITY
	gen socialsec=.
	replace socialsec=1 if s43==1
	replace socialsec=0 if s43==2
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


** UNION MEMBERSHIP
	gen union=.
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion


/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** INCOME PER CAPITA
	gen pci=.
	label var pci "Monthly income per capita"


** DECILES OF PER CAPITA INCOME
	gen pci_d=.
	label var pci_d "Income per capita deciles"


** CONSUMPTION PER CAPITA
	gen pcc=.
	label var pcc "Monthly consumption per capita"


** DECILES OF PER CAPITA CONSUMPTION
	gen pcc_d=.
	label var pcc_d "Consumption per capita deciles"


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL
	keep ccode year month idh idp wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     cellphone computer internet hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus empstat njobs ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 occup firmsize_l firmsize_u whours wage unitwage contract      ///
	     healthins socialsec union pci pci_d pcc pcc_d


** ORDER VARIABLES
	order ccode year month idh idp wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     cellphone computer internet hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus empstat njobs ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 occup firmsize_l firmsize_u whours wage unitwage contract      ///
	     healthins socialsec union pci pci_d pcc pcc_d

	compress


** DELETE MISSING VARIABLES
	local keep ""
	qui levelsof ccode, local(cty)
	foreach var of varlist urb - pcc_d {
	qui sum `var'
	scalar sclrc = r(mean)
	if sclrc==. {
	     display as txt "Variable " as result "`var'" as txt " for country " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
	}
	else {
	     local keep `keep' `var'
	}
	}
	keep ccode year idh idp wgt  strata psu `keep'


 save "`id_data'\TUR_2006_LFS_v01_M_v01_A_I2D2.dta", replace



















******************************  END OF DO-FILE  *****************************************************/
