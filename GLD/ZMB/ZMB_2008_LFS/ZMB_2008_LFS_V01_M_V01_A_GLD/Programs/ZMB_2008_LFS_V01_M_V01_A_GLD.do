
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
use "`path_in_stata'/zmb_raw_2008_lfs.dta"

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
	bys hhid : gen hsize = _N
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
	*rename literacy literacy_1
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
	replace lstatus=1 if s3q1 < 4 | s3q2 == 1 | s3q3 == 1 | s3q4 == 1 | s3q5 == 1 | s3q6 == 1
	replace lstatus=2 if s6q1 == 1 & s6q3 == 1 & mi(lstatus)
	replace lstatus=3 if mi(lstatus)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = 0
	replace potential_lf = 1 if (s6q1 == 2 & s6q3 == 1) | (s6q1 == 1 & s6q3 == 2)
	replace potential_lf = . if age < minlaborage 
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
	replace unempldur_l = . if lstatus != 2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=s6q6
	recode unempldur_u 1=2 2=5 3=11 4=35 5=.
	replace unempldur_u = . if lstatus != 2
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

	gen str industrycat_isic     = string(s3q9, "%04.0f")
	replace industrycat_isic = "" if industrycat_isic == "."
	
	* Corrections - based on the ISIC Code and looking at the ISCO for consistency
	replace industrycat_isic = "0110" if s3q9 == 101
	replace industrycat_isic = "0720" if s3q9 == 702
	replace industrycat_isic = "0100" if s3q9 == 6210 & inlist(s3q8,6210,6211)
	replace industrycat_isic = ""     if s3q9 == 6210 & !inlist(s3q8,6210,6211)
	replace industrycat_isic = "0110" if s3q9 == 1111
	replace industrycat_isic = "0110" if s3q9 == 151
	replace industrycat_isic = "0810" if s3q9 == 801
	replace industrycat_isic = "0100" if s3q9 == 6114 & inrange(s3q8, 6114,6210)
	replace industrycat_isic = ""     if s3q9 == 6114 & !inrange(s3q8, 6114,6210)
	replace industrycat_isic = "0150" if s3q9 == 1505
	replace industrycat_isic = "0100" if s3q9 == 6111 &  inrange(s3q8, 6111,6210)
	replace industrycat_isic = ""     if s3q9 == 6111 & !inrange(s3q8, 6111,6210)
	replace industrycat_isic = "0113" if s3q9 == 1113
	replace industrycat_isic = "9600" if s3q9 == 9606
	replace industrycat_isic = "0150" if s3q9 == 1501
	replace industrycat_isic = "0100" if inrange(s3q9,102,107) & inrange(s3q8, 6100,6299)
	replace industrycat_isic = ""     if inrange(s3q9,102,107) & !inrange(s3q8, 6100,6299)
	replace industrycat_isic = "0100" if s3q9 == 1115 & inrange(s3q8, 6100,6299)
	replace industrycat_isic = "4920" if s3q9 == 492
	
	* Other cases cannot assess. Set to missing.
	replace industrycat_isic = "" if inlist(s3q9,902, 5230, 2419, 211, 812, 5149, 191, 152)
	replace industrycat_isic = "" if inlist(s3q9, 5121, 1110, 2331, 6142, 5121)
	replace industrycat_isic = "" if inlist(s3q9,11, 56, 118, 132, 133, 154, 155, 158, 159)
	replace industrycat_isic = "" if inlist(s3q9,171, 172, 173, 181, 182, 192, 201, 202, 219)
	replace industrycat_isic = "" if inlist(s3q9,222, 229, 232, 250, 259, 279, 280, 301, 371)
	replace industrycat_isic = "" if inlist(s3q9,401, 410, 411, 421, 471, 472, 478, 479, 481)
	replace industrycat_isic = "" if inlist(s3q9,490, 501, 522, 530, 562, 571, 574, 601, 622)
	replace industrycat_isic = "" if inlist(s3q9,631, 661, 701, 703, 711, 727, 730, 732, 759)
	replace industrycat_isic = "" if inlist(s3q9,772, 780, 852, 911, 929, 933, 969, 1001, 1011)
	replace industrycat_isic = "" if inlist(s3q9,1016, 1017, 1021, 1029, 1051, 1108, 1112, 1117, 1119)
	replace industrycat_isic = "" if inlist(s3q9,1132, 1134, 1135, 1141, 1157, 1221, 1226, 1291, 1295)
	replace industrycat_isic = "" if inlist(s3q9,1319, 1412, 1472, 1499, 1502, 1504, 1541, 1609, 1624)
	replace industrycat_isic = "" if inlist(s3q9,1626, 1628, 1642, 1659, 1712, 1749, 1821, 2015, 2032)
	replace industrycat_isic = "" if inlist(s3q9,2104, 2122, 2131, 2143, 2214, 2224, 2312, 2319, 2321)
	replace industrycat_isic = "" if inlist(s3q9,2332, 2411, 2412, 2422, 2460, 2479, 2515, 3114, 3118)
	replace industrycat_isic = "" if inlist(s3q9,3120, 3122, 3124, 3152, 3231, 3241, 3317, 3340, 3411)
	replace industrycat_isic = "" if inlist(s3q9,3413, 3419, 3421, 3423, 3429, 3432, 3434, 3439, 3443)
	replace industrycat_isic = "" if inlist(s3q9,3449, 3610, 4000, 4101, 4110, 4111, 4119, 4121, 4137)
	replace industrycat_isic = "" if inlist(s3q9,4142, 4153, 4162, 4215, 4222, 4231, 4281, 4292, 4299)
	replace industrycat_isic = "" if inlist(s3q9,4333, 4422, 4521, 4550, 4602, 4619, 4646, 4701, 4709)
	replace industrycat_isic = "" if inlist(s3q9,4712, 4714, 4717, 4718, 4731, 4733, 4749, 4757, 4775)
	replace industrycat_isic = "" if inlist(s3q9,4779, 4786, 4787, 4788, 4792, 4794, 4820, 4919, 4971)
	replace industrycat_isic = "" if inlist(s3q9,4974, 4977, 4989, 4999, 5029, 5101, 5111, 5112, 5114)
	replace industrycat_isic = "" if inlist(s3q9,5122, 5123, 5129, 5131, 5133, 5141, 5151, 5163, 5169)
	replace industrycat_isic = "" if inlist(s3q9,5190, 5211, 5232, 5252, 5259, 5325, 5411, 5412, 5623)
	replace industrycat_isic = "" if inlist(s3q9,5627, 5721, 5773, 5815, 5830, 5929, 5930, 6021, 6022)
	replace industrycat_isic = "" if inlist(s3q9,6023, 6112, 6113, 6121, 6122, 6123, 6132, 6151, 6154)
	replace industrycat_isic = "" if inlist(s3q9,6211, 6212, 6222, 6230, 6479, 6549, 6712, 6909, 6921)
	replace industrycat_isic = "" if inlist(s3q9,7111, 7112, 7121, 7122, 7124, 7129, 7131, 7136, 7141)
	replace industrycat_isic = "" if inlist(s3q9,7211, 7212, 7221, 7223, 7229, 7230, 7231, 7240, 7245)
	replace industrycat_isic = "" if inlist(s3q9,7292, 7331, 7341, 7411, 7412, 7413, 7415, 7419, 7422)
	replace industrycat_isic = "" if inlist(s3q9,7423, 7432, 7433, 7435, 7436, 7444, 7482, 7499, 7511)
	replace industrycat_isic = "" if inlist(s3q9,7520, 7523, 7601, 8050, 8052, 8090, 8103, 8105, 8113)
	replace industrycat_isic = "" if inlist(s3q9,8222, 8322, 8330, 8424, 8433, 8490, 8511, 8512, 8519)
	replace industrycat_isic = "" if inlist(s3q9,8531, 8532, 8741, 8821, 8850, 8899, 8920, 8991, 9009)
	replace industrycat_isic = "" if inlist(s3q9,9113, 9121, 9162, 9191, 9199, 9221, 9302, 9419, 9441)
	replace industrycat_isic = "" if inlist(s3q9,9502, 9528, 9574, 9607, 9608, 9610, 9620, 9662, 9799)
	replace industrycat_isic = "" if inlist(s3q9,9812, 9826, 9830, 9850, 9902)
	
	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	
	preserve 
	int_classif_universe, var(industrycat_isic) universe(ISIC)
	count
	*list
	assert `r(N)' == 0
	restore 

	replace industrycat_isic = "" if lstatus != 1
	label var industrycat_isic "ISIC code of primary job 7 day recall"
	
*</_industrycat_isic_>


*<_industrycat10_>
	gen byte industrycat10 = .
	replace industrycat10=1 if inrange(industrycat_isic,"0100","0399")
	replace industrycat10=2 if inrange(industrycat_isic,"0500","0999")
	replace industrycat10=3 if inrange(industrycat_isic,"1000","3399")
	replace industrycat10=4 if inrange(industrycat_isic,"3500","3999")
	replace industrycat10=5 if inrange(industrycat_isic,"4100","4399")
	replace industrycat10=6 if inrange(industrycat_isic,"4500","4799")
	replace industrycat10=6 if inrange(industrycat_isic,"5500","5699")
	replace industrycat10=7 if inrange(industrycat_isic,"4900","5399")
	replace industrycat10=7 if inrange(industrycat_isic,"5800","6399")
	replace industrycat10=8 if inrange(industrycat_isic,"6400","8299")
	replace industrycat10=9 if inrange(industrycat_isic,"8400", "8499")
	replace industrycat10=10 if inrange(industrycat_isic,"8500","9999")
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
	gen str occup_isco = string(s3q8,     "%04.0f")
	replace occup_isco = "" if occup_isco == "." 
	
	* Corrections - based on the ISIC Code and looking at the ISCO for consistency
	replace occup_isco = "6130" if s3q8 == 6132
	replace occup_isco = "2300" if s3q8 == 2321 &  inrange(s3q9, 8500,8599)
	replace occup_isco = ""     if s3q8 == 2321 & !inrange(s3q9, 8500,8599)
	replace occup_isco = "6100" if s3q8 == 6133 &  inrange(s3q9,  101, 161)
	replace occup_isco = ""     if s3q8 == 6133 & !inrange(s3q9,  101, 161)
	replace occup_isco = "6100" if s3q8 == 6211
	replace occup_isco = "7200" if s3q8 == 7234
	replace occup_isco = "2400" if s3q8 == 2418
	replace occup_isco = "5100" if s3q8 == 5114
	replace occup_isco = "9300" if s3q8 == 9309
	
	* Set to missing cases we cannot sensibly re-code 
	replace occup_isco = "" if inlist(s3q8, 7510, 7520, 4711, 4799, 1240, 8510)
	replace occup_isco = "" if inlist(s3q8,23, 101, 102, 103, 107, 112, 113, 114, 131)
	replace occup_isco = "" if inlist(s3q8,146, 162, 410, 411, 429, 432, 452, 471, 520)
	replace occup_isco = "" if inlist(s3q8,611, 692, 702, 711, 729, 732, 801, 802, 899)
	replace occup_isco = "" if inlist(s3q8,990, 1016, 1017, 1061, 1079, 1101, 1103, 1114, 1122)
	replace occup_isco = "" if inlist(s3q8,1219, 1341, 1391, 1415, 1510, 1514, 1520, 1551, 1620)
	replace occup_isco = "" if inlist(s3q8,1622, 1629, 1711, 1811, 1814, 2119, 2124, 2129, 2214)
	replace occup_isco = "" if inlist(s3q8,2216, 2312, 2318, 2333, 2334, 2342, 2414, 2433, 2435)
	replace occup_isco = "" if inlist(s3q8,2439, 2499, 2599, 2610, 2821, 2957, 3163, 3216, 3218)
	replace occup_isco = "" if inlist(s3q8,3311, 3312, 3319, 3323, 3427, 3437, 3510, 3811, 3812)
	replace occup_isco = "" if inlist(s3q8,4151, 4162, 4226, 4245, 4290, 4311, 4322, 4330, 4520)
	replace occup_isco = "" if inlist(s3q8,4551, 4661, 4715, 4719, 4721, 4722, 4733, 4751, 4759)
	replace occup_isco = "" if inlist(s3q8,4771, 4772, 4774, 4779, 4781, 4782, 4789, 4921, 4922)
	replace occup_isco = "" if inlist(s3q8,4923, 5010, 5102, 5109, 5115, 5116, 5124, 5128, 5129)
	replace occup_isco = "" if inlist(s3q8,5144, 5145, 5147, 5159, 5164, 5168, 5171, 5172, 5182)
	replace occup_isco = "" if inlist(s3q8,5191, 5196, 5198, 5201, 5204, 5212, 5214, 5221, 5222)
	replace occup_isco = "" if inlist(s3q8,5223, 5225, 5229, 5232, 5233, 5234, 5250, 5253, 5259)
	replace occup_isco = "" if inlist(s3q8,5260, 5262, 5270, 5280, 5320, 5330, 5419, 5441, 5520)
	replace occup_isco = "" if inlist(s3q8,5613, 5629, 5721, 5811, 5920, 5969, 6101, 6115, 6116)
	replace occup_isco = "" if inlist(s3q8,6119, 6131, 6134, 6136, 6137, 6144, 6145, 6149, 6169)
	replace occup_isco = "" if inlist(s3q8,6171, 6174, 6190, 6201, 6212, 6213, 6214, 6216, 6221)
	replace occup_isco = "" if inlist(s3q8,6230, 6231, 6232, 6240, 6242, 6250, 6251, 6252, 6269)
	replace occup_isco = "" if inlist(s3q8,6311, 6321, 6415, 6420, 6510, 6621, 6710, 6820, 6920)
	replace occup_isco = "" if inlist(s3q8,6921, 7114, 7115, 7126, 7127, 7151, 7152, 7159, 7162)
	replace occup_isco = "" if inlist(s3q8,7181, 7196, 7217, 7219, 7334, 7403, 7426, 7444, 7451)
	replace occup_isco = "" if inlist(s3q8,7452, 7455, 7490, 7515, 7522, 7535, 7729, 7845, 7911)
	replace occup_isco = "" if inlist(s3q8,8010, 8020, 8114, 8129, 8233, 8292, 8412, 8422, 8423)
	replace occup_isco = "" if inlist(s3q8,8425, 8430, 8521, 8549, 8610, 8620, 8790, 8890, 8922)
	replace occup_isco = "" if inlist(s3q8,9123, 9134, 9139, 9191, 9220, 9521, 9522, 9602, 9609)
	replace occup_isco = "" if inlist(s3q8,9621, 9700, 9731, 9810)

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	
	preserve 
	int_classif_universe, var(occup_isco) universe(ISCO)
	count
	*list
	assert `r(N)' == 0
	restore 
	
	replace occup_isco = "" if lstatus != 1
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
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
	* Info in survey is at day level, we want week. Reduce to missing values > 24
	* Assume 5 days per week 
	gen whours = s3q17*5 if s3q17 <= 24
	replace whours = . if lstatus != 1
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
	* There is no information on unemployment at 12 months. Can only state it employed.
	gen byte lstatus_year = .
	replace lstatus_year  = 1 if s3q1 < 4 | s3q2 == 1 | s3q3 == 1 | s3q4 == 1 | s3q5 == 1 | s3q6 == 1
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
	replace empstat_year = . if lstatus_year != 1
	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>

*<_ocusec_year_>
	gen byte ocusec_year = s4q11
	recode ocusec_year 2=1 4=2 5=2 6=2 7=2
	replace ocusec_year = . if lstatus_year != 1
	label var ocusec_year "Sector of activity primary job 12 month recall"
	la de lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_year lblocusec_year
*</_ocusec_year_>

*<_industry_orig_year_>
	gen industry_orig_year = s4q9
	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	gen str industrycat_isic_year     = string(s4q9, "%04.0f")
	replace industrycat_isic_year = "" if industrycat_isic_year == "."
	
	* Corrections - based on the ISIC Code and looking at the ISCO for consistency
	replace industrycat_isic_year = "0110" if s4q9 == 101
	replace industrycat_isic_year = "0720" if s4q9 == 702
	replace industrycat_isic_year = "0100" if s4q9 == 6210 & inlist(s4q8,6210,6211)
	replace industrycat_isic_year = ""     if s4q9 == 6210 & !inlist(s4q8,6210,6211)
	replace industrycat_isic_year = "0110" if s4q9 == 1111
	replace industrycat_isic_year = "0110" if s4q9 == 151
	replace industrycat_isic_year = "0810" if s4q9 == 801
	replace industrycat_isic_year = "0100" if s4q9 == 6114 & inrange(s4q8, 6114,6210)
	replace industrycat_isic_year = ""     if s4q9 == 6114 & !inrange(s4q8, 6114,6210)
	replace industrycat_isic_year = "0150" if s4q9 == 1505
	replace industrycat_isic_year = "0100" if s4q9 == 6111 &  inrange(s4q8, 6111,6210)
	replace industrycat_isic_year = ""     if s4q9 == 6111 & !inrange(s4q8, 6111,6210)
	replace industrycat_isic_year = "0113" if s4q9 == 1113
	replace industrycat_isic_year = "9600" if s4q9 == 9606
	replace industrycat_isic_year = "0150" if s4q9 == 1501
	replace industrycat_isic_year = "0100" if inrange(s4q9,102,107) & inrange(s4q8, 6100,6299)
	replace industrycat_isic_year = ""     if inrange(s4q9,102,107) & !inrange(s4q8, 6100,6299)
	replace industrycat_isic_year = "0100" if s4q9 == 1115 & inrange(s4q8, 6100,6299)
	replace industrycat_isic_year = "4920" if s4q9 == 492
	
	* Other cases cannot assess. Set to missing.
	replace industrycat_isic_year = "" if inlist(s4q9,902, 5230, 2419, 211, 812, 5149, 191, 152)
	replace industrycat_isic_year = "" if inlist(s4q9, 5121, 1110, 2331, 6142, 5121)
	replace industrycat_isic_year = "" if inlist(s4q9,11, 56, 118, 132, 133, 154, 155, 158, 159)
	replace industrycat_isic_year = "" if inlist(s4q9,171, 172, 173, 181, 182, 192, 201, 202, 219)
	replace industrycat_isic_year = "" if inlist(s4q9,222, 229, 232, 250, 259, 279, 280, 301, 371)
	replace industrycat_isic_year = "" if inlist(s4q9,401, 410, 411, 421, 471, 472, 478, 479, 481)
	replace industrycat_isic_year = "" if inlist(s4q9,490, 501, 522, 530, 562, 571, 574, 601, 622)
	replace industrycat_isic_year = "" if inlist(s4q9,631, 661, 701, 703, 711, 727, 730, 732, 759)
	replace industrycat_isic_year = "" if inlist(s4q9,772, 780, 852, 911, 929, 933, 969, 1001, 1011)
	replace industrycat_isic_year = "" if inlist(s4q9,1016, 1017, 1021, 1029, 1051, 1108, 1112, 1117, 1119)
	replace industrycat_isic_year = "" if inlist(s4q9,1132, 1134, 1135, 1141, 1157, 1221, 1226, 1291, 1295)
	replace industrycat_isic_year = "" if inlist(s4q9,1319, 1412, 1472, 1499, 1502, 1504, 1541, 1609, 1624)
	replace industrycat_isic_year = "" if inlist(s4q9,1626, 1628, 1642, 1659, 1712, 1749, 1821, 2015, 2032)
	replace industrycat_isic_year = "" if inlist(s4q9,2104, 2122, 2131, 2143, 2214, 2224, 2312, 2319, 2321)
	replace industrycat_isic_year = "" if inlist(s4q9,2332, 2411, 2412, 2422, 2460, 2479, 2515, 3114, 3118)
	replace industrycat_isic_year = "" if inlist(s4q9,3120, 3122, 3124, 3152, 3231, 3241, 3317, 3340, 3411)
	replace industrycat_isic_year = "" if inlist(s4q9,3413, 3419, 3421, 3423, 3429, 3432, 3434, 3439, 3443)
	replace industrycat_isic_year = "" if inlist(s4q9,3449, 3610, 4000, 4101, 4110, 4111, 4119, 4121, 4137)
	replace industrycat_isic_year = "" if inlist(s4q9,4142, 4153, 4162, 4215, 4222, 4231, 4281, 4292, 4299)
	replace industrycat_isic_year = "" if inlist(s4q9,4333, 4422, 4521, 4550, 4602, 4619, 4646, 4701, 4709)
	replace industrycat_isic_year = "" if inlist(s4q9,4712, 4714, 4717, 4718, 4731, 4733, 4749, 4757, 4775)
	replace industrycat_isic_year = "" if inlist(s4q9,4779, 4786, 4787, 4788, 4792, 4794, 4820, 4919, 4971)
	replace industrycat_isic_year = "" if inlist(s4q9,4974, 4977, 4989, 4999, 5029, 5101, 5111, 5112, 5114)
	replace industrycat_isic_year = "" if inlist(s4q9,5122, 5123, 5129, 5131, 5133, 5141, 5151, 5163, 5169)
	replace industrycat_isic_year = "" if inlist(s4q9,5190, 5211, 5232, 5252, 5259, 5325, 5411, 5412, 5623)
	replace industrycat_isic_year = "" if inlist(s4q9,5627, 5721, 5773, 5815, 5830, 5929, 5930, 6021, 6022)
	replace industrycat_isic_year = "" if inlist(s4q9,6023, 6112, 6113, 6121, 6122, 6123, 6132, 6151, 6154)
	replace industrycat_isic_year = "" if inlist(s4q9,6211, 6212, 6222, 6230, 6479, 6549, 6712, 6909, 6921)
	replace industrycat_isic_year = "" if inlist(s4q9,7111, 7112, 7121, 7122, 7124, 7129, 7131, 7136, 7141)
	replace industrycat_isic_year = "" if inlist(s4q9,7211, 7212, 7221, 7223, 7229, 7230, 7231, 7240, 7245)
	replace industrycat_isic_year = "" if inlist(s4q9,7292, 7331, 7341, 7411, 7412, 7413, 7415, 7419, 7422)
	replace industrycat_isic_year = "" if inlist(s4q9,7423, 7432, 7433, 7435, 7436, 7444, 7482, 7499, 7511)
	replace industrycat_isic_year = "" if inlist(s4q9,7520, 7523, 7601, 8050, 8052, 8090, 8103, 8105, 8113)
	replace industrycat_isic_year = "" if inlist(s4q9,8222, 8322, 8330, 8424, 8433, 8490, 8511, 8512, 8519)
	replace industrycat_isic_year = "" if inlist(s4q9,8531, 8532, 8741, 8821, 8850, 8899, 8920, 8991, 9009)
	replace industrycat_isic_year = "" if inlist(s4q9,9113, 9121, 9162, 9191, 9199, 9221, 9302, 9419, 9441)
	replace industrycat_isic_year = "" if inlist(s4q9,9502, 9528, 9574, 9607, 9608, 9610, 9620, 9662, 9799)
	replace industrycat_isic_year = "" if inlist(s4q9,9812, 9826, 9830, 9850, 9902)
	replace industrycat_isic_year = "" if inlist(s4q9,12, 31, 131, 156, 157, 165, 167, 174, 221)
	replace industrycat_isic_year = "" if inlist(s4q9,243, 313, 343, 350, 423, 433, 443, 512, 599)
	replace industrycat_isic_year = "" if inlist(s4q9,602, 612, 707, 712, 722, 726, 728, 792, 813)
	replace industrycat_isic_year = "" if inlist(s4q9,818, 819, 820, 821, 851, 853, 1014, 1105, 1106)
	replace industrycat_isic_year = "" if inlist(s4q9,1125, 1131, 1195, 1231, 1372, 1411, 1436, 1503, 1563)
	replace industrycat_isic_year = "" if inlist(s4q9,1619, 1719, 1789, 1903, 1921, 2005, 2025, 2223, 2229)
	replace industrycat_isic_year = "" if inlist(s4q9,2315, 2320, 2340, 2446, 2492, 2594, 2799, 2869, 3121)
	replace industrycat_isic_year = "" if inlist(s4q9,3123, 3221, 3229, 3410, 3609, 3741, 4020, 4030, 4106)
	replace industrycat_isic_year = "" if inlist(s4q9,4190, 4199, 4221, 4230, 4289, 4331, 4474, 4499, 4642)
	replace industrycat_isic_year = "" if inlist(s4q9,4713, 4732, 4739, 4744, 4754, 4755, 4777, 4784, 4785)
	replace industrycat_isic_year = "" if inlist(s4q9,4797, 4852, 4899, 4914, 4925, 4929, 4942, 4944, 4952)
	replace industrycat_isic_year = "" if inlist(s4q9,4959, 4969, 5219, 5225, 5331, 5429, 5430, 5612, 5624)
	replace industrycat_isic_year = "" if inlist(s4q9,5632, 5680, 5710, 5711, 5752, 5852, 5952, 6016, 6128)
	replace industrycat_isic_year = "" if inlist(s4q9,6129, 6140, 6141, 6149, 6162, 6304, 6424, 6466, 6496)
	replace industrycat_isic_year = "" if inlist(s4q9,6710, 6771, 6905, 7123, 7130, 7181, 7291, 7421, 7442)
	replace industrycat_isic_year = "" if inlist(s4q9,7474, 7481, 7489, 7491, 8101, 8251, 8310, 8425, 8432)
	replace industrycat_isic_year = "" if inlist(s4q9,8449, 8450, 8554, 8621, 8640, 8723, 8749, 8791, 8811)
	replace industrycat_isic_year = "" if inlist(s4q9,8990, 8992, 9111, 9131, 9202, 9219, 9233, 9291, 9323)
	replace industrycat_isic_year = "" if inlist(s4q9,9406, 9461, 9527, 9539, 9702, 9710, 9821, 9822, 9892)

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	
	preserve 
	int_classif_universe, var(industrycat_isic_year) universe(ISIC)
	count
	*list
	assert `r(N)' == 0
	restore 
	
	replace industrycat_isic_year = "" if lstatus_year != 1
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
	gen str occup_isco_year = string(s4q8,     "%04.0f")
	replace occup_isco_year = "" if occup_isco_year == "." 
	
	* Corrections - based on the ISIC Code and looking at the ISCO for consistency
	replace occup_isco_year = "6130" if s4q8 == 6132
	replace occup_isco_year = "2300" if s4q8 == 2321 &  inrange(s4q9, 8500,8599)
	replace occup_isco_year = ""     if s4q8 == 2321 & !inrange(s4q9, 8500,8599)
	replace occup_isco_year = "6100" if s4q8 == 6133 &  inrange(s4q9,  101, 161)
	replace occup_isco_year = ""     if s4q8 == 6133 & !inrange(s4q9,  101, 161)
	replace occup_isco_year = "6100" if s4q8 == 6211
	replace occup_isco_year = "7200" if s4q8 == 7234
	replace occup_isco_year = "2400" if s4q8 == 2418
	replace occup_isco_year = "5100" if s4q8 == 5114
	replace occup_isco_year = "9300" if s4q8 == 9309
	
	* Set to missing cases we cannot sensibly re-code 
	replace occup_isco_year = "" if inlist(s4q8, 7510, 7520, 4711, 4799, 1240, 8510)
	replace occup_isco_year = "" if inlist(s4q8,23, 101, 102, 103, 107, 112, 113, 114, 131)
	replace occup_isco_year = "" if inlist(s4q8,146, 162, 410, 411, 429, 432, 452, 471, 520)
	replace occup_isco_year = "" if inlist(s4q8,611, 692, 702, 711, 729, 732, 801, 802, 899)
	replace occup_isco_year = "" if inlist(s4q8,990, 1016, 1017, 1061, 1079, 1101, 1103, 1114, 1122)
	replace occup_isco_year = "" if inlist(s4q8,1219, 1341, 1391, 1415, 1510, 1514, 1520, 1551, 1620)
	replace occup_isco_year = "" if inlist(s4q8,1622, 1629, 1711, 1811, 1814, 2119, 2124, 2129, 2214)
	replace occup_isco_year = "" if inlist(s4q8,2216, 2312, 2318, 2333, 2334, 2342, 2414, 2433, 2435)
	replace occup_isco_year = "" if inlist(s4q8,2439, 2499, 2599, 2610, 2821, 2957, 3163, 3216, 3218)
	replace occup_isco_year = "" if inlist(s4q8,3311, 3312, 3319, 3323, 3427, 3437, 3510, 3811, 3812)
	replace occup_isco_year = "" if inlist(s4q8,4151, 4162, 4226, 4245, 4290, 4311, 4322, 4330, 4520)
	replace occup_isco_year = "" if inlist(s4q8,4551, 4661, 4715, 4719, 4721, 4722, 4733, 4751, 4759)
	replace occup_isco_year = "" if inlist(s4q8,4771, 4772, 4774, 4779, 4781, 4782, 4789, 4921, 4922)
	replace occup_isco_year = "" if inlist(s4q8,4923, 5010, 5102, 5109, 5115, 5116, 5124, 5128, 5129)
	replace occup_isco_year = "" if inlist(s4q8,5144, 5145, 5147, 5159, 5164, 5168, 5171, 5172, 5182)
	replace occup_isco_year = "" if inlist(s4q8,5191, 5196, 5198, 5201, 5204, 5212, 5214, 5221, 5222)
	replace occup_isco_year = "" if inlist(s4q8,5223, 5225, 5229, 5232, 5233, 5234, 5250, 5253, 5259)
	replace occup_isco_year = "" if inlist(s4q8,5260, 5262, 5270, 5280, 5320, 5330, 5419, 5441, 5520)
	replace occup_isco_year = "" if inlist(s4q8,5613, 5629, 5721, 5811, 5920, 5969, 6101, 6115, 6116)
	replace occup_isco_year = "" if inlist(s4q8,6119, 6131, 6134, 6136, 6137, 6144, 6145, 6149, 6169)
	replace occup_isco_year = "" if inlist(s4q8,6171, 6174, 6190, 6201, 6212, 6213, 6214, 6216, 6221)
	replace occup_isco_year = "" if inlist(s4q8,6230, 6231, 6232, 6240, 6242, 6250, 6251, 6252, 6269)
	replace occup_isco_year = "" if inlist(s4q8,6311, 6321, 6415, 6420, 6510, 6621, 6710, 6820, 6920)
	replace occup_isco_year = "" if inlist(s4q8,6921, 7114, 7115, 7126, 7127, 7151, 7152, 7159, 7162)
	replace occup_isco_year = "" if inlist(s4q8,7181, 7196, 7217, 7219, 7334, 7403, 7426, 7444, 7451)
	replace occup_isco_year = "" if inlist(s4q8,7452, 7455, 7490, 7515, 7522, 7535, 7729, 7845, 7911)
	replace occup_isco_year = "" if inlist(s4q8,8010, 8020, 8114, 8129, 8233, 8292, 8412, 8422, 8423)
	replace occup_isco_year = "" if inlist(s4q8,8425, 8430, 8521, 8549, 8610, 8620, 8790, 8890, 8922)
	replace occup_isco_year = "" if inlist(s4q8,9123, 9134, 9139, 9191, 9220, 9521, 9522, 9602, 9609)
	replace occup_isco_year = "" if inlist(s4q8,9621, 9700, 9731, 9810)
	replace occup_isco_year = "" if inlist(s4q8,111, 115, 149, 150, 152, 210, 220, 221, 240)
	replace occup_isco_year = "" if inlist(s4q8,312, 472, 477, 478, 563, 691, 713, 771, 941)
	replace occup_isco_year = "" if inlist(s4q8,949, 1020, 1050, 1072, 1304, 1321, 1399, 1410, 1412)
	replace occup_isco_year = "" if inlist(s4q8,1414, 1432, 1433, 1553, 1610, 1614, 1623, 1642, 1652)
	replace occup_isco_year = "" if inlist(s4q8,2011, 2030, 2311, 2349, 2593, 2640, 2721, 2814, 2824)
	replace occup_isco_year = "" if inlist(s4q8,3252, 3281, 3322, 3359, 3390, 3580, 3952, 4123, 4183)
	replace occup_isco_year = "" if inlist(s4q8,4230, 4433, 4522, 4641, 4730, 4788, 4919, 4999, 5020)
	replace occup_isco_year = "" if inlist(s4q8,5069, 5106, 5125, 5148, 5211, 5215, 5231, 5236, 5269)
	replace occup_isco_year = "" if inlist(s4q8,5300, 5311, 5321, 5331, 5411, 5422, 5530, 5590, 5610)
	replace occup_isco_year = "" if inlist(s4q8,5611, 5662, 5769, 6117, 6118, 6127, 6147, 6159, 6162)
	replace occup_isco_year = "" if inlist(s4q8,6220, 6223, 6253, 6310, 6414, 6425, 6432, 6441, 6450)
	replace occup_isco_year = "" if inlist(s4q8,6452, 6521, 6771, 6910, 7011, 7239, 7249, 7281, 7381)
	replace occup_isco_year = "" if inlist(s4q8,7438, 7453, 7476, 7830, 8132, 8362, 8424, 8511, 8512)
	replace occup_isco_year = "" if inlist(s4q8,8690, 8710, 8822, 9121, 9122, 9129, 9411, 9414, 9610)
	replace occup_isco_year = "" if inlist(s4q8,9723, 9999)

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	
	preserve 
	int_classif_universe, var(occup_isco_year) universe(ISCO)
	count
	*list
	assert `r(N)' == 0
	restore 

	replace occup_isco_year = "" if lstatus_year != 1
	label var occup_isco_year "ISCO code of primary job 7 day recall"
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
	* Info in survey is at day level, we want week. Reduce to missing values > 24
	* Assume 5 days per week 
	gen whours_year = s4q17*5 if s4q17 <= 24
	replace whours_year = . if lstatus_year != 1
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
