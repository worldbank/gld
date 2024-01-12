
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>					ZMB_2008_LFS_V01_M_V01_A] </_Program name_>
<_Application_>						[STATA 17] <_Application_>
<_Author(s)_>						World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>					2023-08-16 </_Date created_>

-------------------------------------------------------------------------

<_Country_>							[ZAMBIA (ZMB)] </_Country_>
<_Survey Title_>					[LABOUR FORCE SURVEY] </_Survey Title_>
<_Survey Year_>						[2008] </_Survey Year_>
<_Study ID_>						[N/A] </_Study ID_>
<_Data collection from_>			[11/2008] </_Data collection from_>
<_Data collection to_>				[12/2008] </_Data collection to_>
<_Source of dataset_> 				[Zambia Statistics Office] </_Source of dataset_>
<_Sample size (HH)_> 				[#] </_Sample size (HH)_>
<_Sample size (IND)_> 				[#] </_Sample size (IND)_>
<_Sampling method_> 				[two stage probabilistic, stratified, by enumeration areas] </_Sampling method_>
<_Geographic coverage_> 			[National, urban/rural] </_Geographic coverage_>
<_Currency_> 						[Zambia Kwacha] </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				[ICLS 13] </_ICLS Version_>
<_ISCED Version_>				[] </_ISCED Version_>
<_ISCO Version_>				[ISCO-88] </_ISCO Version_>
<_OCCUP National_>				[N/A] </_OCCUP National_>
<_ISIC Version_>				[ISIC Rev 4] </_ISIC Version_>
<_INDUS National_>				[N/A] </_INDUS National_>

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

*----------1.2: Set directories------------------------------*

* Define path sections
local server  "Y:/GLD-Harmonization/582018_AQ"
local country "ZMB"
local year    "2008"
local survey  "LFS"
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


/* In the case of 2008, the raw data is divided into different files, to match them an ID needs to be created and in some cases we need leading zeros in some ID variables to avoid duplicates. For this reason, the user will notice that the dta files had been modified with identifiers so that the merge process is smooth. Before the start of the harmonization the identifiers are dropped to not interfere with the GLD variables. The process of ID creation can only be done once, please check the programs files for more details on how we created those IDs but bear in mind that they are not native to the raw data.
*/

***merge
use "`path_in_stata'/hh_level_file.dta"

merge 1:m id using "`path_in_stata'/Section_9_Working_Conditions.dta", nogenerate
merge 1:m id using "`path_in_stata'/Section_8_Occupational_Health.dta", nogenerate
merge 1:m id using "`path_in_stata'/Section_7_Skills_Training_01.dta", nogenerate
merge 1:m id using "`path_in_stata'/Section_7_Skills_Training.dta", nogenerate
merge 1:m id using "`path_in_stata'/Section_6_Unemployment.dta", nogenerate
merge 1:m id using "`path_in_stata'/Section_5_Income_Earnings.dta", nogenerate
merge 1:m id using "`path_in_stata'/Section_4_Usual_Employment_2.dta", nogenerate
merge 1:m id using "`path_in_stata'/Section_4_Usual_Employment_1.dta", nogenerate
merge 1:m id using "`path_in_stata'/Section_3_Employment.dta", nogenerate
merge 1:m id using "`path_in_stata'/Section_2_Education_characteristics.dta", nogenerate
merge 1:m id using "`path_in_stata'/Section_1_Demographic_characteristics_02.dta", nogenerate
merge 1:m id using "`path_in_stata'/hh_heads_file.dta", nogenerate
merge 1:m id using "`path_in_stata'/economically_active_inactive.dta", nogenerate

*household level
merge m:1 hhid using "`path_in_stata'/household_size.dta", nogenerate
merge m:1 hhid using "`path_in_stata'/cover_page_1.dta", nogenerate
merge m:1 hhid using "`path_in_stata'/15av02.dta", nogenerate
merge m:1 hhid using "`path_in_stata'/15av.dta", nogenerate

drop hhid id

save "`path_in_stata'/final_2008.dta", replace

/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode = "ZMB"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "LFS"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "labour force survey"
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
	gen isco_version = "isco_1988"
	label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
	gen isic_version = "isic_4"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	gen int year = 2008
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
	gen int_year=.
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen  int_month = .
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
/* <_hhid_note>

	The variable should be a string made up of the elements to define it, that is psu code, ssu, ...
	Each element should always be as long as needed for the longest element. That is, if there are
	60 psu coded 1 through 60, codes should be 01, 02, ..., 60. If there are 160 it should be 001,
	002, ..., 160.

</_hhid_note> */

	tostring const, gen(const_2) force
	gen const_3 = substr(3 * "0", 1, 3 - length( const_2 )) + const_2
	tostring ward, gen(ward_2) force
	gen ward_3 = substr(2 * "0", 1, 2 - length( ward_2 )) + ward_2
	tostring csa, gen(csa_2) force
	gen csa_3 = substr(2 * "0", 1, 2 - length( csa_2 )) + csa_2
	tostring sbn, gen(sbn_2) force
	gen sbn_3 = substr(3 * "0", 1, 3 - length( sbn_2 )) + sbn_2
	tostring hun, gen(hun_2) force
	gen hun_3 = substr(2 * "0", 1, 2 - length( hun_2 )) + hun_2

	egen hhid=concat(prov dist const_3 ward_3 region csa_3 sea sbn_3 hun_3 hhn category)

	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	tostring pn, gen(pn_2) force
	gen pn_3 = substr(3 * "0", 1, 3 - length( pn_2 )) + pn_2
	egen  pid = concat(hhid pn_3)
	label var pid "Individual ID"
	isid pid
	distinct pid hhid
	drop const_3 ward_3 csa_3 sbn_3 hun_3 const_2 ward_2 csa_2 sbn_2 hun_2 pn_2 pn_3
*</_pid_>


*<_weight_>
	*gen weight = weight
	label var weight "Survey sampling weight"
*</_weight_>


*<_psu_>
	gen psu = .
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
	gen byte urban=.
	replace urban=1 if ec_urban==1
	replace urban=0 if ec_rural==1
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
/* <_subnatid1_note>

	The variable is string and country-specific categorical. Numeric entries are coded in string format using the following naming convention: "1 – Hatay". That is, the variable itself is to be string, not a labelled numeric vector.

	Example of entries would be "1 - Alaska",  "2 - Arkansas", ...

</_subnatid1_note> */
	gen str subnatid1 = ""
	replace subnatid1 = " 1 - Central" if prov==1
	replace subnatid1 = " 2 - Copperbelt" if prov==2
	replace subnatid1 = " 3 - Eastern" if prov==3
	replace subnatid1 = " 4 - Luapula" if prov==4
	replace subnatid1 = " 5 - Lusaka" if prov==5
	replace subnatid1 = " 6 - Northern" if prov==6
	replace subnatid1 = " 7 - North Western" if prov==7
	replace subnatid1 = " 8 - Southern" if prov==8
	replace subnatid1 = " 9 - Western" if prov==9
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
/* <_subnatidsurvey_note>

	Variable denoting lowest administrative info to which the survey is still significat.
	See entry in GLD Guidelines (https://github.com/worldbank/gld/blob/main/Support/A%20-%20Guides%20and%20Documentation/GLD_1.0_Guidelines.docx) for more details

</_subnatidsurvey_note> */
	gen urban_1=""
	replace urban_1=" urban" if urban==1
	replace urban_1=" rural" if urban==0
	egen subnatidsurvey=concat(subnatid1 urban_1)
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
	gen hsize = hhsize
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen age = s1q2
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = s1q4
	recode male 2=0
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen relationharm = s1q3
	recode relationharm 4/9=5 10=4 11/15=5 16=6
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = s1q3
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital = s1q5
	recode marital 1=2 2=1 3=4 6=3
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	gen eye_dsablty = .
	replace eye_dsablty=3 if s1q11a==2
	replace eye_dsablty=4 if s1q11a==1
	replace eye_dsablty=3 if s1q11b==2
	replace eye_dsablty=4 if s1q11b==1
	replace eye_dsablty=3 if s1q11c==2
	replace eye_dsablty=4 if s1q11c==1
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
	label values eye_dsablty dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty = .
	replace hear_dsablty=4 if s1q11a==3
	replace hear_dsablty=4 if s1q11b==3
	replace hear_dsablty=4 if s1q11c==3
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values hear_dsablty dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty = .
	replace walk_dsablty=4 if s1q11a==5
	replace walk_dsablty=4 if s1q11b==5
	replace walk_dsablty=4 if s1q11c==5
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values walk_dsablty dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord = .
	replace conc_dsord=3 if s1q11a==6
	replace conc_dsord=3 if s1q11b==6
	replace conc_dsord=3 if s1q11c==6
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
	replace comm_dsablty=3 if s1q11a==4
	replace comm_dsablty=3 if s1q11b==4
	replace comm_dsablty=3 if s1q11c==4
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
	gen migrated_mod_age = .
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time = .
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen migrated_binary = .
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen migrated_years = .
	label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban = .
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen migrated_from_cat = .
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen migrated_from_code = .
	*label de lblmigrated_from_code
	*label values migrated_from_code lblmigrated_from_code
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country = .
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason = .
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

Education module is only asked to those 5 and older.

</_ed_mod_age_note> */

	gen byte ed_mod_age = 5
	label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school=s2q4
	recode school 2=0 5=.
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	rename literacy literacy_1
	gen byte literacy = s2q1
	recode literacy 0=. 2=0
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen byte educy =.
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7 =s2q5
	recode educat7 0=1 1/4=2 5/7=3 8/9=4 10=5 11=6 12/16=7
	label var educat7 "Level of education 1"
	la de lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete"
	label values educat7 lbleducat7
*</_educat7_>


*<_educat5_>
	gen byte educat5 = educat7
	recode educat5 4=3 5=4 6 7=5
	label var educat5 "Level of education 2"
	la de lbleducat5 1 "No education" 2 "Primary incomplete"  3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>


*<_educat4_>
	gen byte educat4 = educat7
	recode educat4 (2 3 4 = 2) (5=3) (6 7=4)
	label var educat4 "Level of education 3"
	la de lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 lbleducat4
*</_educat4_>


*<_educat_orig_>
	gen educat_orig = s2q5
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
	gen educat_isced = .
	label var educat_isced "ISCED standardised level of education"
*</_educat_isced_>


*----------6.1: Education cleanup------------------------------*

*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
local ed_var "school literacy educy educat7 educat5 educat4 educat_orig educat_isced"

foreach v of local ed_var {
	cap confirm numeric variable `v'
	if _rc == 0 { // is indeed numeric
		replace `v'=. if ( age < ed_mod_age & !missing(age) )
	}
	else { // is not
		replace `v'= "" if ( age < ed_mod_age & !missing(age) )
	}
}


*</_% Correction min age_>


}


/*%%=============================================================================================
	7: Training
==============================================================================================%%*/


{

*<_vocational_>
	gen vocational = s7q1
	recode vocational 2=0
	label de lblvocational 0 "No" 1 "Yes"
	label var vocational "Ever received vocational training"
*</_vocational_>

*<_vocational_type_>
	gen vocational_type = s7q2
	recode vocational_type 3=2 4=1
	label de lblvocational_type 1 "Inside Enterprise" 2 "External"
	label values vocational_type lblvocational_type
	label var vocational_type "Type of vocational training"
*</_vocational_type_>

*<_vocational_length_l_>
	gen vocational_length_l = s7q6
	recode vocational_length_l 1=0 2=3 3=6 4=12 5=36
	label var vocational_length_l "Length of training in months, lower limit"
*</_vocational_length_l_>

*<_vocational_length_u_>
	gen vocational_length_u = s7q6
	recode vocational_length_u 1=3 2=5 3=11 4=35 5=.
	label var vocational_length_u "Length of training in months, upper limit"
*</_vocational_length_u_>

*<_vocational_field_orig_>
	tostring s7q7, replace
	gen vocational_field_orig = s7q7
	label var vocational_field_orig "Original field of training information"
*</_vocational_field_orig_>

*<_vocational_financed_>
	gen vocational_financed = s7q4
	recode vocational_financed 2=4 3=5 4=5
	label de lblvocational_financed 1 "Employer" 2 "Government" 3 "Mixed Employer/Government" 4 "Own funds" 5 "Other"
	label var vocational_financed "How training was financed"
*</_vocational_financed_>

}


/*%%=============================================================================================
	8: Labour
==============================================================================================%%*/


*<_minlaborage_>
	gen byte minlaborage =15
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
	
	gen byte lstatus = .
	replace lstatus=1 if s3q8!=. | s4q8!=. | s3q1==2 | s3q1==3 | s3q1==6 | s3q1==1 | s4q1==2 | s4q1==3 | s4q1==6 | s4q1==1
	replace lstatus=2 if s3q1==4 | s4q1==4 | s6q1==1 | s6q3==1 
	replace lstatus=3 if s3q1==5 | inrange(s3q1,7,11) 
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = s6q6
	recode potential_lf 1/2=0 3/5=1
	replace potential_lf = . if age < minlaborage & age != .
	replace potential_lf=0 if potential_lf!=1
	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen byte underemployment = .
	replace underemployment = . if age < minlaborage & age != .
	replace underemployment = . if lstatus != 1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason=.
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l=s6q6
	recode unempldur_l 1=0 2=3 3=6 4=12 5=36
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=s6q6
	recode unempldur_u 1=2 2=5 3=11 4=35 5=.
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte empstat=s3q12
	recode empstat 1=4 2=3 3=1 4=2
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec = s3q11
	recode ocusec 2=1 4=2 5=2 7=2 6=2
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig = s3q9
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	tostring s3q9, gen(s3q9_2) force
	replace s3q9_2="0111" if s3q9_2=="111"
	replace s3q9_2="0112" if s3q9_2=="112"
	replace s3q9_2="0113" if s3q9_2=="113"
	replace s3q9_2="0114" if s3q9_2=="114"
	replace s3q9_2="0115" if s3q9_2=="115"
	replace s3q9_2="0116" if s3q9_2=="116"
	replace s3q9_2="0118" if s3q9_2=="118"
	replace s3q9_2="0119" if s3q9_2=="119"
	replace s3q9_2="1200" if s3q9_2=="120"
	replace s3q9_2="0121" if s3q9_2=="121"
	replace s3q9_2="0122" if s3q9_2=="122"
	replace s3q9_2="0123" if s3q9_2=="123"
	replace s3q9_2="0124" if s3q9_2=="124"
	replace s3q9_2="0125" if s3q9_2=="125"
	replace s3q9_2="0126" if s3q9_2=="126"
	replace s3q9_2="0127" if s3q9_2=="127"
	replace s3q9_2="0128" if s3q9_2=="128"
	replace s3q9_2="0129" if s3q9_2=="129"
	replace s3q9_2="0130" if s3q9_2=="130"
	replace s3q9_2="1300" if s3q9_2=="132"
	replace s3q9_2="1300" if s3q9_2=="133"
	replace s3q9_2="0141" if s3q9_2=="141"
	replace s3q9_2="0142" if s3q9_2=="142"
	replace s3q9_2="0144" if s3q9_2=="144"
	replace s3q9_2="0145" if s3q9_2=="145"
	replace s3q9_2="0146" if s3q9_2=="146"
	replace s3q9_2="0149" if s3q9_2=="149"
	replace s3q9_2="0150" if s3q9_2=="150"
	replace s3q9_2="0150" if s3q9_2=="151"
	replace s3q9_2="0150" if s3q9_2=="152"
	replace s3q9_2="0150" if s3q9_2=="155"
	replace s3q9_2="0150" if s3q9_2=="158"
	replace s3q9_2="0150" if s3q9_2=="159"
	replace s3q9_2="0160" if s3q9_2=="160"
	replace s3q9_2="0161" if s3q9_2=="161"
	replace s3q9_2="0162" if s3q9_2=="162"
	replace s3q9_2="0163" if s3q9_2=="163"
	replace s3q9_2="0164" if s3q9_2=="164"
	replace s3q9_2="0170" if s3q9_2=="170"
	replace s3q9_2="1700" if s3q9_2=="171"
	replace s3q9_2="1700" if s3q9_2=="172"
	replace s3q9_2="1700" if s3q9_2=="173"
	replace s3q9_2="1810" if s3q9_2=="181"
	replace s3q9_2="1820" if s3q9_2=="182"
	replace s3q9_2="1910" if s3q9_2=="191"
	replace s3q9_2="1920" if s3q9_2=="192"
	replace s3q9_2="0200" if s3q9_2=="200"
	replace s3q9_2="0200" if s3q9_2=="201"
	replace s3q9_2="0200" if s3q9_2=="202"
	replace s3q9_2="0210" if s3q9_2=="210"
	replace s3q9_2="0200" if s3q9_2=="211"
	replace s3q9_2="0220" if s3q9_2=="220"
	replace s3q9_2="0200" if s3q9_2=="222"
	replace s3q9_2="0200" if s3q9_2=="229"
	replace s3q9_2="0230" if s3q9_2=="230"
	replace s3q9_2="2300" if s3q9_2=="232"
	replace s3q9_2="0240" if s3q9_2=="240"
	replace s3q9_2="2500" if s3q9_2=="250"
	replace s3q9_2="2590" if s3q9_2=="259"
	replace s3q9_2="2790" if s3q9_2=="279"
	replace s3q9_2="0300" if s3q9_2=="301"
	replace s3q9_2="0310" if s3q9_2=="310"
	replace s3q9_2="0311" if s3q9_2=="311"
	replace s3q9_2="0312" if s3q9_2=="312"
	replace s3q9_2="0321" if s3q9_2=="321"
	replace s3q9_2="0322" if s3q9_2=="322"
	replace s3q9_2="0300" if s3q9_2=="371"
	replace s3q9_2="4100" if s3q9_2=="401"
	replace s3q9_2="4100" if s3q9_2=="411"
	replace s3q9_2="4210" if s3q9_2=="421"
	replace s3q9_2="4710" if s3q9_2=="471"
	replace s3q9_2="4720" if s3q9_2=="472"
	replace s3q9_2="4780" if s3q9_2=="478"
	replace s3q9_2="4790" if s3q9_2=="479"
	replace s3q9_2="4630" if s3q9_2=="481"
	replace s3q9_2="4900" if s3q9_2=="490"
	replace s3q9_2="4920" if s3q9_2=="492"
	replace s3q9_2="5010" if s3q9_2=="501"
	replace s3q9_2="0510" if s3q9_2=="510"
	replace s3q9_2="0520" if s3q9_2=="520"
	replace s3q9_2="5200" if s3q9_2=="522"
	replace s3q9_2="5000" if s3q9_2=="530"
	replace s3q9_2="0562" if s3q9_2=="562"
	replace s3q9_2="5000" if s3q9_2=="571"
	replace s3q9_2="5000" if s3q9_2=="574"
	replace s3q9_2="6010" if s3q9_2=="601"
	replace s3q9_2="0610" if s3q9_2=="610"
	replace s3q9_2="0620" if s3q9_2=="620"
	replace s3q9_2="0620" if s3q9_2=="622"
	replace s3q9_2="6310" if s3q9_2=="631"
	replace s3q9_2="6610" if s3q9_2=="661"
	replace s3q9_2="7000" if s3q9_2=="700"
	replace s3q9_2="7010" if s3q9_2=="701"
	replace s3q9_2="7020" if s3q9_2=="702"
	replace s3q9_2="7000" if s3q9_2=="703"
	replace s3q9_2="0710" if s3q9_2=="710"
	replace s3q9_2="0710" if s3q9_2=="711"
	replace s3q9_2="0720" if s3q9_2=="720"
	replace s3q9_2="0727" if s3q9_2=="727"
	replace s3q9_2="0729" if s3q9_2=="729"
	replace s3q9_2="0700" if s3q9_2=="730"
	replace s3q9_2="7320" if s3q9_2=="732"
	replace s3q9_2="7000" if s3q9_2=="759"
	replace s3q9_2="7720" if s3q9_2=="772"
	replace s3q9_2="7000" if s3q9_2=="780"
	replace s3q9_2="8010" if s3q9_2=="801"
	replace s3q9_2="8020" if s3q9_2=="810"
	replace s3q9_2="8120" if s3q9_2=="812"
	replace s3q9_2="8500" if s3q9_2=="852"
	replace s3q9_2="0893" if s3q9_2=="893"
	replace s3q9_2="0899" if s3q9_2=="899"
	replace s3q9_2="9100" if s3q9_2=="902"
	replace s3q9_2="0910" if s3q9_2=="910"
	replace s3q9_2="9600" if s3q9_2=="911"
	replace s3q9_2="9600" if s3q9_2=="929"
	replace s3q9_2="9600" if s3q9_2=="933"
	replace s3q9_2="9600" if s3q9_2=="969"
	replace s3q9_2="0990" if s3q9_2=="990"
	replace s3q9_2="0100" if s3q9_2=="0118"
	replace s3q9_2="0500" if s3q9_2=="0562"
	replace s3q9_2="0700" if s3q9_2=="0727"
	replace s3q9_2="1000" if s3q9_2=="1001"
	replace s3q9_2="1000" if s3q9_2=="1011"
	replace s3q9_2="1000" if s3q9_2=="1016"
	replace s3q9_2="1000" if s3q9_2=="1017"
	replace s3q9_2="1000" if s3q9_2=="1021"
	replace s3q9_2="1000" if s3q9_2=="1029"
	replace s3q9_2="1000" if s3q9_2=="1051"
	replace s3q9_2="1100" if s3q9_2=="1108"
	replace s3q9_2="1100" if s3q9_2=="1110"
	replace s3q9_2="1100" if s3q9_2=="1111"
	replace s3q9_2="1100" if s3q9_2=="1112"
	replace s3q9_2="1100" if s3q9_2=="1113"
	replace s3q9_2="1100" if s3q9_2=="1115"
	replace s3q9_2="1100" if s3q9_2=="1117"
	replace s3q9_2="1100" if s3q9_2=="1119"
	replace s3q9_2="1100" if s3q9_2=="1132"
	replace s3q9_2="1100" if s3q9_2=="1135"
	replace s3q9_2="1100" if s3q9_2=="1157"
	replace s3q9_2="1200" if s3q9_2=="1221"
	replace s3q9_2="1200" if s3q9_2=="1226"
	replace s3q9_2="1200" if s3q9_2=="1291"
	replace s3q9_2="1200" if s3q9_2=="1295"
	replace s3q9_2="1400" if s3q9_2=="1472"
	replace s3q9_2="1400" if s3q9_2=="1499"
	replace s3q9_2="1500" if s3q9_2=="1501"
	replace s3q9_2="1500" if s3q9_2=="1505"
	replace s3q9_2="1500" if s3q9_2=="1541"
	replace s3q9_2="1600" if s3q9_2=="1624"
	replace s3q9_2="1600" if s3q9_2=="1626"
	replace s3q9_2="1600" if s3q9_2=="1628"
	replace s3q9_2="1600" if s3q9_2=="1642"
	replace s3q9_2="1600" if s3q9_2=="1659"
	replace s3q9_2="1700" if s3q9_2=="1712"
	replace s3q9_2="1700" if s3q9_2=="1749"
	replace s3q9_2="1800" if s3q9_2=="1821"
	replace s3q9_2="2000" if s3q9_2=="2015"
	replace s3q9_2="2000" if s3q9_2=="2032"
	replace s3q9_2="2100" if s3q9_2=="2104"
	replace s3q9_2="2100" if s3q9_2=="2122"
	replace s3q9_2="2100" if s3q9_2=="2131"
	replace s3q9_2="2100" if s3q9_2=="2143"
	replace s3q9_2="2200" if s3q9_2=="2214"
	replace s3q9_2="2200" if s3q9_2=="2224"
	replace s3q9_2="2300" if s3q9_2=="2312"
	replace s3q9_2="2300" if s3q9_2=="2319"
	replace s3q9_2="2300" if s3q9_2=="2321"
	replace s3q9_2="2300" if s3q9_2=="2331"
	replace s3q9_2="2300" if s3q9_2=="2332"
	replace s3q9_2="2400" if s3q9_2=="2411"
	replace s3q9_2="2400" if s3q9_2=="2412"
	replace s3q9_2="2400" if s3q9_2=="2419"
	replace s3q9_2="2400" if s3q9_2=="2422"
	replace s3q9_2="2400" if s3q9_2=="2460"
	replace s3q9_2="2400" if s3q9_2=="2479"
	replace s3q9_2="2500" if s3q9_2=="2515"
	replace s3q9_2="3100" if s3q9_2=="3114"
	replace s3q9_2="3100" if s3q9_2=="3120"
	replace s3q9_2="3100" if s3q9_2=="3152"
	replace s3q9_2="3200" if s3q9_2=="3231"
	replace s3q9_2="3200" if s3q9_2=="3241"
	replace s3q9_2="3300" if s3q9_2=="3317"
	replace s3q9_2="3300" if s3q9_2=="3340"
	replace s3q9_2="3000" if s3q9_2=="3411"
	replace s3q9_2="3000" if s3q9_2=="3413"
	replace s3q9_2="3000" if s3q9_2=="3419"
	replace s3q9_2="3000" if s3q9_2=="3421"
	replace s3q9_2="3000" if s3q9_2=="3423"
	replace s3q9_2="3000" if s3q9_2=="3429"
	replace s3q9_2="3000" if s3q9_2=="3432"
	replace s3q9_2="3000" if s3q9_2=="3434"
	replace s3q9_2="3000" if s3q9_2=="3439"
	replace s3q9_2="3000" if s3q9_2=="3443"
	replace s3q9_2="3000" if s3q9_2=="3449"
	replace s3q9_2="3600" if s3q9_2=="3610"
	*4000 is replaced to 4300 because no 4000
	replace s3q9_2="4300" if s3q9_2=="4000"
	replace s3q9_2="4100" if s3q9_2=="4101"
	replace s3q9_2="4100" if s3q9_2=="4110"
	replace s3q9_2="4100" if s3q9_2=="4111"
	replace s3q9_2="4100" if s3q9_2=="4119"
	replace s3q9_2="4100" if s3q9_2=="4121"
	replace s3q9_2="4100" if s3q9_2=="4137"
	replace s3q9_2="4100" if s3q9_2=="4142"
	replace s3q9_2="4100" if s3q9_2=="4153"
	replace s3q9_2="4100" if s3q9_2=="4162"
	replace s3q9_2="4200" if s3q9_2=="4215"
	replace s3q9_2="4200" if s3q9_2=="4222"
	replace s3q9_2="4200" if s3q9_2=="4231"
	replace s3q9_2="4200" if s3q9_2=="4281"
	replace s3q9_2="4200" if s3q9_2=="4292"
	replace s3q9_2="4200" if s3q9_2=="4299"
	replace s3q9_2="4300" if s3q9_2=="4333"
	*changed to 43 from 44
	replace s3q9_2="4300" if s3q9_2=="4422"
	replace s3q9_2="4500" if s3q9_2=="4521"
	replace s3q9_2="4500" if s3q9_2=="4550"
	replace s3q9_2="4600" if s3q9_2=="4602"
	replace s3q9_2="4600" if s3q9_2=="4619"
	replace s3q9_2="4600" if s3q9_2=="4646"
	replace s3q9_2="4700" if s3q9_2=="4701"
	replace s3q9_2="4700" if s3q9_2=="4709"
	replace s3q9_2="4700" if s3q9_2=="4712"
	replace s3q9_2="4700" if s3q9_2=="4714"
	replace s3q9_2="4700" if s3q9_2=="4717"
	replace s3q9_2="4700" if s3q9_2=="4718"
	replace s3q9_2="4700" if s3q9_2=="4731"
	replace s3q9_2="4700" if s3q9_2=="4733"
	replace s3q9_2="4700" if s3q9_2=="4749"
	replace s3q9_2="4700" if s3q9_2=="4757"
	replace s3q9_2="4700" if s3q9_2=="4775"
	replace s3q9_2="4700" if s3q9_2=="4779"
	replace s3q9_2="4700" if s3q9_2=="4786"
	replace s3q9_2="4700" if s3q9_2=="4787"
	replace s3q9_2="4700" if s3q9_2=="4788"
	replace s3q9_2="4700" if s3q9_2=="4792"
	replace s3q9_2="4700" if s3q9_2=="4794"
	*it was 4800 and I changed to 4300 because there is no 4000
	replace s3q9_2="4300" if s3q9_2=="4820"
	replace s3q9_2="4900" if s3q9_2=="4919"
	replace s3q9_2="4900" if s3q9_2=="4971"
	replace s3q9_2="4900" if s3q9_2=="4974"
	replace s3q9_2="4900" if s3q9_2=="4977"
	replace s3q9_2="4900" if s3q9_2=="4989"
	replace s3q9_2="4900" if s3q9_2=="4999"
	replace s3q9_2="5100" if s3q9_2=="5101"
	replace s3q9_2="5100" if s3q9_2=="5111"
	replace s3q9_2="5100" if s3q9_2=="5112"
	replace s3q9_2="5100" if s3q9_2=="5114"
	replace s3q9_2="5100" if s3q9_2=="5121"
	replace s3q9_2="5100" if s3q9_2=="5122"
	replace s3q9_2="5100" if s3q9_2=="5123"
	replace s3q9_2="5100" if s3q9_2=="5129"
	replace s3q9_2="5100" if s3q9_2=="5131"
	replace s3q9_2="5100" if s3q9_2=="5133"
	replace s3q9_2="5100" if s3q9_2=="5141"
	replace s3q9_2="5100" if s3q9_2=="5149"
	replace s3q9_2="5100" if s3q9_2=="5163"
	replace s3q9_2="5100" if s3q9_2=="5169"
	replace s3q9_2="5100" if s3q9_2=="5190"
	replace s3q9_2="5200" if s3q9_2=="5211"
	replace s3q9_2="5200" if s3q9_2=="5230"
	replace s3q9_2="5200" if s3q9_2=="5232"
	replace s3q9_2="5200" if s3q9_2=="5252"
	replace s3q9_2="5200" if s3q9_2=="5259"
	replace s3q9_2="5300" if s3q9_2=="5325"
	replace s3q9_2="5000" if s3q9_2=="5411"
	replace s3q9_2="5000" if s3q9_2=="5412"
	replace s3q9_2="5600" if s3q9_2=="5623"
	replace s3q9_2="5600" if s3q9_2=="5627"
	replace s3q9_2="5000" if s3q9_2=="5721"
	replace s3q9_2="5000" if s3q9_2=="5773"
	replace s3q9_2="5800" if s3q9_2=="5815"
	replace s3q9_2="5800" if s3q9_2=="5830"
	replace s3q9_2="5900" if s3q9_2=="5929"
	replace s3q9_2="5900" if s3q9_2=="5930"
	replace s3q9_2="6000" if s3q9_2=="6022"
	replace s3q9_2="6000" if s3q9_2=="6023"
	replace s3q9_2="6100" if s3q9_2=="6111"
	replace s3q9_2="6100" if s3q9_2=="6112"
	replace s3q9_2="6100" if s3q9_2=="6113"
	replace s3q9_2="6100" if s3q9_2=="6114"
	replace s3q9_2="6100" if s3q9_2=="6121"
	replace s3q9_2="6100" if s3q9_2=="6122"
	replace s3q9_2="6100" if s3q9_2=="6123"
	replace s3q9_2="6100" if s3q9_2=="6132"
	replace s3q9_2="6100" if s3q9_2=="6142"
	replace s3q9_2="6100" if s3q9_2=="6151"
	replace s3q9_2="6100" if s3q9_2=="6154"
	replace s3q9_2="6200" if s3q9_2=="6210"
	replace s3q9_2="6200" if s3q9_2=="6211"
	replace s3q9_2="6200" if s3q9_2=="6212"
	replace s3q9_2="6200" if s3q9_2=="6222"
	replace s3q9_2="6400" if s3q9_2=="6479"
	replace s3q9_2="6500" if s3q9_2=="6549"
	replace s3q9_2="6000" if s3q9_2=="6712"
	replace s3q9_2="6900" if s3q9_2=="6909"
	replace s3q9_2="6900" if s3q9_2=="6921"
	replace s3q9_2="7100" if s3q9_2=="7111"
	replace s3q9_2="7100" if s3q9_2=="7112"
	replace s3q9_2="7100" if s3q9_2=="7121"
	replace s3q9_2="7100" if s3q9_2=="7122"
	replace s3q9_2="7100" if s3q9_2=="7124"
	replace s3q9_2="7100" if s3q9_2=="7129"
	replace s3q9_2="7100" if s3q9_2=="7131"
	replace s3q9_2="7100" if s3q9_2=="7136"
	replace s3q9_2="7100" if s3q9_2=="7141"
	replace s3q9_2="7200" if s3q9_2=="7211"
	replace s3q9_2="7200" if s3q9_2=="7212"
	replace s3q9_2="7200" if s3q9_2=="7221"
	replace s3q9_2="7200" if s3q9_2=="7223"
	replace s3q9_2="7200" if s3q9_2=="7229"
	replace s3q9_2="7200" if s3q9_2=="7230"
	replace s3q9_2="7200" if s3q9_2=="7231"
	replace s3q9_2="7200" if s3q9_2=="7240"
	replace s3q9_2="7200" if s3q9_2=="7245"
	replace s3q9_2="7200" if s3q9_2=="7292"
	replace s3q9_2="7300" if s3q9_2=="7331"
	replace s3q9_2="7300" if s3q9_2=="7341"
	replace s3q9_2="7400" if s3q9_2=="7411"
	replace s3q9_2="7400" if s3q9_2=="7412"
	replace s3q9_2="7400" if s3q9_2=="7413"
	replace s3q9_2="7400" if s3q9_2=="7415"
	replace s3q9_2="7400" if s3q9_2=="7419"
	replace s3q9_2="7400" if s3q9_2=="7422"
	replace s3q9_2="7400" if s3q9_2=="7423"
	replace s3q9_2="7400" if s3q9_2=="7432"
	replace s3q9_2="7400" if s3q9_2=="7433"
	replace s3q9_2="7400" if s3q9_2=="7435"
	replace s3q9_2="7400" if s3q9_2=="7444"
	replace s3q9_2="7400" if s3q9_2=="7482"
	replace s3q9_2="7400" if s3q9_2=="7499"
	replace s3q9_2="7500" if s3q9_2=="7511"
	replace s3q9_2="7500" if s3q9_2=="7520"
	replace s3q9_2="7500" if s3q9_2=="7523"
	replace s3q9_2="7000" if s3q9_2=="7601"
	replace s3q9_2="8000" if s3q9_2=="8050"
	replace s3q9_2="8000" if s3q9_2=="8052"
	replace s3q9_2="8000" if s3q9_2=="8090"
	replace s3q9_2="8100" if s3q9_2=="8113"
	replace s3q9_2="8200" if s3q9_2=="8222"
	replace s3q9_2="8000" if s3q9_2=="8322"
	replace s3q9_2="8000" if s3q9_2=="8330"
	replace s3q9_2="8400" if s3q9_2=="8424"
	replace s3q9_2="8400" if s3q9_2=="8433"
	replace s3q9_2="8400" if s3q9_2=="8490"
	replace s3q9_2="8500" if s3q9_2=="8511"
	replace s3q9_2="8500" if s3q9_2=="8512"
	replace s3q9_2="8500" if s3q9_2=="8519"
	replace s3q9_2="8500" if s3q9_2=="8531"
	replace s3q9_2="8500" if s3q9_2=="8532"
	replace s3q9_2="8700" if s3q9_2=="8741"
	replace s3q9_2="8800" if s3q9_2=="8821"
	replace s3q9_2="8800" if s3q9_2=="8850"
	replace s3q9_2="8800" if s3q9_2=="8899"
	replace s3q9_2="8000" if s3q9_2=="8920"
	replace s3q9_2="9000" if s3q9_2=="9009"
	replace s3q9_2="9100" if s3q9_2=="9113"
	replace s3q9_2="9100" if s3q9_2=="9121"
	replace s3q9_2="9100" if s3q9_2=="9162"
	replace s3q9_2="9100" if s3q9_2=="9191"
	replace s3q9_2="9100" if s3q9_2=="9199"
	replace s3q9_2="9200" if s3q9_2=="9221"
	replace s3q9_2="9300" if s3q9_2=="9302"
	replace s3q9_2="9500" if s3q9_2=="9502"
	replace s3q9_2="9500" if s3q9_2=="9528"
	replace s3q9_2="9500" if s3q9_2=="9574"
	replace s3q9_2="9600" if s3q9_2=="9606"
	replace s3q9_2="9600" if s3q9_2=="9607"
	replace s3q9_2="9600" if s3q9_2=="9620"
	replace s3q9_2="9600" if s3q9_2=="9662"
	replace s3q9_2="9700" if s3q9_2=="9799"
	replace s3q9_2="9800" if s3q9_2=="9850"
	replace s3q9_2="9900" if s3q9_2=="9902"
	gen industrycat_isic = substr(4 * "0", 1, 4 - length( s3q9_2 )) + s3q9_2
	replace industrycat_isic="" if industrycat_isic=="000."
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen byte industrycat10 = .
	replace industrycat10=1 if inrange(industrycat_isic,"0100","0399")
	replace industrycat10=2 if inrange(industrycat_isic,"0500","0999")
	replace industrycat10=3 if inrange(industrycat_isic,"1000","3399")
	replace industrycat10=4 if inrange(industrycat_isic,"3400","3999")
	replace industrycat10=5 if inrange(industrycat_isic,"4000","4399")
	replace industrycat10=6 if inrange(industrycat_isic,"4400","4799")
	replace industrycat10=7 if inrange(industrycat_isic,"4800","5399")
	replace industrycat10=6 if inrange(industrycat_isic,"5400","5699")
	replace industrycat10=7 if inrange(industrycat_isic,"5700","6399")
	replace industrycat10=8 if inrange(industrycat_isic,"6400","6899")
	replace industrycat10=8 if inrange(industrycat_isic,"6900","7599")
	replace industrycat10=8 if inrange(industrycat_isic,"7600","8299")
	replace industrycat10=9 if inrange(industrycat_isic,"8300","8419")
	replace industrycat10=9 if inrange(industrycat_isic,"8420", "8499")
	replace industrycat10=10 if inrange(industrycat_isic,"8500","8599")
	replace industrycat10=10 if inrange(industrycat_isic,"8600","8999")
	replace industrycat10=10 if inrange(industrycat_isic,"9000","9399")
	replace industrycat10=10 if inrange(industrycat_isic,"9400","9699")
	replace industrycat10=10 if inrange(industrycat_isic,"9700","9899")
	replace industrycat10=10 if inrange(industrycat_isic,"9900","9999")
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
*</_industrycat10_>


*<_industrycat4_>
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
	gen occup_orig = s3q8
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	tostring s3q8, gen(s3q8_2)
	replace s3q8_2="2300" if s3q8_2=="23"
	replace s3q8_2="1000" if s3q8_2=="101"
	replace s3q8_2="1000" if s3q8_2=="102"
	replace s3q8_2="1000" if s3q8_2=="103"
	replace s3q8_2="1000" if s3q8_2=="107"
	replace s3q8_2="1130" if s3q8_2=="113"
	replace s3q8_2="1140" if s3q8_2=="114"
	replace s3q8_2="1310" if s3q8_2=="131"
	replace s3q8_2="1000" if s3q8_2=="146"
	replace s3q8_2="4100" if s3q8_2=="410"
	replace s3q8_2="4110" if s3q8_2=="411"
	replace s3q8_2="4200" if s3q8_2=="429"
	replace s3q8_2="4000" if s3q8_2=="432"
	replace s3q8_2="4000" if s3q8_2=="452"
	replace s3q8_2="4000" if s3q8_2=="471"
	replace s3q8_2="5200" if s3q8_2=="520"
	replace s3q8_2="6110" if s3q8_2=="611"
	replace s3q8_2="6000" if s3q8_2=="692"
	replace s3q8_2="7000" if s3q8_2=="702"
	replace s3q8_2="7110" if s3q8_2=="711"
	replace s3q8_2="7200" if s3q8_2=="729"
	replace s3q8_2="7320" if s3q8_2=="732"
	replace s3q8_2="8000" if s3q8_2=="801"
	replace s3q8_2="8000" if s3q8_2=="802"
	replace s3q8_2="8000" if s3q8_2=="899"
	replace s3q8_2="9000" if s3q8_2=="990"
	replace s3q8_2="1000" if s3q8_2=="1016"
	replace s3q8_2="1000" if s3q8_2=="1017"
	replace s3q8_2="1000" if s3q8_2=="1061"
	replace s3q8_2="1000" if s3q8_2=="1079"
	replace s3q8_2="1100" if s3q8_2=="1101"
	replace s3q8_2="1100" if s3q8_2=="1103"
	replace s3q8_2="1110" if s3q8_2=="1114"
	replace s3q8_2="1120" if s3q8_2=="1122"
	replace s3q8_2="1210" if s3q8_2=="1219"
	replace s3q8_2="1200" if s3q8_2=="1240"
	replace s3q8_2="1300" if s3q8_2=="1341"
	replace s3q8_2="1000" if s3q8_2=="1415"
	replace s3q8_2="1000" if s3q8_2=="1510"
	replace s3q8_2="1000" if s3q8_2=="1514"
	replace s3q8_2="1000" if s3q8_2=="1520"
	replace s3q8_2="1000" if s3q8_2=="1551"
	replace s3q8_2="1000" if s3q8_2=="1620"
	replace s3q8_2="1000" if s3q8_2=="1622"
	replace s3q8_2="1000" if s3q8_2=="1629"
	replace s3q8_2="1000" if s3q8_2=="1711"
	replace s3q8_2="1000" if s3q8_2=="1811"
	replace s3q8_2="1000" if s3q8_2=="1814"
	replace s3q8_2="2110" if s3q8_2=="2119"
	replace s3q8_2="2120" if s3q8_2=="2124"
	replace s3q8_2="2120" if s3q8_2=="2129"
	replace s3q8_2="2210" if s3q8_2=="2216"
	replace s3q8_2="2310" if s3q8_2=="2312"
	replace s3q8_2="2310" if s3q8_2=="2318"
	replace s3q8_2="2320" if s3q8_2=="2321"
	replace s3q8_2="2330" if s3q8_2=="2333"
	replace s3q8_2="2330" if s3q8_2=="2334"
	replace s3q8_2="2342" if s3q8_2=="2342"
	replace s3q8_2="2410" if s3q8_2=="2414"
	replace s3q8_2="2410" if s3q8_2=="2418"
	replace s3q8_2="2430" if s3q8_2=="2433"
	replace s3q8_2="2430" if s3q8_2=="2435"
	replace s3q8_2="2430" if s3q8_2=="2439"
	replace s3q8_2="2000" if s3q8_2=="2599"
	replace s3q8_2="2000" if s3q8_2=="2610"
	replace s3q8_2="2000" if s3q8_2=="2821"
	replace s3q8_2="2000" if s3q8_2=="2957"
	replace s3q8_2="3100" if s3q8_2=="3163"
	replace s3q8_2="3210" if s3q8_2=="3216"
	replace s3q8_2="3210" if s3q8_2=="3218"
	replace s3q8_2="3310" if s3q8_2=="3311"
	replace s3q8_2="3310" if s3q8_2=="3312"
	replace s3q8_2="3310" if s3q8_2=="3319"
	replace s3q8_2="3320" if s3q8_2=="3323"
	replace s3q8_2="3420" if s3q8_2=="3427"
	replace s3q8_2="3430" if s3q8_2=="3437"
	replace s3q8_2="3000" if s3q8_2=="3510"
	replace s3q8_2="3000" if s3q8_2=="3811"
	replace s3q8_2="3000" if s3q8_2=="3812"
	replace s3q8_2="4100" if s3q8_2=="4151"
	replace s3q8_2="4100" if s3q8_2=="4162"
	replace s3q8_2="4220" if s3q8_2=="4226"
	replace s3q8_2="4200" if s3q8_2=="4245"
	replace s3q8_2="4200" if s3q8_2=="4290"
	replace s3q8_2="4000" if s3q8_2=="4311"
	replace s3q8_2="4000" if s3q8_2=="4322"
	replace s3q8_2="4000" if s3q8_2=="4330"
	replace s3q8_2="4000" if s3q8_2=="4520"
	replace s3q8_2="4000" if s3q8_2=="4551"
	replace s3q8_2="4000" if s3q8_2=="4661"
	replace s3q8_2="4000" if s3q8_2=="4711"
	replace s3q8_2="4000" if s3q8_2=="4715"
	replace s3q8_2="4000" if s3q8_2=="4719"
	replace s3q8_2="4000" if s3q8_2=="4721"
	replace s3q8_2="4000" if s3q8_2=="4722"
	replace s3q8_2="4000" if s3q8_2=="4733"
	replace s3q8_2="4000" if s3q8_2=="4751"
	replace s3q8_2="4000" if s3q8_2=="4759"
	replace s3q8_2="4000" if s3q8_2=="4771"
	replace s3q8_2="4000" if s3q8_2=="4772"
	replace s3q8_2="4000" if s3q8_2=="4774"
	replace s3q8_2="4000" if s3q8_2=="4779"
	replace s3q8_2="4000" if s3q8_2=="4781"
	replace s3q8_2="4000" if s3q8_2=="4789"
	replace s3q8_2="4000" if s3q8_2=="4799"
	replace s3q8_2="4000" if s3q8_2=="4921"
	replace s3q8_2="4000" if s3q8_2=="4922"
	replace s3q8_2="4000" if s3q8_2=="4923"
	replace s3q8_2="5000" if s3q8_2=="5010"
	replace s3q8_2="5100" if s3q8_2=="5102"
	replace s3q8_2="5100" if s3q8_2=="5109"
	replace s3q8_2="5110" if s3q8_2=="5114"
	replace s3q8_2="5110" if s3q8_2=="5115"
	replace s3q8_2="5110" if s3q8_2=="5116"
	replace s3q8_2="5120" if s3q8_2=="5124"
	replace s3q8_2="5120" if s3q8_2=="5128"
	replace s3q8_2="5120" if s3q8_2=="5129"
	replace s3q8_2="5120" if s3q8_2=="5144"
	replace s3q8_2="5140" if s3q8_2=="5145"
	replace s3q8_2="5140" if s3q8_2=="5147"
	replace s3q8_2="5150" if s3q8_2=="5159"
	replace s3q8_2="5160" if s3q8_2=="5164"
	replace s3q8_2="5160" if s3q8_2=="5168"
	replace s3q8_2="5170" if s3q8_2=="5171"
	replace s3q8_2="5170" if s3q8_2=="5172"
	replace s3q8_2="5190" if s3q8_2=="5191"
	replace s3q8_2="5190" if s3q8_2=="5196"
	replace s3q8_2="5190" if s3q8_2=="5198"
	replace s3q8_2="5200" if s3q8_2=="5204"
	replace s3q8_2="5210" if s3q8_2=="5212"
	replace s3q8_2="5210" if s3q8_2=="5214"
	replace s3q8_2="5220" if s3q8_2=="5221"
	replace s3q8_2="5220" if s3q8_2=="5222"
	replace s3q8_2="5220" if s3q8_2=="5223"
	replace s3q8_2="5220" if s3q8_2=="5225"
	replace s3q8_2="5220" if s3q8_2=="5229"
	replace s3q8_2="5230" if s3q8_2=="5232"
	replace s3q8_2="5230" if s3q8_2=="5234"
	replace s3q8_2="5200" if s3q8_2=="5250"
	replace s3q8_2="5200" if s3q8_2=="5253"
	replace s3q8_2="5200" if s3q8_2=="5259"
	replace s3q8_2="5200" if s3q8_2=="5260"
	replace s3q8_2="5200" if s3q8_2=="5262"
	replace s3q8_2="5200" if s3q8_2=="5270"
	replace s3q8_2="5200" if s3q8_2=="5280"
	replace s3q8_2="5000" if s3q8_2=="5320"
	replace s3q8_2="5000" if s3q8_2=="5330"
	replace s3q8_2="5000" if s3q8_2=="5419"
	replace s3q8_2="5000" if s3q8_2=="5441"
	replace s3q8_2="5000" if s3q8_2=="5520"
	replace s3q8_2="5000" if s3q8_2=="5613"
	replace s3q8_2="5000" if s3q8_2=="5629"
	replace s3q8_2="5000" if s3q8_2=="5721"
	replace s3q8_2="5000" if s3q8_2=="5811"
	replace s3q8_2="5000" if s3q8_2=="5920"
	replace s3q8_2="5000" if s3q8_2=="5969"
	replace s3q8_2="6110" if s3q8_2=="6116"
	replace s3q8_2="6130" if s3q8_2=="6131"
	replace s3q8_2="6130" if s3q8_2=="6132"
	replace s3q8_2="6130" if s3q8_2=="6133"
	replace s3q8_2="6130" if s3q8_2=="6134"
	replace s3q8_2="6130" if s3q8_2=="6136"
	replace s3q8_2="6140" if s3q8_2=="6145"
	replace s3q8_2="6140" if s3q8_2=="6149"
	replace s3q8_2="6100" if s3q8_2=="6171"
	replace s3q8_2="6100" if s3q8_2=="6174"
	replace s3q8_2="6100" if s3q8_2=="6190"
	replace s3q8_2="6200" if s3q8_2=="6201"
	replace s3q8_2="6210" if s3q8_2=="6211"
	replace s3q8_2="6210" if s3q8_2=="6212"
	replace s3q8_2="6210" if s3q8_2=="6214"
	replace s3q8_2="6210" if s3q8_2=="6216"
	replace s3q8_2="6200" if s3q8_2=="6221"
	replace s3q8_2="6200" if s3q8_2=="6230"
	replace s3q8_2="6230" if s3q8_2=="6231"
	replace s3q8_2="6230" if s3q8_2=="6232"
	replace s3q8_2="6200" if s3q8_2=="6240"
	replace s3q8_2="6200" if s3q8_2=="6242"
	replace s3q8_2="6200" if s3q8_2=="6250"
	replace s3q8_2="6200" if s3q8_2=="6251"
	replace s3q8_2="6200" if s3q8_2=="6252"
	replace s3q8_2="6200" if s3q8_2=="6269"
	replace s3q8_2="6000" if s3q8_2=="6311"
	replace s3q8_2="6000" if s3q8_2=="6321"
	replace s3q8_2="6000" if s3q8_2=="6415"
	replace s3q8_2="6000" if s3q8_2=="6420"
	replace s3q8_2="6000" if s3q8_2=="6510"
	replace s3q8_2="6000" if s3q8_2=="6621"
	replace s3q8_2="6000" if s3q8_2=="6710"
	replace s3q8_2="6000" if s3q8_2=="6820"
	replace s3q8_2="6000" if s3q8_2=="6920"
	replace s3q8_2="6000" if s3q8_2=="6921"
	replace s3q8_2="7110" if s3q8_2=="7114"
	replace s3q8_2="7110" if s3q8_2=="7115"
	replace s3q8_2="7110" if s3q8_2=="7126"
	replace s3q8_2="7120" if s3q8_2=="7127"
	replace s3q8_2="7100" if s3q8_2=="7151"
	replace s3q8_2="7100" if s3q8_2=="7152"
	replace s3q8_2="7100" if s3q8_2=="7159"
	replace s3q8_2="7100" if s3q8_2=="7162"
	replace s3q8_2="7100" if s3q8_2=="7181"
	replace s3q8_2="7100" if s3q8_2=="7196"
	replace s3q8_2="7210" if s3q8_2=="7217"
	replace s3q8_2="7210" if s3q8_2=="7219"
	replace s3q8_2="7230" if s3q8_2=="7234"
	replace s3q8_2="7330" if s3q8_2=="7334"
	replace s3q8_2="7400" if s3q8_2=="7403"
	replace s3q8_2="7420" if s3q8_2=="7426"
	replace s3q8_2="7440" if s3q8_2=="7444"
	replace s3q8_2="7400" if s3q8_2=="7451"
	replace s3q8_2="7400" if s3q8_2=="7452"
	replace s3q8_2="7400" if s3q8_2=="7455"
	replace s3q8_2="7400" if s3q8_2=="7490"
	replace s3q8_2="7000" if s3q8_2=="7510"
	replace s3q8_2="7000" if s3q8_2=="7515"
	replace s3q8_2="7000" if s3q8_2=="7520"
	replace s3q8_2="7000" if s3q8_2=="7522"
	replace s3q8_2="7000" if s3q8_2=="7535"
	replace s3q8_2="7000" if s3q8_2=="7729"
	replace s3q8_2="7000" if s3q8_2=="7845"
	replace s3q8_2="7000" if s3q8_2=="7911"
	replace s3q8_2="8000" if s3q8_2=="8010"
	replace s3q8_2="8000" if s3q8_2=="8020"
	replace s3q8_2="8110" if s3q8_2=="8114"
	replace s3q8_2="8120" if s3q8_2=="8129"
	replace s3q8_2="8230" if s3q8_2=="8233"
	replace s3q8_2="8290" if s3q8_2=="8292"
	replace s3q8_2="8000" if s3q8_2=="8412"
	replace s3q8_2="8000" if s3q8_2=="8422"
	replace s3q8_2="8000" if s3q8_2=="8423"
	replace s3q8_2="8000" if s3q8_2=="8425"
	replace s3q8_2="8000" if s3q8_2=="8430"
	replace s3q8_2="8000" if s3q8_2=="8510"
	replace s3q8_2="8000" if s3q8_2=="8521"
	replace s3q8_2="8000" if s3q8_2=="8549"
	replace s3q8_2="8000" if s3q8_2=="8610"
	replace s3q8_2="8000" if s3q8_2=="8620"
	replace s3q8_2="8000" if s3q8_2=="8890"
	replace s3q8_2="8000" if s3q8_2=="8922"
	replace s3q8_2="9100" if s3q8_2=="9123"
	replace s3q8_2="9130" if s3q8_2=="9134"
	replace s3q8_2="9130" if s3q8_2=="9139"
	replace s3q8_2="9100" if s3q8_2=="9191"
	replace s3q8_2="9200" if s3q8_2=="9220"
	replace s3q8_2="9300" if s3q8_2=="9309"
	replace s3q8_2="9000" if s3q8_2=="9521"
	replace s3q8_2="9000" if s3q8_2=="9522"
	replace s3q8_2="9000" if s3q8_2=="9602"
	replace s3q8_2="9000" if s3q8_2=="9609"
	replace s3q8_2="9000" if s3q8_2=="9621"
	replace s3q8_2="9000" if s3q8_2=="9700"
	replace s3q8_2="9000" if s3q8_2=="9810"

	replace s3q8_2="2340" if s3q8_2=="2342"
	replace s3q8_2="5100" if s3q8_2=="5170"
	replace s3q8_2="5100" if s3q8_2=="5190"
	replace s3q8_2="6200" if s3q8_2=="6230"

	gen occup_isco = s3q8_2 + substr("0000", 1, 4 - length(s3q8_2))
	replace occup_isco="" if occup_isco==".000"
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	rename occup occup_a
	gen byte occup = .
	replace occup=1 if inrange(occup_isco,"1000","1399")
	replace occup=2 if inrange(occup_isco,"2000","2499")
	replace occup=3 if inrange(occup_isco,"3000","3499")
	replace occup=4 if inrange(occup_isco,"4000","4299")
	replace occup=5 if inrange(occup_isco,"5000","5299")
	replace occup=6 if inrange(occup_isco,"6000","6299")
	replace occup=7 if inrange(occup_isco,"7000","7499")
	replace occup=8 if inrange(occup_isco,"8000","8399")
	replace occup=9 if inrange(occup_isco,"9000","9399")
	replace occup=10 if inrange(occup_isco,"0000","0999")
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
	gen double wage_no_compen = .
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>

/* <_unitwage_note>
	Unitwage refers to the unit used to record wage_no_compen, *not* the unit of
	general wage payent. For example, PHL LFS asks about wage periodicity, then
	asks for basic daily pay. The value of that pay would be wage_no_compen,
	while unitwage is code 1 ("Daily") for all, regardless of the periodicity.
</_unitwage_note> */

	gen byte unitwage = .
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours = s3q17
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	gen wmonths = .
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
/* <_wage_total_note>

	Use gross wages when available and net wages only when gross wages are not available.
	This is done to make it easy to compare earnings in formal and informal sectors.

</_wage_total_note> */
	gen wage_total = .
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen byte contract = .
	replace contract=1 if inrange(s3q10,1,5) & lstatus==1
	replace contract=0 if s3q10==. & lstatus==1
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte healthins = .
	label var healthins "Employment has health insurance primary job 7 day recall"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen byte socialsec = s3q13
	recode socialsec 2=0 9=.
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec 1 "With social security" 0 "Without social secturity"
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen byte union = .
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	gen firmsize_l = .
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen firmsize_u= .
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen byte empstat_2 = .
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
	gen industrycat_isic_2 = .
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen byte industrycat10_2 = .
	label var industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
	label values industrycat10_2 lblindustrycat10
*</_industrycat10_2_>


*<_industrycat4_2_>
	gen byte industrycat4_2 = industrycat10_2
	recode industrycat4_2 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
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
	gen double wage_no_compen_2 = .
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2 = .
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
	gen whours_2 = .
	label var whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>


*<_wmonths_2_>
	gen wmonths_2 = .
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
	gen t_hours_total = .
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
	gen byte lstatus_year = s4q1
	recode lstatus_year 1/3=1 4/5=2 6=1 7/11=3
	replace lstatus_year=1 if s4q2==1
	replace lstatus_year=1 if s4q3==1
	replace lstatus_year=1 if s4q4==1
	replace lstatus_year=1 if s4q5==1
	replace lstatus_year=1 if s4q6==1
	replace lstatus_year=1 if s4q7==1
	replace lstatus_year=. if age < minlaborage & age != .
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>

*<_potential_lf_year_>
	gen byte potential_lf_year = .
	replace potential_lf_year=. if age < minlaborage & age != .
	replace potential_lf_year = . if lstatus_year != 3
	label var potential_lf_year "Potential labour force status"
	la de lblpotential_lf_year 0 "No" 1 "Yes"
	label values potential_lf_year lblpotential_lf_year
*</_potential_lf_year_>


*<_underemployment_year_>
	gen byte underemployment_year = .
	replace underemployment_year = . if age < minlaborage & age != .
	replace underemployment_year = . if lstatus_year == 1
	label var underemployment_year "Underemployment status"
	la de lblunderemployment_year 0 "No" 1 "Yes"
	label values underemployment_year lblunderemployment_year
*</_underemployment_year_>


*<_nlfreason_year_>
	gen byte nlfreason_year=.
	label var nlfreason_year "Reason not in the labor force"
	la de lblnlfreason_year 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason_year lblnlfreason_year
*</_nlfreason_year_>


*<_unempldur_l_year_>
	gen byte unempldur_l_year=.
	label var unempldur_l_year "Unemployment duration (months) lower bracket"
*</_unempldur_l_year_>


*<_unempldur_u_year_>
	gen byte unempldur_u_year=.
	label var unempldur_u_year "Unemployment duration (months) upper bracket"
*</_unempldur_u_year_>

}

*----------8.7: 12 month reference main job------------------------------*

{

*<_empstat_year_>
	gen byte empstat_year = s4q12
	recode empstat_year 1=4 2=3 3=1 4=2
	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>

*<_ocusec_year_>
	gen byte ocusec_year = s4q11
	recode ocusec_year 2=1 4=2 5=2 6=2 7=2
	label var ocusec_year "Sector of activity primary job 12 month recall"
	la de lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_year lblocusec_year
*</_ocusec_year_>

*<_industry_orig_year_>
	gen industry_orig_year = s4q9
	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	tostring s4q9, gen(s4q9_2) force
	replace s4q9_2="0110" if s4q9_2=="11"
	replace s4q9_2="0120" if s4q9_2=="12"
	replace s4q9_2="0310" if s4q9_2=="31"
	replace s4q9_2="1000" if s4q9_2=="100"
	replace s4q9_2="1010" if s4q9_2=="101"
	replace s4q9_2="1020" if s4q9_2=="102"
	replace s4q9_2="1030" if s4q9_2=="103"
	replace s4q9_2="1040" if s4q9_2=="104"
	replace s4q9_2="0110" if s4q9_2=="110"
	replace s4q9_2="0111" if s4q9_2=="111"
	replace s4q9_2="0112" if s4q9_2=="112"
	replace s4q9_2="0113" if s4q9_2=="113"
	replace s4q9_2="0114" if s4q9_2=="114"
	replace s4q9_2="0115" if s4q9_2=="115"
	replace s4q9_2="0116" if s4q9_2=="116"
	replace s4q9_2="0119" if s4q9_2=="119"
	replace s4q9_2="0120" if s4q9_2=="120"
	replace s4q9_2="0121" if s4q9_2=="121"
	replace s4q9_2="0122" if s4q9_2=="122"
	replace s4q9_2="0123" if s4q9_2=="123"
	replace s4q9_2="0124" if s4q9_2=="124"
	replace s4q9_2="0125" if s4q9_2=="125"
	replace s4q9_2="0126" if s4q9_2=="126"
	replace s4q9_2="0127" if s4q9_2=="127"
	replace s4q9_2="0128" if s4q9_2=="128"
	replace s4q9_2="0129" if s4q9_2=="129"
	replace s4q9_2="1300" if s4q9_2=="130"
	replace s4q9_2="1310" if s4q9_2=="131"
	replace s4q9_2="1300" if s4q9_2=="132"
	replace s4q9_2="1300" if s4q9_2=="133"
	replace s4q9_2="0140" if s4q9_2=="140"
	replace s4q9_2="0141" if s4q9_2=="141"
	replace s4q9_2="0142" if s4q9_2=="142"
	replace s4q9_2="0143" if s4q9_2=="143"
	replace s4q9_2="0144" if s4q9_2=="144"
	replace s4q9_2="0145" if s4q9_2=="145"
	replace s4q9_2="0146" if s4q9_2=="146"
	replace s4q9_2="0149" if s4q9_2=="149"
	replace s4q9_2="0150" if s4q9_2=="150"
	replace s4q9_2="0150" if s4q9_2=="151"
	replace s4q9_2="0150" if s4q9_2=="152"
	replace s4q9_2="0150" if s4q9_2=="156"
	replace s4q9_2="0150" if s4q9_2=="157"
	replace s4q9_2="0160" if s4q9_2=="160"
	replace s4q9_2="0160" if s4q9_2=="161"
	replace s4q9_2="0162" if s4q9_2=="162"
	replace s4q9_2="0163" if s4q9_2=="163"
	replace s4q9_2="0164" if s4q9_2=="164"
	replace s4q9_2="0160" if s4q9_2=="165"
	replace s4q9_2="0160" if s4q9_2=="167"
	replace s4q9_2="0170" if s4q9_2=="170"
	replace s4q9_2="0170" if s4q9_2=="171"
	replace s4q9_2="0170" if s4q9_2=="172"
	replace s4q9_2="0170" if s4q9_2=="174"
	replace s4q9_2="1810" if s4q9_2=="181"
	replace s4q9_2="1910" if s4q9_2=="191"
	replace s4q9_2="1920" if s4q9_2=="192"
	replace s4q9_2="0200" if s4q9_2=="200"
	replace s4q9_2="0200" if s4q9_2=="201"
	replace s4q9_2="0200" if s4q9_2=="202"
	replace s4q9_2="0210" if s4q9_2=="210"
	replace s4q9_2="0210" if s4q9_2=="211"
	replace s4q9_2="0220" if s4q9_2=="220"
	replace s4q9_2="0220" if s4q9_2=="221"
	replace s4q9_2="0220" if s4q9_2=="222"
	replace s4q9_2="0220" if s4q9_2=="229"
	replace s4q9_2="0230" if s4q9_2=="230"
	replace s4q9_2="0230" if s4q9_2=="232"
	replace s4q9_2="0240" if s4q9_2=="240"
	replace s4q9_2="0240" if s4q9_2=="243"
	replace s4q9_2="2590" if s4q9_2=="259"
	replace s4q9_2="2790" if s4q9_2=="279"
	replace s4q9_2="0300" if s4q9_2=="301"
	replace s4q9_2="0310" if s4q9_2=="310"
	replace s4q9_2="0311" if s4q9_2=="311"
	replace s4q9_2="0312" if s4q9_2=="312"
	replace s4q9_2="0310" if s4q9_2=="313"
	replace s4q9_2="0321" if s4q9_2=="321"
	replace s4q9_2="0322" if s4q9_2=="322"
	replace s4q9_2="0300" if s4q9_2=="343"
	replace s4q9_2="0300" if s4q9_2=="350"
	replace s4q9_2="4100" if s4q9_2=="401"
	replace s4q9_2="4200" if s4q9_2=="423"
	replace s4q9_2="4330" if s4q9_2=="433"
	replace s4q9_2="4100" if s4q9_2=="443"
	replace s4q9_2="4710" if s4q9_2=="471"
	replace s4q9_2="4720" if s4q9_2=="472"
	replace s4q9_2="4780" if s4q9_2=="478"
	replace s4q9_2="4920" if s4q9_2=="492"
	replace s4q9_2="5010" if s4q9_2=="501"
	replace s4q9_2="5100" if s4q9_2=="510"
	replace s4q9_2="5120" if s4q9_2=="512"
	replace s4q9_2="5200" if s4q9_2=="520"
	replace s4q9_2="5220" if s4q9_2=="522"
	replace s4q9_2="5300" if s4q9_2=="530"
	replace s4q9_2="5620" if s4q9_2=="562"
	replace s4q9_2="5900" if s4q9_2=="599"
	replace s4q9_2="6010" if s4q9_2=="601"
	replace s4q9_2="6020" if s4q9_2=="602"
	replace s4q9_2="6100" if s4q9_2=="610"
	replace s4q9_2="6120" if s4q9_2=="612"
	replace s4q9_2="6200" if s4q9_2=="620"
	replace s4q9_2="6610" if s4q9_2=="661"
	replace s4q9_2="7010" if s4q9_2=="701"
	replace s4q9_2="7020" if s4q9_2=="702"
	replace s4q9_2="7000" if s4q9_2=="703"
	replace s4q9_2="7000" if s4q9_2=="707"
	replace s4q9_2="7100" if s4q9_2=="710"
	replace s4q9_2="7120" if s4q9_2=="712"
	replace s4q9_2="7200" if s4q9_2=="720"
	replace s4q9_2="0721" if s4q9_2=="721"
	replace s4q9_2="7220" if s4q9_2=="722"
	replace s4q9_2="7200" if s4q9_2=="726"
	replace s4q9_2="7200" if s4q9_2=="727"
	replace s4q9_2="7200" if s4q9_2=="728"
	replace s4q9_2="0729" if s4q9_2=="729"
	replace s4q9_2="7720" if s4q9_2=="772"
	replace s4q9_2="7900" if s4q9_2=="792"
	replace s4q9_2="8010" if s4q9_2=="801"
	replace s4q9_2="8100" if s4q9_2=="810"
	replace s4q9_2="8120" if s4q9_2=="812"
	replace s4q9_2="8130" if s4q9_2=="813"
	replace s4q9_2="8100" if s4q9_2=="818"
	replace s4q9_2="8100" if s4q9_2=="819"
	replace s4q9_2="8200" if s4q9_2=="820"
	replace s4q9_2="8210" if s4q9_2=="821"
	replace s4q9_2="8510" if s4q9_2=="851"
	replace s4q9_2="8520" if s4q9_2=="852"
	replace s4q9_2="8530" if s4q9_2=="853"
	replace s4q9_2="0890" if s4q9_2=="890"
	replace s4q9_2="0893" if s4q9_2=="893"
	replace s4q9_2="0899" if s4q9_2=="899"
	replace s4q9_2="9000" if s4q9_2=="902"
	replace s4q9_2="9100" if s4q9_2=="911"
	replace s4q9_2="9300" if s4q9_2=="933"
	replace s4q9_2="0990" if s4q9_2=="990"
	replace s4q9_2="1000" if s4q9_2=="1014"
	replace s4q9_2="1100" if s4q9_2=="1105"
	replace s4q9_2="1100" if s4q9_2=="1106"
	replace s4q9_2="1100" if s4q9_2=="1125"
	replace s4q9_2="1100" if s4q9_2=="1131"
	replace s4q9_2="1100" if s4q9_2=="1195"
	replace s4q9_2="1200" if s4q9_2=="1231"
	replace s4q9_2="1300" if s4q9_2=="1372"
	replace s4q9_2="1400" if s4q9_2=="1436"
	replace s4q9_2="1500" if s4q9_2=="1503"
	replace s4q9_2="1500" if s4q9_2=="1563"
	replace s4q9_2="1600" if s4q9_2=="1619"
	replace s4q9_2="1700" if s4q9_2=="1719"
	replace s4q9_2="1700" if s4q9_2=="1789"
	replace s4q9_2="1900" if s4q9_2=="1903"
	replace s4q9_2="1900" if s4q9_2=="1921"
	replace s4q9_2="2000" if s4q9_2=="2005"
	replace s4q9_2="2000" if s4q9_2=="2025"
	replace s4q9_2="2200" if s4q9_2=="2223"
	replace s4q9_2="2200" if s4q9_2=="2229"
	replace s4q9_2="2300" if s4q9_2=="2315"
	replace s4q9_2="2300" if s4q9_2=="2320"
	replace s4q9_2="2300" if s4q9_2=="2340"
	replace s4q9_2="2400" if s4q9_2=="2446"
	replace s4q9_2="2400" if s4q9_2=="2492"
	replace s4q9_2="2500" if s4q9_2=="2594"
	replace s4q9_2="2700" if s4q9_2=="2799"
	replace s4q9_2="2800" if s4q9_2=="2869"
	replace s4q9_2="3100" if s4q9_2=="3121"
	replace s4q9_2="3100" if s4q9_2=="3122"
	replace s4q9_2="3100" if s4q9_2=="3123"
	replace s4q9_2="3200" if s4q9_2=="3221"
	replace s4q9_2="3200" if s4q9_2=="3229"
	replace s4q9_2="3000" if s4q9_2=="3410"
	replace s4q9_2="3600" if s4q9_2=="3609"
	replace s4q9_2="3700" if s4q9_2=="3741"
	replace s4q9_2="4300" if s4q9_2=="4020"
	replace s4q9_2="4300" if s4q9_2=="4030"
	replace s4q9_2="4100" if s4q9_2=="4106"
	replace s4q9_2="4100" if s4q9_2=="4190"
	replace s4q9_2="4100" if s4q9_2=="4199"
	replace s4q9_2="4200" if s4q9_2=="4221"
	replace s4q9_2="4200" if s4q9_2=="4230"
	replace s4q9_2="4200" if s4q9_2=="4289"
	replace s4q9_2="4300" if s4q9_2=="4331"
	replace s4q9_2="4300" if s4q9_2=="4474"
	replace s4q9_2="4300" if s4q9_2=="4499"
	replace s4q9_2="4600" if s4q9_2=="4642"
	replace s4q9_2="4700" if s4q9_2=="4713"
	replace s4q9_2="4700" if s4q9_2=="4732"
	replace s4q9_2="4700" if s4q9_2=="4739"
	replace s4q9_2="4700" if s4q9_2=="4744"
	replace s4q9_2="4700" if s4q9_2=="4754"
	replace s4q9_2="4700" if s4q9_2=="4755"
	replace s4q9_2="4700" if s4q9_2=="4777"
	replace s4q9_2="4700" if s4q9_2=="4784"
	replace s4q9_2="4700" if s4q9_2=="4785"
	replace s4q9_2="4700" if s4q9_2=="4797"
	replace s4q9_2="4700" if s4q9_2=="4852"
	replace s4q9_2="4700" if s4q9_2=="4899"
	replace s4q9_2="4900" if s4q9_2=="4914"
	replace s4q9_2="4900" if s4q9_2=="4925"
	replace s4q9_2="4900" if s4q9_2=="4929"
	replace s4q9_2="4900" if s4q9_2=="4942"
	replace s4q9_2="4900" if s4q9_2=="4944"
	replace s4q9_2="4900" if s4q9_2=="4952"
	replace s4q9_2="4900" if s4q9_2=="4959"
	replace s4q9_2="4900" if s4q9_2=="4969"
	replace s4q9_2="5200" if s4q9_2=="5219"
	replace s4q9_2="5200" if s4q9_2=="5225"
	replace s4q9_2="5300" if s4q9_2=="5331"
	replace s4q9_2="5000" if s4q9_2=="5429"
	replace s4q9_2="5000" if s4q9_2=="5430"
	replace s4q9_2="5600" if s4q9_2=="5612"
	replace s4q9_2="5600" if s4q9_2=="5624"
	replace s4q9_2="5600" if s4q9_2=="5632"
	replace s4q9_2="5600" if s4q9_2=="5680"
	replace s4q9_2="5600" if s4q9_2=="5710"
	replace s4q9_2="5600" if s4q9_2=="5711"
	replace s4q9_2="5600" if s4q9_2=="5752"
	replace s4q9_2="5800" if s4q9_2=="5852"
	replace s4q9_2="5900" if s4q9_2=="5952"
	replace s4q9_2="6000" if s4q9_2=="6016"
	replace s4q9_2="6000" if s4q9_2=="6021"
	replace s4q9_2="6100" if s4q9_2=="6129"
	replace s4q9_2="6100" if s4q9_2=="6140"
	replace s4q9_2="6100" if s4q9_2=="6141"
	replace s4q9_2="6100" if s4q9_2=="6149"
	replace s4q9_2="6100" if s4q9_2=="6162"
	replace s4q9_2="6300" if s4q9_2=="6304"
	replace s4q9_2="6400" if s4q9_2=="6424"
	replace s4q9_2="6400" if s4q9_2=="6466"
	replace s4q9_2="6400" if s4q9_2=="6496"
	replace s4q9_2="6600" if s4q9_2=="6710"
	replace s4q9_2="6600" if s4q9_2=="6771"
	replace s4q9_2="6900" if s4q9_2=="6905"
	replace s4q9_2="7100" if s4q9_2=="7123"
	replace s4q9_2="7100" if s4q9_2=="7130"
	replace s4q9_2="7100" if s4q9_2=="7181"
	replace s4q9_2="7200" if s4q9_2=="7291"
	replace s4q9_2="7400" if s4q9_2=="7421"
	replace s4q9_2="7400" if s4q9_2=="7442"
	replace s4q9_2="7400" if s4q9_2=="7474"
	replace s4q9_2="7400" if s4q9_2=="7481"
	replace s4q9_2="7400" if s4q9_2=="7489"
	replace s4q9_2="7400" if s4q9_2=="7491"
	replace s4q9_2="8100" if s4q9_2=="8101"
	replace s4q9_2="8200" if s4q9_2=="8251"
	replace s4q9_2="8200" if s4q9_2=="8310"
	replace s4q9_2="8400" if s4q9_2=="8425"
	replace s4q9_2="8400" if s4q9_2=="8432"
	replace s4q9_2="8400" if s4q9_2=="8449"
	replace s4q9_2="8400" if s4q9_2=="8450"
	replace s4q9_2="8500" if s4q9_2=="8554"
	replace s4q9_2="8600" if s4q9_2=="8621"
	replace s4q9_2="8600" if s4q9_2=="8640"
	replace s4q9_2="8700" if s4q9_2=="8723"
	replace s4q9_2="8700" if s4q9_2=="8749"
	replace s4q9_2="8700" if s4q9_2=="8791"
	replace s4q9_2="8800" if s4q9_2=="8811"
	replace s4q9_2="8800" if s4q9_2=="8990"
	replace s4q9_2="8800" if s4q9_2=="8992"
	replace s4q9_2="9100" if s4q9_2=="9111"
	replace s4q9_2="9100" if s4q9_2=="9131"
	replace s4q9_2="9200" if s4q9_2=="9202"
	replace s4q9_2="9200" if s4q9_2=="9219"
	replace s4q9_2="9200" if s4q9_2=="9233"
	replace s4q9_2="9200" if s4q9_2=="9291"
	replace s4q9_2="9300" if s4q9_2=="9323"
	replace s4q9_2="9400" if s4q9_2=="9406"
	replace s4q9_2="9400" if s4q9_2=="9461"
	replace s4q9_2="9500" if s4q9_2=="9527"
	replace s4q9_2="9500" if s4q9_2=="9539"
	replace s4q9_2="9600" if s4q9_2=="9608"
	replace s4q9_2="9600" if s4q9_2=="9610"
	replace s4q9_2="9700" if s4q9_2=="9702"
	replace s4q9_2="9700" if s4q9_2=="9710"
	replace s4q9_2="9800" if s4q9_2=="9821"
	replace s4q9_2="9800" if s4q9_2=="9822"
	replace s4q9_2="9800" if s4q9_2=="9892"
	replace s4q9_2="0100" if s4q9_2=="0118"
	replace s4q9_2="0500" if s4q9_2=="0562"
	replace s4q9_2="0700" if s4q9_2=="0727"
	replace s4q9_2="1000" if s4q9_2=="1001"
	replace s4q9_2="1000" if s4q9_2=="1011"
	replace s4q9_2="1000" if s4q9_2=="1016"
	replace s4q9_2="1000" if s4q9_2=="1017"
	replace s4q9_2="1000" if s4q9_2=="1021"
	replace s4q9_2="1000" if s4q9_2=="1029"
	replace s4q9_2="1000" if s4q9_2=="1051"
	replace s4q9_2="1100" if s4q9_2=="1108"
	replace s4q9_2="1100" if s4q9_2=="1110"
	replace s4q9_2="1100" if s4q9_2=="1111"
	replace s4q9_2="1100" if s4q9_2=="1112"
	replace s4q9_2="1100" if s4q9_2=="1113"
	replace s4q9_2="1100" if s4q9_2=="1115"
	replace s4q9_2="1100" if s4q9_2=="1117"
	replace s4q9_2="1100" if s4q9_2=="1119"
	replace s4q9_2="1100" if s4q9_2=="1132"
	replace s4q9_2="1100" if s4q9_2=="1135"
	replace s4q9_2="1100" if s4q9_2=="1157"
	replace s4q9_2="1200" if s4q9_2=="1221"
	replace s4q9_2="1200" if s4q9_2=="1226"
	replace s4q9_2="1200" if s4q9_2=="1291"
	replace s4q9_2="1200" if s4q9_2=="1295"
	replace s4q9_2="1400" if s4q9_2=="1472"
	replace s4q9_2="1400" if s4q9_2=="1499"
	replace s4q9_2="1500" if s4q9_2=="1501"
	replace s4q9_2="1500" if s4q9_2=="1505"
	replace s4q9_2="1500" if s4q9_2=="1541"
	replace s4q9_2="1600" if s4q9_2=="1624"
	replace s4q9_2="1600" if s4q9_2=="1626"
	replace s4q9_2="1600" if s4q9_2=="1628"
	replace s4q9_2="1600" if s4q9_2=="1642"
	replace s4q9_2="1600" if s4q9_2=="1659"
	replace s4q9_2="1700" if s4q9_2=="1712"
	replace s4q9_2="1700" if s4q9_2=="1749"
	replace s4q9_2="1800" if s4q9_2=="1821"
	replace s4q9_2="2000" if s4q9_2=="2015"
	replace s4q9_2="2000" if s4q9_2=="2032"
	replace s4q9_2="2100" if s4q9_2=="2104"
	replace s4q9_2="2100" if s4q9_2=="2122"
	replace s4q9_2="2100" if s4q9_2=="2131"
	replace s4q9_2="2100" if s4q9_2=="2143"
	replace s4q9_2="2200" if s4q9_2=="2214"
	replace s4q9_2="2200" if s4q9_2=="2224"
	replace s4q9_2="2300" if s4q9_2=="2312"
	replace s4q9_2="2300" if s4q9_2=="2319"
	replace s4q9_2="2300" if s4q9_2=="2321"
	replace s4q9_2="2300" if s4q9_2=="2331"
	replace s4q9_2="2300" if s4q9_2=="2332"
	replace s4q9_2="2400" if s4q9_2=="2411"
	replace s4q9_2="2400" if s4q9_2=="2412"
	replace s4q9_2="2400" if s4q9_2=="2419"
	replace s4q9_2="2400" if s4q9_2=="2422"
	replace s4q9_2="2400" if s4q9_2=="2460"
	replace s4q9_2="2400" if s4q9_2=="2479"
	replace s4q9_2="2500" if s4q9_2=="2515"
	replace s4q9_2="3100" if s4q9_2=="3114"
	replace s4q9_2="3100" if s4q9_2=="3120"
	replace s4q9_2="3100" if s4q9_2=="3152"
	replace s4q9_2="3200" if s4q9_2=="3231"
	replace s4q9_2="3200" if s4q9_2=="3241"
	replace s4q9_2="3300" if s4q9_2=="3317"
	replace s4q9_2="3300" if s4q9_2=="3340"
	replace s4q9_2="3000" if s4q9_2=="3411"
	replace s4q9_2="3000" if s4q9_2=="3413"
	replace s4q9_2="3000" if s4q9_2=="3419"
	replace s4q9_2="3000" if s4q9_2=="3421"
	replace s4q9_2="3000" if s4q9_2=="3423"
	replace s4q9_2="3000" if s4q9_2=="3429"
	replace s4q9_2="3000" if s4q9_2=="3432"
	replace s4q9_2="3000" if s4q9_2=="3434"
	replace s4q9_2="3000" if s4q9_2=="3439"
	replace s4q9_2="3000" if s4q9_2=="3443"
	replace s4q9_2="3000" if s4q9_2=="3449"
	replace s4q9_2="3600" if s4q9_2=="3610"
	*4000 is replaced to 4300 because no 4000
	replace s4q9_2="4300" if s4q9_2=="4000"
	replace s4q9_2="4100" if s4q9_2=="4101"
	replace s4q9_2="4100" if s4q9_2=="4110"
	replace s4q9_2="4100" if s4q9_2=="4111"
	replace s4q9_2="4100" if s4q9_2=="4119"
	replace s4q9_2="4100" if s4q9_2=="4121"
	replace s4q9_2="4100" if s4q9_2=="4137"
	replace s4q9_2="4100" if s4q9_2=="4142"
	replace s4q9_2="4100" if s4q9_2=="4153"
	replace s4q9_2="4100" if s4q9_2=="4162"
	replace s4q9_2="4200" if s4q9_2=="4215"
	replace s4q9_2="4200" if s4q9_2=="4222"
	replace s4q9_2="4200" if s4q9_2=="4231"
	replace s4q9_2="4200" if s4q9_2=="4281"
	replace s4q9_2="4200" if s4q9_2=="4292"
	replace s4q9_2="4200" if s4q9_2=="4299"
	replace s4q9_2="4300" if s4q9_2=="4333"
	*changed to 43 from 44
	replace s4q9_2="4300" if s4q9_2=="4422"
	replace s4q9_2="4500" if s4q9_2=="4521"
	replace s4q9_2="4500" if s4q9_2=="4550"
	replace s4q9_2="4600" if s4q9_2=="4602"
	replace s4q9_2="4600" if s4q9_2=="4619"
	replace s4q9_2="4600" if s4q9_2=="4646"
	replace s4q9_2="4700" if s4q9_2=="4701"
	replace s4q9_2="4700" if s4q9_2=="4709"
	replace s4q9_2="4700" if s4q9_2=="4712"
	replace s4q9_2="4700" if s4q9_2=="4714"
	replace s4q9_2="4700" if s4q9_2=="4717"
	replace s4q9_2="4700" if s4q9_2=="4718"
	replace s4q9_2="4700" if s4q9_2=="4731"
	replace s4q9_2="4700" if s4q9_2=="4733"
	replace s4q9_2="4700" if s4q9_2=="4749"
	replace s4q9_2="4700" if s4q9_2=="4757"
	replace s4q9_2="4700" if s4q9_2=="4775"
	replace s4q9_2="4700" if s4q9_2=="4779"
	replace s4q9_2="4700" if s4q9_2=="4786"
	replace s4q9_2="4700" if s4q9_2=="4787"
	replace s4q9_2="4700" if s4q9_2=="4788"
	replace s4q9_2="4700" if s4q9_2=="4792"
	replace s4q9_2="4700" if s4q9_2=="4794"
	*it was 4800 and I changed to 4300 because there is no 4000
	replace s4q9_2="4300" if s4q9_2=="4820"
	replace s4q9_2="4900" if s4q9_2=="4919"
	replace s4q9_2="4900" if s4q9_2=="4971"
	replace s4q9_2="4900" if s4q9_2=="4974"
	replace s4q9_2="4900" if s4q9_2=="4977"
	replace s4q9_2="4900" if s4q9_2=="4989"
	replace s4q9_2="4900" if s4q9_2=="4999"
	replace s4q9_2="5100" if s4q9_2=="5101"
	replace s4q9_2="5100" if s4q9_2=="5111"
	replace s4q9_2="5100" if s4q9_2=="5112"
	replace s4q9_2="5100" if s4q9_2=="5114"
	replace s4q9_2="5100" if s4q9_2=="5121"
	replace s4q9_2="5100" if s4q9_2=="5122"
	replace s4q9_2="5100" if s4q9_2=="5123"
	replace s4q9_2="5100" if s4q9_2=="5129"
	replace s4q9_2="5100" if s4q9_2=="5131"
	replace s4q9_2="5100" if s4q9_2=="5133"
	replace s4q9_2="5100" if s4q9_2=="5141"
	replace s4q9_2="5100" if s4q9_2=="5149"
	replace s4q9_2="5100" if s4q9_2=="5163"
	replace s4q9_2="5100" if s4q9_2=="5169"
	replace s4q9_2="5100" if s4q9_2=="5190"
	replace s4q9_2="5200" if s4q9_2=="5211"
	replace s4q9_2="5200" if s4q9_2=="5230"
	replace s4q9_2="5200" if s4q9_2=="5232"
	replace s4q9_2="5200" if s4q9_2=="5252"
	replace s4q9_2="5200" if s4q9_2=="5259"
	replace s4q9_2="5300" if s4q9_2=="5325"
	replace s4q9_2="5000" if s4q9_2=="5411"
	replace s4q9_2="5000" if s4q9_2=="5412"
	replace s4q9_2="5600" if s4q9_2=="5623"
	replace s4q9_2="5600" if s4q9_2=="5627"
	replace s4q9_2="5000" if s4q9_2=="5721"
	replace s4q9_2="5000" if s4q9_2=="5773"
	replace s4q9_2="5800" if s4q9_2=="5815"
	replace s4q9_2="5800" if s4q9_2=="5830"
	replace s4q9_2="5900" if s4q9_2=="5929"
	replace s4q9_2="5900" if s4q9_2=="5930"
	replace s4q9_2="6000" if s4q9_2=="6022"
	replace s4q9_2="6000" if s4q9_2=="6023"
	replace s4q9_2="6100" if s4q9_2=="6111"
	replace s4q9_2="6100" if s4q9_2=="6112"
	replace s4q9_2="6100" if s4q9_2=="6113"
	replace s4q9_2="6100" if s4q9_2=="6114"
	replace s4q9_2="6100" if s4q9_2=="6121"
	replace s4q9_2="6100" if s4q9_2=="6122"
	replace s4q9_2="6100" if s4q9_2=="6123"
	replace s4q9_2="6100" if s4q9_2=="6132"
	replace s4q9_2="6100" if s4q9_2=="6142"
	replace s4q9_2="6100" if s4q9_2=="6151"
	replace s4q9_2="6100" if s4q9_2=="6154"
	replace s4q9_2="6200" if s4q9_2=="6210"
	replace s4q9_2="6200" if s4q9_2=="6211"
	replace s4q9_2="6200" if s4q9_2=="6212"
	replace s4q9_2="6200" if s4q9_2=="6222"
	replace s4q9_2="6400" if s4q9_2=="6479"
	replace s4q9_2="6500" if s4q9_2=="6549"
	replace s4q9_2="6000" if s4q9_2=="6712"
	replace s4q9_2="6900" if s4q9_2=="6909"
	replace s4q9_2="6900" if s4q9_2=="6921"
	replace s4q9_2="7100" if s4q9_2=="7111"
	replace s4q9_2="7100" if s4q9_2=="7112"
	replace s4q9_2="7100" if s4q9_2=="7121"
	replace s4q9_2="7100" if s4q9_2=="7122"
	replace s4q9_2="7100" if s4q9_2=="7124"
	replace s4q9_2="7100" if s4q9_2=="7129"
	replace s4q9_2="7100" if s4q9_2=="7131"
	replace s4q9_2="7100" if s4q9_2=="7136"
	replace s4q9_2="7100" if s4q9_2=="7141"
	replace s4q9_2="7200" if s4q9_2=="7211"
	replace s4q9_2="7200" if s4q9_2=="7212"
	replace s4q9_2="7200" if s4q9_2=="7221"
	replace s4q9_2="7200" if s4q9_2=="7223"
	replace s4q9_2="7200" if s4q9_2=="7229"
	replace s4q9_2="7200" if s4q9_2=="7230"
	replace s4q9_2="7200" if s4q9_2=="7231"
	replace s4q9_2="7200" if s4q9_2=="7240"
	replace s4q9_2="7200" if s4q9_2=="7245"
	replace s4q9_2="7200" if s4q9_2=="7292"
	replace s4q9_2="7300" if s4q9_2=="7331"
	replace s4q9_2="7300" if s4q9_2=="7341"
	replace s4q9_2="7400" if s4q9_2=="7411"
	replace s4q9_2="7400" if s4q9_2=="7412"
	replace s4q9_2="7400" if s4q9_2=="7413"
	replace s4q9_2="7400" if s4q9_2=="7415"
	replace s4q9_2="7400" if s4q9_2=="7419"
	replace s4q9_2="7400" if s4q9_2=="7422"
	replace s4q9_2="7400" if s4q9_2=="7423"
	replace s4q9_2="7400" if s4q9_2=="7432"
	replace s4q9_2="7400" if s4q9_2=="7433"
	replace s4q9_2="7400" if s4q9_2=="7435"
	replace s4q9_2="7400" if s4q9_2=="7444"
	replace s4q9_2="7400" if s4q9_2=="7482"
	replace s4q9_2="7400" if s4q9_2=="7499"
	replace s4q9_2="7500" if s4q9_2=="7511"
	replace s4q9_2="7500" if s4q9_2=="7520"
	replace s4q9_2="7500" if s4q9_2=="7523"
	replace s4q9_2="7000" if s4q9_2=="7601"
	replace s4q9_2="8000" if s4q9_2=="8050"
	replace s4q9_2="8000" if s4q9_2=="8052"
	replace s4q9_2="8000" if s4q9_2=="8090"
	replace s4q9_2="8100" if s4q9_2=="8113"
	replace s4q9_2="8200" if s4q9_2=="8222"
	replace s4q9_2="8000" if s4q9_2=="8322"
	replace s4q9_2="8000" if s4q9_2=="8330"
	replace s4q9_2="8400" if s4q9_2=="8424"
	replace s4q9_2="8400" if s4q9_2=="8433"
	replace s4q9_2="8400" if s4q9_2=="8490"
	replace s4q9_2="8500" if s4q9_2=="8511"
	replace s4q9_2="8500" if s4q9_2=="8512"
	replace s4q9_2="8500" if s4q9_2=="8519"
	replace s4q9_2="8500" if s4q9_2=="8531"
	replace s4q9_2="8500" if s4q9_2=="8532"
	replace s4q9_2="8700" if s4q9_2=="8741"
	replace s4q9_2="8800" if s4q9_2=="8821"
	replace s4q9_2="8800" if s4q9_2=="8850"
	replace s4q9_2="8800" if s4q9_2=="8899"
	replace s4q9_2="8000" if s4q9_2=="8920"
	replace s4q9_2="9000" if s4q9_2=="9009"
	replace s4q9_2="9100" if s4q9_2=="9113"
	replace s4q9_2="9100" if s4q9_2=="9121"
	replace s4q9_2="9100" if s4q9_2=="9162"
	replace s4q9_2="9100" if s4q9_2=="9191"
	replace s4q9_2="9100" if s4q9_2=="9199"
	replace s4q9_2="9200" if s4q9_2=="9221"
	replace s4q9_2="9300" if s4q9_2=="9302"
	replace s4q9_2="9500" if s4q9_2=="9502"
	replace s4q9_2="9500" if s4q9_2=="9528"
	replace s4q9_2="9500" if s4q9_2=="9574"
	replace s4q9_2="9600" if s4q9_2=="9606"
	replace s4q9_2="9600" if s4q9_2=="9607"
	replace s4q9_2="9600" if s4q9_2=="9620"
	replace s4q9_2="9600" if s4q9_2=="9662"
	replace s4q9_2="9700" if s4q9_2=="9799"
	replace s4q9_2="9800" if s4q9_2=="9850"
	replace s4q9_2="9900" if s4q9_2=="9902"
	gen industrycat_isic_year = substr(4 * "0", 1, 4 - length( s4q9_2 )) + s4q9_2
	replace industrycat_isic_year="" if industrycat_isic_year=="000."
	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>

*<_industrycat10_year_>
	gen byte industrycat10_year = .
	replace industrycat10_year=1 if inrange(industrycat_isic_year,"0100","0399")
	replace industrycat10_year=2 if inrange(industrycat_isic_year,"0500","0999")
	replace industrycat10_year=3 if inrange(industrycat_isic_year,"1000","3399")
	replace industrycat10_year=4 if inrange(industrycat_isic_year,"3400","3999")
	replace industrycat10_year=5 if inrange(industrycat_isic_year,"4000","4399")
	replace industrycat10_year=6 if inrange(industrycat_isic_year,"4400","4799")
	replace industrycat10_year=7 if inrange(industrycat_isic_year,"4800","5399")
	replace industrycat10_year=6 if inrange(industrycat_isic_year,"5400","5699")
	replace industrycat10_year=7 if inrange(industrycat_isic_year,"5700","6399")
	replace industrycat10_year=8 if inrange(industrycat_isic_year,"6400","6899")
	replace industrycat10_year=8 if inrange(industrycat_isic_year,"6900","7599")
	replace industrycat10_year=8 if inrange(industrycat_isic_year,"7600","8299")
	replace industrycat10_year=9 if inrange(industrycat_isic_year,"8300","8419")
	replace industrycat10_year=9 if inrange(industrycat_isic_year,"8420", "8499")
	replace industrycat10_year=10 if inrange(industrycat_isic_year,"8500","8599")
	replace industrycat10_year=10 if inrange(industrycat_isic_year,"8600","8999")
	replace industrycat10_year=10 if inrange(industrycat_isic_year,"9000","9399")
	replace industrycat10_year=10 if inrange(industrycat_isic_year,"9400","9699")
	replace industrycat10_year=10 if inrange(industrycat_isic_year,"9700","9899")
	replace industrycat10_year=10 if inrange(industrycat_isic_year,"9900","9999")
	label var industrycat10_year "1 digit industry classification, primary job 12 month recall"
	la de lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_year lblindustrycat10_year
*</_industrycat10_year_>


*<_industrycat4_year_>
	gen byte industrycat4_year=industrycat10_year
	recode industrycat4_year (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_year "Broad Economic Activities classification, primary job 12 month recall"
	la de lblindustrycat4_year 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4_year lblindustrycat4_year
*</_industrycat4_year_>


*<_occup_orig_year_>
	gen occup_orig_year = s4q8
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	tostring s3q8, gen(s4q8_2)
	replace s4q8_2="2300" if s4q8_2=="23"
	replace s4q8_2="1000" if s4q8_2=="101"
	replace s4q8_2="1000" if s4q8_2=="102"
	replace s4q8_2="1000" if s4q8_2=="103"
	replace s4q8_2="1000" if s4q8_2=="107"
	replace s4q8_2="1130" if s4q8_2=="113"
	replace s4q8_2="1140" if s4q8_2=="114"
	replace s4q8_2="1310" if s4q8_2=="131"
	replace s4q8_2="1000" if s4q8_2=="146"
	replace s4q8_2="4100" if s4q8_2=="410"
	replace s4q8_2="4110" if s4q8_2=="411"
	replace s4q8_2="4200" if s4q8_2=="429"
	replace s4q8_2="4000" if s4q8_2=="432"
	replace s4q8_2="4000" if s4q8_2=="452"
	replace s4q8_2="4000" if s4q8_2=="471"
	replace s4q8_2="5200" if s4q8_2=="520"
	replace s4q8_2="6110" if s4q8_2=="611"
	replace s4q8_2="6000" if s4q8_2=="692"
	replace s4q8_2="7000" if s4q8_2=="702"
	replace s4q8_2="7110" if s4q8_2=="711"
	replace s4q8_2="7200" if s4q8_2=="729"
	replace s4q8_2="7320" if s4q8_2=="732"
	replace s4q8_2="8000" if s4q8_2=="801"
	replace s4q8_2="8000" if s4q8_2=="802"
	replace s4q8_2="8000" if s4q8_2=="899"
	replace s4q8_2="9000" if s4q8_2=="990"
	replace s4q8_2="1000" if s4q8_2=="1016"
	replace s4q8_2="1000" if s4q8_2=="1017"
	replace s4q8_2="1000" if s4q8_2=="1061"
	replace s4q8_2="1000" if s4q8_2=="1079"
	replace s4q8_2="1100" if s4q8_2=="1101"
	replace s4q8_2="1100" if s4q8_2=="1103"
	replace s4q8_2="1110" if s4q8_2=="1114"
	replace s4q8_2="1120" if s4q8_2=="1122"
	replace s4q8_2="1210" if s4q8_2=="1219"
	replace s4q8_2="1200" if s4q8_2=="1240"
	replace s4q8_2="1300" if s4q8_2=="1341"
	replace s4q8_2="1000" if s4q8_2=="1415"
	replace s4q8_2="1000" if s4q8_2=="1510"
	replace s4q8_2="1000" if s4q8_2=="1514"
	replace s4q8_2="1000" if s4q8_2=="1520"
	replace s4q8_2="1000" if s4q8_2=="1551"
	replace s4q8_2="1000" if s4q8_2=="1620"
	replace s4q8_2="1000" if s4q8_2=="1622"
	replace s4q8_2="1000" if s4q8_2=="1629"
	replace s4q8_2="1000" if s4q8_2=="1711"
	replace s4q8_2="1000" if s4q8_2=="1811"
	replace s4q8_2="1000" if s4q8_2=="1814"
	replace s4q8_2="2110" if s4q8_2=="2119"
	replace s4q8_2="2120" if s4q8_2=="2124"
	replace s4q8_2="2120" if s4q8_2=="2129"
	replace s4q8_2="2210" if s4q8_2=="2216"
	replace s4q8_2="2310" if s4q8_2=="2312"
	replace s4q8_2="2310" if s4q8_2=="2318"
	replace s4q8_2="2320" if s4q8_2=="2321"
	replace s4q8_2="2330" if s4q8_2=="2333"
	replace s4q8_2="2330" if s4q8_2=="2334"
	replace s4q8_2="2342" if s4q8_2=="2342"
	replace s4q8_2="2410" if s4q8_2=="2414"
	replace s4q8_2="2410" if s4q8_2=="2418"
	replace s4q8_2="2430" if s4q8_2=="2433"
	replace s4q8_2="2430" if s4q8_2=="2435"
	replace s4q8_2="2430" if s4q8_2=="2439"
	replace s4q8_2="2000" if s4q8_2=="2599"
	replace s4q8_2="2000" if s4q8_2=="2610"
	replace s4q8_2="2000" if s4q8_2=="2821"
	replace s4q8_2="2000" if s4q8_2=="2957"
	replace s4q8_2="3100" if s4q8_2=="3163"
	replace s4q8_2="3210" if s4q8_2=="3216"
	replace s4q8_2="3210" if s4q8_2=="3218"
	replace s4q8_2="3310" if s4q8_2=="3311"
	replace s4q8_2="3310" if s4q8_2=="3312"
	replace s4q8_2="3310" if s4q8_2=="3319"
	replace s4q8_2="3320" if s4q8_2=="3323"
	replace s4q8_2="3420" if s4q8_2=="3427"
	replace s4q8_2="3430" if s4q8_2=="3437"
	replace s4q8_2="3000" if s4q8_2=="3510"
	replace s4q8_2="3000" if s4q8_2=="3811"
	replace s4q8_2="3000" if s4q8_2=="3812"
	replace s4q8_2="4100" if s4q8_2=="4151"
	replace s4q8_2="4100" if s4q8_2=="4162"
	replace s4q8_2="4220" if s4q8_2=="4226"
	replace s4q8_2="4200" if s4q8_2=="4245"
	replace s4q8_2="4200" if s4q8_2=="4290"
	replace s4q8_2="4000" if s4q8_2=="4311"
	replace s4q8_2="4000" if s4q8_2=="4322"
	replace s4q8_2="4000" if s4q8_2=="4330"
	replace s4q8_2="4000" if s4q8_2=="4520"
	replace s4q8_2="4000" if s4q8_2=="4551"
	replace s4q8_2="4000" if s4q8_2=="4661"
	replace s4q8_2="4000" if s4q8_2=="4711"
	replace s4q8_2="4000" if s4q8_2=="4715"
	replace s4q8_2="4000" if s4q8_2=="4719"
	replace s4q8_2="4000" if s4q8_2=="4721"
	replace s4q8_2="4000" if s4q8_2=="4722"
	replace s4q8_2="4000" if s4q8_2=="4733"
	replace s4q8_2="4000" if s4q8_2=="4751"
	replace s4q8_2="4000" if s4q8_2=="4759"
	replace s4q8_2="4000" if s4q8_2=="4771"
	replace s4q8_2="4000" if s4q8_2=="4772"
	replace s4q8_2="4000" if s4q8_2=="4774"
	replace s4q8_2="4000" if s4q8_2=="4779"
	replace s4q8_2="4000" if s4q8_2=="4781"
	replace s4q8_2="4000" if s4q8_2=="4789"
	replace s4q8_2="4000" if s4q8_2=="4799"
	replace s4q8_2="4000" if s4q8_2=="4921"
	replace s4q8_2="4000" if s4q8_2=="4922"
	replace s4q8_2="4000" if s4q8_2=="4923"
	replace s4q8_2="5000" if s4q8_2=="5010"
	replace s4q8_2="5100" if s4q8_2=="5102"
	replace s4q8_2="5100" if s4q8_2=="5109"
	replace s4q8_2="5110" if s4q8_2=="5114"
	replace s4q8_2="5110" if s4q8_2=="5115"
	replace s4q8_2="5110" if s4q8_2=="5116"
	replace s4q8_2="5120" if s4q8_2=="5124"
	replace s4q8_2="5120" if s4q8_2=="5128"
	replace s4q8_2="5120" if s4q8_2=="5129"
	replace s4q8_2="5120" if s4q8_2=="5144"
	replace s4q8_2="5140" if s4q8_2=="5145"
	replace s4q8_2="5140" if s4q8_2=="5147"
	replace s4q8_2="5150" if s4q8_2=="5159"
	replace s4q8_2="5160" if s4q8_2=="5164"
	replace s4q8_2="5160" if s4q8_2=="5168"
	replace s4q8_2="5170" if s4q8_2=="5171"
	replace s4q8_2="5170" if s4q8_2=="5172"
	replace s4q8_2="5190" if s4q8_2=="5191"
	replace s4q8_2="5190" if s4q8_2=="5196"
	replace s4q8_2="5190" if s4q8_2=="5198"
	replace s4q8_2="5200" if s4q8_2=="5204"
	replace s4q8_2="5210" if s4q8_2=="5212"
	replace s4q8_2="5210" if s4q8_2=="5214"
	replace s4q8_2="5220" if s4q8_2=="5221"
	replace s4q8_2="5220" if s4q8_2=="5222"
	replace s4q8_2="5220" if s4q8_2=="5223"
	replace s4q8_2="5220" if s4q8_2=="5225"
	replace s4q8_2="5220" if s4q8_2=="5229"
	replace s4q8_2="5230" if s4q8_2=="5232"
	replace s4q8_2="5230" if s4q8_2=="5234"
	replace s4q8_2="5200" if s4q8_2=="5250"
	replace s4q8_2="5200" if s4q8_2=="5253"
	replace s4q8_2="5200" if s4q8_2=="5259"
	replace s4q8_2="5200" if s4q8_2=="5260"
	replace s4q8_2="5200" if s4q8_2=="5262"
	replace s4q8_2="5200" if s4q8_2=="5270"
	replace s4q8_2="5200" if s4q8_2=="5280"
	replace s4q8_2="5000" if s4q8_2=="5320"
	replace s4q8_2="5000" if s4q8_2=="5330"
	replace s4q8_2="5000" if s4q8_2=="5419"
	replace s4q8_2="5000" if s4q8_2=="5441"
	replace s4q8_2="5000" if s4q8_2=="5520"
	replace s4q8_2="5000" if s4q8_2=="5613"
	replace s4q8_2="5000" if s4q8_2=="5629"
	replace s4q8_2="5000" if s4q8_2=="5721"
	replace s4q8_2="5000" if s4q8_2=="5811"
	replace s4q8_2="5000" if s4q8_2=="5920"
	replace s4q8_2="5000" if s4q8_2=="5969"
	replace s4q8_2="6110" if s4q8_2=="6116"
	replace s4q8_2="6130" if s4q8_2=="6131"
	replace s4q8_2="6130" if s4q8_2=="6132"
	replace s4q8_2="6130" if s4q8_2=="6133"
	replace s4q8_2="6130" if s4q8_2=="6134"
	replace s4q8_2="6130" if s4q8_2=="6136"
	replace s4q8_2="6140" if s4q8_2=="6145"
	replace s4q8_2="6140" if s4q8_2=="6149"
	replace s4q8_2="6100" if s4q8_2=="6171"
	replace s4q8_2="6100" if s4q8_2=="6174"
	replace s4q8_2="6100" if s4q8_2=="6190"
	replace s4q8_2="6200" if s4q8_2=="6201"
	replace s4q8_2="6210" if s4q8_2=="6211"
	replace s4q8_2="6210" if s4q8_2=="6212"
	replace s4q8_2="6210" if s4q8_2=="6214"
	replace s4q8_2="6210" if s4q8_2=="6216"
	replace s4q8_2="6200" if s4q8_2=="6221"
	replace s4q8_2="6200" if s4q8_2=="6230"
	replace s4q8_2="6230" if s4q8_2=="6231"
	replace s4q8_2="6230" if s4q8_2=="6232"
	replace s4q8_2="6200" if s4q8_2=="6240"
	replace s4q8_2="6200" if s4q8_2=="6242"
	replace s4q8_2="6200" if s4q8_2=="6250"
	replace s4q8_2="6200" if s4q8_2=="6251"
	replace s4q8_2="6200" if s4q8_2=="6252"
	replace s4q8_2="6200" if s4q8_2=="6269"
	replace s4q8_2="6000" if s4q8_2=="6311"
	replace s4q8_2="6000" if s4q8_2=="6321"
	replace s4q8_2="6000" if s4q8_2=="6415"
	replace s4q8_2="6000" if s4q8_2=="6420"
	replace s4q8_2="6000" if s4q8_2=="6510"
	replace s4q8_2="6000" if s4q8_2=="6621"
	replace s4q8_2="6000" if s4q8_2=="6710"
	replace s4q8_2="6000" if s4q8_2=="6820"
	replace s4q8_2="6000" if s4q8_2=="6920"
	replace s4q8_2="6000" if s4q8_2=="6921"
	replace s4q8_2="7110" if s4q8_2=="7114"
	replace s4q8_2="7110" if s4q8_2=="7115"
	replace s4q8_2="7110" if s4q8_2=="7126"
	replace s4q8_2="7120" if s4q8_2=="7127"
	replace s4q8_2="7100" if s4q8_2=="7151"
	replace s4q8_2="7100" if s4q8_2=="7152"
	replace s4q8_2="7100" if s4q8_2=="7159"
	replace s4q8_2="7100" if s4q8_2=="7162"
	replace s4q8_2="7100" if s4q8_2=="7181"
	replace s4q8_2="7100" if s4q8_2=="7196"
	replace s4q8_2="7210" if s4q8_2=="7217"
	replace s4q8_2="7210" if s4q8_2=="7219"
	replace s4q8_2="7230" if s4q8_2=="7234"
	replace s4q8_2="7330" if s4q8_2=="7334"
	replace s4q8_2="7400" if s4q8_2=="7403"
	replace s4q8_2="7420" if s4q8_2=="7426"
	replace s4q8_2="7440" if s4q8_2=="7444"
	replace s4q8_2="7400" if s4q8_2=="7451"
	replace s4q8_2="7400" if s4q8_2=="7452"
	replace s4q8_2="7400" if s4q8_2=="7455"
	replace s4q8_2="7400" if s4q8_2=="7490"
	replace s4q8_2="7000" if s4q8_2=="7510"
	replace s4q8_2="7000" if s4q8_2=="7515"
	replace s4q8_2="7000" if s4q8_2=="7520"
	replace s4q8_2="7000" if s4q8_2=="7522"
	replace s4q8_2="7000" if s4q8_2=="7535"
	replace s4q8_2="7000" if s4q8_2=="7729"
	replace s4q8_2="7000" if s4q8_2=="7845"
	replace s4q8_2="7000" if s4q8_2=="7911"
	replace s4q8_2="8000" if s4q8_2=="8010"
	replace s4q8_2="8000" if s4q8_2=="8020"
	replace s4q8_2="8110" if s4q8_2=="8114"
	replace s4q8_2="8120" if s4q8_2=="8129"
	replace s4q8_2="8230" if s4q8_2=="8233"
	replace s4q8_2="8290" if s4q8_2=="8292"
	replace s4q8_2="8000" if s4q8_2=="8412"
	replace s4q8_2="8000" if s4q8_2=="8422"
	replace s4q8_2="8000" if s4q8_2=="8423"
	replace s4q8_2="8000" if s4q8_2=="8425"
	replace s4q8_2="8000" if s4q8_2=="8430"
	replace s4q8_2="8000" if s4q8_2=="8510"
	replace s4q8_2="8000" if s4q8_2=="8521"
	replace s4q8_2="8000" if s4q8_2=="8549"
	replace s4q8_2="8000" if s4q8_2=="8610"
	replace s4q8_2="8000" if s4q8_2=="8620"
	replace s4q8_2="8000" if s4q8_2=="8890"
	replace s4q8_2="8000" if s4q8_2=="8922"
	replace s4q8_2="9100" if s4q8_2=="9123"
	replace s4q8_2="9130" if s4q8_2=="9134"
	replace s4q8_2="9130" if s4q8_2=="9139"
	replace s4q8_2="9100" if s4q8_2=="9191"
	replace s4q8_2="9200" if s4q8_2=="9220"
	replace s4q8_2="9300" if s4q8_2=="9309"
	replace s4q8_2="9000" if s4q8_2=="9521"
	replace s4q8_2="9000" if s4q8_2=="9522"
	replace s4q8_2="9000" if s4q8_2=="9602"
	replace s4q8_2="9000" if s4q8_2=="9609"
	replace s4q8_2="9000" if s4q8_2=="9621"
	replace s4q8_2="9000" if s4q8_2=="9700"
	replace s4q8_2="9000" if s4q8_2=="9810"

	replace s4q8_2="2340" if s4q8_2=="2342"
	replace s4q8_2="5100" if s4q8_2=="5170"
	replace s4q8_2="5100" if s4q8_2=="5190"
	replace s4q8_2="6200" if s4q8_2=="6230"
	gen occup_isco_year = s4q8_2 + substr("0000", 1, 4 - length(s4q8_2))
	replace occup_isco_year="" if occup_isco_year==".000"
	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_year_>
	gen byte occup_year = .
	replace occup_year=1 if inrange(occup_isco_year,"1000","1399")
	replace occup_year=2 if inrange(occup_isco_year,"2000","2499")
	replace occup_year=3 if inrange(occup_isco_year,"3000","3499")
	replace occup_year=4 if inrange(occup_isco_year,"4000","4299")
	replace occup_year=5 if inrange(occup_isco_year,"5000","5299")
	replace occup_year=6 if inrange(occup_isco_year,"6000","6299")
	replace occup_year=7 if inrange(occup_isco_year,"7000","7499")
	replace occup_year=8 if inrange(occup_isco_year,"8000","8399")
	replace occup_year=9 if inrange(occup_isco_year,"9000","9399")
	replace occup_year=10 if inrange(occup_isco_year,"0000","0999")
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
	gen byte unitwage_year = 1
	label var unitwage_year "Last wages' time unit primary job 12 month recall"
	la de lblunitwage_year 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_year lblunitwage_year
*</_unitwage_year_>


*<_whours_year_>
	gen whours_year = s4q17
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
	replace contract_year=1 if inrange(s4q10,1,5) & lstatus==1
	replace contract_year=0 if s4q10==. & lstatus==1
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
	gen byte socialsec_year = s4q13
	recode socialsec_year 2=0 9=.
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
	gen industrycat_isic_2_year = .
	label var industrycat_isic_2_year "ISIC code of secondary job 12 month recall"
*</_industrycat_isic_2_year_>


*<_industrycat10_2_year_>
	gen byte industrycat10_2_year = .
	label var industrycat10_2_year "1 digit industry classification, secondary job 12 month recall"
	label values industrycat10_2_year lblindustrycat10_year
*</_industrycat10_2_year_>


*<_industrycat4_2_year_>
	gen byte industrycat4_2_year=industrycat10_2_year
	recode industrycat4_2_year (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
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
	gen njobs = .
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
	local lab_var "minlaborage lstatus nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome"

	foreach v of local lab_var {
		cap confirm numeric variable `v'
		if _rc == 0 { // is indeed numeric
			replace `v'=. if ( age < minlaborage & !missing(age) )
		}
		else { // is not
			replace `v'= "" if ( age < minlaborage & !missing(age) )
		}

	}

*</_% Correction min age_>
}


/*%%=============================================================================================
	9: Final steps
==============================================================================================%%*/

quietly{

*<_% KEEP VARIABLES - ALL_>

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

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

foreach var of local kept_vars {
   capture assert missing(`var')
   if !_rc drop `var'
}

*</_% DELETE MISSING VARIABLES_>


*<_% COMPRESS_>

compress

*</_% COMPRESS_>


*<_% SAVE_>

save "`path_output'/`out_file'", replace

*</_% SAVE_>
