/*%%=============================================================================================
    0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>             HND_2025_EPHPM_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>              Stata </_Application_>
<_Author(s)_>                World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>             2026-06-11 </_Date created_>

-------------------------------------------------------------------------

<_Country_>                  Honduras (HND) </_Country_>
<_Survey Title_>             Encuesta Permanente de Hogares de Propositos Multiples </_Survey Title_>
<_Survey Year_>              2025 </_Survey Year_>
<_Data collection from_>     07/2025 </_Data collection from_>
<_Data collection to_>       07/2025 </_Data collection to_>
<_Source of dataset_>        Instituto Nacional de Estadistica, Honduras </_Source of dataset_>
<_Currency_>                 Lempiras </_Currency_>

-------------------------------------------------------------------------

<_ICLS Version_>             ICLS-19 </_ICLS Version_>
<_ISCED Version_>            Not coded; no documented ISCED crosswalk in the report </_ISCED Version_>
<_ISCO Version_>             ISCO-08 </_ISCO Version_>
<_OCCUP National_>           National occupation extension, grouped to ISCO-08 </_OCCUP National_>
<_ISIC Version_>             ISIC Rev. 4 </_ISIC Version_>
<_INDUS National_>           National industry extension, grouped to ISIC Rev. 4 </_INDUS National_>

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

*----------1.2: Set directories------------------------------*

if "`c(username)'" == "wb510859" {
	local server "C:/Users/`c(username)'/OneDrive - WBG/GLD - Current Contributors/510859_AS"
}
else {
	local server "C:/Users/`c(username)'/WBG/GLD - Current Contributors/510859_AS"
}
local country "HND"
local year    "2025"
local survey  "EPHPM"
local vermast "V01"
local veralt  "V01"

local level_1      "`country'_`year'_`survey'"
local level_2_mast "`level_1'_`vermast'_M"
local level_2_harm "`level_1'_`vermast'_M_`veralt'_A_GLD"

local path_in_stata "`server'/`country'/`level_1'/`level_2_mast'/Data/Stata"
local path_in_other "`server'/`country'/`level_1'/`level_2_mast'/Data/Original"
local path_output   "`server'/`country'/`level_1'/`level_2_harm'/Data/Harmonized"
local path_work     "`server'/`country'/`level_1'/`level_2_harm'/Work"

capture log close
log using "`path_work'/HND_2025_harmonization.log", replace text

*----------1.3: Database assembly------------------------------*

use "`path_in_stata'/EPHPM JDULIO 2025.dta", clear


/*%%=============================================================================================
    2: Survey, ID, geography, and demographics
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
    gen str10 icls_v = "ICLS-19"
    label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>

*<_isced_version_>
    gen strL isced_version = ""
    label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>

*<_isco_version_>
    gen str10 isco_version = "isco_2008"
    label var isco_version "Version of ISCO used"
*</_isco_version_>

*<_isic_version_>
    gen str10 isic_version = "isic_4"
    label var isic_version "Version of ISIC used"
*</_isic_version_>

*<_year_>
    gen int year = 2025
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
    gen int int_year = 2025
    label var int_year "Year of the interview"
*</_int_year_>

*<_int_month_>
    gen byte int_month = 7
    label var int_month "Month of the interview"
*</_int_month_>

*<_hhid_>
/* <_hhid_note>
The 2023 household identifier ID is absent in 2025. The adjacent-year report
shows HOGAR is nonmissing for all records and HOGAR NPER uniquely identifies
persons in the target raw file.
</_hhid_note> */
    gen str20 hhid = strtrim(string(HOGAR, "%20.0f"))
    label var hhid "Household ID"
*</_hhid_>

*<_pid_>
    gen str30 pid = hhid + "-" + strtrim(string(NPER, "%02.0f"))
    isid pid
    label var pid "Individual ID"
*</_pid_>

*<_weight_>
    gen double weight = FACTOR
    label var weight "Survey sampling weight"
*</_weight_>

*<_psu_>
    gen double psu = COR_PRE
    label var psu "Primary sampling units"
*</_psu_>

*<_strata_>
    gen double strata = DOMINIO
    label var strata "Strata"
*</_strata_>

*<_urban_>
    gen byte urban = .
    replace urban = 1 if UR == 1
    replace urban = 0 if UR == 2
    label define lblurban 1 "Urban" 0 "Rural", replace
    label values urban lblurban
    label var urban "Location is urban"
*</_urban_>

*<_subnatid1_>
    gen str40 region_est2 = ""
    replace region_est2 = "01 - Atlantida" if DEPTO == 1
    replace region_est2 = "02 - Colon" if DEPTO == 2
    replace region_est2 = "03 - Comayagua" if DEPTO == 3
    replace region_est2 = "04 - Copan" if DEPTO == 4
    replace region_est2 = "05 - Cortes" if DEPTO == 5
    replace region_est2 = "06 - Choluteca" if DEPTO == 6
    replace region_est2 = "07 - El Paraiso" if DEPTO == 7
    replace region_est2 = "08 - Francisco Morazan" if DEPTO == 8
    replace region_est2 = "09 - Gracias a Dios" if DEPTO == 9
    replace region_est2 = "10 - Intibuca" if DEPTO == 10
    replace region_est2 = "11 - Islas de Bahia" if DEPTO == 11
    replace region_est2 = "12 - La Paz" if DEPTO == 12
    replace region_est2 = "13 - Lempira" if DEPTO == 13
    replace region_est2 = "14 - Ocotepeque" if DEPTO == 14
    replace region_est2 = "15 - Olancho" if DEPTO == 15
    replace region_est2 = "16 - Santa Barbara" if DEPTO == 16
    replace region_est2 = "17 - Valle" if DEPTO == 17
    replace region_est2 = "18 - Yoro" if DEPTO == 18
    gen str40 subnatid1 = region_est2
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
    gen str40 subnatidsurvey = ""
    replace subnatidsurvey = "1 - Distrito Central" if domi == 1
    replace subnatidsurvey = "2 - San Pedro Sula" if domi == 2
    replace subnatidsurvey = "3 - Resto Urbano" if domi == 3
    replace subnatidsurvey = "4 - Rural" if domi == 4
    label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>

*<_hsize_>
    gen double hsize = TOTPER
    label var hsize "Household size"
*</_hsize_>

*<_age_>
    gen double age = EDAD
    label var age "Individual age"
*</_age_>

*<_male_>
    gen byte male = .
    replace male = 1 if SEXO == 1
    replace male = 0 if SEXO == 2
    label define lblmale 0 "Female" 1 "Male", replace
    label values male lblmale
    label var male "Sex - Ind is male"
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
    replace marital = 3 if CIVIL == 6
    replace marital = 5 if CIVIL == 2
    replace marital = 4 if inlist(CIVIL, 3, 4)
    replace marital = 2 if CIVIL == 5
    label define lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed", replace
    label values marital lblmarital
    label var marital "Marital status"
*</_marital_>

}


/*%%=============================================================================================
    3: Disability and migration
==============================================================================================%%*/

{

*<_disability_>
/* <_disability_note>
The 2025 raw file does not contain CH307, the 2023 disability source identified
in the reference report. Disability variables are intentionally left missing.
</_disability_note> */
    gen byte eye_dsablty = .
    gen byte hear_dsablty = .
    gen byte walk_dsablty = .
    gen byte conc_dsord = .
    gen byte slfcre_dsablty = .
    gen byte comm_dsablty = .
    label var eye_dsablty "Disability related to eyesight"
    label var hear_dsablty "Disability related to hearing"
    label var walk_dsablty "Disability related to walking or climbing stairs"
    label var conc_dsord "Disability related to concentration or remembering"
    label var slfcre_dsablty "Disability related to selfcare"
    label var comm_dsablty "Disability related to communicating"
*</_disability_>

*<_migration_>
/* <_migration_note>
The 2023 CD* migration variables are absent from the 2025 raw file. The report
does not identify an alternate migration source.
</_migration_note> */
    gen byte migrated_mod_age = .
    gen byte migrated_ref_time = .
    gen byte migrated_binary = .
    gen double migrated_years = .
    gen byte migrated_from_urban = .
    gen byte migrated_from_cat = .
    gen strL migrated_from_code = ""
    gen str3 migrated_from_country = ""
    gen byte migrated_reason = .
    label var migrated_mod_age "Migration module application age"
    label var migrated_ref_time "Migration reference time"
    label var migrated_binary "Individual has migrated"
    label var migrated_years "Years since latest migration"
    label var migrated_from_urban "Migrant came from an urban area"
    label var migrated_from_cat "Category of migration area"
    label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
    label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
    label var migrated_reason "Reason for migrating"
*</_migration_>

}


/*%%=============================================================================================
    4: Education
==============================================================================================%%*/

{

*<_ed_mod_age_>
    gen byte ed_mod_age = 3
    label var ed_mod_age "Education module application age"
*</_ed_mod_age_>

*<_school_>
    gen byte school = .
    replace school = 1 if ED03 == 1
    replace school = 0 if ED03 == 2
    label define lblschool 0 "No" 1 "Yes", replace
    label values school lblschool
    label var school "Attending school"
*</_school_>

*<_literacy_>
/* <_literacy_note>
The 2023 literacy source ED01 is absent from the 2025 raw file.
</_literacy_note> */
    gen byte literacy = .
    label var literacy "Individual can read & write"
*</_literacy_>

*<_educy_>
/* <_educy_note>
    Leave educy missing for series consistency. Although anosest is present, the
    years-of-schooling construction was not cleared consistently across HND
    years, so education attainment is harmonized through educat7.
</_educy_note> */
    gen double educy = .
    label var educy "Years of education"
*</_educy_>

*<_educat7_>
/* <_educat7_note>
The 2025 report keeps the HND education ladder but adapts fallback variables to
lowercase nivel and anosest. ED07 is not observed for ED05=5 in 2025, so ED08
is used to split Media/Diversificado: years 1-2 are secondary incomplete and
years 3-4 are secondary complete, matching the adjacent-year pattern.
</_educat7_note> */
    gen byte educat7 = .
    replace educat7 = 1 if inlist(ED05, 1, 2, 3)
    replace educat7 = 2 if ED05 == 4 & inrange(ED08, 1, 5)
    replace educat7 = 3 if ED05 == 4 & ED08 == 6
    replace educat7 = 4 if ED05 == 4 & inrange(ED08, 7, 9)
    replace educat7 = 4 if ED05 == 5 & inlist(ED08, 1, 2)
    replace educat7 = 5 if ED05 == 5 & inlist(ED08, 3, 4)
    replace educat7 = 6 if inlist(ED05, 6, 7)
    replace educat7 = 7 if inlist(ED05, 8, 9, 10, 11)

    replace educat7 = 1 if missing(educat7) & ED10 == 3
    replace educat7 = 1 if missing(educat7) & ED10 == 4 & ED13 == 1
    replace educat7 = 2 if missing(educat7) & ED10 == 4 & inrange(ED13, 2, 6)
    replace educat7 = 3 if missing(educat7) & ED10 == 4 & ED13 == 7
    replace educat7 = 4 if missing(educat7) & ED10 == 4 & inrange(ED13, 8, 9)
    replace educat7 = 4 if missing(educat7) & ED10 == 5
    replace educat7 = 6 if missing(educat7) & inlist(ED10, 6, 7)
    replace educat7 = 7 if missing(educat7) & inlist(ED10, 8, 9, 10, 11)

    replace educat7 = 1 if missing(educat7) & nivel == 1
    replace educat7 = 2 if missing(educat7) & nivel == 2 & inrange(anosest, 1, 5)
    replace educat7 = 3 if missing(educat7) & nivel == 2 & anosest == 6
    replace educat7 = 4 if missing(educat7) & nivel == 2 & inrange(anosest, 7, 9)
    replace educat7 = 4 if missing(educat7) & nivel == 3 & anosest < 12
    replace educat7 = 5 if missing(educat7) & nivel == 3 & anosest >= 12 & anosest < .
    replace educat7 = 4 if missing(educat7) & nivel == 4 & anosest < 12
    replace educat7 = 5 if missing(educat7) & nivel == 4 & anosest >= 12 & anosest < .
    replace educat7 = 7 if missing(educat7) & nivel == 5

    label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete", replace
    label values educat7 lbleducat7
    label var educat7 "Level of education 1"
*</_educat7_>

*<_educat5_>
    gen byte educat5 = .
    replace educat5 = 1 if educat7 == 1
    replace educat5 = 2 if educat7 == 2
    replace educat5 = 3 if inlist(educat7, 3, 4)
    replace educat5 = 4 if educat7 == 5
    replace educat5 = 5 if inlist(educat7, 6, 7)
    label define lbleducat5 1 "No education" 2 "Primary incomplete" 3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary", replace
    label values educat5 lbleducat5
    label var educat5 "Level of education 2"
*</_educat5_>

*<_educat4_>
    gen byte educat4 = .
    replace educat4 = 1 if educat7 == 1
    replace educat4 = 2 if inlist(educat7, 2, 3, 4)
    replace educat4 = 3 if educat7 == 5
    replace educat4 = 4 if inlist(educat7, 6, 7)
    label define lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary", replace
    label values educat4 lbleducat4
    label var educat4 "Level of education 3"
*</_educat4_>

*<_educat_orig_>
    gen int educat_orig = ED05
    replace educat_orig = ED10 if missing(educat_orig) & !missing(ED10)
    replace educat_orig = nivel if missing(educat_orig) & !missing(nivel)
    label var educat_orig "Original survey education code"
*</_educat_orig_>

}


/*%%=============================================================================================
    5: Labor status
==============================================================================================%%*/

{

*<_minlaborage_>
    gen byte minlaborage = 15
    label var minlaborage "Labor module application age"
*</_minlaborage_>

*<_lstatus_>
/* <_lstatus_note>
The adjacent-year report documents that CONDACT differs from the reconstructed
route for 109 persons age 15+. Following the labor-status skill, CONDACT is
used only as a diagnostic comparison. Employment is assigned first from the
route blocks, unemployment is then assigned to non-employed people with search
or future-start evidence and availability, and remaining age-eligible records
are coded non-LF.
</_lstatus_note> */
    gen byte __age15 = age >= 15 & age < .
    gen byte __emp_route = 0 if __age15 == 1

    replace __emp_route = 1 if __age15 == 1 & CA501 == 1 & CA502 == 1
    replace __emp_route = 1 if __age15 == 1 & __emp_route == 0 & inrange(CA503, 1, 9)
    replace __emp_route = 1 if __age15 == 1 & __emp_route == 0 & CA504 == 1 & inrange(CA505, 1, 4)
    replace __emp_route = 1 if __age15 == 1 & __emp_route == 0 & CA504 == 1 & CA506 == 1
    replace __emp_route = 1 if __age15 == 1 & __emp_route == 0 & CA504 == 1 & inlist(CA507, 1, 2)
    replace __emp_route = 1 if __age15 == 1 & __emp_route == 0 & CA508 == 1 & CA508A == 1

    gen byte __search_start = 0 if __age15 == 1 & __emp_route == 0
    replace __search_start = 1 if __age15 == 1 & __emp_route == 0 & CA512 == 1
    replace __search_start = 1 if __age15 == 1 & __emp_route == 0 & inlist(CA513, 1, 2)

    gen byte __available = 0 if __age15 == 1 & __emp_route == 0
    replace __available = 1 if __age15 == 1 & __emp_route == 0 & inlist(CA511, 1, 2)
    replace __available = . if __age15 == 1 & __emp_route == 0 & CA511 == 9

    gen byte lstatus = .
    replace lstatus = 1 if __age15 == 1 & __emp_route == 1
    replace lstatus = 2 if __age15 == 1 & __emp_route == 0 & __search_start == 1 & __available == 1
    replace lstatus = 3 if __age15 == 1 & missing(lstatus)
    replace lstatus = . if age < minlaborage & age < .

    label define lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF", replace
    label values lstatus lbllstatus
    label var lstatus "Labor status"
*</_lstatus_>

*<_potential_lf_>
    gen byte potential_lf = .
    replace potential_lf = 1 if lstatus == 3 & __search_start == 1 & __available != 1
    replace potential_lf = 1 if lstatus == 3 & __search_start != 1 & __available == 1
    replace potential_lf = 0 if lstatus == 3 & missing(potential_lf) & !missing(__search_start) & !missing(__available)
    label define lblpotential_lf 0 "No" 1 "Yes", replace
    label values potential_lf lblpotential_lf
    label var potential_lf "Potential labor force"
*</_potential_lf_>

*<_underemployment_>
/* <_underemployment_note>
    Underemployment uses the direct more-hours and availability questions, in
    line with the 2021-2024 construction. The derived ACTIVIDA grouping is not
    used because it gives a narrower time-related underemployment count in 2025.
</_underemployment_note> */
    gen byte underemployment = .
    replace underemployment = 0 if lstatus == 1 & !missing(CA522)
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
    replace nlfreason = 4 if lstatus == 3 & inlist(CA514, 7, 8)
    replace nlfreason = 5 if lstatus == 3 & inlist(CA514, 6, 9, 97)
    label define lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other", replace
    label values nlfreason lblnlfreason
    label var nlfreason "Reason not in the labor force"
*</_nlfreason_>

*<_unempldur_l_>
    gen double __unempldur_months = .
    replace __unempldur_months = ceil(CA516TIEMPO / 30) if lstatus == 2 & CA516DSM == 1 & CA516TIEMPO < .
    replace __unempldur_months = ceil(CA516TIEMPO / 4.345) if lstatus == 2 & CA516DSM == 2 & CA516TIEMPO < .
    replace __unempldur_months = CA516TIEMPO if lstatus == 2 & CA516DSM == 3 & CA516TIEMPO < .
    replace __unempldur_months = . if __unempldur_months < 0
    gen double unempldur_l = __unempldur_months
    label var unempldur_l "Unemployment duration lower bound"
*</_unempldur_l_>

*<_unempldur_u_>
    gen double unempldur_u = __unempldur_months
    label var unempldur_u "Unemployment duration upper bound"
*</_unempldur_u_>

}


/*%%=============================================================================================
    6: Employment status, sector, classifications, hours, and wages
==============================================================================================%%*/

{

*<_empstat_>
    gen byte empstat = .
    replace empstat = 1 if lstatus == 1 & inlist(OC609, 1, 2, 3, 4, 5)
    replace empstat = 1 if lstatus == 1 & inlist(OC609, 9, 10, 11)
    replace empstat = 2 if lstatus == 1 & OC609 == 8
    replace empstat = 3 if lstatus == 1 & OC609 == 6
    replace empstat = 4 if lstatus == 1 & OC609 == 7
    label define lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status", replace
    label values empstat lblempstat
    label var empstat "Employment status during past week primary job 7 day recall"
*</_empstat_>

*<_ocusec_>
    gen byte ocusec = .
    replace ocusec = 1 if lstatus == 1 & inlist(OC609, 1, 4, 9)
    replace ocusec = 2 if lstatus == 1 & inlist(OC609, 2, 3, 5, 6, 7)
    replace ocusec = 2 if lstatus == 1 & inlist(OC609, 8, 10, 11)
    label define lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish", replace
    label values ocusec lblocusec
    label var ocusec "Sector of activity primary job 7 day recall"
*</_ocusec_>

*<_industry_orig_>
    gen str12 industry_orig = ""
    replace industry_orig = strtrim(string(O02_CODIGO, "%12.0f")) if lstatus == 1 & O02_CODIGO < .
    replace industry_orig = "" if inlist(industry_orig, "99999", "999999")
    label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>

*<_industrycat_isic_>
/* <_industrycat_isic_note>
Industrycat_isic uses the first four digits of the detailed industry code when
valid. Raw code 999801 produces unsupported group 9998 and is left missing for
64 employed records rather than recoded to 9900, which would imply
extraterritorial activities.
</_industrycat_isic_note> */
    gen str6 __ind_code = ""
    replace __ind_code = "0" + string(O02_CODIGO, "%04.0f") if lstatus == 1 & O02_CODIGO < 10000 & O02_CODIGO < .
    replace __ind_code = string(O02_CODIGO, "%05.0f") if lstatus == 1 & inrange(O02_CODIGO, 10000, 99999)
    replace __ind_code = string(O02_CODIGO, "%06.0f") if lstatus == 1 & inrange(O02_CODIGO, 100000, 999998)
    gen str4 industrycat_isic = substr(__ind_code, 1, 4)
    replace industrycat_isic = "" if inlist(O02_CODIGO, 99999, 999999) | lstatus != 1
    replace industrycat_isic = "" if inlist(industrycat_isic, "8990", "9998")
    replace industry_orig = "" if industrycat_isic == ""
    label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>

*<_industrycat10_>
/* <_industrycat10_note>
Industrycat10 is derived from the first two digits of industrycat_isic so the
broad industry category remains aligned with the retained ISIC code. The broad
RAMAOP variable is not used when it disagrees with the detailed code.
</_industrycat10_note> */
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
    gen byte industrycat4 = .
    replace industrycat4 = 1 if industrycat10 == 1
    replace industrycat4 = 2 if inlist(industrycat10, 2, 3, 4, 5)
    replace industrycat4 = 3 if inlist(industrycat10, 6, 7, 8, 9)
    replace industrycat4 = 4 if industrycat10 == 10
    label define lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other", replace
    label values industrycat4 lblindustrycat4
    label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
*</_industrycat4_>

*<_occup_orig_>
    gen str12 occup_orig = ""
    replace occup_orig = strtrim(string(O01_CODIGO, "%12.0f")) if lstatus == 1 & O01_CODIGO < .
    replace occup_orig = "" if O01_CODIGO == 999999
    label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>

*<_occup_isco_>
/* <_occup_isco_note>
The detailed occupation codes 3450 and 5170 are not valid ISCO-08 codes after
the first-three-digit construction. They affect 81 employed records and are
collapsed to the valid two-digit ISCO-08 groups 3400 and 5100.
</_occup_isco_note> */
    gen str6 __occraw = strtrim(string(O01_CODIGO, "%12.0f"))
    gen str4 occup_isco = ""
    replace occup_isco = substr(__occraw, 1, 3) + "0" if lstatus == 1 & O01_CODIGO < . & strlen(__occraw) >= 5
    replace occup_isco = substr(occup_isco, 1, 2) + "00" if inlist(occup_isco, "3450", "5170")
    replace occup_isco = "" if O01_CODIGO == 999999 | O01_CODIGO == 989901 | lstatus != 1
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
    replace occup_skill = 3 if inlist(occup, 1, 2, 3)
    replace occup_skill = 2 if inlist(occup, 4, 5, 6, 7, 8)
    replace occup_skill = 1 if occup == 9
    label define lbloccup_skill 1 "Low skill" 2 "Medium skill" 3 "High skill", replace
    label values occup_skill lbloccup_skill
    label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>

*<_wage_no_compen_>
/* <_wage_no_compen_note>
The 2025 report clears the retained pay-period components OC617/OC618 for
employee pay and OC628 for employer or own-account monthly gains. OC617 is used
only when the retained currency flag is lempiras. The result is a monthly
lempira amount; lowercase ytraop is kept separately as total labor income.
</_wage_no_compen_note> */
    gen double wage_no_compen = .
    replace wage_no_compen = OC617 * OC618 if lstatus == 1 & OC617_TIPO_DE_MONEDA == 1 & OC617 < . & OC618 < .
    replace wage_no_compen = OC628 if lstatus == 1 & inlist(empstat, 3, 4) & OC628 < .
    replace wage_no_compen = . if wage_no_compen <= 0
    label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>

*<_unitwage_>
    gen byte unitwage = .
    replace unitwage = 5 if wage_no_compen < .
    label define lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly" 5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other", replace
    label values unitwage lblunitwage
    label var unitwage "Last wages' time unit primary job 7 day recall"
*</_unitwage_>

*<_whours_>
    egen double whours = rowtotal(OC_605_LUNES OC_605_MARTES OC_605_MIERCOLES OC_605_JUEVES OC_605_VIERNES OC_605_SABADO OC_605_DOMINGO), missing
    replace whours = . if lstatus != 1
    replace whours = . if whours == 0
    label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>

*<_wage_total_>
/* <_wage_total_note>
    Left missing. The retained main-job wage concept is wage_no_compen; broader
    wage-total variables are not harmonized for this survey.
</_wage_total_note> */
    gen double wage_total = .
    label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>

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

*<_firmsize_l_>
    gen double firmsize_l = .
    replace firmsize_l = 1 if lstatus == 1 & OC608 == 1
    replace firmsize_l = 11 if lstatus == 1 & OC608 == 2
    replace firmsize_l = 51 if lstatus == 1 & OC608 == 3
    replace firmsize_l = 151 if lstatus == 1 & OC608 == 4
    label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>

*<_firmsize_u_>
    gen double firmsize_u = .
    replace firmsize_u = 10 if lstatus == 1 & OC608 == 1
    replace firmsize_u = 50 if lstatus == 1 & OC608 == 2
    replace firmsize_u = 150 if lstatus == 1 & OC608 == 3
    label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

*<_empstat_2_>
    gen byte empstat_2 = .
    replace empstat_2 = 1 if lstatus == 1 & CA519 > 1 & inlist(OC6091, 1, 2, 3, 4, 5)
    replace empstat_2 = 1 if lstatus == 1 & CA519 > 1 & inlist(OC6091, 9, 10, 11)
    replace empstat_2 = 2 if lstatus == 1 & CA519 > 1 & OC6091 == 8
    replace empstat_2 = 3 if lstatus == 1 & CA519 > 1 & OC6091 == 6
    replace empstat_2 = 4 if lstatus == 1 & CA519 > 1 & OC6091 == 7
    label values empstat_2 lblempstat
    label var empstat_2 "Employment status during past week secondary job 7 day recall"
*</_empstat_2_>

*<_ocusec_2_>
    gen byte ocusec_2 = .
    replace ocusec_2 = 1 if lstatus == 1 & CA519 > 1 & inlist(OC6091, 1, 4, 9)
    replace ocusec_2 = 2 if lstatus == 1 & CA519 > 1 & inlist(OC6091, 2, 3, 5, 6, 7)
    replace ocusec_2 = 2 if lstatus == 1 & CA519 > 1 & inlist(OC6091, 8, 10, 11)
    label values ocusec_2 lblocusec
    label var ocusec_2 "Sector of activity secondary job 7 day recall"
*</_ocusec_2_>

*<_industry_orig_2_>
    gen str12 industry_orig_2 = ""
    replace industry_orig_2 = strtrim(string(OS02_CODIGO, "%12.0f")) if lstatus == 1 & CA519 > 1 & OS02_CODIGO < .
    replace industry_orig_2 = "" if inlist(industry_orig_2, "99999", "999999")
    label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>

*<_industrycat_isic_2_>
    gen str6 __ind2_code = ""
    replace __ind2_code = "0" + string(OS02_CODIGO, "%04.0f") if lstatus == 1 & CA519 > 1 & OS02_CODIGO < 10000 & OS02_CODIGO < .
    replace __ind2_code = string(OS02_CODIGO, "%05.0f") if lstatus == 1 & CA519 > 1 & inrange(OS02_CODIGO, 10000, 99999)
    replace __ind2_code = string(OS02_CODIGO, "%06.0f") if lstatus == 1 & CA519 > 1 & inrange(OS02_CODIGO, 100000, 999998)
    gen str4 industrycat_isic_2 = substr(__ind2_code, 1, 4)
    replace industrycat_isic_2 = "" if inlist(OS02_CODIGO, 99999, 999999) | lstatus != 1 | CA519 <= 1
    replace industrycat_isic_2 = "" if inlist(industrycat_isic_2, "8990", "9998")
    label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>

*<_industrycat10_2_>
    tempvar isic2_2
    gen byte `isic2_2' = real(substr(industrycat_isic_2, 1, 2)) if industrycat_isic_2 != ""
    gen byte industrycat10_2 = .
    replace industrycat10_2 = 1 if inrange(`isic2_2', 1, 3)
    replace industrycat10_2 = 2 if inrange(`isic2_2', 5, 9)
    replace industrycat10_2 = 3 if inrange(`isic2_2', 10, 33)
    replace industrycat10_2 = 4 if inrange(`isic2_2', 35, 39)
    replace industrycat10_2 = 5 if inrange(`isic2_2', 41, 43)
    replace industrycat10_2 = 6 if inrange(`isic2_2', 45, 47) | inrange(`isic2_2', 55, 56)
    replace industrycat10_2 = 7 if inrange(`isic2_2', 49, 53) | inrange(`isic2_2', 58, 63)
    replace industrycat10_2 = 8 if inrange(`isic2_2', 64, 82)
    replace industrycat10_2 = 9 if `isic2_2' == 84
    replace industrycat10_2 = 10 if inrange(`isic2_2', 85, 99)
    label values industrycat10_2 lblindustrycat10
    label var industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
*</_industrycat10_2_>

*<_industrycat4_2_>
    gen byte industrycat4_2 = .
    replace industrycat4_2 = 1 if industrycat10_2 == 1
    replace industrycat4_2 = 2 if inlist(industrycat10_2, 2, 3, 4, 5)
    replace industrycat4_2 = 3 if inlist(industrycat10_2, 6, 7, 8, 9)
    replace industrycat4_2 = 4 if industrycat10_2 == 10
    label values industrycat4_2 lblindustrycat4
    label var industrycat4_2 "Broad Economic Activities classification, secondary job 7 day recall"
*</_industrycat4_2_>

*<_occup_orig_2_>
    gen str12 occup_orig_2 = ""
    replace occup_orig_2 = strtrim(string(OS01_CODIGO, "%12.0f")) if lstatus == 1 & CA519 > 1 & OS01_CODIGO < .
    replace occup_orig_2 = "" if OS01_CODIGO == 999999
    label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>

*<_occup_isco_2_>
/* <_occup_isco_2_note>
Secondary occupation code 5170 is not valid in ISCO-08. It affects 3 records
and is collapsed to the valid two-digit ISCO-08 group 5100.
</_occup_isco_2_note> */
    gen str6 __occ2raw = strtrim(string(OS01_CODIGO, "%12.0f"))
    gen str4 occup_isco_2 = ""
    replace occup_isco_2 = substr(__occ2raw, 1, 3) + "0" if lstatus == 1 & CA519 > 1 & OS01_CODIGO < . & strlen(__occ2raw) >= 5
    replace occup_isco_2 = substr(occup_isco_2, 1, 2) + "00" if occup_isco_2 == "5170"
    replace occup_isco_2 = "" if OS01_CODIGO == 999999 | OS01_CODIGO == 989901 | lstatus != 1 | CA519 <= 1
    label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>

*<_occup_2_>
    gen byte occup_2 = .
    replace occup_2 = OCUPAOS if lstatus == 1 & CA519 > 1 & inrange(OCUPAOS, 1, 10)
    label values occup_2 lbloccup
    label var occup_2 "1 digit occupational classification, secondary job 7 day recall"
*</_occup_2_>

*<_occup_skill_2_>
    gen byte occup_skill_2 = .
    replace occup_skill_2 = 3 if inlist(occup_2, 1, 2, 3)
    replace occup_skill_2 = 2 if inlist(occup_2, 4, 5, 6, 7, 8)
    replace occup_skill_2 = 1 if occup_2 == 9
    label values occup_skill_2 lbloccup_skill
    label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>

*<_wage_no_compen_2_>
    gen double wage_no_compen_2 = .
    replace wage_no_compen_2 = OC6171 * OC6181 if lstatus == 1 & CA519 > 1 & OC617_TIPO_DE_MONEDA1 == 1 & OC6171 < . & OC6181 < .
    replace wage_no_compen_2 = OC6281 if lstatus == 1 & CA519 > 1 & inlist(empstat_2, 3, 4) & OC6281 < .
    replace wage_no_compen_2 = . if wage_no_compen_2 <= 0
    label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>

*<_unitwage_2_>
    gen byte unitwage_2 = .
    replace unitwage_2 = 5 if wage_no_compen_2 < .
    label values unitwage_2 lblunitwage
    label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
*</_unitwage_2_>

*<_whours_2_>
    egen double whours_2 = rowtotal(OC_605_LUNES1 OC_605_MARTES1 OC_605_MIERCOLES1 OC_605_JUEVES1 OC_605_VIERNES1 OC_605_SABADO1 OC_605_DOMINGO1), missing
    replace whours_2 = . if lstatus != 1 | CA519 <= 1
    replace whours_2 = . if whours_2 == 0
    label var whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>

*<_wage_total_2_>
/* <_wage_total_2_note>
    Left missing. The retained secondary-job wage concept is wage_no_compen_2;
    broader wage-total variables are not harmonized for this survey.
</_wage_total_2_note> */
    gen double wage_total_2 = .
    label var wage_total_2 "Annualized total wage secondary job 7 day recall"
*</_wage_total_2_>

*<_firmsize_l_2_>
    gen double firmsize_l_2 = .
    replace firmsize_l_2 = 1 if lstatus == 1 & CA519 > 1 & OC6081 == 1
    replace firmsize_l_2 = 11 if lstatus == 1 & CA519 > 1 & OC6081 == 2
    replace firmsize_l_2 = 51 if lstatus == 1 & CA519 > 1 & OC6081 == 3
    replace firmsize_l_2 = 151 if lstatus == 1 & CA519 > 1 & OC6081 == 4
    label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>

*<_firmsize_u_2_>
    gen double firmsize_u_2 = .
    replace firmsize_u_2 = 10 if lstatus == 1 & CA519 > 1 & OC6081 == 1
    replace firmsize_u_2 = 50 if lstatus == 1 & CA519 > 1 & OC6081 == 2
    replace firmsize_u_2 = 150 if lstatus == 1 & CA519 > 1 & OC6081 == 3
    label var firmsize_u_2 "Firm size (upper bracket) secondary job 7 day recall"
*</_firmsize_u_2_>

}


/*%%=============================================================================================
    7: Totals, remaining missing variables, and save
==============================================================================================%%*/

{

*<_totals_>
    gen double t_hours_total = whours
    replace t_hours_total = whours + whours_2 if whours < . & whours_2 < .
    replace t_hours_total = whours_2 if missing(t_hours_total) & whours_2 < .
    label var t_hours_total "Annualized hours worked in all jobs 7 day recall"

    gen double t_wage_nocompen_total = .
    label var t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"

    gen double t_wage_total = .
    label var t_wage_total "Annualized total wage for all jobs 7 day recall"

    gen double njobs = CA519 if lstatus == 1
    label var njobs "Total number of jobs"

    gen double t_hours_annual = t_hours_total * 52 if t_hours_total < .
    label var t_hours_annual "Total hours worked in all jobs in the previous 12 months"

    gen double linc_nc = .
    label var linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."

    gen double laborincome = .
    label var laborincome "Total annual individual labor income in all jobs, incl. bonuses, etc."
*</_totals_>

*<_remaining_missing_variables_>
    gen double weight_m = .
    gen double weight_q = .
    gen double ssu = .
    gen double wave = .
    gen str1 panel = ""
    gen double visit_no = .
    gen strL subnatid1_prev = ""
    gen strL subnatid2_prev = ""
    gen strL subnatid3_prev = ""
    gen double gaul_adm1_code = .
    gen double gaul_adm2_code = .
    gen double gaul_adm3_code = .
    gen byte educat_isced = .
    gen byte vocational = .
    gen byte vocational_type = .
    gen double vocational_length_l = .
    gen double vocational_length_u = .
    gen strL vocational_field_orig = ""
    gen byte vocational_financed = .
    gen double wmonths = .
    gen byte contract = .
    gen byte healthins = .
    gen byte union = .
    gen double wmonths_2 = .
    gen double t_hours_others = .
    gen double t_wage_nocompen_others = .
    gen double t_wage_others = .

    gen byte lstatus_year = .
    gen byte potential_lf_year = .
    gen byte underemployment_year = .
    gen byte nlfreason_year = .
    gen double unempldur_l_year = .
    gen double unempldur_u_year = .
    gen byte empstat_year = .
    gen byte ocusec_year = .
    gen strL industry_orig_year = ""
    gen strL industrycat_isic_year = ""
    gen byte industrycat10_year = .
    gen byte industrycat4_year = .
    gen strL occup_orig_year = ""
    gen strL occup_isco_year = ""
    gen byte occup_skill_year = .
    gen byte occup_year = .
    gen double wage_no_compen_year = .
    gen byte unitwage_year = .
    gen double whours_year = .
    gen double wmonths_year = .
    gen double wage_total_year = .
    gen byte contract_year = .
    gen byte healthins_year = .
    gen byte socialsec_year = .
    gen byte union_year = .
    gen double firmsize_l_year = .
    gen double firmsize_u_year = .
    gen byte empstat_2_year = .
    gen byte ocusec_2_year = .
    gen strL industry_orig_2_year = ""
    gen strL industrycat_isic_2_year = ""
    gen byte industrycat10_2_year = .
    gen byte industrycat4_2_year = .
    gen strL occup_orig_2_year = ""
    gen strL occup_isco_2_year = ""
    gen byte occup_skill_2_year = .
    gen byte occup_2_year = .
    gen double wage_no_compen_2_year = .
    gen byte unitwage_2_year = .
    gen double whours_2_year = .
    gen double wmonths_2_year = .
    gen double wage_total_2_year = .
    gen double firmsize_l_2_year = .
    gen double firmsize_u_2_year = .
    gen double t_hours_others_year = .
    gen double t_wage_nocompen_others_year = .
    gen double t_wage_others_year = .
    gen double t_hours_total_year = .
    gen double t_wage_nocompen_total_year = .
    gen double t_wage_total_year = .

    label var weight_m "Monthly weight"
    label var weight_q "Quarterly weight"
    label var ssu "Secondary sampling units"
    label var wave "Wave"
    label var panel "Panel"
    label var visit_no "Visit number"
    label var educat_isced "Level of education coded to ISCED"
    label var vocational "Vocational education"
    label var contract "Contract"
    label var healthins "Health insurance"
    label var union "Union membership"
*</_remaining_missing_variables_>

}

local keeplist countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu ssu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

keep `keeplist'
order `keeplist'
compress

save "`path_output'/`level_2_harm'_ALL.dta", replace

log close
