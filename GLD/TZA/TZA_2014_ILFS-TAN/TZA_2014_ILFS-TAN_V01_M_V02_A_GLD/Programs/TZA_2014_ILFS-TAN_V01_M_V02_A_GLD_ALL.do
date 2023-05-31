/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------
<_Program name_> 			TZA_2014_ILFS-TAN_V01_M_V02_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata 17 <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2022-02-09 </_Date created_>
-------------------------------------------------------------------------
<_Country_>						TZA </_Country_>
<_Survey Title_>				Integrated Labour Force Survey </_Survey Title_>
<_Survey Year_>					2014 </_Survey Year_>
<_Study ID_>					https://microdatalib.worldbank.org/index.php/catalog/10464 </_Study ID_>
<_Data collection from_>		[MM/YYYY] </_Data collection from_>
<_Data collection to_>			[MM/YYYY] </_Data collection to_>
<_Source of dataset_> 			Shared with GLD team with note that ILFS 2014 Tanzania Mainland should be 
								publicly available, to be uploaded to WB microdata library
								</_Source of dataset_>
<_Sample size (HH)_> 			11,472 </_Sample size (HH)_>
<_Sample size (IND)_> 			47,199 </_Sample size (IND)_>
<_Sampling method_> 			
								The 2014 ILFS used the sampling frame derived from 2012 Population and Housing Census (PHC). The sample selection methodology for the 2014 ILFS was based on a stratified three-stage sample design.
							
The first stage involved systematic sampling of EAs within each stratum with Probability Proportion to Size (PPS) from the ordered list of EAs in the sampling frame. A total of 480 EAs were selected at the first stage whereby 360 EAs were in urban areas and 120 EAs in Rural areas. The second stage involved systematic sampling procedure for selecting households from each selected EA. A total of 24 households were selected from each sampled EA.

The third stage involved selection of respondents for Time Use Module. During data collection, interviewer developed a household register for persons aged 5 years or above in accordance to their sex and age. One household member was selected from the register using KISH grid approach and the time use questionnaire was therefore administered to the selected member of the household in each selected household.

NOTE: Third stage for time use not covered here.

								</_Sampling method_>
<_Geographic coverage_> 		Strata of Dar-es-Salaam // Other Urban // Rural 
								Does not include Zanzibar
								</_Geographic coverage_>
<_Currency_> 					Tanzanian Shilling </_Currency_>
-----------------------------------------------------------------------
<_ICLS Version_>				ICLS-18
								Questionnaire asks for degree of marketness of production of
								goods but does not exclude those in majority self production
								from survey	</_ICLS Version_>
<_ISCED Version_>				ISCED 2011 </_ISCED Version_>
<_ISCO Version_>				ISCO 88 </_ISCO Version_>
<_OCCUP National_>				TASCO 
								At two digits equal to ISCO 88 (not 08 as report says)
								</_OCCUP National_>
<_ISIC Version_>				ISIC Rev 4 </_ISIC Version_>
<_INDUS National_>				Based on ISIC Rev 4 at 2 digits  </_INDUS National_>
-----------------------------------------------------------------------
<_Version Control_>

* Date: [YYYY-MM-DD] - [Description of changes]
* Date: [YYYY-MM-DD] - [Description of changes]
* Date: 2023-05-30 - Update vars educat7

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
local server  "Y:/GLD"
local country "TZA"
local year    "2014"
local survey  "ILFS-TAN"
local vermast "V01"
	local veralt "V02"

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

use "`path_in_stata'\ILFS-2014 for Sharing.dta", clear


/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode = "TZA"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "ILFS"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "LFS"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	gen icls_v = "ICLS-18"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	gen isced_version = "isced_2011"
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
	gen int year = 2014
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
	gen int_year = YEAR
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen  int_month = MONTH
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>

/* <_hhid_note>
	Official report states 11,472 HHs, but survey HHID variable has 11,473 distinct values.
	If you look at household heads, there are 11,472 heads. However, cannot find fault at others
	(like noticing a sole head who should be part of this.)
</_hhid_note> */

	gen hhid = string(HHID, "%06.0f")
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	gen pid = string(HHMID, "%08.0f")
	label var pid "Individual ID"
	isid pid
*</_pid_>


*<_weight_>
	gen weight = ADJWT
	label var weight "Household sampling weight"
*</_weight_>


*<_psu_>
	gen psu = CLUSTER
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = hhid
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	gen strata = GEOG_1
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
	gen byte urban = GEOG_2
	recode urban (2 = 0)
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
/* <_subnatid1_note>
	Survey report not explicit but information in it only disaggregated by strata of 
	Dar es Salaam, Other Urban, Rural. Though not an admin area used for setting subnatid1
</_subnatid1_note> */
	tostring GEOG_1, gen(subnatid1)
	replace subnatid1 = "1 - Dar es Salaam" if subnatid1 == "1"
	replace subnatid1 = "2 - Other Urban" if subnatid1 == "2"
	replace subnatid1 = "3 - Rural" if subnatid1 == "3"
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	tostring REGION, gen(subnatid2)
	replace subnatid2 = "1 - Dodoma" if subnatid2 == "1"
	replace subnatid2 = "2 - Arusha" if subnatid2 == "2"
	replace subnatid2 = "3 - Kilimanjaro" if subnatid2 == "3"
	replace subnatid2 = "4 - Tanga" if subnatid2 == "4"
	replace subnatid2 = "5 - Morogoro" if subnatid2 == "5"
	replace subnatid2 = "6 - Pwani" if subnatid2 == "6"
	replace subnatid2 = "7 - Dar es salaam" if subnatid2 == "7"
	replace subnatid2 = "8 - Lindi" if subnatid2 == "8"
	replace subnatid2 = "9 - Mtwara" if subnatid2 == "9"
	replace subnatid2 = "10 - Ruvuma" if subnatid2 == "10"
	replace subnatid2 = "11 - Iringa" if subnatid2 == "11"
	replace subnatid2 = "12 - Mbeya" if subnatid2 == "12"
	replace subnatid2 = "13 - Singida" if subnatid2 == "13"
	replace subnatid2 = "14 - Tabora" if subnatid2 == "14"
	replace subnatid2 = "15 - Rukwa" if subnatid2 == "15"
	replace subnatid2 = "16 - Kigoma" if subnatid2 == "16"
	replace subnatid2 = "17 - Shinyanga" if subnatid2 == "17"
	replace subnatid2 = "18 - Kagera" if subnatid2 == "18"
	replace subnatid2 = "19 - Mwanza" if subnatid2 == "19"
	replace subnatid2 = "20 - Mara" if subnatid2 == "20"
	replace subnatid2 = "21 - Manyara" if subnatid2 == "21"
	replace subnatid2 = "22 - Njombe" if subnatid2 == "22"
	replace subnatid2 = "23 - Katavi" if subnatid2 == "23"
	replace subnatid2 = "24 - Simiyu" if subnatid2 == "24"
	replace subnatid2 = "25 - Geita" if subnatid2 == "25"
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	tostring REGION, gen(REGION_STR)
	tostring DISTRICT, gen(DISTRICT_STR)
	gen subnatid3 = REGION_STR + DISTRICT_STR
	tostring subnatid3, replace
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
	gen subnatidsurvey = subnatid1
	label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>


*<_subnatid1_prev_>
	gen subnatid1_prev = .
	label var subnatid1_prev "Classification used for subnatid1 from previous survey"
*</_subnatid1_prev_>


*<_subnatid2_prev_>
	gen subnatid2_prev = ""
	replace subnatid2_prev = "11 - Iringa"    if REGION == 11 | REGION == 22
	replace subnatid2_prev = "15 - Rukwa"     if REGION == 15 | REGION == 23 
	
	replace subnatid2_prev = "17 - Shinyanga" if REGION == 17
	replace subnatid2_prev = "17 - Shinyanga" if REGION == 24 & inrange(DISTRICT, 1, 4)
	replace subnatid2_prev = "17 - Shinyanga" if REGION == 25 & inrange(DISTRICT, 1, 4)
	
	replace subnatid2_prev = "19 - Mwanza"    if REGION == 19
	replace subnatid2_prev = "19 - Mwanza"    if REGION == 24 & DISTRICT == 5
	
	replace subnatid2_prev = "18 - Kagera"    if REGION == 18
	replace subnatid2_prev = "18 - Kagera"    if REGION == 25 & DISTRICT == 5
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
	bys hhid: egen hsize = count(Q03_RELATIONSHIP<=6 | Q03_RELATIONSHIP == 8)
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen byte age=Q05B_AGE
	replace age=. if age>=98
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = Q04_SEX
	recode male (2 = 0)
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen relationharm = Q03_RELATIONSHIP
	recode relationharm (4 = 3) (5 = 4) (6 = 5) (7 8 = 6)
	
	* There is one HH without a HH Head
	replace relationharm = 1 if relationharm == 2 & HHID == 381002
	
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = Q03_RELATIONSHIP
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital = Q09_MARSTAT
	recode marital (1=2)(2=1)(4=5)(5=4)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	gen eye_dsablty = Q07B
	recode eye_dsablty (5 = .)
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
	label values eye_dsablty dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty = Q07C
	recode hear_dsablty (5 = .)
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values hear_dsablty dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty = Q07D
	recode walk_dsablty (5 = .)
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values walk_dsablty dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord = Q07E
	recode conc_dsord (5 = .)
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values conc_dsord dsablty
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty  = Q07F
	recode slfcre_dsablty (5 = .)
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values slfcre_dsablty dsablty
	label var slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty = Q07G
	recode comm_dsablty (5 = .)
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
	gen migrated_mod_age = 5
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time = 99
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen migrated_binary = Q11_MIGRA1_GRP1
	recode migrated_binary(2 3 = 1)
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen migrated_years = Q11_MIGRA1_YR
	label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>

/* <_migrated_from_urban_note>
	Survey has question of whether coming from village or city, not officially defined 
	concepts of rural or urban. Additionally, only valid for people coming from within Tanzania.
</_migrated_from_urban_note> */

	gen migrated_from_urban = .
	replace migrated_from_urban = 1 if Q12A_MIGRA2 == 2
	replace migrated_from_urban = 0 if Q12A_MIGRA2 == 1
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen migrated_from_cat = .
	replace migrated_from_cat = 3 if REGION == Q12B_REG
	replace migrated_from_cat = 4 if REGION != Q12B_REG & !missing(Q12B_REG)
	replace migrated_from_cat = 5 if inrange(Q12A_MIGRA2,3,7)
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen migrated_from_code = .
	replace migrated_from_code = Q12B_REG
	label de lblmigrated_from_code 1 "1 - Dodoma" 2 "2 - Arusha" 3 "3 - Kilimanjaro" 4 "4 - Tanga" 5 "5 - Morogoro" 6 "6 - Pwani" 7 "7 - Dar es salaam" 8 "8 - Lindi" 9 "9 - Mtwara" 10 "10 - Ruvuma" 11 "11 - Iringa" 12 "12 - Mbeya" 13 "13 - Singida" 14 "14 - Tabora" 15 "15 - Rukwa" 16 "16 - Kigoma" 17 "17 - Shinyanga" 18 "18 - Kagera" 19 "19 - Mwanza" 20 "20 - Mara" 21 "21 - Manyara" 22 "22 - Njombe" 23 "23 - Katavi" 24 "24 - Simiyu" 25 "25 - Geita" 51 "51 - Kaskazini Unguja" 52 "52 - Kusini Unguja" 53 "53 - Mjini magharibi" 54 "54 - Kaskazini Pemba" 55 "55 - Kusini Pemba"
	label values migrated_from_code lblmigrated_from_code
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country = ""
	replace migrated_from_country = "KEN" if Q12A_MIGRA2 == 3
	replace migrated_from_country = "UGA" if Q12A_MIGRA2 == 4
	replace migrated_from_country = "RWA" if Q12A_MIGRA2 == 5
	replace migrated_from_country = "BDI" if Q12A_MIGRA2 == 6
	replace migrated_from_country = "Other" if Q12A_MIGRA2 == 7
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason = Q13_MIGRA3 if migrated_binary == 1
	recode migrated_reason (1/5 = 3) (6 = 1) (7 = 2) (8 = 4) (9 = 5)
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

	gen byte ed_mod_age = 5
	label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school = Q15_EDSTAT1
	recode school (2 = 0)
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen byte literacy = Q14_LITERACY
	recode literacy (1/4 = 1) (5 = 0)
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen byte educy =.
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7 = .
	replace educat7 = 1 if Q17A_EDUCA == 0
	* Set missing cases who never went to school, not answering this as no education
	replace educat7 = 1 if missing(Q17A_EDUCA) & inrange(age,5,99) & Q15_EDSTAT == 4
	replace educat7 = 2 if inrange(Q17A_EDUCA,1,6)
	replace educat7 = 3 if inrange(Q17A_EDUCA,7,9)
	* Note that we leave out code 10 Adult Education as it is difficult
	* To assign: It is just 98 people
	replace educat7 = 4 if inrange(Q17A_EDUCA,11,13)
	replace educat7 = 5 if inrange(Q17A_EDUCA,14,17)
	replace educat7 = 6 if inrange(Q17A_EDUCA,18,19)
	replace educat7 = 7 if Q17A_EDUCA == 20
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
	gen educat_orig = Q17A_EDUCA
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
/* Here, I use ISCED 2011 with the following codes
	
	ISCED code 				Equivalent
		0				Early childhood
		1				Primary
		2				Lower secondary
		3				Upper secondary
		4				Post secondary
		5				Short-cycle tertiary
		6				Bachelor's
		7				Master's
		8				Doctoral


*/
	gen educat_isced = 0 if educat7 == 2
	replace educat_isced = 1 if inrange(educat7, 3, 4) 
	replace educat_isced = 2 if educat7 == 5
	replace educat_isced = 3 if educat7 == 6
	replace educat_isced = 6 if educat7 == 7

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
	gen vocational = Q18_TYPTRAIN
	recode vocational (1 = 0) (2 / 9 = 1)
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
	gen byte minlaborage = 5
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{

*<_lstatus_>

/* <_lstatus_note>
	Use the "standard definition" current activity. However, they assign all those
	who were available for work as unemployed. We use the definition of available and 
	looking for work. That is variable L2Q12_FINDWORK (any steps to look for work).
	Amend CECSTAT1 accordingly.
	
	lstatus and potential_lf lead you to CECSTAT1
</_lstatus_note> */

	gen byte lstatus = CECSTAT1
	replace lstatus = 3 if L2Q12_FINDWORK == 2
	replace lstatus = . if age < minlaborage	
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = 0 if lstatus == 3
	replace potential_lf = 1 if L2Q12_FINDWORK == 2
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen byte underemployment = 0 if lstatus == 1
	replace underemployment = 1 if L2Q55_CAVAIL == 1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason = L2Q10_RNOTAV
	recode nlfreason (3 9 10 13 96 = 5) (5 6 = 2) (7 = 3) (11 12 = 4)
	replace nlfreason = 5 if inrange(L2Q14_WHY4WK,1,4) | L2Q14_WHY4WK == 9
	replace nlfreason = 2 if L2Q14_WHY4WK == 5
	replace nlfreason = . if lstatus != 3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l=.
	replace unempldur_l = 0 if L2Q17A_DURAVAIL == 1
	replace unempldur_l = 3 if L2Q17A_DURAVAIL == 2
	replace unempldur_l = 6 if L2Q17A_DURAVAIL == 3
	replace unempldur_l = 12 if L2Q17A_DURAVAIL == 4
	replace unempldur_l = . if lstatus != 2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=.
	replace unempldur_u = 3 if L2Q17A_DURAVAIL == 1
	replace unempldur_u = 6 if L2Q17A_DURAVAIL == 2
	replace unempldur_u = 12 if L2Q17A_DURAVAIL == 3
	replace unempldur_u = 9999 if L2Q17A_DURAVAIL == 4
	replace unempldur_u = . if lstatus != 2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte empstat = L2Q20_MSTATUS
	recode empstat (4/7 =2) (2=3) (3 8 9 10=4) 
	replace empstat=. if lstatus!=1
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec = .
	replace ocusec = 1 if inrange(L2Q23_MSECTOR,1,2) | L2Q23_MSECTOR == 9
	replace ocusec = 3 if L2Q23_MSECTOR == 3
	replace ocusec = 2 if inrange(L2Q23_MSECTOR,4,8) | inrange(L2Q23_MSECTOR,10,96)
	replace ocusec = . if lstatus != 1
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish", replace
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig = L2Q22A_MIND
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
/* <_ industrycat_isic_note>

1)	Different classification for unpaid family helper or self-employed in agricultural sector

Q21 (industry classification) is not asked for individuals reported working as unpaid family helper or self-employed in agricultural sector.
Instead, they are asked the specific main activity (Q18b), which can be converted to ISIC codes

2)	Finding the correct ISIC classification version

It is not clear what ISIC version is used here. NO information from available documentation. Industry codes in raw data where mapped to ISIC codes from all revisions
(2, 3 – since 3.1 was released only after the survey (2002), 4 even later). They mapped perfectly to ISIC 2 at two digits and hence this system was used.
There are differences at more depth (3rd, 4th digit) and since the correspondence between national adaption and international codes is unknown, data is kept at 2D.

</_ industrycat_isic_note> */
	gen industrycat_isic = string(L2Q22A_MIND, "%04.0f")
	replace industrycat_isic = "" if industrycat_isic == "."
	replace industrycat_isic = "4900" if industrycat_isic == "4929"
	replace industrycat_isic = "9100" if industrycat_isic == "9199"
	label var industrycat_isic "ISIC code of primary job 7 day recall"

*</_industrycat_isic_>


*<_industrycat10_>
	gen byte industrycat10 = floor(L2Q22A_MIND/100)
	recode industrycat10 (1/3=1) (5/9 = 2) (10/33 = 3) (35/39 = 4) (41/43 = 5) (45/47 55/56 = 6) (49/53 58/63 = 7) (64/82 = 8) (84 = 9) (85/99 = 10) 
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
	gen occup_orig = L2Q18A_MTASK 
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>

/* <_occup_isco_note>
	TASCO codes are equal at two digits to ISCO-88
	Note further, ISCO 88 has codes:
		- 5. Service Workers and Shop and Market Sales Workers
			- 51 – Personal and Protective Services Workers
			- 52 – Models, Salespersons and Demonstrators
	while TASCO has 
		- 5. SERVICE WORKERS AND SHOP SALES WORKERS
			- 51 PERSONAL SERVICE WORKERS
			- 52 PROTECTIVE SERVICE WORKERS
			- 53 SALESPERSONS, DEMONSTRATORS AND MODELS
	So 52 needs to be changed to 51, 53 to 52. All other cases are the same.
</_occup_isco_note> */

	gen occup_isco = string(L2Q18A_MTASK)
	replace occup_isco = substr(occup_isco,1,2)
	replace occup_isco = "" if occup_isco == "."
	replace occup_isco = occup_isco + "00" if !missing(occup_isco)
	replace occup_isco = "" if lstatus != 1
	replace occup_isco = "5100" if occup_isco == "5200"
	replace occup_isco = "5200" if occup_isco == "5300"
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_skill_>
	gen occup_skill = floor(L2Q18A_MTASK/1000)
	recode occup_skill (1/3 = 3) (4/8 = 2) (9 = 1)
	la de lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lblskill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_occup_>
	gen byte occup = floor(L2Q18A_MTASK/1000)
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>


*<_wage_no_compen_>

/* <_wage_no_compen_note>
	Questionnaire does not ask salary in employment sections (within questions on 
	first job, second job) but rather as a block later, asking for *all* salaries
	
	Information on wage divided into three blocks: 
		a) paid employment 
		b) self employment non agriculture
		c) self employment agriculture
	
	Assign main job salary to categor of main job. I.e., if a person is self employed 
	but there is also paid employment info, that piece is not counted here. As a 
	consequence wage is given based on empstat.
	
</_wage_no_compen_note> */

	gen double wage_no_compen = .
	replace wage_no_compen = L2Q61B_WAGE if empstat == 1
	replace wage_no_compen = L2Q62D1 if inrange(empstat,3,4) & industrycat10 != 1
	replace wage_no_compen = L2Q63D1 if inrange(empstat,3,4) & industrycat10 == 1
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
	replace unitwage = 5 if empstat == 1
	replace unitwage = L2Q62D2 if inrange(empstat,3,4) & industrycat10 != 1
	replace unitwage = L2Q63D2 if inrange(empstat,3,4) & industrycat10 == 1
	replace unitwage = . if L2Q62D2 == 0 | L2Q63D2 == 0
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours = L2Q58M_UHOURS
	replace whours = . if whours == 0
	* Replace if tothours worked is > 168 (ave of 24 hours per day)
	egen tothours_helper = rowtotal( L2Q58M_UHOURS L2Q58S_UHOURS )
	
	* Check consistency with raw data variable
	assert tothours_helper == L2Q58T_UHOURS if !missing(L2Q58T_UHOURS)

	replace whours = . if lstatus != 1
	replace whours = . if tothours_helper > 168 & !missing(tothours_helper)
	
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
	gen byte firmsize_l = .
	replace firmsize_l = 1 if L2Q25_MNUME == 1
	replace firmsize_l = 5 if L2Q25_MNUME == 2
	replace firmsize_l = . if lstatus != 1
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u= .
	replace firmsize_u = 4 if L2Q25_MNUME == 1
	replace firmsize_u = 999999 if L2Q25_MNUME == 2
	replace firmsize_u = . if lstatus != 1
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen byte empstat_2 = L2Q38_SSTATUS
	recode empstat_2 (4/7 =2) (2=3) (3 8 9 10=4) 
	replace empstat_2=. if lstatus!=1
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2 = .
	replace ocusec_2 = 1 if inrange(L2Q41_SSECTOR,1,2) | L2Q41_SSECTOR == 9
	replace ocusec_2 = 3 if L2Q41_SSECTOR == 3
	replace ocusec_2 = 2 if inrange(L2Q41_SSECTOR,4,8) | inrange(L2Q41_SSECTOR,10,96)
	replace ocusec_2 = . if missing(empstat_2)
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2 = L2Q40A_SIND
	replace industry_orig_2 = . if missing(empstat_2)
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	
	gen industrycat_isic_2 = string(L2Q40A_SIND, "%04.0f")
	replace industrycat_isic_2 = "" if industrycat_isic_2 == "."
	replace industrycat_isic_2 = "" if missing(empstat_2)
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen byte industrycat10_2 = floor(L2Q40A_SIND/100)
	recode industrycat10_2 (1/3=1) (5/9 = 2) (10/33 = 3) (35/39 = 4) (41/43 = 5) (45/47 55/56 = 6) (49/53 58/63 = 7) (64/82 = 8) (84 = 9) (85/99 = 10) 
	replace industrycat10_2 = . if missing(empstat_2)	
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
	gen occup_orig_2 = L2Q36A_STASK
	replace occup_orig_2 = . if missing(empstat_2)
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>

/* <_occup_isco_2_note>
	Tanzanian occupation classification TASCO is equal to ISCO 88 at two digits, reduce
</_occup_isco_2_note> */

	gen occup_isco_2 = string(L2Q36A_STASK)
	replace occup_isco_2 = substr(occup_isco_2,1,2)
	
	replace occup_isco_2 = "" if occup_isco_2 == "."
	replace occup_isco_2 = occup_isco_2 + "00" if !missing(occup_isco_2)
	replace occup_isco_2 = "5100" if occup_isco_2 == "5200"
	replace occup_isco_2 = "5200" if occup_isco_2 == "5300"
	replace occup_isco_2 = "" if missing(empstat_2)
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_skill_2_>
	gen occup_skill_2 = floor(L2Q36A_STASK/1000)
	recode occup_skill_2 (1/3 = 3) (4/8 = 2) (9 = 1)
	replace occup_skill_2 = . if missing(empstat_2)
	la de lblskill2 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_2 lblskill2
	label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>


*<_occup_2_>
	gen occup_2 = floor(L2Q36A_STASK/1000)
	replace occup_2 = . if missing(empstat_2)
	label var occup_2 "1 digit occupational classification secondary job 7 day recall"
	label values occup_2 lbloccup
*</_occup_2_>


*<_wage_no_compen_2_>

/* <_wage_no_compen_2_note>

	Since the information is not specific to jobs but overall, assumption is that
	if you have two jobs of the same type, only the main is recorded. Hence second
	job salaries would be only recordable for those who differ in first and second.
	This would potentially skew the data and thus information is not provided.
	
</_wage_no_compen_2_note> */
	gen double wage_no_compen_2 = .
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2 = .
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
	gen whours_2 = L2Q58S_UHOURS
	replace whours_2 = . if whours_2 == 0
	replace whours_2 = . if tothours_helper > 168 & !missing(tothours_helper)
	drop tothours_helper
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
	replace firmsize_l_2 = 1 if L2Q43_SNUME == 1
	replace firmsize_l_2 = 5 if L2Q43_SNUME == 2
	replace firmsize_l_2 = . if missing(empstat)
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	gen byte firmsize_u_2 = .
	replace firmsize_u_2 = 4 if L2Q43_SNUME == 1
	replace firmsize_u_2 = 999999 if L2Q43_SNUME == 2
	replace firmsize_u_2 = . if missing(empstat)
	label var firmsize_u_2 "Firm size (upper bracket) secondary job 7 day recall"
*</_firmsize_u_2_>

}

*----------8.4: 7 day reference additional jobs------------------------------*
{
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
}

*----------8.6: 12 month reference overall------------------------------*

{

*<_lstatus_year_>
	gen byte lstatus_year = UECSTAT
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
	gen byte nlfreason_year = L2Q05A_UNOWORK
	recode nlfreason_year (2 3 7 10 96 = 5) (4 = 2) (5 6 = 3) (8 9 = 4) 
	replace nlfreason_year = . if lstatus_year != 3
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
	replace empstat_year = 1 if inrange(L2Q06A_UWORK,1,11)
	replace empstat_year = 2 if inrange(L2Q06A_UWORK,15,16)
	replace empstat_year = 3 if inrange(L2Q06A_UWORK,12,12)
	replace empstat_year = 4 if inrange(L2Q06A_UWORK,13,14)
	replace empstat_year = 5 if inrange(L2Q06A_UWORK,96,96)
	replace empstat_year = . if lstatus_year != 1
	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>

*<_ocusec_year_>
	gen byte ocusec_year = .
	replace ocusec_year = 1 if inrange(L2Q06A_UWORK,1,3) | L2Q06A_UWORK == 10
	replace ocusec_year = 2 if !missing(L2Q06A_UWORK) & missing(ocusec_year)
	replace ocusec_year = . if lstatus_year != 1
	label var ocusec_year "Sector of activity primary job 12 month recall"
	la de lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_year lblocusec_year
*</_ocusec_year_>

*<_industry_orig_year_>
/* <_industry_orig_year_note>
	Industry information for 12 oth period only asked to paid employees and apprentices
	Hence, code the orig but not done for other variables as it may skew information, 
	info is already there for 7 day recall
</_industry_orig_year_note> */
	gen industry_orig_year = L2Q06C_ISIC
	replace industry_orig_year = . if lstatus_year != 1
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
/* <_occup_orig_year_note>
	See note on industry_orig_year
</_occup_orig_year_note> */
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
	* Create helper with at least some part of the month worked
	gen helper = L2Q04A_A + L2Q04A_B + L2Q04A_C
	gen wmonths_year = .
	replace wmonths_year = 12 if L2Q03_WORKALL == 1
	replace wmonths_year = helper if L2Q03_WORKALL == 2
	replace wmonths_year = . if lstatus_year != 1
	label var wmonths_year "Months of work in past 12 months primary job 12 month recall"
	drop helper
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

save "`path_output'/`out_file'", replace

*</_% SAVE_>
