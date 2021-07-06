/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	INDIA
** COUNTRY ISO CODE	IND
** YEAR	2005
** SURVEY NAME	NATIONAL SAMPLE SURVEY 62ND ROUND SCHEDULE 10
** SURVEY AGENCY	GOVERNMENT OF INDIA NATIONAL SAMPLE SURVEY ORGANISATION
** SURVEY SOURCE	
** UNIT OF ANALYSIS	Individuals
** INPUT DATABASES	Y:\__I2D2\India\2005\NSS_SCH10\Original\Data
** RESPONSIBLE	Angelo Santos
** Created	6/29/2021
** Modified NA
** NUMBER OF HOUSEHOLDS	78,879
** NUMBER OF INDIVIDUALS 377,377
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
	global path "Y:\__I2D2\India\2005\NSS_SCH10"


** LOG FILE
	*log using "$path\Processed\IND_2005_I2D2_NSS_SCH10.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT


use "$path\Original\Data\Block-6-Persons-daily-activity-time-disposition-reecords.dta"
	
	
/* Need to order activity status such that the order of priority is as follows: 
	a. Working status
	b. Non-working status but seeking employment
	c. Neither working nor available for work
*/

destring B6_q4, gen(priority_tag)
gen num_status = priority_tag
* Classify the level of priority
recode priority_tag 11/72=1 81 82=2 91/98=3 99=.

* Decreasingorder of number of days worked
gen neg_days = -(B6_q14)


* Order the records such that priority 1 comes first

/*============================================================================== 
The following is the hierarchy of rules for selecting the current weekly activity
	1. Priority tag 
	2. Number of days worked in a week
	3. If number of days are equal between two employment activities, the status 
	code that is smaller in value is taken as the CWA (e.g., activites 11 and 51 
	are worked for 3.5 days each; activity 11 will be the CWA because it is smaller
	in value than 51.
==============================================================================*/

sort Person_key priority_tag neg_days num_status 
bys Person_key: gen runner = _n

* Extract original serial number
gen original_serial = substr(Activity_slno_key, -1, 1)
destring original_serial, replace

* How many cases wherein this priority order is not followed
count if B6_q4 ! = B6_q18 & runner==1 //0
	* majority of the cases is due to equal number of hours worked

/*============================================================================== 
What are the implications?
1. Individual's employment status can be determined on the basis of status 1 or the 
	current weekly activity status. No need to recode everything as both variables
	are the same!
2. The NSO under the CWA is the same as activity 1 
3. These is no overlap between activity 2 and activity 1!
==============================================================================*/

* Switch serial numbering of activities to integer
destring B6_q3, replace
keep B6_q4 B6_q5 B6_q14 B6_q15 - B6_q20 Hhold_key  B6_q1 runner

/*============================================================================== 
Issue: Current weekly activity is constant across Person id, but there are cases
		wherein the industry and occupation for each activity vary! Ideally, there
		should be 1:1 correspondence between NIC/NCO and CWA
		
Resolve: Include the NIC/NCO in the reshaping to wide, then keep only the first instance
But first, make sure that the first instance for employed is nonmissing
==============================================================================*/

reshape wide B6_q4 B6_q5 B6_q14 - B6_q17 B6_q19 B6_q20, i(Hhold_key B6_q1) j(runner)

destring B6_q18, gen(cwa_e)

*============================================================================== 
* Need to count how many non-zero responses for industry/occupation variables

count if B6_q191 == "" & inrange(cwa_e, 11, 72) //zero!
count if B6_q201 == "" & inrange(cwa_e, 11, 72) 

* there are 913 employed people with no occupation code

count if missing(B6_q201) & (!missing(B6_q202) | !missing(B6_q203) | !missing(B6_q204)) & inrange(cwa_e, 11, 72) 
* 2 cases wherein occupation code is recorded under the second instance
* Move this to first instance; ignore second instance

replace B6_q201 = B6_q202 if missing(B6_q201)& !missing(B6_q202) & inrange(cwa_e, 11, 72)

count if B6_q201 == "" & inrange(cwa_e, 11, 72) 
* Still 911 employed people with no occupation code. Nothing we can do!
* 911/137,450 employed people = 0.6%

* Next step, drop second, third and fourth NIC/NCO variables
drop B6_q192 B6_q193 B6_q194 B6_q202 B6_q203 B6_q204
ren B6_q191 B6_q19
ren B6_q201 B6_q20

* Make sure that CWA = first activity
count if B6_q41 != B6_q18 //zero

* Make sure that CWA is available for all
count if missing(B6_q18)  //zero

* Make sure that second is not missing when third is not missing
count if missing(B6_q42) & !missing(B6_q43) //zero

**** Looks like data is in good shape!

tempfile weekly_act
save `weekly_act'

* Generate unique id variable at person level
egen Person_key = concat(Hhold_key B6_q1)

** Begin merging the other datasets

* Merge with block 4
merge m:1 Person_key using "$path\Original\Data\Block-4-Persons-demographic-particulars-records.dta", keep(master match) nogen

* Start with Block 1
merge m:1 Hhold_key using "$path\Original\Data\Block-1-2-Household-ID-records.dta" , keep(master match) nogen

* Block 5
merge 1:1 Person_key using "$path\Original\Data\Block-5-Persons-usual-activity-records.dta" , keep(master match) nogen



** COUNTRY
	gen ccode="IND"
	label var ccode "Country code"


** MONTH
	gen month =substr(B2_q2i,-4,2)
	destring month, replace
	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"


** YEAR
	gen year=2005
	label var year "Year of survey"


** YEAR OF INTERVIEW
	gen intv_year=substr(B2_q2i,-2,2)
	destring intv_year, replace
	recode intv_year 6=2006 5=2005
	label var intv_year "Year of the interview"


** HOUSEHOLD IDENTIFICATION NUMBER
	gen idh = Hhold_key
	label var idh "Household id"


** INDIVIDUAL IDENTIFICATION NUMBER
	egen str idp =concat(idh Person_slno_B4_q1)
	label var idp "Individual id"


	isid idp


** HOUSEHOLD WEIGHTS
	gen wgt=WGT

	label var wgt "Household sampling weight"


** STRATA
	gen strata=Stratum
	label var strata "Strata"


** PSU
	gen psu=FSU 
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
	label define statecode  28 "Andhra Pradesh"  18 "Assam"  10 "Bihar" 24 "Gujarat" 06 "Haryana"  02 "HimachalPradesh" ///
	01 "Jammu & Kashmir" 29"Karnataka" 32 "Kerala" 23 "Madhya Pradesh" 27  "Maharashtra" ///  
	14 "Manipur"   17 "Meghalaya"  13 "Nagaland"  21 "Orissa"  03 "Punjab" 08 "Rajasthan" 11 "Sikkim" ///
	33 "Tamil Nadu"  16 "Tripura"  09 "Uttar Pradesh"  19 "West Bengal" 35 "A & N Islands" ///
	12 "Arunachal Pradesh"  4 "Chandigarh" 26 "Dadra & Nagar Haveli" 7 "Delhi"  30 "Goa" ///
	31"Lakshdweep" 15 "Mizoram"  34 "Pondicherry"  25 "Daman & Diu" 22"Chhattisgarh" 20"Jharkhand" 5"Uttaranchal"
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
	destring(B4_q3), gen(head)
	recode head (3 5 = 3) (7=4) (4 6 8 = 5) (9=6) (0 = .)
	label var head "Relationship to the head of household"
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
	replace atschool= atnum>=21 & atnum<=40
	replace atschool = . if age>30 | missing(age) | missing(B4_q9)
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
	drop atnum


** CAN READ AND WRITE
	gen literacy=.
	replace literacy = 0 if B4_q7 == "01"
	replace literacy = 1 if !inlist(B4_q7, "01") & !missing(B4_q7)	
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy

** YEARS OF EDUCATION COMPLETED
	gen educy=.
	/* no education */
	replace educy=0 if B4_q7=="01" | B4_q7=="02" | B4_q7=="03" | B4_q7=="04" 
	/* below primary */
	replace educy=1 if B4_q7=="05"
	/* primary */
	replace educy=5 if B4_q7=="06"
	/* middle */
	replace educy=8 if B4_q7=="07"
	/* secondary */
	replace educy=10 if B4_q7=="08"
	/* higher secondary */
	replace educy=12 if B4_q7=="10" 
	/* diploma - as per ISCID 2011, diploma is longer by 1 year to finish viz senior secondary */
	replace educy= 13 if B4_q7=="11" 
	/* College graduate */
	replace educy=16 if  B4_q7=="12" 
	/* Finished graduate school */
	replace educy=18 if B4_q7=="13" 
	
		* Use age to get in between categories using the ISCED mapping
	* (http://uis.unesco.org/en/isced-mappings)
	* Entry into primary is 6, entry into middle is at 11, 
	* entry into secondar7 is 14, entry into higher sec is at 16
	* Use age to adapt profile. For example a 17 year old with higher secondary
	* has 11 years of education, not 12
	
	* Primary kids, allow entry from 5
	replace educy = educy - (5 - (age - 5)) if B4_q7 == "06" & inrange(age,5,11)
	* Middle kids
	replace educy = educy - (3 - (age - 11)) if B4_q7 == "07" & inrange(age,11,14)
	* Secondary
	replace educy = educy - (2 - (age - 14)) if B4_q7 == "08" & inrange(age,14,16)
	* Higher secondary
	replace educy = educy - (2 - (age - 16)) if B4_q7 == "10" & inrange(age,16,18)
	
	* Correct if B4_q7 incorrect (e.g., a five year old high schooler)
	replace educy = educy - 4 if (educy > age) & (educy > 0) & !missing(educy) 
	replace educy = 0 if (educy > age) & (age < 4) & (educy > 0) & !missing(educy) 
	replace educy = educy - (8 - age) if (educy > age) & (age >= 4 & age <=8) & (educy > 0) & !missing(educy) 
	replace educy = 0 if educy < 0
	
	label var educy "Years of education"

** EDUCATIONAL LEVEL 1
	destring B4_q7, gen(genedulev)
	gen byte edulevel1 = .
	replace edulevel1= 1 if genedulev<=4 
	replace edulevel1 = 2 if genedulev == 5 & educy < 5 // Primary incomplete
	replace edulevel1 = 3 if genedulev == 6 & educy >= 5  // Primary complete
	replace edulevel1 = 4 if genedulev == 7 & educy < 12  // Secondary incomplete
	replace edulevel1 = 5 if genedulev == 8 & educy >= 12  // Secondary complete
	replace edulevel1 = 6 if genedulev == 10| genedulev ==11 
	replace edulevel1= 7 if genedulev==12 | genedulev==13
	replace edulevel1=. if  genedulev==02 | genedulev==03 | genedulev==04
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
	destring B5_q3, gen(lstatus_year)
	recode lstatus_year  11/72=1 81 82=2 91/98=3 99=.
	destring  B5_q8, gen(secondary_help)
	recode secondary_help  11/72=1 81 82=2 91/99=.
	replace lstatus_year = 1 if secondary_help == 1 & lstatus_year != 1
	replace lstatus = . if age < lb_mod_age
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Not employed" 
	label values lstatus_year lbllstatus_year
	drop secondary_help


** EMPLOYMENT STATUS
	destring B6_q41, gen(empstat)
	recode empstat 11=4 12=3 21=2 31 41 51 61 62 71 72=1 81/99=.
	replace empstat=. if lstatus != 1 | (age < lb_mod_age & age != .)
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** EMPLOYMENT STATUS LAST YEAR
	destring B5_q3, gen(empstat_year)
	recode empstat_year 11=4 12=3 21=2 31 41 51 61 62 71 72=1 81/99=.
	destring B5_q8, gen(secondary_help)
	recode secondary_help  11=4 12=3 21=2 31 41 51 61 62 71 72=1 81/99=.
	replace empstat_year = secondary_help if missing(empstat_year) & lstatus_year == 1
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
	drop secondary_help
	
	
** EMPLOYMENT STATUS - SECOND JOB
	gen has_job_primary = inlist(B6_q41,"11", "12", "21", "31", "41", "51") | inlist(B6_q41, "61", "62", "71", "72")
	destring B6_q42, gen(empstat_2)
	recode empstat_2 11=4 12=3 21=2 31 41 51 61 62 71 72=1 81/99=.
	replace empstat_2=. if lstatus != 1 | (age < lb_mod_age & age != .)
	replace empstat_2 = . if has_job_primary == 0 & !missing(empstat_2)
	label var empstat_2 "Employment status - second job"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
	
	** Third job in the past week 
	destring B6_q43, gen(empstat_3)
	recode empstat_3 11=4 12=3 21=2 31 41 51 61 62 71 72=1 81/99=.
	replace empstat_3=. if lstatus != 1 | (age < lb_mod_age & age != .)
	replace empstat_3 = . if has_job_primary == 0 & !missing(empstat_3)
	
	** Fourth job
	destring B6_q44, gen(empstat_4)
	recode empstat_4 11=4 12=3 21=2 31 41 51 61 62 71 72=1 81/99=.
	replace empstat_4=. if lstatus != 1 | (age < lb_mod_age & age != .)
	replace empstat_4 = . if has_job_primary == 0 & !missing(empstat_4)

** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
	destring B5_q8, gen(empstat_2_year)
	recode empstat_2_year  11=4 12=3 21=2 31 41 51 61 62 71 72=1 81/99=.
	replace empstat_2_year = . if lstatus_year != 1
	
	destring B5_q3, gen(helper)
	destring B5_q8, gen(secondary_helper)
	replace empstat_2_year = . if inrange(helper, 81, 99) & inrange(secondary_helper, 11, 72)
	label var empstat_2_year "Employment status - second job"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
	drop helper secondary_helper

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
	destring B6_q41, gen(nlfreason)
	recode nlfreason 11/82=. 91=1 92 93=2 94=3 95=4 96/98=5
	replace nlfreason = . if lstatus != 3 | (age < lb_mod_age & age != .)
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen byte unempldur_u=.	
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	gen red_indus =substr(B6_q51,1,2)
	destring red_indus, replace 
	
	gen industry = .
	
	replace industry=1 if red_indus>=00 & red_indus<=09 
	replace industry=2 if red_indus>=10 & red_indus<=14
	replace industry=3 if red_indus>=15 & red_indus<=39
	replace industry=4 if red_indus>=40 & red_indus<=41 
	replace industry=5 if red_indus>=45 & red_indus<=45 
	replace industry=6 if red_indus>=50 & red_indus<=59
	replace industry=7 if red_indus>=60 & red_indus<=64
	replace industry=8 if red_indus>=65 & red_indus<=74
	replace industry=9 if  red_indus==75
	replace industry=10 if red_indus>=80 & red_indus<=99
	
	replace industry=. if lstatus != 1 | (age < lb_mod_age & age != .)
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Community and family oriented services" 10 "Others"
	label values industry lblindustry
	drop red_indus


** INDUSTRY 1
	gen byte industry1=industry
	recode industry1 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry1=. if lstatus!=1
	label var industry1 "1 digit industry classification (Broad Economic Activities)"
	la de lblindustry1 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1 lblindustry1


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION
	gen industry_orig=B6_q51
	replace industry_orig= "" if lstatus!=1
	label var industry_orig "Original Industry Codes"


** OCCUPATION CLASSIFICATION
	gen code_04 = substr(B6_q20,1,1)
	
	destring code_04, replace
	recode code_04 (0 = 99)
	gen occup = .
	replace occup = code_04 if lstatus == 1 & (age >= lb_mod_age & age != .)
	label var occup "1 digit occupational classification"
	label define occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup
	drop code_04


** SURVEY SPECIFIC OCCUPATION CLASSIFICATION
	destring B6_q20, gen(occup_orig) force
	replace occup_orig=. if lstatus!=1
	label var occup_orig "Original Occupational Codes"


** FIRM SIZE
	* The variable is not available in the 2005 dataset
	gen firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"

	gen firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK (for main job only)
	egen whours= rowtotal(B6_q141) 
	replace whours = whours*8
	replace whours = . if lstatus!=1 | (age< lb_mod_age & age!=.)
	label var whours "Hours of work in last week"


** WAGES
	gen double wage = B6_q151
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
	destring B6_q52, gen(red_indus)
	
	gen industry_2 = .
	replace industry_2=1 if red_indus>=00 & red_indus<=09 
	replace industry_2=2 if red_indus>=10 & red_indus<=14
	replace industry_2=3 if red_indus>=15 & red_indus<=39
	replace industry_2=4 if red_indus>=40 & red_indus<=41 
	replace industry_2=5 if red_indus>=45 & red_indus<=45 
	replace industry_2=6 if red_indus>=50 & red_indus<=59
	replace industry_2=7 if red_indus>=60 & red_indus<=64
	replace industry_2=8 if red_indus>=65 & red_indus<=74
	replace industry_2=9 if  red_indus==75
	replace industry_2=10 if red_indus>=80 & red_indus<=99
	
	replace industry_2 = . if lstatus != 1 | (age < lb_mod_age & age != .)
	replace industry_2 = . if missing(empstat_2)
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
	gen industry_orig_2=B6_q52
	label var industry_orig_2 "Original Industry Codes - Second job"


** OCCUPATION CLASSIFICATION - SECOND JOB
	gen occup_2=  .
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2


** WAGES - SECOND JOB
	gen double wage_2= B6_q152
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
	gen byte rprevious_juris=.
	label var rprevious_juris "Region of previous residence jurisdiction"
	la de lblrprevious_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rprevious_juris lblrprevious_juris


**REGION OF PREVIOUS RESIDENCE
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
