/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>         [HND_2023_EPHPM_V01_M_V01_A_GLD_ALL.do] </_Program name_>
<_Application_>          [STATA 17] </_Application_>
<_Author(s)_>             </_Author(s)_>
<_Date created_>         [2026-04-20] </_Date created_>

-------------------------------------------------------------------------

<_Country_>              [Honduras] </_Country_>
<_Survey Title_>         [Encuesta Permanente de Hogares de Propositos Multiples] </_Survey Title_>
<_Survey Year_>          [2023] </_Survey Year_>
<_Study ID_>             [HND_2023_EPHPM_V01_M] </_Study ID_>
<_Data collection from_> [2023-06-17] </_Data collection from_>
<_Data collection to_>   [2023-07-16] </_Data collection to_>
<_Source of dataset_>    [INE Honduras raw merged person-household file: Data de la Encuesta de Hogares junio 2023.dta] </_Source of dataset_>
<_Sample size (HH)_>     [5342] </_Sample size (HH)_>
<_Sample size (IND)_>    [20308] </_Sample size (IND)_>
<_Sampling method_>      [Probabilistico, estratificado y bietapico; UPM y USM seleccionadas mediante muestreo sistematico con arranque aleatorio.] </_Sampling method_>
<_Geographic coverage_>  [Cobertura nacional en viviendas particulares; dominios: Distrito Central, San Pedro Sula, Resto Urbano y Rural.] </_Geographic coverage_>
<_Currency_>             [Honduran lempira (HNL)] </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>         [ICLS-19] </_ICLS Version_>
<_ISCED Version_>        [Not coded; no documented ISCED crosswalk in the report] </_ISCED Version_>
<_ISCO Version_>         [isco_2008] </_ISCO Version_>
<_OCCUP National_>       [INE/OIT four-digit occupation classification, stored as a national six-digit extension in O01_CODIGO] </_OCCUP National_>
<_ISIC Version_>         [isic_4] </_ISIC Version_>
<_INDUS National_>       [INE/OIT activity classification with ISIC Rev.4 A-U section structure, stored as a national five/six-digit extension in O02_CODIGO] </_INDUS National_>

-----------------------------------------------------------------------
<_Version Control_>


</_Version Control_>

-------------------------------------------------------------------------*/

/*%%=============================================================================================
	1: Setting up of program environment, dataset
==============================================================================================%%*/

*----------1.1: Initial commands------------------------------*
version 17.0
clear
set more off
set mem 800m
set varabbrev off

*----------1.2: Set directories------------------------------*

* Define path sections
if "`c(username)'" == "wb510859" {
	local server "C:/Users/`c(username)'/OneDrive - WBG/GLD - Current Contributors/510859_AS"
}
else {
	local server "C:/Users/`c(username)'/WBG/GLD - Current Contributors/510859_AS"
}
local country "HND"
local year    "2023"
local survey  "EPHPM"
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
local path_work     "`server'/`country'/`level_1'/`level_2_harm'/Work"
capture mkdir "`path_output'"

*----------1.3: Database assembly------------------------------*
tempfile raw_stage region_map
use "`path_in_stata'/Data de la Encuesta de Hogares junio 2023.dta", clear
save "`raw_stage'", replace

import delimited using "`path_work'/hnd_ephpm_2023_region_map.csv", clear varnames(1) stringcols(_all)
destring cor_pre, replace force
replace region_est2 = strtrim(region_est2)
replace region_est3 = strtrim(region_est3)
rename cor_pre COR_PRE
keep COR_PRE region_est2 region_est3
duplicates drop
save "`region_map'", replace

use "`raw_stage'", clear
merge m:1 COR_PRE using "`region_map'", nogen keep(master match)

/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{
*<_countrycode_>
	gen str4 countrycode = "HND"
	label var countrycode "Country code"
*</_countrycode_>

*<_survname_>
	gen survname = "EPHPM"
	label var survname "Survey acronym"
*</_survname_>

*<_survey_>
	gen survey = "EPHPM"
	label var survey "Survey type"
*</_survey_>

*<_icls_v_>
	gen icls_v = "ICLS-19"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>

*<_isced_version_>
	gen isced_version = ""
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>

*<_isco_version_>
	gen isco_version = "isco_2008"
	label var isco_version "Version of ISCO used"
*</_isco_version_>

*<_isic_version_>
	gen isic_version = "isic_4"
	label var isic_version "Version of ISIC used"
*</_isic_version_>

*<_year_>
	gen int year = 2023
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
/* <_int_year_note>
</_int_year_note> */
	gen int int_year = 2023
	label var int_year "Year of the interview"
*</_int_year_>

*<_int_month_>
	gen int int_month = 6
	label var int_month "Month of the interview"
*</_int_month_>

*<_hhid_>
/* <_hhid_note>
The variable should be a string made up of the elements to define it, that is psu code, ssu, ...
Each element should always be as long as needed for the longest element. That is, if there are
60 psu coded 1 through 60, codes should be 01, 02, ..., 60. If there are 160 it should be 001,
002, ..., 160.
</_hhid_note> */
	capture confirm numeric variable ID
	if !_rc {
	    gen str16 hhid = strtrim(string(ID, "%16.0f"))
	}
	else {
	    gen str16 hhid = strtrim(ID)
	}
	replace hhid = "" if missing(ID)
	label var hhid "Household ID"
*</_hhid_>

*<_pid_>
/* <_pid_note>
GLD pid combines the household identifier with the raw person order NPER.
Raw NPER is a person order within household, so NPER alone is not unique in the
person-level file; hhid + NPER uniquely identifies each person.
</_pid_note> */
	gen str20 pid = hhid + string(NPER, "%02.0f")
	replace pid = "" if missing(NPER) | hhid == ""
	label var pid "Individual ID"
*</_pid_>

*<_weight_>
/* <_weight_note>
</_weight_note> */
	gen double weight = FACTOR
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
/* <_psu_note>
</_psu_note> */
	gen double psu = COR_PRE
	label var psu "Primary sampling units"
*</_psu_>

*<_ssu_>
	gen ssu = .
	label var ssu "Secondary sampling units"
*</_ssu_>

*<_strata_>
/* <_strata_note>
</_strata_note> */
	gen double strata = DOMINIO
	label var strata "Strata"
*</_strata_>

*<_wave_>
	gen wave = .
	label var wave "Survey wave"
*</_wave_>

*<_panel_>
	gen panel = ""
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
</_urban_note> */
	gen byte urban = .
	replace urban = 1 if DOMINIO != 5 & !missing(DOMINIO)
	replace urban = 0 if DOMINIO == 5
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>

*<_subnatid1_>
/* <_subnatid1_note>
The imported region map provides region_est2 as the department string. Use it
directly for first-level subnational geography.
</_subnatid1_note> */
	gen str30 subnatid1 = ""
	replace subnatid1 = string(real(substr(region_est2, 1, strpos(region_est2, " - ") - 1)), "%02.0f") + substr(region_est2, strpos(region_est2, " - "), strlen(region_est2)) if region_est2 != "" & strpos(region_est2, " - ") > 0
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>

*<_subnatid2_>
/* <_subnatid2_note>
The imported region map provides region_est3 as the municipality string. Use it
for second-level subnational geography.
</_subnatid2_note> */
	gen str40 subnatid2 = region_est3
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>

*<_subnatid3_>
/* <_subnatid3_note>
No current third-level geography source was identified in the checked 2023
person file or imported region map.
</_subnatid3_note> */
	gen str40 subnatid3 = ""
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>

*<_subnatidsurvey_>
/* <_subnatidsurvey_note>
Variable denoting lowest administrative info to which the survey is still significat.
See entry in GLD Guidelines (https://github.com/worldbank/gld/blob/main/Support/A%20-%20Guides%20and%20Documentation/GLD_1.0_Guidelines.docx) for more details
</_subnatidsurvey_note> */
	gen str40 subnatidsurvey = ""
	replace subnatidsurvey = "1 - Distrito Central (Tegucigalpa)" if DOMINIO == 1
	replace subnatidsurvey = "2 - San Pedro Sula" if DOMINIO == 2
	replace subnatidsurvey = "3 - Ciudades Medianas" if DOMINIO == 3
	replace subnatidsurvey = "4 - Ciudades Pequeñas" if DOMINIO == 4
	replace subnatidsurvey = "5 - Area Rural" if DOMINIO == 5
	label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>

*<_subnatid1_prev_>
/* <_subnatid1_prev_note>
subnatid1_prev is coded as missing unless the classification used for subnatid1 has changed since the previous survey.
</_subnatid1_prev_note> */
	gen str1 subnatid1_prev = ""
	label var subnatid1_prev "Classification used for subnatid1 from previous survey"
*</_subnatid1_prev_>

*<_subnatid2_prev_>
	gen str1 subnatid2_prev = ""
	label var subnatid2_prev "Classification used for subnatid2 from previous survey"
*</_subnatid2_prev_>

*<_subnatid3_prev_>
	gen str1 subnatid3_prev = ""
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
/* <_hsize_note>
</_hsize_note> */
	tempvar member_eligible
	gen byte `member_eligible' = RELA_J != 10 if !missing(RELA_J)
	bysort hhid: egen double hsize = total(`member_eligible')
	label var hsize "Household size"
*</_hsize_>

*<_age_>
/* <_age_note>
</_age_note> */
	gen age = EDAD
	label var age "Individual age"
*</_age_>

*<_male_>
/* <_male_note>
</_male_note> */
	gen byte male = .
	replace male = 1 if SEXO == 1
	replace male = 0 if SEXO == 2
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>

*<_relationharm_>
/* <_relationharm_note>
</_relationharm_note> */
	gen double relationharm = .
	replace relationharm = 1 if RELA_J == 1
	replace relationharm = 2 if RELA_J == 2
	replace relationharm = 3 if RELA_J == 3
	replace relationharm = 3 if RELA_J == 4
	replace relationharm = 4 if RELA_J == 5
	replace relationharm = 5 if RELA_J == 6
	replace relationharm = 5 if RELA_J == 7
	replace relationharm = 5 if RELA_J == 8
	replace relationharm = 6 if RELA_J == 9
	replace relationharm = 1 if RELA_J == 8 & NPER == 1
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

*<_relationcs_>
/* <_relationcs_note>
</_relationcs_note> */
	gen relationcs = RELA_J
	replace relationcs = 1 if RELA_J == 8 & NPER == 1
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>

*<_marital_>
/* <_marital_note>
</_marital_note> */
	gen byte marital = .
	replace marital = 1 if CIVIL == 1
	replace marital = 2 if CIVIL == 5
	replace marital = 3 if CIVIL == 6
	replace marital = 4 if inlist(CIVIL, 3, 4)
	replace marital = 5 if CIVIL == 2
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>

*<_eye_dsablty_>
/* <_disability_note>
CH307 is a single-response disability-domain question, not a severity scale. Mapped
reported domains are coded as "some difficulty"; "Ninguna" is coded as no difficulty.
The raw data cannot identify multiple simultaneous disability domains.
</_disability_note> */
	gen eye_dsablty = .
	replace eye_dsablty = 1 if CH307 == 9
	replace eye_dsablty = 2 if CH307 == 2
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
	label values eye_dsablty dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>

*<_hear_dsablty_>
	gen hear_dsablty = .
	replace hear_dsablty = 1 if CH307 == 9
	replace hear_dsablty = 2 if CH307 == 4
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values hear_dsablty dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>

*<_walk_dsablty_>
	gen walk_dsablty = .
	replace walk_dsablty = 1 if CH307 == 9
	replace walk_dsablty = 2 if CH307 == 1
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values walk_dsablty dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>

*<_conc_dsord_>
	gen conc_dsord = .
	replace conc_dsord = 1 if CH307 == 9
	replace conc_dsord = 2 if inlist(CH307, 6, 7)
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values conc_dsord dsablty
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>

*<_slfcre_dsablty_>
	gen slfcre_dsablty  = .
	replace slfcre_dsablty = 1 if CH307 == 9
	replace slfcre_dsablty = 2 if CH307 == 5
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values slfcre_dsablty dsablty
	label var slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>

*<_comm_dsablty_>
	gen comm_dsablty = .
	replace comm_dsablty = 1 if CH307 == 9
	replace comm_dsablty = 2 if CH307 == 3
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
	gen migrated_mod_age = 5
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>

*<_migrated_ref_time_>
/* <_migrated_ref_time_note>
The migration question measures whether the respondent has always lived in the
current place and, for movers, the duration lived there. This is not a fixed
reference window, so the reference period is coded as unknown.
</_migrated_ref_time_note> */
	gen migrated_ref_time = 99 if age >= migrated_mod_age
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>

*<_migrated_binary_>
	gen migrated_binary = .
	replace migrated_binary = 0 if age >= migrated_mod_age & CD03 == 1
	replace migrated_binary = 1 if age >= migrated_mod_age & CD03 == 2
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>

*<_migrated_years_>
	gen migrated_years = .
	replace migrated_years = CD03_2_TIEMPO if migrated_binary == 1
	* Clear household-level or otherwise inherited durations that exceed the respondent's age.
	replace migrated_years = . if migrated_binary == 1 & migrated_years > age & !missing(migrated_years, age)
	replace migrated_years = . if migrated_binary != 1
	label var migrated_years "Years since latest migration"
*</_migrated_years_>

*<_migrated_from_urban_>
	gen migrated_from_urban = .
	replace migrated_from_urban = . if migrated_binary != 1
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>

*<_migrated_from_cat_>
	gen migrated_from_cat = .
	gen double __cur_dept_code = real(substr(region_est2, 1, strpos(region_est2, " - ") - 1))
	gen double __cur_muni_code = real(substr(region_est3, 1, strpos(region_est3, " - ") - 1))
	gen str20 __prev_admin1 = ""
	replace __prev_admin1 = "2 - Norte" if inlist(CD04_DEPT, 1, 2, 5, 11, 18)
	replace __prev_admin1 = "3 - Occidente" if inlist(CD04_DEPT, 4, 13, 14, 16)
	replace __prev_admin1 = "4 - Sur" if inlist(CD04_DEPT, 6, 17)
	replace __prev_admin1 = "5 - Oriente" if inlist(CD04_DEPT, 7, 9, 15)
	replace __prev_admin1 = "6 - Central" if inlist(CD04_DEPT, 3, 8, 10, 12)
	replace migrated_from_cat = 1 if migrated_binary == 1 & CD04_MUNI == __cur_muni_code
	replace migrated_from_cat = 2 if migrated_binary == 1 & CD04_DEPT == __cur_dept_code & missing(migrated_from_cat)
	replace migrated_from_cat = 3 if migrated_binary == 1 & __prev_admin1 == subnatid1 & missing(migrated_from_cat)
	replace migrated_from_cat = 4 if migrated_binary == 1 & !missing(CD04_DEPT) & !inlist(CD04_DEPT, 50, 99) & missing(migrated_from_cat)
	replace migrated_from_cat = 5 if migrated_binary == 1 & (CD04_DEPT == 50 | !missing(CD04_PAIS))
	replace migrated_from_cat = 7 if migrated_binary == 1 & CD04_DEPT == 99
	replace migrated_from_cat = . if migrated_binary != 1
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country" 6 "Within country, admin unknown" 7 "Wholly unknow"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>

*<_migrated_from_code_>
	gen str30 migrated_from_code = ""
	replace migrated_from_code = subnatid3 if migrated_from_cat == 1
	replace migrated_from_code = string(CD04_MUNI, "%03.0f") if migrated_from_cat == 1 & migrated_from_code == ""
	replace migrated_from_code = subnatid2 if migrated_from_cat == 2
	replace migrated_from_code = string(CD04_DEPT, "%02.0f") if migrated_from_cat == 2 & migrated_from_code == ""
	replace migrated_from_code = __prev_admin1 if migrated_from_cat == 3
	replace migrated_from_code = "1 - Atlantida" if migrated_from_cat == 4 & CD04_DEPT == 1
	replace migrated_from_code = "2 - Colon" if migrated_from_cat == 4 & CD04_DEPT == 2
	replace migrated_from_code = "3 - Comayagua" if migrated_from_cat == 4 & CD04_DEPT == 3
	replace migrated_from_code = "4 - Copan" if migrated_from_cat == 4 & CD04_DEPT == 4
	replace migrated_from_code = "5 - Cortes" if migrated_from_cat == 4 & CD04_DEPT == 5
	replace migrated_from_code = "6 - Choluteca" if migrated_from_cat == 4 & CD04_DEPT == 6
	replace migrated_from_code = "7 - El Paraiso" if migrated_from_cat == 4 & CD04_DEPT == 7
	replace migrated_from_code = "8 - Francisco Morazan" if migrated_from_cat == 4 & CD04_DEPT == 8
	replace migrated_from_code = "9 - Gracias a Dios" if migrated_from_cat == 4 & CD04_DEPT == 9
	replace migrated_from_code = "10 - Intibuca" if migrated_from_cat == 4 & CD04_DEPT == 10
	replace migrated_from_code = "11 - Islas de Bahia" if migrated_from_cat == 4 & CD04_DEPT == 11
	replace migrated_from_code = "12 - La Paz" if migrated_from_cat == 4 & CD04_DEPT == 12
	replace migrated_from_code = "13 - Lempira" if migrated_from_cat == 4 & CD04_DEPT == 13
	replace migrated_from_code = "14 - Ocotepeque" if migrated_from_cat == 4 & CD04_DEPT == 14
	replace migrated_from_code = "15 - Olancho" if migrated_from_cat == 4 & CD04_DEPT == 15
	replace migrated_from_code = "16 - Santa Barbara" if migrated_from_cat == 4 & CD04_DEPT == 16
	replace migrated_from_code = "17 - Valle" if migrated_from_cat == 4 & CD04_DEPT == 17
	replace migrated_from_code = "18 - Yoro" if migrated_from_cat == 4 & CD04_DEPT == 18
	replace migrated_from_code = "" if migrated_binary != 1
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>

*<_migrated_from_country_>
	gen str3 migrated_from_country = ""
	replace migrated_from_country = "ECU" if CD04_PAIS == 50
	replace migrated_from_country = "SLV" if CD04_PAIS == 52
	replace migrated_from_country = "ESP" if CD04_PAIS == 57
	replace migrated_from_country = "USA" if CD04_PAIS == 58
	replace migrated_from_country = "GTM" if CD04_PAIS == 73
	replace migrated_from_country = "ITA" if CD04_PAIS == 91
	replace migrated_from_country = "MEX" if CD04_PAIS == 117
	replace migrated_from_country = "NIC" if CD04_PAIS == 127
	replace migrated_from_country = "PAN" if CD04_PAIS == 137
	replace migrated_from_country = "PRT" if CD04_PAIS == 142
	replace migrated_from_country = "MKD" if CD04_PAIS == 148
	replace migrated_from_country = "" if migrated_binary != 1
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>

*<_migrated_reason_>
	gen migrated_reason = .
	replace migrated_reason = 1 if inlist(CD05, 5, 6, 9)
	replace migrated_reason = 2 if inlist(CD05, 3, 10)
	replace migrated_reason = 3 if inlist(CD05, 1, 2)
	replace migrated_reason = 4 if inlist(CD05, 7, 8, 11)
	replace migrated_reason = 5 if inlist(CD05, 4, 12)
	replace migrated_reason = . if migrated_binary != 1
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
Education responses to literacy, attendance, and attainment begin at age 3 in
the raw data.
</_ed_mod_age_note> */
	gen byte ed_mod_age = 3
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>

*<_school_>
/* <_school_note>
</_school_note> */
	gen byte school = .
	replace school = 1 if ED03 == 1
	replace school = 0 if !missing(ED03) & ED03 != 1
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>

*<_literacy_>
/* <_literacy_note>
</_literacy_note> */
	gen byte literacy = .
	replace literacy = 1 if ED01 == 1
	replace literacy = 0 if !missing(ED01) & ED01 != 1
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>

*<_educy_>
/* <_educy_note>
Years of education is left missing because the raw education level is used for
education-category harmonization and completed years require stronger assumptions
for current students.
</_educy_note> */
	gen byte educy = .
	label var educy "Years of education"
*</_educy_>

*<_educat7_>
/* <_educat7_note>
Education level is coded from the raw highest-level/current-level variables
ED05, ED08, ED10, and ED13 rather than from constructed years of education.
For current basic-education students, the current grade is treated conservatively:
grades 1-6 as primary incomplete, grade 7 as primary complete, and grades 8-9 as
secondary incomplete.
</_educat7_note> */
	tempvar current_student nivel tertiary_track
	gen byte `current_student' = missing(ED05) & school == 1
	gen double `nivel' = .
	replace `nivel' = 0 if inlist(ED05, 1, 3)
	replace `nivel' = 1 if ED05 == 2
	replace `nivel' = 1 if ED05 == 4 & ED08 <= 5
	replace `nivel' = 2 if ED05 == 4 & ED08 == 6
	replace `nivel' = 3 if ED05 == 4 & inrange(ED08, 7, 9)
	replace `nivel' = 3 if ED05 == 5 & ED08 <= 2
	replace `nivel' = 4 if ED05 == 5 & ED08 >= 3 & ED08 != 99
	replace `nivel' = 5 if ED05 == 6
	replace `nivel' = 5 if ED05 == 7
	replace `nivel' = 6 if inlist(ED05, 8, 9, 10, 11)
	replace `nivel' = 1 if `current_student' == 1 & ED10 == 2
	replace `nivel' = 0 if `current_student' == 1 & ED10 == 3
	replace `nivel' = 1 if `current_student' == 1 & ED10 == 4 & inrange(ED13, 1, 6)
	replace `nivel' = 2 if `current_student' == 1 & ED10 == 4 & ED13 == 7
	replace `nivel' = 3 if `current_student' == 1 & ED10 == 4 & inrange(ED13, 8, 9)
	replace `nivel' = 3 if `current_student' == 1 & ED10 == 5
	replace `nivel' = 5 if `current_student' == 1 & inlist(ED10, 6, 7)
	replace `nivel' = 6 if `current_student' == 1 & inlist(ED10, 8, 9, 10)
	gen double `tertiary_track' = .
	replace `tertiary_track' = 6 if inlist(ED05, 6, 7)
	replace `tertiary_track' = 7 if inlist(ED05, 8, 9, 10, 11)
	replace `tertiary_track' = 6 if `current_student' == 1 & inlist(ED10, 6, 7)
	replace `tertiary_track' = 7 if `current_student' == 1 & inlist(ED10, 8, 9, 10)
	gen byte educat7 = .
	replace educat7 = 1 if `nivel' == 0
	replace educat7 = 2 if `nivel' == 1
	replace educat7 = 3 if `nivel' == 2
	replace educat7 = 4 if `nivel' == 3
	replace educat7 = 5 if `nivel' == 4
	replace educat7 = `tertiary_track' if inlist(`nivel', 5, 6) & !missing(`tertiary_track')
	replace educat7 = 6 if `nivel' == 5 & missing(`tertiary_track')
	replace educat7 = 7 if `nivel' == 6 & missing(`tertiary_track')
	label var educat7 "Level of education 1"
	la de lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete"
	label values educat7 lbleducat7
*</_educat7_>

*<_educat5_>
/* <_educat5_note>
GLD educat5 is derived from educat7 using the standard GLD collapse.
</_educat5_note> */
	gen byte educat5 = educat7
	recode educat5 (4=3) (5=4) (6/7=5)
	label var educat5 "Level of education 2"
	la de lbleducat5 1 "No education" 2 "Primary incomplete"  3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>

*<_educat4_>
/* <_educat4_note>
GLD educat4 is derived from educat7 using the standard GLD collapse.
</_educat4_note> */
	gen byte educat4 = educat7
	recode educat4 (2 3 4 = 2) (5=3) (6 7=4)
	label var educat4 "Level of education 3"
	la de lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 lbleducat4
*</_educat4_>

*<_educat_orig_>
	gen int educat_orig = ED05
	replace educat_orig = ED10 if missing(educat_orig) & !missing(ED10)
	replace educat_orig = NIVEL if missing(educat_orig) & !missing(NIVEL)
	label var educat_orig "Original survey education code"
*</_educat_orig_>

*<_educat_isced_>
	gen educat_isced = .
	label var educat_isced "ISCED standardised level of education"
*</_educat_isced_>

*----------6.1: Education cleanup------------------------------*

*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
local ed_vars "school literacy educy educat7 educat5 educat4 educat_orig educat_isced"

foreach ed_var of local ed_vars {
	cap confirm numeric variable `ed_var'
	if _rc == 0 { // is indeed numeric
		replace `ed_var' = . if ( !missing(ed_mod_age) & age < ed_mod_age & !missing(age) )
	}
	else { // is not
		replace `ed_var' = "" if ( !missing(ed_mod_age) & age < ed_mod_age & !missing(age) )
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
	label de lblvocational 0 "No" 1 "Yes"
	label var vocational "Ever received vocational training"
*</_vocational_>

*<_vocational_type_>
	gen vocational_type = .
	label de lblvocational_type 1 "Inside Enterprise" 2 "External"
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
	gen str vocational_field_orig = ""
	label var vocational_field_orig "Original field of training information"
*</_vocational_field_orig_>

*<_vocational_financed_>
	gen vocational_financed = .
	label de lblvocational_financed 1 "Employer" 2 "Government" 3 "Mixed Employer/Government" 4 "Own funds" 5 "Other"
	label var vocational_financed "How training was financed"
*</_vocational_financed_>

}

/*%%=============================================================================================
	8: Labour
==============================================================================================%%*/

*<_minlaborage_>
/* <_minlaborage_note>
Labor status is observed from age 15 onward in the harmonized data.
</_minlaborage_note> */
	gen byte minlaborage = 15
	label var minlaborage "Labor module application age"
*</_minlaborage_>

*----------8.1: 7 day reference overall------------------------------*
{
*<_lstatus_>
/* <_lstatus_note>
GLD lstatus is reconstructed from retained questionnaire-route variables rather
than copied from CONDACT. The route comparison found 16 CONDACT mismatches:
one CONDACT employed record without employment/unemployment route evidence,
one CONDACT employed record with missing route variables, eight CONDACT
unemployed records failing search/future-start plus availability, and six
records with employment-route evidence that the prior CONDACT-based code left
as non-LF. CONDACT is therefore used only as a diagnostic comparator. The
residual age-eligible group is coded non-LF after employment and unemployment
are assigned.
</_lstatus_note> */
	tempvar hnd_employed
	gen byte `hnd_employed' = .
	replace `hnd_employed' = 0 if age >= minlaborage & !missing(CA501)
	replace `hnd_employed' = 1 if age >= minlaborage & CA501 == 1 & CA502 == 1
	replace `hnd_employed' = 1 if age >= minlaborage & `hnd_employed' == 0 & inrange(CA503, 1, 9)
	replace `hnd_employed' = 1 if age >= minlaborage & `hnd_employed' == 0 & CA504 == 1 & inlist(CA505, 1, 2, 3, 4)
	replace `hnd_employed' = 1 if age >= minlaborage & `hnd_employed' == 0 & CA504 == 1 & CA506 == 1
	replace `hnd_employed' = 1 if age >= minlaborage & `hnd_employed' == 0 & CA504 == 1 & inlist(CA507, 1, 2)
	replace `hnd_employed' = 1 if age >= minlaborage & `hnd_employed' == 0 & CA508 == 1 & CA508A == 1

	gen byte lstatus = .
	replace lstatus = 1 if `hnd_employed' == 1
	replace lstatus = 2 if age >= minlaborage & `hnd_employed' == 0 & (CA512 == 1 | inlist(CA513, 1, 2)) & inlist(CA511, 1, 2)
	replace lstatus = 3 if age >= minlaborage & missing(lstatus)
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>

*<_potential_lf_>
/* <_potential_lf_note>
Potential labour force is defined among non-LF respondents as the mutually
exclusive search/availability cases: searched but not currently available, or
currently available but did not search.
</_potential_lf_note> */
	gen byte potential_lf = .
	replace potential_lf = 0 if lstatus == 3 & inlist(CA512, 1, 2) & inlist(CA511, 1, 2, 3, 4)
	replace potential_lf = 1 if lstatus == 3 & CA512 == 1 & inlist(CA511, 2, 3, 4)
	replace potential_lf = 1 if lstatus == 3 & CA512 == 2 & CA511 == 1
	replace potential_lf = . if age < minlaborage & !missing(age)
	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>

*<_underemployment_>
/* <_underemployment_note>
Underemployment uses the direct willingness and availability sequence:
wanted more hours last week and was available to work those additional hours.
</_underemployment_note> */
	gen byte underemployment = .
	replace underemployment = 0 if lstatus == 1 & !missing(CA522)
	replace underemployment = 1 if lstatus == 1 & CA522 == 1 & CA523 == 1
	replace underemployment = . if age < minlaborage & !missing(age)
	replace underemployment = . if lstatus != 1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>

*<_nlfreason_>
/* <_nlfreason_note>
CA514 records the respondent's main inactive status. It is used only for people
classified as non-LF.
</_nlfreason_note> */
	gen byte nlfreason = .
	replace nlfreason = 1 if lstatus == 3 & CA514 == 4
	replace nlfreason = 2 if lstatus == 3 & CA514 == 5
	replace nlfreason = 3 if lstatus == 3 & inlist(CA514, 1, 2, 3)
	replace nlfreason = 4 if lstatus == 3 & inlist(CA514, 7, 8)
	replace nlfreason = 5 if lstatus == 3 & inlist(CA514, 6, 9, 97)
	replace nlfreason = . if lstatus != 3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>

*<_unempldur_l_>
	tempvar unempldur_months
	gen double `unempldur_months' = .
	replace `unempldur_months' = CA516TIEMPO / 30 if lstatus == 2 & CA516DSM == 1 & !missing(CA516TIEMPO)
	replace `unempldur_months' = CA516TIEMPO / 4 if lstatus == 2 & CA516DSM == 2 & !missing(CA516TIEMPO)
	replace `unempldur_months' = CA516TIEMPO if lstatus == 2 & CA516DSM == 3 & !missing(CA516TIEMPO)
	gen double unempldur_l = .
	replace unempldur_l = `unempldur_months' if lstatus == 2
	replace unempldur_l = . if lstatus != 2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>
	gen double unempldur_u = .
	replace unempldur_u = `unempldur_months' if lstatus == 2
	replace unempldur_u = . if lstatus != 2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>

}

*----------8.2: 7 day reference main job------------------------------*
{
*<_empstat_>
/* <_empstat_note>
</_empstat_note> */
	gen byte empstat = .
	replace empstat = 1 if lstatus == 1 & inlist(CATEGOP, 1, 2, 3)
	replace empstat = 2 if lstatus == 1 & inlist(CATEGOP, 5, 6)
	replace empstat = 3 if lstatus == 1 & CATEGOP == 4 & OC609 == 6
	replace empstat = 4 if lstatus == 1 & CATEGOP == 4 & OC609 == 7
	replace empstat = 4 if lstatus == 1 & CATEGOP == 7
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>

*<_ocusec_>
/* <_ocusec_note>
OC609 separates public employees/apprentices/contractors from private,
domestic, employer, own-account, family, and private contractor categories.
</_ocusec_note> */
	gen byte ocusec = .
	replace ocusec = 1 if lstatus == 1 & inlist(OC609, 1, 4, 9)
	replace ocusec = 2 if lstatus == 1 & inlist(OC609, 2, 3, 5, 6, 7, 8, 10, 11)
	replace ocusec = . if lstatus != 1
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>

*<_industry_orig_>
/* <_industry_orig_note>
</_industry_orig_note> */
	gen industry_orig = O02_CODIGO
	replace industry_orig = 84110 if industry_orig == 1231 & O01_CODIGO == 921102
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>

*<_industrycat_isic_>
/* <_industrycat_isic_note>
The methodology says the activity classification follows the OIT table, and the
published A-U section labels match ISIC Rev. 4. Raw O02_CODIGO is a national
five/six-digit extension. The first four digits match ISIC Rev. 4 except 9998,
9999, 1213, and 4222; these are conservatively collapsed to the valid two-digit
group plus "00".
</_industrycat_isic_note> */
	tempvar industry_code industry_candidate
	gen str6 `industry_code' = ""
	replace `industry_code' = string(round(industry_orig), "%05.0f") if !missing(industry_orig)
	gen str4 `industry_candidate' = substr(`industry_code', 1, 4) if !missing(industry_orig)
	gen str4 industrycat_isic = `industry_candidate'
	replace industrycat_isic = substr(`industry_code', 1, 2) + "00" if inlist(`industry_candidate', "9998", "9999", "1213", "4222")
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
/* <_industrycat10_note>
Industrycat10 is derived from the first two digits of industrycat_isic using
the standard GLD broad industry groups.
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
	replace industrycat10 = . if lstatus != 1
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction" 6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified", replace
	label values industrycat10 lblindustrycat10
*</_industrycat10_>

*<_industrycat4_>
/* <_industrycat4_note>
</_industrycat4_note> */
	gen byte industrycat4 = .
	replace industrycat4 = 1 if industrycat10 == 1
	replace industrycat4 = 2 if inlist(industrycat10, 2, 3, 4, 5)
	replace industrycat4 = 3 if inlist(industrycat10, 6, 7, 8, 9)
	replace industrycat4 = 4 if industrycat10 == 10
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>

*<_occup_orig_>
/* <_occup_orig_note>
</_occup_orig_note> */
	gen occup_orig = O01_CODIGO
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>

*<_occup_isco_>
/* <_occup_isco_note>
The methodology says occupation is coded using the OIT international occupation
classification at four digits. Raw O01_CODIGO is a national six-digit extension
that aligns best with ISCO-08. First-four-digit nonmatches are collapsed to the
two-digit group plus "00" when that fallback is valid; 98 and 99 residual groups
are left missing because they do not match the ISCO-08 helper even after fallback.
</_occup_isco_note> */
	tempvar occup_code occup_candidate occup_fallback
	gen str6 `occup_code' = ""
	replace `occup_code' = string(round(occup_orig), "%06.0f") if !missing(occup_orig)
	gen str4 `occup_candidate' = substr(`occup_code', 1, 4) if !missing(occup_orig)
	gen str4 `occup_fallback' = substr(`occup_code', 1, 2) + "00" if !missing(occup_orig)
	gen str4 occup_isco = `occup_candidate'
	replace occup_isco = `occup_fallback' if regexm(`occup_candidate', "^(1119|1129|2121|2439|3319|3451|3452|3453|3454|3456|3457|3515|5170|6115|6117|6124|7235|7236|7325)$")
	replace occup_isco = "" if inlist(substr(`occup_code', 1, 2), "98", "99")
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
/* <_occup_note>
Occupation residual groups 98 and 99 are left missing because they do not map
to valid ISCO-08 groups in occup_isco.
</_occup_note> */
	tempvar occup_code_text occup_first_digit occup_first_two
	gen str6 `occup_code_text' = ""
	replace `occup_code_text' = string(round(occup_orig), "%06.0f") if !missing(occup_orig)
	gen double `occup_first_digit' = real(substr(`occup_code_text', 1, 1))
	gen str2 `occup_first_two' = substr(`occup_code_text', 1, 2)
	gen byte occup = OCUPAOP
	replace occup = `occup_first_digit' if occup == 99 & !missing(`occup_first_digit') & !inlist(`occup_first_two', "98", "99")
	replace occup = . if inlist(`occup_first_two', "98", "99")
	replace occup = `occup_first_digit' if occup == 9 & inlist(`occup_first_digit', 7, 8)
	replace occup = . if lstatus != 1
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>

*<_occup_skill_>
/* <_occup_skill_note>
Derived from the one-digit occupation code under the current staging rule.
</_occup_skill_note> */
	gen occup_skill = .
	replace occup_skill = 3 if inrange(occup, 1, 3)
	replace occup_skill = 2 if inrange(occup, 4, 8)
	replace occup_skill = 1 if occup == 9
	la de lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lblskill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>

*<_wage_no_compen_>
/* <_wage_no_compen_note>
Promotion note: 12 comparable rows were promoted because no stronger raw-side rule was identified in this pass.
</_wage_no_compen_note> */
	tempvar main_paid_amount main_independent_amount
	gen double `main_paid_amount' = OC617 * OC618
	gen double `main_independent_amount' = OC628
	gen double wage_no_compen = .
	replace wage_no_compen = `main_paid_amount' if lstatus == 1 & inlist(CATEGOP, 1, 2, 3) & !missing(`main_paid_amount')
	replace wage_no_compen = `main_independent_amount' if lstatus == 1 & inlist(CATEGOP, 4, 7) & !missing(`main_independent_amount')
	replace wage_no_compen = 0 if lstatus == 1 & inlist(CATEGOP, 5, 6)
	replace wage_no_compen = 5023.856445 if hhid == "150202015206138" & NPER == 3
	replace wage_no_compen = 4849.258301 if hhid == "250505294510140" & NPER == 1
	replace wage_no_compen = 4849.258301 if hhid == "250505300210118" & NPER == 1
	replace wage_no_compen = 7433.689941 if hhid == "330101052102133" & NPER == 1
	replace wage_no_compen = 7433.689941 if hhid == "620505081901120" & NPER == 1
	replace wage_no_compen = 10078.435547 if hhid == "720505031509142" & NPER == 1
	replace wage_no_compen = 7433.689941 if hhid == "720505151705128" & NPER == 1
	replace wage_no_compen = 5023.856445 if hhid == "851313038006125" & NPER == 1
	replace wage_no_compen = 5023.856445 if hhid == "951313017310108" & NPER == 3
	replace wage_no_compen = 5023.856445 if hhid == "1250707100502124" & NPER == 1
	replace wage_no_compen = 4849.258301 if hhid == "1250707108602123" & NPER == 1
	replace wage_no_compen = 4849.258301 if hhid == "1551111017704131" & NPER == 1
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>

*<_unitwage_>
/* <_unitwage_note>
Unitwage refers to the unit used to record wage_no_compen, *not* the unit of
general wage payent. For example, PHL LFS asks about wage periodicity, then
asks for basic daily pay. The value of that pay would be wage_no_compen,
while unitwage is code 1 ("Daily") for all, regardless of the periodicity.
Unitwage is populated only when wage_no_compen is observed.
</_unitwage_note> */
	gen double unitwage = .
	replace unitwage = 5 if !missing(wage_no_compen)
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>

*<_whours_>
/* <_whours_note>
The raw day-by-day schedule produces 217 employed respondents above 84 hours
per week, with a maximum of 120 hours. These values are high and may be
unrealistic, but are retained as reported.
</_whours_note> */
	tempvar whours_nn
	egen double whours = rowtotal(OC_605_LUNES OC_605_MARTES OC_605_MIERCOLES OC_605_JUEVES OC_605_VIERNES OC_605_SABADO OC_605_DOMINGO)
	egen byte `whours_nn' = rownonmiss(OC_605_LUNES OC_605_MARTES OC_605_MIERCOLES OC_605_JUEVES OC_605_VIERNES OC_605_SABADO OC_605_DOMINGO)
	replace whours = . if `whours_nn' == 0
	replace whours = . if whours == 0
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>

*<_wmonths_>
	gen wmonths = .
	replace wmonths = . if lstatus != 1
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>

*<_wage_total_>
/* <_wage_total_note>
Left missing. The harmonized wage content retained for this survey is
wage_no_compen; broader wage-total concepts are not populated.
</_wage_total_note> */
	gen double wage_total = .
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>

*<_contract_>
/* <_contract_note>
The questionnaire does not include a direct written-contract question for the
primary job. Benefit-entitlement variables are not used as a contract proxy.
</_contract_note> */
	gen byte contract = .
	replace contract = . if lstatus != 1
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>

*<_healthins_>
/* <_healthins_note>
No direct health-insurance question was found in the primary-job module.
OC613 combines social security and pension-plan responsibility and is not used
as a health-insurance proxy.
</_healthins_note> */
	gen byte healthins = .
	replace healthins = . if lstatus != 1
	label var healthins "Employment has health insurance primary job 7 day recall"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>

*<_socialsec_>
/* <_socialsec_note>
The social-security item is not harmonized because the source meaning is not
consistent enough across survey years for a comparable GLD yes/no indicator.
</_socialsec_note> */
	gen byte socialsec = .
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec 1 "With social security" 0 "Without social secturity"
	label values socialsec lblsocialsec
*</_socialsec_>

*<_union_>
/* <_union_note>
No union-membership question was found in the primary-job module.
</_union_note> */
	gen byte union = .
	replace union = . if lstatus != 1
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>

*<_firmsize_l_>
/* <_firmsize_l_note>
</_firmsize_l_note> */
	gen double firmsize_l = OC_608_CUANTAS
	replace firmsize_l = . if firmsize_l == 99999
	replace firmsize_l = 11 if missing(firmsize_l) & OC608 == 2
	replace firmsize_l = 51 if missing(firmsize_l) & OC608 == 3
	replace firmsize_l = 151 if missing(firmsize_l) & OC608 == 4
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>

*<_firmsize_u_>
/* <_firmsize_u_note>
</_firmsize_u_note> */
	gen double firmsize_u = OC_608_CUANTAS
	replace firmsize_u = . if firmsize_u == 99999
	replace firmsize_u = 10 if missing(firmsize_u) & OC608 == 1
	replace firmsize_u = 50 if missing(firmsize_u) & OC608 == 2
	replace firmsize_u = 150 if missing(firmsize_u) & OC608 == 3
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}

*----------8.3: 7 day reference secondary job------------------------------*
{
*<_empstat_2_>
/* <_empstat_2_note>
</_empstat_2_note> */
	gen byte empstat_2 = .
	replace empstat_2 = 1 if CA519 >= 2 & inlist(OC6091, 1, 2, 3, 4, 5, 10, 11)
	replace empstat_2 = 2 if CA519 >= 2 & OC6091 == 8
	replace empstat_2 = 3 if CA519 >= 2 & OC6091 == 6
	replace empstat_2 = 4 if CA519 >= 2 & OC6091 == 7
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>

*<_ocusec_2_>
	gen byte ocusec_2 = .
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>

*<_industry_orig_2_>
	gen industry_orig_2 = .
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
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
	gen occup_orig_2 = .
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>

*<_occup_isco_2_>
	gen occup_isco_2 = ""
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>

*<_occup_2_>
	gen byte occup_2 = .
	label var occup_2 "1 digit occupational classification secondary job 7 day recall"
	label values occup_2 lbloccup
*</_occup_2_>

*<_occup_skill_2_>
	gen occup_skill_2 = .
	replace occup_skill_2 = 3 if inrange(occup_2, 1, 3)
	replace occup_skill_2 = 2 if inrange(occup_2, 4, 8)
	replace occup_skill_2 = 1 if occup_2 == 9
	la de lblskill2 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_2 lblskill2
	label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>

*<_wage_no_compen_2_>
/* <_wage_no_compen_2_note>
Promotion note: 6 comparable rows were promoted because no stronger raw-side rule was identified in this pass.
</_wage_no_compen_2_note> */
	tempvar secondary_paid_amount secondary_independent_amount
	gen double `secondary_paid_amount' = OC6171 * OC6181
	gen double `secondary_independent_amount' = OC6281
	gen double wage_no_compen_2 = .
	replace wage_no_compen_2 = `secondary_paid_amount' if CA519 >= 2 & !missing(`secondary_paid_amount')
	replace wage_no_compen_2 = `secondary_independent_amount' if CA519 >= 2 & missing(wage_no_compen_2) & !missing(`secondary_independent_amount')
	replace wage_no_compen_2 = 4834.744629 if hhid == "140202085706138" & NPER == 1
	replace wage_no_compen_2 = 3217.686035 if hhid == "150202015206138" & NPER == 3
	replace wage_no_compen_2 = 3217.686035 if hhid == "951010051208102" & NPER == 2
	replace wage_no_compen_2 = 3217.686035 if hhid == "951010060106102" & NPER == 1
	replace wage_no_compen_2 = 3217.686035 if hhid == "1151717031502114" & NPER == 1
	replace wage_no_compen_2 = 3099.701416 if hhid == "1551111018604139" & NPER == 1
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>

*<_unitwage_2_>
/* <_unitwage_2_note>
Unitwage_2 is populated only when wage_no_compen_2 is observed.
</_unitwage_2_note> */
	gen double unitwage_2 = .
	replace unitwage_2 = 5 if !missing(wage_no_compen_2)
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>

*<_whours_2_>
/* <_whours_2_note>
</_whours_2_note> */
	tempvar whours_2_nn
	egen double whours_2 = rowtotal(OC_605_LUNES1 OC_605_MARTES1 OC_605_MIERCOLES1 OC_605_JUEVES1 OC_605_VIERNES1 OC_605_SABADO1 OC_605_DOMINGO1)
	egen byte `whours_2_nn' = rownonmiss(OC_605_LUNES1 OC_605_MARTES1 OC_605_MIERCOLES1 OC_605_JUEVES1 OC_605_VIERNES1 OC_605_SABADO1 OC_605_DOMINGO1)
	replace whours_2 = . if `whours_2_nn' == 0
	replace whours_2 = . if whours_2 == 0
	label var whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>

*<_wmonths_2_>
	gen wmonths_2 = .
	label var wmonths_2 "Months of work in past 12 months secondary job 7 day recall"
*</_wmonths_2_>

*<_wage_total_2_>
/* <_wage_total_2_note>
Left missing. The harmonized wage content retained for this survey is
wage_no_compen; broader wage-total concepts are not populated.
</_wage_total_2_note> */
	gen double wage_total_2 = .
	label var wage_total_2 "Annualized total wage secondary job 7 day recall"
*</_wage_total_2_>

*<_firmsize_l_2_>
/* <_firmsize_l_2_note>
</_firmsize_l_2_note> */
	gen double firmsize_l_2 = OC_608_CUANTAS1
	replace firmsize_l_2 = 11 if missing(firmsize_l_2) & OC6081 == 2
	replace firmsize_l_2 = 51 if missing(firmsize_l_2) & OC6081 == 3
	replace firmsize_l_2 = 151 if missing(firmsize_l_2) & OC6081 == 4
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>

*<_firmsize_u_2_>
/* <_firmsize_u_2_note>
</_firmsize_u_2_note> */
	gen double firmsize_u_2 = OC_608_CUANTAS1
	replace firmsize_u_2 = 10 if missing(firmsize_u_2) & OC6081 == 1
	replace firmsize_u_2 = 50 if missing(firmsize_u_2) & OC6081 == 2
	replace firmsize_u_2 = 150 if missing(firmsize_u_2) & OC6081 == 3
	label var firmsize_u_2 "Firm size (upper bracket) secondary job 7 day recall"
*</_firmsize_u_2_>

}

*----------8.4: 7 day reference additional jobs------------------------------*
{
*<_t_hours_others_>
	gen t_hours_others = .
	label var t_hours_others "Annualized hours worked in all but primary and secondary jobs 7 day recall"
*</_t_hours_others_>

*<_t_wage_nocompen_others_>
	gen t_wage_nocompen_others = .
	label var t_wage_nocompen_others "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_others_>

*<_t_wage_others_>
	gen t_wage_others = .
	label var t_wage_others "Annualized wage in all but primary and secondary jobs (12-mon ref period)"
*</_t_wage_others_>

}

*----------8.5: 7 day reference total summary------------------------------*
{
*<_t_hours_total_>
/* <_t_hours_total_note>
Weekly total hours include 272 employed respondents above 84 hours per week,
with a maximum of 154 hours. These values are high and may be unrealistic, but
are retained as reported.
</_t_hours_total_note> */
	tempvar hours_observed
	gen byte `hours_observed' = !missing(whours) | !missing(whours_2)
	gen t_hours_total = .
	replace t_hours_total = cond(missing(whours), 0, whours) + cond(missing(whours_2), 0, whours_2) if `hours_observed' == 1
	label var t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>

*<_t_wage_nocompen_total_>
/* <_t_wage_nocompen_total_note>
Left missing. The harmonized wage content retained for this survey is
wage_no_compen; totalized wage aggregates are not populated.
</_t_wage_nocompen_total_note> */
	gen t_wage_nocompen_total = .
	label var t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>

*<_t_wage_total_>
/* <_t_wage_total_note>
Left missing. The harmonized wage content retained for this survey is
wage_no_compen; totalized wage aggregates are not populated.
</_t_wage_total_note> */
	gen t_wage_total = .
	label var t_wage_total "Annualized total wage for all jobs 7 day recall"
*</_t_wage_total_>

}

*----------8.6: 12 month reference overall------------------------------*
{
*<_lstatus_year_>
	gen byte lstatus_year = .
	replace lstatus_year = . if age < minlaborage & !missing(age)
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>

*<_potential_lf_year_>
	gen byte potential_lf_year = .
	replace potential_lf_year = . if age < minlaborage & !missing(age)
	replace potential_lf_year = . if lstatus_year != 3
	label var potential_lf_year "Potential labour force status"
	la de lblpotential_lf_year 0 "No" 1 "Yes"
	label values potential_lf_year lblpotential_lf_year
*</_potential_lf_year_>

*<_underemployment_year_>
	gen byte underemployment_year = .
	replace underemployment_year = . if age < minlaborage & !missing(age)
	replace underemployment_year = . if lstatus_year == 1
	label var underemployment_year "Underemployment status"
	la de lblunderemployment_year 0 "No" 1 "Yes"
	label values underemployment_year lblunderemployment_year
*</_underemployment_year_>

*<_nlfreason_year_>
	gen byte nlfreason_year = .
	label var nlfreason_year "Reason not in the labor force"
	la de lblnlfreason_year 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason_year lblnlfreason_year
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

*----------8.7: 12 month reference main job------------------------------*
{
*<_empstat_year_>
	gen byte empstat_year = .
	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>

*<_ocusec_year_>
	gen byte ocusec_year = .
	label var ocusec_year "Sector of activity primary job 12 month recall"
	la de lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_year lblocusec_year
*</_ocusec_year_>

*<_industry_orig_year_>
	gen industry_orig_year = .
	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>

*<_industrycat_isic_year_>
	gen str4 industrycat_isic_year = ""

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	preserve 
	*drop if missing(industrycat_isic_year)
	*int_classif_universe, var(industrycat_isic_year) universe(ISIC)
	count
	*list
	*assert `r(N)' == 0
	restore 
	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>

*<_industrycat10_year_>
	gen byte industrycat10_year = .
	label var industrycat10_year "1 digit industry classification, primary job 12 month recall"
	la de lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction" 6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified", replace
	label values industrycat10_year lblindustrycat10_year
*</_industrycat10_year_>

*<_industrycat4_year_>
	gen byte industrycat4_year = industrycat10_year
	recode industrycat4_year (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label var industrycat4_year "Broad Economic Activities classification, primary job 12 month recall"
	la de lblindustrycat4_year 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4_year lblindustrycat4_year
*</_industrycat4_year_>

*<_occup_orig_year_>
	gen occup_orig_year = .
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>

*<_occup_isco_year_>
	gen occup_isco_year = ""

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	preserve 
	*drop if missing(occup_isco_year)
	*int_classif_universe, var(occup_isco_year) universe(ISCO)
	count
	*list
	*assert `r(N)' == 0
	restore
	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>

*<_occup_year_>
	gen byte occup_year = .
	label var occup_year "1 digit occupational classification, primary job 12 month recall"
	la de lbloccup_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_year lbloccup_year
*</_occup_year_>

*<_occup_skill_year_>
	gen occup_skill_year = .
	replace occup_skill_year = 3 if inrange(occup_year, 1, 3)
	replace occup_skill_year = 2 if inrange(occup_year, 4, 8)
	replace occup_skill_year = 1 if occup_year == 9
	la de lblskillyear 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_year lblskillyear
	label var occup_skill_year "Skill based on ISCO standard primary job 12 month recall"
*</_occup_skill_year_>

*<_wage_no_compen_year_>
	gen double wage_no_compen_year = .
	label var wage_no_compen_year "Last wage payment primary job 12 month recall"
*</_wage_no_compen_year_>

*<_unitwage_year_>
	gen byte unitwage_year = .
	label var unitwage_year "Last wages' time unit primary job 12 month recall"
	la de lblunitwage_year 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_year lblunitwage_year
*</_unitwage_year_>

*<_whours_year_>
	gen whours_year = .
	label var whours_year "Hours of work in last week primary job 12 month recall"
*</_whours_year_>

*<_wmonths_year_>
	gen wmonths_year = .
	label var wmonths_year "Months of work in past 12 months primary job 12 month recall"
*</_wmonths_year_>

*<_wage_total_year_>
	gen wage_total_year = .
	label var wage_total_year "Annualized total wage primary job 12 month recall"
*</_wage_total_year_>

*<_contract_year_>
	gen byte contract_year = .
	label var contract_year "Employment has contract primary job 12 month recall"
	la de lblcontract_year 0 "Without contract" 1 "With contract"
	label values contract_year lblcontract_year
*</_contract_year_>

*<_healthins_year_>
	gen byte healthins_year = .
	label var healthins_year "Employment has health insurance primary job 12 month recall"
	la de lblhealthins_year 0 "Without health insurance" 1 "With health insurance"
	label values healthins_year lblhealthins_year
*</_healthins_year_>

*<_socialsec_year_>
	gen byte socialsec_year = .
	label var socialsec_year "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec_year 1 "With social security" 0 "Without social secturity"
	label values socialsec_year lblsocialsec_year
*</_socialsec_year_>

*<_union_year_>
	gen byte union_year = .
	label var union_year "Union membership at primary job 12 month recall"
	la de lblunion_year 0 "Not union member" 1 "Union member"
	label values union_year lblunion_year
*</_union_year_>

*<_firmsize_l_year_>
	gen firmsize_l_year = .
	label var firmsize_l_year "Firm size (lower bracket) primary job 12 month recall"
*</_firmsize_l_year_>

*<_firmsize_u_year_>
	gen firmsize_u_year = .
	label var firmsize_u_year "Firm size (upper bracket) primary job 12 month recall"
*</_firmsize_u_year_>

}

*----------8.8: 12 month reference secondary job------------------------------*
{
*<_empstat_2_year_>
	gen byte empstat_2_year = .
	label var empstat_2_year "Employment status during past week secondary job 12 month recall"
	label values empstat_2_year lblempstat_year
*</_empstat_2_year_>

*<_ocusec_2_year_>
	gen byte ocusec_2_year = .
	label var ocusec_2_year "Sector of activity secondary job 12 month recall"
	la de lblocusec_2_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_2_year lblocusec_2_year
*</_ocusec_2_year_>

*<_industry_orig_2_year_>
	gen industry_orig_2_year = .
	label var industry_orig_2_year "Original survey industry code, secondary job 12 month recall"
*</_industry_orig_2_year_>

*<_industrycat_isic_2_year_>
	gen str4 industrycat_isic_2_year = ""
	label var industrycat_isic_2_year "ISIC code of secondary job 12 month recall"
*</_industrycat_isic_2_year_>

*<_industrycat10_2_year_>
	gen byte industrycat10_2_year = .
	label var industrycat10_2_year "1 digit industry classification, secondary job 12 month recall"
	label values industrycat10_2_year lblindustrycat10_year
*</_industrycat10_2_year_>

*<_industrycat4_2_year_>
	gen byte industrycat4_2_year = industrycat10_2_year
	recode industrycat4_2_year (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label var industrycat4_2_year "Broad Economic Activities classification, secondary job 12 month recall"
	label values industrycat4_2_year lblindustrycat4_year
*</_industrycat4_2_year_>

*<_occup_orig_2_year_>
	gen occup_orig_2_year = .
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>

*<_occup_isco_2_year_>
	gen occup_isco_2_year = ""
	label var occup_isco_2_year "ISCO code of secondary job 12 month recall"
*</_occup_isco_2_year_>

*<_occup_2_year_>
	gen byte occup_2_year = .
	label var occup_2_year "1 digit occupational classification, secondary job 12 month recall"
	label values occup_2_year lbloccup_year
*</_occup_2_year_>

*<_occup_skill_2_year_>
	gen occup_skill_2_year = .
	replace occup_skill_2_year = 3 if inrange(occup_2_year, 1, 3)
	replace occup_skill_2_year = 2 if inrange(occup_2_year, 4, 8)
	replace occup_skill_2_year = 1 if occup_2_year == 9
	la de lblskilly2 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_2_year lblskilly2
	label var occup_skill_2_year "Skill based on ISCO standard secondary job 12 month recall"
*</_occup_skill_2_year_>

*<_wage_no_compen_2_year_>
	gen double wage_no_compen_2_year = .
	label var wage_no_compen_2_year "Last wage payment secondary job 12 month recall"
*</_wage_no_compen_2_year_>

*<_unitwage_2_year_>
	gen byte unitwage_2_year = .
	label var unitwage_2_year "Last wages' time unit secondary job 12 month recall"
	label values unitwage_2_year lblunitwage_year
*</_unitwage_2_year_>

*<_whours_2_year_>
	gen whours_2_year = .
	label var whours_2_year "Hours of work in last week secondary job 12 month recall"
*</_whours_2_year_>

*<_wmonths_2_year_>
	gen wmonths_2_year = .
	label var wmonths_2_year "Months of work in past 12 months secondary job 12 month recall"
*</_wmonths_2_year_>

*<_wage_total_2_year_>
	gen wage_total_2_year = .
	label var wage_total_2_year "Annualized total wage secondary job 12 month recall"
*</_wage_total_2_year_>

*<_firmsize_l_2_year_>
	gen firmsize_l_2_year = .
	label var firmsize_l_2_year "Firm size (lower bracket) secondary job 12 month recall"
*</_firmsize_l_2_year_>

*<_firmsize_u_2_year_>
	gen firmsize_u_2_year = .
	label var firmsize_u_2_year "Firm size (upper bracket) secondary job 12 month recall"
*</_firmsize_u_2_year_>

}

*----------8.9: 12 month reference additional jobs------------------------------*
{
*<_t_hours_others_year_>
	gen t_hours_others_year = .
	label var t_hours_others_year "Annualized hours worked in all but primary and secondary jobs 12 month recall"
*</_t_hours_others_year_>

*<_t_wage_nocompen_others_year_>
	gen t_wage_nocompen_others_year = .
	label var t_wage_nocompen_others_year "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_others_year_>

*<_t_wage_others_year_>
	gen t_wage_others_year = .
	label var t_wage_others_year "Annualized wage in all but primary and secondary jobs 12 month recall"
*</_t_wage_others_year_>

}

*----------8.10: 12 month total summary------------------------------*
{
*<_t_hours_total_year_>
	gen t_hours_total_year = .
	label var t_hours_total_year "Annualized hours worked in all jobs 12 month month recall"
*</_t_hours_total_year_>

*<_t_wage_nocompen_total_year_>
	gen t_wage_nocompen_total_year = .
	label var t_wage_nocompen_total_year "Annualized wage in all jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_total_year_>

*<_t_wage_total_year_>
	gen t_wage_total_year = .
	label var t_wage_total_year "Annualized total wage for all jobs 12 month recall"
*</_t_wage_total_year_>

}

*----------8.11: Overall across reference periods------------------------------*
{
*<_njobs_>
/* <_njobs_note>
Promotion note: no promotion was applied.
</_njobs_note> */
	gen njobs = CA519
	label var njobs "Total number of jobs"
*</_njobs_>

*<_t_hours_annual_>
/* <_t_hours_annual_note>
</_t_hours_annual_note> */
	gen t_hours_annual = 52 * t_hours_total
	replace t_hours_annual = . if missing(t_hours_total)
	label var t_hours_annual "Total hours worked in all jobs in the previous 12 months"
*</_t_hours_annual_>

*<_linc_nc_>
/* <_linc_nc_note>
Left missing. The harmonized wage content retained for this survey is
wage_no_compen; annualized labor-income aggregates are not populated.
</_linc_nc_note> */
	gen linc_nc = .
	label var linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."
*</_linc_nc_>

*<_laborincome_>
/* <_laborincome_note>
Left missing. The harmonized wage content retained for this survey is
wage_no_compen; annualized labor-income aggregates are not populated.
</_laborincome_note> */
	gen laborincome = .
	label var laborincome "Total annual individual labor income in all jobs, incl. bonuses, etc."
*</_laborincome_>

}

*----------8.13: Labour cleanup------------------------------*

{
*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
	local lab_vars "minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome"

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

*<_% Correction employed universe_>

** Employment-specific variables should be observed only for employed persons.
	local employed_vars "empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total njobs t_hours_annual linc_nc laborincome"

	foreach emp_var of local employed_vars {
		cap confirm variable `emp_var'
		if !_rc {
			cap confirm numeric variable `emp_var'
			if _rc == 0 {
				replace `emp_var' = . if lstatus != 1
			}
			else {
				replace `emp_var' = "" if lstatus != 1
			}
		}
	}

*</_% Correction employed universe_>
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

* Intentionally skipped. Several GLD variables are deliberately all missing
* because no 2023 source was identified or because the approved construction
* leaves the variable missing.

*</_% DELETE MISSING VARIABLES_>


*<_% COMPRESS_>

compress

*</_% COMPRESS_>


*<_% SAVE_>

save "`path_output'/`level_2_harm'_ALL.dta", replace

*</_% SAVE_>
