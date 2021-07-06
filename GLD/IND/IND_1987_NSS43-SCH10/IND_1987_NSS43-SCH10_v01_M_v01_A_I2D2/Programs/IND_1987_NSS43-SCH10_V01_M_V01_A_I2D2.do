/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	INDIA
** COUNTRY ISO CODE	IND
** YEAR	1987
** SURVEY NAME	NATIONAL SAMPLE SURVEY 62ND ROUND SCHEDULE 10
** SURVEY AGENCY	GOVERNMENT OF INDIA NATIONAL SAMPLE SURVEY ORGANISATION
** SURVEY SOURCE	
** UNIT OF ANALYSIS	Individuals
** INPUT DATABASES	To be labelled
** RESPONSIBLE	World Bank Jobs Team
** Created	7/4/2021
** Modified NA
** NUMBER OF HOUSEHOLDS	129,194
** NUMBER OF INDIVIDUALS 667,848
** EXPANDED POPULATION	
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
	set mem 700m


** DIRECTORY
	global path "Y:\__I2D2\India\1987\NSS_SCH10"


** LOG FILE
	*log using "$path\Processed\IND_2005_I2D2_NSS_SCH10.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
*----------1.3: Database assembly------------------------------*
* Start process with individual block 4
tempfile block4 block4short

use "$path_in/Block-4-Persons-Demographic-current-weekly-activity- Records.dta", clear

* Identify the duplicates in person id
distinct Person_key //duplicates of 44 records
duplicates tag Person_key, gen(tag)

* Remove duplicates

	* Rule 1: If age is missing, drop that duplicate
	drop if B4_q5 == . & tag == 1 //drop

	* Rule 2: Keep the record with more information on labor market
	gen count = B4_q12 != "" // if has value of q12, also has value for q14-15
	bys Person_key: egen countmax = max(count)
	drop if tag == 1 & countmax != count

	* Rule 3: Keep the first recorded - get back to this later on

	duplicates drop Person_key, force
	distinct Person_key

* At this point, there are 667,804 persons (vs 667,844 in MOSPI - which included duplicates)
save `block4'

	* Save only Person key and current weekly activity (CWA)
	* CWA is important for us to reconcile with daily activity records in Block 5
	keep Person_key B4_q11

save `block4short'


* Proceed with Block 5
use "$path_in/Block-5-Persons-Daily- activity- time-disposion-Records.dta", clear

* Drop the invalid data to arrive with total consistent with that reported by MOSPI
drop if missing(B5_q13)
count // same total as reported by IND Ministry

* Generate person serial number from the unique person ID variable, Person_key
gen Prsn_slno = substr(Person_key, -3, 3)

* Sorting procedure

/* Creating the PRIORITY TAG variable
Need to order activity status such that the order of priority is as follows:

	a. Working status
	b. Non-working status but seeking employment
	c. Neither working nor available for work

*/

destring B5_q3, gen(priority_tag)
gen num_status = priority_tag

* Classify the level of priority
recode priority_tag 11/72=1 81 82=2 91/98=3 99=.

* Decreasing order of number of days worked
gen neg_days = -(B5_q13)

/*==============================================================================
Caveat on using the number of days worked variable:

As per the instruction manual for the 1987 EUE, the total number of days for all
the activities shold be 7. However, in the data, the number of days for all activities
taken together do not all add up to 7. A total of 13,000 individuals have total
days more than or less than 7.

The harmonizer leaves it up to the data user to explore methods to address this
data issue. For the purposes of this exercise, only the ordering of the activity
duration is taken into consideration, regardless of the number of days sum up for
that individual or not.

==============================================================================*/
* Generate PID bec this is variable name used for the sorting procedure below
gen PID = Person_key

* Total number of days for each person's activity should be equal to 7
bys PID: egen tot = sum(B5_q13)
distinct PID if tot != 7 //nearly 13,000 people with unreliable data

distinct PID

* There are several duplicates in status code for the same person.
* Need to keep only one status code such that HH - Person - status code is unique
duplicates drop PID B5_q3, force

* Check if unique after trimming records
distinct PID B5_q3, joint
* End up with 750,293 unique observations

* Merge with block 4 short
merge m:1 Person_key using `block4short'
* There are 238 persons in Block 5 not found in Block 4
* There are 8 persons in Block 4 not in Block 5


/*==============================================================================
The following is the hierarchy of rules for ordering daily activity records
	1. Equal to the reported CWA variable
	2. Priority tag such that activity 2 captures working status if person has 2 diff jobs
	3. Number of days worked in a week to break tie for similar priority tags
	4. If number of days are still equal between two activities of same priority tag, the status
	code that is smaller in value is taken as the CWA (e.g., activites 11 and 51
	are worked for 3.5 days each; activity 11 will be the CWA because it is smaller
	in value than 51.) * Note: a caveat is that this procedure biases towards self-employment
==============================================================================*/

gen first = 1 if B5_q3 == B4_q11
replace first = 2 if B5_q3 != B4_q11

sort PID first priority_tag neg_days num_status
bys PID: gen runner = _n

* At this point, we expect activity 1 to be equal to CWA, B4_q11
count if B5_q3! =  B4_q11 & runner==1 & !missing(B4_q11)

* However, there are 193 cases of mismatch. What do we do with this?
* In principle, CWA should be derived from daily activity records. I stick to this
* Also, since 50% of these cases have value = 99 under CWA, using daily activity records
* would also be more favorable. In terms of identifying primary and secondary 7-day
* occupation codes, which are mapped only to CWA, we leave them as missing
* for these 193 records.

* Keep only necessary variables for reshape
keep B5_q3 B5_q4 B5_q13 B5_q14 B5_q15 B5_q16  Hhold_key Prsn_slno Person_key runner

* Activity serial number is not unique, create serial id for each person

reshape wide B5_q3 B5_q4 B5_q13 B5_q14 B5_q15 B5_q16, i(Person_key) j(runner)

* Check whether activities correctly coded in order - there should not be a third activity if
* there is no second activity.
count if missing(B5_q31) & !missing(B5_q32)
count if missing(B5_q32) & !missing(B5_q33)
count if missing(B5_q33) & !missing(B5_q34)

* Next, we merge with full block 4
merge m:1 Person_key using `block4', nogen

tempfile weekly_act
save `weekly_act'


* Create temporary files for each block where we save the clean version
tempfile block3 block7 block6

* Proceed with block 1- 3

use "$path_in/Block-1-3-Household-Records", clear

duplicates tag Hhold_key, gen(tag)

	* Rule 1: Keep the duplicated record with more non-missing values
	foreach var of varlist B3_q7 - B3_q16{
		gen count_`var' = `var' ! = .
		}

	egen totl_nonmissing = rowtotal(count_B3_q7 - count_B3_q16)
	bys Hhold_key: egen max_nonmissing = max(totl_nonmissing)

	drop if tag ==1 & max_nonmissing != totl_nonmissing

	* Rule 2: At this point, all duplicates have same information. Drop duplicates
	duplicates drop Hhold_key, force

	save `block3'

* Proceed with block 7
use "$path_in/Block-7-Persons- usual-activity-statuscode-11to94-Records", clear

	* Since no pattern found, drop first record
	duplicates drop Person_key, force

	save `block7'

* Proceed with block 6
use "$path_in/Block-6--Persons-Usual-activity- migration-Records.dta", clear

* Identify the duplicates in person id
distinct Person_key //duplicates of 44 records
duplicates tag Person_key, gen(tag)

* Remove duplicates (keep the first instance)
duplicates drop Person_key, force


/*==============================================================================
Caveat:

At this point, we are not sure whether the dropped HHs/persons in Blocks 1-3, 6
and 7 are the exact match to those dropped in Block 4.

Unfortunately, there is no other common variable that would allow us to filter
the perfect match. We ignore the implications of the mismatch and leave it to the data analyzer
to explore other innovative options to match these observations.
==============================================================================*/


* Merge Individual 12 month info with 7 day info
merge 1:1 Person_key using `weekly_act', keep(match master) nogen

* Merge with HH info
merge m:1 Hhold_key using `block3', keep(match master) nogen

* Merge with additional questions for employed (note this is a subset)
merge 1:1 Person_key using `block7', keep(match master) nogen

** COUNTRY
	gen ccode="IND"
	label var ccode "Country code"


** MONTH
	gen month = .
	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"


** YEAR
	gen year= 1987
	label var year "Year of survey"


** YEAR OF INTERVIEW
	gen intv_year= .
	replace intv_year = 1987 if inlist(SubRound, "1", "2")
	replace intv_year = 1988 if inlist(SubRound, "3", "4")
	label var intv_year "Year of the interview"


** HOUSEHOLD IDENTIFICATION NUMBER
	gen idh = Hhold_key
	label var idh "Household id"


** INDIVIDUAL IDENTIFICATION NUMBER
	egen str idp = Person_key
	label var idp "Individual id"


	isid idp


** HOUSEHOLD WEIGHTS
	gen wgt= Wgt4_pooled

	label var wgt "Household sampling weight"


** STRATA
	gen strata=Stratum
	label var strata "Strata"


** PSU
	gen psu=FSU_No
	destring psu , replace
	label var psu "Primary sampling units"


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	destring Sector, gen(urb)
	recode urb (2=1) (1=2)

	label var urb "Urban/Rural"
	la de lblurb 1 "Urban" 2 "Rural"
	label values urb lblurb


**REGIONAL AREAS
	gen reg01=.
	label var reg01 "Macro regional areas"

	destring State, gen(REG)
	label define statecode 2 "2 - Andhra Pradesh" 3 "3 - Arunachal Pradesh" 4 "4 - Assam" ///
			5 "5 - Bihar" 6 "6 - Goa" 7 "7 - Gujarat" 8 "8 - Haryana" 9 "9 - Himachal Pradesh" ///
			10 "10 - Jammu & Kashmir" 11 "11 - Karnataka" 12 "12 - Kerala" 13 "13 - Madhya Pradesh" ///
			14 "14 - Maharashtra" 15 "15 - Manipur" 16 "16 - Meghalaya" 17 "17 - Mizoram" ///
			18 "18 - Nagaland" 19 "19 - Orissa" 20 "20 - Punjab" 21 "21 - Rajasthan" ///
			22 "22 - Sikkim" 23 "23 - Tamil Nadu" 24 "24 - Tripura" 25 "25 - Uttar Pradesh" ///
			26 "26 - West Bengal" 27 "27 - A & N Islands" 28 "28 - Chandigarh" ///
			29 "29 - Dadra & Nagar Haveli" 30 "30 - Daman & Diu" 31 "31 - Delhi" ///
			32 "32 - Lakshdweep" 33 "33 - Pondicherry"
	gen reg02=REG
	label values reg02 statecode
	label var reg02 "Region at 1 digit(ADMN1)"


** REGIONAL AREA 2 DIGITS ADM LEVEL (ADMN2)
	destring Region, gen(reg03)
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
	gen water=. /* B7_v18 bringing water from outside premises */
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


**HOUSEHOLD SIZE
	bys idh: gen hhsize= _N
	label var hhsize "Household size"

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD

	
	string B4_q3, replace

	bys Hhold_key: gen one=1 if B4_q3==1
	bys Hhold_key: egen temp=count(one)
	tab temp

	destring Prsn_Slno, gen(pno)
	destring B4_q4, gen(sex)
	gen relation = B4_q3
	bys Hhold_key relation: egen istheremale = total(sex==1)
	bys Hhold_key relation: egen maxagemale = max(cond(sex==1,age,.))
	bys Hhold_key relation: egen maxagefemale = max(cond(sex==2,age,.))
	bys Hhold_key relation: egen minid = min(pno)
	bys Hhold_key relation: egen howmany = total(age==maxagefemale)

	replace relation = 1 if temp==0 & istheremale>=1 & age==maxagemale & minid==pno
	replace relation = 1 if temp==0 & istheremale==0 & age==maxagefemale & minid==pno

	drop istheremale maxage* minid howmany one temp
	bys Hhold_key: gen one=1 if relation==1
	bys Hhold_key: egen temp=count(one)
	tab temp

	bys Hhold_key relation: egen istheremale = total(sex==1)
	bys Hhold_key relation: egen maxagemale = max(cond(sex==1,age,.))
	bys Hhold_key relation: egen maxagefemale = max(cond(sex==2,age,.))
	bys Hhold_key relation: egen minid = min(pno)
	bys Hhold_key relation: egen howmany = total(age==maxagefemale)

	replace relation = cond(temp>1 & relation ==1 & istheremale>=1 & (age!=maxagemale|sex==2),5,cond(age!=maxagefemale & howmany == 1 & temp>1 & relation ==1 &istheremale==0,5,cond(minid!=pno & howmany >1 & temp>1 & relation ==1 & istheremale==0,5,relation)))

	drop one temp
	bys Hhold_key: gen one=1 if relation==1
	bys Hhold_key: egen temp=count(one)
	tab temp
	* 33 cases left, 5 HHs, change manually.

	replace relation = 5 if Hhold_key == "10230202" & pno == 2
	replace relation = 5 if Hhold_key == "11249202" & pno == 11
	replace relation = 5 if Hhold_key == "14591101" & pno == 2
	replace relation = 5 if Hhold_key == "73988201" & pno == 2
	replace relation = 5 if Hhold_key == "74623207" & pno == 100

	drop one temp
	bys Hhold_key: gen one=1 if relation==1
	bys Hhold_key: egen temp=count(one)
	tab temp

	drop one temp
	* At this point, we have single HH head per HH

	gen head = relation
	recode head (3 5 = 3) (7=4) (4 6 8 = 5) (9=6) (0=.)
	label var head "Relationship to the head of household - Harmonized"
	la de lblhead  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values head  lblhead
	

** GENDER
	destring B4_q4, gen(gender)
	label var gender "Gender"
	la de lblgender 1 "Male" 2 "Female"
	label values gender lblgender


** AGE
	gen age = B4_q5
	label var age "Individual age"
	replace age=98 if age>=98


** SOCIAL GROUP

/*
The variable caste exist too, named "B3_v06"
*/
	gen soc=. 
* B3_v06
	label var soc "Social group"



** MARITAL STATUS
	destring B4_q6, gen(marital)
	recode marital (1=2) (2=1) (3=5) (0=.)
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
	* This is only asked for persons aged 30 and below
	* Tagged as those with entries between 21 and 40
	gen atschool=.
	destring B4_q9, gen(atnum)
	replace atschool= atnum!=1
	replace atschool = . if age>30 | missing(age) | missing(B4_q9) | B4_q9 == 99
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
	drop atnum


** CAN READ AND WRITE
gen educy=.
	/* no education */
	replace educy=0 if B4_q7=="01" | B4_q7=="00"
	/* below primary */
	replace educy=1 if B4_q7=="02"
	/* primary */
	replace educy=5 if B4_q7=="03"
	/* middle */
	replace educy=8 if B4_q7=="04"
	/* secondary */
	replace educy=10 if B4_q7=="05"
	/* higher secondary */
	* None
	/* graduate and above in agriculture, engineering/technology, medicine */
	replace educy=16 if B4_q7=="06" | B4_q7=="07" | B4_q7=="08"
	/* graduate and above in other subjects */
	replace educy=15 if B4_q7=="09"

	* Use age to get in between categories using the ISCED mapping
	* (http://uis.unesco.org/en/isced-mappings)
	* Entry into primary is 6, entry into middle is at 11,
	* entry into secondar7 is 14, entry into higher sec is at 16
	* Use age to adapt profile. For example a 17 year old with higher secondary
	* has 11 years of education, not 12

	* Primary kids, allow entry from 5
	replace educy = educy - (5 - (age - 5)) if B4_q7 == "03" & inrange(age,5,11)
	* Middle kids
	replace educy = educy - (3 - (age - 11)) if B4_q7 == "04" & inrange(age,11,14)
	* Secondary
	replace educy = educy - (2 - (age - 14)) if B4_q7 == "05" & inrange(age,14,16)
	* Higher secondary
	*replace educy = educy - (2 - (age - 16)) if B4_q7 == "09" & inrange(age,16,18)

	* Correct if B4_q7 incorrect (e.g., a five year old high schooler)
	replace educy = educy - 4 if (educy > age) & (educy > 0) & !missing(educy)
	replace educy = 0 if (educy > age) & (age < 4) & (educy > 0) & !missing(educy)
	replace educy = educy - (8 - age) if (educy > age) & (age >= 4 & age <=8) & (educy > 0) & !missing(educy)
	replace educy = 0 if educy < 0
	label var educy "Years of education"

		* Use age to get in between categories using the ISCED mapping
	* (http://uis.unesco.org/en/isced-mappings)
	* Entry into primary is 6, entry into middle is at 11, 
	* entry into secondar7 is 14, entry into higher sec is at 16
	* Use age to adapt profile. For example a 17 year old with higher secondary
	* has 11 years of education, not 12

** EDUCATIONAL LEVEL 1
	destring B4_q7, gen(genedulev)
	gen byte edulevel1 = .
	replace edulevel1= 1 if genedulev== 0 | genedulev==1 // No educ
	replace edulevel1 = 2 if genedulev == 2 & educy < 5 // Primary incomplete
	replace edulevel1 = 3 if genedulev == 3 & educy >= 5  // Primary complete
	replace edulevel1 = 4 if genedulev == 4 & educy < 12  // Secondary incomplete
	replace edulevel1 = 5 if genedulev == 5 & educy >= 12  // Secondary complete
	replace edulevel1= 7 if genedulev==6 | genedulev==7 | genedulev==8 | genedulev==9
	replace edulevel1=. if  genedulev==99
	label var edulevel1 "Level of education 1"
	la de lbledulevel1 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete"
	label values edulevel1 lbledulevel1
	drop genedulev


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

	replace educy=0 if everattend==0 
	replace edulevel1=1 if everattend==0 
	replace edulevel2=1 if everattend==0 
	replace edulevel3=1 if everattend==0 


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen lb_mod_age=5
	label var lb_mod_age "Labor module application age"


** LABOR STATUS
	destring B6_q41, gen(lstatus)
	recode lstatus  11/72=1 81 82=2 91/98=3 99=.
	replace lstatus = . if age < lb_mod_age
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** LABOR STATUS LAST YEAR
	* Note here that non-LF is recoded to missing
	destring B7_q2, gen(lstatus_year)
	recode lstatus_year  11/51=1 81 82=2 91/99=.
	destring B7_q3, gen(secondary_help)
	recode secondary_help  11/51=1
	replace lstatus_year = 1 if secondary_help == 1 & lstatus_year != 1
	replace lstatus = . if age < minlaborage
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 
	label values lstatus_year lbllstatus_year
	drop secondary_help

** EMPLOYMENT STATUS
	destring B5_q31, gen(empstat)
	recode empstat 11=4 12=3 21=2 31 41 51 61 62 71 72=1 81/99=.
	replace empstat=. if lstatus != 1 | (age < minlaborage & age != .)
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat


** EMPLOYMENT STATUS LAST YEAR
	destring B7_q2, gen(empstat_year)
	recode empstat_year 11=4 21=2 31 41 51 = 1 81/99=.
	destring B7_q3, gen(secondary_help)
	recode secondary_help  11=4 21=2 31 41 51 = 1
	replace empstat_year = secondary_help if missing(empstat_year) & lstatus_year == 1
	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
	drop secondary_help

** EMPLOYMENT STATUS - SECOND JOB
	gen has_job_primary = inlist(B5_q31,"11", "12", "21", "31", "41", "51") | inlist(B5_q31, "61", "62", "71", "72")
	destring B5_q32, gen(empstat_2)
	recode empstat_2 11=4 12=3 21=2 31 41 51 61 62 71 72=1 81/99=.
	replace empstat_2=. if lstatus != 1 | (age < minlaborage & age != .)
	replace empstat_2 = . if has_job_primary == 0 & !missing(empstat_2)
	label var empstat_2 "Employment status during past week primary job 7 day recall"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2

	** Third job in the past week 
	destring B5_q33, gen(empstat_3)
	recode empstat_3 11=4 12=3 21=2 31 41 51 61 62 71 72=1 81/99=.
	replace empstat_3=. if lstatus != 1 | (age < lb_mod_age & age != .)
	replace empstat_3 = . if has_job_primary == 0 & !missing(empstat_3)

	** Fourth job
	destring B5_q34, gen(empstat_4)
	recode empstat_4 11=4 12=3 21=2 31 41 51 61 62 71 72=1 81/99=.
	replace empstat_4=. if lstatus != 1 | (age < lb_mod_age & age != .)
	replace empstat_4 = . if has_job_primary == 0 & !missing(empstat_4)

** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
	destring B5_q8, gen(empstat_2_year)
	recode empstat_2_year  11=4 12=3 21=2 31 41 51 61 62 71 72=1 81/99=.
	replace empstat_2_year = . if lstatus_year != 1

	gen has_job_primary = inlist(B7_q2,"11", "21", "31", "41", "51")
	destring B7_q3, gen(empstat_2_year)
	recode empstat_2_year  11=4 21=2 31 41 51 =1 81/99=.
	replace empstat_2_year = . if lstatus_year != 1
	replace empstat_2_year = . if has_job_primary == 0 & !missing(empstat_2_year)
	label var empstat_2_year "Employment status during past week secondary job 12 month recall"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2_year lblempstat_2_year
	drop has_job_primary
	
	
** NUMBER OF ADDITIONAL JOBS
	gen njobs=.
	replace njobs = 1 if !missing(empstat)
	replace njobs = 2 if !missing(empstat_2)
	replace njobs = 3 if !missing(empstat_3)
	replace njobs = 4 if !missing(empstat_4)
	label var njobs "Number of additional jobs"
	drop empstat_3 empstat_4


** NUMBER OF ADDITIONAL JOBS LAST YEAR
	gen byte njobs_year=.
	replace njobs_year= 1 if !missing(empstat_year) 
	replace njobs_year= 2 if !missing(empstat_2_year)
	label var njobs_year "Number of additional jobs during last year"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public Sector, Central Government, Army, NGO" 2 "Private" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1


** REASONS NOT IN THE LABOR FORCE
	destring B5_q31, gen(nlfreason)
	recode nlfreason 11/82=. 91=1 92 93=2 94=3 95=4 96/98=5
	replace nlfreason = . if lstatus != 3 | (age < minlaborage & age != .)
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen unempldur_l= floor(unemp_months)
	replace unempldur_l = . if missing(B7_q6) | lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"
	
	gen unempldur_u= ceil(unemp_months)
	replace unempldur_u = . if missing(B7_q6) | lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"

** INDUSTRY CLASSIFICATION
	gen industry = .

	replace industry=1 if B5_q41 == "0"
	replace industry=2 if B5_q41 == "1"
	replace industry=3 if B5_q41 == "2" | B5_q41 == "3"
	replace industry=4 if B5_q41 == "4"
	replace industry=5 if B5_q41 == "5"
	replace industry=6 if B5_q41 == "6"
	replace industry=7 if B5_q41 == "7"
	replace industry=8 if B5_q41 == "8"
	replace industry=9 if B5_q41 == "9"

	replace industry=. if lstatus != 1 | (age < minlaborage & age != .)
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Community and family oriented services" 10 "Others"
	label values industry lblindustry


** INDUSTRY 1
	gen byte industry1=industry
	recode industry1 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry1=. if lstatus!=1
	label var industry1 "1 digit industry classification (Broad Economic Activities)"
	la de lblindustry1 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1 lblindustry1


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION
	gen industry_orig=B5_q41
	replace industry_orig= "" if lstatus!=1
	label var industry_orig "Original Industry Codes"


** OCCUPATION CLASSIFICATION
	gen code_68 = B4_q15 if B4_q11 == B5_q31
	gen x_indic = regexm(code_68, "x|X|y|y")
	replace code_68 = "99" if x_indic == 1
	replace code_68 = "0" + code_68 if length(code_68) == 2
	replace code_68 = "00" + code_68 if length(code_68) == 1
	replace code_68 = substr(code_68,1,2)

	merge m:1 code_68 using "$path/IND_1987_NSS43-SCH10_NCO_68_to_2004_conversion.dta"
	destring code_04, replace

	gen occup = .
	replace occup = code_04 if lstatus == 1 & (age >= minlaborage & age != .)
	replace occup = 99 if x_indic == 1 & lstatus == 1 & (age >= minlaborage & age != .)
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
	drop x_indic code_68 code_04

** SURVEY SPECIFIC OCCUPATION CLASSIFICATION
	gen occup_orig = B4_q15 if B4_q11 == B5_q31
	label var occup_orig "Original Occupational Codes"


** FIRM SIZE
	* The variable is not available in the 2005 dataset
	gen firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"

	gen firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK (for main job only)
	gen whours = 8*B5_q131
	replace whours=. if lstatus != 1 | (age < minlaborage & age != .)
	label var whours "Hours of work in last week primary job 7 day recall"
	label var whours "Hours of work in last week"


** WAGES
	gen double wage = B5_q141
	replace wage=. if lstatus != 1 | (age < lb_mod_age & age != .)
	replace wage = . if missing(empstat)
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen unitwage= 2	
	replace unitwage=. if lstatus != 1 | (age < lb_mod_age & age != .)
	replace unitwage = . if missing(empstat)
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 
	label values unitwage lblunitwage



** INDUSTRY CLASSIFICATION - SECOND JOB
gen industry_2 = .

	replace industry_2=1 if B5_q42 == "0"
	replace industry_2=2 if B5_q42 == "1"
	replace industry_2=3 if B5_q42 == "2" | B5_q42 == "3"
	replace industry_2=4 if B5_q42 == "4"
	replace industry_2=5 if B5_q42 == "5"
	replace industry_2=6 if B5_q42 == "6"
	replace industry_2=7 if B5_q42 == "7"
	replace industry_2=8 if B5_q42 == "8"
	replace industry_2=10 if B5_q42 == "9"


	replace industry_2=. if lstatus != 1 | (age < minlaborage & age != .)
	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2  lblindustry_2
	drop red_indus


** INDUSTRY 1 - SECOND JOB
	gen byte industry1_2=industry_2
	recode industry1_2 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry1_2=. if njobs==0 | njobs==.
	label var industry1_2 "1 digit industry classification (Broad Economic Activities) - Second job"
	la de lblindustry1_2 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1_2 lblindustry1_2


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
	gen industry_orig_2=B5_q42
	label var industry_orig_2 "Original Industry Codes - Second job"


** OCCUPATION CLASSIFICATION - SECOND JOB
	gen occup_2=  .
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2


** WAGES - SECOND JOB
	gen double wage_2= B5_q142
	replace wage_2=. if lstatus != 1 | (age < lb_mod_age & age != .)
	label var wage_2 "Last wage payment - Second job"


** WAGES TIME UNIT - SECOND JOB
	gen byte unitwage_2 = 2
	replace unitwage_2=. if lstatus != 1 | (age < lb_mod_age & age != .)
	replace unitwage_2 = . if missing(empstat_2)
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
	gen union= .
	la de lblunion 0 "No member" 1 "Member"
	label var union "Union membership"
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
	gen  rbirth=.
	label var rbirth "Region of Birth"


** REGION OF PREVIOUS RESIDENCE JURISDICTION
	destring B6_q14, gen(migrated_binary)
	recode migrated_binary (2 = 0)
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
	
	
	gen byte rprevious_juris=.
	replace rprevious_juris = 1 if inlist(B6_q16, "3", "4") & migrated_binary == 1
	replace rprevious_juris = 2 if inlist(B6_q16, "1", "2") & migrated_binary == 1
	replace rprevious_juris = 5 if B6_q16 == "7" & migrated_binary == 1

	label var rprevious_juris "Region of previous residence jurisdiction"
	la de lblrprevious_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rprevious_juris lblrprevious_juris


**REGION OF PREVIOUS RESIDENCE
	gen  rprevious=.
	label var rprevious "Region of Previous residence"


** YEAR OF MOST RECENT MOVE
	gen int yrmove= 1987 - B6_q15 if migrated_binary == 1
	label var yrmove "Year of most recent move"


**TIME REFERENCE OF MIGRATION
	gen byte rprevious_time_ref= 0.5
	label var rprevious_time_ref "Time reference of migration"
	la de lblrprevious_time_ref 99 "Previous migration"
	label values rprevious_time_ref lblrprevious_time_ref
	
	drop migrated_binary


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


** CONSUMPTION PER CAPITA
	gen pcc= .
	label var pcc "Monthly consumption per capita"


** DECILES OF PER CAPITA CONSUMPTION
	gen pcc_d = .
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
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage       ///
	empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2  occup_2 wage_2 unitwage_2 ///
	     contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d


** ORDER VARIABLES
	order ccode year intv_year month idh idp wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     cellphone computer internet hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage       ///
	empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
	     contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d

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
	keep ccode year month intv_year idh idp wgt strata psu `keep'


	save "$path\Processed\IND_2005_I2D2_NSS_SCH10.dta", replace
	save "Y:\__CURRENT\IND_2005_I2D2_NSS_SCH10.dta",replace
	log close





******************************  END OF DO-FILE  *****************************************************/
