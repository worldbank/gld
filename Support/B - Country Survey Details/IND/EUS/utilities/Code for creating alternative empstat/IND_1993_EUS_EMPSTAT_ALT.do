
clear
set more off
set mem 800m

*----------1.2: Set directories------------------------------*

local path_in "Y:\GLD\IND\IND_1993_EUS\IND_1993_EUS_v01_M\Data\Stata"
local path_output "Y:\GLD\IND\IND_1993_EUS\IND_1993_EUS_v01_M_v03_A_GLD\Data\Harmonized"

*----------1.3: Database assembly------------------------------*

* Start with Block 5 as this has several lines per individual
use "`path_in'\Block-5-Persons-Activity-Records.dta", clear

* In a few cases the activity serial number starts with 0. Need to make HH-Person-Serial unique
destring B5_q3, gen(serial)
tab serial
* From inspection of cases with 0, often followed by cases with a 1 but status codes is empty

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


/* Need to classify activity status following this:

	a. Working status
	b. Non-working status but seeking employment
	c. Neither working nor available for work

	In this special case, we add the first rule that B5_q4 should be equal to B5_q19
*/

drop if missing(B5_q4)

gen first = 1 if B5_q4 == B5_q19
replace first = 2 if B5_q4 != B5_q19

destring B5_q4, gen(priority_tag)
gen num_status = priority_tag
* Classify the level of priority
recode priority_tag 11/72=1 81 82=2 91/98=3 99=.

* Decreasing order of number of days worked
gen neg_days = -(B5_q14)

* Order the records such that priority 1 comes first


* Generate PID
egen PID = concat(Hhold_Key Prsn_slno)

sort PID first priority_tag neg_days num_status
bys PID: gen runner = _n

* Extract original serial number
destring B5_q3, gen(original_serial)

* How many cases wherein this priority order is not followed
count if B5_q4! =  B5_q19 & runner==1 & B5_q19 != "" //4 cases
drop if B5_q4! =  B5_q19 & runner==1 & B5_q19 != ""

/*==============================================================================
What are the implications?

1. Individual's employment status can be determined on the basis of status 1 or the
	current weekly activity status. No need to recode everything as both variables
	are the same!

2. The NSO under the CWA is the same as activity 1

3. These is no overlap between activity 2 and activity 1!

==============================================================================*/


keep B5_q4 B5_q5 B5_q14 B5_q15 B5_q16 B5_q17 Hhold_Key Prsn_slno runner B5_q18 B5_q19 B5_q20 B5_q21  B5_q22
reshape wide B5_q4 B5_q5 B5_q14 B5_q15 B5_q16 B5_q17, i( Hhold_Key Prsn_slno) j(runner)

tempfile weekly_act
save `weekly_act'

use "`path_in'\Block-4-Persons-Records.dta", clear

* From having merged I know that there are two errors in HH Keys, where the first number is 6 when the village code starts with 4, see
* tab Hhold_Key if Vill_ == "44292"
* tab Hhold_Key if Vill_ == "44293"
replace Hhold_Key = "44293210" if Hhold_Key == "64293210"
replace Hhold_Key = "44292210" if Hhold_Key == "64292210"

* Additionally one case HH Key is 44374*0*04 for HH 04 when all others are 44374*2*04
* tab Hhold_Key if Vill_ == "44374"
replace Hhold_Key = "44374204" if Hhold_Key == "44374004"

* Merge Individual 12 month info with 7 day info
merge 1:1 Hhold_Key Prsn_slno using `weekly_act',  nogen

* Merge with HH info
merge m:1 Hhold_Key using "`path_in'\Block-1-3-Household-Records", assert(match) nogen


*<_hhid_>
/* <_hhid_note>

	From different surveys a str9 should be created. In later surveys this is:
	FSU (str5) + Hamlet (str1) + 2nd Stage Sample (str1) + Sample HH Id (str2).

	Here Hhold_Key is str8 of FSU + Stage 2 Stratum + Sample HH Id. Add subround to make str9
	From preparing I notice there is one case where Stage2_Stratum is "0", when this makes no sense,
	HH Key has code 2, so first amend that
</_hhid_note> */
	replace Stage2_Stratum = "2" if Stage2_Stratum == "0"
	egen str9 hhid = concat(Vill_Blk_Slno SubRound Stage2_Stratum Hhold_no)
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	gen pid_helper = substr(Prsn_slno,2,.)
	egen  str11 pid = concat(hhid pid_helper)
	label var pid "Individual ID"
	drop pid_helper
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
	destring B5_q19, gen(lstatus)
	recode lstatus  (11/72 98 = 1) (81=2) (82 91/97=3) (99=.)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_empstat_alt_>
	destring B5_q19, gen(empstat_alt)
	recode empstat_alt (11=4) (12=3) (61 62 21=2) (31 71 72 =1) (81/97 99=.) (41 51 98 = 6)
	replace empstat_alt=. if lstatus != 1 | (age < minlaborage & age != .)
	label var empstat_alt "Employment status during past week primary job 7 day recall"
	la de lblempstat_alt 1 "Regular employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" 6 "Casual employee"
	label values empstat_alt lblempstat_alt
*</_empstat_alt_>

keep pid empstat_alt 

save "Y:/GLD-Harmonization/529026_MG/Countries/IND/empstat_alt\IND_1993_empstat_alt.dta", replace