
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				TJK_2009_LFS_V01_M_V02_A_GLD_ALL.do </_Program name_>
<_Application_>					[Name of your software (STATA) and version] <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2025-04-18 </_Date created_>

-------------------------------------------------------------------------

<_Country_>					TJK </_Country_>
<_Survey Title_>				Labor Force Survey </_Survey Title_>
<_Survey Year_>					2009 </_Survey Year_>
<_Study ID_>					[Microdata Library ID if present] </_Study ID_>
<_Data collection from_>			06/2009 </_Data collection from_>
<_Data collection to_>				07/2009 </_Data collection to_>
<_Source of dataset_> 				[Source of data, e.g. NSO] </_Source of dataset_>
<_Sample size (HH)_> 				4937 </_Sample size (HH)_>
<_Sample size (IND)_> 				17177 </_Sample size (IND)_>
<_Sampling method_> 				[Brief description] </_Sampling method_>
<_Geographic coverage_> 			[To what level is data significant] </_Geographic coverage_>
<_Currency_> 					[Currency used for wages] </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				[Version of ICLS for Labor Questions] </_ICLS Version_>
<_ISCED Version_>				[Version of ICLS for Labor Questions] </_ISCED Version_>
<_ISCO Version_>				[Version of ICLS for Labor Questions] </_ISCO Version_>
<_OCCUP National_>				[Version of ICLS for Labor Questions] </_OCCUP National_>
<_ISIC Version_>				[Version of ICLS for Labor Questions] </_ISIC Version_>
<_INDUS National_>				[Version of ICLS for Labor Questions] </_INDUS National_>

-----------------------------------------------------------------------
<_Version Control_>

* Date: [YYYY-MM-DD] - [Description of changes]
* Date: [YYYY-MM-DD] - [Description of changes]

* Date: 2026-02-25 - remove firm_regis

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

* Define path sections
local server  "C:/Users/`c(username)'/WBG/GLD - GLD Files"
local country "TJK"
local year    "2009"
local survey  "LFS"
local vermast "V01"
local veralt  "V02"

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

use "`path_in_stata'/lfs_2009.dta", clear

/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode = "TJK"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "LFS"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "LFS"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	gen icls_v = "ICLS-13"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	gen isced_version = "isced_1997"
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
	gen isco_version = "isco_1988"
	label var isco_version "Version of ISCO used"
*</_isco_version_>

*<_isic_version_>
	gen isic_version = "isic_3.1"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	gen int year = 2009
	label var year "Year of survey"
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
	gen int_year = 2009
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen  int_month = a85_2
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
/* <_hhid_note>

	The variable should be a string made up of the elements to define it, that is psu code, ssu, ...
	Each element should always be as long as needed for the longest element. That is, if there are
	60 psu coded 1 through 60, codes should be 01, 02, ..., 60. If there are 160 it should be 001,
	002, ..., 160.

</_hhid_note> */
	tostring id,  gen(hhid) format(%04.0f)
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	tostring nr, gen(person_str) format(%02.0f)
	egen  pid = concat(hhid person_str)
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
	*gen weight = .
	label var weight "Survey sampling weight"
*</_weight_>


*<_weight_m_>
	gen weight_m = .
	label var weight_m "Survey sampling weight to obtain national estimates for each month"
*</_weight_m_>


*<_weight_q_>
	gen weight_q = .
	label var weight_q "Survey sampling weight to obtain national estimates for each quarter"
*</_weight_q_>


*<_psu_>
	gen psu = pve
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = hhid
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	gen strata = .
	label var strata "Strata"
*</_strata_>


*<_wave_>
	gen wave = .
	label var wave "Survey wave"
*</_wave_>


*<_panel_>
	gen panel = ""
	label var panel "Panel individual belongs to"
*</_panel_>


*<_visit_no_>
	gen visit_no = .
	label var visit_no "Visit number in panel"
*</_visit_no_>

}


/*%%=============================================================================================
	3: Geography
==============================================================================================%%*/

{

*<_urban_>
	gen byte urban = place
	recode urban (2 = 0)
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
/* <_subnatid1_note>

	The variable is string and country-specific categorical. Numeric entries are coded in string format using the following naming convention: "1 – Hatay". That is, the variable itself is to be string, not a labelled numeric vector. 
	
	Example of entries would be "1 - Alaska",  "2 - Arkansas", ...
	
	With the actual information we have the regions(oblast) codes but no the region string

</_subnatid1_note> */
	tostring oblast, gen(subnatid1)
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
/* <_subnatid2_note>

	Same as subnatid1
	
</_subnatid2_note> */
	tostring region_city, gen(subnatid2)
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	gen str subnatid3 = ""
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
/* <_subnatidsurvey_note>

	Variable denoting lowest administrative info to which the survey is still significat.
	See entry in GLD Guidelines (https://github.com/worldbank/gld/blob/main/Support/A%20-%20Guides%20and%20Documentation/GLD_1.0_Guidelines.docx) for more details

</_subnatidsurvey_note> */
	gen str subnatidsurvey = ""
	label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>


*<_subnatid1_prev_>
/* <_subnatid1_prev_note>

	subnatid1_prev is coded as missing unless the classification used for subnatid1 has changed since the previous survey.

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


/*%%=============================================================================================
	4: Demography
==============================================================================================%%*/

{

*<_hsize_>
	bys hhid : gen hsize = _N
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen age = vozr
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = pol
	recode male (2 = 0)
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen relationharm = .
	replace relationharm = a5
	recode relationharm (6 7 8 9 10 = 5) (11 = 6)
	
	*Not head coded
	gen count_heads = (relationharm == 1)
	bys hhid : egen total_heads = total(count_heads)
	
	*spouse
	gen new_head = 1 if total_heads == 0 & a5 == 2 
	bys hhid : egen hh_new_head = count(new_head)
	
	gen count_spouses = (new_head == 1)
	bys hhid : egen total_spouses = total(count_spouses)
	bys hhid (age) : replace relationharm = 5 if total_spouses == 2 & a5 == 2 & age != age[_N]

	*oldest member
	bysort hhid (age): gen oldest = (_n == _N) if total_heads == 0 & hh_new_head == 0
	replace new_head = 2 if oldest == 1 & missing(new_head)
	bysort hhid (age) : gen hh_oldest = 1 if oldest[_N] == 1
	
	replace relationharm = 1 if new_head == 1 & relationharm == 2
	replace relationharm = 5 if new_head == 1 & relationharm == 4
	replace relationharm = 1 if new_head == 2
	replace relationharm = 5 if hh_oldest == 1 & relationharm != 1
	
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = a5
	la de lblrelationcs 1 "Head of household" 2 "Wife, husband" 3 "Daughter, son" 4 "Mother, father" 5 "Sister, brother" 6 "Mother-in-law, father-in-law" 7 "Daughter-in-law, son-in-law" 8 "Grandmother, grandfather" 9 "Granddaughter, grandson" 10 "Other relative" 11 "Not a relative"
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital = brach
	recode marital (2 = 3) (3 = 5) (4 5 = 4) (6 = 2)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	gen eye_dsablty = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
	label values eye_dsablty dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values hear_dsablty dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values walk_dsablty dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values conc_dsord dsablty
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty  = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values slfcre_dsablty dsablty
	label var slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty = .
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
	gen migrated_mod_age = .
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time = .
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen migrated_binary = .
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen migrated_years = .
	replace migrated_years = . if migrated_binary != 1
	label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban = .
	replace migrated_from_urban = . if migrated_binary != 1
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen migrated_from_cat = .
	replace migrated_from_cat = . if migrated_binary != 1
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country" 6 "Within country, admin unknown" 7 "Wholly unknow"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen migrated_from_code = .
	replace migrated_from_code = . if migrated_binary != 1
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country = .
	replace migrated_from_country = . if migrated_binary != 1
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason = .
	replace migrated_reason = . if migrated_binary != 1
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

Education module is only asked to those XX and older.

</_ed_mod_age_note> */

gen byte ed_mod_age = 12
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school = .
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen byte literacy = .
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
/* <_educy_note>

	1- Higher
	2- Incomplete higher education
	3- Vocational secondary education
	4- Primary vocational
	5- Secondary (complete)
	6- Basic general
	7- Elementary general
	8- Don't have elementary general

</_educy_note> */
	
	* Use Tajikistan ISCED 1997 Mapping 
	gen byte educy = .
	replace educy = 0 if obraz == 8
	replace educy = 4 if obraz == 7
	replace educy = 9 if obraz == 6
	replace educy = 11 if obraz == 5
	replace educy = 12 if obraz == 4
	replace educy = 13 if obraz == 3
	replace educy = 14 if obraz == 2
	replace educy = 15 if obraz == 1
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7 = obraz
	recode educat7 (8 = 1) (7 = 3) (6 = 4) (5 4 = 5) (3 = 6) (2 1 = 7)
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
	replace educat_orig = "Higher" if obraz == 1
	replace educat_orig = "Incomplete higher education" if obraz == 2
	replace educat_orig = "Vocational secondary education" if obraz == 3
	replace educat_orig = "Primary vocational" if obraz == 4
	replace educat_orig = "Secondary (complete)" if obraz == 5
	replace educat_orig = "Basic general" if obraz == 6
	replace educat_orig = "Elementary general" if obraz == 7
	replace educat_orig = "Don't have elementary general" if obraz == 8
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
	gen educat_isced = ""
	replace educat_isced = "0" if obraz == 8
	replace educat_isced = "1" if obraz == 7
	replace educat_isced = "2A" if obraz == 6
	replace educat_isced = "3A" if obraz == 5
	replace educat_isced = "3C" if obraz == 4
	replace educat_isced = "4B" if obraz == 3
	replace educat_isced = "5" if obraz == 2
	replace educat_isced = "5" if obraz == 1
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
	gen byte minlaborage = 12
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
	gen byte lstatus = .
	
	*employed
	gen lstatus_emp = (a11 == 1) | (a12 == 1) | (a13_a == 2) | (a13_b == 2) | inlist(a14_a, 1, 2, 3, 4, 8, 11, 12, 13, 14) | (a14_v == 1) | (a14_d == 1)
	
		* Add own consumption
		replace lstatus_emp = 1 if a13_a == 1 
	
	replace lstatus = 1 if lstatus_emp == 1
	
	*unemployed
		// passive (bz_got1) If you were offered paid job, would you have been able to start last week?
		// active = (psk_bz*) Within 4 weeks preceding the last week, what steps did you make to find a job or organize your own business?
		* There are broader questions but we used the more accurate with GLD definitions
	gen passive = (bz_got1 == 1)
	gen active = 0
	replace active = 1 if psk_bz1 == 1 | psk_bz2 == 1 | psk_bz3 == 1 | psk_bz4 == 1 | psk_bz5 == 1 | psk_bz6 == 1
	
	replace lstatus = 2 if passive == 1 & active == 1 & missing(lstatus)
	
	*presently not working but waiting for the start of a new job
	replace lstatus = 2 if prch_bz1 == 1  & missing(lstatus)
	
	*NLF
	replace lstatus = 3 if missing(lstatus)
	
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
		
*</_lstatus_>

*<_potential_lf_>
	gen byte potential_lf = 0
	replace potential_lf = 1 if passive == 1 | active == 1
	replace potential_lf = . if age < minlaborage & !missing(age)
	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen byte underemployment = 0
	replace underemployment = 1 if psk_vt == 1
	replace underemployment = . if age < minlaborage & !missing(age)
	replace underemployment = . if lstatus != 1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason = .
	replace nlfreason = 1 if (prch_bz1 == 9 | prch_bz2 == 4) & missing(nlfreason)
	replace nlfreason = 2 if (prch_bz1 == 8 | prch_bz2 == 3) & missing(nlfreason)
	replace nlfreason = 3 if (prch_bz1 == 10 | prch_bz2 == 5) & missing(nlfreason)
	replace nlfreason = 4 if (prch_bz1 == 7 | prch_bz2 == 1) & missing(nlfreason)
	replace nlfreason = 5 if (inlist(prch_bz1,2,3,4,5,6,11,12) | prch_bz2 == 6)  & missing(nlfreason)
	replace nlfreason = . if lstatus != 3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l = .
	replace unempldur_l = 0 if inlist(prd_bz,1,7) | prd_nez == 1
	replace unempldur_l = 1 if prd_bz == 2 | prd_nez == 2
	replace unempldur_l = 3 if prd_bz == 3 | prd_nez == 3
	replace unempldur_l = 6 if prd_bz == 4 | prd_nez == 4
	replace unempldur_l = 9 if prd_bz == 5 | prd_nez == 5
	replace unempldur_l = 12 if prd_bz == 6 | prd_nez == 6
	replace unempldur_l = 36 if prd_nez == 7
	replace unempldur_l = . if lstatus != 2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u = .
	replace unempldur_u = 0 if prd_bz == 7
	replace unempldur_u = 1 if prd_bz == 1| prd_nez == 1
	replace unempldur_u = 3 if prd_bz == 2 | prd_nez == 2
	replace unempldur_u = 6 if prd_bz == 3 | prd_nez == 3
	replace unempldur_u = 9 if prd_bz == 4 | prd_nez == 4
	replace unempldur_u = 12 if prd_bz == 5 | prd_nez == 5
	replace unempldur_u = 36 if prd_nez == 6 
	replace unempldur_u = . if prd_bz == 6 | prd_nez == 7

	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte empstat = .
	replace empstat = 1 if v_osnrb == 2
	replace empstat = 2 if v_osnrb == 4 & missing(empstat)
	replace empstat = 3 if v_osnrb == 1 & inlist(naim_osn, 2, 3)
	replace empstat = 4 if (v_osnzan == 3) | (v_osnrb == 1 & naim_osn == 1)
	replace empstat = 5 if (v_osnrb == 3) & missing(empstat)
	
	* Add own consumption individuals 
	replace empstat = 4 if a13_a == 1 & missing(empstat)
	
	*The rest are individuals who own a business, but it is unclear whether they have employees
	*tab v_osnrb naim_osn if empstat == ., miss
	replace empstat = 5 if missing(empstat) & lstatus == 1
	
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec = kfs
	recode ocusec (4 5 6 = 2) (1 = 3) (3 = 4)
	* Add own consumption individuals 
	replace ocusec = 2 if a13_a == 1

	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	tostring vd_osn, gen(industry_orig)
	replace industry_orig = "" if lstatus != 1 | industry_orig == "."
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
/* <_industrycat_isic_note>

	They use OKVED (the Russian Classification of Economic Activities), which is aligned with NACE Rev. 1.1 at the 4-digit level
	
	NACE Rev. 1.1 is the classification of economic activities corresponding to ISIC Rev.3.1 at European level. It is  in line with ISIC Rev.3.1 at 2 digits level.	For the rest, we have to make the replaces
	
</_industrycat_isic_note> */
	gen industry_adapted = floor(vd_osn/ 10)
	tostring industry_adapted,  gen(str_industry_adpted) format(%04.0f)
	replace str_industry_adpted = "" if str_industry_adpted == "." | lstatus != 1
	replace str_industry_adpted = "0122" if inlist(str_industry_adpted,"0121","0123","0124","0125")
	replace str_industry_adpted = "0140" if inlist(str_industry_adpted,"0141","0142")
	replace str_industry_adpted = "0200" if inlist(str_industry_adpted,"0201","0202")
	replace str_industry_adpted = "1410" if inlist(str_industry_adpted,"1411","1412","1413")
	replace str_industry_adpted = "1410" if inlist(str_industry_adpted,"1421","1422")
	replace str_industry_adpted = "1422" if str_industry_adpted == "1424"
	replace str_industry_adpted = "1429" if str_industry_adpted == "1450"
	replace str_industry_adpted = "1511" if inlist(str_industry_adpted,"1511","1512","1513")
	replace str_industry_adpted = "1512" if inlist(str_industry_adpted,"1520","1521")
	replace str_industry_adpted = "1513" if inlist(str_industry_adpted,"1531","1532","1533")
	replace str_industry_adpted = "1514" if inlist(str_industry_adpted,"1541","1542","1543")
	replace str_industry_adpted = "1520" if inlist(str_industry_adpted,"1551","1552")
	replace str_industry_adpted = "1541" if inlist(str_industry_adpted,"1581","1582")
	replace str_industry_adpted = "1542" if str_industry_adpted == "1583"
	replace str_industry_adpted = "1543" if str_industry_adpted == "1584"
	replace str_industry_adpted = "1544" if str_industry_adpted == "1585"
	replace str_industry_adpted = "1549" if inlist(str_industry_adpted,"1586","1587","1588","1589")
	replace str_industry_adpted = "1551" if inlist(str_industry_adpted,"1591","1592")
	replace str_industry_adpted = "1552" if inlist(str_industry_adpted,"1593","1594")
	replace str_industry_adpted = "1553" if inlist(str_industry_adpted,"1595","1596","1597")
	replace str_industry_adpted = "1554" if str_industry_adpted == "1598"
	replace str_industry_adpted = "1600" if str_industry_adpted == "1600"
	replace str_industry_adpted = "1711" if inlist(str_industry_adpted,"1711","1712","1713","1714","1715","1716","1717")
	replace str_industry_adpted = "1711"  if inlist(str_industry_adpted,"1721","1722","1723","1724","1725","1730")
	replace str_industry_adpted = "1721" if str_industry_adpted == "1741"
	replace str_industry_adpted = "1722" if str_industry_adpted == "1740"
	replace str_industry_adpted = "1722" if str_industry_adpted == "1751"
	replace str_industry_adpted = "1729" if inlist(str_industry_adpted,"1752","1753","1760","1771")
	replace str_industry_adpted = "1730" if str_industry_adpted == "1772"
	replace str_industry_adpted = "1810" if inlist(str_industry_adpted,"1811","1812","1813","1814","1815","1816","1817","1818") ///
    | inlist(str_industry_adpted,"1821","1822","1823","1824")
	replace str_industry_adpted = "1820" if str_industry_adpted == "1830"
	replace str_industry_adpted = "1911" if str_industry_adpted == "1910"
	replace str_industry_adpted = "1912" if str_industry_adpted == "1920"
	replace str_industry_adpted = "2010" if inlist(str_industry_adpted,"2011","2012")
	replace str_industry_adpted = "2021" if str_industry_adpted == "2020"
	replace str_industry_adpted = "2022" if str_industry_adpted == "2030"
	replace str_industry_adpted = "2023" if str_industry_adpted == "2040"
	replace str_industry_adpted = "2029" if inlist(str_industry_adpted,"2050","2051","2052")
	replace str_industry_adpted = "2101" if inlist(str_industry_adpted,"2111","2112")
	replace str_industry_adpted = "2102" if str_industry_adpted == "2121"
	replace str_industry_adpted = "2109" if inlist(str_industry_adpted,"2122","2123","2124","2125")
	replace str_industry_adpted = "2212" if inlist(str_industry_adpted,"2213")
	replace str_industry_adpted = "2213" if inlist(str_industry_adpted,"2214")
	replace str_industry_adpted = "2219" if inlist(str_industry_adpted,"2215")
	replace str_industry_adpted = "2221" if inlist(str_industry_adpted,"2222")
	replace str_industry_adpted = "2222" if inlist(str_industry_adpted,"2223","2224","2225")
	replace str_industry_adpted = "2230" if inlist(str_industry_adpted,"2231","2232","2233")
	replace str_industry_adpted = "2411" if inlist(str_industry_adpted,"2412","2413","2414")
	replace str_industry_adpted = "2413" if inlist(str_industry_adpted,"2416","2417")
	replace str_industry_adpted = "2421" if inlist(str_industry_adpted,"242","2420")
	replace str_industry_adpted = "2422" if inlist(str_industry_adpted,"243","2430")
	replace str_industry_adpted = "2423" if inlist(str_industry_adpted,"2441","2442")
	replace str_industry_adpted = "2424" if inlist(str_industry_adpted,"2451","2452")
	replace str_industry_adpted = "2429" if inlist(str_industry_adpted,"2461","2462","2463","2464")
	replace str_industry_adpted = "2511" if inlist(str_industry_adpted,"2511","2512","2513")
	replace str_industry_adpted = "2519" if str_industry_adpted == "2513"
	replace str_industry_adpted = "2520" if inlist(str_industry_adpted,"2521","2522","2523","2524")
	replace str_industry_adpted = "2610" if inlist(str_industry_adpted,"2611","2612","2613","2614","2615")
	replace str_industry_adpted = "2691" if inlist(str_industry_adpted,"2621","2622","2623","2624","2625","2626")
	replace str_industry_adpted = "2693" if inlist(str_industry_adpted,"2630","2640")
	replace str_industry_adpted = "2694" if str_industry_adpted == "2650"
	replace str_industry_adpted = "2695" if inlist(str_industry_adpted,"2661","2662","2663","2664","2665","2666")
	replace str_industry_adpted = "2696" if str_industry_adpted == "2670"
	replace str_industry_adpted = "2699" if inlist(str_industry_adpted,"2681","2682")
	replace str_industry_adpted = "2710" if inlist(str_industry_adpted,"2711","2712","2713","2714","2715","2716","2717","2718","2719") ///
		| inlist(str_industry_adpted,"2721","2722","2731","2732","2733","2734")
	replace str_industry_adpted = "2720" if inlist(str_industry_adpted,"2741","2742","2743","2744","2745")
	replace str_industry_adpted = "2731" if str_industry_adpted == "2751"
	replace str_industry_adpted = "2731" if str_industry_adpted == "2752"
	replace str_industry_adpted = "2732" if str_industry_adpted == "2753"
	replace str_industry_adpted = "2732" if str_industry_adpted == "2754"
	replace str_industry_adpted = "2811" if inlist(str_industry_adpted,"28111","28112")
	replace str_industry_adpted = "2812" if inlist(str_industry_adpted,"28121","28122")
	replace str_industry_adpted = "2813" if str_industry_adpted == "2830"
	replace str_industry_adpted = "2891" if str_industry_adpted == "2840"
	replace str_industry_adpted = "2892" if inlist(str_industry_adpted,"2851","2852")
	replace str_industry_adpted = "2893" if inlist(str_industry_adpted,"2861","2862","2863")
	replace str_industry_adpted = "2899" if inlist(str_industry_adpted,"2871","2872","2873","2874","2875")
	replace str_industry_adpted = "2912" if str_industry_adpted == "2913"
	replace str_industry_adpted = "2913" if str_industry_adpted == "2914"
	replace str_industry_adpted = "2914" if str_industry_adpted == "2921"
	replace str_industry_adpted = "2915" if str_industry_adpted == "2922"
	replace str_industry_adpted = "2919" if inlist(str_industry_adpted,"2923","2924")
	replace str_industry_adpted = "2921" if inlist(str_industry_adpted,"2931","2932")
	replace str_industry_adpted = "2922" if inlist(str_industry_adpted,"2941","2942","2943")
	replace str_industry_adpted = "2923" if str_industry_adpted == "2951"
	replace str_industry_adpted = "2924" if str_industry_adpted == "2952"
	replace str_industry_adpted = "2925" if str_industry_adpted == "2953"
	replace str_industry_adpted = "2926" if str_industry_adpted == "2954"
	replace str_industry_adpted = "2929" if inlist(str_industry_adpted,"2955","2956")
	replace str_industry_adpted = "2927" if str_industry_adpted == "2960"
	replace str_industry_adpted = "2930" if inlist(str_industry_adpted,"2971","2972")
	replace str_industry_adpted = "3000" if inlist(str_industry_adpted,"3001","3002")
	replace str_industry_adpted = "3190" if inlist(str_industry_adpted,"3161","3162")
	replace str_industry_adpted = "3311" if str_industry_adpted == "3310"
	replace str_industry_adpted = "3312" if str_industry_adpted == "3320"
	replace str_industry_adpted = "3313" if str_industry_adpted == "3330"
	replace str_industry_adpted = "3591" if str_industry_adpted == "3541"
	replace str_industry_adpted = "3592" if inlist(str_industry_adpted,"3542","3543")
	replace str_industry_adpted = "3599" if str_industry_adpted == "3550"
	replace str_industry_adpted = "3610" if inlist(str_industry_adpted,"3611","3612","3613","3614","3615")
	replace str_industry_adpted = "3691" if inlist(str_industry_adpted,"3621","3622")
	replace str_industry_adpted = "3699" if inlist(str_industry_adpted,"3661","3662","3663")
	replace str_industry_adpted = "4010" if inlist(str_industry_adpted,"4011","4013")
	replace str_industry_adpted = "4020" if inlist(str_industry_adpted,"4021","4022")
	replace str_industry_adpted = "4510" if inlist(str_industry_adpted,"4511","4512")
	replace str_industry_adpted = "4520" if inlist(str_industry_adpted,"4521","4522","4523","4524")
	replace str_industry_adpted = "4520" if inlist(str_industry_adpted,"4521","4522","4523","4524","4525")
	replace str_industry_adpted = "4530" if inlist(str_industry_adpted,"4531","4532","4533","4534")
	replace str_industry_adpted = "4540" if inlist(str_industry_adpted,"4541","4542","4543","4544","4545")
	replace str_industry_adpted = "5110" if inlist(str_industry_adpted,"5111","5112","5113","5114","5115","5116","5117","5118")
	replace str_industry_adpted = "5121" if str_industry_adpted == "51211"
	replace str_industry_adpted = "5122" if str_industry_adpted == "51221"
	replace str_industry_adpted = "5123" if str_industry_adpted == "51231"
	replace str_industry_adpted = "5122" if inlist(str_industry_adpted,"5132","5133","5134","5135","5136","5137","5138","5139")
	replace str_industry_adpted = "5131" if str_industry_adpted == "5130"
	replace str_industry_adpted = "5139" if inlist(str_industry_adpted,"5144","5145","5146","5147")
	replace str_industry_adpted = "5143" if str_industry_adpted == "5153"
	replace str_industry_adpted = "5149" if inlist(str_industry_adpted,"5155","5156","5157")
	replace str_industry_adpted = "5159" if inlist(str_industry_adpted,"5182","5183","5187","5188")
	replace str_industry_adpted = "5190" if str_industry_adpted == "5190"
	replace str_industry_adpted = "5220" if inlist(str_industry_adpted,"5221","5222","5223","5224")
	replace str_industry_adpted = "5220" if inlist(str_industry_adpted,"5225","5226","5227")
	replace str_industry_adpted = "5231" if inlist(str_industry_adpted,"5232","5233")
	replace str_industry_adpted = "5232" if inlist(str_industry_adpted,"5241","5242","5243","5244")
	replace str_industry_adpted = "5233" if str_industry_adpted == "5245"
	replace str_industry_adpted = "5239" if inlist(str_industry_adpted,"5247","5248")
	replace str_industry_adpted = "5260" if inlist(str_industry_adpted,"5271","5272","5273","5274")
	replace str_industry_adpted = "5510" if inlist(str_industry_adpted,"5511","5521","5522","5523")
	replace str_industry_adpted = "5520" if inlist(str_industry_adpted,"5530","5540","5551","5552")
	replace str_industry_adpted = "6022" if str_industry_adpted == "6021"
	replace str_industry_adpted = "6023" if str_industry_adpted == "6022"
	replace str_industry_adpted = "6023" if str_industry_adpted == "6023"
	replace str_industry_adpted = "6220" if inlist(str_industry_adpted,"6221","6222")
	replace str_industry_adpted = "6230" if str_industry_adpted == "6223"
	replace str_industry_adpted = "6301" if str_industry_adpted == "6311"
	replace str_industry_adpted = "6302" if str_industry_adpted == "6312"
	replace str_industry_adpted = "6303" if inlist(str_industry_adpted,"6321","6322","6323")
	replace str_industry_adpted = "6304" if str_industry_adpted == "6330"
	replace str_industry_adpted = "6309" if str_industry_adpted == "6340"
	replace str_industry_adpted = "6519" if str_industry_adpted == "6512"
	replace str_industry_adpted = "6591" if str_industry_adpted == "6521"
	replace str_industry_adpted = "6592" if str_industry_adpted == "6522"
	replace str_industry_adpted = "6599" if str_industry_adpted == "6523"
	replace str_industry_adpted = "6719" if str_industry_adpted == "6713"
	replace str_industry_adpted = "7010" if inlist(str_industry_adpted,"7011","7012","7020")
	replace str_industry_adpted = "7020" if inlist(str_industry_adpted,"7031","7032")
	replace str_industry_adpted = "7110" if str_industry_adpted == "7111"
	replace str_industry_adpted = "7111" if inlist(str_industry_adpted,"7121","7122","7123")
	replace str_industry_adpted = "7129" if inlist(str_industry_adpted,"7131","7133","7134")
	replace str_industry_adpted = "7229" if str_industry_adpted == "7222"
	replace str_industry_adpted = "7290" if str_industry_adpted == "7260"
	replace str_industry_adpted = "7411" if str_industry_adpted == "7412"
	replace str_industry_adpted = "7413" if str_industry_adpted == "7413"
	replace str_industry_adpted = "7414" if inlist(str_industry_adpted,"7414","7415")
	replace str_industry_adpted = "7421" if str_industry_adpted == "7420"
	replace str_industry_adpted = "7422" if str_industry_adpted == "7430"
	replace str_industry_adpted = "7491" if str_industry_adpted == "7450"
	replace str_industry_adpted = "7492" if str_industry_adpted == "7460"
	replace str_industry_adpted = "7493" if str_industry_adpted == "7470"
	replace str_industry_adpted = "7494" if str_industry_adpted == "7481"
	replace str_industry_adpted = "7495" if str_industry_adpted == "7482"
	replace str_industry_adpted = "7499" if inlist(str_industry_adpted,"7485","7486","7487")
	replace str_industry_adpted = "7523" if inlist(str_industry_adpted,"7524","7525")
	replace str_industry_adpted = "8512" if str_industry_adpted == "8513"
	replace str_industry_adpted = "8519" if str_industry_adpted == "8514"
	replace str_industry_adpted = "9000" if inlist(str_industry_adpted,"9001","9002","9003")
	replace str_industry_adpted = "9190" if str_industry_adpted == "9130"
	replace str_industry_adpted = "9191" if str_industry_adpted == "9131"
	replace str_industry_adpted = "9192" if str_industry_adpted == "9132"
	replace str_industry_adpted = "9199" if str_industry_adpted == "9133"
	replace str_industry_adpted = "9211" if str_industry_adpted == "9212"
	replace str_industry_adpted = "9212" if str_industry_adpted == "9213"
	replace str_industry_adpted = "9213" if str_industry_adpted == "9220"
	replace str_industry_adpted = "9214" if inlist(str_industry_adpted,"9231","9232")
	replace str_industry_adpted = "9219" if inlist(str_industry_adpted,"9233","9234")
	replace str_industry_adpted = "9220" if str_industry_adpted == "9240"
	replace str_industry_adpted = "9231" if str_industry_adpted == "9251"
	replace str_industry_adpted = "9232" if str_industry_adpted == "9252"
	replace str_industry_adpted = "9233" if str_industry_adpted == "9253"
	replace str_industry_adpted = "9241" if str_industry_adpted == "9261"
	replace str_industry_adpted = "9249" if inlist(str_industry_adpted,"9262","9271","9272")
	replace str_industry_adpted = "9309" if inlist(str_industry_adpted,"9304","9305")

	replace str_industry_adpted = "7100" if str_industry_adpted == "7150"
	
	gen industrycat_isic = str_industry_adpted

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	/*
	preserve 
	drop if missing(industrycat_isic)
	int_classif_universe, var(industrycat_isic) universe(ISIC)
	count
	list
	assert `r(N)' == 0
	restore 
	*/
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen industrycat10 = floor(real(industrycat_isic)/ 100)
	recode industrycat10 (2/5 = 1) (10/14 = 2) (15/37 = 3) (40/41 = 4) (45 = 5) (50/55 = 6) (60/64 = 7) (65/74 = 8) (75 = 9) (80/99 = 10)
	* Add own consumption individuals 
	replace industrycat10 = 1 if a13_a == 1
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
*</_industrycat10_>


*<_industrycat4_>
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
	tostring prof_osn, gen(occup_orig)
	replace occup_orig = "" if lstatus != 1 | occup_orig == "."
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	gen occup_isco = occup_orig
	replace occup_isco = "" if occup_isco == "." | lstatus != 1
	replace occup_isco = "1210" if occup_isco == "1211"
	replace occup_isco = "1210" if occup_isco == "1212"
	replace occup_isco = "1210" if occup_isco == "1219"
	replace occup_isco = "1200" if occup_isco == "1242"
	replace occup_isco = "2120" if occup_isco == "2123"
	replace occup_isco = "2200" if occup_isco == "2240"
	replace occup_isco = "2410" if occup_isco == "2413"
	replace occup_isco = "2450" if occup_isco == "2459"
	replace occup_isco = "2400" if occup_isco == "2480"
	replace occup_isco = "3140" if occup_isco == "3146"
	replace occup_isco = "3140" if occup_isco == "3149"
	replace occup_isco = "3150" if occup_isco == "3159"
	replace occup_isco = "3470" if occup_isco == "3479"
	replace occup_isco = "5120" if occup_isco == "5129"
	replace occup_isco = "5140" if occup_isco == "5144"
	replace occup_isco = "5140" if occup_isco == "5146"
	replace occup_isco = "5140" if occup_isco == "5147"
	replace occup_isco = "5140" if occup_isco == "5148"
	replace occup_isco = "5100" if occup_isco == "5170"
	replace occup_isco = "5210" if occup_isco == "5219"
	replace occup_isco = "5000" if occup_isco == "5320"
	replace occup_isco = "5000" if occup_isco == "5330"
	replace occup_isco = "5000" if occup_isco == "5340"
	replace occup_isco = "5000" if occup_isco == "5510"
	replace occup_isco = "6110" if occup_isco == "6119"
	replace occup_isco = "7120" if occup_isco == "7125"
	replace occup_isco = "7100" if occup_isco == "7150"
	replace occup_isco = "7200" if occup_isco == "7280"
	replace occup_isco = "7330" if occup_isco == "7333"
	replace occup_isco = "7410" if occup_isco == "7419"
	replace occup_isco = "7440" if occup_isco == "7443"
	replace occup_isco = "7400" if occup_isco == "7450"
	replace occup_isco = "7000" if occup_isco == "7511"
	replace occup_isco = "7000" if occup_isco == "7513"
	replace occup_isco = "7000" if occup_isco == "7521"
	replace occup_isco = "7000" if occup_isco == "7522"
	replace occup_isco = "7000" if occup_isco == "7710"
	replace occup_isco = "8130" if occup_isco == "8133"
	replace occup_isco = "8220" if occup_isco == "8225"
	replace occup_isco = "8220" if occup_isco == "8228"
	replace occup_isco = "8310" if occup_isco == "8319"
	replace occup_isco = "8320" if occup_isco == "8329"
	replace occup_isco = "9000" if occup_isco == "9227"
	replace occup_isco = "9000" if occup_isco == "9350"
	replace occup_isco = "9000" if occup_isco == "9411"
	replace occup_isco = "9000" if occup_isco == "9412"
	replace occup_isco = "9000" if occup_isco == "9413"
	replace occup_isco = "9000" if occup_isco == "9414"
	replace occup_isco = "9000" if occup_isco == "9419"
	replace occup_isco = "9000" if occup_isco == "9999"

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	
	/*
	preserve 
	drop if missing(occup_isco)
	int_classif_universe, var(occup_isco) universe(ISCO)
	count
	list
	assert `r(N)' == 0
	restore
	*/

	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	gen byte occup = real(substr(occup_isco,1,1))
	* Add own consumption individuals 
	replace occup = 6 if a13_a == 1
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>


*<_occup_skill_>
	gen occup_skill = .
	replace occup_skill = 3 if inrange(occup, 1, 3)
	replace occup_skill = 2 if inrange(occup, 4, 8)
	replace occup_skill = 1 if occup == 9
	la de lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lblskill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_wage_no_compen_>
	gen double wage_no_compen = .
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>

/* <_unitwage_note>
	Unitwage refers to the unit used to record wage_no_compen, *not* the unit of
	general wage payent. For example, PHL LFS asks about wage periodicity, then
	asks for basic daily pay. The value of that pay would be wage_no_compen,
	while unitwage is code 1 ("Daily") for all, regardless of the periodicity.
</_unitwage_note> */

	gen byte unitwage = .
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours = vr_fakt if lstatus == 1
	replace whours = . if vr_fakt == 999
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	gen wmonths = .
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
/* <_wage_total_note>

	Use gross wages when available and net wages only when gross wages are not available.
	This is done to make it easy to compare earnings in formal and informal sectors.

</_wage_total_note> */
	gen wage_total = .
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen byte contract = dg_osn if empstat == 1
	recode contract (2 3 4 = 1) (6 = 0)
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte healthins = .
	label var healthins "Employment has health insurance primary job 7 day recall"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen byte socialsec = nfzan_f if lstatus == 1
	recode socialsec (2 = 1) (3 = 0) (4 = .)
	* Add own consumption individuals 
	replace socialsec = 0 if a13_a == 1
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec 1 "With social security" 0 "Without social secturity"
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen byte union = .
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	gen firmsize_l = kol_naim if lstatus == 1
	replace firmsize_l = . if kol_naim == 9999
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen firmsize_u = firmsize_l
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen byte empstat_2 = .
	replace empstat_2 = 1 if v_vtrb == 2
	replace empstat_2 = 2 if v_vtrb == 4 & missing(empstat_2)
	replace empstat_2 = 3 if inlist(naim_vt,2,3) & missing(empstat_2)
	replace empstat_2 = 4 if (naim_vt == 1) & missing(empstat_2)
	replace empstat_2 = 5 if (v_vtzan == 3) & missing(empstat_2)
	
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2 = .
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	tostring vd_vt, gen(industry_orig_2)
	replace industry_orig_2 = "" if empstat_2 == . | lstatus != 1 | industry_orig_2 == "."
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	gen industry_adapted_2 = floor(vd_vt/ 10)
	tostring industry_adapted_2,  gen(str_industry_adpted_2) format(%04.0f)
	replace str_industry_adpted_2 = "" if str_industry_adpted_2 == "." | lstatus != 1

	replace str_industry_adpted_2 = "0122" if inlist(str_industry_adpted_2,"0121","0123","0124","0125")
	replace str_industry_adpted_2 = "0140" if inlist(str_industry_adpted_2,"0141","0142")
	replace str_industry_adpted_2 = "0200" if inlist(str_industry_adpted_2,"0201","0202")

	replace str_industry_adpted_2 = "1410" if inlist(str_industry_adpted_2,"1411","1412","1413")
	replace str_industry_adpted_2 = "1410" if inlist(str_industry_adpted_2,"1421","1422")
	replace str_industry_adpted_2 = "1422" if str_industry_adpted_2 == "1424"
	replace str_industry_adpted_2 = "1429" if str_industry_adpted_2 == "1450"

	replace str_industry_adpted_2 = "1511" if inlist(str_industry_adpted_2,"1511","1512","1513")
	replace str_industry_adpted_2 = "1512" if inlist(str_industry_adpted_2,"1520","1521")
	replace str_industry_adpted_2 = "1513" if inlist(str_industry_adpted_2,"1531","1532","1533")
	replace str_industry_adpted_2 = "1514" if inlist(str_industry_adpted_2,"1541","1542","1543")
	replace str_industry_adpted_2 = "1520" if inlist(str_industry_adpted_2,"1551","1552")

	replace str_industry_adpted_2 = "1541" if inlist(str_industry_adpted_2,"1581","1582")
	replace str_industry_adpted_2 = "1542" if str_industry_adpted_2 == "1583"
	replace str_industry_adpted_2 = "1543" if str_industry_adpted_2 == "1584"
	replace str_industry_adpted_2 = "1544" if str_industry_adpted_2 == "1585"
	replace str_industry_adpted_2 = "1549" if inlist(str_industry_adpted_2,"1586","1587","1588","1589")
	replace str_industry_adpted_2 = "1551" if inlist(str_industry_adpted_2,"1591","1592")
	replace str_industry_adpted_2 = "1552" if inlist(str_industry_adpted_2,"1593","1594")
	replace str_industry_adpted_2 = "1553" if inlist(str_industry_adpted_2,"1595","1596","1597")
	replace str_industry_adpted_2 = "1554" if str_industry_adpted_2 == "1598"

	replace str_industry_adpted_2 = "1711" if inlist(str_industry_adpted_2,"1711","1712","1713","1714","1715","1716","1717")
	replace str_industry_adpted_2 = "1711" if inlist(str_industry_adpted_2,"1721","1722","1723","1724","1725","1730")
	replace str_industry_adpted_2 = "1721" if str_industry_adpted_2 == "1741"
	replace str_industry_adpted_2 = "1722" if str_industry_adpted_2 == "1740"
	replace str_industry_adpted_2 = "1722" if str_industry_adpted_2 == "1751"
	replace str_industry_adpted_2 = "1729" if inlist(str_industry_adpted_2,"1752","1753","1760","1771")
	replace str_industry_adpted_2 = "1730" if str_industry_adpted_2 == "1772"

	replace str_industry_adpted_2 = "1810" if inlist(str_industry_adpted_2,"1811","1812","1813","1814","1815","1816") | inlist(str_industry_adpted_2,"1817","1818","1821","1822","1823","1824")
	replace str_industry_adpted_2 = "1820" if str_industry_adpted_2 == "1830"

	replace str_industry_adpted_2 = "1911" if str_industry_adpted_2 == "1910"
	replace str_industry_adpted_2 = "1912" if str_industry_adpted_2 == "1920"

	replace str_industry_adpted_2 = "2010" if inlist(str_industry_adpted_2,"2011","2012")
	replace str_industry_adpted_2 = "2021" if str_industry_adpted_2 == "2020"
	replace str_industry_adpted_2 = "2022" if str_industry_adpted_2 == "2030"
	replace str_industry_adpted_2 = "2023" if str_industry_adpted_2 == "2040"
	replace str_industry_adpted_2 = "2029" if inlist(str_industry_adpted_2,"2050","2051","2052")

	replace str_industry_adpted_2 = "2101" if inlist(str_industry_adpted_2,"2111","2112")
	replace str_industry_adpted_2 = "2102" if str_industry_adpted_2 == "2121"
	replace str_industry_adpted_2 = "2109" if inlist(str_industry_adpted_2,"2122","2123","2124","2125")

	replace str_industry_adpted_2 = "2212" if inlist(str_industry_adpted_2,"2213")
	replace str_industry_adpted_2 = "2213" if inlist(str_industry_adpted_2,"2214")
	replace str_industry_adpted_2 = "2219" if inlist(str_industry_adpted_2,"2215")

	replace str_industry_adpted_2 = "2221" if inlist(str_industry_adpted_2,"2222")
	replace str_industry_adpted_2 = "2222" if inlist(str_industry_adpted_2,"2223","2224","2225")

	replace str_industry_adpted_2 = "2230" if inlist(str_industry_adpted_2,"2231","2232","2233")

	replace str_industry_adpted_2 = "2411" if inlist(str_industry_adpted_2,"2412","2413","2414")
	replace str_industry_adpted_2 = "2413" if inlist(str_industry_adpted_2,"2416","2417")

	replace str_industry_adpted_2 = "2421" if inlist(str_industry_adpted_2,"242","2420")
	replace str_industry_adpted_2 = "2422" if inlist(str_industry_adpted_2,"243","2430")
	replace str_industry_adpted_2 = "2423" if inlist(str_industry_adpted_2,"2441","2442")
	replace str_industry_adpted_2 = "2424" if inlist(str_industry_adpted_2,"2451","2452")
	replace str_industry_adpted_2 = "2429" if inlist(str_industry_adpted_2,"2461","2462","2463","2464")

	replace str_industry_adpted_2 = "2511" if inlist(str_industry_adpted_2,"2511","2512","2513")
	replace str_industry_adpted_2 = "2519" if str_industry_adpted_2 == "2513"
	replace str_industry_adpted_2 = "2520" if inlist(str_industry_adpted_2,"2521","2522","2523","2524")

	replace str_industry_adpted_2 = "2610" if inlist(str_industry_adpted_2,"2611","2612","2613","2614","2615")
	replace str_industry_adpted_2 = "2691" if inlist(str_industry_adpted_2,"2621","2622","2623","2624","2625","2626")
	replace str_industry_adpted_2 = "2693" if inlist(str_industry_adpted_2,"2630","2640")
	replace str_industry_adpted_2 = "2694" if str_industry_adpted_2 == "2650"
	replace str_industry_adpted_2 = "2695" if inlist(str_industry_adpted_2,"2661","2662","2663","2664","2665","2666")
	replace str_industry_adpted_2 = "2696" if str_industry_adpted_2 == "2670"
	replace str_industry_adpted_2 = "2699" if inlist(str_industry_adpted_2,"2681","2682")

	replace str_industry_adpted_2 = "2710" if inlist(str_industry_adpted_2,"2711","2712","2713","2714","2715","2716","2717") | inlist(str_industry_adpted_2,"2718","2719","2721","2722","2731","2732","2733","2734")
	replace str_industry_adpted_2 = "2720" if inlist(str_industry_adpted_2,"2741","2742","2743","2744","2745")
	replace str_industry_adpted_2 = "2731" if str_industry_adpted_2 == "2751"
	replace str_industry_adpted_2 = "2731" if str_industry_adpted_2 == "2752"
	replace str_industry_adpted_2 = "2732" if str_industry_adpted_2 == "2753"
	replace str_industry_adpted_2 = "2732" if str_industry_adpted_2 == "2754"

	replace str_industry_adpted_2 = "2811" if inlist(str_industry_adpted_2,"28111","28112")
	replace str_industry_adpted_2 = "2812" if inlist(str_industry_adpted_2,"28121","28122")
	replace str_industry_adpted_2 = "2813" if str_industry_adpted_2 == "2830"

	replace str_industry_adpted_2 = "2891" if str_industry_adpted_2 == "2840"
	replace str_industry_adpted_2 = "2892" if inlist(str_industry_adpted_2,"2851","2852")
	replace str_industry_adpted_2 = "2893" if inlist(str_industry_adpted_2,"2861","2862","2863")
	replace str_industry_adpted_2 = "2899" if inlist(str_industry_adpted_2,"2871","2872","2873","2874","2875")

	replace str_industry_adpted_2 = "2912" if str_industry_adpted_2 == "2913"
	replace str_industry_adpted_2 = "2913" if str_industry_adpted_2 == "2914"
	replace str_industry_adpted_2 = "2914" if str_industry_adpted_2 == "2921"
	replace str_industry_adpted_2 = "2915" if str_industry_adpted_2 == "2922"
	replace str_industry_adpted_2 = "2919" if inlist(str_industry_adpted_2,"2923","2924")
	replace str_industry_adpted_2 = "2921" if inlist(str_industry_adpted_2,"2931","2932")
	replace str_industry_adpted_2 = "2922" if inlist(str_industry_adpted_2,"2941","2942","2943")
	replace str_industry_adpted_2 = "2923" if str_industry_adpted_2 == "2951"
	replace str_industry_adpted_2 = "2924" if str_industry_adpted_2 == "2952"
	replace str_industry_adpted_2 = "2925" if str_industry_adpted_2 == "2953"
	replace str_industry_adpted_2 = "2926" if str_industry_adpted_2 == "2954"
	replace str_industry_adpted_2 = "2929" if inlist(str_industry_adpted_2,"2955","2956")
	replace str_industry_adpted_2 = "2927" if str_industry_adpted_2 == "2960"
	replace str_industry_adpted_2 = "2930" if inlist(str_industry_adpted_2,"2971","2972")
	replace str_industry_adpted_2 = "3000" if inlist(str_industry_adpted_2,"3001","3002")
	replace str_industry_adpted_2 = "3190" if inlist(str_industry_adpted_2,"3161","3162")

	replace str_industry_adpted_2 = "3311" if str_industry_adpted_2 == "3310"
	replace str_industry_adpted_2 = "3312" if str_industry_adpted_2 == "3320"
	replace str_industry_adpted_2 = "3313" if str_industry_adpted_2 == "3330"
	replace str_industry_adpted_2 = "3591" if str_industry_adpted_2 == "3541"
	replace str_industry_adpted_2 = "3592" if inlist(str_industry_adpted_2,"3542","3543")
	replace str_industry_adpted_2 = "3599" if str_industry_adpted_2 == "3550"

	replace str_industry_adpted_2 = "3610" if inlist(str_industry_adpted_2,"3611","3612","3613","3614","3615")
	replace str_industry_adpted_2 = "3691" if inlist(str_industry_adpted_2,"3621","3622")
	replace str_industry_adpted_2 = "3699" if inlist(str_industry_adpted_2,"3661","3662","3663")

	replace str_industry_adpted_2 = "4010" if inlist(str_industry_adpted_2,"4011","4013")
	replace str_industry_adpted_2 = "4020" if inlist(str_industry_adpted_2,"4021","4022")

	replace str_industry_adpted_2 = "4510" if inlist(str_industry_adpted_2,"4511","4512")
	replace str_industry_adpted_2 = "4520" if inlist(str_industry_adpted_2,"4521","4522","4523","4524")
	replace str_industry_adpted_2 = "4520" if inlist(str_industry_adpted_2,"4521","4522","4523","4524","4525")
	replace str_industry_adpted_2 = "4530" if inlist(str_industry_adpted_2,"4531","4532","4533","4534")
	replace str_industry_adpted_2 = "4540" if inlist(str_industry_adpted_2,"4541","4542","4543","4544","4545")

	replace str_industry_adpted_2 = "5110" if inlist(str_industry_adpted_2,"5111","5112","5113","5114","5115","5116","5117","5118")
	replace str_industry_adpted_2 = "5121" if str_industry_adpted_2 == "51211"
	replace str_industry_adpted_2 = "5122" if str_industry_adpted_2 == "51221"
	replace str_industry_adpted_2 = "5123" if str_industry_adpted_2 == "51231"
	replace str_industry_adpted_2 = "5122" if inlist(str_industry_adpted_2,"5132","5133","5134","5135","5136","5137","5138","5139")
	replace str_industry_adpted_2 = "5131" if str_industry_adpted_2 == "5130"
	replace str_industry_adpted_2 = "5139" if inlist(str_industry_adpted_2,"5144","5145","5146","5147")
	replace str_industry_adpted_2 = "5143" if str_industry_adpted_2 == "5153"
	replace str_industry_adpted_2 = "5149" if inlist(str_industry_adpted_2,"5155","5156","5157")
	replace str_industry_adpted_2 = "5159" if inlist(str_industry_adpted_2,"5182","5183","5187","5188")
	replace str_industry_adpted_2 = "5190" if str_industry_adpted_2 == "5190"

	replace str_industry_adpted_2 = "5220" if inlist(str_industry_adpted_2,"5221","5222","5223","5224")
	replace str_industry_adpted_2 = "5220" if inlist(str_industry_adpted_2,"5225","5226","5227")
	replace str_industry_adpted_2 = "5231" if inlist(str_industry_adpted_2,"5232","5233")
	replace str_industry_adpted_2 = "5232" if inlist(str_industry_adpted_2,"5241","5242","5243","5244")
	replace str_industry_adpted_2 = "5233" if str_industry_adpted_2 == "5245"
	replace str_industry_adpted_2 = "5239" if inlist(str_industry_adpted_2,"5247","5248")
	replace str_industry_adpted_2 = "5260" if inlist(str_industry_adpted_2,"5271","5272","5273","5274")

	replace str_industry_adpted_2 = "5510" if inlist(str_industry_adpted_2,"5511","5521","5522","5523")
	replace str_industry_adpted_2 = "5520" if inlist(str_industry_adpted_2,"5530","5540","5551","5552")

	replace str_industry_adpted_2 = "6022" if str_industry_adpted_2 == "6021"
	replace str_industry_adpted_2 = "6023" if str_industry_adpted_2 == "6022"
	replace str_industry_adpted_2 = "6023" if str_industry_adpted_2 == "6023"

	replace str_industry_adpted_2 = "6220" if inlist(str_industry_adpted_2,"6221","6222")
	replace str_industry_adpted_2 = "6230" if str_industry_adpted_2 == "6223"

	replace str_industry_adpted_2 = "6301" if str_industry_adpted_2 == "6311"
	replace str_industry_adpted_2 = "6302" if str_industry_adpted_2 == "6312"
	replace str_industry_adpted_2 = "6303" if inlist(str_industry_adpted_2,"6321","6322","6323")
	replace str_industry_adpted_2 = "6304" if str_industry_adpted_2 == "6330"
	replace str_industry_adpted_2 = "6309" if str_industry_adpted_2 == "6340"

	replace str_industry_adpted_2 = "6519" if str_industry_adpted_2 == "6512"
	replace str_industry_adpted_2 = "6591" if str_industry_adpted_2 == "6521"
	replace str_industry_adpted_2 = "6592" if str_industry_adpted_2 == "6522"
	replace str_industry_adpted_2 = "6599" if str_industry_adpted_2 == "6523"

	replace str_industry_adpted_2 = "6719" if str_industry_adpted_2 == "6713"

	replace str_industry_adpted_2 = "7010" if inlist(str_industry_adpted_2,"7011","7012","7020")
	replace str_industry_adpted_2 = "7020" if inlist(str_industry_adpted_2,"7031","7032")

	replace str_industry_adpted_2 = "7110" if str_industry_adpted_2 == "7111"
	replace str_industry_adpted_2 = "7111" if inlist(str_industry_adpted_2,"7121","7122","7123")
	replace str_industry_adpted_2 = "7129" if inlist(str_industry_adpted_2,"7131","7133","7134")

	replace str_industry_adpted_2 = "7229" if str_industry_adpted_2 == "7222"
	replace str_industry_adpted_2 = "7290" if str_industry_adpted_2 == "7260"

	replace str_industry_adpted_2 = "7411" if str_industry_adpted_2 == "7412"
	replace str_industry_adpted_2 = "7413" if str_industry_adpted_2 == "7413"
	replace str_industry_adpted_2 = "7414" if inlist(str_industry_adpted_2,"7414","7415")
	replace str_industry_adpted_2 = "7421" if str_industry_adpted_2 == "7420"
	replace str_industry_adpted_2 = "7422" if str_industry_adpted_2 == "7430"

	replace str_industry_adpted_2 = "7491" if str_industry_adpted_2 == "7450"
	replace str_industry_adpted_2 = "7492" if str_industry_adpted_2 == "7460"
	replace str_industry_adpted_2 = "7493" if str_industry_adpted_2 == "7470"
	replace str_industry_adpted_2 = "7494" if str_industry_adpted_2 == "7481"
	replace str_industry_adpted_2 = "7495" if str_industry_adpted_2 == "7482"
	replace str_industry_adpted_2 = "7499" if inlist(str_industry_adpted_2,"7485","7486","7487")

	replace str_industry_adpted_2 = "7523" if inlist(str_industry_adpted_2,"7524","7525")
	replace str_industry_adpted_2 = "8512" if str_industry_adpted_2 == "8513"
	replace str_industry_adpted_2 = "8519" if str_industry_adpted_2 == "8514"

	replace str_industry_adpted_2 = "9000" if inlist(str_industry_adpted_2,"9001","9002","9003")

	replace str_industry_adpted_2 = "9190" if str_industry_adpted_2 == "9130"
	replace str_industry_adpted_2 = "9191" if str_industry_adpted_2 == "9131"
	replace str_industry_adpted_2 = "9192" if str_industry_adpted_2 == "9132"
	replace str_industry_adpted_2 = "9199" if str_industry_adpted_2 == "9133"

	replace str_industry_adpted_2 = "9211" if str_industry_adpted_2 == "9212"
	replace str_industry_adpted_2 = "9212" if str_industry_adpted_2 == "9213"
	replace str_industry_adpted_2 = "9213" if str_industry_adpted_2 == "9220"
	replace str_industry_adpted_2 = "9214" if inlist(str_industry_adpted_2,"9231","9232")
	replace str_industry_adpted_2 = "9219" if inlist(str_industry_adpted_2,"9233","9234")

	replace str_industry_adpted_2 = "9220" if str_industry_adpted_2 == "9240"
	replace str_industry_adpted_2 = "9231" if str_industry_adpted_2 == "9251"
	replace str_industry_adpted_2 = "9232" if str_industry_adpted_2 == "9252"
	replace str_industry_adpted_2 = "9233" if str_industry_adpted_2 == "9253"
	replace str_industry_adpted_2 = "9241" if str_industry_adpted_2 == "9261"
	replace str_industry_adpted_2 = "9249" if inlist(str_industry_adpted_2,"9262","9271","9272")

	replace str_industry_adpted_2 = "9309" if inlist(str_industry_adpted_2,"9304","9305")

	replace str_industry_adpted_2 = "7100" if str_industry_adpted_2 == "7150"
	
	gen industrycat_isic_2 = str_industry_adpted_2
	
	/*
	preserve 
	drop if missing(industrycat_isic_2)
	int_classif_universe, var(industrycat_isic_2) universe(ISIC)
	count
	list
	assert `r(N)' == 0
	restore 
	*/
	
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen byte industrycat10_2 = floor(real(industrycat_isic_2)/ 100)
	recode industrycat10_2 (2/5 = 1) (10/14 = 2) (15/37 = 3) (40/41 = 4) (45 = 5) (50/55 = 6) (60/64 = 7) (65/74 = 8) (75 = 9) (80/99 = 10)
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
	tostring prof_vt, gen(occup_orig_2)
	replace occup_orig_2 = "" if occup_orig_2 == "."
	replace occup_orig_2 = "" if empstat_2 == . & prof_vt != .
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen occup_isco_2 = occup_orig_2
	replace occup_isco_2 = "" if occup_isco_2 == "." | lstatus != 1
	replace occup_isco_2 = "1210" if occup_isco_2 == "1211"
	replace occup_isco_2 = "1210" if occup_isco_2 == "1212"
	replace occup_isco_2 = "1210" if occup_isco_2 == "1213"
	replace occup_isco_2 = "1210" if occup_isco_2 == "1219"
	replace occup_isco_2 = "1200" if occup_isco_2 == "1242"
	replace occup_isco_2 = "2120" if occup_isco_2 == "2123"
	replace occup_isco_2 = "2200" if occup_isco_2 == "2240"
	replace occup_isco_2 = "2410" if occup_isco_2 == "2413"
	replace occup_isco_2 = "2450" if occup_isco_2 == "2459"
	replace occup_isco_2 = "2400" if occup_isco_2 == "2480"
	replace occup_isco_2 = "3140" if occup_isco_2 == "3146"
	replace occup_isco_2 = "3140" if occup_isco_2 == "3149"
	replace occup_isco_2 = "3150" if occup_isco_2 == "3159"
	replace occup_isco_2 = "3470" if occup_isco_2 == "3479"
	replace occup_isco_2 = "5120" if occup_isco_2 == "5129"
	replace occup_isco_2 = "5140" if occup_isco_2 == "5144"
	replace occup_isco_2 = "5140" if occup_isco_2 == "5146"
	replace occup_isco_2 = "5140" if occup_isco_2 == "5147"
	replace occup_isco_2 = "5140" if occup_isco_2 == "5148"
	replace occup_isco_2 = "5100" if occup_isco_2 == "5170"
	replace occup_isco_2 = "5210" if occup_isco_2 == "5219"
	replace occup_isco_2 = "5000" if occup_isco_2 == "5320"
	replace occup_isco_2 = "5000" if occup_isco_2 == "5330"
	replace occup_isco_2 = "5000" if occup_isco_2 == "5340"
	replace occup_isco_2 = "5000" if occup_isco_2 == "5510"
	replace occup_isco_2 = "6110" if occup_isco_2 == "6119"
	replace occup_isco_2 = "7120" if occup_isco_2 == "7125"
	replace occup_isco_2 = "7100" if occup_isco_2 == "7150"
	replace occup_isco_2 = "7200" if occup_isco_2 == "7280"
	replace occup_isco_2 = "7330" if occup_isco_2 == "7333"
	replace occup_isco_2 = "7410" if occup_isco_2 == "7419"
	replace occup_isco_2 = "7440" if occup_isco_2 == "7443"
	replace occup_isco_2 = "7400" if occup_isco_2 == "7450"
	replace occup_isco_2 = "7000" if occup_isco_2 == "7511"
	replace occup_isco_2 = "7000" if occup_isco_2 == "7513"
	replace occup_isco_2 = "7000" if occup_isco_2 == "7521"
	replace occup_isco_2 = "7000" if occup_isco_2 == "7522"
	replace occup_isco_2 = "7000" if occup_isco_2 == "7710"
	replace occup_isco_2 = "8130" if occup_isco_2 == "8133"
	replace occup_isco_2 = "8220" if occup_isco_2 == "8225"
	replace occup_isco_2 = "8220" if occup_isco_2 == "8228"
	replace occup_isco_2 = "8310" if occup_isco_2 == "8319"
	replace occup_isco_2 = "8320" if occup_isco_2 == "8329"
	replace occup_isco_2 = "9000" if occup_isco_2 == "9227"
	replace occup_isco_2 = "9000" if occup_isco_2 == "9350"
	replace occup_isco_2 = "9000" if occup_isco_2 == "9411"
	replace occup_isco_2 = "9000" if occup_isco_2 == "9412"
	replace occup_isco_2 = "9000" if occup_isco_2 == "9413"
	replace occup_isco_2 = "9000" if occup_isco_2 == "9414"
	replace occup_isco_2 = "9000" if occup_isco_2 == "9419"
	replace occup_isco_2 = "9000" if occup_isco_2 == "9999"
	
	/*
	preserve 
	drop if missing(occup_isco_2)
	int_classif_universe, var(occup_isco_2) universe(ISCO)
	count
	list
	assert `r(N)' == 0
	restore
	*/
	
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_2_>
	gen byte occup_2 = .
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
	gen double wage_no_compen_2 = .
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2 = .
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
	gen whours_2 = vr_vt if empstat_2 != .
	label var whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>


*<_wmonths_2_>
	gen wmonths_2 = .
	label var wmonths_2 "Months of work in past 12 months secondary job 7 day recall"
*</_wmonths_2_>


*<_wage_total_2_>
	gen wage_total_2 = .
	label var wage_total_2 "Annualized total wage secondary job 7 day recall"
*</_wage_total_2_>


*<_firmsize_l_2_>
	gen firmsize_l_2 = .
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	gen firmsize_u_2 = .
	label var firmsize_u_2 "Firm size (upper bracket) secondary job 7 day recall"
*</_firmsize_u_2_>

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
	egen t_hours_total = rowtotal(whours whours_2)
	replace t_hours_total = . if lstatus != 1
	label var t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
	gen t_wage_nocompen_total = .
	label var t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
	gen t_wage_total = .
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
	gen byte empstat_year = .
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
	gen industry_orig_year = .
	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	gen industrycat_isic_year = .

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	preserve 
	*drop if missing(industrycat_isic_year)
	*int_classif_universe, var(industrycat_isic_year) universe(ISIC)
	count
	*list
	*assert `r(N)' == 0
	restore 

	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>

*<_industrycat10_year_>
	gen byte industrycat10_year = .
	label var industrycat10_year "1 digit industry classification, primary job 12 month recall"
	la de lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_year lblindustrycat10_year
*</_industrycat10_year_>


*<_industrycat4_year_>
	gen byte industrycat4_year = industrycat10_year
	recode industrycat4_year (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label var industrycat4_year "Broad Economic Activities classification, primary job 12 month recall"
	la de lblindustrycat4_year 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4_year lblindustrycat4_year
*</_industrycat4_year_>


*<_occup_orig_year_>
	gen occup_orig_year = .
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	gen occup_isco_year = ""

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	preserve 
	*drop if missing(occup_isco_year)
	*int_classif_universe, var(occup_isco_year) universe(ISCO)
	count
	*list
	*assert `r(N)' == 0
	restore

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


*<_wage_no_compen_year_> --- this var has the same name as other and when quoted in the keep and order codes is repeated.
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
	replace njobs = 1 if empstat != . & empstat_2 == .
	replace njobs = 2 if empstat != . & empstat_2 != .
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

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu ssu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu ssu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

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
