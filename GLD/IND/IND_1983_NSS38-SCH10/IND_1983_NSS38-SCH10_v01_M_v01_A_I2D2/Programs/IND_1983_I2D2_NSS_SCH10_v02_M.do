/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	India
** COUNTRY ISO CODE	IND
** YEAR	1983
** SURVEY NAME	SOCIO-ECONOMIC SURVEY  JANUARY TO DECEMBER 1983
*	HOUSEHOLD SCHEDULE 10 : EMPLOYMENT AND UNEMPLOYMENT
** SURVEY AGENCY	GOVERNMENT OF INDIA NATIONAL SAMPLE SURVEY ORGANISATION
** SURVEY SOURCE	
** UNIT OF ANALYSIS	INDIVIDUAL
** INPUT DATABASES	
** RESPONSIBLE	El Hadi Caoui
** Created	2013/5/29

** Update 	2020/6 by Hanchen Jiang
** Update 	2021/2 by Mario Gronert

** NUMBER OF HOUSEHOLDS	119868
** NUMBER OF INDIVIDUALS	615661
** EXPANDED POPULATION	675883544
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
	local path "Z:\__I2D2\India\1983\NSS_SCH10"


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	use "`path'\Original\Data\Mahesh Processed\IND_NSS_1983_1983.dta", clear


** COUNTRY
	gen ccode="IND"
	label var ccode "Country code"


** MONTH
	gen byte month=.
	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"


** YEAR
	gen year=1983
	label var year "Year of survey"


** YEAR OF INTERVIEW
	gen int intv_year=.
	label var intv_year "Year of the interview"


** HOUSEHOLD IDENTIFICATION NUMBER
	gen idh=hid
	label var idh "Household id"

	distinct idh
	/*
		   |        Observations
		   |      total   distinct
	-------+----------------------
	   idh |     620144     120718		
	*/
	
** INDIVIDUAL IDENTIFICATION NUMBER
	gen idp=pid
	label var idp "Individual id"
	duplicates drop idp, force

	distinct idp
	/*
		   |        Observations
		   |      total   distinct
	-------+----------------------
	   idp |     620144     620144	
	*/
	
	
** HOUSEHOLD WEIGHTS
	gen wgt=mlt_comb
	label var wgt "Household sampling weight"


** STRATA
	gen strata=stratum
	destring strata, replace
	label var strata "Strata"



** PSU
	gen psu=s_block
	label var psu "Primary sampling units"


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	gen urb=.
	replace urb=1 if URBAN==1
	replace urb=2 if URBAN==0
	label var urb "Urban/Rural"
	la de lblurb 1 "Urban" 2 "Rural"
	label values urb lblurb


** REGIONAL AREA 1 DIGIT ADMN LEVEL
	*fre state
	/*
	Valid   2  Andhra Pradesh       |      41958       6.77       6.77       6.77
			3  Assam                |      23515       3.79       3.79      10.56
			4  Bihar                |      53101       8.56       8.56      19.12
			5  Gujarat              |      26102       4.21       4.21      23.33
			6  Haryana              |      10171       1.64       1.64      24.97
			7  Himachal Pradesh     |      11450       1.85       1.85      26.82
			8  Jammu & Kashmir      |      23783       3.84       3.84      30.65
			9  Karnataka            |      29782       4.80       4.80      35.45
			10 Kerala               |      23304       3.76       3.76      39.21
			11 Madhya Pradesh       |      46190       7.45       7.45      46.66
			12 Maharashtra          |      51955       8.38       8.38      55.04
			13 Manipur              |       9449       1.52       1.52      56.56
			14 Meghalaya            |       6029       0.97       0.97      57.53
			15 Nagaland             |        863       0.14       0.14      57.67
			16 Orissa               |      20010       3.23       3.23      60.90
			17 Punjab               |      23410       3.77       3.77      64.67
			18 Rajasthan            |      28684       4.63       4.63      69.30
			19 Sikkim               |       2118       0.34       0.34      69.64
			20 Tamil Nadu           |      38612       6.23       6.23      75.87
			21 Tripura              |       5144       0.83       0.83      76.70
			22 Uttar Pradesh        |      79186      12.77      12.77      89.47
			23 West Bengal          |      41410       6.68       6.68      96.14
			24 A & N Islands        |       4797       0.77       0.77      96.92
			25 Arunachal Pradesh    |        193       0.03       0.03      96.95
			26 Chandigarh           |        828       0.13       0.13      97.08
			27 Dadra & Nagar Haveli |       1697       0.27       0.27      97.35
			28 Delhi                |       5552       0.90       0.90      98.25
			29 Goa                  |       1443       0.23       0.23      98.48
			30 Lakshadweep          |         75       0.01       0.01      98.50
			31 Mizoram              |       7850       1.27       1.27      99.76
			32 Pondicherry          |       1483       0.24       0.24     100.00
			Total                   |     620144     100.00     100.00           
	*/

	ren state state_50
	
	gen state=.
	replace state=35 /*"A & N Islands"*/		if state_50==24		/*24 A & N Islands*/
	replace state=28 /*"Andhra Pradesh"*/		if state_50==2		/*2  Andhra Pradesh*/
	replace state=12 /*"Arunachal Pradesh"*/	if state_50==25		/*25 Arunachal Pradesh*/		
	replace state=18 /*"Assam"*/				if state_50==3		/*3  Assam*/
	replace state=10 /*"Bihar"*/				if state_50==4		/*4  Bihar*/
	replace state=4  /*"Chandigarh"*/			if state_50==26		/*26 Chandigarh*/
	/*replace state=22 /*"Chattisgarh"*/		??? non-exist ???		Note: The state was formed on 1 November 2000*/
	replace state=26 /*"D & N Haveli"*/			if state_50==27		/*27 Dadra & Nagar Haveli*/
	/*replace state=25 /*"Daman & Diu"*/		??? non-exist ???		30 Daman & Diu*/
	replace state=7  /*"Delhi"*/				if state_50==28		/*28 Delhi*/
	replace state=30 /*"Goa"*/					if state_50==29		/*29  Goa*/
	replace state=24 /*"Gujarat"*/				if state_50==5 		/*5   Gujarat*/
	replace state=6  /*"Haryana"*/				if state_50==6		/*6  Haryana*/
	replace state=2  /*"Himachal Pradesh"*/		if state_50==7		/*7  Himachal Pradesh*/
	replace state=1  /*"Jammu & Kashmir"*/		if state_50==8 		/*8 Jammu & Kashmir*/
	/*replace state=20 /*"Jharkhand"*/			??? non-exist ???		Note: Formation	15 November 2000*/
	replace state=29 /*"Karnataka"*/ 			if state_50==9		/*9 Karnataka*/
	replace state=32 /*"Kerala"*/				if state_50==10		/*10 Kerala*/
	replace state=31 /*"Lakshadweep"*/			if state_50==30		/*30 Lakshdweep*/
	replace state=23 /*"Madhya Pradesh"*/		if state_50==11		/*11 Madhya Pradesh*/
	replace state=27 /*"Maharastra"*/			if state_50==12		/*12 Maharashtra*/
	replace state=14 /*"Manipur"*/				if state_50==13		/*13 Manipur*/
	replace state=17 /*"Meghalaya"*/			if state_50==14		/*14 Meghalaya*/
	replace state=15 /*"Mizoram"*/				if state_50==31		/*31 Mizoram*/
	replace state=13 /*"Nagaland"*/				if state_50==15		/*15 Nagaland*/
	replace state=21 /*"Orissa"*/				if state_50==16		/*16 Orissa*/
	replace state=34 /*"Pondicherry"*/			if state_50==32		/*32 Pondicherry*/
	replace state=3  /*"Punjab"*/				if state_50==17		/*17 Punjab*/
	replace state=8  /*"Rajasthan"*/			if state_50==18		/*18 Rajasthan*/
	replace state=11 /*"Sikkim"*/				if state_50==19		/*19 Sikkim*/
	replace state=33 /*"Tamil Nadu"*/			if state_50==20		/*20 Tamil Nadu*/
	replace state=16 /*"Tripura"*/				if state_50==21		/*21 Tripura*/
	replace state=9  /*"Uttar Pradesh"*/		if state_50==22		/*22 Uttar Pradesh*/
	/*replace state=5  /*"Uttaranchal"*/		??? non-exist ??? 	Note: Statehood	9 November 2000*/
	replace state=19 /*"West Bengal"*/			if state_50==23		/*23 West Bengal*/
	
	*fre state
	
	lab var state "State"
	
	gen reg02=state
	label var reg02 "Region at 1 digit (ADMN1)"

	label define reg02 1 "Jammu & Kashmir", modify
	label define reg02 2 "Himachal Pradesh", modify
	label define reg02 3 "Punjab", modify
	label define reg02 4 "Chandigarh", modify
	label define reg02 5 "Uttaranchal", modify
	label define reg02 6 "Haryana", modify
	label define reg02 7 "Delhi", modify
	label define reg02 8 "Rajasthan", modify
	label define reg02 9 "Uttar Pradesh", modify
	label define reg02 10 "Bihar", modify
	label define reg02 11 "Sikkim", modify
	label define reg02 12 "Arunachal Pradesh", modify
	label define reg02 13 "Nagaland", modify
	label define reg02 14 "Manipur", modify
	label define reg02 15 "Mizoram", modify
	label define reg02 16 "Tripura", modify
	label define reg02 17 "Meghalaya", modify
	label define reg02 18 "Assam", modify
	label define reg02 19 "West Bengal", modify
	label define reg02 20 "Jharkhand", modify
	label define reg02 21 "Orissa", modify
	label define reg02 22 "Chattisgarh", modify
	label define reg02 23 "Madhya Pradesh", modify
	label define reg02 24 "Gujarat", modify
	label define reg02 25 "Daman & Diu", modify
	label define reg02 26 "D & N Haveli", modify
	label define reg02 27 "Maharastra", modify
	label define reg02 28 "Andhra Pradesh", modify
	label define reg02 29 "Karnataka", modify
	label define reg02 30 "Goa", modify
	label define reg02 31 "Lakshadweep", modify
	label define reg02 32 "Kerala", modify
	label define reg02 33 "Tamil Nadu", modify
	label define reg02 34 "Pondicherry", modify
	label define reg02 35 "A & N Islands", modify
	
	label values reg02 reg02
	label values state reg02

	
**REGIONAL AREAS
	gen reg01=reg02 // States may function as macro area
	label var reg02 "Macro regional areas"
	label values reg01 reg02

** REGIONAL AREA 2 DIGITS ADM LEVEL (ADMN2)
	gen reg03=region
	label var reg03 "NSS Region (ADMN2)"


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

** GENDER
	gen gender=sex
	label var gender "Gender"
	la de lblgender 1 "Male" 2 "Female"
	label values gender lblgender


** AGE
	replace age=98 if age>=98 & age!=.
	label var age "Individual age"
	
** HOUSEHOLD SIZE

	bys idh: egen hhsize=count(prsn_no) 
	label var hhsize "Household size"

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD

	bys idh: gen one=1 if relation==1 
	bys idh: egen temp=count(one) 
	tab temp
	
	* 4483 observations (0.72%) have either no head or more than one.Force it by making 
	* a) eldest male head
	* b) eldest female if no male
	* c) lowest running ID to break ties
	* the head. Other heads sent to value 5, coded as "Other relatives"
	
	bys idh relation: egen istheremale = total(sex==1)
	bys idh relation: egen maxagemale = max(cond(sex==1,age,.))
	bys idh relation: egen maxagefemale = max(cond(sex==2,age,.))
	bys idh relation: egen minid = min(prsn_no)
	bys idh relation: egen howmany = total(age==maxagefemale)
	
	replace relation = 1 if temp==0 & istheremale>=1 & age==maxagemale & minid==prsn_no
	replace relation = 1 if temp==0 & istheremale==0 & age==maxagefemale & minid==prsn_no
	
	drop istheremale maxage* minid howmany one temp
	bys idh: gen one=1 if relation==1 
	bys idh: egen temp=count(one) 
	tab temp
	
	bys idh relation: egen istheremale = total(sex==1)
	bys idh relation: egen maxagemale = max(cond(sex==1,age,.))
	bys idh relation: egen maxagefemale = max(cond(sex==2,age,.))
	bys idh relation: egen minid = min(prsn_no)
	bys idh relation: egen howmany = total(age==maxagefemale)
	
	replace relation = cond(temp>1 & relation ==1 & istheremale>=1 & (age!=maxagemale|sex==2),5,cond(age!=maxagefemale & howmany == 1 & temp>1 & relation ==1 &istheremale==0,5,cond(minid!=prsn_no & howmany >1 & temp>1 & relation ==1 & istheremale==0,5,relation)))

	drop one temp
	bys idh: gen one=1 if relation==1 
	bys idh: egen temp=count(one) 
	tab temp
	* 34 cases left. Don't know what to do with them.
	
	gen head=relation
	recode head (3 5=3)(7=4)(4 6 8=5) (9=6) (0=.)
	label var head "Relationship to the head of household"
	la de lblhead  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values head  lblhead

** SOCIAL GROUP

/*
there is a variable for caste too, named "CASTE" in the original file
*/
	gen soc=RELIGION
* CASTE
	label var soc "Social group"
	la de lblsoc 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 5 "Jainism" 6 "Buddhism" 7 "Zoroastrianism" 9 "Others"
	label values soc  lblsoc


** MARITAL STATUS
	gen marital=.
	replace marital=1 if MARSTAT==2
	replace marital=2 if MARSTAT==1
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen ed_mod_age=0
	label var ed_mod_age "Education module application age"


** CURRENTLY AT SCHOOL
	gen atschool=.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen literacy=.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen educy=CONEDYEARS
	label var educy "Years of education"


** EDUCATIONAL LEVEL 1
	gen edulevel1=.
	replace edulevel1=1 if EDLEVEL_DAVID==0
	replace edulevel1=2 if EDLEVEL_DAVID==1

/*
secondary incomplete is not availabel
*/
	replace edulevel1=3 if EDLEVEL_DAVID==2
	replace edulevel1=5 if EDLEVEL_DAVID==3
	replace edulevel1=7 if EDLEVEL_DAVID==4
	label var edulevel1 "Level of education 1"
	la de lbledulevel1 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete" 8 "Other" 9 "Unstated"
	label values edulevel1 lbledulevel1


**EDUCATION LEVEL 2
	gen byte edulevel2=edulevel1
	recode edulevel2 4=3 5=4 6 7=5 8 9=.
	replace edulevel2=. if age<ed_mod_age & age!=.
	label var edulevel2 "Level of education 2"
	la de lbledulevel2 1 "No education" 2 "Primary incomplete"  3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
	label values edulevel2 lbledulevel2


** EDUCATION LEVEL 3
	gen byte edulevel3=edulevel1
	recode edulevel3 2 3=2 4 5=3 6 7=4 8 9=.
	label var edulevel3 "Level of education 3"
	la de lbledulevel3 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values edulevel3 lbledulevel3


** EVER ATTENDED SCHOOL
	gen byte everattend=.
	replace everattend=1 if edulevel3>=2 & edulevel3<=4
	replace everattend=0 if edulevel3==1
	replace everattend=1 if atschool==1
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend

	replace everattend=0 if educy==0 
	
	replace educy = 1 if edulevel1 == 2 & educy < 1
	replace educy = 5 if edulevel1 == 3 & educy < 5
	replace educy = 12 if edulevel1 == 5 & educy < 12
	replace educy = 13 if edulevel1 == 7 & educy < 13
	
	local ed_var "everattend atschool literacy educy edulevel1 edulevel2 edulevel3"
	foreach v in `ed_var'{
	replace `v'=. if( age<ed_mod_age & age!=.)
	}


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen lb_mod_age=0
	label var lb_mod_age "Labor module application age"

	gen lstatus=EMP_STAT
	recode lstatus (4=3)
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** LABOR STATUS LAST YEAR
	gen byte lstatus_year=.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Not employed" 
	label values lstatus_year lbllstatus_year


** EMPLOYMENT STATUS
	gen empstat=EMPTYPE_MAIN
	recode empstat (3=4) (4=2)
	replace empstat=. if lstatus==2 | lstatus==3
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
	gen njobs= .
	replace njobs = 1 if SECONDJOB == 0
	replace njobs = 2 if SECONDJOB == 1
	label var njobs "Number of additional jobs"


** NUMBER OF ADDITIONAL JOBS LAST YEAR
	gen byte njobs_year=.
	replace njobs_year=. if lstatus_year!=1
	label var njobs_year "Number of additional jobs during last year"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen ocusec=.
	replace ocusec=4 if PUBLIC==1
	replace ocusec=1 if PUBLIC==0
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public Sector, Central Government, Army, NGO" 2 "Private" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
	replace ocusec=. if lstatus==2 | lstatus==3


** REASONS NOT IN THE LABOR FORCE
	gen nlfreason=.
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen unempldur_l=dur_unemp1
	recode unempldur_l 1 2=0 3=1 4=2 5=3 7=6
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen unempldur_u=dur_unemp1
	recode unempldur_u 1 2=0 3=1 4=2 5=3 7=.
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	*gen industry=sector_main 
	destring nic_wkl, generate(nic_wkl_num) force
	
	gen str5 nic_wkl_2digit_str = substr(nic_wkl,1,2)
	destring nic_wkl_2digit_str, generate(nic_wkl_2digit_num) force
	replace nic_wkl_2digit_num=. if nic_wkl_2digit_num<0
	
	gen industry=.
	replace industry=1 if nic_wkl_2digit_num>=00 & nic_wkl_2digit_num<=09 
	replace industry=2 if nic_wkl_2digit_num>=10 & nic_wkl_2digit_num<=19
	replace industry=3 if nic_wkl_2digit_num>=20 & nic_wkl_2digit_num<=39
	replace industry=4 if nic_wkl_2digit_num>=40 & nic_wkl_2digit_num<=47 
	replace industry=5 if nic_wkl_2digit_num>=50 & nic_wkl_2digit_num<=59 
	replace industry=6 if nic_wkl_2digit_num>=60 & nic_wkl_2digit_num<=69
	replace industry=7 if nic_wkl_2digit_num>=70 & nic_wkl_2digit_num<=79
	replace industry=8 if nic_wkl_2digit_num>=80 & nic_wkl_2digit_num<=89
	replace industry=9 if  nic_wkl_2digit_num==90
	replace industry=10 if nic_wkl_2digit_num>=91 & nic_wkl_2digit_num<=99
	replace industry=10 if industry==. & nic_wkl_2digit_num!=.
	*fre industry


	replace industry=. if lstatus==2 | lstatus==3
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Community and family oriented services" 10 "Other services, Unspecified"
	label values industry lblindustry

	clonevar IND_1digit = industry
	
	clonevar IND_2digit = nic_wkl_2digit_num
		replace IND_2digit=. if lstatus!=1
		
** INDUSTRY 1
	gen byte industry1=industry
	recode industry1 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry1=. if lstatus!=1
	label var industry1 "1 digit industry classification (Broad Economic Activities)"
	la de lblindustry1 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1 lblindustry1

	clonevar IND = industry1

**SURVEY SPECIFIC INDUSTRY CLASSIFICATION
	gen industry_orig=nic_wkl_num
	replace industry_orig=. if lstatus!=1
	label var industry_orig "Original Industry Codes - NIC 1970"


** OCCUPATION CLASSIFICATIONfr
	gen occup=OCC_MAIN
	label var occup "1 digit occupational classification"
	label define lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
	replace occup=. if lstatus!=1
	
	clonevar IND_full = industry_orig


** SURVEY SPECIFIC OCCUPATION CLASSIFICATION
	gen  occup_orig=nco_wkl
	replace occup_orig=. if lstatus!=1
	label var occup_orig "Original Occupational Codes - NCO 1968"
	
	clonevar occup_3digit = occup_orig

** FIRM SIZE
	gen firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"

	gen firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"



** HOURS WORKED LAST WEEK
	gen whours=HOURWRKMAIN_week
	replace whours=. if lstatus!=1
	label var whours "Hours of work in last week"
	# delimit cr


** WAGES
	gen wage=income_main_wk
	replace wage=. if lstatus==2 | lstatus==3
	replace wage=0 if empstat==2
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen unitwage=2 if lstatus==1 
	recode unitwage (0=.)
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly"
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
				label values empstat_2 lblempstat_2


			** INDUSTRY CLASSIFICATION - SECOND JOB
				gen byte industry_2=.
				replace industry_2=. if njobs==0 | njobs==.
				label var industry_2 "1 digit industry classification - second job"
				la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
				label values industry_2  lblindustry_2


			** INDUSTRY 1 - SECOND JOB
				gen byte industry1_2=industry_2
				recode industry1_2 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
				replace industry1_2=. if njobs==0 | njobs==.
				label var industry1_2 "1 digit industry classification (Broad Economic Activities) - Second job"
				la de lblindustry1_2 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
				label values industry1_2 lblindustry1_2


			**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
				gen industry_orig_2=.
				replace industry_orig_2=. if njobs==0 | njobs==.
				label var industry_orig_2 "Original Industry Codes - Second job"
				la de lblindustry_orig_2 1""
				label values industry_orig_2 lblindustry_orig_2


			** OCCUPATION CLASSIFICATION - SECOND JOB
				gen byte occup_2=.
				replace occup_2=. if njobs==0 | njobs==.
				label var occup_2 "1 digit occupational classification - second job"
				la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
				label values occup_2 lbloccup_2


			** WAGES - SECOND JOB
			* Second job only as PPP05, not original. Best option is to use the link between original and PPP05 in main job to bring it to same level. In addition second is only monthly. Divide by 4.3
			gen  ppp_wage_bridge = INCOME_MAIN_week_PPP05/income_main_wk
			gen double wage_2= (INCOME_SEC_mon_PPP05/4.3)/ppp_wage_bridge
			replace wage_2=. if njobs==1 | njobs==.
			label var wage_2 "Last wage payment - Second job"
			* Note, disparity that second job is more lucrative is present in "original data"
			* summarize INCOME_MAIN_mon_PPP05 INCOME_SEC_mon_PPP05


			** WAGES TIME UNIT - SECOND JOB
				gen byte unitwage_2=2
				replace unitwage_2=. if njobs==0 | njobs==.
				label var unitwage_2 "Last wages time unit - Second job"
				la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
				label values unitwage_2 lblunitwage_2


** CONTRACT
	gen contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
	replace contract=. if lstatus==2 | lstatus==3


** HEALTH INSURANCE
	gen healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins


** SOCIAL SECURITY
	gen socialsec=.
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


** UNION MEMBERSHIP
	gen union=.
	label var union "Union membership"
	recode union (2=0)
	replace union=. if lstatus!=1
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion

	local lb_var "lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage  empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2  occup_2 wage_2 unitwage_2 contract healthins socialsec union"
	foreach v in `lb_var'{
	di "check `v' only for age>=lb_mod_age"

	replace `v'=. if( age<lb_mod_age & age!=.)
	}


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
	gen  rbirth=.
	label var rbirth "Region of Birth"


** REGION OF PREVIOUS RESIDENCE JURISDICTION
	gen byte rprevious_juris=.
	label var rprevious_juris "Region of previous residence jurisdiction"
	la de lblrprevious_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rprevious_juris lblrprevious_juris


**REGION OF PREVIOUS RESIDENCE
* last_resid, which was used in previous iterations maps to B42_q3, which is an idiosyncratic on and not  reg02. That was covered in B42_q5, which I cannot find in this source file.
	gen  rprevious=. 
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
	gen pci=.
	label var pci "Monthly income per capita"


** DECILES OF PER CAPITA INCOME
	gen pci_d=.
	label var pci_d "Income per capita deciles"



** CONSUMPTION PER CAPITA
	gen pcc=  TOTCONS_LCU05 / [HHSIZE*12]
	label var pcc "Monthly consumption per capita"


** DECILES OF PER CAPITA CONSUMPTION
	xtile pcc_d=pcc [w=wgt], nq(10) 
	label var pcc_d "Consumption per capita deciles"


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL FIXES
*                                                                                                    *
*****************************************************************************************************/

	qui su wage
	replace wage=0 if empstat==2 & r(N)!=0
	replace ownhouse=. if head==6

/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL
	keep ccode year intv_year month idh idp wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     cellphone computer internet hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage       ///
	empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2  occup_2 wage_2 unitwage_2 ///
	     contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d	///
		 state IND IND_1digit IND_2digit IND_full occup_3digit


** ORDER VARIABLES
	order ccode year intv_year month idh idp wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     cellphone computer internet hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage       ///
	empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
	     contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d	///
		 state IND IND_1digit IND_2digit IND_full occup_3digit


	compress


** DELETE MISSING VARIABLES
	local keep ""
	qui levelsof ccode, local(cty)
	foreach var of varlist urb - /*!!! pcc_d -> adjust to our case*/ occup_3digit {
	qui sum `var'
	scalar sclrc = r(mean)
	if sclrc==. {
	     display as txt "Variable " as result "`var'" as txt " for ccode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
	}
	else {
	     local keep `keep' `var'
	}
	}
	keep ccode year month intv_year idh idp wgt strata psu `keep'

	save "`path'\Processed\IND_1983_I2D2_NSS-SCH10_v01_M_v02_A.dta", replace
	*save "`path'\Processed\IND_1983_I2D2_NSS_SCH10.dta", replace
	*log close

******************************  END OF DO-FILE  *****************************************************/
