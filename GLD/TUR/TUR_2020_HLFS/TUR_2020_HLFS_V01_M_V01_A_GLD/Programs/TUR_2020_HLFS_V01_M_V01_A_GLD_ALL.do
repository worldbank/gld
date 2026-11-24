
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				TUR_2020_HLFS_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata 19 <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2026-11-23 </_Date created_>

-------------------------------------------------------------------------

<_Country_>					TUR </_Country_>
<_Survey Title_>				HLFS </_Survey Title_>
<_Survey Year_>					2020 </_Survey Year_>
<_Study ID_>					Not filled in </_Study ID_>
<_Data collection from_>			01/2020 </_Data collection from_>
<_Data collection to_>				12/2020 </_Data collection to_>
<_Source of dataset_> 				Turkish Statistical Institute </_Source of dataset_>
<_Sample size (HH)_> 				191613 </_Sample size (HH)_>
<_Sample size (IND)_> 				474514 </_Sample size (IND)_>
<_Sampling method_> 				Two-stage stratified cluster sampling </_Sampling method_>
<_Geographic coverage_> 			National (annual) </_Geographic coverage_>
<_Currency_> 					Turkish lira (₺) </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS-13 </_ICLS Version_>
<_ISCED Version_>				Not filled in </_ISCED Version_>
<_ISCO Version_>				ISCO-08 </_ISCO Version_>
<_OCCUP National_>				Not filled in </_OCCUP National_>
<_ISIC Version_>				ISIC Rev. 4 </_ISIC Version_>
<_INDUS National_>				Not filled in </_INDUS National_>

-----------------------------------------------------------------------
<_Version Control_>

* Date: 2026-11-23 - Export of the approved blocks, see export.json

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
local server  "C:/Users/wb510859/WBG/GLD - Current Contributors/999999_ZW"
local country "TUR"
local year    "2020"
local survey  "HLFS"
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

* Load the master dataset, mikro_veri_2020.dta.
use "`path_in_stata'/mikro_veri_2020.dta", clear

/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen strL countrycode = "TUR"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen strL survname = "HLFS"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen strL survey = "LFS"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	* Note: No own-use-production question is present, so there is no definable
	*   own-use-only group for the routing test: own-use-only count, with-follow-up
	*   count, and without-follow-up count are unavailable; the follow-up screens
	*   reviewed were CALISMA, CALISMA_BIR_SAAT and CALISMA_SAHIP_IS.
	* Note: ICLS-13 is selected by the specified default rule rather than an
	*   explicit producer statement naming the ICLS resolution.
	gen strL icls_v = "ICLS-13"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	* Not harmonized: not in the scope of the agents
	gen strL isced_version = ""
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
	gen strL isco_version = "isco_2008"
	label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
	gen strL isic_version = "isic_4"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	gen double year = 2020
	label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen strL vermast = "V01"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen strL veralt = "V01"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen strL harmonization = "GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	gen double int_year = REFERANS_YIL if !missing(REFERANS_YIL)
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	* Set to missing
	gen double int_month = .
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
	* Join BIRIMNO with "-", each padded with zeros
	assert BIRIMNO == floor(BIRIMNO) & abs(BIRIMNO) < 2^53 if !missing(BIRIMNO)
	gen strL _part1 = strtrim(strofreal(BIRIMNO, "%24.17g")) ///
	if !missing(BIRIMNO)
	assert ustrlen(_part1) <= 6
	replace _part1 = substr("000000", 1, 6 - ustrlen(_part1)) + _part1 ///
	    if _part1 != ""
	gen strL hhid = _part1 if _part1 != ""
	drop _part1
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	* Join BIRIMNO and FERTNO with "-", each padded with zeros
	assert BIRIMNO == floor(BIRIMNO) & abs(BIRIMNO) < 2^53 if !missing(BIRIMNO)
	gen strL _part1 = strtrim(strofreal(BIRIMNO, "%24.17g")) ///
	if !missing(BIRIMNO)
	assert ustrlen(_part1) <= 6
	replace _part1 = substr("000000", 1, 6 - ustrlen(_part1)) + _part1 ///
	    if _part1 != ""
	assert FERTNO == floor(FERTNO) & abs(FERTNO) < 2^53 if !missing(FERTNO)
	gen strL _part2 = strtrim(strofreal(FERTNO, "%24.17g")) if !missing(FERTNO)
	assert ustrlen(_part2) <= 2
	replace _part2 = substr("00", 1, 2 - ustrlen(_part2)) + _part2 if _part2 != ""
	gen strL pid = _part1 + "-" + _part2 if _part1 != "" & _part2 != ""
	drop _part1 _part2
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
	* Note: The data covers only individuals aged 15 and above.
	* Note: The GLD coverage rule requires weights for the documented main universe,
	*   but the source assigns zero coefficients to some CATI noninterviews; the
	*   runtime therefore leaves those records without a positive analysis weight.
	gen double AGIRLIK_KATSAYISI_str_0 = real(strtrim(AGIRLIK_KATSAYISI)) if regexm(strtrim(AGIRLIK_KATSAYISI), "^[+-]?([0-9]+[.]?[0-9]*|[.][0-9]+)([eE][+-]?[0-9]+)?$")
	gen double weight = (AGIRLIK_KATSAYISI_str_0 * 1000.0) ///
	    if !missing(AGIRLIK_KATSAYISI_str_0)
	drop AGIRLIK_KATSAYISI_str_0
	replace weight = . if weight <= 0
	label var weight "Survey sampling weight"
*</_weight_>


*<_weight_m_>
	* Not harmonized: not in the scope of the agents
	gen double weight_m = .
	label var weight_m "Survey sampling weight to obtain national estimates for each month"
*</_weight_m_>


*<_weight_q_>
	* Set to missing
	gen double weight_q = .
	label var weight_q "Survey sampling weight to obtain national estimates for each quarter"
*</_weight_q_>


*<_psu_>
	* Not harmonized: not in the scope of the agents
	gen strL psu = ""
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	* Not harmonized: not in the scope of the agents
	gen strL ssu = ""
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	* Not harmonized: not in the scope of the agents
	gen strL strata = ""
	label var strata "Strata"
*</_strata_>


*<_wave_>
	* Set to missing
	gen strL wave = ""
	label var wave "Survey wave"
*</_wave_>


*<_panel_>
	* Not harmonized: not in the scope of the agents
	gen strL panel = ""
	label var panel "Panel individual belongs to"
*</_panel_>


*<_visit_no_>
	* Not harmonized: not in the scope of the agents
	gen double visit_no = .
	label var visit_no "Visit number in panel"
*</_visit_no_>

}


/*%%=============================================================================================
	3: Geography
==============================================================================================%%*/

{

*<_urban_>
	* Set to missing
	gen double urban = .
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
/* <_subnatid1_note>

	The variable is string and country-specific categorical. Numeric entries are coded in string format using the following naming convention: "1 – Hatay". That is, the variable itself is to be string, not a labelled numeric vector. 
	
	Example of entries would be "1 - Alaska",  "2 - Arkansas", ...

</_subnatid1_note> */
	* Note: The GLD current-residence and household-level requirements cannot be
	*   fully confirmed because no questionnaire or geographic-universe
	*   documentation is available; the only retained source is the Level-1
	*   statistical-region column, which is used under the best-source rule.
	gen strL subnatid1 = ""
	replace subnatid1 = "TR1 - İstanbul" if IBBS_1 == "TR1"
	replace subnatid1 = "TR2 - West Marmara" if IBBS_1 == "TR2"
	replace subnatid1 = "TR3 - Aegean" if IBBS_1 == "TR3"
	replace subnatid1 = "TR4 - East Marmara" if IBBS_1 == "TR4"
	replace subnatid1 = "TR5 - West Anatolia" if IBBS_1 == "TR5"
	replace subnatid1 = "TR6 - Mediterranean" if IBBS_1 == "TR6"
	replace subnatid1 = "TR7 - Central Anatolia" if IBBS_1 == "TR7"
	replace subnatid1 = "TR8 - West Black Sea" if IBBS_1 == "TR8"
	replace subnatid1 = "TR9 - East Black Sea" if IBBS_1 == "TR9"
	replace subnatid1 = "TRA - Northeast Anatolia" if IBBS_1 == "TRA"
	replace subnatid1 = "TRB - Central east Anatolia" if IBBS_1 == "TRB"
	replace subnatid1 = "TRC - Southeast Anatolia" if IBBS_1 == "TRC"
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	* Not harmonized: not in the scope of the agents
	gen strL subnatid2 = ""
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	* Not harmonized: not in the scope of the agents
	gen strL subnatid3 = ""
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
	* Not harmonized: not in the scope of the agents
	gen strL subnatidsurvey = ""
	label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>


*<_subnatid1_prev_>
	* Not harmonized: not in the scope of the agents
	gen strL subnatid1_prev = ""
	label var subnatid1_prev "Classification used for subnatid1 from previous survey"
*</_subnatid1_prev_>


*<_subnatid2_prev_>
	* Not harmonized: not in the scope of the agents
	gen strL subnatid2_prev = ""
	label var subnatid2_prev "Classification used for subnatid2 from previous survey"
*</_subnatid2_prev_>


*<_subnatid3_prev_>
	* Not harmonized: not in the scope of the agents
	gen strL subnatid3_prev = ""
	label var subnatid3_prev "Classification used for subnatid3 from previous survey"
*</_subnatid3_prev_>


*<_gaul_adm1_code_>
	* Not harmonized: not in the scope of the agents
	gen double gaul_adm1_code = .
	label var gaul_adm1_code "Global Administrative Unit Layers (GAUL) Admin 1 code"
*</_gaul_adm1_code_>


*<_gaul_adm2_code_>
	* Not harmonized: not in the scope of the agents
	gen double gaul_adm2_code = .
	label var gaul_adm2_code "Global Administrative Unit Layers (GAUL) Admin 2 code"
*</_gaul_adm2_code_>


*<_gaul_adm3_code_>
	* Not harmonized: not in the scope of the agents
	gen double gaul_adm3_code = .
	label var gaul_adm3_code "Global Administrative Unit Layers (GAUL) Admin 3 code"
*</_gaul_adm3_code_>

}


/*%%=============================================================================================
	4: Demography
==============================================================================================%%*/

{

*<_hsize_>
	* Household size: people with the same hhid
	egen double hsize = count(1) if !missing(hhid), by(hhid)
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen double age = YAS if !missing(YAS)
	label var age "Individual age"
*</_age_>


*<_male_>
	* Note: The raw CINSIYET column stores codes 1 and 2, while the 2020 codebook
	*   prints 3 Male and 4 Female. The mapping assumes the raw codes preserve the
	*   printed order, with 1 Male and 2 Female. This interpretation is consistent
	*   with the 2021-2025 GLD mappings and with females outnumbering males in each
	*   year's raw sample.
	* Note: The 2020 codebook prints CINSIYET codes 3 Male and 4 Female, but the
	*   assembled data store unlabeled codes 1 and 2. This proposal uses the
	*   adjacent 2021 GLD mapping for the same column and code pattern.
	* Note: Source labels could not be verified automatically. Codes 1 and 2 of
	*   CINSIYET have no value label and no cited source. The agent mapped code 1 to
	*   1 Male and code 2 to 0 Female.
	gen double male = .
	replace male = 1 if CINSIYET == 1
	replace male = 0 if CINSIYET == 2
	replace male = . if missing(YAS) | YAS < 15
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen double relationharm = .
	replace relationharm = 1 if YAKINLIK == 1
	replace relationharm = 2 if YAKINLIK == 2
	replace relationharm = 3 if YAKINLIK == 3
	replace relationharm = 4 if YAKINLIK == 4
	replace relationharm = 5 if YAKINLIK == 5 | YAKINLIK == 6 | YAKINLIK == 7 ///
	    | YAKINLIK == 8 | YAKINLIK == 9
	replace relationharm = 6 if YAKINLIK == 10 | YAKINLIK == 11
	* One head per household
	* No head: the spouse becomes the head, else the first in the ranking
	* More than one head: the first in the ranking stays, the others get 5
	* Ranking: known sex and age first, then male, then older, then lowest pid
	gen long _hh_row = _n
	gen byte _member = !missing(hhid)
	bysort hhid: egen _known = total(_member & !missing(relationharm))
	by hhid: egen _heads = total(_member & relationharm == 1)
	by hhid: egen _spouses = total(_member & relationharm == 2)
	gen byte _candidate = _member & _known > 0 & _heads != 1
	replace _candidate = _candidate & relationharm == 1 if _heads > 1
	replace _candidate = _candidate & relationharm == 2 ///
	    if _heads == 0 & _spouses > 0
	gen byte _sex_rank = cond(male == 1, 0, cond(male == 0, 1, 2))
	gen double _minus_age = -age
	gen byte _incomplete = _sex_rank == 2 | missing(age)
	gen byte _no_pid = missing(pid)
	sort hhid _candidate _incomplete _sex_rank _minus_age _no_pid pid _hh_row
	by hhid _candidate: gen byte _first = _n == 1 & _candidate
	replace relationharm = 5 if _candidate & !_first & _heads > 1
	replace relationharm = 1 if _first
	sort _hh_row
	drop _hh_row _member _known _heads _spouses _candidate _sex_rank _minus_age ///
	    _incomplete _no_pid _first
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen double relationcs = YAKINLIK if !missing(YAKINLIK)
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen double marital = .
	replace marital = 2 if MEDENI_DURUM == 1
	replace marital = 1 if MEDENI_DURUM == 2
	replace marital = 4 if MEDENI_DURUM == 3
	replace marital = 5 if MEDENI_DURUM == 4
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	* Not harmonized: not in the scope of the agents
	gen double eye_dsablty = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
	label values eye_dsablty dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	* Not harmonized: not in the scope of the agents
	gen double hear_dsablty = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values hear_dsablty dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	* Not harmonized: not in the scope of the agents
	gen double walk_dsablty = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values walk_dsablty dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	* Not harmonized: not in the scope of the agents
	gen double conc_dsord = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values conc_dsord dsablty
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	* Not harmonized: not in the scope of the agents
	gen double slfcre_dsablty = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values slfcre_dsablty dsablty
	label var slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	* Not harmonized: not in the scope of the agents
	gen double comm_dsablty = .
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
	gen double migrated_mod_age = 0
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen double migrated_ref_time = 99
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen double migrated_binary = .
	replace migrated_binary = 0 if DOGUM_YER == 1 & BUIL_YASAMA == 1
	replace migrated_binary = 1 if inlist(ONCEKI_IKAMET, 1, 2)
	count if missing(migrated_binary)
	local unclassified_migration_status = r(N)
	if `unclassified_migration_status' > 0 {
	    display as error "Warning: `unclassified_migration_status' records have missing or inconsistent source routes; migration status remains unclassified."
	}
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen double migrated_years = .
	* In 2020 BUIL_YIL records when the respondent began living in this province.
	* TR_YIL is routed through YURTDISI_DURUM, not previous-province residence.
	replace migrated_years = REFERANS_YIL - BUIL_YIL if ///
	    migrated_binary == 1 & inlist(ONCEKI_IKAMET, 1, 2)
	label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen double migrated_from_urban = .
	* Province/district centers are urban; subdistricts/villages are rural.
	replace migrated_from_urban = 1 if ///
	    migrated_binary == 1 & ONCEKI_IKAMET == 1 & inlist(YERLESIM_TUR, 1, 2)
	replace migrated_from_urban = 0 if ///
	    migrated_binary == 1 & ONCEKI_IKAMET == 1 & YERLESIM_TUR == 3
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen double migrated_from_cat = .
	replace migrated_from_cat = 6 if ///
	    migrated_binary == 1 & ONCEKI_IKAMET == 1
	replace migrated_from_cat = 5 if ///
	    migrated_binary == 1 & ONCEKI_IKAMET == 2
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country" 6 "Within country, admin unknown" 7 "Wholly unknown"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen strL migrated_from_code = ""
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen strL migrated_from_country = ""
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen double migrated_reason = .
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

	* Note: The assembled microdata contain no person younger than 15, so the
	*   documented age-5 threshold cannot be empirically checked at its lower
	*   boundary.
	gen double ed_mod_age = 5
	label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen double school = .
	replace school = 1 if EGITIM_DEVAM_K == 1
	replace school = 0 if EGITIM_DEVAM_K == 2
	replace school = . if missing(YAS) | YAS < 5
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	* Note: OKUR_YAZAR is skipped for people with completed schooling; this proposal
	*   assigns literacy=1 to completed primary or higher as the answer implied by
	*   the skip, although the GLD rule normally requires direct evidence of both
	*   reading and writing.
	* Note: The source asks the generic question 'Are you literate?' rather than
	*   naming reading and writing separately, while the GLD definition requires
	*   both abilities.
	gen byte literacy = .
	* Route 1: Literate implied by schooling
	replace literacy = 1 if literacy == . & !missing(YAS) & YAS >= 5 ///
	    & inlist(OKUL_BITEN_K, 1, 2, 31, 32, 4, 5)
	* Route 2: Reported literate
	replace literacy = 1 if literacy == . & !missing(YAS) & YAS >= 5 ///
	    & OKUL_BITEN_K == 0 & OKUR_YAZAR == 1
	* Route 3: Reported not literate
	replace literacy = 0 if literacy == . & !missing(YAS) & YAS >= 5 ///
	    & OKUL_BITEN_K == 0 & OKUR_YAZAR == 2
	replace literacy = . if !(!missing(YAS) & YAS >= 5)
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	* Not harmonized: not in the scope of the agents
	gen double educy = .
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	* Note: The survey does not distinguish 2- or 3-year higher education from
	*   faculty or 4-year higher education, so the ILO education figures cannot be
	*   replicated.
	gen byte educat7 = .
	* Route 1: Completed advanced tertiary
	replace educat7 = 7 if educat7 == . & !missing(YAS) & YAS >= 5 ///
	    & OKUL_BITEN_K == 5
	* Route 2: Completed higher education
	replace educat7 = 7 if educat7 == . & !missing(YAS) & YAS >= 5 ///
	    & OKUL_BITEN_K == 4
	* Route 3: Completed upper secondary
	replace educat7 = 5 if educat7 == . & !missing(YAS) & YAS >= 5 ///
	    & inlist(OKUL_BITEN_K, 31, 32)
	* Route 4: Completed lower secondary
	replace educat7 = 4 if educat7 == . & !missing(YAS) & YAS >= 5 ///
	    & OKUL_BITEN_K == 2
	* Route 5: Completed primary
	replace educat7 = 3 if educat7 == . & !missing(YAS) & YAS >= 5 ///
	    & OKUL_BITEN_K == 1
	* Route 6: No level literate
	replace educat7 = 2 if educat7 == . & !missing(YAS) & YAS >= 5 ///
	    & OKUL_BITEN_K == 0 & OKUR_YAZAR == 1
	* Route 7: No education
	replace educat7 = 1 if educat7 == . & !missing(YAS) & YAS >= 5 ///
	    & OKUL_BITEN_K == 0 & OKUR_YAZAR == 2
	replace educat7 = . if !(!missing(YAS) & YAS >= 5)
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
	capture confirm string variable OKUL_BITEN_K
	if _rc == 0 {
	    gen strL educat_orig = OKUL_BITEN_K if !missing(OKUL_BITEN_K)
	}
	else {
	    gen strL educat_orig = strtrim(strofreal(OKUL_BITEN_K, "%24.17g")) if ///
	        !missing(OKUL_BITEN_K)
	    assert real(educat_orig) == OKUL_BITEN_K if !missing(OKUL_BITEN_K) ///
	        & !missing(YAS) & YAS >= 5
	}
	replace educat_orig = "" if missing(YAS) | YAS < 5
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
	* Not harmonized: not in the scope of the agents
	gen double educat_isced = .
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
	* Not harmonized: not in the scope of the agents
	gen double vocational = .
	label de lblvocational 0 "No" 1 "Yes"
	label var vocational "Ever received vocational training"
	label values vocational lblvocational
*</_vocational_>


*<_vocational_type_>
	* Not harmonized: not in the scope of the agents
	gen double vocational_type = .
	label de lblvocational_type 1 "Inside Enterprise" 2 "External"
	label values vocational_type lblvocational_type
	label var vocational_type "Type of vocational training"
*</_vocational_type_>


*<_vocational_length_l_>
	* Not harmonized: not in the scope of the agents
	gen double vocational_length_l = .
	label var vocational_length_l "Length of training in months, lower limit"
*</_vocational_length_l_>


*<_vocational_length_u_>
	* Not harmonized: not in the scope of the agents
	gen double vocational_length_u = .
	label var vocational_length_u "Length of training in months, upper limit"
*</_vocational_length_u_>


*<_vocational_field_orig_>
	* Not harmonized: not in the scope of the agents
	gen strL vocational_field_orig = ""
	label var vocational_field_orig "Original field of training information"
*</_vocational_field_orig_>


*<_vocational_financed_>
	* Not harmonized: not in the scope of the agents
	gen double vocational_financed = .
	label de lblvocational_financed 1 "Employer" 2 "Government" 3 "Mixed Employer/Government" 4 "Own funds" 5 "Other"
	label var vocational_financed "How training was financed"
	label values vocational_financed lblvocational_financed
*</_vocational_financed_>

}


/*%%=============================================================================================
	8: Labour
==============================================================================================%%*/


*<_minlaborage_>
	* Note: The documented age threshold can be checked only within an assembled
	*   file whose youngest observed age is already 15; there are no below-threshold
	*   records to test erroneous labour-screen answers.
	* Note: Among persons age 15 or older, 5427 records have a missing first
	*   labour-screen response.
	gen double minlaborage = 15
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
	* Note: We use the NSO-provided DURUM variable because it replicates the
	*   official estimates and ILOSTAT estimates.
	* Note: How DURUM was constructed is unclear, and it may contradict the
	*   component variables. For example, 2,839 records with CALISMA=1, indicating
	*   work for income in the reference week, are coded as unemployed or outside
	*   the labor force in DURUM.
	* Note: The component construction and supplied DURUM differ well above the
	*   10-record review threshold: among component employment branches, 350 are
	*   supplied as unemployed and 5025 as outside the labour force, while 21
	*   supplied employed records have all three employment screens equal to no.
	* Note: The searched-and-available path has 25530 supplied unemployed and 211
	*   supplied outside the labour force; the future-starter-and-available path has
	*   406 supplied unemployed and 17 supplied outside the labour force.
	* Note: Temporary absence is classified from the positive job/business screen
	*   because the retained evidence does not document pay, expected return,
	*   duration, or job-attachment restrictions by absence reason.
	* Note: No own-use-production or market-orientation question is retained, so
	*   agriculture and own-use boundaries cannot be separately tested.
	* Note: There are 5427 age-eligible records with all labour variables, including
	*   DURUM, missing.
	gen double lstatus = .
	replace lstatus = 1 if DURUM == 1
	replace lstatus = 2 if DURUM == 2
	replace lstatus = 3 if DURUM == 3
	replace lstatus = . if missing(YAS) | YAS < 15
	replace lstatus = 3 if missing(lstatus) & age >= minlaborage & !missing(age)
	replace lstatus = . if missing(age)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	* Note: The GLD exclusive-or rule also codes searched but unavailable people as
	*   1, but IDO_NEDEN identifies only not-seeking outside-labour-force reasons;
	*   this supported recode therefore has a narrower source definition.
	gen double potential_lf = .
	replace potential_lf = 1 if IDO_NEDEN == 31 | IDO_NEDEN == 32 | IDO_NEDEN == 33
	replace potential_lf = 0 if IDO_NEDEN == 34 | IDO_NEDEN == 35 ///
	    | IDO_NEDEN == 36 | IDO_NEDEN == 37 | IDO_NEDEN == 38 | IDO_NEDEN == 39
	replace potential_lf = . if lstatus != 3
	replace potential_lf = . if age < minlaborage & !missing(age)
	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	* Note: Codes 1 and 2 of FAZLACAL_ISTEK have no value label and no cited source.
	*   The agent mapped code 1 to 1 Yes and code 2 to 0 No.
	gen double underemployment = .
	replace underemployment = 1 if FAZLACAL_ISTEK == 1
	replace underemployment = 0 if FAZLACAL_ISTEK == 2
	replace underemployment = . if lstatus != 1
	replace underemployment = . if age < minlaborage & !missing(age)
	replace underemployment = . if lstatus != 1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	* Note: The GLD availability-first rule cannot be independently reconstructed
	*   because this task states that questionnaire questions and bindings must
	*   remain empty; the proposal therefore uses the NSO-provided
	*   outside-labour-force reason classification.
	* Note: Codes 35, 34, 36, 37, 31, 32, 33, 38 and 39 of IDO_NEDEN have no value
	*   label and no cited source. The agent mapped code 35 to 1 Student, code 34 to
	*   2 Housekeeper, code 36 to 3 Retired, code 37 to 4 Disabled, code 31 to 5
	*   Other, code 32 to 5 Other, code 33 to 5 Other, code 38 to 5 Other and code
	*   39 to 5 Other.
	gen double nlfreason = .
	replace nlfreason = 1 if IDO_NEDEN == 35
	replace nlfreason = 2 if IDO_NEDEN == 34
	replace nlfreason = 3 if IDO_NEDEN == 36
	replace nlfreason = 4 if IDO_NEDEN == 37
	replace nlfreason = 5 if IDO_NEDEN == 31 | IDO_NEDEN == 32 | IDO_NEDEN == 33 ///
	    | IDO_NEDEN == 38 | IDO_NEDEN == 39
	replace nlfreason = . if lstatus != 3
	replace nlfreason = . if lstatus != 3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen double unempldur_l = ISARA_SURE if !missing(ISARA_SURE)
	replace unempldur_l = . if lstatus != 2
	replace unempldur_l = . if lstatus != 2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen double unempldur_u = ISARA_SURE if !missing(ISARA_SURE)
	replace unempldur_u = . if lstatus != 2
	replace unempldur_u = . if lstatus != 2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	* Note: Codes 1, 2, 3 and 4 of ISTEKI_DURUM_K have no value label and no cited
	*   source. The agent mapped code 1 to 1 Paid employee, code 2 to 3 Employer,
	*   code 3 to 4 Self-employed and code 4 to 2 Non-paid employee.
	gen double empstat = .
	replace empstat = 1 if ISTEKI_DURUM_K == 1
	replace empstat = 3 if ISTEKI_DURUM_K == 2
	replace empstat = 4 if ISTEKI_DURUM_K == 3
	replace empstat = 2 if ISTEKI_DURUM_K == 4
	replace empstat = . if lstatus != 1
	replace empstat = . if lstatus != 1
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	* Note: Source code 98 combines NGOs and international organizations, which map
	*   to private, with cooperatives and embassies whose mapping requires separate
	*   evidence; the GLD special-owners rule therefore prevents one supported code.
	* Note: Codes 1 and 2 of OZEL_KAMU have no value label and no cited source. The
	*   agent mapped code 1 to 2 Private, NGO and code 2 to 1 Public sector, Central
	*   Government, Army.
	gen double ocusec = .
	replace ocusec = 2 if OZEL_KAMU == 1
	replace ocusec = 1 if OZEL_KAMU == 2
	replace ocusec = . if lstatus != 1
	replace ocusec = . if lstatus != 1
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	* Note: The GLD seven-day reference-period requirement cannot be verified
	*   because the available codebook identifies the main activity and employed
	*   universe but does not print a reference period.
	capture confirm string variable NACE2_ESAS_K
	if _rc == 0 {
	    gen strL industry_orig = NACE2_ESAS_K if !missing(NACE2_ESAS_K)
	}
	else {
	    gen strL industry_orig = strtrim(strofreal(NACE2_ESAS_K, "%24.17g")) if ///
	        !missing(NACE2_ESAS_K)
	    assert real(industry_orig) == NACE2_ESAS_K if !missing(NACE2_ESAS_K) ///
	        & !missing(YAS) & YAS >= 15 & DURUM == 1
	}
	replace industry_orig = "01" if NACE2_ESAS_K == 1
	replace industry_orig = "02" if NACE2_ESAS_K == 2
	replace industry_orig = "03" if NACE2_ESAS_K == 3
	replace industry_orig = "05" if NACE2_ESAS_K == 5
	replace industry_orig = "06" if NACE2_ESAS_K == 6
	replace industry_orig = "07" if NACE2_ESAS_K == 7
	replace industry_orig = "08" if NACE2_ESAS_K == 8
	replace industry_orig = "09" if NACE2_ESAS_K == 9
	replace industry_orig = "" if missing(YAS) | YAS < 15 | DURUM != 1
	replace industry_orig = "" if lstatus != 1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	* Note: The GLD seven-day reference-period requirement cannot be verified
	*   because the available codebook identifies the main activity and employed
	*   universe but does not print a reference period.
	* First two digits of the ISIC code
	capture confirm string variable NACE2_ESAS_K
	if _rc == 0 {
	    gen strL _code = strtrim(NACE2_ESAS_K) if !missing(NACE2_ESAS_K)
	}
	else {
	    gen strL _code = strtrim(strofreal(NACE2_ESAS_K, "%24.17g")) ///
	        if !missing(NACE2_ESAS_K)
	}
	replace _code = "" if !regexm(_code, "^[0-9]+$") | strlen(_code) > 2
	replace _code = substr("00", 1, 2 - strlen(_code)) + _code if _code != ""
	gen strL industrycat_isic = substr(_code, 1, 2) + "00" if _code != ""
	replace industrycat_isic = "" if missing(YAS) | YAS < 15 | DURUM != 1
	drop _code
	replace industrycat_isic = "" if lstatus != 1
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
	* Industry group from the ISIC Rev. 4 code
	confirm string variable industrycat_isic
	gen double industrycat10 = real(substr(industrycat_isic, 1, 2)) ///
	    if regexm(industrycat_isic, "^[0-9][0-9][0-9][0-9]$")
	recode industrycat10 (1/3 = 1) (5/9 = 2) (10/33 = 3) (35/39 = 4) (41/43 = 5) ///
	    (45/47 55 56 = 6) (49/53 58/63 = 7) (64/66 68/75 77/82 = 8) (84 = 9) ///
	    (85/88 90/99 = 10) (else = .)
	replace industrycat10 = 1 if industrycat_isic == "A"
	replace industrycat10 = 2 if industrycat_isic == "B"
	replace industrycat10 = 3 if industrycat_isic == "C"
	replace industrycat10 = 4 if inlist(industrycat_isic, "D", "E")
	replace industrycat10 = 5 if industrycat_isic == "F"
	replace industrycat10 = 6 if inlist(industrycat_isic, "G", "I")
	replace industrycat10 = 7 if inlist(industrycat_isic, "H", "J")
	replace industrycat10 = 8 if inlist(industrycat_isic, "K", "L", "M", "N")
	replace industrycat10 = 9 if industrycat_isic == "O"
	replace industrycat10 = 10 ///
	    if inlist(industrycat_isic, "P", "Q", "R", "S", "T", "U")
	replace industrycat10 = . if missing(YAS) | YAS < 15 | DURUM != 1
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
	* Note: The canonical seven-day reference period cannot be verified because no
	*   questionnaire PDF is available; the retained codebook identifies only the
	*   Main job item.
	capture confirm string variable ISCO08_ESAS_K
	if _rc == 0 {
	    gen strL occup_orig = ISCO08_ESAS_K if !missing(ISCO08_ESAS_K)
	}
	else {
	    gen strL occup_orig = strtrim(strofreal(ISCO08_ESAS_K, "%24.17g")) if ///
	        !missing(ISCO08_ESAS_K)
	    assert real(occup_orig) == ISCO08_ESAS_K if !missing(ISCO08_ESAS_K) ///
	        & !missing(YAS) & YAS >= 15 & DURUM == 1
	}
	replace occup_orig = "" if missing(YAS) | YAS < 15 | DURUM != 1
	replace occup_orig = "" if lstatus != 1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	* Note: The canonical seven-day reference period cannot be verified because no
	*   questionnaire PDF is available; the retained codebook identifies only the
	*   Main job item.
	* First two digits of the ISCO code
	capture confirm string variable ISCO08_ESAS_K
	if _rc == 0 {
	    gen strL _code = strtrim(ISCO08_ESAS_K) if !missing(ISCO08_ESAS_K)
	}
	else {
	    gen strL _code = strtrim(strofreal(ISCO08_ESAS_K, "%24.17g")) ///
	        if !missing(ISCO08_ESAS_K)
	}
	replace _code = "" if !regexm(_code, "^[0-9]+$") | strlen(_code) > 2
	replace _code = substr("00", 1, 2 - strlen(_code)) + _code if _code != ""
	gen strL occup_isco = substr(_code, 1, 2) + "00" if _code != ""
	replace occup_isco = "" if missing(YAS) | YAS < 15 | DURUM != 1
	drop _code
	replace occup_isco = "" if lstatus != 1
	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	preserve 
	*drop if missing(occup_isco)
	*int_classif_universe, var(occup_isco) universe(ISCO)
	count
	*list
	*assert `r(N)' == 0
	restore

	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	* Major group from the first digit of the ISCO code
	confirm string variable occup_isco
	gen double occup = real(substr(occup_isco, 1, 1)) ///
	    if regexm(occup_isco, "^[1-9][0-9][0-9][0-9]$")
	replace occup = 10 if regexm(occup_isco, "^0[0-9][0-9][0-9]$")
	replace occup = . if missing(YAS) | YAS < 15 | DURUM != 1
	replace occup = . if lstatus != 1
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
	* Note: The GLD amount_definition rule excludes bonuses and premiums, but
	*   GELIR_GECENAY_K explicitly includes them and no separate component permits
	*   their removal.
	* Note: The GLD canonical seven-day reference family differs from the source
	*   question's last-month amount; the only available earnings source is retained
	*   without unsupported period conversion.
	* Note: Code 0 is treated as missing because the codebook uses it for a newly
	*   started job or an undeclared wage, so a genuine reported zero cannot be
	*   distinguished.
	gen double wage_no_compen = GELIR_GECENAY_K if !missing(GELIR_GECENAY_K) ///
	    & GELIR_GECENAY_K != 0
	replace wage_no_compen = . if missing(YAS) | YAS < 15 | ISTEKI_DURUM_K != 1
	replace wage_no_compen = . if lstatus != 1
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>

/* <_unitwage_note>
	Unitwage refers to the unit used to record wage_no_compen, *not* the unit of
	general wage payment. For example, PHL LFS asks about wage periodicity, then
	asks for basic daily pay. The value of that pay would be wage_no_compen,
	while unitwage is code 1 ("Daily") for all, regardless of the periodicity.
</_unitwage_note> */

	gen double unitwage = 5
	replace unitwage = . if missing(YAS) | YAS < 15 | ISTEKI_DURUM_K != 1 ///
	    | lstatus != 1
	replace unitwage = . if lstatus != 1
	replace unitwage = . if mi(wage_no_compen)
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	* Note: The source stores actual hours as text; the construction retains only
	*   values that convert losslessly to numbers and does not cap values.
	capture confirm numeric variable ESAS_FIILI
	if _rc == 0 {
	    gen double whours = ESAS_FIILI if !missing(ESAS_FIILI)
	}
	else {
	    assert !missing(real(ESAS_FIILI)) if !missing(ESAS_FIILI) & lstatus == 1
	    gen double whours = real(ESAS_FIILI) if !missing(ESAS_FIILI)
	}
	replace whours = . if lstatus != 1
	replace whours = . if lstatus != 1
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	* Not harmonized: not in the scope of the agents
	gen double wmonths = .
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
	* Not harmonized: not in the scope of the agents
	gen double wage_total = .
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	* Set to missing
	gen double contract = .
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	* Not harmonized: not in the scope of the agents
	gen double healthins = .
	label var healthins "Employment has health insurance primary job 7 day recall"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	* Not harmonized: not in the scope of the agents
	gen double socialsec = .
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec 1 "With social security" 0 "Without social security"
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	* Not harmonized: not in the scope of the agents
	gen double union = .
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	* Note: The code 1 label prints “10 or less than 10” rather than an explicit
	*   1–10 interval; the lower endpoint of 1 is implied by the question being
	*   asked to an employed person about the number employed in that firm, under
	*   the GLD rule allowing an implied minimum.
	gen double firmsize_l = .
	replace firmsize_l = 1 if CALISAN_SAYI_HH == 1
	replace firmsize_l = 11 if CALISAN_SAYI_HH == 2
	replace firmsize_l = 20 if CALISAN_SAYI_HH == 3
	replace firmsize_l = 50 if CALISAN_SAYI_HH == 4
	replace firmsize_l = 11 if CALISAN_SAYI_HH == 5
	replace firmsize_l = . if lstatus != 1
	replace firmsize_l = . if lstatus != 1
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	* Note: The GLD open-top rule requires source codes 4 (50 or more) and 5
	*   (unknown but more than 10) to have missing upper bounds because no cap is
	*   documented.
	* Note: Codes 1, 2 and 3 of CALISAN_SAYI_HH have no value label and no cited
	*   source. The agent mapped code 1 to 10, code 2 to 19 and code 3 to 49.
	gen double firmsize_u = .
	replace firmsize_u = 10 if CALISAN_SAYI_HH == 1
	replace firmsize_u = 19 if CALISAN_SAYI_HH == 2
	replace firmsize_u = 49 if CALISAN_SAYI_HH == 3
	replace firmsize_u = . if lstatus != 1
	replace firmsize_u = . if lstatus != 1
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen double empstat_2 = .
	replace empstat_2 = 1 if ISTEKI_DURUM_EKIS == 1
	replace empstat_2 = 3 if ISTEKI_DURUM_EKIS == 2
	replace empstat_2 = 4 if ISTEKI_DURUM_EKIS == 3
	replace empstat_2 = 2 if ISTEKI_DURUM_EKIS == 4
	replace empstat_2 = . if missing(YAS) | YAS < 15 | DURUM != 1 | EKIS_DURUM != 1
	replace empstat_2 = . if lstatus != 1
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	* Set to missing
	gen double ocusec_2 = .
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	* Note: The industry_orig_2 detailed-first rule cannot be met because the only
	*   secondary-job source is the four-category aggregate Agriculture, Industry,
	*   Trade, Services rather than a detailed original classification.
	capture confirm string variable NACE2_EKIS_K
	if _rc == 0 {
	    gen strL industry_orig_2 = NACE2_EKIS_K if !missing(NACE2_EKIS_K)
	}
	else {
	    gen strL industry_orig_2 = strtrim(strofreal(NACE2_EKIS_K, "%24.17g")) ///
	        if !missing(NACE2_EKIS_K)
	    assert real(industry_orig_2) == NACE2_EKIS_K if !missing(NACE2_EKIS_K) ///
	        & !missing(YAS) & YAS >= 15 & DURUM == 1 & EKIS_DURUM == 1
	}
	replace industry_orig_2 = "" if missing(YAS) | YAS < 15 | DURUM != 1 ///
	    | EKIS_DURUM != 1
	replace industry_orig_2 = "" if lstatus != 1
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	* Set to missing
	gen strL industrycat_isic_2 = ""
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	* Set to missing
	gen double industrycat10_2 = .
	label var industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
	label values industrycat10_2 lblindustrycat10
*</_industrycat10_2_>


*<_industrycat4_2_>
	* Set to missing
	gen double industrycat4_2 = .
	label var industrycat4_2 "Broad Economic Activities classification, secondary job 7 day recall"
	label values industrycat4_2 lblindustrycat4
*</_industrycat4_2_>


*<_occup_orig_2_>
	* Set to missing
	gen strL occup_orig_2 = ""
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	* Set to missing
	gen strL occup_isco_2 = ""
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_2_>
	* Set to missing
	gen double occup_2 = .
	label var occup_2 "1 digit occupational classification secondary job 7 day recall"
	label values occup_2 lbloccup
*</_occup_2_>


*<_occup_skill_2_>
	* Set to missing
	gen double occup_skill_2 = .
	la de lblskill2 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_2 lblskill2
	label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>


*<_wage_no_compen_2_>
	* Set to missing
	gen double wage_no_compen_2 = .
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	* Set to missing
	gen double unitwage_2 = .
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
	* Note: The source stores actual hours as text, and 372 of 7,725 persons with
	*   EKIS_DURUM=1 have no stored hours; the construction retains only losslessly
	*   numeric values and does not impute or cap.
	capture confirm numeric variable EKIS_FIILI
	if _rc == 0 {
	    gen double whours_2 = EKIS_FIILI if !missing(EKIS_FIILI)
	}
	else {
	    assert !missing(real(EKIS_FIILI)) if !missing(EKIS_FIILI) ///
	        & !missing(YAS) & YAS >= 15 & DURUM == 1 & EKIS_DURUM == 1
	    gen double whours_2 = real(EKIS_FIILI) if !missing(EKIS_FIILI)
	}
	replace whours_2 = . if missing(YAS) | YAS < 15 | DURUM != 1 | EKIS_DURUM != 1
	replace whours_2 = . if lstatus != 1
	label var whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>


*<_wmonths_2_>
	* Not harmonized: not in the scope of the agents
	gen double wmonths_2 = .
	label var wmonths_2 "Months of work in past 12 months secondary job 7 day recall"
*</_wmonths_2_>


*<_wage_total_2_>
	* Not harmonized: not in the scope of the agents
	gen double wage_total_2 = .
	label var wage_total_2 "Annualized total wage secondary job 7 day recall"
*</_wage_total_2_>


*<_firmsize_l_2_>
	* Not harmonized: not in the scope of the agents
	gen double firmsize_l_2 = .
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	* Not harmonized: not in the scope of the agents
	gen double firmsize_u_2 = .
	label var firmsize_u_2 "Firm size (upper bracket) secondary job 7 day recall"
*</_firmsize_u_2_>

}

*----------8.4: 7 day reference additional jobs------------------------------*

*<_t_hours_others_>
	* Not harmonized: not in the scope of the agents
	gen double t_hours_others = .
	label var t_hours_others "Annualized hours worked in all but primary and secondary jobs 7 day recall"
*</_t_hours_others_>


*<_t_wage_nocompen_others_>
	* Not harmonized: not in the scope of the agents
	gen double t_wage_nocompen_others = .
	label var t_wage_nocompen_others "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_others_>


*<_t_wage_others_>
	* Not harmonized: not in the scope of the agents
	gen double t_wage_others = .
	label var t_wage_others "Annualized wage in all but primary and secondary jobs (7-day recall)"
*</_t_wage_others_>


*----------8.5: 7 day reference total summary------------------------------*


*<_t_hours_total_>
	* Not harmonized: not in the scope of the agents
	gen double t_hours_total = .
	label var t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
	* Not harmonized: not in the scope of the agents
	gen double t_wage_nocompen_total = .
	label var t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
	* Not harmonized: not in the scope of the agents
	gen double t_wage_total = .
	label var t_wage_total "Annualized total wage for all jobs 7 day recall"
*</_t_wage_total_>


*----------8.6: 12 month reference overall------------------------------*

{

*<_lstatus_year_>
	* Not harmonized: not in the scope of the agents
	gen double lstatus_year = .
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>

*<_potential_lf_year_>
	* Not harmonized: not in the scope of the agents
	gen double potential_lf_year = .
	label var potential_lf_year "Potential labour force status"
	la de lblpotential_lf_year 0 "No" 1 "Yes"
	label values potential_lf_year lblpotential_lf_year
*</_potential_lf_year_>


*<_underemployment_year_>
	* Not harmonized: not in the scope of the agents
	gen double underemployment_year = .
	label var underemployment_year "Underemployment status"
	la de lblunderemployment_year 0 "No" 1 "Yes"
	label values underemployment_year lblunderemployment_year
*</_underemployment_year_>


*<_nlfreason_year_>
	* Not harmonized: not in the scope of the agents
	gen double nlfreason_year = .
	label var nlfreason_year "Reason not in the labor force"
	la de lblnlfreason_year 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason_year lblnlfreason_year
*</_nlfreason_year_>


*<_unempldur_l_year_>
	* Not harmonized: not in the scope of the agents
	gen double unempldur_l_year = .
	label var unempldur_l_year "Unemployment duration (months) lower bracket"
*</_unempldur_l_year_>


*<_unempldur_u_year_>
	* Not harmonized: not in the scope of the agents
	gen double unempldur_u_year = .
	label var unempldur_u_year "Unemployment duration (months) upper bracket"
*</_unempldur_u_year_>

}

*----------8.7: 12 month reference main job------------------------------*

{

*<_empstat_year_>
	* Not harmonized: not in the scope of the agents
	gen double empstat_year = .
	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>

*<_ocusec_year_>
	* Not harmonized: not in the scope of the agents
	gen double ocusec_year = .
	label var ocusec_year "Sector of activity primary job 12 month recall"
	la de lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_year lblocusec_year
*</_ocusec_year_>

*<_industry_orig_year_>
	* Not harmonized: not in the scope of the agents
	gen strL industry_orig_year = ""
	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	* Not harmonized: not in the scope of the agents
	gen strL industrycat_isic_year = ""
	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>

*<_industrycat10_year_>
	* Not harmonized: not in the scope of the agents
	gen double industrycat10_year = .
	label var industrycat10_year "1 digit industry classification, primary job 12 month recall"
	la de lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_year lblindustrycat10_year
*</_industrycat10_year_>


*<_industrycat4_year_>
	* Not harmonized: not in the scope of the agents
	gen double industrycat4_year = .
	label var industrycat4_year "Broad Economic Activities classification, primary job 12 month recall"
	la de lblindustrycat4_year 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4_year lblindustrycat4_year
*</_industrycat4_year_>


*<_occup_orig_year_>
	* Not harmonized: not in the scope of the agents
	gen strL occup_orig_year = ""
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	* Not harmonized: not in the scope of the agents
	gen strL occup_isco_year = ""
	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_year_>
	* Not harmonized: not in the scope of the agents
	gen double occup_year = .
	label var occup_year "1 digit occupational classification, primary job 12 month recall"
	la de lbloccup_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_year lbloccup_year
*</_occup_year_>


*<_occup_skill_year_>
	* Not harmonized: not in the scope of the agents
	gen double occup_skill_year = .
	la de lblskillyear 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_year lblskillyear
	label var occup_skill_year "Skill based on ISCO standard primary job 12 month recall"
*</_occup_skill_year_>


*<_wage_no_compen_year_>
	* Not harmonized: not in the scope of the agents
	gen double wage_no_compen_year = .
	label var wage_no_compen_year "Last wage payment primary job 12 month recall"
*</_wage_no_compen_year_>


*<_unitwage_year_>
	* Not harmonized: not in the scope of the agents
	gen double unitwage_year = .
	label var unitwage_year "Last wages' time unit primary job 12 month recall"
	la de lblunitwage_year 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_year lblunitwage_year
*</_unitwage_year_>


*<_whours_year_>
	* Not harmonized: not in the scope of the agents
	gen double whours_year = .
	label var whours_year "Hours of work in last week primary job 12 month recall"
*</_whours_year_>


*<_wmonths_year_>
	* Not harmonized: not in the scope of the agents
	gen double wmonths_year = .
	label var wmonths_year "Months of work in past 12 months primary job 12 month recall"
*</_wmonths_year_>


*<_wage_total_year_>
	* Not harmonized: not in the scope of the agents
	gen double wage_total_year = .
	label var wage_total_year "Annualized total wage primary job 12 month recall"
*</_wage_total_year_>


*<_contract_year_>
	* Not harmonized: not in the scope of the agents
	gen double contract_year = .
	label var contract_year "Employment has contract primary job 12 month recall"
	la de lblcontract_year 0 "Without contract" 1 "With contract"
	label values contract_year lblcontract_year
*</_contract_year_>


*<_healthins_year_>
	* Not harmonized: not in the scope of the agents
	gen double healthins_year = .
	label var healthins_year "Employment has health insurance primary job 12 month recall"
	la de lblhealthins_year 0 "Without health insurance" 1 "With health insurance"
	label values healthins_year lblhealthins_year
*</_healthins_year_>


*<_socialsec_year_>
	* Not harmonized: not in the scope of the agents
	gen double socialsec_year = .
	label var socialsec_year "Employment has social security insurance primary job 12 month recall"
	la de lblsocialsec_year 1 "With social security" 0 "Without social security"
	label values socialsec_year lblsocialsec_year
*</_socialsec_year_>


*<_union_year_>
	* Not harmonized: not in the scope of the agents
	gen double union_year = .
	label var union_year "Union membership at primary job 12 month recall"
	la de lblunion_year 0 "Not union member" 1 "Union member"
	label values union_year lblunion_year
*</_union_year_>


*<_firmsize_l_year_>
	* Not harmonized: not in the scope of the agents
	gen double firmsize_l_year = .
	label var firmsize_l_year "Firm size (lower bracket) primary job 12 month recall"
*</_firmsize_l_year_>


*<_firmsize_u_year_>
	* Not harmonized: not in the scope of the agents
	gen double firmsize_u_year = .
	label var firmsize_u_year "Firm size (upper bracket) primary job 12 month recall"
*</_firmsize_u_year_>

}


*----------8.8: 12 month reference secondary job------------------------------*

{

*<_empstat_2_year_>
	* Not harmonized: not in the scope of the agents
	gen double empstat_2_year = .
	label var empstat_2_year "Employment status during past week secondary job 12 month recall"
	label values empstat_2_year lblempstat_year
*</_empstat_2_year_>


*<_ocusec_2_year_>
	* Not harmonized: not in the scope of the agents
	gen double ocusec_2_year = .
	label var ocusec_2_year "Sector of activity secondary job 12 month recall"
	la de lblocusec_2_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_2_year lblocusec_2_year
*</_ocusec_2_year_>


*<_industry_orig_2_year_>
	* Not harmonized: not in the scope of the agents
	gen strL industry_orig_2_year = ""
	label var industry_orig_2_year "Original survey industry code, secondary job 12 month recall"
*</_industry_orig_2_year_>


*<_industrycat_isic_2_year_>
	* Not harmonized: not in the scope of the agents
	gen strL industrycat_isic_2_year = ""
	label var industrycat_isic_2_year "ISIC code of secondary job 12 month recall"
*</_industrycat_isic_2_year_>


*<_industrycat10_2_year_>
	* Not harmonized: not in the scope of the agents
	gen double industrycat10_2_year = .
	label var industrycat10_2_year "1 digit industry classification, secondary job 12 month recall"
	label values industrycat10_2_year lblindustrycat10_year
*</_industrycat10_2_year_>


*<_industrycat4_2_year_>
	* Not harmonized: not in the scope of the agents
	gen double industrycat4_2_year = .
	label var industrycat4_2_year "Broad Economic Activities classification, secondary job 12 month recall"
	label values industrycat4_2_year lblindustrycat4_year
*</_industrycat4_2_year_>


*<_occup_orig_2_year_>
	* Not harmonized: not in the scope of the agents
	gen strL occup_orig_2_year = ""
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
	* Not harmonized: not in the scope of the agents
	gen strL occup_isco_2_year = ""
	label var occup_isco_2_year "ISCO code of secondary job 12 month recall"
*</_occup_isco_2_year_>


*<_occup_2_year_>
	* Not harmonized: not in the scope of the agents
	gen double occup_2_year = .
	label var occup_2_year "1 digit occupational classification, secondary job 12 month recall"
	label values occup_2_year lbloccup_year
*</_occup_2_year_>


*<_occup_skill_2_year_>
	* Not harmonized: not in the scope of the agents
	gen double occup_skill_2_year = .
	la de lblskilly2 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_2_year lblskilly2
	label var occup_skill_2_year "Skill based on ISCO standard secondary job 12 month recall"
*</_occup_skill_2_year_>


*<_wage_no_compen_2_year_>
	* Not harmonized: not in the scope of the agents
	gen double wage_no_compen_2_year = .
	label var wage_no_compen_2_year "Last wage payment secondary job 12 month recall"
*</_wage_no_compen_2_year_>


*<_unitwage_2_year_>
	* Not harmonized: not in the scope of the agents
	gen double unitwage_2_year = .
	label var unitwage_2_year "Last wages' time unit secondary job 12 month recall"
	label values unitwage_2_year lblunitwage_year
*</_unitwage_2_year_>


*<_whours_2_year_>
	* Not harmonized: not in the scope of the agents
	gen double whours_2_year = .
	label var whours_2_year "Hours of work in last week secondary job 12 month recall"
*</_whours_2_year_>


*<_wmonths_2_year_>
	* Not harmonized: not in the scope of the agents
	gen double wmonths_2_year = .
	label var wmonths_2_year "Months of work in past 12 months secondary job 12 month recall"
*</_wmonths_2_year_>


*<_wage_total_2_year_>
	* Not harmonized: not in the scope of the agents
	gen double wage_total_2_year = .
	label var wage_total_2_year "Annualized total wage secondary job 12 month recall"
*</_wage_total_2_year_>

*<_firmsize_l_2_year_>
	* Not harmonized: not in the scope of the agents
	gen double firmsize_l_2_year = .
	label var firmsize_l_2_year "Firm size (lower bracket) secondary job 12 month recall"
*</_firmsize_l_2_year_>


*<_firmsize_u_2_year_>
	* Not harmonized: not in the scope of the agents
	gen double firmsize_u_2_year = .
	label var firmsize_u_2_year "Firm size (upper bracket) secondary job 12 month recall"
*</_firmsize_u_2_year_>

}


*----------8.9: 12 month reference additional jobs------------------------------*


*<_t_hours_others_year_>
	* Not harmonized: not in the scope of the agents
	gen double t_hours_others_year = .
	label var t_hours_others_year "Annualized hours worked in all but primary and secondary jobs 12 month recall"
*</_t_hours_others_year_>

*<_t_wage_nocompen_others_year_>
	* Not harmonized: not in the scope of the agents
	gen double t_wage_nocompen_others_year = .
	label var t_wage_nocompen_others_year "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_others_year_>

*<_t_wage_others_year_>
	* Not harmonized: not in the scope of the agents
	gen double t_wage_others_year = .
	label var t_wage_others_year "Annualized wage in all but primary and secondary jobs 12 month recall"
*</_t_wage_others_year_>


*----------8.10: 12 month total summary------------------------------*


*<_t_hours_total_year_>
	* Not harmonized: not in the scope of the agents
	gen double t_hours_total_year = .
	label var t_hours_total_year "Annualized hours worked in all jobs 12 month recall"
*</_t_hours_total_year_>


*<_t_wage_nocompen_total_year_>
	* Not harmonized: not in the scope of the agents
	gen double t_wage_nocompen_total_year = .
	label var t_wage_nocompen_total_year "Annualized wage in all jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_total_year_>


*<_t_wage_total_year_>
	* Not harmonized: not in the scope of the agents
	gen double t_wage_total_year = .
	label var t_wage_total_year "Annualized total wage for all jobs 12 month recall"
*</_t_wage_total_year_>


*----------8.11: Overall across reference periods------------------------------*


*<_njobs_>
	* Not harmonized: not in the scope of the agents
	gen double njobs = .
	label var njobs "Total number of jobs"
*</_njobs_>


*<_t_hours_annual_>
	* Not harmonized: not in the scope of the agents
	gen double t_hours_annual = .
	label var t_hours_annual "Total hours worked in all jobs in the previous 12 months"
*</_t_hours_annual_>


*<_linc_nc_>
	* Not harmonized: not in the scope of the agents
	gen double linc_nc = .
	label var linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."
*</_linc_nc_>


*<_laborincome_>
	* Not harmonized: not in the scope of the agents
	gen double laborincome = .
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

* GLD_EXPORT_FINAL_KEEP
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


* GLD_EXPORT_FINAL_SAVE
save "`path_output'/`out_file'", replace

*</_% SAVE_>
