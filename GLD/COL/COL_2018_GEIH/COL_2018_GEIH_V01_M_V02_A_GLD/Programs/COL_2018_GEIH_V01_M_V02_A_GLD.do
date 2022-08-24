/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				COL_2018_GEIH_V01_M_V02_A_GLD_ALL
<_Application_>					Stata 17
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org)
<_Date created_>				2022-04-11

-------------------------------------------------------------------------

<_Country_>					    Colombia (COL)
<_Survey Title_>				Gran Encuesta Integrada de Hogares - GEIH
<_Survey Year_>					2018
<_Study ID_>					[Microdata Library ID if present] </_Study ID_>
<_Data collection from_>			01/2018
<_Data collection to_>				12/2018 </_Data collection to_>
<_Source of dataset_> 				Departamento Administrativo Nacional de Estadistica - DANE
<_Sample size (HH)_> 				231,128 </_Sample size (HH)_>
<_Sample size (IND)_> 				762,753  </_Sample size (IND)_>
<_Sampling method_> 				 probabilistic, multi-stage, stratified, unequal conglomerate and self-weighted design </_Sampling method_>
<_Geographic coverage_> 			national </_Geographic coverage_>
<_Currency_> 					COP </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS-13 </_ICLS Version_>
<_ISCED Version_>				isced-2011 </_ISCED Version_>
<_ISCO Version_>				N/A </_ISCO Version_>
<_OCCUP National_>				CNO 1970 </_OCCUP National_>
<_ISIC Version_>				ISIC REV 3.1 </_ISIC Version_>
<_INDUS National_>				ISIC COLOLMBIA REV 3</_INDUS National_>
-----------------------------------------------------------------------
<_Version Control_>

* Date: 2022-17-04 - Changes from I2D2 to GLD
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


local path_in "Z:\GLD-Harmonization\582018_AQ\COL\COL_2018_GEIH\COL_2018_GEIH_v01_M\Data\Stata\"
local path_output "Z:\GLD-Harmonization\582018_AQ\COL\COL_2018_GEIH\COL_2018_GEIH_v01_M_V02_A_GLD\Data\Harmonized\"

*----------1.3: Database assembly------------------------------*



*** append household monthly data
clear all
use "`path_in'\GEIH_2018_1.dta"

forvalues i=2/12 {
    append using "`path_in'\GEIH_2018_`i'.dta", force
}

rename *, lower
drop _merge

*** amazonia annual data append
*for data transformation use convert file in programs folder in original data folder
append using "`path_in'\amazonia\amazonia_2018.dta", force

***San andrés
append using "`path_in'\SA_2018.dta", force


tempfile general_2018
save `general_2018'

clear all


use "`path_in'\Migration\mi_1.dta"
forvalues i=2/12 {
    append using "`path_in'\Migration\mi_`i'.dta", force
}
*save "`path_in'\migration_2018.dta", replace
tempfile migration_2018
save `migration_2018'

*full set
use "`general_2018'",clear

*merge with migration asserting matches that need to be in master only (not in migration) or match (in both) in using would be an error.
merge 1:1 directorio secuencia_p orden using "`migration_2018'", force assert(master match) nogen
tempfile general_mig
save `general_mig'


****final dataset with updated weights
use "`path_in'\Fex proyeccion CNPV_2018.dta"
rename *, lower

merge 1:1 directorio secuencia_p orden using "`general_mig'", force assert(match using) nogen


save "`path_in'\data_2018_final.dta", replace

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
	gen isic_version = "isic_3.1"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	gen int year = 2018
	label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen vermast = "V01"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen veralt = "V02"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen harmonization = "GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	gen int_year = 2018 //instead of intv_year=ano
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_> // Includes all months
	destring mes, force replace
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
	*san andres urban
	replace urban=1 if dpto=="88"
	*amazonia ? ciudades entonces urbano
	replace urban=1 if inrange(area,"81","99")
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>

*<_subnatid1_>
	gen str subnatid1 =""
	replace subnatid1 = "1 - Atlantica" if dpto == "08" | dpto == "13"  | dpto == "20" | dpto == "23" | dpto == "44" | dpto == "47" | dpto == "70" | area == "08" | area == "13"  | area == "20" | area == "23" | area == "44" | area == "47" | area == "70"
	replace subnatid1 = "2 - Oriental" if dpto == "15" | dpto == "25" | dpto == "50" | dpto == "54" | dpto == "68" | area == "15" | area == "25" | area == "50" | area == "54" | area == "68"
	replace subnatid1 = "3 - Central" if dpto == "05" | dpto== "17" | dpto == "18" | dpto == "41" | dpto == "63" | dpto == "66" | dpto == "66" | dpto == "73" | area == "05" | area== "17" | area == "18" | area == "41" | area == "63" | area == "66" | area == "66" | area == "73"
	replace subnatid1 = "4 - Pacifica" if dpto == "19" | dpto == "27" | dpto == "52" | dpto == "76" | area == "19" | area == "27" | area == "52" | area == "76"
	replace subnatid1 = "5 - Santa Fe de Bogota" if dpto == "11" | area == "11"
	replace subnatid1 = "6 - Aamazonia y Orinoquía" if area == "81" | area == "85" | area == "86" |area == "91" | area == "94" | area == "95" | area == "97" | area == "99"
	replace subnatid1 = "7 - San Andrés" if dpto =="88" | area == "88"
	label var subnatid1 "Subnational ID at First Administrative Level"

/* <_subnatid1_note>

	The variable is string and country-specific categorical. Numeric entries are coded in string format using the following naming convention: "1 – Hatay". That is, the variable itself is to be string, not a labelled numeric vector.

	Example of entries would be "1 - Alaska",  "2 - Arkansas", ...

</_subnatid1_note> */
*</_subnatid1_>


*<_subnatid2_>
	gen str subnatid2 = dpto
	replace subnatid2 = "5 - Antioquia" if subnatid2 == "05"
	replace subnatid2 = "8 - Atlántico" if subnatid2 == "08"
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
	replace subnatid2= "" if dpto=="."
	replace subnatid2 = "81 - Arauca" if area == "81"
	replace subnatid2 = "85 - Yopal" if area == "85"
	replace subnatid2 = "86 - Mocoa" if area == "86"
	replace subnatid2 = "88 - San Andrés" if dpto =="88"
	replace subnatid2 = "91 - Leticia" if area == "91"
	replace subnatid2 = "94 - Inirida" if area == "94"
	replace subnatid2 = "95 - San Jose del Guaviare" if area == "95"
	replace subnatid2 = "97 - Mitu" if area == "97"
	replace subnatid2 = "99 - Puerto Carreño" if area == "99"
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
	destring rama2d rama4d, replace
	gen industry_orig = rama4d
	replace industry_orig=. if rama4d==0
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>



*<_industrycat_isic_> // Colombian ISIC rev 3.1 to ISIC rev. 3.1
	gen industrycat_isic = .
	replace industrycat_isic = 111 if rama4d == 114 | rama4d == 115 | rama4d == 118 | rama4d == 119
	replace industrycat_isic = 112 if rama4d == 112 | rama4d == 116
	replace industrycat_isic = 113 if rama4d == 111 | rama4d == 113 | rama4d == 117
	replace industrycat_isic = 121 if rama4d == 121 | rama4d == 124
	 replace industrycat_isic = 120 if  rama4d == 129
	replace industrycat_isic = 122 if rama4d == 122 | rama4d == 123 | rama4d == 125
	replace industrycat_isic = 130 if rama4d == 130
	replace industrycat_isic = 140 if rama4d == 140
	replace industrycat_isic = 150 if rama4d == 150
	replace industrycat_isic = 200 if rama4d == 201 | rama4d == 202
	replace industrycat_isic = 501 if rama4d == 501
	replace industrycat_isic = 502 if rama4d == 502
	replace industrycat_isic = 1010 if rama4d == 1010
	replace industrycat_isic = 1020 if rama4d == 1020
	replace industrycat_isic = 1030 if rama4d == 1030
	replace industrycat_isic = 1110 if rama4d == 1110
	replace industrycat_isic = 1120 if rama4d == 1120
	replace industrycat_isic = 1200 if rama4d == 1200
	replace industrycat_isic = 1310 if rama4d == 1310
	replace industrycat_isic = 1320 if rama4d == 1320 | rama4d == 1331 | rama4d == 1339
	replace industrycat_isic = 1410 if rama4d == 1411 | rama4d == 1412 | rama4d == 1413 | rama4d == 1414 | rama4d == 1415
	replace industrycat_isic = 1421 if rama4d == 1421
	replace industrycat_isic = 1422 if rama4d == 1422
	replace industrycat_isic = 1429 if rama4d == 1431 | rama4d == 1432 | rama4d == 1490
	replace industrycat_isic = 1511 if rama4d == 1511
	replace industrycat_isic = 1512 if rama4d == 1512
	replace industrycat_isic = 1513 if rama4d == 1521
	replace industrycat_isic = 1514 if rama4d == 1522
	replace industrycat_isic = 1520 if rama4d == 1530
	replace industrycat_isic = 1531 if rama4d == 1541
	replace industrycat_isic = 1532 if rama4d == 1542
	replace industrycat_isic = 1533 if rama4d == 1543
	replace industrycat_isic = 1541 if rama4d == 1551
	replace industrycat_isic = 1542 if rama4d == 1571 | rama4d == 1572
	replace industrycat_isic = 1544 if rama4d == 1581
	replace industrycat_isic = 1544 if rama4d == 1552
	replace industrycat_isic = 1549 if rama4d == 1561 | rama4d == 1562 | rama4d == 1563 | rama4d == 1564 | rama4d == 1589
	replace industrycat_isic = 1551 if rama4d == 1591
	replace industrycat_isic = 1552 if rama4d == 1592
	replace industrycat_isic = 1553 if rama4d == 1593
	replace industrycat_isic = 1554 if rama4d == 1594
	replace industrycat_isic = 1600 if rama4d == 1600
	replace industrycat_isic = 1711 if rama4d == 1710 | rama4d == 1720
	replace industrycat_isic = 1712 if rama4d == 1730
	replace industrycat_isic = 1721 if rama4d == 1741
	replace industrycat_isic = 1722 if rama4d == 1742
	replace industrycat_isic = 1723 if rama4d == 1743
	replace industrycat_isic = 1729 if rama4d == 1749
	replace industrycat_isic = 1730 if rama4d == 1750
	replace industrycat_isic = 1810 if rama4d == 1810
	replace industrycat_isic = 1820 if rama4d == 1820
	replace industrycat_isic = 1911 if rama4d == 1910
	replace industrycat_isic = 1912 if rama4d == 1931 | rama4d == 1932 | rama4d == 1939
	replace industrycat_isic = 1920 if rama4d == 1921 | rama4d == 1922 | rama4d == 1923 | rama4d == 1924 | rama4d == 1925 | rama4d == 1926 | rama4d == 1929
	replace industrycat_isic = 2010 if rama4d == 2010
	replace industrycat_isic = 2021 if rama4d == 2020
	replace industrycat_isic = 2022 if rama4d == 2030
	replace industrycat_isic = 2023 if rama4d == 2040
	replace industrycat_isic = 2029 if rama4d == 2090
	replace industrycat_isic = 2101 if rama4d == 2101
	replace industrycat_isic = 2102 if rama4d == 2102
	replace industrycat_isic = 2109 if rama4d == 2109
	replace industrycat_isic = 2211 if rama4d == 2211
	replace industrycat_isic = 2212 if rama4d == 2212
	replace industrycat_isic = 2213 if rama4d == 2213
	replace industrycat_isic = 2219 if rama4d == 2219
	replace industrycat_isic = 2221 if rama4d == 2220
	replace industrycat_isic = 2222 if rama4d == 2231 | rama4d == 2232 | rama4d == 2233 | rama4d == 2234 | rama4d == 2239
	replace industrycat_isic = 2230 if rama4d == 2240
	replace industrycat_isic = 2310 if rama4d == 2310
	replace industrycat_isic = 2320 if rama4d == 2321 | rama4d == 2322
	replace industrycat_isic = 2330 if rama4d == 2330
	replace industrycat_isic = 2411 if rama4d == 2411
	replace industrycat_isic = 2412 if rama4d == 2412
	replace industrycat_isic = 2413 if rama4d == 2413 | rama4d == 2414
	replace industrycat_isic = 2421 if rama4d == 2421
	replace industrycat_isic = 2422 if rama4d == 2422
	replace industrycat_isic = 2423 if rama4d == 2423
	replace industrycat_isic = 2424 if rama4d == 2424
	replace industrycat_isic = 2429 if rama4d == 2429
	replace industrycat_isic = 2430 if rama4d == 2430
	replace industrycat_isic = 2511 if rama4d == 2511 | rama4d == 2512 | rama4d == 2513 /* included*/
	replace industrycat_isic = 2520 if rama4d == 2521 | rama4d == 2529
	*included
	replace industrycat_isic = 2519 if rama4d == 2519
	*
	replace industrycat_isic = 2610 if rama4d == 2610
	replace industrycat_isic = 2691 if rama4d == 2691
	replace industrycat_isic = 2692 if rama4d == 2692
	replace industrycat_isic = 2693 if rama4d == 2693
	replace industrycat_isic = 2694 if rama4d == 2694
	replace industrycat_isic = 2695 if rama4d == 2695
	replace industrycat_isic = 2696 if rama4d == 2696
	replace industrycat_isic = 2699 if rama4d == 2699
	replace industrycat_isic = 2710 if rama4d == 2710
	replace industrycat_isic = 2720 if rama4d == 2721 | rama4d == 2729
	replace industrycat_isic = 2731 if rama4d == 2731
	replace industrycat_isic = 2732 if rama4d == 2732
	replace industrycat_isic = 2811 if rama4d == 2811
	replace industrycat_isic = 2812 if rama4d == 2812
	replace industrycat_isic = 2813 if rama4d == 2813
	replace industrycat_isic = 2891 if rama4d == 2891
	replace industrycat_isic = 2892 if rama4d == 2892
	replace industrycat_isic = 2893 if rama4d == 2893
	replace industrycat_isic = 2899 if rama4d == 2899
	replace industrycat_isic = 2911 if rama4d == 2911
	replace industrycat_isic = 2912 if rama4d == 2912
	replace industrycat_isic = 2913 if rama4d == 2913
	replace industrycat_isic = 2914 if rama4d == 2914
	replace industrycat_isic = 2915 if rama4d == 2915
	replace industrycat_isic = 2919 if rama4d == 2919
	replace industrycat_isic = 2921 if rama4d == 2921
	replace industrycat_isic = 2922 if rama4d == 2922
	replace industrycat_isic = 2923 if rama4d == 2923
	replace industrycat_isic = 2924 if rama4d == 2924
	replace industrycat_isic = 2925 if rama4d == 2925
	replace industrycat_isic = 2926 if rama4d == 2926
	replace industrycat_isic = 2927 if rama4d == 2927
	replace industrycat_isic = 2929 if rama4d == 2929
	replace industrycat_isic = 2930 if rama4d == 2930
	replace industrycat_isic = 3000 if rama4d == 3000
	replace industrycat_isic = 3110 if rama4d == 3110
	replace industrycat_isic = 3120 if rama4d == 3120
	replace industrycat_isic = 3130 if rama4d == 3130
	replace industrycat_isic = 3140 if rama4d == 3140
	replace industrycat_isic = 3150 if rama4d == 3150
	replace industrycat_isic = 3190 if rama4d == 3190
	replace industrycat_isic = 3210 if rama4d == 3210
	replace industrycat_isic = 3220 if rama4d == 3220
	replace industrycat_isic = 3230 if rama4d == 3230
	replace industrycat_isic = 3311 if rama4d == 3311
	replace industrycat_isic = 3312 if rama4d == 3312
	replace industrycat_isic = 3313 if rama4d == 3313
	replace industrycat_isic = 3320 if rama4d == 3320
	replace industrycat_isic = 3330 if rama4d == 3330
	replace industrycat_isic = 3410 if rama4d == 3410
	replace industrycat_isic = 3420 if rama4d == 3420
	replace industrycat_isic = 3430 if rama4d == 3420 | rama4d == 3430 /*included*/
	replace industrycat_isic = 3511 if rama4d == 3511
	replace industrycat_isic = 3512 if rama4d == 3512
	replace industrycat_isic = 3520 if rama4d == 3520
	replace industrycat_isic = 3530 if rama4d == 3530
	replace industrycat_isic = 3591 if rama4d == 3591
	replace industrycat_isic = 3592 if rama4d == 3592
	replace industrycat_isic = 3599 if rama4d == 3599
	replace industrycat_isic = 3610 if rama4d == 3611 | rama4d == 3612 | rama4d == 3613 | rama4d == 3614 | rama4d == 3619
	replace industrycat_isic = 3691 if rama4d == 3691
	replace industrycat_isic = 3692 if rama4d == 3692
	replace industrycat_isic = 3693 if rama4d == 3693
	replace industrycat_isic = 3694 if rama4d == 3694
	replace industrycat_isic = 3699 if rama4d == 3699
	replace industrycat_isic = 3710 if rama4d == 3710
	replace industrycat_isic = 3720 if rama4d == 3720
	replace industrycat_isic = 4010 if rama4d == 4010
	replace industrycat_isic = 4020 if rama4d == 4020
	replace industrycat_isic = 4030 if rama4d == 4030
	replace industrycat_isic = 4100 if rama4d == 4100
	replace industrycat_isic = 4510 if rama4d == 4511 | rama4d == 4512
	replace industrycat_isic = 4520 if rama4d == 4521 | rama4d == 4522 | rama4d == 4530
	replace industrycat_isic = 4530 if rama4d == 4541 | rama4d == 4542 | rama4d == 4543 | rama4d == 4549
	replace industrycat_isic = 4540 if rama4d == 4551 | rama4d == 4552 | rama4d == 4559
	replace industrycat_isic = 4550 if rama4d == 4560
	replace industrycat_isic = 5010 if rama4d == 5011 | rama4d == 5012
	replace industrycat_isic = 5020 if rama4d == 5020
	replace industrycat_isic = 5030 if rama4d == 5030
	replace industrycat_isic = 5040 if rama4d == 5040
	replace industrycat_isic = 5050 if rama4d == 5051 | rama4d == 5052
	replace industrycat_isic = 5110 if rama4d == 5111 | rama4d == 5112 | rama4d == 5113 | rama4d == 5119
	replace industrycat_isic = 5121 if rama4d == 5121 | rama4d == 5123 | rama4d == 5124
	replace industrycat_isic = 5122 if rama4d == 5122 | rama4d == 5125 | rama4d == 5126 | rama4d == 5127
	replace industrycat_isic = 5131 if rama4d == 5131 | rama4d == 5132 | rama4d == 5133
	replace industrycat_isic = 5139 if rama4d == 5134 | rama4d == 5135 | rama4d == 5136 | rama4d == 5137 | rama4d == 5139
	replace industrycat_isic = 5143 if rama4d == 5141 | rama4d == 5142
	replace industrycat_isic = 5149 if rama4d == 5153 | rama4d == 5154 | rama4d == 5155 | rama4d == 5159
	*included
	replace industrycat_isic = 5520 if rama4d == 5521 | rama4d == 5522 | rama4d == 5523 |  rama4d == 5524 | rama4d == 5529 | rama4d == 5530
	*
	replace industrycat_isic = 5151 if rama4d == 5163 | rama4d == 5151
	replace industrycat_isic = 5152 if rama4d == 5169 | rama4d == 5152
	replace industrycat_isic = 5159 if rama4d == 5161 | rama4d == 5162 | rama4d == 5170
	replace industrycat_isic = 5190 if rama4d == 5190
	replace industrycat_isic = 5211 if rama4d == 5211
	replace industrycat_isic = 5219 if rama4d == 5219
	replace industrycat_isic = 5220 if rama4d == 5221 | rama4d == 5222 | rama4d == 5223 | rama4d == 5224 | rama4d == 5225 | rama4d == 5229
	replace industrycat_isic = 5231 if rama4d == 5231
	replace industrycat_isic = 5232 if rama4d == 5232 | rama4d == 5233 | rama4d == 5234
	replace industrycat_isic = 5233 if rama4d == 5235 | rama4d == 5236 | rama4d == 5237
	replace industrycat_isic = 5234 if rama4d == 5241 | rama4d == 5242
	replace industrycat_isic = 5239 if rama4d == 5243 | rama4d == 5244 | rama4d == 5245 | rama4d == 5246 | rama4d == 5249 | rama4d == 5239
	replace industrycat_isic = 5240 if rama4d == 5251 | rama4d == 5252
	replace industrycat_isic = 5251 if rama4d == 5261
	replace industrycat_isic = 5252 if rama4d == 5262
	replace industrycat_isic = 5259 if rama4d == 5269
	replace industrycat_isic = 5260 if rama4d == 5271 | rama4d == 5272
	replace industrycat_isic = 5510 if rama4d == 5511 | rama4d == 5512 | rama4d == 5513 | rama4d == 5519
	replace industrycat_isic = 6010 if rama4d == 6010
	replace industrycat_isic = 6021 if rama4d == 6021 | rama4d == 6022 | rama4d == 6023
	replace industrycat_isic = 6022 if rama4d == 6031 | rama4d == 6032 | rama4d == 6039
	replace industrycat_isic = 6023 if rama4d == 6041 | rama4d == 6042 | rama4d == 6043 | rama4d == 6044
	replace industrycat_isic = 6030 if rama4d == 6050
	replace industrycat_isic = 6110 if rama4d == 6111 | rama4d == 6112
	replace industrycat_isic = 6120 if rama4d == 6120
	replace industrycat_isic = 6210 if rama4d == 6211 | rama4d == 6212 | rama4d == 6213 | rama4d == 6214
	replace industrycat_isic = 6220 if rama4d == 6220
	replace industrycat_isic = 6301 if rama4d == 6310
	replace industrycat_isic = 6302 if rama4d == 6320
	replace industrycat_isic = 6303 if rama4d == 6331 | rama4d == 6332 | rama4d == 6333 | rama4d == 6339
	replace industrycat_isic = 6304 if rama4d == 6340
	replace industrycat_isic = 6309 if rama4d == 6390
	replace industrycat_isic = 6411 if rama4d == 6411
	replace industrycat_isic = 6412 if rama4d == 6412
	replace industrycat_isic = 6420 if rama4d == 6421 | rama4d == 6422 | rama4d == 6423 | rama4d == 6424 | rama4d == 6425 | rama4d == 6426
	replace industrycat_isic = 6511 if rama4d == 6511
	replace industrycat_isic = 6519 if rama4d == 6512 | rama4d == 6513 | rama4d == 6514 | rama4d == 6515 | rama4d == 6516 | rama4d == 6519
	replace industrycat_isic = 6591 if rama4d == 6591
	replace industrycat_isic = 6592 if rama4d == 6593 | rama4d == 6596
	replace industrycat_isic = 6599 if rama4d == 6594 | rama4d == 6595 | rama4d == 6599
	replace industrycat_isic = 6601 if rama4d == 6602 | rama4d == 6603
	replace industrycat_isic = 6602 if rama4d == 6604
	replace industrycat_isic = 6603 if rama4d == 6601
	replace industrycat_isic = 6711 if rama4d == 6711 | rama4d == 6712
	replace industrycat_isic = 6712 if rama4d == 6592 | rama4d == 6713 | rama4d == 6714
	replace industrycat_isic = 6719 if rama4d == 6715 | rama4d == 6716 | rama4d == 6719
	replace industrycat_isic = 6720 if rama4d == 6721 | rama4d == 6722
	replace industrycat_isic = 7010 if rama4d == 7010
	replace industrycat_isic = 7020 if rama4d == 7020
	replace industrycat_isic = 7111 if rama4d == 7111
	replace industrycat_isic = 7112 if rama4d == 7112
	replace industrycat_isic = 7113 if rama4d == 7113
	replace industrycat_isic = 7121 if rama4d == 7121
	replace industrycat_isic = 7122 if rama4d == 7122
	replace industrycat_isic = 7123 if rama4d == 7123
	replace industrycat_isic = 7129 if rama4d == 7129
	replace industrycat_isic = 7130 if rama4d == 7130
	replace industrycat_isic = 7210 if rama4d == 7210
	replace industrycat_isic = 7221 if rama4d == 7220
	replace industrycat_isic = 7230 if rama4d == 7230
	replace industrycat_isic = 7240 if rama4d == 7240
	replace industrycat_isic = 7250 if rama4d == 7250
	replace industrycat_isic = 7290 if rama4d == 7290
	replace industrycat_isic = 7310 if rama4d == 7310
	replace industrycat_isic = 7320 if rama4d == 7320
	replace industrycat_isic = 7411 if rama4d == 7411
	replace industrycat_isic = 7412 if rama4d == 7412
	replace industrycat_isic = 7413 if rama4d == 7413
	replace industrycat_isic = 7414 if rama4d == 7414
	replace industrycat_isic = 7421 if rama4d == 7421
	replace industrycat_isic = 7422 if rama4d == 7422
	replace industrycat_isic = 7430 if rama4d == 7430
	replace industrycat_isic = 7491 if rama4d == 7491
	replace industrycat_isic = 7492 if rama4d == 7492
	replace industrycat_isic = 7493 if rama4d == 7493
	replace industrycat_isic = 7494 if rama4d == 7494
	replace industrycat_isic = 7495 if rama4d == 7495
	replace industrycat_isic = 7499 if rama4d == 7499
	replace industrycat_isic = 7511 if rama4d == 7511 | rama4d == 7512
	replace industrycat_isic = 7512 if rama4d == 7513
	replace industrycat_isic = 7513 if rama4d == 7514
	replace industrycat_isic = 7514 if rama4d == 7515
	replace industrycat_isic = 7521 if rama4d == 7521
	replace industrycat_isic = 7522 if rama4d == 7522
	replace industrycat_isic = 7523 if rama4d == 7523 | rama4d == 7524
	replace industrycat_isic = 7530 if rama4d == 7530
	replace industrycat_isic = 8010 if rama4d == 8011 | rama4d == 8012 | rama4d == 8041 | rama4d == 8042 | rama4d == 8043 | rama4d == 8044 | rama4d == 8045 | rama4d == 8046
	replace industrycat_isic = 8021 if rama4d == 8021 | rama4d == 8022
	replace industrycat_isic = 8022 if rama4d == 8030
	replace industrycat_isic = 8090 if rama4d == 8050
	replace industrycat_isic = 8090 if rama4d == 8060
	replace industrycat_isic = 8511 if rama4d == 8511
	replace industrycat_isic = 8512 if rama4d == 8512 | rama4d == 8513
	replace industrycat_isic = 8519 if rama4d == 8514 | rama4d == 8515 | rama4d == 8519
	replace industrycat_isic = 8520 if rama4d == 8520
	replace industrycat_isic = 8531 if rama4d == 8531
	replace industrycat_isic = 8532 if rama4d == 8532
	replace industrycat_isic = 9000 if rama4d == 9000
	replace industrycat_isic = 9111 if rama4d == 9111
	replace industrycat_isic = 9112 if rama4d == 9112
	replace industrycat_isic = 9120 if rama4d == 9120
	replace industrycat_isic = 9191 if rama4d == 9191
	replace industrycat_isic = 9192 if rama4d == 9192
	replace industrycat_isic = 9199 if rama4d == 9199
	replace industrycat_isic = 9211 if rama4d == 9211
	replace industrycat_isic = 9212 if rama4d == 9212
	replace industrycat_isic = 9213 if rama4d == 9213
	replace industrycat_isic = 9214 if rama4d == 9214
	replace industrycat_isic = 9219 if rama4d == 9219
	replace industrycat_isic = 9220 if rama4d == 9220
	replace industrycat_isic = 9231 if rama4d == 9231
	replace industrycat_isic = 9232 if rama4d == 9232
	replace industrycat_isic = 9233 if rama4d == 9233
	replace industrycat_isic = 9241 if rama4d == 9241
	replace industrycat_isic = 9249 if rama4d == 9242 | rama4d == 9249
	replace industrycat_isic = 9301 if rama4d == 9301
	replace industrycat_isic = 9302 if rama4d == 9302
	replace industrycat_isic = 9303 if rama4d == 9303
	*included
	replace industrycat_isic = 9309 if rama4d == 9309
	*
	replace industrycat_isic = 9500 if rama4d == 9500
	replace industrycat_isic = 9600 if rama4d == 9600
	replace industrycat_isic = 9700 if rama4d == 9700
	replace industrycat_isic = 9900 if rama4d == 9900
	replace industrycat_isic = . if rama4d == 0000
	replace industrycat_isic = . if rama4d == 0
	gen industrycat_isic_S = string(industrycat_isic, "%04.0f")
	drop industrycat_isic
	rename industrycat_isic_S industrycat_isic
	replace industrycat_isic="" if lstatus!=1
	replace industrycat_isic="" if industrycat_isic=="."
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen byte industrycat10 = .
	replace industrycat10 = 1 if rama2d==1 | rama2d==2|rama2d==5
	replace industrycat10 = 2 if rama2d>=10 & rama2d<=14
	replace industrycat10 = 3 if rama2d>=15 & rama2d<=37
	replace industrycat10 = 4 if rama2d==40 | rama2d==41
	replace industrycat10 = 5 if rama2d==45
	replace industrycat10 = 6 if (rama2d>=50 & rama2d<=52) | rama2d==55
	replace industrycat10 = 7 if rama2d>=60 & rama2d<=64
	replace industrycat10 = 8 if (rama2d>=65 & rama2d<=67)|(rama2d>=70 & rama2d<=74)
	replace industrycat10 = 9 if rama2d==75
	replace industrycat10 = 10 if rama2d>=80 & rama2d<=99
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
  replace occup_skill =. if occup==99
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
	replace unitwage=. if lstatus!=1
	label values unitwage lblunitwage
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
	label values contract lblcontract
	replace contract=. if lstatus!=1
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

save "`path_output'\COL_2018_GEIH_V01_M_V02_A_GLD_ALL.dta", replace

*</_% SAVE_>
}
