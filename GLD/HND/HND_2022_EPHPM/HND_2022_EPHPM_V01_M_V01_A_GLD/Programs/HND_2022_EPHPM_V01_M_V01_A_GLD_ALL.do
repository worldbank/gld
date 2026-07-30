/*%%=============================================================================================
    0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>                HND_2022_EPHPM_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>                 Stata </_Application_>
<_Author(s)_>                   World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>                2026-06-11 </_Date created_>

-------------------------------------------------------------------------

<_Country_>                     Honduras (HND) </_Country_>
<_Survey Title_>                Encuesta Permanente de Hogares de Propositos Multiples </_Survey Title_>
<_Survey Year_>                 2022 </_Survey Year_>
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

clear
set more off
set varabbrev off
version 17

if "`c(username)'" == "wb510859" {
	local server "C:/Users/`c(username)'/OneDrive - WBG/GLD - Current Contributors/625372_DB"
}
else {
	local server "C:/Users/`c(username)'/WBG/GLD - Current Contributors/625372_DB"
}
local country "HND"
local year    "2022"
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
use "`path_in_stata'/EPHPM2022.dta", clear


/*%%=============================================================================================
    2: Survey & ID
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
    gen str20 icls_v = "ICLS-19"
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
    gen int year = 2022
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
    gen int int_year = 2022
    label var int_year "Year of the interview"
*</_int_year_>

*<_int_month_>
    gen byte int_month = 6
    label define lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December", replace
    label values int_month lblint_month
    label var int_month "Month of the interview"
*</_int_month_>

*<_hhid_>
/* <_hhid_note>
    The adjacent-year report shows that the 2023 household identifier ID is absent
    in 2022. HOGAR is used as the household identifier, but HOGAR NPER is not a
    unique person key in the 2022 raw file.
</_hhid_note> */
    gen str20 hhid = strtrim(string(HOGAR, "%12.0f"))
    label var hhid "Household ID"
*</_hhid_>

*<_pid_>
/* <_pid_note>
    Raw NPER is not unique within HOGAR for 94 duplicate person keys. This
    report-based draft therefore creates a row-level person identifier within
    hhid so the draft output can be saved and checked. A production do-file
    should replace this with an approved survey person identifier if one is
    later identified.
</_pid_note> */
    bysort hhid (NPER RELA_J SEXO EDAD): gen int _pid_seq = _n
    gen str40 pid = hhid + "-" + string(_pid_seq, "%02.0f")
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
    gen long psu = COR_PRE
    label var psu "Primary sampling units"
*</_psu_>

*<_ssu_>
    gen byte ssu = NUM_REC
    label var ssu "Secondary sampling units"
*</_ssu_>

*<_strata_>
    gen byte strata = DOMINIO
    label var strata "Strata"
*</_strata_>

*<_wave_>
    gen byte wave = .
    label var wave "Wave"
*</_wave_>

*<_panel_>
    gen str1 panel = ""
    label var panel "Panel"
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
/* <_subnatid1_note>
    The adjacent-year report says current department is not retained in the
    checked 2022 person file. Do not create administrative subnational IDs from
    non-current geography.
</_subnatid1_note> */
    gen str80 subnatid1 = ""
    label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>

*<_subnatid2_>
    gen str80 subnatid2 = ""
    label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>

*<_subnatid3_>
    gen str80 subnatid3 = ""
    label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>

*<_subnatidsurvey_>
    gen str80 subnatidsurvey = ""
    replace subnatidsurvey = "1 - Distrito Central" if DOMI == 1
    replace subnatidsurvey = "2 - San Pedro Sula" if DOMI == 2
    replace subnatidsurvey = "3 - Resto Urbano" if DOMI == 3
    replace subnatidsurvey = "4 - Rural" if DOMI == 4
    label var subnatidsurvey "Subnational representative area"
*</_subnatidsurvey_>

*<_subnatid_prev_>
    gen str80 subnatid1_prev = ""
    gen str80 subnatid2_prev = ""
    gen str80 subnatid3_prev = ""
    label var subnatid1_prev "Previous Subnational ID at First Administrative Level"
    label var subnatid2_prev "Previous Subnational ID at Second Administrative Level"
    label var subnatid3_prev "Previous Subnational ID at Third Administrative Level"
*</_subnatid_prev_>

*<_gaul_codes_>
    gen gaul_adm1_code = .
    gen gaul_adm2_code = .
    gen gaul_adm3_code = .
    label var gaul_adm1_code "GAUL first administrative level code"
    label var gaul_adm2_code "GAUL second administrative level code"
    label var gaul_adm3_code "GAUL third administrative level code"
*</_gaul_codes_>

}


/*%%=============================================================================================
    4: Demographics
==============================================================================================%%*/

{

*<_hsize_>
    gen byte hsize = TOTPER
    label var hsize "Household size"
*</_hsize_>

*<_age_>
    gen int age = EDAD
    label var age "Age (years)"
*</_age_>

*<_male_>
    gen byte male = .
    replace male = 1 if SEXO == 1
    replace male = 0 if SEXO == 2
    label define lblmale 1 "Male" 0 "Female", replace
    label values male lblmale
    label var male "Individual is male"
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
    gen byte relationcs = RELA_J
    label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>

*<_marital_>
    gen byte marital = .
    replace marital = 1 if CIVIL == 1
    replace marital = 2 if CIVIL == 5
    replace marital = 3 if CIVIL == 6
    replace marital = 4 if inlist(CIVIL, 3, 4)
    replace marital = 5 if CIVIL == 2
    label define lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed", replace
    label values marital lblmarital
    label var marital "Marital status"
*</_marital_>

*<_disability_>
/* <_disability_note>
    CH307 is present in the 2023 reference year and absent from the checked
    2022 raw file. Disability variables are left missing.
</_disability_note> */
    foreach v in eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty {
        gen byte `v' = .
    }
    label var eye_dsablty "Vision disability"
    label var hear_dsablty "Hearing disability"
    label var walk_dsablty "Walking disability"
    label var conc_dsord "Concentration disorder"
    label var slfcre_dsablty "Self-care disability"
    label var comm_dsablty "Communication disability"
*</_disability_>

}


/*%%=============================================================================================
    5: Migration
==============================================================================================%%*/

{

*<_migration_>
/* <_migration_note>
    The adjacent-year report found the 2023 migration variables beginning with
    CD absent from the checked 2022 raw file. Migration variables are preserved
    as missing.
</_migration_note> */
    gen byte migrated_mod_age = .
    gen byte migrated_ref_time = .
    gen byte migrated_binary = .
    gen byte migrated_years = .
    gen byte migrated_from_urban = .
    gen byte migrated_from_cat = .
    gen str80 migrated_from_code = ""
    gen str80 migrated_from_country = ""
    gen byte migrated_reason = .
    label var migrated_mod_age "Age when migration module starts"
    label var migrated_ref_time "Reference time for migration question"
    label var migrated_binary "Individual has migrated"
    label var migrated_years "Years since migration"
    label var migrated_from_urban "Migrated from urban area"
    label var migrated_from_cat "Place of origin category"
    label var migrated_from_code "Place of origin code"
    label var migrated_from_country "Country of origin"
    label var migrated_reason "Reason for migration"
*</_migration_>

}


/*%%=============================================================================================
    6: Education
==============================================================================================%%*/

{

*<_ed_mod_age_>
    gen byte ed_mod_age = 3
    label var ed_mod_age "Age when education module starts"
*</_ed_mod_age_>

*<_school_>
    gen byte school = .
    replace school = 1 if ED03 == 1
    replace school = 0 if ED03 == 2
    label define lblschool 1 "Yes" 0 "No", replace
    label values school lblschool
    label var school "Currently in school"
*</_school_>

*<_literacy_>
    gen byte literacy = .
    replace literacy = 1 if ED01 == 1
    replace literacy = 0 if ED01 == 2
    label define lblliteracy 1 "Literate" 0 "Not literate", replace
    label values literacy lblliteracy
    label var literacy "Individual can read and write"
*</_literacy_>

*<_educy_>
    gen byte educy = .
    * Leave educy missing: the checked raw education evidence is not reliable enough
    * to harmonize years of education without a separate approved rule.
    label var educy "Years of education"
*</_educy_>

*<_educat7_>
/* <_educat7_note>
    For HND 2022, ED05 identifies the highest level reached and ED10 identifies
    the current level attended. The 2022 education ladder differs from 2023:
    ED05=5 corresponds to Ciclo común, ED05=6 corresponds to Diversificado,
    ED05=7 to Técnico superior, ED05=8 to Superior no universitaria, ED05=9
    to Superior universitaria, and ED05=10 to Post-grado. Basic education is
    split using ED08, with ANOSEST used only as a fallback when ED08 is missing.
    Diversificado completion is identified using ED07; when ED07 is missing,
    ED08 is used as fallback. Current attendance is used as a fallback through
    ED10 and ED13, and final fallback classifications use NIVEL and ANOSEST.
</_educat7_note> */

    gen byte educat7 = .

    replace educat7 = 1 if inlist(ED05, 1, 2, 3)

    replace educat7 = 2 if ED05 == 4 & ///
        (inrange(ED08, 1, 5) | (missing(ED08) & inrange(ANOSEST, 1, 5)))

    replace educat7 = 3 if ED05 == 4 & ///
        (ED08 == 6 | (missing(ED08) & ANOSEST == 6))

    replace educat7 = 4 if ED05 == 4 & ///
        (inrange(ED08, 7, 9) | (missing(ED08) & inrange(ANOSEST, 7, 9)))

    * Ciclo común
    replace educat7 = 4 if ED05 == 5

    * Diversificado
    replace educat7 = 4 if ED05 == 6 & ED07 == 2
    replace educat7 = 5 if ED05 == 6 & ED07 == 1

    * Fallback for Diversificado when completion status is missing
    replace educat7 = 4 if missing(educat7) & ED05 == 6 & inrange(ED08, 1, 2)
    replace educat7 = 5 if missing(educat7) & ED05 == 6 & inrange(ED08, 3, 4)

    * Técnico superior / Superior no universitaria
    replace educat7 = 6 if inlist(ED05, 7, 8)

    * Superior universitaria / Post-grado
    replace educat7 = 7 if inlist(ED05, 9, 10)


    * Current students
    replace educat7 = 1 if missing(educat7) & inlist(ED10, 2, 3)

    replace educat7 = 1 if missing(educat7) & ED10 == 4 & ED13 == 1
    replace educat7 = 2 if missing(educat7) & ED10 == 4 & inrange(ED13, 2, 6)
    replace educat7 = 3 if missing(educat7) & ED10 == 4 & ED13 == 7
    replace educat7 = 4 if missing(educat7) & ED10 == 4 & inrange(ED13, 8, 9)

    replace educat7 = 4 if missing(educat7) & ED10 == 5
    replace educat7 = 4 if missing(educat7) & ED10 == 6

    replace educat7 = 6 if missing(educat7) & inlist(ED10, 7, 8)
    replace educat7 = 7 if missing(educat7) & inlist(ED10, 9, 10)


    * Fallback using NIVEL + ANOSEST
    replace educat7 = 1 if missing(educat7) & NIVEL == 1

    replace educat7 = 2 if missing(educat7) & NIVEL == 2 & inrange(ANOSEST, 1, 5)
    replace educat7 = 3 if missing(educat7) & NIVEL == 2 & ANOSEST == 6
    replace educat7 = 4 if missing(educat7) & NIVEL == 2 & inrange(ANOSEST, 7, 9)

    replace educat7 = 4 if missing(educat7) & NIVEL == 3 & ANOSEST < 12
    replace educat7 = 5 if missing(educat7) & NIVEL == 3 & ANOSEST >= 12 & ANOSEST < .

    replace educat7 = 7 if missing(educat7) & NIVEL == 4

    replace educat7 = . if missing(educat7) & ED05 == 99 & ED10 == 99 & NIVEL == 9

    label define lbleducat7 ///
        1 "No education" ///
        2 "Primary incomplete" ///
        3 "Primary complete" ///
        4 "Secondary incomplete" ///
        5 "Secondary complete" ///
        6 "Higher than secondary but not university" ///
        7 "University incomplete or complete", replace

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
    gen int educat_orig = ED05
    replace educat_orig = ED10 if missing(educat_orig) & !missing(ED10)
    replace educat_orig = NIVEL if missing(educat_orig) & !missing(NIVEL)
    label var educat_orig "Original survey education code"
*</_educat_orig_>

*<_educat_isced_>
    gen byte educat_isced = .
    label var educat_isced "ISCED standardised level of education"
*</_educat_isced_>

*<_vocational_>
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
*</_vocational_>

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
    The HND 2022 adjacent-year report says not to use CONDACT as the primary
    lstatus source. The code reconstructs employment and unemployment from the
    route variables. Because CA508A is absent in 2022, CA508=1 is used as the
    2022 unpaid-family-work employment route. The residual age-eligible group
    is coded non-LF after employment and unemployment are assigned.
</_lstatus_note> */
    gen byte _lab_eligible = age >= minlaborage if !missing(age)
    gen byte _emp_direct_paid = _lab_eligible == 1 & CA501 == 1 & CA502 == 1
    gen byte _emp_listed_activity = _lab_eligible == 1 & _emp_direct_paid == 0 & inrange(CA503, 1, 9)
    gen byte _emp_abs_reason = _lab_eligible == 1 & _emp_direct_paid == 0 & _emp_listed_activity == 0 & CA504 == 1 & inrange(CA505, 1, 5)
    gen byte _emp_abs_paid = _lab_eligible == 1 & _emp_direct_paid == 0 & _emp_listed_activity == 0 & _emp_abs_reason == 0 & CA504 == 1 & CA506 == 1
    gen byte _emp_abs_short = _lab_eligible == 1 & _emp_direct_paid == 0 & _emp_listed_activity == 0 & _emp_abs_reason == 0 & _emp_abs_paid == 0 & CA504 == 1 & inlist(CA507, 1, 2)
    gen byte _emp_family_2022 = _lab_eligible == 1 & _emp_direct_paid == 0 & _emp_listed_activity == 0 & _emp_abs_reason == 0 & _emp_abs_paid == 0 & _emp_abs_short == 0 & CA508 == 1
    gen byte _employed_route = _emp_direct_paid | _emp_listed_activity | _emp_abs_reason | _emp_abs_paid | _emp_abs_short | _emp_family_2022
    gen byte _unemployed_route = _lab_eligible == 1 & _employed_route == 0 & inlist(CA511, 1, 2) & (CA512 == 1 | inlist(CA513, 1, 2))
    gen byte _route_observed = _lab_eligible == 1 & !missing(CA501)

    gen byte lstatus = .
    replace lstatus = 1 if _employed_route == 1
    replace lstatus = 2 if missing(lstatus) & _unemployed_route == 1
    replace lstatus = 3 if missing(lstatus) & _lab_eligible == 1
    replace lstatus = . if age < minlaborage & !missing(age)

    label define lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF", replace
    label values lstatus lbllstatus
    label var lstatus "Labor status"
*</_lstatus_>

*<_potential_lf_>
/* <_potential_lf_note>
    Potential labor force uses search and direct availability evidence. The
    desire-for-work question alone is not used because it does not establish the
    search-availability mismatch needed for this GLD variable.
</_potential_lf_note> */
    gen byte potential_lf = .
    replace potential_lf = 0 if lstatus == 3
    replace potential_lf = 1 if lstatus == 3 & CA512 == 1 & !inlist(CA511, 1, 2, 9)
    replace potential_lf = 1 if lstatus == 3 & CA512 == 2 & inlist(CA511, 1, 2)
    replace potential_lf = . if lstatus == 3 & CA511 == 9
    label define lblpotential_lf 0 "No" 1 "Yes", replace
    label values potential_lf lblpotential_lf
    label var potential_lf "Potential labour force status"
*</_potential_lf_>

*<_underemployment_>
/* <_underemployment_note>
    ACTIVIDA is absent in 2022. This draft uses the retained hours-wanted and
    availability questions rather than the 2023 ACTIVIDA shortcut.
</_underemployment_note> */
    gen byte underemployment = .
    replace underemployment = 0 if lstatus == 1
    replace underemployment = 1 if lstatus == 1 & CA522 == 1 & CA523 == 1
    label define lblunderemployment 0 "No" 1 "Yes", replace
    label values underemployment lblunderemployment
    label var underemployment "Underemployment status"
*</_underemployment_>

*<_nlfreason_>
    gen byte nlfreason = .
    replace nlfreason = 3 if lstatus == 3 & inlist(CA514, 1, 2, 3)
    replace nlfreason = 1 if lstatus == 3 & CA514 == 4
    replace nlfreason = 2 if lstatus == 3 & CA514 == 5
    replace nlfreason = 5 if lstatus == 3 & CA514 == 6
    replace nlfreason = 4 if lstatus == 3 & inlist(CA514, 7, 8)
    replace nlfreason = 5 if lstatus == 3 & inlist(CA514, 9, 97)
    label define lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other", replace
    label values nlfreason lblnlfreason
    label var nlfreason "Reason not in the labor force"
*</_nlfreason_>

*<_unempldur_l_>
/* <_unempldur_note>
    CA516TIEMPO gives a duration and CA516DSM gives units. The draft converts
    days and weeks to integer months and assigns the same value to lower and
    upper bounds because the report says HND does not report ranges here.
</_unempldur_note> */
    gen int unempldur_l = .
    replace unempldur_l = round(CA516TIEMPO / 30) if lstatus == 2 & CA516DSM == 1
    replace unempldur_l = round(CA516TIEMPO / 4.345) if lstatus == 2 & CA516DSM == 2
    replace unempldur_l = CA516TIEMPO if lstatus == 2 & CA516DSM == 3
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
    replace empstat = 1 if lstatus == 1 & inlist(OC609, 1, 2, 3, 4, 5)
    replace empstat = 2 if lstatus == 1 & OC609 == 8
    replace empstat = 3 if lstatus == 1 & OC609 == 6
    replace empstat = 4 if lstatus == 1 & inlist(OC609, 7, 9, 10, 11)
    label define lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status", replace
    label values empstat lblempstat
    label var empstat "Employment status in primary job"
*</_empstat_>


*<_ocusec_>
    gen byte ocusec = .
    replace ocusec = 1 if lstatus == 1 & inlist(OC609, 1, 4, 9)
    replace ocusec = 2 if lstatus == 1 & inlist(OC609, 2, 3, 5, 6, 7, 8, 10, 11)
    label define lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish", replace
    label values ocusec lblocusec
    label var ocusec "Sector of activity"
*</_ocusec_>

*<_industry_orig_>
    gen str20 industry_orig = ""
    replace industry_orig = strtrim(string(O02_CODIGO, "%12.0f")) if lstatus == 1 & O02_CODIGO < . & !inlist(O02_CODIGO, 99999, 999999)
    label var industry_orig "Original industry record primary job 7 day recall"
*</_industry_orig_>

*<_industrycat_isic_>
    gen str20 _indstr = strtrim(string(O02_CODIGO, "%12.0f"))
    gen str4 industrycat_isic = ""
    replace industrycat_isic = "0" + substr(_indstr, 1, 3) if lstatus == 1 & length(_indstr) == 4 & inrange(O02_CODIGO, 1000, 3999)
    replace industrycat_isic = _indstr if lstatus == 1 & length(_indstr) == 4 & industrycat_isic == ""
    replace industrycat_isic = substr(_indstr, 1, 4) if lstatus == 1 & inlist(length(_indstr), 5, 6)
    * Fall back to first-two-digits + 00 for observed invalid ISIC-4 detailed codes.
    replace industrycat_isic = substr(industrycat_isic, 1, 2) + "00" if inlist(industrycat_isic, "0380", "3110", "5611", "7291", "7661", "8222", "9121", "9899")
    * Leave still-invalid fallback codes missing. For the checked 2022 output, 7661 -> 7600 and 9998 remain outside ISIC-4.
    replace industrycat_isic = "" if inlist(industrycat_isic, "7600", "9998")
    replace industrycat_isic = "" if inlist(O02_CODIGO, 8990, 99999, 999999) | lstatus != 1
    replace industry_orig = "" if industrycat_isic == ""
    label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>

*<_industrycat10_>
    tempvar isic2
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
    replace occup_orig = strtrim(string(O01_CODIGO, "%12.0f")) if lstatus == 1 & O01_CODIGO < . & O01_CODIGO != 999999
    label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>

*<_occup_isco_>
    gen str20 _occstr = strtrim(string(O01_CODIGO, "%12.0f"))
    gen str4 occup_isco = ""
    replace occup_isco = substr(_occstr, 1, 3) + "0" if lstatus == 1 & O01_CODIGO < . & !inlist(O01_CODIGO, 989901, 999999)
    * Fall back to first-two-digits + 00 for observed invalid ISCO-08 detailed codes.
    replace occup_isco = substr(occup_isco, 1, 2) + "00" if inlist(occup_isco, "3450", "5170", "9990")
    * Leave still-invalid fallback codes missing. For the checked 2022 output, 9990 -> 9900 remains outside ISCO-08.
    replace occup_isco = "" if occup_isco == "9900"
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
    egen whours = rowtotal(OC_605_LUNES OC_605_MARTES OC_605_MIERCOLES OC_605_JUEVES OC_605_VIERNES OC_605_SABADO OC_605_DOMINGO), missing
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

*<_contract_>
/* <_contract_note>
    Contract evidence is partial in the received raw file, so contract is left
    missing.
</_contract_note> */
    gen byte contract = .
    label var contract "Contract"
*</_contract_>

*<_healthins_>
    gen byte healthins = .
    label var healthins "Health insurance"
*</_healthins_>

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

*<_union_>
    gen byte union = .
    label var union "Union membership"
*</_union_>

*<_firmsize_l_>
    gen int firmsize_l = .
    replace firmsize_l = 1   if lstatus == 1 & OC608 == 1
    replace firmsize_l = 11  if lstatus == 1 & OC608 == 2
    replace firmsize_l = 51  if lstatus == 1 & OC608 == 3
    replace firmsize_l = 151 if lstatus == 1 & OC608 == 4
    label var firmsize_l "Firm size (lower bound), primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
    gen int firmsize_u = .
    replace firmsize_u = 10  if lstatus == 1 & OC608 == 1
    replace firmsize_u = 50  if lstatus == 1 & OC608 == 2
    replace firmsize_u = 150 if lstatus == 1 & OC608 == 3
    label var firmsize_u "Firm size (upper bound), primary job 7 day recall"
*</_firmsize_u_>

}


/*%%=============================================================================================
    8.3: 7 day reference secondary job
==============================================================================================%%*/

{
*<_empstat_2_>
    gen byte empstat_2 = .
    replace empstat_2 = 1 if lstatus == 1 & CA519 > 1 & inlist(OC6091, 1, 2, 3, 4, 5)
    replace empstat_2 = 2 if lstatus == 1 & CA519 > 1 & OC6091 == 8
    replace empstat_2 = 3 if lstatus == 1 & CA519 > 1 & OC6091 == 6
    replace empstat_2 = 4 if lstatus == 1 & CA519 > 1 & inlist(OC6091, 7, 9, 10, 11)
    label var empstat_2 "Employment status in secondary job"
    label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
    gen byte ocusec_2 = .
    replace ocusec_2 = 1 if lstatus == 1 & CA519 > 1 & inlist(OC6091, 1, 4, 9)
    replace ocusec_2 = 2 if lstatus == 1 & CA519 > 1 & inlist(OC6091, 2, 3, 5, 6, 7, 8, 10, 11)
    label var ocusec_2 "Sector of activity, secondary job"
    label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
    gen str20 industry_orig_2 = ""
    label var industry_orig_2 "Original industry record secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
    gen str4 industrycat_isic_2 = ""
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
    gen str20 occup_orig_2 = ""
    label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
    gen str4 occup_isco_2 = ""
    label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_2_>
    gen byte occup_2 = .
    label var occup_2 "1 digit occupational classification, secondary job 7 day recall"
    label values occup_2 lbloccup
*</_occup_2_>


*<_occup_skill_2_>
    gen byte occup_skill_2 = .
    replace occup_skill_2 = 3 if inrange(occup_2, 1, 3)
    replace occup_skill_2 = 2 if inrange(occup_2, 4, 8)
    replace occup_skill_2 = 1 if occup_2 == 9
    label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
    label values occup_skill_2 lblskill
*</_occup_skill_2_>


*<_wage_no_compen_2_>
/* <_wage_no_compen_2_note>
    The adjacent-year report states that HND 2022 lacks the retained
    secondary total `YTRAOS` used in HND 2023, but retains the detailed
    secondary earnings components. The HND 2023 raw totals validate the
    component formula: monetary employee earnings are `OC6171` times
    `OC6181`, in-kind employee earnings are the row sum of the `OC619_*1`
    items, monetary self-employment earnings are `OC6281`, and own-use or
    in-kind self-employment earnings are `OC6301` plus `OC6361`. For HND
    2022, all observed secondary pay-period currency records use local-
    currency code 1, so no currency conversion is applied. The rebuilt
    value is a monthly secondary labor-income amount and is restricted to
    employed persons with a secondary job.
</_wage_no_compen_2_note> */

    tempvar sec_sal_cash sec_sal_inkind sec_self_cash sec_self_inkind

    gen double `sec_sal_cash' = OC6171 * OC6181 ///
        if OC617_TIPO_DE_MONEDA1 == 1 ///
        & OC6171 >= 0 & OC6171 < 999999 ///
        & OC6181 > 0 & OC6181 < 999999

    local sec_inkind_components
    foreach v in OC619_ALIMENTOS1 OC619_HABITACION1 OC619_ROPA_CALZADO1 ///
        OC619_TRANSPORTE1 OC619_COMISION1 OC619_BONIFICACION1 ///
        OC619_PROPINAS1 OC619_HORAS_EXTRAS1 {

        tempvar c
        gen double `c' = `v' if `v' >= 0 & `v' < 999999
        local sec_inkind_components `sec_inkind_components' `c'
    }

    egen double `sec_sal_inkind' = rowtotal(`sec_inkind_components'), missing

    gen double `sec_self_cash' = OC6281 if OC6281 >= 0 & OC6281 < 999999

    local sec_self_inkind_components
    foreach v in OC6301 OC6361 {
        tempvar c
        gen double `c' = `v' if `v' >= 0 & `v' < 999999
        local sec_self_inkind_components `sec_self_inkind_components' `c'
    }

    egen double `sec_self_inkind' = rowtotal(`sec_self_inkind_components'), missing

    egen double wage_no_compen_2 = rowtotal( ///
        `sec_sal_cash' ///
        `sec_sal_inkind' ///
        `sec_self_cash' ///
        `sec_self_inkind'), missing

    replace wage_no_compen_2 = . if lstatus != 1 | CA519 <= 1 | missing(CA519)

    label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
    gen byte unitwage_2 = .
    replace unitwage_2 = 5 if !missing(wage_no_compen_2)
    label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
    label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
    egen whours_2 = rowtotal( ///
        OC_605_LUNES1 ///
        OC_605_MARTES1 ///
        OC_605_MIERCOLES1 ///
        OC_605_JUEVES1 ///
        OC_605_VIERNES1 ///
        OC_605_SABADO1 ///
        OC_605_DOMINGO1), missing

    replace whours_2 = . if lstatus != 1 | CA519 <= 1 | missing(CA519)
    label var whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>


*<_wmonths_2_>
    gen byte wmonths_2 = .
    label var wmonths_2 "Months worked in last year, secondary job"
*</_wmonths_2_>


*<_wage_total_2_>
    gen double wage_total_2 = .
    label var wage_total_2 "Annualized total wage secondary job 7 day recall"
*</_wage_total_2_>


*<_firmsize_l_2_>
    gen int firmsize_l_2 = .
    replace firmsize_l_2 = 1   if lstatus == 1 & CA519 > 1 & OC6081 == 1
    replace firmsize_l_2 = 11  if lstatus == 1 & CA519 > 1 & OC6081 == 2
    replace firmsize_l_2 = 51  if lstatus == 1 & CA519 > 1 & OC6081 == 3
    replace firmsize_l_2 = 151 if lstatus == 1 & CA519 > 1 & OC6081 == 4
    label var firmsize_l_2 "Firm size (lower bound), secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
    gen int firmsize_u_2 = .
    replace firmsize_u_2 = 10  if lstatus == 1 & CA519 > 1 & OC6081 == 1
    replace firmsize_u_2 = 50  if lstatus == 1 & CA519 > 1 & OC6081 == 2
    replace firmsize_u_2 = 150 if lstatus == 1 & CA519 > 1 & OC6081 == 3
    label var firmsize_u_2 "Firm size (upper bound), secondary job 7 day recall"
*</_firmsize_u_2_>

}


/*%%=============================================================================================
    8.4: 7 day reference additional jobs
==============================================================================================%%*/

*<_t_hours_others_>
    gen double t_hours_others = whours_2
    label var t_hours_others "Hours of work in last week other jobs 7 day recall"
*</_t_hours_others_>


*<_t_wage_nocompen_others_>
    gen double t_wage_nocompen_others = wage_no_compen_2
    label var t_wage_nocompen_others "Last wage payment other jobs 7 day recall"
*</_t_wage_nocompen_others_>


*<_t_wage_others_>
    gen double t_wage_others = wage_total_2
    label var t_wage_others "Annualized wage other jobs 7 day recall"
*</_t_wage_others_>


/*%%=============================================================================================
    8.5: 7 day reference total summary
==============================================================================================%%*/

*<_t_hours_total_>
    egen double t_hours_total = rowtotal(whours whours_2), missing
    label var t_hours_total "Hours of work in last week all jobs 7 day recall"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
    gen double t_wage_nocompen_total = .
    * Leave t_wage_nocompen_total missing until a total labor-income rule is approved.
    label var t_wage_nocompen_total "Last wage payment all jobs 7 day recall"
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
    egen double t_wage_total = rowtotal(wage_total wage_total_2), missing
    label var t_wage_total "Annualized wage all jobs 7 day recall"
*</_t_wage_total_>


/*%%=============================================================================================
    8.6: 12 month reference overall
==============================================================================================%%*/

{
*<_lstatus_year_>
    gen byte lstatus_year = .
    label var lstatus_year "Labor status during last year"
    label values lstatus_year lbllstatus
*</_lstatus_year_>


*<_potential_lf_year_>
    gen byte potential_lf_year = .
    label var potential_lf_year "Potential labour force status"
    label values potential_lf_year lblpotential_lf
*</_potential_lf_year_>


*<_underemployment_year_>
    gen byte underemployment_year = .
    label var underemployment_year "Underemployment status"
    label values underemployment_year lblunderemployment
*</_underemployment_year_>


*<_nlfreason_year_>
    gen byte nlfreason_year = .
    label var nlfreason_year "Reason not in the labor force"
    label values nlfreason_year lblnlfreason
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


/*%%=============================================================================================
    8.7: 12 month reference main job
==============================================================================================%%*/

{
*<_empstat_year_>
    gen byte empstat_year = .
    label var empstat_year "Employment status during past week primary job 12 month recall"
    label values empstat_year lblempstat
*</_empstat_year_>


*<_ocusec_year_>
    gen byte ocusec_year = .
    label var ocusec_year "Sector of activity primary job 12 month recall"
    label values ocusec_year lblocusec
*</_ocusec_year_>


*<_industry_orig_year_>
    gen str20 industry_orig_year = ""
    label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
    gen str20 industrycat_isic_year = ""
    label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>


*<_industrycat10_year_>
    gen byte industrycat10_year = .
    label var industrycat10_year "1 digit industry classification, primary job 12 month recall"
    label values industrycat10_year lblindustrycat10
*</_industrycat10_year_>


*<_industrycat4_year_>
    gen byte industrycat4_year = industrycat10_year
    recode industrycat4_year (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
    label var industrycat4_year "Broad Economic Activities classification, primary job 12 month recall"
    label values industrycat4_year lblindustrycat4
*</_industrycat4_year_>


*<_occup_orig_year_>
    gen str20 occup_orig_year = ""
    label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
    gen str20 occup_isco_year = ""
    label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_year_>
    gen byte occup_year = .
    label var occup_year "1 digit occupational classification, primary job 12 month recall"
    label values occup_year lbloccup
*</_occup_year_>


*<_occup_skill_year_>
    gen byte occup_skill_year = .
    replace occup_skill_year = 3 if inrange(occup_year, 1, 3)
    replace occup_skill_year = 2 if inrange(occup_year, 4, 8)
    replace occup_skill_year = 1 if occup_year == 9
    label var occup_skill_year "Skill based on ISCO standard primary job 12 month recall"
    label values occup_skill_year lblskill
*</_occup_skill_year_>


*<_wage_no_compen_year_>
    gen double wage_no_compen_year = .
    label var wage_no_compen_year "Last wage payment primary job 12 month recall"
*</_wage_no_compen_year_>


*<_unitwage_year_>
    gen byte unitwage_year = .
    label var unitwage_year "Last wages' time unit primary job 12 month recall"
    label values unitwage_year lblunitwage
*</_unitwage_year_>


*<_whours_year_>
    gen double whours_year = .
    label var whours_year "Hours of work in last week primary job 12 month recall"
*</_whours_year_>


*<_wmonths_year_>
    gen byte wmonths_year = .
    label var wmonths_year "Months of work in past 12 months primary job 12 month recall"
*</_wmonths_year_>


*<_wage_total_year_>
    gen double wage_total_year = .
    label var wage_total_year "Annualized total wage primary job 12 month recall"
*</_wage_total_year_>


*<_contract_year_>
    gen byte contract_year = .
    label var contract_year "Employment has contract primary job 12 month recall"
*</_contract_year_>


*<_healthins_year_>
    gen byte healthins_year = .
    label var healthins_year "Employment has health insurance primary job 12 month recall"
*</_healthins_year_>


*<_socialsec_year_>
    gen byte socialsec_year = .
    label var socialsec_year "Employment has social security insurance primary job 12 month recall"
    label values socialsec_year lblsocialsec
*</_socialsec_year_>


*<_union_year_>
    gen byte union_year = .
    label var union_year "Union membership at primary job 12 month recall"
*</_union_year_>


*<_firmsize_l_year_>
    gen int firmsize_l_year = .
    label var firmsize_l_year "Firm size (lower bracket) primary job 12 month recall"
*</_firmsize_l_year_>


*<_firmsize_u_year_>
    gen int firmsize_u_year = .
    label var firmsize_u_year "Firm size (upper bracket) primary job 12 month recall"
*</_firmsize_u_year_>

}


/*%%=============================================================================================
    8.8: 12 month reference secondary job
==============================================================================================%%*/

{
*<_empstat_2_year_>
    gen byte empstat_2_year = .
    label var empstat_2_year "Employment status during past week secondary job 12 month recall"
    label values empstat_2_year lblempstat
*</_empstat_2_year_>


*<_ocusec_2_year_>
    gen byte ocusec_2_year = .
    label var ocusec_2_year "Sector of activity secondary job 12 month recall"
    label values ocusec_2_year lblocusec
*</_ocusec_2_year_>


*<_industry_orig_2_year_>
    gen str20 industry_orig_2_year = ""
    label var industry_orig_2_year "Original survey industry code, secondary job 12 month recall"
*</_industry_orig_2_year_>


*<_industrycat_isic_2_year_>
    gen str20 industrycat_isic_2_year = ""
    label var industrycat_isic_2_year "ISIC code of secondary job 12 month recall"
*</_industrycat_isic_2_year_>


*<_industrycat10_2_year_>
    gen byte industrycat10_2_year = .
    label var industrycat10_2_year "1 digit industry classification, secondary job 12 month recall"
    label values industrycat10_2_year lblindustrycat10
*</_industrycat10_2_year_>


*<_industrycat4_2_year_>
    gen byte industrycat4_2_year = industrycat10_2_year
    recode industrycat4_2_year (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
    label var industrycat4_2_year "Broad Economic Activities classification, secondary job 12 month recall"
    label values industrycat4_2_year lblindustrycat4
*</_industrycat4_2_year_>


*<_occup_orig_2_year_>
    gen str20 occup_orig_2_year = ""
    label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
    gen str20 occup_isco_2_year = ""
    label var occup_isco_2_year "ISCO code of secondary job 12 month recall"
*</_occup_isco_2_year_>


*<_occup_2_year_>
    gen byte occup_2_year = .
    label var occup_2_year "1 digit occupational classification, secondary job 12 month recall"
    label values occup_2_year lbloccup
*</_occup_2_year_>


*<_occup_skill_2_year_>
    gen byte occup_skill_2_year = .
    replace occup_skill_2_year = 3 if inrange(occup_2_year, 1, 3)
    replace occup_skill_2_year = 2 if inrange(occup_2_year, 4, 8)
    replace occup_skill_2_year = 1 if occup_2_year == 9
    label var occup_skill_2_year "Skill based on ISCO standard secondary job 12 month recall"
    label values occup_skill_2_year lblskill
*</_occup_skill_2_year_>


*<_wage_no_compen_2_year_>
    gen double wage_no_compen_2_year = .
    label var wage_no_compen_2_year "Last wage payment secondary job 12 month recall"
*</_wage_no_compen_2_year_>


*<_unitwage_2_year_>
    gen byte unitwage_2_year = .
    label var unitwage_2_year "Last wages' time unit secondary job 12 month recall"
    label values unitwage_2_year lblunitwage
*</_unitwage_2_year_>


*<_whours_2_year_>
    gen double whours_2_year = .
    label var whours_2_year "Hours of work in last week secondary job 12 month recall"
*</_whours_2_year_>


*<_wmonths_2_year_>
    gen byte wmonths_2_year = .
    label var wmonths_2_year "Months of work in past 12 months secondary job 12 month recall"
*</_wmonths_2_year_>


*<_wage_total_2_year_>
    gen double wage_total_2_year = .
    label var wage_total_2_year "Annualized total wage secondary job 12 month recall"
*</_wage_total_2_year_>


*<_firmsize_l_2_year_>
    gen int firmsize_l_2_year = .
    label var firmsize_l_2_year "Firm size (lower bracket) secondary job 12 month recall"
*</_firmsize_l_2_year_>


*<_firmsize_u_2_year_>
    gen int firmsize_u_2_year = .
    label var firmsize_u_2_year "Firm size (upper bracket) secondary job 12 month recall"
*</_firmsize_u_2_year_>

}


/*%%=============================================================================================
    8.9: 12 month reference additional jobs
==============================================================================================%%*/

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


/*%%=============================================================================================
    8.10: 12 month total summary
==============================================================================================%%*/

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


/*%%=============================================================================================
    8.11: Overall across reference periods
==============================================================================================%%*/

*<_njobs_>
    gen byte njobs = .
    replace njobs = 1 if lstatus == 1 & CA519 == 1
    replace njobs = 2 if lstatus == 1 & CA519 > 1 & CA519 < .
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


/*%%=============================================================================================
    9: Final steps
==============================================================================================%%*/

quietly {

*<_% KEEP VARIABLES - ALL_>

    local keep_vars ///
        countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization ///
        int_year int_month hhid pid weight weight_m weight_q psu ssu strata wave panel visit_no urban ///
        subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev ///
        gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital ///
        eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty ///
        migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat ///
        migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 ///
        educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u ///
        vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason ///
        unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 ///
        occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total ///
        contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 ///
        industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 ///
        wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 ///
        t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total ///
        lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year ///
        empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year ///
        occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year ///
        whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year ///
        firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year ///
        industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year ///
        occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year ///
        firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year ///
        t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

    keep `keep_vars'

*</_% KEEP VARIABLES - ALL_>


*<_% ORDER VARIABLES_>

    order `keep_vars'

*</_% ORDER VARIABLES_>


*<_% DROP UNUSED LABELS_>

    label dir
    local all_lab `r(names)'

    local used_lab = ""
    ds, has(vallabel)
    local labelled_vars `r(varlist)'

    foreach varName of local labelled_vars {
        local y : value label `varName'
        local used_lab `"`used_lab' `y'"'
    }

    local notused     : list all_lab - used_lab
    local notused_len : list sizeof notused

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

save "`path_output'/`level_2_harm'_ALL.dta", replace

*</_% SAVE_>