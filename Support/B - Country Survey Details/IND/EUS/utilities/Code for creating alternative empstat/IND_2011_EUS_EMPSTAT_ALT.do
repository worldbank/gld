
clear
set more off
set mem 800m

*----------1.2: Set directories------------------------------*

local path_in "Y:/GLD/IND/IND_2011_EUS/IND_2011_EUS_v01_M/Data/Stata"
local path_output "Y:/GLD/IND/IND_2011_EUS/IND_2011_EUS_v01_M_v02_A_GLD/Data/Harmonized"

*----------1.3: Database assembly------------------------------*

* IN the 2011 round, Block 5 is subdivided into three datasets: principal activity,
* subsidiary activity and time disposition.

tempfile pa sa block5

* Principal activity data
use "`path_in'/Block_5_1_Usual principal activity particulars of household members.dta", clear
save `pa' ///456,999 obs

* Subsidiary activity data
use "`path_in'/Block_5_2_Usual subsidiary economic activity particulars of household members.dta", clear
	rename Type_of_Job_Contract Type_of_Job_Contract2
	rename No_of_Workers_in_Enterprise No_of_Workers_in_Enterprise2
	rename Enterprise_Type Enterprise_Type2
	rename Social_Security_Benefits Social_Security_Benefits2
	keep HHID Person_Serial_No Type_of_Job_Contract2 Usual_Subsidiary_Activity_Status	Usual_SubsidiaryActivity_NIC2004 Usual_SubsidiaryActivity_NCO2004 No_of_Workers_in_Enterprise2 Enterprise_Type2 Social_Security_Benefits2

save `sa' //38,098 obs

* Time disposition - unique at the Sample_Hhld_No Person_Se
*** Note the awkward file name with space in the end before .dta
use "`path_in'/Block_5_3_Time disposition during the week ended on .dta", clear


** Sorting procedure

/* Need to order activity status such that the order of priority is as follows:

	a. Working status
	b. Non-working status but seeking employment
	c. Neither working nor available for work
*/

destring Status, gen(priority_tag)
gen num_status = priority_tag
* Classify the level of priority
recode priority_tag 11/72=1 81 82=2 91/98=3 99=.

* Decreasingorder of number of days worked
gen neg_days = -(Total_no_days_in_each_activity)


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

egen PID = concat(HHID Person_Serial_No)

sort PID priority_tag neg_days num_status
bys PID: gen runner = _n

* How many cases wherein this priority order is not followed
count if Status ! = Current_Weekly_Activity_Status & runner==1 //0

drop priority_tag num_status neg_days



* Ensure that No of Days of Nominal Work is constant
bys HHID Person_Serial_No: egen Nominal_rc = max(No_of_Days_with_Nominal_Work)
keep HHID Person_Serial_No  Age Status - Mode_of_Payment Current_Weekly_Activity_Status - Nominal_rc

reshape wide Status NIC_2008_Code Operation Intensity* Total_no_days_in_each_activity Wage_* Mode_of_Payment, i(HHID Person_Serial_No) j(runner)

* Merge these three datasets
merge 1:1 HHID Person_Serial_No using `sa', assert(match master) nogen
merge 1:1 HHID Person_Serial_No using `pa', assert(match master) nogen

save `block5'

* Merge Block 3 with Block 1- 2
use "`path_in'/Block_1_2_Identification of sample household and particulars of field operation.dta", clear
merge 1:1 FSU_Serial_No Hamlet_Group_Sub_Block_No Second_Stage_Stratum_No Sample_Hhld_No using "`path_in'/Block_3_Household characteristics.dta", assert(match) nogen

* Merge with Block 5
merge 1:m HHID using `block5', assert(match) nogen

** There is no HHID variable in Block 3; merge using PSU+ Hamlet + Second stage + HH No
merge m:1 FSU_Serial_No Hamlet_Group_Sub_Block_No Second_Stage_Stratum_No Sample_Hhld_No using "`path_in'/Block_3_Household characteristics.dta", assert(match) nogen

* Merge with Block 4
merge 1:1 HHID Person_Serial_No using "`path_in'/Block_4_Demographic particulars of household members.dta", assert(match) nogen

* Merge with Block 6
merge 1:1 HHID Person_Serial_No using "`path_in'/Block_6_Follow-up questions on availability for.dta", assert(match master) nogen

* Merge with Blcok 7
merge 1:1 HHID Person_Serial_No using "`path_in'/Block_7_Follow-up questions for persons with usual principal activity status code 92 or 93 in col. 3 of  bl. 5.dta", assert(match master) nogen



*<_hhid_>
/* <_hhid_note>

	From different surveys a str9 should be created. In later surveys this is:
	FSU (str5) + Hamlet (str1) + 2nd Stage Sample (str1) + Sample HH Id (str2).

	Here Hhold_Key is str8 of FSU + Stage 2 Stratum + Sample HH Id. Add subround to make str9
	From preparing I notice there is one case where Stage2_Stratum is "0", when this makes no sense,
	HH Key has code 2, so first amend that
</_hhid_note> */
	egen str9 hhid = concat(FSU_Serial_No Hamlet_Group_Sub_Block_No Second_Stage_Stratum_No Sample_Hhld_No)
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	egen  str11 pid = concat(hhid Person_Serial_No)
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
	destring Current_Weekly_Activity_Status, gen(lstatus)
	recode lstatus (11/72 98 = 1) (81=2) (82 91/97=3) (99=.)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_empstat_alt_>
	destring Current_Weekly_Activity_Status, gen(empstat_alt)
	recode empstat_alt (11=4) (12=3) (61 62 21=2) (31 71 72 =1) (81/97 99=.) (41 42 51 98 = 6)
	replace empstat_alt=. if lstatus != 1 | (age < minlaborage & age != .)
	label var empstat_alt "Employment status during past week primary job 7 day recall"
	la de lblempstat_alt 1 "Regular employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" 6 "Casual employee"
	label values empstat_alt lblempstat_alt
*</_empstat_alt_>

keep pid empstat_alt 

save "Y:/GLD-Harmonization/529026_MG/Countries/IND/empstat_alt\IND_2011_empstat_alt.dta"