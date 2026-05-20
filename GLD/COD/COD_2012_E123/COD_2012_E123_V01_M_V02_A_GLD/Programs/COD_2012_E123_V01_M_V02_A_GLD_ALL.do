/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				COD_2012_E123_V01_M_V02_A_GLD_ALL.do </_Program name_>
<_Application_>					STATA </_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2026-03-23 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						Democratic Republic of the Congo (COD) </_Country_>
<_Survey Title_>				Enquete 1-2-3 Phase 1 Emploi </_Survey Title_>
<_Survey Year_>					2012 </_Survey Year_>
<_Study ID_>					COD_2012_E123 </_Study ID_>
<_Data collection from_>		08/2012 </_Data collection from_>
<_Data collection to_>			04/2013 </_Data collection to_>
<_Source of dataset_> 			Institut National de la Statistique (INS) </_Source of dataset_>
<_Sample size (HH)_> 			21454 </_Sample size (HH)_>
<_Sample size (IND)_> 			111679 </_Sample size (IND)_>
<_Sampling method_> 			Two stage sampling design </_Sampling method_>
<_Geographic coverage_> 		National, with province and urban-rural reporting domains </_Geographic coverage_>
<_Currency_> 					Congolese franc (FC) </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS-13 </_ICLS Version_>
<_ISCED Version_>				 </_ISCED Version_>
<_ISCO Version_>				ISCO 1988 </_ISCO Version_>
<_OCCUP National_>				ISCO 1988 </_OCCUP National_>
<_ISIC Version_>				ISIC version 4 </_ISIC Version_>
<_INDUS National_>				ISIC version 4 </_INDUS National_>

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

if "`c(username)'" == "wb510859" {
	local server "C:/Users/`c(username)'/OneDrive - WBG/GLD - Current Contributors/510859_AS"
}
else {
	local server "C:/Users/`c(username)'/WBG/GLD - Current Contributors/510859_AS"
}
local country "COD"
local year    "2012"
local survey  "E123"
local vermast "V01"
local veralt  "V02"

local level_1      "`country'_`year'_`survey'"
local level_2_mast "`level_1'_`vermast'_M"
local level_2_harm "`level_1'_`vermast'_M_`veralt'_A_GLD"

local path_in_stata "`server'/`country'/`level_1'/`level_2_mast'/Data/Stata"
local path_in_other "`server'/`country'/`level_1'/`level_2_mast'/Data/Original"
local path_output   "`server'/`country'/`level_1'/`level_2_harm'/Data/Harmonized"

*----------1.3: Database assembly------------------------------*

* All steps necessary to merge datasets (if several) to have all elements needed to produce
* harmonized output in a single file

use "`path_in_stata'/e123indmod_emploi.dta", clear
merge 1:1 site menage m1 using "`path_in_stata'/e123indmod00.dta", keep(match master) nogen
merge 1:1 site menage m1 using "`path_in_stata'/e123indmod03.dta", keep(match master) nogen
merge 1:1 site menage m1 using "`path_in_stata'/e123indmod04.dta", keep(match master) nogen
merge 1:1 site menage m1 using "`path_in_stata'/e123indmod05.dta", keep(match master) nogen
merge 1:1 inid using "`path_in_stata'/Activities.dta", keep(match master) nogen
merge 1:1 hhid inid using "`path_in_stata'/ActSecondaire2012.dta", keep(match master) nogen
rename hhid hhid_raw


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

	The delivered education module supports the GLD education ladder through broad attainment levels
	and years completed in cycle, but it does not provide a clean crosswalk to a specific ISCED
	version for all categories. Nonformal, professional (INPP), and "other" schooling categories are
	retained in the raw data but are not mapped to ISCED here. We therefore preserve the GLD schema
	and leave `isced_version` empty.

	</_isced_version_note> */
	gen strL isced_version = ""
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
	gen strL isco_version = "isco_1988"
	label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
	gen str8 isic_version = "isic_4"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	gen year = 2012
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
	gen int_year = .
	replace int_year = 2012 if q20a == 12
	replace int_year = 2013 if q20a == 13
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen int_month = q20m
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

	The delivered module 00 file already contains `hhid`, which is unique at household level. We use
	that stable raw identifier directly and store it as a string GLD household ID.

</_hhid_note> */
	gen strL hhid = string(hhid_raw, "%18.0f")
	replace hhid = subinstr(hhid, " ", "", .)
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
/* <_pid_note>

	The delivered module 00 file already contains `inid`, and that identifier is unique for all
	111,679 observations after the person-level module merges. We use it directly as the GLD person
	ID.

</_pid_note> */
	gen strL pid = string(inid, "%18.0f")
	replace pid = subinstr(pid, " ", "", .)
	isid pid
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
	gen weight = coefext
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
	egen strata = group(province milieu)
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

	The raw variable `milieu` is directly labelled as urban or rural in the delivered data, so the
	GLD urban flag follows that coding without approximation.

</_urban_note> */
	gen urban = .
	replace urban = 1 if milieu == 1
	replace urban = 0 if milieu == 2
	label var urban "Location is urban"
	label define lblurban 1 "Urban" 0 "Rural", replace
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
	gen strL subnatid1 = ""
	replace subnatid1 = "1 - Kinshasa" if province == 1
	replace subnatid1 = "2 - Bandundu" if province == 2
	replace subnatid1 = "3 - Bas-Congo" if province == 3
	replace subnatid1 = "4 - Katanga" if province == 4
	replace subnatid1 = "5 - Kasai Oriental" if province == 5
	replace subnatid1 = "6 - Kasai Occidental" if province == 6
	replace subnatid1 = "7 - Equateur" if province == 7
	replace subnatid1 = "8 - Nord-Kivu" if province == 8
	replace subnatid1 = "9 - Sud-Kivu" if province == 9
	replace subnatid1 = "10 - Maniema" if province == 10
	replace subnatid1 = "11 - Province Orientale" if province == 11
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
/* <_subnatid2_note>

	The survey folder includes `site` codes and a technical workbook on sites, but the delivered
	materials do not provide a complete administrative crosswalk that would justify a clean second
	admin-level GLD geography. `subnatid2` is therefore left blank rather than forcing a code-only
	approximation.

</_subnatid2_note> */
	gen strL subnatid2 = ""
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	gen strL subnatid3 = ""
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
	/* <_subnatidsurvey_note>

	The 2012 round is representative at the province level and is also commonly reported separately
	by urban-rural residence. We therefore code `subnatidsurvey` as the province reporting domain
	interacted with urban-rural residence.

	</_subnatidsurvey_note> */
	gen str5 urban_str = ""
	replace urban_str = "Urban" if urban == 1
	replace urban_str = "Rural" if urban == 0
	gen strL subnatidsurvey = subnatid1 + " " + urban_str if urban_str != ""
	drop urban_str
	label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>


*<_subnatid1_prev_>
/* <_subnatid1_prev_note>

	subnatid1_prev is coded as missing unless the classification used for subnatid1 has changed since the previous survey.

</_subnatid1_prev_note> */
	gen strL subnatid1_prev = ""
	label var subnatid1_prev "Classification used for subnatid1 from previous survey"
*</_subnatid1_prev_>


*<_subnatid2_prev_>
	gen strL subnatid2_prev = ""
	label var subnatid2_prev "Classification used for subnatid2 from previous survey"
*</_subnatid2_prev_>


*<_subnatid3_prev_>
	gen strL subnatid3_prev = ""
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
	gen hsize = tailm
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen age = m8a
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = .
	replace male = 1 if m3 == 1
	replace male = 0 if m3 == 2
	label var male "Sex - Ind is male"
	label define lblmale 1 "Male" 0 "Female", replace
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen relationharm = .
	replace relationharm = 1 if m4 == 1
	replace relationharm = 2 if m4 == 2
	replace relationharm = 3 if m4 == 3
	replace relationharm = 4 if m4 == 4
	replace relationharm = 5 if m4 == 5
	replace relationharm = 6 if inlist(m4, 6, 7)
	label var relationharm "Relationship to the head of household - Harmonized"
	label define lblrelationharm 1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives", replace
	label values relationharm lblrelationharm
*</_relationharm_>


*<_relationcs_>
	decode m4, gen(relationcs)
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen marital = .
	replace marital = 1 if inlist(m19, 2, 3)
	replace marital = 2 if m19 == 1
	replace marital = 3 if m19 == 4
	replace marital = 4 if m19 == 5
	replace marital = 5 if m19 == 6
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
	gen migrated_mod_age = 5
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time = 99
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
	/* <_migrated_binary_note>

		Continuous residence in the current locality is asked directly in m16a.
		Respondents with m16a==2 are treated as migrants. The small group with
		m16a coded missing is left uncoded even when some migration follow-up
		variables are completed. We observe 1,472 such respondents in fully
		completed interviews, so this is not an age skip pattern. Because the
		migration trigger question itself is missing, these cases are left missing
		rather than forced into migrant or nonmigrant status.

	</_migrated_binary_note> */
	gen migrated_binary = .
	replace migrated_binary = 0 if m16a == 1
	replace migrated_binary = 1 if m16a == 2
	label define lblmigrated_binary 0 "No" 1 "Yes", replace
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen migrated_years = .
	replace migrated_years = m16b if migrated_binary == 1 & !inlist(m16b, 98, 99)
	label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban = .
	replace migrated_from_urban = 1 if migrated_binary == 1 & inrange(m17a, 1, 4)
	replace migrated_from_urban = 0 if migrated_binary == 1 & m17a == 5
	label define lblmigrated_from_urban 0 "Rural" 1 "Urban", replace
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	/* <_migrated_from_cat_note>

		The previous territory code in m17b can be translated to a previous
		province because its labels are organized in province-prefixed blocks
		(e.g. 2001-2012, 3101-3309, 4101-4506). The current file does not retain
		a comparable current lower-admin code, so migration categories are coded
		conservatively at the province level only. All valid internal m17b codes
		observed in the given data fall into one of these province blocks, so the
		admin1 mapping is based on the raw label structure rather than on ad hoc
		code-format assumptions.

	</_migrated_from_cat_note> */
	gen migrated_from_cat = .
	tempvar m17b_pref prev_province
	gen `m17b_pref' = floor(m17b/100)
	gen `prev_province' = .
	replace `prev_province' = 3  if `m17b_pref' == 20
	replace `prev_province' = 2  if inlist(`m17b_pref', 31, 32, 33)
	replace `prev_province' = 7  if inlist(`m17b_pref', 41, 42, 43, 44, 45)
	replace `prev_province' = 11 if inlist(`m17b_pref', 51, 52, 53, 54)
	replace `prev_province' = 8  if `m17b_pref' == 61
	replace `prev_province' = 9  if `m17b_pref' == 62
	replace `prev_province' = 10 if `m17b_pref' == 63
	replace `prev_province' = 4  if inlist(`m17b_pref', 71, 72, 73, 74)
	replace `prev_province' = 5  if inlist(`m17b_pref', 81, 82, 83)
	replace `prev_province' = 6  if inlist(`m17b_pref', 91, 92)
	replace migrated_from_cat = 5 if migrated_binary == 1 & m17a == 6
	replace migrated_from_cat = 3 if migrated_binary == 1 & m17a != 6 & m17b != 9999 & `prev_province' == province
	replace migrated_from_cat = 4 if migrated_binary == 1 & m17a != 6 & m17b != 9999 & `prev_province' != . & `prev_province' != province
	replace migrated_from_cat = 6 if migrated_binary == 1 & missing(migrated_from_cat)
	label define lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country" 6 "Within country, admin unknown" 7 "Wholly unknown", replace
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	/* <_migrated_from_code_note>

		m17b is a raw previous-territory code, but migrated_from_cat is coded at
		the province level. To keep migrated_from_code at the same admin level as
		migrated_from_cat, the code stored here is the previous province in the
		same subnatid1-style format used elsewhere in the file, not the raw m17b
		territory code.

	</_migrated_from_code_note> */
	gen strL migrated_from_code = ""
	replace migrated_from_code = "1 - Kinshasa" if inlist(migrated_from_cat, 3, 4) & `prev_province' == 1
	replace migrated_from_code = "2 - Bandundu" if inlist(migrated_from_cat, 3, 4) & `prev_province' == 2
	replace migrated_from_code = "3 - Bas-Congo" if inlist(migrated_from_cat, 3, 4) & `prev_province' == 3
	replace migrated_from_code = "4 - Katanga" if inlist(migrated_from_cat, 3, 4) & `prev_province' == 4
	replace migrated_from_code = "5 - Kasai Oriental" if inlist(migrated_from_cat, 3, 4) & `prev_province' == 5
	replace migrated_from_code = "6 - Kasai Occidental" if inlist(migrated_from_cat, 3, 4) & `prev_province' == 6
	replace migrated_from_code = "7 - Equateur" if inlist(migrated_from_cat, 3, 4) & `prev_province' == 7
	replace migrated_from_code = "8 - Nord-Kivu" if inlist(migrated_from_cat, 3, 4) & `prev_province' == 8
	replace migrated_from_code = "9 - Sud-Kivu" if inlist(migrated_from_cat, 3, 4) & `prev_province' == 9
	replace migrated_from_code = "10 - Maniema" if inlist(migrated_from_cat, 3, 4) & `prev_province' == 10
	replace migrated_from_code = "11 - Province Orientale" if inlist(migrated_from_cat, 3, 4) & `prev_province' == 11
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen strL migrated_from_country = ""
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason = .
	replace migrated_reason = 1 if migrated_binary == 1 & m18 == 1
	replace migrated_reason = 2 if migrated_binary == 1 & m18 == 2
	replace migrated_reason = 3 if migrated_binary == 1 & inlist(m18, 4, 5)
	replace migrated_reason = 4 if migrated_binary == 1 & m18 == 6
	replace migrated_reason = 5 if migrated_binary == 1 & inlist(m18, 3, 7)
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

The individual questionnaire applies the education block to persons age 3 and older. The
delivered education module is merged for the full roster, so GLD applies the documented age rule
explicitly during cleanup.

</_ed_mod_age_note> */

gen ed_mod_age = 3
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen school = .
	replace school = 1 if ed10 == 1
	replace school = 0 if ed10 == 2
	label var school "Attending school"
	label define lblschool 0 "No" 1 "Yes", replace
	label values school lblschool
*</_school_>


*<_literacy_>
	gen literacy = .
	replace literacy = 1 if ed01 == 1 & ed02 == 1
	replace literacy = 0 if ed01 == 2 | ed02 == 2
	label var literacy "Individual can read & write"
	label define lblliteracy 0 "No" 1 "Yes", replace
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen educy = .
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
/* <_educat7_note>

	The questionnaire identifies the highest level passed successfully in `ed22` and the number of
	years completed successfully within that cycle in `ed23`. We map the GLD education ladder from
	those two variables only where the raw data justify the distinction. Nonformal and "other"
	education categories are left missing rather than forced into the standard ladder.

</_educat7_note> */
	gen educat7 = .
	replace educat7 = 1 if ed22 == 0
	replace educat7 = 2 if ed22 == 1 & inrange(ed23, 0, 5)
	replace educat7 = 3 if ed22 == 1 & ed23 >= 6 & !missing(ed23)
	replace educat7 = 4 if ed22 == 2 & inrange(ed23, 0, 5)
	replace educat7 = 5 if ed22 == 2 & ed23 >= 6 & !missing(ed23)
	replace educat7 = 5 if ed22 == 6
	replace educat7 = 7 if inlist(ed22, 4, 5)
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
	gen educat_orig = ed22
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
	/* <_educat_isced_note>

	The delivered education categories are sufficient for `educat7`, `educat5`, and `educat4`, but
	they do not support a defensible standardised ISCED mapping across all reported schooling types.
	For this reason, `educat_isced` is left missing rather than forcing an approximate crosswalk.

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
	gen minlaborage = 5
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
/* <_lstatus_note>

Employed:
- worked at least one hour in the last 7 days (`ea2 == 1`), which affects 34,304 cases.
- reported an own-account, family-helping, or other income-generating activity after a "no" at
  `EA2`; this is captured by `ea3` values 1 to 9 and affects 2,916 additional cases.
- was temporarily absent from a job but could return within 4 weeks (`ea4 == 1 & ea6 == 1`),
  which affects 166 additional cases.

Unemployed:
- not employed under the worked, other activity, or short temporary-absence branches above.
- searched for work in the last week or the last 4 weeks (`ea7a == 1` or `ea7b == 1`).
- was available immediately or within 15 days (`ea7c` in 1 or 2). This branch affects 1,653
  cases.

Final employed branch:
- had a main-job module response despite missing absence duration (`ea4 == 1 & ap3 < .`), which
  affects 1,035 additional cases after the unemployment branch. The questionnaire routes 223
  respondents with `EA6 = 2` (more than 4 weeks), `EA6 = 3` (does not know), or `EA6 = 9`
  (missing) away from the main-job module, so those cases are not treated as employed here.

Non-labour force:
- everyone else age 10 and older.
- `potential_lf` separately records those searching but not available within 15 days, or not
  searching but available to start immediately.

</_lstatus_note> */
	gen lstatus = .
	replace lstatus = . if age < minlaborage & !missing(age)
	replace lstatus = 1 if age >= minlaborage & ea2 == 1
	replace lstatus = 1 if age >= minlaborage & missing(lstatus) & inrange(ea3, 1, 9)
	replace lstatus = 1 if age >= minlaborage & missing(lstatus) & ea4 == 1 & ea6 == 1
	replace lstatus = 2 if age >= minlaborage & missing(lstatus) & (ea7a == 1 | ea7b == 1) & inlist(ea7c, 1, 2)
	replace lstatus = 1 if age >= minlaborage & missing(lstatus) & ea4 == 1 & ap3 < .
	replace lstatus = 3 if age >= minlaborage & missing(lstatus)
	label var lstatus "Labor status"
	label define lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF", replace
	label values lstatus lbllstatus

	* There is an lstatus built in variable there:
	tab lstatus actif

	/*
	6 people tagged as not in the labor force by actif but reported the following responses
	indicating employment:


        Activit� r�alis�e pendant les 7 |
   derniers jours pour aider la famille |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
   Travail dans une affaire personnelle |          3       50.00       50.00
 Fabrication d'un produit pour la vente |          1       16.67       66.67
                D�livrance d'un service |          2       33.33      100.00
----------------------------------------+-----------------------------------
                                  Total |          6      100.00

	These respondents also have responses to all the employment modules, and we cannot
	justify why the actif variable tagged them as out of labor force

	*/
*</_lstatus_>


*<_potential_lf_>
	gen potential_lf = .
	replace potential_lf = . if age < minlaborage & !missing(age)
	replace potential_lf = . if lstatus != 3
	replace potential_lf = 1 if lstatus == 3 & (ea7a == 1 | ea7b == 1) & inlist(ea7c, 3, 4)
	replace potential_lf = 1 if lstatus == 3 & ea8b2 == 1
	replace potential_lf = 0 if lstatus == 3 & missing(potential_lf)
	label var potential_lf "Potential labour force status"
	label define lblpotential_lf 0 "No" 1 "Yes", replace
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen underemployment = .
	replace underemployment = . if age < minlaborage & !missing(age)
	replace underemployment = . if lstatus != 1
	replace underemployment = 1 if lstatus == 1 & ap11 < 45 & r3 == 1
	replace underemployment = 0 if lstatus == 1 & (r3 == 2 | ap11 >= 45)
	label var underemployment "Underemployment status"
	label define lblunderemployment 0 "No" 1 "Yes", replace
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen nlfreason = .
	replace nlfreason = . if lstatus != 3
	replace nlfreason = 1 if lstatus == 3 & ea8a == 2
	replace nlfreason = 2 if lstatus == 3 & ea8a == 4
	replace nlfreason = 3 if lstatus == 3 & ea8a == 3
	replace nlfreason = 4 if lstatus == 3 & ea8a == 1
	replace nlfreason = 5 if lstatus == 3 & inlist(ea8a, 5, 6)
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
	gen empstat = .
	replace empstat = . if lstatus != 1
	replace empstat = 1 if lstatus == 1 & inlist(ap3, 1, 2, 3, 4, 5, 6)
	replace empstat = 2 if lstatus == 1 & inlist(ap3, 9, 10)
	replace empstat = 3 if lstatus == 1 & ap3 == 7
	replace empstat = 4 if lstatus == 1 & ap3 == 8
	label var empstat "Employment status during past week primary job 7 day recall"
	label define lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status", replace
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen ocusec = .
	replace ocusec = . if lstatus != 1
	replace ocusec = 1 if lstatus == 1 & inlist(ap4, 1, 2)
	replace ocusec = 2 if lstatus == 1 & inlist(ap4, 3, 4, 5, 6)
	replace ocusec = 4 if lstatus == 1 & ap4 == 2
	label var ocusec "Sector of activity primary job 7 day recall"
	label define lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish", replace
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig = .
	replace industry_orig = real(Classe) if lstatus == 1 & !missing(Classe)
	replace industry_orig = . if lstatus != 1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
/* <_industrycat_isic_note>

	The auxiliary main-job activity file provides detailed ISIC Rev. 4 class information in `Classe`,
	but the delivered class codes are not fully defensible as exact 4-digit ISIC for every record.
	We therefore code `industrycat_isic` consistently from the first two digits and store it as
	`XX00` rather than mixing detailed values with fallback values. After that uniform fallback, 20
	employed cases with nonmissing raw industry do not have a defensible ISIC Rev. 4 match and are
	left missing.

</_industrycat_isic_note> */
	gen str4 industrycat_isic = ""
	replace industrycat_isic = "" if lstatus != 1
	capture confirm numeric variable Classe
	if _rc == 0 {
		tostring Classe, gen(classe_str) format(%12.0f)
	}
	else {
		gen strL classe_str = Classe
	}
	replace classe_str = subinstr(classe_str, " ", "", .)
	replace classe_str = "0" + classe_str if length(classe_str) == 3
	replace classe_str = "00" + classe_str if length(classe_str) == 2
	replace classe_str = "000" + classe_str if length(classe_str) == 1
	replace industrycat_isic = substr(classe_str, 1, 2) + "00" if lstatus == 1 & classe_str != ""
	replace industrycat_isic = "" if inlist(industrycat_isic, "0400", "4400")
	replace industrycat_isic = "" if lstatus != 1 | industrycat_isic == "0000"
	drop classe_str
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen industrycat10 = .
	replace industrycat10 = . if lstatus != 1
	gen isic2_main = real(substr(industrycat_isic, 1, 2)) if lstatus == 1 & industrycat_isic != ""
	replace industrycat10 = 1 if inrange(isic2_main, 1, 3)
	replace industrycat10 = 2 if inrange(isic2_main, 5, 9)
	replace industrycat10 = 3 if inrange(isic2_main, 10, 33)
	replace industrycat10 = 4 if inrange(isic2_main, 35, 39)
	replace industrycat10 = 5 if inrange(isic2_main, 41, 43)
	replace industrycat10 = 6 if inrange(isic2_main, 45, 47)
	replace industrycat10 = 7 if inrange(isic2_main, 49, 63)
	replace industrycat10 = 8 if inrange(isic2_main, 64, 82)
	replace industrycat10 = 9 if isic2_main == 84
	replace industrycat10 = 10 if inrange(isic2_main, 85, 99)
	replace industrycat10 = . if lstatus != 1
	drop isic2_main
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
	gen strL occup_orig = ""
	replace occup_orig = string(ap1, "%03.0f") if lstatus == 1 & !missing(ap1)
	replace occup_orig = ap1a if lstatus == 1 & missing(ap1) & !missing(ap1a)
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
/* <_occup_isco_note>

	The delivered main-job variable `ap1` contains grouped 3-digit occupation codes. Comparing the
	full code list to the shared GLD helper shows that the observed scheme aligns with ISCO-88 rather
	than ISCO-08: codes such as 344, 345, 346, 347, 614, and 615 are valid grouped ISCO-88 classes
	but not ISCO-08 classes. As in AFG IELFS, because the grouped 3-digit scheme is defensible, we
	preserve that detail by zero-padding and appending a trailing zero. The single unmatched code
	`999` is left missing rather than forced into ISCO.

</_occup_isco_note> */
	gen str4 occup_isco = ""
	replace occup_isco = string(ap1, "%03.0f") + "0" if lstatus == 1 & !missing(ap1)
	replace occup_isco = "" if occup_isco == "9990"
	replace occup_isco = "" if lstatus != 1
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	gen occup = .
	replace occup = real(substr(string(ap1, "%03.0f"), 1, 1)) if lstatus == 1 & !missing(ap1) & ap1 != 999
	replace occup = 10 if lstatus == 1 & !missing(ap1) & ap1 != 999 & substr(string(ap1, "%03.0f"), 1, 1) == "0"
	replace occup = . if lstatus != 1
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

	The questionnaire first asks whether the respondent can report last-month income for the main job
	and stores that response in `ap13a`. When the respondent provides the amount, the monetary value
	is recorded in `ap13a1`. When the respondent does not know or refuses, the fallback bracket is
	recorded in `ap13b`. Because `ap12` explicitly distinguishes wages, commissions, business
	profits, and in-kind remuneration, this monthly earnings question is used for all paid
	remuneration modes `1-6`, leaving only unpaid workers (`7`) missing. Exact reported amounts are
	used directly. For bracket-only respondents, the harmonized monthly earnings are imputed from the
	weighted mean exact earnings of comparable workers in the same wage bracket, sex, area,
	occupation, and broad industry group. The separately monetized `ap16*` benefit items are not
	added here to avoid double-counting.

</_wage_no_compen_note> */
	gen double wage_no_compen = .
	gen double wage1 = ap13a1 if lstatus == 1 & inlist(ap12, 1, 2, 3, 4, 5, 6) & ap13a == 1
	replace wage1 = . if wage1 == 0
	winsor2 wage1, suffix(_w) cuts(1 99)
	gen byte salary_cat = .
	replace salary_cat = 1 if wage1_w < 30000 & !missing(wage1_w)
	replace salary_cat = 2 if inrange(wage1_w, 30000, 79999.999999)
	replace salary_cat = 3 if inrange(wage1_w, 80000, 129999.999999)
	replace salary_cat = 4 if inrange(wage1_w, 130000, 149999.999999)
	replace salary_cat = 5 if inrange(wage1_w, 150000, 179999.999999)
	replace salary_cat = 6 if inrange(wage1_w, 180000, 229999.999999)
	replace salary_cat = 7 if wage1_w >= 230000 & !missing(wage1_w)
	preserve
		collapse (mean) wage1_w [iw=weight] if !missing(wage1_w), by(industrycat10 occup male urban salary_cat)
		rename wage1_w wage_group_estimate
		rename salary_cat ap13b
		tempfile salary_helper
		save `salary_helper'
	restore
	merge m:1 industrycat10 occup male urban ap13b using `salary_helper', keep(master match) nogen
	replace wage_no_compen = wage1 if !missing(wage1)
	replace wage_no_compen = wage_group_estimate if lstatus == 1 & inlist(ap12, 1, 2, 3, 4, 5, 6) & ap13a == 2 & missing(wage1) & inrange(ap13b, 1, 7) & !missing(wage_group_estimate)
	drop wage1 wage1_w salary_cat wage_group_estimate
	replace wage_no_compen = . if lstatus != 1
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
	replace whours = ap11 if lstatus == 1 & ap11 < 999
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	gen wmonths = .
	replace wmonths = . if lstatus != 1
	replace wmonths = ap10a if lstatus == 1 & inrange(ap10a, 0, 12)
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
/* <_wage_total_note>

	The questionnaire supports a monthly main-job earnings measure, but the broader
	total-earnings aggregates are left missing here to avoid mixing partially
	constructed totals with the primary monthly earnings concept.

</_wage_total_note> */
	gen wage_total = .
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen contract = .
	replace contract = . if lstatus != 1
	replace contract = 1 if lstatus == 1 & inlist(ap8e, 1, 2, 3)
	replace contract = 0 if lstatus == 1 & ap8e == 4
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
	replace socialsec = 1 if lstatus == 1 & ap16a1 == 1
	replace socialsec = 0 if lstatus == 1 & ap16a1 == 2
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	label define lblsocialsec 1 "With social security" 0 "Without social security", replace
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen union = .
	replace union = . if lstatus != 1
	replace union = 1 if lstatus == 1 & ap15b == 1
	replace union = 0 if lstatus == 1 & ap15b == 2
	label var union "Union membership at primary job 7 day recall"
	label define lblunion 0 "Not union member" 1 "Union member", replace
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	gen firmsize_l = .
	replace firmsize_l = . if lstatus != 1
	replace firmsize_l = 1 if lstatus == 1 & ap5 == 1
	replace firmsize_l = 2 if lstatus == 1 & ap5 == 2
	replace firmsize_l = 3 if lstatus == 1 & ap5 == 3
	replace firmsize_l = 6 if lstatus == 1 & ap5 == 4
	replace firmsize_l = 11 if lstatus == 1 & ap5 == 5
	replace firmsize_l = 21 if lstatus == 1 & ap5 == 6
	replace firmsize_l = 51 if lstatus == 1 & ap5 == 7
	replace firmsize_l = 101 if lstatus == 1 & ap5 == 8
	replace firmsize_l = 501 if lstatus == 1 & ap5 == 9
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen firmsize_u = .
	replace firmsize_u = . if lstatus != 1
	replace firmsize_u = 1 if lstatus == 1 & ap5 == 1
	replace firmsize_u = 2 if lstatus == 1 & ap5 == 2
	replace firmsize_u = 5 if lstatus == 1 & ap5 == 3
	replace firmsize_u = 10 if lstatus == 1 & ap5 == 4
	replace firmsize_u = 20 if lstatus == 1 & ap5 == 5
	replace firmsize_u = 50 if lstatus == 1 & ap5 == 6
	replace firmsize_u = 100 if lstatus == 1 & ap5 == 7
	replace firmsize_u = 500 if lstatus == 1 & ap5 == 8
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen empstat_2 = .
	replace empstat_2 = . if lstatus != 1
	replace empstat_2 = 1 if lstatus == 1 & as1c == 1 & inlist(as4, 1, 2, 3, 4, 5, 6)
	replace empstat_2 = 2 if lstatus == 1 & as1c == 1 & inlist(as4, 9, 10)
	replace empstat_2 = 3 if lstatus == 1 & as1c == 1 & as4 == 7
	replace empstat_2 = 4 if lstatus == 1 & as1c == 1 & as4 == 8
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen ocusec_2 = .
	replace ocusec_2 = . if mi(empstat_2)
	replace ocusec_2 = 1 if lstatus == 1 & as1c == 1 & inlist(as5, 1, 2)
	replace ocusec_2 = 2 if lstatus == 1 & as1c == 1 & inlist(as5, 3, 4, 5, 6)
	replace ocusec_2 = 4 if lstatus == 1 & as1c == 1 & as5 == 2
	replace ocusec_2 = . if mi(empstat_2)
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2 = .
	replace industry_orig_2 = AS3asection if lstatus == 1 & as1c == 1 & !missing(AS3asection)
	replace industry_orig_2 = . if mi(empstat_2)
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
/* <_industrycat_isic_2_note>

	The secondary-job auxiliary file only provides ISIC Rev. 4 section recodes. We therefore retain
	the defensible section letter in `industrycat_isic_2` rather than inventing unsupported detailed
	divisions.

</_industrycat_isic_2_note> */
	gen str4 industrycat_isic_2 = ""
	replace industrycat_isic_2 = "" if mi(empstat_2)
	replace industrycat_isic_2 = "A" if lstatus == 1 & as1c == 1 & AS3asection == 1
	replace industrycat_isic_2 = "B" if lstatus == 1 & as1c == 1 & AS3asection == 2
	replace industrycat_isic_2 = "C" if lstatus == 1 & as1c == 1 & AS3asection == 3
	replace industrycat_isic_2 = "D" if lstatus == 1 & as1c == 1 & AS3asection == 4
	replace industrycat_isic_2 = "E" if lstatus == 1 & as1c == 1 & AS3asection == 5
	replace industrycat_isic_2 = "F" if lstatus == 1 & as1c == 1 & AS3asection == 6
	replace industrycat_isic_2 = "G" if lstatus == 1 & as1c == 1 & AS3asection == 7
	replace industrycat_isic_2 = "H" if lstatus == 1 & as1c == 1 & AS3asection == 8
	replace industrycat_isic_2 = "I" if lstatus == 1 & as1c == 1 & AS3asection == 9
	replace industrycat_isic_2 = "J" if lstatus == 1 & as1c == 1 & AS3asection == 10
	replace industrycat_isic_2 = "K" if lstatus == 1 & as1c == 1 & AS3asection == 11
	replace industrycat_isic_2 = "L" if lstatus == 1 & as1c == 1 & AS3asection == 12
	replace industrycat_isic_2 = "M" if lstatus == 1 & as1c == 1 & AS3asection == 13
	replace industrycat_isic_2 = "N" if lstatus == 1 & as1c == 1 & AS3asection == 14
	replace industrycat_isic_2 = "O" if lstatus == 1 & as1c == 1 & AS3asection == 15
	replace industrycat_isic_2 = "P" if lstatus == 1 & as1c == 1 & AS3asection == 16
	replace industrycat_isic_2 = "Q" if lstatus == 1 & as1c == 1 & AS3asection == 17
	replace industrycat_isic_2 = "R" if lstatus == 1 & as1c == 1 & AS3asection == 18
	replace industrycat_isic_2 = "S" if lstatus == 1 & as1c == 1 & AS3asection == 19
	replace industrycat_isic_2 = "T" if lstatus == 1 & as1c == 1 & AS3asection == 20
	replace industrycat_isic_2 = "U" if lstatus == 1 & as1c == 1 & AS3asection == 21
	replace industrycat_isic_2 = "" if mi(empstat_2)
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen industrycat10_2 = .
	replace industrycat10_2 = . if mi(empstat_2)
	replace industrycat10_2 = 1 if lstatus == 1 & as1c == 1 & AS3asection == 1
	replace industrycat10_2 = 2 if lstatus == 1 & as1c == 1 & AS3asection == 2
	replace industrycat10_2 = 3 if lstatus == 1 & as1c == 1 & AS3asection == 3
	replace industrycat10_2 = 4 if lstatus == 1 & as1c == 1 & inlist(AS3asection, 4, 5)
	replace industrycat10_2 = 5 if lstatus == 1 & as1c == 1 & AS3asection == 6
	replace industrycat10_2 = 6 if lstatus == 1 & as1c == 1 & AS3asection == 7
	replace industrycat10_2 = 7 if lstatus == 1 & as1c == 1 & inlist(AS3asection, 8, 9, 10)
	replace industrycat10_2 = 8 if lstatus == 1 & as1c == 1 & inlist(AS3asection, 11, 12, 13, 14)
	replace industrycat10_2 = 9 if lstatus == 1 & as1c == 1 & AS3asection == 15
	replace industrycat10_2 = 10 if lstatus == 1 & as1c == 1 & inlist(AS3asection, 16, 17, 18, 19, 20, 21)
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
	gen strL occup_orig_2 = ""
	replace occup_orig_2 = string(as2, "%03.0f") if lstatus == 1 & as1c == 1 & !missing(as2)
	replace occup_orig_2 = as2a if lstatus == 1 & as1c == 1 & missing(as2) & !missing(as2a)
	replace occup_orig_2 = "" if mi(empstat_2)
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
/* <_occup_isco_2_note>

	The secondary-job variable `as2` follows the same grouped 3-digit occupation scheme as `ap1` and
	aligns with ISCO-88. We therefore format nonmissing `as2` values as grouped 4-digit ISCO strings
	by appending a trailing zero.

</_occup_isco_2_note> */
	gen str4 occup_isco_2 = ""
	replace occup_isco_2 = string(as2, "%03.0f") + "0" if lstatus == 1 & as1c == 1 & !missing(as2)
	replace occup_isco_2 = "" if mi(empstat_2)
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_2_>
	gen occup_2 = .
	replace occup_2 = real(substr(string(as2, "%03.0f"), 1, 1)) if lstatus == 1 & as1c == 1 & !missing(as2)
	replace occup_2 = 10 if lstatus == 1 & as1c == 1 & !missing(as2) & substr(string(as2, "%03.0f"), 1, 1) == "0"
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

	As with the main job, `as10a` records whether the respondent can provide the amount and the
	monetary value itself is stored in `as10am`. When the respondent cannot provide an amount, the
	fallback bracket is recorded in `as10b`. Because the secondary-job question asks for income from
	the job rather than only wage salary, nonmissing secondary-job earnings are retained for all paid
	secondary-job statuses, while non-paid workers remain missing. For bracket-only respondents,
	monthly earnings are imputed from the weighted mean exact earnings of comparable workers in the
	same wage bracket, sex, area, occupation, and broad industry group.

</_wage_no_compen_2_note> */
	gen double wage_no_compen_2 = .
	gen double wage2 = as10am if lstatus == 1 & inlist(empstat_2, 1, 3, 4) & as10a == 1
	replace wage2 = . if wage2 == 0
	winsor2 wage2, suffix(_w) cuts(1 99)
	gen byte salary_cat_2 = .
	replace salary_cat_2 = 1 if wage2_w < 30000 & !missing(wage2_w)
	replace salary_cat_2 = 2 if inrange(wage2_w, 30000, 79999.999999)
	replace salary_cat_2 = 3 if inrange(wage2_w, 80000, 129999.999999)
	replace salary_cat_2 = 4 if inrange(wage2_w, 130000, 149999.999999)
	replace salary_cat_2 = 5 if inrange(wage2_w, 150000, 179999.999999)
	replace salary_cat_2 = 6 if inrange(wage2_w, 180000, 229999.999999)
	replace salary_cat_2 = 7 if wage2_w >= 230000 & !missing(wage2_w)
	preserve
		collapse (mean) wage2_w [iw=weight] if !missing(wage2_w), by(industrycat10_2 occup_2 male urban salary_cat_2)
		rename wage2_w wage_group_estimate_2
		rename salary_cat_2 as10b
		tempfile salary_helper_2
		save `salary_helper_2'
	restore
	merge m:1 industrycat10_2 occup_2 male urban as10b using `salary_helper_2', keep(master match) nogen
	replace wage_no_compen_2 = wage2 if !missing(wage2)
	replace wage_no_compen_2 = wage_group_estimate_2 if lstatus == 1 & inlist(empstat_2, 1, 3, 4) & as10a == 2 & missing(wage2) & inrange(as10b, 1, 7) & !missing(wage_group_estimate_2)
	drop wage2 wage2_w salary_cat_2 wage_group_estimate_2
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
	replace whours_2 = as9b if lstatus == 1 & as1c == 1 & as9b < 999
	replace whours_2 = . if mi(empstat_2)
	label var whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>


*<_wmonths_2_>
	gen wmonths_2 = .
	replace wmonths_2 = . if mi(empstat_2)
	replace wmonths_2 = as9a if lstatus == 1 & as1c == 1 & inrange(as9a, 0, 12)
	replace wmonths_2 = . if mi(empstat_2)
	label var wmonths_2 "Months of work in past 12 months secondary job 7 day recall"
*</_wmonths_2_>


*<_wage_total_2_>
	gen wage_total_2 = .
	label var wage_total_2 "Annualized total wage secondary job 7 day recall"
*</_wage_total_2_>


*<_firmsize_l_2_>
	gen firmsize_l_2 = .
	replace firmsize_l_2 = . if mi(empstat_2)
	replace firmsize_l_2 = 1 if lstatus == 1 & as1c == 1 & as6 == 1
	replace firmsize_l_2 = 2 if lstatus == 1 & as1c == 1 & as6 == 2
	replace firmsize_l_2 = 3 if lstatus == 1 & as1c == 1 & as6 == 3
	replace firmsize_l_2 = 6 if lstatus == 1 & as1c == 1 & as6 == 4
	replace firmsize_l_2 = 11 if lstatus == 1 & as1c == 1 & as6 == 5
	replace firmsize_l_2 = 21 if lstatus == 1 & as1c == 1 & as6 == 6
	replace firmsize_l_2 = 51 if lstatus == 1 & as1c == 1 & as6 == 7
	replace firmsize_l_2 = 101 if lstatus == 1 & as1c == 1 & as6 == 8
	replace firmsize_l_2 = 501 if lstatus == 1 & as1c == 1 & as6 == 9
	replace firmsize_l_2 = . if mi(empstat_2)
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	gen firmsize_u_2 = .
	replace firmsize_u_2 = . if mi(empstat_2)
	replace firmsize_u_2 = 1 if lstatus == 1 & as1c == 1 & as6 == 1
	replace firmsize_u_2 = 2 if lstatus == 1 & as1c == 1 & as6 == 2
	replace firmsize_u_2 = 5 if lstatus == 1 & as1c == 1 & as6 == 3
	replace firmsize_u_2 = 10 if lstatus == 1 & as1c == 1 & as6 == 4
	replace firmsize_u_2 = 20 if lstatus == 1 & as1c == 1 & as6 == 5
	replace firmsize_u_2 = 50 if lstatus == 1 & as1c == 1 & as6 == 6
	replace firmsize_u_2 = 100 if lstatus == 1 & as1c == 1 & as6 == 7
	replace firmsize_u_2 = 500 if lstatus == 1 & as1c == 1 & as6 == 8
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
	label var t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
	gen t_wage_nocompen_total = .
	label var t_wage_nocompen_total "Annualized earnings in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
	gen t_wage_total = .
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
	gen str4 industrycat_isic_year = ""
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
	gen str4 industrycat_isic_2_year = ""
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
	replace njobs = 2 if lstatus == 1 & as1c == 1
	label var njobs "Total number of jobs"
*</_njobs_>


*<_t_hours_annual_>
	gen t_hours_annual = .
	replace t_hours_annual = . if lstatus_year != 1
	label var t_hours_annual "Total hours worked in all jobs in the previous 12 months"
*</_t_hours_annual_>


*<_linc_nc_>
	gen linc_nc = .
	label var linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."
*</_linc_nc_>


*<_laborincome_>
	gen laborincome = .
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

*<_% COMPRESS_>

compress

*</_% COMPRESS_>


*<_% SAVE_>

save "`path_output'/`level_2_harm'_ALL.dta", replace

*</_% SAVE_>
