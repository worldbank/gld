
/*%%=============================================================================================
    0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>                HND_2021_EPHPM_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>                 Stata </_Application_>
<_Author(s)_>                   World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>                2026-06-11 </_Date created_>

-------------------------------------------------------------------------

<_Country_>                     Honduras (HND) </_Country_>
<_Survey Title_>                Encuesta Permanente de Hogares de Propositos Multiples </_Survey Title_>
<_Survey Year_>                 2021 </_Survey Year_>
<_Source of dataset_>           INE Honduras </_Source of dataset_>
<_Currency_>                    Lempira </_Currency_>

-------------------------------------------------------------------------

<_ICLS Version_>                ICLS-13 </_ICLS Version_>
<_ISCED Version_>               Not coded; no documented ISCED crosswalk in the report </_ISCED Version_>
<_ISCO Version_>                ISCO-08, inferred from report-supported classification checks </_ISCO Version_>
<_ISIC Version_>                ISIC Rev. 4, inferred from report-supported classification checks </_ISIC Version_>

-------------------------------------------------------------------------
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
version 17

*----------1.2: Set directories------------------------------*

if "`c(username)'" == "wb510859" {
	local server "C:/Users/`c(username)'/OneDrive - WBG/GLD - Current Contributors/510859_AS"
}
else {
	local server "C:/Users/`c(username)'/WBG/GLD - Current Contributors/510859_AS"
}
local country "HND"
local year    "2021"
local survey  "EPHPM"
local vermast "V01"
local veralt  "V01"

local level_1      "`country'_`year'_`survey'"
local level_2_mast "`level_1'_`vermast'_M"
local level_2_harm "`level_1'_`vermast'_M_`veralt'_A_GLD"

local path_in_stata "`server'/`country'/`level_1'/`level_2_mast'/Data/Stata"
local path_in_other "`server'/`country'/`level_1'/`level_2_mast'/Data/Original"
local path_output   "`server'/`country'/`level_1'/`level_2_harm'/Data/Harmonized"

capture mkdir "`path_output'"

*----------1.3: Database assembly------------------------------*

use "`path_in_stata'/HOGARES_OCTUBRE_2021R.dta", clear

/*%%=============================================================================================
    2: Helpers
==============================================================================================%%*/

{
    foreach v of varlist _all {
        capture confirm numeric variable `v'
        if !_rc {
            capture replace `v' = . if inlist(`v', 78888, 99999, 999999, 9999999, 99999999)
            capture replace `v' = . if `v' >= 999999999999999
        }
    }
}

/*%%=============================================================================================
    3: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
    gen str3 countrycode = "HND"
    label var countrycode "Country code"
*</_countrycode_>

*<_survname_>
    gen str10 survname = "EPHPM"
    label var survname "Survey acronym"
*</_survname_>

*<_survey_>
    gen str10 survey = "EPHPM"
    label var survey "Survey type"
*</_survey_>

*<_icls_v_>
    gen str20 icls_v = "ICLS-13"
    label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>

*<_isced_version_>
    gen str20 isced_version = ""
    label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>

*<_isco_version_>
    gen str20 isco_version = "isco_2008"
    label var isco_version "Version of ISCO used"
*</_isco_version_>

*<_isic_version_>
    gen str20 isic_version = "isic_4"
    label var isic_version "Version of ISIC used"
*</_isic_version_>

*<_year_>
    gen int year = 2021
    label var year "Year of survey"
*</_year_>

*<_vermast_>
    gen str3 vermast = "V01"
    label var vermast "Version of master data"
*</_vermast_>

*<_veralt_>
    gen str3 veralt = "V01"
    label var veralt "Version of the alt/harmonized data"
*</_veralt_>

*<_harmonization_>
    gen str3 harmonization = "GLD"
    label var harmonization "Type of harmonization"
*</_harmonization_>

*<_int_year_>
    gen int int_year = 2021
    label var int_year "Year of the interview"
*</_int_year_>

*<_int_month_>
    gen byte int_month = 10
    label define lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December", replace
    label values int_month lblint_month
    label var int_month "Month of the interview"
*</_int_month_>

*<_hhid_>
/* <_hhid_note>
    The adjacent-year report shows that `Boleta` is the 2021 household index.
    `Boleta Nper` is not unique at the person level, so `Boleta` is used only
    for hhid and `_v1` is used for pid.
</_hhid_note> */
    gen str20 hhid = strtrim(string(Boleta, "%12.0f"))
    label var hhid "Household ID"
*</_hhid_>

*<_pid_>
/* <_pid_note>
    `_v1` is unique in the 2021 raw file. Candidate keys based on household
    identifiers and Nper leave duplicate person records.
</_pid_note> */
    gen str40 pid = strtrim(string(_v1, "%12.0f"))
    isid pid
    label var pid "Individual ID"
*</_pid_>

*<_weight_>
    gen double weight = FACTOR
    label var weight "Survey sampling weight"
*</_weight_>

*<_weight_m_>
    gen double weight_m = .
    label var weight_m "Survey sampling weight to obtain national estimates for each month"
*</_weight_m_>

*<_weight_q_>
    gen double weight_q = .
    label var weight_q "Survey sampling weight to obtain national estimates for each quarter"
*</_weight_q_>

*<_psu_>
    gen long psu = cor_pre
    label var psu "Primary sampling units"
*</_psu_>

*<_ssu_>
    gen byte ssu = num_rec
    label var ssu "Secondary sampling units"
*</_ssu_>

*<_strata_>
    gen byte strata = dominio
    label var strata "Strata"
*</_strata_>

*<_wave_>
    gen byte wave = .
    label var wave "Survey wave"
*</_wave_>

*<_panel_>
    gen byte panel = .
    label var panel "Panel identifier"
*</_panel_>

*<_visit_no_>
    gen byte visit_no = .
    label var visit_no "Visit number"
*</_visit_no_>

}

/*%%=============================================================================================
    3: Geography
==============================================================================================%%*/

{

*<_urban_>
    gen byte urban = .
    replace urban = 1 if UR == 1
    replace urban = 0 if UR == 2
    label define lblurban 1 "Urban" 0 "Rural", replace
    label values urban lblurban
    label var urban "Location is urban"
*</_urban_>

*<_subnatid1_>
    decode DEPTO, gen(_depto_name)
    gen str80 region_est2 = ""
    replace region_est2 = string(DEPTO, "%02.0f") + " - " + proper(_depto_name) if !missing(DEPTO)
    gen str80 subnatid1 = region_est2
    label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>

*<_subnatid2_>
    decode MUNIC, gen(_munic_name)
    gen str80 subnatid2 = ""
    replace subnatid2 = string(MUNIC, "%04.0f") + " - " + proper(_munic_name) if !missing(MUNIC)
    label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>

*<_subnatid3_>
    gen str80 subnatid3 = ""
    label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>

*<_subnatidsurvey_>
    decode dominio, gen(_dominio_name)
    gen str80 subnatidsurvey = string(dominio, "%02.0f") + " - " + _dominio_name if !missing(dominio)
    label var subnatidsurvey "Survey representative area"
*</_subnatidsurvey_>

foreach v in subnatid1_prev subnatid2_prev subnatid3_prev migrated_from_code migrated_from_country {
    gen str80 `v' = ""
}
foreach v in gaul_adm1_code gaul_adm2_code gaul_adm3_code {
    gen int `v' = .
}
label var subnatid1_prev "Previous Subnational ID at First Administrative Level"
label var subnatid2_prev "Previous Subnational ID at Second Administrative Level"
label var subnatid3_prev "Previous Subnational ID at Third Administrative Level"
label var gaul_adm1_code "GAUL first-level administrative code"
label var gaul_adm2_code "GAUL second-level administrative code"
label var gaul_adm3_code "GAUL third-level administrative code"

}

/*%%=============================================================================================
    4: Demographics
==============================================================================================%%*/

{

*<_hsize_>
    bysort hhid: gen int hsize = _N
    label var hsize "Household size"
*</_hsize_>

*<_age_>
    gen int age = EDAD if EDAD < .
    replace age = . if age > 120
    label var age "Age"
*</_age_>

*<_male_>
    gen byte male = .
    replace male = 1 if C03 == 1
    replace male = 0 if C03 == 2
    label define lblmale 1 "Male" 0 "Female", replace
    label values male lblmale
    label var male "Male"
*</_male_>

*<_relationharm_>
/* <_relationharm_note>
    The raw relationship code yields a small number of households with more
    than one reported head. GLD headship fallback keeps the priority head by
    reported head status, male, and age, and recodes extra reported heads to
    other non-relative.
</_relationharm_note> */
    gen byte relationharm = .
    replace relationharm = 1 if RELA_J == 1
    replace relationharm = 2 if RELA_J == 2
    replace relationharm = 3 if inlist(RELA_J, 3, 4)
    replace relationharm = 4 if inlist(RELA_J, 5, 6, 7, 8)
    replace relationharm = 5 if inlist(RELA_J, 9, 10)
    gen byte _reported_head = relationharm == 1 if !missing(relationharm)
    bysort hhid: egen byte _nheads = total(_reported_head)
    gen byte _head_priority = _reported_head
    gsort hhid -_head_priority -male -age
    by hhid: gen long _hh_rank = _n
    replace relationharm = 1 if _nheads == 0 & _hh_rank == 1
    replace relationharm = 5 if _nheads > 1 & _reported_head == 1
    replace relationharm = 1 if _nheads > 1 & _hh_rank == 1
    sort pid
    drop _reported_head _nheads _head_priority _hh_rank
    label define lblrelationharm 1 "Head" 2 "Spouse" 3 "Child" 4 "Other relative" 5 "Other non-relative", replace
    label values relationharm lblrelationharm
    label var relationharm "Relationship to household head"
*</_relationharm_>

*<_relationcs_>
    gen byte relationcs = relationharm
    label values relationcs lblrelationharm
    label var relationcs "Relationship to household head original categories"
*</_relationcs_>

*<_marital_>
    gen byte marital = .
    replace marital = 1 if inlist(CIVIL, 1, 6)
    replace marital = 2 if CIVIL == 5
    replace marital = 3 if inlist(CIVIL, 2, 3, 4)
    label define lblmarital 1 "Married/union" 2 "Never married" 3 "Divorced/separated/widowed", replace
    label values marital lblmarital
    label var marital "Marital status"
*</_marital_>

foreach v in eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty {
    gen byte `v' = .
}
label var eye_dsablty "Vision difficulty"
label var hear_dsablty "Hearing difficulty"
label var walk_dsablty "Walking difficulty"
label var conc_dsord "Concentrating difficulty"
label var slfcre_dsablty "Self-care difficulty"
label var comm_dsablty "Communicating difficulty"

}

/*%%=============================================================================================
    5: Migration
==============================================================================================%%*/

{

foreach v in migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_reason {
    gen byte `v' = .
}
label var migrated_mod_age "Migration module age"
label var migrated_ref_time "Migration reference time"
label var migrated_binary "Migration status"
label var migrated_years "Years since migration"
label var migrated_from_urban "Migrated from urban area"
label var migrated_from_cat "Migration origin category"
label var migrated_reason "Reason for migration"
label var migrated_from_code "Migration origin code"
label var migrated_from_country "Migration origin country"

}

/*%%=============================================================================================
    6: Education
==============================================================================================%%*/

{

*<_ed_mod_age_>
    gen byte ed_mod_age = 5
    label var ed_mod_age "Education module application age"
*</_ed_mod_age_>

*<_school_>
    gen byte school = .
    replace school = 1 if CP405 == 1
    replace school = 0 if CP405 == 2
    label define lblschool 1 "Yes" 0 "No", replace
    label values school lblschool
    label var school "Currently in school"
*</_school_>

*<_literacy_>
    gen byte literacy = .
    replace literacy = 1 if P403 == 1
    replace literacy = 0 if P403 == 2
    label define lblliteracy 1 "Literate" 0 "Not literate", replace
    label values literacy lblliteracy
    label var literacy "Individual can read and write"
*</_literacy_>

*<_educy_>
    gen byte educy = .
    replace educy = ANOSEST if inrange(ANOSEST, 0, 22)
    replace educy = . if educy > age & !missing(educy, age)
    label var educy "Years of education"
*</_educy_>

*<_educat7_>
/* <_educat7_note>
    The 2021 attainment ladder uses CP407 for highest level reached. It splits
    Ciclo comun from Diversificado and combines postgraduate education into one
    category. The mapping follows the adjacent-year report and uses CP410/ANOSEST
    to split basic education where possible.
</_educat7_note> */
    gen byte educat7 = .
    replace educat7 = 1 if inlist(CP407, 1, 2, 3)
    replace educat7 = 2 if CP407 == 4 & (inrange(CP410, 1, 5) | inrange(ANOSEST, 1, 5))
    replace educat7 = 3 if CP407 == 4 & (CP410 == 6 | ANOSEST == 6)
    replace educat7 = 4 if CP407 == 4 & (inrange(CP410, 7, 9) | inrange(ANOSEST, 7, 9))
    replace educat7 = 4 if CP407 == 5
    replace educat7 = 4 if CP407 == 6 & P409 == 2
    replace educat7 = 5 if CP407 == 6 & P409 == 1
    replace educat7 = 6 if inlist(CP407, 7, 8)
    replace educat7 = 7 if inlist(CP407, 9, 10)
    replace educat7 = 1 if missing(educat7) & inlist(CP412, 2, 3)
    replace educat7 = 1 if missing(educat7) & CP412 == 4 & CP417 == 1
    replace educat7 = 2 if missing(educat7) & CP412 == 4 & inrange(CP417, 2, 6)
    replace educat7 = 3 if missing(educat7) & CP412 == 4 & CP417 == 7
    replace educat7 = 4 if missing(educat7) & CP412 == 4 & inrange(CP417, 8, 9)
    replace educat7 = 4 if missing(educat7) & inlist(CP412, 5, 6)
    replace educat7 = 6 if missing(educat7) & inlist(CP412, 7, 8)
    replace educat7 = 7 if missing(educat7) & inlist(CP412, 9, 10)
    replace educat7 = 1 if missing(educat7) & NIVEL == 1
    replace educat7 = 2 if missing(educat7) & NIVEL == 2 & inrange(ANOSEST, 1, 5)
    replace educat7 = 3 if missing(educat7) & NIVEL == 2 & ANOSEST == 6
    replace educat7 = 4 if missing(educat7) & NIVEL == 2 & inrange(ANOSEST, 7, 9)
    replace educat7 = 4 if missing(educat7) & NIVEL == 3 & ANOSEST < 12
    replace educat7 = 5 if missing(educat7) & NIVEL == 3 & ANOSEST >= 12 & ANOSEST < .
    replace educat7 = 7 if missing(educat7) & NIVEL == 4
    replace educat7 = . if CP407 == 11 | CP412 == 11 | NIVEL == 9
    label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete", replace
    label values educat7 lbleducat7
    label var educat7 "Level of education 1"
*</_educat7_>

*<_educat5_>
    gen byte educat5 = educat7
    recode educat5 (4 = 3) (5 = 4) (6 7 = 5)
    label define lbleducat5 1 "No education" 2 "Primary incomplete" 3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary", replace
    label values educat5 lbleducat5
    label var educat5 "Level of education 2"
*</_educat5_>

*<_educat4_>
    gen byte educat4 = educat7
    recode educat4 (2 3 4 = 2) (5 = 3) (6 7 = 4)
    label define lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary", replace
    label values educat4 lbleducat4
    label var educat4 "Level of education 3"
*</_educat4_>

*<_educat_orig_>
    gen int educat_orig = CP407
    replace educat_orig = CP412 if missing(educat_orig) & !missing(CP412)
    replace educat_orig = NIVEL if missing(educat_orig) & !missing(NIVEL)
    label var educat_orig "Original survey education code"
*</_educat_orig_>

*<_educat_isced_>
    gen byte educat_isced = .
    label var educat_isced "ISCED standardised level of education"
*</_educat_isced_>

foreach v in vocational vocational_type vocational_length_l vocational_length_u vocational_financed {
    gen byte `v' = .
}
gen str1 vocational_field_orig = ""
label var vocational "Vocational education"
label var vocational_type "Type of vocational education"
label var vocational_length_l "Vocational education duration lower bound"
label var vocational_length_u "Vocational education duration upper bound"
label var vocational_field_orig "Vocational field original"
label var vocational_financed "Vocational education financed"

}

/*%%=============================================================================================
    7: Labor status
==============================================================================================%%*/

{

*<_minlaborage_>
    gen byte minlaborage = 15
    label var minlaborage "Minimum age for labor module"
*</_minlaborage_>

*<_lstatus_>
/* <_lstatus_note>
    The adjacent-year report says to adapt the 2022 route-based labor rule to
    the 2021 P-variable names. CONDACT is used as a diagnostic check only.
</_lstatus_note> */
    gen byte _lab_eligible = age >= minlaborage if !missing(age)
    gen byte _emp_direct_paid = _lab_eligible == 1 & P501 == 1 & P502 == 1
    gen byte _emp_listed_activity = _lab_eligible == 1 & _emp_direct_paid == 0 & inrange(P503, 1, 9)
    gen byte _emp_abs_reason = _lab_eligible == 1 & _emp_direct_paid == 0 & _emp_listed_activity == 0 & P504 == 1 & inrange(P505, 1, 4)
    gen byte _emp_abs_paid = _lab_eligible == 1 & _emp_direct_paid == 0 & _emp_listed_activity == 0 & _emp_abs_reason == 0 & P504 == 1 & P506 == 1
    gen byte _emp_abs_short = _lab_eligible == 1 & _emp_direct_paid == 0 & _emp_listed_activity == 0 & _emp_abs_reason == 0 & _emp_abs_paid == 0 & P504 == 1 & inlist(P507, 1, 2)
    gen byte _emp_family = _lab_eligible == 1 & _emp_direct_paid == 0 & _emp_listed_activity == 0 & _emp_abs_reason == 0 & _emp_abs_paid == 0 & _emp_abs_short == 0 & P508 == 1
    gen byte _employed_route = _emp_direct_paid | _emp_listed_activity | _emp_abs_reason | _emp_abs_paid | _emp_abs_short | _emp_family
    gen byte _unemployed_route = _lab_eligible == 1 & _employed_route == 0 & inlist(P511, 1, 2) & (P512 == 1 | inlist(P513, 1, 2))
    gen byte _route_observed = _lab_eligible == 1 & !missing(P501)
    gen byte lstatus = .
    replace lstatus = 1 if _employed_route == 1
    replace lstatus = 2 if missing(lstatus) & _unemployed_route == 1
    replace lstatus = 3 if missing(lstatus) & _lab_eligible == 1 & _route_observed == 1
    replace lstatus = . if age < minlaborage & !missing(age)
    label define lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF", replace
    label values lstatus lbllstatus
    label var lstatus "Labor status"
*</_lstatus_>

*<_potential_lf_>
    gen byte potential_lf = .
    replace potential_lf = 0 if lstatus == 3
    replace potential_lf = 1 if lstatus == 3 & P512 == 1 & !inlist(P511, 1, 2, 9)
    replace potential_lf = 1 if lstatus == 3 & P512 == 2 & inlist(P511, 1, 2)
    replace potential_lf = 1 if lstatus == 3 & P510 == 1 & P512 == 2
    replace potential_lf = . if lstatus == 3 & P511 == 9
    label define lblpotential_lf 0 "No" 1 "Yes", replace
    label values potential_lf lblpotential_lf
    label var potential_lf "Potential labour force status"
*</_potential_lf_>

*<_underemployment_>
    gen byte underemployment = .
    replace underemployment = 0 if lstatus == 1
    replace underemployment = 1 if lstatus == 1 & P522 == 1 & P523 == 1
    label define lblunderemployment 0 "No" 1 "Yes", replace
    label values underemployment lblunderemployment
    label var underemployment "Underemployment status"
*</_underemployment_>

*<_nlfreason_>
    gen byte nlfreason = .
    replace nlfreason = 3 if lstatus == 3 & inlist(P514, 1, 2, 3)
    replace nlfreason = 1 if lstatus == 3 & P514 == 4
    replace nlfreason = 2 if lstatus == 3 & P514 == 5
    replace nlfreason = 5 if lstatus == 3 & P514 == 6
    replace nlfreason = 4 if lstatus == 3 & inlist(P514, 7, 8)
    replace nlfreason = 5 if lstatus == 3 & inlist(P514, 9, 10)
    label define lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other", replace
    label values nlfreason lblnlfreason
    label var nlfreason "Reason not in the labor force"
*</_nlfreason_>

*<_unempldur_l_>
    gen int unempldur_l = .
    replace unempldur_l = round(P516A / 30) if lstatus == 2 & P516B == 1
    replace unempldur_l = round(P516A / 4.345) if lstatus == 2 & P516B == 2
    replace unempldur_l = P516A if lstatus == 2 & P516B == 3
    label var unempldur_l "Unemployment duration lower bound"
*</_unempldur_l_>

*<_unempldur_u_>
    gen int unempldur_u = unempldur_l
    label var unempldur_u "Unemployment duration upper bound"
*</_unempldur_u_>

}

/*%%=============================================================================================
    8: Employment status, classifications, hours, and wages
==============================================================================================%%*/

{

*<_empstat_>
    gen byte empstat = .
    replace empstat = 1 if lstatus == 1 & inlist(P609, 1, 2, 3, 4, 8)
    replace empstat = 2 if lstatus == 1 & P609 == 7
    replace empstat = 3 if lstatus == 1 & P609 == 5
    replace empstat = 4 if lstatus == 1 & P609 == 6
    label define lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status", replace
    label values empstat lblempstat
    label var empstat "Employment status in primary job"
*</_empstat_>

*<_ocusec_>
    gen byte ocusec = .
    replace ocusec = 1 if lstatus == 1 & P609 == 1
    replace ocusec = 2 if lstatus == 1 & inlist(P609, 2, 3, 4, 5, 6, 7, 8)
    label define lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish", replace
    label values ocusec lblocusec
    label var ocusec "Sector of activity"
*</_ocusec_>

*<_industry_orig_>
    gen str20 industry_orig = ""
    replace industry_orig = strtrim(string(O02COD, "%12.0f")) if lstatus == 1 & O02COD < . & !inlist(O02COD, 9998001, 999999)
    label var industry_orig "Original industry record primary job 7 day recall"
*</_industry_orig_>

*<_industrycat_isic_>
    /*
    O02COD is a national activity code with ISIC Rev. 4 structure plus national
    detail. Six-digit codes store a hidden leading zero in the ISIC portion:
    111101 -> 0111, 810006 -> 0810. Seven-digit codes keep the first four
    digits as the ISIC portion. GLD retains only the corrected first two ISIC
    digits plus 00 so industrycat_isic and industrycat10 stay aligned.
    */
    tempvar indstr ind4 isic2
    gen str12 `indstr' = strtrim(string(O02COD, "%12.0f"))
    gen str4 `ind4' = ""
    replace `ind4' = "0" + substr(`indstr', 1, 3) if lstatus == 1 & length(`indstr') == 6
    replace `ind4' = substr(`indstr', 1, 4) if lstatus == 1 & length(`indstr') > 6
    gen str4 industrycat_isic = ""
    replace industrycat_isic = substr(`ind4', 1, 2) + "00" if lstatus == 1 & `ind4' != ""
    replace industrycat_isic = "" if inlist(O02COD, 9998001, 999999) | lstatus != 1
    label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>

*<_industrycat10_>
    gen byte `isic2' = real(substr(industrycat_isic, 1, 2)) if industrycat_isic != ""
    gen byte industrycat10 = .
    replace industrycat10 = 1 if inrange(`isic2', 1, 3)
    replace industrycat10 = 2 if inrange(`isic2', 5, 9)
    replace industrycat10 = 3 if inrange(`isic2', 10, 33)
    replace industrycat10 = 4 if inrange(`isic2', 35, 39)
    replace industrycat10 = 5 if inrange(`isic2', 41, 43)
    replace industrycat10 = 6 if inrange(`isic2', 45, 47) | inrange(`isic2', 55, 56)
    replace industrycat10 = 7 if inrange(`isic2', 49, 53) | inrange(`isic2', 58, 63)
    replace industrycat10 = 8 if inrange(`isic2', 64, 82)
    replace industrycat10 = 9 if `isic2' == 84
    replace industrycat10 = 10 if inrange(`isic2', 85, 99)
    replace industrycat10 = . if lstatus != 1
    label define lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction" 6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified", replace
    label values industrycat10 lblindustrycat10
    label var industrycat10 "1 digit industry classification, primary job 7 day recall"
*</_industrycat10_>

*<_industrycat4_>
    gen byte industrycat4 = industrycat10
    recode industrycat4 (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
    label define lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other", replace
    label values industrycat4 lblindustrycat4
    label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
*</_industrycat4_>

*<_occup_orig_>
    gen str20 occup_orig = ""
    replace occup_orig = strtrim(string(O01COD, "%12.0f")) if lstatus == 1 & O01COD < . & O01COD != 989901
    label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>

*<_occup_isco_>
    gen str20 _occstr = strtrim(string(O01COD, "%12.0f"))
    gen str4 occup_isco = ""
    replace occup_isco = string(OCUPAOP, "%1.0f") + "000" if lstatus == 1 & inrange(OCUPAOP, 1, 9)
    replace occup_isco = "0000" if lstatus == 1 & OCUPAOP == 10
    label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>

*<_occup_>
    gen byte occup = .
    replace occup = OCUPAOP if lstatus == 1 & inrange(OCUPAOP, 1, 10)
    label define lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces" 99 "Others", replace
    label values occup lbloccup
    label var occup "1 digit occupational classification, primary job 7 day recall"
*</_occup_>

*<_occup_skill_>
    gen byte occup_skill = .
    replace occup_skill = 3 if inrange(occup, 1, 3)
    replace occup_skill = 2 if inrange(occup, 4, 8)
    replace occup_skill = 1 if occup == 9
    label define lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill", replace
    label values occup_skill lblskill
    label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>

*<_whours_>
    egen whours = rowtotal(P605LU P605MA P605MI P605JU P605VI P605SA P605DO), missing
    replace whours = . if whours == 0
    replace whours = . if lstatus != 1
    label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>

*<_wage_no_compen_>
    gen double wage_no_compen = YTRAOP if lstatus == 1 & YTRAOP >= 0 & YTRAOP < .
    label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>

*<_unitwage_>
    gen byte unitwage = .
    replace unitwage = 5 if !missing(wage_no_compen)
    label define lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly" 5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other", replace
    label values unitwage lblunitwage
    label var unitwage "Last wages' time unit primary job 7 day recall"
*</_unitwage_>

*<_wmonths_>
    gen byte wmonths = .
    label var wmonths "Months worked in last year"
*</_wmonths_>

*<_wage_total_>
    gen double wage_total = .
    label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>

foreach v in contract healthins union {
    gen byte `v' = .
}
label var contract "Contract"
label var healthins "Health insurance"
label var union "Union membership"

*<_socialsec_>
/* <_socialsec_note>
The social-security item is not harmonized because the source meaning is not
consistent enough across survey years for a comparable GLD yes/no indicator.
</_socialsec_note> */
    gen byte socialsec = .
    label var socialsec "Employment has social security insurance primary job 7 day recall"
    label define lblsocialsec 1 "With social security" 0 "Without social secturity", replace
    label values socialsec lblsocialsec
*</_socialsec_>

*<_firmsize_>
    gen int firmsize_l = .
    gen int firmsize_u = .
    replace firmsize_l = 1 if lstatus == 1 & P608 == 1
    replace firmsize_u = 10 if lstatus == 1 & P608 == 1
    replace firmsize_l = 11 if lstatus == 1 & P608 == 2
    replace firmsize_u = 50 if lstatus == 1 & P608 == 2
    replace firmsize_l = 51 if lstatus == 1 & P608 == 3
    replace firmsize_u = 150 if lstatus == 1 & P608 == 3
    replace firmsize_l = 151 if lstatus == 1 & P608 == 4
    label var firmsize_l "Firm size (lower bound), primary job 7 day recall"
    label var firmsize_u "Firm size (upper bound), primary job 7 day recall"
*</_firmsize_>

*<_secondary_job_>
    gen byte njobs = .
    replace njobs = 1 if lstatus == 1 & P519 == 1
    replace njobs = P519 if lstatus == 1 & P519 > 1 & P519 < .
    label var njobs "Number of jobs"

    gen byte empstat_2 = .
    replace empstat_2 = 1 if lstatus == 1 & P519 > 1 & inlist(OSP609, 1, 2, 3, 4, 8)
    replace empstat_2 = 2 if lstatus == 1 & P519 > 1 & OSP609 == 7
    replace empstat_2 = 3 if lstatus == 1 & P519 > 1 & OSP609 == 5
    replace empstat_2 = 4 if lstatus == 1 & P519 > 1 & OSP609 == 6
    label values empstat_2 lblempstat
    label var empstat_2 "Employment status in secondary job"

    gen byte ocusec_2 = .
    replace ocusec_2 = 1 if lstatus == 1 & P519 > 1 & OSP609 == 1
    replace ocusec_2 = 2 if lstatus == 1 & P519 > 1 & inlist(OSP609, 2, 3, 4, 5, 6, 7, 8)
    label values ocusec_2 lblocusec
    label var ocusec_2 "Sector of activity, secondary job"

    gen str20 industry_orig_2 = ""
    replace industry_orig_2 = strtrim(string(OS02COD, "%12.0f")) if lstatus == 1 & P519 > 1 & OS02COD < . & OS02COD != 9998001
    gen str4 industrycat_isic_2 = ""
    gen str20 _indstr2 = strtrim(string(OS02COD, "%12.0f"))
    replace industrycat_isic_2 = substr(_indstr2, 1, 2) + "00" if lstatus == 1 & P519 > 1 & inlist(length(_indstr2), 6, 7) & OS02COD != 9998001
    gen byte industrycat10_2 = .
    replace industrycat10_2 = real(substr(industrycat_isic_2, 1, 2)) if industrycat_isic_2 != ""
    recode industrycat10_2 (1/3 = 1) (5/9 = 2) (10/33 = 3) (35/39 = 4) (41/43 = 5) (45/47 55/56 = 6) (49/53 58/63 = 7) (64/82 = 8) (84 = 9) (85/99 = 10)
    gen byte industrycat4_2 = industrycat10_2
    recode industrycat4_2 (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
    gen str20 occup_orig_2 = ""
    replace occup_orig_2 = strtrim(string(OS01COD, "%12.0f")) if lstatus == 1 & P519 > 1 & OS01COD < . & OS01COD != 989901
    gen str4 occup_isco_2 = ""
    gen str20 _occstr2 = strtrim(string(OS01COD, "%12.0f"))
    replace occup_isco_2 = substr(_occstr2, 1, 2) + "00" if lstatus == 1 & P519 > 1 & OS01COD < . & OS01COD != 989901
    replace occup_isco_2 = "" if inlist(substr(_occstr2, 1, 2), "05", "06", "98", "99")
    gen byte occup_2 = .
    replace occup_2 = real(substr(occup_isco_2, 1, 1)) if occup_isco_2 != "" & substr(occup_isco_2, 1, 1) != "0"
    replace occup_2 = 10 if occup_isco_2 != "" & substr(occup_isco_2, 1, 1) == "0"
    gen byte occup_skill_2 = .
    replace occup_skill_2 = 3 if inrange(occup_2, 1, 3)
    replace occup_skill_2 = 2 if inrange(occup_2, 4, 8)
    replace occup_skill_2 = 1 if occup_2 == 9
    label values industrycat10_2 lblindustrycat10
    label values industrycat4_2 lblindustrycat4
    label values occup_2 lbloccup
    label values occup_skill_2 lblskill
    label var industry_orig_2 "Original industry record secondary job 7 day recall"
    label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
    label var industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
    label var industrycat4_2 "Broad Economic Activities classification, secondary job 7 day recall"
    label var occup_orig_2 "Original occupation record secondary job 7 day recall"
    label var occup_isco_2 "ISCO code of secondary job 7 day recall"
    label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
    label var occup_2 "1 digit occupational classification, secondary job 7 day recall"

    egen whours_2 = rowtotal(OSP605LU OSP605MA OSP605MI OSP605JU OSP605VI OSP605SA OSP605DO), missing
    replace whours_2 = . if whours_2 == 0
    replace whours_2 = . if lstatus != 1 | P519 <= 1 | missing(P519)
    label var whours_2 "Hours of work in last week secondary job 7 day recall"

    tempvar sec_sal_cash sec_sal_inkind sec_self_cash sec_self_inkind
    gen double `sec_sal_cash' = OSP617 * OSP618 if OSP617 >= 0 & OSP617 < 999999 & OSP618 > 0 & OSP618 < 999999
    egen double `sec_sal_inkind' = rowtotal(OSP61901 OSP61902 OSP61903 OSP61904 OSP61905 OSP61906 OSP61907 OSP61908), missing
    replace `sec_sal_inkind' = . if `sec_sal_inkind' >= 999999
    gen double `sec_self_cash' = OSP628 if OSP628 >= 0 & OSP628 < 999999
    egen double `sec_self_inkind' = rowtotal(OSP630 OSP636), missing
    replace `sec_self_inkind' = . if `sec_self_inkind' >= 999999
    egen double wage_no_compen_2 = rowtotal(`sec_sal_cash' `sec_sal_inkind' `sec_self_cash' `sec_self_inkind'), missing
    replace wage_no_compen_2 = . if lstatus != 1 | P519 <= 1 | missing(P519)
    label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
    gen byte unitwage_2 = .
    replace unitwage_2 = 5 if !missing(wage_no_compen_2)
    label values unitwage_2 lblunitwage
    label var unitwage_2 "Last wages' time unit secondary job 7 day recall"

    gen double wage_total_2 = .
    label var wage_total_2 "Annualized total wage secondary job 7 day recall"
    gen byte wmonths_2 = .
    label var wmonths_2 "Months worked in last year, secondary job"
    gen int firmsize_l_2 = .
    gen int firmsize_u_2 = .
    replace firmsize_l_2 = 1 if lstatus == 1 & P519 > 1 & OSP608 == 1
    replace firmsize_u_2 = 10 if lstatus == 1 & P519 > 1 & OSP608 == 1
    replace firmsize_l_2 = 11 if lstatus == 1 & P519 > 1 & OSP608 == 2
    replace firmsize_u_2 = 50 if lstatus == 1 & P519 > 1 & OSP608 == 2
    replace firmsize_l_2 = 51 if lstatus == 1 & P519 > 1 & OSP608 == 3
    replace firmsize_u_2 = 150 if lstatus == 1 & P519 > 1 & OSP608 == 3
    replace firmsize_l_2 = 151 if lstatus == 1 & P519 > 1 & OSP608 == 4
    label var firmsize_l_2 "Firm size (lower bound), secondary job 7 day recall"
    label var firmsize_u_2 "Firm size (upper bound), secondary job 7 day recall"
*</_secondary_job_>

*<_totals_>
    gen double t_hours_others = whours_2
    gen double t_wage_nocompen_others = .
    gen double t_wage_others = wage_total_2
    egen t_hours_total = rowtotal(whours whours_2), missing
    gen double t_wage_nocompen_total = .
    egen t_wage_total = rowtotal(wage_total wage_total_2), missing
    label var t_hours_others "Hours of work in last week other jobs 7 day recall"
    label var t_wage_nocompen_others "Last wage payment other jobs 7 day recall"
    label var t_wage_others "Annualized wage other jobs 7 day recall"
    label var t_hours_total "Hours of work in last week all jobs 7 day recall"
    label var t_wage_nocompen_total "Last wage payment all jobs 7 day recall"
    label var t_wage_total "Annualized wage all jobs 7 day recall"
*</_totals_>

}

/*%%=============================================================================================
    9: Annual labor missing variables
==============================================================================================%%*/

{

foreach v in lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industrycat10_year industrycat4_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industrycat10_2_year industrycat4_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year {
    gen double `v' = .
}
foreach v in industry_orig_year industrycat_isic_year occup_orig_year occup_isco_year industry_orig_2_year industrycat_isic_2_year occup_orig_2_year occup_isco_2_year {
    gen str20 `v' = ""
}
gen double t_hours_annual = .
gen double linc_nc = .
gen double laborincome = .
label var t_hours_annual "Annual hours worked"
label var linc_nc "Labor income, no compensation"
label var laborincome "Labor income"

}

/*%%=============================================================================================
    10: Final keep, order, save
==============================================================================================%%*/

local keep_vars countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu ssu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

keep `keep_vars'
order `keep_vars'
compress
save "`path_output'/`level_2_harm'_ALL.dta", replace
