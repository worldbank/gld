/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				AFG_2019_IELFS_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata 18 </_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2026-03-23 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						AFG </_Country_>
<_Survey Title_>				Income, Expenditure and Labour Force Survey (IELFS) 2019-20 </_Survey Title_>
<_Survey Year_>					2019 </_Survey Year_>
<_Study ID_>					 </_Study ID_>
<_Data collection from_>		01/2019 </_Data collection from_>
<_Data collection to_>			12/2020 </_Data collection to_>
<_Source of dataset_> 			National Statistics and Information Authority (NSIA), Afghanistan </_Source of dataset_>
<_Sample size (HH)_> 			18,344 </_Sample size (HH)_>
<_Sample size (IND)_> 			136,848 </_Sample size (IND)_>
<_Sampling method_> 			Two-stage sampling design </_Sampling method_>
<_Geographic coverage_> 		National </_Geographic coverage_>
<_Currency_> 					Afghan afghani (AFN) </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS-19 </_ICLS Version_>
<_ISCED Version_>				Not identified from the available documentation </_ISCED Version_>
<_ISCO Version_>				ISCO-08 grouped survey coding </_ISCO Version_>
<_OCCUP National_>				[National occupation classification] </_OCCUP National_>
<_ISIC Version_>				ISIC Rev. 4 grouped survey coding </_ISIC Version_>
<_INDUS National_>				[National industry classification] </_INDUS National_>

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
set varabbrev off

*----------1.2: Set directories------------------------------*

local server  "/Users/angelosantos/Downloads"
local country  "AFG"
local year  "2019"
local survey  "IELFS"
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
	use "`path_in_stata'/roster_male.dta", clear
	merge 1:1 HH_ID Mem_ID using "`path_in_stata'/labour_male.dta", nogen
	merge 1:1 HH_ID Mem_ID using "`path_in_stata'/disability.dta", nogen
	gen strL HH_ID_orig = HH_ID
	destring HH_ID, replace
	merge m:1 HH_ID using "`path_in_stata'/clusters.dta", nogen


/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode="AFG"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen strL survname = "IELFS"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen strL survey = "LFS"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	gen strL icls_v = "ICLS-19"
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
	gen int year=2019
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
	gen int int_year = yy + 1921 if !missing(yy)
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen int_month = mm
	label define lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December", replace
	label values int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
	gen strL hhid = HH_ID_orig
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	gen strL pid = Mem_ID
	isid pid
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
	gen double weight = ind_weight
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
	gen psu = cluster_code
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
	gen byte urban = q15
	recode urban 2=0 3=.
	label var urban "Location is urban"
	label define lblurban 1 "Urban" 0 "Rural", replace
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
	decode province, gen(subnatid1_name)
	tostring province, gen(subnatid1_code)
	gen strL subnatid1 = subnatid1_code + " - " + subnatid1_name
	drop subnatid1_name subnatid1_code
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	gen strL subnatid2 = district_code
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
	replace subnatidsurvey = "Urban" if q15 == 1
	replace subnatidsurvey = "Rural" if q15 == 2
	replace subnatidsurvey = "Kuchi" if q15 == 3
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
	gen byte hsize = hhsize
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen byte age=q202
	replace age=98 if age>=99
	label var age "Individual age"
*</_age_>


*<_male_>
	gen byte male = q203
	recode male 2=0
	label var male "Sex - Ind is male"
	label define lblmale 1 "Male" 0 "Female", replace
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen byte relationharm = .
	replace relationharm = 1 if q201r == 1
	replace relationharm = 2 if q201r == 2
	replace relationharm = 3 if q201r == 3
	replace relationharm = 4 if q201r == 6
	replace relationharm = 5 if inlist(q201r,4,5,7,8,9,10)
	replace relationharm = 6 if q201r == 11
	label var relationharm "Relationship to the head of household - Harmonized"
	label define lblrelationharm 1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives", replace
	label values relationharm lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = q201r
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital = .
	replace marital = 1 if q204 == 1
	replace marital = 2 if inlist(q204,4,5)
	replace marital = 4 if q204 == 2
	replace marital = 5 if q204 == 3
	label var marital "Marital status"
	label define lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed", replace
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	gen eye_dsablty = q2207
	recode eye_dsablty 5=.
	label define dsablty 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all", replace
	label values eye_dsablty dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty = q2209
	recode hear_dsablty 5=.
	label define dsablty 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all", replace
	label values hear_dsablty dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty = q2211
	recode walk_dsablty 5=.
	label define dsablty 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all", replace
	label values walk_dsablty dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord = q2215
	recode conc_dsord 5=.
	label define dsablty 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all", replace
	label values conc_dsord dsablty
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty = q2213
	recode slfcre_dsablty 5=.
	label define dsablty 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all", replace
	label values slfcre_dsablty dsablty
	label var slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty = q2217
	recode comm_dsablty 5=.
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
	gen migrated_mod_age = .
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time = .
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen migrated_binary = .
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
	replace migrated_from_urban = . if migrated_binary != 1
	label define lblmigrated_from_urban 0 "Rural" 1 "Urban", replace
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen migrated_from_cat = .
	replace migrated_from_cat = . if migrated_binary != 1
	label define lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country" 6 "Within country, admin unknown" 7 "Wholly unknown", replace
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen strL migrated_from_code = ""
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
	gen byte school=q217
	recode school 2=0
	label var school "Attending school"
	label define lblschool 0 "No" 1 "Yes", replace
	label values school lblschool
*</_school_>


*<_literacy_>
	gen byte literacy=q213
	recode literacy 2=0
	label var literacy "Individual can read & write"
	label define lblliteracy 0 "No" 1 "Yes", replace
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen byte educy=q215g
	replace educy=0 if q214==2
	replace educy=. if age<ed_mod_age
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
/* <_educat7_note>

	Question 2.15 code 8 is Islamic school. The questionnaire records completed
	grade for that track, so Islamic schooling is mapped by grade into the GLD
	education ladder rather than left in a survey-specific residual category.

</_educat7_note> */
	gen byte educat7=educy
	recode educat7 0=1 1/5=2 6=3 7/11=4 12=5 13/19=7
	replace educat7=6 if inlist(q215e,4,5)
	replace educat7=7 if inlist(q215e,6,7)
	replace educat7=2 if q215e==8 & inrange(q215g,0,8)
	replace educat7=3 if q215e==8 & q215g==9
	replace educat7=4 if q215e==8 & inrange(q215g,10,11)
	replace educat7=5 if q215e==8 & q215g==12
	replace educat7=6 if q215e==8 & inrange(q215g,13,14)
	replace educat7=. if q214==2 & educy!=0
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

	The labour module does not distinguish farm output for sale from farm output for
	own consumption in the main 7-day work screens, so reported farm and livestock
	activity is treated as employment under the survey's work concept.

	Temporary absence is treated as job attachment because the questionnaire uses a
	direct temporary-absence screen and does not show a separate duration, return-date,
	or continued-pay test before returning respondents to the current-job section.

</_lstatus_note> */
	gen byte lstatus = .

	***************************
	* Define those employed
	***************************

	* E1 - Worked in the past 7 days in wage work, own-account work, family work,
	* agricultural work, or another activity captured directly in the work screens.
	* We code these cases as employed because the questionnaire keeps them in the
	* current-work branch. This captures 25,928 cases.
	replace lstatus = 1 if inlist(1,q304,q305,q306,q307,q309)

	* E2 - Did not work in the past 7 days but reported being temporarily absent
	* from a job or activity. We treat these cases as employed because the survey
	* uses direct temporary absence as the job-attachment test. This captures 39 cases.
	replace lstatus = 1 if q310 == 1 & missing(lstatus)

	***************************
	* Define those unemployed
	***************************

	* U1 - Not employed, available for work, and looked for work in the last four
	* weeks. We code these cases as unemployed because the survey observes both
	* search and availability. This captures 1,242 cases.
	replace lstatus = 2 if missing(lstatus) & q312 == 1 & q313 == 1

	* U2 - Not employed, available for work, and not looking because a future job
	* had already been found. We code these future starters as unemployed because
	* the survey still observes current availability. This captures 2,017 cases.
	replace lstatus = 2 if missing(lstatus) & q312 == 1 & q314 == 8

	***************************
	* Define those not in the LF
	***************************

	* N1 - Everyone else age 14+ who is neither employed nor unemployed. This is
	* the residual non-labour-force branch after applying work, temporary absence,
	* search, and availability. This captures 43,039 cases.
	replace lstatus = 3 if missing(lstatus)

	* Respondents below the labour-module age are left missing because the labour
	* questions apply only to persons age 14 and older. This affects 64,583 cases.
	replace lstatus = . if age<minlaborage & age!=.
	label var lstatus "Labor status"
	label define lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF", replace
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen potential_lf = 0 if lstatus == 3
	replace potential_lf = 1 if lstatus == 3 & q312 == 1 & q313 != 1 & q314 != 8
	replace potential_lf = 1 if lstatus == 3 & q312 != 1 & (q313 == 1 | q314 == 8)
	replace potential_lf = . if age < minlaborage & !missing(age)
	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labour force status"
	label define lblpotential_lf 0 "No" 1 "Yes", replace
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen underemployment = 0 if lstatus == 1
	replace underemployment = 1 if lstatus == 1 & q321 == 1 & q322 == 1
	replace underemployment = . if age < minlaborage & !missing(age)
	replace underemployment = . if lstatus != 1
	label var underemployment "Underemployment status"
	label define lblunderemployment 0 "No" 1 "Yes", replace
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
/* <_nlfreason_note>

	`nlfreason` should preferably reflect why someone is outside the labour force.
	This survey does not provide a separate reason for not being available, so we use
	the observed reason for not looking for work instead. Non-labour-force cases who
	were looking but not available therefore remain without a separate reason code.

</_nlfreason_note> */
	gen byte nlfreason = q314
	recode nlfreason 4/5=4 6/14=5
	replace nlfreason = . if lstatus != 3
	label var nlfreason "Reason not in the labor force"
	label define lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other", replace
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen empstat=q316
	recode empstat 1/3=1 6=2 5=3 4=4
	replace empstat=. if lstatus!=1
	label var empstat "Employment status during past week primary job 7 day recall"
	label define lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status", replace
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec=q316
	recode ocusec 3=1 1 2 4/6=2
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity primary job 7 day recall"
	label define lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish", replace
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen strL industry_orig = q319
	replace industry_orig = "" if lstatus!=1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
/* <_industrycat_isic_note>

	The raw industry coding is a grouped survey classification rather than an exact
	4-digit standard code. We use ISIC Rev. 4 because the first two digits align
	more cleanly with that version than with the older ISIC families. `industrycat_isic`
	is therefore built from the first two digits and stored as `XX00`. After that
	fallback, 243 employed cases with nonmissing raw industry remain without a
	defensible ISIC Rev. 4 match and are left missing.

</_industrycat_isic_note> */
	gen strL industry_raw_str = strtrim(q319)
	gen str4 industrycat_isic = substr(industry_raw_str,1,2) + "00" if industry_raw_str != ""
	replace industrycat_isic = "" if inlist(industrycat_isic,"8300","3400","4400","5400")
	replace industrycat_isic = "" if lstatus != 1 | industrycat_isic == "000"
	drop industry_raw_str
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen byte industrycat10 = .
	replace industrycat10 = 1 if inrange(real(substr(industrycat_isic,1,2)),1,3)
	replace industrycat10 = 2 if inrange(real(substr(industrycat_isic,1,2)),5,9)
	replace industrycat10 = 3 if inrange(real(substr(industrycat_isic,1,2)),10,33)
	replace industrycat10 = 4 if inrange(real(substr(industrycat_isic,1,2)),35,39)
	replace industrycat10 = 5 if inrange(real(substr(industrycat_isic,1,2)),41,43)
	replace industrycat10 = 6 if inrange(real(substr(industrycat_isic,1,2)),45,47)
	replace industrycat10 = 7 if inrange(real(substr(industrycat_isic,1,2)),49,53)
	replace industrycat10 = 8 if inrange(real(substr(industrycat_isic,1,2)),55,82)
	replace industrycat10 = 9 if real(substr(industrycat_isic,1,2)) == 84
	replace industrycat10 = 10 if inrange(real(substr(industrycat_isic,1,2)),85,99)
	replace industrycat10=. if (lstatus!=1)
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
	gen strL occup_orig=q320
	replace occup_orig="" if lstatus!=1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
/* <_occup_isco_note>

	The raw occupation coding broadly follows ISCO-08, but the survey classification
	is not fully defensible at the detailed 4-digit level. For consistency, all
	nonmissing occupied cases are therefore coded to the first two digits plus `00`
	rather than mixing detailed 4-digit values with fallback values. After that
	uniform fallback, 229 employed cases with nonmissing raw occupation still do not
	have a defensible ISCO-08 match and are left missing. Most of those unresolved
	cases are survey code 999.

</_occup_isco_note> */
	gen strL occup_raw_str = strtrim(q320)
	gen str4 occup_isco = ""
	replace occup_isco = substr(occup_raw_str,1,2) + "00" if occup_raw_str != ""
	replace occup_isco = "" if inlist(occup_isco,"9900","0500","2900","0800","0900","5700","6400","8600")
	replace occup_isco = "" if lstatus != 1
	drop occup_raw_str
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	gen strL occup_raw3 = strtrim(q320)
	gen byte occup=.
	replace occup = 10 if substr(occup_raw3,1,1) == "0"
	replace occup = real(substr(occup_raw3,1,1)) if inrange(real(substr(occup_raw3,1,1)),1,9)
	replace occup = 99 if occup_raw3 == "999"
	replace occup = . if lstatus != 1
	drop occup_raw3
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
/* <_wage_no_compen_note>

	The 7-day labour block records work status, days worked, and hours worked, but
	does not collect a current wage amount for the main job. The earnings questions
	appear only in the retrospective 12-month branch (`q324`-`q334_2`). For this
	reason, the GLD leaves `wage_no_compen` missing for the 7-day recall rather than
	retaining a misleading mix of structural zeroes for unpaid family workers only.

</_wage_no_compen_note> */
	gen double wage_no_compen=.
	replace wage_no_compen=.  if (lstatus!=1)
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
/* <_unitwage_note>

	Because the questionnaire does not collect a current 7-day wage amount for the
	main job, the corresponding wage time unit cannot be identified for the 7-day
	recall either. The retrospective 12-month earnings module is harmonized in the
	`*_year` wage variables instead.

</_unitwage_note> */
	gen byte unitwage=.
	replace unitwage=.  if lstatus!=1
	label var unitwage "Last wages' time unit primary job 7 day recall"
	label define lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other", replace
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours= q317 * q318
	replace whours = . if lstatus != 1
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
	label var contract "Employment has contract primary job 7 day recall"
	label define lblcontract 0 "Without contract" 1 "With contract", replace
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte healthins=.
	label var healthins "Employment has health insurance primary job 7 day recall"
	label define lblhealthins 0 "Without health insurance" 1 "With health insurance", replace
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen byte socialsec=.
	replace socialsec=. if (lstatus!=1)
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	label define lblsocialsec 1 "With social security" 0 "Without social security", replace
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen byte union=.
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
	gen byte empstat_2 = q322b
	recode empstat_2 1/3=1 6=2 5=3 4=4
	replace empstat_2 = . if q322a != 1
	replace empstat_2 = . if lstatus != 1
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen ocusec_2 = q322b
	recode ocusec_2 3=1 1 2 4/6=2
	replace ocusec_2 = . if q322a != 1
	replace ocusec_2 = . if lstatus != 1
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen strL industry_orig_2 = q322e
	replace industry_orig_2 = "" if q322a != 1
	replace industry_orig_2 = "" if lstatus != 1
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
/* <_industrycat_isic_2_note>

	The raw second-job industry coding is a grouped survey classification rather than
	an exact 4-digit standard code. We therefore code `industrycat_isic_2` from the
	first two digits and store it as `XX00`. After that fallback, 9 employed second-job
	cases with nonmissing raw industry do not have a defensible ISIC Rev. 4 match and
	are left missing.

</_industrycat_isic_2_note> */
	gen str4 industrycat_isic_2 = substr(strtrim(q322e),1,2) + "00" if strtrim(q322e) != ""
	replace industrycat_isic_2 = "" if inlist(industrycat_isic_2,"8300","3400")
	replace industrycat_isic_2 = "" if q322a != 1
	replace industrycat_isic_2 = "" if lstatus != 1
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen byte industrycat10_2 = .
	replace industrycat10_2 = 1 if inrange(real(substr(industrycat_isic_2,1,2)),1,3)
	replace industrycat10_2 = 2 if inrange(real(substr(industrycat_isic_2,1,2)),5,9)
	replace industrycat10_2 = 3 if inrange(real(substr(industrycat_isic_2,1,2)),10,33)
	replace industrycat10_2 = 4 if inrange(real(substr(industrycat_isic_2,1,2)),35,39)
	replace industrycat10_2 = 5 if inrange(real(substr(industrycat_isic_2,1,2)),41,43)
	replace industrycat10_2 = 6 if inrange(real(substr(industrycat_isic_2,1,2)),45,47)
	replace industrycat10_2 = 7 if inrange(real(substr(industrycat_isic_2,1,2)),49,53)
	replace industrycat10_2 = 8 if inrange(real(substr(industrycat_isic_2,1,2)),55,82)
	replace industrycat10_2 = 9 if real(substr(industrycat_isic_2,1,2)) == 84
	replace industrycat10_2 = 10 if inrange(real(substr(industrycat_isic_2,1,2)),85,99)
	replace industrycat10_2 = . if q322a != 1
	replace industrycat10_2 = . if lstatus != 1
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
	gen strL occup_orig_2 = q322f
	replace occup_orig_2 = "" if q322a != 1
	replace occup_orig_2 = "" if lstatus != 1
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
/* <_occup_isco_2_note>

	The raw second-job occupation coding broadly follows ISCO-08, but the survey
	classification is not fully defensible at the detailed 4-digit level. For
	consistency, all nonmissing occupied second-job cases are coded to the first
	two digits plus `00`. After that fallback, 38 employed second-job cases with
	nonmissing raw occupation remain unresolved and are left missing. Most of those
	unresolved cases are survey code 999.

</_occup_isco_2_note> */
	gen str4 occup_isco_2 = substr(strtrim(q322f),1,2) + "00" if strtrim(q322f) != ""
	replace occup_isco_2 = "" if inlist(occup_isco_2,"0600","9900")
	replace occup_isco_2 = "" if q322a != 1
	replace occup_isco_2 = "" if lstatus != 1
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_2_>
	gen strL occup_raw3_2 = strtrim(q322f)
	gen byte occup_2 = .
	replace occup_2 = 10 if substr(occup_raw3_2,1,1) == "0"
	replace occup_2 = real(substr(occup_raw3_2,1,1)) if inrange(real(substr(occup_raw3_2,1,1)),1,9)
	replace occup_2 = 99 if occup_raw3_2 == "999"
	replace occup_2 = . if q322a != 1
	replace occup_2 = . if lstatus != 1
	drop occup_raw3_2
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
	gen double wage_no_compen_2 = .
	replace wage_no_compen_2 = 0 if empstat_2 == 2
	replace wage_no_compen_2 = . if q322a != 1
	replace wage_no_compen_2 = . if lstatus != 1
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2=.
	replace unitwage_2=. if missing(empstat_2)
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
	gen whours_2 = q322c * q322d
	replace whours_2 = . if q322a != 1
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
/* <_lstatus_year_note>

	The annual labour module asks whether the respondent did any work in the last
	12 months and then collects retrospective information for day labour, salaried
	work, self-employment, and unpaid family work. The questionnaire does not provide
	an annual search-and-availability branch, so annual unemployment and non-labour-force
	status are not identified separately. Respondents who are currently employed are
	also treated as employed during the last 12 months. Other age-eligible cases are
	left missing rather than being forced into annual unemployment or non-labour-force
	categories.

</_lstatus_year_note> */
	gen byte lstatus_year=.
	replace lstatus_year = 1 if lstatus == 1
	replace lstatus_year = 1 if q315 == 1
	replace lstatus_year = . if age < minlaborage & !missing(age)
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
/* <_empstat_year_note>

	The annual labour questions identify day labour, salaried work, self-employment
	without employees, and unpaid family work over the last 12 months. They do not
	define a unique main annual job across those statuses, so `empstat_year` is coded
	conservatively using the following hierarchy when multiple annual activities are
	reported: salaried or day labour, then self-employment without employees, then
	unpaid family work. No separate annual employer category is observed.

</_empstat_year_note> */
	gen byte empstat_year=.
	replace empstat_year = 1 if q329 == 1 | q324 > 0
	replace empstat_year = 4 if q332 == 1 & missing(empstat_year)
	replace empstat_year = 2 if (q335 == 1 | q336 == 1) & missing(empstat_year)
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
/* <_wage_no_compen_year_note>

	The annual module provides separate earnings questions for day labour, salaried
	work, and self-employment. Because the questionnaire does not define a unique
	main annual job across those categories, `wage_no_compen_year` follows the same
	conservative hierarchy used for `empstat_year`: salaried work first, then
	self-employment, then day labour, and zero for unpaid family work. Salaried
	earnings use basic monthly salary (`q331_1`) rather than total monthly earnings.

</_wage_no_compen_year_note> */
	gen wage_no_compen_year = .
	replace wage_no_compen_year = q331_1 if q329 == 1
	replace wage_no_compen_year = q334_2 if q332 == 1 & missing(wage_no_compen_year)
	replace wage_no_compen_year = q326 if q324 > 0 & missing(wage_no_compen_year)
	replace wage_no_compen_year = 0 if empstat_year == 2 & missing(wage_no_compen_year)
	replace wage_no_compen_year = . if lstatus_year != 1
	label var wage_no_compen_year "Last wage payment primary job 12 month recall"
*</_wage_no_compen_year_>


*<_unitwage_year_>
	gen unitwage_year = .
	replace unitwage_year = 5 if q329 == 1 & !missing(q331_1)
	replace unitwage_year = 1 if q332 == 1 & q334_1 == 1
	replace unitwage_year = 2 if q332 == 1 & q334_1 == 2
	replace unitwage_year = 5 if q332 == 1 & q334_1 == 3
	replace unitwage_year = 1 if q324 > 0 & !missing(q326) & missing(unitwage_year)
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
	replace wmonths_year = q330 if q329 == 1
	replace wmonths_year = q333 if q332 == 1 & missing(wmonths_year)
	replace wmonths_year = q324 if q324 > 0 & missing(wmonths_year)
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
