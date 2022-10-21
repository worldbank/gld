
/*%%=============================================================================================
	0: GLD Harmonization Preamble
================================================================================================*/

/* -----------------------------------------------------------------------

<_Program name_>				IND_2007_EUS_V01_M_V02_A_GLD_ALL.do </_Program name_>
<_Application_>					STATA 16 <_Application_>
<_Author(s)_>						World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2021-06-09 </_Date created_>
<_Date modified>				2021-10-06 </_Date modified_>

-------------------------------------------------------------------------

<_Country_>							India </_Country_>
<_Survey Title_>				Employment and Unemployment Survey: NSS 64th Round : July 2007 - June 2008 </_Survey Title_>
<_Survey Year_>					2007 </_Survey Year_>
<_ICLS Version_>				Unknown (does not seem to follow ICLS-13 </_ICLS Version_>
<_Study ID_>						DDI-IND-NSSO-EUMS-2007-v1 </_Study ID_>
<_Data collection from (M/Y)_>	07/2007 </_Data collection from (M/Y)_>
<_Data collection to (M/Y)_>	06/2008 </_Data collection to (M/Y)_>
<_Source of dataset_> 			http://microdata.gov.in/nada43/index.php/catalog/117 </_Source of dataset_>
<_Sample size (HH)_> 				125,578 </_Sample size (HH)_>
<_Sample size (IND)_> 			572,254 </_Sample size (IND)_>
<_Sampling method_>

A stratified multi-stage design was adopted for the 64th round survey. T
he first stage units (FSU) were the 2001 census villages (Panchayat wards in case of Kerala)
in the rural sector and Urban Frame Survey (UFS) blocks in the urban sector.
However, for the newly declared towns and out growths (OGs) in Census 2001 for
which UFS were not done, each individual town/ OG were considered as an FSU.
The ultimate stage units (USU) were the households in both the sectors.
In case of large FSUs, i.e. villages/ towns/ blocks requiring hamlet-group (hg)/
sub-block (sb) formation, one intermediate stage was the selection of two hgs/
sbs from each FSU. Details of the sample design and estimation procedure is
given as a document in external resource .

											</_Sampling method_>
<_Geographic coverage_> 		State Level </_Geographic coverage_>
<_Currency_> 								Indian Rupee </_Currency_>
-----------------------------------------------------------------------

<_ICLS Version_>				ICLS 13 </_ICLS Version_>
<_ISCED Version_>				ISCED 1997 </_ISCED Version_>
<_ISCO Version_>				ISCO 1988 </_ISCO Version_>
<_OCCUP National_>			NCO 2004 </_OCCUP National_>
<_ISIC Version_>				ISIC 3.1 </_ISIC Version_>
<_INDUS National_>			NIC 2004 </_INDUS National_>

-----------------------------------------------------------------------

<_Version Control_>

* Date: 2022-09-25 Changes to more accurately define what is a first jobs and a second job in 12 month recall, change subnatid1 to string, improve subnatidsurvey

</_Version Control_>

-------------------------------------------------------------------------*/


/*%%=============================================================================================
	1: Setting up of program environment, dataset
================================================================================================*/

*----------1.1: Initial commands------------------------------*

clear
set more off
set mem 800m

*----------1.2: Set directories------------------------------*

local path_in "Y:/GLD/IND/IND_2007_EUS/IND_2007_EUS_v01_M/Data/Stata"
local path_output "Y:/GLD/IND/IND_2007_EUS/IND_2007_EUS_v01_M_v02_A_GLD/Data/Harmonized"

*----------1.3: Database assembly------------------------------*

* Start with Block 5.3 as this has several lines per individual
use "`path_in'/Block-5-members-time-disposition-records.dta", clear

********************************************************************************
********************************************************************************
* Sorting procedure

/*==============================================================================
Current weekly activity is selected based on this order:
	1. Equal to current weekly activity variable
	2. Activity status classification (see below)
	3. Number of days worked in a week
	4. If number of days are equal between two employment activities, the status
	code that is smaller in value is taken as the CWA (e.g., activites 11 and 51
	are worked for 3.5 days each; activity 11 will be the CWA because it is smaller
	in value than 51.

	Rule #1 is added because otherwise, CWA will not be entirely equal to activity status 1
==============================================================================*/


/* Need to classify activity status into the following:

	a. Working status
	b. Non-working status but seeking employment
	c. Neither working nor available for work

*/

gen first = 1 if B5_c4 == B5_c18
replace first = 2 if B5_c4 != B5_c18

destring B5_c4, gen(priority_tag)
gen num_status = priority_tag
* Classify the level of priority
recode priority_tag 11/72=1 81 82=2 91/98=3 99=.

* Decreasingorder of number of days worked
gen neg_days = -(B5_c14)

* Generate PID
egen PID = concat(key_hhold B5_c1)

sort PID first priority_tag neg_days num_status
bys PID: gen runner = _n

* Extract original serial number
destring B5_c3, gen(original_serial)

* How many cases wherein this priority order is not followed
count if B5_c4! =  B5_c18 & runner==1

/*==============================================================================
What are the implications?

1. Individual's employment status can be determined on the basis of status 1 or the
	current weekly activity status. No need to recode everything as both variables
	are the same!

2. The NSO under the CWA is the same as activity 1

3. These is no overlap between activity 2 and activity 1!

==============================================================================*/

keep B5_c4 B5_c5 B5_c14 B5_c15 B5_c16 B5_c17 B5_c18 B5_c19 B5_c20 key_hhold  B5_c1 runner
reshape wide B5_c4 B5_c5 B5_c14 B5_c15 B5_c16 B5_c17 B5_c18 B5_c19 B5_c20, i(key_hhold B5_c1) j(runner)

* Check whether activities correctly coded in order - there should not be a third activity if
* there is no second activity.
count if missing(B5_c41) & !missing(B5_c42)
count if missing(B5_c42) & !missing(B5_c43)
count if missing(B5_c43) & !missing(B5_c44)


tempfile weekly_act
save `weekly_act'

* Generate unique id variable at person level
egen key_memb = concat(key_hhold B5_c1)

** Begin merging the other datasets

* Merge with block 4
merge m:1 key_memb using "`path_in'/Block-4-demographic-usual-activity-members-records.dta" , keep(master match) nogen

* Merge with block 1 - 3
gen key_Hhold = key_hhold

* Start with Block 1
merge m:1 key_Hhold using "`path_in'/Block-1-sample-household-identification-records.dta" , keep(master match) nogen

* Block 3dot1 - this data is not relevant for GLD
merge 1:1 key_memb using "`path_in'/Block-3dot1-out-migrants-records.dta" , keep(master match) nogen

* Block 3 only
gen Key_hhold = key_hhold
merge m:1 Key_hhold using "`path_in'/Block-3-household-characteristics-ecords.dta" , keep(master match) nogen

* Merge with block 6
merge 1:1 key_memb using "`path_in'/Block-6-members-migration-records.dta" , keep(master match) nogen

* Merge with Block 7
	// **Not need this for harmonization** //


/*%%=============================================================================================
	2: Survey & ID
================================================================================================*/


{

*<_countrycode_>
	gen str4 countrycode="IND"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "EUS"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "LFS"
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
	gen isco_version = "isco_1988"
	label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
	gen isic_version = "isic_3.1"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	gen int year = 2007
	label var year "Year of the start of the survey"
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
	gen int_year=.
	replace int_year = 2007 if inlist(Sub_Round,"1","2")
	replace int_year = 2008 if inlist(Sub_Round,"3","4")
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	* The date of interview variable is not in string
	tostring B2_q2i, gen(str_doi)
	* Ensure that they are all eight digits
	replace str_doi = "0" + str_doi if length(str_doi) == 5
	replace str_doi = "" if length(str_doi) !=6

	gen  int_month = substr(str_doi, -4, 2)
	destring int_month, replace
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
/* <_hhid_note>

	From different surveys a str9 should be created. In later surveys this is:
	FSU (str5) + seg_no (str1) + 2nd Stage Sample (str1) + Sample HH Id (str2).
	No need to have str11 or str13, fewer characters already specify uniquely
</_hhid_note> */
	egen str9 hhid = concat(FSU sub_block Ss_stratum Sample_hhold_No)
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
/* <_pid_note>

	Because there are so many variables for the same sample individual id, I drop
	them and keep only the data from block 5

</_pid_note> */
	count if B5_c1 != B4_c1 | B5_c1 ! = B6_c1 // all equal

	egen  str11 pid = concat(hhid B5_c1)
	label var pid "Individual ID"
	isid pid
*</_pid_>


*<_weight_>
/* <_weight_note>

	From the Use of Multiplier for Sch-10 and Sch-10.1 document

</_weight_note> */
	gen weight = wgt_combined

*</_weight_>


*<_psu_>
	gen psu = FSU
	label var psu "Primary sampling units"
*</_psu_>


*<_strata_>
	gen strata = Stratum
	label var strata "Strata"
*</_strata_>

*<_wave_>
	gen wave = Sub_Round
	label var wave "Survey wave"
*</_wave_>
}


/*%%=============================================================================================
	3: Geography
================================================================================================*/

{

*<_urban_>
	destring Sector, gen(urban)
	recode urban (1 = 0) (2 = 1)
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>

*<_subnatid1_>
	destring state, gen(subnatid1)
	label de lblsubnatid1  28 "28 - Andhra Pradesh" 12 "12 - Arunachal Pradesh" 18 "18 - Assam" 10 "10 - Bihar" 30 "30 - Goa" 24 "24 - Gujrat" 6 "6 - Haryana" 2 "2 - Himachal Pradesh" 1 "1 - Jammu & Kashmir" 29 "29 - Karnataka" 32 "32 - Kerala" 23 "23 - Madhya Pradesh" 27 "27 - Maharastra" 14 "14 - Manipur" 17 "17 - Meghalaya" 15 "15 - Mizoram" 13 "13 - Nagaland" 21 "21 - Orissa" 3 "3 - Punjab" 8 "8 - Rajasthan" 11 "11 - Sikkim" 33 "33 - Tamil Nadu" 16 "16 - Tripura" 9 "9 - Uttar Pradesh" 19 "19 - West Bengal" 35 "35 - Andaman & Nicober" 4 "4 - Chandigarh" 26 "26 - Dadra & Nagar Haveli" 25 "25 - Daman & Diu" 7 "7 - Delhi" 31 "31 - Lakshadweep" 34 "34 - Pondicheri" 22 "22 - Chhattisgarh" 20 "20 - Jharkhand" 5 "5 - Uttaranchal"
	label values subnatid1 lblsubnatid1
	
	* Convert numeric into string
	decode subnatid1, gen(subnatid1_str)
	rename subnatid1 subnatid1_num
	rename subnatid1_str subnatid1
	
	label var subnatid1 "Subnational ID at First Administrative Level"
	
	* Create correspondence table for migrated_from_code
	preserve
		collapse (first) state_name=subnatid1, by(subnatid1_num)
		rename subnatid1_num migrated_from_code
		tempfile state_name_correspondence
		save `state_name_correspondence'
	restore
	
*</_subnatid1_>

*<_subnatid2_>
	destring District, gen(subnatid2)
	label var subnatid2 "District CodNSS Region - not a national ID but useful to later re-assing states (e.g., Uttarkhand)"
*</_subnatid2_>


*<_subnatid3_>
	gen byte subnatid3 = .
	label de lblsubnatid3 1 "1 - Name"
	label values subnatid3 lblsubnatid3
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
	gen subnatidsurvey = ""
	replace subnatidsurvey = subnatid1 + " - Urban" if urban == 1
	replace subnatidsurvey = subnatid1 + " - Rural" if urban == 0
	label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>


*<_subnatid1_prev_>
/* <_subnatid1_prev_note>

	Changes occured in 2000, so EUS 1999 has old, EUS 2004 has new codes, 
	EUS 2004 has the subnatid1_prev info, here no changes.

</_subnatid1_prev_note> */
	gen subnatid1_prev = ""
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
================================================================================================*/

{

*<_hsize_>
	bys hhid: gen hsize = _N
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen age = B4_c5
	label var age "Individual age"
*</_age_>


*<_male_>
	destring B4_c4, gen(male)
	recode male (2 = 0)
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>

	gen relationharm = B4_c3
	destring relationharm, replace
	recode relationharm (3 5 = 3) (7=4) (4 6 8 = 5) (9=6) (0=.)
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = B4_c3
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	destring B4_c6, gen(marital)
	recode marital (1 = 2) (2 = 1) (3 = 5) (0 = .)
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
================================================================================================*/


{

*<_migrated_mod_age_>
	gen migrated_mod_age = 0
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time = 99
	label var migrated_ref_time "Reference time applied to migration questions"
*</_migrated_ref_time_>


*<_migrated_binary_>
	destring B6_c7, gen(migrated_binary)
	recode migrated_binary (2 = 0)
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen migrated_years = B6_c10
	label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban = .
	replace migrated_from_urban = 1 if inlist(B6_c11, "2", "4", "6") & migrated_binary == 1
	replace migrated_from_urban = 0 if inlist(B6_c11, "1", "3", "5") & migrated_binary == 1
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen migrated_from_cat = .
	replace migrated_from_cat = 2 if inlist(B6_c11, "1", "2") & migrated_binary == 1
	replace migrated_from_cat = 3 if inlist(B6_c11, "3", "4") & migrated_binary == 1
	replace migrated_from_cat = 4 if inlist(B6_c11, "5", "6") & migrated_binary == 1
	replace migrated_from_cat = 5 if inlist(B6_c11, "7") & migrated_binary == 1
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	destring B6_c13, gen(helper_var)
	gen migrated_from_code = .
	replace migrated_from_code = subnatid1_num if inrange(migrated_from_cat,1,3)
	replace migrated_from_code = helper_var if migrated_from_cat == 4
	* replace as missing if they claim they came from another state (from_cat = 4) but state code is actually a country (>33)
	replace migrated_from_code = . if (migrated_from_cat == 4 & helper_var > 33)
	
	* Read in correspondence to make codes into string descriptions
	merge m:1 migrated_from_code using "`state_name_correspondence'",  keep(match master) nogen
	drop migrated_from_code
	rename state_name migrated_from_code
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
	drop helper_var
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country = ""
	replace migrated_from_country = "AFG" if migrated_from_cat == 5 & B6_c13 == "41"
	replace migrated_from_country = "BAN" if migrated_from_cat == 5 & B6_c13 == "42"
	replace migrated_from_country = "BTN" if migrated_from_cat == 5 & B6_c13 == "43"
	replace migrated_from_country = "MLD" if migrated_from_cat == 5 & B6_c13 == "44"
	replace migrated_from_country = "NPL" if migrated_from_cat == 5 & B6_c13 == "45"
	replace migrated_from_country = "PAK" if migrated_from_cat == 5 & B6_c13 == "46"
	replace migrated_from_country = "SRL" if migrated_from_cat == 5 & B6_c13 == "47"
	replace migrated_from_country = "Gulf countries" if migrated_from_cat == 5 & B6_c13 == "48"
	replace migrated_from_country = "Other Asian" if migrated_from_cat == 5 & B6_c13 == "49"
	replace migrated_from_country = "USA" if migrated_from_cat == 5 & B6_c13 == "50"
	replace migrated_from_country = "Canada" if migrated_from_cat == 5 & B6_c13 == "51"
	replace migrated_from_country = "Other Americas" if migrated_from_cat == 5 & B6_c13 == "52"
	replace migrated_from_country = "UK" if migrated_from_cat == 5 & B6_c13 == "53"
	replace migrated_from_country = "Other Europe" if migrated_from_cat == 5 & B6_c13 == "54"
	replace migrated_from_country = "African countries" if migrated_from_cat == 5 & B6_c13 == "55"
	replace migrated_from_country = "Other World" if migrated_from_cat == 5 & B6_c13 == "99"
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>



*<_migrated_reason_>
	gen migrated_reason = .
	replace migrated_reason =  3 if inlist(B6_c16,"01", "02", "03", "04", "05", "06") & !missing(migrated_binary)
	replace migrated_reason =  2 if inlist(B6_c16,"07") & !missing(migrated_binary)
	replace migrated_reason =  1 if inlist(B6_c16,"16", "17") & !missing(migrated_binary)
	replace migrated_reason =  4 if inlist(B6_c16,"10") & !missing(migrated_binary)
	replace migrated_reason =  5 if missing(migrated_reason) & !missing(B6_c16)
	label de lblmigrated_reason 1 "Family reasons" 2 "Educational reasons" 3 "Employment" 4 "Forced (political reasons, natural disaster, …)" 5 "Other reasons"
	label values migrated_reason lblmigrated_reason
	label var migrated_reason "Reason for migrating"
*</_migrated_reason_>


}


/*%%=============================================================================================
	6: Education
================================================================================================*/


{

*<_ed_mod_age_>

/* <_ed_mod_age_note>

Education module is only asked to those XX and older.

</_ed_mod_age_note> */

gen byte ed_mod_age = 0
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>

/* <_school>

This variable is not available in the 2007 dataset.
However, it is available in other years

</_school> */

	gen byte school = .
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen byte literacy = .
	replace literacy = 0 if B4_c7 == "01"
	replace literacy = 1 if !inlist(B4_c7, "01", "00") & !missing(B4_c7)
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen educy=.
	label var educy "Years of education"
*</_educy_>



*<_educat7_>
	destring B4_c7, gen(genedulev)
	gen byte educat7 = .
	replace educat7= 1 if genedulev<=5
	replace educat7 = 2 if genedulev == 6 // Primary incomplete
	replace educat7 = 3 if genedulev == 7 // Primary complete
	replace educat7 = 4 if genedulev == 8 // Secondary incomplete
	replace educat7 = 5 if (genedulev == 10 | genedulev == 11) // Secondary complete
	replace educat7 = 6 if genedulev ==12
	replace educat7= 7 if genedulev==13| genedulev==14
	label var educat7 "Level of education 1"
	la de lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete"
	label values educat7 lbleducat7
	drop genedulev
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
	recode educat4 (2 3 4=2) (5=3) (6 7=4)
	label var educat4 "Level of education 3"
	la de lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 lbleducat4
*</_educat4_>


*<_educat_orig_>
 	gen educat_orig = B4_c7
 	label var educat_orig "Original survey education code"
 *</_educat_orig_>


*<_educat_isced_>
	* This is based on ISCED 1997 mapping
	destring B4_c7, gen(genedulev)
	gen educat_isced = .
	replace educat_isced = 0 if genedulev == 6
	replace educat_isced = 100 if genedulev == 7
	replace educat_isced = 200 if genedulev == 8
	replace educat_isced = 300 if genedulev == 10 | genedulev == 11
	replace educat_isced = 400 if genedulev == 12
	replace educat_isced = 500 if genedulev == 13
	replace educat_isced = 600 if genedulev == 14

	label var educat_isced "ISCED standardised level of education"
	drop genedulev
*</_educat_isced_>


*----------6.1: Education cleanup------------------------------*

*<_% Correction age_> age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
local ed_var "school literacy educy educat7 educat5 educat4 educat_isced"
foreach v of local ed_var {
	replace `v'=. if ( age < ed_mod_age & !missing(age) )
}

*</_% Correction age_> age_>


}



/*%%=============================================================================================
	7: Training
================================================================================================*/


{

*<_vocational_>
	gen vocational = .
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
================================================================================================*/


*<_minlaborage_>
	gen byte minlaborage = 0
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
	destring B5_c181, gen(lstatus)
	recode lstatus (11/72 98 = 1) (81=2) (82 91/97=3) (99=.)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = .
	replace potential_lf = 0 if lstatus == 3
	replace potential_lf = 1 if B5_c181 == "82"
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
	destring B5_c181, gen(nlfreason)
	recode nlfreason (11/81 98=.) (91=1) (92 93=2) (94=3) (95=4) (82 96 97=5)
	replace nlfreason = . if lstatus != 3 | (age < minlaborage & age != .)
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"
	* No duration of unemployment variable -- only for migration module
*</_unempldur_l_>


*<_unempldur_u_>
	gen unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"
	* No duration of unemployment variable -- only for migration module

*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	destring B5_c181, gen(empstat)
	recode empstat (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72 98 =1) (81/97 99=.)
	replace empstat=. if lstatus != 1 | (age < minlaborage & age != .)
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec = .
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig = B5_c191
	replace industry_orig = "" if lstatus != 1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>

/* <_industrycat_isic_note>

This year is the first to use NIC 2004. The intro to 
NIC 2004 says the codes are identical to ISIC 3.1 at 
four digits, but this is not true for the following 
cases:

 - 1713 (Preparation and spinning of textile fiber including weaving of textiles
(khadi/handloom))
 - 1714 (Finishing of textiles (khadi/handloom))
 These subgroups of 171 do not exist in ISIC 3.1, coded as 1710 
 
 - 1724 (Embroidery work, zari work and making of ornamental trimmings by hand)
 - 1725 (Manufacture of blankets, shawls, carpets, rugs and other similar textile products
by hand)
 These subgroups of 172 do not exist in ISIC 3.1, coded as 1720
 
 - 2711 to 2719 (subgroups to 271 Manufacture of Basic Iron & Steel)
 There are no subgroups in ISIC 3.1 so all should be coded as 2710

</_industrycat_isic_note> */

	gen industrycat_isic = substr(industry_orig, 1, 4)
	replace industrycat_isic = "" if industrycat_isic == "0000"
	* Corrections as explained in the note
	replace industrycat_isic = "1710" if inlist(industrycat_isic, "1713", "1714")
	replace industrycat_isic = "1720" if inlist(industrycat_isic, "1724", "1725")
	
	replace industrycat_isic = "2710" if inlist(industrycat_isic, "2711", "2712", "2713", "2714", "2715")
	replace industrycat_isic = "2710" if inlist(industrycat_isic, "2716", "2717", "2718", "2719")
	
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen red_indus =substr(industry_orig,1,2)
	destring red_indus, replace

	gen industrycat10 = .

	replace industrycat10=1 if red_indus>=00 & red_indus<=09
	replace industrycat10=2 if red_indus>=10 & red_indus<=14
	replace industrycat10=3 if red_indus>=15 & red_indus<=37
	replace industrycat10=4 if red_indus>=40 & red_indus<=41
	replace industrycat10=5 if red_indus>=45 & red_indus<=45
	replace industrycat10=6 if red_indus>=50 & red_indus<=59
	replace industrycat10=7 if red_indus>=60 & red_indus<=64
	replace industrycat10=8 if red_indus>=65 & red_indus<=74
	replace industrycat10=9 if  red_indus==75
	replace industrycat10=10 if red_indus>=80 & red_indus<=99

	replace industrycat10=. if lstatus != 1 | (age < minlaborage & age != .)
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
	drop red_indus
*</_industrycat10_>


*<_industrycat4_>
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4 "1 digit industry classification (Broad Economic Activities), primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
	gen occup_orig = B5_c201
	replace occup_orig = "" if lstatus != 1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	gen nco_04 = occup_orig
	gen x_indic = regexm(nco_04, "x|X|y|y")
	replace nco_04 = "099" if x_indic == 1
	replace nco_04 = "0" + nco_04 if length(nco_04) == 2
	replace nco_04 = "00" + nco_04 if length(nco_04) == 1

	merge m:1 nco_04 using "`path_in'/India_nco_04_to_isco_88.dta", nogen assert(match master)

	* Make isco four digit string
	tostring isco_88, replace
	replace isco_88 = "" if isco_88 == "."
	replace isco_88 = isco_88 + "0" if !missing(isco_88)

	gen occup_isco = isco_88
	replace occup_isco = "" if lstatus != 1
	drop x_indic nco_04 isco_88
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>

*<_occup_>
	gen code_04 = substr(occup_orig,1,1)
	gen x_indic = regexm(code_04, "x|X|y|y")
	replace code_04 = "" if x_indic == 1
	destring code_04, replace

	gen occup = .
	replace occup = code_04 if lstatus == 1 & (age >= minlaborage & age != .)
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
	drop x_indic code_04
*</_occup_>


*<_occup_skill_>
	gen occup_skill = .
	replace occup_skill = 3 if inrange(occup, 1, 3)
	replace occup_skill = 2 if inrange(occup, 4, 8)
	replace occup_skill = 1 if occup == 9
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_wage_no_compen_>
/* <_wage_no_compen_note>
	Technically should use cash, but we do not add in total
	later as cannot annualise it. Furthermore, the values are
	basically the same (compare the means), but total is present
	in 1181 cases where cash is not, while cash is tehere only
	in 3 cases where total is not, so overall better value to
	use.
<_wage_no_compen_note> */

	gen double wage_no_compen = B5_c171
	replace wage_no_compen=. if lstatus != 1 | (age < minlaborage & age != .)
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
	gen byte unitwage = 2
	replace unitwage=. if lstatus != 1 | (age < minlaborage & age != .)
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
/* <_whours_note>

	Data is recorded for the day as full day or half day, then summed up over the 7 days. Assume a full day has 8 hours

*</_whours_note> */
	gen whours = 8*B5_c141
	replace whours=. if lstatus != 1 | (age < minlaborage & age != .)
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	gen wmonths = .
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
/* <_wage_total_note>

	Since this is annualized but no information is given on how many months of work cannot fill it out

*</_wage_total_note> */
	gen wage_total = .
	replace wage_total=. if lstatus != 1 | (age < minlaborage & age != .)
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
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u=.
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen has_job_primary = inlist(B5_c181,"11", "12", "21", "31", "41", "51") | inlist(B5_c181, "61", "62", "71", "72", "98")
	destring B5_c42, gen(empstat_2)
	recode empstat_2 (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72 98 =1) (81/97 99=.)
	replace empstat_2=. if lstatus != 1 | (age < minlaborage & age != .)
	replace empstat_2 = . if has_job_primary == 0 & !missing(empstat_2)
	label var empstat_2 "Employment status during past week primary job 7 day recall"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status", modify
	label values empstat_2 lblempstat_2
	drop has_job_primary
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2 = .
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2 = B5_c52
	replace industry_orig_2 = "" if missing(empstat_2)
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	gen industrycat_isic_2 = industry_orig_2 + "00"
	replace industrycat_isic_2 = "" if missing(empstat_2)
	replace industrycat_isic_2 = "" if industrycat_isic_2 == "00"
	replace industrycat_isic_2 = "" if industrycat_isic_2 == "0000"
	
	* Corrections as explained in the note for industrycat_isic
	replace industrycat_isic_2 = "1710" if inlist(industrycat_isic_2, "1713", "1714")
	replace industrycat_isic_2 = "1720" if inlist(industrycat_isic_2, "1724", "1725")
	
	replace industrycat_isic_2 = "2710" if inlist(industrycat_isic_2, "2711", "2712", "2713", "2714", "2715")
	replace industrycat_isic_2 = "2710" if inlist(industrycat_isic_2, "2716", "2717", "2718", "2719")
	
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	destring industry_orig_2, gen(red_indus)

	gen industrycat10_2 = .
	replace industrycat10_2=1 if red_indus>=00 & red_indus<=09
	replace industrycat10_2=2 if red_indus>=10 & red_indus<=14
	replace industrycat10_2=3 if red_indus>=15 & red_indus<=39
	replace industrycat10_2=4 if red_indus>=40 & red_indus<=41
	replace industrycat10_2=5 if red_indus>=45 & red_indus<=45
	replace industrycat10_2=6 if red_indus>=50 & red_indus<=59
	replace industrycat10_2=7 if red_indus>=60 & red_indus<=64
	replace industrycat10_2=8 if red_indus>=65 & red_indus<=74
	replace industrycat10_2=9 if  red_indus==75
	replace industrycat10_2=10 if red_indus>=80 & red_indus<=99

	replace industrycat10_2 = . if lstatus != 1 | (age < minlaborage & age != .)
	replace industrycat10_2 = . if missing(empstat_2)
	label var industrycat10_2 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_2 lblindustrycat10_2
	drop red_indus
*</_industrycat10_2_>


*<_industrycat4_2_>
	gen byte industrycat4_2 = industrycat10_2
	recode industrycat4_2 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_2 "1 digit industry classification (Broad Economic Activities), secondary job 7 day recall"
	label values industrycat4_2 lblindustrycat4
*</_industrycat4_2_>


*<_occup_orig_2_>
	gen occup_orig_2 = .
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen occup_isco_2 = .
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_skill_2_>
	gen occup_skill_2 = .
	label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>


*<_occup_2_>
	gen byte occup_2 = .
	label var occup_2 "1 digit occupational classification secondary job 7 day recall"
	label values occup_2 lbloccup
*</_occup_2_>


*<_wage_no_compen_2_>
	gen double wage_no_compen_2 = B5_c172
	replace wage_no_compen_2=. if lstatus != 1 | (age < minlaborage & age != .)
	replace wage_no_compen_2 = . if missing(empstat_2)
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2 = 2
	replace unitwage_2=. if lstatus != 1 | (age < minlaborage & age != .)
	replace unitwage_2 = . if missing(empstat_2)
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_2 lblunitwage_2
*</_unitwage_2_>


*<_whours_2_>
	gen whours_2 = 8*B5_c142
	replace whours_2=. if lstatus != 1 | (age < minlaborage & age != .)
	replace unitwage_2 = . if missing(empstat_2)
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
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	gen byte firmsize_u_2 = .
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
	label var t_wage_nocompen_others "Annualized wage in all but primary & secondary jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_others_>


*<_t_wage_others_>
	gen t_wage_others = .
	label var t_wage_others "Annualized wage in all but primary and secondary jobs (12-mon ref period)"
*</_t_wage_others_total_>

}

*----------8.5: 7 day reference total summary------------------------------*

{
*<_t_hours_total_>
	egen t_hours_total = rowtotal(whours whours_2 t_hours_others), missing
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
/* <_lstatus_year_note>

	For a person to be employed use the concept of usual economic activity, that is principal
	activity and add secondary if the principal is not in employment byt secondary is.
	So a full time student working on the side is still in the labor force in this 12 month sense

</_lstatus_year_note> */
	destring B4_c9, gen(primary_help)
	recode primary_help  11/72=1 81 82=2 91/98=3 99=.
	destring B4_c14, gen(secondary_help)
	recode secondary_help  11/72=1 81 82=2 91/98=3 99=.
	* tab primary_help secondary_help,m
	* Cross tabulation let's us see which cases are the adders and true seconds
	gen adders = 1 if inrange(primary_help,2,3) & secondary_help == 1
	gen seconds = 1 if primary_help == 1 & secondary_help == 1

	gen lstatus_year = primary_help
	replace lstatus_year = 1 if adders == 1

	replace lstatus = . if age < minlaborage
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
	label var underemployment_year "Underemployment status"
	la de lblunderemployment_year 0 "No" 1 "Yes"
	label values underemployment_year lblunderemployment_year
*</_underemployment_year_>


*<_nlfreason_year_>
	destring B4_c9, gen(nlfreason_year)
	recode nlfreason_year 11/82=. 91=1 92 93=2 94=3 95=4 96/99=5
	replace nlfreason_year = . if lstatus_year != 3 | (age < minlaborage & age != .)
	label var nlfreason_year "Reason not in the labor force - 12 month recall"
	la de lblnlfreason_year 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
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
	destring B4_c9, gen(empstat_y1)
	recode empstat_y1 (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72=1) (81/99=.)
	destring B4_c14, gen(empstat_y2)
	recode empstat_y2 (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72=1) (81/99=.)

	gen empstat_year = empstat_y1
	replace empstat_year = empstat_y2 if adders == 1

	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
	drop empstat_y1 empstat_y2
*</_empstat_year_>


*<_ocusec_year_>
	gen byte ocusec_year = .
	label var ocusec_year "Sector of activity primary job 12 day recall"
	la de lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_year lblocusec_year
*</_ocusec_year_>

*<_industry_orig_year_>
	gen industry_orig_year = B4_c11
	replace industry_orig_year = B4_c16 if adders == 1
	replace industry_orig_year = "" if lstatus_year != 1
	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	gen industrycat_isic_year = substr(industry_orig_year,1,4)
	
	* Corrections as explained in the note for industrycat_isic
	replace industrycat_isic_year = "1710" if inlist(industrycat_isic_year, "1713", "1714")
	replace industrycat_isic_year = "1720" if inlist(industrycat_isic_year, "1724", "1725")
	
	replace industrycat_isic_year = "2710" if inlist(industrycat_isic_year, "2711", "2712", "2713", "2714", "2715")
	replace industrycat_isic_year = "2710" if inlist(industrycat_isic_year, "2716", "2717", "2718", "2719")
	
	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>


*<_industrycat10_year_>
	gen red_indus =substr(industry_orig_year,1,2)
	destring red_indus, replace

	gen byte industrycat10_year = .
    replace industrycat10_year=1 if red_indus>=00 & red_indus<=09
    replace industrycat10_year=2 if red_indus>=10 & red_indus<=14
    replace industrycat10_year=3 if red_indus>=15 & red_indus<=39
    replace industrycat10_year=4 if red_indus>=40 & red_indus<=41
    replace industrycat10_year=5 if red_indus>=45 & red_indus<=45
    replace industrycat10_year=6 if red_indus>=50 & red_indus<=59
    replace industrycat10_year=7 if red_indus>=60 & red_indus<=64
    replace industrycat10_year=8 if red_indus>=65 & red_indus<=74
    replace industrycat10_year=9 if red_indus==75
    replace industrycat10_year=10 if red_indus>=80 & red_indus<=99
	replace industrycat10_year= . if lstatus_year != 1 | (age < minlaborage & age != .)
	label var industrycat10_year "1 digit industry classification, primary job 12 month recall"
	la de lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_year lblindustrycat10_year
	drop red_indus
*</_industrycat10_year_>


*<_industrycat4_year_>
	gen byte industrycat4_year=industrycat10_year
	recode industrycat4_year (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_year "1 digit industry classification (Broad Economic Activities), primary job 12 month recall"
	la de lblindustrycat4_year 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4_year lblindustrycat4_year
*</_industrycat4_year_>


*<_occup_orig_year_>
	gen occup_orig_year = B4_c12
	replace occup_orig_year = B4_c17 if adders == 1
	replace occup_orig_year = "" if lstatus_year != 1
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	gen nco_04 = occup_orig_year
	gen x_indic = regexm(nco_04, "x|X|y|y")
	replace nco_04 = "" if x_indic == 1

	merge m:1 nco_04 using "`path_in'/India_nco_04_to_isco_88.dta", nogen assert(match master)

	* Make isco four digit string
	tostring isco_88, replace
	replace isco_88 = "" if isco_88 == "."
	replace isco_88 = isco_88 + "0" if !missing(isco_88)

	gen occup_isco_year = isco_88
	replace occup_isco_year = "" if lstatus_year != 1
	label var occup_isco_year "ISCO code of primary job 12 month recall"
	drop x_indic nco_04 isco_88
*</_occup_isco_year_>


*<_occup_year_>
	gen code_04 = substr(occup_orig_year,1,1)
	gen x_indic = regexm(code_04, "x|X|y|y")
	replace code_04 = "" if x_indic == 1
	destring code_04, replace

	gen occup_year = .
	replace occup_year = code_04 if lstatus_year == 1 & (age >= minlaborage & age != .)
	label var occup_year "1 digit occupational classification, secondary job 12 month recall"
	la de lbloccup_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_year lbloccup_year
	drop x_indic code_04
*</_occup_year_>


*<_occup_skill_year_>
	gen occup_skill_year = .
	replace occup_skill_year = 3 if inrange(occup_year, 1, 3)
	replace occup_skill_year = 2 if inrange(occup_year, 4, 8)
	replace occup_skill_year = 1 if occup_year == 9
	label var occup_skill_year "Skill based on ISCO standard primary job 12 month recall"
*</_occup_skill_year_>


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
	destring B4_c14, gen(empstat_2_year)
	recode empstat_2_year (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72=1) (81/99=.)
	replace empstat_2_year = . if lstatus_year != 1
	replace empstat_2_year = . if seconds != 1

	label var empstat_2_year "Employment status during past week secondary job 12 month recall"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2_year lblempstat_2_year
*</_empstat_2_year_>


*<_ocusec_2_year_>
	gen byte ocusec_2_year = .
	label var ocusec_2_year "Sector of activity secondary job 12 day recall"
	la de lblocusec_2_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_2_year lblocusec_2_year
*</_ocusec_2_year_>


*<_industry_orig_2_year_>
	gen industry_orig_2_year = B4_c16 if seconds == 1
	replace industry_orig_2_year = "" if missing(empstat_2_year)
	label var industry_orig_2_year "Original survey industry code, secondary job 12 month recall"
*</_industry_orig_2_year_>


*<_industrycat_isic_2_year_>
	gen industrycat_isic_2_year = substr(industry_orig_2_year, 1, 4)
	
	* Corrections as explained in the note for industrycat_isic
	replace industrycat_isic_2_year = "1710" if inlist(industrycat_isic_2_year, "1713", "1714")
	replace industrycat_isic_2_year = "1720" if inlist(industrycat_isic_2_year, "1724", "1725")
	
	replace industrycat_isic_2_year = "2710" if inlist(industrycat_isic_2_year, "2711", "2712", "2713", "2714", "2715")
	replace industrycat_isic_2_year = "2710" if inlist(industrycat_isic_2_year, "2716", "2717", "2718", "2719")
	
	label var industrycat_isic_2_year "ISIC code of secondary job 12 month recall"
*</_industrycat_isic_2_year_>


*<_industrycat10_2_year_>
	gen red_indus = substr(industry_orig_2_year,1,2)
  destring red_indus, replace

	gen industrycat10_2_year = .
	replace industrycat10_2_year=1 if red_indus>=00 & red_indus<=09
	replace industrycat10_2_year=2 if red_indus>=10 & red_indus<=14
	replace industrycat10_2_year=3 if red_indus>=15 & red_indus<=39
	replace industrycat10_2_year=4 if red_indus>=40 & red_indus<=41
	replace industrycat10_2_year=5 if red_indus>=45 & red_indus<=45
	replace industrycat10_2_year=6 if red_indus>=50 & red_indus<=59
	replace industrycat10_2_year=7 if red_indus>=60 & red_indus<=64
	replace industrycat10_2_year=8 if red_indus>=65 & red_indus<=74
	replace industrycat10_2_year=9 if  red_indus==75
	replace industrycat10_2_year=10 if red_indus>=80 & red_indus<=99

	replace industrycat10_2_year = . if lstatus_year != 1 | (age < minlaborage & age != .)
	replace industrycat10_2_year = . if missing(empstat_2_year)
	label var industrycat10_2_year "1 digit industry classification, secondary job 12 month recall"
	la de lblindustrycat10_2_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_2_year lblindustrycat10_2_year
	drop red_indus
*</_industrycat10_2_year_>


*<_industrycat4_2_year_>
	gen byte industrycat4_2_year=industrycat10_2_year
	recode industrycat4_2_year (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_2_year "1 digit industry classification (Broad Economic Activities), secondary job 12 month recall"
	label values industrycat4_2_year lblindustrycat4_year
*</_industrycat4_2_year_>


*<_occup_orig_2_year_>
	gen occup_orig_2_year = B4_c17 if seconds == 1
	replace occup_orig_2_year = "" if missing(empstat_2_year)
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
	gen nco_04 = occup_orig_2_year
	gen x_indic = regexm(nco_04, "x|X|y|y")
	replace nco_04 = "099" if x_indic == 1
	replace nco_04 = "0" + nco_04 if length(nco_04) == 2
	replace nco_04 = "00" + nco_04 if length(nco_04) == 1

	merge m:1 nco_04 using "`path_in'/India_nco_04_to_isco_88.dta", nogen keep(match master)

	* Make isco four digit string
	tostring isco_88, replace
	replace isco_88 = "" if isco_88 == "."
	replace isco_88 = isco_88 + "0" if !missing(isco_88)

	gen occup_isco_2_year = isco_88
	replace occup_isco_2_year = "" if lstatus_year != 1
	label var occup_isco_2_year "ISCO code of secondary job 12 month recall"
	drop x_indic nco_04 isco_88
*</_occup_isco_2_year_>



*<_occup_2_year_>
	gen code_04 = substr(occup_orig_2_year,1,1)
	gen x_indic = regexm(code_04, "x|X|y|y")
	replace code_04 = "" if x_indic == 1
	destring code_04, replace

	gen occup_2_year = .
	replace occup_2_year = code_04 if lstatus_year == 1 & (age >= minlaborage & age != .)
	label var occup_2_year "1 digit occupational classification, secondary job 12 month recall"
	la de lbloccup_2_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2_year lbloccup_2_year
	drop x_indic code_04
*</_occup_2_year_>


*<_occup_skill_2_year_>
	gen occup_skill_2_year = .

	replace occup_skill_2_year = 3 if inrange(occup_2_year, 1, 3)
	replace occup_skill_2_year = 2 if inrange(occup_2_year, 4, 8)
	replace occup_skill_2_year = 1 if occup_2_year == 9

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
	replace njobs = 1 if !missing(empstat_year)
	replace njobs = 2 if !missing(empstat_2_year)
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
	gen laborincome = .
	label var laborincome "Total annual individual labor income in all jobs, incl. bonuses, etc."
*</_laborincome_>


*----------8.13: Labour cleanup------------------------------*

{
*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
local lab_var "lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others  t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome"

foreach v of local lab_var {
	capture confirm numeric variable `v'
	if _rc != 0 {
		replace `v'="" if ( age < minlaborage & !missing(age) )
	}
	else {
		replace `v'=. if ( age < minlaborage & !missing(age) )
	}

}

*</_% Correction min age_>
}


/*%%=============================================================================================
	9: Final steps
================================================================================================*/

quietly{

*<_% KEEP VARIABLES - ALL_>

keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% ORDER VARIABLES_>

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

save "`path_output'\IND_2007_EUS_V01_M_V02_A_GLD_ALL.dta", replace

*</_% SAVE_>
