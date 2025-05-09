/*%%============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				COL_2004_GLD_ECH_v01
<_Application_>					Stata 17
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) Eliana Carranza, Andreas Eberhardt, Alejandro Rueda-Sanz
<_Date created_>				2022-05-20

-------------------------------------------------------------------------

<_Country_>					    Colombia (COL)
<_Survey Title_>				Encuesta Continua de Hogares - ECH
<_Survey Year_>					2004
<_Study ID_>					N/A </_Study ID_>
<_Data collection from_>		[07/2004] </_Data collection from_>
<_Data collection to_>			[09/2004] </_Data collection to_>
<_Source of dataset_> 				Departamento Administrativo Nacional de Estadistica - DANE
<_Sample size (HH)_> 				37,698
<_Sample size (IND)_> 				152,589
<_Sampling method_> 			 </_Sampling method_>
<_Geographic coverage_> 		National </_Geographic coverage_>
<_Currency_> 					Colombian Peso (COP) </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>		ICLS-13		 </_ICLS Version_>
<_ISCED Version_>		ISCED 1997		 </_ISCED Version_>
<_ISCO Version_>		ISCO-1968		 </_ISCO Version_>
<_OCCUP National_>		CNO 1970		 </_OCCUP National_>
<_ISIC Version_>		ISIC REV 3</_ISIC Version_>
<_INDUS National_>		ISIC REV 3 COLOMBIA 	</_INDUS National_>

-----------------------------------------------------------------------
<_Version Control_>

* Date: 2022-28-05 - Changes from I2D2 to GLD
* Date: 2022-16-12 - Changes to default harmonization information and several variables.

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
local server  "Y:\GLD-Harmonization\582018_AQ"
local country "COL"
local year    "2004"
local survey  "ECH"
local vermast "V01"
local veralt  "V02"

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

** DATABASE ASSEMBLENT

use "`path_in_stata'/ECH_2004_1.dta"

forvalues i=2/12 {
    append using "`path_in_stata'\ECH_2004_`i'.dta", force
}

save "`path_in_stata'/ECH_2004.dta", replace

/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode = "COL"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "ECH"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "ECH"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	gen icls_v = "ICLS-13"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	gen isced_version = "isced_1997"
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
	gen isco_version = "isco_1968"
	label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
	gen isic_version = "isic_3"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	gen int year = 2004
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
	gen int_year = 2004
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	destring mes, replace
	gen  int_month = mes
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
	tostring llave_viv, gen(helper_h) format("%12.0f")
	gen hhid = helper_h
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	gen helper_n=hogar
	egen pid = concat(helper_h orden helper_n)
	label var pid "Individual ID"
	isid pid
*</_pid_>


*<_weight_>
	gen weight = (fex_c_2011/12)
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

}

/*%%=============================================================================================
	3: Geography
==============================================================================================%%*/

{

*<_urban_>
 	gen urban=clase
	replace urban = 0 if urban == 2
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>
*</_urban_>

*<_subnatid1_>
	gen subnatid1 = ""
	replace subnatid1 =" 1 - Atlantica" if dpto == 13 | dpto == 20 | dpto ==23 | dpto == 44 | dpto ==47 | dpto == 70 | dpto ==8
	replace subnatid1 =" 2 - Oriental" if  dpto == 15 | dpto == 25 | dpto ==50 | dpto == 54 | dpto ==68
	replace subnatid1 =" 3 - Central" if  dpto == 17 | dpto == 18 | dpto ==41 | dpto == 63 | dpto ==66 | dpto == 73
	replace subnatid1 =" 4 - Pacifica" if  dpto == 19 | dpto == 27 | dpto ==52 | dpto == 76 | dpto == 5
	replace subnatid1 =" 5 - Santa Fe de Bogota" if  dpto == 11

/* <_subnatid1_note>

	The variable is string and country-specific categorical. Numeric entries are coded in string format using the following naming convention: "1 – Hatay". That is, the variable itself is to be string, not a labelled numeric vector.

	Example of entries would be "1 - Alaska",  "2 - Arkansas", ...

</_subnatid1_note> */
*</_subnatid1_>


*<_subnatid2_>
	gen subnatid2 = string(dpto)
	replace subnatid2 = "5 - Antioquia" if subnatid2 == "5"
	replace subnatid2 = "8 - Atlántico" if subnatid2 == "8"
	replace subnatid2 = "11 - Bogotá, D.C." if subnatid2 == "11"
	replace subnatid2 = "13 - Bolívar" if subnatid2 == "13"
	replace subnatid2 = "15 - Boyacá" if subnatid2 == "15"
	replace subnatid2 = "17 - Caldas" if subnatid2 == "17"
	replace subnatid2 = "18 - Caquetá" if subnatid2 == "18"
	replace subnatid2 = "19 - Cauca" if subnatid2 == "19"
	replace subnatid2 = "20 - Cesar" if subnatid2 == "20"
	replace subnatid2 = "23 - Córdoba" if subnatid2 == "23"
	replace subnatid2 = "25 - Cundinamarca" if subnatid2 == "25"
	replace subnatid2 = "27 - Chocó" if subnatid2 == "27"
	replace subnatid2 = "41 - Huila" if subnatid2 == "41"
	replace subnatid2 = "44 - La Guajira" if subnatid2 == "44"
	replace subnatid2 = "47 - Magdalena" if subnatid2 == "47"
	replace subnatid2 = "50 - Meta" if subnatid2 == "50"
	replace subnatid2 = "52 - Nariño" if subnatid2 == "52"
	replace subnatid2 = "54 - Norte de Santander" if subnatid2 == "54"
	replace subnatid2 = "63 - Quindío" if subnatid2 == "63"
	replace subnatid2 = "66 - Risaralda" if subnatid2 == "66"
	replace subnatid2 = "68 - Santander" if subnatid2 == "68"
	replace subnatid2 = "70 - Sucre" if subnatid2 == "70"
	replace subnatid2 = "73 - Tolima" if subnatid2 == "73"
	replace subnatid2 = "76 - Valle del Cauca" if subnatid2 == "76"
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
	gen subnatidsurvey = ""
replace subnatidsurvey = subnatid2 + " - Urban" if urban == 1
replace subnatidsurvey = subnatid2 + " - Rural" if urban == 0
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
	destring p3, force replace
	gen a=1 if (p3!=14 & p3!=15)
	egen byte hsize=sum(a), by(hhid)
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	destring p5, force replace
	gen age = p5
	replace age=98 if age>98 & age!=.
	label var age "Individual age"
*</_age_>

*<_male_>
	destring p4, force replace
	gen male =(p4==1)
	recode male 2=0
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen relationharm = p3
	recode relationharm 4/9=5 10/15=6
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

*<_relationcs_>
	gen relationcs = p3
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen marital= p6
	recode marital (2=1) (1 5=2) (3=5)
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

Education module is only asked to those XX and older.

</_ed_mod_age_note> */

gen byte ed_mod_age = 5
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	destring p8, force replace
	gen byte school = p8
	recode school 2=0
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school lblschool
*</_school_>

*<_literacy_>
	destring p7, force replace
	gen byte literacy = p7
	recode literacy 2=0
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen byte educy = .
	replace educy=. if age<ed_mod_age & age!=.
	label var educy "Years of education"

*</_educy_>


*<_educat7_>
	gen byte educat7 =.
	tostring p10, replace force
	replace educat7=1 if p10=="100" | inrange(p10,"200","201")
	replace educat7=2 if inrange(p10,"300","304")
	replace educat7=3 if p10=="305"
	replace educat7=4 if p10=="400" | inrange(p10,"406","410")
	replace educat7=5 if p10=="411"
	replace educat7=5 if p10=="412"
	replace educat7=5 if p10=="413"
	replace educat7=7 if inrange(p10,"500","515")
	label var educat7 "Level of education 1"
	la de lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete"
	label values educat7 lbleducat7
*</_educat7_>


*<_educat5_>
	gen byte educat5 = educat7
	recode educat5 (4=3) (5=4)  (6/7=5)
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
	gen educat_orig = p10n
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

*<_vocational_field_>
	gen vocational_field = .
	label var vocational_field "Field of training"
*</_vocational_field_>

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
	gen byte minlaborage = 12
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
  *<_lstatus_>
  destring p24 p16 p23, replace

  /* <_lstatus_note>
       Note that the Colombian survey has different age cut-offs for the employment questions. 10 years for rural areas, 12 for urban areas. Here we use a single cut-off of 12.

       Further note that results may vary somewhat from official results and from results hitherto calculate in I2D2. The numbers for employed should be the same but the concept of unemployment varied.

       For GLD unemployed are those looking for a job *and* available.

       For the NSO all those available (regardless of whether looking or not for a job) are unemployed.

       For the I2D2 coding, using SEDLAC, unemployed where all those looking for a job (regardless of whether available or not).
  </_lstatus_note> */

       gen lstatus = .
       * Employed are those who answer questions for employment
       replace lstatus = 1 if !missing(p24) & inrange(age,12,9999)
       * Unemployed is looking (p16 == 1) *and* available (p23 == 1)
       replace lstatus = 2 if p16 == 1 & p23 == 1 & inrange(age,12,9999)
       * NLF are the rest
       replace lstatus = 3 if missing(lstatus) & inrange(age,12,9999)

       label var lstatus "Labor status"
       la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
       label values lstatus lbllstatus
  *</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = .
	replace potential_lf = . if age < minlaborage & age != .
	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen byte underemployment = .
	replace underemployment = . if age < minlaborage & age != .
	replace underemployment = . if lstatus == 1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>

*<_nlfreason_>
	destring p18, force replace
	gen byte nlfreason=p18
	recode nlfreason 14=1 1/13=5 15=5
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>

*<_unempldur_l_>
	gen byte unempldur_l= int(p49/4)
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u= int(p49/4)
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*
{

*<_empstat_>

/* <_empstat_note>

     In the ECH (2001-2005) the question on the relationship at work (p27)
     has different answer codes depending on whether the questionnaire was 
     administered in "cabeceras" and metropolitan areas, then if it was administered
     in "rural areas". In the former the question has 7 answer codes, in the latter
     8. The distribution is different.
	 
	 In 2005 the difference is between whethe a survey was conducted in an urban , rural
	 or traditional setting.
     
     The first three codes are the same but rural areas have an additional category
     (4) to represent day labourers. The subsequent codes 5-8 are then the same as
     4-7 in the other areas.
     
     The raw variable "clase" can be used to differentiate between them.

</_empstat_note> */

     destring p27, replace
	 destring clase, replace
     gen byte empstat= p27
     recode empstat (1 2 3 = 1) (4 = 4) (5 = 3) (6 = 2) (7 = 5) if clase == 1
     recode empstat (1 2 3 4 = 1) (5 = 4) (6 = 3) (7 = 2) (8 = 5) if clase == 2
     replace empstat=. if lstatus!=1
     label var empstat "Employment status during past week primary job 7 day recall"
     la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status", replace
     label values empstat lblempstat
*</_empstat_>


* NUMBER OF ADDITIONAL JOBS
	gen byte njobs= .
	replace njobs=. if lstatus!=1
	label var njobs "Number of additional jobs"

*<_ocusec_>
	destring p27, replace
	gen byte ocusec = p27
	recode ocusec 0=. 2=1 1 3 4 5=2 6=. 7=. 8=.
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	replace ocusec=. if lstatus!=1
	label values ocusec lblocusec
*</_ocusec_>

*<_industry_orig_> // NOT IN DATASET: rama4d
/* <_industry_orig_note>
	Original information at letter code level for ISIC 3(3.1).

        | #  | A/Z | Name
        | 1  | A   | Agriculture, hunting and forestry
        | 2  | B   | Fishing
        | 3  | C   | Mining and quarrying
        | 4  | D   | Manufacturing
        | 5  | E   | Electricity, gas and water supply
        | 6  | F   | Construction
        | 7  | G   | Wholesale and retail trade; repair of motor vehicles, motorcycles and
personal and household goods
        | 8  | H   | Hotels and restaurants
        | 9  | I   | Transport, storage and communications
        | 10 | J   | Financial intermediation
        | 11 | K   | Real estate, renting and business activities
        | 12 | L   | Public administration and defence; compulsory social security
        | 13 | M   | Education
        | 14 | N   | Health and social work
        | 15 | O   | Other community, social and personal service activities
        | 16 | P   | Activities of private households as employers and undifferentiated production
activities of private households
        | 17 | Q   | Extra-territorial organizations and bodies

        See https://unstats.un.org/unsd/statcom/doc02/isic.pdf for more details

</_industry_orig_note> */
	gen industry_orig = string(p26)
	replace industry_orig="" if lstatus!=1
	replace industry_orig="" if industry_orig=="0"
	replace industry_orig="" if industry_orig=="00"
	replace industry_orig="" if industry_orig=="0000"
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_> // Colombian ISIC rev 3 to ISIC rev. 3, rama4d not in ECH merged dataset given
	gen industrycat_isic = substr(industry_orig,1,2)
	replace industrycat_isic="01" if industry_orig=="1"
	replace industrycat_isic="02" if industry_orig=="2"
	replace industrycat_isic="05" if industry_orig=="5"
	gen industrycat_isic_a=industrycat_isic + "00" if !missing(industry_orig)
	drop industrycat_isic
	rename industrycat_isic_a industrycat_isic
	label var industrycat_isic "ISIC code of primary job 7 day recall"

*</_industrycat_isic_>


*<_industrycat10_>
	gen rama2d=substr(industrycat_isic,1,2)
	gen byte industrycat10 = .
	replace industrycat10 = 1 if inrange(rama2d,"01", "05")
	replace industrycat10 = 2 if inrange(rama2d,"10", "14")
	replace industrycat10 = 3 if inrange(rama2d,"15", "37")
	replace industrycat10 = 4 if inrange(rama2d,"40", "41")
	replace industrycat10 = 5 if rama2d=="45"
	replace industrycat10 = 6 if rama2d=="55" | inrange(rama2d,"50","52")
	replace industrycat10 = 7 if inrange(rama2d,"60","64")
	replace industrycat10 = 8 if inrange(rama2d,"65","67")| inrange(rama2d,"70","74")
	replace industrycat10 = 9 if rama2d=="75"
	replace industrycat10 = 10 if inrange(rama2d,"80","99")
	replace industrycat10 = . if lstatus!=1
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
*</_industrycat10_>


*<_industrycat4_>
	gen industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
	rename p24 oficio
	destring oficio, replace
	gen occup_orig = oficio
	replace occup_orig=. if lstatus!=1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	gen help_isco=string(oficio)
	gen occup_isco = help_isco + substr("0000", 1, 4 - length(help_isco))
	replace occup_isco="" if lstatus!=1
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	* Note: Colombia uses CNO 1970, which is based on ISCO-1968 according to the Ministry of Labor's Resolution 1186 of 1970, that adopts the code according to ILO standards.
	* Convert ISCO-68 categories to ISCO-88/ISCO-08 1 digit Major Groups

	gen byte occup = .
	replace occup = 1 if oficio == 20 | oficio == 21 | oficio == 30 | oficio == 40 | oficio == 41 | oficio == 50 | oficio == 51 | oficio == 60
	replace occup = 2 if oficio == 1 | oficio == 2 | oficio == 5 | oficio == 6 | oficio == 8 | oficio == 9 | oficio == 2 | oficio == 11 | oficio == 12 | oficio == 13 | oficio == 14 | oficio == 15 | oficio == 19
	replace occup = 3 if oficio == 3 | oficio == 4 | oficio == 7 | oficio == 16 | oficio == 17 | oficio == 18 | oficio == 31 | oficio == 34 | oficio == 42 | oficio == 43 | oficio == 44 | oficio == 86
	replace occup = 4 if oficio == 32 | oficio == 33 | oficio == 37 | oficio == 38 | oficio == 39
	replace occup = 5 if oficio == 36 | oficio == 45 | oficio == 49 | oficio == 52 | oficio == 53 | oficio == 57 | oficio == 58 | oficio == 59 | oficio == 59
	replace occup = 6 if oficio == 61 | oficio == 63 | oficio == 64
	replace occup = 7 if oficio == 70 | oficio == 71 | oficio == 76 | oficio == 79 | oficio == 80 | oficio == 81 | oficio == 82 | oficio == 83 | oficio == 84 | oficio == 85 | oficio == 87 | oficio == 88 | oficio == 89 | oficio == 92 | oficio == 93 | oficio == 94 | oficio == 95
	replace occup = 8 if oficio == 56 | oficio == 72 | oficio == 73 | oficio == 74 | oficio == 75 | oficio == 77 | oficio == 78 | oficio == 90 | oficio == 91 | oficio == 96 | oficio == 98
	replace occup = 9 if oficio == 54 | oficio == 55 | oficio == 62 | oficio == 97 | oficio == 99
	replace occup = 99 if oficio == 35 | oficio == 0
	replace occup=. if lstatus!=1
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>

*<_occup_skill_>
	gen occup_skill = occup
	replace occup_skill = 3 if inrange(occup, 1, 3)
	replace occup_skill = 2 if inrange(occup, 4, 8)
	replace occup_skill = 1 if occup == 9
	replace occup_skill =. if occup==99
	la de lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lblskill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_wage_no_compen_>
	gen double wage_no_compen = valor28
	replace wage_no_compen = . if lstatus!=1
	replace wage_no_compen=. if valor28==0
	replace wage_no_compen=. if valor28==00
	replace wage_no_compen=. if wage_no_compen==99
	replace wage_no_compen=. if wage_no_compen==98
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>

/* <_unitwage_note>
	Unitwage refers to the unit used to record wage_no_compen, *not* the unit of
	general wage payent. For example, PHL LFS asks about wage periodicity, then
	asks for basic daily pay. The value of that pay would be wage_no_compen,
	while unitwage is code 1 ("Daily") for all, regardless of the periodicity.
</_unitwage_note> */

	gen byte unitwage = 5
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	replace unitwage=. if lstatus!=1
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours = p34
	replace whours=. if lstatus!=1
	replace whours=. if whours==0
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
	des valor28
	* ECH doesn't include payment for extra hours

	*Extra hours  QI.15
	gen wage_extra = .
	*Replace by median value those who did not know the exact amount
	gen wage_extra_prel = wage_extra
	replace wage_extra_prel = .
	sum wage_extra_prel,d
	egen wage_extra_mean = median(wage_extra_prel)
	replace wage_extra = wage_extra_mean
	*Replace by 0 for those who already reported this in base wage
	replace wage_extra = .

	*In-kind income
	*In-kind income (food) QI.16
	gen wage_food = valor29 if lstatus==1
	gen wage_food_prel = wage_food
	egen wage_food_mean = median(wage_food_prel)
	replace wage_food = wage_food_mean
	*In-kind income (housing) QI.17
	gen wage_house = valor30 if lstatus==1
	gen wage_house_prel = wage_house
	egen wage_house_mean = median(wage_house_prel)
	*In-kind income (transport) QI.18
	gen wage_transp = .
	*In-kind income (other in-kind) QI.19
	gen wage_otherk = .
	*In-kind income (all)
	egen wage_kind = rsum(wage_food wage_house wage_transp wage_otherk) if lstatus==1
	count if wage_kind==0
	replace wage_kind = . if wage_kind == 0
	*mediana en lugar de media. ok para transporte, pero no bonificaciones

	*Bonuses - Not asked in ECH
	*Q.I22a
	gen prim_serv = .
    *Q.I22b
	gen prim_christ = .
	*Q.I22c
	gen prim_vac = .
	*Q.I22d
	gen bon_ann = .
	*Bonuses (all)
	egen prim_bon = rsum(prim_serv prim_christ prim_vac bon_ann)
	replace prim_bon = . if prim_bon==0

	*Wage - Monthly income, including extra hours QI.14 + QI.15
	*Paid employees
	gen wage_principal_1 = valor28
	replace wage_principal_1 = valor31 + wage_extra if wage_extra!=.

	*Self-employed, employer and others
	*Wage for employers and self-employed workers
	count if valor31!=. & (empstat!=3 & empstat!=4 & empstat!=5)
	gen wage_self = valor31 if empstat==3 | empstat==4 | empstat==5

	*Replace wage for self-employed, employers, others
	replace wage_principal_1 = wage_self if (empstat==3 | empstat==4 | empstat==5 | valor31!=.) & wage_self!=.
	replace wage_principal_1=0 if empstat==2
	replace wage_principal_1=. if lstatus!=1
	sum wage_principal_1
	replace wage_principal_1 = wage_principal_1 + prim_bon if prim_bon!=.
	sum wage_principal_1

	*Wage - Monthly income, including extra hours + other job remunerations + bonuses
	gen wage_principal_2 = wage_principal_1
	replace wage_principal_2 = wage_principal_1 + wage_kind if wage_kind!=.
    replace wage_principal_2 = wage_principal_2 + prim_bon if prim_bon!=.

	*Replace wage for self-employed, employers, others
	replace wage_principal_2 = wage_self if (empstat==3 | empstat==4 | empstat==5 | valor31!=.) & wage_self!=.
	replace wage_principal_2=0 if empstat==2
	replace wage_principal_2=. if lstatus!=1
	sum wage_principal_2

	gen wage_total = wage_principal_2*12
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen byte contract = .
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	destring p33a, force replace
	gen byte healthins= p33a
	recode healthins 9=. 2=0
	replace healthins=. if lstatus!=1
	label var healthins "Employment has health insurance primary job 7 day recall"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	destring p33d, replace
	gen byte socialsec= p33d
	recode socialsec 9=. 2=0 3=.
	replace socialsec=. if lstatus!=1
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec 1 "With social security" 0 "Without social secturity"
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen byte union = .
	recode union 2=0
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	gen byte firmsize_l = .
	recode firmsize_l 3=4 4=6 5=11 6=20 7=31 8=51 9=101
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u = .
	recode firmsize_u 2=3 3=5 4=10 5=19 6=30 7=50 8=100 9=.
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
	gen ocusec_2 = .
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


*<_occup_skill_2_>
	gen occup_skill_2 = .
	la de lblskill2 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_2 lblskill2
	label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>


*<_occup_2_>
	gen byte occup_2 = .
	label var occup_2 "1 digit occupational classification secondary job 7 day recall"
	label values occup_2 lbloccup
*</_occup_2_>


*<_wage_no_compen_2_>
	gen double wage_no_compen_2 = valor38 if valor38 !=0
	replace wage_no_compen_2=. if lstatus!=1
	replace wage_no_compen_2=. if wage_no_compen_2==99
	replace wage_no_compen_2=. if wage_no_compen_2==98
	*unexplained outliers only 1 obs each
	replace wage_no_compen_2=. if wage_no_compen_2==24
	replace wage_no_compen_2=. if wage_no_compen_2==35
	replace wage_no_compen_2=. if wage_no_compen_2==72
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2 = 5
	replace unitwage_2=. if lstatus!=1
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
	gen byte firmsize_l_2 = .
	recode firmsize_l_2 3=4 4=6 5=11 6=20 7=31 8=51 9=101
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	gen byte firmsize_u_2 = .
	recode firmsize_u_2 2=3 3=5 4=10 5=19 6=30 7=50 8=100 9=.
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
	gen t_hours_total = whours + whours_2 + t_hours_others
	label var t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
	gen t_wage_nocompen_total = wage_no_compen + wage_no_compen_2 + t_wage_nocompen_others
	label var t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
	gen t_wage_total = wage_total + wage_total_2 + t_wage_others
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


*<_occup_skill_year_>
	gen occup_skill_year = .
	la de lblskillyear 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_year lblskillyear
	label var occup_skill_year "Skill based on ISCO standard primary job 12 month recall"
*</_occup_skill_year_>


*<_occup_year_>
	gen byte occup_year = .
	label var occup_year "1 digit occupational classification, primary job 12 month recall"
	la de lbloccup_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_year lbloccup_year
*</_occup_year_>


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
	gen byte firmsize_l_year = .
	label var firmsize_l_year "Firm size (lower bracket) primary job 12 month recall"
*</_firmsize_l_year_>


*<_firmsize_u_year_>
	gen byte firmsize_u_year = .
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


*<_occup_skill_2_year_>
	gen occup_skill_2_year = .
	la de lblskilly2 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_2_year lblskilly2
	label var occup_skill_2_year "Skill based on ISCO standard secondary job 12 month recall"
*</_occup_skill_2_year_>


*<_occup_2_year_>
	gen byte occup_2_year = .
	label var occup_2_year "1 digit occupational classification, secondary job 12 month recall"
	label values occup_2_year lbloccup_year
*</_occup_2_year_>


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
	gen byte firmsize_l_2_year = .
	label var firmsize_l_2_year "Firm size (lower bracket) secondary job 12 month recall"
*</_firmsize_l_2_year_>


*<_firmsize_u_2_year_>
	gen byte firmsize_u_2_year = .
	label var firmsize_u_2_year "Firm size (upper bracket) secondary job 12 month recall"
*</_firmsize_u_2_year_>

}


*----------8.9: 12 month reference additional jobs------------------------------*

* NUMBER OF ADDITIONAL JOBS LAST YEAR
	gen byte njobs_year=.
	replace njobs_year=. if lstatus_year!=1
	label var njobs_year "Number of additional jobs during last year"

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


/*%%=============================================================================================
	9: Final steps
==============================================================================================%%*/

quietly{

*<_% KEEP VARIABLES - ALL_>

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

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
}
