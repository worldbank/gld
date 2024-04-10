# Migration Section

This page only applies for the migration code in the 2022 GLD harmonization. 

The raw microdata contains separate files for questionnaire section. The migration section is separated in quarterly files that need to be combined. However, unique identifiers of each file are not easy to match because the migration section has a different unique identifier that has not been documented to our knowledge. 

As the data is, the individuals that migrated in each household are identified with an ID code that differs to the ID code from the rest of the files. A feasible way to identify the individuals in the household that informed about their migration patterns is to match them through other individual characteristic such as age and gender, unfortunately this could lead to imprecise matching when ae or gender are the same within household. 

The GLD team tried to include the information from the migration section into the GLD harmonized version through matching with age and gender and household ID, we ended up with around 800 observations added to the master file but becasue we do not have a precise documentation onto why the IDs in the migration section are different, the team decided to drop this code and report it here for the user to decide this alternate version. 


## Proposed Code

```

/*%%=============================================================================================
	1: Setting up of program environment, dataset
==============================================================================================%%*/


*----------1.1: Initial commands------------------------------*

clear
set more off
set mem 800m
set varabbrev off

*----------1.2: Set directories------------------------------*

* Define path sections
local server  "Y:/GLD-Harmonization/582018_AQ"
local country "BGD"
local year    "2022"
local survey  "QLFS"
local vermast "V01"
local veralt  "V01"

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

*=========== Append Blocks =============*
* We are first going to create three appended blocks, then merge those in
* Create a local to loop over quarters
local quarters "Q1 Q2 Q3 Q4"

* Create Socio_Economic block
foreach quarter of local quarters {
	append using "`path_in_stata'/`quarter'_LFS_Socio_Economic_2022.dta", force
}

* Keep only HH level info (there are HR vars)
keep YEAR - RU BBS_geo - INT_CODE
tempfile se
save "`se'"
clear

* Create Roster block
foreach quarter of local quarters {
	append using "`path_in_stata'/`quarter'_LFS_Roster_Disability_2022.dta", force
}
tempfile rd
save "`rd'"
clear 

* Create Employment Education block
foreach quarter of local quarters {
	append using "`path_in_stata'/`quarter'_LFS_Education_Employment_2022.dta", force
}

* Clean up duplicates. There are 7 (14 obs) of duplicates in Q3, 14 in Q4
count
local rnb `r(N)'
dis `rnb'
duplicates drop YEAR QUARTER PSU EAUM HHNO EMP_HRLN, force
count
assert `rnb' - 21 == `r(N)'

tempfile ee
save "`ee'"
clear 


* Create Migration block
foreach quarter of local quarters {
	append using "`path_in_stata'/`quarter'_LFS_Migration_2022.dta", force
}



gen SEX = 1 if MGT_01B == "M"
replace SEX = 2 if MGT_01B == "F"
rename MGT_01C AGE
ren *, lower

gen quarter_s = string(quarter, "%02.0f")
gen psu_s = string(psu, "%04.0f")
gen eaum_s = string(eaum, "%03.0f")
gen hhno_s = string(hhno, "%03.0f")
egen hhid = concat(quarter_s psu_s eaum_s hhno_s)
label var hhid "Household ID"
distinct hhid 

duplicates drop hhid, force

tempfile mi
save "`mi'"
clear 

*=========== Merge Blocks =============*
* Load socio economic block
use "`se'", clear 

* Merge - housheold (1) to individuals (m) to roster block 
* There are 128 obs in roster block w/o socio-economic, keep only matched (no master only)
merge 1:m YEAR QUARTER PSU EAUM HHNO using "`rd'", nogen keep(match)

* Merge - individual (1) to individual (1) to employment and education
* There are 2 obs from EE that are not in the SE-RD merge, drop (keep only match, master)
merge 1:1 YEAR QUARTER PSU EAUM HHNO EMP_HRLN using "`ee'", nogen keep(master match)

*=========== Make lowercase =============*
* Rename, where needed WT_02f, which is the any binary for WT_02A to WT_02X.
* Choice of variable name is odd
cap rename WT_02f WT_02_ANY
ren *, lower

* Note that result is missing in Q1, cannot keep if result == 1
tab result,m

rename hr_03 sex
rename hr_04 age

gen quarter_s = string(quarter, "%02.0f")
gen psu_s = string(psu, "%04.0f")
gen eaum_s = string(eaum, "%03.0f")
gen hhno_s = string(hhno, "%03.0f")
egen hhid = concat(quarter_s psu_s eaum_s hhno_s)
label var hhid "Household ID"
distinct hhid 


*merge m:1 YEAR QUARTER PSU EAUM HHNO sex age using "`mi'", nogen keep(master match)
merge m:1 hhid sex age using "`mi'", nogen keep(master match)
drop hhid quarter_s psu_s eaum_s hhno_s 
rename sex hr_03 
rename  age hr_04

save "`path_in_stata'/final_merged_2022.dta", replace



/*%%=============================================================================================
	5: Migration
==============================================================================================%%*/

*<_migrated_mod_age_>
	gen migrated_mod_age = 15
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time = .
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen migrated_binary = .
	replace migrated_binary=1 if mgt_02!=""
	replace migrated_binary=0 if migrated_binary!=1
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen migrated_years = .
	label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban = .
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen migrated_from_cat = .
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen migrated_from_code = .
	*label de lblmigrated_from_code
	*label values migrated_from_code lblmigrated_from_code
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country = mgt_02
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason = .
	label de lblmigrated_reason 1 "Family reasons" 2 "Educational reasons" 3 "Employment" 4 "Forced (political reasons, natural disaster, …)" 5 "Other reasons"
	label values migrated_reason lblmigrated_reason
	label var migrated_reason "Reason for migrating"
*</_migrated_reason_>



```

