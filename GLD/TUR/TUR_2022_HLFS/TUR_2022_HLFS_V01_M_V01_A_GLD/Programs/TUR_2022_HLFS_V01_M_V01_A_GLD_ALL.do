
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				TUR_2022_HLFS_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata 19 <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2026-11-23 </_Date created_>

-------------------------------------------------------------------------

<_Country_>					TUR </_Country_>
<_Survey Title_>				HLFS </_Survey Title_>
<_Survey Year_>					2022 </_Survey Year_>
<_Study ID_>					Not filled in </_Study ID_>
<_Data collection from_>		01/2022 </_Data collection from_>
<_Data collection to_>			12/2022 </_Data collection to_>
<_Source of dataset_> 			Turkish Statistical Institute (TurkStat) </_Source of dataset_>
<_Sample size (HH)_> 			203667 </_Sample size (HH)_>
<_Sample size (IND)_> 			628936 </_Sample size (IND)_>
<_Sampling method_> 			Two-stage stratified cluster sampling </_Sampling method_>
<_Geographic coverage_> 		National </_Geographic coverage_>
<_Currency_> 					Turkish lira (TL, ₺) </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS-19 </_ICLS Version_>
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
local year    "2022"
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

* Load the master dataset, mikro_veri_2022.dta.
use "`path_in_stata'/mikro_veri_2022.dta", clear

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
	gen strL icls_v = "ICLS-19"
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
	gen double year = 2022
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
	gen double int_year = 2022
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
	* Note: The source weight is stored as str20 although the document defines it as
	*   numeric; the construction assumes its nonblank strings are losslessly
	*   numeric before the documented multiplication.
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
	* Fill missing subnatid1 from the household (BIRIMNO)
	gen long _hh_row = _n
	bysort BIRIMNO subnatid1: gen byte _hh_first = _n == 1 & !missing(subnatid1) ///
	    & !missing(BIRIMNO)
	bysort BIRIMNO: egen _hh_values = total(_hh_first)
	bysort BIRIMNO (subnatid1): replace subnatid1 = subnatid1[_N] if ///
	    missing(subnatid1) & _hh_values == 1 & !missing(BIRIMNO)
	sort _hh_row
	drop _hh_row _hh_first _hh_values
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
	* Note: The source records completed age as whole years, which does not meet the
	*   GLD young_child_precision rule requiring decimal years from completed months
	*   for children younger than five; YAS is nevertheless the only direct age
	*   source selected under the best-source rule.
	gen double age = YAS if !missing(YAS)
	label var age "Individual age"
*</_age_>


*<_male_>
	gen double male = .
	replace male = 1 if CINSIYET == 1
	replace male = 0 if CINSIYET == 2
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
	    | YAKINLIK == 8 | YAKINLIK == 9 | YAKINLIK == 98
	replace relationharm = 6 if YAKINLIK == 982
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
	replace marital = . if missing(YAS) | YAS < 15
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
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen double migrated_years = .
	replace migrated_years = REFERANS_YIL - BUIL_YIL if ///
	    migrated_binary == 1 & ONCEKI_IKAMET == 1
	replace migrated_years = REFERANS_YIL - TR_YIL if ///
	    migrated_binary == 1 & ONCEKI_IKAMET == 2
	label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen double migrated_from_urban = .
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

	gen double ed_mod_age = 5
	label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen double school = .
	replace school = 1 if EGITIM_DEVAM == 1
	replace school = 0 if EGITIM_DEVAM == 2
	replace school = . if missing(YAS) | YAS < 5 | YAS > 74
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	* Note: The questionnaire skips OKUR_YAZAR for people with any completed school
	*   level; this proposal assigns that skipped group literacy=1 as an implied
	*   answer, although the GLD rule normally requires direct evidence that the
	*   person can both read and write.
	* Note: The GLD read-and-write rule requires evidence for both abilities, while
	*   the source asks the combined concept 'Are you literate?' and only
	*   parenthetically mentions people who can read and write in other languages;
	*   this proposal treats that direct question as the survey's combined measure.
	gen byte literacy = .
	* Route 1: Completed school implies literate
	replace literacy = 1 if literacy == . ///
	    & inlist(OKUL_BITEN_K, 2, 3, 41, 42, 511, 512, 52)
	* Route 2: Literate answer
	replace literacy = 1 if literacy == . & OKUL_BITEN_K == 1 & OKUR_YAZAR == 1
	* Route 3: Not literate answer
	replace literacy = 0 if literacy == . & OKUL_BITEN_K == 1 & OKUR_YAZAR == 2
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
	* Note: The GLD attainment ladder requires a defensible primary-incomplete
	*   distinction; following the requested 2023 and 2024 logic, literacy splits
	*   people with no completed school and may classify self-taught literate people
	*   as primary incomplete.
	gen byte educat7 = .
	* Route 1: Higher education or university
	replace educat7 = 7 if educat7 == . & inlist(OKUL_BITEN_K, 511, 512, 52)
	* Route 2: Completed upper secondary
	replace educat7 = 5 if educat7 == . & inlist(OKUL_BITEN_K, 41, 42)
	* Route 3: Completed lower secondary
	replace educat7 = 4 if educat7 == . & OKUL_BITEN_K == 3
	* Route 4: Completed primary
	replace educat7 = 3 if educat7 == . & OKUL_BITEN_K == 2
	* Route 5: No school but literate
	replace educat7 = 2 if educat7 == . & OKUL_BITEN_K == 1 & OKUR_YAZAR == 1
	* Route 6: No school not literate
	replace educat7 = 1 if educat7 == . & OKUL_BITEN_K == 1 & OKUR_YAZAR == 2
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
	gen double minlaborage = 15
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
	* Note: The GLD component-first rule cannot be applied fully because the
	*   questionnaire says additional questions can overturn affirmative work
	*   screens but does not retain or print those production and job-attachment
	*   questions; the documented official DURUM classification is therefore used as
	*   fallback.
	gen byte lstatus = .
	* Employed, official fallback
	replace lstatus = 1 if DURUM == 1
	* Unemployed, official fallback
	replace lstatus = 2 if missing(lstatus) & DURUM == 2
	* Outside labor force, fallback
	replace lstatus = 3 if missing(lstatus) & DURUM == 3
	replace lstatus = . if missing(YAS) | YAS < 15
	replace lstatus = 3 if missing(lstatus) & age >= minlaborage & !missing(age)
	replace lstatus = . if missing(age)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	* Note: The GLD definition uses a 7-day availability reference period, but page
	*   10 does not print the availability reference period behind IDO_NEDEN.
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
	* Note: The GLD rule seeks the binding reason outside the labour force, but the
	*   NSO source combines direct activity reasons with potential labour force
	*   categories 31 to 33; those categories and residual codes 38 to 39 are mapped
	*   to Other because no closer canonical category exists.
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
	gen double unempldur_l = ///
	    (cond(!missing(ISARA_SURE), ISARA_SURE, 0) + ///
	    cond(!missing(BULUNAN_IS_SURE), BULUNAN_IS_SURE, 0)) if ///
	    !missing(ISARA_SURE) | !missing(BULUNAN_IS_SURE)
	replace unempldur_l = . if lstatus != 2
	replace unempldur_l = . if lstatus != 2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen double unempldur_u = ///
	    (cond(!missing(ISARA_SURE), ISARA_SURE, 0) + ///
	    cond(!missing(BULUNAN_IS_SURE), BULUNAN_IS_SURE, 0)) if ///
	    !missing(ISARA_SURE) | !missing(BULUNAN_IS_SURE)
	replace unempldur_u = . if lstatus != 2
	replace unempldur_u = . if lstatus != 2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen double empstat = .
	replace empstat = 1 if ISTEKI_DURUM_K == 11 | ISTEKI_DURUM_K == 12
	replace empstat = 2 if ISTEKI_DURUM_K == 4
	replace empstat = 3 if ISTEKI_DURUM_K == 2
	replace empstat = 4 if ISTEKI_DURUM_K == 3
	replace empstat = . if lstatus != 1
	replace empstat = . if lstatus != 1
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen double ocusec = .
	replace ocusec = 1 if OZEL_KAMU == 1
	replace ocusec = 2 if OZEL_KAMU == 2
	replace ocusec = . if lstatus != 1
	replace ocusec = . if lstatus != 1
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	* Note: The GLD definition specifies a primary-job seven-day reference period,
	*   but the cited NACE2_ESAS_K item prints no recall period.
	capture confirm string variable NACE2_ESAS_K
	if _rc == 0 {
	    gen strL industry_orig = NACE2_ESAS_K if !missing(NACE2_ESAS_K)
	}
	else {
	    gen strL industry_orig = strtrim(strofreal(NACE2_ESAS_K, "%24.17g")) if ///
	        !missing(NACE2_ESAS_K)
	    assert real(industry_orig) == NACE2_ESAS_K if !missing(NACE2_ESAS_K) ///
	        & lstatus == 1
	}
	replace industry_orig = "01" if NACE2_ESAS_K == 1
	replace industry_orig = "02" if NACE2_ESAS_K == 2
	replace industry_orig = "03" if NACE2_ESAS_K == 3
	replace industry_orig = "05" if NACE2_ESAS_K == 5
	replace industry_orig = "06" if NACE2_ESAS_K == 6
	replace industry_orig = "07" if NACE2_ESAS_K == 7
	replace industry_orig = "08" if NACE2_ESAS_K == 8
	replace industry_orig = "09" if NACE2_ESAS_K == 9
	replace industry_orig = "10" if NACE2_ESAS_K == 10
	replace industry_orig = "11" if NACE2_ESAS_K == 11
	replace industry_orig = "12" if NACE2_ESAS_K == 12
	replace industry_orig = "13" if NACE2_ESAS_K == 13
	replace industry_orig = "14" if NACE2_ESAS_K == 14
	replace industry_orig = "15" if NACE2_ESAS_K == 15
	replace industry_orig = "16" if NACE2_ESAS_K == 16
	replace industry_orig = "17" if NACE2_ESAS_K == 17
	replace industry_orig = "18" if NACE2_ESAS_K == 18
	replace industry_orig = "19" if NACE2_ESAS_K == 19
	replace industry_orig = "20" if NACE2_ESAS_K == 20
	replace industry_orig = "21" if NACE2_ESAS_K == 21
	replace industry_orig = "22" if NACE2_ESAS_K == 22
	replace industry_orig = "23" if NACE2_ESAS_K == 23
	replace industry_orig = "24" if NACE2_ESAS_K == 24
	replace industry_orig = "25" if NACE2_ESAS_K == 25
	replace industry_orig = "26" if NACE2_ESAS_K == 26
	replace industry_orig = "27" if NACE2_ESAS_K == 27
	replace industry_orig = "28" if NACE2_ESAS_K == 28
	replace industry_orig = "29" if NACE2_ESAS_K == 29
	replace industry_orig = "30" if NACE2_ESAS_K == 30
	replace industry_orig = "31" if NACE2_ESAS_K == 31
	replace industry_orig = "32" if NACE2_ESAS_K == 32
	replace industry_orig = "33" if NACE2_ESAS_K == 33
	replace industry_orig = "35" if NACE2_ESAS_K == 35
	replace industry_orig = "36" if NACE2_ESAS_K == 36
	replace industry_orig = "37" if NACE2_ESAS_K == 37
	replace industry_orig = "38" if NACE2_ESAS_K == 38
	replace industry_orig = "39" if NACE2_ESAS_K == 39
	replace industry_orig = "41" if NACE2_ESAS_K == 41
	replace industry_orig = "42" if NACE2_ESAS_K == 42
	replace industry_orig = "43" if NACE2_ESAS_K == 43
	replace industry_orig = "45" if NACE2_ESAS_K == 45
	replace industry_orig = "46" if NACE2_ESAS_K == 46
	replace industry_orig = "47" if NACE2_ESAS_K == 47
	replace industry_orig = "49" if NACE2_ESAS_K == 49
	replace industry_orig = "50" if NACE2_ESAS_K == 50
	replace industry_orig = "51" if NACE2_ESAS_K == 51
	replace industry_orig = "52" if NACE2_ESAS_K == 52
	replace industry_orig = "53" if NACE2_ESAS_K == 53
	replace industry_orig = "55" if NACE2_ESAS_K == 55
	replace industry_orig = "56" if NACE2_ESAS_K == 56
	replace industry_orig = "58" if NACE2_ESAS_K == 58
	replace industry_orig = "59" if NACE2_ESAS_K == 59
	replace industry_orig = "60" if NACE2_ESAS_K == 60
	replace industry_orig = "61" if NACE2_ESAS_K == 61
	replace industry_orig = "62" if NACE2_ESAS_K == 62
	replace industry_orig = "63" if NACE2_ESAS_K == 63
	replace industry_orig = "64" if NACE2_ESAS_K == 64
	replace industry_orig = "65" if NACE2_ESAS_K == 65
	replace industry_orig = "66" if NACE2_ESAS_K == 66
	replace industry_orig = "68" if NACE2_ESAS_K == 68
	replace industry_orig = "69" if NACE2_ESAS_K == 69
	replace industry_orig = "70" if NACE2_ESAS_K == 70
	replace industry_orig = "71" if NACE2_ESAS_K == 71
	replace industry_orig = "72" if NACE2_ESAS_K == 72
	replace industry_orig = "73" if NACE2_ESAS_K == 73
	replace industry_orig = "74" if NACE2_ESAS_K == 74
	replace industry_orig = "75" if NACE2_ESAS_K == 75
	replace industry_orig = "77" if NACE2_ESAS_K == 77
	replace industry_orig = "78" if NACE2_ESAS_K == 78
	replace industry_orig = "79" if NACE2_ESAS_K == 79
	replace industry_orig = "80" if NACE2_ESAS_K == 80
	replace industry_orig = "81" if NACE2_ESAS_K == 81
	replace industry_orig = "82" if NACE2_ESAS_K == 82
	replace industry_orig = "84" if NACE2_ESAS_K == 84
	replace industry_orig = "85" if NACE2_ESAS_K == 85
	replace industry_orig = "86" if NACE2_ESAS_K == 86
	replace industry_orig = "87" if NACE2_ESAS_K == 87
	replace industry_orig = "88" if NACE2_ESAS_K == 88
	replace industry_orig = "90" if NACE2_ESAS_K == 90
	replace industry_orig = "91" if NACE2_ESAS_K == 91
	replace industry_orig = "92" if NACE2_ESAS_K == 92
	replace industry_orig = "93" if NACE2_ESAS_K == 93
	replace industry_orig = "94" if NACE2_ESAS_K == 94
	replace industry_orig = "95" if NACE2_ESAS_K == 95
	replace industry_orig = "96" if NACE2_ESAS_K == 96
	replace industry_orig = "97" if NACE2_ESAS_K == 97
	replace industry_orig = "99" if NACE2_ESAS_K == 99
	replace industry_orig = "" if lstatus != 1
	replace industry_orig = "" if lstatus != 1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
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
	replace industrycat_isic = "" if lstatus != 1
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
	replace industrycat10 = . if lstatus != 1
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
	* Note: The GLD definition requires a 7-day reference period, but the retained
	*   questionnaire wording for ISCO08_ESAS_K prints no recall period.
	capture confirm string variable ISCO08_ESAS_K
	if _rc == 0 {
	    gen strL occup_orig = ISCO08_ESAS_K if !missing(ISCO08_ESAS_K)
	}
	else {
	    gen strL occup_orig = strtrim(strofreal(ISCO08_ESAS_K, "%24.17g")) if ///
	        !missing(ISCO08_ESAS_K)
	    assert real(occup_orig) == ISCO08_ESAS_K if !missing(ISCO08_ESAS_K) ///
	        & lstatus == 1 & DURUM == 1
	}
	replace occup_orig = "" if lstatus != 1 | DURUM != 1
	replace occup_orig = "" if lstatus != 1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	* Note: The GLD rule calls for the primary job in the seven-day reference
	*   period, but the printed occupation item gives no explicit recall period.
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
	replace occup_isco = "" if lstatus != 1
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
	replace occup = . if lstatus != 1
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
	* Note: The GLD definition names a seven-day reference family and excludes
	*   bonuses and other compensation, but the only amount source is total main-job
	*   earnings during the last month and does not document excluded components.
	* Note: The GLD construction allows documented net self-employment revenue or
	*   salary drawn from the business, but the income question applies only to
	*   paid, salaried, and casual employees, so employment-status codes 2 and 3
	*   remain missing.
	gen double wage_no_compen = GELIR_GECENAY_K if !missing(GELIR_GECENAY_K)
	replace wage_no_compen = . if lstatus != 1
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
	replace unitwage = . if lstatus != 1
	replace unitwage = . if lstatus != 1
	replace unitwage = . if mi(wage_no_compen)
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	* Note: The GLD guidance says to assess zero hours using temporary-absence
	*   routing, but the questionnaire does not ask ESAS_FIILI to most job-holders
	*   absent during the reference week.
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
	* Note: The GLD rule requires the primary-job seven-day reference family, but
	*   CALISAN_SAYI_HH prints no reference period.
	gen double firmsize_l = .
	replace firmsize_l = 1 if CALISAN_SAYI_HH == 1
	replace firmsize_l = 10 if CALISAN_SAYI_HH == 2
	replace firmsize_l = 20 if CALISAN_SAYI_HH == 3
	replace firmsize_l = 50 if CALISAN_SAYI_HH == 4
	replace firmsize_l = 250 if CALISAN_SAYI_HH == 5
	replace firmsize_l = 10 if CALISAN_SAYI_HH == 6
	replace firmsize_l = . if lstatus != 1
	replace firmsize_l = . if lstatus != 1
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	* Note: Codes 5, '250 or more', and 6, 'Don't know but 10 or more', have no
	*   documented upper endpoint, so firmsize_u remains missing for them under the
	*   GLD open-interval rule.
	* Note: The GLD definition requires the primary job in the seven-day reference
	*   family, but this workplace local-unit question does not itself print the
	*   primary-job or seven-day reference period; it is retained as the only
	*   firm-size source.
	gen double firmsize_u = .
	replace firmsize_u = 9 if CALISAN_SAYI_HH == 1
	replace firmsize_u = 19 if CALISAN_SAYI_HH == 2
	replace firmsize_u = 49 if CALISAN_SAYI_HH == 3
	replace firmsize_u = 249 if CALISAN_SAYI_HH == 4
	replace firmsize_u = . if lstatus != 1
	replace firmsize_u = . if lstatus != 1
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	* Note: The GLD definition requires a seven-day reference period, but the
	*   secondary-job status question does not print a recall period; it appears in
	*   the reference-week employment module.
	gen double empstat_2 = .
	replace empstat_2 = 1 if ISTEKI_DURUM_EKIS == 1
	replace empstat_2 = 3 if ISTEKI_DURUM_EKIS == 2
	replace empstat_2 = 4 if ISTEKI_DURUM_EKIS == 3
	replace empstat_2 = 2 if ISTEKI_DURUM_EKIS == 4
	replace empstat_2 = . if lstatus != 1 | !inlist(IS_SAYI, 2, 3)
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
	* Note: The GLD detailed-first rule calls for the most detailed original
	*   secondary-job industry code, but NACE2_EKIS_K contains only four broad
	*   activity groups.
	capture confirm string variable NACE2_EKIS_K
	if _rc == 0 {
	    gen strL industry_orig_2 = NACE2_EKIS_K if !missing(NACE2_EKIS_K)
	}
	else {
	    gen strL industry_orig_2 = strtrim(strofreal(NACE2_EKIS_K, "%24.17g")) ///
	        if !missing(NACE2_EKIS_K)
	    assert real(industry_orig_2) == NACE2_EKIS_K if !missing(NACE2_EKIS_K) ///
	        & DURUM == 1 & inlist(IS_SAYI, 2, 3)
	}
	replace industry_orig_2 = "" if DURUM != 1 | !inlist(IS_SAYI, 2, 3)
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
	capture confirm numeric variable EKIS_FIILI
	if _rc == 0 {
	    gen double whours_2 = EKIS_FIILI if !missing(EKIS_FIILI)
	}
	else {
	    assert !missing(real(EKIS_FIILI)) if !missing(EKIS_FIILI) & lstatus == 1 ///
	        & inlist(IS_SAYI, 2, 3)
	    gen double whours_2 = real(EKIS_FIILI) if !missing(EKIS_FIILI)
	}
	replace whours_2 = . if lstatus != 1 | !inlist(IS_SAYI, 2, 3)
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

* GLD_EXPORT_OUTPUT_SETUP_BEGIN
capture mkdir "C:/Users/wb510859/WBG/GLD - Current Contributors/999999_ZW/TUR/TUR_2022_HLFS/TUR_2022_HLFS_V01_M_V01_A_GLD"
capture mkdir "C:/Users/wb510859/WBG/GLD - Current Contributors/999999_ZW/TUR/TUR_2022_HLFS/TUR_2022_HLFS_V01_M_V01_A_GLD/Data"
capture mkdir "C:/Users/wb510859/WBG/GLD - Current Contributors/999999_ZW/TUR/TUR_2022_HLFS/TUR_2022_HLFS_V01_M_V01_A_GLD/Data/Harmonized"
* GLD_EXPORT_OUTPUT_SETUP_END

* GLD_EXPORT_FINAL_SAVE
save "`path_output'/`out_file'", replace

*</_% SAVE_>
