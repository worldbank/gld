
*----------1.1: Initial commands------------------------------*

clear
set more off
set mem 800m

capture which distinct
if _rc ssc install distinct

*----------1.2: Set directories------------------------------*

local path_in "Y:\GLD\IND\IND_1987_EUS\IND_1987_EUS_v01_M\Data\Stata"
local path_output "Y:\GLD\IND\IND_1987_EUS\IND_1987_EUS_v01_M_v03_A_GLD\Data\Harmonized"

*----------1.3: Database assembly------------------------------*

* Start process with individual block 4
tempfile block4 block4short

use "`path_in'/Block-4-Persons-Demographic-current-weekly-activity- Records.dta", clear

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
use "`path_in'/Block-5-Persons-Daily- activity- time-disposion-Records.dta", clear

* Drop the invalid data to arrive with total consistent with that reported by MOSPI
drop if missing(B5_q13)
count // same total as reported by IND Ministry

* Generate person serial number from the unique person ID variable, Person_key
gen Prsn_slno = substr(Person_key, -3, 3)

********************************************************************************
********************************************************************************
* Sorting procedure

/*==============================================================================
Current weekly activity is selected based on this order:
	1. Equal to current weekly activity variable
	2. Activity status classification (see below)
	3. Number of days worked in a week
	4. If number of days are equal between two employment activities, the status
	code that is smaller in value is taken as the CWA (e.g., activites 11 and 51
	are worked for 3.5 days each; activity 11 will be the CWA because it is smaller
	in value than 51.

	Rule #1 is added because otherwise, CWA will not be entirely equal to activity status 1
===============================================================================*/


/* Need to classify activity status into the following:

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

use "`path_in'/Block-1-3-Household-Records", clear

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
use "`path_in'/Block-7-Persons- usual-activity-statuscode-11to94-Records", clear

	* Since no pattern found, drop first record
	duplicates drop Person_key, force

	save `block7'

* Proceed with block 6
use "`path_in'/Block-6--Persons-Usual-activity- migration-Records.dta", clear

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

*<_hhid_>
/* <_hhid_note>

	From different surveys a str9 should be created. In later surveys this is:
	FSU (str5) + Hamlet (str1) + 2nd Stage Sample (str1) + Sample HH Id (str2).

	Here Hhold_Key is str8 of FSU + Stage 2 Stratum + Sample HH Id. Add subround to make str9
	From preparing I notice there is one case where Stage2_Stratum is "0", when this makes no sense,
	HH Key has code 2, so first amend that
</_hhid_note> */
	gen hamlet = substr(Vill_Blk_No, -1, 1)
	gen psu_helper = FSU_SlNo
	replace psu_helper = FSU_No if missing(psu_helper)
	egen hhid = concat(psu_helper hamlet Sub_stratum Hhold_No)
	drop psu_helper
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	egen  str11 pid = concat(hhid Prsn_Slno)
	label var pid "Individual ID"
	isid pid
*</_pid_>

*<_age_>
	gen age = B4_q5
	label var age "Individual age"
*</_age_>



*<_minlaborage_>
	gen byte minlaborage = 5
	label var minlaborage "Labor module application age"
*</_minlaborage_>



*<_lstatus_>
	destring B4_q11, gen(lstatus)
	recode lstatus  (11/72 98 = 1) (81=2) (82 91/97=3) (99=.)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_empstat_alt_>
	destring B4_q11, gen(empstat_alt)
	recode empstat_alt (11=4) (12=3) (61 62 21=2) (31 71 72 =1) (81/97 99=.) (41 51 98 = 6)
	replace empstat_alt=. if lstatus != 1 | (age < minlaborage & age != .)
	label var empstat_alt "Employment status during past week primary job 7 day recall"
	la de lblempstat_alt 1 "Regular employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" 6 "Casual employee"
	label values empstat_alt lblempstat_alt
*</_empstat_alt_>

keep pid empstat_alt 

save "Y:/GLD-Harmonization/529026_MG/Countries/IND/empstat_alt\IND_1987_empstat_alt.dta", replace