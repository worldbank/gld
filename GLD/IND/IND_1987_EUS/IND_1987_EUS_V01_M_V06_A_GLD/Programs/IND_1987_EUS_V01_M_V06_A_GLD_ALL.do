
/*%%=============================================================================================
	0: GLD Harmonization Preamble
================================================================================================*/

/* -----------------------------------------------------------------------

<_Program name_> 			IND_1987_EUS_V01_M_V06_A_GLD_ALL.do </_Program name_>
<_Application_>					STATA 16 <_Application_>
<_Author(s)_>					World Bank Jobs Group </_Author(s)_>
<_Date created_>				2021-05-24 </_Date created_>
<_Date modified>				2022-01-03 </_Date modified_>

-------------------------------------------------------------------------

<_Country_>						India </_Country_>
<_Survey Title_>				National Sample survey 1987 Schedule 10 - Round 43 </_Survey Title_>
<_Survey Year_>					1987 </_Survey Year_>
<_ICLS Version_>				Unknown (does not seem to follow ICLS-13 </_ICLS Version_>
<_Study ID_>					DDI-IND-MOSPI-NSSO-43Rnd-Sch10-1987-88 </_Study ID_>
<_Data collection from (M/Y)_>	07/1987 </_Data collection from (M/Y)_>
<_Data collection to (M/Y)_>	06/1988 </_Data collection to (M/Y)_>
<_Source of dataset_> 			http://microdata.gov.in/nada43/index.php/catalog/55 </_Source of dataset_>
<_Sample size (HH)_> 			129,060 </_Sample size (HH)_>
<_Sample size (IND)_> 			667,804 </_Sample size (IND)_>
<_Sampling method_> 			The sample design adopted for this round of survey was similar to that followed in the past surveys in its general aspects. The ge neral scheme was a two stage stratified design with the first stage units being villages in the rural areas and urban frame survey blocks(UFS) in the urban areas. The second stage units were the households. 	</_Sampling method_>
<_Geographic coverage_> 		State Level </_Geographic coverage_>
<_Currency_> 					Indian Rupee </_Currency_>
-----------------------------------------------------------------------

<_ICLS Version_>				ICLS 13 </_ICLS Version_>
<_ISCED Version_>				ISCED 1997 </_ISCED Version_>
<_ISCO Version_>				ISCO 1968  </_ISCO Version_>
<_OCCUP National_>				NCO 1968  </_OCCUP National_>
<_ISIC Version_>				ISIC 2 </_ISIC Version_>
<_INDUS National_>				NIC 1970 </_INDUS National_>

-----------------------------------------------------------------------

<_Version Control_>

Version v02_A done to updated industry options
In 7 day recall, 1 digit variable (B4_q12) is not 1 digit of three digit
(B4_q14) but rather (and oddly) different. Change to do all based on three digit
codes so everything is in line with industry_orig.
2022-07-13
Version v03_A done to better (and more succinctly add workers who are employed
but in subsidiary activity, not in principal.)
Change subnatid1 to string, improve subnatidsurvey
* Date: 2024-01-05 - Update vars subnatid2, subnatid3
* Date: 2024-02-07 - Update vars subnatid2, subnatid3
* Date: 2024-04-17 - Update vars subnatid1

</_Version Control_>

-------------------------------------------------------------------------*/


/*%%=============================================================================================
	1: Setting up of program environment, dataset
================================================================================================*/

*----------1.1: Initial commands------------------------------*

clear
set more off
set mem 800m

capture which distinct
if _rc ssc install distinct

*----------1.2: Set directories------------------------------*

* Define path sections
local server  "Y:/GLD"
local country "IND"
local year    "1987"
local survey  "EUS"
local vermast "V01"
	local veralt "V06"

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

* Start process with individual block 4
tempfile block4 block4short

use "`path_in_stata'/Block-4-Persons-Demographic-current-weekly-activity- Records.dta", clear

* Identify the duplicates in person id
distinct Person_key //duplicates of 44 records
duplicates tag Person_key, gen(tag)

* Remove duplicates

	* Rule 1: If age is missing, drop that duplicate
	drop if B4_q5 == . & tag == 1 //drop

	* Rule 2: Keep the record with more information on labor market
	gen count = B4_q12 != "" // if has value of q12, also has value for q14-15
	bys Person_key: egen countmax = max(count)
	drop if tag == 1 & countmax != count

	* Rule 3: Keep the first recorded - get back to this later on

	duplicates drop Person_key, force
	distinct Person_key

* At this point, there are 667,804 persons (vs 667,844 in MOSPI - which included duplicates)
save `block4'

	* Save only Person key and current weekly activity (CWA)
	* CWA is important for us to reconcile with daily activity records in Block 5
	keep Person_key B4_q11

save `block4short'


* Proceed with Block 5
use "`path_in_stata'/Block-5-Persons-Daily- activity- time-disposion-Records.dta", clear

* Drop the invalid data to arrive with total consistent with that reported by MOSPI
drop if missing(B5_q13)
count // same total as reported by IND Ministry

* Generate person serial number from the unique person ID variable, Person_key
gen Prsn_slno = substr(Person_key, -3, 3)

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
===============================================================================*/


/* Need to classify activity status into the following:

	a. Working status
	b. Non-working status but seeking employment
	c. Neither working nor available for work

*/

destring B5_q3, gen(priority_tag)
gen num_status = priority_tag

* Classify the level of priority
recode priority_tag 11/72=1 81 82=2 91/98=3 99=.

* Decreasing order of number of days worked
gen neg_days = -(B5_q13)

/*==============================================================================
Caveat on using the number of days worked variable:

As per the instruction manual for the 1987 EUE, the total number of days for all
the activities shold be 7. However, in the data, the number of days for all activities
taken together do not all add up to 7. A total of 13,000 individuals have total
days more than or less than 7.

The harmonizer leaves it up to the data user to explore methods to address this
data issue. For the purposes of this exercise, only the ordering of the activity
duration is taken into consideration, regardless of the number of days sum up for
that individual or not.

==============================================================================*/
* Generate PID bec this is variable name used for the sorting procedure below
gen PID = Person_key

* Total number of days for each person's activity should be equal to 7
bys PID: egen tot = sum(B5_q13)
distinct PID if tot != 7 //nearly 13,000 people with unreliable data

distinct PID

* There are several duplicates in status code for the same person.
* Need to keep only one status code such that HH - Person - status code is unique
duplicates drop PID B5_q3, force

* Check if unique after trimming records
distinct PID B5_q3, joint
* End up with 750,293 unique observations

* Merge with block 4 short
merge m:1 Person_key using `block4short'
* There are 238 persons in Block 5 not found in Block 4
* There are 8 persons in Block 4 not in Block 5

gen first = 1 if B5_q3 == B4_q11
replace first = 2 if B5_q3 != B4_q11

sort PID first priority_tag neg_days num_status
bys PID: gen runner = _n

* At this point, we expect activity 1 to be equal to CWA, B4_q11
count if B5_q3! =  B4_q11 & runner==1 & !missing(B4_q11)

* However, there are 193 cases of mismatch. What do we do with this?
* In principle, CWA should be derived from daily activity records. I stick to this
* Also, since 50% of these cases have value = 99 under CWA, using daily activity records
* would also be more favorable. In terms of identifying primary and secondary 7-day
* occupation codes, which are mapped only to CWA, we leave them as missing
* for these 193 records.

* Keep only necessary variables for reshape
keep B5_q3 B5_q4 B5_q13 B5_q14 B5_q15 B5_q16  Hhold_key Prsn_slno Person_key runner

* Activity serial number is not unique, create serial id for each person

reshape wide B5_q3 B5_q4 B5_q13 B5_q14 B5_q15 B5_q16, i(Person_key) j(runner)

* Check whether activities correctly coded in order - there should not be a third activity if
* there is no second activity.
count if missing(B5_q31) & !missing(B5_q32)
count if missing(B5_q32) & !missing(B5_q33)
count if missing(B5_q33) & !missing(B5_q34)

* Next, we merge with full block 4
merge m:1 Person_key using `block4', nogen

tempfile weekly_act
save `weekly_act'


* Create temporary files for each block where we save the clean version
tempfile block3 block7 block6

* Proceed with block 1- 3

use "`path_in_stata'/Block-1-3-Household-Records", clear

duplicates tag Hhold_key, gen(tag)

	* Rule 1: Keep the duplicated record with more non-missing values
	foreach var of varlist B3_q7 - B3_q16{
		gen count_`var' = `var' ! = .
		}

	egen totl_nonmissing = rowtotal(count_B3_q7 - count_B3_q16)
	bys Hhold_key: egen max_nonmissing = max(totl_nonmissing)

	drop if tag ==1 & max_nonmissing != totl_nonmissing

	* Rule 2: At this point, all duplicates have same information. Drop duplicates
	duplicates drop Hhold_key, force

	save `block3'

* Proceed with block 7
use "`path_in_stata'/Block-7-Persons- usual-activity-statuscode-11to94-Records", clear

	* Since no pattern found, drop first record
	duplicates drop Person_key, force

	save `block7'

* Proceed with block 6
use "`path_in_stata'/Block-6--Persons-Usual-activity- migration-Records.dta", clear

* Identify the duplicates in person id
distinct Person_key //duplicates of 44 records
duplicates tag Person_key, gen(tag)

* Remove duplicates (keep the first instance)
duplicates drop Person_key, force


/*==============================================================================
Caveat:

At this point, we are not sure whether the dropped HHs/persons in Blocks 1-3, 6
and 7 are the exact match to those dropped in Block 4.

Unfortunately, there is no other common variable that would allow us to filter
the perfect match. We ignore the implications of the mismatch and leave it to the data analyzer
to explore other innovative options to match these observations.
==============================================================================*/


* Merge Individual 12 month info with 7 day info
merge 1:1 Person_key using `weekly_act', keep(match master) nogen

* Merge with HH info
merge m:1 Hhold_key using `block3', keep(match master) nogen

* Merge with additional questions for employed (note this is a subset)
merge 1:1 Person_key using `block7', keep(match master) nogen


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
	gen isced_version = "isced_1976"
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
	gen isco_version = "isco_1988"
	label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
	gen isic_version = "isic_2"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	gen int year = 1987
	label var year "Year of the start of the survey"
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
	gen int_year=.
	replace int_year = 1987 if inlist(SubRound,"1","2")
	replace int_year = 1988 if inlist(SubRound,"3","4")
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

	From different surveys a str9 should be created. In later surveys this is:
	FSU (str5) + Hamlet (str1) + 2nd Stage Sample (str1) + Sample HH Id (str2).

	Here Hhold_Key is str8 of FSU + Stage 2 Stratum + Sample HH Id. Add subround to make str9
	From preparing I notice there is one case where Stage2_Stratum is "0", when this makes no sense,
	HH Key has code 2, so first amend that
</_hhid_note> */
	gen hamlet = substr(Vill_Blk_No, -1, 1)
	gen psu_helper = FSU_SlNo
	replace psu_helper = FSU_No if missing(psu_helper)
	egen hhid = concat(psu_helper hamlet Sub_stratum Hhold_No)
	drop psu_helper
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	egen  str11 pid = concat(hhid Prsn_Slno)
	label var pid "Individual ID"
	isid pid
*</_pid_>


*<_weight_>
	gen weight = Wgt4_pooled
	label var weight "Household sampling weight"
*</_weight_>


*<_psu_>
	gen psu = FSU_SlNo
	replace psu = FSU_No if missing(psu)
	label var psu "Primary sampling units"
*</_psu_>


*<_strata_>
	gen strata = Stratum
	label var strata "Strata"
*</_strata_>

*<_wave_>
	gen wave = Subround
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
	* One case were Sector (1,2 var) has value 0, all others in HH are 2
	replace urban = 1 if pid == "749286203006"
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
	destring State, gen(subnatid1)
	label de lblsubnatid1 2 "2 - Andhra Pradesh" 3 "3 - Assam" 4 "4 - Bihar" 5 "5 - Gujarat" 6 "6 - Haryana" 7 "7 - Himachal Pradesh" 8 "8 - Jammu & Kashmir" 9 "9 - Karnataka" 10 "10 - Kerala" 11 "11 - Madhya Pradesh" 12 "12 - Maharashtra" 13 "13 - Manipur" 14 "14 - Meghalaya" 15 "15 - Nagaland" 16 "16 - Orissa" 17 "17 - Punjab" 18 "18 - Rajasthan" 19 "19 - Sikkim" 20 "20 - Tamil Nadu" 21 "21 - Tripura" 22 "22 - Uttar Pradesh" 23 "23 - West Bengal" 24 "24 - Andaman & Nicober" 25 "25 - Arunachal Pradesh" 26 "26 - Chandigarh" 27 "27 - Dadra & Nagar Haveli" 28 "28 - Delhi" 29 "29 - Goa" 30 "30 - Lakshadweep" 31 "31 - Mizoram" 32 "32 - Pondicherry"
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
	* From observation in running the below, there is one special case where the PSU has some 00, all the rest 06
	* as district and one lose 16. Single person in a single HH. Assume this is incorrect, replace here.
	replace District = "06" if pid == "105167102001"
	* There are about 468 cases where the District info is missing or 00 Use the psu common answer to replace
	* We will detect them and go through the clusters they are a part of, replace it with the district value.
	* For this we need:
	* 1) The district number in the cluster to be unique (other than missing or 0)
	* 2) Convert the string district to a number as we need summ's return p(50 value)
	* 3) Reconvert the number to a string 2 value, replace the wrong ingfo with it
	gen hlpr_district_odd = mi(District) | District == "00"
	levelsof psu if hlpr_district_odd == 1, local (clusters)
	destring District, gen(hlpr_num_dist)
	gen hlpr_dist_rep_num = .
	* Go through each cluster and determine the district.
	foreach cluster of local clusters {
	* Ensure it is unique other than missing or 0
	quietly : tab District if psu == "`cluster'" & !inlist(District, "", "00", "0")
	assert `r(r)' == 1
	* Make a numeric istrict as that we can extract from summ
	quietly : summ hlpr_num_dist if psu == "`cluster'", d
	* Fill replace variable
	replace hlpr_dist_rep_num = `r(p50)' if psu == "`cluster'" & hlpr_district_odd == 1
	}
	* Replace for all
	gen hlpr_dist_rep_str = string(hlpr_dist_rep_num, "%02.0f")
	replace District = hlpr_dist_rep_str if hlpr_district_odd == 1
	drop hlpr_*
	* Additionally, out of the nearly 13K PSUs, there are 164 (1.3%) that have a two (or more)
	* different district numbers. In 158 of them (96%) the most common code is there for
	* at least 75% of respondents, in 133 it is above 85%. Given this and the fact that in the
	* next years District code is always unique per PSU, assume this is a mistake,
	* set code to most common
	destring District, gen(hlpr_num_dist)
	bys psu : egen hlpr_sd_dist = sd(hlpr_num_dist)
	gen hlpr_district_odd = hlpr_sd_dist > 0
	levelsof psu if hlpr_district_odd == 1, local (clusters)
	gen hlpr_dist_rep_num = .
	* Go through each cluster and determine the district.
	foreach cluster of local clusters {
	* Make a numeric istrict as that we can extract from summ
	quietly : summ hlpr_num_dist if psu == "`cluster'", d
	* Fill replace variable
	replace hlpr_dist_rep_num = `r(p50)' if psu == "`cluster'" & hlpr_district_odd == 1
	}
	* Replace for all
	gen hlpr_dist_rep_str = string(hlpr_dist_rep_num, "%02.0f")
	replace District = hlpr_dist_rep_str if hlpr_district_odd == 1
	drop hlpr_*
	egen subnatid2 = concat(State District), punct(-)
	label var subnatid2 "Admin 2 - District"
	replace subnatid2 = "02-01 - Srikakulam" if subnatid2 == "02-01"
	replace subnatid2 = "02-02 - Vizianagaram" if subnatid2 == "02-02"
	replace subnatid2 = "02-03 - Visakhapatnam" if subnatid2 == "02-03"
	replace subnatid2 = "02-04 - East Godavari" if subnatid2 == "02-04"
	replace subnatid2 = "02-05 - West Godawari" if subnatid2 == "02-05"
	replace subnatid2 = "02-06 - Krishna" if subnatid2 == "02-06"
	replace subnatid2 = "02-07 - Guntur" if subnatid2 == "02-07"
	replace subnatid2 = "02-08 - Prakasam" if subnatid2 == "02-08"
	replace subnatid2 = "02-09 - Nellore" if subnatid2 == "02-09"
	replace subnatid2 = "02-10 - Chittoor" if subnatid2 == "02-10"
	replace subnatid2 = "02-11 - Cuddapah" if subnatid2 == "02-11"
	replace subnatid2 = "02-12 - Ananthapur" if subnatid2 == "02-12"
	replace subnatid2 = "02-13 - Kurnool" if subnatid2 == "02-13"
	replace subnatid2 = "02-14 - Mahaboobnagar" if subnatid2 == "02-14"
	replace subnatid2 = "02-15 - Rangareddy" if subnatid2 == "02-15"
	replace subnatid2 = "02-16 - Hyderabad" if subnatid2 == "02-16"
	replace subnatid2 = "02-17 - Medak" if subnatid2 == "02-17"
	replace subnatid2 = "02-18 - Nizamabad" if subnatid2 == "02-18"
	replace subnatid2 = "02-19 - Adilabad" if subnatid2 == "02-19"
	replace subnatid2 = "02-20 - Karimnagar" if subnatid2 == "02-20"
	replace subnatid2 = "02-21 - Warangal" if subnatid2 == "02-21"
	replace subnatid2 = "02-22 - Khammam" if subnatid2 == "02-22"
	replace subnatid2 = "02-23 - Nalgonda" if subnatid2 == "02-23"
	replace subnatid2 = "03-01 - Goalpara" if subnatid2 == "03-01"
	replace subnatid2 = "03-02 - Kamrup" if subnatid2 == "03-02"
	replace subnatid2 = "03-03 - Darrang" if subnatid2 == "03-03"
	replace subnatid2 = "03-04 - Lakhimpur" if subnatid2 == "03-04"
	replace subnatid2 = "03-05 - Dibrugarh" if subnatid2 == "03-05"
	replace subnatid2 = "03-06 - Sibsagar" if subnatid2 == "03-06"
	replace subnatid2 = "03-07 - Nowgong" if subnatid2 == "03-07"
	replace subnatid2 = "03-08 - Karbi Anglong" if subnatid2 == "03-08"
	replace subnatid2 = "03-09 - North Cachar Hills" if subnatid2 == "03-09"
	replace subnatid2 = "03-10 - Cachar" if subnatid2 == "03-10"
	replace subnatid2 = "04-01 - Patna" if subnatid2 == "04-01"
	replace subnatid2 = "04-02 - Nalanda" if subnatid2 == "04-02"
	replace subnatid2 = "04-03 - Nawada" if subnatid2 == "04-03"
	replace subnatid2 = "04-04 - Gaya" if subnatid2 == "04-04"
	replace subnatid2 = "04-05 - Aurangabad" if subnatid2 == "04-05"
	replace subnatid2 = "04-06 - Rohtas" if subnatid2 == "04-06"
	replace subnatid2 = "04-07 - Bhojpur" if subnatid2 == "04-07"
	replace subnatid2 = "04-08 - Saran" if subnatid2 == "04-08"
	replace subnatid2 = "04-09 - Siwan" if subnatid2 == "04-09"
	replace subnatid2 = "04-10 - Gopalganj" if subnatid2 == "04-10"
	replace subnatid2 = "04-11 - Champaran West" if subnatid2 == "04-11"
	replace subnatid2 = "04-12 - Champaran East" if subnatid2 == "04-12"
	replace subnatid2 = "04-13 - Sitamarhi" if subnatid2 == "04-13"
	replace subnatid2 = "04-14 - Muzaffarpur" if subnatid2 == "04-14"
	replace subnatid2 = "04-15 - Vaishali" if subnatid2 == "04-15"
	replace subnatid2 = "04-16 - Begusarai" if subnatid2 == "04-16"
	replace subnatid2 = "04-17 - Samastipur" if subnatid2 == "04-17"
	replace subnatid2 = "04-18 - Darbhanga" if subnatid2 == "04-18"
	replace subnatid2 = "04-19 - Madhubani" if subnatid2 == "04-19"
	replace subnatid2 = "04-20 - Saharsa" if subnatid2 == "04-20"
	replace subnatid2 = "04-21 - Purnea" if subnatid2 == "04-21"
	replace subnatid2 = "04-22 - Katihar" if subnatid2 == "04-22"
	replace subnatid2 = "04-23 - Monghyr" if subnatid2 == "04-23"
	replace subnatid2 = "04-24 - Bhagalpur" if subnatid2 == "04-24"
	replace subnatid2 = "04-25 - Dumka" if subnatid2 == "04-25"
	replace subnatid2 = "04-26 - Dhanbad" if subnatid2 == "04-26"
	replace subnatid2 = "04-27 - Giridih" if subnatid2 == "04-27"
	replace subnatid2 = "04-28 - Hazaribagh" if subnatid2 == "04-28"
	replace subnatid2 = "04-29 - Palamu" if subnatid2 == "04-29"
	replace subnatid2 = "04-30 - Ranchi" if subnatid2 == "04-30"
	replace subnatid2 = "04-31 - Singbhum" if subnatid2 == "04-31"
	replace subnatid2 = "04-32 - Madhepura" if subnatid2 == "04-32"
	replace subnatid2 = "04-33 - Khageria" if subnatid2 == "04-33"
	replace subnatid2 = "04-34 - Deoghar" if subnatid2 == "04-34"
	replace subnatid2 = "04-35 - Godda" if subnatid2 == "04-35"
	replace subnatid2 = "04-36 - Sahebganj" if subnatid2 == "04-36"
	replace subnatid2 = "04-37 - Gumla" if subnatid2 == "04-37"
	replace subnatid2 = "05-01 - Jamnagar" if subnatid2 == "05-01"
	replace subnatid2 = "05-02 - Rajkot" if subnatid2 == "05-02"
	replace subnatid2 = "05-03 - Surendranagar" if subnatid2 == "05-03"
	replace subnatid2 = "05-04 - Bhavnagar" if subnatid2 == "05-04"
	replace subnatid2 = "05-05 - Amreli" if subnatid2 == "05-05"
	replace subnatid2 = "05-06 - Junagadh" if subnatid2 == "05-06"
	replace subnatid2 = "05-07 - Kachehha" if subnatid2 == "05-07"
	replace subnatid2 = "05-08 - Binaskantha" if subnatid2 == "05-08"
	replace subnatid2 = "05-09 - Sabarkantha" if subnatid2 == "05-09"
	replace subnatid2 = "05-10 - Mahesana" if subnatid2 == "05-10"
	replace subnatid2 = "05-11 - Gandhinagar" if subnatid2 == "05-11"
	replace subnatid2 = "05-12 - Ahmedabad" if subnatid2 == "05-12"
	replace subnatid2 = "05-13 - Kheda" if subnatid2 == "05-13"
	replace subnatid2 = "05-14 - Panchmahals" if subnatid2 == "05-14"
	replace subnatid2 = "05-15 - Vadodara" if subnatid2 == "05-15"
	replace subnatid2 = "05-16 - Bharuch" if subnatid2 == "05-16"
	replace subnatid2 = "05-17 - Surat" if subnatid2 == "05-17"
	replace subnatid2 = "05-18 - Valsad" if subnatid2 == "05-18"
	replace subnatid2 = "05-19 - The Dangs" if subnatid2 == "05-19"
	replace subnatid2 = "06-01 - Ambala" if subnatid2 == "06-01"
	replace subnatid2 = "06-02 - Kurukshetra" if subnatid2 == "06-02"
	replace subnatid2 = "06-03 - Karnal" if subnatid2 == "06-03"
	replace subnatid2 = "06-04 - Jind" if subnatid2 == "06-04"
	replace subnatid2 = "06-05 - Sonepat" if subnatid2 == "06-05"
	replace subnatid2 = "06-06 - Rohtak" if subnatid2 == "06-06"
	replace subnatid2 = "06-07 - Faridabad" if subnatid2 == "06-07"
	replace subnatid2 = "06-08 - Gurgaon" if subnatid2 == "06-08"
	replace subnatid2 = "06-09 - Mahendragarh" if subnatid2 == "06-09"
	replace subnatid2 = "06-10 - Bhiwani" if subnatid2 == "06-10"
	replace subnatid2 = "06-11 - Hissar" if subnatid2 == "06-11"
	replace subnatid2 = "06-12 - Sirsa" if subnatid2 == "06-12"
	replace subnatid2 = "07-01 - Chamba" if subnatid2 == "07-01"
	replace subnatid2 = "07-02 - Kangra" if subnatid2 == "07-02"
	replace subnatid2 = "07-03 - Hamirpur" if subnatid2 == "07-03"
	replace subnatid2 = "07-04 - Una" if subnatid2 == "07-04"
	replace subnatid2 = "07-05 - Bilaspur" if subnatid2 == "07-05"
	replace subnatid2 = "07-06 - Mandi" if subnatid2 == "07-06"
	replace subnatid2 = "07-07 - Kulu" if subnatid2 == "07-07"
	replace subnatid2 = "07-08 - Lahaur & Spiti" if subnatid2 == "07-08"
	replace subnatid2 = "07-09 - Simla" if subnatid2 == "07-09"
	replace subnatid2 = "07-10 - Solan" if subnatid2 == "07-10"
	replace subnatid2 = "07-11 - Sirmaur" if subnatid2 == "07-11"
	replace subnatid2 = "07-12 - Kinnaur" if subnatid2 == "07-12"
	replace subnatid2 = "08-01 - Anantang" if subnatid2 == "08-01"
	replace subnatid2 = "08-02 - Pulwama" if subnatid2 == "08-02"
	replace subnatid2 = "08-03 - Srinagar" if subnatid2 == "08-03"
	replace subnatid2 = "08-04 - Badgam" if subnatid2 == "08-04"
	replace subnatid2 = "08-05 - Barmula" if subnatid2 == "08-05"
	replace subnatid2 = "08-06 - Kupwara" if subnatid2 == "08-06"
	replace subnatid2 = "08-07 - Kargil" if subnatid2 == "08-07"
	replace subnatid2 = "08-08 - Ladakh" if subnatid2 == "08-08"
	replace subnatid2 = "08-09 - Doda" if subnatid2 == "08-09"
	replace subnatid2 = "08-10 - Udhampur" if subnatid2 == "08-10"
	replace subnatid2 = "08-11 - Kathua" if subnatid2 == "08-11"
	replace subnatid2 = "08-12 - Jammu" if subnatid2 == "08-12"
	replace subnatid2 = "08-13 - Rajouri" if subnatid2 == "08-13"
	replace subnatid2 = "08-14 - Poonch" if subnatid2 == "08-14"
	replace subnatid2 = "09-01 - Bangalore" if subnatid2 == "09-01"
	replace subnatid2 = "09-02 - Belgaum" if subnatid2 == "09-02"
	replace subnatid2 = "09-03 - Bellary" if subnatid2 == "09-03"
	replace subnatid2 = "09-04 - Bidar" if subnatid2 == "09-04"
	replace subnatid2 = "09-05 - Bijapur" if subnatid2 == "09-05"
	replace subnatid2 = "09-06 - Chikmagalur" if subnatid2 == "09-06"
	replace subnatid2 = "09-07 - Chitradurga" if subnatid2 == "09-07"
	replace subnatid2 = "09-08 - Dakshin Kannada" if subnatid2 == "09-08"
	replace subnatid2 = "09-09 - Dharwar" if subnatid2 == "09-09"
	replace subnatid2 = "09-10 - Gulbarga" if subnatid2 == "09-10"
	replace subnatid2 = "09-11 - Hassan" if subnatid2 == "09-11"
	replace subnatid2 = "09-12 - Kodagu" if subnatid2 == "09-12"
	replace subnatid2 = "09-13 - Kolar" if subnatid2 == "09-13"
	replace subnatid2 = "09-14 - Mandya" if subnatid2 == "09-14"
	replace subnatid2 = "09-15 - Mysore" if subnatid2 == "09-15"
	replace subnatid2 = "09-16 - Raichur" if subnatid2 == "09-16"
	replace subnatid2 = "09-17 - Shimoga" if subnatid2 == "09-17"
	replace subnatid2 = "09-18 - Thumkur" if subnatid2 == "09-18"
	replace subnatid2 = "09-19 - Uttar Kannada" if subnatid2 == "09-19"
	replace subnatid2 = "10-01 - Cannanore" if subnatid2 == "10-01"
	replace subnatid2 = "10-02 - Wynad" if subnatid2 == "10-02"
	replace subnatid2 = "10-03 - Kozhikode" if subnatid2 == "10-03"
	replace subnatid2 = "10-04 - Malappuram" if subnatid2 == "10-04"
	replace subnatid2 = "10-05 - Palghat" if subnatid2 == "10-05"
	replace subnatid2 = "10-06 - Trichur" if subnatid2 == "10-06"
	replace subnatid2 = "10-07 - Ernakulam" if subnatid2 == "10-07"
	replace subnatid2 = "10-08 - Idukki" if subnatid2 == "10-08"
	replace subnatid2 = "10-09 - Kottayam" if subnatid2 == "10-09"
	replace subnatid2 = "10-10 - Alleppey" if subnatid2 == "10-10"
	replace subnatid2 = "10-11 - Quilon" if subnatid2 == "10-11"
	replace subnatid2 = "10-12 - Trivandrum" if subnatid2 == "10-12"
	replace subnatid2 = "10-13 - Kasargod" if subnatid2 == "10-13"
	replace subnatid2 = "10-14 - Pathanamthitta" if subnatid2 == "10-14"
	replace subnatid2 = "11-01 - Morena" if subnatid2 == "11-01"
	replace subnatid2 = "11-02 - Bhind" if subnatid2 == "11-02"
	replace subnatid2 = "11-03 - Gwalior" if subnatid2 == "11-03"
	replace subnatid2 = "11-04 - Datian" if subnatid2 == "11-04"
	replace subnatid2 = "11-05 - Shivpuri" if subnatid2 == "11-05"
	replace subnatid2 = "11-06 - Guna" if subnatid2 == "11-06"
	replace subnatid2 = "11-07 - Tikamgarh" if subnatid2 == "11-07"
	replace subnatid2 = "11-08 - Chhatarpur" if subnatid2 == "11-08"
	replace subnatid2 = "11-09 - Panna" if subnatid2 == "11-09"
	replace subnatid2 = "11-10 - Sagar" if subnatid2 == "11-10"
	replace subnatid2 = "11-11 - Damoh" if subnatid2 == "11-11"
	replace subnatid2 = "11-12 - Satna" if subnatid2 == "11-12"
	replace subnatid2 = "11-13 - Rewa" if subnatid2 == "11-13"
	replace subnatid2 = "11-14 - Shahdol" if subnatid2 == "11-14"
	replace subnatid2 = "11-15 - Sidhi" if subnatid2 == "11-15"
	replace subnatid2 = "11-16 - Manisaur" if subnatid2 == "11-16"
	replace subnatid2 = "11-17 - Ratlam" if subnatid2 == "11-17"
	replace subnatid2 = "11-18 - Ujjain" if subnatid2 == "11-18"
	replace subnatid2 = "11-19 - Shajapur" if subnatid2 == "11-19"
	replace subnatid2 = "11-20 - Dewas" if subnatid2 == "11-20"
	replace subnatid2 = "11-21 - Jhabua" if subnatid2 == "11-21"
	replace subnatid2 = "11-22 - Dharwar" if subnatid2 == "11-22"
	replace subnatid2 = "11-23 - Indore" if subnatid2 == "11-23"
	replace subnatid2 = "11-24 - Khargone" if subnatid2 == "11-24"
	replace subnatid2 = "11-25 - Khandwa" if subnatid2 == "11-25"
	replace subnatid2 = "11-26 - Raigarh" if subnatid2 == "11-26"
	replace subnatid2 = "11-27 - Vidisha" if subnatid2 == "11-27"
	replace subnatid2 = "11-28 - Bhopal" if subnatid2 == "11-28"
	replace subnatid2 = "11-29 - Sahore" if subnatid2 == "11-29"
	replace subnatid2 = "11-30 - Raisen" if subnatid2 == "11-30"
	replace subnatid2 = "11-31 - Betul" if subnatid2 == "11-31"
	replace subnatid2 = "11-32 - Hoshangabad" if subnatid2 == "11-32"
	replace subnatid2 = "11-33 - Jabalpur" if subnatid2 == "11-33"
	replace subnatid2 = "11-34 - Narshinhapur" if subnatid2 == "11-34"
	replace subnatid2 = "11-35 - Mandla" if subnatid2 == "11-35"
	replace subnatid2 = "11-36 - Chhidwara" if subnatid2 == "11-36"
	replace subnatid2 = "11-37 - Seoni" if subnatid2 == "11-37"
	replace subnatid2 = "11-38 - Balaghat" if subnatid2 == "11-38"
	replace subnatid2 = "11-39 - Surguja" if subnatid2 == "11-39"
	replace subnatid2 = "11-40 - Bilaspur" if subnatid2 == "11-40"
	replace subnatid2 = "11-41 - Raigarh" if subnatid2 == "11-41"
	replace subnatid2 = "11-42 - Rajnandgaon" if subnatid2 == "11-42"
	replace subnatid2 = "11-43 - Durg" if subnatid2 == "11-43"
	replace subnatid2 = "11-44 - Raipur" if subnatid2 == "11-44"
	replace subnatid2 = "11-45 - Bastar" if subnatid2 == "11-45"
	replace subnatid2 = "12-01 - Greater Bombay" if subnatid2 == "12-01"
	replace subnatid2 = "12-02 - Thane" if subnatid2 == "12-02"
	replace subnatid2 = "12-03 - Raigarh" if subnatid2 == "12-03"
	replace subnatid2 = "12-04 - Retangiri" if subnatid2 == "12-04"
	replace subnatid2 = "12-05 - Nasik" if subnatid2 == "12-05"
	replace subnatid2 = "12-06 - Dhule" if subnatid2 == "12-06"
	replace subnatid2 = "12-07 - Jalgaon" if subnatid2 == "12-07"
	replace subnatid2 = "12-08 - Ahmednagar" if subnatid2 == "12-08"
	replace subnatid2 = "12-09 - Pune" if subnatid2 == "12-09"
	replace subnatid2 = "12-10 - Satara" if subnatid2 == "12-10"
	replace subnatid2 = "12-11 - Sangli" if subnatid2 == "12-11"
	replace subnatid2 = "12-12 - Solapur" if subnatid2 == "12-12"
	replace subnatid2 = "12-13 - Kolhapur" if subnatid2 == "12-13"
	replace subnatid2 = "12-14 - Aurangabad" if subnatid2 == "12-14"
	replace subnatid2 = "12-15 - Parbhani" if subnatid2 == "12-15"
	replace subnatid2 = "12-16 - Beed" if subnatid2 == "12-16"
	replace subnatid2 = "12-17 - Nanded" if subnatid2 == "12-17"
	replace subnatid2 = "12-18 - Usmanabad" if subnatid2 == "12-18"
	replace subnatid2 = "12-19 - Buldara" if subnatid2 == "12-19"
	replace subnatid2 = "12-20 - Akola" if subnatid2 == "12-20"
	replace subnatid2 = "12-21 - Amravati" if subnatid2 == "12-21"
	replace subnatid2 = "12-22 - Yavatmal" if subnatid2 == "12-22"
	replace subnatid2 = "12-23 - Wardha" if subnatid2 == "12-23"
	replace subnatid2 = "12-24 - Nagpur" if subnatid2 == "12-24"
	replace subnatid2 = "12-25 - Bhandara" if subnatid2 == "12-25"
	replace subnatid2 = "12-26 - Chanrapur" if subnatid2 == "12-26"
	replace subnatid2 = "12-27 - Jalna" if subnatid2 == "12-27"
	replace subnatid2 = "12-28 - Sindhudurg" if subnatid2 == "12-28"
	replace subnatid2 = "12-29 - Latur" if subnatid2 == "12-29"
	replace subnatid2 = "13-01 - Manipur North" if subnatid2 == "13-01"
	replace subnatid2 = "13-02 - Manipur West" if subnatid2 == "13-02"
	replace subnatid2 = "13-03 - Manipur South" if subnatid2 == "13-03"
	replace subnatid2 = "13-04 - Tengnoupal" if subnatid2 == "13-04"
	replace subnatid2 = "13-05 - Imphal" if subnatid2 == "13-05"
	replace subnatid2 = "13-06 - Bishnupur" if subnatid2 == "13-06"
	replace subnatid2 = "13-07 - Thoubal" if subnatid2 == "13-07"
	replace subnatid2 = "13-08 - Manipur East" if subnatid2 == "13-08"
	replace subnatid2 = "14-01 - Jaintia Hills" if subnatid2 == "14-01"
	replace subnatid2 = "14-02 - East Khasi Hills" if subnatid2 == "14-02"
	replace subnatid2 = "14-03 - West Khasi Hills" if subnatid2 == "14-03"
	replace subnatid2 = "14-04 - East Garo Hills" if subnatid2 == "14-04"
	replace subnatid2 = "14-05 - West Garo Hills" if subnatid2 == "14-05"
	replace subnatid2 = "15-01 - Kohima" if subnatid2 == "15-01"
	replace subnatid2 = "15-02 - Phek" if subnatid2 == "15-02"
	replace subnatid2 = "15-03 - Wokha" if subnatid2 == "15-03"
	replace subnatid2 = "15-04 - Zonhebato" if subnatid2 == "15-04"
	replace subnatid2 = "15-05 - Makokohung" if subnatid2 == "15-05"
	replace subnatid2 = "15-06 - Tuensang" if subnatid2 == "15-06"
	replace subnatid2 = "15-07 - Mou" if subnatid2 == "15-07"
	replace subnatid2 = "16-01 - Sambalpur" if subnatid2 == "16-01"
	replace subnatid2 = "16-02 - Sundargarh" if subnatid2 == "16-02"
	replace subnatid2 = "16-03 - Keonjhar" if subnatid2 == "16-03"
	replace subnatid2 = "16-04 - Mayurbhanj" if subnatid2 == "16-04"
	replace subnatid2 = "16-05 - Balasore" if subnatid2 == "16-05"
	replace subnatid2 = "16-06 - Cukkack" if subnatid2 == "16-06"
	replace subnatid2 = "16-07 - Dhen Kahal" if subnatid2 == "16-07"
	replace subnatid2 = "16-08 - Baudh Khondmals" if subnatid2 == "16-08"
	replace subnatid2 = "16-09 - Bolangir" if subnatid2 == "16-09"
	replace subnatid2 = "16-10 - Kalahandi" if subnatid2 == "16-10"
	replace subnatid2 = "16-11 - Koraput" if subnatid2 == "16-11"
	replace subnatid2 = "16-12 - Ganjam" if subnatid2 == "16-12"
	replace subnatid2 = "16-13 - Puri" if subnatid2 == "16-13"
	replace subnatid2 = "17-01 - Gurudaspur" if subnatid2 == "17-01"
	replace subnatid2 = "17-02 - Amritsar" if subnatid2 == "17-02"
	replace subnatid2 = "17-03 - Ferozpur" if subnatid2 == "17-03"
	replace subnatid2 = "17-04 - Ludhiana" if subnatid2 == "17-04"
	replace subnatid2 = "17-05 - Jullundur" if subnatid2 == "17-05"
	replace subnatid2 = "17-06 - Kapurthala" if subnatid2 == "17-06"
	replace subnatid2 = "17-07 - Hoshiarpur" if subnatid2 == "17-07"
	replace subnatid2 = "17-08 - Rupnagar" if subnatid2 == "17-08"
	replace subnatid2 = "17-09 - Patiala" if subnatid2 == "17-09"
	replace subnatid2 = "17-10 - Sangrur" if subnatid2 == "17-10"
	replace subnatid2 = "17-11 - Bhatinda" if subnatid2 == "17-11"
	replace subnatid2 = "17-12 - Faridkot" if subnatid2 == "17-12"
	replace subnatid2 = "18-01 - Ganganagar" if subnatid2 == "18-01"
	replace subnatid2 = "18-02 - Bikaner" if subnatid2 == "18-02"
	replace subnatid2 = "18-03 - Cauru" if subnatid2 == "18-03"
	replace subnatid2 = "18-04 - Jhunjhunun" if subnatid2 == "18-04"
	replace subnatid2 = "18-05 - Alwar" if subnatid2 == "18-05"
	replace subnatid2 = "18-06 - Bharatpur" if subnatid2 == "18-06"
	replace subnatid2 = "18-07 - Sawai-Modhopur" if subnatid2 == "18-07"
	replace subnatid2 = "18-08 - Jaipur" if subnatid2 == "18-08"
	replace subnatid2 = "18-09 - Sikar" if subnatid2 == "18-09"
	replace subnatid2 = "18-10 - Ajmer" if subnatid2 == "18-10"
	replace subnatid2 = "18-11 - Tonk" if subnatid2 == "18-11"
	replace subnatid2 = "18-12 - Jaisalmer" if subnatid2 == "18-12"
	replace subnatid2 = "18-13 - Jodhpur" if subnatid2 == "18-13"
	replace subnatid2 = "18-14 - Nagpur" if subnatid2 == "18-14"
	replace subnatid2 = "18-15 - Pali" if subnatid2 == "18-15"
	replace subnatid2 = "18-16 - Parmer" if subnatid2 == "18-16"
	replace subnatid2 = "18-17 - Jalor" if subnatid2 == "18-17"
	replace subnatid2 = "18-18 - Sirchi" if subnatid2 == "18-18"
	replace subnatid2 = "18-19 - Bhilwara" if subnatid2 == "18-19"
	replace subnatid2 = "18-20 - Udaipur" if subnatid2 == "18-20"
	replace subnatid2 = "18-21 - Chittorgarh" if subnatid2 == "18-21"
	replace subnatid2 = "18-22 - Dungarpur" if subnatid2 == "18-22"
	replace subnatid2 = "18-23 - Banswara" if subnatid2 == "18-23"
	replace subnatid2 = "18-24 - Bundi" if subnatid2 == "18-24"
	replace subnatid2 = "18-25 - Kota" if subnatid2 == "18-25"
	replace subnatid2 = "18-26 - Jhalawar" if subnatid2 == "18-26"
	replace subnatid2 = "18-27 - Dholpur" if subnatid2 == "18-27"
	replace subnatid2 = "19-01 - North East" if subnatid2 == "19-01"
	replace subnatid2 = "19-02 - East" if subnatid2 == "19-02"
	replace subnatid2 = "19-03 - South" if subnatid2 == "19-03"
	replace subnatid2 = "19-04 - West" if subnatid2 == "19-04"
	replace subnatid2 = "20-01 - Madras" if subnatid2 == "20-01"
	replace subnatid2 = "20-02 - Chingalpattu" if subnatid2 == "20-02"
	replace subnatid2 = "20-03 - North Arcot" if subnatid2 == "20-03"
	replace subnatid2 = "20-04 - South Arcot" if subnatid2 == "20-04"
	replace subnatid2 = "20-05 - Dharmapuri" if subnatid2 == "20-05"
	replace subnatid2 = "20-06 - Salem" if subnatid2 == "20-06"
	replace subnatid2 = "20-07 - Periyar" if subnatid2 == "20-07"
	replace subnatid2 = "20-08 - Coimbatore" if subnatid2 == "20-08"
	replace subnatid2 = "20-09 - Nilgiris" if subnatid2 == "20-09"
	replace subnatid2 = "20-10 - Madurai" if subnatid2 == "20-10"
	replace subnatid2 = "20-11 - Tiruchirapalli" if subnatid2 == "20-11"
	replace subnatid2 = "20-12 - Thanjavu" if subnatid2 == "20-12"
	replace subnatid2 = "20-13 - Pudukkottai" if subnatid2 == "20-13"
	replace subnatid2 = "20-14 - Ramanathapuram" if subnatid2 == "20-14"
	replace subnatid2 = "20-15 - Tirunelvalli" if subnatid2 == "20-15"
	replace subnatid2 = "20-16 - Kanyakumari" if subnatid2 == "20-16"
	replace subnatid2 = "20-17 - Ramalingam" if subnatid2 == "20-17"
	replace subnatid2 = "20-18 - Kamarajar" if subnatid2 == "20-18"
	replace subnatid2 = "20-19 - Anna" if subnatid2 == "20-19"
	replace subnatid2 = "21-01 - West Tripura" if subnatid2 == "21-01"
	replace subnatid2 = "21-02 - North Tripura" if subnatid2 == "21-02"
	replace subnatid2 = "21-03 - South Tripura" if subnatid2 == "21-03"
	replace subnatid2 = "22-01 - Uttar Kashi" if subnatid2 == "22-01"
	replace subnatid2 = "22-02 - Chamoli" if subnatid2 == "22-02"
	replace subnatid2 = "22-03 - Theri Garwal" if subnatid2 == "22-03"
	replace subnatid2 = "22-04 - Dehra Dun" if subnatid2 == "22-04"
	replace subnatid2 = "22-05 - Garhwal" if subnatid2 == "22-05"
	replace subnatid2 = "22-06 - Pithora Garh" if subnatid2 == "22-06"
	replace subnatid2 = "22-07 - Almora" if subnatid2 == "22-07"
	replace subnatid2 = "22-08 - Nainital" if subnatid2 == "22-08"
	replace subnatid2 = "22-09 - Saharanpur" if subnatid2 == "22-09"
	replace subnatid2 = "22-10 - Muzaffarnagar" if subnatid2 == "22-10"
	replace subnatid2 = "22-11 - Disnor" if subnatid2 == "22-11"
	replace subnatid2 = "22-12 - Meerut" if subnatid2 == "22-12"
	replace subnatid2 = "22-13 - Ghaziabad" if subnatid2 == "22-13"
	replace subnatid2 = "22-14 - Bulandshahr" if subnatid2 == "22-14"
	replace subnatid2 = "22-15 - Moradabad" if subnatid2 == "22-15"
	replace subnatid2 = "22-16 - Rampur" if subnatid2 == "22-16"
	replace subnatid2 = "22-17 - Budaun" if subnatid2 == "22-17"
	replace subnatid2 = "22-18 - Bareilly" if subnatid2 == "22-18"
	replace subnatid2 = "22-19 - Pilibhit" if subnatid2 == "22-19"
	replace subnatid2 = "22-20 - Shahjahanpur" if subnatid2 == "22-20"
	replace subnatid2 = "22-21 - Aligarh" if subnatid2 == "22-21"
	replace subnatid2 = "22-22 - Mathura" if subnatid2 == "22-22"
	replace subnatid2 = "22-23 - Agra" if subnatid2 == "22-23"
	replace subnatid2 = "22-24 - Etah" if subnatid2 == "22-24"
	replace subnatid2 = "22-25 - Mainpuri" if subnatid2 == "22-25"
	replace subnatid2 = "22-26 - Farukhabad" if subnatid2 == "22-26"
	replace subnatid2 = "22-27 - Etawah" if subnatid2 == "22-27"
	replace subnatid2 = "22-28 - Kanpur" if subnatid2 == "22-28"
	replace subnatid2 = "22-29 - Fatehpur" if subnatid2 == "22-29"
	replace subnatid2 = "22-30 - Allahabad" if subnatid2 == "22-30"
	replace subnatid2 = "22-31 - Jalaun" if subnatid2 == "22-31"
	replace subnatid2 = "22-32 - Jhansi" if subnatid2 == "22-32"
	replace subnatid2 = "22-33 - Lalitpur" if subnatid2 == "22-33"
	replace subnatid2 = "22-34 - Hamirpur" if subnatid2 == "22-34"
	replace subnatid2 = "22-35 - Banda" if subnatid2 == "22-35"
	replace subnatid2 = "22-36 - Kheri" if subnatid2 == "22-36"
	replace subnatid2 = "22-37 - Sitapur" if subnatid2 == "22-37"
	replace subnatid2 = "22-38 - Hardoi" if subnatid2 == "22-38"
	replace subnatid2 = "22-39 - Unnao" if subnatid2 == "22-39"
	replace subnatid2 = "22-40 - Lucknow" if subnatid2 == "22-40"
	replace subnatid2 = "22-41 - Raibareli" if subnatid2 == "22-41"
	replace subnatid2 = "22-42 - Baharaich" if subnatid2 == "22-42"
	replace subnatid2 = "22-43 - Gonia" if subnatid2 == "22-43"
	replace subnatid2 = "22-44 - Barabanki" if subnatid2 == "22-44"
	replace subnatid2 = "22-45 - Faizabad" if subnatid2 == "22-45"
	replace subnatid2 = "22-46 - Sultanpur" if subnatid2 == "22-46"
	replace subnatid2 = "22-47 - Pratapgarh" if subnatid2 == "22-47"
	replace subnatid2 = "22-48 - Basti" if subnatid2 == "22-48"
	replace subnatid2 = "22-49 - Gorakhpur" if subnatid2 == "22-49"
	replace subnatid2 = "22-50 - Deoria" if subnatid2 == "22-50"
	replace subnatid2 = "22-51 - Azamgarh" if subnatid2 == "22-51"
	replace subnatid2 = "22-52 - Jaunpur" if subnatid2 == "22-52"
	replace subnatid2 = "22-53 - Balia" if subnatid2 == "22-53"
	replace subnatid2 = "22-54 - Ghazipur" if subnatid2 == "22-54"
	replace subnatid2 = "22-55 - Varanasi" if subnatid2 == "22-55"
	replace subnatid2 = "22-56 - Mirzapur" if subnatid2 == "22-56"
	replace subnatid2 = "23-01 - Cooch Behar" if subnatid2 == "23-01"
	replace subnatid2 = "23-02 - Jalpaiguri" if subnatid2 == "23-02"
	replace subnatid2 = "23-03 - Darjeeling" if subnatid2 == "23-03"
	replace subnatid2 = "23-04 - West Dinajpur" if subnatid2 == "23-04"
	replace subnatid2 = "23-05 - Maldah" if subnatid2 == "23-05"
	replace subnatid2 = "23-06 - Murshidabad" if subnatid2 == "23-06"
	replace subnatid2 = "23-07 - Nadia" if subnatid2 == "23-07"
	replace subnatid2 = "23-08 - Parganas North" if subnatid2 == "23-08"
	replace subnatid2 = "23-09 - Calcutta" if subnatid2 == "23-09"
	replace subnatid2 = "23-10 - Howrah" if subnatid2 == "23-10"
	replace subnatid2 = "23-11 - Hoogly" if subnatid2 == "23-11"
	replace subnatid2 = "23-12 - Midnapur" if subnatid2 == "23-12"
	replace subnatid2 = "23-13 - Bankura" if subnatid2 == "23-13"
	replace subnatid2 = "23-14 - Purulia" if subnatid2 == "23-14"
	replace subnatid2 = "23-15 - Burdwan" if subnatid2 == "23-15"
	replace subnatid2 = "23-16 - Birbhum" if subnatid2 == "23-16"
	replace subnatid2 = "23-17 - Parganas South" if subnatid2 == "23-17"
	replace subnatid2 = "24-01 - Andaman" if subnatid2 == "24-01"
	replace subnatid2 = "24-02 - Nicobar" if subnatid2 == "24-02"
	replace subnatid2 = "25-01 - West Kameng" if subnatid2 == "25-01"
	replace subnatid2 = "25-02 - East Kameng" if subnatid2 == "25-02"
	replace subnatid2 = "25-03 - Lower Subansiri" if subnatid2 == "25-03"
	replace subnatid2 = "25-04 - Upper Subansiri" if subnatid2 == "25-04"
	replace subnatid2 = "25-05 - West Siang" if subnatid2 == "25-05"
	replace subnatid2 = "25-06 - East Siang" if subnatid2 == "25-06"
	replace subnatid2 = "25-07 - Dibang Valley" if subnatid2 == "25-07"
	replace subnatid2 = "25-08 - Lohit" if subnatid2 == "25-08"
	replace subnatid2 = "25-09 - Tirap" if subnatid2 == "25-09"
	replace subnatid2 = "26-01 - Chandigarh" if subnatid2 == "26-01"
	replace subnatid2 = "27-01 - Dadra & Nagar Haveli" if subnatid2 == "27-01"
	replace subnatid2 = "28-01 - Delhi" if subnatid2 == "28-01"
	replace subnatid2 = "29-01 - Goa" if subnatid2 == "29-01"
	replace subnatid2 = "29-02 - Daman" if subnatid2 == "29-02"
	replace subnatid2 = "29-03 - Diu" if subnatid2 == "29-03"
	replace subnatid2 = "30-01 - Lakshadweep" if subnatid2 == "30-01"
	replace subnatid2 = "31-01 - Aizawl" if subnatid2 == "31-01"
	replace subnatid2 = "31-02 - Linglee" if subnatid2 == "31-02"
	replace subnatid2 = "31-03 - Chhimtuipui" if subnatid2 == "31-03"
	replace subnatid2 = "32-01 - Pondicherry" if subnatid2 == "32-01"
	replace subnatid2 = "32-02 - Karaikal" if subnatid2 == "32-02"
	replace subnatid2 = "32-03 - Mahe" if subnatid2 == "32-03"
	replace subnatid2 = "32-04 - Yanam" if subnatid2 == "32-04"
*</_subnatid2_>


*<_subnatid3_>
	gen str subnatid3 = ""
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
	gen subnatidsurvey = ""
	replace subnatidsurvey = subnatid1 + " - Urban" if urban == 1
	replace subnatidsurvey = subnatid1 + " - Rural" if urban == 0
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
================================================================================================*/

{

*<_hsize_>
	* Need to recount hh size after dropping individuals in data assembly
	bys hhid: gen hsize = _N
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen age = B4_q5
	label var age "Individual age"
*</_age_>


*<_male_>
	destring B4_q4, gen(male)
	recode male (2 = 0)
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
/* <_relationharm_note>

	1578 observations (335 HHs) have either no head or more than one.
	Elect HH head following this order:
	 a) eldest male head, if not
	 b) eldest female if no male the head. Use
	 c) lowest running ID to break ties
	Other heads sent to value 5, coded as "Other relatives"
</_relationharm_note> */


	destring B4_q3, replace

	bys Hhold_key: gen one=1 if B4_q3==1
	bys Hhold_key: egen temp=count(one)
	tab temp

	destring Prsn_Slno, gen(pno)
	destring B4_q4, gen(sex)
	gen relation = B4_q3
	bys Hhold_key relation: egen istheremale = total(sex==1)
	bys Hhold_key relation: egen maxagemale = max(cond(sex==1,age,.))
	bys Hhold_key relation: egen maxagefemale = max(cond(sex==2,age,.))
	bys Hhold_key relation: egen minid = min(pno)
	bys Hhold_key relation: egen howmany = total(age==maxagefemale)

	replace relation = 1 if temp==0 & istheremale>=1 & age==maxagemale & minid==pno
	replace relation = 1 if temp==0 & istheremale==0 & age==maxagefemale & minid==pno

	drop istheremale maxage* minid howmany one temp
	bys Hhold_key: gen one=1 if relation==1
	bys Hhold_key: egen temp=count(one)
	tab temp

	bys Hhold_key relation: egen istheremale = total(sex==1)
	bys Hhold_key relation: egen maxagemale = max(cond(sex==1,age,.))
	bys Hhold_key relation: egen maxagefemale = max(cond(sex==2,age,.))
	bys Hhold_key relation: egen minid = min(pno)
	bys Hhold_key relation: egen howmany = total(age==maxagefemale)

	replace relation = cond(temp>1 & relation ==1 & istheremale>=1 & (age!=maxagemale|sex==2),5,cond(age!=maxagefemale & howmany == 1 & temp>1 & relation ==1 &istheremale==0,5,cond(minid!=pno & howmany >1 & temp>1 & relation ==1 & istheremale==0,5,relation)))

	drop one temp
	bys Hhold_key: gen one=1 if relation==1
	bys Hhold_key: egen temp=count(one)
	tab temp
	* 33 cases left, 5 HHs, change manually.

	replace relation = 5 if Hhold_key == "10230202" & pno == 2
	replace relation = 5 if Hhold_key == "11249202" & pno == 11
	replace relation = 5 if Hhold_key == "14591101" & pno == 2
	replace relation = 5 if Hhold_key == "73988201" & pno == 2
	replace relation = 5 if Hhold_key == "74623207" & pno == 100

	drop one temp
	bys Hhold_key: gen one=1 if relation==1
	bys Hhold_key: egen temp=count(one)
	tab temp

	drop one temp
	* At this point, we have single HH head per HH

	gen relationharm = relation
	recode relationharm (3 5 = 3) (7=4) (4 6 8 = 5) (9=6) (0=.)
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = relation
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>
*/

*<_marital_>
	destring B4_q6, gen(marital)
	recode marital (1 = 2) (2 = 1) (3 = 5)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital

	*All spouses should not have "never been married" response
	replace marital = 1 if relationharm == 2

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
/* <_migrated_ref_time_note>

	 Records a change in the place of usual residence.
	 The usual residence for the purpose of this survey being
	 defined as a place (village or town) where the person has
	 stayed continuously for a period of six months or more.
</_migrated_ref_time_note> */

	gen migrated_ref_time = 99
	label var migrated_ref_time "Reference time applied to migration questions"
*</_migrated_ref_time_>


*<_migrated_binary_>
	destring B6_q14, gen(migrated_binary)
	recode migrated_binary (2 = 0)
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen migrated_years = .
	replace migrated_years = B6_q15 if migrated_binary == 1
	label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban = .
	replace migrated_from_urban = 1 if inlist(B6_q16, "2", "4", "6") & migrated_binary == 1
	replace migrated_from_urban = 0 if inlist(B6_q16, "1", "3", "5") & migrated_binary == 1
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen migrated_from_cat = .
	replace migrated_from_cat = 2 if inlist(B6_q16, "1", "2") & migrated_binary == 1
	replace migrated_from_cat = 3 if inlist(B6_q16, "3", "4") & migrated_binary == 1
	replace migrated_from_cat = 4 if inlist(B6_q16, "5", "6") & migrated_binary == 1
	replace migrated_from_cat = 5 if inlist(B6_q16, "7") & migrated_binary == 1
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	destring B6_q18, gen(helper_var)
	gen migrated_from_code = .
	replace migrated_from_code = subnatid1_num if inrange(migrated_from_cat,1,3)
	replace migrated_from_code = helper_var if migrated_from_cat == 4 & (helper_var != subnatid1_num)
	/* In the above code, if the respondent declared migrating from a diff state but the
	state of residence 6 months ago is same as the current state of residence, then
	this data should be missing.
	*/
	
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
	* Codes of origin do not clearly identify the specific countries
	gen migrated_from_country = ""
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason = .
	replace migrated_reason =  3 if inlist(B6_q21,"1", "2", "3") & !missing(migrated_binary)
	replace migrated_reason =  2 if inlist(B6_q21,"4") & !missing(migrated_binary)
	replace migrated_reason =  1 if inlist(B6_q21,"5", "6") & !missing(migrated_binary)
	replace migrated_reason =  4 if inlist(B6_q21,"7", "8") & !missing(migrated_binary)
	replace migrated_reason =  5 if inlist(B6_q21,"9") & !missing(migrated_binary)
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
	gen byte school = .
	replace school=0 if B4_q9 == "01"
	replace school=1 if B4_q9 != "01" & !missing(B4_q9)
	replace school=. if B4_q9 == "99"
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen byte literacy = .
	replace literacy = 0 if B4_q7 == "00"
	replace literacy = 1 if B4_q7 != "00" & !missing(B4_q7)
	*Allow for missing values if literacy cannot be determined
	replace literacy = . if B4_q7 == "99"
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>

*<_educy_>
	gen educy=.
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	destring B4_q7, gen(genedulev)
	gen byte educat7 = .
	replace educat7= 1 if genedulev== 0 | genedulev==1 // No educ
	replace educat7 = 2 if genedulev == 2 // Primary incomplete
	replace educat7 = 3 if genedulev == 3  // Primary complete
	replace educat7 = 4 if genedulev == 4   // Secondary incomplete
	replace educat7 = 5 if genedulev == 5  // Secondary complete
	replace educat7= 7 if inrange(genedulev, 6, 9)
	replace educat7= 6 if inrange(genedulev, 10, 14)
	replace educat7=. if  genedulev==99
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
	recode educat4 2 3 4=2 5=3 6 7=4
	label var educat4 "Level of education 3"
	la de lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 lbleducat4
*</_educat4_>


*<_educat_orig_>
 	gen educat_orig = B4_q7
 	label var educat_orig "Original survey education code"
 *</_educat_orig_>


*<_educat_isced_>
	destring B4_q7, gen(genedulev)
	gen educat_isced = .
	replace educat_isced = 0 if genedulev == 2 //early childhood education
	replace educat_isced = 100 if genedulev == 3 //Primary education
	replace educat_isced = 200 if genedulev == 4 // Lower secondary
	replace educat_isced = 300 if genedulev == 5 //Upper secondary
	replace educat_isced = 600 if inrange(genedulev, 6, 9) //Bachelor
	label var educat_isced "ISCED standardised level of education"
	drop genedulev
*</_educat_isced_>



*----------6.1: Education cleanup------------------------------*

*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
local ed_var "school literacy educy educat7 educat5 educat4 educat_isced"

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
================================================================================================*/


{

*<_vocational_>
	gen vocational = .
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
	gen byte minlaborage = 5
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{

*<_lstatus_>
	destring B4_q11, gen(lstatus)
	recode lstatus  (11/72 98 = 1) (81=2) (82 91/97=3) (99=.)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = .
	replace potential_lf = 0 if lstatus == 3
	replace potential_lf = 1 if B4_q11 == "82"
	replace potential_lf = . if age < minlaborage & age != .
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
	destring B4_q11, gen(nlfreason)
	recode nlfreason (11/81 98=.) (91=1) (92 93=2) (94=3) (95=4) (82 96 97=5)
	replace nlfreason = . if lstatus != 3 | (age < minlaborage & age != .)
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen unempldur_l = .
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen unempldur_u = .
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>

}


*----------8.2: 7 day reference main job------------------------------*


{

*<_empstat_>
	destring B4_q11, gen(empstat)
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
	gen industry_orig = B4_q14
	replace industry_orig = "" if lstatus != 1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>

	/* <_industrycat_isic_note>

	Have found no NIC70 to ISIC-68 (ISIC Rev2). NIC 70 and NIC 87 basically tha same, small amendments needed.
	Process is:
		1) Translate NIC70 to NIC87
		2) Use NIC87 to ISIC Rev2 translator
	</_industrycat_isic_note> */

	gen nic_87 = industry_orig
	replace nic_87 = substr(nic_87,1,2)
	replace nic_87 = nic_87 + "0" if length(nic_87) == 1
	replace nic_87 = "" if lstatus != 1
	gen nic_70 = nic_87

	replace nic_87 = "12" if industry_orig == "120"
	replace nic_87 = "13" if inlist(industry_orig, "121", "122", "123", "124", "125", "126", "127", "128", "129")
	replace nic_87 = "15" if nic_70 == "19"
	replace nic_87 = "30" if nic_70 == "31"
	replace nic_87 = "31" if nic_70 == "30"
	replace nic_87 = "61" if nic_70 == "62"
	replace nic_87 = "62" if nic_70 == "63"
	replace nic_87 = "63" if nic_70 == "64"
	replace nic_87 = "64" if industry_orig == "821"
	replace nic_87 = "82" if industry_orig == "820"
	replace nic_87 = "85" if industry_orig == "827"
	replace nic_87 = "89" if inlist(industry_orig, "822", "823", "824", "825", "826", "828", "829")

	replace nic_87 = nic_87 + "0"
	replace nic_87 = "" if regexm(nic_87, "x|X")

	merge m:1 nic_87 using "`path_in_stata'/nic87_to_isic2.dta", nogen keep(match master)

	gen industrycat_isic = isic_68
	replace industrycat_isic = "" if lstatus != 1

	* Set NIC X codes (not correctly defined) to ISIC-2 0000
	replace industrycat_isic = "0000" if regexm(industry_orig, "x|X")

	* Take care of construction: NIC 51 codes are allied to construction, ISIC 2
	* only has 5000 for construction
	replace industrycat_isic = "5000" if regexm(industry_orig, "^51")

	label var industrycat_isic "ISIC code of primary job 7 day recall"
	drop nic_87 nic_70 isic_68
*</_industrycat_isic_>


*<_industrycat10_>

	/* <_industrycat10_note>
	Use industrycat_isic (revision 2).
	</_industrycat10_note> */

	destring industrycat_isic, gen(helper_isic)
	replace helper_isic = floor(helper_isic/100)

	gen industrycat10 = .

	replace industrycat10 = 1 if inrange(helper_isic,11,13)
	replace industrycat10 = 2 if inrange(helper_isic,21,29)
	replace industrycat10 = 3 if inrange(helper_isic,31,39)
	replace industrycat10 = 4 if inrange(helper_isic,41,42)
	replace industrycat10 = 5 if inrange(helper_isic,50,51)
	replace industrycat10 = 6 if inrange(helper_isic,61,63)
	replace industrycat10 = 7 if inrange(helper_isic,71,72)
	replace industrycat10 = 8 if inrange(helper_isic,81,83)
	replace industrycat10 = 9 if inrange(helper_isic,91,91)
	replace industrycat10 = 10 if inrange(helper_isic,92,96) | helper_isic == 0

	replace industrycat10=. if lstatus != 1 | (age < minlaborage & age != .)

	* Set NIC X codes (not correctly defined) to industrycat10 code 10
	replace industrycat10 = 10 if regexm(industry_orig, "x|X|y|Y")

	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
	drop helper_isic
*</_industrycat10_>


*<_industrycat4_>
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4 "1 digit industry classification (Broad Economic Activities), primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
	gen occup_orig = B4_q15
	replace occup_orig = "" if lstatus != 1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_>
	gen nco_68 = B4_q15
	gen x_indic = regexm(nco_68, "x|X|y|y")
	replace nco_68 = "099" if x_indic == 1
	replace nco_68 = "0" + nco_68 if length(nco_68) == 2
	replace nco_68 = "00" + nco_68 if length(nco_68) == 1

	merge m:1 nco_68 using "`path_in_stata'/India_occup_correspondences.dta", nogen keep(match master)
	gen code_04 = substr(nco_04,1,1)
	destring code_04, replace

	gen occup = .
	replace occup = code_04 if lstatus == 1 & (age >= minlaborage & age != .)
	replace occup = 99 if x_indic == 1 & lstatus == 1 & (age >= minlaborage & age != .)
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
	drop x_indic nco_68 code_04 nco_04 isco_88
*</_occup_>


*<_occup_isco_>
	gen nco_68 = B4_q15
	gen x_indic = regexm(nco_68, "x|X|y|y")
	replace nco_68 = "099" if x_indic == 1
	replace nco_68 = "0" + nco_68 if length(nco_68) == 2
	replace nco_68 = "00" + nco_68 if length(nco_68) == 1

	merge m:1 nco_68 using "`path_in_stata'/India_occup_correspondences.dta", nogen keep(match master)

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
	la de lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lblskill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_wage_no_compen_>
	gen double wage_no_compen = B5_q141
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

</_whours_note> */
	gen whours = 8*B5_q131
	replace whours=. if lstatus != 1 | (age < minlaborage & age != .)
	replace whours = . if whours == 0
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	gen wmonths = .
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
/* <_wage_total_note>

	Since this is annualized but no information is given on how many months of work cannot fill it out

</_wage_total_note> */
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
	gen empstat_2 = .
	label var empstat_2 "Employment status during past week primary job 7 day recall"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
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
	gen industrycat10_2 = .
	label var industrycat10_2 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_2 lblindustrycat10_2
*</_industrycat10_2_>


*<_industrycat4_2_>
	gen byte industrycat4_2 = .
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
	gen double wage_no_compen_2 = .
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2 = .
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_2 lblunitwage_2
*</_unitwage_2_>


*<_whours_2_>
	gen whours_2 = .
	replace whours_2 = . if whours_2 == 0
	replace whours_2=. if lstatus != 1 | (age < minlaborage & age != .)
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


*----------8.6: 12 month reference overall------------------------------*

{

*<_lstatus_year_>
/* <_lstatus_year_note>

	For a person to be employed use the concept of usual economic activity, that is principal
	activity and add secondary if the principal is not in employment byt secondary is.
	So a full time student working on the side is still in the labor force in this 12 month sense

	Thus labour info for the 12 month recall is what is coded in Usual Principal Activity plus
	adding Subsidiary Activity if the person is not employed in Principal but is in secondary

*</_lstatus_year_note> */
	destring B6_q2, gen(primary_help)
	recode primary_help  11/51=1 81 82=2 91/99=3
	destring B6_q8, gen(secondary_help)
	recode secondary_help  11/51=1
	* tab primary_help secondary_help,m
	* Cross tabulation let's us see which cases are the adders and true seconds
	gen adders = 1 if inrange(primary_help,2,3) & secondary_help == 1
	gen seconds = 1 if primary_help == 1 & secondary_help == 1

	gen lstatus_year = primary_help
	replace lstatus_year = 1 if adders == 1

	replace lstatus_year = . if age < minlaborage
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
	drop secondary_help
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
	label var underemployment_year "Underemployment status"
	la de lblunderemployment_year 0 "No" 1 "Yes"
	label values underemployment_year lblunderemployment_year
*</_underemployment_year_>


*<_nlfreason_year_>
	destring B6_q2, gen(nlfreason_year)
	recode nlfreason_year 11/82=. 91=1 92 93=2 94=3 95=4 96/99=5
	replace nlfreason_year = . if lstatus_year != 3 | (age < minlaborage & age != .)
	label var nlfreason_year "Reason not in the labor force - 12 month recall"
	la de lblnlfreason_year 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason_year lblnlfreason_year
*</_nlfreason_year_>


*<_unempldur_l_year_>
	gen unemp_months = round(B7_q6/4.33) // info is in weeks, turn to months
	replace unemp_months = 1 if unemp_months == 0 // under a month is a month
	gen byte unempldur_l_year= unemp_months
	replace unempldur_l_year = . if lstatus_year != 2
	label var unempldur_l_year "Unemployment duration (months) lower bracket"
*</_unempldur_l_year_>


*<_unempldur_u_year_>
	gen byte unempldur_u_year= unemp_months
	replace unempldur_u_year = . if lstatus_year != 2
	label var unempldur_u_year "Unemployment duration (months) upper bracket"
*</_unempldur_u_year_>
}



*----------8.7: 12 month reference main job------------------------------*

{

*<_empstat_year_>
	destring B6_q2, gen(empstat_y1)
	recode empstat_y1 (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72=1) (81/99=.)
	destring B6_q8, gen(empstat_y2)
	recode empstat_y2 11=4 21=2 31 41 51 = 1

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
	gen industry_orig_year = B6_q5
	replace industry_orig_year = B6_q11 if adders == 1
	replace industry_orig_year = "" if lstatus_year != 1
	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>

	/* <_industrycat_isic_year_note>

	Have found no NIC70 to ISIC-68 (ISIC Rev2). NIC 70 and NIC 87 basically tha same, small amendments needed.
	Process is:
		1) Translate NIC70 to NIC87
		2) Use NIC87 to ISIC Rev2 translator
	</_industrycat_isic_year_note> */

	gen nic_87 = industry_orig_year
	replace nic_87 = substr(nic_87,1,2)
	replace nic_87 = nic_87 + "0" if length(nic_87) == 1
	replace nic_87 = "" if lstatus_year != 1
	gen nic_70 = nic_87

	replace nic_87 = "12" if industry_orig_year == "120"
	replace nic_87 = "13" if inlist(industry_orig_year, "121", "122", "123", "124", "125", "126", "127", "128", "129")
	replace nic_87 = "15" if nic_70 == "19"
	replace nic_87 = "30" if nic_70 == "31"
	replace nic_87 = "31" if nic_70 == "30"
	replace nic_87 = "61" if nic_70 == "62"
	replace nic_87 = "62" if nic_70 == "63"
	replace nic_87 = "63" if nic_70 == "64"
	replace nic_87 = "64" if industry_orig_year == "821"
	replace nic_87 = "82" if industry_orig_year == "820"
	replace nic_87 = "85" if industry_orig_year == "827"
	replace nic_87 = "89" if inlist(industry_orig_year, "822", "823", "824", "825", "826", "828", "829")

	replace nic_87 = nic_87 + "0"
	replace nic_87 = "" if regexm(nic_87, "x|X")

	merge m:1 nic_87 using "`path_in_stata'/nic87_to_isic2.dta", nogen keep(match master)

	gen industrycat_isic_year = isic_68
	replace industrycat_isic_year = "" if lstatus_year != 1
	replace industrycat_isic_year = "0000" if regexm(industry_orig_year, "x|X")

	* Take care of construction: NIC 51 codes are allied to construction, ISIC 2
	* only has 5000 for construction
	replace industrycat_isic_year = "5000" if regexm(industry_orig_year, "^51")


	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
	drop nic_87 nic_70 isic_68
*</_industrycat_isic_year_>


*<_industrycat10_year_>
	destring industrycat_isic_year, gen(helper_isic)
	replace helper_isic = floor(helper_isic/100)

	gen industrycat10_year = .

	replace industrycat10_year = 1 if inrange(helper_isic,11,13)
	replace industrycat10_year = 2 if inrange(helper_isic,21,29)
	replace industrycat10_year = 3 if inrange(helper_isic,31,39)
	replace industrycat10_year = 4 if inrange(helper_isic,41,42)
	replace industrycat10_year = 5 if inrange(helper_isic,50,51)
	replace industrycat10_year = 6 if inrange(helper_isic,61,63)
	replace industrycat10_year = 7 if inrange(helper_isic,71,72)
	replace industrycat10_year = 8 if inrange(helper_isic,81,83)
	replace industrycat10_year = 9 if inrange(helper_isic,91,91)
	replace industrycat10_year = 10 if inrange(helper_isic,92,96) | helper_isic == 0

	replace industrycat10_year=. if lstatus_year != 1 | (age < minlaborage & age != .)

	* Set NIC X codes (not correctly defined) to industrycat10 code 10
	replace industrycat10_year = 10 if regexm(industry_orig_year, "x|X|y|Y")

	label var industrycat10_year "1 digit industry classification, primary job 12 month recall"
	la de lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_year lblindustrycat10_year
	drop helper_isic
*</_industrycat10_year_>


*<_industrycat4_year_>
	gen byte industrycat4_year=industrycat10_year
	recode industrycat4_year (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_year "1 digit industry classification (Broad Economic Activities), primary job 12 month recall"
	la de lblindustrycat4_year 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4_year lblindustrycat4_year
*</_industrycat4_year_>


*<_occup_orig_year_>
	gen occup_orig_year = B6_q6
	replace occup_orig_year = B6_q12 if adders == 1
	replace occup_orig_year = "" if lstatus_year != 1
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>

*<_occup_isco_year_>
	gen nco_68 = occup_orig_year
	gen x_indic = regexm(nco_68, "x|X|y|y")
	replace nco_68 = "099" if x_indic == 1
	replace nco_68 = "0" + nco_68 if length(nco_68) == 2
	replace nco_68 = "00" + nco_68 if length(nco_68) == 1

	merge m:1 nco_68 using "`path_in_stata'/India_occup_correspondences.dta", nogen keep(match master)

	gen occup_isco_year = isco_88
	replace occup_isco_year = "" if lstatus_year != 1
	drop x_indic nco_68 nco_04 isco_88
	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_year_>
	gen nco_68 = occup_orig_year
	gen x_indic = regexm(nco_68, "x|X|y|y")
	replace nco_68 = "099" if x_indic == 1
	replace nco_68 = "0" + nco_68 if length(nco_68) == 2
	replace nco_68 = "00" + nco_68 if length(nco_68) == 1

	merge m:1 nco_68 using "`path_in_stata'/India_occup_correspondences.dta", nogen keep(match master)
	gen code_04 = substr(nco_04,1,1)
	destring code_04, replace

	gen occup_year = .
	replace occup_year = code_04 if lstatus_year == 1 & (age >= minlaborage & age != .)
	replace occup_year = 99 if x_indic == 1 & lstatus_year == 1 & (age >= minlaborage & age != .)
	label var occup_year "1 digit occupational classification, primary job 12 month recall"
	la de lbloccup_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_year lbloccup_year
	drop x_indic nco_68 code_04 nco_04 isco_88
*</_occup_year_>

*<_occup_skill_year_>
	gen occup_skill_year = .
	replace occup_skill_year = 3 if inrange(occup_year, 1, 3)
	replace occup_skill_year = 2 if inrange(occup_year, 4, 8)
	replace occup_skill_year = 1 if occup_year == 9
	la de lblskill_y 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_year lblskill_y
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
	Hence assume if worked regularly 12 months of work, if not 12 minus the number of weekes mentioned
	(by 4.33 to make months) mentioned.
</_wmonths_year_note> */
	gen wmonths_year = .
	replace wmonths_year = 12 if B7_q4 == "1"
	replace wmonths_year = round(12 - (B7_q6/4.33)) if B7_q4 == "2"
	replace wmonths_year = . if lstatus_year != 1
	replace wmonths_year = . if wmonths_year < 1
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
/* <_union_year_note>

	Survey asks whether there is a union available, if not no further questions - if yes,
	then whether they are member. Treat no union available also as a no.
</_union_year_note> */
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
	destring B6_q8, gen(empstat_2_year)
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
	gen industry_orig_2_year = B6_q11 if seconds == 1
	replace industry_orig_2_year = "" if missing(empstat_2_year)
	replace industry_orig_2_year = "" if lstatus_year != 1
	label var industry_orig_2_year "Original survey industry code, secondary job 12 month recall"
*</_industry_orig_2_year_>


*<_industrycat_isic_2_year_>
	gen nic_87 = industry_orig_2_year
	replace nic_87 = substr(nic_87,1,2)
	replace nic_87 = nic_87 + "0" if length(nic_87) == 1
	replace nic_87 = "" if lstatus_year != 1
	gen nic_70 = nic_87

	replace nic_87 = "12" if industry_orig_2_year == "120"
	replace nic_87 = "13" if inlist(industry_orig_2_year, "121", "122", "123", "124", "125", "126", "127", "128", "129")
	replace nic_87 = "15" if nic_70 == "19"
	replace nic_87 = "30" if nic_70 == "31"
	replace nic_87 = "31" if nic_70 == "30"
	replace nic_87 = "61" if nic_70 == "62"
	replace nic_87 = "62" if nic_70 == "63"
	replace nic_87 = "63" if nic_70 == "64"
	replace nic_87 = "64" if industry_orig_2_year == "821"
	replace nic_87 = "82" if industry_orig_2_year == "820"
	replace nic_87 = "85" if industry_orig_2_year == "827"
	replace nic_87 = "89" if inlist(industry_orig_2_year, "822", "823", "824", "825", "826", "828", "829")

	replace nic_87 = nic_87 + "0"
	replace nic_87 = "" if regexm(nic_87, "x|X")

	merge m:1 nic_87 using "`path_in_stata'/nic87_to_isic2.dta", nogen keep(match master)

	gen industrycat_isic_2_year = isic_68
	replace industrycat_isic_2_year = "" if lstatus_year != 1
	replace industrycat_isic_2_year = "0000" if regexm(industry_orig_2_year, "x|X")

	label var industrycat_isic_2_year "ISIC code of secondary job 12 month recall"
	drop nic_87 nic_70 isic_68
*</_industrycat_isic_2_year_>


*<_industrycat10_2_year_>
	destring industrycat_isic_2_year, gen(helper_isic)
	replace helper_isic = floor(helper_isic/100)

	gen industrycat10_2_year = .

	replace industrycat10_2_year = 1 if inrange(helper_isic,11,13)
	replace industrycat10_2_year = 2 if inrange(helper_isic,21,29)
	replace industrycat10_2_year = 3 if inrange(helper_isic,31,39)
	replace industrycat10_2_year = 4 if inrange(helper_isic,41,42)
	replace industrycat10_2_year = 5 if inrange(helper_isic,50,51)
	replace industrycat10_2_year = 6 if inrange(helper_isic,61,63)
	replace industrycat10_2_year = 7 if inrange(helper_isic,71,72)
	replace industrycat10_2_year = 8 if inrange(helper_isic,81,83)
	replace industrycat10_2_year = 9 if inrange(helper_isic,91,91)
	replace industrycat10_2_year = 10 if inrange(helper_isic,92,96) | helper_isic == 0

	* Set NIC X codes (not correctly defined) to industrycat10 code 10
	replace industrycat10_2_year = 10 if regexm(industry_orig_2_year, "x|X|y|Y")

	replace industrycat10_2_year= . if lstatus_year != 1 | (age < minlaborage & age != .)
	replace industrycat10_2_year= . if missing(empstat_2_year)
	label var industrycat10_2_year "1 digit industry classification, secondary job 12 month recall"
	la de lblindustrycat10_2_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_2_year lblindustrycat10_2_year
	drop helper_isic
*</_industrycat10_2_year_>


*<_industrycat4_2_year_>
	gen byte industrycat4_2_year=industrycat10_2_year
	recode industrycat4_2_year (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_2_year "1 digit industry classification (Broad Economic Activities), secondary job 12 month recall"
	label values industrycat4_2_year lblindustrycat4_year
*</_industrycat4_2_year_>


*<_occup_orig_2_year_>
	gen occup_orig_2_year = B6_q12 if seconds == 1
	replace occup_orig_2_year = "" if missing(empstat_2_year)
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
	gen nco_68 = occup_orig_2_year
	gen x_indic = regexm(nco_68, "x|X|y|y")
	replace nco_68 = "099" if x_indic == 1
	replace nco_68 = "0" + nco_68 if length(nco_68) == 2
	replace nco_68 = "00" + nco_68 if length(nco_68) == 1

	merge m:1 nco_68 using "`path_in_stata'/India_occup_correspondences.dta", nogen keep(match master)

	gen occup_isco_2_year = isco_88
	gen has_job_primary = inlist(B7_q2,"11", "21", "31", "41", "51")
	replace occup_isco_2_year = "" if has_job_primary == 0 & !missing(occup_isco_2_year)
	drop x_indic nco_68 nco_04 isco_88 has_job_primary
	label var occup_isco_2_year "ISCO code of secondary job 12 month recall"
*</_occup_isco_2_year_>


*<_occup_2_year_>
	gen nco_68 = occup_orig_2_year
	gen x_indic = regexm(nco_68, "x|X|y|y")
	replace nco_68 = "099" if x_indic == 1
	replace nco_68 = "0" + nco_68 if length(nco_68) == 2
	replace nco_68 = "00" + nco_68 if length(nco_68) == 1

	merge m:1 nco_68 using "`path_in_stata'/India_occup_correspondences.dta", nogen keep(match master)
	gen code_04 = substr(nco_04,1,1)
	destring code_04, replace

	gen occup_2_year = .
	replace occup_2_year = code_04 if lstatus_year == 1 & (age >= minlaborage & age != .)
	replace occup_2_year = 99 if x_indic == 1 & lstatus_year == 1 & (age >= minlaborage & age != .)
	gen has_job_primary = inlist(B7_q2,"11", "21", "31", "41", "51")
	replace occup_2_year = . if has_job_primary == 0 & !missing(occup_2_year)
	label var occup_2_year "1 digit occupational classification, primary job 12 month recall"
	la de lbloccup_2_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2_year lbloccup_2_year
	drop x_indic nco_68 code_04 nco_04 isco_88
*</_occup_2_year_>


*<_occup_skill_2_year_>
	gen occup_skill_2_year = .
	replace occup_skill_2_year = 3 if inrange(occup_2_year, 1, 3)
	replace occup_skill_2_year = 2 if inrange(occup_2_year, 4, 8)
	replace occup_skill_2_year = 1 if occup_2_year == 9
	la de lblskill__2y 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_2_year lblskill__2y
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
local lab_var "minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others  t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome"

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

{

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
   if _rc == 0 {
	drop `var'
	dis as error "Drop variable: `var' since all missing"
   }
}

*</_% DELETE MISSING VARIABLES_>


*<_% SAVE_>

save "`path_output'/`out_file'", replace

*</_% SAVE_>
