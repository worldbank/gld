
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				BIH_2022_LFS_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata 18 <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2025-09-25 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						BIH </_Country_>
<_Survey Title_>				Labor Force Survey </_Survey Title_>
<_Survey Year_>					2022 </_Survey Year_>
<_Study ID_>					[Microdata Library ID if present] </_Study ID_>
<_Data collection from_>		01/2022 </_Data collection from_>
<_Data collection to_>			12/2022 </_Data collection to_>
<_Source of dataset_> 			Agency of Statistics </_Source of dataset_>
<_Sample size (HH)_> 			29,991 </_Sample size (HH)_>
<_Sample size (IND)_> 			74,385 </_Sample size (IND)_>
<_Sampling method_> 			The sample was designed as a stratified two-stage random sample </_Sampling method_>
<_Geographic coverage_> 		National </_Geographic coverage_>
<_Currency_> 					Convertible Mark </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS 13 </_ICLS Version_>
<_ISCED Version_>				[Version of ICLS for Labor Questions] </_ISCED Version_>
<_ISCO Version_>				ISCO 2008 </_ISCO Version_>
<_OCCUP National_>				[Version of ICLS for Labor Questions] </_OCCUP National_>
<_ISIC Version_>				ISIC Rev 4 </_ISIC Version_>
<_INDUS National_>				[Version of ICLS for Labor Questions] </_INDUS National_>

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
local server  "C:/Users/`c(username)'/WBG/GLD - Current Contributors/625372_DB"
dis "`server'"
local country "BIH"
local year    "2022"
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
use "`path_in_stata'/lfs_raw_dlw_2022.dta", clear

*there are individuals with duplicates of all vars
duplicates tag, gen(tag)

/*

-----------------------------------------------------------
              |      Freq.    Percent      Valid       Cum.
--------------+--------------------------------------------
Valid   0     |      74268      99.84      99.84      99.84
        1     |        115       0.15       0.15     100.00
        2     |          2       0.00       0.00     100.00
        Total |      74385     100.00     100.00           
-----------------------------------------------------------

*/

*keep the first obs
duplicates drop



/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode = "BIH"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "LFS"
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
	gen int year = 2022
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
	gen int_year = 2022
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

*This survey is quarterly, Since 2020, a  panel component has been introduced in the sample and 
*households are surveyed in two consecutive quarters, excluded  from the sample for the next two quarters, 
*and re-surveyed in two more consecutive quarters (rotation scheme 2 (-2) 2).
	* hhid for cross-sectional analysis: hhid = hhid + quarter
	egen hhid = concat(COEFFHH RefQuarter), punct("Q")
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	
	*Not Personal ID in raw data, we have to construct it:
		*pid = hhid + sex + yearbirth + age + hhlink + counter
	bys hhid : gen counter = string(_n,"%02.0f")
	bys hhid : gen sex_str = string(Sex_Q6,"%02.0f")
	bys hhid : gen age_str = string(Starost_Q9,"%03.0f")
	bys hhid : gen hhlink_str = string(HHLINK_Q10,"%02.0f")

	egen  pid = concat(hhid sex_str age_str hhlink_str YEARBIR_Q7 counter)
	label var pid "Individual ID"
	
	*hhid and pid need to be unique in the database.
	
	isid hhid pid 
	duplicates report hhid pid 
	
*</_pid_>



*<_weight_>
	gen weight = CalibrationWeight
	label var weight "Survey sampling weight"
*</_weight_>


*<_weight_m_>
	gen weight_m = .
	label var weight_m "Survey sampling weight to obtain national estimates for each month"
*</_weight_m_>


*<_weight_q_>
	gen pop_t = _N
	bys RefQuarter : gen pop_q = _N
	
	gen weight_q = weight * (pop_t/pop_q)
	label var weight_q "Survey sampling weight to obtain national estimates for each quarter"
*</_weight_q_>


*<_psu_>
	gen psu = PSU_EUROSTAT
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = hhid
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	gen strata = stratum_EUROSTAT
	label var strata "Strata"
*</_strata_>


*<_wave_>
	gen wave = "Q" + string(RefQuarter)
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
	gen byte urban = .
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
	replace subnatid1 = "1 - Federation of Bosnia and Herzegovina" if Entitet == 1
	replace subnatid1 = "2 - Republika Srpska" if Entitet == 2
	replace subnatid1 = "3 - Brčko Distrikt of Bosnia and Herzegovina" if Entitet == 3
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

	gen str subnatidsurvey = subnatid1
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
	gen age = Starost_Q9
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = Sex_Q6
	recode male (2 = 0)
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
/*
1 - 	Reference person			
2 - 	Partner of reference person			
3 - 	Children of reference person			
4 - 	Son/daughter-in-law of reference person			
5 - 	Grand-child of reference person			
6 - 	Parent of reference person			
7 - 	Parent-in-law of reference person			
8 - 	Grandparent of reference person			
9 - 	Brother/sister of reference person			
10 - 	Other relative			
11 - 	Other non-relative			
*/

	** Each household must have exactly one head **

	*Priority: 
	*(1) respondent originally coded `head'
	gen relationharm = HHLINK_Q10
	recode relationharm (4 = 3) (6 7 = 4) (8 9 10 = 5) (11 = 6)
	
	*If household has no head:
	gen head = relationharm == 1
	bys hhid : egen number_heads = total(head)

	/*
	fre number_heads

		number_heads
		-----------------------------------------------------------
					  |      Freq.    Percent      Valid       Cum.
		--------------+--------------------------------------------
		Valid   0     |          3       0.00       0.00       0.00
				1     |      63505      87.72      87.72      87.72
				2     |       6863       9.48       9.48      97.20
				3     |       1438       1.99       1.99      99.19
				4     |        388       0.54       0.54      99.72
				5     |        128       0.18       0.18      99.90
				6     |         72       0.10       0.10     100.00
				Total |      72397     100.00     100.00           
		-----------------------------------------------------------

	unique hhid if number_heads == 0
		Number of unique values of hhid is  3
		Number of records is  3

	There are 3 households (3 individuals) with no household head
	
	unique hhid if inrange(number_heads,2,999)
		Number of unique values of hhid is  2902
		Number of records is  8889
		
	There are 2902 households (8889 individuals) with more than one head
	*/
	
	*(2) In cases where there is no head, and only one person lives in the household, designate that person as the head.
	replace relationharm = 1 if relationharm != 1 & number_heads == 0
	
	*(3) If more than one head, select the oldest as head
	bys hhid (head age) : gen oldest = 1 if (_n == _N)
	bys hhid: replace relationharm = 1 if relationharm != 1 & inrange(number_heads,2,99) & oldest == 1
	bys hhid: replace relationharm = 5 if relationharm == 1 & inrange(number_heads,2,99) & oldest != 1
	
	*Prove that number_heads is now equal to 1 for all households
	drop head number_heads
	gen head = 1 if relationharm == 1
	bys hhid : egen number_heads = total(head)
	
	assert number_heads == 1
	
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = ""
	replace relationcs = "Reference person" if HHLINK_Q10 == 1
	replace relationcs = "Partner of reference person" if HHLINK_Q10 == 2
	replace relationcs = "Children of reference person" if HHLINK_Q10 == 3
	replace relationcs = "Son/daughter-in-law of reference person" if HHLINK_Q10 == 4
	replace relationcs = "Grand-child of reference person" if HHLINK_Q10 == 5
	replace relationcs = "Parent of reference person" if HHLINK_Q10 == 6
	replace relationcs = "Parent-in-law of reference person" if HHLINK_Q10 == 7
	replace relationcs = "Grandparent of reference person" if HHLINK_Q10 == 8
	replace relationcs = "Brother/sister of reference person" if HHLINK_Q10 == 9
	replace relationcs = "Other relative" if HHLINK_Q10 == 10
	replace relationcs = "Other non-relative" if HHLINK_Q10 == 11
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital = .
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
	recode migrated_binary (1 = 0) (2 = 1)
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen migrated_years = 1 if migrated_binary == 1
	replace migrated_years = . if migrated_binary != 1
	label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban = .
	replace migrated_from_urban = . if migrated_binary != 1
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen migrated_from_cat = .
	replace migrated_from_cat = . if migrated_binary != 1
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country" 6 "Within country, admin unknown" 7 "Wholly unknow"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen migrated_from_code = ""
	replace migrated_from_code = "" if migrated_binary != 1
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country = ""
	replace migrated_from_country = "" if migrated_binary != 1
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason = .
	replace migrated_reason = . if migrated_binary != 1
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

gen byte ed_mod_age = 15
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school = EDUCFED4_Q99
	recode school (2 = 0)
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen byte literacy = .
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>

/*
1 - No education
2 - From 1. to 3. grade of eight-year primary school
3 - From 1. to 4. grade of nine-year primary school
4 - From 4. to 7. grade of eight-year elementary school
5 - From 5. to 8. grade of a nine-year elementary school
6 - Elementary school (eight years, nine years)
7 - Vocational high school lasting 1 or 2 years
8 - Vocational high school lasting 3 years
9 - Vocational high school lasting 4 years
10 - Gymnasium
11 - Specialization after high school
12 - High school or 1st degree faculty
13 - Academic studies lasting 4-4.5 years, I cycle studies
14 - Academic studies lasting 5-6 years, specialist and master studies, integrated I and II cycle studies
15 - Doctoral or III cycle studies
*/
	gen byte educy = .
	replace educy = 0 if HATLEVEL_Q96 == 1 
	replace educy = 2 if inlist(HATLEVEL_Q96,2,3)
	replace educy = 6 if inlist(HATLEVEL_Q96,4,5) 
	replace educy = 9 if HATLEVEL_Q96 == 6
	replace educy = 10 if HATLEVEL_Q96 == 7
	replace educy = 12 if HATLEVEL_Q96 == 8
	replace educy = 13 if HATLEVEL_Q96 == 9
	replace educy = 14 if HATLEVEL_Q96 == 10
	replace educy = 15 if HATLEVEL_Q96 == 11
	replace educy = 16 if HATLEVEL_Q96 == 12
	replace educy = 20 if HATLEVEL_Q96 == 13
	replace educy = 22 if HATLEVEL_Q96 == 14
	replace educy = 25 if HATLEVEL_Q96 == 15
	
	
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7 = .
	replace educat7 = 1 if HATLEVEL_Q96 == 1
	replace educat7 = 2 if inlist(HATLEVEL_Q96,2,3)
	replace educat7 = 3 if inlist(HATLEVEL_Q96,4,5)
	replace educat7 = 4 if inlist(HATLEVEL_Q96,6)
	replace educat7 = 5 if inlist(HATLEVEL_Q96,7,8,9,10)
	replace educat7 = 6 if inlist(HATLEVEL_Q96,11,12)
	replace educat7 = 7 if inlist(HATLEVEL_Q96,13,14,15)
	label var educat7 "Level of education 1"
	la de lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete"
	label values educat7 lbleducat7
*</_educat7_>


*<_educat5_>
	gen byte educat5 = educat7
	recode educat5 (4 = 3) (5 = 4) (6 7 = 5)
	label var educat5 "Level of education 2"
	la de lbleducat5 1 "No education" 2 "Primary incomplete"  3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>


*<_educat4_>
	gen byte educat4 = educat7
	recode educat4 (2 3 4 = 2) (5 = 3) (6 7 = 4)
	label var educat4 "Level of education 3"
	la de lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 lbleducat4
*</_educat4_>


*<_educat_orig_>
	gen educat_orig = ""
	replace educat_orig = "No education" if HATLEVEL_Q96 == 1
	replace educat_orig = "From 1. to 3. grade of eight-year primary school" if HATLEVEL_Q96 == 2
	replace educat_orig = "From 1. to 4. grade of nine-year primary school" if HATLEVEL_Q96 == 3
	replace educat_orig = "From 4. to 7. grade of eight-year elementary school" if HATLEVEL_Q96 == 4
	replace educat_orig = "From 5. to 8. grade of a nine-year elementary school" if HATLEVEL_Q96 == 5
	replace educat_orig = "Elementary school (eight years, nine years)" if HATLEVEL_Q96 == 6
	replace educat_orig = "Vocational high school lasting 1 or 2 years" if HATLEVEL_Q96 == 7
	replace educat_orig = "Vocational high school lasting 3 years" if HATLEVEL_Q96 == 8
	replace educat_orig = "Vocational high school lasting 4 years" if HATLEVEL_Q96 == 9
	replace educat_orig = "Gymnasium" if HATLEVEL_Q96 == 10
	replace educat_orig = "Specialization after high school" if HATLEVEL_Q96 == 11
	replace educat_orig = "High school or 1st degree faculty" if HATLEVEL_Q96 == 12
	replace educat_orig = "Academic studies lasting 4-4.5 years, I cycle studies" if HATLEVEL_Q96 == 13
	replace educat_orig = "Academic studies lasting 5-6 years, specialist and master studies, integrated I and II cycle studies" if HATLEVEL_Q96 == 14
	replace educat_orig = "Doctoral or III cycle studies" if HATLEVEL_Q96 == 15
	label var educat_orig "Original survey education code"
*</_educat_orig_>

*<_educat_isced_>
	gen educat_isced = .
	
	label var educat_isced "ISCED standardised level of education"
*</_educat_isced_>


*----------6.1: Education cleanup------------------------------*

*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
local ed_vars "school literacy educy educat7 educat5 educat4 educat_orig educat_isced"

foreach ed_var of local ed_vars {
	cap confirm numeric variable `ed_var'
	if _rc == 0 { // is indeed numeric
		replace `ed_var' = . if ( age < ed_mod_age & !missing(age) )
	}
	else { // is not
		replace `ed_var' = "" if ( age < ed_mod_age & !missing(age) )
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

	*They apply labour realted questions if the individual: 15<= age <= 89
	gen byte lstatus = .
	
	***employed***
	
	*ICLS-13 DEFINITION: "The employed comprise all persons above a specified age who, during a specified brief period, either:

		*(a) performed any work at all for pay or profit (it has to include market interaction), or

		*(b) were temporarily absent from a job in which they had already worked and to which they had a formal attachment or from which they were temporarily absent due to, for example, illness, vacation, industrial dispute or other reasons."
		
	replace lstatus = 1 if EMPSTAT_Q4 == 1
	
	***unemployed***
	
	*seeking work
	
	gen active = (SEEKJOB_Q74 == 1)
	
	*Available for work
	gen passive = (AVAILBLE_Q90 == 1)
	
	*Future starters: Have found a job which will start in no more than 3 months
	gen future_starter = (FOUNDJOB_Q75 == 2 | STARTJOB_Q76 == 1)
	
	replace lstatus = 2 if (passive == 1 & active == 1) & missing(lstatus)
	replace lstatus = 2 if (future_starter == 1) & missing(lstatus)
	
	***NLF***
	replace lstatus = 3 if missing(lstatus) 
	
	replace lstatus = . if age < minlaborage
	replace lstatus = . if age > 89
	
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = (passive == 1 | active == 1)
	replace potential_lf = . if age < minlaborage & !missing(age)
	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen byte underemployment = AVAILBLE_Q64
	recode underemployment (2 = 0)
	replace underemployment = . if age < minlaborage & !missing(age)
	replace underemployment = . if lstatus != 1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	/*
	1 - 	Education or training
	2 - 	Own illness or disability
	3 - 	Care responsibilities
	4 - 	Other family reasons
	5 - 	Other personal reasons
	6 - 	Retirement
	7 - 	Other reasons
	
	
	1 - 	Education or training
	2 - 	Illness or disability
	3 - 	Care responsibilities
	4 - 	Other family reasons
	5 - 	Other personal reasons
	6 - 	Other reasons
	*/
	gen byte nlfreason1 = WANTREAS_Q79
	recode nlfreason1 (2 = 4) (3 = 2) (4 7 = 5) (6 = 3)
	gen byte nlfreason2 = AVAIREAS_Q91 
	recode nlfreason2 (2 = 4) (3 = 2) (4 6 = 5)
	
	gen nlfreason = nlfreason1
	replace nlfreason = nlfreason2 if missing(nlfreason)
	
	replace nlfreason = . if lstatus != 3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l = SEEKDUR_Q89
	recode unempldur_l (1 = 0) (2 = 1) (4 = 6) (5 = 12) (6 = 18) (7 = 24) (8 = 48)
	replace unempldur_l = . if lstatus != 2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u = SEEKDUR_Q89
	recode unempldur_u (3 = 5) (4 = 11) (5 = 17) (6 = 23) (7 = 47) (8 = .)
	replace unempldur_u = . if lstatus != 2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	/*
	1 - 	Owner/co-owner with employees - employer 
	2 - 	Farmer on his own farm with an employee 
	3 - 	Owner/co-owner without employees - self-employed
	4 - 	Farmer on his own farm without employees 
	5 - 	You work for a foreign organization - an employee
	6 - 	You work for an employer - an employee
	7 - 	Family worker (unpaid)
	*/
	gen byte empstat = STAPRO_Q11
	recode empstat (1 2 = 3) (3 = 4) (5 6 = 1) (7 = 2)
	replace empstat = . if lstatus != 1
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	/*
	1 - 	State owned
	2 - 	Private owned
	3 - 	Private - unregistered 
	4 - 	Other - registered
	5 - 	Other - unregistered
	6 - 	I do not know
	*/
	gen byte ocusec = Svojina_Q10
	recode ocusec (3 = 2)(5 6 = 4)
	replace ocusec = . if lstatus != 1
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig = NACE3D_Q9
	replace industry_orig = "" if lstatus != 1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
*They use NACE 2 which is in line with ISIC rev 4 at 2 digits level
	gen industrycat_isic = substr(industry_orig, 1, 2) + "00"

	replace industrycat_isic = "" if industrycat_isic == "00" | lstatus !=1
	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20checkç
	/*
	preserve 
	drop if missing(industrycat_isic)
	int_classif_universe, var(industrycat_isic) universe(ISIC)
	count
	list
	assert `r(N)' == 0
	restore 
	*/

	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen byte industrycat10 = real(substr(industrycat_isic,1,2))
	recode industrycat10 (1/3 = 1) (5/9 = 2) (10/33 = 3) (35/39 = 4) (41/43 = 5) (45/47 55/56 = 6) (49/53 58/63 = 7) (64/82 = 8) (84 = 9) (85/99 = 10)
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
*</_industrycat10_>


*<_industrycat4_>
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
	gen occup_orig = ISCO4D_Q8 if lstatus == 1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	gen occup_isco = occup_orig
	replace occup_isco = "" if occup_isco == "." | lstatus != 1

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	/*
	preserve 
	drop if missing(occup_isco)
	int_classif_universe, var(occup_isco) universe(ISCO)
	count
	list
	assert `r(N)' == 0
	restore
	*/
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	gen byte occup = real(substr(occup_isco,1,1))
	recode occup (0 = 10)
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
	*Some respondents agreed to report their exact salary, while others did not. For those who declined, a question about their salary range was asked instead.
	/*
	Up to 200 KM — 1
	201 – 300 KM — 2
	301 – 400 KM — 3
	401 – 500 KM — 4
	501 – 700 KM — 5
	701 – 900 KM — 6
	901 – 1,500 KM — 7
	1,501 – 2,500 KM — 8
	2,501 KM and more — 9
	*/
	gen double wage_no_compen = INCSUM_Q23 
	replace wage_no_compen = . if lstatus != 1
	replace wage_no_compen = . if empstat == 2 //non-paid employees
	
	*individuals who answered intervals, use the middle point
	gen wage_ranges = INCDECIL_Q24
	recode wage_ranges (1 = 100) (2 = 250) (3 = 350) (4 = 450) (5 = 600) (6 = 800) (7 = 1200) (8 = 2000) (9 = 2500) (99 = .)
	replace wage_no_compen = wage_ranges if missing(wage_no_compen) & empstat != 2

	label var wage_no_compen "Last wage payment primary job 7 day recall"
	*Generate a dummy variable: 1 if the salary is exact, 0 if the salary is given in ranges.
	
	gen dwage = (IZNOSPLATA_Q22 == 1) if !missing(wage_no_compen)
	la de lbldwage 1 "Continous" 0 "Ranges"
	label values dwage lbldwage	
*</_wage_no_compen_>


*<_unitwage_>

/* <_unitwage_note>
	Unitwage refers to the unit used to record wage_no_compen, *not* the unit of
	general wage payent. For example, PHL LFS asks about wage periodicity, then
	asks for basic daily pay. The value of that pay would be wage_no_compen,
	while unitwage is code 1 ("Daily") for all, regardless of the periodicity.
</_unitwage_note> */

	gen byte unitwage = 5 if !missing(wage_no_compen)
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours = HVACTUAL_Q39 if !missing(wage_no_compen)
	replace whours = . if whours == 0
	replace whours = HWUSUAL_Q37 if missing(whours) & !missing(wage_no_compen)
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
	gen byte contract = Ugovori_Q14 if lstatus == 1
	recode contract (2 3 = 0)
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte healthins = OSIGURAN_Q28 if lstatus == 1
	recode healthins (2 = 0) (3 = .)
	label var healthins "Employment has health insurance primary job 7 day recall"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen byte socialsec = Penziono_Q31 if lstatus == 1
	recode socialsec (2 = 0)(3 = .)
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
/*
01-09	Exact number of persons if that number is from 1 to 9
10 - 	From 10 to 19
11 - 	From 20 to 49 
12 - 	From 50 to 249
13 - 	250 and more people
14 - 	Don't know, but less than  10 a person
15 - 	Don't know, but less than  10 a person

*/
	gen firmsize_l = SIZEFIRM_Q27 if lstatus == 1
	recode firmsize_l (11 = 20) (12 = 50) (13 = 250) (14 15 = .)
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen firmsize_u = SIZEFIRM_Q27 if lstatus == 1
	recode firmsize_u (10 = 19) (11 = 49) (12 = 249) (13 = .) (14 15 = .)
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen byte empstat_2 = STAPRO2J_Q58
	recode empstat_2 (1 2 = 3) (3 = 4) (5 6 = 1) (7 = 2)
	replace empstat_2 = . if lstatus != 1
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2 = .
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2 = NACE2J2D_Q59 if lstatus == 1 & !missing(empstat_2)
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	gen industrycat_isic_2 = substr(industry_orig_2, 1, 2) + "00"
	replace industrycat_isic_2 = "" if industrycat_isic_2 == "00" | lstatus !=1 | missing(empstat_2)
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen byte industrycat10_2 = real(substr(industrycat_isic_2,1,2))
	recode industrycat10_2 (1/3 = 1) (5/9 = 2) (10/33 = 3) (35/39 = 4) (41/43 = 5) (45/47 55/56 = 6) (49/53 58/63 = 7) (64/82 = 8) (84 = 9) (85/99 = 10)
	label var industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
	label values industrycat10_2 lblindustrycat10
*</_industrycat10_2_>


*<_industrycat4_2_>
	gen byte industrycat4_2 = industrycat10_2
	recode industrycat4_2 (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
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
	gen whours_2 = HWACTU2J_Q61 if !missing(empstat_2)
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

*If the number of months worked is missing, the harmonizer may assume that the person worked the whole year inputting the "average, commonly hours worked" (i.e., using usually worked hours instead of actual). Moreover, the harmonizer may assume that the person worked the whole year in this job (multiply monthly data by 12, weekly data by 48). Thus, the variable functions as an upper bound.

	egen t_hours_total = rowtotal(whours whours_2), missing
	replace t_hours_total = t_hours_total * 48
	label var t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>

	*just info of main job
	gen t_wage_nocompen_total = wage_no_compen * 12
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
	
	replace lstatus_year = . if age < minlaborage & !missing(age)
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>

*<_potential_lf_year_>
	gen byte potential_lf_year = .
	replace potential_lf_year = . if age < minlaborage & !missing(age)
	replace potential_lf_year = . if lstatus_year != 3
	label var potential_lf_year "Potential labour force status"
	la de lblpotential_lf_year 0 "No" 1 "Yes"
	label values potential_lf_year lblpotential_lf_year
*</_potential_lf_year_>


*<_underemployment_year_>
	gen byte underemployment_year = .
	replace underemployment_year = . if age < minlaborage & !missing(age)
	replace underemployment_year = . if lstatus_year == 1
	label var underemployment_year "Underemployment status"
	la de lblunderemployment_year 0 "No" 1 "Yes"
	label values underemployment_year lblunderemployment_year
*</_underemployment_year_>


*<_nlfreason_year_>
	gen byte nlfreason_year = .
	label var nlfreason_year "Reason not in the labor force"
	la de lblnlfreason_year 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason_year lblnlfreason_year
*</_nlfreason_year_>


*<_unempldur_l_year_>
	gen byte unempldur_l_year = .
	label var unempldur_l_year "Unemployment duration (months) lower bracket"
*</_unempldur_l_year_>


*<_unempldur_u_year_>
	gen byte unempldur_u_year = .
	label var unempldur_u_year "Unemployment duration (months) upper bracket"
*</_unempldur_u_year_>

}

*----------8.7: 12 month reference main job------------------------------*

{

*<_empstat_year_>
	gen byte empstat_year = .
	replace empstat_year = . if lstatus_year != 1
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
	/*
	preserve 
	drop if missing(industrycat_isic_year)
	int_classif_universe, var(industrycat_isic_year) universe(ISIC)
	count
	list
	assert `r(N)' == 0
	restore 
	*/

	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>

*<_industrycat10_year_>
	gen byte industrycat10_year = .
	label var industrycat10_year "1 digit industry classification, primary job 12 month recall"
	la de lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_year lblindustrycat10_year
*</_industrycat10_year_>


*<_industrycat4_year_>
	gen byte industrycat4_year = industrycat10_year
	recode industrycat4_year (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
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
	gen byte industrycat4_2_year = industrycat10_2_year
	recode industrycat4_2_year (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
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
	replace njobs = 1 if NUMJOBPROV_Q56 == 1
	replace njobs = 2 if NUMJOBPROV_Q56 == 2
	replace njobs = 3 if NUMJOBPROV_Q56 == 3
	replace njobs = . if lstatus != 1
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
	local lab_vars "minlaborage lstatus nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome"

	foreach lab_var of local lab_vars {
		cap confirm numeric variable `lab_var'
		if _rc == 0 { // is indeed numeric
			replace `lab_var' = . if ( age < minlaborage & !missing(age) )
		}
		else { // is not
			replace `lab_var' = "" if ( age < minlaborage & !missing(age) )
		}

	}

*</_% Correction min age_>
}


/*%%=============================================================================================
	9: Final steps
==============================================================================================%%*/

quietly{

*<_% KEEP VARIABLES - ALL_>

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu ssu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome dwage

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu ssu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen dwage unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

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

foreach kept_var of local kept_vars {
	
	capture assert missing(`kept_var')
	if !_rc drop `kept_var'
   
}

*</_% DELETE MISSING VARIABLES_>


*<_% COMPRESS_>

compress

*</_% COMPRESS_>


*<_% SAVE_>

save "`path_output'/`out_file'", replace

*</_% SAVE_>