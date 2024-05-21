/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				GMB_2018_LFS_V01_M_V01_A_GLD_ALL </_Program name_>
<_Application_>					Stata SE 18.0 <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2024-04-10 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						Gambia (GMB) </_Country_>
<_Survey Title_>				The Gambia Labour Force Survey </_Survey Title_>
<_Survey Year_>					2018 </_Survey Year_>
<_Study ID_>					GMB_2018_LFS_v01_M </_Study ID_>
<_Data collection from_>			 07/2018 </_Data collection from_>
<_Data collection to_>				 12/2018 </_Data collection to_>
<_Source of dataset_> 				Gambia Bureau of Statistics </_Source of dataset_>
<_Sample size (HH)_> 				5,989  </_Sample size (HH)_>
<_Sample size (IND)_> 				57,792 </_Sample size (IND)_>
<_Sampling method_> 				Stratified two-stage sample design </_Sampling method_>
<_Geographic coverage_> 			The sample was designed to provide labour market information with 95 per cent confidence interval in the 8 LGAs namely; 
									Banjul, Kanifing, Brikama, Mansakonko, Kerewan, Kuntaur, Janjanbureh and Basse </_Geographic coverage_>
<_Currency_> 					    GMD </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS-19 </_ICLS Version_>
<_ISCED Version_>				isced_2011 </_ISCED Version_>
<_ISCO Version_>				isco_2008 </_ISCO Version_>
<_OCCUP National_>				isco_2008 </_OCCUP National_>
<_ISIC Version_>				isic_4 </_ISIC Version_>
<_INDUS National_>				isic_4 </_INDUS National_>

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
set varabbrev off

*----------1.2: Set directories------------------------------*
* Define path sections
local server  "Y:/GLD-Harmonization/625372_DB"
local country "GMB"
local year    "2018"
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


use "`path_in_stata'/LFS_Final.dta", clear
/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode = "GMB"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "GLFS"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "LFS"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	gen icls_v = "ICLS-19"
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
	gen int year = 2018
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
	gen int_year= 2018
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen  int_month = 7
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
	
	One household was incorrectly coded. The cluster to which it was assigned is from another region. Therefore, this household does not belong to the cluster and hid has duplicates. Drop the household id for this case:
	preserve
		duplicates drop hh8 hid, force
		duplicates tag hid, gen(tag)
		tab hid if tag != 0 // hid == 30502
		tab hh8 if tag != 0 // KUNTAUR and BASSE
	restore
	
	tab hh8 hh1 if hh7 == 2 & hh8 == 6 // KUNTAUR
	tab hh8 hh1 if hh7 == 2 & hh8 == 8 // BASSE
	
	The HH of KUNTAUR was incorrectly coded. Put it in a cluster of the correct region, put a new household number that does not duplicate with other HH: Cluster(hh1) 196 does not have obs of household number(hh2) == 1
	

</_hhid_note> */
	gen hhid = hid
	replace hhid = "19601" if hh7 == 2 & hh8 == 6 & hid == "30502" // 4 obs, one household
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
/* <_hhid_note>

	Change code of household corrected above

</_hhid_note> */
	gen  pid = uid
	replace pid = subinstr(uid,"30502","19601",.) if hhid == "19601" & hh7 == 2 & hh8 == 6
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
/* <_weight_note>

	It is already created with the same name

</_weight_note> */
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
/* <_psu_note>

the Primary Sampling Units (PSUs) are at the level of Enumeration Areas (EAs). Enumeration Areas are geographic units defined by the 8 Local Government Areas (LGAs) and their Areas (urban/rural). In each selected EA, 20 households were selected for the survey

</_psu_note> */
	gen psu = hh1
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	egen ssu = concat(hh1 hh2), format("%03.0f")
	destring ssu, replace
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
/* <_strata_note>

By urban and rural, there was a total of 14 sampling strata in the 8 LGAs

</_strata_note> */
	egen strata = concat(hh8 hh7), format("%02.0f")
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
	gen byte urban = hh7
	replace urban = 0 if urban == 2 // rural
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
/* <_subnatid1_note>

	The variable is string and country-specific categorical. Numeric entries are coded in string format using the following naming convention: "1 – Hatay". That is, the variable itself is to be string, not a labelled numeric vector. 
	
	Example of entries would be "1 - Alaska",  "2 - Arkansas", ...

</_subnatid1_note> */
	decode hh8, gen(lga)
	egen subnatid1 = concat(hh8 lga), punct(" - ")
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
	See entry in GLD Guidelines (https://github.com/worldbank/gld/blob/main/Support/A%20-%20Guides%20and%20Documentation/GLD_1.0_Guidelines.docx)
	for more details

</_subnatidsurvey_note> */
	gen subnatidsurvey = subnatid1
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
/* <_hsize_note>

	There is a nhhold_memb var but has mistakes on his codification.

</_hsize_note> */
	bys hhid: gen hsize = _N
	label var hsize "Household size"
*</_hsize_>


*<_age_>
/* <_age_note>

	In the case of children aged less than or equal to 60 months, variable age should be expressed in the number of completed years and months in decimals.

</_age_note> */
	gen age = hl6
	*Identify children under 60 months and code the completed years and months
	gen under_5yrs = 1 if hl6 < 5
	//interview month: the var interview_month is wrong codificated. Use the interview_date var
	tostring interview_date, gen(interview_date_str)
	gen interview_month_correct = real(substr(interview_date_str, -6, 2))
	// calculate the difference
	gen monthly_int_date = ym(interview_year,interview_month_correct) 
	format monthly_int_date %tm
	gen monthly_birth_date = ym(hl5_2,hl5_1) 
	format monthly_birth_date %tm
	gen completed_age = (monthly_int_date - monthly_birth_date)/12 if under_5yrs == 1
	// put only one decimal
	replace completed_age = floor(completed_age*10)/10
	// replace
	replace age = completed_age if completed_age != .
	*There are missing values, look on the data for another age vars
	// ind age info for education section
	replace age = ed2_2 if age == .
	// ind age info for external migration section
	replace age = ex2_2 if age == .
	*There are contradictions, internal mig questions shows another ages, correct
	replace age = im2age if age != im2age & im2age != .
	*There are contradictions, educ questions shows another ages, correct
	*There are some negative values, the interview date is before than the birth date (contratiction)
	replace age = ed2_2 if age != ed2_2 & ed2_2 != . & age < 3
	replace age = 0 if age < 0
	*There are two cases of children whose birth dates do not match the reported ages. Keep the reported ages.
	replace age = hl6 if age > 5 & mod(age,1) > 0
	label var age "Individual age"
*</_age_>
	


*<_male_>
	gen male = hl4
	*There are missing values, look on the data for another gender vars
	// ind gender info for external migration section
	replace male = ex3 if male == .
	replace male = 0 if male == 2 // female
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
/* <_relationharm_note>

01 HEAD
02 SPOUSE / PARTNER
03 SON / DAUGHTER
04 SON-IN-LAW / DAUGHTER-IN-LAW 
05 GRAND SON / DAUGHTER
06 PARENT
07 PARENT-IN-LAW
08 BROTHER / SISTER
09 BROTHER-IN-LAW / SISTER-IN-LAW            
10 UNCLE/AUNT
11 NIECE / NEPHEW
12 OTHER RELATIVE
13 ADOPTED / FOSTER / STEPCHILD
14 SERVANT (LIVE-IN) 
15 CO-WIVES
16 GRAND PARENT
96 OTHER (NOT RELATED)
98 DK
                                                                           
</_relationharm_note> */
	gen relationharm = hl3
	recode relationharm (15 = 2) (4 13 = 3) (6 7= 4) (8 9 10 11 12 16 = 5) (14 17 = 6)
	replace relationharm = . if relationharm == 98 //don't know
	bys hhid: gen head_check = _n == 1
	*br hhid hl3 head_check if hl3 != head_check & head_check == 1
	//two cases, they did not answer relationharm question. Use the oldest member as head
	replace relationharm = head_check if hl3 != head_check & head_check == 1
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = hl3
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
/* <_marital_note>

	1 MARRIED
	2 NEVER MARRIED
	3 COHABITING/LIVING TOGETHER
	4 DIVORCED / SEPARATED / WIDOWED

	DIVORCED / SEPARATED are in the same category of WIDOWED. Put missing
</_marital_note> */

	gen byte marital = hl8
	replace marital = 2 if age < 18 & marital == . //18 years is the minimum age of marriage 
	replace marital = . if hl8 == 4
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	gen eye_dsablty = fn3
	replace eye_dsablty = . if eye_dsablty == 8
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
	label values eye_dsablty dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty = fn4
	replace hear_dsablty = . if hear_dsablty == 8
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values hear_dsablty dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty = fn5
	replace walk_dsablty = . if walk_dsablty == 8
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values walk_dsablty dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord = fn6
	replace conc_dsord = . if conc_dsord == 8
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values conc_dsord dsablty
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty  = fn7
	replace slfcre_dsablty = . if slfcre_dsablty == 8
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values slfcre_dsablty dsablty
	label var slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty = fn8
	replace comm_dsablty = . if comm_dsablty == 8
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
	gen migrated_mod_age = 15
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time = 99
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
/* <_migrated_binary_note>

	(im3) How many years have you lived in this village/town/city?

</_migrated_binary_note> */
	gen migrated_binary = .
	replace migrated_binary = 1 if (im3 != age) & (im3 != .)
	replace migrated_binary = 0 if migrated_binary == .
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen migrated_years = im3
	label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban = .
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
/* <_migrated_from_cat_note>

	Only info of admin1 area
	(im4)Which LGA did you move from?

</_migrated_from_cat_note> */
	gen migrated_from_cat = .
	replace migrated_from_cat = 3 if (hh8 == im4) & (im4 != .)
	replace migrated_from_cat = 4 if (hh8 != im4) & (im4 != .)
	replace migrated_from_cat = 5 if (im4 == 9) //abroad
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
/* <_migrated_from_code_note>

	abroad case, put missing

</_migrated_from_code_note> */
	*decode im4, gen(migrated_from_code)
	*egen migrated_from_code = concat(im4 lga_mig) if (im4 != 9 & im4 != .) , punct(" - ")
	gen migrated_from_code = im4
	replace migrated_from_code = . if im4 == 9 //abroad
	label de lblmigrated_from_code 1 "BANJUL" 2 "KANIFING" 3 "BRIKAMA" 4 "MANSAKONKO" 5 "KEREWAN" 6 "KUNTAUR" 7 "JANJANBUREH" 8 "BASSE"
	label values migrated_from_code lblmigrated_from_code
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country = .
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
/* <_migrated_reason_note>

	(im5) What were the three the main reasons (starting with the most important) 
	for moving to this village/town/city?. 
	
	Just choose the first one
	
	A WORK
	B OWN EDUCATION
	C EDUCATION OF CHILDREN 
	D MARRIAGE
	E OTHER FAMILY REASON
	F BETTER HOUSING / SERVICES 
	G SECURITY REASONS/CRIME 
	H RETURNED FROM ABROAD 
	X OTHER / SPECIFY

</_migrated_reason_note> */
	gen migrated_reason = substr(im5,1,1)
	*three exceptional cases:
	replace migrated_reason = "4" if im5 == "004"
	replace migrated_reason = "6" if im5 == "06"
	replace migrated_reason = "1" if im5 == "l15"
	destring migrated_reason, replace
	recode migrated_reason (3 = 2) (1 = 3) (4 5 = 1) (7 = 4) (6 8 9 = 5)
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

	The educational module is only requested for those over 3 years old up

</_ed_mod_age_note> */

gen byte ed_mod_age = 3
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school= ed6
	recode school (2 = 0)(8 = .)
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen byte literacy = ed9
	recode literacy (2 3 = 0)(8 = .)
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>

/* <_educy_note>

	Education levels in Gambia - Sering info
	
	ECE -- Nursery 1 to 4
	Primary -- grade 1 to 6
	Lower Secondary -- garde 7 to 9
	Upper Secondary -- grade 10 to 12
	Vocational -- 1 to 2 years
	Diploma -- 1 to 3 years
	Higher (BSc/ACCA/MSc/PhD) -- 1 to 12 years

</_educy_note> */

	gen byte educy = .
	replace educy = 0 if ed4 == 2 // No education 
	replace educy = 0 if ed8_level == 0 //ECE
	replace educy = ed8_grade if ed8_level == 1 & ed8_grade <=6 // primary (level 1 to 6)
	replace educy = ed8_grade+6 if ed8_level == 2 & ed8_grade <=3 // lower secondary (level 7 to 9)
	replace educy = ed8_grade+9 if ed8_level == 3 & ed8_grade <=3 // upper secondary (level 10 to 12)
	
	replace educy = ed8_grade+12 if ed8_level == 4 & ed8_grade <=2 // vocational certificate (after level 12) 
	replace educy = 14 if ed8_level == 4 & ed8_grade > 2 //truncate to 2 years
	
	replace educy = ed8_grade+12 if ed8_level == 5 & ed8_grade <=3 // diploma. 
	replace educy = 15 if ed8_level == 5 & ed8_grade > 3 //truncate to 3 years.
	
	replace educy = ed8_grade+12 if ed8_level == 6 & ed8_grade <=12 // higher. 
	
	replace educy = . if ed8_level == 98 | ed8_grade == 98  //DK, 7 obs
	replace educy = . if  age < educy & (age != . & educy != .) // put to missing this contratiction, only 24 obs

	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7 = .
	replace educat7 = 1 if ed4 == 2 // No education 
	replace educat7 = 1 if ed8_level == 0 // No education
	replace educat7 = 2 if ed8_level == 1 & ed8_grade < 6 // primary incomplete
	replace educat7 = 3 if ed8_level == 1 & ed8_grade == 6 // primary complete
	replace educat7 = 4 if (ed8_level == 2 & ed8_grade <=3)  | (ed8_level == 3 & ed8_grade <3) // secondary incomplete
	replace educat7 = 5 if ed8_level == 3 & ed8_grade == 3 // secondary complete
	replace educat7 = 6 if ed8_level == 4 | ed8_level == 5 // Higher than secondary but not university
	replace educat7 = 7 if  ed8_level == 6 // University incomplete or complete
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
/* <_educat_orig_note>

	The survey has two variables that need to be used to codify education.

</_educat_orig_note> */
	gen educat_orig = .
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
	gen educat_isced = .
	*replace educat_isced = "000" if ed4 == 2
	*replace educat_isced = "000" if ed8_level == 0 //Some early childhood education
	replace educat_isced = 100 if ed8_level == 1
	replace educat_isced = 200 if ed8_level == 2
	replace educat_isced = 300 if ed8_level == 3
	replace educat_isced = 400 if ed8_level == 4
	replace educat_isced = 500 if ed8_level == 5
	replace educat_isced = 600 if ed8_level == 6
	
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
/* <_vocational_note>

	The survey only asks the last 12 months (tr3)

</_vocational_note> */
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
	gen str vocational_field_orig = ""
	label var vocational_field_orig "Original field of training information"
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
	gen byte minlaborage = 15
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
/* <_lstatus_note>

	
	The Gambian report says that Discouraged job seeker are consider as unemployed: It represents the proportion of unemployed persons who are not seeking job for reasons such as feeling that they lack proper qualifications, they do not know where or how to look for work; or they feel that no suitable work is available.
	
	*** employed ***
	
	emp5 -- And what would you say was (name?s) main activity in the last 7 days?
		1 A PAID EMPLOYEE OF SOMEONE WHO IS NOT A MEMBER OF YOUR HH
		2 A PAID WORKER ON HH FARM OR NON-FARM BUSINESS ENTERPRISE
		3 AN EMPLOYER
		4 A WORKER NON- AGRICULTURAL OWN ACCOUNT WORKER, WITHOUT EMPLOYEES 
		5 UNPAID WORKERS (E.G.HOMEMAKER, WORKING ON NON-FARM FAMILY BUSINESS) 
		6 UNPAID FARMERS
		7 NONE OF THE ABOVE
		
	emp6 -- Does (name) have a permanent/long term job (even though you did not work in the last 7 days) 
			from which you were temporarily absent?
		1 YES
		2 NO
		
	emp12 -- [ASK ONLY IF EMP 5 = 6] Are the products produced on the HH farm or business enterprise?
		1 ONLY FOR SALE/BARTER
		2 MAINLY FOR SALE, BUT PARTLY FOR OWN CONSUMPTION
		3 MAINLY FOR OWN CONSUMPTION, BUT ALSO FOR SALE/BARTER
		4 ONLY FOR OWN CONSUMPTION
			
	*** unemployed *** 
	
	aviable and looking for job
		the questionnarie considers as unemployed (apply unemployment block): a not working or unpaid family worker in subsistence business, available for work and looking for work. In other words: if **emp13 == 1**
	
		(emp13 != .) if [inlist(emp5,5,6,7) OR inlist(emp12,3,4)] OR [emp9 == 1]
		
	In the questionnarie does not appear an specific question. It could be an dummy variable.
	However codify as unemployed using the following variables 
	
	emp8 -- Is (name) available to start a job
		1 NO
		2 IMMEDIATELY
		3 WITHIN THE LAST 2 WEEKS
		4 AFTER 2 WEEKS TO A MONTH
		5 AFTER A
		MONTHS
		6 DON'T KNOW
		
	emp9 -- During the last 4 weeks, has (name) tried in any way to find a job or start (her/his) own business
		1 YES
		2 NO
		
	emp13 -- (i.e. not working or unpaid family worker in subsistence business, available for work and looking for work)
		1 YES
		2 NO
	
	*After harmonization: There are missing values, there are not info about labor questions for the respondent
</_lstatus_note> */
	gen byte lstatus = .
	replace lstatus = 1 if inlist(emp5,1,2,3,4) | (inlist(emp5,5,6,7) & emp6 == 1) | inlist(emp12,1,2) 
	replace lstatus = 2 if inlist(emp8,2,3) & emp9 == 1
	replace lstatus = 3 if lstatus == . & emp5 != . // These are neither persons who were neither employed nor unemployed in the reference period (one week). This includes persons doing solely unpaid domestic work in their own houses; those engaged in full time studies and persons not working because they were sick, retired or did not want to work
	
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = 0
	replace potential_lf = 1 if inlist(emp8,1,4,5,6) & emp9 == 1 & inlist(emp12,3,4,.) // not aviable and looking
	replace potential_lf = 1 if inlist(emp8,2,3) & emp9 == 2 & inlist(emp12,3,4,.) // aviable and not looking
	replace potential_lf = . if age < minlaborage & age != .
	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
/*</_underemployment_note> 

	(hw4c -- less than 35 hours) What was the main reason (name) worked less than 35 hours during the last week?

	1 ILLNESS OR AGED (Next section)
	2 DISABILITY (Next section)
	3 IN SCHOOL OR TRAINING (Next section)
	4 LEAVE, HOLIDAY ICL. FAMILY OBLIGATIONS (FUNERALS, SICK/
	CHILD ETC.) (Next section)
	5 DID NOT WANT TO WORK MORE HOURS (Next section)
	6 HOUSEWORK DUTIES... 06(Next section)
	7 CANNOT FIND MORE WORK IN A JOB, AGRICULTURE OR FOR A BUSINESS
	8 NO SUITABLE AGRICULTURE LAND OR
	SLACK PERIOD IN AGRICULTURE
	9 LACK OF RAW MATERIALS, EQUIPMENT
	AND FINANCE
	10 MACHINERY/ELECTRICAL BREAKDOWN/
	OTHER TECHNICAL PROBLEMS
	11 STOOD DOWN BY EMPLOYER
	12 OFF SEASAON
	96 OTHER (specify)

IF HW4C=7|8|9|10|11|12|96 go to HW5

	(hw5) Were (name) available for 35 more hours of work during the last week?
	
	1 YES
	2 NO
</_underemployment_note> */
	gen byte underemployment = hw5
	recode underemployment (2 = 0)
	replace underemployment = 0 if underemployment == . & lstatus == 1
	replace underemployment = . if age < minlaborage & age != .
	replace underemployment = . if lstatus != 1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason= emp11
	recode nlfreason (7 8 9 96 10 = 5)
	replace nlfreason = . if lstatus != 3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l= ub4
	recode unempldur_l (1 = 0) (2 = 3) (3 = 6) (4 = 12)
	replace unempldur_l = . if lstatus != 2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u= ub4
	recode unempldur_u (1 = 3) (2 = 5) (3 = 12) (4 = .)
	replace unempldur_u = . if lstatus != 2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
/* </_empstat_note>
	
	This survey does not consider non-paid employees. If emp5 == UNPAID WORKERS (E.G. HOMEMAKER, WORKING ON NON-FARM FAMILY BUSINESS), then the survey asks them about job search or job absenteeism instead of delving into their current work.

	emp17 -- Can I just check in this job were working as:
		1 A PAID EMPLOYEE OF SOMEONE WHO IS NOT A MEMBER OF YOUR HH
		2 A PAID WORKER ON HH FARM OR NON-FARM BUSINESS ENTERPRISE
		3 AN EMPLOYER
		4 A WORKER ON OWN ACCOUNT, WITHOUT EMPLOYEES
</_empstat_note> */

	gen byte empstat = .
	replace empstat = 1 if inlist(emp17,1,2)
	replace empstat = 3 if emp17 == 3
	replace empstat = 4 if emp17 == 4
	replace empstat = 5 if empstat == . & lstatus == 1 //zero changes

	replace empstat = . if lstatus != 1
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec = eb4
	recode ocusec (3 4 = 2) (96 = 4)
	replace ocusec = . if lstatus!= 1
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>

*<_industry_orig_>
	gen industry_orig = emp16
	replace industry_orig = "" if age<minlaborage
	replace industry_orig = "" if lstatus != 1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
/* <_industrycat_isic_note>

	The information in the survey is only aviable at section level
	
	The survey do not ask the economic activity for the majority of unpaid workers and unpaid farmers. Impute economic activity == Agriculture to unpaid farmers

</_industrycat_isic_note> */
	gen industrycat_isic = industry_orig
	replace industrycat_isic = "" if inlist(industrycat_isic,"V","X")
	replace industrycat_isic = "" if lstatus != 1
	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	preserve 
	*drop if missing(industrycat_isic)
	*int_classif_universe, var(industrycat_isic) universe(ISIC)
	count
	*list
	*assert `r(N)' == 0
	restore 

	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen byte industrycat10 = .
	replace industrycat10 = 1 if industrycat_isic == "A"
	replace industrycat10 = 2 if industrycat_isic == "B"
	replace industrycat10 = 3 if industrycat_isic == "C"
	replace industrycat10 = 4 if inlist(industrycat_isic,"D","E")
	replace industrycat10 = 5 if industrycat_isic == "F"
	replace industrycat10 = 6 if inlist(industrycat_isic,"G","I")
	replace industrycat10 = 7 if inlist(industrycat_isic,"H","J")
	replace industrycat10 = 8 if inlist(industrycat_isic,"K","L","M","N")
	replace industrycat10 = 9 if industrycat_isic == "O"
	replace industrycat10 = 10 if inlist(industrycat_isic,"P","Q","R","S","T","U")

	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
*</_industrycat10_>


*<_industrycat4_>
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 = 2)(6 7 8 9=3)(10=4)
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
	gen occup_orig = emp15
	replace occup_orig = . if lstatus != 1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
/* <_occup_isco_note>

	The information in the survey is only aviable at mayor group level
	There are wrong coding issues (emp15 == 0), correct them using emp14

</_occup_isco_note> */
	gen occup_isco = emp15
	replace occup_isco = . if inlist(occup_isco,0,98)
	replace occup_isco = 0 if occup_isco == 10 // armed forces
	replace occup_isco = occup_isco * 1000
	tostring occup_isco, replace
	replace occup_isco = "" if occup_isco == "."
	replace occup_isco = "0000" if occup_isco == "0" // armed forces
	replace occup_isco = "" if lstatus != 1

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	preserve 
	*drop if missing(occup_isco)
	*int_classif_universe, var(occup_isco) universe(ISCO)
	count
	*list
	*assert `r(N)' == 0
	restore

	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	gen occup = occup_isco
	destring occup, replace
	replace occup = occup/1000
	recode occup (0 = 10) // armed forces
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
/* <_wage_no_compen_note>

	the data is presented only in salary ranges. Put missing
	
</_wage_no_compen_note> */
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

	gen byte unitwage = eb6 // employee
	recode unitwage (4 = 5) (96 = 10)
	*employers and self-employee
	replace unitwage = 8 if sb17 == 1 & unitwage == .
	replace unitwage = 5 if sb17 == 2 & unitwage == .
	replace unitwage = 3 if sb17 == 3 & unitwage == .
	replace unitwage = 2 if sb17 == 4 & unitwage == .
	replace unitwage = 1 if sb17 == 5 & unitwage == .
	replace unitwage = 10 if sb17 == 96 & unitwage == .
	replace unitwage = . if (lstatus !=1) | (empstat != 1)
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen sum_whours = hw3a_mon + hw3a_tue + hw3a_wed + hw3a_thu + hw3a_fri + hw3a_sat + hw3a_sun
	gen whours = sum_whours
	replace whours = . if lstatus != 1
	*replace whours = . if whours > 84
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
	gen byte contract = eb10
	recode contract (2 = 0)
	replace contract = . if lstatus != 1
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
	gen byte socialsec = eb14
	recode socialsec (2 = 0)
	replace socialsec = . if lstatus != 1
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec 1 "With social security" 0 "Without social secturity"
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen byte union = eb8
	recode union (2 = 0) (8 = .)
	replace union = . if lstatus != 1
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	gen firmsize_l = sb6
	recode firmsize_l (5 = 10) (4 = 5) (2 = 1) (3 = 2) 
	replace firmsize_l = . if lstatus != 1
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen firmsize_u= sb6
	recode firmsize_u  (5 = .) (4 = 10) (2 = 1) (3 = 5)
		replace firmsize_u = . if lstatus != 1
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
	replace t_hours_total = . if lstatus!= 1
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

/* <*_year_note>

Despite there being questions related to employment for the last 12 months of reference, they are only applied to individuals who did not work in the 7 days of reference.

	tab emp5 em5 if inrange(age,15,999), m
	tab emp5 em5 if inrange(age,15,999), m row nofreq

Consequently, the variables *_year cannot be coded over 12 months because the questions are only asked to a subgroup of the sample; therefore, the results are biased towards the total population level.


<*_year_note> */

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
	gen byte nlfreason_year= .
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

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	preserve 
	*drop if missing(industrycat_isic_year)
	*int_classif_universe, var(industrycat_isic_year) universe(ISIC)
	count
	*list
	*assert `r(N)' == 0
	restore 

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

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	preserve 
	*drop if missing(occup_isco_year)
	*int_classif_universe, var(occup_isco_year) universe(ISCO)
	count
	*list
	*assert `r(N)' == 0
	restore

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

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu ssu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu ssu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

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
