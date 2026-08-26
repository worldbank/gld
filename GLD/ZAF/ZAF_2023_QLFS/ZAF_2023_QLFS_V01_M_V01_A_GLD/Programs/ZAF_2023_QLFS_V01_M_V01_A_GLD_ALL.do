
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				ZAF_2023_QLFS_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata 18 <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2026-07-21 </_Date created_>

-------------------------------------------------------------------------

<_Country_>					    South Africa (ZAF) </_Country_>
<_Survey Title_>				Quarterly Labour Force Survey </_Survey Title_>
<_Survey Year_>					2023 </_Survey Year_>
<_Study ID_>					[Microdata Library ID if present] </_Study ID_>
<_Data collection from_>		[MM/YYYY] </_Data collection from_>
<_Data collection to_>			[MM/YYYY] </_Data collection to_>
<_Source of dataset_> 			[Source of data, e.g. NSO] </_Source of dataset_>
<_Sample size (HH)_> 			81,661 </_Sample size (HH)_>
<_Sample size (IND)_> 			264,495 </_Sample size (IND)_>
<_Sampling method_> 			[Brief description] </_Sampling method_>
<_Geographic coverage_> 		[To what level is data significant] </_Geographic coverage_>
<_Currency_> 					[Currency used for wages] </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS-19 </_ICLS Version_>
<_ISCED Version_>				Not assigned </_ISCED Version_>
<_ISCO Version_>				ISCO-88 </_ISCO Version_>
<_OCCUP National_>				SASCO-2003 </_OCCUP National_>
<_ISIC Version_>				ISIC Rev 3 </_ISIC Version_>
<_INDUS National_>				SIC 5 </_INDUS National_>


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

* Define path sections
local server  "C:/Users/wb529026/WBG/GLD - Focal Point/Countries"
local country "ZAF"
local year    "2023"
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

* All steps necessary to merge datasets (if several) to have all elements needed to produce
* harmonized output in a single file

use "`path_in_stata'/lmdsa-2023-v1.1.dta", clear

/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
gen str4 countrycode = "ZAF"
label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
gen survname = "QLFS"
label var survname "Survey acronym"
*</_survname_>


*<_survey_>
gen survey = "QLFS"
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
gen isco_version = "isco_1988"
label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
gen isic_version = "isic_3"
label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
gen int year = 2023
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
gen int int_year = 2023
label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen  int_month = .
	label value int_month lblint_month
label var int_month "Month of the interview"
label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
*</_int_month_>


*<_hhid_>
gen str18 hhid = lmd2023_uqno
label var hhid "Household ID"
*</_hhid_>


*<_pid_>
* Repeated pid values preserve the rotating panel; pid plus wave is the unique person-quarter key.
gen str21 pid = lmd2023_uqno + "_" + string(lmd2023_personno,"%02.0f")
label var pid "Individual ID"
*</_pid_>


*<_weight_>
gen double weight = lmd2023_weight
label var weight "Survey sampling weight"
*</_weight_>


*<_weight_m_>
	gen weight_m = .
label var weight_m "Survey sampling weight to obtain national estimates for each month"
*</_weight_m_>


*<_weight_q_>
gen double weight_q = lmd2023_weight_qtr
label var weight_q "Survey sampling weight to obtain national estimates for each quarter"
*</_weight_q_>


*<_psu_>
gen double psu = lmd2023_psuno_seg
label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = .
label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
gen double strata = lmd2023_stratum
label var strata "Strata"
*</_strata_>


*<_wave_>
gen byte wave = lmd2023_qtr
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
gen byte urban = .
replace urban = 1 if lmd2023_geo_type == 1
replace urban = 0 if !missing(lmd2023_geo_type) & lmd2023_geo_type != 1
label var urban "Location is urban"
la de lblurban 1 "Urban" 0 "Rural"
label values urban lblurban
*</_urban_>


*<_subnatid1_>
decode lmd2023_province, gen(_province_name)
gen str30 subnatid1 = string(lmd2023_province) + " - " + _province_name
drop _province_name
label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
decode lmd2023_metro_code, gen(_metro_name)
gen str40 subnatid2 = string(lmd2023_metro_code) + " - " + _metro_name
drop _metro_name
label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	gen str subnatid3 = ""
label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
gen str40 subnatidsurvey = subnatid2
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
bysort lmd2023_uqno lmd2023_qtr: egen hsize = count(lmd2023_personno)
label var hsize "Household size"
*</_hsize_>


*<_age_>
gen byte age = lmd2023_q14age
label var age "Individual age"
*</_age_>


*<_male_>
gen byte male = .
replace male = 1 if lmd2023_q13gender == 1
replace male = 0 if lmd2023_q13gender == 2
label var male "Sex - Ind is male"
la de lblmale 1 "Male" 0 "Female"
label values male lblmale
*</_male_>


*<_relationharm_>

/*<_relationharm_note_>

Relationship was not asked. Personal number 1 is the head. If absent, assign the eldest adult male, or eldest adult female when no adult male is present. Drop households without one unique adult head. Majority age is 18. Propagate status across quarters.

</_relationharm_note_>*/

	gen byte relationharm=1 if lmd2023_personno==1
	bys hhid: egen _rh0=sum(relationharm==1)
	bys hhid: egen _rha=max(lmd2023_q14age)
	replace _rha=. if _rha<18
	replace relationharm=1 if _rh0==0 & lmd2023_q14age==_rha
	bys hhid: egen _rh1=sum(relationharm==1)
	drop _rh0
	
	preserve
		collapse (max) relationharm, by(pid hhid _rh1)
		bys hhid: egen _rh2=sum(relationharm)
		drop _rh1
		tempfile rh
		save `rh'
	restore
	
	merge m:1 pid hhid using `rh', nogen
	replace relationharm=. if _rh2==2 & lmd2023_q13gender==2 & relationharm==1
	bys hhid: egen _rh3=sum(relationharm==1)
	
	preserve
		collapse (max) relationharm, by(pid hhid _rh3)
		bys hhid: egen _rh4=sum(relationharm)
		save `rh', replace
	restore
	
	merge m:1 pid hhid using `rh', nogen
	bys hhid: egen _rhf=max(lmd2023_q13gender==2)
	replace relationharm=1 if _rh4==0 & _rha<. & lmd2023_q14age==_rha & _rhf
	
	preserve
		collapse (max) relationharm, by(pid hhid _rh4)
		bys hhid: egen _rh5=sum(relationharm)
		save `rh', replace
	restore
	
	merge m:1 hhid pid using `rh', nogen
	drop if _rh5!=1
	bys pid: egen _rhmax=max(!missing(relationharm))
	bys pid: egen _rhmin=min(!missing(relationharm))
	replace relationharm=1 if _rhmax==1 & _rhmin==0
	drop _rh*
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = .
label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
gen byte marital = .
replace marital = 1 if lmd2023_q16maritalstatus == 1
replace marital = 2 if lmd2023_q16maritalstatus == 5
replace marital = 3 if lmd2023_q16maritalstatus == 2
replace marital = 4 if lmd2023_q16maritalstatus == 4
replace marital = 5 if lmd2023_q16maritalstatus == 3
label var marital "Marital status"
la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	gen eye_dsablty = .
label var eye_dsablty "Disability related to eyesight"
label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
label values eye_dsablty dsablty
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty = .
label var hear_dsablty "Disability related to hearing"
label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
label values hear_dsablty dsablty
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty = .
label var walk_dsablty "Disability related to walking or climbing stairs"
label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
label values walk_dsablty dsablty
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord = .
label var conc_dsord "Disability related to concentration or remembering"
label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
label values conc_dsord dsablty
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty  = .
label var slfcre_dsablty "Disability related to selfcare"
label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
label values slfcre_dsablty dsablty
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty = .
label var comm_dsablty "Disability related to communicating"
label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
label values comm_dsablty dsablty
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
label var migrated_binary "Individual has migrated"
label de lblmigrated_binary 0 "No" 1 "Yes"
label values migrated_binary lblmigrated_binary
*</_migrated_binary_>


*<_migrated_years_>
	gen migrated_years = .
	replace migrated_years = . if migrated_binary != 1
label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban = .
	replace migrated_from_urban = . if migrated_binary != 1
label var migrated_from_urban "Migrated from area"
label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
label values migrated_from_urban lblmigrated_from_urban
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen migrated_from_cat = .
	replace migrated_from_cat = . if migrated_binary != 1
label var migrated_from_cat "Category of migration area"
label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country" 6 "Within country, admin unknown" 7 "Wholly unknown"
label values migrated_from_cat lblmigrated_from_cat
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen migrated_from_code = ""
	replace migrated_from_code = "" if migrated_binary != 1
label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country = ""
	replace migrated_from_country = "" if migrated_binary != 1
label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason = .
	replace migrated_reason = . if migrated_binary != 1
label var migrated_reason "Reason for migrating"
label de lblmigrated_reason 1 "Family reasons" 2 "Educational reasons" 3 "Employment" 4 "Forced (political reasons, natural disaster, …)" 5 "Other reasons"
label values migrated_reason lblmigrated_reason
*</_migrated_reason_>


}


/*%%=============================================================================================
	6: Education
==============================================================================================%%*/


{

*<_ed_mod_age_>
gen byte ed_mod_age = 0
label var ed_mod_age "Education module application age"
*</_ed_mod_age_>

*<_school_>
gen byte school = .
replace school = 1 if lmd2023_q19atte == 1
replace school = 0 if lmd2023_q19atte == 2
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
gen byte educy = .
replace educy = 0 if inlist(lmd2023_q17education,0,98)
replace educy = lmd2023_q17education if inrange(lmd2023_q17education,1,12)
replace educy = . if educy > age & !missing(age)
label var educy "Years of education"
*</_educy_>


*<_educat7_>
gen byte educat7 = .
replace educat7 = 1 if inlist(lmd2023_q17education,0,98)
replace educat7 = 2 if inrange(lmd2023_q17education,1,6)
replace educat7 = 3 if lmd2023_q17education == 7
replace educat7 = 4 if inlist(lmd2023_q17education,8,9,10,11,14,15)
replace educat7 = 5 if inlist(lmd2023_q17education,12,13,16)
replace educat7 = 6 if inlist(lmd2023_q17education,17,18,21,22,23)
replace educat7 = 7 if inrange(lmd2023_q17education,24,28)
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
gen int educat_orig = lmd2023_q17education
replace educat_orig = . if inlist(lmd2023_q17education,19,20,29,30,31)
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
label var vocational "Ever received vocational training"
label de lblvocational 0 "No" 1 "Yes"
*</_vocational_>


*<_vocational_type_>
	gen vocational_type = .
label var vocational_type "Type of vocational training"
label de lblvocational_type 1 "Inside Enterprise" 2 "External"
label values vocational_type lblvocational_type
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
label var vocational_financed "How training was financed"
label de lblvocational_financed 1 "Employer" 2 "Government" 3 "Mixed Employer/Government" 4 "Own funds" 5 "Other"
*</_vocational_financed_>

}


/*%%=============================================================================================
	8: Labour
==============================================================================================%%*/


*<_minlaborage_>
gen byte minlaborage = 15
label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
gen byte lstatus = .
replace lstatus = 1 if lmd2023_status == 1 & age >= 15
replace lstatus = 2 if lmd2023_status == 2 & age >= 15
replace lstatus = 3 if inlist(lmd2023_status,3,4) & age >= 15
label var lstatus "Labor status"
la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
gen byte potential_lf = .
replace potential_lf = 1 if lmd2023_status == 3 & age >= 15
replace potential_lf = 0 if lmd2023_status == 4 & age >= 15
label var potential_lf "Potential labour force status"
la de lblpotential_lf 0 "No" 1 "Yes"
label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
gen byte underemployment = .
replace underemployment = 1 if lmd2023_underempl == 1
replace underemployment = 0 if lmd2023_underempl == 2
replace underemployment = . if lstatus != 1
label var underemployment "Underemployment status"
la de lblunderemployment 0 "No" 1 "Yes"
label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
gen byte nlfreason = .
replace nlfreason = 1 if lmd2023_q35ynotwrk == 1
replace nlfreason = 2 if lmd2023_q35ynotwrk == 2
replace nlfreason = 3 if lmd2023_q35ynotwrk == 4
replace nlfreason = 4 if lmd2023_q35ynotwrk == 8
replace nlfreason = 5 if inlist(lmd2023_q35ynotwrk,3,5,6,7,9)
replace nlfreason = 1 if missing(lmd2023_q35ynotwrk) & lmd2023_q38rsnnotseek == 13
replace nlfreason = 2 if missing(lmd2023_q35ynotwrk) & lmd2023_q38rsnnotseek == 6
replace nlfreason = 3 if missing(lmd2023_q35ynotwrk) & lmd2023_q38rsnnotseek == 14
replace nlfreason = 4 if missing(lmd2023_q35ynotwrk) & lmd2023_q38rsnnotseek == 5
replace nlfreason = 5 if missing(lmd2023_q35ynotwrk) & inlist(lmd2023_q38rsnnotseek,1,2,3,4,7,8,9,10)
replace nlfreason = 5 if missing(lmd2023_q35ynotwrk) & inlist(lmd2023_q38rsnnotseek,11,12,15,16)
replace nlfreason = . if lstatus != 3
label var nlfreason "Reason not in the labor force"
la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
gen byte unempldur_l = .
recode lmd2023_q36timeseek (1=0) (2=3) (3=6) (4=9) (5=12) (6=36) (7=60) (8=.), gen(_udl)
replace unempldur_l = _udl if lstatus == 2
drop _udl
label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
gen byte unempldur_u = .
recode lmd2023_q36timeseek (1=3) (2=6) (3=9) (4=12) (5=36) (6=60) (7=.) (8=.), gen(_udu)
replace unempldur_u = _udu if lstatus == 2
drop _udu
label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
gen byte empstat = .
replace empstat = 1 if lmd2023_q45wrk4whom == 1
replace empstat = 2 if lmd2023_q45wrk4whom == 4
replace empstat = 3 if lmd2023_q45wrk4whom == 2
replace empstat = 4 if lmd2023_q45wrk4whom == 3
replace empstat = . if lstatus != 1
label var empstat "Employment status during past week primary job 7 day recall"
la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
gen byte ocusec = .
replace ocusec = 1 if lmd2023_q415typebusns == 1
replace ocusec = 3 if lmd2023_q415typebusns == 2
replace ocusec = 2 if inlist(lmd2023_q415typebusns,3,4,5)
replace ocusec = . if lstatus != 1
label var ocusec "Sector of activity primary job 7 day recall"
la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
gen int industry_orig = lmd2023_q43industry
replace industry_orig = . if inlist(lmd2023_q43industry,988,999)
replace industry_orig = . if lstatus != 1
label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	* Reuse the reviewer-approved 2022 SIC-style to ISIC Rev. 3 crosswalk.
	tostring lmd2023_q43industry, gen(_indus_string) format(%03.0f)
	gen _industrycat_isic_num = real(substr(_indus_string, 1, 2))
	recode _industrycat_isic_num (01=95) (03=99) (11=01) (12=02) (13=05) (21=10) (22=11) (23=12) (24=13) (25=14) (29=.) (30=15) (31=17) (32=20) (33=23) (34=26) (35=27) (36=31) (37=32) (38=34) (39=36) (41=40) (42=41) (50=45) (61=51) (62=52) (63=50) (64=55) (71=60) (72=61) (73=62) (74=63) (75=64) (81=65) (82=66) (83=67) (84=70) (85=71) (86=72) (87=73) (88=74) (91=75) (92=80) (93=85) (94=90) (95=91) (96=92) (99=93)
	replace _industrycat_isic_num = 16 if lmd2023_q43industry == 306
	replace _industrycat_isic_num = 18 if lmd2023_q43industry == 314
	replace _industrycat_isic_num = 19 if inrange(lmd2023_q43industry, 316, 317)
	replace _industrycat_isic_num = 21 if lmd2023_q43industry == 323
	replace _industrycat_isic_num = 22 if inrange(lmd2023_q43industry, 324, 325)
	replace _industrycat_isic_num = 24 if inrange(lmd2023_q43industry, 334, 335)
	replace _industrycat_isic_num = 25 if inrange(lmd2023_q43industry, 337, 338)
	replace _industrycat_isic_num = 28 if inrange(lmd2023_q43industry, 354, 355)
	replace _industrycat_isic_num = 29 if inrange(lmd2023_q43industry, 356, 358)
	replace _industrycat_isic_num = 30 if lmd2023_q43industry == 359
	replace _industrycat_isic_num = 33 if inrange(lmd2023_q43industry, 374, 375)
	replace _industrycat_isic_num = 35 if inrange(lmd2023_q43industry, 384, 387)
	replace _industrycat_isic_num = 37 if lmd2023_q43industry == 395
	replace _industrycat_isic_num = _industrycat_isic_num * 100
	tostring _industrycat_isic_num, gen(industrycat_isic) format(%04.0f)
	drop _industrycat_isic_num _indus_string
	replace industrycat_isic = "" if industrycat_isic == "." | lstatus != 1
	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	preserve 
	*drop if missing(industrycat_isic)
	*int_classif_universe, var(industrycat_isic) universe(ISIC)
	count
	*list
	*assert `r(N)' == 0
	restore 

label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen byte industrycat10 = .
	gen byte _isic_div = real(substr(industrycat_isic, 1, 2))
	replace industrycat10 = 1 if inrange(_isic_div, 1, 5)
	replace industrycat10 = 2 if inrange(_isic_div, 10, 14)
	replace industrycat10 = 3 if inrange(_isic_div, 15, 37)
	replace industrycat10 = 4 if inrange(_isic_div, 40, 41)
	replace industrycat10 = 5 if _isic_div == 45
	replace industrycat10 = 6 if inrange(_isic_div, 50, 55)
	replace industrycat10 = 7 if inrange(_isic_div, 60, 64)
	replace industrycat10 = 8 if inrange(_isic_div, 65, 74)
	replace industrycat10 = 9 if _isic_div == 75
	replace industrycat10 = 10 if inrange(_isic_div, 80, 99)
	drop _isic_div
	replace industrycat10 = . if lstatus != 1
label var industrycat10 "1 digit industry classification, primary job 7 day recall"
la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
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
gen int occup_orig = lmd2023_q42occupation
replace occup_orig = . if inlist(lmd2023_q42occupation,9888,9999)
replace occup_orig = . if lstatus != 1
label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
tostring lmd2023_q42occupation, gen(_occup_string) format(%04.0f)
gen str3 occupcat_isco = substr(_occup_string,1,3)
merge m:1 occupcat_isco using "`path_in_stata'/isco88_sasco03_mapping.dta"
drop if _merge == 2
destring isco_88, replace
gen _occup_isco_num = isco_88 * 10
replace _occup_isco_num = . if inlist(lmd2023_q42occupation,9888,9999)
tostring _occup_isco_num, gen(occup_isco) format(%04.0f)
replace occup_isco = "" if occup_isco == "." | lstatus != 1
drop _merge _occup_string occupcat_isco sasco_occup isco_88 isco_occup _occup_isco_num
label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
gen byte occup = real(substr(occup_isco,1,1))
replace occup = 10 if occup == 0
replace occup = . if occup_isco == "" | lstatus != 1
label var occup "1 digit occupational classification, primary job 7 day recall"
la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
label values occup lbloccup
*</_occup_>


*<_occup_skill_>
	gen occup_skill = .
	replace occup_skill = 3 if inrange(occup, 1, 3)
	replace occup_skill = 2 if inrange(occup, 4, 8)
	replace occup_skill = 1 if occup == 9
label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
la de lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill"
label values occup_skill lblskill
*</_occup_skill_>


*<_wage_no_compen_>
gen double wage_no_compen = lmd2023_monthly_amount if lstatus == 1
label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
gen byte unitwage = 5 if !missing(wage_no_compen)
label var unitwage "Last wages' time unit primary job 7 day recall"
la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
gen double whours = lmd2023_hrswrk if lstatus == 1
label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	gen wmonths = .
	replace wmonths = . if lstatus != 1
label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
gen double wage_total = lmd2023_monthly_amount * 12 if lstatus == 1
label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
gen byte contract = .
replace contract = 1 if lmd2023_q411contracttype == 1
replace contract = 0 if lmd2023_q411contracttype == 2
replace contract = . if lstatus != 1
label var contract "Employment has contract primary job 7 day recall"
la de lblcontract 0 "Without contract" 1 "With contract"
label values contract lblcontract
*</_contract_>


*<_healthins_>
gen byte healthins = .
replace healthins = 1 if lmd2023_q49medical == 1
replace healthins = 0 if lmd2023_q49medical == 2
replace healthins = . if lstatus != 1
label var healthins "Employment has health insurance primary job 7 day recall"
la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen byte socialsec = .
label var socialsec "Employment has social security insurance primary job 7 day recall"
la de lblsocialsec 1 "With social security" 0 "Without social security"
label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
gen byte union = .
replace union = 1 if lmd2023_q412bmemunion == 1
replace union = 0 if lmd2023_q412bmemunion == 2
replace union = . if lstatus != 1
label var union "Union membership at primary job 7 day recall"
la de lblunion 0 "Not union member" 1 "Union member"
label values union lblunion
*</_union_>


*<_firmsize_l_>
recode lmd2023_q416nrworkers (1=0) (2=1) (3=2) (4=5) (5=10) (6=20) (7=50) (8=.), gen(firmsize_l)
replace firmsize_l = . if lstatus != 1
label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
recode lmd2023_q416nrworkers (1=0) (2=1) (3=4) (4=9) (5=19) (6=49) (7=.) (8=.), gen(firmsize_u)
replace firmsize_u = . if lstatus != 1
label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen byte empstat_2 = .
label var empstat_2 "Employment status during past week secondary job 7 day recall"
label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2 = .
label var ocusec_2 "Sector of activity secondary job 7 day recall"
label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2 = .
label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	gen industrycat_isic_2 = .
label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen byte industrycat10_2 = .
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
	gen occup_orig_2 = .
label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen occup_isco_2 = ""
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
label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
la de lblskill2 1 "Low skill" 2 "Medium skill" 3 "High skill"
label values occup_skill_2 lblskill2
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
	gen whours_2 = .
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
	gen t_hours_total = .
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
	replace underemployment_year = . if lstatus_year != 1
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
la de lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
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
label var occup_skill_year "Skill based on ISCO standard primary job 12 month recall"
la de lblskillyear 1 "Low skill" 2 "Medium skill" 3 "High skill"
label values occup_skill_year lblskillyear
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
la de lblsocialsec_year 1 "With social security" 0 "Without social security"
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
label var occup_skill_2_year "Skill based on ISCO standard secondary job 12 month recall"
la de lblskilly2 1 "Low skill" 2 "Medium skill" 3 "High skill"
label values occup_skill_2_year lblskilly2
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
label var t_hours_total_year "Annualized hours worked in all jobs 12 month recall"
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
	local lab_vars "minlaborage lstatus nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome"

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
