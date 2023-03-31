

clear
set more off
set mem 800m

*----------1.2: Set directories------------------------------*

local path_in "Y:/GLD/IND/IND_2005_EUS/IND_2005_EUS_v01_M/Data/Stata"
local path_output "Y:/GLD/IND/IND_2005_EUS/IND_2005_EUS_v01_M_v02_A_GLD/Data/Harmonized"

*----------1.3: Database assembly------------------------------*

* Start with Block 5.3 as this has several lines per individual
use "`path_in'/Block-6-Persons-daily-activity-time-disposition-reecords.dta", clear

/*==============================================================================
Current weekly activity is selected based on this order:
	1. Activity status classification (see below)
	2. Number of days worked in a week
	3. If number of days are equal between two employment activities, the status
	code that is smaller in value is taken as the CWA (e.g., activites 11 and 51
	are worked for 3.5 days each; activity 11 will be the CWA because it is smaller
	in value than 51.

	Following this order, CWA = activity status 1
==============================================================================*/

/* Need to classify activity status into the following:

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
merge m:1 Person_key using "`path_in'/Block-4-Persons-demographic-particulars-records.dta" , keep(master match) nogen

* Start with Block 1
merge m:1 Hhold_key using "`path_in'/Block-1-2-Household-ID-records.dta" , keep(master match) nogen

* Block 5
merge 1:1 Person_key using "`path_in'/Block-5-Persons-usual-activity-records.dta" , keep(master match) nogen


*<_hhid_>
/* <_hhid_note>

	From different surveys a str9 should be created. In later surveys this is:
	FSU (str5) + seg_no (str1) + 2nd Stage Sample (str1) + Sample HH Id (str2).
	No need to have str11 or str13, fewer characters already specify uniquely
</_hhid_note> */
	egen str9 hhid = concat(FSU Segment stage2stratum Hhhld_SlNo)
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
/* <_pid_note>

	Because there are so many variables for the same sample individual id, I drop
	them and keep only the data from block 5

</_pid_note> */
	egen  str11 pid = concat(hhid B6_q1)
	label var pid "Individual ID"
	isid pid
*</_pid_>



*<_age_>
	gen age = B4_q5
	label var age "Individual age"
*</_age_>


*<_minlaborage_>
	gen byte minlaborage = 0
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*<_lstatus_>
	destring B6_q41, gen(lstatus)
	recode lstatus  (11/72 98 = 1) (81=2) (82 91/97=3) (99=.)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_empstat_alt_>
	destring B6_q41, gen(empstat_alt)
	recode empstat_alt (11=4) (12=3) (61 62 21=2) (31 71 72 =1) (81/97 99=.) (41 51 98 = 6)
	replace empstat_alt=. if lstatus != 1 | (age < minlaborage & age != .)
	label var empstat_alt "Employment status during past week primary job 7 day recall"
	la de lblempstat_alt 1 "Regular employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" 6 "Casual employee"
	label values empstat_alt lblempstat_alt
*</_empstat_alt_>


keep pid empstat_alt 

save "Y:/GLD-Harmonization/529026_MG/Countries/IND/empstat_alt\IND_2005_empstat_alt.dta"