/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				COL_2021_GLD_GEIH_v06
<_Application_>					Stata 17
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) 
<_Date created_>				2022-04-11

-------------------------------------------------------------------------

<_Country_>					    Colombia (COL)
<_Survey Title_>				Gran Encuesta Integrada de Hogares - GEIH
<_Survey Year_>					2021
<_Study ID_>					[Microdata Library ID if present] </_Study ID_>
<_Data collection from_>			01/2021
<_Data collection to_>				12/2021 </_Data collection to_>
<_Source of dataset_> 				Departamento Administrativo Nacional de Estadistica - DANE
<_Sample size (HH)_> 				225,853 </_Sample size (HH)_>
<_Sample size (IND)_> 				711,381  </_Sample size (IND)_>
<_Sampling method_> 				 probabilistic, multi-stage, stratified, unequal conglomerate and self-weighted design </_Sampling method_>
<_Geographic coverage_> 			national </_Geographic coverage_>
<_Currency_> 					COP </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS-13 </_ICLS Version_>
<_ISCED Version_>				isced_2011 </_ISCED Version_>
<_ISCO Version_>				N/A </_ISCO Version_>
<_OCCUP National_>				CNO 1970 </_OCCUP National_>
<_ISIC Version_>				ISIC REV 4 </_ISIC Version_>
<_INDUS National_>				ISIC REV 4 COLOMBIA </_INDUS National_>

-----------------------------------------------------------------------
<_Version Control_>

* Date: 2022-18-04 - Changes from I2D2 to GLD
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
*set max_memory .

*----------1.2: Set directories------------------------------*


local path_in "Z:\GLD-Harmonization\582018_AQ\COL\COL_2021_GEIH\COL_2021_GEIH_v01_M\Data\Stata\"
local path_output "Z:\GLD-Harmonization\582018_AQ\COL\COL_2021_GEIH\COL_2021_GEIH_v01_M_V03_A_GLD\Data\Harmonized\"

*----------1.3: Database assembly------------------------------*

*** append household monthly data
clear all
use "`path_in'\GEIH_2021_1.dta"

forvalues i=2/12 {
    append using "`path_in'\GEIH_2021_`i'.dta", force
}

rename *, lower
drop _merge
tempfile general_2021
save `general_2021'

clear all


use "`path_in'\Migration\mi_1.dta"
forvalues i=2/12 {
    append using "`path_in'\Migration\mi_`i'.dta", force
}
*save "`path_in'\migration_2021.dta", replace
tempfile migration_2021
save `migration_2021'

*full set
use "`general_2021'",clear

*merge with migration asserting matches that need to be in master only (not in migration) or match (in both) in using would be an error.
merge 1:1 directorio secuencia_p orden  using "`migration_2021'", assert(master match) nogen
tempfile general_mig
save `general_mig'


****final dataset with updated weights
use "`path_in'\Fex proyeccion CNPV_2018.dta"
rename *, lower
merge 1:1 directorio secuencia_p orden using "`general_mig'", force assert(master match) keep(match) nogen


save "`path_in'\data_2021_final.dta", replace

/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode = "COL"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "GEIH"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "household survey"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	gen icls_v = "ICLS-13"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	gen isced_version = "isced_2011"
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
	gen int year = 2021
	label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen vermast = "V01"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen veralt = "V03"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen harmonization = "GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	gen int_year = 2021 //instead of intv_year=ano
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_> // Includes all months
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


local letters "secuencia_p orden"

	foreach letter of local letters {
     gen helper_`letter' = string(`letter',"%02.0f")
	}

	gen helper_d=string(directorio,"%07.0f")
	egen hhid = concat(helper_d helper_secuencia_p)
	drop helper_d helper_secuencia_p

	label var hhid "Household ID"

*</_hhid_>


*<_pid_>

	gen com=orden
	egen  pid = concat(hhid com)
	label var pid "Individual ID"
	isid pid hhid
*</_pid_>


*<_weight_>
	gen weight = fex_c_2011
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


*<_wave_>  // NOT USED
	gen wave = .
	label var wave "Survey wave"
*</_wave_>

}

/*%%=============================================================================================
	3: Geography
==============================================================================================%%*/

{

*<_urban_>
 	destring clase, gen(urbano) //add
	gen byte urban=urbano
	replace urban = 0 if urban == 2
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>

*<_subnatid1_>
	destring dpto, replace
	gen subnatid1 =string(dpto)
	replace subnatid1 = "1 - Atlantica" if subnatid1 == "8" | subnatid1 == "13" | subnatid1 == "20" | subnatid1 == "23" | subnatid1 == "44" | subnatid1 == "47" | subnatid1 == "70"
	replace subnatid1 = "2 - Oriental" if subnatid1 == "15" | subnatid1 == "25" | subnatid1 == "50" | subnatid1 == "54" | subnatid1 == "68"
	replace subnatid1 = "3 - Central" if subnatid1 == "5" | subnatid1== "17" | subnatid1 == "18" | subnatid1 == "41" | subnatid1 == "63" | subnatid1 == "66" | subnatid1 == "66" | subnatid1 == "73"
	replace subnatid1 = "4 - Pacifica" if subnatid1 == "19" | subnatid1 == "27" | subnatid1 == "52" | subnatid1 == "76"
	replace subnatid1 = "5 - Santa Fe de Bogota" if subnatid1 == "11"
	label var subnatid1 "Subnational ID at First Administrative Level"

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
	egen subnatidsurvey = concat(subnatid2 urban), p(" ")
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
	gen a=1 if (p6050!=6 & p6050!=7 & p6050!=8)  //instead of gen a=1 of p6050!=6 (taking out pensionista and trabajador)
	egen byte hsize=sum(a), by(hhid)
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen age = p6040  //add
	replace age=98 if age>98 & age!=.
	label var age "Individual age"
*</_age_>

*<_male_>
	gen male =(p6020==1)  //add
	gen byte gender=male
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen relationharm = p6050
	recode relationharm (7=6) (8=6)  (9=6) (4=5) //added
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

*<_relationcs_>
	gen relationcs = p6050
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital=p6070
	recode marital 1 2=3 3=1 6=2
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
//seems like this information is in separate database available online, even if it was in the same questionnaire (P.Modulo de Migracion)
{

*<_migrated_mod_age_>
	gen migrated_mod_age = 5
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time = 5
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen migrated_binary = p755
	recode migrated_binary 1/2=0 3/4=1
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
	gen migrated_reason = p1662
	recode migrated_reason 1=3 3=5 4/6=4 9/10=5 7/8=1
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

gen byte ed_mod_age = 3
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school = p6170
	recode school 2=0
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school lblschool
*</_school_>

*<_literacy_>
	gen byte literacy = p6160
	recode literacy 2=0
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen byte educy = esc
	replace educy=. if age<ed_mod_age & age!=.
	replace educy=. if age < educy & (age != . & educy != .)
	label var educy "Years of education"

*</_educy_>


*<_educat7_>
	gen byte educat7 = p6210
	recode educat7 2=1 3=2 4 5=4 6=7 9=.
	replace educat7=3 if educat7==2 & educy==5
	replace educat7=5 if educat7==4 & educy==11 //different from questionnaire but in reality secondary is for 6 years (media:10-11), so no change here
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
	gen educat_orig = .
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
	gen educat_isced = p6210
	recode educat_isced (1 9=.) (2=0) (3=1) (4=2) (5=3)
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

*<_vocational_field_orig_>
	gen vocational_field_orig = .
	label var vocational_field_orig "Field of training"
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
	gen byte minlaborage = 10
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
	gen byte lstatus = 1 if oci==1
	replace lstatus=2 if dsi==1
	replace lstatus=3 if ini==1
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>

*<_lstatus_extra>

*For unemployed and inactive that report some kind of labor earning on the last month
	tab p7422 dsi,m
	tab p7310 dsi,m //Jump for unemployed in question p7310
	sum p7422s1
	tab p7472 ini,m
	tab p7430 ini,m //Jump for inactive in question p7430
	sum p7472s1
	*lstatus_extra identifies unemployed and inactive that report labor earnings on the last month (sub-employment)
	gen lstatus_extra = (p7422==1 | p7472==1)
	replace lstatus_extra =. if oci==1
	tab lstatus_extra
	tab lstatus_extra,m
	tab lstatus_extra dsi,m
	tab lstatus_extra ini,m
	label var lstatus_extra "Labor status extra, for unemployed and inactive that report labor earnings (=1 if labor earnings, =0 if no labor earnings, =. if employed)"
	*tab p7320 how many weeks ago they stopped working
*</_lstatus_extra>

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

*<_nlfreason_> //not creating any variable. p7450 asks reason to leave last job for "inactive" people, should replace?
	gen byte nlfreason=.
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>

*<_unempldur_l_>
	gen byte unempldur_l=int(p7250/4)
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=int(p7250/4)  //same variable as unempldur_l?
	replace unempldur_l=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*
{
*<_empstat_>
	gen byte empstat= p6430
	recode empstat 2 3 8=1 5=3 6 7=2 9=5
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>

* NUMBER OF ADDITIONAL JOBS -- Changed order
	gen byte njobs=1 if p7040==1 //?should add replace njobs=0 if p7040==2? does not count number of jobs, just indicates if another job, but no info on number of aditional jobs in questionnaire
	replace njobs=. if lstatus!=1
	label var njobs "Number of additional jobs"

*<_ocusec_>
	gen byte ocusec = p6430
	recode ocusec 2=1 1 3 4 5/9=2
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>

*<_industry_orig_>
	*destring rama2d_r4 rama4d_r4, replace
	gen industry_orig = rama4d_r4
	replace industry_orig="" if rama4d_r4=="0000"
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>// Colombian ISIC rev 4 to ISIC rev. 4
	gen industrycat_isic = .
	destring rama4d_r4, replace force
	replace industrycat_isic = 111 if rama4d_r4 == 111
	replace industrycat_isic = 112 if rama4d_r4 == 112
	replace industrycat_isic = 113 if rama4d_r4 == 113
	replace industrycat_isic = 115 if rama4d_r4 == 114 | rama4d_r4 == 124
	replace industrycat_isic = 116 if rama4d_r4 == 115
	replace industrycat_isic = 119 if rama4d_r4 == 119 | rama4d_r4 == 125
	replace industrycat_isic = 122 if rama4d_r4 == 121 | rama4d_r4 == 122
	replace industrycat_isic = 126 if rama4d_r4 == 126
	replace industrycat_isic = 127 if rama4d_r4 == 123 | rama4d_r4 == 127
	replace industrycat_isic = 128 if rama4d_r4 == 128
	replace industrycat_isic = 129 if rama4d_r4 == 129
	replace industrycat_isic = 130 if rama4d_r4 == 130
	replace industrycat_isic = 141 if rama4d_r4 == 141
	replace industrycat_isic = 142 if rama4d_r4 == 142
	replace industrycat_isic = 144 if rama4d_r4 == 143
	replace industrycat_isic = 145 if rama4d_r4 == 144
	replace industrycat_isic = 146 if rama4d_r4 == 145
	replace industrycat_isic = 149 if rama4d_r4 == 143 | rama4d_r4 == 149
	replace industrycat_isic = 150 if rama4d_r4 == 150
	replace industrycat_isic = 161 if rama4d_r4 == 161
	replace industrycat_isic = 162 if rama4d_r4 == 162
	replace industrycat_isic = 163 if rama4d_r4 == 163
	replace industrycat_isic = 164 if rama4d_r4 == 164
	replace industrycat_isic = 170 if rama4d_r4 == 170
	replace industrycat_isic = 210 if rama4d_r4 == 210
	replace industrycat_isic = 220 if rama4d_r4 == 220
	replace industrycat_isic = 230 if rama4d_r4 == 230
	replace industrycat_isic = 240 if rama4d_r4 == 240
	replace industrycat_isic = 311 if rama4d_r4 == 311
	replace industrycat_isic = 312 if rama4d_r4 == 312
	replace industrycat_isic = 321 if rama4d_r4 == 321
	replace industrycat_isic = 322 if rama4d_r4 == 322
	replace industrycat_isic = 510 if rama4d_r4 == 510
	replace industrycat_isic = 520 if rama4d_r4 == 520
	replace industrycat_isic = 610 if rama4d_r4 == 610
	replace industrycat_isic = 620 if rama4d_r4 == 620
	replace industrycat_isic = 710 if rama4d_r4 == 710
	replace industrycat_isic = 721 if rama4d_r4 == 721
	replace industrycat_isic = 729 if rama4d_r4 == 722 | rama4d_r4 == 723 | rama4d_r4 == 729
	replace industrycat_isic = 810 if rama4d_r4 == 811 | rama4d_r4 == 812
	replace industrycat_isic = 891 if rama4d_r4 == 891
	replace industrycat_isic = 892 if rama4d_r4 == 892 | rama4d_r4 == 899
	replace industrycat_isic = 899 if rama4d_r4 == 820
	replace industrycat_isic = 910 if rama4d_r4 == 910
	replace industrycat_isic = 990 if rama4d_r4 == 990
	replace industrycat_isic = 1010 if rama4d_r4 == 1011
	replace industrycat_isic = 1020 if rama4d_r4 == 1012
	replace industrycat_isic = 1030 if rama4d_r4 == 1020
	replace industrycat_isic = 1040 if rama4d_r4 == 1030
	replace industrycat_isic = 1050 if rama4d_r4 == 1040
	replace industrycat_isic = 1061 if rama4d_r4 == 1051
	replace industrycat_isic = 1062 if rama4d_r4 == 1052
	replace industrycat_isic = 1071 if rama4d_r4 == 1081
	replace industrycat_isic = 1072 if rama4d_r4 == 1071 | rama4d_r4 == 1072
	replace industrycat_isic = 1073 if rama4d_r4 == 1082
	replace industrycat_isic = 1074 if rama4d_r4 == 1083
	replace industrycat_isic = 1075 if rama4d_r4 == 1084
	replace industrycat_isic = 1079 if rama4d_r4 == 1061 | rama4d_r4 == 1062 | rama4d_r4 == 1063 | rama4d_r4 == 1089
	replace industrycat_isic = 1080 if rama4d_r4 == 1090
	replace industrycat_isic = 1101 if rama4d_r4 == 1101
	replace industrycat_isic = 1102 if rama4d_r4 == 1102
	replace industrycat_isic = 1103 if rama4d_r4 == 1103
	replace industrycat_isic = 1104 if rama4d_r4 == 1104
	replace industrycat_isic = 1200 if rama4d_r4 == 1200
	replace industrycat_isic = 1311 if rama4d_r4 == 1311
	replace industrycat_isic = 1312 if rama4d_r4 == 1312
	replace industrycat_isic = 1313 if rama4d_r4 == 1313
	replace industrycat_isic = 1391 if rama4d_r4 == 1391
	replace industrycat_isic = 1392 if rama4d_r4 == 1392
	replace industrycat_isic = 1393 if rama4d_r4 == 1393
	replace industrycat_isic = 1394 if rama4d_r4 == 1394
	replace industrycat_isic = 1399 if rama4d_r4 == 1399
	replace industrycat_isic = 1410 if rama4d_r4 == 1410
	replace industrycat_isic = 1420 if rama4d_r4 == 1420
	replace industrycat_isic = 1430 if rama4d_r4 == 1430
	replace industrycat_isic = 1511 if rama4d_r4 == 1511
	replace industrycat_isic = 1512 if rama4d_r4 == 1512 | rama4d_r4 == 1513
	replace industrycat_isic = 1520 if rama4d_r4 == 1521 | rama4d_r4 == 1522 | rama4d_r4 == 1523
	replace industrycat_isic = 1610 if rama4d_r4 == 1610
	replace industrycat_isic = 1621 if rama4d_r4 == 1620
	replace industrycat_isic = 1622 if rama4d_r4 == 1630
	replace industrycat_isic = 1623 if rama4d_r4 == 1640
	replace industrycat_isic = 1629 if rama4d_r4 == 1690
	replace industrycat_isic = 1701 if rama4d_r4 == 1701
	replace industrycat_isic = 1702 if rama4d_r4 == 1702
	replace industrycat_isic = 1709 if rama4d_r4 == 1709
	replace industrycat_isic = 1811 if rama4d_r4 == 1811
	replace industrycat_isic = 1812 if rama4d_r4 == 1812
	replace industrycat_isic = 1820 if rama4d_r4 == 1820
	replace industrycat_isic = 1910 if rama4d_r4 == 1910
	replace industrycat_isic = 1920 if rama4d_r4 == 1921 | rama4d_r4 == 1922
	replace industrycat_isic = 2011 if rama4d_r4 == 2011
	replace industrycat_isic = 2012 if rama4d_r4 == 2012
	replace industrycat_isic = 2013 if rama4d_r4 == 2013 | rama4d_r4 == 2014
	replace industrycat_isic = 2021 if rama4d_r4 == 2021
	replace industrycat_isic = 2022 if rama4d_r4 == 2022
	replace industrycat_isic = 2023 if rama4d_r4 == 2023
	replace industrycat_isic = 2029 if rama4d_r4 == 2029
	replace industrycat_isic = 2030 if rama4d_r4 == 2030
	replace industrycat_isic = 2100 if rama4d_r4 == 2100
	replace industrycat_isic = 2211 if rama4d_r4 == 2211 | rama4d_r4 == 2212 | rama4d_r4 == 2219
	replace industrycat_isic = 2220 if rama4d_r4 == 2221 | rama4d_r4 == 2229
	replace industrycat_isic = 2310 if rama4d_r4 == 2310
	replace industrycat_isic = 2391 if rama4d_r4 == 2391
	replace industrycat_isic = 2392 if rama4d_r4 == 2392
	replace industrycat_isic = 2393 if rama4d_r4 == 2393
	replace industrycat_isic = 2394 if rama4d_r4 == 2394
	replace industrycat_isic = 2395 if rama4d_r4 == 2395
	replace industrycat_isic = 2396 if rama4d_r4 == 2396
	replace industrycat_isic = 2399 if rama4d_r4 == 2399
	replace industrycat_isic = 2410 if rama4d_r4 == 2410
	replace industrycat_isic = 2420 if rama4d_r4 == 2421 | rama4d_r4 == 2429
	replace industrycat_isic = 2431 if rama4d_r4 == 2431
	replace industrycat_isic = 2432 if rama4d_r4 == 2432
	replace industrycat_isic = 2511 if rama4d_r4 == 2511
	replace industrycat_isic = 2512 if rama4d_r4 == 2512
	replace industrycat_isic = 2513 if rama4d_r4 == 2513
	replace industrycat_isic = 2520 if rama4d_r4 == 2520
	replace industrycat_isic = 2591 if rama4d_r4 == 2591
	replace industrycat_isic = 2592 if rama4d_r4 == 2592
	replace industrycat_isic = 2593 if rama4d_r4 == 2593
	replace industrycat_isic = 2599 if rama4d_r4 == 2599
	replace industrycat_isic = 2610 if rama4d_r4 == 2610
	replace industrycat_isic = 2620 if rama4d_r4 == 2620
	replace industrycat_isic = 2630 if rama4d_r4 == 2630
	replace industrycat_isic = 2640 if rama4d_r4 == 2640
	replace industrycat_isic = 2651 if rama4d_r4 == 2651
	replace industrycat_isic = 2652 if rama4d_r4 == 2652
	replace industrycat_isic = 2660 if rama4d_r4 == 2660
	replace industrycat_isic = 2670 if rama4d_r4 == 2670
	replace industrycat_isic = 2680 if rama4d_r4 == 2680
	replace industrycat_isic = 2710 if rama4d_r4 == 2711 | rama4d_r4 == 2712
	replace industrycat_isic = 2720 if rama4d_r4 == 2720
	replace industrycat_isic = 2731 if rama4d_r4 == 2731
	replace industrycat_isic = 2733 if rama4d_r4 == 2732
	replace industrycat_isic = 2740 if rama4d_r4 == 2740
	replace industrycat_isic = 2750 if rama4d_r4 == 2750
	replace industrycat_isic = 2790 if rama4d_r4 == 2790
	replace industrycat_isic = 2811 if rama4d_r4 == 2811
	replace industrycat_isic = 2812 if rama4d_r4 == 2812
	replace industrycat_isic = 2813 if rama4d_r4 == 2813
	replace industrycat_isic = 2814 if rama4d_r4 == 2814
	replace industrycat_isic = 2815 if rama4d_r4 == 2815
	replace industrycat_isic = 2816 if rama4d_r4 == 2816
	replace industrycat_isic = 2818 if rama4d_r4 == 2818
	replace industrycat_isic = 2819 if rama4d_r4 == 2819
	replace industrycat_isic = 2821 if rama4d_r4 == 2821
	replace industrycat_isic = 2822 if rama4d_r4 == 2822
	replace industrycat_isic = 2823 if rama4d_r4 == 2823
	replace industrycat_isic = 2824 if rama4d_r4 == 2824
	replace industrycat_isic = 2825 if rama4d_r4 == 2825
	replace industrycat_isic = 2826 if rama4d_r4 == 2826
	replace industrycat_isic = 2829 if rama4d_r4 == 2829
	replace industrycat_isic = 2910 if rama4d_r4 == 2910
	replace industrycat_isic = 2920 if rama4d_r4 == 2920
	replace industrycat_isic = 2930 if rama4d_r4 == 2930
	replace industrycat_isic = 3011 if rama4d_r4 == 3011
	replace industrycat_isic = 3012 if rama4d_r4 == 3012
	replace industrycat_isic = 3020 if rama4d_r4 == 3020
	replace industrycat_isic = 3030 if rama4d_r4 == 3030
	replace industrycat_isic = 3040 if rama4d_r4 == 3040
	replace industrycat_isic = 3091 if rama4d_r4 == 3091
	replace industrycat_isic = 3092 if rama4d_r4 == 3092
	replace industrycat_isic = 3099 if rama4d_r4 == 3099
	replace industrycat_isic = 3100 if rama4d_r4 == 3110 | rama4d_r4 == 3120
	replace industrycat_isic = 3211 if rama4d_r4 == 3210
	replace industrycat_isic = 3220 if rama4d_r4 == 3220
	replace industrycat_isic = 3230 if rama4d_r4 == 3230
	replace industrycat_isic = 3240 if rama4d_r4 == 3240
	replace industrycat_isic = 3250 if rama4d_r4 == 3250
	replace industrycat_isic = 3290 if rama4d_r4 == 3290
	replace industrycat_isic = 3311 if rama4d_r4 == 3311
	replace industrycat_isic = 3312 if rama4d_r4 == 3312
	replace industrycat_isic = 3313 if rama4d_r4 == 3313
	replace industrycat_isic = 3314 if rama4d_r4 == 3314
	replace industrycat_isic = 3315 if rama4d_r4 == 3315
	replace industrycat_isic = 3319 if rama4d_r4 == 3319
	replace industrycat_isic = 3320 if rama4d_r4 == 3320
	replace industrycat_isic = 3510 if rama4d_r4 == 3511 | rama4d_r4 == 3512 | rama4d_r4 == 3513 | rama4d_r4 == 3514
	replace industrycat_isic = 3520 if rama4d_r4 == 3520
	replace industrycat_isic = 3530 if rama4d_r4 == 3530
	replace industrycat_isic = 3600 if rama4d_r4 == 3600
	replace industrycat_isic = 3700 if rama4d_r4 == 3700
	replace industrycat_isic = 3811 if rama4d_r4 == 3811
	replace industrycat_isic = 3812 if rama4d_r4 == 3812
	replace industrycat_isic = 3821 if rama4d_r4 == 3821
	replace industrycat_isic = 3822 if rama4d_r4 == 3822
	replace industrycat_isic = 3830 if rama4d_r4 == 3830
	replace industrycat_isic = 3900 if rama4d_r4 == 3900
	replace industrycat_isic = 4100 if rama4d_r4 == 4111 | rama4d_r4 == 4112
	replace industrycat_isic = 4210 if rama4d_r4 == 4210
	replace industrycat_isic = 4220 if rama4d_r4 == 4220
	replace industrycat_isic = 4290 if rama4d_r4 == 4290
	replace industrycat_isic = 4311 if rama4d_r4 == 4311
	replace industrycat_isic = 4312 if rama4d_r4 == 4312
	replace industrycat_isic = 4321 if rama4d_r4 == 4321
	replace industrycat_isic = 4322 if rama4d_r4 == 4322
	replace industrycat_isic = 4329 if rama4d_r4 == 4329
	replace industrycat_isic = 4330 if rama4d_r4 == 4330
	replace industrycat_isic = 4390 if rama4d_r4 == 4390
	replace industrycat_isic = 4510 if rama4d_r4 == 4511 | rama4d_r4 == 4512
	replace industrycat_isic = 4520 if rama4d_r4 == 4520
	replace industrycat_isic = 4530 if rama4d_r4 == 4530
	replace industrycat_isic = 4540 if rama4d_r4 == 4541
	replace industrycat_isic = 4540 if rama4d_r4 == 4542
	replace industrycat_isic = 4610 if rama4d_r4 == 4610
	replace industrycat_isic = 4620 if rama4d_r4 == 4620
	replace industrycat_isic = 4630 if rama4d_r4 == 4631 | rama4d_r4 == 4632
	replace industrycat_isic = 4641 if rama4d_r4 == 4641 | rama4d_r4 == 4642 | rama4d_r4 == 4643 | rama4d_r4 == 4649
	replace industrycat_isic = 4649 if rama4d_r4 == 4644 | rama4d_r4 == 4644
	replace industrycat_isic = 4651 if rama4d_r4 == 4651
	replace industrycat_isic = 4652 if rama4d_r4 == 4652
	replace industrycat_isic = 4653 if rama4d_r4 == 4653
	replace industrycat_isic = 4659 if rama4d_r4 == 4659
	replace industrycat_isic = 4661 if rama4d_r4 == 4661
	replace industrycat_isic = 4662 if rama4d_r4 == 4662
	replace industrycat_isic = 4663 if rama4d_r4 == 4663
	replace industrycat_isic = 4669 if rama4d_r4 == 4664 | rama4d_r4 == 4665 | rama4d_r4 == 4669
	replace industrycat_isic = 4690 if rama4d_r4 == 4690
	replace industrycat_isic = 4711 if rama4d_r4 == 4711
	replace industrycat_isic = 4719 if rama4d_r4 == 4719
	replace industrycat_isic = 4721 if rama4d_r4 == 4721 | rama4d_r4 == 4722 | rama4d_r4 == 4723 | rama4d_r4 == 4729
	replace industrycat_isic = 4722 if rama4d_r4 == 4724
	replace industrycat_isic = 4730 if rama4d_r4 == 4731 | rama4d_r4 == 4722
	replace industrycat_isic = 4741 if rama4d_r4 == 4741
	replace industrycat_isic = 4742 if rama4d_r4 == 4742
	replace industrycat_isic = 4751 if rama4d_r4 == 4751
	replace industrycat_isic = 4752 if rama4d_r4 == 4752
	replace industrycat_isic = 4753 if rama4d_r4 == 4753 | rama4d_r4 == 4755
	replace industrycat_isic = 4759 if rama4d_r4 == 4754 | rama4d_r4 == 4759
	replace industrycat_isic = 4761 if rama4d_r4 == 4761
	replace industrycat_isic = 4762 if rama4d_r4 == 4762 | rama4d_r4 == 4769
	replace industrycat_isic = 4771 if rama4d_r4 == 4771 | rama4d_r4 == 4772
	replace industrycat_isic = 4772 if rama4d_r4 == 4773
	replace industrycat_isic = 4773 if rama4d_r4 == 4774
	replace industrycat_isic = 4774 if rama4d_r4 == 4773
	replace industrycat_isic = 4781 if rama4d_r4 == 4781
	replace industrycat_isic = 4782 if rama4d_r4 == 4782
	replace industrycat_isic = 4789 if rama4d_r4 == 4789
	replace industrycat_isic = 4791 if rama4d_r4 == 4791 | rama4d_r4 == 4792
	replace industrycat_isic = 4799 if rama4d_r4 == 4799
	replace industrycat_isic = 4911 if rama4d_r4 == 4911
	replace industrycat_isic = 4912 if rama4d_r4 == 4912
	replace industrycat_isic = 4921 if rama4d_r4 == 4921
	replace industrycat_isic = 4922 if rama4d_r4 == 4922
	replace industrycat_isic = 4930 if rama4d_r4 == 4930
	replace industrycat_isic = 5011 if rama4d_r4 == 5011
	replace industrycat_isic = 5012 if rama4d_r4 == 5012
	replace industrycat_isic = 5021 if rama4d_r4 == 5021
	replace industrycat_isic = 5022 if rama4d_r4 == 5022
	replace industrycat_isic = 5110 if rama4d_r4 == 5111 | rama4d_r4 == 5112
	replace industrycat_isic = 5120 if rama4d_r4 == 5121 | rama4d_r4 == 5122
	replace industrycat_isic = 5221 if rama4d_r4 == 5221
	replace industrycat_isic = 5222 if rama4d_r4 == 5222
	replace industrycat_isic = 5223 if rama4d_r4 == 5223
	replace industrycat_isic = 5224 if rama4d_r4 == 5224
	replace industrycat_isic = 5229 if rama4d_r4 == 5229
	replace industrycat_isic = 5310 if rama4d_r4 == 5310
	replace industrycat_isic = 5320 if rama4d_r4 == 5320
	replace industrycat_isic = 5510 if rama4d_r4 == 5511 | rama4d_r4 == 5512 | rama4d_r4 == 5513 | rama4d_r4 == 5514 | rama4d_r4 == 5519
	replace industrycat_isic = 5520 if rama4d_r4 == 5520
	replace industrycat_isic = 5590 if rama4d_r4 == 5530 | rama4d_r4 == 5590
	replace industrycat_isic = 5610 if rama4d_r4 == 5611 | rama4d_r4 == 5612 | rama4d_r4 == 5613 | rama4d_r4 == 5619
	replace industrycat_isic = 5621 if rama4d_r4 == 5621
	replace industrycat_isic = 5629 if rama4d_r4 == 5629
	replace industrycat_isic = 5630 if rama4d_r4 == 5630
	replace industrycat_isic = 5811 if rama4d_r4 == 5811
	replace industrycat_isic = 5812 if rama4d_r4 == 5812
	replace industrycat_isic = 5813 if rama4d_r4 == 5813
	replace industrycat_isic = 5819 if rama4d_r4 == 5819
	replace industrycat_isic = 5820 if rama4d_r4 == 5820
	replace industrycat_isic = 5911 if rama4d_r4 == 5911
	replace industrycat_isic = 5912 if rama4d_r4 == 5912
	replace industrycat_isic = 5913 if rama4d_r4 == 5913
	replace industrycat_isic = 5914 if rama4d_r4 == 5914
	replace industrycat_isic = 5920 if rama4d_r4 == 5920
	replace industrycat_isic = 6010 if rama4d_r4 == 6010
	replace industrycat_isic = 6020 if rama4d_r4 == 6020
	replace industrycat_isic = 6110 if rama4d_r4 == 6110
	replace industrycat_isic = 6120 if rama4d_r4 == 6120
	replace industrycat_isic = 6130 if rama4d_r4 == 6130
	replace industrycat_isic = 6190 if rama4d_r4 == 6190
	replace industrycat_isic = 6201 if rama4d_r4 == 6201
	replace industrycat_isic = 6202 if rama4d_r4 == 6202
	replace industrycat_isic = 6209 if rama4d_r4 == 6209
	replace industrycat_isic = 6311 if rama4d_r4 == 6311
	replace industrycat_isic = 6312 if rama4d_r4 == 6312
	replace industrycat_isic = 6391 if rama4d_r4 == 6391
	replace industrycat_isic = 6399 if rama4d_r4 == 6399
	replace industrycat_isic = 6411 if rama4d_r4 == 6411
	replace industrycat_isic = 6419 if rama4d_r4 == 6412 | rama4d_r4 == 6421 | rama4d_r4 == 6422 | rama4d_r4 == 6424
	replace industrycat_isic = 6430 if rama4d_r4 == 6431 | rama4d_r4 == 6432
	replace industrycat_isic = 6491 if rama4d_r4 == 6491
	replace industrycat_isic = 6492 if rama4d_r4 == 6423 | rama4d_r4 == 6492 | rama4d_r4 == 6494 | rama4d_r4 == 6495
	replace industrycat_isic = 6499 if rama4d_r4 == 6493 | rama4d_r4 == 6496 | rama4d_r4 == 6499
	replace industrycat_isic = 6511 if rama4d_r4 == 6512
	replace industrycat_isic = 6512 if rama4d_r4 == 6511 | rama4d_r4 == 6515 | rama4d_r4 == 6521 | rama4d_r4 == 6522 | rama4d_r4 == 6523
	replace industrycat_isic = 6520 if rama4d_r4 == 6513
	replace industrycat_isic = 6530 if rama4d_r4 == 6531 | rama4d_r4 == 6532
	replace industrycat_isic = 6611 if rama4d_r4 == 6611
	replace industrycat_isic = 6612 if rama4d_r4 == 6612 | rama4d_r4 == 6613 | rama4d_r4 == 6614 | rama4d_r4 == 6615
	replace industrycat_isic = 6619 if rama4d_r4 == 6619
	replace industrycat_isic = 6622 if rama4d_r4 == 6621 | rama4d_r4 == 6629
	replace industrycat_isic = 6630 if rama4d_r4 == 6630
	replace industrycat_isic = 6810 if rama4d_r4 == 6810
	replace industrycat_isic = 6820 if rama4d_r4 == 6820
	replace industrycat_isic = 6910 if rama4d_r4 == 6910
	replace industrycat_isic = 6920 if rama4d_r4 == 6920
	replace industrycat_isic = 7010 if rama4d_r4 == 7010
	replace industrycat_isic = 7020 if rama4d_r4 == 7020
	replace industrycat_isic = 7110 if rama4d_r4 == 7111 | rama4d_r4 == 7112
	replace industrycat_isic = 7120 if rama4d_r4 == 7120
	replace industrycat_isic = 7210 if rama4d_r4 == 7210
	replace industrycat_isic = 7220 if rama4d_r4 == 7220
	replace industrycat_isic = 7310 if rama4d_r4 == 7310
	replace industrycat_isic = 7320 if rama4d_r4 == 7320
	replace industrycat_isic = 7410 if rama4d_r4 == 7410
	replace industrycat_isic = 7420 if rama4d_r4 == 7420
	replace industrycat_isic = 7490 if rama4d_r4 == 7490
	replace industrycat_isic = 7500 if rama4d_r4 == 7500
	replace industrycat_isic = 7710 if rama4d_r4 == 7710
	replace industrycat_isic = 7721 if rama4d_r4 == 7721
	replace industrycat_isic = 7722 if rama4d_r4 == 7722
	replace industrycat_isic = 7729 if rama4d_r4 == 7729
	replace industrycat_isic = 7730 if rama4d_r4 == 7730
	replace industrycat_isic = 7740 if rama4d_r4 == 7740
	replace industrycat_isic = 7810 if rama4d_r4 == 7810
	replace industrycat_isic = 7820 if rama4d_r4 == 7820
	replace industrycat_isic = 7830 if rama4d_r4 == 7830
	replace industrycat_isic = 7911 if rama4d_r4 == 7911
	replace industrycat_isic = 7912 if rama4d_r4 == 7912
	replace industrycat_isic = 7990 if rama4d_r4 == 7990
	replace industrycat_isic = 8010 if rama4d_r4 == 8010
	replace industrycat_isic = 8020 if rama4d_r4 == 8020
	replace industrycat_isic = 8030 if rama4d_r4 == 8030
	replace industrycat_isic = 8110 if rama4d_r4 == 8110
	replace industrycat_isic = 8121 if rama4d_r4 == 8121
	replace industrycat_isic = 8129 if rama4d_r4 == 8129
	replace industrycat_isic = 8130 if rama4d_r4 == 8130
	replace industrycat_isic = 8211 if rama4d_r4 == 8211
	replace industrycat_isic = 8219 if rama4d_r4 == 8219
	replace industrycat_isic = 8220 if rama4d_r4 == 8220
	replace industrycat_isic = 8230 if rama4d_r4 == 8230
	replace industrycat_isic = 8291 if rama4d_r4 == 8291
	replace industrycat_isic = 8292 if rama4d_r4 == 8292
	replace industrycat_isic = 8299 if rama4d_r4 == 8299
	replace industrycat_isic = 8411 if rama4d_r4 == 8411 | rama4d_r4 == 8412 | rama4d_r4 == 8415
	replace industrycat_isic = 8412 if rama4d_r4 == 8413
	replace industrycat_isic = 8413 if rama4d_r4 == 8414
	replace industrycat_isic = 8421 if rama4d_r4 == 8421
	replace industrycat_isic = 8422 if rama4d_r4 == 8422
	replace industrycat_isic = 8423 if rama4d_r4 == 8411 | rama4d_r4 == 8424
	replace industrycat_isic = 8430 if rama4d_r4 == 8430
	replace industrycat_isic = 8510 if rama4d_r4 == 8511 | rama4d_r4 == 8512 | rama4d_r4 == 8513 | rama4d_r4 == 8530
	replace industrycat_isic = 8521 if rama4d_r4 == 8521 | rama4d_r4 == 8522
	replace industrycat_isic = 8522 if rama4d_r4 == 8523
	replace industrycat_isic = 8530 if rama4d_r4 == 8541 | rama4d_r4 == 8542 | rama4d_r4 == 8543 | rama4d_r4 == 8544
	replace industrycat_isic = 8541 if rama4d_r4 == 8552
	replace industrycat_isic = 8542 if rama4d_r4 == 8553
	replace industrycat_isic = 8549 if rama4d_r4 == 8551 | rama4d_r4 == 8559
	replace industrycat_isic = 8550 if rama4d_r4 == 8560
	replace industrycat_isic = 8610 if rama4d_r4 == 8610
	replace industrycat_isic = 8620 if rama4d_r4 == 8621 | rama4d_r4 == 8622
	replace industrycat_isic = 8690 if rama4d_r4 == 8691 | rama4d_r4 == 8692 | rama4d_r4 == 8699
	replace industrycat_isic = 8710 if rama4d_r4 == 8710
	replace industrycat_isic = 8720 if rama4d_r4 == 8720
	replace industrycat_isic = 8730 if rama4d_r4 == 8730
	replace industrycat_isic = 8810 if rama4d_r4 == 8810
	replace industrycat_isic = 8890 if rama4d_r4 == 8891 | rama4d_r4 == 8899
	replace industrycat_isic = 9000 if rama4d_r4 == 9001 | rama4d_r4 == 9002 | rama4d_r4 == 9003 | rama4d_r4 == 9004 | rama4d_r4 == 9005 | rama4d_r4 == 9006 | rama4d_r4 == 9007 | rama4d_r4 == 9008
	replace industrycat_isic = 9101 if rama4d_r4 == 9101
	replace industrycat_isic = 9102 if rama4d_r4 == 9102
	replace industrycat_isic = 9103 if rama4d_r4 == 9103
	replace industrycat_isic = 9200 if rama4d_r4 == 9200
	replace industrycat_isic = 9311 if rama4d_r4 == 9311
	replace industrycat_isic = 9312 if rama4d_r4 == 9312
	replace industrycat_isic = 9319 if rama4d_r4 == 9319
	replace industrycat_isic = 9321 if rama4d_r4 == 9321
	replace industrycat_isic = 9329 if rama4d_r4 == 9329
	replace industrycat_isic = 9411 if rama4d_r4 == 9411
	replace industrycat_isic = 9412 if rama4d_r4 == 9412
	replace industrycat_isic = 9420 if rama4d_r4 == 9420
	replace industrycat_isic = 9491 if rama4d_r4 == 9491
	replace industrycat_isic = 9492 if rama4d_r4 == 9492
	replace industrycat_isic = 9499 if rama4d_r4 == 9499
	replace industrycat_isic = 9511 if rama4d_r4 == 9511
	replace industrycat_isic = 9512 if rama4d_r4 == 9512
	replace industrycat_isic = 9521 if rama4d_r4 == 9521
	replace industrycat_isic = 9522 if rama4d_r4 == 9522
	replace industrycat_isic = 9524 if rama4d_r4 == 9524
	replace industrycat_isic = 9529 if rama4d_r4 == 9529
	replace industrycat_isic = 9601 if rama4d_r4 == 9601
	replace industrycat_isic = 9602 if rama4d_r4 == 9602
	replace industrycat_isic = 9603 if rama4d_r4 == 9603
	replace industrycat_isic = 9609 if rama4d_r4 == 9609
	replace industrycat_isic = 9700 if rama4d_r4 == 9700
	replace industrycat_isic = 9810 if rama4d_r4 == 9810
	replace industrycat_isic = 9820 if rama4d_r4 == 9820
	replace industrycat_isic = 9900 if rama4d_r4 == 9900

	gen industrycat_isic_S = string(industrycat_isic, "%04.0f")
	drop industrycat_isic
	rename industrycat_isic_S industrycat_isic
	replace industrycat_isic="" if lstatus!=1
	replace industrycat_isic="" if industrycat_isic=="."
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen byte industrycat10 = .
	destring rama2d_r4, replace force
	replace industrycat10 = 1 if inrange(rama2d_r4,1,3)
	replace industrycat10 = 2 if inrange(rama2d_r4,5,9)
	replace industrycat10 = 3 if inrange(rama2d_r4,10,33)
	replace industrycat10 = 4 if inrange(rama2d_r4,35,39)
	replace industrycat10 = 5 if inrange(rama2d_r4,41,43)
	replace industrycat10 = 6 if inrange(rama2d_r4,45,47)
	replace industrycat10 = 6 if inrange(rama2d_r4,55,56)
 	replace industrycat10 = 7 if inrange(rama2d_r4,49,53)
	replace industrycat10 = 7 if inrange(rama2d_r4,58,63)
	replace industrycat10 = 8 if inrange(rama2d_r4,64,68)
	replace industrycat10 = 9 if rama2d_r4==84
	replace industrycat10 = 10 if inrange(rama2d_r4,69,82)
	replace industrycat10 = 10 if inrange(rama2d_r4,85,99)
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
	destring oficio, replace
	gen occup_orig = oficio
	replace occup_orig=. if lstatus!=1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	gen occup_isco = .
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
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>

*<_occup_skill_>
	gen occup_skill = occup
	replace occup_skill = 3 if inrange(occup, 1, 3)
	replace occup_skill = 2 if inrange(occup, 4, 8)
	replace occup_skill = 1 if occup == 9
  replace occup_skill=. if occup==99
	la de lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lblskill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_wage_no_compen_>
	gen double wage_no_compen = p6500
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
	label values unitwage lblunitwage
	replace unitwage=. if lstatus!=1
*</_unitwage_>


*<_whours_>
	gen whours = p6800
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
	des p6500 p6510 p6510s1 p6510s2

	*Extra hours  QI.15
	gen wage_extra = p6510s1 if p6510==1
	*Replace by median value those who did not know the exact amount
	gen wage_extra_prel = wage_extra
	replace wage_extra_prel = . if p6510s1==98
	sum wage_extra_prel,d
	egen wage_extra_mean = median(wage_extra_prel)
	replace wage_extra = wage_extra_mean if p6510s1==98
	*Replace by 0 for those who already reported this in base wage
	replace wage_extra = 0 if p6510s2==1

	*In-kind income
	*In-kind income (food) QI.16
	gen wage_food = p6590s1 if lstatus==1
	count if p6590s1 ==98
	gen wage_food_prel = wage_food
	replace wage_food_prel = . if p6590s1 ==98
	egen wage_food_mean = median(wage_food_prel)
	replace wage_food = wage_food_mean if p6590s1 ==98
	*In-kind income (housing) QI.17
	gen wage_house = p6600s1 if lstatus==1
	count if p6600s1 ==98
	gen wage_house_prel = wage_food
	replace wage_house_prel = . if p6600s1 ==98
	egen wage_house_mean = median(wage_house_prel)
	replace wage_house = wage_house_mean if p6600s1 ==98
	*In-kind income (transport) QI.18
	gen wage_transp = p6610s1 if lstatus==1
	count if p6610s1 ==98
	sum p6610s1 if p6610s1 !=98
	gen wage_transp_prel = wage_transp
	replace wage_transp_prel = . if p6610s1==98
	egen wage_transp_mean = median(wage_transp_prel)
	replace wage_transp = wage_transp_mean if p6610s1==98
	*In-kind income (other in-kind) QI.19
	gen wage_otherk = p6620s1 if lstatus==1
	count if wage_otherk==98
	gen wage_otherk_prel = wage_otherk
	replace wage_otherk_prel = . if p6620s1 ==98
	egen wage_otherk_mean = median(wage_otherk_prel)
	replace wage_otherk = wage_otherk_mean if p6620s1 ==98
	*In-kind income (all)
	egen wage_kind = rsum(wage_food wage_house wage_transp wage_otherk) if lstatus==1
	count if wage_kind==0
	replace wage_kind = . if wage_kind == 0
	*mediana en lugar de media. ok para transporte, pero no bonificaciones

	*Bonuses
	*Q.I22a
	gen prim_serv = p6630s1a1/12
    *Q.I22b
	gen prim_christ = p6630s2a1/12
	*Q.I22c
	gen prim_vac = p6630s3a1/12
	*Q.I22d
	gen bon_ann = p6630s4a1/12
	*Bonuses (all)
	egen prim_bon = rsum(prim_serv prim_christ prim_vac bon_ann)
	replace prim_bon = . if prim_bon==0

	*Wage - Monthly income, including extra hours QI.14 + QI.15
	*Paid employees
	gen wage_principal_1 = p6500
	replace wage_principal_1 = p6500 + wage_extra if wage_extra!=.

	*Self-employed, employer and others
	*Wage for employers and self-employed workers
	count if p6750!=. & (empstat!=3 & empstat!=4 & empstat!=5)
	gen wage_self = p6750 if (empstat==3 | empstat==4 | empstat==5)
	  **Divide by number of months represented
	foreach x in 2 3 4 5 6 7 8 9 10 11 12 {
	replace wage_self = p6750/`x' if (empstat==3 | empstat==4 | empstat==5) & p6760==`x'
	}
	replace wage_self = p550/12 if p550!=. & wage_self==.

	*Replace wage for self-employed, employers, others
	replace wage_principal_1 = wage_self if (empstat==3 | empstat==4 | empstat==5 | p550!=.) & wage_self!=.
	replace wage_principal_1=0 if empstat==2
	replace wage_principal_1=. if lstatus!=1
	label var wage_principal_1 "Monthly income, including extra hours"
	sum wage_principal_1
	replace wage_principal_1 = wage_principal_1 + prim_bon if prim_bon!=.
	sum wage_principal_1

	*Wage - Monthly income, including extra hours + other job remunerations + bonuses
	gen wage_principal_2 = wage_principal_1
	replace wage_principal_2 = wage_principal_1 + wage_kind if wage_kind!=.
    replace wage_principal_2 = wage_principal_2 + prim_bon if prim_bon!=.

	*Replace wage for self-employed, employers, others
	replace wage_principal_2 = wage_self if (empstat==3 | empstat==4 | empstat==5 | p550!=.) & wage_self!=.
	replace wage_principal_2=0 if empstat==2
	replace wage_principal_2=. if lstatus!=1
	label var wage_principal_2 "Monthly income, including extra hours + in-kind payments"
	sum wage_principal_2

	gen wage_total = wage_principal_2*12
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen byte contract = 0
	replace contract=1 if p6450==2
	replace contract=. if p6450==9 //instead of replace contract=. if p6450==3
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	replace contract=. if lstatus!=1
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte healthins=p6990
	recode healthins 9=. 2=0
	label var healthins "Employment has health insurance primary job 7 day recall"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen byte socialsec=p6920
	recode socialsec 2=0 3=. 9=.
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec 1 "With social security" 0 "Without social secturity"
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen byte union = p7180
	recode union 2=0
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	gen byte firmsize_l = p6870
	recode firmsize_l 3=4 4=6 5=11 6=20 7=31 8=51 9=101
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u= p6870
	recode firmsize_u 2=3 3=5 4=10 5=19 6=30 7=50 8=100 9=.
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen byte empstat_2 = p7050
	recode empstat_2 2 3 8=1 5=3 6 7=2 9=5
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_> //not creating any variable, not rama2d rama4d for 2nd job
	gen ocusec_2 = .
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_> //not creating any variable, not rama2d rama4d for 2nd job
	gen industry_orig_2 = .
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_> //not creating any variable, not rama2d rama4d for 2nd job
	gen industrycat_isic_2 = .
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_> //not creating any variable, not rama2d rama4d for 2nd job
	gen byte industrycat10_2 = .
	label var industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
	label values industrycat10_2 lblindustrycat10
*</_industrycat10_2_>


*<_industrycat4_2_> //not creating any variable, not rama2d rama4d for 2nd job
	gen byte industrycat4_2 = industrycat10_2
	recode industrycat4_2 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_2 "Broad Economic Activities classification, secondary job 7 day recall"
	label values industrycat4_2 lblindustrycat4
*</_industrycat4_2_>


*<_occup_orig_2_> //not creating any variable, not rama2d rama4d for 2nd job
	gen occup_orig_2 = .
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_> //not creating any variable, not rama2d rama4d for 2nd job
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
	gen double wage_no_compen_2 = p7070 if p7070!=0
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2 = 5
	replace unitwage_2=. if njobs==0 | njobs==.
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
	gen byte firmsize_l_2 = p7075
	recode firmsize_l_2 3=4 4=6 5=11 6=20 7=31 8=51 9=101
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	gen byte firmsize_u_2 = p7075
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

*<_lstatus_year_> //not creating any variable, should wait for joining datasets with 2010?
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

*<_empstat_year_> //not creating any variable, should wait for joining datasets with 2010?
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

*<_empstat_2_year_> //not creating any variable, should wait for joining datasets with 2010?
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

* NUMBER OF ADDITIONAL JOBS LAST YEAR  //not creating any variable, should wait for joining datasets with 2009?
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


/*<_njobs_> Defined above
	gen njobs = .
	label var njobs "Total number of jobs"
*</_njobs_> */


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

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

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

save "`path_output'\COL_2021_GEIH_V01_M_V03_A_GLD_ALL.dta", replace

*</_% SAVE_>
}
