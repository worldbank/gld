
/*%%=============================================================================================
	0: GLD Harmonization Preamble
================================================================================================*/

* Add a more disaggregated empstat

/*%%=============================================================================================
	1: Setting up of program environment, dataset
================================================================================================*/

*----------1.1: Initial commands------------------------------*

clear
set more off
set mem 800m

capture which distinct
if _rc ssc install distinct

*----------1.2: Set directories------------------------------*

global path_in "Y:\GLD\IND\IND_1983_EUS\IND_1983_EUS_v01_M\Data\Stata"
global path_output "Y:/GLD-Harmonization/529026_MG/Countries/IND/empstat_alt"

*----------1.3: Database assembly------------------------------*

use "$path_in/Block-5-Persons-DailyActivity-records.dta", clear

* First, drop obs with missing activities
drop if missing(B5_q3)

* The dataset is not unique at the activity_slno_key when it should be!
* Need to reconstruct the id variables such that activity_slno_key is unique

egen hhid = concat(Sector State Region FSU_Slno Hhold_Slno)
egen pid = concat(hhid Person_slno)

* Before we create the activity id, we first apply the sorting procedure
/*==============================================================================
Current weekly activity is selected based on this order:
	1. Equal to current weekly activity variable (if applicable)
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

* Drop if activity status has zero hours
drop if B5_q13==0

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


* Merge Block 4 informaion on CWAS
preserve

	use "$path_in/Block-41-Persons-Demogrphic-weelyActivity-records.dta", clear

	gen pid = Person_key
	keep pid B41_q14

	* Convert status code into numeric.
	destring B41_q14, gen(numstatus)
	sort pid numstatus

	* Keep only the first instance
	duplicates tag pid, gen(dups)
	bys pid: gen runner = _n

	drop if dups==1 & runner !=1

	* Uniqueness check
	distinct pid
	drop runner

	tempfile cwas
	save `cwas'

restore

* Merge with CWAS data
merge m:1 pid using `cwas', keep(master match) nogen

gen first = 1 if B5_q3 == B41_q14
replace first = 2 if B5_q3 != B41_q14


sort pid first priority_tag neg_days num_status

bys pid: gen runner = _n

* Total number of days for each person's activity should be equal to 7
bys pid: egen tot = sum(B5_q13)
distinct pid if tot != 7 //only 34 people with tota days != 7

* Crude correction: divide by 2 to prorate the number of days
replace B5_q13 = B5_q13/2 if tot!=7
drop tot

bys pid: egen tot = sum(B5_q13)
distinct pid if tot != 7 //everybody has total number of days at 7

* Check if data is unqiue at pid-runner
distinct pid runner, joint //unique

* Unemployment duration variable cleaning
destring B5_q17, replace
bys pid: egen B5_q17a = max(B5_q17)

replace B5_q17 = B5_q17a

* Next, reshape to wide so that data frame is unique at the pid level
keep pid runner B5_q3 B5_q4 B5_q13 B5_q14 B5_q15 B5_q16 B5_q17 B41_q14
reshape wide B5_q3 B5_q4 B5_q13 B5_q14 B5_q15 B5_q16 B5_q17, i(pid) j(runner)

* Check how distinct the given CWAS is from the determined CWAS
count if B5_q31 != B41_q14

tempfile block5
save `block5'

/*******************************************************

Next, merge the data with other modules

*******************************************************/

* Merge with block 4.1 and 4.2
	use "$path_in/Block-41-Persons-Demogrphic-weelyActivity-records.dta", clear

	gen pid = Person_key

	* Convert status code into numeric.
	destring B41_q14, gen(numstatus)
	sort pid numstatus

	* Keep only the first instance
	duplicates tag pid, gen(dups)
	bys pid: gen runner = _n

	drop if dups==1 & runner !=1

	tempfile block41
	save `block41'

* Merge with block 4.2
	use "$path_in/Block-42-Persons-migration-records.dta", clear

	gen pid = Person_key

	* Convert status code into numeric.
	destring B42_q11, gen(numstatus)
	sort pid numstatus

	* Keep only the first instance
	duplicates tag pid, gen(dups)
	bys pid: gen runner = _n

	drop if dups==1 & runner !=1

	distinct pid
	drop runner

	merge 1:1 pid using `block41', nogen
	merge 1:1 pid using `block5', nogen

	tempfile combined
	save `combined'

* Merge with block 6
use "$path_in\Block-6-Persons-UsualActivity-records.dta", clear

* Is this unique at the person_key level?
	* > It is not! Bec there are individuals reporting two PUAS whereas there should only be one!

	* How to select which PUAS to select? Approach is to pick activity status code corresponding to employment. In short, just sort by activity status since it is ordered that way. If two PUAS are reported indicating employment, the approach biases towards self-employment. But this is observed only in a negligible number of cases.

gen pid = Person_key

* Convert status code into numeric.
destring B6_q2, gen(numstatus)
sort pid numstatus

* Keep only the first instance
duplicates tag pid, gen(dups)
bys pid: gen runner = _n
drop if dups==1 & runner !=1

* Uniqueness check
distinct pid

* Next, proceed with merging with block 5
merge 1:1 pid using `combined', keep(master match) nogen
* Note that there is one individual in Block 5 that has no match in Block 6. This is dropped out!


* Next, merge with Block 7
preserve
	use "$path_in\Block-7-Persons-Notworking-subsidiary-activity-record.dta", clear

	duplicates drop Person_key, force
	tempfile block7
	save `block7'

restore

merge 1:1 Person_key using `block7', keep(master match) nogen

* Next, merge with Block 8
preserve
	use "$path_in\Block-8-Persons-Addl-Questions-UsualActivity-records.dta", clear

	* Make variable names consistent
	gen Person_key = Person_KEY
	drop Person_KEY

	* Sort PUAS variable
	destring B8_q2a, gen(numstatus)
	sort Person_key numstatus

	* Keep only the first instance
	duplicates tag Person_key, gen(dups)
	bys Person_key: gen runner = _n
	drop if dups==1 & runner !=1
	drop runner

	tempfile block8
	save `block8'

restore

merge 1:1 Person_key using `block8', keep(master match) nogen


* Next, proceed with Block 3
preserve
	use "$path_in\Block-1-3-Household-records.dta", clear

	* This dataset has duplicates problem. The reported values in the duplicates appear roughly similar, except for a few monetary variables. Since we cannot determine which datapoint to keep, we just keep the first instance, which the duplicates drop command does.

	distinct Hhold_key

	duplicates drop Hhold_key, force

	tempfile block3
	save `block3'

restore

* Merge with hhold data
merge m:1 Hhold_key using `block3', keep(master match) nogen
* Note there are 76 hholds not in Block 6 and 41 individuals not in Block 3


*<_hhid_>
/* <_hhid_note>
	There is no way a 9-digit HH id variable can be created from the variables on sampling info.

</_hhid_note> */
	egen hhid = concat(Sector State Region FSU_Slno Hhold_Slno)
	label var hhid "Household ID"
*</_hhid_>

*<_pid_>
	label var pid "Individual ID"
	isid pid
*</_pid_>

*<_age_>
	gen age = B41_q6
	label var age "Individual age"
*</_age_>

*<_minlaborage_>
	gen byte minlaborage = 5
	label var minlaborage "Labor module application age"
*</_minlaborage_>

*<_lstatus_>
	destring B41_q14, gen(lstatus)
	recode lstatus  (11/72 99 = 1) (81 =2) (1/4 82 91/98=3) 
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_empstat_>
	destring B41_q14, gen(empstat_alt)
	recode empstat_alt (11=4) (12=3) (61 62 21=2) (31 71 = 1) (1/4 81/98 =.) (41 51 99 = 6)
	replace empstat_alt=. if lstatus != 1 | (age < minlaborage & age != .)
	label var empstat_alt "Employment status during past week primary job 7 day recall - India specific"
	la de lblempstat 1 "Regular employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" 6 "Casual employee"
	label values empstat_alt lblempstat
*</_empstat_>

keep pid empstat_alt

*<_% COMPRESS_>

compress

*</_% COMPRESS_>


*<_% SAVE_>

save "$path_output\IND_1983_empstat_alt.dta", replace

*</_% SAVE_>
