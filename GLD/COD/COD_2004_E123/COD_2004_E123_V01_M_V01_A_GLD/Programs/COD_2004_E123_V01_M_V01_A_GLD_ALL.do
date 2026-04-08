/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				COD_2004_E123_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>					STATA </_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2026-03-23 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						Democratic Republic of the Congo (COD) </_Country_>
<_Survey Title_>				Enquete 1-2-3 Phase 1 Emploi </_Survey Title_>
<_Survey Year_>					2004 </_Survey Year_>
<_Study ID_>					COD_2004_E123 </_Study ID_>
<_Data collection from_>		2004 </_Data collection from_>
<_Data collection to_>			2004 </_Data collection to_>
<_Source of dataset_> 			Institut National de la Statistique (INS) </_Source of dataset_>
<_Sample size (HH)_> 			13215 </_Sample size (HH)_>
<_Sample size (IND)_> 			72685 </_Sample size (IND)_>
<_Sampling method_> 			Person-level Phase 1 employment file. Delivered documentation in this folder was sufficient to identify provinces and residence strata, but not to recover a fuller sampling note. </_Sampling method_>
<_Geographic coverage_> 		National, with province and residence-area information in the raw data </_Geographic coverage_>
<_Currency_> 					Congolese franc (FC) </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS-13 </_ICLS Version_>
<_ISCED Version_>				Not identified from delivered documentation </_ISCED Version_>
<_ISCO Version_>				isco_1988 </_ISCO Version_>
<_OCCUP National_>				Delivered occupation codes are close to ISCO-88 3-digit groups, with a few survey-specific residual codes </_OCCUP National_>
<_ISIC Version_>				isic_3_1 </_ISIC Version_>
<_INDUS National_>				Delivered industry codes are close to ISIC Rev. 3.1, with some grouped or survey-specific codes </_INDUS National_>

-----------------------------------------------------------------------
<_Version Control_>

</_Version Control_>

-------------------------------------------------------------------------*/


/*%%=============================================================================================
	1: Setting up of program environment, dataset
==============================================================================================%%*/

*----------1.1: Initial commands------------------------------*

clear
set more off
set varabbrev off

*----------1.2: Set directories------------------------------*

local server  "/Users/angelosantos/Downloads"
local country "COD"
local year    "2004"
local survey  "E123"
local vermast "V01"
local veralt  "V01"

local level_1      "`country'_`year'_`survey'"
local level_2_mast "`level_1'_`vermast'_M"
local level_2_harm "`level_1'_`vermast'_M_`veralt'_A_GLD"

local path_in_stata "`server'/`country'/`level_1'/`level_2_mast'/Data/Stata"
local path_in_other "`server'/`country'/`level_1'/`level_2_mast'/Data/Original"
local path_output   "`server'/`country'/`level_1'/`level_2_harm'/Data/Harmonized"

local out_file "`level_2_harm'_ALL.dta"

*----------1.3: Database assembly------------------------------*

* All steps necessary to merge datasets (if several) to have all elements needed to produce
* harmonized output in a single file

use "`path_in_stata'/Phase1_IND.dta", clear


/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str3 countrycode = "COD"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen str4 survname = "E123"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen str12 survey = "E123"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	gen str8 icls_v = "ICLS-13"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	/* <_isced_version_note>

	The delivered 2004 education variables support the GLD education ladder through school
	attendance, level, diploma, and years completed, but they do not provide a clean crosswalk to a
	specific ISCED version for all reported categories. We therefore preserve the GLD schema and
	leave `isced_version` empty.

	</_isced_version_note> */
	gen strL isced_version = ""
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
	gen str10 isco_version = "isco_1988"
	label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
	gen str10 isic_version = "isic_3.1"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	gen year = 2004
	label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen strL vermast = "`vermast'"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen strL veralt = "`veralt'"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen strL harmonization = "GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	gen int_year = 2004
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen int_month = .
	label define lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December", replace
	label values int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
/* <_hhid_note>

	The variable should be a string made up of the elements to define it, that is psu code, ssu, ...
	Each element should always be as long as needed for the longest element. That is, if there are
	60 psu coded 1 through 60, codes should be 01, 02, ..., 60. If there are 160 it should be 001,
	002, ..., 160.

	The delivered person file already contains `idmen`, which is unique at household level. We use
	that stable raw identifier directly and store it as a string GLD household ID.

</_hhid_note> */
	gen strL hhid = string(idmen, "%12.0f")
	replace hhid = subinstr(hhid, " ", "", .)
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
/* <_pid_note>

	The delivered person file already contains `idind`, and that identifier is unique for all
	72,685 observations in `Phase1_IND.dta`. We use it directly as the GLD person ID.

</_pid_note> */
	gen strL pid = string(idind, "%12.0f")
	replace pid = subinstr(pid, " ", "", .)
	isid pid
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
	gen weight = ponder3b
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
	gen psu = site
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = menage
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	egen strata = group(prov milieu)
	label var strata "Strata"
*</_strata_>


*<_wave_>
	gen wave = .
	label var wave "Survey wave"
*</_wave_>


*<_panel_>
	gen strL panel = ""
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
/* <_urban_note>

	The raw variable `milieu` has three categories. Based on the province-by-milieu distribution,
	category 3 is treated as rural and categories 1 and 2 are treated as urban. This should be
	revisited if fuller sampling documentation becomes available.

</_urban_note> */
	gen urban = .
	replace urban = 1 if inlist(milieu, 1, 2)
	replace urban = 0 if milieu == 3
	label var urban "Location is urban"
	label define lblurban 1 "Urban" 0 "Rural", replace
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
* Made consistent with 2012 codes because that is better organized
	gen strL subnatid1 = ""
	replace subnatid1 = "1 - Kinshasa" if prov == 10
	replace subnatid1 = "2 - Bandundu" if prov == 30
	replace subnatid1 = "3 - Bas-Congo" if prov == 20
	replace subnatid1 = "4 - Katanga" if prov == 63
	replace subnatid1 = "5 - Kasai Oriental" if prov == 62
	replace subnatid1 = "6 - Kasai Occidental" if prov == 61
	replace subnatid1 = "7 - Equateur" if prov == 40
	replace subnatid1 = "8 - Nord-Kivu" if prov == 80
	replace subnatid1 = "9 - Sud-Kivu" if prov == 90
	replace subnatid1 = "10 - Maniema" if prov == 70
	replace subnatid1 = "11 - Province Orientale" if prov == 50
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
/* <_subnatid2_note>

	The delivered file includes `pool`, but no crosswalk to subnational names was provided in the
	survey folder. We therefore retain the code only as the second-level GLD geography string.

</_subnatid2_note> */
	gen strL subnatid2 = string(pool, "%02.0f")
	replace subnatid2 = subinstr(subnatid2, " ", "", .)
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	gen strL subnatid3 = ""
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
/* <_subnatidsurvey_note>

The 2004-2005 materials are not presented as one uniform province-by-province reporting frame.
Instead, the main reporting domains are Kinshasa on its own and the broader urban-rural split in
the later rollout. We therefore code `subnatidsurvey` to reflect those reporting domains rather
than the province identifier stored in `subnatid1`.

</_subnatidsurvey_note> */
	gen strL subnatidsurvey = ""
	replace subnatidsurvey = "Kinshasa" if subnatid1 == "1 - Kinshasa"
	replace subnatidsurvey = "Urban" if subnatid1 != "1 - Kinshasa" & urban == 1
	replace subnatidsurvey = "Rural" if urban == 0
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
	gen hsize = q17_tmen
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen age = m4_age
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = .
	replace male = 1 if m3_sexe == 1
	replace male = 0 if m3_sexe == 2
	label var male "Sex - Ind is male"
	label define lblmale 1 "Male" 0 "Female", replace
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen relationharm = .
	replace relationharm = 1 if m5_lien == 1
	replace relationharm = 2 if m5_lien == 2
	replace relationharm = 3 if m5_lien == 3
	replace relationharm = 4 if m5_lien == 4
	replace relationharm = 5 if m5_lien == 5
	replace relationharm = 6 if inlist(m5_lien, 6, 7)
	label var relationharm "Relationship to the head of household - Harmonized"
	label define lblrelationharm 1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives", replace
	label values relationharm lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = m5_lien
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen marital = .
	replace marital = 1 if inlist(m6_situa, 2, 3)
	replace marital = 2 if m6_situa == 1
	replace marital = 3 if m6_situa == 4
	replace marital = 4 if m6_situa == 5
	replace marital = 5 if m6_situa == 6
	label var marital "Marital status"
	label define lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed", replace
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	gen eye_dsablty = .
	label define dsablty 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all", replace
	label values eye_dsablty dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty = .
	label define dsablty 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all", replace
	label values hear_dsablty dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty = .
	label define dsablty 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all", replace
	label values walk_dsablty dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord = .
	label define dsablty 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all", replace
	label values conc_dsord dsablty
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty = .
	label define dsablty 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all", replace
	label values slfcre_dsablty dsablty
	label var slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty = .
	label define dsablty 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all", replace
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
	label define lblmigrated_binary 0 "No" 1 "Yes", replace
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
	label define lblmigrated_from_urban 0 "Rural" 1 "Urban", replace
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen migrated_from_cat = .
	replace migrated_from_cat = . if migrated_binary != 1
	label define lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country" 6 "Within country, admin unknown" 7 "Wholly unknown", replace
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen strL migrated_from_code = ""
	replace migrated_from_code = "" if migrated_binary != 1
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen strL migrated_from_country = ""
	replace migrated_from_country = "" if migrated_binary != 1
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason = .
	replace migrated_reason = . if migrated_binary != 1
	label define lblmigrated_reason 1 "Family reasons" 2 "Educational reasons" 3 "Employment" 4 "Forced (political reasons, natural disaster, ...)" 5 "Other reasons", replace
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

Education items are populated for nearly the full roster in the delivered person file, so the
GLD education module age is set to zero and no survey-based lower cutoff is imposed.

</_ed_mod_age_note> */

gen ed_mod_age = 0
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen school = .
	replace school = 1 if m16_eca == 1
	replace school = 0 if m16_eca == 2
	label var school "Attending school"
	label define lblschool 0 "No" 1 "Yes", replace
	label values school lblschool
*</_school_>


*<_literacy_>
	gen literacy = .
	replace literacy = 1 if m18_lfr == 1 | m18_lna == 1 | m18_aut == 1
	replace literacy = 0 if m18_lfr == 2 & m18_lna == 2 & m18_aut == 2
	label var literacy "Individual can read & write"
	label define lblliteracy 0 "No" 1 "Yes", replace
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen educy = m14_cla
	replace educy = 0 if m13a_ecp == 2
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
/* <_educat7_note>

	The survey provides a direct years-of-study variable in `m14_cla`, and the questionnaire states
	that it should already be converted into years of education completed successfully. We therefore
	use `m13a_ecp`, `m13b_ens`, `m13d_dip`, and `m14_cla` together to map the GLD education ladder.
	Because the delivered data do not support a clean distinction between short-cycle tertiary and
	university, level 6 is not used. A conservative 108 cases remain missing after this mapping.

</_educat7_note> */
	gen educat7 = .
	replace educat7 = 1 if m13a_ecp == 2
	replace educat7 = 2 if m13a_ecp == 1 & m13b_ens == 1 & m14_cla < 6
	replace educat7 = 3 if m13a_ecp == 1 & m13b_ens == 1 & (m14_cla >= 6 | m13d_dip == 1)
	replace educat7 = 4 if m13a_ecp == 1 & inlist(m13b_ens, 2, 3) & m14_cla < 12 & !inlist(m13d_dip, 2, 3, 5)
	replace educat7 = 5 if m13a_ecp == 1 & inlist(m13b_ens, 2, 3) & (m14_cla >= 12 | inlist(m13d_dip, 2, 3, 5))
	replace educat7 = 7 if m13a_ecp == 1 & inlist(m13b_ens, 4, 5)
	label var educat7 "Level of education 1"
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete", replace
	label values educat7 lbleducat7
*</_educat7_>


*<_educat5_>
	gen educat5 = educat7
	recode educat5 (4 = 3) (5 = 4) (6 7 = 5)
	label var educat5 "Level of education 2"
	label define lbleducat5 1 "No education" 2 "Primary incomplete" 3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary", replace
	label values educat5 lbleducat5
*</_educat5_>


*<_educat4_>
	gen educat4 = educat7
	recode educat4 (2 3 4 = 2) (5 = 3) (6 7 = 4)
	label var educat4 "Level of education 3"
	label define lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary", replace
	label values educat4 lbleducat4
*</_educat4_>


*<_educat_orig_>
	gen educat_orig = m13d_dip
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
	/* <_educat_isced_note>

	The raw 2004 education module is sufficient for `educat7`, `educat5`, and `educat4`, but it
	does not support a defensible standardised ISCED mapping across the reported schooling and
	diploma categories. `educat_isced` is therefore left missing rather than filled through a weak
	approximation.

	</_educat_isced_note> */
	gen educat_isced = .
	label var educat_isced "ISCED standardised level of education"
*</_educat_isced_>


*----------6.1: Education cleanup------------------------------*

*<_% Correction min age_>

local ed_vars "school literacy educy educat7 educat5 educat4 educat_orig educat_isced"

foreach ed_var of local ed_vars {
	capture confirm numeric variable `ed_var'
	if _rc == 0 {
		replace `ed_var' = . if age < ed_mod_age & !missing(age)
	}
	else {
		replace `ed_var' = "" if age < ed_mod_age & !missing(age)
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
	label define lblvocational 0 "No" 1 "Yes", replace
	label values vocational lblvocational
	label var vocational "Ever received vocational training"
*</_vocational_>


*<_vocational_type_>
	gen vocational_type = .
	label define lblvocational_type 1 "Inside Enterprise" 2 "External", replace
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
	gen strL vocational_field_orig = ""
	label var vocational_field_orig "Original field of training information"
*</_vocational_field_orig_>


*<_vocational_financed_>
	gen vocational_financed = .
	label define lblvocational_financed 1 "Employer" 2 "Government" 3 "Mixed Employer/Government" 4 "Own funds" 5 "Other", replace
	label values vocational_financed lblvocational_financed
	label var vocational_financed "How training was financed"
*</_vocational_financed_>

}


/*%%=============================================================================================
	8: Labour
==============================================================================================%%*/


*<_minlaborage_>
	gen minlaborage = 10
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
/* <_lstatus_note>

Employed:
- worked at least one hour in the last 7 days (`ea2_empl == 1`), which affects 22,211 cases.
- did an own-account, family, apprenticeship, or other income-generating activity after a "no"
  at `EA2`; this is captured in `ea3_aut` values 1 to 9 and affects 1,851 cases.
- was temporarily absent from a job but still reported a job attachment (`ea4_empl == 1`), which
  affects 954 cases.

Unemployed:
- not employed under the branches above.
- searched for work in the last week or the last 4 weeks (`ea7_rsm == 1` or `ea7b_rmm == 1`).
- was available immediately or within 15 days (`ea7c_dis` in 1 or 2). This branch affects
  891 cases.

Non-labour force:
- everyone else age 10 and older.
- `potential_lf` separately records those who are available but not searching, or searching but
  not available within 15 days.

</_lstatus_note> */
	gen lstatus = .
	replace lstatus = . if age < minlaborage & !missing(age)
	replace lstatus = 1 if age >= minlaborage & (ea2_empl == 1 | inrange(ea3_aut, 1, 9) | ea4_empl == 1)
	replace lstatus = 2 if age >= minlaborage & missing(lstatus) & (ea7_rsm == 1 | ea7b_rmm == 1) & inlist(ea7c_dis, 1, 2)
	replace lstatus = 3 if age >= minlaborage & missing(lstatus)
	label var lstatus "Labor status"
	label define lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF", replace
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen potential_lf = .
	replace potential_lf = . if age < minlaborage & !missing(age)
	replace potential_lf = . if lstatus != 3
	replace potential_lf = 1 if lstatus == 3 & ((ea7_rsm == 1 | ea7b_rmm == 1) & inlist(ea7c_dis, 3, 4))
	replace potential_lf = 1 if lstatus == 3 & ea8b2_im == 1
	replace potential_lf = 0 if lstatus == 3 & missing(potential_lf)
	label var potential_lf "Potential labour force status"
	label define lblpotential_lf 0 "No" 1 "Yes", replace
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen underemployment = .
	replace underemployment = . if age < minlaborage & !missing(age)
	replace underemployment = . if lstatus != 1
	replace underemployment = 1 if lstatus == 1 & ap11_hh < 45 & r3_plus == 1
	replace underemployment = 0 if lstatus == 1 & (r3_plus == 2 | ap11_hh >= 45)
	label var underemployment "Underemployment status"
	label define lblunderemployment 0 "No" 1 "Yes", replace
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen nlfreason = .
	replace nlfreason = . if lstatus != 3
	replace nlfreason = 1 if lstatus == 3 & ea8a_rai == 2
	replace nlfreason = 2 if lstatus == 3 & ea8a_rai == 4
	replace nlfreason = 3 if lstatus == 3 & ea8a_rai == 3
	replace nlfreason = 4 if lstatus == 3 & ea8a_rai == 1
	replace nlfreason = 5 if lstatus == 3 & inlist(ea8a_rai, 5, 6)
	label var nlfreason "Reason not in the labor force"
	label define lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other", replace
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen unempldur_l = .
	replace unempldur_l = . if lstatus != 2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen unempldur_u = .
	replace unempldur_u = . if lstatus != 2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
/* <_empstat_note>

	The delivered main-job status ladder `ap3_cat` is unlabeled in the raw 2004 Stata file. To keep
	the main-job coding aligned with the survey's own secondary-job ladder `as4_cat`, we use the
	same status pattern here: categories `0-5` are treated as paid employee, `9` as non-paid
	employee, `6` as employer, `7` as self-employed, and `8` as other.

</_empstat_note> */
	gen empstat = .
	replace empstat = . if lstatus != 1
	replace empstat = 1 if lstatus == 1 & inlist(ap3_cat, 0, 1, 2, 3, 4, 5)
	replace empstat = 2 if lstatus == 1 & ap3_cat == 9
	replace empstat = 3 if lstatus == 1 & ap3_cat == 6
	replace empstat = 4 if lstatus == 1 & ap3_cat == 7
	replace empstat = 5 if lstatus == 1 & ap3_cat == 8
	label var empstat "Employment status during past week primary job 7 day recall"
	label define lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status", replace
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen ocusec = .
	replace ocusec = . if lstatus != 1
	replace ocusec = 1 if lstatus == 1 & ap4_ent == 1
	replace ocusec = 3 if lstatus == 1 & ap4_ent == 2
	replace ocusec = 2 if lstatus == 1 & inlist(ap4_ent, 3, 4, 5)
	label var ocusec "Sector of activity primary job 7 day recall"
	label define lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish", replace
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig = ap2_bran
	replace industry_orig = . if lstatus != 1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
/* <_industrycat_isic_note>

	The delivered main-job industry code is close to ISIC Rev. 3.1 but not exact for every category.
	To avoid overstating detail, we code `industrycat_isic` consistently at the 2-digit-plus-`00`
	level for all defensible nonmissing cases. Six main-job observations remain missing because even
	the first two digits are not defensible against the helper file.

</_industrycat_isic_note> */
	gen str4 industrycat_isic = ""
	replace industrycat_isic = "" if lstatus != 1
	tostring ap2_bran, gen(ap2_bran_str) format(%04.0f)
	gen ind2 = real(substr(ap2_bran_str, 1, 2))
	replace industrycat_isic = substr(ap2_bran_str, 1, 2) + "00" if lstatus == 1 & ap2_bran_str != "" & ///
		(ind2 == 1 | ind2 == 2 | ind2 == 5 | ind2 == 40 | ind2 == 41 | ind2 == 45 | ind2 == 75 | ind2 == 80 | ind2 == 85 | ///
		ind2 == 90 | ind2 == 91 | ind2 == 92 | ind2 == 93 | ind2 == 95 | ind2 == 99 | inrange(ind2, 10, 37) | inrange(ind2, 50, 74))
	drop ap2_bran_str ind2
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen industrycat10 = .
	replace industrycat10 = . if lstatus != 1
	replace industrycat10 = 1 if inlist(substr(industrycat_isic, 1, 2), "01", "02", "05")
	replace industrycat10 = 2 if inlist(substr(industrycat_isic, 1, 2), "10", "11", "12", "13", "14")
	replace industrycat10 = 3 if real(substr(industrycat_isic, 1, 2)) >= 15 & real(substr(industrycat_isic, 1, 2)) <= 37
	replace industrycat10 = 4 if inlist(substr(industrycat_isic, 1, 2), "40", "41")
	replace industrycat10 = 5 if substr(industrycat_isic, 1, 2) == "45"
	replace industrycat10 = 6 if real(substr(industrycat_isic, 1, 2)) >= 50 & real(substr(industrycat_isic, 1, 2)) <= 55
	replace industrycat10 = 7 if real(substr(industrycat_isic, 1, 2)) >= 60 & real(substr(industrycat_isic, 1, 2)) <= 64
	replace industrycat10 = 8 if real(substr(industrycat_isic, 1, 2)) >= 65 & real(substr(industrycat_isic, 1, 2)) <= 74
	replace industrycat10 = 9 if substr(industrycat_isic, 1, 2) == "75"
	replace industrycat10 = 10 if real(substr(industrycat_isic, 1, 2)) >= 80 & real(substr(industrycat_isic, 1, 2)) <= 99
	replace industrycat10 = . if lstatus != 1
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	label define lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified", replace
	label values industrycat10 lblindustrycat10
*</_industrycat10_>


*<_industrycat4_>
	gen industrycat4 = industrycat10
	recode industrycat4 (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	replace industrycat4 = . if lstatus != 1
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	label define lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other", replace
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
	gen occup_orig = ap1_nom
	replace occup_orig = . if lstatus != 1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
/* <_occup_isco_note>

	The main-job occupation code is close to ISCO-88 at the 3-digit level, but the full scheme is
	not completely defensible as exact 4-digit ISCO. We therefore code `occup_isco` consistently as
	the first two digits plus `00` for all defensible nonmissing cases. Twelve main-job cases remain
	missing because even the 2-digit fallback is not supported by the helper file.

</_occup_isco_note> */
	gen str4 occup_isco = ""
	replace occup_isco = "" if lstatus != 1
	tostring ap1_nom, gen(ap1_nom_str) format(%03.0f)
	gen occ2 = real(substr(ap1_nom_str, 1, 2))
	replace occup_isco = substr(ap1_nom_str, 1, 2) + "00" if lstatus == 1 & ap1_nom_str != "" & ///
		(inrange(occ2, 1, 3) | inrange(occ2, 11, 13) | inrange(occ2, 21, 24) | inrange(occ2, 31, 34) | ///
		inrange(occ2, 41, 42) | inrange(occ2, 51, 52) | inrange(occ2, 61, 62) | inrange(occ2, 71, 78) | ///
		inrange(occ2, 81, 83) | inrange(occ2, 91, 93))
	drop ap1_nom_str occ2
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	gen occup = .
	replace occup = . if lstatus != 1
	replace occup = real(substr(string(ap1_nom, "%03.0f"), 1, 1)) if lstatus == 1 & !missing(ap1_nom)
	replace occup = 10 if lstatus == 1 & substr(string(ap1_nom, "%03.0f"), 1, 1) == "0"
	replace occup = 99 if lstatus == 1 & missing(occup) & !missing(ap1_nom)
	label var occup "1 digit occupational classification, primary job 7 day recall"
	label define lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others", replace
	label values occup lbloccup
*</_occup_>


*<_occup_skill_>
	gen occup_skill = .
	replace occup_skill = 3 if inrange(occup, 1, 3)
	replace occup_skill = 2 if inrange(occup, 4, 8)
	replace occup_skill = 1 if occup == 9
	replace occup_skill = . if lstatus != 1
	label define lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill", replace
	label values occup_skill lblskill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_wage_no_compen_>
/* <_wage_no_compen_note>

	The questionnaire records last-month income from the main job as an exact amount in `ap13a_mt`
	and, when that is not available, as an interval in `ap13b_sa`. Because `ap12_pai` explicitly
	allows wages, commissions, business profits, and in-kind remuneration, this monthly earnings
	question is used for all paid remuneration modes `1-6`, leaving only unpaid workers (`7`)
	missing. Exact reported amounts are used directly. For bracket-only respondents, the harmonized
	monthly earnings are imputed from the mean exact earnings of comparable workers in the same wage
	bracket, sex, area, occupation, and broad industry group, with conservative fallback to simpler
	cells when donor cells are sparse. The separately monetized `ap16*` benefit items are not added
	here to avoid double-counting.

</_wage_no_compen_note> */
	gen wage_no_compen = .
	replace wage_no_compen = . if lstatus != 1
	replace wage_no_compen = ap13a_mt if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & !missing(ap13a_mt)
	tempvar exact_bracket donor_full donor_ind donor_occ donor_area donor_sex donor_br
	gen byte `exact_bracket' = .
	replace `exact_bracket' = 1 if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & !missing(ap13a_mt) & ap13a_mt < 5000
	replace `exact_bracket' = 2 if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & !missing(ap13a_mt) & inrange(ap13a_mt, 5000, 9999.999999)
	replace `exact_bracket' = 3 if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & !missing(ap13a_mt) & inrange(ap13a_mt, 10000, 19999.999999)
	replace `exact_bracket' = 4 if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & !missing(ap13a_mt) & inrange(ap13a_mt, 20000, 39999.999999)
	replace `exact_bracket' = 5 if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & !missing(ap13a_mt) & inrange(ap13a_mt, 40000, 59999.999999)
	replace `exact_bracket' = 6 if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & !missing(ap13a_mt) & inrange(ap13a_mt, 60000, 99999.999999)
	replace `exact_bracket' = 7 if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & !missing(ap13a_mt) & ap13a_mt >= 100000
	egen `donor_full' = mean(ap13a_mt) if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & !missing(ap13a_mt), by(`exact_bracket' male urban occup industrycat10)
	egen `donor_ind' = mean(ap13a_mt) if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & !missing(ap13a_mt), by(`exact_bracket' male urban industrycat10)
	egen `donor_occ' = mean(ap13a_mt) if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & !missing(ap13a_mt), by(`exact_bracket' male urban occup)
	egen `donor_area' = mean(ap13a_mt) if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & !missing(ap13a_mt), by(`exact_bracket' urban)
	egen `donor_sex' = mean(ap13a_mt) if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & !missing(ap13a_mt), by(`exact_bracket' male)
	egen `donor_br' = mean(ap13a_mt) if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & !missing(ap13a_mt), by(`exact_bracket')
	replace wage_no_compen = `donor_full' if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & missing(ap13a_mt) & ap13b_sa == `exact_bracket'
	replace wage_no_compen = `donor_ind' if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & missing(wage_no_compen) & missing(ap13a_mt) & ap13b_sa == `exact_bracket'
	replace wage_no_compen = `donor_occ' if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & missing(wage_no_compen) & missing(ap13a_mt) & ap13b_sa == `exact_bracket'
	replace wage_no_compen = `donor_area' if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & missing(wage_no_compen) & missing(ap13a_mt) & ap13b_sa == `exact_bracket'
	replace wage_no_compen = `donor_sex' if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & missing(wage_no_compen) & missing(ap13a_mt) & ap13b_sa == `exact_bracket'
	replace wage_no_compen = `donor_br' if lstatus == 1 & inlist(ap12_pai, 1, 2, 3, 4, 5, 6) & missing(wage_no_compen) & missing(ap13a_mt) & ap13b_sa == `exact_bracket'
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>

/* <_unitwage_note>
	Unitwage refers to the unit used to record wage_no_compen, *not* the unit of
	general wage payent. For example, PHL LFS asks about wage periodicity, then
	asks for basic daily pay. The value of that pay would be wage_no_compen,
	while unitwage is code 1 ("Daily") for all, regardless of the periodicity.
</_unitwage_note> */

	gen unitwage = .
	replace unitwage = . if lstatus != 1
	replace unitwage = . if mi(wage_no_compen)
	replace unitwage = 5 if !missing(wage_no_compen)
	label var unitwage "Last wages' time unit primary job 7 day recall"
	label define lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other", replace
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours = .
	replace whours = . if lstatus != 1
	replace whours = ap11_hh if lstatus == 1 & ap11_hh < 99
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	gen wmonths = .
	replace wmonths = . if lstatus != 1
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
/* <_wage_total_note>

	Use gross wages when available and net wages only when gross wages are not available.
	This is done to make it easy to compare earnings in formal and informal sectors.

</_wage_total_note> */
	gen wage_total = .
	replace wage_total = . if lstatus != 1
	replace wage_total = wage_no_compen * 12 if !missing(wage_no_compen)
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen contract = .
	replace contract = . if lstatus != 1
	replace contract = 1 if lstatus == 1 & inlist(ap8e_ctr, 1, 2, 3)
	replace contract = 0 if lstatus == 1 & ap8e_ctr == 4
	label var contract "Employment has contract primary job 7 day recall"
	label define lblcontract 0 "Without contract" 1 "With contract", replace
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen healthins = .
	replace healthins = . if lstatus != 1
	label var healthins "Employment has health insurance primary job 7 day recall"
	label define lblhealthins 0 "Without health insurance" 1 "With health insurance", replace
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen socialsec = .
	replace socialsec = . if lstatus != 1
	replace socialsec = 1 if lstatus == 1 & ap16a_re == 1
	replace socialsec = 0 if lstatus == 1 & ap16a_re == 2
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	label define lblsocialsec 1 "With social security" 0 "Without social security", replace
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen union = .
	replace union = . if lstatus != 1
	replace union = 1 if lstatus == 1 & ap15b_ap == 1
	replace union = 0 if lstatus == 1 & ap15b_ap == 2
	label var union "Union membership at primary job 7 day recall"
	label define lblunion 0 "Not union member" 1 "Union member", replace
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	gen firmsize_l = .
	replace firmsize_l = . if lstatus != 1
	replace firmsize_l = 1 if lstatus == 1 & ap5_nbre == 1
	replace firmsize_l = 2 if lstatus == 1 & ap5_nbre == 2
	replace firmsize_l = 3 if lstatus == 1 & ap5_nbre == 3
	replace firmsize_l = 6 if lstatus == 1 & ap5_nbre == 4
	replace firmsize_l = 11 if lstatus == 1 & ap5_nbre == 5
	replace firmsize_l = 21 if lstatus == 1 & ap5_nbre == 6
	replace firmsize_l = 51 if lstatus == 1 & ap5_nbre == 7
	replace firmsize_l = 101 if lstatus == 1 & ap5_nbre == 8
	replace firmsize_l = 501 if lstatus == 1 & ap5_nbre == 9
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen firmsize_u = .
	replace firmsize_u = . if lstatus != 1
	replace firmsize_u = 1 if lstatus == 1 & ap5_nbre == 1
	replace firmsize_u = 2 if lstatus == 1 & ap5_nbre == 2
	replace firmsize_u = 5 if lstatus == 1 & ap5_nbre == 3
	replace firmsize_u = 10 if lstatus == 1 & ap5_nbre == 4
	replace firmsize_u = 20 if lstatus == 1 & ap5_nbre == 5
	replace firmsize_u = 50 if lstatus == 1 & ap5_nbre == 6
	replace firmsize_u = 100 if lstatus == 1 & ap5_nbre == 7
	replace firmsize_u = 500 if lstatus == 1 & ap5_nbre == 8
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen empstat_2 = .
	replace empstat_2 = . if lstatus != 1
	replace empstat_2 = 1 if lstatus == 1 & as1c_aut == 1 & inlist(as4_cat, 0, 1, 2, 3, 4, 5)
	replace empstat_2 = 2 if lstatus == 1 & as1c_aut == 1 & as4_cat == 9
	replace empstat_2 = 3 if lstatus == 1 & as1c_aut == 1 & as4_cat == 6
	replace empstat_2 = 4 if lstatus == 1 & as1c_aut == 1 & as4_cat == 7
	replace empstat_2 = 5 if lstatus == 1 & as1c_aut == 1 & as4_cat == 8
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen ocusec_2 = .
	replace ocusec_2 = . if mi(empstat_2)
	replace ocusec_2 = 1 if lstatus == 1 & as1c_aut == 1 & as5_ent == 1
	replace ocusec_2 = 3 if lstatus == 1 & as1c_aut == 1 & as5_ent == 2
	replace ocusec_2 = 2 if lstatus == 1 & as1c_aut == 1 & inlist(as5_ent, 3, 4, 5)
	replace ocusec_2 = . if mi(empstat_2)
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2 = as3_bran
	replace industry_orig_2 = . if mi(empstat_2)
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
/* <_industrycat_isic_2_note>

	The same ISIC Rev. 3.1 logic is applied to the secondary-job industry code. This yields 631
	two-digit fallbacks and leaves 2 observations missing because the code is not defensible.

</_industrycat_isic_2_note> */
	gen str4 industrycat_isic_2 = ""
	replace industrycat_isic_2 = "" if mi(empstat_2)
	tostring as3_bran, gen(as3_bran_str) format(%04.0f)
	gen ind2_2 = real(substr(as3_bran_str, 1, 2))
	replace industrycat_isic_2 = substr(as3_bran_str, 1, 2) + "00" if lstatus == 1 & as1c_aut == 1 & as3_bran_str != "" & ///
		(ind2_2 == 1 | ind2_2 == 2 | ind2_2 == 5 | ind2_2 == 40 | ind2_2 == 41 | ind2_2 == 45 | ind2_2 == 75 | ind2_2 == 80 | ind2_2 == 85 | ///
		ind2_2 == 90 | ind2_2 == 91 | ind2_2 == 92 | ind2_2 == 93 | ind2_2 == 95 | ind2_2 == 99 | inrange(ind2_2, 10, 37) | inrange(ind2_2, 50, 74))
	replace industrycat_isic_2 = "" if mi(empstat_2)
	drop as3_bran_str ind2_2
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen industrycat10_2 = .
	replace industrycat10_2 = . if mi(empstat_2)
	replace industrycat10_2 = 1 if inlist(substr(industrycat_isic_2, 1, 2), "01", "02")
	replace industrycat10_2 = 2 if inlist(substr(industrycat_isic_2, 1, 2), "10", "11", "12", "13", "14")
	replace industrycat10_2 = 3 if real(substr(industrycat_isic_2, 1, 2)) >= 15 & real(substr(industrycat_isic_2, 1, 2)) <= 37
	replace industrycat10_2 = 4 if inlist(substr(industrycat_isic_2, 1, 2), "40", "41")
	replace industrycat10_2 = 5 if substr(industrycat_isic_2, 1, 2) == "45"
	replace industrycat10_2 = 6 if real(substr(industrycat_isic_2, 1, 2)) >= 50 & real(substr(industrycat_isic_2, 1, 2)) <= 55
	replace industrycat10_2 = 7 if real(substr(industrycat_isic_2, 1, 2)) >= 60 & real(substr(industrycat_isic_2, 1, 2)) <= 64
	replace industrycat10_2 = 8 if real(substr(industrycat_isic_2, 1, 2)) >= 65 & real(substr(industrycat_isic_2, 1, 2)) <= 74
	replace industrycat10_2 = 9 if substr(industrycat_isic_2, 1, 2) == "75"
	replace industrycat10_2 = 10 if real(substr(industrycat_isic_2, 1, 2)) >= 80 & real(substr(industrycat_isic_2, 1, 2)) <= 99
	replace industrycat10_2 = . if mi(empstat_2)
	label var industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
	label values industrycat10_2 lblindustrycat10
*</_industrycat10_2_>


*<_industrycat4_2_>
	gen industrycat4_2 = industrycat10_2
	recode industrycat4_2 (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	replace industrycat4_2 = . if mi(empstat_2)
	label var industrycat4_2 "Broad Economic Activities classification, secondary job 7 day recall"
	label values industrycat4_2 lblindustrycat4
*</_industrycat4_2_>


*<_occup_orig_2_>
	gen occup_orig_2 = as2_prof
	replace occup_orig_2 = . if mi(empstat_2)
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
/* <_occup_isco_2_note>

	The secondary-job occupation code is treated the same way as the main-job code: a consistent
	2-digit ISCO-88 fallback for defensible codes, with 9 cases left missing.

</_occup_isco_2_note> */
	gen str4 occup_isco_2 = ""
	replace occup_isco_2 = "" if mi(empstat_2)
	tostring as2_prof, gen(as2_prof_str) format(%03.0f)
	gen occ2_2 = real(substr(as2_prof_str, 1, 2))
	replace occup_isco_2 = substr(as2_prof_str, 1, 2) + "00" if lstatus == 1 & as1c_aut == 1 & as2_prof_str != "" & ///
		(inrange(occ2_2, 1, 3) | inrange(occ2_2, 11, 13) | inrange(occ2_2, 21, 24) | inrange(occ2_2, 31, 34) | ///
		inrange(occ2_2, 41, 42) | inrange(occ2_2, 51, 52) | inrange(occ2_2, 61, 62) | inrange(occ2_2, 71, 78) | ///
		inrange(occ2_2, 81, 83) | inrange(occ2_2, 91, 93))
	replace occup_isco_2 = "" if mi(empstat_2)
	drop as2_prof_str occ2_2
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_2_>
	gen occup_2 = .
	replace occup_2 = . if mi(empstat_2)
	replace occup_2 = real(substr(string(as2_prof, "%03.0f"), 1, 1)) if lstatus == 1 & as1c_aut == 1 & !missing(as2_prof)
	replace occup_2 = 10 if lstatus == 1 & as1c_aut == 1 & substr(string(as2_prof, "%03.0f"), 1, 1) == "0"
	replace occup_2 = 99 if lstatus == 1 & as1c_aut == 1 & missing(occup_2) & !missing(as2_prof)
	replace occup_2 = . if mi(empstat_2)
	label var occup_2 "1 digit occupational classification secondary job 7 day recall"
	label values occup_2 lbloccup
*</_occup_2_>


*<_occup_skill_2_>
	gen occup_skill_2 = .
	replace occup_skill_2 = 3 if inrange(occup_2, 1, 3)
	replace occup_skill_2 = 2 if inrange(occup_2, 4, 8)
	replace occup_skill_2 = 1 if occup_2 == 9
	replace occup_skill_2 = . if mi(empstat_2)
	label define lblskill2 1 "Low skill" 2 "Medium skill" 3 "High skill", replace
	label values occup_skill_2 lblskill2
	label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>


*<_wage_no_compen_2_>
/* <_wage_no_compen_2_note>

	As with the main job, the secondary-job module asks for last-month income from the job rather than
	only wage salary. Exact secondary-job earnings are retained from `as10a_sl`; when only the
	bracketed fallback `as10b_mi` is available, monthly earnings are imputed from the mean exact
	earnings of comparable workers in the same wage bracket, sex, area, occupation, and broad
	industry group, with conservative fallback to simpler cells when donor cells are sparse. Because
	the questionnaire records income for salaried and self-employed secondary jobs, nonmissing
	amounts are retained for all paid secondary-job statuses, while non-paid workers remain missing.

</_wage_no_compen_2_note> */
	gen wage_no_compen_2 = .
	replace wage_no_compen_2 = as10a_sl if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & !missing(as10a_sl)
	tempvar exact_bracket_2 donor_full_2 donor_ind_2 donor_occ_2 donor_area_2 donor_sex_2 donor_br_2
	gen byte `exact_bracket_2' = .
	replace `exact_bracket_2' = 1 if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & !missing(as10a_sl) & as10a_sl < 5000
	replace `exact_bracket_2' = 2 if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & !missing(as10a_sl) & inrange(as10a_sl, 5000, 9999.999999)
	replace `exact_bracket_2' = 3 if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & !missing(as10a_sl) & inrange(as10a_sl, 10000, 19999.999999)
	replace `exact_bracket_2' = 4 if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & !missing(as10a_sl) & inrange(as10a_sl, 20000, 39999.999999)
	replace `exact_bracket_2' = 5 if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & !missing(as10a_sl) & inrange(as10a_sl, 40000, 59999.999999)
	replace `exact_bracket_2' = 6 if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & !missing(as10a_sl) & inrange(as10a_sl, 60000, 99999.999999)
	replace `exact_bracket_2' = 7 if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & !missing(as10a_sl) & as10a_sl >= 100000
	egen `donor_full_2' = mean(as10a_sl) if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & !missing(as10a_sl), by(`exact_bracket_2' male urban occup_2 industrycat10_2)
	egen `donor_ind_2' = mean(as10a_sl) if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & !missing(as10a_sl), by(`exact_bracket_2' male urban industrycat10_2)
	egen `donor_occ_2' = mean(as10a_sl) if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & !missing(as10a_sl), by(`exact_bracket_2' male urban occup_2)
	egen `donor_area_2' = mean(as10a_sl) if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & !missing(as10a_sl), by(`exact_bracket_2' urban)
	egen `donor_sex_2' = mean(as10a_sl) if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & !missing(as10a_sl), by(`exact_bracket_2' male)
	egen `donor_br_2' = mean(as10a_sl) if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & !missing(as10a_sl), by(`exact_bracket_2')
	replace wage_no_compen_2 = `donor_full_2' if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & missing(as10a_sl) & as10b_mi == `exact_bracket_2'
	replace wage_no_compen_2 = `donor_ind_2' if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & missing(wage_no_compen_2) & missing(as10a_sl) & as10b_mi == `exact_bracket_2'
	replace wage_no_compen_2 = `donor_occ_2' if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & missing(wage_no_compen_2) & missing(as10a_sl) & as10b_mi == `exact_bracket_2'
	replace wage_no_compen_2 = `donor_area_2' if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & missing(wage_no_compen_2) & missing(as10a_sl) & as10b_mi == `exact_bracket_2'
	replace wage_no_compen_2 = `donor_sex_2' if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & missing(wage_no_compen_2) & missing(as10a_sl) & as10b_mi == `exact_bracket_2'
	replace wage_no_compen_2 = `donor_br_2' if lstatus == 1 & inlist(empstat_2, 1, 3, 4, 5) & missing(wage_no_compen_2) & missing(as10a_sl) & as10b_mi == `exact_bracket_2'
	replace wage_no_compen_2 = . if mi(empstat_2)
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen unitwage_2 = .
	replace unitwage_2 = . if mi(empstat_2)
	replace unitwage_2 = . if mi(wage_no_compen_2)
	replace unitwage_2 = 5 if !missing(wage_no_compen_2)
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
	gen whours_2 = .
	replace whours_2 = . if mi(empstat_2)
	replace whours_2 = as9_hh if lstatus == 1 & as1c_aut == 1 & as9_hh < 99
	replace whours_2 = . if mi(empstat_2)
	label var whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>


*<_wmonths_2_>
	gen wmonths_2 = .
	replace wmonths_2 = . if mi(empstat_2)
	label var wmonths_2 "Months of work in past 12 months secondary job 7 day recall"
*</_wmonths_2_>


*<_wage_total_2_>
	gen wage_total_2 = .
	replace wage_total_2 = . if mi(empstat_2)
	replace wage_total_2 = wage_no_compen_2 * 12 if !missing(wage_no_compen_2)
	label var wage_total_2 "Annualized total wage secondary job 7 day recall"
*</_wage_total_2_>


*<_firmsize_l_2_>
	gen firmsize_l_2 = .
	replace firmsize_l_2 = . if mi(empstat_2)
	replace firmsize_l_2 = 1 if lstatus == 1 & as1c_aut == 1 & as6_nbp == 1
	replace firmsize_l_2 = 2 if lstatus == 1 & as1c_aut == 1 & as6_nbp == 2
	replace firmsize_l_2 = 3 if lstatus == 1 & as1c_aut == 1 & as6_nbp == 3
	replace firmsize_l_2 = 6 if lstatus == 1 & as1c_aut == 1 & as6_nbp == 4
	replace firmsize_l_2 = 11 if lstatus == 1 & as1c_aut == 1 & as6_nbp == 5
	replace firmsize_l_2 = 21 if lstatus == 1 & as1c_aut == 1 & as6_nbp == 6
	replace firmsize_l_2 = 51 if lstatus == 1 & as1c_aut == 1 & as6_nbp == 7
	replace firmsize_l_2 = 101 if lstatus == 1 & as1c_aut == 1 & as6_nbp == 8
	replace firmsize_l_2 = 501 if lstatus == 1 & as1c_aut == 1 & as6_nbp == 9
	replace firmsize_l_2 = . if mi(empstat_2)
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	gen firmsize_u_2 = .
	replace firmsize_u_2 = . if mi(empstat_2)
	replace firmsize_u_2 = 1 if lstatus == 1 & as1c_aut == 1 & as6_nbp == 1
	replace firmsize_u_2 = 2 if lstatus == 1 & as1c_aut == 1 & as6_nbp == 2
	replace firmsize_u_2 = 5 if lstatus == 1 & as1c_aut == 1 & as6_nbp == 3
	replace firmsize_u_2 = 10 if lstatus == 1 & as1c_aut == 1 & as6_nbp == 4
	replace firmsize_u_2 = 20 if lstatus == 1 & as1c_aut == 1 & as6_nbp == 5
	replace firmsize_u_2 = 50 if lstatus == 1 & as1c_aut == 1 & as6_nbp == 6
	replace firmsize_u_2 = 100 if lstatus == 1 & as1c_aut == 1 & as6_nbp == 7
	replace firmsize_u_2 = 500 if lstatus == 1 & as1c_aut == 1 & as6_nbp == 8
	replace firmsize_u_2 = . if mi(empstat_2)
	label var firmsize_u_2 "Firm size (upper bracket) secondary job 7 day recall"
*</_firmsize_u_2_>

}

*----------8.4: 7 day reference additional jobs------------------------------*

*<_t_hours_others_>
	gen t_hours_others = .
	replace t_hours_others = . if lstatus != 1
	label var t_hours_others "Annualized hours worked in all but primary and secondary jobs 7 day recall"
*</_t_hours_others_>


*<_t_wage_nocompen_others_>
	gen t_wage_nocompen_others = .
	replace t_wage_nocompen_others = . if lstatus != 1
	label var t_wage_nocompen_others "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_others_>


*<_t_wage_others_>
	gen t_wage_others = .
	replace t_wage_others = . if lstatus != 1
	label var t_wage_others "Annualized wage in all but primary and secondary jobs (12-mon ref period)"
*</_t_wage_others_>


*----------8.5: 7 day reference total summary------------------------------*


*<_t_hours_total_>
	gen t_hours_total = .
	replace t_hours_total = . if lstatus != 1
	tempvar t_hours_total_tmp
	egen `t_hours_total_tmp' = rowtotal(whours whours_2)
	replace t_hours_total = `t_hours_total_tmp' if lstatus == 1
	label var t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
	gen t_wage_nocompen_total = .
	replace t_wage_nocompen_total = . if lstatus != 1
	tempvar t_wage_nc_total_tmp
	egen `t_wage_nc_total_tmp' = rowtotal(wage_no_compen wage_no_compen_2)
	replace t_wage_nocompen_total = `t_wage_nc_total_tmp' if lstatus == 1
	label var t_wage_nocompen_total "Annualized earnings in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
	gen t_wage_total = .
	replace t_wage_total = . if lstatus != 1
	tempvar t_wage_total_tmp
	egen `t_wage_total_tmp' = rowtotal(wage_total wage_total_2)
	replace t_wage_total = `t_wage_total_tmp' if lstatus == 1
	label var t_wage_total "Annualized total earnings for all jobs 7 day recall"
*</_t_wage_total_>


*----------8.6: 12 month reference overall------------------------------*

{

*<_lstatus_year_>
	gen lstatus_year = .
	replace lstatus_year = . if age < minlaborage & !missing(age)
	label var lstatus_year "Labor status during last year"
	label define lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF", replace
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>

*<_potential_lf_year_>
	gen potential_lf_year = .
	replace potential_lf_year = . if age < minlaborage & !missing(age)
	replace potential_lf_year = . if lstatus_year != 3
	label var potential_lf_year "Potential labour force status"
	label define lblpotential_lf_year 0 "No" 1 "Yes", replace
	label values potential_lf_year lblpotential_lf_year
*</_potential_lf_year_>


*<_underemployment_year_>
	gen underemployment_year = .
	replace underemployment_year = . if age < minlaborage & !missing(age)
	replace underemployment_year = . if lstatus_year != 1
	label var underemployment_year "Underemployment status"
	label define lblunderemployment_year 0 "No" 1 "Yes", replace
	label values underemployment_year lblunderemployment_year
*</_underemployment_year_>


*<_nlfreason_year_>
	gen nlfreason_year = .
	replace nlfreason_year = . if lstatus_year != 3
	label var nlfreason_year "Reason not in the labor force"
	label define lblnlfreason_year 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other", replace
	label values nlfreason_year lblnlfreason_year
*</_nlfreason_year_>


*<_unempldur_l_year_>
	gen unempldur_l_year = .
	replace unempldur_l_year = . if lstatus_year != 2
	label var unempldur_l_year "Unemployment duration (months) lower bracket"
*</_unempldur_l_year_>


*<_unempldur_u_year_>
	gen unempldur_u_year = .
	replace unempldur_u_year = . if lstatus_year != 2
	label var unempldur_u_year "Unemployment duration (months) upper bracket"
*</_unempldur_u_year_>

}

*----------8.7: 12 month reference main job------------------------------*

{

*<_empstat_year_>
	gen empstat_year = .
	replace empstat_year = . if lstatus_year != 1
	label var empstat_year "Employment status during past week primary job 12 month recall"
	label define lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status", replace
	label values empstat_year lblempstat_year
*</_empstat_year_>

*<_ocusec_year_>
	gen ocusec_year = .
	replace ocusec_year = . if lstatus_year != 1
	label var ocusec_year "Sector of activity primary job 12 month recall"
	label define lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish", replace
	label values ocusec_year lblocusec_year
*</_ocusec_year_>

*<_industry_orig_year_>
	gen industry_orig_year = .
	replace industry_orig_year = . if lstatus_year != 1
	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	gen industrycat_isic_year = .
	replace industrycat_isic_year = . if lstatus_year != 1

	preserve 
	count
	restore 

	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>

*<_industrycat10_year_>
	gen industrycat10_year = .
	replace industrycat10_year = . if lstatus_year != 1
	label var industrycat10_year "1 digit industry classification, primary job 12 month recall"
	label define lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified", replace
	label values industrycat10_year lblindustrycat10_year
*</_industrycat10_year_>


*<_industrycat4_year_>
	gen industrycat4_year = industrycat10_year
	recode industrycat4_year (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	replace industrycat4_year = . if lstatus_year != 1
	label var industrycat4_year "Broad Economic Activities classification, primary job 12 month recall"
	label define lblindustrycat4_year 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other", replace
	label values industrycat4_year lblindustrycat4_year
*</_industrycat4_year_>


*<_occup_orig_year_>
	gen occup_orig_year = .
	replace occup_orig_year = . if lstatus_year != 1
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	gen strL occup_isco_year = ""
	replace occup_isco_year = "" if lstatus_year != 1

	preserve 
	count
	restore

	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_year_>
	gen occup_year = .
	replace occup_year = . if lstatus_year != 1
	label var occup_year "1 digit occupational classification, primary job 12 month recall"
	label define lbloccup_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others", replace
	label values occup_year lbloccup_year
*</_occup_year_>


*<_occup_skill_year_>
	gen occup_skill_year = .
	replace occup_skill_year = 3 if inrange(occup_year, 1, 3)
	replace occup_skill_year = 2 if inrange(occup_year, 4, 8)
	replace occup_skill_year = 1 if occup_year == 9
	replace occup_skill_year = . if lstatus_year != 1
	label define lblskillyear 1 "Low skill" 2 "Medium skill" 3 "High skill", replace
	label values occup_skill_year lblskillyear
	label var occup_skill_year "Skill based on ISCO standard primary job 12 month recall"
*</_occup_skill_year_>


*<_wage_no_compen_year_>
	gen wage_no_compen_year = .
	replace wage_no_compen_year = . if lstatus_year != 1
	label var wage_no_compen_year "Last wage payment primary job 12 month recall"
*</_wage_no_compen_year_>


*<_unitwage_year_>
	gen unitwage_year = .
	replace unitwage_year = . if lstatus_year != 1
	replace unitwage_year = . if mi(wage_no_compen_year)
	label var unitwage_year "Last wages' time unit primary job 12 month recall"
	label define lblunitwage_year 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other", replace
	label values unitwage_year lblunitwage_year
*</_unitwage_year_>


*<_whours_year_>
	gen whours_year = .
	replace whours_year = . if lstatus_year != 1
	label var whours_year "Hours of work in last week primary job 12 month recall"
*</_whours_year_>


*<_wmonths_year_>
	gen wmonths_year = .
	replace wmonths_year = . if lstatus_year != 1
	label var wmonths_year "Months of work in past 12 months primary job 12 month recall"
*</_wmonths_year_>


*<_wage_total_year_>
	gen wage_total_year = .
	replace wage_total_year = . if lstatus_year != 1
	label var wage_total_year "Annualized total wage primary job 12 month recall"
*</_wage_total_year_>


*<_contract_year_>
	gen contract_year = .
	replace contract_year = . if lstatus_year != 1
	label var contract_year "Employment has contract primary job 12 month recall"
	label define lblcontract_year 0 "Without contract" 1 "With contract", replace
	label values contract_year lblcontract_year
*</_contract_year_>


*<_healthins_year_>
	gen healthins_year = .
	replace healthins_year = . if lstatus_year != 1
	label var healthins_year "Employment has health insurance primary job 12 month recall"
	label define lblhealthins_year 0 "Without health insurance" 1 "With health insurance", replace
	label values healthins_year lblhealthins_year
*</_healthins_year_>


*<_socialsec_year_>
	gen socialsec_year = .
	replace socialsec_year = . if lstatus_year != 1
	label var socialsec_year "Employment has social security insurance primary job 12 month recall"
	label define lblsocialsec_year 1 "With social security" 0 "Without social security", replace
	label values socialsec_year lblsocialsec_year
*</_socialsec_year_>


*<_union_year_>
	gen union_year = .
	replace union_year = . if lstatus_year != 1
	label var union_year "Union membership at primary job 12 month recall"
	label define lblunion_year 0 "Not union member" 1 "Union member", replace
	label values union_year lblunion_year
*</_union_year_>


*<_firmsize_l_year_>
	gen firmsize_l_year = .
	replace firmsize_l_year = . if lstatus_year != 1
	label var firmsize_l_year "Firm size (lower bracket) primary job 12 month recall"
*</_firmsize_l_year_>


*<_firmsize_u_year_>
	gen firmsize_u_year = .
	replace firmsize_u_year = . if lstatus_year != 1
	label var firmsize_u_year "Firm size (upper bracket) primary job 12 month recall"
*</_firmsize_u_year_>

}


*----------8.8: 12 month reference secondary job------------------------------*

{

*<_empstat_2_year_>
	gen empstat_2_year = .
	replace empstat_2_year = . if lstatus_year != 1
	label var empstat_2_year "Employment status during past week secondary job 12 month recall"
	label values empstat_2_year lblempstat_year
*</_empstat_2_year_>


*<_ocusec_2_year_>
	gen ocusec_2_year = .
	replace ocusec_2_year = . if lstatus_year != 1
	label var ocusec_2_year "Sector of activity secondary job 12 month recall"
	label define lblocusec_2_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish", replace
	label values ocusec_2_year lblocusec_2_year
*</_ocusec_2_year_>



*<_industry_orig_2_year_>
	gen industry_orig_2_year = .
	replace industry_orig_2_year = . if lstatus_year != 1
	label var industry_orig_2_year "Original survey industry code, secondary job 12 month recall"
*</_industry_orig_2_year_>



*<_industrycat_isic_2_year_>
	gen industrycat_isic_2_year = .
	replace industrycat_isic_2_year = . if lstatus_year != 1
	label var industrycat_isic_2_year "ISIC code of secondary job 12 month recall"
*</_industrycat_isic_2_year_>


*<_industrycat10_2_year_>
	gen industrycat10_2_year = .
	replace industrycat10_2_year = . if lstatus_year != 1
	label var industrycat10_2_year "1 digit industry classification, secondary job 12 month recall"
	label values industrycat10_2_year lblindustrycat10_year
*</_industrycat10_2_year_>


*<_industrycat4_2_year_>
	gen industrycat4_2_year = industrycat10_2_year
	recode industrycat4_2_year (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	replace industrycat4_2_year = . if lstatus_year != 1
	label var industrycat4_2_year "Broad Economic Activities classification, secondary job 12 month recall"
	label values industrycat4_2_year lblindustrycat4_year
*</_industrycat4_2_year_>


*<_occup_orig_2_year_>
	gen occup_orig_2_year = .
	replace occup_orig_2_year = . if lstatus_year != 1
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
	gen strL occup_isco_2_year = ""
	replace occup_isco_2_year = "" if lstatus_year != 1
	label var occup_isco_2_year "ISCO code of secondary job 12 month recall"
*</_occup_isco_2_year_>


*<_occup_2_year_>
	gen occup_2_year = .
	replace occup_2_year = . if lstatus_year != 1
	label var occup_2_year "1 digit occupational classification, secondary job 12 month recall"
	label values occup_2_year lbloccup_year
*</_occup_2_year_>


*<_occup_skill_2_year_>
	gen occup_skill_2_year = .
	replace occup_skill_2_year = 3 if inrange(occup_2_year, 1, 3)
	replace occup_skill_2_year = 2 if inrange(occup_2_year, 4, 8)
	replace occup_skill_2_year = 1 if occup_2_year == 9
	replace occup_skill_2_year = . if lstatus_year != 1
	label define lblskilly2 1 "Low skill" 2 "Medium skill" 3 "High skill", replace
	label values occup_skill_2_year lblskilly2
	label var occup_skill_2_year "Skill based on ISCO standard secondary job 12 month recall"
*</_occup_skill_2_year_>


*<_wage_no_compen_2_year_>
	gen wage_no_compen_2_year = .
	replace wage_no_compen_2_year = . if lstatus_year != 1
	label var wage_no_compen_2_year "Last wage payment secondary job 12 month recall"
*</_wage_no_compen_2_year_>


*<_unitwage_2_year_>
	gen unitwage_2_year = .
	replace unitwage_2_year = . if lstatus_year != 1
	replace unitwage_2_year = . if mi(wage_no_compen_2_year)
	label var unitwage_2_year "Last wages' time unit secondary job 12 month recall"
	label values unitwage_2_year lblunitwage_year
*</_unitwage_2_year_>


*<_whours_2_year_>
	gen whours_2_year = .
	replace whours_2_year = . if lstatus_year != 1
	label var whours_2_year "Hours of work in last week secondary job 12 month recall"
*</_whours_2_year_>


*<_wmonths_2_year_>
	gen wmonths_2_year = .
	replace wmonths_2_year = . if lstatus_year != 1
	label var wmonths_2_year "Months of work in past 12 months secondary job 12 month recall"
*</_wmonths_2_year_>


*<_wage_total_2_year_>
	gen wage_total_2_year = .
	replace wage_total_2_year = . if lstatus_year != 1
	label var wage_total_2_year "Annualized total wage secondary job 12 month recall"
*</_wage_total_2_year_>

*<_firmsize_l_2_year_>
	gen firmsize_l_2_year = .
	replace firmsize_l_2_year = . if lstatus_year != 1
	label var firmsize_l_2_year "Firm size (lower bracket) secondary job 12 month recall"
*</_firmsize_l_2_year_>


*<_firmsize_u_2_year_>
	gen firmsize_u_2_year = .
	replace firmsize_u_2_year = . if lstatus_year != 1
	label var firmsize_u_2_year "Firm size (upper bracket) secondary job 12 month recall"
*</_firmsize_u_2_year_>

}


*----------8.9: 12 month reference additional jobs------------------------------*


*<_t_hours_others_year_>
	gen t_hours_others_year = .
	replace t_hours_others_year = . if lstatus_year != 1
	label var t_hours_others_year "Annualized hours worked in all but primary and secondary jobs 12 month recall"
*</_t_hours_others_year_>

*<_t_wage_nocompen_others_year_>
	gen t_wage_nocompen_others_year = .
	replace t_wage_nocompen_others_year = . if lstatus_year != 1
	label var t_wage_nocompen_others_year "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_others_year_>

*<_t_wage_others_year_>
	gen t_wage_others_year = .
	replace t_wage_others_year = . if lstatus_year != 1
	label var t_wage_others_year "Annualized wage in all but primary and secondary jobs 12 month recall"
*</_t_wage_others_year_>


*----------8.10: 12 month total summary------------------------------*


*<_t_hours_total_year_>
	gen t_hours_total_year = .
	replace t_hours_total_year = . if lstatus_year != 1
	label var t_hours_total_year "Annualized hours worked in all jobs 12 month recall"
*</_t_hours_total_year_>


*<_t_wage_nocompen_total_year_>
	gen t_wage_nocompen_total_year = .
	replace t_wage_nocompen_total_year = . if lstatus_year != 1
	label var t_wage_nocompen_total_year "Annualized wage in all jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_total_year_>


*<_t_wage_total_year_>
	gen t_wage_total_year = .
	replace t_wage_total_year = . if lstatus_year != 1
	label var t_wage_total_year "Annualized total wage for all jobs 12 month recall"
*</_t_wage_total_year_>


*----------8.11: Overall across reference periods------------------------------*


*<_njobs_>
	gen njobs = .
	replace njobs = . if lstatus != 1
	replace njobs = 1 if lstatus == 1
	replace njobs = 2 if lstatus == 1 & as1c_aut == 1
	label var njobs "Total number of jobs"
*</_njobs_>


*<_t_hours_annual_>
	gen t_hours_annual = .
	replace t_hours_annual = . if lstatus_year != 1
	label var t_hours_annual "Total hours worked in all jobs in the previous 12 months"
*</_t_hours_annual_>


*<_linc_nc_>
	gen linc_nc = t_wage_nocompen_total
	replace linc_nc = . if lstatus != 1
	label var linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."
*</_linc_nc_>


*<_laborincome_>
	gen laborincome = t_wage_total
	replace laborincome = . if lstatus != 1
	label var laborincome "Total annual individual labor income in all jobs, incl. bonuses, etc."
*</_laborincome_>


*----------8.13: Labour cleanup------------------------------*

{
*<_% Correction min age_>

	local lab_vars "minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome"

	foreach lab_var of local lab_vars {
		capture confirm numeric variable `lab_var'
		if _rc == 0 {
			replace `lab_var' = . if age < minlaborage & !missing(age)
		}
		else {
			replace `lab_var' = "" if age < minlaborage & !missing(age)
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

	label dir
	local all_lab `r(names)'

	local used_lab
	ds, has(vallabel)

	local labelled_vars `r(varlist)'

	foreach varName of local labelled_vars {
		local y : value label `varName'
		local used_lab `"`used_lab' `y'"'
	}

	local notused 		: list all_lab - used_lab
	local notused_len 	: list sizeof notused

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
local preserve_missing "isced_version educat_isced"

foreach kept_var of local kept_vars {
	if !`: list kept_var in preserve_missing' {
		capture assert missing(`kept_var')
		if !_rc drop `kept_var'
	}
}

*</_% DELETE MISSING VARIABLES_>


*<_% COMPRESS_>

compress

*</_% COMPRESS_>


*<_% SAVE_>

save "`path_output'/`out_file'", replace

*</_% SAVE_>
