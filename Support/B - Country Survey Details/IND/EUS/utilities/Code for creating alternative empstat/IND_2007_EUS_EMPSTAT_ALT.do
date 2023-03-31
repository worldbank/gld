
clear
set more off
set mem 800m

*----------1.2: Set directories------------------------------*

local path_in "Y:/GLD/IND/IND_2007_EUS/IND_2007_EUS_v01_M/Data/Stata"
local path_output "Y:/GLD/IND/IND_2007_EUS/IND_2007_EUS_v01_M_v02_A_GLD/Data/Harmonized"

*----------1.3: Database assembly------------------------------*

* Start with Block 5.3 as this has several lines per individual
use "`path_in'/Block-5-members-time-disposition-records.dta", clear

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
==============================================================================*/


/* Need to classify activity status into the following:

	a. Working status
	b. Non-working status but seeking employment
	c. Neither working nor available for work

*/

gen first = 1 if B5_c4 == B5_c18
replace first = 2 if B5_c4 != B5_c18

destring B5_c4, gen(priority_tag)
gen num_status = priority_tag
* Classify the level of priority
recode priority_tag 11/72=1 81 82=2 91/98=3 99=.

* Decreasingorder of number of days worked
gen neg_days = -(B5_c14)

* Generate PID
egen PID = concat(key_hhold B5_c1)

sort PID first priority_tag neg_days num_status
bys PID: gen runner = _n

* Extract original serial number
destring B5_c3, gen(original_serial)

* How many cases wherein this priority order is not followed
count if B5_c4! =  B5_c18 & runner==1

/*==============================================================================
What are the implications?

1. Individual's employment status can be determined on the basis of status 1 or the
	current weekly activity status. No need to recode everything as both variables
	are the same!

2. The NSO under the CWA is the same as activity 1

3. These is no overlap between activity 2 and activity 1!

==============================================================================*/

keep B5_c4 B5_c5 B5_c14 B5_c15 B5_c16 B5_c17 B5_c18 B5_c19 B5_c20 key_hhold  B5_c1 runner
reshape wide B5_c4 B5_c5 B5_c14 B5_c15 B5_c16 B5_c17 B5_c18 B5_c19 B5_c20, i(key_hhold B5_c1) j(runner)

* Check whether activities correctly coded in order - there should not be a third activity if
* there is no second activity.
count if missing(B5_c41) & !missing(B5_c42)
count if missing(B5_c42) & !missing(B5_c43)
count if missing(B5_c43) & !missing(B5_c44)


tempfile weekly_act
save `weekly_act'

* Generate unique id variable at person level
egen key_memb = concat(key_hhold B5_c1)

** Begin merging the other datasets

* Merge with block 4
merge m:1 key_memb using "`path_in'/Block-4-demographic-usual-activity-members-records.dta" , keep(master match) nogen

* Merge with block 1 - 3
gen key_Hhold = key_hhold

* Start with Block 1
merge m:1 key_Hhold using "`path_in'/Block-1-sample-household-identification-records.dta" , keep(master match) nogen

* Block 3dot1 - this data is not relevant for GLD
merge 1:1 key_memb using "`path_in'/Block-3dot1-out-migrants-records.dta" , keep(master match) nogen

* Block 3 only
gen Key_hhold = key_hhold
merge m:1 Key_hhold using "`path_in'/Block-3-household-characteristics-ecords.dta" , keep(master match) nogen

* Merge with block 6
merge 1:1 key_memb using "`path_in'/Block-6-members-migration-records.dta" , keep(master match) nogen


*<_hhid_>
/* <_hhid_note>

	From different surveys a str9 should be created. In later surveys this is:
	FSU (str5) + seg_no (str1) + 2nd Stage Sample (str1) + Sample HH Id (str2).
	No need to have str11 or str13, fewer characters already specify uniquely
</_hhid_note> */
	egen str9 hhid = concat(FSU sub_block Ss_stratum Sample_hhold_No)
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
/* <_pid_note>

	Because there are so many variables for the same sample individual id, I drop
	them and keep only the data from block 5

</_pid_note> */
	count if B5_c1 != B4_c1 | B5_c1 ! = B6_c1 // all equal

	egen  str11 pid = concat(hhid B5_c1)
	label var pid "Individual ID"
	isid pid
*</_pid_>


*<_age_>
	gen age = B4_c5
	label var age "Individual age"
*</_age_>



*<_minlaborage_>
	gen byte minlaborage = 0
	label var minlaborage "Labor module application age"
*</_minlaborage_>



*<_lstatus_>
	destring B5_c181, gen(lstatus)
	recode lstatus (11/72 98 = 1) (81=2) (82 91/97=3) (99=.)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_empstat_alt_>
	destring B5_c181, gen(empstat_alt)
	recode empstat_alt (11=4) (12=3) (61 62 21=2) (31 71 72 =1) (81/97 99=.) (41 42 51 98 = 6)
	replace empstat_alt=. if lstatus != 1 | (age < minlaborage & age != .)
	label var empstat_alt "Employment status during past week primary job 7 day recall"
	la de lblempstat_alt 1 "Regular employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" 6 "Casual employee", replace
	label values empstat_alt lblempstat_alt
*</_empstat_alt_>


keep pid empstat_alt 

save "Y:/GLD-Harmonization/529026_MG/Countries/IND/empstat_alt\IND_2007_empstat_alt.dta", replace