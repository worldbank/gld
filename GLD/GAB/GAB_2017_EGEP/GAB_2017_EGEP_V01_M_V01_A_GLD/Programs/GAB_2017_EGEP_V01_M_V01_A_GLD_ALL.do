
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				GAB_2017_EGEP_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata 18 <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2025-08-05 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						GAB </_Country_>
<_Survey Title_>				Enquête Gabonaise pour l'Évaluation de la Pauvreté </_Survey Title_>
<_Survey Year_>					2017 </_Survey Year_>
<_Study ID_>					[Microdata Library ID if present] </_Study ID_>
<_Data collection from_>		07/2017 </_Data collection from_>
<_Data collection to_>			12/2017 </_Data collection to_>
<_Source of dataset_> 			La Direction Générale de la Statistique et des Etudes Economiques </_Source of dataset_>
<_Sample size (HH)_> 			7,989 </_Sample size (HH)_>
<_Sample size (IND)_> 			28,268 </_Sample size (IND)_>
<_Sampling method_> 			Two stage stratified sampling </_Sampling method_>
<_Geographic coverage_> 		National </_Geographic coverage_>
<_Currency_> 					CFA Franc </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS-13 </_ICLS Version_>
<_ISCED Version_>				ISCED-11 </_ISCED Version_>
<_ISCO Version_>				Not compatible </_ISCO Version_>
<_OCCUP National_>				Unknown </_OCCUP National_>
<_ISIC Version_>				ISIC 4 </_ISIC Version_>
<_INDUS National_>				Unknown </_INDUS National_>

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
local server  "C:/Users/wb510859/WBG/GLD - Current Contributors/510859_AS"
local country  "GAB"
local year  "2017"
local survey  "EGEP"
local vermast  "V01"
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


use "`path_in_stata'/GAB_EGEP_INDIVIDUS.dta", clear
drop _merge

* I am forcing bec variable menage is string in using but byte in master
merge m:1 interview_id using "`path_in_stata'/MENAGE_REC.dta", force


/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode="GAB"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "EGEP"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "HBS"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	gen icls_v = "ICLS-13"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	gen isced_version = ""
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
	gen isco_version = ""
	label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
	gen isic_version = "isic_4"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	gen int year=2017
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
	gen int int_year=2017
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen str_month = substr(gps_prefill_timestamp, 6, 2)
	
	* There is a HH with timestamp in January. Seems this is an error. See below
	tab gps_prefill_timestamp if str_month == "01"
	* Interview dates and time should be same for each grappe (PSU)
	replace str_month = "11" if grappe == 547 & menage == 10
	destring(str_month), gen(int_month)
	drop str_month
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
	gen psu_str = string(grappe, "%03.0f")
	gen hh_str = string(menage, "%02.0f")
	gen pid_str = string(pid, "%02.0f")
	gen hhid= psu_str + hh_str
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	drop pid
	gen pid= hhid + pid_str
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
	gen double weight= pond03
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
	gen psu = psu_str
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = hh_str
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	gen strata= strate
	label var strata "Strata"
*</_strata_>


*<_wave_>
	gen wave = .
	label var wave "Survey wave"
*</_wave_>


*<_panel_>
	gen panel = ""
	label var panel "Panel individual belongs to"
*</_panel_>3


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
	gen byte urban = (milieu == 1)
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
	gen byte subnatid1=.
	la de lblsubnatid1 1 " "
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	gen byte subnatid2=.
	la de lblsubnatid2 1 ""
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	gen str subnatid3 = ""
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
/* <_subnatidsurvey_note>

	Variable denoting lowest administrative info to which the survey is still significat.
	See entry in GLD Guidelines (https://github.com/worldbank/gld/blob/main/Support/A%20-%20Guides%20and%20Documentation/GLD_1.0_Guidelines.docx) for more details

</_subnatidsurvey_note> */
	gen str subnatidsurvey = ""
	label var subnatidsurvey "Administrative level at which survey is representative"
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
	gen hsize = .
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen byte age=s01_05
	replace age=98 if age>98 & age!=.
	label var age "Individual age"
*</_age_>


*<_male_>
	gen byte male=s01_01 == 1
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen byte relationharm=s01_02
	recode relationharm 8=4 5/7 9=5 10=6
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = s01_02
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital = s01_40
	recode marital (1 = 2) (2 = 3) (3 4 = 1) (6 7 = 4)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	gen eye_dsablty = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
	label values eye_dsablty dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values hear_dsablty dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values walk_dsablty dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values conc_dsord dsablty
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty  = .
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values slfcre_dsablty dsablty
	label var slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty = .
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
	gen migrated_mod_age = 0
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time = 99
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen migrated_binary = 0
	* 1. Was not born in Gabon
	gen byte intl_birth  = (s01_07 == 2)  if !missing(s01_07)   // 0 = born outside Gabon
	
	* 2. Resided previously abroad
	gen byte intl_prev = (s01_12 == 2)
	
	* 3. Lived in another province in Gabon
	gen byte moved_prov = (s01_10 == 2)
	
	replace migrated_binary = 1 if (intl_birth == 1) | (intl_prev == 1) | (moved_prov == 1)
	
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen migrated_years = s01_11
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
	replace migrated_from_cat = 5 if intl_birth == 1 | intl_prev
	replace migrated_from_cat = 4 if moved_prov == 1
	replace migrated_from_cat = 6 if migrated_binary == 1 & missing(migrated_from_cat)
	replace migrated_from_cat = . if migrated_binary != 1
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country" 6 "Within country, admin unknown" 7 "Wholly unknow"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen migrated_from_code = ""
	replace migrated_from_code = "1 - Estuaire"          if s01_13 == 1
	replace migrated_from_code = "2 - Haut-Ogooué"       if s01_13 == 2
	replace migrated_from_code = "3 - Moyen-Ogooué"      if s01_13 == 3
	replace migrated_from_code = "4 - Ngounié"           if s01_13 == 4
	replace migrated_from_code = "5 - Nyanga"            if s01_13 == 5
	replace migrated_from_code = "6 - Ogooué-Ivindo"     if s01_13 == 6
	replace migrated_from_code = "7 - Ogooué-Lolo"       if s01_13 == 7
	replace migrated_from_code = "8 - Ogooué-Maritime"   if s01_13 == 8
	replace migrated_from_code = "9 - Woleu-Ntem"        if s01_13 == 9
	replace migrated_from_code = "" if migrated_binary != 1
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country = ""
	replace migrated_from_country = "South Africa"                         if s01_14 == 202
	replace migrated_from_country = "Germany"                              if s01_14 == 206
	replace migrated_from_country = "Angola"                               if s01_14 == 208
	replace migrated_from_country = "Saudi Arabia"                         if s01_14 == 213
	replace migrated_from_country = "Benin"                                if s01_14 == 230
	replace migrated_from_country = "Burkina Faso"                         if s01_14 == 241
	replace migrated_from_country = "Cameroon"                             if s01_14 == 244
	replace migrated_from_country = "Cabo Verde"                           if s01_14 == 246
	replace migrated_from_country = "China"                                if s01_14 == 248
	replace migrated_from_country = "Republic of the Congo"                if s01_14 == 253
	replace migrated_from_country = "Côte d'Ivoire"                        if s01_14 == 258
	replace migrated_from_country = "United States"                        if s01_14 == 271
	replace migrated_from_country = "France"                               if s01_14 == 275
	replace migrated_from_country = "Gambia"                               if s01_14 == 276
	replace migrated_from_country = "Ghana"                                if s01_14 == 279
	replace migrated_from_country = "Guinea"                               if s01_14 == 287
	replace migrated_from_country = "Equatorial Guinea"                    if s01_14 == 288
	replace migrated_from_country = "Guinea-Bissau"                        if s01_14 == 289
	replace migrated_from_country = "Italy"                                if s01_14 == 321
	replace migrated_from_country = "Mali"                                 if s01_14 == 346
	replace migrated_from_country = "Morocco"                              if s01_14 == 350
	replace migrated_from_country = "Mauritania"                           if s01_14 == 352
	replace migrated_from_country = "World"                                if s01_14 == 358
	replace migrated_from_country = "Niger"                                if s01_14 == 368
	replace migrated_from_country = "Nigeria"                              if s01_14 == 369
	replace migrated_from_country = "Central African Republic"             if s01_14 == 391
	replace migrated_from_country = "Democratic Republic of the Congo"     if s01_14 == 392
	replace migrated_from_country = "United Kingdom"                       if s01_14 == 396
	replace migrated_from_country = "São Tomé and Príncipe"                if s01_14 == 410
	replace migrated_from_country = "Senegal"                              if s01_14 == 411
	replace migrated_from_country = "Switzerland"                          if s01_14 == 424
	replace migrated_from_country = "Chad"                                 if s01_14 == 431
	replace migrated_from_country = "Togo"                                 if s01_14 == 436
	replace migrated_from_country = "Tunisia"                              if s01_14 == 440

	replace migrated_from_country = "" if migrated_binary != 1
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason = .
	replace migrated_reason = . if migrated_binary != 1
		
	* Employment: 1=Job search, 2=Job loss, 3=Professional transfer
	replace migrated_reason = 3 if migrated_binary==1 & inlist(s01_15, 1, 2, 3)

	* Family: 4=Family, 7=Marriage
	replace migrated_reason = 1 if migrated_binary==1 & inlist(s01_15, 4, 7)

	* Educational: 6=School/Training
	replace migrated_reason = 2 if migrated_binary==1 & s01_15==6

	* Other: 5=Health, 8=Retirement, 9=Pregnancy/Childbirth, 98=Other (specify)
	replace migrated_reason = 5 if migrated_binary==1 & inlist(s01_15, 5, 8, 9, 98)

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
	gen byte ed_mod_age=3
label var ed_mod_age "Education module application age"
*</_ed_mod_age_>

*<_school_>
	gen byte school= (s02_09 == 1)
	replace school=. if age<ed_mod_age & age!=.
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen byte literacy = 0
	gen can_read_any = s02_01_1 == 1 | s02_01_2 == 1 | s02_01_8 == 1
	gen can_write_any = s02_02_1 == 1 | s02_02_2 == 1 | s02_02_8 == 1
	
	* Defined as can read AND write
	replace literacy = 1 if can_read_any == 1 & can_write_any == 1
	replace literacy = . if age<ed_mod_age & age!=.
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen byte educy = .
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7= s02_23
	* Missing for students (currently attending); set to current level
	replace educat7 = s02_11 if missing(educat7)
	recode educat7 ///
    (1 = 2)  /// Pre-primary  → Primary incomplete
    (2 = 3)  /// Primary      → Primary complete
    (3 = 4)  /// Sec. 1       → Secondary incomplete
    (4 = 5)  /// Sec. 2       → Secondary complete
    (5/7 = 7)  /// Supérieur (1er–3e cycle) → University (incl. incomplete/complete)
	
	* There is no code for "no education" but there is question on whether ever attended formal education (s02_03)
	replace educat7 = 1 if s02_03 == 2
	replace educat7=. if age<ed_mod_age & age!=.
	label var educat7 "Level of education 1"
	la de lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete"
	label values educat7 lbleducat7
*</_educat7_>


*<_educat5_>
	gen byte educat5 = .
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
	gen educat_orig = s02_23
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
	gen educat_isced = s02_23
	recode educat_isced (1 = 0) (2 = 1) (3 = 2) (4 = 3) (5 = 6) (6 7 = 7)
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
	gen byte minlaborage=6
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
	gen byte lstatus = .
	
	* Employed: engaged in economic activity in past 7 days or absent
	* s04a_05 is supposedly a catch-all variable for all hours worked in activities in s04a_01 to s04a_04 but there are some that were not covered; thus I include all activites on top of the catch-all so all bases are covered
	replace lstatus = 1 if s04a_01_1==1 | s04a_01_2==1 | s04a_02_1==1 | s04a_02_2==1 | s04a_02_3==1 | s04a_02_4==1 | s04a_02_5==1 | s04a_03_1==1 | s04a_03_2 ==1 ///
	| s04a_03_3==1 | s04a_04==1 | s04a_05==1 | s04a_06==1

	* Unemployed: looked for work in past 7 or 30 days & available immediately or in the next 2 weeks (based on ILO standard)
	* We can include those avialable more than 2 weeks, but just minimal additional observations
	replace lstatus = 2 if (s04a_09 == 1 | s04a_10 == 1) &  inlist(s04a_12, 1,2) & lstatus != 1

	* Not in the labor force
	replace lstatus = 3 if missing(lstatus) & age >= minlaborage & !missing(s04a_00)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>

/*
*NOTE: Alternative definition of unemployed based on national definition
*- The national definition for unemployed includes the hidden unemployed, i.e., workers who are discouraged due to lack of jobs or do not know how to look for work
	gen byte lstatus_alt = .
	
	* Employed: engaged in economic activity in past 7 days or absent
	replace lstatus_alt = 1 if s04a_01_1==1 | s04a_01_2==1 | s04a_02_1==1 | s04a_02_2==1 | s04a_02_3==1 | s04a_02_4==1 | s04a_02_5==1 | s04a_03_1==1 | s04a_03_2 ==1 ///
	| s04a_03_3==1 | s04a_04==1 | s04a_05==1 | s04a_06==1

	* Unemployed: looked for work in past 7 or 30 days
	replace lstatus_alt = 2 if (s04a_09 == 1 | s04a_10 == 1) & lstatus_alt != 1
	
	* Define hidden unemployed: those not know how to search for job and discouraged due to lack of opportunities
	replace lstatus_alt = 2 if inlist(s04a_11, 11, 12) & lstatus_alt != 1
	
	* Not in the labor force
	replace lstatus_alt = 3 if missing(lstatus_alt) & age >= minlaborage & !missing(s04a_00)
	replace lstatus_alt = . if age < minlaborage
	label var lstatus_alt "Labor status"
	label values lstatus_alt lbllstatus
*</_lstatus_alt_>


*/

*<_potential_lf_>
	gen byte potential_lf = .
	replace potential_lf = (s04a_09 == 1 | s04a_10 == 1) | (inlist(s04a_12, 1,4)) & lstatus == 3
	replace potential_lf = . if age < minlaborage & !missing(age)
	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen byte underemployment = .
	replace underemployment = . if age < minlaborage & !missing(age)
	replace underemployment = . if lstatus != 1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason=s04a_09a
	recode nlfreason 2=1 5=2 4=3 7=4 1 3 6 8/98=5
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l=s04a_14
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=s04a_14
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte empstat = .
	replace empstat = 1 if inlist(s04b_30, 1, 2, 3, 4, 5) 
	replace empstat = 3 if s04b_30 == 6                  
	replace empstat = 4 if s04b_30 == 7                  
	replace empstat = 2 if inlist(s04b_30,  9)   
	
	* Apprentice as "others" bec we cannot tell if paid or unpaid
	replace empstat = 5 if s04b_30 == 8
	replace empstat = . if lstatus != 1

	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec=s04b_23
	replace ocusec = 1 if inlist(s04b_23,1,2,3,4,5,6)
	replace ocusec = 2 if inlist(s04b_23,7,8,9,10,11,13)
	replace ocusec = 3 if s04b_23==12  

	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig=s04b_22a
	replace industry_orig=. if lstatus!=1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	gen industrycat_isic = ""
	
	* Cross walk based on ISIC 4 letters
	* A — Agriculture, forestry & fishing
	replace industrycat_isic = "A" if inlist(industry_orig,10000,20010,20020,30000,40000,50000)

	* B — Mining & quarrying
	replace industrycat_isic = "B" if inlist(industry_orig,60010,60020,60030,60040)

	* C — Manufacturing
	replace industrycat_isic = "C" if inlist(industry_orig, ///
		70010,70020,70030,70040, /// 
		80000,90000,100000,110000,120010,120020, /// 
		130000,140000,150000,160000, /// 
		170010,170020,170030,170040, ///
		180010,180020,              /// 
		190000,                     /// 
		200010,200020,200030,200040, /// 
		210000,                     /// 
		220010,220020,              /// 
		230000,240000,250000,260000, /// 
		270020,270030)              /// 

	* D — Electricity, gas, steam & A/C
	replace industrycat_isic = "D" if inlist(industry_orig,280000)

	* E — Water supply; sewerage; waste; remediation
	replace industrycat_isic = "E" if inlist(industry_orig,410010)   // assainissement/voirie/déchets (default to E)

	* F — Construction
	replace industrycat_isic = "F" if inlist(industry_orig,290000)

	* G — Wholesale & retail trade; repair of motor vehicles
	replace industrycat_isic = "G" if inlist(industry_orig,300010,300020,300030,300040,300050,300060,310010)

	* H — Transportation & storage (incl. postal)
	replace industrycat_isic = "H" if inlist(industry_orig,330010,330020,330030,330040,330050,340010)

	* I — Accommodation & food service activities
	replace industrycat_isic = "I" if inlist(industry_orig,320010,320020)

	* J — Information & communication
	replace industrycat_isic = "J" if inlist(industry_orig,340020,370020) 
	
	* K — Financial & insurance activities
	replace industrycat_isic = "K" if inlist(industry_orig,350010,350020,350030)

	* L — Real estate activities
	replace industrycat_isic = "L" if inlist(industry_orig,360000)

	* N — Administrative & support service activities
	* Vs SSAPOV: we include 370030 as this group includes receiptionists, service workers, hotel staff (code "81" or 82 in ISIC)
	replace industrycat_isic = "N" if inlist(industry_orig,370010,370030)

	* O — Public administration & defence; compulsory social security
	* we include "380010" as we interpret this as "public administration": 95% public sector; some 5% in private, which we assume as encoding error
	tab ocusec  if industry_orig == 380010
	* We also include 430000; all 3 obs in public sector (this is territoriale correction), given description, this is correctional facility 
	replace industrycat_isic = "O" if inlist(industry_orig,380010,380020,380030, 430000)

	* P — Education
	replace industrycat_isic = "P" if inlist(industry_orig,390000)

	* Q — Human health & social work activities
	replace industrycat_isic = "Q" if inlist(industry_orig,400000)

	* R — Arts, entertainment & recreation
	replace industrycat_isic = "R" if inlist(industry_orig,410030)

	* S — Other service activities
	replace industrycat_isic = "S" if inlist(industry_orig,410020,410040,310020)   

	* T — Activities of households as employers
	replace industrycat_isic = "T" if inlist(industry_orig,410050)
	
	* Ambiguous ones (420000 and 999999), leave missing since only 26 (420000) + 67 (999999) observations
	* Text description of activites suggest it has no clear correspondence to ISIC: diplomat, control de prix, comptable, nettoyage, administration communale, service de santé publique
	replace industrycat_isic = "" if  inlist(industry_orig,420000, 999999) 


	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen byte industrycat10= .
	
	* 1 Agriculture
	replace industrycat10 = 1 if inlist(industrycat_isic,"A")

	* 2 Mining
	replace industrycat10 = 2 if inlist(industrycat_isic,"B")

	* 3 Manufacturing
	replace industrycat10 = 3 if inlist(industrycat_isic,"C")

	* 4 Public utilities (Electricity + Water/Sewer/Waste)
	replace industrycat10 = 4 if inlist(industrycat_isic,"D","E")

	* 5 Construction
	replace industrycat10 = 5 if inlist(industrycat_isic,"F")

	* 6 Commerce (Wholesale/Retail & vehicle repair)
	replace industrycat10 = 6 if inlist(industrycat_isic,"G", "I")

	* 7 Transport & Communications (Transport/Storage + Info/Telecom)
	replace industrycat10 = 7 if inlist(industrycat_isic,"H", "J")

	* 8 Financial & Business Services (Finance/Insurance + Real estate + Prof/Tech + Admin/Support)
	replace industrycat10 = 8 if inlist(industrycat_isic,"K","L","N")

	* 9 Public Administration (incl. compulsory social security)
	replace industrycat10 = 9 if inlist(industrycat_isic,"O")

	* 10 Other Services, Unspecified (Accommodation & food; Education; Health/Social; Arts/Rec; Other services; Households)
	replace industrycat10 = 10 if inlist(industrycat_isic,"P","Q","R","S","T")

	replace industrycat10=. if lstatus!=1
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
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
	gen occup_orig= string(s04b_21a)
	replace occup_orig= "" if lstatus!=1 | occup_orig == "."
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
* This uses the same occupation nomenclature used by Morocco which has no direct correspondence with ISCO
* For this reason, we do not code occup_isco here as we did in Morocco
	gen occup_isco = ""

	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>

/* - The questionnaire's 4-digit codes are a LOCAL taxonomy, not ISCO.
   Many 2-digit groups mix different job families (e.g., 51–55) and
   include "n.c.a." categories, so a clean 1:1 mapping to ISCO-style
   major groups is impossible without judgment calls.
 - Titles indicate tasks or setting (e.g., "agent d'hygiène"), but can refer
   to very different jobs across sectors (public health vs. refuse work).
 - Some codes denote status/seniority (cadre, agent subalterne) more
   than occupation; others blend occupation & sector (banque, douanes).
 - Because of this, we use a 2-digit BASELINE plus hand-picked 4-digit
   EXCEPTIONS to better match to occup. A few mappings remain
   debatable; those lines are flagged as QUESTIONABLE below.

 Debatable mappings to be aware of (documented inline as well):
 - Police/gendarme/fire → group 5 "Service": ISCO-08 puts protective
   services under Major Group 5; only the armed forces go to group 10.
 - 5220 "Caissier" (cashier): we keep as Clerks (4), but many schemes
   (ISCO-08 52xx) place cashiers under Sales (5). Toggle provided.
 - 5480 "Agent d'hygiène / d'assainissement": could be refuse worker (9),
   or environmental health assistant (3). We default to 9; toggle provided.
 - 5250 "Planton / agent de liaison / commis": mixed messenger (9) vs
   office clerk (4). We default to 4; toggle provided.
 - 8530 "Blanchisseur" (Launderer): we default to 9 (elementary). Some classify in
   personal services (5). Toggle provided.
 - Street food sellers (8260/8280/8290): default EXCLUDED from 9;
   optional toggle to include them as "street & related sales".
*/
	gen byte occup=.
	gen occ2 = substr(occup_orig, 1, 2)
	destring occ2, replace
	replace occup=. if lstatus!=1
	
	replace occup = 6  if inrange(occ2,11,14)                         // Skilled agricultural
	replace occup = 1  if inlist(occ2,21,23)                          // Managers (legisl./traditional)
	replace occup = 2  if occ2==22                                    // Professionals (clergy)
	replace occup = 2  if inrange(occ2,31,39)                         // Professionals
	replace occup = 4  if occ2==41                                    // Clerks
	replace occup = 2  if inlist(occ2,42,43)                          // Teachers, nurses/midwives
	replace occup = 3  if inrange(occ2,44,48)                         // Technicians (cadres moyens)
	replace occup = 4  if inrange(occ2,51,52)                         // Admin/support clerks
	replace occup = 8  if occ2==53                                    // Plant/machine operators (operators)
	replace occup = 5  if occ2==54                                    // Health/personal/service assistants
	replace occup = 9  if occ2==55                                    // Labourers (will refine below)
	replace occup = 5  if inrange(occ2,61,69)                         // Service & market sales
	replace occup = 7  if inrange(occ2,70,74)                         // Craft workers
	replace occup = 5  if inrange(occ2,81,82) | inrange(occ2,84,86)    // Hotels/food/personal services

	* Transport drivers/operators
	replace occup = 8  if occ2==83                                    
	replace occup = 9  if s04b_21a==8340                              
	* Armed forces vs police/gendarme/fire
	replace occup = 10 if inlist(s04b_21a, 9110,9190,9210,9290,9310)   // Armed forces
	replace occup = 5  if inlist(s04b_21a, 9120,9220,9320,9130,9330,9140,9240,9340) // Police/gendarme/fire

	* Elementary occupations
	replace occup = 9 if inlist(s04b_21a, 5530,5590,8570,8600,8340,5480,8530,8190)

	* Mining labourers/miners 
	replace occup = 9 if s04b_21a==5140                             

	* Keep classic clerks as Clerks (if touched by overrides)
	replace occup = 4 if inlist(s04b_21a, 4110,4120,4140,5220,5260,5510,5520,5250)

	* Treat  street food sellers as elementary
	replace occup = 9 if inlist(s04b_21a, 8260,8280,8290)

	* Remaining unmapped but coded -> Others
	replace occup = 99 if missing(occup) & s04b_21a<.
	
	replace occup = . if lstatus != 1
	
	drop occ2
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
* This asks about the average earnings in the past 12 months of the job taken in the last 7 days
* There is a question abut non-cash benefits asked for those who reported cash income, which we don't include here
	gen double wage_no_compen=s04b_31a 
	replace wage_no_compen=. if lstatus!=1
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
	gen byte unitwage=s04b_31b
	recode unitwage 3=5 4=6 5=8
	replace unitwage=. if lstatus!=1
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	* There is no variable on the hours worked per week but we have data on hours per day and the # days worked per month. 
	gen whours= int(s04b_29*(s04b_28/4.33))
	* Suspiciously high if 16 hours, 7days a week!
	replace whours=. if whours>16*7
	replace whours=. if lstatus!=1
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	gen wmonths = s04b_27
	replace wmonths = . if lstatus != 1
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
/* <_wage_total_note>

	Use gross wages when available and net wages only when gross wages are not available.
	This is done to make it easy to compare earnings in formal and informal sectors.

</_wage_total_note> */

	* Cash income annualized
	gen wage_total_cash= .
	replace wage_total_cash = wage_no_compen * s04b_28 * s04b_27 if lstatus==1 & unitwage==1
	replace wage_total_cash = wage_no_compen * 4.33 * s04b_27     if lstatus==1 & unitwage==2
	replace wage_total_cash = wage_no_compen * s04b_27           if lstatus==1 & unitwage==5
	replace wage_total_cash = 4 * wage_no_compen        if lstatus==1 & unitwage==6               
	replace wage_total_cash = wage_no_compen      if lstatus==1 & unitwage==8        
	
	* Non-cash income annualized
	gen wage_total_noncash= .
	replace wage_total_noncash = s04b_32a * s04b_28 * s04b_27 if lstatus==1 & s04b_32b==1
	replace wage_total_noncash = s04b_32a * 4.33 * s04b_27     if lstatus==1 & s04b_32b==2
	replace wage_total_noncash = s04b_32a * s04b_27           if lstatus==1 & s04b_32b==3
	replace wage_total_noncash = 4 * wage_no_compen        if lstatus==1 & s04b_32b==4             
	replace wage_total_noncash = wage_no_compen      if lstatus==1 & s04b_32b==5        
	
	egen wage_total = rowtotal(wage_total_cash wage_total_noncash)
	replace wage_total = . if (missing(wage_total_cash) & missing(wage_total_noncash))
	
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen byte contract=(s04b_30a == 1)
	replace contract=. if lstatus!=1
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte healthins=.
	replace healthins=. if lstatus!=1
	label var healthins "Employment has health insurance primary job 7 day recall"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen byte socialsec=.
	replace socialsec=. if lstatus!=1
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec 1 "With social security" 0 "Without social secturity"
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen byte union=.
	replace union=. if lstatus!=1
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	gen byte firmsize_l=s04b_26
	recode firmsize_l 3=6 4=11 5=51 6=100 7=.
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u=s04b_26
	recode firmsize_u 2=5 3=10 4=50 5=100 6/7=.
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen byte empstat_2=s04c_42
	* 1 Paid employee: cadres/employés/ouvriers (1–5)
	replace empstat_2 = 1 if inlist(s04c_42, 1,2,3,4,5)

	* 3 Employer
	replace empstat_2 = 3 if s04c_42 == 6

	* 4 Self-employed (own-account)
	replace empstat_2 = 4 if s04c_42 == 7

	* 2 Non-paid employee: family helper
	replace empstat_2 = 2 if s04c_42 == 9

	* 5 Other: apprentice (kept as "other" since paid/unpaid is unclear here)
	replace empstat_2 = 5 if s04c_42 == 8

	replace empstat_2 = . if s04b_35 != 1 | missing(s04c_42) | lstatus != 1
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2 = .
	replace ocusec_2 = 1 if inlist(s04c_38, 1, 2)
	replace ocusec_2 = 3 if s04c_38 == 3
	replace ocusec_2 = 2 if inlist(s04c_38, 4, 5, 6, 7)

	replace ocusec_2 = . if s04b_35 != 1 | missing(s04c_38)  | lstatus != 1
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2=s04c_37b
	replace industry_orig_2=. if s04b_35 != 1 | lstatus != 1
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	gen industrycat_isic_2 = ""
	
	* Cross walk based on ISIC 4 letters
	* A — Agriculture, forestry & fishing
	replace industrycat_isic_2 = "A" if inlist(industry_orig_2,10000,20010,20020,30000,40000,50000)

	* B — Mining & quarrying
	replace industrycat_isic_2 = "B" if inlist(industry_orig_2,60010,60020,60030,60040)

	* C — Manufacturing
	replace industrycat_isic_2 = "C" if inlist(industry_orig_2, ///
		70010,70020,70030,70040, /// 
		80000,90000,100000,110000,120010,120020, /// 
		130000,140000,150000,160000, /// 
		170010,170020,170030,170040, ///
		180010,180020,              /// 
		190000,                     /// 
		200010,200020,200030,200040, /// 
		210000,                     /// 
		220010,220020,              /// 
		230000,240000,250000,260000, /// 
		270020,270030)              /// 

	* D — Electricity, gas, steam & A/C
	replace industrycat_isic_2 = "D" if inlist(industry_orig_2,280000)

	* E — Water supply; sewerage; waste; remediation
	replace industrycat_isic_2 = "E" if inlist(industry_orig_2,410010)   // assainissement/voirie/déchets (default to E)

	* F — Construction
	replace industrycat_isic_2 = "F" if inlist(industry_orig_2,290000)

	* G — Wholesale & retail trade; repair of motor vehicles
	replace industrycat_isic_2 = "G" if inlist(industry_orig_2,300010,300020,300030,300040,300050,300060,310010)

	* H — Transportation & storage (incl. postal)
	replace industrycat_isic_2 = "H" if inlist(industry_orig_2,330010,330020,330030,330040,330050,340010)

	* I — Accommodation & food service activities
	replace industrycat_isic_2 = "I" if inlist(industry_orig_2,320010,320020)

	* J — Information & communication
	replace industrycat_isic_2 = "J" if inlist(industry_orig_2,340020,370020) 
	
	* K — Financial & insurance activities
	replace industrycat_isic_2 = "K" if inlist(industry_orig_2,350010,350020,350030)

	* L — Real estate activities
	replace industrycat_isic_2 = "L" if inlist(industry_orig_2,360000)

	* N — Administrative & support service activities
	* Vs SSAPOV: we include 370030 as this group includes receiptionists, service workers, hotel staff (code "81" or 82 in ISIC)
	replace industrycat_isic_2 = "N" if inlist(industry_orig_2,370010,370030)

	* O — Public administration & defence; compulsory social security
	* we include "380010" as we interpret this as "public administration": 95% public sector; some 5% in private, which we assume as encoding error
	tab ocusec  if industry_orig_2 == 380010
	* We also include 430000; all 3 obs in public sector (this is territoriale correction), given description, this is correctional facility 
	replace industrycat_isic_2 = "O" if inlist(industry_orig_2,380010,380020,380030, 430000)

	* P — Education
	replace industrycat_isic_2 = "P" if inlist(industry_orig_2,390000)

	* Q — Human health & social work activities
	replace industrycat_isic_2 = "Q" if inlist(industry_orig_2,400000)

	* R — Arts, entertainment & recreation
	replace industrycat_isic_2 = "R" if inlist(industry_orig_2,410030)

	* S — Other service activities
	replace industrycat_isic_2 = "S" if inlist(industry_orig_2,410020,410040,310020)   

	* T — Activities of households as employers
	replace industrycat_isic_2 = "T" if inlist(industry_orig_2,410050)
	
	* Ambiguous ones (420000 and 999999), leave missing since only 26 (420000) + 67 (999999) observations
	* Text description of activites suggest it has no clear correspondence to ISIC: diplomat, control de prix, comptable, nettoyage, administration communale, service de santé publique
	replace industrycat_isic_2 = "" if  inlist(industry_orig_2,420000, 999999) 


	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen byte industrycat10_2= .
	
	* 1 Agriculture
	replace industrycat10_2 = 1 if inlist(industrycat_isic_2,"A")

	* 2 Mining
	replace industrycat10_2 = 2 if inlist(industrycat_isic_2,"B")

	* 3 Manufacturing
	replace industrycat10_2 = 3 if inlist(industrycat_isic_2,"C")

	* 4 Public utilities (Electricity + Water/Sewer/Waste)
	replace industrycat10_2 = 4 if inlist(industrycat_isic_2,"D","E")

	* 5 Construction
	replace industrycat10_2 = 5 if inlist(industrycat_isic_2,"F")

	* 6 Commerce (Wholesale/Retail & vehicle repair)
	replace industrycat10_2 = 6 if inlist(industrycat_isic_2,"G")

	* 7 Transport & Communications (Transport/Storage + Info/Telecom)
	replace industrycat10_2 = 7 if inlist(industrycat_isic_2,"H", "I", "J")

	* 8 Financial & Business Services (Finance/Insurance + Real estate + Prof/Tech + Admin/Support)
	replace industrycat10_2 = 8 if inlist(industrycat_isic_2,"K","L","M","N")

	* 9 Public Administration (incl. compulsory social security)
	replace industrycat10_2 = 9 if inlist(industrycat_isic_2,"O")

	* 10 Other Services, Unspecified (Accommodation & food; Education; Health/Social; Arts/Rec; Other services; Households)
	replace industrycat10_2 = 10 if inlist(industrycat_isic_2,"P","Q","R","S","T")

	replace industrycat10_2 = . if s04b_35 != 1 | lstatus != 1

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
	gen occup_orig_2 = string(s04c_36b)
	replace occup_orig_2 = "" if occup_orig_2 == "."
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen occup_isco_2 = ""
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_2_>
	gen byte occup_2=.
	gen occ2 = substr(occup_orig_2, 1, 2)
	destring occ2, replace
	replace occup_2=. if lstatus!=1
	
	replace occup_2 = 6  if inrange(occ2,11,14)                         // Skilled agricultural
	replace occup_2 = 1  if inlist(occ2,21,23)                          // Managers (legisl./traditional)
	replace occup_2 = 2  if occ2==22                                    // Professionals (clergy)
	replace occup_2 = 2  if inrange(occ2,31,39)                         // Professionals
	replace occup_2 = 4  if occ2==41                                    // Clerks
	replace occup_2 = 2  if inlist(occ2,42,43)                          // Teachers, nurses/midwives
	replace occup_2 = 3  if inrange(occ2,44,48)                         // Technicians (cadres moyens)
	replace occup_2 = 4  if inrange(occ2,51,52)                         // Admin/support clerks
	replace occup_2 = 8  if occ2==53                                    // Plant/machine operators (operators)
	replace occup_2 = 5  if occ2==54                                    // Health/personal/service assistants
	replace occup_2 = 9  if occ2==55                                    // Labourers (will refine below)
	replace occup_2 = 5  if inrange(occ2,61,69)                         // Service & market sales
	replace occup_2 = 7  if inrange(occ2,70,74)                         // Craft workers
	replace occup_2 = 5  if inrange(occ2,81,82) | inrange(occ2,84,86)    // Hotels/food/personal services

	* Transport drivers/operators
	replace occup_2 = 8  if occ2==83                                    // 83xx drivers (chauffeur/bus/taxi)
	replace occup_2 = 9  if s04c_36b==8340                              

	* Armed forces vs police/gendarme/fire
	replace occup_2 = 10 if inlist(s04c_36b, 9110,9190,9210,9290,9310)   // Armed forces
	replace occup_2 = 5  if inlist(s04c_36b, 9120,9220,9320,9130,9330,9140,9240,9340) // Police/gendarme/fire

	* Elementary occup_2ations (code-only set; no titles/regex)
	replace occup_2 = 9 if inlist(s04c_36b, 5530,5590,8570,8600,8340,5480,8530,8190)

	* Mining labourers/miners
	replace occup_2 = 9 if s04c_36b==5140                             

	* Keep classic clerks as Clerks (if touched by overrides)
	replace occup_2 = 4 if inlist(s04c_36b, 4110,4120,4140,5220,5260,5510,5520,5250)

	* Treat  street food sellers as elementary
	replace occup_2 = 9 if inlist(s04c_36b, 8260,8280,8290)

	* Remaining unmapped but coded -> Others
	replace occup_2 = 99 if missing(occup_2) & s04c_36b<.
	drop occ2
	replace occup_2 = . if s04b_35 != 1 | lstatus != 1
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
	gen double wage_no_compen_2=s04c_43a if s04c_43b>2
	replace wage_no_compen_2=. if s04b_35 != 1 | lstatus != 1
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2=s04c_43b if s04c_43b>2
	recode unitwage_2 3=5 4=6 5=8
	replace unitwage_2=. if s04b_35 != 1 | lstatus != 1
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
	gen days_per_month = s04c_40
	replace days_per_month = . if s04c_40>30 | missing(s04c_40)
	gen whours_2 = int(s04c_41*(days_per_month/4.33))
	replace whours_2 = . if s04b_35 != 1 | whours_2>16*7 | lstatus!=1
	label var whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>


*<_wmonths_2_>
	gen wmonths_2 = s04c_39
	replace wmonths_2 = 1 if wmonths_2 == 0
	replace wmonths_2 = . if  s04b_35 != 1 | s04c_39>12 | lstatus!=1
	label var wmonths_2 "Months of work in past 12 months secondary job 7 day recall"
*</_wmonths_2_>


*<_wage_total_2_>
	gen wage_total_2 = .
	label var wage_total_2 "Annualized total wage secondary job 7 day recall"
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
	gen t_wage_nocompen_others = .
	label var t_wage_nocompen_others "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_others_>


*<_t_wage_others_>
	gen t_wage_others = .
	label var t_wage_others "Annualized wage in all but primary and secondary jobs (12-mon ref period)"
*</_t_wage_others_>


*----------8.5: 7 day reference total summary------------------------------*


*<_t_hours_total_>
	* calculate primary occup: hours worked per day * # days per month * # of months worked
	gen whours_primary_annual = s04b_29 * s04b_28 * wmonths
	gen whours_secondary_annual = s04c_41 * days_per_month * wmonths_2
	
	egen t_hours_total = rowtotal(whours_primary_annual whours_secondary_annual)
	
	* Set sanity check: 16 hours per week, everyday for an entire year is 5856 in a leap year	
	replace t_hours_total = . if missing(whours_primary_annual) | lstatus!= 1 | t_hours_total>5856
	label var t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
	gen t_wage_nocompen_total = .
	label var t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
	gen t_wage_total = .
	label var t_wage_total "Annualized total wage for all jobs 7 day recall"
*</_t_wage_total_>


*----------8.6: 12 month reference overall------------------------------*

{

*<_lstatus_year_>
	gen byte lstatus_year=.
	replace lstatus_year=. if age<minlaborage & age!=.
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
	gen byte empstat_year=.
	replace empstat_year=. if lstatus_year!=1
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
	la de lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
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
	gen byte empstat_2_year=.
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


*----------8.11: Overall across reference periods------------------------------*


*<_njobs_>
	gen njobs = 1 
	replace njobs = 2 if s04b_35 == 1
	replace njobs = . if lstatus != 1
	label var njobs "Total number of jobs"
*</_njobs_>


*<_t_hours_annual_>
	gen t_hours_annual = .
	label var t_hours_annual "Total hours worked in all jobs in the previous 12 months"
*</_t_hours_annual_>


*<_linc_nc_>
	gen linc_nc = .
	label var linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."
*</_linc_nc_>


*<_laborincome_>
	gen laborincome = t_wage_total_year
	label var laborincome "Total annual individual labor income in all jobs, incl. bonuses, etc."
*</_laborincome_>


*----------8.13: Labour cleanup------------------------------*

{
*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
	local lab_vars "minlaborage lstatus nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome"

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
