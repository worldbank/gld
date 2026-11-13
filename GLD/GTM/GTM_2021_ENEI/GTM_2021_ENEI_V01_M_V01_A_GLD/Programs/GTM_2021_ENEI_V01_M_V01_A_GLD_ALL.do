
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				GTM_2021_ENEI_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata 18 <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				YYYY-MM-DD </_Date created_>

-------------------------------------------------------------------------

<_Country_>					Guatemala (GTM) </_Country_>
<_Survey Title_>				Encuesta Nacional de Empleo e Ingresos </_Survey Title_>
<_Survey Year_>					2021 </_Survey Year_>
<_Study ID_>					[Microdata Library ID if present] </_Study ID_>
<_Data collection from_>			[MM/YYYY] </_Data collection from_>
<_Data collection to_>				[MM/YYYY] </_Data collection to_>
<_Source of dataset_> 				[Source of data, e.g. NSO] </_Source of dataset_>
<_Sample size (HH)_> 				[#] </_Sample size (HH)_>
<_Sample size (IND)_> 				[#] </_Sample size (IND)_>
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
local year    "2021"
local survey  "ENEI"
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
local path_work   "`server'/`country'/`level_1'/`level_2_harm'/Work"

* Define Output file name
local out_file "`level_2_harm'_ALL.dta"

*----------1.3: Database assembly------------------------------*

capture log close _all
log using "`path_work'/template_assembly.log", text replace

tempfile person_input
use "`path_in_stata'/ENEI 2021 BASE DE PERSONAS.dta", clear
isid NUM_HOGAR ID
local expected_rows = _N
    local label_number = 0
    foreach variable of varlist _all {
        local source_label : value label `variable'
        if "`source_label'" != "" {
            local label_number = `label_number' + 1
            label copy `source_label' p1_`label_number'
            label values `variable' p1_`label_number'
        }
    }
save "`person_input'", replace
use "`path_in_stata'/ENEI 2021 BASE DE HOGARES.dta", clear
isid NUM_HOGAR
    local label_number = 0
    foreach variable of varlist _all {
        local source_label : value label `variable'
        if "`source_label'" != "" {
            local label_number = `label_number' + 1
            label copy `source_label' h1_`label_number'
            label values `variable' h1_`label_number'
        }
    }
foreach shared in DOMINIO DEPTO MUPIO UPM AREA FACTOR {
    rename `shared' _hh_`shared'
}
merge 1:m NUM_HOGAR using "`person_input'"
assert _merge == 3
foreach shared in DOMINIO DEPTO MUPIO UPM AREA FACTOR {
    assert `shared' == _hh_`shared'
    drop _hh_`shared'
}
drop _merge
assert _N == `expected_rows'
isid NUM_HOGAR ID
generate byte assembly_round = 1
label variable assembly_round "Source-file survey round"
sort NUM_HOGAR ID
save "`path_work'/assembled.dta", replace
display "ASSEMBLY_SUCCESS rows=" _N " columns=" c(k)

/*%%==========================================================================
    2: Survey & ID
==========================================================================%%*/

*<_countrycode_>
	generate str3 countrycode = "GTM"
	label variable countrycode "Country code"
*</_countrycode_>


*<_survname_>
	generate str4 survname = "ENEI"
	label variable survname "Survey acronym"
*</_survname_>


*<_survey_>
	generate str3 survey = "LFS"
	label variable survey "Survey type"
*</_survey_>


*<_icls_v_>
	* Subsistence and unpaid family work enter employment in the questionnaire.
	generate str7 icls_v = "ICLS-13"
	label variable icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	generate str10 isced_version = ""
	label variable isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
	* ISCO-2008 inferred from the released two-digit classification labels.
	generate str9 isco_version = "isco_2008"
	label variable isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
	generate str6 isic_version = "isic_4"
	label variable isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	generate int year = 2021
	label variable year "Year of survey"
*</_year_>


*<_vermast_>
	generate str3 vermast = "`vermast'"
	label variable vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	generate str3 veralt = "`veralt'"
	label variable veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	generate str3 harmonization = "GLD"
	label variable harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	* Survey-year proxy; exact interview dates are absent from these inputs.
	generate int int_year = 2021
	label variable int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	generate byte int_month = .
	label variable int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
	* Independent round records; a repeated household number is not panel linkage.
	quietly summarize NUM_HOGAR
	local household_width = strlen(strtrim(string(r(max), "%18.0f")))
	generate hhid = string(assembly_round, "%1.0f") + "-" + ///
	    string(NUM_HOGAR, "%0`household_width'.0f")
	label variable hhid "Household ID"
*</_hhid_>


*<_pid_>
	quietly summarize ID
	local person_width = strlen(strtrim(string(r(max), "%18.0f")))
	generate pid = hhid + "-" + string(ID, "%0`person_width'.0f")
	label variable pid "Individual ID"
	isid pid
*</_pid_>


*<_weight_>
	* Single annual delivery: use its expansion factor without a pooled-round divisor.
	generate double weight = FACTOR
	assert weight > 0 & !missing(weight)
	label variable weight "Survey sampling weight"
*</_weight_>


*<_weight_m_>
	generate double weight_m = .
	label variable weight_m "Survey sampling weight to obtain national estimates for each month"
*</_weight_m_>


*<_weight_q_>
	* ENEI rounds are not identified as calendar quarters.
	generate double weight_q = .
	label variable weight_q "Quarterly survey sampling weight"
*</_weight_q_>


*<_psu_>
	generate psu = string(UPM, "%18.0f") if !missing(UPM)
	replace psu = strtrim(psu)
	label variable psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	generate str1 ssu = hhid
	label variable ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	* DOMINIO is a reporting domain, not necessarily the sampling stratum.
	generate str1 strata = ""
	label variable strata "Strata"
*</_strata_>


*<_wave_>
	generate str2 wave = "R" + string(assembly_round, "%1.0f")
	label variable wave "Survey wave"
*</_wave_>


*<_panel_>
	generate str1 panel = ""
	label variable panel "Panel individual belongs to"
*</_panel_>


*<_visit_no_>
	generate byte visit_no = .
	label variable visit_no "Visit number in panel"
*</_visit_no_>


/*%%==========================================================================
    3: Geography
==========================================================================%%*/

*<_urban_>
	generate byte urban = .
	replace urban = 1 if AREA == 1
	replace urban = 0 if AREA == 2
	label define lblurban 0 "Rural" 1 "Urban", replace
	label values urban lblurban
	label variable urban "Location is urban"
*</_urban_>


*<_subnatid1_>
	* Department code and source value label.
	decode DEPTO, generate(_subnatid1_name)
	generate str40 subnatid1 = strtrim(string(DEPTO, "%18.0f")) + " - " + ///
	    strtrim(_subnatid1_name) if !missing(DEPTO)
	label variable subnatid1 "Subnational ID at First Administrative Level"
	drop _subnatid1_name
*</_subnatid1_>


*<_subnatid2_>
	generate str1 subnatid2 = ""
	label variable subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	generate str1 subnatid3 = ""
	label variable subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
	generate str30 subnatidsurvey = ""
	replace subnatidsurvey = "1 - Urbano Metropolitano" if DOMINIO == 1
	replace subnatidsurvey = "2 - Resto Urbano" if DOMINIO == 2
	replace subnatidsurvey = "3 - Rural Nacional" if DOMINIO == 3
	label variable subnatidsurvey "Administrative level of survey representation"
*</_subnatidsurvey_>


*<_subnatid1_prev_>
	generate str1 subnatid1_prev = ""
	label variable subnatid1_prev "Classification used for subnatid1 from previous survey"
*</_subnatid1_prev_>


*<_subnatid2_prev_>
	generate str1 subnatid2_prev = ""
	label variable subnatid2_prev "Classification used for subnatid2 from previous survey"
*</_subnatid2_prev_>


*<_subnatid3_prev_>
	generate str1 subnatid3_prev = ""
	label variable subnatid3_prev "Classification used for subnatid3 from previous survey"
*</_subnatid3_prev_>


*<_gaul_adm1_code_>
	generate double gaul_adm1_code = .
	label variable gaul_adm1_code "Global Administrative Unit Layers (GAUL) Admin 1 code"
*</_gaul_adm1_code_>


*<_gaul_adm2_code_>
	generate double gaul_adm2_code = .
	label variable gaul_adm2_code "Global Administrative Unit Layers (GAUL) Admin 2 code"
*</_gaul_adm2_code_>


*<_gaul_adm3_code_>
	generate double gaul_adm3_code = .
	label variable gaul_adm3_code "Global Administrative Unit Layers (GAUL) Admin 3 code"
*</_gaul_adm3_code_>


/*%%==========================================================================
    4: Demography
==========================================================================%%*/

*<_hsize_>
	* Proposed economic-household count excludes domestic employees and lodgers.
	bysort hhid: egen hsize = total( ///
	    !inlist(PPA05, 11, 12) & !missing(PPA05))
	label variable hsize "Household size"
*</_hsize_>


*<_age_>
	* Completed years; do not infer young-child months without interview dates.
	generate double age = PPA03 if inrange(PPA03, 0, 120)
	label variable age "Individual age"
*</_age_>


*<_male_>
	generate byte male = .
	replace male = 1 if PPA02 == 1
	replace male = 0 if PPA02 == 2
	label define lblmale 0 "Female" 1 "Male", replace
	label values male lblmale
	label variable male "Sex - Ind is male"
*</_male_>


*<_relationharm_>
	generate byte relationharm = .
	replace relationharm = 1 if PPA05 == 1
	replace relationharm = 2 if PPA05 == 2
	replace relationharm = 3 if PPA05 == 3
	replace relationharm = 4 if PPA05 == 6
	replace relationharm = 5 if inlist(PPA05, 4, 5, 7, 8, 9, 10)
	replace relationharm = 6 if inlist(PPA05, 11, 12, 13)
	label define lblrelationharm 1 "Head of household" 2 "Spouse" ///
	    3 "Children" 4 "Parents" 5 "Other relatives" ///
	    6 "Other and non-relatives", replace
	label values relationharm lblrelationharm
	label variable relationharm "Relationship to household head - Harmonized"
*</_relationharm_>


*<_relationcs_>
	clonevar relationcs = PPA05
	label variable relationcs "Relationship to household head - Country original"
*</_relationcs_>


*<_marital_>
	generate byte marital = .
	replace marital = 3 if PPA09 == 1
	replace marital = 1 if PPA09 == 2
	replace marital = 4 if inlist(PPA09, 3, 4, 5)
	replace marital = 5 if PPA09 == 6
	replace marital = 2 if PPA09 == 7
	* Code 8 means under 12 years; it does not establish marital status.
	label define lblmarital 1 "Married" 2 "Never Married" 3 "Living together" ///
	    4 "Divorced/Separated" 5 "Widowed", replace
	label values marital lblmarital
	label variable marital "Marital status"
*</_marital_>


*<_eye_dsablty_>
	generate byte eye_dsablty = .
	label variable eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	generate byte hear_dsablty = .
	label variable hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	generate byte walk_dsablty = .
	label variable walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	generate byte conc_dsord = .
	label variable conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	generate byte slfcre_dsablty = .
	label variable slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	generate byte comm_dsablty = .
	label variable comm_dsablty "Disability related to communicating"
*</_comm_dsablty_>


/*%%==========================================================================
    5: Migration
==========================================================================%%*/

* No supported migration construction from the supplied 2018 inputs.

*<_migrated_mod_age_>
	generate byte migrated_mod_age = .
	label variable migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	generate double migrated_ref_time = .
	label variable migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
	generate byte migrated_binary = .
	label variable migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	generate double migrated_years = .
	label variable migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	generate byte migrated_from_urban = .
	label variable migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	generate byte migrated_from_cat = .
	label variable migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	generate str1 migrated_from_code = ""
	label variable migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	generate str3 migrated_from_country = ""
	label variable migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	generate byte migrated_reason = .
	label variable migrated_reason "Reason for migrating"
*</_migrated_reason_>


/*%%==========================================================================
    6: Education
==========================================================================%%*/

*<_ed_mod_age_>
	generate byte ed_mod_age = 7
	label variable ed_mod_age "Education module application age"
*</_ed_mod_age_>


*<_school_>
	* Enrollment is the available proxy, not a direct current-attendance question.
	generate byte school = .
	replace school = 1 if P03A02 == 1
	replace school = 0 if P03A02 == 2
	replace school = . if age < ed_mod_age | missing(age)
	label define lblschool 0 "No" 1 "Yes", replace
	label values school lblschool
	label variable school "Attending school"
*</_school_>


*<_literacy_>
	generate byte literacy = .
	replace literacy = 1 if P03A01 == 1
	replace literacy = 0 if P03A01 == 2
	replace literacy = . if age < ed_mod_age | missing(age)
	label define lblliteracy 0 "No" 1 "Yes", replace
	label values literacy lblliteracy
	label variable literacy "Individual can read & write"
*</_literacy_>


*<_educy_>
	* Grade numbering and program lengths need a separate reviewed construction.
	generate double educy = .
	label variable educy "Years of education"
*</_educy_>


*<_educat7_>
	generate byte educat7 = .
	replace educat7 = 1 if educat7 == . & !missing(P03A05A) & P03A05A < 2
	replace educat7 = 2 if educat7 == . & P03A05A == 2 ///
	    & inlist(P03A05B, 1, 2, 3, 4, 5)
	replace educat7 = 3 if educat7 == . & P03A05A == 2 & P03A05B == 6
	replace educat7 = 4 if educat7 == . & P03A05A == 3
	replace educat7 = 4 if educat7 == . & P03A05A == 4 & P03A05B == 4
	replace educat7 = 5 if educat7 == . & P03A05A == 4 & inlist(P03A05B, 5, 6, 7)
	replace educat7 = 7 if educat7 == . & inlist(P03A05A, 5, 6, 7)
	replace educat7 = . if age < ed_mod_age | missing(age)
	label define lbleducat7 1 "No education" 2 "Primary incomplete" ///
	    3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" ///
	    6 "Higher than secondary but not university" ///
	    7 "University incomplete or complete", replace
	label values educat7 lbleducat7
	label variable educat7 "Level of education 1"
*</_educat7_>


*<_educat5_>
	generate byte educat5 = educat7
	recode educat5 (4 = 3) (5 = 4) (6 7 = 5)
	label define lbleducat5 1 "No education" 2 "Primary incomplete" ///
	    3 "Primary complete but secondary incomplete" 4 "Secondary complete" ///
	    5 "Some tertiary/post-secondary", replace
	label values educat5 lbleducat5
	label variable educat5 "Level of education 2"
*</_educat5_>


*<_educat4_>
	generate byte educat4 = educat7
	recode educat4 (2 3 4 = 2) (5 = 3) (6 7 = 4)
	label define lbleducat4 1 "No education" 2 "Primary" ///
	    3 "Secondary" 4 "Post-secondary", replace
	label values educat4 lbleducat4
	label variable educat4 "Level of education 3"
*</_educat4_>


*<_educat_orig_>
	* Preserve the source level and grade, separated by a hyphen.
	generate educat_orig = string(P03A05A, "%1.0f") + "-" + ///
	    cond(missing(P03A05B), "", string(P03A05B, "%02.0f")) ///
	    if inrange(P03A05A, 0, 7) & age >= ed_mod_age & !missing(age)
	label variable educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
	generate int educat_isced = .
	label variable educat_isced "ISCED standardised level of education"
*</_educat_isced_>

/*%%==========================================================================
    7: Training
==========================================================================%%*/

*<_vocational_>
	* Ages 13-29; attendance during the last six months, not lifetime training.
	* Recent attendance establishes ever trained; a recent no does not mean never.
	generate byte vocational = .
	label define lblvocational 0 "No" 1 "Yes", replace
	label values vocational lblvocational
	label variable vocational "Ever received vocational training"
*</_vocational_>


*<_vocational_type_>
	generate byte vocational_type = .
	label define lblvocational_type 1 "Inside Enterprise" 2 "External", replace
	label values vocational_type lblvocational_type
	label variable vocational_type "Type of vocational training"
*</_vocational_type_>


*<_vocational_length_l_>
	generate double vocational_length_l = .
	label variable vocational_length_l "Length of training in months, lower limit"
*</_vocational_length_l_>


*<_vocational_length_u_>
	generate double vocational_length_u = .
	label variable vocational_length_u "Length of training in months, upper limit"
*</_vocational_length_u_>


*<_vocational_field_orig_>
	generate str1 vocational_field_orig = ""
	label variable vocational_field_orig "Original field of training information"
*</_vocational_field_orig_>


*<_vocational_financed_>
	generate byte vocational_financed = .
	label define lblvocational_financed 1 "Employer" 2 "Government" ///
	    3 "Mixed Employer/Government" 4 "Own funds" 5 "Other", replace
	label values vocational_financed lblvocational_financed
	label variable vocational_financed "How training was financed"
*</_vocational_financed_>

/*%%==========================================================================
    8: Labour
==========================================================================%%*/

*<_minlaborage_>
	generate byte minlaborage = 7
	label variable minlaborage "Labor module application age"
*</_minlaborage_>

*----------8.1: 7 day reference overall---------------------------------------*

*<_lstatus_>
	generate byte lstatus = .
	replace lstatus = 1 if P04A02 == 1 | P04A03 == 1 | ///
	    P04A04 == 1 | P04A05 == 1
		
	replace lstatus = 1 if inrange(P04A07, 1, 5) | P04A08 == 1 | ///
	inlist(P04A09, 1, 2)
	
	replace lstatus = 2 if missing(lstatus) & ///
	    (P04B01 == 1 | P04B02 == 1) & P04B05 == 2
	
	replace lstatus = 3 if missing(lstatus) 
	replace lstatus = . if age < minlaborage | missing(age)
	label define lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF", replace
	label values lstatus lbllstatus
	label variable lstatus "Labor status"
*</_lstatus_>


*<_potential_lf_>
	generate byte potential_lf = 0 
	replace potential_lf = 1 if P04B01 == 1 & P04B05 == 1
	replace potential_lf = 1 if P04B01 == 2 & P04B05 == 2
	replace potential_lf = 1 if P04B02 == 1 & P04B05 == 1
	replace potential_lf = 1 if P04B02 == 2 & P04B05 == 2
	replace potential_lf = . if lstatus != 3
	label define lblpotential_lf 0 "No" 1 "Yes", replace
	label values potential_lf lblpotential_lf
	label variable potential_lf "Potential labour force status"
*</_potential_lf_>


*<_underemployment_>
	* Wants more hours and is available; not a nationally defined hours threshold.
	generate byte underemployment = .
	replace underemployment = 1 if lstatus == 1 & P04E01 == 1 & P04E05 == 1
	replace underemployment = 0 if lstatus == 1 & ///
	    (P04E01 == 2 | (P04E01 == 1 & P04E05 == 2))
	label define lblunderemployment 0 "No" 1 "Yes", replace
	label values underemployment lblunderemployment
	label variable underemployment "Underemployment status"
*</_underemployment_>


*<_nlfreason_>
	generate byte nlfreason = .
	replace nlfreason = 5 if lstatus == 3 & !missing(P04B04)
	replace nlfreason = 1 if lstatus == 3 & P04B04 == 17
	replace nlfreason = 2 if lstatus == 3 & inrange(P04B04, 12, 14)
	replace nlfreason = 4 if lstatus == 3 & P04B04 == 15
	replace nlfreason = 3 if lstatus == 3 & P04A02 == 5 & P04B04 == 11
	label define lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" ///
	    4 "Disabled" 5 "Other", replace
	label values nlfreason lblnlfreason
	label variable nlfreason "Reason not in the labor force"
*</_nlfreason_>


*<_unempldur_l_>
	* F01 asks weeks looking for work; this is a job-search-duration proxy.
	generate double unempldur_l = P04F01 * 12 / 52 ///
	    if lstatus == 2 & inrange(P04F01, 0, 96)
	replace unempldur_l = 96 * 12 / 52 if lstatus == 2 & P04F01 == 97
	label variable unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	generate double unempldur_u = P04F01 * 12 / 52 ///
	    if lstatus == 2 & inrange(P04F01, 0, 96)
	label variable unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>


*----------8.2: 7 day reference main job--------------------------------------*


*<_empstat_>
	generate byte empstat = .
	replace empstat = 1 if inrange(P04C06, 1, 4)
	replace empstat = 4 if inlist(P04C06, 5, 7)
	replace empstat = 3 if inlist(P04C06, 6, 8)
	replace empstat = 2 if P04C06 == 9
	replace empstat = . if lstatus != 1
	label define lblempstat 1 "Paid employee" 2 "Non-paid employee" ///
	    3 "Employer" 4 "Self-employed" ///
	    5 "Other, workers not classifiable by status", replace
	label values empstat lblempstat
	label variable empstat "Employment status, primary job (7-day ref period)"
*</_empstat_>


*<_ocusec_>
	* Government employee is explicit; non-government statuses treated as private.
	generate byte ocusec = .
	replace ocusec = 1 if P04C06 == 1
	replace ocusec = 2 if inrange(P04C06, 2, 9)
	replace ocusec = . if lstatus != 1
	label define lblocusec 1 "Public Sector, Central Government, Army" ///
	    2 "Private, NGO" 3 "State owned" ///
	    4 "Public or State-owned, but cannot distinguish", replace
	label values ocusec lblocusec
	label variable ocusec "Sector of activity, primary job (7-day ref period)"
*</_ocusec_>


*<_industry_orig_>
	generate industry_orig = strtrim(string(P04C04B_2D, "%18.0f")) ///
	    if lstatus == 1 & !missing(P04C04B_2D)
	label variable industry_orig "Original industry code, primary job"
*</_industry_orig_>


*<_industrycat_isic_>
	generate industrycat_isic = string(P04C04B_2D, "%02.0f") + "00" ///
	    if lstatus == 1 & inrange(P04C04B_2D, 1, 99)
	label variable industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	generate byte industrycat10 = .
	replace industrycat10 = 1 if inrange(P04C04B_2D, 1, 3)
	replace industrycat10 = 2 if inrange(P04C04B_2D, 5, 9)
	replace industrycat10 = 3 if inrange(P04C04B_2D, 10, 33)
	replace industrycat10 = 4 if inrange(P04C04B_2D, 35, 39)
	replace industrycat10 = 5 if inrange(P04C04B_2D, 41, 43)
	replace industrycat10 = 6 if ///
	    inrange(P04C04B_2D, 45, 47) | inrange(P04C04B_2D, 55, 56)
	replace industrycat10 = 7 if ///
	    inrange(P04C04B_2D, 49, 53) | inrange(P04C04B_2D, 58, 63)
	replace industrycat10 = 8 if inrange(P04C04B_2D, 64, 66) | ///
	    inrange(P04C04B_2D, 68, 75) | inrange(P04C04B_2D, 77, 82)
	replace industrycat10 = 9 if P04C04B_2D == 84
	replace industrycat10 = 10 if inrange(P04C04B_2D, 85, 99)
	replace industrycat10 = . if lstatus != 1
	label define lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" ///
	    4 "Public utilities" 5 "Construction" 6 "Commerce" ///
	    7 "Transport and Communications" 8 "Financial and Business Services" ///
	    9 "Public Administration" 10 "Other Services, Unspecified", replace
	label values industrycat10 lblindustrycat10
	label variable industrycat10 "1 digit industry classification, primary job"
*</_industrycat10_>


*<_industrycat4_>
	generate byte industrycat4 = industrycat10
	recode industrycat4 (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label define lblindustrycat4 1 "Agriculture" 2 "Industry" ///
	    3 "Services" 4 "Other", replace
	label values industrycat4 lblindustrycat4
	label variable industrycat4 "Broad Economic Activities, primary job"
*</_industrycat4_>


*<_occup_orig_>
	generate occup_orig = strtrim(string(P04C02B_2D, "%18.0f")) ///
	    if lstatus == 1 & !missing(P04C02B_2D)
	label variable occup_orig "Original occupation record, primary job"
*</_occup_orig_>


*<_occup_isco_>
	generate occup_isco = string(P04C02B_2D * 100, "%04.0f") ///
	    if lstatus == 1 & inrange(P04C02B_2D, 0, 99)
	label variable occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	generate byte occup = real(substr(occup_isco, 1, 1))
	replace occup = 10 if occup == 0
	label define lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" ///
	    4 "Clerks" 5 "Service and market sales workers" ///
	    6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" ///
	    9 "Elementary occupations" 10 "Armed forces" 99 "Others", replace
	label values occup lbloccup
	label variable occup "1 digit occupational classification, primary job"
*</_occup_>


*<_occup_skill_>
	generate byte occup_skill = .
	replace occup_skill = 3 if inrange(occup, 1, 3)
	replace occup_skill = 2 if inrange(occup, 4, 8)
	replace occup_skill = 1 if occup == 9
	label define lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill", replace
	label values occup_skill lblskill
	label variable occup_skill "Skill based on ISCO standard, primary job"
*</_occup_skill_>


*<_wage_no_compen_>
	* Monthly salary, overtime, commissions and food/housing/transport benefits;
	* independent agricultural profit is a monthly average over the last year.
	egen double _earn_D = rowtotal(P04C10 P04C11C P04C12B P04C18B P04C19B P04C20B), missing
	egen double _earn_E = rowtotal(P04C22 P04C23), missing
	egen double wage_no_compen = rowtotal(_earn_D _earn_E), missing
	replace wage_no_compen = . if !inrange(age, 15, 120) ///
	    | !inlist(P04C06, 1, 2, 3, 4, 5, 6, 7, 8) | lstatus != 1
	drop _earn_D _earn_E
	label variable wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
	generate byte unitwage = 5 if !missing(wage_no_compen)
	label define lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" ///
	    4 "Twice monthly" 5 "Monthly" 6 "Quarterly" 7 "Every six months" ///
	    8 "Annually" 9 "Hourly" 10 "Other", replace
	label values unitwage lblunitwage
	label variable unitwage "Last wages' time unit, primary job"
*</_unitwage_>


*<_whours_>
	* C28 records usual daily hours, not actual hours in the previous week.
	egen double whours = rowtotal(P04C28A P04C28B P04C28C P04C28D ///
	    P04C28E P04C28F P04C28G), missing
	replace whours = . if lstatus != 1
	label variable whours "Hours of work in last week, primary job"
*</_whours_>


*<_wmonths_>
	* Tenure is not months worked or paid in the last year.
	generate double wmonths = .
	label variable wmonths "Months of work in past 12 months, primary job"
*</_wmonths_>


*<_wage_total_>
	generate double wage_total = .
	label variable wage_total "Annualized total wage, primary job"
*</_wage_total_>


*<_contract_>
	* Contract or appointment is broader than explicitly signed/written contract.
	generate byte contract = 0 if lstatus == 1
	replace contract = 1 if P04C07 == 1 & lstatus == 1
	label define lblcontract 0 "Without contract" 1 "With contract", replace
	label values contract lblcontract
	label variable contract "Employment has contract, primary job"
*</_contract_>


*<_healthins_>
	generate byte healthins = .
	label define lblhealthins 0 "Without health insurance" ///
	    1 "With health insurance", replace
	label values healthins lblhealthins
	label variable healthins "Employment has health insurance, primary job"
*</_healthins_>


*<_socialsec_>
	* IGSS affiliation proxy; coverage is not explicitly tied to this job.
	generate byte socialsec = .
	replace socialsec = 1 if P04C25A == 1 & lstatus == 1
	replace socialsec = 0 if inrange(P04C25A, 2, 4) & lstatus == 1
	label define lblsocialsec 0 "Without social security" ///
	    1 "With social security", replace
	label values socialsec lblsocialsec
	label variable socialsec "Employment has social security, primary job"
*</_socialsec_>


*<_union_>
	generate byte union = 0 if lstatus == 1
	replace union = 1 if P04C09B == 1 & lstatus == 1
	label define lblunion 0 "Not union member" 1 "Union member", replace
	label values union lblunion
	label variable union "Union membership, primary job"
*</_union_>


*<_firmsize_l_>
	* Continuous headcount, not the later ENEIC bracket codes.
	generate double firmsize_l = P04C05 if lstatus == 1 & ///
	    P04C05 >= 1 & !missing(P04C05)
	label variable firmsize_l "Firm size (lower bracket), primary job"
*</_firmsize_l_>


*<_firmsize_u_>
	generate double firmsize_u = firmsize_l
	label variable firmsize_u "Firm size (upper bracket), primary job"
*</_firmsize_u_>


*----------8.3: 7 day reference secondary job---------------------------------*

*<_empstat_2_>
	generate byte empstat_2 = .
	replace empstat_2 = 1 if inrange(P04D05, 1, 4)
	replace empstat_2 = 4 if inlist(P04D05, 5, 7)
	replace empstat_2 = 3 if inlist(P04D05, 6, 8)
	replace empstat_2 = 2 if P04D05 == 9
	replace empstat_2 = . if lstatus != 1
	label values empstat_2 lblempstat
	label variable empstat_2 "Employment status, secondary job"
*</_empstat_2_>


*<_ocusec_2_>
	generate byte ocusec_2 = .
	replace ocusec_2 = 1 if P04D05 == 1
	replace ocusec_2 = 2 if inrange(P04D05, 2, 9)
	replace ocusec_2 = . if lstatus != 1
	label values ocusec_2 lblocusec
	label variable ocusec_2 "Sector of activity, secondary job"
*</_ocusec_2_>


*<_industry_orig_2_>
	generate industry_orig_2 = strtrim(string(P04D04B_2D, "%18.0f")) ///
	    if lstatus == 1 & !missing(P04D04B_2D)
	label variable industry_orig_2 "Original industry code, secondary job"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	generate industrycat_isic_2 = string(P04D04B_2D, "%02.0f") + "00" ///
	    if lstatus == 1 & inrange(P04D04B_2D, 1, 99)
	label variable industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	generate byte industrycat10_2 = .
	replace industrycat10_2 = 1 if inrange(P04D04B_2D, 1, 3)
	replace industrycat10_2 = 2 if inrange(P04D04B_2D, 5, 9)
	replace industrycat10_2 = 3 if inrange(P04D04B_2D, 10, 33)
	replace industrycat10_2 = 4 if inrange(P04D04B_2D, 35, 39)
	replace industrycat10_2 = 5 if inrange(P04D04B_2D, 41, 43)
	replace industrycat10_2 = 6 if ///
	    inrange(P04D04B_2D, 45, 47) | inrange(P04D04B_2D, 55, 56)
	replace industrycat10_2 = 7 if ///
	    inrange(P04D04B_2D, 49, 53) | inrange(P04D04B_2D, 58, 63)
	replace industrycat10_2 = 8 if inrange(P04D04B_2D, 64, 66) | ///
	    inrange(P04D04B_2D, 68, 75) | inrange(P04D04B_2D, 77, 82)
	replace industrycat10_2 = 9 if P04D04B_2D == 84
	replace industrycat10_2 = 10 if inrange(P04D04B_2D, 85, 99)
	replace industrycat10_2 = . if lstatus != 1
	label values industrycat10_2 lblindustrycat10
	label variable industrycat10_2 "1 digit industry classification, secondary job"
*</_industrycat10_2_>


*<_industrycat4_2_>
	generate byte industrycat4_2 = industrycat10_2
	recode industrycat4_2 (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label values industrycat4_2 lblindustrycat4
	label variable industrycat4_2 "Broad Economic Activities, secondary job"
*</_industrycat4_2_>


*<_occup_orig_2_>
	generate occup_orig_2 = strtrim(string(P04D02B_2D, "%18.0f")) ///
	    if lstatus == 1 & !missing(P04D02B_2D)
	label variable occup_orig_2 "Original occupation record, secondary job"
*</_occup_orig_2_>


*<_occup_isco_2_>
	generate occup_isco_2 = string(P04D02B_2D * 100, "%04.0f") ///
	    if lstatus == 1 & inrange(P04D02B_2D, 0, 99)
	label variable occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_2_>
	generate byte occup_2 = real(substr(occup_isco_2, 1, 1))
	replace occup_2 = 10 if occup_2 == 0
	label values occup_2 lbloccup
	label variable occup_2 "1 digit occupational classification, secondary job"
*</_occup_2_>


*<_occup_skill_2_>
	generate byte occup_skill_2 = .
	replace occup_skill_2 = 3 if inrange(occup_2, 1, 3)
	replace occup_skill_2 = 2 if inrange(occup_2, 4, 8)
	replace occup_skill_2 = 1 if occup_2 == 9
	label values occup_skill_2 lblskill
	label variable occup_skill_2 "Skill based on ISCO standard, secondary job"
*</_occup_skill_2_>


*<_wage_no_compen_2_>
	generate double wage_no_compen_2 = .
	replace wage_no_compen_2 = P04D06 if empstat_2 == 1
	replace wage_no_compen_2 = P04D12 if inlist(P04D05, 5, 6) & lstatus == 1
	replace wage_no_compen_2 = P04D13 if inlist(P04D05, 7, 8) & lstatus == 1
	replace wage_no_compen_2 = 0 if empstat_2 == 2
	replace wage_no_compen_2 = . if missing(empstat_2) | lstatus != 1
	label variable wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	generate byte unitwage_2 = 5 if !missing(wage_no_compen_2) & empstat_2 != 2
	label values unitwage_2 lblunitwage
	label variable unitwage_2 "Last wages' time unit, secondary job"
*</_unitwage_2_>


*<_whours_2_>
	generate double whours_2 = P04D16 if lstatus == 1 & ///
	    P04D16 >= 0 & !missing(P04D16)
	label variable whours_2 "Hours of work in last week, secondary job"
*</_whours_2_>


*<_wmonths_2_>
	generate double wmonths_2 = .
	label variable wmonths_2 "Months of work in past 12 months, secondary job"
*</_wmonths_2_>


*<_wage_total_2_>
	generate double wage_total_2 = .
	label variable wage_total_2 "Annualized total wage, secondary job"
*</_wage_total_2_>


*<_firmsize_l_2_>
	generate double firmsize_l_2 = P04D15 if lstatus == 1 & ///
	    P04D15 >= 1 & !missing(P04D15)
	label variable firmsize_l_2 "Firm size (lower bracket), secondary job"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	generate double firmsize_u_2 = firmsize_l_2
	label variable firmsize_u_2 "Firm size (upper bracket), secondary job"
*</_firmsize_u_2_>

*----------8.4: 7 day reference additional jobs--------------------------------*

*<_t_hours_others_>
	generate double t_hours_others = .
	label variable t_hours_others "Annualized hours worked in all but primary and secondary jobs 7 day recall"
*</_t_hours_others_>


*<_t_wage_nocompen_others_>
	generate double t_wage_nocompen_others = .
	label variable t_wage_nocompen_others "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_others_>


*<_t_wage_others_>
	generate double t_wage_others = .
	label variable t_wage_others "Annualized wage in all but primary and secondary jobs (7-day recall)"
*</_t_wage_others_>

*----------8.5: 7 day reference total summary----------------------------------*

*<_t_hours_total_>
	generate double t_hours_total = .
	label variable t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
	generate double t_wage_nocompen_total = .
	label variable t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
	generate double t_wage_total = .
	label variable t_wage_total "Annualized total wage for all jobs 7 day recall"
*</_t_wage_total_>

*----------8.6: 12 month reference overall-------------------------------------*

*<_lstatus_year_>
	generate byte lstatus_year = .
	label variable lstatus_year "Labor status during last year"
*</_lstatus_year_>


*<_potential_lf_year_>
	generate byte potential_lf_year = .
	label variable potential_lf_year "Potential labour force status"
*</_potential_lf_year_>


*<_underemployment_year_>
	generate byte underemployment_year = .
	label variable underemployment_year "Underemployment status"
*</_underemployment_year_>


*<_nlfreason_year_>
	generate byte nlfreason_year = .
	label variable nlfreason_year "Reason not in the labor force"
*</_nlfreason_year_>


*<_unempldur_l_year_>
	generate double unempldur_l_year = .
	label variable unempldur_l_year "Unemployment duration (months) lower bracket"
*</_unempldur_l_year_>


*<_unempldur_u_year_>
	generate double unempldur_u_year = .
	label variable unempldur_u_year "Unemployment duration (months) upper bracket"
*</_unempldur_u_year_>

*----------8.7: 12 month reference main job------------------------------------*

*<_empstat_year_>
	generate byte empstat_year = .
	label variable empstat_year "Employment status during past week primary job 12 month recall"
*</_empstat_year_>


*<_ocusec_year_>
	generate byte ocusec_year = .
	label variable ocusec_year "Sector of activity primary job 12 month recall"
*</_ocusec_year_>


*<_industry_orig_year_>
	generate str1 industry_orig_year = ""
	label variable industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	generate str1 industrycat_isic_year = ""
	label variable industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>


*<_industrycat10_year_>
	generate byte industrycat10_year = .
	label variable industrycat10_year "1 digit industry classification, primary job 12 month recall"
*</_industrycat10_year_>


*<_industrycat4_year_>
	generate byte industrycat4_year = .
	label variable industrycat4_year "Broad Economic Activities classification, primary job 12 month recall"
*</_industrycat4_year_>


*<_occup_orig_year_>
	generate str1 occup_orig_year = ""
	label variable occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	generate str1 occup_isco_year = ""
	label variable occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_year_>
	generate byte occup_year = .
	label variable occup_year "1 digit occupational classification, primary job 12 month recall"
*</_occup_year_>


*<_occup_skill_year_>
	generate byte occup_skill_year = .
	label variable occup_skill_year "Skill based on ISCO standard primary job 12 month recall"
*</_occup_skill_year_>


*<_wage_no_compen_year_>
	generate double wage_no_compen_year = .
	label variable wage_no_compen_year "Last wage payment primary job 12 month recall"
*</_wage_no_compen_year_>


*<_unitwage_year_>
	generate byte unitwage_year = .
	label variable unitwage_year "Last wages' time unit primary job 12 month recall"
*</_unitwage_year_>


*<_whours_year_>
	generate double whours_year = .
	label variable whours_year "Hours of work in last week primary job 12 month recall"
*</_whours_year_>


*<_wmonths_year_>
	generate double wmonths_year = .
	label variable wmonths_year "Months of work in past 12 months primary job 12 month recall"
*</_wmonths_year_>


*<_wage_total_year_>
	generate double wage_total_year = .
	label variable wage_total_year "Annualized total wage primary job 12 month recall"
*</_wage_total_year_>


*<_contract_year_>
	generate byte contract_year = .
	label variable contract_year "Employment has contract primary job 12 month recall"
*</_contract_year_>


*<_healthins_year_>
	generate byte healthins_year = .
	label variable healthins_year "Employment has health insurance primary job 12 month recall"
*</_healthins_year_>


*<_socialsec_year_>
	generate byte socialsec_year = .
	label variable socialsec_year "Employment has social security insurance primary job 12 month recall"
*</_socialsec_year_>


*<_union_year_>
	generate byte union_year = .
	label variable union_year "Union membership at primary job 12 month recall"
*</_union_year_>


*<_firmsize_l_year_>
	generate double firmsize_l_year = .
	label variable firmsize_l_year "Firm size (lower bracket) primary job 12 month recall"
*</_firmsize_l_year_>


*<_firmsize_u_year_>
	generate double firmsize_u_year = .
	label variable firmsize_u_year "Firm size (upper bracket) primary job 12 month recall"
*</_firmsize_u_year_>

*----------8.8: 12 month reference secondary job-------------------------------*

*<_empstat_2_year_>
	generate byte empstat_2_year = .
	label variable empstat_2_year "Employment status during past week secondary job 12 month recall"
*</_empstat_2_year_>


*<_ocusec_2_year_>
	generate byte ocusec_2_year = .
	label variable ocusec_2_year "Sector of activity secondary job 12 month recall"
*</_ocusec_2_year_>


*<_industry_orig_2_year_>
	generate str1 industry_orig_2_year = ""
	label variable industry_orig_2_year "Original survey industry code, secondary job 12 month recall"
*</_industry_orig_2_year_>


*<_industrycat_isic_2_year_>
	generate str1 industrycat_isic_2_year = ""
	label variable industrycat_isic_2_year "ISIC code of secondary job 12 month recall"
*</_industrycat_isic_2_year_>


*<_industrycat10_2_year_>
	generate byte industrycat10_2_year = .
	label variable industrycat10_2_year "1 digit industry classification, secondary job 12 month recall"
*</_industrycat10_2_year_>


*<_industrycat4_2_year_>
	generate byte industrycat4_2_year = .
	label variable industrycat4_2_year "Broad Economic Activities classification, secondary job 12 month recall"
*</_industrycat4_2_year_>


*<_occup_orig_2_year_>
	generate str1 occup_orig_2_year = ""
	label variable occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
	generate str1 occup_isco_2_year = ""
	label variable occup_isco_2_year "ISCO code of secondary job 12 month recall"
*</_occup_isco_2_year_>


*<_occup_2_year_>
	generate byte occup_2_year = .
	label variable occup_2_year "1 digit occupational classification, secondary job 12 month recall"
*</_occup_2_year_>


*<_occup_skill_2_year_>
	generate byte occup_skill_2_year = .
	label variable occup_skill_2_year "Skill based on ISCO standard secondary job 12 month recall"
*</_occup_skill_2_year_>


*<_wage_no_compen_2_year_>
	generate double wage_no_compen_2_year = .
	label variable wage_no_compen_2_year "Last wage payment secondary job 12 month recall"
*</_wage_no_compen_2_year_>


*<_unitwage_2_year_>
	generate byte unitwage_2_year = .
	label variable unitwage_2_year "Last wages' time unit secondary job 12 month recall"
*</_unitwage_2_year_>


*<_whours_2_year_>
	generate double whours_2_year = .
	label variable whours_2_year "Hours of work in last week secondary job 12 month recall"
*</_whours_2_year_>


*<_wmonths_2_year_>
	generate double wmonths_2_year = .
	label variable wmonths_2_year "Months of work in past 12 months secondary job 12 month recall"
*</_wmonths_2_year_>


*<_wage_total_2_year_>
	generate double wage_total_2_year = .
	label variable wage_total_2_year "Annualized total wage secondary job 12 month recall"
*</_wage_total_2_year_>


*<_firmsize_l_2_year_>
	generate double firmsize_l_2_year = .
	label variable firmsize_l_2_year "Firm size (lower bracket) secondary job 12 month recall"
*</_firmsize_l_2_year_>


*<_firmsize_u_2_year_>
	generate double firmsize_u_2_year = .
	label variable firmsize_u_2_year "Firm size (upper bracket) secondary job 12 month recall"
*</_firmsize_u_2_year_>

*----------8.9: 12 month reference additional jobs-----------------------------*

*<_t_hours_others_year_>
	generate double t_hours_others_year = .
	label variable t_hours_others_year "Annualized hours worked in all but primary and secondary jobs 12 month recall"
*</_t_hours_others_year_>


*<_t_wage_nocompen_others_year_>
	generate double t_wage_nocompen_others_year = .
	label variable t_wage_nocompen_others_year "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_others_year_>


*<_t_wage_others_year_>
	generate double t_wage_others_year = .
	label variable t_wage_others_year "Annualized wage in all but primary and secondary jobs 12 month recall"
*</_t_wage_others_year_>

*----------8.10: 12 month total summary----------------------------------------*

*<_t_hours_total_year_>
	generate double t_hours_total_year = .
	label variable t_hours_total_year "Annualized hours worked in all jobs 12 month recall"
*</_t_hours_total_year_>


*<_t_wage_nocompen_total_year_>
	generate double t_wage_nocompen_total_year = .
	label variable t_wage_nocompen_total_year "Annualized wage in all jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_total_year_>


*<_t_wage_total_year_>
	generate double t_wage_total_year = .
	label variable t_wage_total_year "Annualized total wage for all jobs 12 month recall"
*</_t_wage_total_year_>

*----------8.11: Overall across reference periods-----------------------------*

*<_njobs_>
	* Source code 3 means three or more; an exact number is not established.
	generate byte njobs = P04C01 if lstatus == 1 & inlist(P04C01, 1, 2)
	label variable njobs "Total number of jobs"
*</_njobs_>


*<_t_hours_annual_>
	generate double t_hours_annual = .
	label variable t_hours_annual "Total hours worked in all jobs in the previous 12 months"
*</_t_hours_annual_>


*<_linc_nc_>
	generate double linc_nc = .
	label variable linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."
*</_linc_nc_>


*<_laborincome_>
	generate double laborincome = .
	label variable laborincome "Total annual individual labor income in all jobs, incl. bonuses, etc."
*</_laborincome_>


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