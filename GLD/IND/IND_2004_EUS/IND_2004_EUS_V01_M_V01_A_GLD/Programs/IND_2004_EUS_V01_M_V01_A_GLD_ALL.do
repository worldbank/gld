
/*%%=============================================================================================
	0: GLD Harmonization Preamble
================================================================================================*/

/* -----------------------------------------------------------------------

<_Program name_>				IND_2004_EUS_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>					STATA 16 <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2021-06-18 </_Date created_>
<_Date modified>				2021-06-18 </_Date modified_>

-------------------------------------------------------------------------

<_Country_>						India </_Country_>
<_Survey Title_>				Employment and Unemployment Survey: NSS 62th Round : July 2005 - June 2006 </_Survey Title_>
<_Survey Year_>					2004 </_Survey Year_>
<_ICLS Version_>				Unknown (does not seem to follow ICLS-13 </_ICLS Version_>
<_Study ID_>					DDI-IND-NSSO-EUMS-2004-v1 </_Study ID_>
<_Data collection from (M/Y)_>	07/2004 </_Data collection from (M/Y)_>
<_Data collection to (M/Y)_>	06/2005 </_Data collection to (M/Y)_>
<_Source of dataset_> 			http://microdata.gov.in/nada43/index.php/catalog/109 </_Source of dataset_>
<_Sample size (HH)_> 			124,680 </_Sample size (HH)_>
<_Sample size (IND)_> 			602,833 </_Sample size (IND)_>
<_Sampling method_>

In the 61st round survey, a stratified multi-stage sampling design was adopted for selection
of the sample units for rural as well as urban areas. The first stage units (FSUs)
were the census villages (panchayat wards for Kerala) for rural areas and the NSSO
Urban Frame Survey (UFS) blocks for urban areas. The ultimate stage units (USUs) were
the households for both rural and urban areas. Hamlet-groups/sub-blocks constituted
the intermediate stage whenever these were formed in the sample FSUs. For rural
areas, the list of 2001 census villages constituted the sampling frame for selection
of sample FSUs for most of the states. For the rural areas of Kerala, however, the
list of panchayat wards was used as the sampling frame for selection of panchayat
wards. For the urban areas, the latest lists of UFS blocks constituted the sampling
frame for selection of sample FSUs.

											</_Sampling method_>
<_Geographic coverage_> 		State Level </_Geographic coverage_>
<_Currency_> 					Indian Rupee </_Currency_>
-----------------------------------------------------------------------

<_ICLS Version_>				ICLS 13 </_ICLS Version_>
<_ISCED Version_>				ISCED 1997 </_ISCED Version_>
<_ISCO Version_>				ISCO 1988 </_ISCO Version_>
<_OCCUP National_>				NCO 1968 </_OCCUP National_>
<_ISIC Version_>				ISIC 3 </_ISIC Version_>
<_INDUS National_>				NIC 1998 </_INDUS National_>

-----------------------------------------------------------------------

<_Version Control_>

* Date: [YYYY-MM-DD] File: [As in Program name above] - [Description of changes]
* Date: [YYYY-MM-DD] File: [As in Program name above] - [Description of changes]

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

local path_in "C:\Users\wb529026\OneDrive - WBG\Documents\Country Work\IND\IND_2004_EUS\IND_2004_EUS_v01_M\Data\Stata"
local path_output "C:\Users\wb529026\OneDrive - WBG\Documents\Country Work\IND\IND_2004_EUS\IND_2004_EUS_v01_M_v01_A_GLD\Data\Harmonized"

*----------1.3: Database assembly------------------------------*


* Start with Block 5.3 as this has several lines per individual
use "`path_in'\Block_5pt3_level_06", clear

/*==============================================================================
Current weekly activity is selected based on this order:
	1. Activity status classification (see below)
	2. Number of days worked in a week
	3. If number of days are equal between two employment activities, the status
	code that is smaller in value is taken as the CWA (e.g., activites 11 and 51
	are worked for 3.5 days each; activity 11 will be the CWA because it is smaller
	in value than 51.

	Following this order, CWA = activity status 1
==============================================================================*/

/* Need to classify activity status into the following:

	a. Working status
	b. Non-working status but seeking employment
	c. Neither working nor available for work
*/

destring Current_day_activity_Status, gen(priority_tag)
gen num_status = priority_tag
* Classify the level of priority
recode priority_tag 11/72=1 81 82=2 91/98=3 99=.

* Decreasingorder of number of days worked
gen neg_days = -(Total_no_of_days_in_current_acti)


* Order the records such that priority 1 comes first


sort PID priority_tag neg_days num_status
bys PID: gen runner = _n

* Extract original serial number
destring Srl_no_of_current_day_activity, gen(original_serial)

* How many cases wherein this priority order is not followed
count if Current_day_activity_Status! =  Current_weekly_activity_status & runner==1 //0
	* majority of the cases is due to equal number of hours worked

/*==============================================================================
What are the implications?

1. Individual's employment status can be determined on the basis of status 1 or the
	current weekly activity status. No need to recode everything as both variables
	are the same!

2. The NSO under the CWA is the same as activity 1

3. These is no overlap between activity 2 and activity 1!

==============================================================================*/
* Switch serial numbering of activities to integer
destring Srl_no_of_current_day_activity, replace

* Ensure that nominal days work is constant within PID
destring No_of_days_nominal_work, gen(days_num)
by PID: egen constantdays = max(days_num)
drop days_num

keep Current_day_activity_Status Current_day_activity_NIC_1998_co Total_no_of_days_in_current_acti ///
Wage_salary_cash_during_the_week - Wage_salary_earnings_total_durin ///
Current_weekly_activity_status - Current_weekly_activity_NCO_1968 PID runner

/*==============================================================================
Issue: Current weekly activity is constant across Person id, but there are cases
		wherein the industry and occupation for each activity vary! Ideally, there
		should be 1:1 correspondence between NIC/NCO and CWA

Resolve: Include the NCO in the reshaping to wide, then keep only the first instance
But first, make sure that the first instance for employed is nonmissing
==============================================================================*/

* Because some variables are too long, I rename it below:
rename Current_day_activity_NIC_1998_co Current_activity_NIC1998_
rename Total_no_of_days_in_current_acti Total_no_days_activity_
rename Wage_salary_cash_during_the_week Total_cash_
rename Wage_salary_earnings_kind_during Total_kind_
rename Wage_salary_earnings_total_durin Total_earnings_
rename Current_weekly_activity_NCO_1968 Current_activity_NCO1968_

reshape wide Current_day_activity_Status Current_activity_NIC1998_ Total_no_days_activity_ ///
 Total_cash_ - Total_earnings_ Current_activity_NCO1968_, i(PID) j(runner)

destring Current_weekly_activity_status, gen(cwa_e)

*==============================================================================
* Need to count how many non-zero responses for industry/occupation variables

count if Current_activity_NCO1968_1 == "" & inrange(cwa_e, 11, 72)
count if Current_activity_NCO1968_2 == "" & inrange(cwa_e, 11, 72)

* there are 2,613 employed people with no occupation code

count if missing(Current_activity_NCO1968_1) & ///
(!missing(Current_activity_NCO1968_2) | !missing(Current_activity_NCO1968_3) | ///
!missing(Current_activity_NCO1968_4) | !missing(Current_activity_NCO1968_5) ///
& inrange(cwa_e, 11, 72))
* 7 cases wherein occupation code is recorded under the second instance
* Move this to first instance; ignore second instance

replace Current_activity_NCO1968_1 = Current_activity_NCO1968_2 if missing(Current_activity_NCO1968_1) ///
& !missing(Current_activity_NCO1968_2) & inrange(cwa_e, 11, 72)

count if Current_activity_NCO1968_1 == "" & inrange(cwa_e, 11, 72)
* Still 2606 employed people with no occupation code. Nothing we can do!
* 2606/602,833 employed people = 0.4%

* Next step, drop second, third and fourth NIC/NCO variables
drop Current_activity_NCO1968_2 Current_activity_NCO1968_3 ///
	Current_activity_NCO1968_4 Current_activity_NCO1968_5

ren Current_activity_NCO1968_1 Current_activity_NCO_1968

* Make sure that CWA = first activity
count if Current_day_activity_Status1 != Current_weekly_activity_status //zero

* Make sure that CWA is available for all
count if missing(Current_weekly_activity_status)  //zero

* Make sure that second is not missing when third is not missing
count if missing(Current_day_activity_Status2) & !missing(Current_day_activity_Status3) //zero

**** Looks like data is in good shape!

tempfile weekly_act
save `weekly_act'

** Begin merging the other datasets
* Merge with other block 5: usual principal activity status
merge 1:1 PID using "`path_in'/Block_5pt1_level_04.dta", assert(match) nogen

* Merge with subsidary activity status
tempfile subsidiary
preserve
	use "`path_in'/Block_5pt2_level_05.dta", clear
	rename Type_of_job_contract Type_of_job_contract2
	rename No_of_workers_in_the_enterprise  No_of_workers_in_the_enterprise2
	rename Enterprise_type Enterprise_type2
	rename Availability_of_social_security_ Availability_of_social_security2
	keep PID Type_of_job_contract2 Usual_subsidiary_economic_activi V22 V23 No_of_workers_in_the_enterprise2 Enterprise_type2 Availability_of_social_security2
	save `subsidiary'
restore

merge 1:1 PID using `subsidiary', assert(match master) nogen

* Merge with block 4
merge m:1 PID using "`path_in'/Block_4_level_03", assert(match) nogen

* Merge with blocks 1 - 3 level 01
* Should merge all, but one entry in using (Block 1 2 3) has HHID == "" which does not match evidently -> use keep
merge m:1 HHID using "`path_in'/Block_1_2_and_3_level_01.dta", keep(master match) nogen

* Merge with block 3pt1_level 02 - loan indebtedness
	** This is not needed for the purposes of the GLD


* Merge with block 6
preserve
	tempfile block62
	* Brief issue with Block 6
	use "`path_in'/Block_6_level_07.dta", clear
	keep PID Duration_spell_of_unemployment Whether_ever_worked Last_employment_Duration Last_employment_Status Last_employment_NIC_98 Last_employment_NCO_68 Reason_for_break_in_employment Reason_for_quitting_the_job
	* Four changes since PID has random blank space, replace with "0"
	replace PID = regexr(PID," ","0")
	save `block62'
restore

merge 1:1 PID using "`block62'", assert(match master) nogen

* Before merging with block 7 - 1
preserve
	tempfile block7
	use "`path_in'/Block_7pt1_level_08.dta", clear
	duplicates drop PID, force
	* there are 2 records with the same PID and same labor market information, just drop one of them
	save `block7'
restore

merge 1:1 PID using `block7', assert(match master) nogen


* Merge with block 7 - 2
preserve
	tempfile block72
	use "`path_in'/Block_7pt2_level_09.dta", clear
	duplicates drop PID, force
	* likewise, there are 2 records with the same PID and same labor market information, just drop one of them
	save `block72'
restore

merge 1:1 PID using `block72', assert(match master) nogen

* Not merge blocks 8 and 9 bec these are not relevant on the GLD


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
	gen isic_version = "isic_3"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	gen int year = 2004
	label var year "Year of the start of the survey"
*</_year_>


*<_vermast_>
	gen vermast = "V01"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen veralt = "V01"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen harmonization = "GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	gen int_year=.
	replace int_year = 2004 if inlist(Sub_round,"1","2")
	replace int_year = 2005 if inlist(Sub_round,"3","4")
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen  int_month = substr(Date_survey, -4, 2)
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
	egen str9 hhid = concat(FSU Hamlet Second_stage_stratum Sample_hhld_no)
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
/* <_pid_note>

	Because there are so many variables for the same sample individual id, I drop
	them and keep only the data from block 5

</_pid_note> */
	egen  str11 pid = concat(hhid Personal_serial_no)
	label var pid "Individual ID"
	isid pid
*</_pid_>


*<_weight_>
/* <_weight_note>

	From the Use of Multiplier for Sch-10 and Sch-10.1 document

</_weight_note> */
	gen weight = WEIGHT_COMBINED

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
	gen wave = Sub_round
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
	destring State, gen(subnatid1)
	label de lblsubnatid1  28 "28 - Andhra Pradesh" 12 "12 - Arunachal Pradesh" 18 "18 - Assam" 10 "10 - Bihar" 30 "30 - Goa" 24 "24 - Gujrat" 6 "6 - Haryana" 2 "2 - Himachal Pradesh" 1 "1 - Jammu & Kashmir" 29 "29 - Karnataka" 32 "32 - Kerala" 23 "23 - Madhya Pradesh" 27 "27 - Maharastra" 14 "14 - Manipur" 17 "17 - Meghalaya" 15 "15 - Mizoram" 13 "13 - Nagaland" 21 "21 - Orissa" 3 "3 - Punjab" 8 "8 - Rajasthan" 11 "11 - Sikkim" 33 "33 - Tamil Nadu" 16 "16 - Tripura" 9 "9 - Uttar Pradesh" 19 "19 - West Bengal" 35 "35 - Andaman & Nicober" 4 "4 - Chandigarh" 26 "26 - Dadra & Nagar Haveli" 25 "25 - Daman & Diu" 7 "7 - Delhi" 31 "31 - Lakshadweep" 34 "34 - Pondicheri" 22 "22 - Chhattisgarh" 20 "20 - Jharkhand" 5 "5 - Uttaranchal"
	label values subnatid1 lblsubnatid1
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	gen Region = substr(State_region, -1, 1)
	destring Region, gen(subnatid2)
	label var subnatid2 "NSS Region - not a national ID but useful to later re-assing states (e.g., Uttarkhand)"
*</_subnatid2_>


*<_subnatid3_>
	gen byte subnatid3 = .
	label de lblsubnatid3 1 "1 - Name"
	label values subnatid3 lblsubnatid3
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
	gen subnatidsurvey = "subnatid1"
	label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>


*<_subnatid1_prev_>
/* <_subnatid1_prev_note>

	subnatid1_prev is coded as missing unless the classification used for subnatid1 has changed since the previous survey.

</_subnatid1_prev_note> */
	gen subnatid1_prev = .
	replace subnatid1_prev = 9 if subnatid1 == 5 | subnatid1 == 9
	replace subnatid1_prev = 23 if subnatid1 == 22 | subnatid1 == 23
	replace subnatid1_prev = 10 if subnatid1 == 20 | subnatid1 == 10
	label de lblsubnatid1_prev 10 "10 - Bihar" 23 "23 - Madhya Pradesh" 9 "9 - Uttar Pradesh"
	label values subnatid1_prev lblsubnatid1_prev
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
	bys hhid: gen help_1 = _N
	gen hsize = HH_SIZE
	replace hsize = help_1 if missing(hsize)
	label var hsize "Household size"
	drop help_1
*</_hsize_>


*<_age_>
	gen age = Age
	label var age "Individual age"
*</_age_>


*<_male_>
	destring Sex, gen(male)
	recode male (2 = 0)
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>

	gen relationharm = Relation_to_head
	destring relationharm, replace
	recode relationharm (3 5 = 3) (7=4) (4 6 8 = 5) (9=6) (0=.)
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = Relation_to_head
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	destring Marital_status, gen(marital)
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
	gen migrated_mod_age = .
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time = .
	label var migrated_ref_time "Reference time applied to migration questions"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen migrated_binary = .
	recode migrated_binary (2 = 0)
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
	gen migrated_from_country = ""
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason = .
	label de lblmigrated_reason 1 "Family reasons" 2 "Educational reasons" 3 "Employment" 4 "Forced (political reasons, natural disaster, �)" 5 "Other reasons"
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
	destring Status_of_current_attendance, gen(school)
	recode school (1/15 = 0) (21/40 = 1)
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen byte literacy = .
	replace literacy = 0 if General_education == "01"
	replace literacy = 1 if !inlist(General_education, "01") & !missing(General_education)
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen educy=.
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	destring General_education, gen(genedulev)
	gen byte educat7 = .
	replace educat7= 1 if genedulev<=4 & !missing(genedulev)
	replace educat7 = 2 if genedulev == 5 // Primary incomplete
	replace educat7 = 3 if genedulev == 6 // Primary complete
	replace educat7 = 4 if genedulev == 7 // Secondary incomplete
	replace educat7 = 5 if genedulev == 8 | genedulev == 10 // Secondary complete
	replace educat7 = 6 if genedulev == 11
	replace educat7 = 7 if genedulev==12 | genedulev==13

	* 16 kids aged 10 or 11 with general education university or higher. Set to missing as strange.
	replace educat7 = . if inrange(age,10,11) & General_education == "12"

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
 	gen educat_orig = General_education
 	label var educat_orig "Original survey education code"
 *</_educat_orig_>


*<_educat_isced_>
	destring General_education, gen(genedulev)
	gen educat_isced = .
	replace educat_isced = 0 if genedulev == 5
	replace educat_isced = 100 if genedulev == 6
	replace educat_isced = 200 if genedulev == 7
	replace educat_isced = 300 if genedulev == 8 | genedulev == 10
	replace educat_isced = 400 if genedulev == 11
	replace educat_isced = 600 if genedulev == 12 | genedulev == 13
	label var educat_isced "ISCED standardised level of education"
	drop genedulev
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
================================================================================================*/

{

*<_vocational_>
	gen vocational = 1 if inlist(Vocational_training, "1", "2", "3", "4")
	replace vocational = 0 if Vocational_training == "5"
	label de lblvocational 0 "No" 1 "Yes"
	label values vocational lblvocational
	label var vocational "Ever received vocational training"
*</_vocational_>

*<_vocational_type_>
	gen vocational_type = .
	label de lblvocational_type 1 "Inside Enterprise" 2 "External"
	label values vocational_type lblvocational_type
	label var vocational_type "Type of vocational training"
*</_vocational_type_>

*<_vocational_length_l_>
	gen vocational_length_l = Duration_of_training/4.33
	label var vocational_length_l "Length of training in months, lower limit"
*</_vocational_length_l_>

*<_vocational_length_u_>
	gen vocational_length_u = Duration_of_training/4.33
	label var vocational_length_u "Length of training in months, upper limit"
*</_vocational_length_u_>

*<_vocational_field_>
	gen vocational_field = Field_of_training
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
	destring Current_day_activity_Status1, gen(lstatus)
	recode lstatus  (11/72 98 = 1) (81=2) (82 91/97=3) (99=.)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = .
  replace potential_lf = 0 if lstatus == 3
	replace potential_lf = 1 if Current_day_activity_Status1 == "82"
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
	destring Current_day_activity_Status1, gen(nlfreason)
	recode nlfreason (11/81 98=.) (91=1) (92 93=2) (94=3) (95=4) (82 96 97=5)
	replace nlfreason = . if lstatus != 3 | (age < minlaborage & age != .)
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen unempldur_l=.
	replace unempldur_l=0 if Duration_spell_of_unemployment=="1"
	replace unempldur_l=0.25 if Duration_spell_of_unemployment=="2"
	replace unempldur_l=0.5 if Duration_spell_of_unemployment=="3"
	replace unempldur_l=1 if Duration_spell_of_unemployment=="4"
	replace unempldur_l=2 if Duration_spell_of_unemployment=="5"
	replace unempldur_l=3 if Duration_spell_of_unemployment=="6"
	replace unempldur_l=6 if Duration_spell_of_unemployment=="7"
	replace unempldur_l=12 if Duration_spell_of_unemployment=="8"
	replace unempldur_l=. if missing(Duration_spell_of_unemployment)
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen unempldur_u=.
	replace unempldur_u=0.25 if Duration_spell_of_unemployment=="1"
	replace unempldur_u=0.5 if Duration_spell_of_unemployment=="2"
	replace unempldur_u=1 if Duration_spell_of_unemployment=="3"
	replace unempldur_u=2 if Duration_spell_of_unemployment=="4"
	replace unempldur_u=3 if Duration_spell_of_unemployment=="5"
	replace unempldur_u=6 if Duration_spell_of_unemployment=="6"
	replace unempldur_u=12 if Duration_spell_of_unemployment=="7"
	replace unempldur_u=. if Duration_spell_of_unemployment=="8"
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"

*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{

*<_empstat_>
	destring Current_day_activity_Status1, gen(empstat)
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
	gen industry_orig =  Current_weekly_activity_NIC_1998
	replace industry_orig = "" if lstatus != 1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
  gen industrycat_isic = substr(industry_orig,1,4)
  replace industrycat_isic = "" if lstatus != 1
  label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
  gen red_indus =substr(industry_orig,1,2)
  destring red_indus, replace

  gen industrycat10 = .

  replace industrycat10=1 if red_indus>=00 & red_indus<=09
  replace industrycat10=2 if red_indus>=10 & red_indus<=14
  replace industrycat10=3 if red_indus>=15 & red_indus<=39
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
	gen occup_orig = Current_activity_NCO_1968
	replace occup_orig = "" if lstatus != 1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_>
	gen nco_68 = occup_orig
	gen x_indic = regexm(nco_68, "x|X|y|y")
	replace nco_68 = "099" if x_indic == 1
	replace nco_68 = "0" + nco_68 if length(nco_68) == 2
	replace nco_68 = "00" + nco_68 if length(nco_68) == 1

	merge m:1 nco_68 using "`path_in'/India_occup_correspondences.dta", nogen keep(match master)
	gen code_04 = substr(nco_04,1,1)
	destring code_04, replace

	gen occup = .
	replace occup = code_04 if lstatus == 1 & (age >= minlaborage & age != .)
	replace occup = 99 if x_indic == 1 & lstatus == 1 & (age >= minlaborage & age != .)
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
	drop x_indic nco_68 nco_04 isco_88 code_04
*</_occup_>


*<_occup_isco_>
	gen nco_68 = occup_orig
	gen x_indic = regexm(nco_68, "x|X|y|y")
	replace nco_68 = "099" if x_indic == 1
	replace nco_68 = "0" + nco_68 if length(nco_68) == 2
	replace nco_68 = "00" + nco_68 if length(nco_68) == 1

	merge m:1 nco_68 using "`path_in'/India_occup_correspondences.dta", nogen keep(match master)

	gen occup_isco = isco_88
	replace occup_isco = "" if lstatus != 1
	drop x_indic nco_68 nco_04 isco_88
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>



*<_occup_skill_>
	gen occup_skill = .
	replace occup_skill = 3 if inrange(occup, 1, 3)
	replace occup_skill = 2 if inrange(occup, 4, 8)
	replace occup_skill = 1 if occup == 9
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>



*<_wage_no_compen_>
	* Use earnings as there is not other info to add, cannot annualise.
	gen double wage_no_compen = Total_earnings_1
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
	gen whours = 8*Total_no_days_activity_1
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
	gen has_job_primary = inlist(Current_day_activity_Status1,"11", "12", "21", "31", "41", "51") ///
							| inlist(Current_day_activity_Status1, "61", "62", "71", "72", "98")
	destring Current_day_activity_Status2, gen(empstat_2)
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
	gen industry_orig_2 = Current_activity_NIC1998_2
  replace industry_orig_2 = "" if missing(empstat_2)
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
  gen industrycat_isic_2 = industry_orig_2 + "00"
  replace industrycat_isic_2 = "" if missing(empstat_2)
  replace industrycat_isic_2 = "" if industrycat_isic_2 == "00"
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
	gen double wage_no_compen_2 = Total_earnings_2
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
	gen whours_2 = 8*Total_no_days_activity_2
	replace whours_2=. if lstatus != 1 | (age < minlaborage & age != .)
	replace whours_2 = . if missing(empstat_2)
	replace whours_2 = . if whours_2 == 0
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


*----------8.5: 7 day reference total summary------------------------------*


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


*----------8.6: 12 month reference overall------------------------------*

{

*<_lstatus_year_>
/* <_lstatus_year_note>

	For a person to be employed use the concept of usual economic activity, that is principal
	activity and add secondary if the principal is not in employment byt secondary is.
	So a full time student working on the side is still in the labor force in this 12 month sense

*</_lstatus_year_note> */
	destring Usual_principal_activity_status, gen(lstatus_year)
	recode lstatus_year  11/72=1 81 82=2 91/98=3 99=.

	replace Usual_subsidary_activity_status = "99" if Usual_subsidary_activity_status == "X" | Usual_subsidary_activity_status == "XX"
	destring  Usual_subsidary_activity_status, gen(secondary_help)
	recode secondary_help  11/72=1 81 82=2 91/98=3 99=.
	replace lstatus_year = 1 if secondary_help == 1 & lstatus_year != 1
	replace lstatus = . if age < minlaborage
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
	drop secondary_help
*</_lstatus_year_>

*<_potential_lf_year_>
	gen byte potential_lf_year = .
	label var potential_lf_year "Potential labour force status"
	la de lblpotential_lf_year 0 "No" 1 "Yes"
	label values potential_lf_year lblpotential_lf_year
*</_potential_lf_year_>


*<_underemployment_year_>
	gen byte underemployment_year = .
	replace underemployment_year = 1 if inlist(Sought_available_for_additional_, "1", "2") & lstatus_year == 1
	replace underemployment_year = 0 if Sought_available_for_additional_ == "3" & lstatus_year == 1
	label var underemployment_year "Underemployment status"
	la de lblunderemployment_year 0 "No" 1 "Yes"
	label values underemployment_year lblunderemployment_year
*</_underemployment_year_>


*<_nlfreason_year_>
	destring Usual_principal_activity_status, gen(nlfreason_year)
	destring  Usual_subsidary_activity_status, gen(secondary_help)
	recode secondary_help  11/72=1 81 82=2 91/98=3 99=.
	recode nlfreason_year 11/82=. 91=1 92 93=2 94=3 95=4 96/99=5
	recode nlfreason_year 1 2 3 4 5 = . if secondary_help == 1
	replace nlfreason_year = . if lstatus_year != 3 | (age < minlaborage & age != .)
	label var nlfreason_year "Reason not in the labor force - 12 month recall"
	la de lblnlfreason_year 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason_year lblnlfreason_year
	drop secondary_help
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
	destring Usual_principal_activity_status, gen(empstat_year)
	recode empstat_year (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72=1) (81/99=.)
	destring Usual_subsidary_activity_status, gen(secondary_help)
	recode secondary_help (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72=1) (81/99=.)
	replace empstat_year = secondary_help if missing(empstat_year) & lstatus_year == 1
	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>

*<_ocusec_year_>
	** Enterprise type refers to employment under principal activity status (12 month basis)
	gen byte ocusec_year = .
	destring Enterprise_type, replace
	replace ocusec_year=1 if Enterprise_type==5
	replace ocusec_year=2 if  Enterprise_type>=1 & Enterprise_type<=4 | Enterprise_type == 7
	replace ocusec_year=2 if  Enterprise_type==8
	replace ocusec_year=4 if Enterprise_type==6
	replace ocusec_year=. if  Enterprise_type==9 | lstatus_year != 1
	label var ocusec_year "Sector of activity primary job 12 day recall"
	la de lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_year lblocusec_year
*</_ocusec_year_>

*<_industry_orig_year_>
	gen industry_orig_year = Usual_principal_activity_NIC_5_d
	replace industry_orig_year = V22 if missing(Usual_principal_activity_NIC_5_d)
  replace industry_orig_year = "" if lstatus_year != 1
	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	gen industrycat_isic_year = substr(industry_orig_year,1,4)
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
	gen occup_orig_year = Usual_principal_activity_NCO_3_d
	replace occup_orig_year = V23 if missing(Usual_principal_activity_NCO_3_d)
  replace occup_orig_year = "" if lstatus_year != 1
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_year_>
  gen nco_68 = occup_orig_year
  gen x_indic = regexm(nco_68, "x|X|y|y")
  replace nco_68 = "099" if x_indic == 1
  replace nco_68 = "0" + nco_68 if length(nco_68) == 2
  replace nco_68 = "00" + nco_68 if length(nco_68) == 1

  merge m:1 nco_68 using "`path_in'/India_occup_correspondences.dta", nogen keep(match master)
  gen code_04 = substr(nco_04,1,1)
  destring code_04, replace

  gen occup_year = .
  replace occup_year = code_04 if lstatus_year == 1 & (age >= minlaborage & age != .)
  replace occup_year = 99 if x_indic == 1 & lstatus_year == 1 & (age >= minlaborage & age != .)
  label var occup_year "1 digit occupational classification, primary job 12 month recall"
  la de lbloccup_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
  label values occup_year lbloccup_year
  drop x_indic nco_68 nco_04 isco_88 code_04
*</_occup_year_>


*<_occup_isco_year_>
	gen nco_68 = occup_orig_year
	gen x_indic = regexm(nco_68, "x|X|y|y")
	replace nco_68 = "099" if x_indic == 1
	replace nco_68 = "0" + nco_68 if length(nco_68) == 2
	replace nco_68 = "00" + nco_68 if length(nco_68) == 1

	merge m:1 nco_68 using "`path_in'/India_occup_correspondences.dta", nogen keep(match master)

	gen occup_isco_year = isco_88
	replace occup_isco_year = "" if lstatus_year != 1
	drop x_indic nco_68 nco_04 isco_88
	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


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
/* <_wmonths_year_note>

	Survey asks individuals whether they worked regularly. If not, how many months out of work.
	Hence assume if worked regularly 12 months of work, if not 12 minus the number mentioned.

	For this survey, there is no variable that identifies whether individual worked regularly
</_wmonths_year_note> */
	gen wmonths_year = .
	label var wmonths_year "Months of work in past 12 months primary job 12 month recall"
*</_wmonths_year_>


*<_wage_total_year_>
	gen wage_total_year = .
	label var wage_total_year "Annualized total wage primary job 12 month recall"
*</_wage_total_year_>


*<_contract_year_>
	gen byte contract_year = .
	replace contract_year = 1 if inlist(Type_of_job_contract, "2", "3", "4")
	replace contract_year = 0 if Type_of_job_contract == "1"

	replace contract_year = 1 if inlist(Type_of_job_contract2, "2", "3", "4") & lstatus_year == 1 & contract_year == .
	replace contract_year = 0 if Type_of_job_contract2 == "1" & lstatus_year == 1 & contract_year == .

	replace contract_year = . if lstatus_year!= 1
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
	destring Social_security_benefits, replace
	replace socialsec_year = 1 if (Social_security_benefits < 8) & lstatus_year == 1
	replace socialsec_year = 0 if Social_security_benefits == 8 & lstatus_year == 1

	destring Availability_of_social_security2, replace
	replace socialsec_year = 1 if (Availability_of_social_security2 < 8) & lstatus_year == 1 & socialsec_year == .
	replace socialsec_year = 0 if (Availability_of_social_security2 == 8) & lstatus_year == 1 & socialsec_year == .


	label var socialsec_year "Employment has social security insurance primary job 12 month recall"
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

	** Referring to the firm employed under principal activity status; thus, reported under 12-year reference period
	destring No_of_workers_in_enterprises, gen(firm_sizes)
	destring No_of_workers_in_the_enterprise2, gen(firm_sizes_2)
	replace firm_sizes = firm_sizes_2 if missing(firm_sizes) & !missing(empstat_year)

	gen byte firmsize_l_year = .
	replace firmsize_l_year=1 if firm_sizes==1
	replace firmsize_l_year=6 if firm_sizes==2
	replace firmsize_l_year=10 if firm_sizes==3
	replace firmsize_l_year=20 if firm_sizes==4
	replace firmsize_l_year=. if firm_sizes==9
	replace firmsize_l_year=. if lstatus_year!=1
	label var firmsize_l_year "Firm size (lower bracket) primary job 12 month recall"
*</_firmsize_l_year_>


*<_firmsize_u_year_>
	gen byte firmsize_u_year = .
	replace firmsize_u_year = 6 if firm_sizes==1
	replace firmsize_u_year = 9 if firm_sizes==2
	replace firmsize_u_year = 10 if firm_sizes==3
	replace firmsize_u_year = . if firm_sizes==4
	replace firmsize_u_year=. if firm_sizes==9
	replace firmsize_u_year=. if lstatus_year!=1
	label var firmsize_u_year "Firm size (upper bracket) primary job 12 month recall"
	drop firm_sizes firm_sizes_2
*</_firmsize_u_year_>

}


*----------8.8: 12 month reference secondary job------------------------------*

{

*<_empstat_2_year_>
	destring Usual_principal_activity_status, gen(has_job_primary)
	recode has_job_primary 1/51 = 1 81/99 = 0

	destring Usual_subsidary_activity_status, gen(empstat_2_year)
	recode empstat_2_year  (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72=1) (81/99=.)
	* One wrong code twice
	replace empstat_2_year = . if empstat_2_year == 25
	replace empstat_2_year = . if lstatus_year != 1
	replace empstat_2_year = . if has_job_primary == 0 & !missing(empstat_2_year)

	label var empstat_2_year "Employment status during past week secondary job 12 month recall"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2_year lblempstat_2_year
	drop has_job_primary
*</_empstat_2_year_>


*<_ocusec_2_year_>
	gen byte ocusec_2_year = .
	destring Enterprise_type2, replace
	replace ocusec_2_year=1 if Enterprise_type2==5
	replace ocusec_2_year=2 if  Enterprise_type2>=1 & Enterprise_type2<=4 | Enterprise_type2 == 7
	replace ocusec_2_year=2 if  Enterprise_type2==8
	replace ocusec_2_year=4 if Enterprise_type2==6
	replace ocusec_2_year=. if  Enterprise_type2==9 | missing(empstat_2_year)
	label var ocusec_2_year "Sector of activity primary job 12 day recall"
	la de lblocusec_2_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_2_year lblocusec_2_year
*</_ocusec_2_year_>


*<_industry_orig_2_year_>
	gen industry_orig_2_year = V22
	replace industry_orig_2_year = "" if missing(empstat_2_year)
	label var industry_orig_2_year "Original survey industry code, secondary job 12 month recall"
*</_industry_orig_2_year_>


*<_industrycat_isic_2_year_>
	gen industrycat_isic_2_year = substr(industry_orig_2_year, 1, 4)
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
	gen occup_orig_2_year = V23
	replace occup_orig_2_year = "" if missing(empstat_2_year)
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_2_year_>
	gen nco_68 = occup_orig_2_year
	gen x_indic = regexm(nco_68, "x|X|y|y")
	replace nco_68 = "099" if x_indic == 1
	replace nco_68 = "0" + nco_68 if length(nco_68) == 2
	replace nco_68 = "00" + nco_68 if length(nco_68) == 1

	merge m:1 nco_68 using "`path_in'/India_occup_correspondences.dta", nogen keep(match master)
	gen code_04 = substr(nco_04,1,1)
	destring code_04, replace

	gen occup_2_year = .
	replace occup_2_year = code_04 if lstatus_year == 1 & (age >= minlaborage & age != .)
	replace occup_2_year = 99 if x_indic == 1 & lstatus_year == 1 & (age >= minlaborage & age != .)
	label var occup_2_year "1 digit occupational classification, secondary job 12 month recall"
	la de lbloccup_2_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2_year lbloccup_2_year
	drop x_indic nco_68 nco_04 isco_88 code_04
*</_occup_2_year_>


*<_occup_isco_2_year_>
	gen nco_68 = occup_orig_2_year
	gen x_indic = regexm(nco_68, "x|X|y|y")
	replace nco_68 = "099" if x_indic == 1
	replace nco_68 = "0" + nco_68 if length(nco_68) == 2
	replace nco_68 = "00" + nco_68 if length(nco_68) == 1

	merge m:1 nco_68 using "`path_in'/India_occup_correspondences.dta", nogen keep(match master)

	gen occup_isco_2_year = isco_88
	replace occup_isco_2_year = "" if lstatus_year != 1
	drop x_indic nco_68 nco_04 isco_88
	label var occup_isco_2_year "ISCO code of secondary job 12 month recall"
*</_occup_isco_year_>


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
	destring No_of_workers_in_the_enterprise2, gen(firm_sizes)
	replace firm_sizes = . if !missing(firm_sizes) & missing(empstat_2_year)

	gen byte firmsize_l_2_year = .
	replace firmsize_l_2_year=1 if firm_sizes==1
	replace firmsize_l_2_year=6 if firm_sizes==2
	replace firmsize_l_2_year=10 if firm_sizes==3
	replace firmsize_l_2_year=20 if firm_sizes==4
	replace firmsize_l_2_year=. if firm_sizes==9
	replace firmsize_l_2_year=. if lstatus_year!=1
	label var firmsize_l_2_year "Firm size (lower bracket) secondary job 12 month recall"
*</_firmsize_l_2_year_>


*<_firmsize_u_2_year_>
	gen byte firmsize_u_2_year = .
	replace firmsize_u_2_year = 6 if firm_sizes==1
	replace firmsize_u_2_year = 9 if firm_sizes==2
	replace firmsize_u_2_year = 10 if firm_sizes==3
	replace firmsize_u_2_year = . if firm_sizes==4
	replace firmsize_u_2_year=. if firm_sizes==9
	replace firmsize_u_2_year=. if lstatus_year!=1
	label var firmsize_u_2_year "Firm size (upper bracket) secondary job 12 month recall"
	drop firm_sizes
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

save "`path_output'\IND_2004_EUS_V01_M_V01_A_GLD_ALL.dta", replace

*</_% SAVE_>
