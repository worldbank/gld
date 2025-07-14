
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				[MEX_2020_ENOE_V03_M_V02_A_GLD_ALL.do] </_Program name_>
<_Application_>					[STATA] <_Application_>
<_Author(s)_>					[The World Bank Jobs Group] </_Author(s)_>
<_Date created_>				2021-04-01 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						Mexico (MEX) </_Country_>
<_Survey Title_>				Encuesta Nacional de Ocupación y Empleo] </_Survey Title_>
<_Survey Year_>					2020 </_Survey Year_>
<_Study ID_>					Microdata Library ID if present] </_Study ID_>
<_Data collection from_>		01/2020 </_Data collection from_>
<_Data collection to_>			03/2020 </_Data collection to_>
<_Source of dataset_> 			INEGI (Mexico NSO) </_Source of dataset_>
<_Sample size (HH)_> 			[] </_Sample size (HH)_>
<_Sample size (IND)_> 			417,783 </_Sample size (IND)_>
<_Sampling method_> 			[ El tipo de muestreo utilizado es probabilístico, bietápico, estratificado y por conglomerados.] </_Sampling method_>
<_Geographic coverage_> 		[Los niveles geograficos usados en la encuesta de México comienzan en estados siguen con ciudades autorrepresentadas y terminan con municipios de las ciudades autorrepresentadas. https://www.inegi.org.mx/contenidos/productos/prod_serv/contenidos/espanol/bvinegi/productos/metodologias/est/cobertura.pdf] </_Geographic coverage_>
<_Currency_> 					[Pesos] </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				[ICLS-18] </_ICLS Version_>
<_ISCED Version_>				[ISCED 2011] </_ISCED Version_>
<_ISCO Version_>				[ISCO 08] </_ISCO Version_>
<_OCCUP National_>				[Sinco 2019] </_OCCUP National_>
<_ISIC Version_>				[Rev.4] </_ISIC Version_>
<_INDUS National_>				[SCIAN 2007] </_INDUS National_>
-----------------------------------------------------------------------
<_Version Control_>

* Date: [2024-10-24] - New master that only uses T1 of 2020 as the last ENOE before pandemic
*                      switch to ENOE-N
* Date: [2025-07-14] - New master that only uses T1 of 2020 as the last ENOE before pandemic
*                      switch to ENOE-N

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
local server  "C:/Users/`c(username)'/WBG/GLD - GLD"
local country "MEX"
local year    "2020"
local survey  "ENOE"
local vermast "V03"
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

* All steps necessary to merge datasets (if several) to have all elements needed to produce
/*
* We want all variables to have the prefix of its source but for the variables
* that we use for merging. This is because some repeat: there are p1 in one file,
* p1 in another, Stata will keep the master, not tell us about the repeat.
* We create a local with the ones we exclude 
local exclude "cd_a ent con v_sel n_hog h_mud n_ren loc t_loc t_loc_tri t_loc_men fac fac_tri fac_men mun est est_d ageb ur n_ent r_def upm n_pro_viv per"

*** SDEM ***
use "`path_in_stata'/ENOE_SDEMT120.dta"

* First rename all 
rename * sdem_=

* Now drop the cases we don't want 

* Add prefix to all but the merging variables
foreach var of local exclude  {
 
    * Check if variable in data 
	cap des sdem_`var'
	
	* If present, rename 
	if _rc == 0 {
		
		rename sdem_`var' `var'
		
	} // end if variable present
} // end loop through variable list

* Add quarter
gen quarter = 1

* Save tempfile
tempfile sdem 
save "`sdem'"

*** COE1 ***
use "`path_in_stata'/ENOE_COE1T120.dta"

* First rename all 
rename * coe1_=

* Now drop the cases we don't want 

* Add prefix to all but the merging variables
foreach var of local exclude  {
 
    * Check if variable in data 
	cap des coe1_`var'
	
	* If present, rename 
	if _rc == 0 {
		
		rename coe1_`var' `var'
		
	} // end if variable present
} // end loop through variable list

* Save tempfile
tempfile coe1 
save "`coe1'"

*** COE2 ***
use "`path_in_stata'/ENOE_COE2T120.dta"

* First rename all 
rename * coe2_=

* Now drop the cases we don't want 

* Add prefix to all but the merging variables
foreach var of local exclude  {
 
    * Check if variable in data 
	cap des coe2_`var'
	
	* If present, rename 
	if _rc == 0 {
		
		rename coe2_`var' `var'
		
	} // end if variable present
} // end loop through variable list

* Save tempfile
tempfile coe2 
save "`coe2'"

*** HOG ***
use "`path_in_stata'/ENOE_HOGT120.dta"

* First rename all 
rename * hog_=

* Now drop the cases we don't want 

* Add prefix to all but the merging variables
foreach var of local exclude  {
 
    * Check if variable in data 
	cap des hog_`var'
	
	* If present, rename 
	if _rc == 0 {
		
		rename hog_`var' `var'
		
	} // end if variable present
} // end loop through variable list

* Save tempfile
tempfile hog 
save "`hog'"

*** VIV ***
use "`path_in_stata'/ENOE_VIVT120.dta"

* First rename all 
rename * viv_=

* Now drop the cases we don't want 

* Add prefix to all but the merging variables
foreach var of local exclude  {
 
    * Check if variable in data 
	cap des viv_`var'
	
	* If present, rename 
	if _rc == 0 {
		
		rename viv_`var' `var'
		
	} // end if variable present
} // end loop through variable list

* Save tempfile
tempfile viv 
save "`viv'"

* Now merge it 
use "`sdem'", clear

* Add in COEs
quietly : merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "`coe1'", assert(match master) nogen
quietly : merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "`coe2'", assert(match master) nogen

* Add in HH level info, keep only HHs that have individual info 
* Should not lose any, thus check the number of rows is the same before and after
count
local num_rows = `r(N)'

merge m:1 cd_a ent con v_sel n_hog h_mud using "`hog'", keep(match) nogen
merge m:1 cd_a ent con v_sel             using "`viv'", keep(match) nogen

count
assert `r(N)' == `num_rows'

* Merge in the SINCO to ISCO codes - first and second job
tostring coe1_p3, gen(sinco) format("%04.0f")
merge m:1 sinco using "`path_in_stata'/SINCO_11_ISCO_08.dta", keep(master match) nogen
rename isco isco_1
drop sinco match
tostring coe2_p7a, gen(sinco) format("%04.0f")
merge m:1 sinco using "`path_in_stata'/SINCO_11_ISCO_08.dta", keep(master match) nogen
rename isco isco_2
drop sinco match

*Merge in SCIAN codes - first and second job 
gen scian = coe1_p4a
merge m:1 scian using "`path_in_stata'/SCIAN_07_ISIC_4.dta", keep(master match) nogen
rename isic isic_1
drop scian

gen scian = coe2_p7c
merge m:1 scian using "`path_in_stata'/SCIAN_07_ISIC_4.dta", keep(master match) nogen
rename isic isic_2
drop scian

* Save the file
save "`path_in_stata'/ENOE_2020.dta", replace
*/

* Call the file directly (quicker)
* For the first time, use the above outcommented code
use "`path_in_stata'/ENOE_2020.dta", clear	


/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str3 countrycode = "MEX"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "ENOE"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "LFS"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	gen icls_v = "ICLS-13"
	label var icls_v "ICLS version(s) underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	gen isced_version = ""
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
	gen isco_version = "isco_2008"
	label var isco_version "Version of ISCO used"
*</_isco_version_


*<_isic_version_>
	gen isic_version = "isic_4"
	label var isic_version "Version of ISIC used
*</_isic_version_>


*<_year_>
	gen int year = 2020
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
	gen int_year = hog_p_anio + 2000
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen  int_month = hog_p_mes
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

	tostring (ent v_sel n_ren), gen(ent_str v_sel_str n_ren_str) format("%02.0f")
	tostring con, gen(con_str) format("%05.0f")
	tostring (n_hog h_mud), gen(n_hog_str h_mud_str) format("%01.0f")
	
	egen hhid=concat(ent_str con_str v_sel_str n_hog_str h_mud_str)
	label var hhid "Household ID"
	assert !missing(hhid)
*</_hhid_>


*<_pid_>
	egen  pid = concat(hhid n_ren_str)
	label var pid "Individual ID"
*</_pid_>


*<_weight_>

/* <_weight_note>

	In this case, we only have one quarter hence we weigth = weight_q

</_weight_note> */
	
	gen weight = fac
	label var weight "Household sampling weight"
*</_weight_>


*<_weight_m_>
	gen weight_m = .
	label var weight_m "Survey sampling weight to obtain national estimates for each month"
*</_weight_m_>


*<_weight_q_>
	gen weight_q = fac
	label var weight_q "Survey sampling weight to obtain national estimates for each quarter"
*</_weight_q_>


*<_psu_>
	gen psu = upm
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = hhid
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	gen strata = est_d
	label var strata "Strata"
*</_strata_>


*<_wave_>
	gen str2 wave = "Q" + string(quarter)
	label var wave "Survey wave"
*</_wave_>


*<_panel_>
/* <_panel_note>

	Panel = (year - 2005)*4 + alpha + (quarter - 1)
	alpha = 5 - n_ent +1 
	
	*Where:
		year: interview year
		quarter: survey quarter
		alpha: inverse of the visit number
		n_ent: visit number

</_panel_note> */

	gen alpha = 5 - n_ent + 1
	gen panel = (int_year - 2005) * 4 + alpha + (quarter - 1)
	label var panel "Panel individual belongs to"
*</_panel_>


*<_visit_no_>
	gen visit_no = n_ent 
	label var visit_no "Visit number in panel"
*</_visit_no_>

}

/*%%=============================================================================================
	3: Geography
==============================================================================================%%*/

{

*<_urban_>
	gen byte urban=.
 	replace urban=1 if inrange(t_loc,1,3)
 	replace urban=0 if t_loc==4
 	label var urban "Location is urban"
 	la de lblurban 1 "Urban" 0 "Rural"
 	label values urban lblurban
*</_urban_>


*<_subnatid1_>
  * State info in variable ent, is a labelled number
  decode ent,   gen(helper_lbl)
  tostring ent, gen(helper_num)
  gen subnatid1 = helper_num + " - " + helper_lbl
  label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
*selected main cities from states
	gen byte subnatid2 = cd_a
	recode subnatid2 82/86=81
	label de lblsubnatid2 1 "1 - Mexico" 2 "2 - Guadalajara" 3 "3 - Monterrey" 4 "4 - Puebla" 5 "5 - Leon" 7 "6 - San Luis Potosi" 8 "7 - Merida" 9 "8 - Chihuahua" 10 " 9 - Tampico" 12 "10 - Veracruz" 13 "11 - Acapulco" 14 "12 - Aguacalientes" 15 "13 - Morelia" 16 "14 - Toluca" 17 "15 - Saltillo" 18 "16 - Villahermosa" 19 "17 - Tuxtla Gutierrez" 21 "18 - Tijuana" 24 "19 - Culiacan" 25 "20 - Hermosillo" 26 "21 - Durango" 27 "22 - Tepic" 28 "23 - Campeche" 29 "24 - Cuernavaca" 31 "25 - Oaxaca" 32 "26 - Zacatecas " 33 "27 - Colima" 36 "28 - Queretaro" 39 "29 - Tlaxcala" 40 "30 - La Paz " 41 "31 - Cancun" 43 "32 - Pachuca" 42 "33 - Ciudad del Carmen" 44 "34 - Mexicali" 46 "35 - Reynosa" 52 "36 Tapachula" 6 "37 - Torreón" 20 "38 - Ciudad Juárez" 30 "39 - Coatzacoalcos" 81 "99 - Complemento Urbano Rural", replace
	label values subnatid2 lblsubnatid2
	decode subnatid2, gen(help_sub2)
	drop subnatid2
	rename help_sub2 subnatid2
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
*selected towns within selected cities from states
	gen byte subnatid3 = loc
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
	gen subnatidsurvey = "subnatid2"
	label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>


*<_subnatid1_prev_>
/* <_subnatid1_prev>

	subnatid1_prev is coded as missing unless the classification used for subnatid1 has changed since the previous survey.

</_subnatid1_prev> */
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
	bysort hhid quarter: gen hsize=_N if sdem_par_c<400 | inrange(sdem_par_c,600,999)
	* Domestic workers (codes 600), Guests (700s) and non-defined (999) are
	* not counted
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen age = sdem_eda
	replace age = . if sdem_eda == 99
	replace age = . if sdem_eda == 99
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = sdem_sex
	recode male 2=0
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen relationharm = .
	replace relationharm = 1 if sdem_par_c == 101
	replace relationharm = 2 if sdem_par_c == 201
	replace relationharm = 5 if inrange(sdem_par_c, 202, 204) // Other partners, not spouse
	replace relationharm = 3 if inrange(sdem_par_c, 301, 304)
	replace relationharm = 4 if inrange(sdem_par_c, 401, 402)
	replace relationharm = 5 if inrange(sdem_par_c, 403, 423)
	replace relationharm = 6 if inrange(sdem_par_c, 501, 999) 
	
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives", replace
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = sdem_par_c
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital = sdem_e_con
	recode marital 1=3 2=4 3=4 4=5 5=1 6=2 9=.
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	gen eye_dsablty = .
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty = .
	label var eye_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty = .
	label var eye_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord = .
	label var eye_dsablty "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty  = .
	label var eye_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty = .
	label var eye_dsablty "Disability related to communicating"
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
	gen byte school = sdem_cs_p17
	recode school (2 = 0) (9 = .)
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen byte literacy = sdem_cs_p12
	recode literacy (2 = 0) (9 = .)
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
  * No Education and Pre-Primary OR Primary with Zero Years
  gen byte educy = 0 if (sdem_cs_p13_1 == 0 | sdem_cs_p13_1 == 1) /// 
  | (sdem_cs_p13_1 == 2 & sdem_cs_p13_2 == 0)

  * Primary School
  replace educy=1 if sdem_cs_p13_1==2 & sdem_cs_p13_2==1
  replace educy=2 if sdem_cs_p13_1==2 & sdem_cs_p13_2==2
  replace educy=3 if sdem_cs_p13_1==2 & sdem_cs_p13_2==3
  replace educy=4 if sdem_cs_p13_1==2 & sdem_cs_p13_2==4
  replace educy=5 if sdem_cs_p13_1==2 & sdem_cs_p13_2==5
  replace educy=6 if sdem_cs_p13_1==2 & sdem_cs_p13_2>=6 & sdem_cs_p13_2!=.

  * Carrera Tecnica con antecedente Primaria OR Primaria 
  replace educy=7 if ((sdem_cs_p13_1==6 & sdem_cs_p15==1) | sdem_cs_p13_1==3) & sdem_cs_p13_2==1
  replace educy=8 if ((sdem_cs_p13_1==6 & sdem_cs_p15==1) | sdem_cs_p13_1==3) & sdem_cs_p13_2==2
  replace educy=9 if ((sdem_cs_p13_1==6 & sdem_cs_p15==1) | sdem_cs_p13_1==3) & sdem_cs_p13_2>=3 & sdem_cs_p13_2!=.

  * Normal con Antecedente Primaria
  replace educy=7 if (sdem_cs_p13_1==5 & sdem_cs_p15==1) & sdem_cs_p13_2==1
  replace educy=8 if (sdem_cs_p13_1==5 & sdem_cs_p15==1) & sdem_cs_p13_2==2
  replace educy=9 if (sdem_cs_p13_1==5 & sdem_cs_p15==1) & sdem_cs_p13_2>=3 & sdem_cs_p13_2!=.

  * Prepa OR Carrera Tecnica con antecedente secundaria 
  * + años de escolaridad
  replace educy=10 if (sdem_cs_p13_1==4 | (sdem_cs_p13_1==6 & sdem_cs_p15==2)) & sdem_cs_p13_2==1
  replace educy=11 if (sdem_cs_p13_1==4 | (sdem_cs_p13_1==6 & sdem_cs_p15==2)) & sdem_cs_p13_2==2
  replace educy=12 if (sdem_cs_p13_1==4 | (sdem_cs_p13_1==6 & sdem_cs_p15==2)) & sdem_cs_p13_2>=3 & sdem_cs_p13_2!=.

  * NORMAL con Antecedente Secundaria
  replace educy=10 if (sdem_cs_p13_1==5 & sdem_cs_p15==2) & sdem_cs_p13_2==1
  replace educy=11 if (sdem_cs_p13_1==5 & sdem_cs_p15==2) & sdem_cs_p13_2==2
  replace educy=12 if (sdem_cs_p13_1==5 & sdem_cs_p15==2) & sdem_cs_p13_2==3
  replace educy=13 if (sdem_cs_p13_1==5 & sdem_cs_p15==2) & sdem_cs_p13_2>=4 & sdem_cs_p13_2!=.
    
  * Profesional without any years
  replace educy=12 if ((sdem_cs_p13_1==7 & sdem_cs_p13_2==0))
    
  * Profesional con antecedente bachillerato
  replace educy=13 if (sdem_cs_p13_1==7 & sdem_cs_p15==3)  & sdem_cs_p13_2==1  
  replace educy=14 if (sdem_cs_p13_1==7 & sdem_cs_p15==3)  & sdem_cs_p13_2==2  
  replace educy=15 if (sdem_cs_p13_1==7 & sdem_cs_p15==3)  & sdem_cs_p13_2==3  
  replace educy=16 if (sdem_cs_p13_1==7 & sdem_cs_p15==3)  & sdem_cs_p13_2==4
  replace educy=17 if (sdem_cs_p13_1==7 & sdem_cs_p15==3)  & sdem_cs_p13_2>=5 & sdem_cs_p13_2!=.

  * Carrera Tecnica con Antecedente Preparatoria 
  replace educy=13 if (sdem_cs_p13_1==6 & sdem_cs_p15==3) & sdem_cs_p13_2==1
  replace educy=14 if (sdem_cs_p13_1==6 & sdem_cs_p15==3) & sdem_cs_p13_2==2
  replace educy=15 if (sdem_cs_p13_1==6 & sdem_cs_p15==3) & sdem_cs_p13_2>=3 & sdem_cs_p13_2!=. 

  * NORMAL con antecedente Preparatoria
  replace educy=13 if (sdem_cs_p13_1==5 & sdem_cs_p15==3) & sdem_cs_p13_2==1
  replace educy=14 if (sdem_cs_p13_1==5 & sdem_cs_p15==3) & sdem_cs_p13_2==2
  replace educy=15 if (sdem_cs_p13_1==5 & sdem_cs_p15==3) & sdem_cs_p13_2==3
  replace educy=16 if (sdem_cs_p13_1==5 & sdem_cs_p15==3) & sdem_cs_p13_2==4
  replace educy=17 if (sdem_cs_p13_1==5 & sdem_cs_p15==3) & sdem_cs_p13_2>=5 & sdem_cs_p13_2!=.

  * Maestria
  replace educy=18 if sdem_cs_p13_1==8 & sdem_cs_p13_2==1
  replace educy=19 if sdem_cs_p13_1==8 & sdem_cs_p13_2>=2 & sdem_cs_p13_2!=.

  * Doctorado
  replace educy=18 if (sdem_cs_p13_1==9 & sdem_cs_p13_2==1)
  replace educy=19 if (sdem_cs_p13_1==9 & sdem_cs_p13_2==2)	
  replace educy=20 if (sdem_cs_p13_1==9 & sdem_cs_p13_2==3) 
  replace educy=21 if (sdem_cs_p13_1==9 & sdem_cs_p13_2==4)
  replace educy=22 if (sdem_cs_p13_1==9 & sdem_cs_p13_2>=5 & sdem_cs_p13_2!=.)

  * Missing and Zeros
  replace educy=0 if (sdem_cs_p13_1==0 | sdem_cs_p13_1==1) |(sdem_cs_p13_1==2 & sdem_cs_p13_2==0)
  replace educy=. if (sdem_cs_p13_1==99 | sdem_cs_p13_2==9 | sdem_cs_p15==9)
  replace educy=. if age<ed_mod_age & age!=.
  label var educy "Years of education"
*</_educy_>


*<_educat7_>
	*gen byte educat7 =
	gen byte educat7=1 if educy==0
	replace educat7=2 if sdem_cs_p13_1==2
	replace educat7=3 if educy==6 & sdem_cs_p13_1==2
	replace educat7=4 if inrange(sdem_cs_p13_1,3,4)
	replace educat7=5 if educy==12 & sdem_cs_p13_1==4
	replace educat7=6 if inrange(sdem_cs_p13_1,5,6)
	replace educat7=7 if inrange(sdem_cs_p13_1,7,9)
	replace educat7=. if age<ed_mod_age & age!=.
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
	recode educat4 (2 3 4=2) (5=3) (6 7=4 )
	label var educat4 "Level of education 3"
	la de lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 lbleducat4
*</_educat4_>

*<_educat_orig_>
	gen educat_orig = .
	label var educat_orig "Original survey education code"
	*Note: The ENOE uses the national education classification which needs two variables
	*sdem_cs_p13_1 (school level) & sdem_cs_p13_2(years  in school) to create one measurement of
	*education level as a result there is no unique variable that
	*translate to educat_orig. See documentation references for more details.
*</_educat_orig_>

*<_educat_isced_>
	gen educat_isced = .
	label var educat_isced "ISCED standardised level of education"
*</_educat_isced_>


*----------6.1: Education cleanup------------------------------*

*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
local ed_var "school literacy educy educat7 educat5 educat4 educat_isced"
foreach v of local ed_var {
	replace `v'=. if ( age < ed_mod_age & !missing(age) )
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
	label var vocational_length_l "Length of training, lower limit"
*</_vocational_length_l_>

*<_vocational_length_u_>
	gen vocational_length_u = .
	label var vocational_length_u "Length of training, upper limit"
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
	gen byte minlaborage = 12
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>

	gen byte lstatus=1 if inlist(coe1_p1,1,2) | coe1_p1a1==1 | coe1_p1a2==2 ///
	| coe1_p1b==1 | inrange(coe1_p1c,1,4) | coe1_p1d==1 | coe1_p1e==1
	replace lstatus=2 if (coe1_p2_1==1 | coe1_p2_2==2 | coe1_p2_3==3)
	replace lstatus=3 if coe1_p2_4==4
	replace lstatus=. if age < minlaborage & age != .
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = .
	replace potential_lf=1 if lstatus==3
	replace potential_lf = . if age < minlaborage & age != .
	replace potential_lf = 0 if lstatus != 3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen byte underemployment = .
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason = coe1_p2e
	*Set the "don't know (9)" responses to missing
	recode nlfreason 3=1 2=3 4=2 5=4 1=5 6=5 9=.
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"
	label values unempldur_l lblune
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"
	label values unempldur_u lblune_2
*</_unempldur_u_>

}


*----------8.2: 7 day reference main job------------------------------*


{
	
*<_empstat_>
	gen empstat = .

	* Employee if doesn't work on their own (p3b is 2 or missing), gets pay
	replace empstat = 1 if inlist(coe1_p3b,.,2) & coe1_p3h == 1

	* Non paid employee if as above, yet no pay
	replace empstat = 2 if inlist(coe1_p3b,.,2) & inrange(coe1_p3h,2,3)

	* Employer works own account, has employees they pay (3G1_1 = 1) 
	replace empstat = 3 if coe1_p3b == 1 & coe1_p3g1_1 == 1

	* Self employed works own account, has no paid employees
	replace empstat = 4 if coe1_p3b == 1 & coe1_p3g1_1 != 1
		
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec = .
	
	* Note that any "agropecuario" (agriculture and fishing) skips the questions
	
	* If activity is in private sector (4B = 4) o undetermined (4B = 5) 
	* yet independent or private (4C = 1|2)
	replace ocusec = 2 if (coe1_p4b == 4) | /// 
	(coe1_p4b == 5 & inrange(coe1_p4c, 1, 2))
	
	* If education/hospital (4B = 2) or public or non-profit (4B = 3), then 4D decides
	* Public: All options administered by government (4D1 == 1)
	replace ocusec = 1 if (inrange(coe1_p4b, 2, 3)) & coe1_p4d1 == 1 & inrange(coe1_p4d2,1,7)
	* Public Among not administered by government (4D1 == 2, public education, independent orgs (Election Commission), International Orgs
	replace ocusec = 1 if (inrange(coe1_p4b, 2, 3)) & coe1_p4d1 == 2 & inlist(coe1_p4d2,2,3,6)
	
	* Private: Not administered by gov, not the above
	replace ocusec = 2 if (inrange(coe1_p4b, 2, 3)) & coe1_p4d1 == 2 & inlist(coe1_p4d2,1,4,5,7)
	
	* In agriculture and not paid employee
	replace ocusec = 2 if coe1_p4b == 1 & inrange(empstat,2,4)
	
	* A lot of the people still undefined are classified in industry as house staff
	* industry_orig 8140. This we code as private sector 
	replace ocusec = 2 if mi(ocusec) & coe1_p4a == 8140
	
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig = coe1_p4a
	replace industry_orig = . if age < minlaborage & age != .
	replace industry_orig=. if lstatus!=1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	gen industrycat_isic= isic_1
	replace industrycat_isic="" if lstatus!=1
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	destring isic_1, gen(ind_helper) force
	replace ind_helper = floor(ind_helper/100)
	
	* Use IND Helper to create categories
	gen industrycat10 = .
	replace industrycat10 = 1  if inrange(ind_helper, 1, 3)
	replace industrycat10 = 2  if inrange(ind_helper, 5, 9)
	replace industrycat10 = 3  if inrange(ind_helper, 10, 33)
	replace industrycat10 = 4  if inrange(ind_helper, 35, 39)
	replace industrycat10 = 5  if inrange(ind_helper, 41, 43)
	replace industrycat10 = 6  if inrange(ind_helper, 45, 47) | inrange(ind_helper, 55, 56)
	replace industrycat10 = 7  if inrange(ind_helper, 49, 53) | inrange(ind_helper, 58, 63)
	replace industrycat10 = 8  if inrange(ind_helper, 64, 82)
	replace industrycat10 = 9  if inrange(ind_helper, 84, 84)
	replace industrycat10 = 10 if inrange(ind_helper, 85, 99)
	
	* Add in cases with letters
	replace industrycat10 = 1  if inlist(isic_1, "A") & mi(industrycat10)
	replace industrycat10 = 2  if inlist(isic_1, "B") & mi(industrycat10)
	replace industrycat10 = 3  if inlist(isic_1, "C") & mi(industrycat10)
	replace industrycat10 = 4  if inlist(isic_1, "D", "E") & mi(industrycat10)
	replace industrycat10 = 5  if inlist(isic_1, "F") & mi(industrycat10)
	replace industrycat10 = 6  if inlist(isic_1, "G", "I") & mi(industrycat10)
	replace industrycat10 = 7  if inlist(isic_1, "H", "J") & mi(industrycat10)
	replace industrycat10 = 8  if inlist(isic_1, "K", "L", "M", "N") & mi(industrycat10)
	replace industrycat10 = 9  if inlist(isic_1, "O") & mi(industrycat10)
	replace industrycat10 = 10 if inlist(isic_1, "P", "Q", "R", "S", "T", "U") & mi(industrycat10)
	
	replace industrycat10 = . if lstatus!=1
	drop ind_helper
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
*</_industrycat10_>


*<_industrycat4_>
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4 "1 digit industry classification (Broad Economic Activities), primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
	replace industrycat4=. if lstatus!=1
*</_industrycat4_>


*<_occup_orig_>
	gen occup_orig = coe1_p3
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_>
	destring isco_1, gen(occup_helper)
	gen byte occup = floor(occup_helper/1000)
	replace occup = 10 if occup == 0
	drop occup_helper
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
	replace occup = . if lstatus!=1
*</_occup_>


*<_occup_isco_>
	gen occup_isco = isco_1
	replace occup_isco = "" if lstatus!=1
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_skill_>
	gen occup_skill = .
	replace occup_skill = 1 if occup == 9
	replace occup_skill = 2 if inrange(occup, 4, 8)
	replace occup_skill = 3 if inrange(occup, 1, 3)
	replace occup_skill = . if lstatus != 1
	la de lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lbloccupskill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_wage_no_compen_>
	gen double wage_no_compen =.
	replace wage_no_compen = coe2_p6b2 if lstatus==1
	
	* There are also people who estimate their salary. We us the people in those
	* categories to estimate that of others. Note that there are two salary zones
	* so we need to run this twice
	
	foreach i of numlist 1/2 {
		
		preserve 
		
			* First store minimum salaries 
			summ sdem_salario if sdem_zona == `i'
			local min_sal_`i' `r(mean)'
			
			gen     salary_cat = .
			replace salary_cat = 1 if wage_no_compen < `min_sal_`i''
			replace salary_cat = 2 if wage_no_compen == `min_sal_`i''
			replace salary_cat = 3 if wage_no_compen > `min_sal_`i''   & wage_no_compen <= `min_sal_`i''*2
			replace salary_cat = 4 if wage_no_compen > `min_sal_`i''*2 & wage_no_compen <= `min_sal_`i''*3
			replace salary_cat = 5 if wage_no_compen > `min_sal_`i''*3 & wage_no_compen <= `min_sal_`i''*5
			replace salary_cat = 6 if wage_no_compen > `min_sal_`i''*5 & wage_no_compen <= `min_sal_`i''*10
			replace salary_cat = 7 if wage_no_compen > `min_sal_`i''*10 & !mi(wage_no_compen)
			
			* Collapse, prep data 
			collapse (p50) wage_no_compen, by(salary_cat)
			rename wage_no_compen salary_estimate
			rename salary_cat coe2_p6c
			gen sdem_zona = `i'
			
			* If first round, save; if second, append and save
			if `i' == 1 {
				
				tempfile wage_helper_1
				save "`wage_helper_1'"
			
			}
			
			else {
				
				append using "`wage_helper_1'"
				tempfile wage_helper
				save "`wage_helper'"
				
			}
			
			
		restore
		
	}
	
	merge m:1 coe2_p6c sdem_zona using "`wage_helper'", assert(match master) nogen
	
	* Now assign salary by category estimates with the medians of those in that category 
	replace wage_no_compen = salary_estimate if !mi(salary_estimate) & mi(wage_no_compen)
	
	* Assign minimum salary for those (very few, not in categories) who claim to get exactly
	* the minimum salary (coe2_p6c == 2)
	foreach i of numlist 1/2 {
		
		summ sdem_salario if sdem_zona == `i'
		local min_sal `r(mean)'
		replace wage_no_compen = `min_sal' if mi(wage_no_compen) & sdem_zona == `i' & coe2_p6c == 2
		
	}
	
	replace wage_no_compen = 0 if empstat==2
	replace wage_no_compen = . if lstatus!=1
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
	* Questionnaire has different options, but salary is already made to 
	* fit monthly
	gen byte unitwage = 5
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	replace unitwage = . if wage_no_compen==.
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	* Var differs if extended or basic questionnaire - 2020 ENOE only Q1 Extended
	* Generate unified vars - values differ if extended or basic survey
	gen hlp_whours_usual_bin = .
	*replace hlp_whours_usual_bin = coe1_p5c if inrange(quarter, 2, 4)
	replace hlp_whours_usual_bin = coe1_p5d /// if quarter == 1

	gen hlp_whours_lw = .
	*replace hlp_whours_lw = coe1_p5b_thrs if inrange(quarter, 2, 4)
	replace hlp_whours_lw = coe1_p5c_thrs /// if quarter == 1

	gen hlp_whours_nw = .
	*replace hlp_whours_nw = coe1_p5d_thrs if inrange(quarter, 2, 4)
	replace hlp_whours_nw = coe1_p5e_thrs /// if quarter == 1

	* Generate actual var
	gen whours = hlp_whours_lw
	*replace if not the usual hours in the week
	replace whours = hlp_whours_nw if hlp_whours_usual_bin == 2
	replace whours = . if lstatus != 1
	replace whours = . if inlist(whours, 0, 999)
	label var whours "Hours of work in last week primary job 7 day recall"
	drop hlp_whours_*
*</_whours_>


*<_wmonths_>
* Var changes if extended or basic questionnaire, unify - 2020 ENOE only Q1 Extended
foreach num of numlist 1/15 99 {
	
	gen hlp_wmonths_`num' = .
	*replace hlp_wmonths_`num' = 1 if !mi(coe1_p5f`num') & inrange(quarter, 2, 4)
	replace hlp_wmonths_`num' = 1 if !mi(coe1_p5g`num') /// & quarter == 1
	
}

	egen wmonths = rowtotal(hlp_wmonths_1 - hlp_wmonths_12), missing
	replace wmonths = 12 if hlp_wmonths_14 == 1
	replace wmonths = . if hlp_wmonths_13 == 1 | hlp_wmonths_15 == 1 | hlp_wmonths_99 == 1
	replace wmonths = . if lstatus!=1
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
	drop hlp_wmonths_*
*</_wmonths_>


*<_wage_total_>
/* <_wage_total>

	Use gross wages when available and net wages only when gross wages are not available.
	This is done to make it easy to compare earnings in formal and informal sectors.

</_wage_total> */
	gen double wage_total=.
	replace wage_total = (wage_no_compen)*wmonths
	replace wage_total = . if lstatus != 1 
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen byte contract=coe1_p3j
	recode contract 2=0 9=.
	replace contract=. if lstatus!=1
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
	gen byte socialsec = .
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec 1 "With social security" 0 "Without social secturity"
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen byte union = 1 if coe1_p3i == 1
	replace union  = 0 if coe1_p3i == 2
	replace union  = . if coe1_p3i == 9
	replace union  = . if lstatus != 1
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>


*<_firmsize_l_>

	gen byte firmsize_l = .
	replace firmsize_l =   1 if coe1_p3q == 1
	replace firmsize_l =   2 if coe1_p3q == 2
	replace firmsize_l =   6 if coe1_p3q == 3
	replace firmsize_l =  11 if coe1_p3q == 4
	replace firmsize_l =  16 if coe1_p3q == 5
	replace firmsize_l =  21 if coe1_p3q == 6
	replace firmsize_l =  31 if coe1_p3q == 7
	replace firmsize_l =  51 if coe1_p3q == 8
	replace firmsize_l = 101 if coe1_p3q == 9
	replace firmsize_l = 251 if coe1_p3q == 10
	replace firmsize_l = 501 if coe1_p3q == 11

	* Add self-employed
	replace firmsize_l = 1 if empstat == 4

	* Add employer
	replace firmsize_l =   2 if inrange(coe1_p3g_tot, 1, 4)
	replace firmsize_l =   6 if inrange(coe1_p3g_tot, 5, 9)
	replace firmsize_l =  11 if inrange(coe1_p3g_tot, 10, 14)
	replace firmsize_l =  16 if inrange(coe1_p3g_tot, 15, 19)
	replace firmsize_l =  21 if inrange(coe1_p3g_tot, 20, 29)
	replace firmsize_l =  31 if inrange(coe1_p3g_tot, 30, 49)
	replace firmsize_l =  51 if inrange(coe1_p3g_tot, 50, 99)
	replace firmsize_l = 101 if inrange(coe1_p3g_tot, 100, 249)
	replace firmsize_l = 251 if inrange(coe1_p3g_tot, 250, 499)
	replace firmsize_l = 501 if inrange(coe1_p3g_tot, 500, 999999)

	replace firmsize_l=. if lstatus!=1

	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u = .
	replace firmsize_u =   1 if coe1_p3q == 1
	replace firmsize_u =   5 if coe1_p3q == 2
	replace firmsize_u =  10 if coe1_p3q == 3
	replace firmsize_u =  15 if coe1_p3q == 4
	replace firmsize_u =  20 if coe1_p3q == 5
	replace firmsize_u =  30 if coe1_p3q == 6
	replace firmsize_u =  50 if coe1_p3q == 7
	replace firmsize_u = 100 if coe1_p3q == 8
	replace firmsize_u = 250 if coe1_p3q == 9
	replace firmsize_u = 500 if coe1_p3q==10
	replace firmsize_u =   . if coe1_p3q==11

	* Add self-employed
	replace firmsize_u = 1 if empstat == 4

	* Add employer
	replace firmsize_u = 5 if inrange(coe1_p3g_tot, 1, 4)
	replace firmsize_u = 10 if inrange(coe1_p3g_tot, 5, 9)
	replace firmsize_u = 15 if inrange(coe1_p3g_tot, 10, 14)
	replace firmsize_u = 20 if inrange(coe1_p3g_tot, 15, 19)
	replace firmsize_u = 30 if inrange(coe1_p3g_tot, 20, 29)
	replace firmsize_u = 50 if inrange(coe1_p3g_tot, 30, 49)
	replace firmsize_u = 100 if inrange(coe1_p3g_tot, 50, 99)
	replace firmsize_u = 250 if inrange(coe1_p3g_tot, 100, 249)
	replace firmsize_u = 500 if  inrange(coe1_p3g_tot, 250, 499)
	replace firmsize_u = . if inrange(coe1_p3g_tot, 500, 999999)

	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen byte empstat_2 = coe2_p7
	recode empstat_2 (4 5 = 1) (6 = 2) (1 2 3 = 4) (7 9 = .)
	replace empstat_2 = . if lstatus!=1
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2 = .
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2 = coe2_p7c
	replace industry_orig_2 = . if mi(empstat_2)
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	gen industrycat_isic_2 = isic_2
	replace industrycat_isic_2 = "" if mi(empstat_2)
	label var industrycat_isic_2 "ISIC code of primary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	destring isic_2, gen(ind_helper) force
	replace ind_helper = floor(ind_helper/100)
	
	* Use IND Helper to create categories
	gen industrycat10_2 = .
	replace industrycat10_2 = 1  if inrange(ind_helper, 1, 3)
	replace industrycat10_2 = 2  if inrange(ind_helper, 5, 9)
	replace industrycat10_2 = 3  if inrange(ind_helper, 10, 33)
	replace industrycat10_2 = 4  if inrange(ind_helper, 35, 39)
	replace industrycat10_2 = 5  if inrange(ind_helper, 41, 43)
	replace industrycat10_2 = 6  if inrange(ind_helper, 45, 47) | inrange(ind_helper, 55, 56)
	replace industrycat10_2 = 7  if inrange(ind_helper, 49, 53) | inrange(ind_helper, 58, 63)
	replace industrycat10_2 = 8  if inrange(ind_helper, 64, 82)
	replace industrycat10_2 = 9  if inrange(ind_helper, 84, 84)
	replace industrycat10_2 = 10 if inrange(ind_helper, 85, 99)
	
	* Add in cases with letters
	replace industrycat10_2 = 1  if inlist(isic_1, "A") & mi(industrycat10_2)
	replace industrycat10_2 = 2  if inlist(isic_1, "B") & mi(industrycat10_2)
	replace industrycat10_2 = 3  if inlist(isic_1, "C") & mi(industrycat10_2)
	replace industrycat10_2 = 4  if inlist(isic_1, "D", "E") & mi(industrycat10_2)
	replace industrycat10_2 = 5  if inlist(isic_1, "F") & mi(industrycat10_2)
	replace industrycat10_2 = 6  if inlist(isic_1, "G", "I") & mi(industrycat10_2)
	replace industrycat10_2 = 7  if inlist(isic_1, "H", "J") & mi(industrycat10_2)
	replace industrycat10_2 = 8  if inlist(isic_1, "K", "L", "M", "N") & mi(industrycat10_2)
	replace industrycat10_2 = 9  if inlist(isic_1, "O") & mi(industrycat10_2)
	replace industrycat10_2 = 10 if inlist(isic_1, "P", "Q", "R", "S", "T", "U") & mi(industrycat10_2)
	
	replace industrycat10_2 = . if mi(empstat_2)
	drop ind_helper
	label values industrycat10_2 lblindustrycat10
*</_industrycat10_2_>


*<_industrycat4_2_>
	gen byte industrycat4_2 = industrycat10_2
	recode industrycat4_2 (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label var industrycat4_2 "1 digit industry classification (Broad Economic Activities), secondary job 7 day recall"
	label values industrycat4_2 lblindustrycat4
*</_industrycat4_2_>


*<_occup_orig_2_>
	gen occup_orig_2 = coe2_p7a
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen occup_isco_2 = isco_2
	replace occup_isco_2 = "" if mi(empstat_2)
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>

*<_occup_2_>
	destring isco_2, gen(occup_helper_2)
	gen byte occup_2 = floor(occup_helper_2/1000)
	replace occup = 10 if occup == 0
	drop occup_helper_2
	label var occup_2 "1 digit occupational classification secondary job 7 day recall"
	label values occup_2 lbloccup
*</_occup_2_>


*<_occup_skill_2_>
	gen occup_skill_2 = .
	replace occup_skill_2 = 1 if occup_2 == 9
	replace occup_skill_2 = 2 if inrange(occup_2, 4, 8)
	replace occup_skill_2 = 3 if inrange(occup_2, 1, 3)
	replace occup_skill_2 = . if mi(empstat_2)
	label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
	label values occup_skill_2 lbloccupskill
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
	* Only in extended survey. Since this has only Q1, OK to do
	gen byte firmsize_l_2 = .
	replace firmsize_l_2 =   1 if coe2_p7e == 1
	replace firmsize_l_2 =   2 if coe2_p7e == 2
	replace firmsize_l_2 =   6 if coe2_p7e == 3
	replace firmsize_l_2 =  11 if coe2_p7e == 4
	replace firmsize_l_2 =  16 if coe2_p7e == 5
	replace firmsize_l_2 =  21 if coe2_p7e == 6
	replace firmsize_l_2 =  31 if coe2_p7e == 7
	replace firmsize_l_2 =  51 if coe2_p7e == 8
	replace firmsize_l_2 = 101 if coe2_p7e == 9
	replace firmsize_l_2 = 251 if coe2_p7e == 10
	replace firmsize_l_2 = 501 if coe2_p7e == 11

	* Add self-employed
	replace firmsize_l_2 = 1 if empstat_2 == 4
	replace firmsize_l_2 = . if mi(empstat_2)
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>

	gen byte firmsize_u_2 = .
	replace firmsize_u_2 =   1 if coe2_p7e == 1
	replace firmsize_u_2 =   5 if coe2_p7e == 2
	replace firmsize_u_2 =  10 if coe2_p7e == 3
	replace firmsize_u_2 =  15 if coe2_p7e == 4
	replace firmsize_u_2 =  20 if coe2_p7e == 5
	replace firmsize_u_2 =  30 if coe2_p7e == 6
	replace firmsize_u_2 =  50 if coe2_p7e == 7
	replace firmsize_u_2 = 100 if coe2_p7e == 8
	replace firmsize_u_2 = 250 if coe2_p7e == 9
	replace firmsize_u_2 = 500 if coe2_p7e == 10
	replace firmsize_u_2 =   . if coe2_p7e == 11

	* Add self-employed
	replace firmsize_u_2 = 1 if empstat_2 == 4
	replace firmsize_u_2=. if mi(empstat_2)
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
	label var t_wage_nocompen_others "Annualized wage in all but primary & secondary jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_others_>


*<_t_wage_others_>
	gen t_wage_others = .
	label var t_wage_others "Annualized wage in all but primary and secondary jobs (12-mon ref period)"
*</_t_wage_others_>


*----------8.5: 7 day reference total summary------------------------------*


*<_t_hours_total_>
/* approximate hours worked in a year 48 ILO standard */
	gen t_hours_total =(whours*4)*wmonths
	label var t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
	gen t_wage_nocompen_total = wage_total
	label var t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
	gen t_wage_total = t_wage_nocompen_total
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
	label var ocusec_year "Sector of activity primary job 12 day recall"
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
	label var industrycat4_year "1 digit industry classification (Broad Economic Activities), primary job 12 month recall"
	la de lblindustrycat4_year 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4_year lblindustrycat4_year
*</_industrycat4_year_>


*<_occup_orig_year_>
	gen occup_orig_year = .
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	gen occup_isco_year = .
	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_skill_year_>
	gen occup_skill_year = .
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
	gen wage_total_year = wage_total
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
	label var ocusec_2_year "Sector of activity secondary job 12 day recall"
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
	label var industrycat4_2_year "1 digit industry classification (Broad Economic Activities), secondary job 12 month recall"
	label values industrycat4_2_year lblindustrycat4_year
*</_industrycat4_2_year_>


*<_occup_orig_2_year_>
	gen occup_orig_2_year = .
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
	gen occup_isco_2_year = .
	label var occup_isco_2_year "ISCO code of secondary job 12 month recall"
*</_occup_isco_2_year_>


*<_occup_skill_2_year_>
	gen occup_skill_2_year = .
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


*<_t_hours_others_year_>
	gen t_hours_others_year = .
	label var t_hours_others_year "Annualized hours worked in all but primary and secondary jobs 12 month recall"
*</_t_hours_others_year_>

*<_t_wage_nocompen_others_year_>
	gen t_wage_nocompen_others_year = .
	label var t_wage_nocompen_others_year "Annualized wage in all but primary & secondary jobs excl. bonuses, etc. 12 month recall)"
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
	gen t_wage_nocompen_total_year = wage_total
	label var t_wage_nocompen_total_year "Annualized wage in all jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_total_year_>


*<_t_wage_total_year_>
	gen t_wage_total_year = wage_total
	label var t_wage_total_year "Annualized total wage for all jobs 12 month recall"
*</_t_wage_total_year_>


*----------8.11: Overall across reference periods------------------------------*


*<_njobs_>
	gen njobs = sdem_t_tra
	replace njobs = 1 if njobs == 0 & lstatus == 1
	replace njobs = . if lstatus != 1
	label var njobs "Total number of jobs"
*</_njobs_>


*<_t_hours_annual_>
	gen t_hours_annual = t_hours_total
	label var t_hours_annual "Total hours worked in all jobs in the previous 12 months"
*</_t_hours_annual_>


*<_linc_nc_>
	gen linc_nc = wage_total
	label var linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."
*</_linc_nc_>


*<_laborincome_>
	gen laborincome = wage_total
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

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

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
