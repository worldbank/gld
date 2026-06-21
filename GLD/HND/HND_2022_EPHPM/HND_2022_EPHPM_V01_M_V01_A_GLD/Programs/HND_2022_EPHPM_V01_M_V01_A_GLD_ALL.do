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
	local server "C:/Users/`c(username)'/OneDrive - WBG/GLD - Current Contributors/510859_AS"
}
else {
	local server "C:/Users/`c(username)'/WBG/GLD - Current Contributors/510859_AS"
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
    gen byte panel = .
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
    gen byte relationharm = .
    replace relationharm = 1 if RELA_J == 1
    replace relationharm = 2 if RELA_J == 2
    replace relationharm = 3 if inlist(RELA_J, 3, 4)
    replace relationharm = 4 if RELA_J == 5
    replace relationharm = 5 if inlist(RELA_J, 6, 7, 8)
    replace relationharm = 6 if inlist(RELA_J, 9, 10)
    label define lblrelationharm 1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives", replace
    label values relationharm lblrelationharm
    label var relationharm "Relationship to the head of household - Harmonized"
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
    The HND 2022 labels differ slightly from 2023: ED05=5 is Ciclo comun and
    ED05=6 is Diversificado. The mapping follows the adjacent-year report and
    the 2023 education report, using 2022 labels where they differ.
</_educat7_note> */
    gen byte educat7 = .

    replace educat7 = 1 if inlist(ED05, 1, 2, 3)
    replace educat7 = 2 if ED05 == 4 & (inrange(ED08, 1, 5) | inrange(ANOSEST, 1, 5))
    replace educat7 = 3 if ED05 == 4 & (ED08 == 6 | ANOSEST == 6)
    replace educat7 = 4 if ED05 == 4 & (inrange(ED08, 7, 9) | inrange(ANOSEST, 7, 9))
    replace educat7 = 4 if ED05 == 5
    replace educat7 = 4 if ED05 == 6 & ED07 == 2
    replace educat7 = 5 if ED05 == 6 & ED07 == 1
    replace educat7 = 6 if inlist(ED05, 7, 8)
    replace educat7 = 7 if inlist(ED05, 9, 10)

    replace educat7 = 1 if missing(educat7) & inlist(ED10, 2, 3)
    replace educat7 = 1 if missing(educat7) & ED10 == 4 & ED13 == 1
    replace educat7 = 2 if missing(educat7) & ED10 == 4 & inrange(ED13, 2, 6)
    replace educat7 = 3 if missing(educat7) & ED10 == 4 & ED13 == 7
    replace educat7 = 4 if missing(educat7) & ED10 == 4 & inrange(ED13, 8, 9)
    replace educat7 = 4 if missing(educat7) & inlist(ED10, 5, 6)
    replace educat7 = 6 if missing(educat7) & inlist(ED10, 7, 8)
    replace educat7 = 7 if missing(educat7) & inlist(ED10, 9, 10)

    replace educat7 = 1 if missing(educat7) & NIVEL == 1
    replace educat7 = 2 if missing(educat7) & NIVEL == 2 & inrange(ANOSEST, 1, 5)
    replace educat7 = 3 if missing(educat7) & NIVEL == 2 & ANOSEST == 6
    replace educat7 = 4 if missing(educat7) & NIVEL == 2 & inrange(ANOSEST, 7, 9)
    replace educat7 = 4 if missing(educat7) & NIVEL == 3 & ANOSEST < 12
    replace educat7 = 5 if missing(educat7) & NIVEL == 3 & ANOSEST >= 12 & ANOSEST < .
    replace educat7 = 7 if missing(educat7) & NIVEL == 4

    replace educat7 = . if ED05 == 99 | ED10 == 99 | NIVEL == 9
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
    foreach v in vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed {
        gen byte `v' = .
    }
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
    2022 unpaid-family-work employment route.
</_lstatus_note> */
    gen byte _lab_eligible = age >= minlaborage if !missing(age)
    gen byte _emp_direct_paid = _lab_eligible == 1 & CA501 == 1 & CA502 == 1
    gen byte _emp_listed_activity = _lab_eligible == 1 & _emp_direct_paid == 0 & inrange(CA503, 1, 9)
    gen byte _emp_abs_reason = _lab_eligible == 1 & _emp_direct_paid == 0 & _emp_listed_activity == 0 & CA504 == 1 & inrange(CA505, 1, 4)
    gen byte _emp_abs_paid = _lab_eligible == 1 & _emp_direct_paid == 0 & _emp_listed_activity == 0 & _emp_abs_reason == 0 & CA504 == 1 & CA506 == 1
    gen byte _emp_abs_short = _lab_eligible == 1 & _emp_direct_paid == 0 & _emp_listed_activity == 0 & _emp_abs_reason == 0 & _emp_abs_paid == 0 & CA504 == 1 & inlist(CA507, 1, 2)
    gen byte _emp_family_2022 = _lab_eligible == 1 & _emp_direct_paid == 0 & _emp_listed_activity == 0 & _emp_abs_reason == 0 & _emp_abs_paid == 0 & _emp_abs_short == 0 & CA508 == 1
    gen byte _employed_route = _emp_direct_paid | _emp_listed_activity | _emp_abs_reason | _emp_abs_paid | _emp_abs_short | _emp_family_2022
    gen byte _unemployed_route = _lab_eligible == 1 & _employed_route == 0 & inlist(CA511, 1, 2) & (CA512 == 1 | inlist(CA513, 1, 2))
    gen byte _route_observed = _lab_eligible == 1 & !missing(CA501)

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
    replace potential_lf = 1 if lstatus == 3 & CA512 == 1 & !inlist(CA511, 1, 2, 9)
    replace potential_lf = 1 if lstatus == 3 & CA512 == 2 & inlist(CA511, 1, 2)
    replace potential_lf = 1 if lstatus == 3 & CA510 == 1 & CA512 == 2
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
    replace empstat = 1 if lstatus == 1 & inlist(OC609, 1, 2, 3, 4, 5, 9, 10, 11)
    replace empstat = 2 if lstatus == 1 & OC609 == 8
    replace empstat = 3 if lstatus == 1 & OC609 == 6
    replace empstat = 4 if lstatus == 1 & OC609 == 7
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
    replace industrycat_isic = substr(industrycat_isic, 1, 2) + "00" if inlist(industrycat_isic, "0380", "3110", "5611", "7291", "7661", "8222", "9121", "9899", "9998")
    * Leave still-invalid fallback codes missing. For the checked 2022 output, 7661 -> 7600 remains outside ISIC-4.
    replace industrycat_isic = "" if industrycat_isic == "7600"
    replace industrycat_isic = "" if inlist(O02_CODIGO, 8990, 99999, 999999) | lstatus != 1
    label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>

*<_industrycat10_>
    gen byte industrycat10 = .
    replace industrycat10 = 1 if lstatus == 1 & RAMAOP == 1
    replace industrycat10 = 2 if lstatus == 1 & RAMAOP == 2
    replace industrycat10 = 3 if lstatus == 1 & RAMAOP == 3
    replace industrycat10 = 4 if lstatus == 1 & inlist(RAMAOP, 4, 5)
    replace industrycat10 = 5 if lstatus == 1 & RAMAOP == 6
    replace industrycat10 = 6 if lstatus == 1 & inlist(RAMAOP, 7, 9)
    replace industrycat10 = 7 if lstatus == 1 & inlist(RAMAOP, 8, 10)
    replace industrycat10 = 8 if lstatus == 1 & inlist(RAMAOP, 11, 12, 13, 14)
    replace industrycat10 = 9 if lstatus == 1 & RAMAOP == 15
    replace industrycat10 = 10 if lstatus == 1 & inrange(RAMAOP, 16, 21)
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

*<_firmsize_>
    gen int firmsize_l = .
    gen int firmsize_u = .
    replace firmsize_l = 1 if lstatus == 1 & OC608 == 1
    replace firmsize_u = 10 if lstatus == 1 & OC608 == 1
    replace firmsize_l = 11 if lstatus == 1 & OC608 == 2
    replace firmsize_u = 50 if lstatus == 1 & OC608 == 2
    replace firmsize_l = 51 if lstatus == 1 & OC608 == 3
    replace firmsize_u = 150 if lstatus == 1 & OC608 == 3
    replace firmsize_l = 151 if lstatus == 1 & OC608 == 4
    label var firmsize_l "Firm size (lower bound), primary job 7 day recall"
    label var firmsize_u "Firm size (upper bound), primary job 7 day recall"
*</_firmsize_>

*<_secondary_job_>
    gen byte njobs = .
    replace njobs = 1 if lstatus == 1 & CA519 == 1
    replace njobs = 2 if lstatus == 1 & CA519 > 1 & CA519 < .
    label var njobs "Number of jobs"

    gen byte empstat_2 = .
    replace empstat_2 = 1 if lstatus == 1 & CA519 > 1 & inlist(OC6091, 1, 2, 3, 4, 5, 9, 10, 11)
    replace empstat_2 = 2 if lstatus == 1 & CA519 > 1 & OC6091 == 8
    replace empstat_2 = 3 if lstatus == 1 & CA519 > 1 & OC6091 == 6
    replace empstat_2 = 4 if lstatus == 1 & CA519 > 1 & OC6091 == 7
    label values empstat_2 lblempstat
    label var empstat_2 "Employment status in secondary job"

    gen byte ocusec_2 = .
    replace ocusec_2 = 1 if lstatus == 1 & CA519 > 1 & inlist(OC6091, 1, 4, 9)
    replace ocusec_2 = 2 if lstatus == 1 & CA519 > 1 & inlist(OC6091, 2, 3, 5, 6, 7, 8, 10, 11)
    label values ocusec_2 lblocusec
    label var ocusec_2 "Sector of activity, secondary job"

    gen str20 industry_orig_2 = ""
    gen str4 industrycat_isic_2 = ""
    gen byte industrycat10_2 = .
    gen byte industrycat4_2 = .
    gen str20 occup_orig_2 = ""
    gen str4 occup_isco_2 = ""
    gen byte occup_skill_2 = .
    gen byte occup_2 = .
    label var industry_orig_2 "Original industry record secondary job 7 day recall"
    label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
    label var industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
    label var industrycat4_2 "Broad Economic Activities classification, secondary job 7 day recall"
    label var occup_orig_2 "Original occupation record secondary job 7 day recall"
    label var occup_isco_2 "ISCO code of secondary job 7 day recall"
    label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
    label var occup_2 "1 digit occupational classification, secondary job 7 day recall"

    egen whours_2 = rowtotal(OC_605_LUNES1 OC_605_MARTES1 OC_605_MIERCOLES1 OC_605_JUEVES1 OC_605_VIERNES1 OC_605_SABADO1 OC_605_DOMINGO1), missing
    replace whours_2 = . if lstatus != 1 | CA519 <= 1 | missing(CA519)
    label var whours_2 "Hours of work in last week secondary job 7 day recall"

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
	    gen double `sec_sal_cash' = OC6171 * OC6181 if OC617_TIPO_DE_MONEDA1 == 1 & OC6171 >= 0 & OC6171 < 999999 & OC6181 > 0 & OC6181 < 999999

	    local sec_inkind_components
	    foreach v in OC619_ALIMENTOS1 OC619_HABITACION1 OC619_ROPA_CALZADO1 OC619_TRANSPORTE1 OC619_COMISION1 OC619_BONIFICACION1 OC619_PROPINAS1 OC619_HORAS_EXTRAS1 {
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

	    egen double wage_no_compen_2 = rowtotal(`sec_sal_cash' `sec_sal_inkind' `sec_self_cash' `sec_self_inkind'), missing
	    replace wage_no_compen_2 = . if lstatus != 1 | CA519 <= 1 | missing(CA519)
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
    replace firmsize_l_2 = 1 if lstatus == 1 & CA519 > 1 & OC6081 == 1
    replace firmsize_u_2 = 10 if lstatus == 1 & CA519 > 1 & OC6081 == 1
    replace firmsize_l_2 = 11 if lstatus == 1 & CA519 > 1 & OC6081 == 2
    replace firmsize_u_2 = 50 if lstatus == 1 & CA519 > 1 & OC6081 == 2
    replace firmsize_l_2 = 51 if lstatus == 1 & CA519 > 1 & OC6081 == 3
    replace firmsize_u_2 = 150 if lstatus == 1 & CA519 > 1 & OC6081 == 3
    replace firmsize_l_2 = 151 if lstatus == 1 & CA519 > 1 & OC6081 == 4
    label var firmsize_l_2 "Firm size (lower bound), secondary job 7 day recall"
    label var firmsize_u_2 "Firm size (upper bound), secondary job 7 day recall"
*</_secondary_job_>

*<_totals_>
    gen double t_hours_others = whours_2
    gen double t_wage_nocompen_others = wage_no_compen_2
    gen double t_wage_others = wage_total_2
    egen t_hours_total = rowtotal(whours whours_2), missing
    gen double t_wage_nocompen_total = .
    * Leave t_wage_nocompen_total missing until a total labor-income rule is approved.
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
    9: Annual labor variables and final missing variables
==============================================================================================%%*/

{

*<_annual_labor_>
/* <_annual_labor_note>
    The received raw data do not identify annual labor-status, annual hours,
    months-worked, or non-comparable labor income sources. Annual labor variables
    and linc_nc are left missing.
</_annual_labor_note> */
    foreach v in lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industrycat10_year industrycat4_year occup_skill_year occup_year unitwage_year whours_year wmonths_year wage_no_compen_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industrycat10_2_year industrycat4_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year t_hours_annual linc_nc laborincome {
        gen double `v' = .
    }
    foreach v in industry_orig_year industrycat_isic_year occup_orig_year occup_isco_year industry_orig_2_year industrycat_isic_2_year occup_orig_2_year occup_isco_2_year {
        gen str20 `v' = ""
    }
*</_annual_labor_>

}


/*%%=============================================================================================
    10: Final checks and save
==============================================================================================%%*/

compress

local keep_vars countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu ssu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

keep `keep_vars'
order `keep_vars'

save "`path_output'/`level_2_harm'_ALL.dta", replace
