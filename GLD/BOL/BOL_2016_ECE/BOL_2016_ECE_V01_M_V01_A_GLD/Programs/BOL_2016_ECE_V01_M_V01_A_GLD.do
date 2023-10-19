
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				[BOL_2016_ECE_V01_M_V01_A_GLD.do] </_Program name_>
<_Application_>					[STATA 2017] <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2023-07-04 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						[BOLIVIA (BOL)] </_Country_>
<_Survey Title_>				[CONTINOUS EMPLOYMENT SURVEY] </_Survey Title_>
<_Survey Year_>					[2016] </_Survey Year_>
<_Study ID_>					[N/A] </_Study ID_>
<_Data collection from_>		[01/2016] </_Data collection from_>
<_Data collection to_>			[12/2016] </_Data collection to_>
<_Source of dataset_> 			[NATIONAL STATISTICS INSTITUTE OF BOLIVA - INE] </_Source of dataset_>
<_Sample size (HH)_> 			[39939] </_Sample size (HH)_>
<_Sample size (IND)_> 			[254234] </_Sample size (IND)_>
<_Sampling method_> 			[Panel design, two stage probabilistic, stratified, by conglomerate] </_Sampling method_>
<_Geographic coverage_> 		[national, urban/rural] </_Geographic coverage_>
<_Currency_> 					[Bolivian Boliviano] </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				[ICLS-13] </_ICLS Version_>
<_ISCED Version_>				[ISCED 2011] </_ISCED Version_>
<_ISCO Version_>				[ISCO 2008] </_ISCO Version_>
<_OCCUP National_>				[CLASIFICACIÓN DE OCUPACIONES DE BOLIVIA COB 2009] </_OCCUP National_>
<_ISIC Version_>				[ISIC REV 4] </_ISIC Version_>
<_INDUS National_>				[CLASIFICACION DE ACTIVIDADES ECONOMICAS DE BOLIVIA 2011] </_INDUS National_>

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
local country "BOL"
local year    "2016"
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

use "`path_in_stata'/qlfs-q1-2016.dta", clear 

gen quarter=1

append using "`path_in_stata'/qlfs-q2-2016.dta", force

replace quarter=2 if quarter==.

append using "`path_in_stata'/qlfs-q3-2016.dta", force

replace quarter=3 if quarter==.

append using "`path_in_stata'/qlfs-q4-2016.dta", force

replace quarter=4 if quarter==.

save "`path_in_stata'/qlfs_2016.dta", replace


/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode = "BOL"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "ECE"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "labour force survey"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	gen icls_v = "ICLS-[13]"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	gen isced_version = "isced_2011"
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
	gen int year = 2016
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
	gen int_year=gestion
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen  int_month = meses
	replace int_month=1 if meses==672
	replace int_month=2 if meses==673
	replace int_month=3 if meses==674
	replace int_month=4 if meses==675
	replace int_month=5 if meses==676
	replace int_month=6 if meses==677
	replace int_month=7 if meses==678
	replace int_month=8 if meses==679
	replace int_month=9 if meses==680
	replace int_month=10 if meses==681
	replace int_month=11 if meses==682
	replace int_month=12 if meses==683
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
	tostring id_hog_panel, gen(id_hogar_1)
	egen hhid = concat( id_hogar_1)
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	tostring id_per_panel, gen(id_persona_1)
	egen  pid = concat(hhid id_persona_1)
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
	gen counter = 1
	egen count_all = count(counter)
	bys trim : egen count_trim = count(counter)
	gen relative_weight = count_trim/count_all
	gen weight = fact_trim*relative_weight
	drop counter count_all count_trim relative_weight
	label var weight "Survey sampling weight"
*</_weight_>


*<_psu_>
	gen psu = upm
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = .
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	gen strata = estrato
	label var strata "Strata"
*</_strata_>


*<_wave_>
	gen wave = trimestre
	label var wave "Survey wave"
*</_wave_>

*<_panel_>
/*<_panel_note>
No need to create variable panel because the raw dataset already has one with that name
*</panel_note>*/
	*gen panel = panel
	label var panel "Panel"
*</_panel_>

*<_visit_no_>
	gen visit_no = .
	label var visit_no "Visit Number"
*</_visit_no_>

}


/*%%=============================================================================================
	3: Geography
==============================================================================================%%*/

{

*<_urban_>
	gen byte urban = area
	recode urban 2=0
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
/* <_subnatid1_note>

	The variable is string and country-specific categorical. Numeric entries are coded in string format using the following naming convention: “1 – Hatay”. That is, the variable itself is to be string, not a labelled numeric vector. 
	
	Example of entries would be "1 - Alaska",  "2 - Arkansas", ...

</_subnatid1_note> */
	gen str subnatid1 = ""
	replace subnatid1 = " 1 - Chuquisaca" if depto==1
	replace subnatid1 = " 2 - La Paz" if depto==2
	replace subnatid1 = " 3 - Cochabamba" if depto==3
	replace subnatid1 = " 4 - Oruro" if depto==4
	replace subnatid1 = " 5 - Potosi" if depto==5
	replace subnatid1 = " 6 - Tarija" if depto==6
	replace subnatid1 = " 7 - Santa Cruz" if depto==7
	replace subnatid1 = " 8 - Beni" if depto==8
	replace subnatid1 = " 9 - Pando" if depto==9
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
In this case we are generating a helper to create the variable, the helper uses information from the urban variable.
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
	gen help_1 = 1
	bys hhid: egen hsize = total(help_1)
	label var hsize "Household size"
	drop help_1
*</_hsize_>


*<_age_>
	gen age = s1_03a
	recode age 887=. 888=.
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = s1_02
	recode male 2=0
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen relationharm = s1_05
	recode relationharm 6=4 4/5=5 7/9=5 10/12=6
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = s1_05
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital = s1_09
	recode marital 1=2 2=1 4/5=4 6=5
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
/* <_migrated_mod_age__note>
the residence information is only for employment during performance of the occupation , last 12 months month question. Not information from further down so not relevant for GLD migration coding.
</_migrated_mod_age_note> */
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

Education module is only asked to those 10 and older.

</_ed_mod_age_note> */

gen byte ed_mod_age = 10
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school=.
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
/* <_literacy_note>

We are using the variable of level of education to build the literacy status

</_literacy_note> */
	gen byte literacy = .
	replace literacy=1 if inrange(s1_07a,11,81)
	replace literacy=0 if s1_07a==10
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen byte educy =e
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7 =niv_ed
	recode educat7 0=1 1=2 2=3 3=4 4=5 
	replace educat7=6 if inrange(s1_07a,78,81)
	replace educat7=6 if s1_07a==71
	replace educat7=7 if inrange(s1_07a,72,77)
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
	gen educat_orig = s1_07a
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
	gen vocational = s2_30
	recode vocational 2=0
	label de lblvocational 0 "No" 1 "Yes"
	label var vocational "Ever received vocational training"
	label values vocational lblvocational
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
	gen vocational_financed = s2_31
	recode vocational_financed 1=4 2=1 4=2 3=5 5=5 6=5
	label de lblvocational_financed 1 "Employer" 2 "Government" 3 "Mixed Employer/Government" 4 "Own funds" 5 "Other"
	label var vocational_financed "How training was financed"
	label values vocational_financed lblvocational_financed
*</_vocational_financed_>

}


/*%%=============================================================================================
	8: Labour
==============================================================================================%%*/


*<_minlaborage_>
	gen byte minlaborage =10
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
	gen byte lstatus = .
	replace lstatus=1 if s2_01==1
	replace lstatus=1 if inrange(s2_02,1,6)
	replace lstatus=1 if inrange(s2_03,1,7)
	replace lstatus=2 if s2_04==1 & s2_05==1
	replace lstatus=3 if missing(lstatus)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = .
	replace potential_lf=1 if s2_04==1 & s2_05==2
	replace potential_lf=1 if s2_04==2 & s2_05==1
	replace potential_lf=0 if missing(potential_lf)
	replace potential_lf = . if age < minlaborage & age != .
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
	gen byte nlfreason=s2_09
	recode nlfreason 6=1 11=2 7=3 9=4 1/5=5 8=5 10=5 12=5
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
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
	gen byte empstat=s2_20
	recode empstat 1/2=1 3=4 4/5=3 6=5 7=2 8=1
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec = s2_22
	recode ocusec 2=3 3=2 4=2 5=2 6=.
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig = s2_16acod
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
/* <_industrycat_isic_note>

	We are using the three first digits because in the documentation the INE says that from the 4th digit onwards the code is a variation they performed for the Bolivia industries.
	
	C,F,G correspond to the higher level of industry classification, since there is not more details we leave it to missing in isic but it will be coded in industrycat10

</_industrycat_isic_note> */
	gen industrycat_isic_help= s2_16acod + substr("00000", 1, 5 - length(s2_16acod))
	replace industrycat_isic_help = substr(industrycat_isic_help, 1, length(industrycat_isic_help) - 2) 
	replace industrycat_isic_help="" if s2_16acod=="G"
	replace industrycat_isic_help="" if s2_16acod=="F"
	replace industrycat_isic_help="" if s2_16acod=="C"
	gen industrycat_isic = industrycat_isic_help + substr("0000", 1, 4 - length(industrycat_isic_help))
	replace industrycat_isic="" if industrycat_isic=="0000"
	replace industrycat_isic="" if industrycat_isic=="8900"
	replace industrycat_isic="9900" if industrycat_isic=="9990"
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
	replace industrycat10=7 if inrange(industrycat_isic,"4900","5399")
	replace industrycat10=6 if inrange(industrycat_isic,"5500","5699")
	replace industrycat10=7 if inrange(industrycat_isic,"5800","6399")
	replace industrycat10=8 if inrange(industrycat_isic,"6400","6899")
	replace industrycat10=8 if inrange(industrycat_isic,"6910","7599")
	replace industrycat10=8 if inrange(industrycat_isic,"7700","8299")
	replace industrycat10=9 if inrange(industrycat_isic,"8400","8419")
	replace industrycat10=9 if inrange(industrycat_isic,"8420", "8499")
	replace industrycat10=10 if inrange(industrycat_isic,"8500","8599")
	replace industrycat10=10 if inrange(industrycat_isic,"8600","8899")
	replace industrycat10=10 if inrange(industrycat_isic,"9000","9399")
	replace industrycat10=10 if inrange(industrycat_isic,"9400","9699")
	replace industrycat10=10 if inrange(industrycat_isic,"9700","9899")
	replace industrycat10=10 if inrange(industrycat_isic,"9900","9999")
	replace industrycat10=6 if s2_16acod=="G"
	replace industrycat10=5 if s2_16acod=="F"
	replace industrycat10=3 if s2_16acod=="C"
	replace industrycat10=. if lstatus!=1
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
	gen occup_orig = s2_15acod
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	gen occup_isco=""
	replace occup_isco="0110" if s2_15acod=="01000"
	replace occup_isco="0210" if s2_15acod=="02000"
	replace occup_isco="0310" if s2_15acod=="03099"
	replace occup_isco="1111" if s2_15acod=="11101"
	replace occup_isco="1111" if s2_15acod=="11102"
	replace occup_isco="2612" if s2_15acod=="11103"
	replace occup_isco="1111" if s2_15acod=="11104"
	replace occup_isco="1112" if s2_15acod=="11105"
	replace occup_isco="1112" if s2_15acod=="11106"
	replace occup_isco="1112" if s2_15acod=="11107"
	replace occup_isco="1113" if s2_15acod=="11108"
	replace occup_isco="1114" if s2_15acod=="11109"
	replace occup_isco="1114" if s2_15acod=="11110"
	replace occup_isco="1114" if s2_15acod=="11111"
	replace occup_isco="1114" if s2_15acod=="11199"
	replace occup_isco="1120" if s2_15acod=="11201"
	replace occup_isco="1120" if s2_15acod=="11202"
	replace occup_isco="1120" if s2_15acod=="11203"
	replace occup_isco="1120" if s2_15acod=="11204"
	replace occup_isco="1120" if s2_15acod=="11205"
	replace occup_isco="1120" if s2_15acod=="11206"
	replace occup_isco="1120" if s2_15acod=="11207"
	replace occup_isco="1120" if s2_15acod=="11208"
	replace occup_isco="1120" if s2_15acod=="11209"
	replace occup_isco="1120" if s2_15acod=="11210"
	replace occup_isco="1120" if s2_15acod=="11211"
	replace occup_isco="1120" if s2_15acod=="11212"
	replace occup_isco="1120" if s2_15acod=="11213"
	replace occup_isco="1120" if s2_15acod=="11214"
	replace occup_isco="1120" if s2_15acod=="11215"
	replace occup_isco="1120" if s2_15acod=="11299"
	replace occup_isco="1211" if s2_15acod=="12101"
	replace occup_isco="1212" if s2_15acod=="12102"
	replace occup_isco="1213" if s2_15acod=="12103"
	replace occup_isco="1221" if s2_15acod=="12104"
	replace occup_isco="1222" if s2_15acod=="12105"
	replace occup_isco="1223" if s2_15acod=="12106"
	replace occup_isco="1324" if s2_15acod=="12107"
	replace occup_isco="1330" if s2_15acod=="12108"
	replace occup_isco="1324" if s2_15acod=="12109"
	replace occup_isco="1349" if s2_15acod=="12110"
	replace occup_isco="1349" if s2_15acod=="12111"
	replace occup_isco="1349" if s2_15acod=="12199"
	replace occup_isco="1311" if s2_15acod=="13101"
	replace occup_isco="1311" if s2_15acod=="13102"
	replace occup_isco="1311" if s2_15acod=="13103"
	replace occup_isco="1311" if s2_15acod=="13104"
	replace occup_isco="1312" if s2_15acod=="13105"
	replace occup_isco="1321" if s2_15acod=="13201"
	replace occup_isco="1322" if s2_15acod=="13202"
	replace occup_isco="1323" if s2_15acod=="13203"
	replace occup_isco="1330" if s2_15acod=="13300"
	replace occup_isco="1344" if s2_15acod=="13401"
	replace occup_isco="1342" if s2_15acod=="13402"
	replace occup_isco="1345" if s2_15acod=="13403"
	replace occup_isco="1346" if s2_15acod=="13404"
	replace occup_isco="1349" if s2_15acod=="13499"
	replace occup_isco="1411" if s2_15acod=="14101"
	replace occup_isco="1412" if s2_15acod=="14102"
	replace occup_isco="1420" if s2_15acod=="14200"
	replace occup_isco="1439" if s2_15acod=="14301"
	replace occup_isco="1439" if s2_15acod=="14302"
	replace occup_isco="1439" if s2_15acod=="14303"
	replace occup_isco="1439" if s2_15acod=="14304"
	replace occup_isco="1439" if s2_15acod=="14305"
	replace occup_isco="1431" if s2_15acod=="14306"
	replace occup_isco="1324" if s2_15acod=="14307"
	replace occup_isco="1349" if s2_15acod=="14308"
	replace occup_isco="1439" if s2_15acod=="14399"
	replace occup_isco="2111" if s2_15acod=="21101"				
	replace occup_isco="2112" if s2_15acod=="21102"				
	replace occup_isco="2113" if s2_15acod=="21103"				
	replace occup_isco="2114" if s2_15acod=="21104"				
	replace occup_isco="2632" if s2_15acod=="21105"				
	replace occup_isco="2120" if s2_15acod=="21201"				
	replace occup_isco="2120" if s2_15acod=="21202"							
	replace occup_isco="2131" if s2_15acod=="21301"				
	replace occup_isco="2131" if s2_15acod=="21302"				
	replace occup_isco="2132" if s2_15acod=="21303"				
	replace occup_isco="2133" if s2_15acod=="21304"				
	replace occup_isco="2130" if s2_15acod=="21399"							
	replace occup_isco="2142" if s2_15acod=="21401"				
	replace occup_isco="2151" if s2_15acod=="21402"				
	replace occup_isco="2152" if s2_15acod=="21403"				
	replace occup_isco="2144" if s2_15acod=="21404"				
	replace occup_isco="2145" if s2_15acod=="21405"				
	replace occup_isco="2146" if s2_15acod=="21406"				
	replace occup_isco="2149" if s2_15acod=="21407"				
	replace occup_isco="2149" if s2_15acod=="21408"	
	replace occup_isco="2149" if s2_15acod=="21409"	
	replace occup_isco="2149" if s2_15acod=="21499"							
	replace occup_isco="2160" if s2_15acod=="21501"							
	replace occup_isco="2165" if s2_15acod=="21502"				
	replace occup_isco="2166" if s2_15acod=="21503"							
	replace occup_isco="2210" if s2_15acod=="22101"							
	replace occup_isco="2269" if s2_15acod=="22102"							
	replace occup_isco="2221" if s2_15acod=="22201"				
	replace occup_isco="2222" if s2_15acod=="22202"							
	replace occup_isco="2230" if s2_15acod=="22300"							
	replace occup_isco="2250" if s2_15acod=="22400"							
	replace occup_isco="2261" if s2_15acod=="22501"				
	replace occup_isco="2262" if s2_15acod=="22502"				
	replace occup_isco="2264" if s2_15acod=="22503"				
	replace occup_isco="2265" if s2_15acod=="22504"				
	replace occup_isco="2266" if s2_15acod=="22505"				
	replace occup_isco="2267" if s2_15acod=="22506"							
	replace occup_isco="2269" if s2_15acod=="22599"							
	replace occup_isco="2310" if s2_15acod=="23101"				
	replace occup_isco="2310" if s2_15acod=="23102"							
	replace occup_isco="2320" if s2_15acod=="23200"							
	replace occup_isco="2330" if s2_15acod=="23300"							
	replace occup_isco="2341" if s2_15acod=="23401"				
	replace occup_isco="2342" if s2_15acod=="23402"							
	replace occup_isco="2351" if s2_15acod=="23501"				
	replace occup_isco="2359" if s2_15acod=="23502"				
	replace occup_isco="2352" if s2_15acod=="23503"				
	replace occup_isco="2353" if s2_15acod=="23504"				
	replace occup_isco="2354" if s2_15acod=="23505"				
	replace occup_isco="2355" if s2_15acod=="23506"				
	replace occup_isco="2355" if s2_15acod=="23507"				
	replace occup_isco="2356" if s2_15acod=="23508"				
	replace occup_isco="5165" if s2_15acod=="23509"				
	replace occup_isco="3423" if s2_15acod=="23510"				
	replace occup_isco="2359" if s2_15acod=="23599"						
	replace occup_isco="2411" if s2_15acod=="24101"				
	replace occup_isco="2411" if s2_15acod=="24102"
	replace occup_isco="2410" if s2_15acod=="24103"
	replace occup_isco="2410" if s2_15acod=="24199"							
	replace occup_isco="2421" if s2_15acod=="24201"							
	replace occup_isco="2420" if s2_15acod=="24299"							
	replace occup_isco="2431" if s2_15acod=="24301"				
	replace occup_isco="2432" if s2_15acod=="24302"				
	replace occup_isco="2433" if s2_15acod=="24303"						
	replace occup_isco="2511" if s2_15acod=="25101"				
	replace occup_isco="2512" if s2_15acod=="25102"				
	replace occup_isco="2513" if s2_15acod=="25103"							
	replace occup_isco="2529" if s2_15acod=="25199"							
	replace occup_isco="2521" if s2_15acod=="25201"				
	replace occup_isco="2522" if s2_15acod=="25202"				
	replace occup_isco="2523" if s2_15acod=="25203"				
	replace occup_isco="2153" if s2_15acod=="25204"				
	replace occup_isco="2520" if s2_15acod=="25299"							
	replace occup_isco="2611" if s2_15acod=="26101"				
	replace occup_isco="2619" if s2_15acod=="26102"				
	replace occup_isco="2612" if s2_15acod=="26103"				
	replace occup_isco="2619" if s2_15acod=="26199"							
	replace occup_isco="2633" if s2_15acod=="26201"				
	replace occup_isco="2633" if s2_15acod=="26203"				
	replace occup_isco="2641" if s2_15acod=="26202"				
	replace occup_isco="2634" if s2_15acod=="26204"				
	replace occup_isco="2600" if s2_15acod=="26205"				
	replace occup_isco="2622" if s2_15acod=="26206"				
	replace occup_isco="2643" if s2_15acod=="26207"				
	replace occup_isco="2643" if s2_15acod=="26208"				
	replace occup_isco="2600" if s2_15acod=="26299"							
	replace occup_isco="2631" if s2_15acod=="26301"				
	replace occup_isco="2632" if s2_15acod=="26302"				
	replace occup_isco="2632" if s2_15acod=="26303"				
	replace occup_isco="2632" if s2_15acod=="26304"				
	replace occup_isco="2635" if s2_15acod=="26305"				
	replace occup_isco="2642" if s2_15acod=="26306"				
	replace occup_isco="2636" if s2_15acod=="26307"				
	replace occup_isco="2630" if s2_15acod=="26399"						
	replace occup_isco="2641" if s2_15acod=="26400"						
	replace occup_isco="2651" if s2_15acod=="26501"				
	replace occup_isco="2652" if s2_15acod=="26502"				
	replace occup_isco="2652" if s2_15acod=="26503"				
	replace occup_isco="2652" if s2_15acod=="26504"				
	replace occup_isco="2652" if s2_15acod=="26505"				
	replace occup_isco="2652" if s2_15acod=="26506"				
	replace occup_isco="2653" if s2_15acod=="26507"				
	replace occup_isco="2654" if s2_15acod=="26508"				
	replace occup_isco="2655" if s2_15acod=="26509"				
	replace occup_isco="2656" if s2_15acod=="26510"				
	replace occup_isco="2659" if s2_15acod=="26599"						
	replace occup_isco="2000" if s2_15acod=="27100"				
	replace occup_isco="3111" if s2_15acod=="31101"				
	replace occup_isco="3111" if s2_15acod=="31102"				
	replace occup_isco="3111" if s2_15acod=="31103"				
	replace occup_isco="3111" if s2_15acod=="31104"				
	replace occup_isco="3119" if s2_15acod=="31105"				
	replace occup_isco="3112" if s2_15acod=="31106"				
	replace occup_isco="3113" if s2_15acod=="31107"				
	replace occup_isco="3114" if s2_15acod=="31108"				
	replace occup_isco="3115" if s2_15acod=="31109"				
	replace occup_isco="3116" if s2_15acod=="31110"				
	replace occup_isco="3117" if s2_15acod=="31111"				
	replace occup_isco="3118" if s2_15acod=="31112"				
	replace occup_isco="3119" if s2_15acod=="31113"				
	replace occup_isco="3119" if s2_15acod=="31114"				
	replace occup_isco="3119" if s2_15acod=="31199"				
	replace occup_isco="3121" if s2_15acod=="31201"				
	replace occup_isco="3122" if s2_15acod=="31202"				
	replace occup_isco="3123" if s2_15acod=="31203"						
	replace occup_isco="3131" if s2_15acod=="31301"				
	replace occup_isco="3132" if s2_15acod=="31302"				
	replace occup_isco="3132" if s2_15acod=="31303"				
	replace occup_isco="3133" if s2_15acod=="31304"				
	replace occup_isco="3134" if s2_15acod=="31305"				
	replace occup_isco="3135" if s2_15acod=="31306"				
	replace occup_isco="3139" if s2_15acod=="31399"							
	replace occup_isco="3141" if s2_15acod=="31401"				
	replace occup_isco="3142" if s2_15acod=="31402"				
	replace occup_isco="3143" if s2_15acod=="31403"				
	replace occup_isco="3141" if s2_15acod=="31499"							
	replace occup_isco="3151" if s2_15acod=="31501"				
	replace occup_isco="3152" if s2_15acod=="31502"				
	replace occup_isco="3153" if s2_15acod=="31503"				
	replace occup_isco="3154" if s2_15acod=="31504"				
	replace occup_isco="3155" if s2_15acod=="31505"				
	replace occup_isco="3153" if s2_15acod=="31599"						
	replace occup_isco="3211" if s2_15acod=="32101"				
	replace occup_isco="3212" if s2_15acod=="32102"				
	replace occup_isco="3214" if s2_15acod=="32103"				
	replace occup_isco="3213" if s2_15acod=="32104"						
	replace occup_isco="3221" if s2_15acod=="32201"				
	replace occup_isco="3222" if s2_15acod=="32202"						
	replace occup_isco="3230" if s2_15acod=="32301"							
	replace occup_isco="3240" if s2_15acod=="32400"							
	replace occup_isco="3251" if s2_15acod=="32501"				
	replace occup_isco="3252" if s2_15acod=="32502"				
	replace occup_isco="3253" if s2_15acod=="32503"				
	replace occup_isco="3254" if s2_15acod=="32504"				
	replace occup_isco="3255" if s2_15acod=="32505"				
	replace occup_isco="3256" if s2_15acod=="32506"				
	replace occup_isco="3257" if s2_15acod=="32507"				
	replace occup_isco="3213" if s2_15acod=="32508"				
	replace occup_isco="3258" if s2_15acod=="32509"				
	replace occup_isco="3259" if s2_15acod=="32510"				
	replace occup_isco="3259" if s2_15acod=="32511"				
	replace occup_isco="3259" if s2_15acod=="32599"							
	replace occup_isco="3311" if s2_15acod=="33101"				
	replace occup_isco="3312" if s2_15acod=="33102"				
	replace occup_isco="3313" if s2_15acod=="33103"				
	replace occup_isco="3314" if s2_15acod=="33104"				
	replace occup_isco="3315" if s2_15acod=="33105"							
	replace occup_isco="3321" if s2_15acod=="33201"				
	replace occup_isco="3322" if s2_15acod=="33202"				
	replace occup_isco="3323" if s2_15acod=="33203"				
	replace occup_isco="3324" if s2_15acod=="33204"				
	replace occup_isco="3320" if s2_15acod=="33299"							
	replace occup_isco="3331" if s2_15acod=="33301"				
	replace occup_isco="3332" if s2_15acod=="33302"				
	replace occup_isco="3333" if s2_15acod=="33303"				
	replace occup_isco="3334" if s2_15acod=="33304"				
	replace occup_isco="3339" if s2_15acod=="33305"				
	replace occup_isco="3339" if s2_15acod=="33399"										
	replace occup_isco="3342" if s2_15acod=="33401"				
	replace occup_isco="3343" if s2_15acod=="33402"				
	replace occup_isco="3344" if s2_15acod=="33403"				
	replace occup_isco="3340" if s2_15acod=="33499"						
	replace occup_isco="3351" if s2_15acod=="33501"				
	replace occup_isco="3352" if s2_15acod=="33502"				
	replace occup_isco="3353" if s2_15acod=="33503"				
	replace occup_isco="3354" if s2_15acod=="33504"				
	replace occup_isco="3355" if s2_15acod=="33505"				
	replace occup_isco="3359" if s2_15acod=="33599"							
	replace occup_isco="3411" if s2_15acod=="34101"				
	replace occup_isco="3412" if s2_15acod=="34102"				
	replace occup_isco="3413" if s2_15acod=="34103"						
	replace occup_isco="3421" if s2_15acod=="34201"				
	replace occup_isco="3422" if s2_15acod=="34202"							
	replace occup_isco="3431" if s2_15acod=="34301"				
	replace occup_isco="3432" if s2_15acod=="34302"				
	replace occup_isco="3118" if s2_15acod=="34303"				
	replace occup_isco="3433" if s2_15acod=="34304"				
	replace occup_isco="3434" if s2_15acod=="34305"				
	replace occup_isco="3435" if s2_15acod=="34306"				
	replace occup_isco="3435" if s2_15acod=="34307"				
	replace occup_isco="3435" if s2_15acod=="34308"				
	replace occup_isco="3435" if s2_15acod=="34309"				
	replace occup_isco="3435" if s2_15acod=="34310"				
	replace occup_isco="3435" if s2_15acod=="34311"				
	replace occup_isco="3435" if s2_15acod=="34312"				
	replace occup_isco="3435" if s2_15acod=="34313"				
	replace occup_isco="3435" if s2_15acod=="34399"							
	replace occup_isco="3511" if s2_15acod=="35101"				
	replace occup_isco="3512" if s2_15acod=="35102"				
	replace occup_isco="3513" if s2_15acod=="35103"				
	replace occup_isco="3514" if s2_15acod=="35104"				
	replace occup_isco="3510" if s2_15acod=="35199"						
	replace occup_isco="3521" if s2_15acod=="35201"				
	replace occup_isco="3522" if s2_15acod=="35202"	
	replace occup_isco="4110" if s2_15acod=="41100"						
	replace occup_isco="4120" if s2_15acod=="41200"					
	replace occup_isco="4211" if s2_15acod=="42101"				
	replace occup_isco="4212" if s2_15acod=="42102"				
	replace occup_isco="4213" if s2_15acod=="42103"				
	replace occup_isco="4214" if s2_15acod=="42104"
	replace occup_isco="4214" if s2_15acod=="42199"
	replace occup_isco="4221" if s2_15acod=="42201"				
	replace occup_isco="4222" if s2_15acod=="42202"				
	replace occup_isco="4223" if s2_15acod=="42203"				
	replace occup_isco="4224" if s2_15acod=="42204"				
	replace occup_isco="4225" if s2_15acod=="42205"				
	replace occup_isco="4226" if s2_15acod=="42206"				
	replace occup_isco="4227" if s2_15acod=="42207"				
	replace occup_isco="4229" if s2_15acod=="42299"							
	replace occup_isco="4311" if s2_15acod=="43101"				
	replace occup_isco="4312" if s2_15acod=="43102"				
	replace occup_isco="4313" if s2_15acod=="43103"							
	replace occup_isco="4321" if s2_15acod=="43201"				
	replace occup_isco="4322" if s2_15acod=="43202"				
	replace occup_isco="4323" if s2_15acod=="43203"						
	replace occup_isco="4411" if s2_15acod=="44101"				
	replace occup_isco="4412" if s2_15acod=="44102"				
	replace occup_isco="4413" if s2_15acod=="44103"				
	replace occup_isco="4414" if s2_15acod=="44104"				
	replace occup_isco="4415" if s2_15acod=="44105"							
	replace occup_isco="4419" if s2_15acod=="44199"				
	replace occup_isco="5111" if s2_15acod=="51101"
	replace occup_isco="5112" if s2_15acod=="51102"
	replace occup_isco="5113" if s2_15acod=="51103"
	replace occup_isco="5120" if s2_15acod=="51200"
	replace occup_isco="5130" if s2_15acod=="51300"
	replace occup_isco="5141" if s2_15acod=="51401"
	replace occup_isco="5142" if s2_15acod=="51402"
	replace occup_isco="5151" if s2_15acod=="51501"
	replace occup_isco="5152" if s2_15acod=="51502"
	replace occup_isco="5153" if s2_15acod=="51503"
	replace occup_isco="5161" if s2_15acod=="51601"
	replace occup_isco="5162" if s2_15acod=="51602"
	replace occup_isco="5163" if s2_15acod=="51603"
	replace occup_isco="5164" if s2_15acod=="51604"
	replace occup_isco="5169" if s2_15acod=="51605"
	replace occup_isco="5169" if s2_15acod=="51699"
	replace occup_isco="5211" if s2_15acod=="52101"
	replace occup_isco="5221" if s2_15acod=="52201"
	replace occup_isco="5222" if s2_15acod=="52202"
	replace occup_isco="5223" if s2_15acod=="52203"
	replace occup_isco="5230" if s2_15acod=="52301"
	replace occup_isco="5241" if s2_15acod=="52401"
	replace occup_isco="5242" if s2_15acod=="52402"
	replace occup_isco="5243" if s2_15acod=="52403"
	replace occup_isco="5244" if s2_15acod=="52404"
	replace occup_isco="5245" if s2_15acod=="52405"
	replace occup_isco="5246" if s2_15acod=="52406"
	replace occup_isco="5249" if s2_15acod=="52407"
	replace occup_isco="5249" if s2_15acod=="52499"
	replace occup_isco="5212" if s2_15acod=="52501"
	replace occup_isco="9520" if s2_15acod=="52502"
	replace occup_isco="5310" if s2_15acod=="53101"
	replace occup_isco="5310" if s2_15acod=="53102"
	replace occup_isco="5321" if s2_15acod=="53201"
	replace occup_isco="5322" if s2_15acod=="53202"
	replace occup_isco="5329" if s2_15acod=="53203"
	replace occup_isco="5411" if s2_15acod=="54101"
	replace occup_isco="5412" if s2_15acod=="54102"
	replace occup_isco="5412" if s2_15acod=="54103"
	replace occup_isco="5413" if s2_15acod=="54104"
	replace occup_isco="5414" if s2_15acod=="54105"
	replace occup_isco="5419" if s2_15acod=="54199"
	replace occup_isco="6111" if s2_15acod=="61001"				
	replace occup_isco="6111" if s2_15acod=="61002"				
	replace occup_isco="6111" if s2_15acod=="61003"				
	replace occup_isco="6111" if s2_15acod=="61004"				
	replace occup_isco="6111" if s2_15acod=="61005"				
	replace occup_isco="6111" if s2_15acod=="61006"				
	replace occup_isco="6111" if s2_15acod=="61007"				
	replace occup_isco="6111" if s2_15acod=="61008"				
	replace occup_isco="6112" if s2_15acod=="61009"				
	replace occup_isco="6112" if s2_15acod=="61010"				
	replace occup_isco="6112" if s2_15acod=="61011"				
	replace occup_isco="6112" if s2_15acod=="61012"				
	replace occup_isco="6113" if s2_15acod=="61013"						
	replace occup_isco="6110" if s2_15acod=="61014"	
	replace occup_isco="6110" if s2_15acod=="61015"
	replace occup_isco="6110" if s2_15acod=="61099"							
	replace occup_isco="6121" if s2_15acod=="62001"				
	replace occup_isco="6121" if s2_15acod=="62002"				
	replace occup_isco="6121" if s2_15acod=="62003"				
	replace occup_isco="6121" if s2_15acod=="62004"				
	replace occup_isco="6122" if s2_15acod=="62005"				
	replace occup_isco="6129" if s2_15acod=="62006"				
	replace occup_isco="6129" if s2_15acod=="62007"				
	replace occup_isco="6129" if s2_15acod=="62008"				
	replace occup_isco="6123" if s2_15acod=="62009"				
	replace occup_isco="6123" if s2_15acod=="62010"				
	replace occup_isco="6121" if s2_15acod=="62011"				
	replace occup_isco="6129" if s2_15acod=="62099"							
	replace occup_isco="6210" if s2_15acod=="63100"							
	replace occup_isco="6221" if s2_15acod=="63201"				
	replace occup_isco="6222" if s2_15acod=="63202"				
	replace occup_isco="6224" if s2_15acod=="63203"				
	replace occup_isco="7111" if s2_15acod=="71102"					
	replace occup_isco="7110" if s2_15acod=="71101"					
	replace occup_isco="7115" if s2_15acod=="71103"					
	replace occup_isco="7119" if s2_15acod=="71199"					
	replace occup_isco="7115" if s2_15acod=="71104"									
	replace occup_isco="7121" if s2_15acod=="71201"					
	replace occup_isco="7122" if s2_15acod=="71202"					
	replace occup_isco="7123" if s2_15acod=="71203"					
	replace occup_isco="7124" if s2_15acod=="71204"					
	replace occup_isco="7125" if s2_15acod=="71205"					
	replace occup_isco="7126" if s2_15acod=="71206"					
	replace occup_isco="7127" if s2_15acod=="71207"					
	replace occup_isco="7210" if s2_15acod=="71299"									
	replace occup_isco="7131" if s2_15acod=="71301"					
	replace occup_isco="7132" if s2_15acod=="71302"					
	replace occup_isco="7133" if s2_15acod=="71303"									
	replace occup_isco="7211" if s2_15acod=="72101"					
	replace occup_isco="7212" if s2_15acod=="72102"					
	replace occup_isco="7213" if s2_15acod=="72103"					
	replace occup_isco="7214" if s2_15acod=="72104"					
	replace occup_isco="7215" if s2_15acod=="72105"									
	replace occup_isco="7221" if s2_15acod=="72201"					
	replace occup_isco="7222" if s2_15acod=="72202"					
	replace occup_isco="7223" if s2_15acod=="72203"					
	replace occup_isco="7224" if s2_15acod=="72204"									
	replace occup_isco="7231" if s2_15acod=="72301"					
	replace occup_isco="7232" if s2_15acod=="72302"					
	replace occup_isco="7233" if s2_15acod=="72303"					
	replace occup_isco="7234" if s2_15acod=="72304"
	replace occup_isco="7230" if s2_15acod=="72305"
	replace occup_isco="7230" if s2_15acod=="72399"								
	replace occup_isco="7311" if s2_15acod=="73101"					
	replace occup_isco="7312" if s2_15acod=="73102"					
	replace occup_isco="7312" if s2_15acod=="73103"					
	replace occup_isco="7312" if s2_15acod=="73104"					
	replace occup_isco="7313" if s2_15acod=="73105"									
	replace occup_isco="7314" if s2_15acod=="73201"					
	replace occup_isco="7315" if s2_15acod=="73202"					
	replace occup_isco="7316" if s2_15acod=="73203"								
	replace occup_isco="7317" if s2_15acod=="73301"					
	replace occup_isco="7318" if s2_15acod=="73302"					
	replace occup_isco="7318" if s2_15acod=="73303"					
	replace occup_isco="7319" if s2_15acod=="73304"					
	replace occup_isco="7314" if s2_15acod=="73305"					
	replace occup_isco="7318" if s2_15acod=="73306"					
	replace occup_isco="7319" if s2_15acod=="73399"								
	replace occup_isco="7321" if s2_15acod=="73401"					
	replace occup_isco="7322" if s2_15acod=="73402"					
	replace occup_isco="7323" if s2_15acod=="73403"					
	replace occup_isco="7323" if s2_15acod=="73499"									
	replace occup_isco="7412" if s2_15acod=="74101"					
	replace occup_isco="7413" if s2_15acod=="74102"									
	replace occup_isco="7421" if s2_15acod=="74201"					
	replace occup_isco="7422" if s2_15acod=="74202"									
	replace occup_isco="7511" if s2_15acod=="75101"					
	replace occup_isco="7512" if s2_15acod=="75102"					
	replace occup_isco="7513" if s2_15acod=="75103"					
	replace occup_isco="7514" if s2_15acod=="75104"					
	replace occup_isco="7515" if s2_15acod=="75105"					
	replace occup_isco="7516" if s2_15acod=="75106"					
	replace occup_isco="7514" if s2_15acod=="75199"									
	replace occup_isco="7521" if s2_15acod=="75201"					
	replace occup_isco="7522" if s2_15acod=="75202"					
	replace occup_isco="7523" if s2_15acod=="75203"					
	replace occup_isco="7520" if s2_15acod=="75299"									
	replace occup_isco="7532" if s2_15acod=="75301"					
	replace occup_isco="7532" if s2_15acod=="75302"					
	replace occup_isco="7531" if s2_15acod=="75303"					
	replace occup_isco="7531" if s2_15acod=="75304"					
	replace occup_isco="7531" if s2_15acod=="75305"					
	replace occup_isco="7532" if s2_15acod=="75306"					
	replace occup_isco="7533" if s2_15acod=="75307"					
	replace occup_isco="7534" if s2_15acod=="75308"					
	replace occup_isco="7530" if s2_15acod=="75399"								
	replace occup_isco="7535" if s2_15acod=="75401"					
	replace occup_isco="7536" if s2_15acod=="75402"					
	replace occup_isco="7530" if s2_15acod=="75403"					
	replace occup_isco="7531" if s2_15acod=="75404"					
	replace occup_isco="7530" if s2_15acod=="75499"								
	replace occup_isco="8111" if s2_15acod=="75501"					
	replace occup_isco="8111" if s2_15acod=="75502"					
	replace occup_isco="7513" if s2_15acod=="75503"					
	replace occup_isco="7542" if s2_15acod=="75504"					
	replace occup_isco="8110" if s2_15acod=="75599"								
	replace occup_isco="7541" if s2_15acod=="75601"								
	replace occup_isco="7543" if s2_15acod=="75602"					
	replace occup_isco="7549" if s2_15acod=="75603"					
	replace occup_isco="7549" if s2_15acod=="75604"					
	replace occup_isco="7549" if s2_15acod=="75699"					
	replace occup_isco="8111" if s2_15acod=="81101"				
	replace occup_isco="8112" if s2_15acod=="81102"				
	replace occup_isco="8113" if s2_15acod=="81103"				
	replace occup_isco="8114" if s2_15acod=="81104"				
	replace occup_isco="8114" if s2_15acod=="81105"					
	replace occup_isco="8121" if s2_15acod=="81201"				
	replace occup_isco="8122" if s2_15acod=="81202"						
	replace occup_isco="8131" if s2_15acod=="81301"				
	replace occup_isco="8132" if s2_15acod=="81302"						
	replace occup_isco="8141" if s2_15acod=="81401"				
	replace occup_isco="8142" if s2_15acod=="81402"				
	replace occup_isco="8143" if s2_15acod=="81403"							
	replace occup_isco="8151" if s2_15acod=="81501"				
	replace occup_isco="8152" if s2_15acod=="81502"				
	replace occup_isco="8153" if s2_15acod=="81503"				
	replace occup_isco="8154" if s2_15acod=="81504"				
	replace occup_isco="8155" if s2_15acod=="81505"				
	replace occup_isco="8156" if s2_15acod=="81506"							
	replace occup_isco="8159" if s2_15acod=="81599"						
	replace occup_isco="8160" if s2_15acod=="81600"							
	replace occup_isco="8171" if s2_15acod=="81701"				
	replace occup_isco="8172" if s2_15acod=="81702"							
	replace occup_isco="8181" if s2_15acod=="81801"				
	replace occup_isco="8182" if s2_15acod=="81802"				
	replace occup_isco="8183" if s2_15acod=="81803"				
	replace occup_isco="8189" if s2_15acod=="81804"				
	replace occup_isco="8189" if s2_15acod=="81899"							
	replace occup_isco="8211" if s2_15acod=="82101"				
	replace occup_isco="8212" if s2_15acod=="82102"				
	replace occup_isco="8219" if s2_15acod=="82199"						
	replace occup_isco="8311" if s2_15acod=="83101"				
	replace occup_isco="8312" if s2_15acod=="83102"							
	replace occup_isco="8321" if s2_15acod=="83201"				
	replace occup_isco="8322" if s2_15acod=="83202"				
	replace occup_isco="8322" if s2_15acod=="83203"				
	replace occup_isco="8322" if s2_15acod=="83209"						
	replace occup_isco="8331" if s2_15acod=="83302"				
	replace occup_isco="8332" if s2_15acod=="83301"				
	replace occup_isco="8332" if s2_15acod=="83399"							
	replace occup_isco="8341" if s2_15acod=="83401"				
	replace occup_isco="8342" if s2_15acod=="83402"				
	replace occup_isco="8343" if s2_15acod=="83403"				
	replace occup_isco="8344" if s2_15acod=="83404"				
	replace occup_isco="8340" if s2_15acod=="83499"						
	replace occup_isco="8350" if s2_15acod=="83500"				
	replace occup_isco="9111" if s2_15acod=="91101"				
	replace occup_isco="9112" if s2_15acod=="91102"						
	replace occup_isco="9121" if s2_15acod=="91201"				
	replace occup_isco="9122" if s2_15acod=="91202"				
	replace occup_isco="9123" if s2_15acod=="91203"				
	replace occup_isco="9129" if s2_15acod=="91299"							
	replace occup_isco="9211" if s2_15acod=="92101"				
	replace occup_isco="9212" if s2_15acod=="92102"				
	replace occup_isco="9213" if s2_15acod=="92103"				
	replace occup_isco="9214" if s2_15acod=="92104"				
	replace occup_isco="9215" if s2_15acod=="92105"				
	replace occup_isco="9216" if s2_15acod=="92106"				
	replace occup_isco="9210" if s2_15acod=="92199"							
	replace occup_isco="9311" if s2_15acod=="93101"				
	replace occup_isco="9312" if s2_15acod=="93102"				
	replace occup_isco="9313" if s2_15acod=="93103"						
	replace occup_isco="9321" if s2_15acod=="93201"				
	replace occup_isco="9329" if s2_15acod=="93299"						
	replace occup_isco="9331" if s2_15acod=="93301"				
	replace occup_isco="9332" if s2_15acod=="93302"				
	replace occup_isco="9333" if s2_15acod=="93303"				
	replace occup_isco="9334" if s2_15acod=="93304"				
	replace occup_isco="9330" if s2_15acod=="93399"							
	replace occup_isco="9412" if s2_15acod=="94100"							
	replace occup_isco="9520" if s2_15acod=="95101"				
	replace occup_isco="9510" if s2_15acod=="95102"				
	replace occup_isco="9510" if s2_15acod=="95103"				
	replace occup_isco="9500" if s2_15acod=="95199"							
	replace occup_isco="9611" if s2_15acod=="96101"				
	replace occup_isco="9612" if s2_15acod=="96102"				
	replace occup_isco="9613" if s2_15acod=="96103"						
	replace occup_isco="9621" if s2_15acod=="96201"							
	replace occup_isco="9629" if s2_15acod=="96202"				
	replace occup_isco="9623" if s2_15acod=="96203"				
	replace occup_isco="9623" if s2_15acod=="96204"				
	replace occup_isco="9624" if s2_15acod=="96205"				
	replace occup_isco="9629" if s2_15acod=="96299"				
	replace occup_isco="1430" if s2_15acod=="143"		
	replace occup_isco="2000" if s2_15acod=="2"	
	replace occup_isco="2110" if s2_15acod=="211"	
	replace occup_isco="2140" if s2_15acod=="214"	
	replace occup_isco="2300" if s2_15acod=="23"	
	replace occup_isco="2340" if s2_15acod=="234"	
	replace occup_isco="2350" if s2_15acod=="235"	
	replace occup_isco="2410" if s2_15acod=="241"	
	replace occup_isco="2620" if s2_15acod=="262"	
	replace occup_isco="3110" if s2_15acod=="311"	
	replace occup_isco="3250" if s2_15acod=="325"	
	replace occup_isco="3310" if s2_15acod=="331"	
	replace occup_isco="3320" if s2_15acod=="332"	
	replace occup_isco="3410" if s2_15acod=="341"	
	replace occup_isco="3430" if s2_15acod=="343"	
	replace occup_isco="4220" if s2_15acod=="422"	
	replace occup_isco="5200" if s2_15acod=="52"	
	replace occup_isco="5240" if s2_15acod=="524"	
	replace occup_isco="6100" if s2_15acod=="61"	
	replace occup_isco="6100" if s2_15acod=="610"	
	replace occup_isco="6200" if s2_15acod=="620"
	replace occup_isco="7100" if s2_15acod=="71"
	replace occup_isco="7120" if s2_15acod=="712"
	replace occup_isco="7210" if s2_15acod=="721"
	replace occup_isco="7230" if s2_15acod=="723"
	replace occup_isco="7300" if s2_15acod=="733"
	replace occup_isco="7510" if s2_15acod=="751"
	replace occup_isco="7530" if s2_15acod=="753"
	replace occup_isco="8100" if s2_15acod=="81"
	replace occup_isco="8300" if s2_15acod=="83"
	replace occup_isco="8320" if s2_15acod=="832"
	replace occup_isco="8330" if s2_15acod=="833"
	replace occup_isco="8340" if s2_15acod=="834"
	replace occup_isco="9210" if s2_15acod=="921"
	replace occup_isco="1100" if s2_15acod=="111"	
	replace occup_isco="1310" if s2_15acod=="131"	
	replace occup_isco="1320" if s2_15acod=="132"	
	replace occup_isco="1340" if s2_15acod=="134"	
	replace occup_isco="1410" if s2_15acod=="141"	
	replace occup_isco="2120" if s2_15acod=="212"	
	replace occup_isco="2160" if s2_15acod=="215"
	replace occup_isco="2210" if s2_15acod=="221"
	replace occup_isco="2310" if s2_15acod=="231"
	replace occup_isco="2320" if s2_15acod=="232"
	replace occup_isco="2330" if s2_15acod=="233"
	replace occup_isco="2420" if s2_15acod=="242"
	replace occup_isco="2430" if s2_15acod=="243"
	replace occup_isco="2510" if s2_15acod=="251"
	replace occup_isco="2520" if s2_15acod=="252"
	replace occup_isco="2610" if s2_15acod=="261"
	replace occup_isco="2630" if s2_15acod=="263"
	replace occup_isco="3100" if s2_15acod=="31"
	replace occup_isco="3120" if s2_15acod=="312"
	replace occup_isco="3130" if s2_15acod=="313"
	replace occup_isco="3140" if s2_15acod=="314"
	replace occup_isco="3150" if s2_15acod=="315"
	replace occup_isco="3210" if s2_15acod=="321"
	replace occup_isco="3330" if s2_15acod=="333"
	replace occup_isco="3340" if s2_15acod=="334"
	replace occup_isco="3520" if s2_15acod=="352"
	replace occup_isco="4110" if s2_15acod=="411"
	replace occup_isco="4210" if s2_15acod=="421"
	replace occup_isco="4310" if s2_15acod=="431"
	replace occup_isco="4410" if s2_15acod=="441"
	replace occup_isco="5110" if s2_15acod=="511"
	replace occup_isco="5120" if s2_15acod=="512"
	replace occup_isco="5140" if s2_15acod=="514"
	replace occup_isco="5150" if s2_15acod=="515"
	replace occup_isco="5210" if s2_15acod=="521"
	replace occup_isco="5310" if s2_15acod=="531"
	replace occup_isco="5410" if s2_15acod=="541"
	replace occup_isco="7110" if s2_15acod=="711"
	replace occup_isco="7130" if s2_15acod=="713"
	replace occup_isco="7310" if s2_15acod=="731"
	replace occup_isco="7320" if s2_15acod=="734"
	replace occup_isco="7410" if s2_15acod=="741"
	replace occup_isco="7420" if s2_15acod=="742"
	replace occup_isco="7530" if s2_15acod=="754"
	replace occup_isco="7530" if s2_15acod=="755"
	replace occup_isco="8110" if s2_15acod=="811"
	replace occup_isco="8120" if s2_15acod=="812"
	replace occup_isco="8130" if s2_15acod=="813"
	replace occup_isco="8140" if s2_15acod=="814"
	replace occup_isco="8150" if s2_15acod=="815"
	replace occup_isco="8180" if s2_15acod=="818"
	replace occup_isco="8210" if s2_15acod=="821"
	replace occup_isco="9110" if s2_15acod=="911"
	replace occup_isco="9120" if s2_15acod=="912"
	replace occup_isco="9310" if s2_15acod=="931"
	replace occup_isco="9320" if s2_15acod=="932"
	replace occup_isco="9330" if s2_15acod=="933"
	replace occup_isco="9610" if s2_15acod=="961"
	replace occup_isco="9620" if s2_15acod=="962"
	replace occup_isco="9000" if s2_15acod=="97000"
	replace occup_isco="9000" if s2_15acod=="99992"
	replace occup_isco="9000" if s2_15acod=="99996"
	replace occup_isco= "1200" if s2_15acod=="12"
	replace occup_isco= "1200" if s2_15acod=="121"
	replace occup_isco= "2130" if s2_15acod=="213"
	replace occup_isco= "2250" if s2_15acod=="224"
	replace occup_isco= "3220" if s2_15acod=="322"
	replace occup_isco= "3230" if s2_15acod=="323"
	replace occup_isco= "3350" if s2_15acod=="335"
	replace occup_isco= "3420" if s2_15acod=="342"
	replace occup_isco= "3500" if s2_15acod=="35"
	replace occup_isco= "3510" if s2_15acod=="351"
	replace occup_isco= "4100" if s2_15acod=="41"
	replace occup_isco= "4320" if s2_15acod=="432"
	replace occup_isco= "5220" if s2_15acod=="522"
	replace occup_isco= "5200" if s2_15acod=="525"
	replace occup_isco= "6000" if s2_15acod=="6"
	replace occup_isco= "6100" if s2_15acod=="62"
	replace occup_isco= "6220" if s2_15acod=="632"
	replace occup_isco= "7200" if s2_15acod=="72"
	replace occup_isco= "7220" if s2_15acod=="722"
	replace occup_isco= "7400" if s2_15acod=="74"
	replace occup_isco= "7500" if s2_15acod=="75"
	replace occup_isco= "7520" if s2_15acod=="752"
	replace occup_isco= "9100" if s2_15acod=="91"
	replace occup_isco= "9400" if s2_15acod=="94"
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	gen byte occup = .
	replace occup = 1 if inrange(occup_isco, "1000","1439")
	replace occup = 2 if inrange(occup_isco, "2000","2719")
	replace occup = 3 if inrange(occup_isco, "3000","3599")
	replace occup = 4 if inrange(occup_isco, "4000","4490")
	replace occup = 5 if inrange(occup_isco, "5000","5490")
	replace occup = 6 if inrange(occup_isco, "6000","6390")
	replace occup = 7 if inrange(occup_isco, "7000","7590")
	replace occup = 8 if inrange(occup_isco, "8000","8309")
	replace occup = 9 if inrange(occup_isco, "9000","9709")
	replace occup = 10 if inrange(occup_isco,"0100","0399")
	replace occup = 99 if occup_isco=="9999"
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
	order  s2_33a s2_38a
	egen wage_no_compen = rowtotal(s2_33a - s2_38a)
	replace wage_no_compen=. if lstatus!=1
	replace wage_no_compen=. if wage_no_compen==0
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>

/* <_unitwage_note>
	Unitwage refers to the unit used to record wage_no_compen, *not* the unit of
	general wage payent. For example, PHL LFS asks about wage periodicity, then
	asks for basic daily pay. The value of that pay would be wage_no_compen,
	while unitwage is code 1 ("Daily") for all, regardless of the periodicity.
</_unitwage_note> */
	gen byte unitwage = s2_33b
	replace unitwage = s2_38b if s2_33b==.
	recode unitwage 4=5 5=4 
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours = s2_29a*s2_28
	replace whours=0.75 if s2_29b==45
	replace whours=0.25 if s2_29b==15
	replace whours=0.50 if s2_29b==30
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
	gen double wage_total=.
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
/* <_contract_note>

	aggrements are considered as contract

</_contract_note> */
	gen byte contract = s2_21
	recode contract 2/3=1 4/5=0
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte healthins = s2_36a
	recode healthins 2=0
	label var healthins "Employment has health insurance primary job 7 day recall"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen byte socialsec = .
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
	gen firmsize_l = s2_26a
	recode firmsize_l 1=1 2=2 3=11 4=15 5=20 6=50
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen firmsize_u= s2_26a
	recode firmsize_u 1=1 2=10 3=14 4=19 5=49 6=. 
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen byte empstat_2 = s2_46
	recode empstat_2 2=1 3=4 5=3 7=2 8=1 6=5
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat_2
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2 = .
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2 = s2_45acod
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	gen industrycat_isic_help_2= s2_45acod + substr("00000", 1, 5 - length(s2_45acod))
	replace industrycat_isic_help_2 = substr(industrycat_isic_help_2, 1, length(industrycat_isic_help_2) - 2) 
	replace industrycat_isic_help_2="" if s2_45acod=="G"
	replace industrycat_isic_help_2="" if s2_45acod=="F"
	replace industrycat_isic_help_2="" if s2_45acod=="C"
	replace industrycat_isic_help_2="" if s2_45acod=="M"
	replace industrycat_isic_help_2="" if s2_45acod=="A"
	gen industrycat_isic_2 = industrycat_isic_help_2 + substr("0000", 1, 4 - length(industrycat_isic_help_2))
	replace industrycat_isic_2="" if industrycat_isic_2=="0000"
	replace industrycat_isic_2="" if industrycat_isic_2=="8900"
	replace industrycat_isic_2="9900" if industrycat_isic_2=="9990"
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen byte industrycat10_2 = .
	replace industrycat10_2=1 if inrange(industrycat_isic_2,"0100","0399")
	replace industrycat10_2=2 if inrange(industrycat_isic_2,"0500","0999")
	replace industrycat10_2=3 if inrange(industrycat_isic_2,"1000","3399")
	replace industrycat10_2=4 if inrange(industrycat_isic_2,"3500","3999")
	replace industrycat10_2=5 if inrange(industrycat_isic_2,"4100","4399")
	replace industrycat10_2=6 if inrange(industrycat_isic_2,"4500","4799")
	replace industrycat10_2=7 if inrange(industrycat_isic_2,"4900","5399")
	replace industrycat10_2=6 if inrange(industrycat_isic_2,"5500","5699")
	replace industrycat10_2=7 if inrange(industrycat_isic_2,"5800","6399")
	replace industrycat10_2=8 if inrange(industrycat_isic_2,"6400","6899")
	replace industrycat10_2=8 if inrange(industrycat_isic_2,"6900","7599")
	replace industrycat10_2=8 if inrange(industrycat_isic_2,"7700","8299")
	replace industrycat10_2=9 if inrange(industrycat_isic_2,"8400","8419")
	replace industrycat10_2=9 if inrange(industrycat_isic_2,"8420", "8499")
	replace industrycat10_2=10 if inrange(industrycat_isic_2,"8500","8559")
	replace industrycat10_2=10 if inrange(industrycat_isic_2,"8600","8899")
	replace industrycat10_2=10 if inrange(industrycat_isic_2,"9000","9399")
	replace industrycat10_2=10 if inrange(industrycat_isic_2,"9400","9609")
	replace industrycat10_2=10 if inrange(industrycat_isic_2,"9700","9899")
	replace industrycat10_2=10 if inrange(industrycat_isic_2,"9900","9999")
	replace industrycat10_2=6 if s2_45acod=="G"
	replace industrycat10_2=5 if s2_45acod=="F"
	replace industrycat10_2=3 if s2_45acod=="C"
	replace industrycat10_2=8 if s2_45acod=="M"
	replace industrycat10_2=1 if s2_45acod=="A"
	replace industrycat10_2=. if lstatus!=1
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
	gen occup_orig_2 = s2_44acod
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen occup_isco_2=""
	replace occup_isco_2="0110" if s2_44acod=="01000"
	replace occup_isco_2="0210" if s2_44acod=="02000"
	replace occup_isco_2="0310" if s2_44acod=="03099"
	replace occup_isco_2="1111" if s2_44acod=="11101"
	replace occup_isco_2="1111" if s2_44acod=="11102"
	replace occup_isco_2="2612" if s2_44acod=="11103"
	replace occup_isco_2="1111" if s2_44acod=="11104"
	replace occup_isco_2="1112" if s2_44acod=="11105"
	replace occup_isco_2="1112" if s2_44acod=="11106"
	replace occup_isco_2="1112" if s2_44acod=="11107"
	replace occup_isco_2="1113" if s2_44acod=="11108"
	replace occup_isco_2="1114" if s2_44acod=="11109"
	replace occup_isco_2="1114" if s2_44acod=="11110"
	replace occup_isco_2="1114" if s2_44acod=="11111"
	replace occup_isco_2="1114" if s2_44acod=="11199"
	replace occup_isco_2="1120" if s2_44acod=="11201"
	replace occup_isco_2="1120" if s2_44acod=="11202"
	replace occup_isco_2="1120" if s2_44acod=="11203"
	replace occup_isco_2="1120" if s2_44acod=="11204"
	replace occup_isco_2="1120" if s2_44acod=="11205"
	replace occup_isco_2="1120" if s2_44acod=="11206"
	replace occup_isco_2="1120" if s2_44acod=="11207"
	replace occup_isco_2="1120" if s2_44acod=="11208"
	replace occup_isco_2="1120" if s2_44acod=="11209"
	replace occup_isco_2="1120" if s2_44acod=="11210"
	replace occup_isco_2="1120" if s2_44acod=="11211"
	replace occup_isco_2="1120" if s2_44acod=="11212"
	replace occup_isco_2="1120" if s2_44acod=="11213"
	replace occup_isco_2="1120" if s2_44acod=="11214"
	replace occup_isco_2="1120" if s2_44acod=="11215"
	replace occup_isco_2="1120" if s2_44acod=="11299"
	replace occup_isco_2="1211" if s2_44acod=="12101"
	replace occup_isco_2="1212" if s2_44acod=="12102"
	replace occup_isco_2="1213" if s2_44acod=="12103"
	replace occup_isco_2="1221" if s2_44acod=="12104"
	replace occup_isco_2="1222" if s2_44acod=="12105"
	replace occup_isco_2="1223" if s2_44acod=="12106"
	replace occup_isco_2="1324" if s2_44acod=="12107"
	replace occup_isco_2="1330" if s2_44acod=="12108"
	replace occup_isco_2="1324" if s2_44acod=="12109"
	replace occup_isco_2="1349" if s2_44acod=="12110"
	replace occup_isco_2="1349" if s2_44acod=="12111"
	replace occup_isco_2="1349" if s2_44acod=="12199"
	replace occup_isco_2="1311" if s2_44acod=="13101"
	replace occup_isco_2="1311" if s2_44acod=="13102"
	replace occup_isco_2="1311" if s2_44acod=="13103"
	replace occup_isco_2="1311" if s2_44acod=="13104"
	replace occup_isco_2="1312" if s2_44acod=="13105"
	replace occup_isco_2="1321" if s2_44acod=="13201"
	replace occup_isco_2="1322" if s2_44acod=="13202"
	replace occup_isco_2="1323" if s2_44acod=="13203"
	replace occup_isco_2="1330" if s2_44acod=="13300"
	replace occup_isco_2="1344" if s2_44acod=="13401"
	replace occup_isco_2="1342" if s2_44acod=="13402"
	replace occup_isco_2="1345" if s2_44acod=="13403"
	replace occup_isco_2="1346" if s2_44acod=="13404"
	replace occup_isco_2="1349" if s2_44acod=="13499"
	replace occup_isco_2="1411" if s2_44acod=="14101"
	replace occup_isco_2="1412" if s2_44acod=="14102"
	replace occup_isco_2="1420" if s2_44acod=="14200"
	replace occup_isco_2="1439" if s2_44acod=="14301"
	replace occup_isco_2="1439" if s2_44acod=="14302"
	replace occup_isco_2="1439" if s2_44acod=="14303"
	replace occup_isco_2="1439" if s2_44acod=="14304"
	replace occup_isco_2="1439" if s2_44acod=="14305"
	replace occup_isco_2="1431" if s2_44acod=="14306"
	replace occup_isco_2="1324" if s2_44acod=="14307"
	replace occup_isco_2="1349" if s2_44acod=="14308"
	replace occup_isco_2="1439" if s2_44acod=="14399"
	replace occup_isco_2="2111" if s2_44acod=="21101"				
	replace occup_isco_2="2112" if s2_44acod=="21102"				
	replace occup_isco_2="2113" if s2_44acod=="21103"				
	replace occup_isco_2="2114" if s2_44acod=="21104"				
	replace occup_isco_2="2632" if s2_44acod=="21105"				
	replace occup_isco_2="2120" if s2_44acod=="21201"				
	replace occup_isco_2="2120" if s2_44acod=="21202"							
	replace occup_isco_2="2131" if s2_44acod=="21301"				
	replace occup_isco_2="2131" if s2_44acod=="21302"				
	replace occup_isco_2="2132" if s2_44acod=="21303"				
	replace occup_isco_2="2133" if s2_44acod=="21304"				
	replace occup_isco_2="2130" if s2_44acod=="21399"							
	replace occup_isco_2="2142" if s2_44acod=="21401"				
	replace occup_isco_2="2151" if s2_44acod=="21402"				
	replace occup_isco_2="2152" if s2_44acod=="21403"				
	replace occup_isco_2="2144" if s2_44acod=="21404"				
	replace occup_isco_2="2145" if s2_44acod=="21405"				
	replace occup_isco_2="2146" if s2_44acod=="21406"				
	replace occup_isco_2="2149" if s2_44acod=="21407"				
	replace occup_isco_2="2149" if s2_44acod=="21408"	
	replace occup_isco_2="2149" if s2_44acod=="21409"	
	replace occup_isco_2="2149" if s2_44acod=="21499"							
	replace occup_isco_2="2160" if s2_44acod=="21501"							
	replace occup_isco_2="2165" if s2_44acod=="21502"				
	replace occup_isco_2="2166" if s2_44acod=="21503"							
	replace occup_isco_2="2210" if s2_44acod=="22101"							
	replace occup_isco_2="2269" if s2_44acod=="22102"							
	replace occup_isco_2="2221" if s2_44acod=="22201"				
	replace occup_isco_2="2222" if s2_44acod=="22202"							
	replace occup_isco_2="2230" if s2_44acod=="22300"							
	replace occup_isco_2="2250" if s2_44acod=="22400"							
	replace occup_isco_2="2261" if s2_44acod=="22501"				
	replace occup_isco_2="2262" if s2_44acod=="22502"				
	replace occup_isco_2="2264" if s2_44acod=="22503"				
	replace occup_isco_2="2265" if s2_44acod=="22504"				
	replace occup_isco_2="2266" if s2_44acod=="22505"				
	replace occup_isco_2="2267" if s2_44acod=="22506"							
	replace occup_isco_2="2269" if s2_44acod=="22599"							
	replace occup_isco_2="2310" if s2_44acod=="23101"				
	replace occup_isco_2="2310" if s2_44acod=="23102"							
	replace occup_isco_2="2320" if s2_44acod=="23200"							
	replace occup_isco_2="2330" if s2_44acod=="23300"							
	replace occup_isco_2="2341" if s2_44acod=="23401"				
	replace occup_isco_2="2342" if s2_44acod=="23402"							
	replace occup_isco_2="2351" if s2_44acod=="23501"				
	replace occup_isco_2="2359" if s2_44acod=="23502"				
	replace occup_isco_2="2352" if s2_44acod=="23503"				
	replace occup_isco_2="2353" if s2_44acod=="23504"				
	replace occup_isco_2="2354" if s2_44acod=="23505"				
	replace occup_isco_2="2355" if s2_44acod=="23506"				
	replace occup_isco_2="2355" if s2_44acod=="23507"				
	replace occup_isco_2="2356" if s2_44acod=="23508"				
	replace occup_isco_2="5165" if s2_44acod=="23509"				
	replace occup_isco_2="3423" if s2_44acod=="23510"				
	replace occup_isco_2="2359" if s2_44acod=="23599"						
	replace occup_isco_2="2411" if s2_44acod=="24101"				
	replace occup_isco_2="2411" if s2_44acod=="24102"
	replace occup_isco_2="2410" if s2_44acod=="24103"
	replace occup_isco_2="2410" if s2_44acod=="24199"							
	replace occup_isco_2="2421" if s2_44acod=="24201"							
	replace occup_isco_2="2420" if s2_44acod=="24299"							
	replace occup_isco_2="2431" if s2_44acod=="24301"				
	replace occup_isco_2="2432" if s2_44acod=="24302"				
	replace occup_isco_2="2433" if s2_44acod=="24303"						
	replace occup_isco_2="2511" if s2_44acod=="25101"				
	replace occup_isco_2="2512" if s2_44acod=="25102"				
	replace occup_isco_2="2513" if s2_44acod=="25103"							
	replace occup_isco_2="2529" if s2_44acod=="25199"							
	replace occup_isco_2="2521" if s2_44acod=="25201"				
	replace occup_isco_2="2522" if s2_44acod=="25202"				
	replace occup_isco_2="2523" if s2_44acod=="25203"				
	replace occup_isco_2="2153" if s2_44acod=="25204"				
	replace occup_isco_2="2520" if s2_44acod=="25299"							
	replace occup_isco_2="2611" if s2_44acod=="26101"				
	replace occup_isco_2="2619" if s2_44acod=="26102"				
	replace occup_isco_2="2612" if s2_44acod=="26103"				
	replace occup_isco_2="2619" if s2_44acod=="26199"							
	replace occup_isco_2="2633" if s2_44acod=="26201"				
	replace occup_isco_2="2633" if s2_44acod=="26203"				
	replace occup_isco_2="2641" if s2_44acod=="26202"				
	replace occup_isco_2="2634" if s2_44acod=="26204"				
	replace occup_isco_2="2600" if s2_44acod=="26205"				
	replace occup_isco_2="2622" if s2_44acod=="26206"				
	replace occup_isco_2="2643" if s2_44acod=="26207"				
	replace occup_isco_2="2643" if s2_44acod=="26208"				
	replace occup_isco_2="2600" if s2_44acod=="26299"							
	replace occup_isco_2="2631" if s2_44acod=="26301"				
	replace occup_isco_2="2632" if s2_44acod=="26302"				
	replace occup_isco_2="2632" if s2_44acod=="26303"				
	replace occup_isco_2="2632" if s2_44acod=="26304"				
	replace occup_isco_2="2635" if s2_44acod=="26305"				
	replace occup_isco_2="2642" if s2_44acod=="26306"				
	replace occup_isco_2="2636" if s2_44acod=="26307"				
	replace occup_isco_2="2630" if s2_44acod=="26399"						
	replace occup_isco_2="2641" if s2_44acod=="26400"						
	replace occup_isco_2="2651" if s2_44acod=="26501"				
	replace occup_isco_2="2652" if s2_44acod=="26502"				
	replace occup_isco_2="2652" if s2_44acod=="26503"				
	replace occup_isco_2="2652" if s2_44acod=="26504"				
	replace occup_isco_2="2652" if s2_44acod=="26505"				
	replace occup_isco_2="2652" if s2_44acod=="26506"				
	replace occup_isco_2="2653" if s2_44acod=="26507"				
	replace occup_isco_2="2654" if s2_44acod=="26508"				
	replace occup_isco_2="2655" if s2_44acod=="26509"				
	replace occup_isco_2="2656" if s2_44acod=="26510"				
	replace occup_isco_2="2659" if s2_44acod=="26599"						
	replace occup_isco_2="2000" if s2_44acod=="27100"				
	replace occup_isco_2="3111" if s2_44acod=="31101"				
	replace occup_isco_2="3111" if s2_44acod=="31102"				
	replace occup_isco_2="3111" if s2_44acod=="31103"				
	replace occup_isco_2="3111" if s2_44acod=="31104"				
	replace occup_isco_2="3119" if s2_44acod=="31105"				
	replace occup_isco_2="3112" if s2_44acod=="31106"				
	replace occup_isco_2="3113" if s2_44acod=="31107"				
	replace occup_isco_2="3114" if s2_44acod=="31108"				
	replace occup_isco_2="3115" if s2_44acod=="31109"				
	replace occup_isco_2="3116" if s2_44acod=="31110"				
	replace occup_isco_2="3117" if s2_44acod=="31111"				
	replace occup_isco_2="3118" if s2_44acod=="31112"				
	replace occup_isco_2="3119" if s2_44acod=="31113"				
	replace occup_isco_2="3119" if s2_44acod=="31114"				
	replace occup_isco_2="3119" if s2_44acod=="31199"				
	replace occup_isco_2="3121" if s2_44acod=="31201"				
	replace occup_isco_2="3122" if s2_44acod=="31202"				
	replace occup_isco_2="3123" if s2_44acod=="31203"						
	replace occup_isco_2="3131" if s2_44acod=="31301"				
	replace occup_isco_2="3132" if s2_44acod=="31302"				
	replace occup_isco_2="3132" if s2_44acod=="31303"				
	replace occup_isco_2="3133" if s2_44acod=="31304"				
	replace occup_isco_2="3134" if s2_44acod=="31305"				
	replace occup_isco_2="3135" if s2_44acod=="31306"				
	replace occup_isco_2="3139" if s2_44acod=="31399"							
	replace occup_isco_2="3141" if s2_44acod=="31401"				
	replace occup_isco_2="3142" if s2_44acod=="31402"				
	replace occup_isco_2="3143" if s2_44acod=="31403"				
	replace occup_isco_2="3141" if s2_44acod=="31499"							
	replace occup_isco_2="3151" if s2_44acod=="31501"				
	replace occup_isco_2="3152" if s2_44acod=="31502"				
	replace occup_isco_2="3153" if s2_44acod=="31503"				
	replace occup_isco_2="3154" if s2_44acod=="31504"				
	replace occup_isco_2="3155" if s2_44acod=="31505"				
	replace occup_isco_2="3153" if s2_44acod=="31599"						
	replace occup_isco_2="3211" if s2_44acod=="32101"				
	replace occup_isco_2="3212" if s2_44acod=="32102"				
	replace occup_isco_2="3214" if s2_44acod=="32103"				
	replace occup_isco_2="3213" if s2_44acod=="32104"						
	replace occup_isco_2="3221" if s2_44acod=="32201"				
	replace occup_isco_2="3222" if s2_44acod=="32202"						
	replace occup_isco_2="3230" if s2_44acod=="32301"							
	replace occup_isco_2="3240" if s2_44acod=="32400"							
	replace occup_isco_2="3251" if s2_44acod=="32501"				
	replace occup_isco_2="3252" if s2_44acod=="32502"				
	replace occup_isco_2="3253" if s2_44acod=="32503"				
	replace occup_isco_2="3254" if s2_44acod=="32504"				
	replace occup_isco_2="3255" if s2_44acod=="32505"				
	replace occup_isco_2="3256" if s2_44acod=="32506"				
	replace occup_isco_2="3257" if s2_44acod=="32507"				
	replace occup_isco_2="3213" if s2_44acod=="32508"				
	replace occup_isco_2="3258" if s2_44acod=="32509"				
	replace occup_isco_2="3259" if s2_44acod=="32510"				
	replace occup_isco_2="3259" if s2_44acod=="32511"				
	replace occup_isco_2="3259" if s2_44acod=="32599"							
	replace occup_isco_2="3311" if s2_44acod=="33101"				
	replace occup_isco_2="3312" if s2_44acod=="33102"				
	replace occup_isco_2="3313" if s2_44acod=="33103"				
	replace occup_isco_2="3314" if s2_44acod=="33104"				
	replace occup_isco_2="3315" if s2_44acod=="33105"							
	replace occup_isco_2="3321" if s2_44acod=="33201"				
	replace occup_isco_2="3322" if s2_44acod=="33202"				
	replace occup_isco_2="3323" if s2_44acod=="33203"				
	replace occup_isco_2="3324" if s2_44acod=="33204"				
	replace occup_isco_2="3320" if s2_44acod=="33299"							
	replace occup_isco_2="3331" if s2_44acod=="33301"				
	replace occup_isco_2="3332" if s2_44acod=="33302"				
	replace occup_isco_2="3333" if s2_44acod=="33303"				
	replace occup_isco_2="3334" if s2_44acod=="33304"				
	replace occup_isco_2="3339" if s2_44acod=="33305"				
	replace occup_isco_2="3339" if s2_44acod=="33399"										
	replace occup_isco_2="3342" if s2_44acod=="33401"				
	replace occup_isco_2="3343" if s2_44acod=="33402"				
	replace occup_isco_2="3344" if s2_44acod=="33403"				
	replace occup_isco_2="3340" if s2_44acod=="33499"						
	replace occup_isco_2="3351" if s2_44acod=="33501"				
	replace occup_isco_2="3352" if s2_44acod=="33502"				
	replace occup_isco_2="3353" if s2_44acod=="33503"				
	replace occup_isco_2="3354" if s2_44acod=="33504"				
	replace occup_isco_2="3355" if s2_44acod=="33505"				
	replace occup_isco_2="3359" if s2_44acod=="33599"							
	replace occup_isco_2="3411" if s2_44acod=="34101"				
	replace occup_isco_2="3412" if s2_44acod=="34102"				
	replace occup_isco_2="3413" if s2_44acod=="34103"						
	replace occup_isco_2="3421" if s2_44acod=="34201"				
	replace occup_isco_2="3422" if s2_44acod=="34202"							
	replace occup_isco_2="3431" if s2_44acod=="34301"				
	replace occup_isco_2="3432" if s2_44acod=="34302"				
	replace occup_isco_2="3118" if s2_44acod=="34303"				
	replace occup_isco_2="3433" if s2_44acod=="34304"				
	replace occup_isco_2="3434" if s2_44acod=="34305"				
	replace occup_isco_2="3435" if s2_44acod=="34306"				
	replace occup_isco_2="3435" if s2_44acod=="34307"				
	replace occup_isco_2="3435" if s2_44acod=="34308"				
	replace occup_isco_2="3435" if s2_44acod=="34309"				
	replace occup_isco_2="3435" if s2_44acod=="34310"				
	replace occup_isco_2="3435" if s2_44acod=="34311"				
	replace occup_isco_2="3435" if s2_44acod=="34312"				
	replace occup_isco_2="3435" if s2_44acod=="34313"				
	replace occup_isco_2="3435" if s2_44acod=="34399"							
	replace occup_isco_2="3511" if s2_44acod=="35101"				
	replace occup_isco_2="3512" if s2_44acod=="35102"				
	replace occup_isco_2="3513" if s2_44acod=="35103"				
	replace occup_isco_2="3514" if s2_44acod=="35104"				
	replace occup_isco_2="3510" if s2_44acod=="35199"						
	replace occup_isco_2="3521" if s2_44acod=="35201"				
	replace occup_isco_2="3522" if s2_44acod=="35202"	
	replace occup_isco_2="4110" if s2_44acod=="41100"						
	replace occup_isco_2="4120" if s2_44acod=="41200"					
	replace occup_isco_2="4211" if s2_44acod=="42101"				
	replace occup_isco_2="4212" if s2_44acod=="42102"				
	replace occup_isco_2="4213" if s2_44acod=="42103"				
	replace occup_isco_2="4214" if s2_44acod=="42104"
	replace occup_isco_2="4214" if s2_44acod=="42199"
	replace occup_isco_2="4221" if s2_44acod=="42201"				
	replace occup_isco_2="4222" if s2_44acod=="42202"				
	replace occup_isco_2="4223" if s2_44acod=="42203"				
	replace occup_isco_2="4224" if s2_44acod=="42204"				
	replace occup_isco_2="4225" if s2_44acod=="42205"				
	replace occup_isco_2="4226" if s2_44acod=="42206"				
	replace occup_isco_2="4227" if s2_44acod=="42207"				
	replace occup_isco_2="4229" if s2_44acod=="42299"							
	replace occup_isco_2="4311" if s2_44acod=="43101"				
	replace occup_isco_2="4312" if s2_44acod=="43102"				
	replace occup_isco_2="4313" if s2_44acod=="43103"							
	replace occup_isco_2="4321" if s2_44acod=="43201"				
	replace occup_isco_2="4322" if s2_44acod=="43202"				
	replace occup_isco_2="4323" if s2_44acod=="43203"						
	replace occup_isco_2="4411" if s2_44acod=="44101"				
	replace occup_isco_2="4412" if s2_44acod=="44102"				
	replace occup_isco_2="4413" if s2_44acod=="44103"				
	replace occup_isco_2="4414" if s2_44acod=="44104"				
	replace occup_isco_2="4415" if s2_44acod=="44105"							
	replace occup_isco_2="4419" if s2_44acod=="44199"				
	replace occup_isco_2="5111" if s2_44acod=="51101"
	replace occup_isco_2="5112" if s2_44acod=="51102"
	replace occup_isco_2="5113" if s2_44acod=="51103"
	replace occup_isco_2="5120" if s2_44acod=="51200"
	replace occup_isco_2="5130" if s2_44acod=="51300"
	replace occup_isco_2="5141" if s2_44acod=="51401"
	replace occup_isco_2="5142" if s2_44acod=="51402"
	replace occup_isco_2="5151" if s2_44acod=="51501"
	replace occup_isco_2="5152" if s2_44acod=="51502"
	replace occup_isco_2="5153" if s2_44acod=="51503"
	replace occup_isco_2="5161" if s2_44acod=="51601"
	replace occup_isco_2="5162" if s2_44acod=="51602"
	replace occup_isco_2="5163" if s2_44acod=="51603"
	replace occup_isco_2="5164" if s2_44acod=="51604"
	replace occup_isco_2="5169" if s2_44acod=="51605"
	replace occup_isco_2="5169" if s2_44acod=="51699"
	replace occup_isco_2="5211" if s2_44acod=="52101"
	replace occup_isco_2="5221" if s2_44acod=="52201"
	replace occup_isco_2="5222" if s2_44acod=="52202"
	replace occup_isco_2="5223" if s2_44acod=="52203"
	replace occup_isco_2="5230" if s2_44acod=="52301"
	replace occup_isco_2="5241" if s2_44acod=="52401"
	replace occup_isco_2="5242" if s2_44acod=="52402"
	replace occup_isco_2="5243" if s2_44acod=="52403"
	replace occup_isco_2="5244" if s2_44acod=="52404"
	replace occup_isco_2="5245" if s2_44acod=="52405"
	replace occup_isco_2="5246" if s2_44acod=="52406"
	replace occup_isco_2="5249" if s2_44acod=="52407"
	replace occup_isco_2="5249" if s2_44acod=="52499"
	replace occup_isco_2="5212" if s2_44acod=="52501"
	replace occup_isco_2="9520" if s2_44acod=="52502"
	replace occup_isco_2="5310" if s2_44acod=="53101"
	replace occup_isco_2="5310" if s2_44acod=="53102"
	replace occup_isco_2="5321" if s2_44acod=="53201"
	replace occup_isco_2="5322" if s2_44acod=="53202"
	replace occup_isco_2="5329" if s2_44acod=="53203"
	replace occup_isco_2="5411" if s2_44acod=="54101"
	replace occup_isco_2="5412" if s2_44acod=="54102"
	replace occup_isco_2="5412" if s2_44acod=="54103"
	replace occup_isco_2="5413" if s2_44acod=="54104"
	replace occup_isco_2="5414" if s2_44acod=="54105"
	replace occup_isco_2="5419" if s2_44acod=="54199"
	replace occup_isco_2="6111" if s2_44acod=="61001"				
	replace occup_isco_2="6111" if s2_44acod=="61002"				
	replace occup_isco_2="6111" if s2_44acod=="61003"				
	replace occup_isco_2="6111" if s2_44acod=="61004"				
	replace occup_isco_2="6111" if s2_44acod=="61005"				
	replace occup_isco_2="6111" if s2_44acod=="61006"				
	replace occup_isco_2="6111" if s2_44acod=="61007"				
	replace occup_isco_2="6111" if s2_44acod=="61008"				
	replace occup_isco_2="6112" if s2_44acod=="61009"				
	replace occup_isco_2="6112" if s2_44acod=="61010"				
	replace occup_isco_2="6112" if s2_44acod=="61011"				
	replace occup_isco_2="6112" if s2_44acod=="61012"				
	replace occup_isco_2="6113" if s2_44acod=="61013"						
	replace occup_isco_2="6110" if s2_44acod=="61014"	
	replace occup_isco_2="6110" if s2_44acod=="61015"
	replace occup_isco_2="6110" if s2_44acod=="61099"							
	replace occup_isco_2="6121" if s2_44acod=="62001"				
	replace occup_isco_2="6121" if s2_44acod=="62002"				
	replace occup_isco_2="6121" if s2_44acod=="62003"				
	replace occup_isco_2="6121" if s2_44acod=="62004"				
	replace occup_isco_2="6122" if s2_44acod=="62005"				
	replace occup_isco_2="6129" if s2_44acod=="62006"				
	replace occup_isco_2="6129" if s2_44acod=="62007"				
	replace occup_isco_2="6129" if s2_44acod=="62008"				
	replace occup_isco_2="6123" if s2_44acod=="62009"				
	replace occup_isco_2="6123" if s2_44acod=="62010"				
	replace occup_isco_2="6121" if s2_44acod=="62011"				
	replace occup_isco_2="6129" if s2_44acod=="62099"							
	replace occup_isco_2="6210" if s2_44acod=="63100"							
	replace occup_isco_2="6221" if s2_44acod=="63201"				
	replace occup_isco_2="6222" if s2_44acod=="63202"				
	replace occup_isco_2="6224" if s2_44acod=="63203"				
	replace occup_isco_2="7111" if s2_44acod=="71102"					
	replace occup_isco_2="7110" if s2_44acod=="71101"					
	replace occup_isco_2="7115" if s2_44acod=="71103"					
	replace occup_isco_2="7119" if s2_44acod=="71199"					
	replace occup_isco_2="7115" if s2_44acod=="71104"									
	replace occup_isco_2="7121" if s2_44acod=="71201"					
	replace occup_isco_2="7122" if s2_44acod=="71202"					
	replace occup_isco_2="7123" if s2_44acod=="71203"					
	replace occup_isco_2="7124" if s2_44acod=="71204"					
	replace occup_isco_2="7125" if s2_44acod=="71205"					
	replace occup_isco_2="7126" if s2_44acod=="71206"					
	replace occup_isco_2="7127" if s2_44acod=="71207"					
	replace occup_isco_2="7210" if s2_44acod=="71299"									
	replace occup_isco_2="7131" if s2_44acod=="71301"					
	replace occup_isco_2="7132" if s2_44acod=="71302"					
	replace occup_isco_2="7133" if s2_44acod=="71303"									
	replace occup_isco_2="7211" if s2_44acod=="72101"					
	replace occup_isco_2="7212" if s2_44acod=="72102"					
	replace occup_isco_2="7213" if s2_44acod=="72103"					
	replace occup_isco_2="7214" if s2_44acod=="72104"					
	replace occup_isco_2="7215" if s2_44acod=="72105"									
	replace occup_isco_2="7221" if s2_44acod=="72201"					
	replace occup_isco_2="7222" if s2_44acod=="72202"					
	replace occup_isco_2="7223" if s2_44acod=="72203"					
	replace occup_isco_2="7224" if s2_44acod=="72204"									
	replace occup_isco_2="7231" if s2_44acod=="72301"					
	replace occup_isco_2="7232" if s2_44acod=="72302"					
	replace occup_isco_2="7233" if s2_44acod=="72303"					
	replace occup_isco_2="7234" if s2_44acod=="72304"
	replace occup_isco_2="7230" if s2_44acod=="72305"
	replace occup_isco_2="7230" if s2_44acod=="72399"								
	replace occup_isco_2="7311" if s2_44acod=="73101"					
	replace occup_isco_2="7312" if s2_44acod=="73102"					
	replace occup_isco_2="7312" if s2_44acod=="73103"					
	replace occup_isco_2="7312" if s2_44acod=="73104"					
	replace occup_isco_2="7313" if s2_44acod=="73105"									
	replace occup_isco_2="7314" if s2_44acod=="73201"					
	replace occup_isco_2="7315" if s2_44acod=="73202"					
	replace occup_isco_2="7316" if s2_44acod=="73203"								
	replace occup_isco_2="7317" if s2_44acod=="73301"					
	replace occup_isco_2="7318" if s2_44acod=="73302"					
	replace occup_isco_2="7318" if s2_44acod=="73303"					
	replace occup_isco_2="7319" if s2_44acod=="73304"					
	replace occup_isco_2="7314" if s2_44acod=="73305"					
	replace occup_isco_2="7318" if s2_44acod=="73306"					
	replace occup_isco_2="7319" if s2_44acod=="73399"								
	replace occup_isco_2="7321" if s2_44acod=="73401"					
	replace occup_isco_2="7322" if s2_44acod=="73402"					
	replace occup_isco_2="7323" if s2_44acod=="73403"					
	replace occup_isco_2="7323" if s2_44acod=="73499"									
	replace occup_isco_2="7412" if s2_44acod=="74101"					
	replace occup_isco_2="7413" if s2_44acod=="74102"									
	replace occup_isco_2="7421" if s2_44acod=="74201"					
	replace occup_isco_2="7422" if s2_44acod=="74202"									
	replace occup_isco_2="7511" if s2_44acod=="75101"					
	replace occup_isco_2="7512" if s2_44acod=="75102"					
	replace occup_isco_2="7513" if s2_44acod=="75103"					
	replace occup_isco_2="7514" if s2_44acod=="75104"					
	replace occup_isco_2="7515" if s2_44acod=="75105"					
	replace occup_isco_2="7516" if s2_44acod=="75106"					
	replace occup_isco_2="7514" if s2_44acod=="75199"									
	replace occup_isco_2="7521" if s2_44acod=="75201"					
	replace occup_isco_2="7522" if s2_44acod=="75202"					
	replace occup_isco_2="7523" if s2_44acod=="75203"					
	replace occup_isco_2="7520" if s2_44acod=="75299"									
	replace occup_isco_2="7532" if s2_44acod=="75301"					
	replace occup_isco_2="7532" if s2_44acod=="75302"					
	replace occup_isco_2="7531" if s2_44acod=="75303"					
	replace occup_isco_2="7531" if s2_44acod=="75304"					
	replace occup_isco_2="7531" if s2_44acod=="75305"					
	replace occup_isco_2="7532" if s2_44acod=="75306"					
	replace occup_isco_2="7533" if s2_44acod=="75307"					
	replace occup_isco_2="7534" if s2_44acod=="75308"					
	replace occup_isco_2="7530" if s2_44acod=="75399"								
	replace occup_isco_2="7535" if s2_44acod=="75401"					
	replace occup_isco_2="7536" if s2_44acod=="75402"					
	replace occup_isco_2="7530" if s2_44acod=="75403"					
	replace occup_isco_2="7531" if s2_44acod=="75404"					
	replace occup_isco_2="7530" if s2_44acod=="75499"								
	replace occup_isco_2="8111" if s2_44acod=="75501"					
	replace occup_isco_2="8111" if s2_44acod=="75502"					
	replace occup_isco_2="7513" if s2_44acod=="75503"					
	replace occup_isco_2="7542" if s2_44acod=="75504"					
	replace occup_isco_2="8110" if s2_44acod=="75599"								
	replace occup_isco_2="7541" if s2_44acod=="75601"								
	replace occup_isco_2="7543" if s2_44acod=="75602"					
	replace occup_isco_2="7549" if s2_44acod=="75603"					
	replace occup_isco_2="7549" if s2_44acod=="75604"					
	replace occup_isco_2="7549" if s2_44acod=="75699"					
	replace occup_isco_2="8111" if s2_44acod=="81101"				
	replace occup_isco_2="8112" if s2_44acod=="81102"				
	replace occup_isco_2="8113" if s2_44acod=="81103"				
	replace occup_isco_2="8114" if s2_44acod=="81104"				
	replace occup_isco_2="8114" if s2_44acod=="81105"					
	replace occup_isco_2="8121" if s2_44acod=="81201"				
	replace occup_isco_2="8122" if s2_44acod=="81202"						
	replace occup_isco_2="8131" if s2_44acod=="81301"				
	replace occup_isco_2="8132" if s2_44acod=="81302"						
	replace occup_isco_2="8141" if s2_44acod=="81401"				
	replace occup_isco_2="8142" if s2_44acod=="81402"				
	replace occup_isco_2="8143" if s2_44acod=="81403"							
	replace occup_isco_2="8151" if s2_44acod=="81501"				
	replace occup_isco_2="8152" if s2_44acod=="81502"				
	replace occup_isco_2="8153" if s2_44acod=="81503"				
	replace occup_isco_2="8154" if s2_44acod=="81504"				
	replace occup_isco_2="8155" if s2_44acod=="81505"				
	replace occup_isco_2="8156" if s2_44acod=="81506"							
	replace occup_isco_2="8159" if s2_44acod=="81599"						
	replace occup_isco_2="8160" if s2_44acod=="81600"							
	replace occup_isco_2="8171" if s2_44acod=="81701"				
	replace occup_isco_2="8172" if s2_44acod=="81702"							
	replace occup_isco_2="8181" if s2_44acod=="81801"				
	replace occup_isco_2="8182" if s2_44acod=="81802"				
	replace occup_isco_2="8183" if s2_44acod=="81803"				
	replace occup_isco_2="8189" if s2_44acod=="81804"				
	replace occup_isco_2="8189" if s2_44acod=="81899"							
	replace occup_isco_2="8211" if s2_44acod=="82101"				
	replace occup_isco_2="8212" if s2_44acod=="82102"				
	replace occup_isco_2="8219" if s2_44acod=="82199"						
	replace occup_isco_2="8311" if s2_44acod=="83101"				
	replace occup_isco_2="8312" if s2_44acod=="83102"							
	replace occup_isco_2="8321" if s2_44acod=="83201"				
	replace occup_isco_2="8322" if s2_44acod=="83202"				
	replace occup_isco_2="8322" if s2_44acod=="83203"				
	replace occup_isco_2="8322" if s2_44acod=="83209"						
	replace occup_isco_2="8331" if s2_44acod=="83302"				
	replace occup_isco_2="8332" if s2_44acod=="83301"				
	replace occup_isco_2="8332" if s2_44acod=="83399"							
	replace occup_isco_2="8341" if s2_44acod=="83401"				
	replace occup_isco_2="8342" if s2_44acod=="83402"				
	replace occup_isco_2="8343" if s2_44acod=="83403"				
	replace occup_isco_2="8344" if s2_44acod=="83404"				
	replace occup_isco_2="8340" if s2_44acod=="83499"						
	replace occup_isco_2="8350" if s2_44acod=="83500"				
	replace occup_isco_2="9111" if s2_44acod=="91101"				
	replace occup_isco_2="9112" if s2_44acod=="91102"						
	replace occup_isco_2="9121" if s2_44acod=="91201"				
	replace occup_isco_2="9122" if s2_44acod=="91202"				
	replace occup_isco_2="9123" if s2_44acod=="91203"				
	replace occup_isco_2="9129" if s2_44acod=="91299"							
	replace occup_isco_2="9211" if s2_44acod=="92101"				
	replace occup_isco_2="9212" if s2_44acod=="92102"				
	replace occup_isco_2="9213" if s2_44acod=="92103"				
	replace occup_isco_2="9214" if s2_44acod=="92104"				
	replace occup_isco_2="9215" if s2_44acod=="92105"				
	replace occup_isco_2="9216" if s2_44acod=="92106"				
	replace occup_isco_2="9210" if s2_44acod=="92199"							
	replace occup_isco_2="9311" if s2_44acod=="93101"				
	replace occup_isco_2="9312" if s2_44acod=="93102"				
	replace occup_isco_2="9313" if s2_44acod=="93103"						
	replace occup_isco_2="9321" if s2_44acod=="93201"				
	replace occup_isco_2="9329" if s2_44acod=="93299"						
	replace occup_isco_2="9331" if s2_44acod=="93301"				
	replace occup_isco_2="9332" if s2_44acod=="93302"				
	replace occup_isco_2="9333" if s2_44acod=="93303"				
	replace occup_isco_2="9334" if s2_44acod=="93304"				
	replace occup_isco_2="9330" if s2_44acod=="93399"							
	replace occup_isco_2="9412" if s2_44acod=="94100"							
	replace occup_isco_2="9520" if s2_44acod=="95101"				
	replace occup_isco_2="9510" if s2_44acod=="95102"				
	replace occup_isco_2="9510" if s2_44acod=="95103"				
	replace occup_isco_2="9500" if s2_44acod=="95199"							
	replace occup_isco_2="9611" if s2_44acod=="96101"				
	replace occup_isco_2="9612" if s2_44acod=="96102"				
	replace occup_isco_2="9613" if s2_44acod=="96103"						
	replace occup_isco_2="9621" if s2_44acod=="96201"							
	replace occup_isco_2="9629" if s2_44acod=="96202"				
	replace occup_isco_2="9623" if s2_44acod=="96203"				
	replace occup_isco_2="9623" if s2_44acod=="96204"				
	replace occup_isco_2="9624" if s2_44acod=="96205"				
	replace occup_isco_2="9629" if s2_44acod=="96299"				
	replace occup_isco_2="1430" if s2_44acod=="143"		
	replace occup_isco_2="2000" if s2_44acod=="2"	
	replace occup_isco_2="2110" if s2_44acod=="211"	
	replace occup_isco_2="2140" if s2_44acod=="214"	
	replace occup_isco_2="2300" if s2_44acod=="23"	
	replace occup_isco_2="2340" if s2_44acod=="234"	
	replace occup_isco_2="2350" if s2_44acod=="235"	
	replace occup_isco_2="2410" if s2_44acod=="241"	
	replace occup_isco_2="2620" if s2_44acod=="262"	
	replace occup_isco_2="3110" if s2_44acod=="311"	
	replace occup_isco_2="3250" if s2_44acod=="325"	
	replace occup_isco_2="3310" if s2_44acod=="331"	
	replace occup_isco_2="3320" if s2_44acod=="332"	
	replace occup_isco_2="3410" if s2_44acod=="341"	
	replace occup_isco_2="3430" if s2_44acod=="343"	
	replace occup_isco_2="4220" if s2_44acod=="422"	
	replace occup_isco_2="5200" if s2_44acod=="52"	
	replace occup_isco_2="5240" if s2_44acod=="524"	
	replace occup_isco_2="6100" if s2_44acod=="61"	
	replace occup_isco_2="6100" if s2_44acod=="610"	
	replace occup_isco_2="6200" if s2_44acod=="620"
	replace occup_isco_2="7100" if s2_44acod=="71"
	replace occup_isco_2="7120" if s2_44acod=="712"
	replace occup_isco_2="7210" if s2_44acod=="721"
	replace occup_isco_2="7230" if s2_44acod=="723"
	replace occup_isco_2="7300" if s2_44acod=="733"
	replace occup_isco_2="7510" if s2_44acod=="751"
	replace occup_isco_2="7530" if s2_44acod=="753"
	replace occup_isco_2="8100" if s2_44acod=="81"
	replace occup_isco_2="8300" if s2_44acod=="83"
	replace occup_isco_2="8320" if s2_44acod=="832"
	replace occup_isco_2="8330" if s2_44acod=="833"
	replace occup_isco_2="8340" if s2_44acod=="834"
	replace occup_isco_2="9210" if s2_44acod=="921"
	
	replace occup_isco_2="1100" if s2_44acod=="111"	
	replace occup_isco_2="1310" if s2_44acod=="131"	
	replace occup_isco_2="1320" if s2_44acod=="132"	
	replace occup_isco_2="1340" if s2_44acod=="134"	
	replace occup_isco_2="1410" if s2_44acod=="141"	
	replace occup_isco_2="2120" if s2_44acod=="212"	
	replace occup_isco_2="2160" if s2_44acod=="215"
	replace occup_isco_2="2210" if s2_44acod=="221"
	replace occup_isco_2="2310" if s2_44acod=="231"
	replace occup_isco_2="2320" if s2_44acod=="232"
	replace occup_isco_2="2330" if s2_44acod=="233"
	replace occup_isco_2="2420" if s2_44acod=="242"
	replace occup_isco_2="2430" if s2_44acod=="243"
	replace occup_isco_2="2510" if s2_44acod=="251"
	replace occup_isco_2="2520" if s2_44acod=="252"
	replace occup_isco_2="2610" if s2_44acod=="261"
	replace occup_isco_2="2630" if s2_44acod=="263"
	replace occup_isco_2="3100" if s2_44acod=="31"
	replace occup_isco_2="3120" if s2_44acod=="312"
	replace occup_isco_2="3130" if s2_44acod=="313"
	replace occup_isco_2="3140" if s2_44acod=="314"
	replace occup_isco_2="3150" if s2_44acod=="315"
	replace occup_isco_2="3210" if s2_44acod=="321"
	replace occup_isco_2="3330" if s2_44acod=="333"
	replace occup_isco_2="3340" if s2_44acod=="334"
	replace occup_isco_2="3520" if s2_44acod=="352"
	replace occup_isco_2="4110" if s2_44acod=="411"
	replace occup_isco_2="4210" if s2_44acod=="421"
	replace occup_isco_2="4310" if s2_44acod=="431"
	replace occup_isco_2="4410" if s2_44acod=="441"
	
	replace occup_isco_2="5110" if s2_44acod=="511"
	replace occup_isco_2="5120" if s2_44acod=="512"
	replace occup_isco_2="5140" if s2_44acod=="514"
	replace occup_isco_2="5150" if s2_44acod=="515"
	replace occup_isco_2="5210" if s2_44acod=="521"
	replace occup_isco_2="5310" if s2_44acod=="531"
	replace occup_isco_2="5410" if s2_44acod=="541"
	replace occup_isco_2="7110" if s2_44acod=="711"
	replace occup_isco_2="7130" if s2_44acod=="713"
	replace occup_isco_2="7310" if s2_44acod=="731"
	replace occup_isco_2="7320" if s2_44acod=="734"
	replace occup_isco_2="7410" if s2_44acod=="741"
	replace occup_isco_2="7420" if s2_44acod=="742"
	
	replace occup_isco_2="7530" if s2_44acod=="754"
	replace occup_isco_2="7530" if s2_44acod=="755"
	replace occup_isco_2="8110" if s2_44acod=="811"
	replace occup_isco_2="8120" if s2_44acod=="812"
	replace occup_isco_2="8130" if s2_44acod=="813"
	replace occup_isco_2="8140" if s2_44acod=="814"
	replace occup_isco_2="8150" if s2_44acod=="815"
	replace occup_isco_2="8180" if s2_44acod=="818"
	replace occup_isco_2="8210" if s2_44acod=="821"
	replace occup_isco_2="9110" if s2_44acod=="911"
	replace occup_isco_2="9120" if s2_44acod=="912"
	replace occup_isco_2="9310" if s2_44acod=="931"
	replace occup_isco_2="9320" if s2_44acod=="932"
	replace occup_isco_2="9330" if s2_44acod=="933"
	replace occup_isco_2="9610" if s2_44acod=="961"
	replace occup_isco_2="9620" if s2_44acod=="962"
	replace occup_isco_2="9000" if s2_44acod=="97000"
	replace occup_isco_2="9000" if s2_44acod=="99992"
	replace occup_isco_2="9000" if s2_44acod=="99996"
	
	
	replace occup_isco_2="0100" if s2_44acod=="01"
	replace occup_isco_2="1200" if s2_44acod=="121"
	replace occup_isco_2="2130" if s2_44acod=="213"
	replace occup_isco_2="3220" if s2_44acod=="322"
	replace occup_isco_2="3420" if s2_44acod=="342"
	replace occup_isco_2="3510" if s2_44acod=="351"
	replace occup_isco_2="5100" if s2_44acod=="51"
	replace occup_isco_2="5200" if s2_44acod=="525"
	replace occup_isco_2="6210" if s2_44acod=="631"
	replace occup_isco_2="9000" if s2_44acod=="99999"
	replace occup_isco_2="6220" if s2_44acod=="632"
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_2_>
	gen byte occup_2 = .
	replace occup_2 = 1 if inrange(occup_isco_2, "1000","1430")
	replace occup_2 = 2 if inrange(occup_isco_2, "2000","2719")
	replace occup_2 = 3 if inrange(occup_isco_2, "3000","3599")
	replace occup_2 = 4 if inrange(occup_isco_2, "4000","4499")
	replace occup_2 = 5 if inrange(occup_isco_2, "5000","5499")
	replace occup_2 = 6 if inrange(occup_isco_2, "6000","6399")
	replace occup_2 = 7 if inrange(occup_isco_2, "7000","7599")
	replace occup_2 = 8 if inrange(occup_isco_2, "8000","8399")
	replace occup_2 = 9 if inrange(occup_isco_2, "9000","9709")
	replace occup_2 = 10 if inrange(occup_isco_2,"0100","0399")
	replace occup_2 = 99 if occup_isco_2=="9999"
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
	order  s2_50a s2_52a
	egen wage_no_compen_2 = rowtotal(s2_50a - s2_52a)
	replace wage_no_compen_2=. if lstatus!=1
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2 = s2_50b
	replace unitwage_2 = s2_52b if s2_50b==.
	recode unitwage_2 4=5 5=4 
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>



*<_whours_2_>
	gen whours_2 = s2_48a
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
	gen byte lstatus_year = .
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
	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>

*<_industrycat10_year_>
	gen byte industrycat10_year = .
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
	gen occup_orig_year = .
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	gen occup_isco_year = ""
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

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome panel visit_no

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
