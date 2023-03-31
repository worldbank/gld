

clear
set more off
set mem 800m

*----------1.2: Set directories------------------------------*

local path_in "Y:\GLD\IND\IND_1999_EUS\IND_1999_EUS_v01_M\Data\Stata"
local path_output "Y:\GLD\IND\IND_1999_EUS\IND_1999_EUS_v01_M_v02_A_GLD\Data\Harmonized"

*----------1.3: Database assembly------------------------------*

* Start with Block 5.3 as this has several lines per individual
	use "`path_in'\Block53-sch10-and-10dot1-Records-combined.dta", clear

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

	drop if missing(B53_q4)

	gen first = 1 if B53_q4 == B53_q20
	replace first = 2 if B53_q4 != B53_q20

	destring B53_q4, gen(priority_tag)
	gen num_status = priority_tag
	* Classify the level of priority
	recode priority_tag 11/72=1 81 82=2 91/98=3 99=.

	* Decreasing order of number of days worked
	bys Key_prsn_slno: egen totdays = sum(B53_q14)
	sum totdays
	local max = r(max)
	assert `max' == 7

	gen neg_days = -(B53_q14)


	* Generate idp
	gen idp = Key_prsn_slno

	* Activity status should be unique per activity
	duplicates drop idp B53_q4, force

	* Sorting
	sort idp first priority_tag neg_days num_status
	bys idp: gen runner = _n

	* How many cases wherein this priority order is not followed
	count if B53_q4! =  B53_q20 & runner==1

	********************************************************************************
	********************************************************************************
	keep runner B53_q4 B53_q5 B53_q14 B53_q17 B53_q18 B53_q20 B53_q21  B53_q22 Key_Hhold_slno Key_prsn_slno
	reshape wide B53_q4 B53_q5 B53_q14 B53_q17 B53_q18 B53_q22, i(Key_prsn_slno) j(runner)

	drop B53_q222  B53_q223 B53_q224
	rename B53_q221 B53_q22

	* Check whether activities correctly coded in order - there should not be a third activity if
	* there is no second activity.
	count if missing(B53_q41) & !missing(B53_q42)
	count if missing(B53_q42) & !missing(B53_q43)
	count if missing(B53_q43) & !missing(B53_q44)

	gen ID = Key_prsn_slno

	tempfile weekly_act
	save `weekly_act'


	* Continue with block 6 since it has 9455 observations but 9433 unique ones. There are 22 perfect pairs.
	use "`path_in'\Block6-sch10-persons-unemployed-7daysweek-Records.dta", clear
	capture which dups
	if _rc != 0 ssc install dups
	dups
	dups, drop key(Key_Prsn_slno)
	drop _expand

	gen ID = Key_Prsn_slno

	tempfile weekly_unemp
	save `weekly_unemp'

	* Next is Block 5.2 which lists secondary activties. 24.034 individuals have a secondary
	* activity, 2.173 of them have two.
	use "`path_in'\Block52-sch10-and-10dot1-Records-combined.dta", clear
	destring B52_q17, replace
	keep B52_q2 B52_q3 B52_q5 B52_q6 B52_q7 B52_q8 B52_q9 B52_q10 B52_q11 B52_q12 B52_q13 B52_q14 B52_q15 B52_q16 Key_Hhold Key_Prsn B52_q17
	reshape wide B52_q3 B52_q5 B52_q6 B52_q7 B52_q8 B52_q9 B52_q10 B52_q11 B52_q12 B52_q13 B52_q14 B52_q15 B52_q16, i(Key_Prsn) j(B52_q17)
	gen ID = Key_Prsn

	tempfile subsidiary_act
	save `subsidiary_act'

	* Start process with individual block 4
	use "`path_in'\Block4-sch10-and-10dot1-Records-combined.dta", clear
	* Merging gives 2314 cases of non
	* match, exactly 1157 on either. These should match but I cannot find the logic of the mistake that
	* caused them to diverge.

	* Note that all these cases are from the same state - Lakshadweep (https://en.wikipedia.org/wiki/Lakshadweep). The full sample size is 2769, so we lose about 40% of the sample for this state for the weekly status information.
	* Given that it is a far off archipelago state that has a small population and a very specific economy it is a problem we need to note but that should not be too problematic
	gen ID = Key_prsn

	* Merge block 4 with 7 day time spent info
	merge 1:1 ID using `weekly_act', keep(match master) nogen

	* Merge with Block 5.1 -
	* Same issue with merge errors in Lakshadweep.
	merge 1:1 Key_prsn using "`path_in'\Block51-sch10-and-10dot1-Records-combined.dta", keep(match master) nogen

	* Merge with Block 5.2 (which has more than one entry per
	* individual, so treated earlier and saved as
	* `subsidiary_act'
	* Note that 52 don't match, all from Lakshadweep
	merge 1:1 ID using `subsidiary_act', keep(master match) nogen

	* Merge with Block 6
	* Note that 29 don't match, all from Lakshadweep
	merge 1:1 ID using `weekly_unemp', keep(master match) nogen

	* Merge with Block 7.1
	* Note that 354 don't match, all from Lakshadweep
	drop Key_prsn_slno Key_Prsn Key_Prsn_slno
	gen Key_prsn_slno = ID
	merge 1:1 Key_prsn_slno using "`path_in'\Block71-sch10-Persons-availability-for-work-Records.dta", keep(master match) nogen

	* Merge with Block 7.2
	* Note that 354 don't match, all from Lakshadweep
	gen Key_Prsn_slno = ID
	merge 1:1 Key_Prsn_slno using "`path_in'\Block72-sch10-Persons-change-of-work-Records.dta", keep(master match) nogen
	

*<_hhid_>
	gen hhid = Key_Hhold
	egen casa= concat(fsu_no visit_no seg_no Stg2_stratm Hhold_Slno)
	replace hhid = casa if missing(hhid)
	drop casa
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	*gen id_helper = substr(Key_prsn,-3,3)
	*egen  str11 pid = concat(hhid id_helper)
	gen pid = Key_Prsn_slno
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
	destring B53_q20, gen(lstatus)
	recode lstatus  (11/72 98 = 1) (81=2) (82 91/97=3) (99=.)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_empstat_alt_>
	destring B53_q20, gen(empstat_alt)
	recode empstat_alt (11=4) (12=3) (61 62 21=2) (31 71 72 = 1) (81/97 99=.) (41 51 98 = 6)
	replace empstat_alt=. if lstatus != 1 | (age < minlaborage & age != .)
	label var empstat_alt "Employment status during past week primary job 7 day recall"
	la de lblempstat_alt 1 "Regular employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" 6 "Casual employee"
	label values empstat_alt lblempstat_alt
*</_empstat_alt_>

keep pid empstat_alt 

save "Y:/GLD-Harmonization/529026_MG/Countries/IND/empstat_alt\IND_1999_empstat_alt.dta"