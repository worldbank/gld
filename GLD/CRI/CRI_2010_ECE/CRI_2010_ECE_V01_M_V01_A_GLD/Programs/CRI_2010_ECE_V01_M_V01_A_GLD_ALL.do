
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				CRI_2010_ECE_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>					StataNow 19 </_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2026-08-04 </_Date created_>

-------------------------------------------------------------------------

<_Country_>					Costa Rica (CRI) </_Country_>
<_Survey Title_>				Encuesta Continua de Empleo (ECE) </_Survey Title_>
<_Survey Year_>					2010 </_Survey Year_>
<_Study ID_>					CR-INEC-ECE-2010 </_Study ID_>
<_Data collection from_>			07/2010 </_Data collection from_>
<_Data collection to_>				12/2010 </_Data collection to_>
<_Source of dataset_> 				Instituto Nacional de Estadistica y Censos (INEC) </_Source of dataset_>
<_Sample size (HH)_> 				15,095 </_Sample size (HH)_>
<_Sample size (IND)_> 				52,885 </_Sample size (IND)_>
<_Sampling method_> 				Probabilistic, stratified, two-stage cluster sample with quarterly rotation </_Sampling method_>
<_Geographic coverage_> 			National, urban and rural, and six planning regions </_Geographic coverage_>
<_Currency_> 					Costa Rican colon (CRC) </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS-19 </_ICLS Version_>
<_ISCED Version_>				ISCED 1997 </_ISCED Version_>
<_ISCO Version_>				ISCO 2008 </_ISCO Version_>
<_OCCUP National_>				COCR-2011 </_OCCUP National_>
<_ISIC Version_>				ISIC Revision 4 </_ISIC Version_>
<_INDUS National_>				CIIU Revision 4 adapted to Costa Rica </_INDUS National_>

-----------------------------------------------------------------------
<_Version Control_>

* Date: [YYYY-MM-DD] - [Description of changes]
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
local server  "C:/Users/wb625372/WBG/GLD - Current Contributors/999999_ZW"
local country "CRI"
local year    "2010"
local survey  "ECE"
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

* All steps necessary to merge datasets (if several) to have all elements needed to produce
* harmonized output in a single file

use "`path_in_stata'/III Trimestre 2010.dta", clear
append using "`path_in_stata'/IV Trimestre 2010.dta"

/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
gen str12 countrycode = "CRI"
label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
gen str12 survname = "ECE"
label var survname "Survey acronym"
*</_survname_>


*<_survey_>
gen str12 survey = "LFS"
label var survey "Survey type"
*</_survey_>


*<_icls_v_>
gen str12 icls_v = "ICLS-19"
label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	gen isced_version = ""
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
gen str12 isco_version = "isco_2008"
label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
gen str12 isic_version = "isic_4"
label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
gen int year = 2010
label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen vermast = "`vermast'"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen veralt = "`veralt'"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen harmonization = "GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
gen int int_year = ID_AMO
replace int_year = . if int_year != 2010
label var int_year "Year of interview"
*</_int_year_>


*<_int_month_>
	gen  int_month = .
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
assert !missing(ID_TRIMESTRE,Consecutivo,ID_VIVIENDA,ID_HOGAR)
assert inlist(ID_TRIMESTRE,3,4)
assert inrange(Consecutivo,0,999999999) & floor(Consecutivo)==Consecutivo
assert inrange(ID_VIVIENDA,0,99) & floor(ID_VIVIENDA)==ID_VIVIENDA
assert inrange(ID_HOGAR,0,99) & floor(ID_HOGAR)==ID_HOGAR
gen str15 hhid = "Q" + string(ID_TRIMESTRE,"%1.0f") + string(Consecutivo,"%09.0f") + string(ID_VIVIENDA,"%02.0f") + string(ID_HOGAR,"%02.0f")
assert strlen(hhid)==15
label var hhid "Quarter-specific household ID"
*</_hhid_>


*<_pid_>
assert !missing(ID_LINEA)
assert inrange(ID_LINEA,0,99) & floor(ID_LINEA)==ID_LINEA
gen str17 pid = hhid + string(ID_LINEA,"%02.0f")
assert strlen(pid)==17
isid pid
label var pid "Quarter-specific individual ID"
*</_pid_>


*<_weight_>
bysort ID_TRIMESTRE: gen long _quarter_n = _N
gen double weight = Factor_ponderacion*(_quarter_n/_N)
replace weight = . if Factor_ponderacion<=0
drop _quarter_n
label var weight "Survey sampling weight"
*</_weight_>


*<_weight_m_>
	gen weight_m = .
	label var weight_m "Survey sampling weight to obtain national estimates for each month"
*</_weight_m_>


*<_weight_q_>
gen double weight_q = Factor_ponderacion
replace weight_q = . if weight_q <= 0
label var weight_q "Quarterly survey weight"
*</_weight_q_>


*<_psu_>
gen long psu = Consecutivo
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = .
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
gen int strata = Region*10 + Zona
label var strata "Strata"
*</_strata_>


*<_wave_>
gen byte wave = ID_TRIMESTRE
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
gen byte urban = .
replace urban = 1 if Zona == 1
replace urban = 0 if Zona == 2
label define lblurban 1 "Urban" 0 "Rural"
label values urban lblurban
label var urban "Location is urban"
*</_urban_>


*<_subnatid1_>
/* <_subnatid1_note>

	The variable is string and country-specific categorical. Numeric entries are coded in string format using the following naming convention: "1 ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ Hatay". That is, the variable itself is to be string, not a labelled numeric vector. 
	
	Example of entries would be "1 - Alaska",  "2 - Arkansas", ...

</_subnatid1_note> */
	gen str subnatid1 = ""
	replace subnatid1 = "1 - Central"          if Region == 1
	replace subnatid1 = "2 - Chorotega"        if Region == 2
	replace subnatid1 = "3 - Pacifico central" if Region == 3
	replace subnatid1 = "4 - Brunca"           if Region == 4
	replace subnatid1 = "5 - Huetar caribe"    if Region == 5
	replace subnatid1 = "6 - Huetar norte"     if Region == 6
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	gen str subnatid2 = ""
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	gen str subnatid3 = ""
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
gen str20 subnatidsurvey = ""
replace subnatidsurvey = "CRI urban" if urban == 1
replace subnatidsurvey = "CRI rural" if urban == 0
label var subnatidsurvey "Lowest survey domain"
*</_subnatidsurvey_>


*<_subnatid1_prev_>
/* <_subnatid1_prev_note>

	subnatid1_prev is coded as missing unless the classification used for subnatid1 has changed since the previous survey.

</_subnatid1_prev_note> */
	gen subnatid1_prev = .
	label var subnatid1_prev "Classification used for subnatid1 from previous survey"
*</_subnatid1_prev_>


*<_subnatid2_prev_>
	gen subnatid2_prev = .
	label var subnatid2_prev "Classification used for subnatid2 from previous survey"
*</_subnatid2_prev_>


*<_subnatid3_prev_>
	gen subnatid3_prev = .
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
bysort hhid: gen int hsize = _N
label var hsize "Household size"
*</_hsize_>


*<_age_>
gen byte age = Edad
replace age = . if inlist(Edad,98,99)
label var age "Age in years"
*</_age_>


*<_male_>
gen byte male = .
replace male = 1 if Sexo == 1
replace male = 0 if Sexo == 2
label define lblmale 1 "Male" 0 "Female"
label values male lblmale
label var male "Individual is male"
*</_male_>


*<_relationharm_>
gen byte relationharm = .
replace relationharm = 1 if inlist(Relacion_parentesco,1,13)
replace relationharm = 2 if inlist(Relacion_parentesco,2,16,17)
replace relationharm = 3 if inlist(Relacion_parentesco,3,14)
replace relationharm = 4 if Relacion_parentesco==6
replace relationharm = 5 if inlist(Relacion_parentesco,4,5,7,8,9,15)
replace relationharm = 6 if inlist(Relacion_parentesco,10,11,12)

* Enforce exactly one head per quarter-specific household.
gen double _relation_age_sort = age
replace _relation_age_sort = -1 if missing(_relation_age_sort)
gsort hhid -_relation_age_sort pid
by hhid: gen int _head_order = sum(relationharm==1)
replace relationharm = 5 if relationharm==1 & _head_order>1
bysort hhid: egen byte _nhead = total(relationharm==1)
gen byte _spouse_candidate = relationharm==2 if _nhead==0
replace _spouse_candidate = 0 if missing(_spouse_candidate)
gsort hhid -_spouse_candidate -_relation_age_sort pid
by hhid: replace relationharm = 1 if _nhead==0 & _n==1
bysort hhid: egen byte _nhead_check = total(relationharm==1)
assert _nhead_check==1
drop _relation_age_sort _head_order _nhead _spouse_candidate _nhead_check
sort hhid pid

label define lblrelationharm 1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
label values relationharm lblrelationharm
label var relationharm "Relationship to head"
*</_relationharm_>


*<_relationcs_>
gen byte relationcs = Relacion_parentesco
label var relationcs "Relationship country-specific"
*</_relationcs_>


*<_marital_>
gen byte marital = .
replace marital = 1 if inlist(Estado_conyugal,2,7)
replace marital = 2 if Estado_conyugal==6
replace marital = 3 if inlist(Estado_conyugal,1,8)
replace marital = 4 if inlist(Estado_conyugal,3,4)
replace marital = 5 if Estado_conyugal==5
label define lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
label values marital lblmarital
label var marital "Marital status"
*</_marital_>


*<_eye_dsablty_>
	gen eye_dsablty = .
	label define dsablty 1 "No ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ no difficulty" 2 "Yes ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ some difficulty" 3 "Yes ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ a lot of difficulty" 4 "Cannot do at all"
	label values eye_dsablty dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty = .
	label define dsablty 1 "No ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ no difficulty" 2 "Yes ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ some difficulty" 3 "Yes ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ a lot of difficulty" 4 "Cannot do at all", replace
	label values hear_dsablty dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty = .
	label define dsablty 1 "No ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ no difficulty" 2 "Yes ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ some difficulty" 3 "Yes ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ a lot of difficulty" 4 "Cannot do at all", replace
	label values walk_dsablty dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord = .
	label define dsablty 1 "No ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ no difficulty" 2 "Yes ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ some difficulty" 3 "Yes ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ a lot of difficulty" 4 "Cannot do at all", replace
	label values conc_dsord dsablty
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty  = .
	label define dsablty 1 "No ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ no difficulty" 2 "Yes ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ some difficulty" 3 "Yes ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ a lot of difficulty" 4 "Cannot do at all", replace
	label values slfcre_dsablty dsablty
	label var slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty = .
	label define dsablty 1 "No ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ no difficulty" 2 "Yes ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ some difficulty" 3 "Yes ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ a lot of difficulty" 4 "Cannot do at all", replace
	label values comm_dsablty dsablty
	label var comm_dsablty "Disability related to communicating"
*</_comm_dsablty_>

}


/*%%=============================================================================================
	5: Migration
==============================================================================================%%*/


{

*<_migrated_mod_age_>
gen byte migrated_mod_age = .
label var migrated_mod_age "Migration module age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
gen byte migrated_ref_time = .
label var migrated_ref_time "Migration reference time"
*</_migrated_ref_time_>


*<_migrated_binary_>
gen byte migrated_binary = .
label define lblmigrated_binary 0 "No" 1 "Yes"
label values migrated_binary lblmigrated_binary
label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen migrated_years = .
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
gen byte migrated_from_cat = .
label define lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country" 6 "Within country, admin unknown" 7 "Wholly unknown"
label values migrated_from_cat lblmigrated_from_cat
label var migrated_from_cat "Migration origin category"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen migrated_from_code = ""
	replace migrated_from_code = "" if migrated_binary != 1
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country = ""
	replace migrated_from_country = "" if migrated_binary != 1
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
gen byte migrated_reason = .
label define lblmigrated_reason 1 "Family reasons" 2 "Educational reasons" 3 "Employment" 4 "Forced (political reasons, natural disaster, ...)" 5 "Other reasons"
label values migrated_reason lblmigrated_reason
label var migrated_reason "Reason for migrating"
*</_migrated_reason_>


}


/*%%=============================================================================================
	6: Education
==============================================================================================%%*/


{

*<_ed_mod_age_>
gen byte ed_mod_age = 5
label var ed_mod_age "Education module age"
*</_ed_mod_age_>

*<_school_>
gen byte school = .
replace school = 1 if inrange(Educacion_asiste,1,5)
replace school = 0 if inlist(Educacion_asiste,6,7)
label define lblschool 0 "No" 1 "Yes"
label values school lblschool
label var school "Currently in school"
*</_school_>


*<_literacy_>
	gen byte literacy = .
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
gen byte educy = Amos_educacion if inrange(Amos_educacion,0,30)
label var educy "Years of education"
*</_educy_>


*<_educat7_>
gen byte educat7 = .
replace educat7 = 1 if inlist(Educacion_nivel_grado,0,1,2)
replace educat7 = 2 if inrange(Educacion_nivel_grado,11,15)
replace educat7 = 3 if Educacion_nivel_grado==16
replace educat7 = 4 if inrange(Educacion_nivel_grado,21,25)|inrange(Educacion_nivel_grado,31,36)
replace educat7 = 5 if inlist(Educacion_nivel_grado,26,37)
replace educat7 = 6 if inrange(Educacion_nivel_grado,41,49)
replace educat7 = 7 if inrange(Educacion_nivel_grado,51,59)
label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete"
label values educat7 lbleducat7
label var educat7 "Education, 7 categories"
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
gen int educat_orig = Educacion_nivel_grado
label var educat_orig "Original education code"
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
gen byte minlaborage = 15
label var minlaborage "Labor module age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
gen byte lstatus = .
replace lstatus = 1 if Ocupado==1 & (Edad>=15|Edad==99)
replace lstatus = 2 if Desempleado==1 & (Edad>=15|Edad==99)
replace lstatus = 3 if Fuera_fuerza_trabajo==1 & (Edad>=15|Edad==99)
label define lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
label values lstatus lbllstatus
label var lstatus "Labor status"
*</_lstatus_>


*<_potential_lf_>
gen byte potential_lf = .
replace potential_lf = 0 if lstatus==3 & Disponibilidad_fuera_fuerza_trab==1
replace potential_lf = 1 if lstatus==3 & inlist(Disponibilidad_fuera_fuerza_trab,2,3)
label define lblpotential_lf 0 "No" 1 "Yes"
label values potential_lf lblpotential_lf
label var potential_lf "Potential labour force"
*</_potential_lf_>


*<_underemployment_>
gen byte underemployment = .
replace underemployment = Subempleado if lstatus==1 & inlist(Subempleado,0,1)
label define lblunderemployment 0 "No" 1 "Yes"
label values underemployment lblunderemployment
label var underemployment "Underemployment"
*</_underemployment_>


*<_nlfreason_>
gen byte nlfreason = .
replace nlfreason = 1 if Motivo_nobusco==11 & lstatus==3
replace nlfreason = 2 if Motivo_nobusco==12 & lstatus==3
replace nlfreason = 4 if Motivo_nobusco==10 & lstatus==3
replace nlfreason = 5 if lstatus==3 & inrange(Motivo_nobusco,1,14) & missing(nlfreason)
label define lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
label values nlfreason lblnlfreason
label var nlfreason "Reason not in labor force"
*</_nlfreason_>


*<_unempldur_l_>
gen byte unempldur_l = .
* Tiempo_busqueda_empleo exists but is fully missing in the available source data.
label var unempldur_l "Unemployment duration lower bound"
*</_unempldur_l_>


*<_unempldur_u_>
gen byte unempldur_u = .
* Tiempo_busqueda_empleo exists but is fully missing in the available source data.
label var unempldur_u "Unemployment duration upper bound"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
gen byte empstat = .
replace empstat = 1 if Posicion_empleo==1 & lstatus==1
replace empstat = 4 if Posicion_empleo==2 & lstatus==1
replace empstat = 3 if Posicion_empleo==3 & lstatus==1
replace empstat = 2 if Posicion_empleo==4 & lstatus==1
label define lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
label values empstat lblempstat
label var empstat "Employment status"
*</_empstat_>


*<_ocusec_>
gen byte ocusec = .
replace ocusec = 1 if Sector_institucional==1 & lstatus==1
replace ocusec = 2 if Sector_institucional==2 & lstatus==1
label define lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
label values ocusec lblocusec
label var ocusec "Sector of activity"
*</_ocusec_>


*<_industry_orig_>
gen str4 industry_orig = string(Cod_rama_publicacion,"%04.0f") if !missing(Cod_rama_publicacion) & lstatus==1
label var industry_orig "Original industry code"
*</_industry_orig_>


*<_industrycat_isic_>
tostring Cod_rama_publicacion, gen(industrycat_isic) format(%04.0f) force
replace industrycat_isic = "" if lstatus!=1 | inlist(industrycat_isic,"0000","0850")
label var industrycat_isic "ISIC code"
*</_industrycat_isic_>


*<_industrycat10_>
gen byte industrycat10 = .
replace industrycat10 = 1 if inrange(real(substr(industrycat_isic,1,2)),1,3)
replace industrycat10 = 2 if inrange(real(substr(industrycat_isic,1,2)),5,9)
replace industrycat10 = 3 if inrange(real(substr(industrycat_isic,1,2)),10,33)
replace industrycat10 = 4 if inrange(real(substr(industrycat_isic,1,2)),35,39)
replace industrycat10 = 5 if inrange(real(substr(industrycat_isic,1,2)),41,43)
replace industrycat10 = 6 if inrange(real(substr(industrycat_isic,1,2)),45,47)|inrange(real(substr(industrycat_isic,1,2)),55,56)
replace industrycat10 = 7 if inrange(real(substr(industrycat_isic,1,2)),49,53)|inrange(real(substr(industrycat_isic,1,2)),58,63)
replace industrycat10 = 8 if inrange(real(substr(industrycat_isic,1,2)),64,82)
replace industrycat10 = 9 if real(substr(industrycat_isic,1,2))==84
replace industrycat10 = 10 if inrange(real(substr(industrycat_isic,1,2)),85,99)
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
label values industrycat10 lblindustrycat10
label var industrycat10 "Industry, 10 categories"
*</_industrycat10_>


*<_industrycat4_>
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
gen long occup_orig = Cod_ocupacion if lstatus==1
label var occup_orig "Original occupation code"
*</_occup_orig_>


*<_occup_isco_>
tostring Cod_ocupacion, gen(occup_isco) format(%04.0f) force
replace occup_isco = "" if lstatus!=1 | inlist(Cod_ocupacion,0,3316,5170,3610,9800,3711,2639,3712,3715,3716,3714,5168)
label var occup_isco "ISCO code"
*</_occup_isco_>


*<_occup_>
gen byte occup = real(substr(occup_isco,1,1)) if occup_isco!="" & lstatus==1
replace occup = 10 if substr(occup_isco,1,1)=="0" & lstatus==1
label define lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces" 99 "Others"
label values occup lbloccup
label var occup "Occupation, 1 digit"
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
gen double wage_no_compen = Ingreso_principal //Use Ingreso_principal
replace wage_no_compen = . if lstatus != 1 | empstat == 2 | missing(Ingreso_principal) | Ingreso_principal >= 99999999 | Ingreso_principal == 0
label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
gen byte unitwage = 5 if !missing(wage_no_compen)
label define lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly" 5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
label values unitwage lblunitwage
label var unitwage "Wage time unit"
*</_unitwage_>


*<_whours_>
gen double whours = Horas_efectivas_principal
replace whours = . if lstatus!=1|!inrange(Horas_efectivas_principal,1,168)
label var whours "Weekly hours, primary job"
*</_whours_>


*<_wmonths_>
	gen wmonths = .
	replace wmonths = . if lstatus != 1
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
gen double wage_total = .
label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen byte contract = .
	replace contract = . if lstatus != 1
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
gen byte healthins = .
replace healthins = 1 if Condicion_aseguramiento==1 & lstatus==1
replace healthins = 0 if Condicion_aseguramiento==0 & lstatus==1
label define lblhealthins 0 "Without health insurance" 1 "With health insurance"
label values healthins lblhealthins
label var healthins "Health insurance through work"
*</_healthins_>


*<_socialsec_>
gen byte socialsec = .
replace socialsec = 1 if E10A==1 & lstatus==1
replace socialsec = 0 if E10A==2 & lstatus==1
replace socialsec = 1 if missing(socialsec) & D14_1==1 & lstatus==1
replace socialsec = 0 if missing(socialsec) & D14_1==2 & lstatus==1
label define lblsocialsec 1 "With social security" 0 "Without social security"
label values socialsec lblsocialsec
label var socialsec "Social security through work"
*</_socialsec_>


*<_union_>
	gen byte union = .
	replace union = . if lstatus != 1
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>


*<_firmsize_l_>
gen int firmsize_l = .
replace firmsize_l = Cantidad_personas if inrange(Cantidad_personas,1,9) & lstatus==1
replace firmsize_l = 10 if Cantidad_personas==10 & lstatus==1
replace firmsize_l = 20 if Cantidad_personas==11 & lstatus==1
replace firmsize_l = 30 if Cantidad_personas==12 & lstatus==1
replace firmsize_l = 100 if Cantidad_personas==13 & lstatus==1
label var firmsize_l "Firm size lower bound"
*</_firmsize_l_>


*<_firmsize_u_>
gen int firmsize_u = .
replace firmsize_u = Cantidad_personas if inrange(Cantidad_personas,1,9) & lstatus==1
replace firmsize_u = 19 if Cantidad_personas==10 & lstatus==1
replace firmsize_u = 29 if Cantidad_personas==11 & lstatus==1
replace firmsize_u = 99 if Cantidad_personas==12 & lstatus==1
label var firmsize_u "Firm size upper bound"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
gen byte empstat_2 = .
replace empstat_2 = 1 if Posicion_secundario==1 & Empleo_secundario==1
replace empstat_2 = 4 if Posicion_secundario==2 & Empleo_secundario==1
replace empstat_2 = 3 if Posicion_secundario==3 & Empleo_secundario==1
replace empstat_2 = 2 if Posicion_secundario==4 & Empleo_secundario==1
label values empstat_2 lblempstat
label var empstat_2 "Employment status, secondary job"
*</_empstat_2_>


*<_ocusec_2_>
gen byte ocusec_2 = .
replace ocusec_2 = 1 if Sector_institucional_secundario==1 & Empleo_secundario==1
replace ocusec_2 = 2 if Sector_institucional_secundario==2 & Empleo_secundario==1
label values ocusec_2 lblocusec
label var ocusec_2 "Sector, secondary job"
*</_ocusec_2_>


*<_industry_orig_2_>
gen str4 industry_orig_2 = string(Cod_actividad_sec,"%04.0f") if !missing(Cod_actividad_sec) & Empleo_secundario==1
label var industry_orig_2 "Original industry, secondary job"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
tostring Cod_actividad_sec, gen(industrycat_isic_2) format(%04.0f) force
replace industrycat_isic_2 = "" if Empleo_secundario!=1 | inlist(industrycat_isic_2,"0000","0850")
label var industrycat_isic_2 "ISIC, secondary job"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
gen byte industrycat10_2 = .
replace industrycat10_2 = 1 if inrange(real(substr(industrycat_isic_2,1,2)),1,3)
replace industrycat10_2 = 2 if inrange(real(substr(industrycat_isic_2,1,2)),5,9)
replace industrycat10_2 = 3 if inrange(real(substr(industrycat_isic_2,1,2)),10,33)
replace industrycat10_2 = 4 if inrange(real(substr(industrycat_isic_2,1,2)),35,39)
replace industrycat10_2 = 5 if inrange(real(substr(industrycat_isic_2,1,2)),41,43)
replace industrycat10_2 = 6 if inrange(real(substr(industrycat_isic_2,1,2)),45,47)|inrange(real(substr(industrycat_isic_2,1,2)),55,56)
replace industrycat10_2 = 7 if inrange(real(substr(industrycat_isic_2,1,2)),49,53)|inrange(real(substr(industrycat_isic_2,1,2)),58,63)
replace industrycat10_2 = 8 if inrange(real(substr(industrycat_isic_2,1,2)),64,82)
replace industrycat10_2 = 9 if real(substr(industrycat_isic_2,1,2))==84
replace industrycat10_2 = 10 if inrange(real(substr(industrycat_isic_2,1,2)),85,99)
label values industrycat10_2 lblindustrycat10
label var industrycat10_2 "Industry, 10 categories"
*</_industrycat10_2_>


*<_industrycat4_2_>
	gen byte industrycat4_2 = industrycat10_2
	recode industrycat4_2 (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label var industrycat4_2 "Broad Economic Activities classification, secondary job 7 day recall"
	label values industrycat4_2 lblindustrycat4
*</_industrycat4_2_>


*<_occup_orig_2_>
gen long occup_orig_2 = Cod_ocupacion_sec if Empleo_secundario==1
label var occup_orig_2 "Original occupation, secondary job"
*</_occup_orig_2_>


*<_occup_isco_2_>
tostring Cod_ocupacion_sec, gen(occup_isco_2) format(%04.0f) force
replace occup_isco_2 = "" if Empleo_secundario!=1 | inlist(Cod_ocupacion_sec,0,3316,5170,3610,9800,3711,2639,3712,3715,3716,3714,5168)
label var occup_isco_2 "ISCO, secondary job"
*</_occup_isco_2_>


*<_occup_2_>
gen byte occup_2 = real(substr(occup_isco_2,1,1)) if occup_isco_2!="" & Empleo_secundario==1
replace occup_2 = 10 if substr(occup_isco_2,1,1)=="0" & Empleo_secundario==1
label values occup_2 lbloccup
label var occup_2 "Occupation, secondary job"
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
gen double wage_no_compen_2 = Ingreso_secundario
replace wage_no_compen_2 = . if Empleo_secundario != 1 | empstat_2 == 2 | missing(Ingreso_secundario) | Ingreso_secundario >= 99999999 | Ingreso_secundario == 0
label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
gen byte unitwage_2 = 5 if !missing(wage_no_compen_2)
label values unitwage_2 lblunitwage
label var unitwage_2 "Wage unit, secondary job"
*</_unitwage_2_>


*<_whours_2_>
gen double whours_2 = Horas_efectivas_secs
replace whours_2 = . if Empleo_secundario!=1|!inrange(Horas_efectivas_secs,1,168)
label var whours_2 "Weekly hours, secondary job"
*</_whours_2_>


*<_wmonths_2_>
	gen wmonths_2 = .
	label var wmonths_2 "Months of work in past 12 months secondary job 7 day recall"
*</_wmonths_2_>


*<_wage_total_2_>
gen double wage_total_2 = .
label var wage_total_2 "Annualized total wage, secondary job"
*</_wage_total_2_>


*<_firmsize_l_2_>
	gen firmsize_l_2 = .
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	gen firmsize_u_2 = .
	label var firmsize_u_2 "Firm size (upper bracket) secondary job 7 day recall"
*</_firmsize_u_2_>

}

*----------8.4: 7 day reference additional jobs------------------------------*

*<_t_hours_others_>
	gen t_hours_others = .
	label var t_hours_others "Annualized hours worked in all but primary and secondary jobs 7 day recall"
*</_t_hours_others_>


*<_t_wage_nocompen_others_>
gen double t_wage_nocompen_others = Ingreso_otros*12
replace t_wage_nocompen_others = . if lstatus!=1|Ingreso_otros>=99999999
label var t_wage_nocompen_others "Annualized other-job wage"
*</_t_wage_nocompen_others_>


*<_t_wage_others_>
gen double t_wage_others = .
label var t_wage_others "Annualized other-job wage"
*</_t_wage_others_>


*----------8.5: 7 day reference total summary------------------------------*


*<_t_hours_total_>
gen double t_hours_total = Horas_efectivas_total*48
replace t_hours_total = . if lstatus!=1|!inrange(Horas_efectivas_total,1,168)
label var t_hours_total "Annualized hours in all current jobs"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
gen double t_wage_nocompen_total = Ingreso_total*12
replace t_wage_nocompen_total = . if lstatus!=1 | Ingreso_total>=99999999
label var t_wage_nocompen_total "Annualized gross income, all current jobs"
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
gen double t_wage_total = Ingreso_bruto_total_trabajo*12
replace t_wage_total = . if lstatus!=1 | Ingreso_bruto_total_trabajo>=99999999
label var t_wage_total "Annualized total income, all current jobs"
*</_t_wage_total_>


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
	replace underemployment_year = . if lstatus_year != 1
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
	gen industrycat_isic_year = .

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
	la de lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
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


*<_wage_no_compen_year_> --- this var has the same name as other and when quoted in the keep and order codes is repeated.
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
	la de lblsocialsec_year 1 "With social security" 0 "Without social security"
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
	gen industrycat_isic_2_year = .
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


*----------8.10: 12 month total summary------------------------------*


*<_t_hours_total_year_>
	gen t_hours_total_year = .
	label var t_hours_total_year "Annualized hours worked in all jobs 12 month recall"
*</_t_hours_total_year_>


*<_t_wage_nocompen_total_year_>
	gen t_wage_nocompen_total_year = .
	label var t_wage_nocompen_total_year "Annualized wage in all jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_total_year_>


*<_t_wage_total_year_>
	gen t_wage_total_year = .
	label var t_wage_total_year "Annualized total wage for all jobs 12 month recall"
*</_t_wage_total_year_>


*----------8.11: Overall across reference periods------------------------------*


*<_njobs_>
gen byte njobs = F1 if lstatus==1 & inlist(F1,1,2,3)
* Source code 3 means three or more jobs.
label var njobs "Total number of jobs"
*</_njobs_>


*<_t_hours_annual_>
gen double t_hours_annual = .
label var t_hours_annual "Annualized hours in all current jobs"
*</_t_hours_annual_>


*<_linc_nc_>
gen double linc_nc = t_wage_nocompen_total
label var linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."
*</_linc_nc_>


*<_laborincome_>
gen double laborincome = t_wage_total
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
