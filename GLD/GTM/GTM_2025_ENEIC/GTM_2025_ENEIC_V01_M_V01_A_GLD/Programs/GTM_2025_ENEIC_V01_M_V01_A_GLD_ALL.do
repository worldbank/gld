
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				GTM_2025_ENEIC_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2026-11-03 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						GTM </_Country_>
<_Survey Title_>				ENEIC </_Survey Title_>
<_Survey Year_>					2025 </_Survey Year_>
<_Study ID_>					Not filled in </_Study ID_>
<_Data collection from_>		Not filled in </_Data collection from_>
<_Data collection to_>			Not filled in </_Data collection to_>
<_Source of dataset_> 			Not filled in </_Source of dataset_>
<_Sample size (HH)_> 			Not filled in </_Sample size (HH)_>
<_Sample size (IND)_> 			Not filled in </_Sample size (IND)_>
<_Sampling method_> 			Not filled in </_Sampling method_>
<_Geographic coverage_> 		Not filled in </_Geographic coverage_>
<_Currency_> 					Not filled in </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS-13 </_ICLS Version_>
<_ISCED Version_>				Not filled in </_ISCED Version_>
<_ISCO Version_>				ISCO-2008 </_ISCO Version_>
<_OCCUP National_>				Maps ISCO-2008 </_OCCUP National_>
<_ISIC Version_>				ISIC-4 </_ISIC Version_>
<_INDUS National_>				Maps ISIC-4 </_INDUS National_>

-----------------------------------------------------------------------

<_Version Control_>

* Date: [YYYY-MM-DD] - [Details]

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
local server  "C:/Users/`c(username)'/WBG/GLD - Focal Point/Countries"
local country "GTM"
local year    "2025"
local survey  "ENEIC"
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

local households1 "Hogares_ENEIC_T1-2025.dta"
local households2 "Hogares ENEIC T2-2025.dta"
local households3 "Base de datos Hogares ENEIC III 2025.dta"
local households4 "Base de datos Hogares ENEIC IV 2025.dta"
local persons1 "Personas_ENEIC_T1_2025.dta"
local persons2 "Personas ENEIC T2-2025.dta"
local persons3 "Base de datos Personas ENEIC III 2025.dta"
local persons4 "Base de datos Personas ENEIC IV 2025.dta"

tempfile quarter1 quarter2 quarter3 quarter4 person_input
local expected_rows = 0

forvalues quarter = 1/4 {
    display "GLD_STEP `quarter' BEGIN"
    use "`path_in_stata'/`persons`quarter''", clear
    isid ANIO TRIMESTRE NUM_HOGAR NUM_PERSONA
    assert ANIO == 2025
    local person_rows = _N
    local expected_rows = `expected_rows' + `person_rows'
    quietly label dir
    local original_labels `r(names)'
    local label_number = 0
    foreach variable of varlist _all {
        local source_label : value label `variable'
        if "`source_label'" != "" {
            local label_number = `label_number' + 1
            label copy `source_label' p`quarter'_`label_number'
            label values `variable' p`quarter'_`label_number'
        }
    }
    if "`original_labels'" != "" {
        label drop `original_labels'
    }
    save "`person_input'", replace

    use "`path_in_stata'/`households`quarter''", clear
    isid ANIO TRIMESTRE NUM_HOGAR
    assert ANIO == 2025
    display "GLD_STEP `quarter' HOUSEHOLDS " string(_N, "%20.0f")
    display "GLD_STEP `quarter' PERSONS " string(`person_rows', "%20.0f")
    quietly label dir
    local original_labels `r(names)'
    local label_number = 0
    foreach variable of varlist _all {
        local source_label : value label `variable'
        if "`source_label'" != "" {
            local label_number = `label_number' + 1
            label copy `source_label' h`quarter'_`label_number'
            label values `variable' h`quarter'_`label_number'
        }
    }
    if "`original_labels'" != "" {
        label drop `original_labels'
    }
    foreach shared in DOMINIO FACTOR P00A10 {
        rename `shared' _hh_`shared'
    }

    merge 1:m ANIO TRIMESTRE NUM_HOGAR using "`person_input'"
    forvalues outcome = 1/3 {
        quietly count if _merge == `outcome'
        display "GLD_STEP `quarter' MERGE`outcome' " string(r(N), "%20.0f")
    }
    display "GLD_STEP `quarter' ROWS " string(_N, "%20.0f")
    assert _merge == 3
    foreach shared in DOMINIO FACTOR P00A10 {
        assert `shared' == _hh_`shared'
        drop _hh_`shared'
    }
    drop _merge
    assert _N == `person_rows'
    isid ANIO TRIMESTRE NUM_HOGAR NUM_PERSONA
    generate byte assembly_quarter = `quarter'
    label variable assembly_quarter "Source-file quarter in 2025 (1-4); raw TRIMESTRE unchanged"
    save "`quarter`quarter''", replace
    display "GLD_STEP `quarter' KEPT " string(_N, "%20.0f")
}

use "`quarter1'", clear
forvalues quarter = 2/4 {
    local step = `quarter' + 3
    display "GLD_STEP `step' BEGIN"
    local previous_rows = _N
    append using "`quarter`quarter''"
    display "GLD_STEP `step' APPEND " string(_N - `previous_rows', "%20.0f")
    display "GLD_STEP `step' ROWS " string(_N, "%20.0f")
}

/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen strL countrycode = "GTM"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen strL survname = "ENEIC"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "LFS"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	gen strL icls_v = "ICLS-13"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
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
	gen int year = 2025
	label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen strL vermast = "`vermast'"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen strL veralt = "`vermast'"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen strL harmonization = "GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	* Note: The GLD earliest-interview requirement is not directly established: ANIO
	*   is documented only as Año, while the questionnaire records visit dates in
	*   P00D01 and those date components are absent from the assembled data.
	gen double int_year = ANIO if !missing(ANIO)
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen double int_month = .
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
/* <_hhid_note>

	Surveyis a rotating panel, hence hhid repeats and pid requires quarter to be unique
	
</_hhid_note> */
	quietly summarize NUM_HOGAR
	local w = strlen(string(r(max), "%12.0f"))
	gen str`w' hhid = string(NUM_HOGAR, "%0`w'.0f") if !missing(NUM_HOGAR)
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	quietly summarize NUM_PERSONA
	local w = strlen(string(r(max), "%12.0f"))
	gen str`w' pid = string(NUM_PERSONA, "%0`w'.0f") if !missing(NUM_PERSONA)
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
	quietly count
	local n = r(N)
	bysort assembly_quarter: gen double _share = _N / `n'
	gen double weight = FACTOR * _share
	drop _share
	label var weight "Survey sampling weight"
*</_weight_>


*<_weight_m_>
	gen double weight_m = .
	label var weight_m "Survey sampling weight to obtain national estimates for each month"
*</_weight_m_>


*<_weight_q_>
	gen double weight_q = FACTOR
	label var weight_q "Survey sampling weight to obtain national estimates for each quarter"
*</_weight_q_>


*<_psu_>
	gen psu = .
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = .
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	gen strata = .
	label var strata "Strata"
*</_strata_>


*<_wave_>
	* Note: Codes 1, 2, 3 and 4 of assembly_quarter have no value label and no cited
	*   source. The agent mapped code 1 to Q1, code 2 to Q2, code 3 to Q3 and code 4
	*   to Q4.
	gen strL wave = ""
	replace wave = "Q1" if assembly_quarter == 1
	replace wave = "Q2" if assembly_quarter == 2
	replace wave = "Q3" if assembly_quarter == 3
	replace wave = "Q4" if assembly_quarter == 4
	label var wave "Survey wave"
*</_wave_>


*<_panel_>
	gen panel = .
	label var panel "Panel individual belongs to"
*</_panel_>


*<_visit_no_>
	gen double visit_no = .
	label var visit_no "Visit number in panel"
*</_visit_no_>

}


/*%%=============================================================================================
	3: Geography
==============================================================================================%%*/

{

*<_urban_>
	gen double urban = .
	replace urban = 1 if P00A10 == 1
	replace urban = 0 if P00A10 == 2
	clonevar urban_source_dominio = DOMINIO
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
	* Information about district is not given - dominio is only thing we have
	gen strL subnatid1 = ""
	replace subnatid1 = "1 - Urbano Metropolitano" if DOMINIO == 1
	replace subnatid1 = "2. Resto Urbano"          if DOMINIO == 2
	replace subnatid1 = "3. Rural Nacional"        if DOMINIO == 3
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	gen strL subnatid2 = ""
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	gen strL subnatid3 = ""
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
	gen strL subnatidsurvey = subnatid1
	label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>


*<_subnatid1_prev_>
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
	gen double gaul_adm1_code = .
	label var gaul_adm1_code "Global Administrative Unit Layers (GAUL) Admin 1 code"
*</_gaul_adm1_code_>


*<_gaul_adm2_code_>
	gen double gaul_adm2_code = .
	label var gaul_adm2_code "Global Administrative Unit Layers (GAUL) Admin 2 code"
*</_gaul_adm2_code_>


*<_gaul_adm3_code_>
	gen double gaul_adm3_code = .
	label var gaul_adm3_code "Global Administrative Unit Layers (GAUL) Admin 3 code"
*</_gaul_adm3_code_>

}


/*%%=============================================================================================
	4: Demography
==============================================================================================%%*/

{

*<_hsize_>
	gen long _hh_row = _n
	bysort hhid wave: gen double hsize = _N if !missing(hhid)
	sort _hh_row
	drop _hh_row
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	* Note: The source does not meet the GLD young_child_precision rule because
	*   everyone under age one is stored as 0 completed years rather than completed
	*   months as a decimal fraction.
	* Note: The source does not provide exact age for people aged 97 or older
	*   because the questionnaire top-codes all such ages at 97.
	gen double age = P02A03 if !missing(P02A03)
	label var age "Individual age"
*</_age_>


*<_male_>
	gen double male = .
	replace male = 1 if P02A02 == 1
	replace male = 0 if P02A02 == 2
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen double relationharm = .
	replace relationharm = 1 if P02A07 == 1
	replace relationharm = 2 if P02A07 == 2
	replace relationharm = 3 if P02A07 == 3 | P02A07 == 4
	replace relationharm = 4 if P02A07 == 7
	replace relationharm = 5 if P02A07 == 5 | P02A07 == 6 | P02A07 == 8 ///
	    | P02A07 == 9 | P02A07 == 10 | P02A07 == 11
	replace relationharm = 6 if P02A07 == 12 | P02A07 == 13 | P02A07 == 14
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
	gen double relationcs = P02A07 if !missing(P02A07)
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	* Note: P02A12 code 8 records “under 12 years” rather than a documented marital
	*   status; mapping it to GLD never married departs from the rule to map
	*   categories by documented marital meaning, and 624 code-8 records have
	*   reported age 12 or older.
	gen double marital = .
	replace marital = 3 if P02A12 == 1
	replace marital = 1 if P02A12 == 2
	replace marital = 4 if P02A12 == 3 | P02A12 == 4 | P02A12 == 5
	replace marital = 5 if P02A12 == 6
	replace marital = 2 if P02A12 == 7 | P02A12 == 8
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	gen int eye_dsablty = P02A11A if inrange(P02A11A, 1, 4)
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
	label values eye_dsablty dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen int hear_dsablty = P02A11B if inrange(P02A11B, 1, 4)
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values hear_dsablty dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen int walk_dsablty = P02A11C if inrange(P02A11C, 1, 4)
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values walk_dsablty dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen int conc_dsord = P02A11D if inrange(P02A11D, 1, 4)
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values conc_dsord dsablty
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen int slfcre_dsablty = P02A11E if inrange(P02A11E, 1, 4)
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values slfcre_dsablty dsablty
	label var slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen int comm_dsablty = P02A11F if inrange(P02A11F, 1, 4)
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
	gen double migrated_mod_age = .
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen double migrated_ref_time = .
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen double migrated_binary = .
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen double migrated_years = .
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

	gen double ed_mod_age = 7
	label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	* Note: The GLD current_attendance rule calls for current attendance, but P03A02
	*   measures enrollment in an educational establishment for the current school
	*   year rather than attendance.
	gen double school = .
	replace school = 1 if P03A02 == 1
	replace school = 0 if P03A02 == 2
	replace school = . if !(!missing(age) & age >= 7)
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen double literacy = .
	replace literacy = 1 if P03A01 == 1
	replace literacy = 0 if P03A01 == 2
	replace literacy = . if !(!missing(age) & age >= 7)
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen double educy = .
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7 = .
	* Route 1: No education
	replace educat7 = 1 if educat7 == . & !missing(P03A03A) & P03A03A < 2
	* Route 2: Primary incomplete
	replace educat7 = 2 if educat7 == . & P03A03A == 2 ///
	    & inlist(P03A03B, 1, 2, 3, 4, 5)
	* Route 3: Primary complete
	replace educat7 = 3 if educat7 == . & P03A03A == 2 & P03A03B == 6
	* Route 4: Lower secondary
	replace educat7 = 4 if educat7 == . & P03A03A == 3
	* Route 5: Diversified grade 4
	replace educat7 = 4 if educat7 == . & P03A03A == 4 & P03A03B == 4
	* Route 6: Diversified grades 5 to 7
	replace educat7 = 5 if educat7 == . & P03A03A == 4 & inlist(P03A03B, 5, 6, 7)
	* Route 7: Advanced degrees
	replace educat7 = 7 if educat7 == . & inlist(P03A03A, 5, 6, 7)
	replace educat7 = . if !(!missing(age) & age >= 7)
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
	* Note: The source question also records grade in P03A03B, but educat_orig's
	*   single-source rule permits only one original code; this proposal preserves
	*   the level code P03A03A and does not concatenate grade.
	capture confirm string variable P03A03A
	if _rc == 0 {
	    gen strL educat_orig = P03A03A if !missing(P03A03A)
	}
	else {
	    gen strL educat_orig = strtrim(strofreal(P03A03A, "%24.17g")) if ///
	        !missing(P03A03A)
	    assert real(educat_orig) == P03A03A if !missing(P03A03A) & !missing(age) ///
	        & age >= 7
	}
	replace educat_orig = "" if !(!missing(age) & age >= 7)
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
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
	gen double vocational = .
	label de lblvocational 0 "No" 1 "Yes"
	label var vocational "Ever received vocational training"
	label values vocational lblvocational
*</_vocational_>


*<_vocational_type_>
	gen double vocational_type = .
	label de lblvocational_type 1 "Inside Enterprise" 2 "External"
	label values vocational_type lblvocational_type
	label var vocational_type "Type of vocational training"
*</_vocational_type_>


*<_vocational_length_l_>
	gen double vocational_length_l = .
	label var vocational_length_l "Length of training in months, lower limit"
*</_vocational_length_l_>


*<_vocational_length_u_>
	gen double vocational_length_u = .
	label var vocational_length_u "Length of training in months, upper limit"
*</_vocational_length_u_>


*<_vocational_field_orig_>
	gen strL vocational_field_orig = ""
	label var vocational_field_orig "Original field of training information"
*</_vocational_field_orig_>


*<_vocational_financed_>
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
	* Note: The future-starter route follows the GLD Construction notes rather than
	*   the supplied DESOCUPADOS flag: the retained answers identify available
	*   non-search initiators starting within three months, while the supplied
	*   unemployed flag aligns only with active search plus availability.
	gen byte lstatus = .
	* Route 1: Employed, main activity
	replace lstatus = 1 if lstatus == . & !missing(P02A03) & P02A03 >= 15 ///
	    & inlist(P05A02, 1, 2, 3)
	* Route 2: Employed, paid work
	replace lstatus = 1 if lstatus == . & !missing(P02A03) & P02A03 >= 15 ///
	    & !inlist(P05A02, 1, 2, 3) & P05A03 == 1
	* Route 3: Employed, own account
	replace lstatus = 1 if lstatus == . & !missing(P02A03) & P02A03 >= 15 ///
	    & P05A03 == 2 & P05A04 == 1
	* Route 4: Employed, unpaid family
	replace lstatus = 1 if lstatus == . & !missing(P02A03) & P02A03 >= 15 ///
	    & P05A04 == 2 & P05A05 == 1
	* Route 5: Employed, protected absence
	replace lstatus = 1 if lstatus == . & !missing(P02A03) & P02A03 >= 15 ///
	    & P05A06 == 1 & inlist(P05A07, 1, 2, 3, 4)
	* Route 6: Employed, returns soon
	replace lstatus = 1 if lstatus == . & !missing(P02A03) & P02A03 >= 15 ///
	    & inlist(P05A07, 5, 6, 7, 8, 9, 10, 11, 12, 13, 98) & inlist(P05A08, 1, 2)
	* Route 7: Employed, paid absence
	replace lstatus = 1 if lstatus == . & !missing(P02A03) & P02A03 >= 15 ///
	    & inlist(P05A08, 3, 4, 5, 6) & P05A09 == 1
	* Route 8: Unemployed, searched
	replace lstatus = 2 if lstatus == . & !missing(P02A03) & P02A03 >= 15 ///
	    & (P05A06 == 2 | P05A07 == 14 | P05A09 == 2) & P05B01 == 1 ///
	    & (P05B01 == 1 | inlist(P05B06, 1, 2, 3) | inlist(P05B07, 1, 2)) ///
	    & inlist(P05B08, 1, 2)
	* Route 9: Unemployed, future starter
	replace lstatus = 2 if lstatus == . & !missing(P02A03) & P02A03 >= 15 ///
	    & (P05A06 == 2 | P05A07 == 14 | P05A09 == 2) & P05B01 == 2 ///
	    & inlist(P05B05, 1, 2, 3, 4, 5) & inlist(P05B06, 1, 2) ///
	    & (P05B01 == 1 | inlist(P05B06, 1, 2, 3) | inlist(P05B07, 1, 2)) ///
	    & inlist(P05B08, 1, 2)
	* Route 10: Outside labor force, residual
	replace lstatus = 3 if lstatus == . & !missing(P02A03) & P02A03 >= 15 ///
	    & (P05B01 == 1 | inlist(P05B06, 1, 2, 3) | inlist(P05B07, 1, 2)) ///
	    & inlist(P05B08, 1, 2, 3, 4)
	clonevar lstatus_src_ocupados = OCUPADOS
	clonevar lstatus_src_desocupados = DESOCUPADOS
	clonevar lstatus_src_inactivos = INACTIVOS
	replace lstatus = . if missing(age)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	* Note: Availability codes 1-2 are treated as available within fifteen days,
	*   while code 3 is treated as unavailable under the GLD current-availability
	*   rule.
	gen byte potential_lf = .
	* Route 1: Searched unavailable
	replace potential_lf = 1 if potential_lf == . & P05B01 == 1 ///
	    & inlist(P05B08, 3, 4)
	* Route 2: Not searched available
	replace potential_lf = 1 if potential_lf == . & P05B01 == 2 ///
	    & inlist(P05B08, 1, 2)
	* Route 3: Remaining inactive cases
	replace potential_lf = 0 if potential_lf == .
	replace potential_lf = . if !(lstatus == 3)
	replace potential_lf = . if age < minlaborage & !missing(age)
	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	* Note: The GLD primary-job seven-day label differs from the only source, which
	*   asks currently about wanting more hours across all jobs; the best-source
	*   rule retains this direct wish measure.
	gen double underemployment = .
	replace underemployment = 1 if P05H02 == 1
	replace underemployment = 0 if P05H02 == 2
	replace underemployment = . if !(lstatus == 1)
	replace underemployment = . if age < minlaborage & !missing(age)
	replace underemployment = . if lstatus != 1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen double nlfreason = .
	replace nlfreason = 1 if P05B05 == 10
	replace nlfreason = 2 if P05B05 == 6 | P05B05 == 7 | P05B05 == 8
	replace nlfreason = 5 if P05B05 == 1 | P05B05 == 2 | P05B05 == 3 ///
	    | P05B05 == 4 | P05B05 == 5 | P05B05 == 9 | P05B05 == 11 | P05B05 == 12
	replace nlfreason = 5 if P05B05 == 13 | P05B05 == 14 | P05B05 == 15 ///
	    | P05B05 == 16 | P05B05 == 17 | P05B05 == 18 | P05B05 == 19 | P05B05 == 98
	replace nlfreason = . if !(lstatus == 3)
	replace nlfreason = . if lstatus != 3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	* Note: The source measures time spent searching for work or trying to establish
	*   a business, which may differ from total unemployment-spell duration in the
	*   GLD definition.
	gen double unempldur_l = (P05B04 / 4.333333333333333) if !missing(P05B04)
	replace unempldur_l = . if !(lstatus == 2)
	replace unempldur_l = . if lstatus != 2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	* Note: The open-ended code 97 means more than 96 weeks or 2 years and correctly
	*   has no documented upper bound, so it is declared missing for the upper-bound
	*   construction.
	* Note: The source measures time spent searching for work or trying to establish
	*   a business, which may differ from total unemployment-spell duration in the
	*   GLD definition.
	gen double unempldur_u = (P05B04 / 4.333333333333333) ///
	    if P05B04 != 97.0 & !missing(P05B04)
	replace unempldur_u = . if !(lstatus == 2)
	replace unempldur_u = . if lstatus != 2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen double empstat = .
	replace empstat = 1 if P05C16 == 1 | P05C16 == 2 | P05C16 == 3 | P05C16 == 4
	replace empstat = 4 if P05C16 == 5 | P05C16 == 7
	replace empstat = 3 if P05C16 == 6 | P05C16 == 8
	replace empstat = 2 if P05C16 == 9
	replace empstat = . if !(lstatus == 1)
	replace empstat = . if lstatus != 1
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	* Note: The GLD sector_source rule prefers direct enterprise ownership; P05C16
	*   gives worker status and only explicitly identifies government versus private
	*   for employees, so the private mapping for other statuses relies on the
	*   documented non-wage routing rule.
	gen double ocusec = .
	replace ocusec = 1 if P05C16 == 1
	replace ocusec = 2 if P05C16 == 2 | P05C16 == 3 | P05C16 == 4 | P05C16 == 5 ///
	    | P05C16 == 6 | P05C16 == 7 | P05C16 == 8 | P05C16 == 9
	replace ocusec = . if !(lstatus == 1)
	replace ocusec = . if lstatus != 1
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig = P05C04_2D
	replace industry_orig = . if lstatus != 1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	* First two digits of the ISIC code
	capture confirm string variable P05C04_2D
	if _rc == 0 {
	    gen strL _code = strtrim(P05C04_2D) if !missing(P05C04_2D)
	}
	else {
	    gen strL _code = strtrim(strofreal(P05C04_2D, "%24.17g")) ///
	        if !missing(P05C04_2D)
	}
	replace _code = "" if !regexm(_code, "^[0-9]+$") | strlen(_code) > 2
	replace _code = substr("00", 1, 2 - strlen(_code)) + _code if _code != ""
	gen strL industrycat_isic = substr(_code, 1, 2) + "00" if _code != ""
	replace industrycat_isic = "" if !(!missing(age) & age >= 15 & lstatus == 1)
	clonevar source_industry_1d = P05C04_1D
	drop _code
	replace industrycat_isic = "" if lstatus != 1
	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	
	preserve 
	drop if missing(industrycat_isic)
	int_classif_universe, var(industrycat_isic) universe(ISIC)
	count
	list
	assert `r(N)' == 0
	restore 

	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	* Industry group from the 4-digit ISIC code (string, e.g. "0100")
	gen byte industrycat10 = .
	replace industrycat10 = 1  if inrange(industrycat_isic, "0100", "0399")
	replace industrycat10 = 2  if inrange(industrycat_isic, "0500", "0999")
	replace industrycat10 = 3  if inrange(industrycat_isic, "1000", "3399")
	replace industrycat10 = 4  if inrange(industrycat_isic, "3500", "3999")
	replace industrycat10 = 5  if inrange(industrycat_isic, "4100", "4399")
	replace industrycat10 = 6  if inrange(industrycat_isic, "4500", "4799") ///
	                            | inrange(industrycat_isic, "5500", "5699")
	replace industrycat10 = 7  if inrange(industrycat_isic, "4900", "5399") ///
	                            | inrange(industrycat_isic, "5800", "6399")
	replace industrycat10 = 8  if inrange(industrycat_isic, "6400", "8299")
	replace industrycat10 = 9  if inrange(industrycat_isic, "8400", "8499")
	replace industrycat10 = 10 if inrange(industrycat_isic, "8500", "9999")
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction" 6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
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
	gen occup_orig = P05C02_2D
	replace occup_orig = . if lstatus != 1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	* Note: ISCO-2008 is inferred from the code-set match (the documentation doesn't name the revision).
	* Note: The GLD canonical seven-day reference differs because the questionnaire
	*   also permits the last week worked when the person did not work last week.
	* Two-digit code padded to four digits (e.g. 52 -> "5200"); 999 and other invalid codes fall outside the range
	gen occup_isco = string(P05C02_2D * 100, "%04.0f") ///
	    if inrange(P05C02_2D, 0, 99) & P02A03 >= 15 & lstatus == 1
	clonevar source_occupation_2digit = P05C02_2D
	clonevar source_occupation_1digit = P05C02_1D
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	* Major group from the first digit of the ISCO code (0 = Armed forces -> 10)
	gen byte occup = real(substr(occup_isco, 1, 1))
	replace occup = 10 if occup == 0
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces" 99 "Others"
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
	* Note: The GLD last-payment line is approximated by the survey's documented
	*   monthly concepts: current monthly salary for dependent workers and average
	*   monthly net income over the last 12 months for independent workers.
	* Note: The GLD self-employment rule asks for net revenue after operating costs
	*   and before taxes, while P05E10, P05E11 and P05E12 say profit or net income
	*   but do not explicitly state the treatment of operating costs and taxes.
	* Note: The questionnaire explicitly prints quetzales beside the
	*   independent-income amounts on page 15, but P05D01's page does not separately
	*   print a currency label; the proposal applies the national-survey quetzal
	*   unit consistently to the salary amount.

	* a) Dependent-worker earnings (missing only if all components are missing)
	egen double _earn_D = rowtotal(P05D01 P05D02C P05D03B P05D04B P05D05B P05D06B), missing

	* b) Independent-worker earnings (missing only if all components are missing)
	egen double _earn_E = rowtotal(P05E10 P05E11 P05E12B), missing

	* c) Combine, then restrict to employed people aged 15+ with a valid job category
	egen double wage_no_compen = rowtotal(_earn_D _earn_E), missing
	replace wage_no_compen = . if !(P02A03 >= 15 & P02A03 < .) ///
	    | !inlist(P05C16, 1, 2, 3, 4, 5, 6, 7, 8) | lstatus != 1

	* d) Cleanup
	drop _earn_D _earn_E
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
	gen int unitwage = 5
	replace unitwage = . if missing(unitwage)
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen double whours = ///
	    (cond(!missing(P05C15A), P05C15A, 0) + ///
	    cond(!missing(P05C15B), P05C15B, 0) + ///
	    cond(!missing(P05C15C), P05C15C, 0) + ///
	    cond(!missing(P05C15D), P05C15D, 0) + ///
	    cond(!missing(P05C15E), P05C15E, 0) + ///
	    cond(!missing(P05C15F), P05C15F, 0) + ///
	    cond(!missing(P05C15G), P05C15G, 0)) if !missing(P05C15A) ///
	    | !missing(P05C15B) | !missing(P05C15C) | !missing(P05C15D) ///
	    | !missing(P05C15E) | !missing(P05C15F) | !missing(P05C15G)
	replace whours = . if !(lstatus == 1)
	replace whours = . if lstatus != 1
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	gen double wmonths = .
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
	gen double wage_total = .
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen byte contract = 0
	replace contract = 1 if P05C20 == 1
	replace contract = . if lstatus != 1
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen double healthins = .
	label var healthins "Employment has health insurance primary job 7 day recall"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen int socialsec = 0
	replace socialsec = 1 if P05C08A == 1
	replace socialsec = . if lstatus != 1
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec 1 "With social security" 0 "Without social security"
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen double union = .
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	gen double firmsize_l = .
	replace firmsize_l = 1   if P05C13 == 1
	replace firmsize_l = 2   if P05C13 == 2
	replace firmsize_l = 3   if P05C13 == 3
	replace firmsize_l = 4   if P05C13 == 4
	replace firmsize_l = 5   if P05C13 == 5
	replace firmsize_l = 6   if P05C13 == 6
	replace firmsize_l = 11  if P05C13 == 7
	replace firmsize_l = 51  if P05C13 == 8
	replace firmsize_l = 101 if P05C13 == 9
	replace firmsize_l = 201 if P05C13 == 10
	replace firmsize_l = 501 if P05C13 == 11
	replace firmsize_l = . if lstatus != 1
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	* Note: The find marked firmsize_u as one question, but the proposal uses
	*   routes.
	gen double firmsize_u = .
	replace firmsize_u = 1 if P05C13 == 1
	replace firmsize_u = 2   if P05C13 == 2
	replace firmsize_u = 3   if P05C13 == 3
	replace firmsize_u = 4   if P05C13 == 4
	replace firmsize_u = 5   if P05C13 == 5
	replace firmsize_u = 10  if P05C13 == 6
	replace firmsize_u = 50  if P05C13 == 7
	replace firmsize_u = 100 if P05C13 == 8
	replace firmsize_u = 200 if P05C13 == 9
	replace firmsize_u = 500 if P05C13 == 10
	replace firmsize_u = .   if P05C13 == 11
	replace firmsize_u = .   if lstatus != 1
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	recode P05G08 (1/4 = 1) (5 7 = 4) (6 8 = 3) (9 = 2), gen(empstat_2)
	replace empstat_2 = . if lstatus != 1
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	recode P05G08 (1 = 1) (2/9 = 2), gen(ocusec_2)
	replace ocusec_2 = . if lstatus != 1
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen strL industry_orig_2 = ""
	replace industry_orig_2 = strtrim(string(P05G04_2D, "%18.0f")) ///
	    if lstatus == 1 & !missing(P05G04_2D)
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	gen strL industrycat_isic_2 = ""
	replace industrycat_isic_2 = string(P05G04_2D, "%02.0f") + "00" ///
	    if lstatus == 1 & inrange(P05G04_2D, 1, 99)
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen byte industrycat10_2 = .
	replace industrycat10_2 = 1 if inrange(P05G04_2D, 1, 3)
	replace industrycat10_2 = 2 if inrange(P05G04_2D, 5, 9)
	replace industrycat10_2 = 3 if inrange(P05G04_2D, 10, 33)
	replace industrycat10_2 = 4 if inrange(P05G04_2D, 35, 39)
	replace industrycat10_2 = 5 if inrange(P05G04_2D, 41, 43)
	replace industrycat10_2 = 6 if ///
	    inrange(P05G04_2D, 45, 47) | inrange(P05G04_2D, 55, 56)
	replace industrycat10_2 = 7 if ///
	    inrange(P05G04_2D, 49, 53) | inrange(P05G04_2D, 58, 63)
	replace industrycat10_2 = 8 if ///
	    inrange(P05G04_2D, 64, 66) | inrange(P05G04_2D, 68, 75) ///
	    | inrange(P05G04_2D, 77, 82)
	replace industrycat10_2 = 9 if P05G04_2D == 84
	replace industrycat10_2 = 10 if ///
	    inrange(P05G04_2D, 85, 99) | P05G04_2D == 999
	replace industrycat10_2 = . if lstatus != 1
	label var industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
	label values industrycat10_2 lblindustrycat10
*</_industrycat10_2_>


*<_industrycat4_2_>
	gen byte industrycat4_2 = industrycat10_2
	recode industrycat4_2 (1 = 1) (2 3 4 5 = 2) ///
	    (6 7 8 9 = 3) (10 = 4)
	label var industrycat4_2 "Broad Economic Activities classification, secondary job 7 day recall"
	label values industrycat4_2 lblindustrycat4
*</_industrycat4_2_>


*<_occup_orig_2_>
	gen strL occup_orig_2 = ""
	replace occup_orig_2 = strtrim(string(P05G02_2D, "%18.0f")) ///
	    if lstatus == 1 & !missing(P05G02_2D)
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen strL occup_isco_2 = ""
	replace occup_isco_2 = string(P05G02_2D * 100, "%04.0f") ///
	    if lstatus == 1 & inrange(P05G02_2D, 0, 99)
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_2_>
	gen byte occup_2 = P05G02_1D if inrange(P05G02_1D, 1, 9)
	replace occup_2 = 10 if P05G02_1D == 0
	replace occup_2 = 99 if P05G02_1D == 99
	replace occup_2 = . if lstatus != 1
	label var occup_2 "1 digit occupational classification secondary job 7 day recall"
	label values occup_2 lbloccup
*</_occup_2_>


*<_occup_skill_2_>
	gen byte occup_skill_2 = .
	replace occup_skill_2 = 3 if inrange(occup_2, 1, 3)
	replace occup_skill_2 = 2 if inrange(occup_2, 4, 8)
	replace occup_skill_2 = 1 if occup_2 == 9
	label define lblskill2 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_2 lblskill2
	label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>


*<_wage_no_compen_2_>
	* No cross contamination
	gen has_2nd_wage = !mi(P05G10)
	gen has_2nd_earn = !mi(P05G26)
	tab has_2nd_*

	gen double wage_no_compen_2 = .
	* Monthly salary for employees, jornaleros, and domestic workers.
	replace wage_no_compen_2 = P05G10 
	* Monthly net business income for own-account workers and employers.
	replace wage_no_compen_2 = P05G26 
		replace wage_no_compen_2 = . if mi(empstat_2)
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2 = 5 if !mi(wage_no_compen_2)
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
	egen double whours_2 = rowtotal( ///
	    P05G29A P05G29B P05G29C P05G29D P05G29E P05G29F P05G29G), missing
	replace whours_2 = . if lstatus != 1
	label var whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>


*<_wmonths_2_>
	* Months worked in the last year are not collected on the cited pages.
	gen double wmonths_2 = .
	label var wmonths_2 "Months of work in past 12 months secondary job 7 day recall"
*</_wmonths_2_>


*<_wage_total_2_>
	* Leave annualized total missing because months worked are unavailable.
	gen double wage_total_2 = .
	label var wage_total_2 "Annualized total wage secondary job 7 day recall"
*</_wage_total_2_>


*<_firmsize_l_2_>
	recode P05G07 (1 = 1) (2 = 2) (3 = 3) (4 = 4) (5 = 5) (6 = 6) ///
	    (7 = 11) (8 = 51) (9 = 101) (10 = 201) (11 = 501), ///
	    gen(firmsize_l_2)
	replace firmsize_l_2 = . if lstatus != 1
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	recode P05G07 (1 = 1) (2 = 2) (3 = 3) (4 = 4) (5 = 5) ///
	    (6 = 10) (7 = 50) (8 = 100) (9 = 200) (10 = 500) (11 = .), ///
	    gen(firmsize_u_2)
	replace firmsize_u_2 = . if lstatus != 1
	label var firmsize_u_2 "Firm size (upper bracket) secondary job 7 day recall"
*</_firmsize_u_2_>

}

*----------8.4: 7 day reference additional jobs------------------------------*

*<_t_hours_others_>
	gen double t_hours_others = .
	label var t_hours_others "Annualized hours worked in all but primary and secondary jobs 7 day recall"
*</_t_hours_others_>


*<_t_wage_nocompen_others_>
	gen double t_wage_nocompen_others = .
	label var t_wage_nocompen_others "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_others_>


*<_t_wage_others_>
	gen double t_wage_others = .
	label var t_wage_others "Annualized wage in all but primary and secondary jobs (7-day recall)"
*</_t_wage_others_>


*----------8.5: 7 day reference total summary------------------------------*


*<_t_hours_total_>
	gen double t_hours_total = .
	label var t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
	gen double t_wage_nocompen_total = .
	label var t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
	gen double t_wage_total = .
	label var t_wage_total "Annualized total wage for all jobs 7 day recall"
*</_t_wage_total_>


*----------8.6: 12 month reference overall------------------------------*

{

*<_lstatus_year_>
	gen double lstatus_year = .
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>

*<_potential_lf_year_>
	gen double potential_lf_year = .
	label var potential_lf_year "Potential labour force status"
	la de lblpotential_lf_year 0 "No" 1 "Yes"
	label values potential_lf_year lblpotential_lf_year
*</_potential_lf_year_>


*<_underemployment_year_>
	gen double underemployment_year = .
	label var underemployment_year "Underemployment status"
	la de lblunderemployment_year 0 "No" 1 "Yes"
	label values underemployment_year lblunderemployment_year
*</_underemployment_year_>


*<_nlfreason_year_>
	gen double nlfreason_year = .
	label var nlfreason_year "Reason not in the labor force"
	la de lblnlfreason_year 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason_year lblnlfreason_year
*</_nlfreason_year_>


*<_unempldur_l_year_>
	gen double unempldur_l_year = .
	label var unempldur_l_year "Unemployment duration (months) lower bracket"
*</_unempldur_l_year_>


*<_unempldur_u_year_>
	gen double unempldur_u_year = .
	label var unempldur_u_year "Unemployment duration (months) upper bracket"
*</_unempldur_u_year_>

}

*----------8.7: 12 month reference main job------------------------------*

{

*<_empstat_year_>
	gen double empstat_year = .
	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>

*<_ocusec_year_>
	gen double ocusec_year = .
	label var ocusec_year "Sector of activity primary job 12 month recall"
	la de lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_year lblocusec_year
*</_ocusec_year_>

*<_industry_orig_year_>
	gen strL industry_orig_year = ""
	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	gen strL industrycat_isic_year = ""
	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>

*<_industrycat10_year_>
	gen double industrycat10_year = .
	label var industrycat10_year "1 digit industry classification, primary job 12 month recall"
	la de lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_year lblindustrycat10_year
*</_industrycat10_year_>


*<_industrycat4_year_>
	gen double industrycat4_year = .
	label var industrycat4_year "Broad Economic Activities classification, primary job 12 month recall"
	la de lblindustrycat4_year 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4_year lblindustrycat4_year
*</_industrycat4_year_>


*<_occup_orig_year_>
	gen strL occup_orig_year = ""
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	gen strL occup_isco_year = ""
	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_year_>
	gen double occup_year = .
	label var occup_year "1 digit occupational classification, primary job 12 month recall"
	la de lbloccup_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_year lbloccup_year
*</_occup_year_>


*<_occup_skill_year_>
	gen double occup_skill_year = .
	la de lblskillyear 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_year lblskillyear
	label var occup_skill_year "Skill based on ISCO standard primary job 12 month recall"
*</_occup_skill_year_>


*<_wage_no_compen_year_>
	gen double wage_no_compen_year = .
	label var wage_no_compen_year "Last wage payment primary job 12 month recall"
*</_wage_no_compen_year_>


*<_unitwage_year_>
	gen double unitwage_year = .
	label var unitwage_year "Last wages' time unit primary job 12 month recall"
	la de lblunitwage_year 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_year lblunitwage_year
*</_unitwage_year_>


*<_whours_year_>
	gen double whours_year = .
	label var whours_year "Hours of work in last week primary job 12 month recall"
*</_whours_year_>


*<_wmonths_year_>
	gen double wmonths_year = .
	label var wmonths_year "Months of work in past 12 months primary job 12 month recall"
*</_wmonths_year_>


*<_wage_total_year_>
	gen double wage_total_year = .
	label var wage_total_year "Annualized total wage primary job 12 month recall"
*</_wage_total_year_>


*<_contract_year_>
	gen double contract_year = .
	label var contract_year "Employment has contract primary job 12 month recall"
	la de lblcontract_year 0 "Without contract" 1 "With contract"
	label values contract_year lblcontract_year
*</_contract_year_>


*<_healthins_year_>
	gen double healthins_year = .
	label var healthins_year "Employment has health insurance primary job 12 month recall"
	la de lblhealthins_year 0 "Without health insurance" 1 "With health insurance"
	label values healthins_year lblhealthins_year
*</_healthins_year_>


*<_socialsec_year_>
	gen double socialsec_year = .
	label var socialsec_year "Employment has social security insurance primary job 12 month recall"
	la de lblsocialsec_year 1 "With social security" 0 "Without social security"
	label values socialsec_year lblsocialsec_year
*</_socialsec_year_>


*<_union_year_>
	gen double union_year = .
	label var union_year "Union membership at primary job 12 month recall"
	la de lblunion_year 0 "Not union member" 1 "Union member"
	label values union_year lblunion_year
*</_union_year_>


*<_firmsize_l_year_>
	gen double firmsize_l_year = .
	label var firmsize_l_year "Firm size (lower bracket) primary job 12 month recall"
*</_firmsize_l_year_>


*<_firmsize_u_year_>
	gen double firmsize_u_year = .
	label var firmsize_u_year "Firm size (upper bracket) primary job 12 month recall"
*</_firmsize_u_year_>

}


*----------8.8: 12 month reference secondary job------------------------------*

{

*<_empstat_2_year_>
	gen double empstat_2_year = .
	label var empstat_2_year "Employment status during past week secondary job 12 month recall"
	label values empstat_2_year lblempstat_year
*</_empstat_2_year_>


*<_ocusec_2_year_>
	gen double ocusec_2_year = .
	label var ocusec_2_year "Sector of activity secondary job 12 month recall"
	la de lblocusec_2_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_2_year lblocusec_2_year
*</_ocusec_2_year_>


*<_industry_orig_2_year_>
	gen strL industry_orig_2_year = ""
	label var industry_orig_2_year "Original survey industry code, secondary job 12 month recall"
*</_industry_orig_2_year_>


*<_industrycat_isic_2_year_>
	gen strL industrycat_isic_2_year = ""
	label var industrycat_isic_2_year "ISIC code of secondary job 12 month recall"
*</_industrycat_isic_2_year_>


*<_industrycat10_2_year_>
	gen double industrycat10_2_year = .
	label var industrycat10_2_year "1 digit industry classification, secondary job 12 month recall"
	label values industrycat10_2_year lblindustrycat10_year
*</_industrycat10_2_year_>


*<_industrycat4_2_year_>
	gen double industrycat4_2_year = .
	label var industrycat4_2_year "Broad Economic Activities classification, secondary job 12 month recall"
	label values industrycat4_2_year lblindustrycat4_year
*</_industrycat4_2_year_>


*<_occup_orig_2_year_>
	gen strL occup_orig_2_year = ""
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
	gen strL occup_isco_2_year = ""
	label var occup_isco_2_year "ISCO code of secondary job 12 month recall"
*</_occup_isco_2_year_>


*<_occup_2_year_>
	gen double occup_2_year = .
	label var occup_2_year "1 digit occupational classification, secondary job 12 month recall"
	label values occup_2_year lbloccup_year
*</_occup_2_year_>


*<_occup_skill_2_year_>
	gen double occup_skill_2_year = .
	la de lblskilly2 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_2_year lblskilly2
	label var occup_skill_2_year "Skill based on ISCO standard secondary job 12 month recall"
*</_occup_skill_2_year_>


*<_wage_no_compen_2_year_>
	gen double wage_no_compen_2_year = .
	label var wage_no_compen_2_year "Last wage payment secondary job 12 month recall"
*</_wage_no_compen_2_year_>


*<_unitwage_2_year_>
	gen double unitwage_2_year = .
	label var unitwage_2_year "Last wages' time unit secondary job 12 month recall"
	label values unitwage_2_year lblunitwage_year
*</_unitwage_2_year_>


*<_whours_2_year_>
	gen double whours_2_year = .
	label var whours_2_year "Hours of work in last week secondary job 12 month recall"
*</_whours_2_year_>


*<_wmonths_2_year_>
	gen double wmonths_2_year = .
	label var wmonths_2_year "Months of work in past 12 months secondary job 12 month recall"
*</_wmonths_2_year_>


*<_wage_total_2_year_>
	gen double wage_total_2_year = .
	label var wage_total_2_year "Annualized total wage secondary job 12 month recall"
*</_wage_total_2_year_>

*<_firmsize_l_2_year_>
	gen double firmsize_l_2_year = .
	label var firmsize_l_2_year "Firm size (lower bracket) secondary job 12 month recall"
*</_firmsize_l_2_year_>


*<_firmsize_u_2_year_>
	gen double firmsize_u_2_year = .
	label var firmsize_u_2_year "Firm size (upper bracket) secondary job 12 month recall"
*</_firmsize_u_2_year_>

}


*----------8.9: 12 month reference additional jobs------------------------------*


*<_t_hours_others_year_>
	gen double t_hours_others_year = .
	label var t_hours_others_year "Annualized hours worked in all but primary and secondary jobs 12 month recall"
*</_t_hours_others_year_>

*<_t_wage_nocompen_others_year_>
	gen double t_wage_nocompen_others_year = .
	label var t_wage_nocompen_others_year "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_others_year_>

*<_t_wage_others_year_>
	gen double t_wage_others_year = .
	label var t_wage_others_year "Annualized wage in all but primary and secondary jobs 12 month recall"
*</_t_wage_others_year_>


*----------8.10: 12 month total summary------------------------------*


*<_t_hours_total_year_>
	gen double t_hours_total_year = .
	label var t_hours_total_year "Annualized hours worked in all jobs 12 month recall"
*</_t_hours_total_year_>


*<_t_wage_nocompen_total_year_>
	gen double t_wage_nocompen_total_year = .
	label var t_wage_nocompen_total_year "Annualized wage in all jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_total_year_>


*<_t_wage_total_year_>
	gen double t_wage_total_year = .
	label var t_wage_total_year "Annualized total wage for all jobs 12 month recall"
*</_t_wage_total_year_>


*----------8.11: Overall across reference periods------------------------------*


*<_njobs_>
	gen double njobs = .
	label var njobs "Total number of jobs"
*</_njobs_>


*<_t_hours_annual_>
	gen double t_hours_annual = .
	label var t_hours_annual "Total hours worked in all jobs in the previous 12 months"
*</_t_hours_annual_>


*<_linc_nc_>
	gen double linc_nc = .
	label var linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."
*</_linc_nc_>


*<_laborincome_>
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