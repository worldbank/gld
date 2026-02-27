/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				UGA_2023_UNHS_GLD_ALL.do </_Program name_>
<_Application_>					Stata 17 <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2025-10-29 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						UGA</_Country_>
<_Survey Title_>				National Labour Force Survey </_Survey Title_>
<_Survey Year_>					2023 </_Survey Year_>
<_Study ID_>					</_Study ID_>
<_Data collection from_>		03/2023 </_Data collection from_>
<_Data collection to_>			03/2024 </_Data collection to_>
<_Source of dataset_> 			[Source of data, e.g. NSO] </_Source of dataset_>
<_Sample size (HH)_> 			[#] </_Sample size (HH)_>
<_Sample size (IND)_> 			[#] </_Sample size (IND)_>
<_Sampling method_> 			[Brief description] </_Sampling method_>
<_Geographic coverage_> 		[To what level is data significant] </_Geographic coverage_>
<_Currency_> 					[Currency used for wages] </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS 19 </_ICLS Version_>
<_ISCED Version_>				[Version of ICLS for Labor Questions] </_ISCED Version_>
<_ISCO Version_>				ISCO 2008 </_ISCO Version_>
<_OCCUP National_>				[Version of ICLS for Labor Questions] </_OCCUP National_>
<_ISIC Version_>				ISIC rev 4 </_ISIC Version_>
<_INDUS National_>				[Version of ICLS for Labor Questions] </_INDUS National_>

-----------------------------------------------------------------------
<_Version Control_>

* Date: [YYYY-MM-DD] - [Description of changes]
* Date: [YYYY-MM-DD] - [Description of changes]

</_Version Control_>

-------------------------------------------------------------------------*/


/*%%=============================================================================================
	1: Setting up of program environment, dataset
==============================================================================================%%*/

*----------1.1: Initial commands------------------------------*

clear
set more off
set mem 800m
set varabbrev off

*----------1.2: Set directories------------------------------*

* De
* Define path sections
local server  "C:/Users/`c(username)'/WBG/GLD - Current Contributors/510859_AS"
local country "UGA"
local year    "2023"
local survey  "UNHS"
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

* All steps necessary to merge datasets (if several) to have all elements needed to produce
* harmonized output in a single file


*==============================================================================
* 1.1: Merge Sections (2-17) to Create LFS Module for HOSTS
*==============================================================================


* --- Merge LFS Sections for Host Population ---

* Start with Section 2 (Household Roster)
use "`path_in_stata'/hsec2.dta", clear

* Merge 1:1 using the household ID (hhid) and person ID (pid) from Section 17 (LFS module)
merge 1:1 hhid pid using "`path_in_stata'/hsec17.dta"

* Drop the merge variable
drop _merge

* Merge 1:1 using hhid and pid from Section 3 (Other household members information)
merge 1:1 hhid pid using "`path_in_stata'/hsec3.dta"

* Drop the merge variable
drop _merge

* Merge 1:1 using hhid and pid from Section 4 (Education)
merge 1:1 hhid pid using "`path_in_stata'/hsec4.dta"

* Drop the merge variable
drop _merge

* Merge 1:1 using hhid and pid from Section 5 (Health)
merge 1:1 hhid pid using "`path_in_stata'/hsec5.dta"

* Drop the merge variable
drop _merge

* Merge M:1 using hhid from Section 1 (Household Characteristics)
* Note: Section 1 typically has one observation per household (M:1 relationship)
merge m:1 hhid using "`path_in_stata'/hsec1.dta"

* Keep only those who completed the interview
keep if final_v1_v2_v3==1

* Drop the merge variable
drop _merge

* Save the final LFS module for the host population
tempfile lfs_module
save `lfs_module'

*==============================================================================
* 1.2: Merge Sections (2-17) to Create LFS Module for REFUGEES
*==============================================================================

* Start with Section 2 for Refugees (Household Roster)
use "`path_in_stata'/hsec2_r.dta", clear

* Merge 1:1 using hhid and pid from Section 17 for Refugees (LFS module)
merge 1:1 hhid pid using "`path_in_stata'/hsec17_r.dta"

* Drop the merge variable
drop _merge

* Merge 1:1 using hhid and pid from Section 4 for Refugees (Education)
merge 1:1 hhid pid using "`path_in_stata'/hsec4_r.dta"

* Drop the merge variable
drop _merge

* Merge 1:1 using hhid and pid from Section 5 (Health)
merge 1:1 hhid pid using "`path_in_stata'/hsec5_r.dta"

* Drop the merge variable
drop _merge

* Merge 1:1 using hhid and pid from Section 3 (Other household members information)
merge 1:1 hhid pid using "`path_in_stata'/hsec3_r.dta"

* Drop the merge variable
drop _merge

* Merge M:1 using hhid from Section 1 for Refugees (Household Characteristics)
merge m:1 hhid using "`path_in_stata'/hsec1_r.dta"

* Keep only those who completed the interview
keep if response==1

* Drop the merge variable
drop _merge

* Generate a flag variable to identify refugees
gen refugee = 1

tempfile lfs_module_r
save `lfs_module_r'

* Load the host data
use `lfs_module', clear

append using `lfs_module_r'


/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode = "UGA"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "UNHS"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "UNHS"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	gen icls_v = "ICLS-19"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	gen isced_version = ""
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
	gen isco_version = "isco_2008"
	label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
	gen isic_version = "isic_4"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	*gen int year = 
	*label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen vermast = "`vermast'"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen veralt = "`veralt'"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen harmonization = "GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	gen int_year = year
	destring int_year, replace
	replace int_year = . if int_year<2023

	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen  int_month = month
	destring int_month, replace
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>

*<_weight_>
	gen weight = finalwgt
	label var weight "Survey sampling weight"
*</_weight_>

*/
/*%%=============================================================================================
	3: Geography
==============================================================================================%%*/

{

*<_urban_>
	gen urban = s1aq3
	recode urban(2=0)
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>

}


*<_subnatid1_>
	gen subnatid1 = ""
	replace subnatid1 = "1 - Central"  if region==1
	replace subnatid1 = "2 - Eastern"  if region == 2
	replace subnatid1 = "3 - Northern" if region == 3
	replace subnatid1 = "4 - Western"  if region == 4

	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	gen str subnatid2 = ""
	replace subnatid2 = "1 - Kampala"        if subreg15 == 1
	replace subnatid2 = "2 - Buganda South"  if subreg15 == 2
	replace subnatid2 = "3 - Buganda North"  if subreg15 == 3
	replace subnatid2 = "4 - Busoga"         if subreg15 == 4
	replace subnatid2 = "5 - Bukedi"         if subreg15 == 5
	replace subnatid2 = "6 - Elgon"          if subreg15 == 6
	replace subnatid2 = "7 - Teso"           if subreg15 == 7
	replace subnatid2 = "8 - Karamoja"       if subreg15 == 8
	replace subnatid2 = "9 - Lango"          if subreg15 == 9
	replace subnatid2 = "10 - Acholi"        if subreg15 == 10
	replace subnatid2 = "11 - West Nile"     if subreg15 == 11
	replace subnatid2 = "12 - Bunyoro"       if subreg15 == 12
	replace subnatid2 = "13 - Tooro"         if subreg15 == 13
	replace subnatid2 = "14 - Ankole"        if subreg15 == 14
	replace subnatid2 = "15 - Kigezi"        if subreg15 == 15
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	gen str subnatid3 = ""
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
/* <_subnatidsurvey_note>

</_subnatidsurvey_note> */
	gen str subnatidsurvey = ""
	label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>


*<_subnatid1_prev_>
/* <_subnatid1_prev_note>

</_subnatid1_prev_note> */
	gen subnatid1_prev = .
	label var subnatid1_prev "Classification used for subnatid1 from previous survey"
*</_subnatid1_prev_>


*<_subnatid2_prev_>
	gen subnatid2_prev = .
	label var subnatid2_prev "Classification used for subnatid2 from previous survey"
*</_subnatid2_prev_>


*<_subnatid3_prev_>
	gen subnatid3_prev = .
	label var subnatid3_prev "Classification used for subnatid3 from previous survey"
*</_subnatid3_prev_>


*<_gaul_adm1_code_>
	gen gaul_adm1_code = .
	label var gaul_adm1_code "Global Administrative Unit Layers (GAUL) Admin 1 code"
*</_gaul_adm1_code_>


*<_gaul_adm2_code_>
	gen gaul_adm2_code = .
	label var gaul_adm2_code "Global Administrative Unit Layers (GAUL) Admin 2 code"
*</_gaul_adm2_code_>


*<_gaul_adm3_code_>
	gen gaul_adm3_code = .
	label var gaul_adm3_code "Global Administrative Unit Layers (GAUL) Admin 3 code"
*</_gaul_adm3_code_>

}
*/

/*%%=============================================================================================
	4: Demography
==============================================================================================%%*/

{

*<_hsize_>
	bys hhid: egen hsize=count(pid) if r04<=4
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen age=r07
	label var age "Individual age"
*</_age_>


*<_male_>
	gen byte male = r02 == 1
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen relationharm = .
	replace relationharm = 1 if r03 == 1                              // Head of household
	replace relationharm = 2 if r03 == 2                              // Spouse
	replace relationharm = 3 if r03 == 3 | r03 ==5                    // Children (includes step/adopted)
	replace relationharm = 4 if r03 == 6                              // Parents
	replace relationharm = 5 if r03 == 4 | inrange(r03,7,9)		     // Other relatives (includes grandchildren)
	replace relationharm = 6 if inrange(r03,10,11)                      // Other and non-relatives

	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

*<_relationcs_>
	gen relationcs = r03
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
* No distinction between married and co-habitating
* There is already a marital variable; delete this!
	gen byte marital = r09
	replace marital = 1 if r09 == 1                    // Married/Cohabiting → Married
	replace marital = 2 if r09 == 5                    // Never married → Never Married
	replace marital = 4 if r09 == 3	            // Divorced or Separated → Divorced/Separated
	replace marital = 5 if r09 == 4                    // Widow/Widower → Widowed
	replace marital = 3 if r09 == 2						// Living together/Polygamous living
	 
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	gen eye_dsablty = .
	replace eye_dsablty = 1 if s31 == 1 | s32==1                   // No difficulty
	replace eye_dsablty = 2 if s31 == 2  | s32==2                    // Some difficulty
	replace eye_dsablty = 3 if s31 == 3  | s32==3                 // A lot of difficulty
	replace eye_dsablty = 4 if s31 == 4  | s32==4                 // Cannot do at all
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
	label values eye_dsablty dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty = .
	replace hear_dsablty = 1 if s35 == 1 | s36 == 1
	replace hear_dsablty = 2 if s35 == 2 | s36 == 2
	replace hear_dsablty = 3 if s35 == 3 | s36 == 3
	replace hear_dsablty = 4 if s35 == 4 | s36 == 4
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values hear_dsablty dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty = .
	replace walk_dsablty = 1 if s40 == 1
	replace walk_dsablty = 2 if s40 == 2
	replace walk_dsablty = 3 if s40 == 3
	replace walk_dsablty = 4 if s40 == 4
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values walk_dsablty dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord = .
	replace conc_dsord = 1 if s39 == 1
	replace conc_dsord = 2 if s39 == 2
	replace conc_dsord = 3 if s39 == 3
	replace conc_dsord = 4 if s39 == 4
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values conc_dsord dsablty
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty = .
	replace slfcre_dsablty = 1 if s43 == 1
	replace slfcre_dsablty = 2 if s43 == 2
	replace slfcre_dsablty = 3 if s43 == 3
	replace slfcre_dsablty = 4 if s43 == 4
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values slfcre_dsablty dsablty
	label var slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty = .
	replace comm_dsablty = 1 if s38 == 1
	replace comm_dsablty = 2 if s38 == 2
	replace comm_dsablty = 3 if s38 == 3
	replace comm_dsablty = 4 if s38 == 4
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values comm_dsablty dsablty
	label var comm_dsablty "Disability related to communicating"
*</_comm_dsablty_>

}


/*%%=============================================================================================
	5: Migration
==============================================================================================%%*/


{

*<_migrated_mod_age_>
	gen migrated_mod_age = 5
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	* There is no reference time. They asked if person has lived in this administrative area and when they moved
	gen migrated_ref_time = 99
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen migrated_binary=.
	replace migrated_binary=0 if r13a_2==997 | r13a_2==-997
	replace migrated_binary=1 if migrated_binary==.
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	destring year, replace
	gen migrated_years = .
	replace migrated_years = 2024-r14b if r14b>-9998 & r14b<9998 & year==2024
	replace migrated_years = 2023-r14b if r14b>-9998 & r14b<9998 & year==2023
	replace migrated_years = . if migrated_binary != 1
	label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban = .
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>
*/

*<_migrated_from_cat_>
	gen migrated_from_cat = 6 if migrated_binary == 1
	replace migrated_from_cat = 5 if r13!=1
	replace migrated_from_cat = . if migrated_binary != 1
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country" 6 "Within country, admin unknown" 7 "Wholly unknow"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>
*/

*<_migrated_from_code_>
	gen migrated_from_code = .
	replace migrated_from_code = . if migrated_binary != 1
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country = ""
	replace migrated_from_country = "" if migrated_binary != 1
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>

*/
*<_migrated_reason_>
	gen migrated_reason = .
	replace migrated_reason = 1 if inlist(r14c, 3, 4)                           // To accompany family, Marriage
	replace migrated_reason = 2 if r14c == 1                                    // Education/training
	replace migrated_reason = 3 if r14c == 2                                    // Employment-related, Farming
	replace migrated_reason = 4 if inlist(r14c, 5, 6, 7)                        // War, Landslides, Drought (forced)
	replace migrated_reason = 5 if r14c == 96 | r14c == -96                     // Other reasons
	label de lblmigrated_reason 1 "Family reasons" 2 "Educational reasons" 3 "Employment" 4 "Forced (political reasons, natural disaster, …)" 5 "Other reasons"
	label values migrated_reason lblmigrated_reason
	label var migrated_reason "Reason for migrating"
*</_migrated_reason_>


}


/*%%=============================================================================================
	6: Education
==============================================================================================%%*/

{

*<_ed_mod_age_>

/* <_ed_mod_age_note>
Based on the minimum age where responses are non-missing for educ variable vopr_24
</_ed_mod_age_note> */

gen byte ed_mod_age = 3
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school = (e03 == 3)
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen byte literacy = (e02 == 3)
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen byte educy = .
	label var educy "Years of education"
*</_educy_>

*<_educat7_>
	gen educat7 = .
	
	* Asks separately for those who are current students an thsoe who left schooling:
	* Current students
	replace educat7 = 1 if e10 == 9
	replace educat7 = 2 if inrange(e10, 11, 15)
	replace educat7 = 3 if e10 == 30
	replace educat7 = 4 if inrange(e10, 31, 33)
	replace educat7 = 5 if inrange(e10, 34, 35)
	replace educat7 = 6 if inrange(e10, 40, 50)
	replace educat7 = 7 if e10 == 60
	
	* Left schooling

	replace educat7 = 1 if e05 == 9                               // None
	replace educat7 = 2 if inrange(e05, 10, 16)                   // Some primary but not completed
	replace educat7 = 3 if e05 == 17                              // Completed P1–P7
	replace educat7 = 4 if inrange(e05, 21, 33)                   // Junior/Senior 1–3 (lower secondary)
	replace educat7 = 5 if inrange(e05, 34, 36)                   // Senior 4–6 (upper secondary)
	replace educat7 = 6 if inrange(e05, 41, 51)                   // Post-primary or post-secondary specialized
	replace educat7 = 7 if inrange(e05, 61,64)                    // Degree and above

	label var educat7 "Level of education 1"
	la de lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete"
	label values educat7 lbleducat7
*</_educat7_>


*<_educat5_>
	gen byte educat5 = educat7
	recode educat5 (4 = 3) (5 = 4) (6 7 = 5)
	label var educat5 "Level of education 2"
	la de lbleducat5 1 "No education" 2 "Primary incomplete"  3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>


*<_educat4_>
	gen byte educat4 = educat7
	recode educat4 (2 3 4 = 2) (5 = 3) (6 7 = 4)
	label var educat4 "Level of education 3"
	la de lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 lbleducat4
*</_educat4_>


*<_educat_orig_>
	gen educat_orig = ""
	decode e10, gen(e10_str)
	decode e05, gen(e05_str)
	
	replace educat_orig = e10_str
	replace educat_orig = e05_str if missing(educat_orig)
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
	gen educat_isced = .
	label var educat_isced "ISCED standardised level of education"
*</_educat_isced_>


*----------6.1: Education cleanup------------------------------*

*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
local ed_vars "school literacy educy educat7 educat5 educat4 educat_orig educat_isced"

foreach ed_var of local ed_vars {
	cap confirm numeric variable `ed_var'
	if _rc == 0 { // is indeed numeric
		replace `ed_var' = . if ( age < ed_mod_age & !missing(age) )
	}
	else { // is not
		replace `ed_var' = "" if ( age < ed_mod_age & !missing(age) )
	}
}


*</_% Correction min age_>


}


/*%%=============================================================================================
	7: Training
==============================================================================================%%*/

{

*<_vocational_>
	gen vocational = .
	label de lblvocational 0 "No" 1 "Yes"
	label var vocational "Ever received vocational training"
*</_vocational_>


*<_vocational_type_>
	gen vocational_type = .
	label de lblvocational_type 1 "Inside Enterprise" 2 "External"
	label values vocational_type lblvocational_type
	label var vocational_type "Type of vocational training"
*</_vocational_type_>


*<_vocational_length_l_>
	gen vocational_length_l = .
	label var vocational_length_l "Length of training in months, lower limit"
*</_vocational_length_l_>


*<_vocational_length_u_>
	gen vocational_length_u = .
	label var vocational_length_u "Length of training in months, upper limit"
*</_vocational_length_u_>


*<_vocational_field_orig_>
	gen str vocational_field_orig = ""
	label var vocational_field_orig "Original field of training information"
*</_vocational_field_orig_>

*<_vocational_financed_>
	gen vocational_financed = .
	label de lblvocational_financed 1 "Employer" 2 "Government" 3 "Mixed Employer/Government" 4 "Own funds" 5 "Other"
	label var vocational_financed "How training was financed"
*</_vocational_financed_>

}

/*%%=============================================================================================
	8: Labour
==============================================================================================%%*/


*<_minlaborage_>
	gen byte minlaborage = 5
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
	gen lstatus = .
	
	* Worked at least one hr per week //  Help without being pad in any kind of business run by your household 		        //Have 	a paid job or business activity, but (were/was) temporarily absent 
	
	*================================
	* Employed
	*================================
	* Engaged in paid employment, helped family business, apprentice, volunteer
	* Doesnt really matter since only 1 apprentice and zero volunteer
	replace lstatus = 1 if  inlist(lf08, 1, 3, 4, 5)
	
	* Absent from work in the past 7 days but reason indicates job attachment
	replace lstatus = 1 if lf08 == 2 & !inlist(lf09, 11, 12, 96, .)
	
	* Engaged in agriculture (wit most produce for sale)
	replace lstatus = 1 if  lstatus==. & inrange(lf03,1,2)
	
	* Unemployed: looking for a job in last 4 weeks and available to start if it had been offered last week
	replace lstatus = 2 if lstatus == . & inlist(lf84, 1, 2) & inlist(lf86, 1, 2) 

	* All others NLF
	replace lstatus = 3 if lstatus == . & age>=minlaborage
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = .
	replace potential_lf=1 if lstatus & ( (lf84==3 & lf86<=2) |(lf84<=2 & lf86==3) )
	replace potential_lf=0 if potential_lf==. & lstatus==3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
* Want to work more hours
	gen byte underemployment = .
	replace underemployment = 0 if lstatus == 1
	replace underemployment = 1 if lf80 <=3 & lstatus == 1
	replace underemployment = . if age < minlaborage & !missing(age)
	replace underemployment = . if lstatus != 1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason = .
	* 1 = Student
	replace nlfreason = 1 if lf87 == 12

	* 2 = Housekeeper / Family responsibilities / Pregnancy
	replace nlfreason = 2 if inrange(lf87, 13, 14)

	* 3 = Retired/ too old
	*replace nlfreason = 3

	* 4 = Disabled / illness
	replace nlfreason = 4 if inrange(lf87, 15, 16)

	* 5 = Other (no desire, off-season,unable too find,no jobs in area, satisfied with subsistence, other) 
	*Too old and too young option was in the same category, therefore I classify them in other
	replace nlfreason = 5 if inlist(lf87,10,11,17,18,19,20,21,22,23,96)

	* Restrict to those not in labor force
	replace nlfreason = . if lstatus != 3
	
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>

*<_unempldur_l_>
	gen byte unempldur_l = .
	replace unempldur_l = 0  if lf88 <=2   // Less than 3 months
	replace unempldur_l = 3  if lf88 == 3   // 3–6 months
	replace unempldur_l = 6  if lf88 == 4   // 6–12 months
	replace unempldur_l = 12 if lf88 == 5   // 1–2 years
	replace unempldur_l = 24 if lf88 == 6   // 2+ years
	replace unempldur_l = . if lstatus != 2 | lf88 == 7
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>
	gen byte unempldur_u = .
	replace unempldur_u = 3   if lf88 <=2
	replace unempldur_u = 6   if lf88 == 3
	replace unempldur_u = 12  if lf88 == 4
	replace unempldur_u = 24  if lf88 == 5
	replace unempldur_u = .  if lf88 == 6 // Open-ended: 2+ years
	replace unempldur_u = .   if lstatus != 2 | lf88 == 7
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>

}

*----------8.7: 7 day reference main job------------------------------*

{

*<_empstat>
	gen byte empstat = .
	replace empstat=1 if lf21==1
	replace empstat=2 if lf21==3 | lf21==4 | lf21==5
	replace empstat=3 if lf21== 2 & lf23==1
	replace empstat=4 if lf21== 2 & lf23==2
	replace empstat=5 if empstat==. & lstatus==1

	label var empstat "Employment status during past week primary job 12 month recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat>

*<_ocusec>
	gen byte ocusec= .
	replace ocusec=1 if lf32==10 			// Public Sector
	replace ocusec=2 if inrange(lf32,12,16) // Private,NGO
	replace ocusec=2 if lf32==96			// Other, assigned to Private,NGO
	replace ocusec=3 if lf32==11 			// State-owned
	replace ocusec=2 if ocusec==. & lstatus==1
	replace ocusec=. if lstatus!=1
	
	label var ocusec"Sector of activity primary job"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec>

*<_industry_orig>
	gen industry_orig = string(lf20_fourdigit, "%04.0f")  if lstatus == 1 & !missing(lf20_fourdigit)
	replace industry_orig = string(lf05_fourdigit, "%04.0f")  if lstatus == 1 & !missing(lf20_fourdigit) & missing(industry_orig)
	label var industry_orig "Original industry record"
*</_industry_orig>


*<_industrycat_isic>
	gen industrycat_isic = string(lf20_twodigit, "%02.0f") + "00" if lstatus == 1 & !missing(lf20_twodigit)
	replace industrycat_isic = string(lf05_twodigit, "%04.0f") + "00" if lstatus == 1 & !missing(lf05_twodigit) & missing(lf05_twodigit)
	label var industrycat_isic "ISIC code of primary job 12 month recall"
*</_industrycat_isic_>


*<_industrycat10>
	gen byte industrycat10= .
	* Map ISIC Rev.4 2-digit sections to your 10-category scheme
	replace industrycat10 = lf20_twodigit
	replace industrycat10 = lf05_twodigit if lstatus==1 & industrycat10==.
	recode industrycat10 ///
		(1/3 = 1)  /// Agriculture, forestry & fishing (A: 01–03)
		(5/9 = 2)  /// Mining & quarrying (B: 05–09)
		(10/33 = 3) /// Manufacturing (C: 10–33)
		(35/39 = 4) /// Electricity, gas, steam; water supply & waste (D–E: 35–39)
		(41/43 = 5) /// Construction (F: 41–43)
		(45/47 55/56 = 6) /// Wholesale/retail; accommodation & food (G & I: 45–47, 55–56)
		(49/53 58/63 = 7) /// Transport & storage; Info & comms (H & J: 49–53, 58–63)
		(64/82 = 8)  /// Financial & business services (K–N: 64–82)
		(84 = 9)     /// Public administration (O: 84)
		(85/99 = 10) /// Other services incl. education, health, arts, households, extraterritorial (P–U: 85–99)
		
	replace industrycat10 = . if lstatus != 1
	label var industrycat10 "1 digit industry classification, primary job"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
*</_industrycat10>


*<_industrycat4>
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label var industrycat4 "Broad Economic Activities classification, primary job"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4>

*<_occup_orig_>
	gen occup_orig = string(lf18_fourdigit)
	replace occup_orig = occup_orig + "0" if length(occup_orig)==3
	replace occup_orig = "" if lstatus != 1
	label var occup_orig"Original occupation record primary job"
*</_occup_orig>


*<_occup_isco_>
	gen occup_isco = occup_orig
	label var occup_isco "ISCO code of primary job"
*</_occup_isco>
*/

*<_occup>
	gen byte occup = .
	replace occup =lf18_onedigit
	recode occup (0 = 10)
	replace occup = . if lstatus != 1
	label var occup "1 digit occupational classification, primary job"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup>


*<_occup_skill_>
	gen occup_skill = .
	replace occup_skill = 3 if inrange(occup, 1, 3)
	replace occup_skill = 2 if inrange(occup, 4, 8)
	replace occup_skill = 1 if occup == 9
	la de lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lblskill
	label var occup_skill "Skill based on ISCO standard primary job"
*</_occup_skill_year_>


*<_wage_no_compen> 
	gen wage_no_compen = lf67
	replace wage_no_compen= lf72 if missing(wage_no_compen) & lf72!=-98
	label var wage_no_compen "Last wage payment primary job"
*</_wage_no_compen_>


*<_unitwage>
	gen byte unitwage = .
	replace unitwage=1 if lf68==2
	replace unitwage=2 if lf68==3
	replace unitwage=3 if lf68==4
	replace unitwage=5 if lf68==5
	replace unitwage=8 if lf68==6
	replace unitwage=9 if lf68==1
	replace unitwage=10 if lf68==96
	replace unitwage = 5 if !missing(lf72) & missing(lf67) & lf72!=-98
	label var unitwage "Last wages' time unit primary job"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours>
* Code this with usual work hours
	gen whours = lf65
	recode whours (0 = .)
	replace whours = . if lstatus != 1
	label var whours "Hours of work in last week primary job"
*</_whours>


*<_wmonths>
	gen wmonths = lf59a
	recode wmonths (0 = .)
	replace wmonths = . if lstatus != 1
	label var wmonths "Months of work in past 12 months primary job"
*</_wmonths>


*<_wage_total>
	gen double wage_total=.
	replace wage_total=(wage_no_compen*5*4.3)*wmonths	if unitwage==1
	//Wage in daily unit 
	replace wage_total=(wage_no_compen*4.3)*wmonths if unitwage==2 //Wage in weekly unit
	replace wage_total=(wage_no_compen*2.15)*wmonths	if unitwage==3
	//Wage in every two weeks unit 
	replace wage_total=(wage_no_compen)/2*wmonths	if unitwage==4 //Wage in every two months unit 
	replace wage_total=( wage_no_compen)*wmonths	if unitwage==5 //Wage in monthly unit
	replace wage_total=( wage_no_compen)/3*wmonths	if unitwage==6
	//Wage in every quarterly unit 
	replace wage_total=(wage_no_compen)/6*wmonths	if unitwage==7 //Wage in every six months unit 
	replace wage_total= wage_no_compen/12*wmonths	if unitwage==8 //Wage in annual unit
	replace wage_total=(wage_no_compen*whours*4.3)*wmonths if unitwage==9 //Wage in hourly unit
	label var wage_total "Annualized total wage primary job 12 month recall"
*</_wage_total>


*<_contract>
* Did not ask if there is contract (only the nature of the contract)
	gen byte contract = .
	label var contract "Employment has contract primary job"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract>


*<_healthins>
	gen byte healthins = .
	label var healthins "Employment has health insurance primary job"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins>


*<_socialsec>
	gen byte socialsec= .
	replace socialsec=1 if inrange(lf36,1,3) & empstat == 1
	replace socialsec=0 if lf36==4 & empstat == 1
	label var socialsec "Employment has social security insurance primary job"
	la de lblsocialsec 1 "With social security" 0 "Without social secturity"
	label values socialsec lblsocialsec
*</_socialsec>


*<_union>
	gen byte union = .
	label var union "Union membership at primary job"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union>


*<_firmsize_l>
	gen firmsize_l = .
	replace firmsize_l=1 if lf42a==1
	replace firmsize_l=2 if lf42a==2
	replace firmsize_l=5 if lf42a==3
	replace firmsize_l=10 if lf42a==4
	replace firmsize_l=20 if lf42a==5
	replace firmsize_l=50 if lf42a==6
	label var firmsize_l "Firm size (lower bracket) primary job"
*</_firmsize_l>


*<_firmsize_u>
	gen firmsize_u = .
	replace firmsize_u=1 if lf42a==1
	replace firmsize_u=4 if lf42a==2
	replace firmsize_u=9 if lf42a==3
	replace firmsize_u=19 if lf42a==4
	replace firmsize_u=49 if lf42a==5
	replace firmsize_u=. if lf42a==6
	label var firmsize_u "Firm size (upper bracket) primary job"
*</_firmsize_u>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>

*It seems that there was a mistake during the survey for lf49==2 & lf51. Ill categorize them as self employed

	gen byte empstat_2 = .
	replace empstat_2=1 if lf49==1
	replace empstat_2=2 if lf49==3 | lf49==4 | lf49==5
	replace empstat_2=4 if lf49== 2 
	replace empstat_2 = . if lstatus != 1 
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen ocusec_2 = .
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2>
	gen industry_orig_2 = string(lf48_fourdigit, "%04.0f")  if lstatus == 1 & !missing(lf48_fourdigit)
	replace industry_orig_2 = "" if missing(empstat_2)
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2>
	gen industrycat_isic_2 = string(lf48_twodigit, "%02.0f") + "00" if lstatus == 1 & !missing(lf48_twodigit)
	replace industrycat_isic_2 = "" if missing(empstat_2)
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen industrycat10_2 = .
	replace industrycat10_2= lf48_twodigit
	recode industrycat10_2 (1/3=1) (5/9 = 2) (10/33 = 3) (35/39 = 4) (41/43 = 5) (45/47 55/56 = 6) (49/53 58/63 = 7) (64/82 = 8) (84 = 9) (85/99 = 10)
	label var industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
	label values industrycat10_2 lblindustrycat10
*</_industrycat10_2_>


*<_industrycat4_2_>
	gen byte industrycat4_2 = industrycat10_2
	recode industrycat4_2 (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label var industrycat4_2 "Broad Economic Activities classification, secondary job 7 day recall"
	label values industrycat4_2 lblindustrycat4
*</_industrycat4_2_>


*<_occup_orig_2_>
	gen occup_orig_2 = string(lf46_fourdigit)
	replace occup_orig_2 = occup_orig_2 + "0" if length(occup_orig_2)==3
	replace occup_orig_2 = "" if missing(empstat_2)
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen occup_isco_2 = occup_orig_2
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_2_>
	gen occup_2 = lf46_onedigit
	recode occup_2 (0 = 10)
	label var occup_2 "1 digit occupational classification secondary job 7 day recall"
	label values occup_2 lbloccup
*</_occup_2_>


*<_occup_skill_2_>
	gen occup_skill_2 = .
	replace occup_skill_2 = 3 if inrange(occup_2, 1, 3)
	replace occup_skill_2 = 2 if inrange(occup_2, 4, 8)
	replace occup_skill_2 = 1 if occup_2 == 9
	la de lblskill2 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_2 lblskill2
	label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>


*<_wage_no_compen_2_>
	gen wage_no_compen_2 = lf73 
	replace wage_no_compen= lf78 if missing(lf73) & wage_no_compen_2==. & lf78!=-98
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	*There seems to be a coding error wit this variable, since most values are 0.
	gen byte unitwage_2 =.
	replace unitwage_2=1 if lf74==2
	replace unitwage_2=2 if lf74==3
	replace unitwage_2=3 if lf74==4
	replace unitwage_2=5 if lf74==5
	replace unitwage_2=8 if lf74==6
	replace unitwage_2=9 if lf74==1
	replace unitwage_2=10 if lf74==96
	replace unitwage = 5 if missing(lf73) & !missing(lf78) & lf78!=-98
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
	gen whours_2 = lf66
	recode whours_2 (0 = .)
	replace whours_2 = . if missing(empstat_2)
	label var whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>


*<_wmonths_2_>
	gen wmonths_2 = lf59b
	recode wmonths_2 (0 = .)
	replace wmonths_2 = . if missing(empstat_2)
	label var wmonths_2 "Months of work in past 12 months secondary job 7 day recall"
*</_wmonths_2_>


*<_wage_total_2_>
	* Since there seems to be something wrong eith unitwage_2, it doesnt seem right to create this variable
	gen wage_total_2 = .
	replace wage_total_2=(wage_no_compen_2*5*4.3)*wmonths_2	if unitwage_2==1
	//Wage in daily unit 
	replace wage_total_2=(wage_no_compen_2*4.3)*wmonths_2 if unitwage_2==2 //Wage in weekly unit
	replace wage_total_2=(wage_no_compen_2*2.15)*wmonths_2	if unitwage_2==3
	//Wage in every two weeks unit 
	replace wage_total_2=(wage_no_compen_2)/2*wmonths_2	if unitwage_2==4 //Wage in every two months unit 
	replace wage_total_2=( wage_no_compen_2)*wmonths_2	if unitwage_2==5 //Wage in monthly unit
	replace wage_total_2=( wage_no_compen_2)/3*wmonths_2	if unitwage_2==6
	//Wage in every quarterly unit 
	replace wage_total_2=(wage_no_compen_2)/6*wmonths_2	if unitwage_2==7 //Wage in every six months unit 
	replace wage_total_2= wage_no_compen_2/12*wmonths_2	if unitwage_2==8 //Wage in annual unit
	replace wage_total_2=(wage_no_compen_2*whours*4.3)*wmonths_2 if unitwage_2==9 //Wage in hourly unit
	label var wage_total_2 "Annualized total wage primary job 12 month recall"
	label var wage_total_2 "Annualized total wage secondary job 7 day recall"
*</_wage_total_2_>


*<_firmsize_l_2>
	gen firmsize_l_2 = .
	replace firmsize_l_2=1 if lf57==1
	replace firmsize_l_2=2 if lf57==2
	replace firmsize_l_2=5 if lf57==3
	replace firmsize_l_2=10 if lf57==4
	replace firmsize_l_2=20 if lf57==5
	replace firmsize_l_2=50 if lf57==6
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2>


*<_firmsize_u_2>
	gen firmsize_u_2 = .
	replace firmsize_u_2=1 if lf57==1
	replace firmsize_u_2=4 if lf57==2
	replace firmsize_u_2=9 if lf57==3
	replace firmsize_u_2=19 if lf57==4
	replace firmsize_u_2=49 if lf57==5
	replace firmsize_u_2=. if lf57==6
	label var firmsize_u_2 "Firm size (upper bracket) secondary job 7 day recall"
*</_firmsize_u_2>


}

*----------8.4: 7 day reference additional jobs------------------------------*

*<_t_hours_others_>
	gen t_hours_others = .
	label var t_hours_others "Annualized hours worked in all but primary and secondary jobs 7 day recall"
*</_t_hours_others_>


*<_t_wage_nocompen_others_>
	gen t_wage_nocompen_others = .
	label var t_wage_nocompen_others "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_others_>


*<_t_wage_others_>
	gen t_wage_others = .
	label var t_wage_others "Annualized wage in all but primary and secondary jobs (12-mon ref period)"
*</_t_wage_others_>


*----------8.5: 7 day reference total summary------------------------------*


*<_t_hours_total_>
	egen t_hours_total = rowtotal(whours whours_2),m
	label var t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
	egen t_wage_nocompen_total = rowtotal(wage_no_compen wage_no_compen_2),m
	label var t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
	egen t_wage_total = rowtotal(wage_total wage_total_2),m
	label var t_wage_total "Annualized total wage for all jobs 7 day recall"
*</_t_wage_total_>

*----------8.6: 12 month reference overall------------------------------*

{

*<_lstatus_year_>
	gen byte lstatus_year = .
	replace lstatus_year = . if age < minlaborage & !missing(age)
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>

*<_potential_lf_year_>
	gen byte potential_lf_year = .
	replace potential_lf_year = . if age < minlaborage & !missing(age)
	replace potential_lf_year = . if lstatus_year != 3
	label var potential_lf_year "Potential labour force status"
	la de lblpotential_lf_year 0 "No" 1 "Yes"
	label values potential_lf_year lblpotential_lf_year
*</_potential_lf_year_>


*<_underemployment_year_>
	gen byte underemployment_year = .
	replace underemployment_year = . if age < minlaborage & !missing(age)
	replace underemployment_year = . if lstatus_year == 1
	label var underemployment_year "Underemployment status"
	la de lblunderemployment_year 0 "No" 1 "Yes"
	label values underemployment_year lblunderemployment_year
*</_underemployment_year_>


*<_nlfreason_year_>
	gen byte nlfreason_year = .
	label var nlfreason_year "Reason not in the labor force"
	la de lblnlfreason_year 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason_year lblnlfreason_year
*</_nlfreason_year_>


*<_unempldur_l_year_>
	gen byte unempldur_l_year = .
	label var unempldur_l_year "Unemployment duration (months) lower bracket"
*</_unempldur_l_year_>


*<_unempldur_u_year_>
	gen byte unempldur_u_year = .
	label var unempldur_u_year "Unemployment duration (months) upper bracket"
*</_unempldur_u_year_>

}

*----------8.7: 12 month reference main job------------------------------*

{

*<_empstat_year_>
	gen byte empstat_year =.
	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>

*<_ocusec_year_>
	gen byte ocusec_year = .
	label var ocusec_year "Sector of activity primary job 12 month recall"
	la de lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_year lblocusec_year
*</_ocusec_year_>

*<_industry_orig_year_>
	gen industry_orig_year = ""
	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	gen industrycat_isic_year = ""
	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>

*<_industrycat10_year_>
	gen byte industrycat10_year = .
	label var industrycat10_year "1 digit industry classification, primary job 12 month recall"
	la de lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_year lblindustrycat10_year
*</_industrycat10_year_>


*<_industrycat4_year_>
	gen byte industrycat4_year = .
	recode industrycat4_year (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label var industrycat4_year "Broad Economic Activities classification, primary job 12 month recall"
	la de lblindustrycat4_year 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4_year lblindustrycat4_year
*</_industrycat4_year_>


*<_occup_orig_year_>
	gen occup_orig_year = ""
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	gen occup_isco_year = ""
	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_year_>
	gen byte occup_year = .
	label var occup_year "1 digit occupational classification, primary job 12 month recall"
	la de lbloccup_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_year lbloccup_year
*</_occup_year_>


*<_occup_skill_year_>
	gen occup_skill_year = .
	replace occup_skill_year = 3 if inrange(occup_year, 1, 3)
	replace occup_skill_year = 2 if inrange(occup_year, 4, 8)
	replace occup_skill_year = 1 if occup_year == 9
	la de lblskillyear 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_year lblskillyear
	label var occup_skill_year "Skill based on ISCO standard primary job 12 month recall"
*</_occup_skill_year_>


*<_wage_no_compen_year_> 
	gen double wage_no_compen_year = .
	label var wage_no_compen_year "Last wage payment primary job 12 month recall"
*</_wage_no_compen_year_>


*<_unitwage_year_>
	gen byte unitwage_year = .
	label var unitwage_year "Last wages' time unit primary job 12 month recall"
	la de lblunitwage_year 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_year lblunitwage_year
*</_unitwage_year_>


*<_whours_year_>
* Code this with usual work hours
	gen whours_year = .
	label var whours_year "Hours of work in last week primary job 12 month recall"
*</_whours_year_>


*<_wmonths_year_>
	gen wmonths_year = .
	label var wmonths_year "Months of work in past 12 months primary job 12 month recall"
*</_wmonths_year_>


*<_wage_total_year_>
	gen wage_total_year = .
	label var wage_total_year "Annualized total wage primary job 12 month recall"
*</_wage_total_year_>


*<_contract_year_>
	gen byte contract_year = .
	label var contract_year "Employment has contract primary job 12 month recall"
	la de lblcontract_year 0 "Without contract" 1 "With contract"
	label values contract_year lblcontract_year
*</_contract_year_>


*<_healthins_year_>
	gen byte healthins_year = .
	label var healthins_year "Employment has health insurance primary job 12 month recall"
	la de lblhealthins_year 0 "Without health insurance" 1 "With health insurance"
	label values healthins_year lblhealthins_year
*</_healthins_year_>


*<_socialsec_year_>
	gen byte socialsec_year = .
	label var socialsec_year "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec_year 1 "With social security" 0 "Without social secturity"
	label values socialsec_year lblsocialsec_year
*</_socialsec_year_>


*<_union_year_>
	gen byte union_year = .
	label var union_year "Union membership at primary job 12 month recall"
	la de lblunion_year 0 "Not union member" 1 "Union member"
	label values union_year lblunion_year
*</_union_year_>


*<_firmsize_l_year_>
	gen firmsize_l_year = .
	label var firmsize_l_year "Firm size (lower bracket) primary job 12 month recall"
*</_firmsize_l_year_>


*<_firmsize_u_year_>
	gen firmsize_u_year = .
	label var firmsize_u_year "Firm size (upper bracket) primary job 12 month recall"
*</_firmsize_u_year_>

}


*----------8.8: 12 month reference secondary job------------------------------*

{

*<_empstat_2_year_>
	gen byte empstat_2_year = .
	label var empstat_2_year "Employment status during past week secondary job 12 month recall"
	label values empstat_2_year lblempstat_year
*</_empstat_2_year_>


*<_ocusec_2_year_>
	gen byte ocusec_2_year = .
	label var ocusec_2_year "Sector of activity secondary job 12 month recall"
	la de lblocusec_2_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_2_year lblocusec_2_year
*</_ocusec_2_year_>



*<_industry_orig_2_year_>
	gen industry_orig_2_year = .
	label var industry_orig_2_year "Original survey industry code, secondary job 12 month recall"
*</_industry_orig_2_year_>



*<_industrycat_isic_2_year_>
	gen industrycat_isic_2_year = .
	label var industrycat_isic_2_year "ISIC code of secondary job 12 month recall"
*</_industrycat_isic_2_year_>


*<_industrycat10_2_year_>
	gen byte industrycat10_2_year = .
	label var industrycat10_2_year "1 digit industry classification, secondary job 12 month recall"
	label values industrycat10_2_year lblindustrycat10_year
*</_industrycat10_2_year_>


*<_industrycat4_2_year_>
	gen byte industrycat4_2_year = industrycat10_2_year
	recode industrycat4_2_year (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label var industrycat4_2_year "Broad Economic Activities classification, secondary job 12 month recall"
	label values industrycat4_2_year lblindustrycat4_year
*</_industrycat4_2_year_>


*<_occup_orig_2_year_>
	gen occup_orig_2_year = .
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
	gen occup_isco_2_year = ""
	label var occup_isco_2_year "ISCO code of secondary job 12 month recall"
*</_occup_isco_2_year_>


*<_occup_2_year_>
	gen byte occup_2_year = .
	label var occup_2_year "1 digit occupational classification, secondary job 12 month recall"
	label values occup_2_year lbloccup_year
*</_occup_2_year_>


*<_occup_skill_2_year_>
	gen occup_skill_2_year = .
	replace occup_skill_2_year = 3 if inrange(occup_2_year, 1, 3)
	replace occup_skill_2_year = 2 if inrange(occup_2_year, 4, 8)
	replace occup_skill_2_year = 1 if occup_2_year == 9
	la de lblskilly2 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_2_year lblskilly2
	label var occup_skill_2_year "Skill based on ISCO standard secondary job 12 month recall"
*</_occup_skill_2_year_>


*<_wage_no_compen_2_year_>
	gen double wage_no_compen_2_year = .
	label var wage_no_compen_2_year "Last wage payment secondary job 12 month recall"
*</_wage_no_compen_2_year_>


*<_unitwage_2_year_>
	gen byte unitwage_2_year = .
	label var unitwage_2_year "Last wages' time unit secondary job 12 month recall"
	label values unitwage_2_year lblunitwage_year
*</_unitwage_2_year_>


*<_whours_2_year_>
	gen whours_2_year = .
	label var whours_2_year "Hours of work in last week secondary job 12 month recall"
*</_whours_2_year_>


*<_wmonths_2_year_>
	gen wmonths_2_year = .
	label var wmonths_2_year "Months of work in past 12 months secondary job 12 month recall"
*</_wmonths_2_year_>


*<_wage_total_2_year_>
	gen wage_total_2_year = .
	label var wage_total_2_year "Annualized total wage secondary job 12 month recall"
*</_wage_total_2_year_>

*<_firmsize_l_2_year_>
	gen firmsize_l_2_year = .
	label var firmsize_l_2_year "Firm size (lower bracket) secondary job 12 month recall"
*</_firmsize_l_2_year_>


*<_firmsize_u_2_year_>
	gen firmsize_u_2_year = .
	label var firmsize_u_2_year "Firm size (upper bracket) secondary job 12 month recall"
*</_firmsize_u_2_year_>

}


*----------8.9: 12 month reference additional jobs------------------------------*


*<_t_hours_others_year_>
	gen t_hours_others_year = .
	label var t_hours_others_year "Annualized hours worked in all but primary and secondary jobs 12 month recall"
*</_t_hours_others_year_>

*<_t_wage_nocompen_others_year_>
	gen t_wage_nocompen_others_year = .
	label var t_wage_nocompen_others_year "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_others_year_>

*<_t_wage_others_year_>
	gen t_wage_others_year = .
	label var t_wage_others_year "Annualized wage in all but primary and secondary jobs 12 month recall"
*</_t_wage_others_year_>


*----------8.10: 12 month total summary------------------------------*


*<_t_hours_total_year_>
	gen t_hours_total_year = .
	label var t_hours_total_year "Annualized hours worked in all jobs 12 month month recall"
*</_t_hours_total_year_>


*<_t_wage_nocompen_total_year_>
	gen t_wage_nocompen_total_year = .
	label var t_wage_nocompen_total_year "Annualized wage in all jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_total_year_>


*<_t_wage_total_year_>
	gen t_wage_total_year = .
	label var t_wage_total_year "Annualized total wage for all jobs 12 month recall"
*</_t_wage_total_year_>


*----------8.11: Overall across reference periods------------------------------*


*<_njobs_>
	gen njobs = .
	replace njobs = 1 if lstatus == 1 & !missing(empstat) & missing(empstat_2)
	replace njobs = 2 if lstatus == 1 & !missing(empstat) & !missing(empstat_2)
	label var njobs "Total number of jobs"
*</_njobs_>


*<_t_hours_annual_>
	gen t_hours_annual = .
	label var t_hours_annual "Total hours worked in all jobs in the previous 12 months"
*</_t_hours_annual_>


*<_linc_nc_>
	gen linc_nc = .
	label var linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."
*</_linc_nc_>


*<_laborincome_>
	gen laborincome = t_wage_total_year
	label var laborincome "Total annual individual labor income in all jobs, incl. bonuses, etc."
*</_laborincome_>

*----------8.13: Labour cleanup------------------------------*

{
*<_% Correction min age_>

ren lstatus lstatus


** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
	local lab_vars "minlaborage lstatus nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome"

	foreach lab_var of local lab_vars {
		cap confirm numeric variable `lab_var'
		if _rc == 0 { // is indeed numeric
			replace `lab_var' = . if ( age < minlaborage & !missing(age) )
		}
		else { // is not
			replace `lab_var' = "" if ( age < minlaborage & !missing(age) )
		}

	}

*</_% Correction min age_>
}


/*%%=============================================================================================
	9: Final steps
==============================================================================================%%*/

quietly{

*<_% KEEP VARIABLES - ALL_>

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% ORDER VARIABLES_>

*<_% DROP UNUSED LABELS_>

	* Store all labels in data
	label dir
	local all_lab `r(names)'

	* Store all variables with a label, extract value label names
	local used_lab = ""
	ds, has(vallabel)

	local labelled_vars `r(varlist)'

	foreach varName of local labelled_vars {
		local y : value label `varName'
		local used_lab `"`used_lab' `y'"'
	}

	* Compare lists, `notused' is list of labels in directory but not used in final variables
	local notused 		: list all_lab - used_lab 		// local `notused' defines value labs not in remaining vars
	local notused_len 	: list sizeof notused 			// store size of local

	* drop labels if the length of the notused vector is 1 or greater, otherwise nothing to drop
	if `notused_len' >= 1 {
		label drop `notused'
	}
	else {
		di "There are no unused labels to drop. No value labels dropped."
	}


*</_% DROP UNUSED LABELS_>

}


*<_% DELETE MISSING VARIABLES_>

quietly: describe, varlist
local kept_vars `r(varlist)'

foreach kept_var of local kept_vars {
	
	capture assert missing(`kept_var')
	if !_rc drop `kept_var'
   
}

*</_% DELETE MISSING VARIABLES_>


*<_% COMPRESS_>

compress

*</_% COMPRESS_>


*<_% SAVE_>

save "`path_output'/`out_file'", replace

*</_% SAVE_>
