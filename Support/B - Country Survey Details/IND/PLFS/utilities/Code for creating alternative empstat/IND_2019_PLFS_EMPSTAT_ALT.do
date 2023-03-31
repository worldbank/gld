


clear
set more off
set mem 800m

*----------1.2: Set directories------------------------------*

* Define path sections
local server  "Y:/GLD"
local country "IND"
local year    "2019"
local survey  "PLFS"
local vermast "v01"
local veralt  "v03"

* From the definitions, set path chunks
local level_1      "`country'_`year'_`survey'"
local level_2_mast "`level_1'_`vermast'_M"
local level_2_harm "`level_1'_`vermast'_M_`veralt'_A_GLD"

* From chunks, define path_in, path_output folder
local path_in_stata "`server'/`country'/`level_1'/`level_2_mast'/Data/Stata"
local path_in_other "`server'/`country'/`level_1'/`level_2_mast'/Data/Original"
local path_output   "`server'/`country'/`level_1'/`level_2_harm'/Data/Harmonized"

* Define Output file name
local out_file "`level_2_harm'_ALL.dta"

*----------1.3: Database assembly------------------------------*

use "`path_in_stata'\IND_2019_PLFS_raw_IND_Stata.dta", clear

gen str1 h_1 = string(sample_sg_b_no,"%01.0f")
gen str1 h_2 = string(ss_stratum,"%01.0f")
gen str2 h_3 = string(hh_num,"%02.0f")

egen str9 hh_key = concat(fsu h_1 h_2 h_3)
drop h_*

tempfile ind_file
save `ind_file'

use "`path_in_stata'\IND_2019_PLFS_raw_HH_Stata.dta", clear

gen str1 h_1 = string(sample_sg_b_no,"%01.0f")
gen str1 h_2 = string(ss_stratum,"%01.0f")
gen str2 h_3 = string(hh_num,"%02.0f")

egen str9 hh_key = concat(fsu h_1 h_2 h_3)
drop h_*

merge 1:m hh_key using `ind_file', assert(match)
drop _merge hh_key


*<_hhid_>
/* <_hhid_note>

	Using sample first segment unit, segment block number,
	second stage stratum, and HH number.

</_hhid_note> */

	gen str1 h_1 = string(sample_sg_b_no,"%01.0f")
	gen str1 h_2 = string(ss_stratum,"%01.0f")
	gen str2 h_3 = string(hh_num,"%02.0f")

	egen hhid = concat(fsu h_1 h_2 h_3)
	label var hhid "Household ID"
	drop h_1 h_2 h_3
*</_hhid_>


*<_pid_>
	gen indiv_id = string(person_no,"%02.0f")
	egen  pid = concat(hhid indiv_id)
	label var pid "Individual ID"
	drop indiv_id
*</_pid_>

*<_age_>
	* Variable age already exists in original data, is string
	rename age age_old
	gen helper = age_old

	* Drop last letter if . or +
	gen x_indic = regexm(helper, "\.|\+")
	replace helper = substr(helper, 1, length(helper) - 1) if x_indic == 1
	drop x_indic

	destring helper, gen(age)
	label var age "Individual age"
*</_age_>

*<_minlaborage_>
	gen byte minlaborage =0
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*<_lstatus_>
	gen byte lstatus = cws
	recode lstatus  (11/72 98 = 1) (81=2) (82 91/97=3) (99=.)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>

*<_empstat_alt_>
	gen byte empstat_alt = cws
	recode empstat_alt (11=4) (12=3) (61 62 21=2) (31 71 72 =1) (81/97 99=.) (41 42 51 98 = 6)
	label var empstat_alt "Employment status during past week primary job 7 day recall"
	la de lblempstat_alt 1 "Regular employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" 6 "Casual employee"
	label values empstat_alt lblempstat_alt
*</_empstat_alt_>

keep pid empstat_alt 

save "Y:/GLD-Harmonization/529026_MG/Countries/IND/empstat_alt\IND_2019_empstat_alt.dta"