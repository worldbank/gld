
clear
set more off
set mem 800m

*----------1.2: Set directories------------------------------*

local path_in     "Y:/GLD/IND/IND_2004_EUS/IND_2004_EUS_v01_M/Data/Stata"
local path_output "Y:/GLD/IND/IND_2004_EUS/IND_2004_EUS_v01_M_v02_A_GLD/Data/Harmonized"

*----------1.3: Database assembly------------------------------*


* Start with Block 5.3 as this has several lines per individual
use "`path_in'\Block_5pt3_level_06", clear

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

destring Current_day_activity_Status, gen(priority_tag)
gen num_status = priority_tag
* Classify the level of priority
recode priority_tag 11/72=1 81 82=2 91/98=3 99=.

* Decreasingorder of number of days worked
gen neg_days = -(Total_no_of_days_in_current_acti)


* Order the records such that priority 1 comes first


sort PID priority_tag neg_days num_status
bys PID: gen runner = _n

* Extract original serial number
destring Srl_no_of_current_day_activity, gen(original_serial)

* How many cases wherein this priority order is not followed
count if Current_day_activity_Status! =  Current_weekly_activity_status & runner==1 //0
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
destring Srl_no_of_current_day_activity, replace

* Ensure that nominal days work is constant within PID
destring No_of_days_nominal_work, gen(days_num)
by PID: egen constantdays = max(days_num)
drop days_num

keep Current_day_activity_Status Current_day_activity_NIC_1998_co Total_no_of_days_in_current_acti ///
Wage_salary_cash_during_the_week - Wage_salary_earnings_total_durin ///
Current_weekly_activity_status - Current_weekly_activity_NCO_1968 PID runner

/*==============================================================================
Issue: Current weekly activity is constant across Person id, but there are cases
		wherein the industry and occupation for each activity vary! Ideally, there
		should be 1:1 correspondence between NIC/NCO and CWA

Resolve: Include the NCO in the reshaping to wide, then keep only the first instance
But first, make sure that the first instance for employed is nonmissing
==============================================================================*/

* Because some variables are too long, I rename it below:
rename Current_day_activity_NIC_1998_co Current_activity_NIC1998_
rename Total_no_of_days_in_current_acti Total_no_days_activity_
rename Wage_salary_cash_during_the_week Total_cash_
rename Wage_salary_earnings_kind_during Total_kind_
rename Wage_salary_earnings_total_durin Total_earnings_
rename Current_weekly_activity_NCO_1968 Current_activity_NCO1968_

reshape wide Current_day_activity_Status Current_activity_NIC1998_ Total_no_days_activity_ ///
 Total_cash_ - Total_earnings_ Current_activity_NCO1968_, i(PID) j(runner)

destring Current_weekly_activity_status, gen(cwa_e)

*==============================================================================
* Need to count how many non-zero responses for industry/occupation variables

count if Current_activity_NCO1968_1 == "" & inrange(cwa_e, 11, 72)
count if Current_activity_NCO1968_2 == "" & inrange(cwa_e, 11, 72)

* there are 2,613 employed people with no occupation code

count if missing(Current_activity_NCO1968_1) & ///
(!missing(Current_activity_NCO1968_2) | !missing(Current_activity_NCO1968_3) | ///
!missing(Current_activity_NCO1968_4) | !missing(Current_activity_NCO1968_5) ///
& inrange(cwa_e, 11, 72))
* 7 cases wherein occupation code is recorded under the second instance
* Move this to first instance; ignore second instance

replace Current_activity_NCO1968_1 = Current_activity_NCO1968_2 if missing(Current_activity_NCO1968_1) ///
& !missing(Current_activity_NCO1968_2) & inrange(cwa_e, 11, 72)

count if Current_activity_NCO1968_1 == "" & inrange(cwa_e, 11, 72)
* Still 2606 employed people with no occupation code. Nothing we can do!
* 2606/602,833 employed people = 0.4%

* Next step, drop second, third and fourth NIC/NCO variables
drop Current_activity_NCO1968_2 Current_activity_NCO1968_3 ///
	Current_activity_NCO1968_4 Current_activity_NCO1968_5

ren Current_activity_NCO1968_1 Current_activity_NCO_1968

* Make sure that CWA = first activity
count if Current_day_activity_Status1 != Current_weekly_activity_status //zero

* Make sure that CWA is available for all
count if missing(Current_weekly_activity_status)  //zero

* Make sure that second is not missing when third is not missing
count if missing(Current_day_activity_Status2) & !missing(Current_day_activity_Status3) //zero

**** Looks like data is in good shape!

tempfile weekly_act
save `weekly_act'

** Begin merging the other datasets
* Merge with other block 5: usual principal activity status
merge 1:1 PID using "`path_in'/Block_5pt1_level_04.dta", assert(match) nogen

* Merge with subsidary activity status
tempfile subsidiary
preserve
	use "`path_in'/Block_5pt2_level_05.dta", clear
	rename Type_of_job_contract Type_of_job_contract2
	rename No_of_workers_in_the_enterprise  No_of_workers_in_the_enterprise2
	rename Enterprise_type Enterprise_type2
	rename Availability_of_social_security_ Availability_of_social_security2
	keep PID Type_of_job_contract2 Usual_subsidiary_economic_activi V22 V23 No_of_workers_in_the_enterprise2 Enterprise_type2 Availability_of_social_security2
	save `subsidiary'
restore

merge 1:1 PID using `subsidiary', assert(match master) nogen

* Merge with block 4
merge m:1 PID using "`path_in'/Block_4_level_03", assert(match) nogen

* Merge with blocks 1 - 3 level 01
* Should merge all, but one entry in using (Block 1 2 3) has HHID == "" which does not match evidently -> use keep
merge m:1 HHID using "`path_in'/Block_1_2_and_3_level_01.dta", keep(master match) nogen

* Merge with block 3pt1_level 02 - loan indebtedness
	** This is not needed for the purposes of the GLD


* Merge with block 6
preserve
	tempfile block62
	* Brief issue with Block 6
	use "`path_in'/Block_6_level_07.dta", clear
	keep PID Duration_spell_of_unemployment Whether_ever_worked Last_employment_Duration Last_employment_Status Last_employment_NIC_98 Last_employment_NCO_68 Reason_for_break_in_employment Reason_for_quitting_the_job
	* Four changes since PID has random blank space, replace with "0"
	replace PID = regexr(PID," ","0")
	save `block62'
restore

merge 1:1 PID using "`block62'", assert(match master) nogen

* Before merging with block 7 - 1
preserve
	tempfile block7
	use "`path_in'/Block_7pt1_level_08.dta", clear
	duplicates drop PID, force
	* there are 2 records with the same PID and same labor market information, just drop one of them
	save `block7'
restore

merge 1:1 PID using `block7', assert(match master) nogen


* Merge with block 7 - 2
preserve
	tempfile block72
	use "`path_in'/Block_7pt2_level_09.dta", clear
	duplicates drop PID, force
	* likewise, there are 2 records with the same PID and same labor market information, just drop one of them
	save `block72'
restore

merge 1:1 PID using `block72', assert(match master) nogen


*<_hhid_>
/* <_hhid_note>

	From different surveys a str9 should be created. In later surveys this is:
	FSU (str5) + seg_no (str1) + 2nd Stage Sample (str1) + Sample HH Id (str2).
	No need to have str11 or str13, fewer characters already specify uniquely
</_hhid_note> */
	egen str9 hhid = concat(FSU Hamlet Second_stage_stratum Sample_hhld_no)
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
/* <_pid_note>

	Because there are so many variables for the same sample individual id, I drop
	them and keep only the data from block 5

</_pid_note> */
	egen  str11 pid = concat(hhid Personal_serial_no)
	label var pid "Individual ID"
	isid pid
*</_pid_>


*<_age_>
	gen age = Age
	label var age "Individual age"
*</_age_>


*<_minlaborage_>
	gen byte minlaborage = 0
	label var minlaborage "Labor module application age"
*</_minlaborage_>



*<_lstatus_>
	destring Current_day_activity_Status1, gen(lstatus)
	recode lstatus  (11/72 98 = 1) (81=2) (82 91/97=3) (99=.)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_empstat_alt_>
	destring Current_day_activity_Status1, gen(empstat_alt)
	recode empstat_alt (11=4) (12=3) (61 62 21=2) (31  71 72 =1) (81/97 99=.) (41 51 98 = 6)
	replace empstat_alt=. if lstatus != 1 | (age < minlaborage & age != .)
	label var empstat_alt "Employment status during past week primary job 7 day recall"
	la de lblempstat_alt 1 "Regular employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" 6 "Casual employee"
	label values empstat_alt lblempstat_alt
*</_empstat_alt_>


keep pid empstat_alt 

save "Y:/GLD-Harmonization/529026_MG/Countries/IND/empstat_alt\IND_2004_empstat_alt.dta", replace