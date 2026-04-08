/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				AFG_2013_LCS_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata 18 </_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2026-03-23 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						AFG </_Country_>
<_Survey Title_>				Afghanistan Living Conditions Survey (LCS) 2013-14 </_Survey Title_>
<_Survey Year_>					2013 </_Survey Year_>
<_Study ID_>					 </_Study ID_>
<_Data collection from_>		12/2013 </_Data collection from_>
<_Data collection to_>			01/2015 </_Data collection to_>
<_Source of dataset_> 			Central Statistics Organization (CSO), Afghanistan </_Source of dataset_>
<_Sample size (HH)_> 			20,786 </_Sample size (HH)_>
<_Sample size (IND)_> 			157,262 </_Sample size (IND)_>
<_Sampling method_> 			Two-stage sampling design </_Sampling method_>
<_Geographic coverage_> 		National </_Geographic coverage_>
<_Currency_> 					Afghan afghani (AFN) </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS-13 </_ICLS Version_>
<_ISCED Version_>				Not identified from the available documentation </_ISCED Version_>
<_ISCO Version_>				ISCO-08 </_ISCO Version_>
<_OCCUP National_>				Not identified from the available documentation </_OCCUP National_>
<_ISIC Version_>				ISIC Revision 2 </_ISIC Version_>
<_INDUS National_>				Not identified from the available documentation </_INDUS National_>

-----------------------------------------------------------------------
<_Version Control_>

* Date: 2026-04-07 - Filled ICLS metadata and documented education ISCED limitation.

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

local server  "/Users/angelosantos/Downloads"
local country  "AFG"
local year  "2013"
local survey  "LCS"
local vermast  "V01"
local veralt  "V01"

local level_1      "`country'_`year'_`survey'"
local level_2_mast "`level_1'_`vermast'_M"
local level_2_harm "`level_1'_`vermast'_M_`veralt'_A_GLD"

local path_in_stata "`server'/`country'/`level_1'/`level_2_mast'/Data/Stata"
local path_in_other "`server'/`country'/`level_1'/`level_2_mast'/Data/Original"
local path_output   "`server'/`country'/`level_1'/`level_2_harm'/Data/Harmonized"

local out_file "`level_2_harm'_ALL.dta"

*----------1.3: Database assembly------------------------------*

* All steps necessary to merge datasets (if several) to have all elements needed to produce
* harmonized output in a single file
	use "`path_in_stata'/H_01.dta" , clear
	merge 1:1 hh_id using "`path_in_stata'/H_02.dta", nogen
	merge 1:1 hh_id using "`path_in_stata'/H_04-09.dta", nogen
	drop q_5_* q_6_* q_9_*
	merge 1:m hh_id using "`path_in_stata'/H_03.dta", nogen
	merge 1:1 hh_id ind_id using "`path_in_stata'/H_10.dta", nogen
	merge 1:1 hh_id ind_id using "`path_in_stata'/H_11.dta", nogen
	merge 1:1 hh_id ind_id using "`path_in_stata'/H_12.dta", nogen
	merge 1:1 hh_id ind_id using "`path_in_stata'/H_24.dta", nogen



/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode="AFG"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen strL survname = "LCS"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen strL survey = "LCS"
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
	gen strL isic_version = "isic_2"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	gen int year=2013
	label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen strL vermast = "`vermast'"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen strL veralt = "`veralt'"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen strL harmonization = "GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	gen int_year=2013
	replace int_year=2014 if q_2_1a>=11 & q_2_1b==10 & q_2_1c==92
	replace int_year=2014 if q_2_1b>=11 & q_2_1c==92
	replace int_year=2014 if q_2_1c==93
	replace int_year=2015 if(inrange(q_2_1a,11,31) & q_2_1b==10 & q_2_1c==93) | (inrange(q_2_1a,1,11) & q_2_1b==11 & q_2_1c==93)
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen byte int_month=12 if (inrange(q_2_1a,10,30) & q_2_1b==9 & q_2_1c==92) | (inrange(q_2_1a,1,10) & q_2_1b==10 & q_2_1c==92)
	replace int_month=1 if(inrange(q_2_1a,11,31) & q_2_1b==10 & q_2_1c==92) | (inrange(q_2_1a,1,11) & q_2_1b==11 & q_2_1c==92)
	replace int_month=2 if(inrange(q_2_1a,12,31) & q_2_1b==11 & q_2_1c==92) | (inrange(q_2_1a,1,9) & q_2_1b==12 & q_2_1c==92)
	replace int_month=3 if(inrange(q_2_1a,11,31) & q_2_1b==12 & q_2_1c==92) | (inrange(q_2_1a,1,11) & q_2_1b==1 & q_2_1c==93)
	replace int_month=4 if(inrange(q_2_1a,12,31) & q_2_1b==1 & q_2_1c==93) | (inrange(q_2_1a,1,10) & q_2_1b==2 & q_2_1c==93)
	replace int_month=5 if(inrange(q_2_1a,11,31) & q_2_1b==2 & q_2_1c==93) | (inrange(q_2_1a,1,10) & q_2_1b==3 & q_2_1c==93)
	replace int_month=6 if(inrange(q_2_1a,11,31) & q_2_1b==3 & q_2_1c==93) | (inrange(q_2_1a,1,9) & q_2_1b==4 & q_2_1c==93)
	replace int_month=7 if(inrange(q_2_1a,10,31) & q_2_1b==4 & q_2_1c==93) | (inrange(q_2_1a,1,9) & q_2_1b==5 & q_2_1c==93)
	replace int_month=8 if(inrange(q_2_1a,10,31) & q_2_1b==5 & q_2_1c==93) | (inrange(q_2_1a,1,9) & q_2_1b==6 & q_2_1c==93)
	replace int_month=9 if(inrange(q_2_1a,10,31) & q_2_1b==6 & q_2_1c==93) | (inrange(q_2_1a,1,8) & q_2_1b==7 & q_2_1c==93)
	replace int_month=10 if(inrange(q_2_1a,9,31) & q_2_1b==7 & q_2_1c==93) | (inrange(q_2_1a,1,9) & q_2_1b==8 & q_2_1c==93)
	replace int_month=11 if(inrange(q_2_1a,10,31) & q_2_1b==8 & q_2_1c==93) | (inrange(q_2_1a,1,9) & q_2_1b==9 & q_2_1c==93)
	replace int_month=12 if(inrange(q_2_1a,10,31) & q_2_1b==9 & q_2_1c==93) | (inrange(q_2_1a,1,10) & q_2_1b==10 & q_2_1c==93)
	replace int_month=1 if(inrange(q_2_1a,11,31) & q_2_1b==10 & q_2_1c==93) | (inrange(q_2_1a,1,11) & q_2_1b==11 & q_2_1c==93)
	label value int_month lblint_month
	label var int_month "Month of the interview"
	label define lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December", replace
	label values int_month lblint_month
*</_int_month_>


*<_hhid_>
	gen str16 hhid=hh_id
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	gen str18 pid = ind_id
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
	gen double weight=ind_weight
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
	gen psu=q_1_3
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = .
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	gen strata=q_1_1
	replace strata=35 if q_1_5==3
	label var strata "Strata"
*</_strata_>


*<_wave_>
	gen wave = .
	label var wave "Survey wave"
*</_wave_>


*<_panel_>
	gen strL panel = ""
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
	gen byte urban=q_1_5
	recode urban 2=0 3=.
	label var urban "Location is urban"
	label define lblurban 1 "Urban" 0 "Rural", replace
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
	gen str30 subnatid1 = ""
	replace subnatid1 = "1 - Kabul" if q_1_1 == 1
	replace subnatid1 = "2 - Kapisa" if q_1_1 == 2
	replace subnatid1 = "3 - Parwan" if q_1_1 == 3
	replace subnatid1 = "4 - Wardak" if q_1_1 == 4
	replace subnatid1 = "5 - Logar" if q_1_1 == 5
	replace subnatid1 = "6 - Nangarhar" if q_1_1 == 6
	replace subnatid1 = "7 - Laghman" if q_1_1 == 7
	replace subnatid1 = "8 - Panjsher" if q_1_1 == 8
	replace subnatid1 = "9 - Baghlan" if q_1_1 == 9
	replace subnatid1 = "10 - Bamyan" if q_1_1 == 10
	replace subnatid1 = "11 - Ghazni" if q_1_1 == 11
	replace subnatid1 = "12 - Paktika" if q_1_1 == 12
	replace subnatid1 = "13 - Paktya" if q_1_1 == 13
	replace subnatid1 = "14 - Khost" if q_1_1 == 14
	replace subnatid1 = "15 - Kunarha" if q_1_1 == 15
	replace subnatid1 = "16 - Nooristan" if q_1_1 == 16
	replace subnatid1 = "17 - Badakhshan" if q_1_1 == 17
	replace subnatid1 = "18 - Takhar" if q_1_1 == 18
	replace subnatid1 = "19 - Kunduz" if q_1_1 == 19
	replace subnatid1 = "20 - Samangan" if q_1_1 == 20
	replace subnatid1 = "21 - Balkh" if q_1_1 == 21
	replace subnatid1 = "22 - Sar-e-Pul" if q_1_1 == 22
	replace subnatid1 = "23 - Ghor" if q_1_1 == 23
	replace subnatid1 = "24 - Daykundi" if q_1_1 == 24
	replace subnatid1 = "25 - Urozgan" if q_1_1 == 25
	replace subnatid1 = "26 - Zabul" if q_1_1 == 26
	replace subnatid1 = "27 - Kandahar" if q_1_1 == 27
	replace subnatid1 = "28 - Jawzjan" if q_1_1 == 28
	replace subnatid1 = "29 - Faryab" if q_1_1 == 29
	replace subnatid1 = "30 - Helmand" if q_1_1 == 30
	replace subnatid1 = "31 - Badghis" if q_1_1 == 31
	replace subnatid1 = "32 - Herat" if q_1_1 == 32
	replace subnatid1 = "33 - Farah" if q_1_1 == 33
	replace subnatid1 = "34 - Nimroz" if q_1_1 == 34
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	tostring q_1_2, gen(subnatid2)
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	gen strL subnatid3 = ""
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
/* <_subnatidsurvey_note>

	Variable denoting lowest administrative info to which the survey is still representative.
	See entry in GLD Guidelines (https://github.com/worldbank/gld/blob/main/Support/A%20-%20Guides%20and%20Documentation/GLD_1.0_Guidelines.docx) for more details

</_subnatidsurvey_note> */
	gen strL subnatidsurvey = ""
	replace subnatidsurvey = "Urban" if q_1_5 == 1
	replace subnatidsurvey = "Rural" if q_1_5 == 2
	replace subnatidsurvey = "Kuchi" if q_1_5 == 3
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
	gen hsize = hh_size
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	capture drop age
	gen byte age=q_3_4
	replace age=98 if age>98 & age!=.
	label var age "Individual age"
*</_age_>


*<_male_>
	gen byte male=q_3_5
	recode male 2=0
	label var male "Sex - Ind is male"
	label define lblmale 1 "Male" 0 "Female", replace
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen byte relationharm=q_3_3
	recode relationharm 6=4 4 5 7/10=5 11=6
	label var relationharm "Relationship to the head of household - Harmonized"
	label define lblrelationharm 1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives", replace
	label values relationharm lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = q_3_3
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital=q_3_6

** MARITAL STATUS
	recode marital 5=2 4=3 3=4 2=5
	label var marital "Marital status"
	label define lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed", replace
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	gen eye_dsablty = .
	label define dsablty 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all", replace
	label values eye_dsablty dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty = .
	label define dsablty 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all", replace
	label values hear_dsablty dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty = .
	label define dsablty 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all", replace
	label values walk_dsablty dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord = .
	label define dsablty 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all", replace
	label values conc_dsord dsablty
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty = .
	label define dsablty 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all", replace
	label values slfcre_dsablty dsablty
	label var slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty = .
	label define dsablty 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all", replace
	label values comm_dsablty dsablty
	label var comm_dsablty "Disability related to communicating"
*</_comm_dsablty_>

}


/*%%=============================================================================================
	5: Migration
==============================================================================================%%*/


{

*<_migrated_mod_age_>
	gen migrated_mod_age = 2
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time = 2
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen migrated_binary = 0 if age >= migrated_mod_age & !missing(age)
	replace migrated_binary = 1 if q_12_4 != q_1_1 & !missing(q_12_4) & age >= migrated_mod_age
	replace migrated_binary = 1 if q_12_4 > 34 & !missing(q_12_4) & age >= migrated_mod_age
	label define lblmigrated_binary 0 "No" 1 "Yes", replace
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
	replace migrated_from_urban = 0 if q_12_6 == 1 & migrated_binary == 1
	replace migrated_from_urban = 1 if q_12_6 == 2 & migrated_binary == 1
	replace migrated_from_urban = . if migrated_binary != 1
	label define lblmigrated_from_urban 0 "Rural" 1 "Urban", replace
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen migrated_from_cat = .
	replace migrated_from_cat = 4 if inrange(q_12_4,1,34) & q_12_4 != q_1_1 & migrated_binary == 1
	replace migrated_from_cat = 5 if q_12_4 > 34 & migrated_binary == 1
	replace migrated_from_cat = . if migrated_binary != 1
	label define lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country" 6 "Within country, admin unknown" 7 "Wholly unknown", replace
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen strL migrated_from_code = ""
	replace migrated_from_code = string(q_12_4) if inrange(q_12_4,1,34) & migrated_binary == 1
	replace migrated_from_code = "" if migrated_binary != 1
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen strL migrated_from_country = ""
	replace migrated_from_country = "" if migrated_binary != 1
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason = .
	replace migrated_reason = 1 if inlist(q_12_8,1,3,7) & migrated_binary == 1
	replace migrated_reason = 2 if q_12_8 == 8 & migrated_binary == 1
	replace migrated_reason = 3 if q_12_8 == 2 & migrated_binary == 1
	replace migrated_reason = 4 if inlist(q_12_8,4,5,6,10) & migrated_binary == 1
	replace migrated_reason = 5 if inlist(q_12_8,9,11) & migrated_binary == 1
	replace migrated_reason = . if migrated_binary != 1
	label define lblmigrated_reason 1 "Family reasons" 2 "Educational reasons" 3 "Employment" 4 "Forced (political reasons, natural disaster, ...)" 5 "Other reasons", replace
	label values migrated_reason lblmigrated_reason
	label var migrated_reason "Reason for migrating"
*</_migrated_reason_>


}


/*%%=============================================================================================
	6: Education
==============================================================================================%%*/


{

*<_ed_mod_age_>
	gen byte ed_mod_age=6
label var ed_mod_age "Education module application age"
*</_ed_mod_age_>

*<_school_>
	gen byte school=q_10_7
	recode school 2=0 .a=.
	replace school=. if age<ed_mod_age & age!=.
	label var school "Attending school"
	label define lblschool 0 "No" 1 "Yes", replace
	label values school lblschool
*</_school_>


*<_literacy_>
	gen byte literacy=q_10_2
	recode literacy 2=0 .a=.
	replace literacy=. if age<ed_mod_age & age!=.
	label var literacy "Individual can read & write"
	label define lblliteracy 0 "No" 1 "Yes", replace
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen byte educy=q_10_6
	replace educy=. if age<ed_mod_age | educy==.a
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
/* <_educat7_note>

	The questionnaire uses `q_10_5` to identify the schooling track and `q_10_6`
	to record the highest completed grade within that track. The cross-tab pattern
	shows clear grade bounds by track:
	- primary: grades 0-6
	- lower secondary: grades 6-9
	- upper secondary: grades 9-12
	- teacher college: grades 12-14
	- university / technical college: grades 12-16
	- post-graduate: grades 16-19
	- Islamic school: grades 0-14

	`educat7` is therefore coded from `q_10_5` and `q_10_6` jointly. The track
	identifies the educational stream, while the completed grade determines whether
	the respondent has not completed any grade, has completed the terminal grade of
	a lower level, or has progressed into the next level. Cases with `q_10_6==0`
	are treated as no education / no completed grade. Question 10.5 code 7 is
	Islamic school. This affects 265 cases. Since the Islamic-school track follows
	its own 0-14 grade ladder, those observations are placed on the GLD ladder by
	completed grade rather than left as a survey-specific residual category. In the
	final harmonized file, 63 individuals above `ed_mod_age` remain missing on
	`educat7` because the raw education record is incomplete, usually with both
	`q_10_5` and `q_10_6` missing despite reported school attendance.

</_educat7_note> */
	gen byte educat7=1 if q_10_4==2
	replace educat7=1 if q_10_4==1 & q_10_6==0
	replace educat7=2 if q_10_5==1 & inrange(q_10_6,1,5)
	replace educat7=3 if q_10_5==7 & q_10_6==6
	replace educat7=3 if inlist(q_10_5,1,2) & q_10_6==6
	replace educat7=4 if q_10_5==2 & inrange(q_10_6,7,9)
	replace educat7=4 if q_10_5==3 & q_10_6==9
	replace educat7=5 if q_10_5==3 & inrange(q_10_6,10,12)
	replace educat7=5 if inlist(q_10_5,4,5) & q_10_6==12
	replace educat7=6 if inlist(q_10_5,4,5) & inrange(q_10_6,13,14)
	replace educat7=7 if inlist(q_10_5,5,6) & inrange(q_10_6,15,19)
	replace educat7=1 if q_10_5==7 & q_10_6==0
	replace educat7=2 if q_10_5==7 & inrange(q_10_6,1,5)
	replace educat7=4 if q_10_5==7 & inrange(q_10_6,7,9)
	replace educat7=5 if q_10_5==7 & inrange(q_10_6,10,12)
	replace educat7=6 if q_10_5==7 & inrange(q_10_6,13,14)
	replace educat7=. if age<ed_mod_age & age!=.
	label var educat7 "Level of education 1"
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete", replace
	label values educat7 lbleducat7
*</_educat7_>


*<_educat5_>
	gen educat5 = educat7
	recode educat5 (4 = 3) (5 = 4) (6 7 = 5)
	label var educat5 "Level of education 2"
	label define lbleducat5 1 "No education" 2 "Primary incomplete" 3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary", replace
	label values educat5 lbleducat5
*</_educat5_>


*<_educat4_>
	gen educat4 = educat7
	recode educat4 (2 3 4 = 2) (5 = 3) (6 7 = 4)
	label var educat4 "Level of education 3"
	label define lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary", replace
	label values educat4 lbleducat4
*</_educat4_>


*<_educat_orig_>
	gen educat_orig = .
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
/* <_educat_isced_note>

	The questionnaire uses survey-specific schooling tracks, including Islamic
	school, but the available documentation does not identify a defensible ISCED
	version or provide a direct ISCED crosswalk. For this reason, `educat_isced`
	is left missing in the GLD harmonization.

</_educat_isced_note> */
	gen educat_isced = .
	label var educat_isced "ISCED standardised level of education"
*</_educat_isced_>


*----------6.1: Education cleanup------------------------------*

*<_% Correction min age_>

local ed_vars "school literacy educy educat7 educat5 educat4 educat_orig educat_isced"

foreach ed_var of local ed_vars {
	capture confirm numeric variable `ed_var'
	if _rc == 0 {
		replace `ed_var' = . if age < ed_mod_age & !missing(age)
	}
	else {
		replace `ed_var' = "" if age < ed_mod_age & !missing(age)
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
	label define lblvocational 0 "No" 1 "Yes", replace
	label values vocational lblvocational
	label var vocational "Ever received vocational training"
*</_vocational_>


*<_vocational_type_>
	gen vocational_type = .
	label define lblvocational_type 1 "Inside Enterprise" 2 "External", replace
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
	gen strL vocational_field_orig = ""
	label var vocational_field_orig "Original field of training information"
*</_vocational_field_orig_>


*<_vocational_financed_>
	gen vocational_financed = .
	label define lblvocational_financed 1 "Employer" 2 "Government" 3 "Mixed Employer/Government" 4 "Own funds" 5 "Other", replace
	label values vocational_financed lblvocational_financed
	label var vocational_financed "How training was financed"
*</_vocational_financed_>

}


/*%%=============================================================================================
	8: Labour
==============================================================================================%%*/


*<_minlaborage_>
	gen byte minlaborage=14
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
/* <_lstatus_note>

	Employed:
	- worked for a business, organization, or other person in the last 7 days
	- did farm or livestock work in the last 7 days
	- did own-account or household business work in the last 7 days
	- produced durable goods for household use in the last 7 days
	- was temporarily absent from a job but reported work to return to

	Job attachment:
	- the survey uses a direct temporary-absence question as the attachment test
	- if the person reports being only temporarily absent from work, the questionnaire
	  routes that person directly to the main-job section and treats them as employed
	- if the person does not report temporary absence, the questionnaire routes them
	  to the later availability and job-search questions
	- no separate duration, continued-pay, or return-date test is observed in this
	  questionnaire, so job attachment is taken from the survey's own routing logic

	Unemployed:
	- not employed
	- available for work
	- looked for work or had already found work to start later

	Non-labour force:
	- everyone else age 14+

	The labour screening questions do not distinguish farm output for sale from
	farm output for own consumption, so farm and livestock activity reported in
	the main work screens is treated as employment under the survey's broader work
	concept.

</_lstatus_note> */
	gen byte lstatus = .
	replace lstatus = 1 if inlist(1,q_11_6,q_11_7,q_11_8)
	replace lstatus = 2 if missing(lstatus) & q_11_10 == 1 & q_11_11 == 1
	replace lstatus = 2 if missing(lstatus) & q_11_10 == 1 & q_11_12 == 8
	replace lstatus = 3 if missing(lstatus)
	replace lstatus=. if age<minlaborage & age!=.
	label var lstatus "Labor status"
	label define lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF", replace
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen potential_lf = 0 if lstatus == 3
	replace potential_lf = 1 if q_11_10 == 1 & q_11_11 != 1 & q_11_12 != 8 & lstatus == 3
	replace potential_lf = 1 if q_11_10 != 1 & (q_11_11 == 1 | q_11_12 == 8) & lstatus == 3
	replace potential_lf = . if age < minlaborage & !missing(age)
	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labour force status"
	label define lblpotential_lf 0 "No" 1 "Yes", replace
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen underemployment = 0 if lstatus == 1
	replace underemployment = 1 if q_11_27 == 1 & q_11_28 == 1 & lstatus == 1
	replace underemployment = . if age < minlaborage & !missing(age)
	replace underemployment = . if lstatus != 1
	label var underemployment "Underemployment status"
	label define lblunderemployment 0 "No" 1 "Yes", replace
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
/* <_nlfreason_note>

	`nlfreason` is based on the survey question on the main reason for not looking
	for work because no separate question on why the person was not available is
	observed here. Among people coded as non-labour-force, 350 cases remain
	missing on `nlfreason`, which is kept as reported rather than filled from a
	constructed rule.

</_nlfreason_note> */
	gen byte nlfreason=q_11_12
	recode nlfreason 5=4 6/14=5 .a=.
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	label define lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other", replace
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l=.
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=.
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte empstat=q_11_13
	recode empstat 1/3=1 6=2 5=3 .a=.
	replace empstat=. if lstatus!=1
	label var empstat "Employment status during past week primary job 7 day recall"
	label define lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status", replace
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec=q_11_13
	recode ocusec 3=1 1 2 4/6=2 .a=.
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity primary job 7 day recall"
	label define lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish", replace
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig=q_11_19
	replace industry_orig=. if lstatus!=1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
/* <_industrycat_isic_note>

	The first two digits of the 2013 LCS industry classification align with
	ISIC Revision 2. The detailed raw codes are grouped survey categories rather
	than exact 4-digit ISIC records, so `industrycat_isic` is coded from the
	2-digit group and stored as the 4-digit string `XX00`.

</_industrycat_isic_note> */
	gen str4 industrycat_isic = string(q_11_19_a) + "00" if !missing(q_11_19_a)
	replace industrycat_isic = "" if lstatus != 1
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen byte industrycat10=q_11_19_b
	replace industrycat10=. if lstatus!=1 | industrycat10==.a
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	label define lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified", replace
	label values industrycat10 lblindustrycat10
*</_industrycat10_>


*<_industrycat4_>
	gen industrycat4 = industrycat10
	recode industrycat4 (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	replace industrycat4 = . if lstatus != 1
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	label define lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other", replace
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
	gen occup_orig=q_11_20
	replace occup_orig=. if lstatus!=1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
/* <_occup_isco_note>

	The raw occupation variable is a grouped ISCO-08 code stored numerically.
	`occup_isco` is therefore built as a 4-digit string by zero-padding the
	3-digit grouped code and appending a trailing `0`. Armed-forces extensions
	981-983 affect 392 cases and are left missing in `occup_isco` because the
	survey does not provide a defensible standard detailed occupation code for
	those observations. Raw code 119 affects 14 cases and is collapsed to 1100 to
	retain the manager group without keeping the inconsistent detailed code 1190.

</_occup_isco_note> */
	gen str4 occup_isco = string(q_11_20, "%03.0f") + "0" if !missing(q_11_20)
	replace occup_isco = "1100" if q_11_20 == 119
	replace occup_isco = "" if inrange(q_11_20,981,983)
	replace occup_isco = "" if lstatus != 1
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	gen byte occup=q_11_20_b
	replace occup=10 if occup==0
	replace occup=. if lstatus!=1 | occup==.a
	label var occup "1 digit occupational classification, primary job 7 day recall"
	label define lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others", replace
	label values occup lbloccup
*</_occup_>


*<_occup_skill_>
	gen occup_skill = .
	replace occup_skill = 3 if inrange(occup, 1, 3)
	replace occup_skill = 2 if inrange(occup, 4, 8)
	replace occup_skill = 1 if occup == 9
	replace occup_skill = . if lstatus != 1
	label define lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill", replace
	label values occup_skill lblskill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_wage_no_compen_>
	gen wage_no_compen=q_11_14 if q_11_13==1
	replace wage_no_compen=q_11_15 if inlist(q_11_13,2,3)
	replace wage_no_compen=q_11_16 if inlist(q_11_13,4,5)
	replace wage_no_compen=0 if empstat==2
	replace wage_no_compen=. if lstatus!=1
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
	gen byte unitwage=q_11_13

** WAGES TIME UNIT
	recode unitwage 1=1 2 3=5 4 5=5 6=. .a=.
	replace unitwage=. if lstatus!=1
	label var unitwage "Last wages' time unit primary job 7 day recall"
	label define lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other", replace
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
/* <_whours_note>

	The questionnaire records actual days worked last week multiplied by actual
	average hours per day. A value of 91 occurs in 170 cases and is retained as
	reported rather than recoded, because it can arise directly from the survey's
	own hours arithmetic.

</_whours_note> */
	gen whours=q_11_17*q_11_18
	replace whours=. if lstatus!=1
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	gen wmonths = .
	replace wmonths = . if lstatus != 1
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
/* <_wage_total_note>

	Use gross wages when available and net wages only when gross wages are not available.
	This is done to make it easy to compare earnings in formal and informal sectors.

</_wage_total_note> */
	gen wage_total = .
	replace wage_total = . if lstatus != 1
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen byte contract=.
	replace contract=. if lstatus!=1
	label var contract "Employment has contract primary job 7 day recall"
	label define lblcontract 0 "Without contract" 1 "With contract", replace
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte healthins=.
	replace healthins=. if lstatus!=1
	label var healthins "Employment has health insurance primary job 7 day recall"
	label define lblhealthins 0 "Without health insurance" 1 "With health insurance", replace
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen byte socialsec=.
	replace socialsec=. if lstatus!=1
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	label define lblsocialsec 1 "With social security" 0 "Without social security", replace
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen byte union=.
	replace union=. if lstatus!=1
	label var union "Union membership at primary job 7 day recall"
	label define lblunion 0 "Not union member" 1 "Union member", replace
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	gen byte firmsize_l=.
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u=.
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen byte empstat_2=q_11_22
	recode empstat_2 1/3=1 6=2 5=3 .a=.
	replace empstat_2=. if missing(empstat_2)
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen ocusec_2 = .
	replace ocusec_2 = . if lstatus != 1
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2=q_11_25
	replace industry_orig_2=. if missing(empstat_2)
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	gen industrycat_isic_2 = .
	replace industrycat_isic_2 = . if lstatus != 1
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen byte industrycat10_2=floor(q_11_25/100)
	replace industrycat10_2=10 if inrange(q_11_25,920,960)
	replace industrycat10_2=. if missing(empstat_2) | industrycat10_2==.a
	label var industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
	label values industrycat10_2 lblindustrycat10
*</_industrycat10_2_>


*<_industrycat4_2_>
	gen industrycat4_2 = industrycat10_2
	recode industrycat4_2 (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	replace industrycat4_2 = . if lstatus != 1
	label var industrycat4_2 "Broad Economic Activities classification, secondary job 7 day recall"
	label values industrycat4_2 lblindustrycat4
*</_industrycat4_2_>


*<_occup_orig_2_>
	gen occup_orig_2 = .
	replace occup_orig_2 = . if lstatus != 1
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen strL occup_isco_2 = ""
	replace occup_isco_2 = "" if lstatus != 1
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_2_>
	gen byte occup_2=floor(q_11_26/100)
	replace occup_2=10 if inrange(q_11_26,981,983)
	replace occup_2=. if missing(empstat_2) | occup_2==.a
	label var occup_2 "1 digit occupational classification secondary job 7 day recall"
	label values occup_2 lbloccup
*</_occup_2_>


*<_occup_skill_2_>
	gen occup_skill_2 = .
	replace occup_skill_2 = 3 if inrange(occup_2, 1, 3)
	replace occup_skill_2 = 2 if inrange(occup_2, 4, 8)
	replace occup_skill_2 = 1 if occup_2 == 9
	replace occup_skill_2 = . if lstatus != 1
	label define lblskill2 1 "Low skill" 2 "Medium skill" 3 "High skill", replace
	label values occup_skill_2 lblskill2
	label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>


*<_wage_no_compen_2_>
	gen double wage_no_compen_2=.
	replace wage_no_compen_2=. if missing(empstat_2)
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2=.
	replace unitwage_2=. if missing(empstat_2)
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
	gen whours_2 = .
	replace whours_2 = . if lstatus != 1
	label var whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>


*<_wmonths_2_>
	gen wmonths_2 = .
	replace wmonths_2 = . if lstatus != 1
	label var wmonths_2 "Months of work in past 12 months secondary job 7 day recall"
*</_wmonths_2_>


*<_wage_total_2_>
	gen wage_total_2 = .
	replace wage_total_2 = . if lstatus != 1
	label var wage_total_2 "Annualized total wage secondary job 7 day recall"
*</_wage_total_2_>


*<_firmsize_l_2_>
	gen firmsize_l_2 = .
	replace firmsize_l_2 = . if lstatus != 1
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	gen firmsize_u_2 = .
	replace firmsize_u_2 = . if lstatus != 1
	label var firmsize_u_2 "Firm size (upper bracket) secondary job 7 day recall"
*</_firmsize_u_2_>

}

*----------8.4: 7 day reference additional jobs------------------------------*

*<_t_hours_others_>
	gen t_hours_others = .
	replace t_hours_others = . if lstatus != 1
	label var t_hours_others "Annualized hours worked in all but primary and secondary jobs 7 day recall"
*</_t_hours_others_>


*<_t_wage_nocompen_others_>
	gen t_wage_nocompen_others = .
	replace t_wage_nocompen_others = . if lstatus != 1
	label var t_wage_nocompen_others "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_others_>


*<_t_wage_others_>
	gen t_wage_others = .
	replace t_wage_others = . if lstatus != 1
	label var t_wage_others "Annualized wage in all but primary and secondary jobs (12-mon ref period)"
*</_t_wage_others_>


*----------8.5: 7 day reference total summary------------------------------*


*<_t_hours_total_>
	gen t_hours_total = .
	replace t_hours_total = . if lstatus != 1
	label var t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
	gen t_wage_nocompen_total = .
	replace t_wage_nocompen_total = . if lstatus != 1
	label var t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
	gen t_wage_total = .
	replace t_wage_total = . if lstatus != 1
	label var t_wage_total "Annualized total wage for all jobs 7 day recall"
*</_t_wage_total_>


*----------8.6: 12 month reference overall------------------------------*

{

*<_lstatus_year_>
	gen byte lstatus_year=.
	replace lstatus_year=. if age<minlaborage & age!=.
	label var lstatus_year "Labor status during last year"
	label define lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF", replace
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>

*<_potential_lf_year_>
	gen potential_lf_year = .
	replace potential_lf_year = . if age < minlaborage & !missing(age)
	replace potential_lf_year = . if lstatus_year != 3
	label var potential_lf_year "Potential labour force status"
	label define lblpotential_lf_year 0 "No" 1 "Yes", replace
	label values potential_lf_year lblpotential_lf_year
*</_potential_lf_year_>


*<_underemployment_year_>
	gen underemployment_year = .
	replace underemployment_year = . if age < minlaborage & !missing(age)
	replace underemployment_year = . if lstatus_year != 1
	label var underemployment_year "Underemployment status"
	label define lblunderemployment_year 0 "No" 1 "Yes", replace
	label values underemployment_year lblunderemployment_year
*</_underemployment_year_>


*<_nlfreason_year_>
	gen nlfreason_year = .
	replace nlfreason_year = . if lstatus_year != 3
	label var nlfreason_year "Reason not in the labor force"
	label define lblnlfreason_year 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other", replace
	label values nlfreason_year lblnlfreason_year
*</_nlfreason_year_>


*<_unempldur_l_year_>
	gen unempldur_l_year = .
	replace unempldur_l_year = . if lstatus_year != 2
	label var unempldur_l_year "Unemployment duration (months) lower bracket"
*</_unempldur_l_year_>


*<_unempldur_u_year_>
	gen unempldur_u_year = .
	replace unempldur_u_year = . if lstatus_year != 2
	label var unempldur_u_year "Unemployment duration (months) upper bracket"
*</_unempldur_u_year_>

}

*----------8.7: 12 month reference main job------------------------------*

{

*<_empstat_year_>
	gen byte empstat_year=.
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status during past week primary job 12 month recall"
	label define lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status", replace
	label values empstat_year lblempstat_year
*</_empstat_year_>

*<_ocusec_year_>
	gen ocusec_year = .
	replace ocusec_year = . if lstatus_year != 1
	label var ocusec_year "Sector of activity primary job 12 month recall"
	label define lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish", replace
	label values ocusec_year lblocusec_year
*</_ocusec_year_>

*<_industry_orig_year_>
	gen industry_orig_year = .
	replace industry_orig_year = . if lstatus_year != 1
	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	gen industrycat_isic_year = .
	replace industrycat_isic_year = . if lstatus_year != 1

	preserve 
	count
	restore 

	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>

*<_industrycat10_year_>
	gen industrycat10_year = .
	replace industrycat10_year = . if lstatus_year != 1
	label var industrycat10_year "1 digit industry classification, primary job 12 month recall"
	label define lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified", replace
	label values industrycat10_year lblindustrycat10_year
*</_industrycat10_year_>


*<_industrycat4_year_>
	gen industrycat4_year = industrycat10_year
	recode industrycat4_year (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	replace industrycat4_year = . if lstatus_year != 1
	label var industrycat4_year "Broad Economic Activities classification, primary job 12 month recall"
	label define lblindustrycat4_year 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other", replace
	label values industrycat4_year lblindustrycat4_year
*</_industrycat4_year_>


*<_occup_orig_year_>
	gen occup_orig_year = .
	replace occup_orig_year = . if lstatus_year != 1
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	gen strL occup_isco_year = ""
	replace occup_isco_year = "" if lstatus_year != 1

	preserve 
	count
	restore

	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_year_>
	gen occup_year = .
	replace occup_year = . if lstatus_year != 1
	label var occup_year "1 digit occupational classification, primary job 12 month recall"
	label define lbloccup_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others", replace
	label values occup_year lbloccup_year
*</_occup_year_>


*<_occup_skill_year_>
	gen occup_skill_year = .
	replace occup_skill_year = 3 if inrange(occup_year, 1, 3)
	replace occup_skill_year = 2 if inrange(occup_year, 4, 8)
	replace occup_skill_year = 1 if occup_year == 9
	replace occup_skill_year = . if lstatus_year != 1
	label define lblskillyear 1 "Low skill" 2 "Medium skill" 3 "High skill", replace
	label values occup_skill_year lblskillyear
	label var occup_skill_year "Skill based on ISCO standard primary job 12 month recall"
*</_occup_skill_year_>


*<_wage_no_compen_year_>
	gen wage_no_compen_year = .
	replace wage_no_compen_year = . if lstatus_year != 1
	label var wage_no_compen_year "Last wage payment primary job 12 month recall"
*</_wage_no_compen_year_>


*<_unitwage_year_>
	gen unitwage_year = .
	replace unitwage_year = . if lstatus_year != 1
	replace unitwage_year = . if mi(wage_no_compen_year)
	label var unitwage_year "Last wages' time unit primary job 12 month recall"
	label define lblunitwage_year 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other", replace
	label values unitwage_year lblunitwage_year
*</_unitwage_year_>


*<_whours_year_>
	gen whours_year = .
	replace whours_year = . if lstatus_year != 1
	label var whours_year "Hours of work in last week primary job 12 month recall"
*</_whours_year_>


*<_wmonths_year_>
	gen wmonths_year = .
	replace wmonths_year = . if lstatus_year != 1
	label var wmonths_year "Months of work in past 12 months primary job 12 month recall"
*</_wmonths_year_>


*<_wage_total_year_>
	gen wage_total_year = .
	replace wage_total_year = . if lstatus_year != 1
	label var wage_total_year "Annualized total wage primary job 12 month recall"
*</_wage_total_year_>


*<_contract_year_>
	gen contract_year = .
	replace contract_year = . if lstatus_year != 1
	label var contract_year "Employment has contract primary job 12 month recall"
	label define lblcontract_year 0 "Without contract" 1 "With contract", replace
	label values contract_year lblcontract_year
*</_contract_year_>


*<_healthins_year_>
	gen healthins_year = .
	replace healthins_year = . if lstatus_year != 1
	label var healthins_year "Employment has health insurance primary job 12 month recall"
	label define lblhealthins_year 0 "Without health insurance" 1 "With health insurance", replace
	label values healthins_year lblhealthins_year
*</_healthins_year_>


*<_socialsec_year_>
	gen socialsec_year = .
	replace socialsec_year = . if lstatus_year != 1
	label var socialsec_year "Employment has social security insurance primary job 12 month recall"
	label define lblsocialsec_year 1 "With social security" 0 "Without social security", replace
	label values socialsec_year lblsocialsec_year
*</_socialsec_year_>


*<_union_year_>
	gen union_year = .
	replace union_year = . if lstatus_year != 1
	label var union_year "Union membership at primary job 12 month recall"
	label define lblunion_year 0 "Not union member" 1 "Union member", replace
	label values union_year lblunion_year
*</_union_year_>


*<_firmsize_l_year_>
	gen firmsize_l_year = .
	replace firmsize_l_year = . if lstatus_year != 1
	label var firmsize_l_year "Firm size (lower bracket) primary job 12 month recall"
*</_firmsize_l_year_>


*<_firmsize_u_year_>
	gen firmsize_u_year = .
	replace firmsize_u_year = . if lstatus_year != 1
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
	gen ocusec_2_year = .
	replace ocusec_2_year = . if lstatus_year != 1
	label var ocusec_2_year "Sector of activity secondary job 12 month recall"
	label define lblocusec_2_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish", replace
	label values ocusec_2_year lblocusec_2_year
*</_ocusec_2_year_>



*<_industry_orig_2_year_>
	gen industry_orig_2_year = .
	replace industry_orig_2_year = . if lstatus_year != 1
	label var industry_orig_2_year "Original survey industry code, secondary job 12 month recall"
*</_industry_orig_2_year_>



*<_industrycat_isic_2_year_>
	gen industrycat_isic_2_year = .
	replace industrycat_isic_2_year = . if lstatus_year != 1
	label var industrycat_isic_2_year "ISIC code of secondary job 12 month recall"
*</_industrycat_isic_2_year_>


*<_industrycat10_2_year_>
	gen industrycat10_2_year = .
	replace industrycat10_2_year = . if lstatus_year != 1
	label var industrycat10_2_year "1 digit industry classification, secondary job 12 month recall"
	label values industrycat10_2_year lblindustrycat10_year
*</_industrycat10_2_year_>


*<_industrycat4_2_year_>
	gen industrycat4_2_year = industrycat10_2_year
	recode industrycat4_2_year (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	replace industrycat4_2_year = . if lstatus_year != 1
	label var industrycat4_2_year "Broad Economic Activities classification, secondary job 12 month recall"
	label values industrycat4_2_year lblindustrycat4_year
*</_industrycat4_2_year_>


*<_occup_orig_2_year_>
	gen occup_orig_2_year = .
	replace occup_orig_2_year = . if lstatus_year != 1
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
	gen strL occup_isco_2_year = ""
	replace occup_isco_2_year = "" if lstatus_year != 1
	label var occup_isco_2_year "ISCO code of secondary job 12 month recall"
*</_occup_isco_2_year_>


*<_occup_2_year_>
	gen occup_2_year = .
	replace occup_2_year = . if lstatus_year != 1
	label var occup_2_year "1 digit occupational classification, secondary job 12 month recall"
	label values occup_2_year lbloccup_year
*</_occup_2_year_>


*<_occup_skill_2_year_>
	gen occup_skill_2_year = .
	replace occup_skill_2_year = 3 if inrange(occup_2_year, 1, 3)
	replace occup_skill_2_year = 2 if inrange(occup_2_year, 4, 8)
	replace occup_skill_2_year = 1 if occup_2_year == 9
	replace occup_skill_2_year = . if lstatus_year != 1
	label define lblskilly2 1 "Low skill" 2 "Medium skill" 3 "High skill", replace
	label values occup_skill_2_year lblskilly2
	label var occup_skill_2_year "Skill based on ISCO standard secondary job 12 month recall"
*</_occup_skill_2_year_>


*<_wage_no_compen_2_year_>
	gen wage_no_compen_2_year = .
	replace wage_no_compen_2_year = . if lstatus_year != 1
	label var wage_no_compen_2_year "Last wage payment secondary job 12 month recall"
*</_wage_no_compen_2_year_>


*<_unitwage_2_year_>
	gen unitwage_2_year = .
	replace unitwage_2_year = . if lstatus_year != 1
	replace unitwage_2_year = . if mi(wage_no_compen_2_year)
	label var unitwage_2_year "Last wages' time unit secondary job 12 month recall"
	label values unitwage_2_year lblunitwage_year
*</_unitwage_2_year_>


*<_whours_2_year_>
	gen whours_2_year = .
	replace whours_2_year = . if lstatus_year != 1
	label var whours_2_year "Hours of work in last week secondary job 12 month recall"
*</_whours_2_year_>


*<_wmonths_2_year_>
	gen wmonths_2_year = .
	replace wmonths_2_year = . if lstatus_year != 1
	label var wmonths_2_year "Months of work in past 12 months secondary job 12 month recall"
*</_wmonths_2_year_>


*<_wage_total_2_year_>
	gen wage_total_2_year = .
	replace wage_total_2_year = . if lstatus_year != 1
	label var wage_total_2_year "Annualized total wage secondary job 12 month recall"
*</_wage_total_2_year_>

*<_firmsize_l_2_year_>
	gen firmsize_l_2_year = .
	replace firmsize_l_2_year = . if lstatus_year != 1
	label var firmsize_l_2_year "Firm size (lower bracket) secondary job 12 month recall"
*</_firmsize_l_2_year_>


*<_firmsize_u_2_year_>
	gen firmsize_u_2_year = .
	replace firmsize_u_2_year = . if lstatus_year != 1
	label var firmsize_u_2_year "Firm size (upper bracket) secondary job 12 month recall"
*</_firmsize_u_2_year_>

}


*----------8.9: 12 month reference additional jobs------------------------------*


*<_t_hours_others_year_>
	gen t_hours_others_year = .
	replace t_hours_others_year = . if lstatus_year != 1
	label var t_hours_others_year "Annualized hours worked in all but primary and secondary jobs 12 month recall"
*</_t_hours_others_year_>

*<_t_wage_nocompen_others_year_>
	gen t_wage_nocompen_others_year = .
	replace t_wage_nocompen_others_year = . if lstatus_year != 1
	label var t_wage_nocompen_others_year "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_others_year_>

*<_t_wage_others_year_>
	gen t_wage_others_year = .
	replace t_wage_others_year = . if lstatus_year != 1
	label var t_wage_others_year "Annualized wage in all but primary and secondary jobs 12 month recall"
*</_t_wage_others_year_>


*----------8.10: 12 month total summary------------------------------*


*<_t_hours_total_year_>
	gen t_hours_total_year = .
	replace t_hours_total_year = . if lstatus_year != 1
	label var t_hours_total_year "Annualized hours worked in all jobs 12 month recall"
*</_t_hours_total_year_>


*<_t_wage_nocompen_total_year_>
	gen t_wage_nocompen_total_year = .
	replace t_wage_nocompen_total_year = . if lstatus_year != 1
	label var t_wage_nocompen_total_year "Annualized wage in all jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_total_year_>


*<_t_wage_total_year_>
	gen t_wage_total_year = .
	replace t_wage_total_year = . if lstatus_year != 1
	label var t_wage_total_year "Annualized total wage for all jobs 12 month recall"
*</_t_wage_total_year_>


*----------8.11: Overall across reference periods------------------------------*


*<_njobs_>
	gen njobs = .
	replace njobs = . if lstatus_year != 1
	label var njobs "Total number of jobs"
*</_njobs_>


*<_t_hours_annual_>
	gen t_hours_annual = .
	replace t_hours_annual = . if lstatus_year != 1
	label var t_hours_annual "Total hours worked in all jobs in the previous 12 months"
*</_t_hours_annual_>


*<_linc_nc_>
	gen linc_nc = .
	replace linc_nc = . if lstatus_year != 1
	label var linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."
*</_linc_nc_>


*<_laborincome_>
	gen laborincome = t_wage_total_year
	replace laborincome = . if lstatus_year != 1
	label var laborincome "Total annual individual labor income in all jobs, incl. bonuses, etc."
*</_laborincome_>


*----------8.13: Labour cleanup------------------------------*

{
*<_% Correction min age_>

	local lab_vars "minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome"

	foreach lab_var of local lab_vars {
		capture confirm numeric variable `lab_var'
		if _rc == 0 {
			replace `lab_var' = . if age < minlaborage & !missing(age)
		}
		else {
			replace `lab_var' = "" if age < minlaborage & !missing(age)
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

	label dir
	local all_lab `r(names)'

	local used_lab
	ds, has(vallabel)

	local labelled_vars `r(varlist)'

	foreach varName of local labelled_vars {
		local y : value label `varName'
		local used_lab `"`used_lab' `y'"'
	}

	local notused 		: list all_lab - used_lab
	local notused_len 	: list sizeof notused

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
