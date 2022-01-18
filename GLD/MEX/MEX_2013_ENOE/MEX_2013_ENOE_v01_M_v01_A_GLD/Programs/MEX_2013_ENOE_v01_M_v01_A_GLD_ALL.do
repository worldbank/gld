
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				[MEX_2013_ENOE_V01_M_V01_A_GLD_ALL.do] </_Program name_>
<_Application_>					[STATA] <_Application_>
<_Author(s)_>					[The World Bank Jobs Group] </_Author(s)_>
<_Date created_>				2021-04-01 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						[Mexico (MEX)] </_Country_>
<_Survey Title_>				[Encuesta Nacional de Ocupación y Empleo] </_Survey Title_>
<_Survey Year_>					[2013] </_Survey Year_>
<_Study ID_>					[Microdata Library ID if present] </_Study ID_>
<_Data collection from_>		[01/2013] </_Data collection from_>
<_Data collection to_>			[05/2013] </_Data collection to_>
<_Source of dataset_> 			[Mexico NSO] </_Source of dataset_>
<_Sample size (HH)_> 			[103,658] </_Sample size (HH)_>
<_Sample size (IND)_> 			[385,658] </_Sample size (IND)_>
<_Sampling method_> 			[ El tipo de muestreo utilizado es probabilístico, bietápico, estratificado y por conglomerados.] </_Sampling method_>
<_Geographic coverage_> 		[Los niveles geograficos usados en la encuesta de México comienzan en estados siguen con ciudades autorrepresentadas y terminan con municipios de las ciudades autorrepresentadas. https://www.inegi.org.mx/contenidos/productos/prod_serv/contenidos/espanol/bvinegi/productos/metodologias/est/cobertura.pdf] </_Geographic coverage_>
<_Currency_> 					[Pesos] </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				[ICLS-18] </_ICLS Version_>
<_ISCED Version_>				[ISCED 2011] </_ISCED Version_>
<_ISCO Version_>				[ISCO 2008] </_ISCO Version_>
<_OCCUP National_>				[Sinco 11] </_OCCUP National_>
<_ISIC Version_>				[Rev.4 ] </_ISIC Version_>
<_INDUS National_>				[SCIAN 2007] </_INDUS National_>

-----------------------------------------------------------------------
<_Version Control_>

* Date: [2021-04-D1] - [Check code and input variables]
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

* All steps necessary to merge dataset
local path_in "Z:\GLD-Harmonization\582018_AQ\MEX\MEX_2013_ENOE\MEX_2013_ENOE_V01_M\Data\Stata"
local path_output "Z:\GLD-Harmonization\582018_AQ\MEX\MEX_2013_ENOE\MEX_2013_ENOE_V01_M_V01_A_GLD\Data\Harmonized"

*----------1.3: Database assembly-------------------s (if several) to have all elements needed to produce
* harmonized output in a single file
		use "`path_in'\COE1T113.dta", clear
	tostring (ent v_sel n_ren), gen(ent_str v_sel_str n_ren_str) format("%02.0f")
	tostring con, gen(con_str) format("%05.0f")
	tostring (n_hog h_mud), gen(n_hog_str h_mud_str) format("%01.0f")

	egen person = concat(ent_str con_str v_sel_str n_hog_str h_mud_str n_ren_str)
	tempfile mex_ind
	save `mex_ind'

	use "`path_in'\COE2T113.dta", clear
	tostring (ent v_sel n_ren), gen(ent_str v_sel_str n_ren_str) format("%02.0f")
	tostring con, gen(con_str) format("%05.0f")
	tostring (n_hog h_mud), gen(n_hog_str h_mud_str) format("%01.0f")


	egen person = concat(ent_str con_str v_sel_str n_hog_str h_mud_str n_ren_str)

	* Merge with COE1, make sure all match through assert
	merge 1:1 person using `mex_ind', assert(match) nogen

	* Drop non finished interviews
	drop if r_def != 0


	* Overwrtwrite temp file
	tempfile mex_ind
	save `mex_ind'


	use "`path_in'\SDEMT113.dta", clear
	tostring (ent v_sel n_ren), gen(ent_str v_sel_str n_ren_str) format("%02.0f")
	tostring con, gen(con_str) format("%05.0f")
	tostring (n_hog h_mud), gen(n_hog_str h_mud_str) format("%01.0f")

	egen person = concat(ent_str con_str v_sel_str n_hog_str h_mud_str n_ren_str)

	drop if r_def != 0
	drop if !missing(cs_ad_mot)

	* Merge with COE1 & COE2 files, assert match (for 12 and over) or master (for younger)
	merge 1:1 person using `mex_ind', assert(match master) nogen

	* Create HH level for merging with that information
	egen casa_long = concat(ent_str con_str v_sel_str n_hog_str h_mud_str)
	egen casa_short = concat(ent_str con_str v_sel_str)

	* Overwrtwrite temp file
	tempfile mex_ind
	save `mex_ind'



	use "`path_in'\VIVT113.dta",clear
	drop p1-p3

	tostring (ent v_sel), gen(ent_str v_sel_str) format("%02.0f")
	tostring con, gen(con_str) format("%05.0f")

	egen casa_short = concat(ent_str con_str v_sel_str)

	* Merge with Individual files, keep only what matches
	merge 1:m casa_short using `mex_ind', keep(match) nogen

	* Overwrtwrite temp file
	tempfile mex_ind
	save `mex_ind'


	use "`path_in'\HOGT113.dta", clear

	tostring (ent v_sel), gen(ent_str v_sel_str) format("%02.0f")
	tostring con, gen(con_str) format("%05.0f")
	tostring n_hog h_mud, gen(n_hog_str h_mud_str) format("%01.0f")

	egen casa_long = concat(ent_str con_str v_sel_str n_hog_str h_mud_str)

	* Merge with Individual files, keep only what matches
	merge 1:m casa_long using `mex_ind', keep(match) nogen


	*the harmonization is for the first three months of the year , any other month will be put to missing.
	tab d_mes
	replace d_mes=. if d_mes == 4 | d_mes == 5 | d_mes == 12
	tab d_mes, missing

*ISIC
***first job
	rename scian scian_orig
	tostring p4a, gen(scian)
	merge m:1 scian using "Z:\GLD-Harmonization\582018_AQ\MEX\MEX_2013_ENOE\MEX_2013_ENOE_V01_M\Data\Stata\SCIAN_07_ISIC_4.dta", keep(master match) nogen
*Note: rename necessary to allow for the second job code to generate a new cmo for the merge
	rename scian scian_1
	rename isic isic_1
***second job
	tostring p7c, gen(scian)
	merge m:1 scian using "Z:\GLD-Harmonization\582018_AQ\MEX\MEX_2013_ENOE\MEX_2013_ENOE_V01_M\Data\Stata\SCIAN_07_ISIC_4.dta", keep(master match) nogen
*Note: rename necessary to misinterpret scian
	rename scian scian_2
	rename isic isic_2

*ISCO

*Note: the dta. 2013- onwards have in var p3 observations already converted to Sinco from CMO, no  need of conversion.

***then first job
	tostring p3, gen(sinco)
	merge m:1 sinco using "Z:\GLD-Harmonization\582018_AQ\MEX\MEX_2013_ENOE\MEX_2013_ENOE_V01_M\Data\Stata\SINCO_11_ISCO_08.dta", keep(master match) nogen
*Note: rename necessary to allow for the second job code to generate a new cmo for the merge
	rename sinco sinco_1
	rename isco isco_1

***then second job
	tostring p7a, gen(sinco)
	merge m:1 sinco using "Z:\GLD-Harmonization\582018_AQ\MEX\MEX_2013_ENOE\MEX_2013_ENOE_V01_M\Data\Stata\SINCO_11_ISCO_08.dta", keep(master match) nogen
*Note: rename necessary to misinterpret cmo
	rename sinco sinco_2
	rename isco isco_2



/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode="MEX"
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
	gen icls_v = "ICLS-18"
	label var icls_v "ICLS version(s) underlying questionnaire questions"
*</_icls_v_>

*<_isced_version_>
	gen isced_version = "isced_2011"
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>

*<_isco_version_>
	gen isco_version = "isco_2008"
	label var isco_version "Version of ISCO used"
*</_isco_version_

*<_isic_version_>
	gen isic_version = "isic_4"
	label var isic_version "Version of ISIC used"


*<_year_>
	gen int year = 2013
	label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen str3 vermast = "v01"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen veralt = "v01"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen harmonization = "GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	gen int_year=2013
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen  int_month = d_mes
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"

	*check int_Month out of the Q1
	tab int_month

*</_int_month_>


*<_hhid_>
/* <_hhid_note>

	The variable should be a string made up of the elements to define it, that is psu code, ssu, ...
	Each element should always be as long as needed for the longest element. That is, if there are
	60 psu coded 1 through 60, codes should be 01, 02, ..., 60. If there are 160 it should be 001,
	002, ..., 160.

</_hhid_note> */
	egen hhid=concat(ent_str con_str v_sel_str n_hog_str h_mud_str)
	label var hhid "Household ID"
	assert !missing(hhid)
*</_hhid_>


*<_pid_>
	egen  pid = concat(hhid n_ren_str)
	label var pid "Individual ID"
	isid hhid pid
*</_pid_>


*<_weight_>
	gen weight = fac
	label var weight "Household sampling weight"
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
	gen strata = est_d
	label var strata "Strata"
*</_strata_>


*<_wave_>
	gen wave = "Q1"
	label var wave "Survey wave"
*</_wave_>

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

/* <_subnatid1>

	Labels are to be defined as # - Name like 1 "1 - Alaska" 2 "2 - Arkansas".

</_subnatid1> */
*states
	gen byte subnatid1 =ent
	label de lblsubnatid1 1 "1 - Aguas Calientes" 2 "2 - Baja California" 3 "3 - Baja California Sur" 4 " 4 - Campeche" 5 " 5 - Chiapas" 6 "6 - Chihuahua" 7 "7 - Coahuila de Zaragoza" 8 "8 - Colima" 9 "9 - Distrito Federal" 10 " 10 - Durango " 11 " 11- Guanajuato " 12 " 12 - Guerrero" 13 "13 - Hidalgo " 14 " 14 -Jalisco " 15 " 15 - Michoacan de Ocampo " 16 " 16 - Morelos " 17 " 17 - Mexico " 18 " 18 - Nayarit " 19 " 19 - Nuevo León " 20 " 20 - Oaxaca " 21 " 21 - Puebla" 22 " 22 - Queretaro" 23 " 23 - Quintana Roo " 24 " 24 - San Luis Potosi" 25 " 25- Sinaloa " 26 " 26 - Sonora " 27 " 27 - Tabasco " 28 " 28 - Tamaulipas" 29 " 29 - Tlaxcala " 30 " 30 - Veracruz de Ignacio de la Llave " 31 " 31 - Yucatán " 32 " 32 - Zacatecas "
	label values subnatid1 lblsubnatid1
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
*selected main cities from states
	gen byte subnatid2 = cd_a
	label de lblsubnatid2 1 "1 - Mexico" 2 " 2- Guadalajara" 3 " 3 - Monterrey" 4 " 4- Puebla" 5 " 5 - Leon" 7 " 6 - San Luis Potosi" 8 " 7 - Merida" 9 " 8 - Chihuahua" 10 " 9- Tampico" 12 " 10 - Veracruz" 13 " 11 - Acapulco" 14 " 12 - Aguacalientes" 15 " 13 - Morelia " 16 " 14 - Toluca" 17 " 15 - Saltillo" 18 " 16 - Villahermosa" 19 " 17 - Tuxtla Gutierrez" 21 " 18 - Tijuana" 24 " 19 - Culiacan" 25 " 20 - Hermosillo" 26 " 21 - Durango" 27 " 22 - Tepic" 28 " 23 - Campeche" 29 " 24 - Cuernavaca" 31 " 25 - Oaxaca" 32 " 26 - Zacatecas " 33 " 27 - Colima" 36 " 28 - Queretaro" 39 " 29 - Tlaxcala" 40 " 30 - La Paz " 41 " 31 - Cancun" 43 " 32 - Pachuca" 81 "  33 - Complemento Urbano Rural"
	recode subnatid2 82/86=81
	label values subnatid2 lblsubnatid2
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
*selected towns within selected cities from states
	gen byte subnatid3 = loc
	*label de lblsubnatid3 1 "1 - Name"
	*label values subnatid3 lblsubnatid3
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
	gen subnatidsurvey = "subnatid3"
	*tostring subnatidsurvey, replace
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
	bysort hhid: gen hsize=_N if par_c<400 | inrange(par_c,600,699)
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen age = eda
replace age = . if eda == 99
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = sex
	recode male 2=0
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen relationharm = floor(par_c/100)
	recode relationharm 6=5 4/5 7=6 9=.
	replace relationharm=4 if par_c==601
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
	by hhid, sort: egen head_count=total(relationharm==1)
	replace relationharm=1 if head_count!=1 & relationharm==2
	replace head_count=1 if relationharm==1
	bysort hhid (age): egen max_age=max(age) if head_count==0
	*as per the survey min age for labour being 15
	replace relationharm=1 if age==max_age & head_count!=1 & relationharm!=1 & relationharm!=3 & age>15
	replace head_count=1 if relationharm==1
	*there is a problem with hh being children under 15 in Q1 (the number of households affected is rather small)
	drop head_count max_age


*</_relationharm_>


*<_relationcs_>
	gen relationcs = floor(par_c/100)
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital = e_con
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

Education module is only asked to those XX and older.

</_ed_mod_age_note> */

gen byte ed_mod_age = 5
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school=cs_p17
	recode school 2=0 9=.
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen byte literacy = cs_p12
	recode literacy 2=0 9=.
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
*note that this variable is not built based on lstatus
	gen byte educy =0 if (cs_p13_1==0 | cs_p13_1==1) | (cs_p13_1==2 & cs_p13_2==0)
	replace educy=1 if cs_p13_1==2 & cs_p13_2==1
	replace educy=2 if cs_p13_1==2 & cs_p13_2==2
	replace educy=3 if cs_p13_1==2 & cs_p13_2==3
	replace educy=4 if cs_p13_1==2 & cs_p13_2==4
	replace educy=5 if cs_p13_1==2 & cs_p13_2==5
	replace educy=6 if cs_p13_1==2 & cs_p13_2==6
	replace educy=7 if ((cs_p13_1==6 & cs_p15==1) | cs_p13_1==3) & cs_p13_2==1
	replace educy=8 if ((cs_p13_1==6 & cs_p15==1) | cs_p13_1==3) & cs_p13_2==2
	replace educy=9 if ((cs_p13_1==6 & cs_p15==1) | cs_p13_1==3) & inlist(cs_p13_2,3,6)
	replace educy=10 if (cs_p13_1==4 | (cs_p13_1==6 & cs_p15==2) | (cs_p13_1==5 & cs_p15==1) | (cs_p13_1==5 & cs_p15==2)) & cs_p13_2==1
	replace educy=11 if (cs_p13_1==4 | (cs_p13_1==6 & cs_p15==2) | (cs_p13_1==5 & cs_p15==1) | (cs_p13_1==5 & cs_p15==2)) & cs_p13_2==2
	replace educy=12 if ((cs_p13_1==4 | (cs_p13_1==6 & cs_p15==2) | (cs_p13_1==5 & cs_p15==1) | (cs_p13_1==5 & cs_p15==2)) & cs_p13_2==3) | ((cs_p13_1==7 & cs_p13_2==0))
	replace educy=13 if ((cs_p13_1==4 | (cs_p13_1==6 & cs_p15==2) | (cs_p13_1==5 & cs_p15==1) | (cs_p13_1==5 & cs_p15==2)) & cs_p13_2==4) | ((cs_p13_1==6 & cs_p15==2 & cs_p13_2==7)) | (((cs_p13_1==7 & cs_p15==3) | (cs_p13_1==5 & cs_p15==3) | (cs_p13_1==6 & cs_p15==3)) & cs_p13_2==1)
	replace educy=14 if ((cs_p13_1==4 | (cs_p13_1==6 & cs_p15==2) | (cs_p13_1==5 & cs_p15==1) | (cs_p13_1==5 & cs_p15==2)) & cs_p13_2==5) | (((cs_p13_1==7 & cs_p15==3) | (cs_p13_1==5 & cs_p15==3) | (cs_p13_1==6 & cs_p15==3)) & cs_p13_2==2)
	replace educy=15 if ((cs_p13_1==4 | (cs_p13_1==6 & cs_p15==2) | (cs_p13_1==5 & cs_p15==1) | (cs_p13_1==5 & cs_p15==2)) & cs_p13_2==6) | (((cs_p13_1==7 & cs_p15==3) | (cs_p13_1==5 & cs_p15==3) | (cs_p13_1==6 & cs_p15==3)) & cs_p13_2==3) | (((cs_p13_1==6 & cs_p15==3) & inlist(cs_p13_2,4,6)))
	replace educy=16 if ((cs_p13_1==7 & cs_p15==3) | (cs_p13_1==5 & cs_p15==3)) & cs_p13_2==4
	replace educy=17 if (((cs_p13_1==7 & cs_p15==3) | (cs_p13_1==5 & cs_p15==3)) & cs_p13_2==5) | (cs_p13_1==8 & cs_p13_2==1)
	replace educy=18 if (((cs_p13_1==7 & cs_p15==3) | (cs_p13_1==5 & cs_p15==3)) & cs_p13_2==6) | (cs_p13_1==8 & cs_p13_2==2)
	replace educy=19 if (((cs_p13_1==7 & cs_p15==3) | (cs_p13_1==5 & cs_p15==3)) & cs_p13_2==7) | (cs_p13_1==8 & inlist(cs_p13_2,3,8)) | (cs_p13_1==9 & cs_p13_2==1)
	replace educy=20 if (((cs_p13_1==7 & cs_p15==3) | (cs_p13_1==5 & cs_p15==3)) & cs_p13_2==8) | (cs_p13_1==9 & cs_p13_2==2)
	replace educy=21 if (cs_p13_1==9 & cs_p13_2==3) | ((cs_p13_1==9 & (cs_p13_2==7 & cs_p13_2==8)))
	replace educy=22 if cs_p13_1==9 & cs_p13_2==4
	replace educy=23 if cs_p13_1==9 & cs_p13_2==5
	replace educy=24 if cs_p13_1==9 & cs_p13_2==6
	replace educy=0 if (cs_p13_1==0 | cs_p13_1==1) |(cs_p13_1==2 & cs_p13_2==0)
	replace educy=. if (cs_p13_1==99 | cs_p13_2==9 | cs_p15==9)
	replace educy=. if age<ed_mod_age & age!=.
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	*gen byte educat7 =
	gen byte educat7=1 if educy==0
	replace educat7=2 if cs_p13_1==2
	replace educat7=3 if educy==6 & cs_p13_1==2
	replace educat7=4 if inrange(cs_p13_1,3,4)
	replace educat7=5 if educy==12 & cs_p13_1==4
	replace educat7=6 if inrange(cs_p13_1,5,6)
	replace educat7=7 if inrange(cs_p13_1,7,9)
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
	*cs_p13_1 (school level) & cs_p13_2(years  in school) to create one measurement of
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
	gen byte minlaborage = 15
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>

	gen byte lstatus=1 if inlist(p1,1,2) | p1a1==1 | p1a2==2 | p1b==1 | inrange(p1c,1,4) | p1d==1 | p1e==1
	replace lstatus=2 if (p2_1==1 | p2_2==2 | p2_3==3)
	replace lstatus=3 if p2_4==4
	replace lstatus=. if age<minlaborage & age!=.
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
	replace underemployment=1 if  p8a==1 | p8a==3
	replace underemployment = . if age < minlaborage & age != .
	**recode underemployment .=0
	replace underemployment=. if lstatus!=1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason=p2e
	*Set the "don't know (9)" responses to missing
	recode nlfreason 3=1 2=3 4=2 5=4 1=5 6=5 9=.
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>

	gen byte unempldur_l=.
	replace unempldur_l=1 if p2b==1
	replace unempldur_l=. if lstatus!=2
	la de lblune 1 "Hasta 1 mes"
	label var unempldur_l "Unemployment duration (months) lower bracket"
	label values unempldur_l lblune
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=.
	replace unempldur_u=1 if p2b==4
	replace unempldur_u=. if lstatus!=2
	la de lblune_2 1 "Más de 3 meses"
	label var unempldur_u "Unemployment duration (months) upper bracket"
	label values unempldur_u lblune_2
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte empstat=5
	replace empstat=1 if p3a==1 & p3h==1
	replace empstat=2 if p3a==2 & inlist(p3h,2,3)
	replace empstat=3 if p3b==1 & p3d==1
	replace empstat=4 if p3b==1 & p3d==2
	replace empstat=. if lstatus!=1
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec=2 if inlist(p4c,1,2)
	replace ocusec=1 if inrange(p4d2,1,6)
	replace ocusec=3 if p4d2==2
	replace ocusec=4 if p4d2==9
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig = p4a
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
		gen industrycat10= substr(industrycat_isic, 1,2)
	gen industrycat10_helper=.
	replace industrycat10_helper=1 if industrycat10=="01" | industrycat10=="02" | industrycat10=="03"
	replace industrycat10_helper=2 if industrycat10=="05" | industrycat10=="06" | industrycat10=="07" | industrycat10=="08"  | industrycat10=="09"
	replace industrycat10_helper=3 if industrycat10=="10" | industrycat10=="11" | industrycat10=="12"  |industrycat10=="13" | industrycat10=="14" | industrycat10=="15" | industrycat10=="16" | industrycat10=="17" | industrycat10=="18" | industrycat10=="19" | industrycat10=="20" | industrycat10=="21" | industrycat10=="22" | industrycat10=="23" | industrycat10=="24" | industrycat10=="25" | industrycat10=="26" | industrycat10=="27" | industrycat10=="28" | industrycat10=="29" | industrycat10=="30" | industrycat10=="31" | industrycat10=="32" | industrycat10=="33"
	replace industrycat10_helper=4 if industrycat10=="35" | industrycat10=="36" | industrycat10=="37" | industrycat10=="38" | industrycat10=="39"
	replace industrycat10_helper=5 if industrycat10=="41" | industrycat10=="42" | industrycat10=="43"
	replace industrycat10_helper=6 if industrycat10=="45" | industrycat10=="46" | industrycat10=="47" | industrycat10=="55"  | industrycat10=="56"
	replace industrycat10_helper=7  if  industrycat10=="49" | industrycat10=="50" | industrycat10=="51" | industrycat10=="52" | industrycat10=="53" | industrycat10=="58" | industrycat10=="59" | industrycat10=="60" |industrycat10=="61" | industrycat10=="62" | industrycat10=="63"
	replace industrycat10_helper=8 if industrycat10=="64" | industrycat10=="65" | industrycat10=="66" | industrycat10=="68" | industrycat10=="69"| industrycat10=="70" | industrycat10=="71" | industrycat10=="72" | industrycat10=="73" | industrycat10=="74" | industrycat10=="75" | industrycat10=="77" | industrycat10=="78" | industrycat10=="79" | industrycat10=="80" | industrycat10=="81" | industrycat10=="82"
	replace industrycat10_helper=9 if industrycat10=="84"
	replace industrycat10_helper=10 if industrycat10=="85" | industrycat10=="86" | industrycat10=="87" | industrycat10=="88" | industrycat10=="90" | industrycat10=="91" | industrycat10=="92" | industrycat10=="93" | industrycat10=="94" | industrycat10=="95" | industrycat10=="96" | industrycat10=="97" | industrycat10=="98" | industrycat10=="99"
	replace industrycat10_helper=. if lstatus!=1
	drop industrycat10
	rename industrycat10_helper industrycat10
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
	gen occup_orig = p3
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>

*<_occup_>
	destring isco_1, gen(occup_helper)
	gen byte occup = floor(occup_helper/1000)
	drop occup_helper
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>

*<_occup_isco_>
		gen occup_isco = isco_1
	replace occup_isco="" if lstatus!=1
	label var occup_isco "ISCO code of primary job 7 day recall"

*</_occup_isco_>

*<_occup_skill_>
	gen  occup_skill= substr(isco_1, 1,2)
	gen occup_skill_helper=.
	replace occup_skill_helper=1 if occup_skill=="10" |  occup_skill=="11" |  occup_skill=="12" |  occup_skill=="13" |  occup_skill=="14" | occup_skill=="20" | occup_skill=="21" | occup_skill=="22" | occup_skill=="23" | occup_skill=="24" | occup_skill=="26"| occup_skill=="23" | occup_skill=="30" | occup_skill=="31" | occup_skill=="32" | occup_skill=="33" | occup_skill=="34" | occup_skill=="35"
	replace occup_skill_helper=2 if occup_skill=="40" |  occup_skill=="41" |  occup_skill=="42" |  occup_skill=="43" |  occup_skill=="44" | occup_skill=="50" | occup_skill=="51" | occup_skill=="52" | occup_skill=="53" | occup_skill=="54" | occup_skill=="60"| occup_skill=="61" | occup_skill=="62" | occup_skill=="63" | occup_skill=="70" | occup_skill=="71" | occup_skill=="72" | occup_skill=="73" | occup_skill=="74" | occup_skill=="75" | occup_skill=="80" | occup_skill=="81" | occup_skill=="82" | occup_skill=="83"
	replace occup_skill_helper=3 if occup_skill=="90" | occup_skill=="91" | occup_skill=="93" | occup_skill=="95" | occup_skill=="96" | occup_skill=="99"
	replace occup_skill_helper=. if lstatus!=1
	drop occup_skill
	rename occup_skill_helper occup_skill
	la de lbloccupskill 1 "High" 2 "Medium" 3 "Low" 4 "Armed Forces" 5 "Not elsewhere classified"
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
	label values occup_skill lbloccupskill
*</_occup_skill_>


*<_wage_no_compen_>
	gen double wage_no_compen =.
	replace wage_no_compen=p6b2 if lstatus==1 & empstat==1
	replace wage_no_compen=0 if empstat==2
	replace wage_no_compen=. if lstatus!=1
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
	gen byte unitwage = p6b1
	label var unitwage "Last wages' time unit primary job 7 day recall"
	/*
	LFS 				GLD
	(1) Cada mes  -  	(1) Daily
	(2) every 15 days - (2) Weekly
	(3) every week - 	(3) every two weeks
	(4) daily  - 		(4) bimonthly
	(5) other		  	(5) monthly
	(6) paid by product (6) trimester
	(7) don't know		(7) biannual
	(8) no reply		(8) annualy
	(9) 				(9) hourly
	(10)				(10) other

	*/
	recode unitwage 1=5 2=3 3=2 4=1 6 5=10 7 8=.
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	replace unitwage=. if wage_no_compen==.
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
*this variable has outliers starting in 85 to 168 hours of work
	gen whours = p5c_thrs
	replace whours=. if lstatus!=1
	replace whours=. if p4==4
	replace whours=. if whours==999
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	foreach i in 1 2 3 4 5 6 7 8 9 10 11 12{
	 gen double new_p5g_`i'=1 if p5g`i'== `i'
	}
	local months "new_p5g_1 new_p5g_2 new_p5g_3 new_p5g_4 new_p5g_5 new_p5g_6 new_p5g_7 new_p5g_8 new_p5g_9 new_p5g_10 new_p5g_11 new_p5g_12"
	foreach m in `months' {
		recode `m' .=0
	}
	gen wmonths = new_p5g_1 + new_p5g_2 + new_p5g_3 + new_p5g_4 + new_p5g_5 + new_p5g_6 + new_p5g_7 + new_p5g_8+ new_p5g_9 + new_p5g_10 + new_p5g_11 + new_p5g_12
	replace wmonths=12 if p5g14==14
	replace wmonths=. if lstatus!=1
	replace wage_no_compen=. if wmonths==0
	replace wmonths=. if wmonths==0
	replace wmonths=. if wage_no_compen==.
	replace unitwage=. if wmonths==.
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
/* <_wage_total>

	Use gross wages when available and net wages only when gross wages are not available.
	This is done to make it easy to compare earnings in formal and informal sectors.

</_wage_total> */
	gen double wage_total=.
replace wage_total=(wage_no_compen*5*4.3)*wmonths if unitwage==1
//Wage in daily unit
replace wage_total=(wage_no_compen*4.3)*wmonths if unitwage==2 //Wage in weekly unit
replace wage_total=(wage_no_compen*2.15)*wmonths if unitwage==3
replace wage_total=( wage_no_compen)*wmonths if unitwage==5 //Wage in monthly unit
replace wage_total=( wage_no_compen) if unitwage==10 //Wage for others
	replace wage_total=. if lstatus!=1 & empstat!=1
	replace wage_total=round(wage_total)
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen byte contract=p3j
	recode contract 2=0 9=.
	replace contract=. if lstatus!=1
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte healthins = 1 if p3m5 == 5
	recode healthins .=0
	replace healthins=. if lstatus!=1
	label var healthins "Employment has health insurance primary job 7 day recall"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen byte socialsec = 1 if p3m4 ==4
	recode socialsec .=0
	replace socialsec=. if lstatus!=1
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec 1 "With social security" 0 "Without social secturity"
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen byte union = 1 if p3i == 1
	replace union = 0 if p3i == 2
	replace union =. if p3i == 3
	replace union=. if lstatus!=1
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	gen byte firmsize_l = .
	replace firmsize_l=1 if p3q==01
	replace firmsize_l=2 if p3q==02
	replace firmsize_l=6 if p3q==03
	replace firmsize_l=11 if p3q==04
	replace firmsize_l=16 if p3q==05
	replace firmsize_l=21 if p3q==06
	replace firmsize_l=31 if p3q==07
	replace firmsize_l=51 if p3q==08
	replace firmsize_l=100 if inrange(p3q,09,12)
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u=.
	replace firmsize_u=1 if p3q==01
	replace firmsize_u=5 if p3q==02
	replace firmsize_u=10 if p3q==03
	replace firmsize_u=15 if p3q==04
	replace firmsize_u=20 if p3q==05
	replace firmsize_u=30 if p3q==06
	replace firmsize_u=50 if p3q==07
	replace firmsize_u=100 if inrange(p3q,8,12)
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen byte empstat_2=.
	replace empstat_2=1 if p7 == 4
	replace empstat_2=1 if p7 == 5
	replace empstat_2=2 if p7 == 6
	replace empstat_2=4 if p7 == 3
	replace empstat_2=5 if p7 == 1
	replace empstat_2=5 if p7 == 2
	replace empstat_2=. if lstatus!=1
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2 = .
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2 = p7c
	replace industry_orig_2=. if lstatus!=1
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
gen industrycat_isic_2=isic_2
	replace industrycat_isic_2="" if lstatus!=1
	label var industrycat_isic_2 "ISIC code of primary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
		gen industrycat10_2= substr(industrycat_isic_2, 1,2)
	gen industrycat10_2_helper=.
	replace industrycat10_2_helper=1 if industrycat10_2=="01" | industrycat10_2=="02" | industrycat10_2=="03"
	replace industrycat10_2_helper=2 if industrycat10_2=="05" | industrycat10_2=="06" | industrycat10_2=="07" | industrycat10_2=="08"  | industrycat10_2=="09"
	replace industrycat10_2_helper=3 if industrycat10_2=="10" | industrycat10_2=="11" | industrycat10_2=="12"  |industrycat10_2=="13" | industrycat10_2=="14" | industrycat10_2=="15" | industrycat10_2=="16" | industrycat10_2=="17" | industrycat10_2=="18" | industrycat10_2=="19" | industrycat10_2=="20" | industrycat10_2=="21" | industrycat10_2=="22" | industrycat10_2=="23" | industrycat10_2=="24" | industrycat10_2=="25" | industrycat10_2=="26" | industrycat10_2=="27" | industrycat10_2=="28" | industrycat10_2=="29" | industrycat10_2=="30" | industrycat10_2=="31" | industrycat10_2=="32" | industrycat10_2=="33"
	replace industrycat10_2_helper=4 if industrycat10_2=="35" | industrycat10_2=="36" | industrycat10_2=="37" | industrycat10_2=="38" | industrycat10_2=="39"
	replace industrycat10_2_helper=5 if industrycat10_2=="41" | industrycat10_2=="42" | industrycat10_2=="43"
	replace industrycat10_2_helper=6 if industrycat10_2=="45" | industrycat10_2=="46" | industrycat10_2=="47" | industrycat10_2=="55"  | industrycat10_2=="56"
	replace industrycat10_2_helper=7  if  industrycat10_2=="49" | industrycat10_2=="50" | industrycat10_2=="51" | industrycat10_2=="52" | industrycat10_2=="53" | industrycat10_2=="58" | industrycat10_2=="59" | industrycat10_2=="60" |industrycat10_2=="61" | industrycat10_2=="62" | industrycat10_2=="63"
	replace industrycat10_2_helper=8 if industrycat10_2=="64" | industrycat10_2=="65" | industrycat10_2=="66" | industrycat10_2=="68" | industrycat10_2=="69"| industrycat10_2=="70" | industrycat10_2=="71" | industrycat10_2=="72" | industrycat10_2=="73" | industrycat10_2=="74" | industrycat10_2=="75" | industrycat10_2=="77" | industrycat10_2=="78" | industrycat10_2=="79" | industrycat10_2=="80" | industrycat10_2=="81" | industrycat10_2=="82"
	replace industrycat10_2_helper=9 if industrycat10_2=="84"
	replace industrycat10_2_helper=10 if industrycat10_2=="85" | industrycat10_2=="86" | industrycat10_2=="87" | industrycat10_2=="88" | industrycat10_2=="90" | industrycat10_2=="91" | industrycat10_2=="92" | industrycat10_2=="93" | industrycat10_2=="94" | industrycat10_2=="95" | industrycat10_2=="96" | industrycat10_2=="97" | industrycat10_2=="98" | industrycat10_2=="99"
	replace industrycat10_2_helper=. if lstatus!=1
	drop industrycat10_2
	rename industrycat10_2_helper industrycat10_2
	label var industrycat10_2 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_2 lblindustrycat10_2
*</_industrycat10_2_>


*<_industrycat4_2_>
	gen byte industrycat4_2 = industrycat10_2
	recode industrycat4_2 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_2 "1 digit industry classification (Broad Economic Activities), secondary job 7 day recall"
	label values industrycat4_2 lblindustrycat4
*</_industrycat4_2_>


*<_occup_orig_2_>
	gen occup_orig_2 = p7a
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen occup_isco_2 = isco_2
	replace occup_isco_2="" if lstatus!=1
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>

*<_occup_2_>
	destring isco_2, gen(occup_helper_2)
	gen byte occup_2 = floor(occup_helper_2/1000)
	drop occup_helper_2
	label var occup_2 "1 digit occupational classification secondary job 7 day recall"
	label values occup_2 lbloccup
*</_occup_2_>

*<_occup_skill_2_>
	gen  occup_skill_2= substr(isco_2, 1,2)
	gen occup_skill_2_helper=.
	replace occup_skill_2_helper=1 if occup_skill_2=="10" |  occup_skill_2=="11" |  occup_skill_2=="12" |  occup_skill_2=="13" |  occup_skill_2=="14" | occup_skill_2=="20" | occup_skill_2=="21" | occup_skill_2=="22" | occup_skill_2=="23" | occup_skill_2=="24" | occup_skill_2=="26"| occup_skill_2=="23" | occup_skill_2=="30" | occup_skill_2=="31" | occup_skill_2=="32" | occup_skill_2=="33" | occup_skill_2=="34" | occup_skill_2=="35"
	replace occup_skill_2_helper=2 if occup_skill_2=="40" |  occup_skill_2=="41" |  occup_skill_2=="42" |  occup_skill_2=="43" |  occup_skill_2=="44" | occup_skill_2=="50" | occup_skill_2=="51" | occup_skill_2=="52" | occup_skill_2=="53" | occup_skill_2=="54" | occup_skill_2=="60"| occup_skill_2=="61" | occup_skill_2=="62" | occup_skill_2=="63" | occup_skill_2=="70" | occup_skill_2=="71" | occup_skill_2=="72" | occup_skill_2=="73" | occup_skill_2=="74" | occup_skill_2=="75" | occup_skill_2=="80" | occup_skill_2=="81" | occup_skill_2=="82" | occup_skill_2=="83"
	replace occup_skill_2_helper=3 if occup_skill_2=="90" | occup_skill_2=="91" | occup_skill_2=="93" | occup_skill_2=="95" | occup_skill_2=="96" | occup_skill_2=="99"
	replace occup_skill_2_helper=. if lstatus!=1
	drop occup_skill_2
	rename occup_skill_2_helper occup_skill_2
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
	gen byte firmsize_l_2 = p7e
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	gen byte firmsize_u_2 = p7e
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
	gen t_hours_total =whours*48
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
	gen njobs = t_tra
	label var njobs "Total number of jobs"
*</_njobs_>


*<_t_hours_annual_>
	gen t_hours_annual = whours*48
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


*<_% COMPRESS_>

compress

*</_% COMPRESS_>


*<_% DELETE MISSING VARIABLES_>

quietly: describe, varlist
local kept_vars `r(varlist)'

foreach var of local kept_vars {
   capture assert missing(`var')
   if !_rc drop `var'
}

*</_% DELETE MISSING VARIABLES_>


*<_% SAVE_>

save "`path_output'\MEX_2013_ENOE_V01_M_V01_A_GLD_ALL.dta", replace

*</_% SAVE_>
