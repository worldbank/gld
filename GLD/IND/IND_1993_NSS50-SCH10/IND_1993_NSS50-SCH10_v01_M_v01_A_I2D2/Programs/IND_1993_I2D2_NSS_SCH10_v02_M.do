/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	India
** COUNTRY ISO CODE	IND
** YEAR	1993
** SURVEY NAME	SOCIO-ECONOMIC SURVEY  FIFTIETH ROUND JULY 1993-JUNE 1994
*	HOUSEHOLD SCHEDULE 10 : EMPLOYMENT AND UNEMPLOYMENT
** SURVEY AGENCY	GOVERNMENT OF INDIA NATIONAL SAMPLE SURVEY ORGANISATION
** SURVEY SOURCE	
** UNIT OF ANALYSIS	
** INPUT DATABASES	C:\_I2D2\India\1993\Original\Data\DataOrig.dta
*	C:\_I2D2\India\1993\Processed\IND_NSS_1993_1994.dta
** RESPONSIBLE	DANIEL PALAZOV\ EL Hadi Caoui
** Created	10/13/2011
** Modified	"5/28/2013"

** Update 	5/2020 by Hanchen Jiang
** Update	2/2021 by Mario Gronert

** NUMBER OF HOUSEHOLDS	115,409       
** NUMBER OF INDIVIDUALS	564,740
** EXPANDED POPULATION	778,297,683
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
	local path "Z:\__I2D2\India\1993\NSS_SCH10"


** LOG FILE
	*log using "`path'\Processed\IND_1993_I2D2_NSS_SCH10.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	use "`path'\Original\Data\DataOrig.dta", clear
	do "`path'\Other\rename.do"


** COUNTRY
	gen ccode="IND"
	label var ccode "Country code"


** YEAR
	gen year=1993
	label var year "Year of survey"


** MONTH
	gen byte month=.
	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"

* YEAR OF INTERVIEW
	gen int intv_year=.
	label var intv_year "Year of the interview"

** HOUSEHOLD IDENTIFICATION NUMBER
	gen idh=HID
	label var idh "Household id"

	distinct idh
	/*
	       |        Observations
		   |      total   distinct
	-------+----------------------
	   idh |     564740     115409
	*/
	
** INDIVIDUAL IDENTIFICATION NUMBER
	gen idp=pid
	label var idp "Individual id"

	distinct idp
	
	/*
		   |        Observations
		   |      total   distinct
	-------+----------------------
	   idp |     564740     564740
	*/
	
** HOUSEHOLD WEIGHTS
	gen wgt=mult
	label var wgt "Household sampling weight"

** STRATA
	gen strata=stratum
	destring strata, replace
	label var strata "Strata"

** PSU
	gen psu=fsu
	label var psu "Primary sampling units"


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	gen urb=.
	replace urb=1 if rural==2
	replace urb=2 if rural==1
	label var urb "Urban/Rural"
	la de lblurb 1 "Urban" 2 "Rural"
	label values urb lblurb


** REGIONAL AREA 1 DIGIT ADMN LEVEL
	ren state state_50
	
	gen state=.
	replace state=35 /*"A & N Islands"*/		if state_50==27		/*27 A & N Islands*/
	replace state=28 /*"Andhra Pradesh"*/		if state_50==2		/*2  Andhra Pradesh*/
	replace state=12 /*"Arunachal Pradesh"*/	if state_50==3		/*3  Arunachal Pradesh*/		
	replace state=18 /*"Assam"*/				if state_50==4		/*4  Assam*/
	replace state=10 /*"Bihar"*/				if state_50==5		/*5  Bihar*/
	replace state=4  /*"Chandigarh"*/			if state_50==28		/*28 Chandigarh*/
	replace state=22 /*"Chattisgarh"*/		 	if state_50==35		/*??? non-exist ???		Note: The state was formed on 1 November 2000*/
	replace state=26 /*"D & N Haveli"*/			if state_50==29		/*29 Dadra & Nagar Haveli*/
	replace state=25 /*"Daman & Diu"*/			if state_50==30		/*30 Daman & Diu*/
	replace state=7  /*"Delhi"*/				if state_50==31		/*31 Delhi*/
	replace state=30 /*"Goa"*/					if state_50==6		/*6  Goa*/
	replace state=24 /*"Gujarat"*/				if state_50==7		/*7  Gujarat*/
	replace state=6  /*"Haryana"*/				if state_50==8		/*8  Haryana*/
	replace state=2  /*"Himachal Pradesh"*/		if state_50==9		/*9  Himachal Pradesh*/
	replace state=1  /*"Jammu & Kashmir"*/		if state_50==10		/*10 Jammu & Kashmir*/
	replace state=20 /*"Jharkhand"*/			if state_50==34		/*??? non-exist ???		Note: Formation	15 November 2000*/
	replace state=29 /*"Karnataka"*/ 			if state_50==11		/*11 Karnataka*/
	replace state=32 /*"Kerala"*/				if state_50==12		/*12 Kerala*/
	replace state=31 /*"Lakshadweep"*/			if state_50==32		/*32 Lakshdweep*/
	replace state=23 /*"Madhya Pradesh"*/		if state_50==13		/*13 Madhya Pradesh*/
	replace state=27 /*"Maharastra"*/			if state_50==14		/*14 Maharashtra*/
	replace state=14 /*"Manipur"*/				if state_50==15		/*15 Manipur*/
	replace state=17 /*"Meghalaya"*/			if state_50==16		/*16 Meghalaya*/
	replace state=15 /*"Mizoram"*/				if state_50==17		/*17 Mizoram*/
	replace state=13 /*"Nagaland"*/				if state_50==18		/*18 Nagaland*/
	replace state=21 /*"Orissa"*/				if state_50==19		/*19 Orissa*/
	replace state=34 /*"Pondicherry"*/			if state_50==33		/*33 Pondicherry*/
	replace state=3  /*"Punjab"*/				if state_50==20		/*20 Punjab*/
	replace state=8  /*"Rajasthan"*/			if state_50==21		/*21 Rajasthan*/
	replace state=11 /*"Sikkim"*/				if state_50==22		/*22 Sikkim*/
	replace state=33 /*"Tamil Nadu"*/			if state_50==23		/*23 Tamil Nadu*/
	replace state=16 /*"Tripura"*/				if state_50==24		/*24 Tripura*/
	replace state=9  /*"Uttar Pradesh"*/		if state_50==25		/*25 Uttar Pradesh*/
	replace state=5  /*"Uttaranchal"*/			if state_50==36		/*??? non-exist ??? 	Note: Statehood	9 November 2000*/
	replace state=19 /*"West Bengal"*/			if state_50==26		/*26 West Bengal*/

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
	gen reg01=state
	label var reg01 "Macro regional areas"
	label values reg01 reg02
	
** REGIONAL AREA 2 DIGITS ADM LEVEL (ADMN2)
	gen reg03=region
	label var reg03 "NSS region (can be used to update states) (ADMN2)"


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
	* hhsize already created in rename.do
	label var hhsize "Household size"


** GENDER
	gen gender=sex
	label var gender "Gender"
	la de lblgender 1 "Male" 2 "Female"
	label values gender lblgender


** AGE
	replace age=98 if age>=98 & age!=.
	label var age "Individual age"

	
** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	
	bys idh: gen one=1 if relntohead==1 
	bys idh: egen temp=count(one) 
	
	* 1578 observations (335 HHs) have either no head or more than one.Force it by making 
	* a) eldest male head, if not
	* b) eldest female if no male the head. Use
	* c) lowest running ID to break ties
	*  Other heads sent to value 5, coded as "Other relatives"
	
	bys idh relntohead: egen istheremale = total(sex==1)
	bys idh relntohead: egen maxagemale = max(cond(sex==1,age,.))
	bys idh relntohead: egen maxagefemale = max(cond(sex==2,age,.))
	bys idh relntohead: egen minid = min(pno)
	bys idh relntohead: egen howmany = total(age==maxagefemale)
	
	replace relntohead = 1 if temp==0 & istheremale>=1 & age==maxagemale & minid==pno
	replace relntohead = 1 if temp==0 & istheremale==0 & age==maxagefemale & minid==pno
	
	drop istheremale maxage* minid howmany one temp
	bys idh: gen one=1 if relntohead==1 
	bys idh: egen temp=count(one) 
	tab temp
	
	bys idh relntohead: egen istheremale = total(sex==1)
	bys idh relntohead: egen maxagemale = max(cond(sex==1,age,.))
	bys idh relntohead: egen maxagefemale = max(cond(sex==2,age,.))
	bys idh relntohead: egen minid = min(pno)
	bys idh relntohead: egen howmany = total(age==maxagefemale)
	
	replace relntohead = cond(temp>1 & relntohead ==1 & istheremale>=1 & (age!=maxagemale|sex==2),5,cond(age!=maxagefemale & howmany == 1 & temp>1 & relntohead ==1 &istheremale==0,5,cond(minid!=pno & howmany >1 & temp>1 & relntohead ==1 & istheremale==0,5,relntohead)))

	drop one temp
	bys idh: gen one=1 if relntohead==1 
	bys idh: egen temp=count(one) 
	tab temp
	* 24 cases left, 5 HHs, change manually.
	
	replace relntohead = 1 if hid == 43868205 & pno == 1
	replace relntohead = 1 if hid == 43868207 & pno == 1
	replace relntohead = 1 if hid == 44210206 & pno == 7
	replace relntohead = 1 if hid == 80498204 & pno == 3
	replace relntohead = 1 if hid == 88431207 & pno == 1

	
	gen head=relntohead
	recode head (3 5 = 3) (7=4) (4 6 8 = 5) (9=6) (0=.)
	label var head "Relationship to the head of household"
	la de lblhead  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values head  lblhead




** SOCIAL GROUP

/*
The caste variable exist too, named "socialgrp"
*/

*fre religion
/*
Valid   1 hindu       |     441327      78.37      78.37      78.37
        2 islam       |      65367      11.61      11.61      89.97
        3 christian   |      30100       5.34       5.34      95.32
        4 sikh        |      13620       2.42       2.42      97.74
        5 jain        |       2200       0.39       0.39      98.13
        6 buddhist    |       4773       0.85       0.85      98.97
        7 zoroastrian |        123       0.02       0.02      99.00
        9 others      |       5652       1.00       1.00     100.00
        Total         |     563162     100.00     100.00           
*/
	gen soc=religion
* socialgrp
	label var soc "Social group"
	label define soc 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 
	label define soc 5 "Jainism" 6 "Buddhism" 7 "Zoroastrianism" 9 "Others", add
	label values soc soc


** MARITAL STATUS

/*
Valid   1 never married      |     282371      50.14      50.15      50.15
        2 currently married  |     251296      44.62      44.63      94.77
        3 widowed            |      27570       4.90       4.90      99.67
        4 divorced/separated |       1856       0.33       0.33     100.00
        Total                |     563093      99.99     100.00           
Missing .                    |         69       0.01                      
Total                        |     563162     100.00                      
*/

	gen marital=.
	replace marital=1 if maritalstatus==2
	replace marital=2 if maritalstatus==1
	replace marital=4 if maritalstatus==4
	replace marital=5 if maritalstatus==3
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
	replace atschool=0 if currattend==1
	replace atschool=1 if currattend>1 & currattend!=.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen literacy=.
	replace literacy = 0 if genedulev == 1
	replace literacy = 1 if (genedulev > 1 & !missing(genedulev))
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen educy=.
	/* no education */
	replace educy=0 if genedulev==01 | genedulev==02 | genedulev==03 | genedulev==04 
	/* below primary */
	replace educy=1 if genedulev==05
	/* primary */
	replace educy=5 if genedulev==06
	/* middle */
	replace educy=8 if genedulev==07
	/* secondary */
	replace educy=10 if genedulev==8
	/* higher secondary */
	replace educy=12 if genedulev==9
	/* graduate and above in agriculture, engineering/technology, medicine */
	replace educy=16 if genedulev==10 | genedulev==11 | genedulev==12
	/* graduate and above in other subjects */
	replace educy=15 if genedulev==13
	
	* Use age to get in between categories using the ISCED mapping
	* (http://uis.unesco.org/en/isced-mappings)
	* Entry into primary is 6, entry into middle is at 11, 
	* entry into secondar7 is 14, entry into higher sec is at 16
	* Use age to adapt profile. For example a 17 year old with higher secondary
	* has 11 years of education, not 12
	
	* Primary kids, allow entry from 5
	replace educy = educy - (5 - (age - 5)) if genedulev ==06 & inrange(age,5,11)
	* Middle kids
	replace educy = educy - (3 - (age - 11)) if genedulev ==07 & inrange(age,11,14)
	* Secondary
	replace educy = educy - (2 - (age - 14)) if genedulev ==08 & inrange(age,14,16)
	* Higher secondary
	replace educy = educy - (2 - (age - 16)) if genedulev ==09 & inrange(age,16,18)
	
	* Correct if genedulev incorrect (e.g., a five year old high schooler)
	replace educy = educy - 4 if (educy > age) & (educy > 0) & !missing(educy) 
	replace educy = 0 if (educy > age) & (age < 4) & (educy > 0) & !missing(educy) 
	replace educy = educy - (8 - age) if (educy > age) & (age >= 4 & age <=8) & (educy > 0) & !missing(educy) 
	replace educy = 0 if educy < 0
	label var educy "Years of education"


** EDUCATIONAL LEVEL 1
	gen edulevel1=.
	replace edulevel1=1 if genedulev==01 
	replace edulevel1 = 1 // No educ
	replace edulevel1 = 2 if genedulev == 6 & educy < 5 // Primary incomplete
	replace edulevel1 = 3 if genedulev == 6 & educy >= 5  // Primary complete
	replace edulevel1 = 4 if (genedulev == 7 | genedulev == 8) & educy < 12  // Secondary incomplete
	replace edulevel1 = 5 if genedulev == 9 & educy >= 12  // Secondary complete
	replace edulevel1=7 if genedulev==10 | genedulev==11 | genedulev==12 | genedulev==13
	replace edulevel1=8 if  genedulev==02 | genedulev==03 | genedulev==04
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
	replace everattend=0 if educy==0 
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend

	replace edulevel1=1 if everattend==0 
	replace edulevel2=1 if everattend==0 
	replace edulevel3=1 if everattend==0 

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

	*gen lstatus=.

* LABOR STATUS
	gen lstatus=status_1
	recode lstatus  11/72=1 81 82=2 91/98=3 99=.
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus

* LABOR STATUS LAST YEAR
	gen byte lstatus_year=.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Not employed" 
	label values lstatus_year lbllstatus_year

* EMPLOYMENT STATUS
	gen empstat=status_1
	recode empstat 11=4 12=3 21=2 31 41 51 61 62 71 72=1 81/99=.
	replace empstat=. if lstatus!=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat
	
* EMPLOYMENT STATUS LAST YEAR
	gen byte empstat_year=.
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
	
* NUMBER OF TOTAL JOBS
	forval j=1/4{
	gen d`j'=1 if status_`j'>=11 & status_`j'<=72
	}
	egen njobs=rowtotal(d1 d2 d3 d4)
	recode njobs 0 =.
	label var njobs "Number of jobs"
	
* NUMBER OF TOTAL JOBS LAST YEAR
	gen byte njobs_year=.
	replace njobs_year=. if lstatus_year!=1
	label var njobs_year "Number of jobs during last year"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
* B7_C20 -- b Nature of employer (public 1,semi public 2, private 3)
	gen ocusec=B7_C20
	recode ocusec 2=4 3=2
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public Sector, Central Government, Army, NGO" 2 "Private" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
	replace ocusec=. if lstatus==2 | lstatus==3


** REASONS NOT IN THE LABOR FORCE
	gen nlfreason=status_1
	recode nlfreason 11/82=. 91=1 92 93=2 94=3 95=4 96/98=5
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason



** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
* B6_C8 -- Duration of present spell of unemployment (code)
	gen unempldur_l=.
	replace unempldur_l=0 if B6_C8<=3
	replace unempldur_l=1 if B6_C8==4
	replace unempldur_l=2 if B6_C8==5
	replace unempldur_l=3 if B6_C8==6
	replace unempldur_l=6 if B6_C8==7
	replace unempldur_l=12 if B6_C8==8
	replace unempldur_l=. if B6_C8==.
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen unempldur_u=.
	replace unempldur_u=1 if B6_C8<=3
	replace unempldur_u=2 if B6_C8==4
	replace unempldur_u=3 if B6_C8==5
	replace unempldur_u=6 if B6_C8==6
	replace unempldur_u=12 if B6_C8==7
	replace unempldur_u=. if B6_C8==8 |B6_C8==.
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	gen industry=.
	gen str5 princind_ISIC_str=industryweek
	destring princind_ISIC_str, generate(princind_ISIC)
	
	gen princind_CODE_2digit =substr(princind_ISIC_str,1,2)
	destring princind_CODE_2digit, generate(princind_ISIC_2digit)
	
	replace industry=1 if princind_ISIC_2digit>=00 & princind_ISIC_2digit<=09 
	replace industry=2 if princind_ISIC_2digit>=10 & princind_ISIC_2digit<=19
	replace industry=3 if princind_ISIC_2digit>=20 & princind_ISIC_2digit<=39
	replace industry=4 if princind_ISIC_2digit>=40 & princind_ISIC_2digit<=47 
	replace industry=5 if princind_ISIC_2digit>=50 & princind_ISIC_2digit<=59 
	replace industry=6 if princind_ISIC_2digit>=60 & princind_ISIC_2digit<=69
	replace industry=7 if princind_ISIC_2digit>=70 & princind_ISIC_2digit<=79
	replace industry=8 if princind_ISIC_2digit>=80 & princind_ISIC_2digit<=89
	replace industry=9 if  princind_ISIC_2digit==90
	replace industry=10 if princind_ISIC_2digit>=91 & princind_ISIC_2digit<=99
	replace industry=10 if industry==. & princind_ISIC_2digit!=.
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Community and family oriented services" 10 "Other services, Unspecified"
	label values industry lblindustry
	replace industry=. if lstatus!=1
	
	clonevar IND_1digit = industry
	
	clonevar IND_2digit = princind_ISIC_2digit
		replace IND_2digit=. if lstatus!=1	
	
** INDUSTRY 1
	gen byte industry1=industry
	recode industry1 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry1=. if lstatus!=1
	label var industry1 "1 digit industry classification (Broad Economic Activities)"
	la de lblindustry1 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1 lblindustry1

	clonevar IND = industry1
	
	
*SURVEY SPECIFIC INDUSTRY CLASSIFICATION
	gen industry_orig=princind_ISIC
	replace industry_orig=. if lstatus!=1
	label var industry_orig "Original Industry Codes - NIC 1987 at Group (not Class) level"

	clonevar IND_full = industry_orig
	
** OCCUPATION CLASSIFICATION
	destring occupweek,replace
	gen occup=.
	replace occup=1 if (occupweek>=100 & occupweek<200) |(occupweek>=1 & occupweek<20)
	replace occup=2 if (occupweek>=200 & occupweek<300) |(occupweek>=20 & occupweek<30)
	replace occup=3 if (occupweek>=300 & occupweek<400) |(occupweek>=30 & occupweek<40)
	replace occup=4 if (occupweek>=400 & occupweek<500) |(occupweek>=40 & occupweek<50)
	replace occup=5 if (occupweek>=500 & occupweek<600) |(occupweek>=50 & occupweek<60)
	replace occup=6 if (occupweek>=600 & occupweek<700) |(occupweek>=60 & occupweek<70)
	replace occup=7 if (occupweek>=700 & occupweek<800) |(occupweek>=70 & occupweek<80)
	replace occup=8 if (occupweek>=800 & occupweek<900)|(occupweek>=80 & occupweek<90)
	replace occup=9 if (occupweek>=900 & occupweek<1000) |(occupweek>=90 & occupweek<100)
	replace occup=. if lstatus!=1
	label var occup "1 digit occupational classification"
	label define occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers"  8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup

* SURVEY SPECIFIC OCCUPATION CLASSIFICATION
	gen  occup_orig=occupweek
	replace occup_orig=. if lstatus!=1
	label var occup_orig "Original Occupational Codes - NCO 1968"
	
	clonevar occup_3digit = occup_orig
	
	*# delimit;

*** FIRM SIZE
	gen firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"

	gen firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"


*** HOURS WORKED LAST WEEK - MAIN JOB
	gen whours=.
	gen mainhrs = totdaysactivity_1
	replace mainhrs=. if  lstatus==2 | lstatus==3
	* Since only day assume 8 hours per day
	replace whours=8*mainhrs
	drop mainhrs
	label var whours "Hours of work in last week"
	
	*# delimit cr


** WAGES
	gen wage=wagecashrs_1
	replace wage=. if lstatus==2 | lstatus==3
	replace wage=0 if empstat==2
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen unitwage = .
	replace unitwage=2 if !missing(wage)
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly"
	label values unitwage lblunitwage

			* EMPLOYMENT STATUS - SECOND JOB
				gen byte empstat_2=status_2
				recode empstat_2 11=4 12=3 21=2 31 41 51 61 62 71 72=1 81/99=.
				replace empstat_2=. if njobs==0 | njobs==.
				label var empstat_2 "Employment status - second job"
				la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
				label values empstat_2 lblempstat_2
				
			* EMPLOYMENT STATUS - SECOND JOB LAST YEAR
				gen byte empstat_2_year=.
				replace empstat_2_year=. if njobs_year==0 | njobs_year==.
				label var empstat_2_year "Employment status - second job"
				la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
				label values empstat_2 lblempstat_2
				
			* INDUSTRY CLASSIFICATION - SECOND JOB
				gen byte industry_2=.
				replace industry_2=. if njobs==0 | njobs==.
				label var industry_2 "1 digit industry classification - second job"
				la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
				label values industry_2  lblindustry_2
				
			* INDUSTRY 1 - SECOND JOB
				gen byte industry1_2=industry_2
				recode industry1_2 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
				replace industry1_2=. if njobs==0 | njobs==.
				label var industry1_2 "1 digit industry classification (Broad Economic Activities) - Second job"
				la de lblindustry1_2 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
				label values industry1_2 lblindustry1_2
				
			*SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
				gen industry_orig_2=.
				replace industry_orig_2=. if njobs==0 | njobs==.
				label var industry_orig_2 "Original Industry Codes - Second job"
				la de lblindustry_orig_2 1""
				label values industry_orig_2 lblindustry_orig_2
				
			* OCCUPATION CLASSIFICATION - SECOND JOB
				gen byte occup_2=.
				replace occup_2=. if njobs==0 | njobs==.
				label var occup_2 "1 digit occupational classification - second job"
				la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
				label values occup_2 lbloccup_2
				
			* WAGES - SECOND JOB
				gen double wage_2=wagecashrs_2
				replace wage_2=. if lstatus==2 | lstatus==3
				replace wage_2=. if njobs==1 | njobs==.
				label var wage_2 "Last wage payment - Second job"
				
			* WAGES TIME UNIT - SECOND JOB
				gen byte unitwage_2=2
				replace unitwage_2=. if missing(wage_2)
				label var unitwage_2 "Last wages time unit - Second job"
				la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
				label values unitwage_2 lblunitwage_2

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
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


** UNION MEMBERSHIP
	gen union=B7_C18
	label var union "Union membership"
	recode union (2=0)
	replace union=. if  lstatus==2 | lstatus==3
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

*REGION OF BIRTH JURISDICTION
	gen byte rbirth_juris=.
	label var rbirth_juris "Region of birth jurisdiction"
	la de lblrbirth_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rbirth_juris lblrbirth_juris
	
*REGION OF BIRTH
	gen  rbirth=.
	label var rbirth "Region of Birth"
	
*REGION OF PREVIOUS RESIDENCE JURISDICTION
	gen byte rprevious_juris=.
	label var rprevious_juris "Region of previous residence jurisdiction"
	la de lblrprevious_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rprevious_juris lblrprevious_juris
	
*REGION OF PREVIOUS RESIDENCE
	gen  rprevious=.
	label var rprevious "Region of Previous residence"
	
* YEAR OF MOST RECENT MOVE
	gen int yrmove=.
	label var yrmove "Year of most recent move"
	
*TIME REFERENCE OF MIGRATION
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
	gen pcc=monthhhexp
	replace pcc=. if head==6
	label var pcc "Monthly consumption per capita"


** DECILES OF PER CAPITA CONSUMPTION
	xtile pcc_d=pcc[w=wgt],nq(10)
	label var pcc_d "Consumption per capita deciles"
	tab pcc_d[w=wgt],summ(pcc)


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL FIXES
*                                                                                                    *
*****************************************************************************************************/

	qui su wage
	replace wage=0 if empstat==2 & r(N)!=0

/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


* KEEP VARIABLES - ALL
	keep ccode year intv_year month idh idp wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     cellphone computer internet hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig occup_3digit firmsize_l firmsize_u whours wage unitwage       ///
		 empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2  occup_2 wage_2 unitwage_2 ///
	     contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d	///
		 state IND IND_1digit IND_2digit IND_full occup_3digit
	
* ORDER VARIABLES
	order ccode year intv_year month idh idp wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     cellphone computer internet hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig occup_3digit firmsize_l firmsize_u whours wage unitwage       ///
		 empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
	     contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d	///
		 state IND IND_1digit IND_2digit IND_full occup_3digit

	
	compress
	
* DELETE MISSING VARIABLES	local keep ""
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

	
	
	
	save "`path'\Processed\IND_1993_I2D2_NSS_SCH10_v01_M_v02_A.dta", replace
	*save "D:\__CURRENT\IND_1993_I2D2_NSS_SCH10.dta",replace
	*log close



******************************  END OF DO-FILE  *****************************************************/
