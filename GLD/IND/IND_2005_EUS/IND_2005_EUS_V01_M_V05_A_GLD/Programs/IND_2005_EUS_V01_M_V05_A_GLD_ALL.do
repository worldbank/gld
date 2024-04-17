
/*%%=============================================================================================
	0: GLD Harmonization Preamble
================================================================================================*/

/* -----------------------------------------------------------------------

<_Program name_> 			IND_2005_EUS_V01_M_V05_A_GLD_ALL.do </_Program name_>
<_Application_>					STATA 16 <_Application_>
<_Author(s)_>					  World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2021-06-13 </_Date created_>
<_Date modified>				2021-06-13 </_Date modified_>

-------------------------------------------------------------------------

<_Country_>						India </_Country_>
<_Survey Title_>				Employment and Unemployment Survey: NSS 62th Round : July 2005 - June 2006 </_Survey Title_>
<_Survey Year_>					2005 </_Survey Year_>
<_ICLS Version_>				Unknown (does not seem to follow ICLS-13 </_ICLS Version_>
<_Study ID_>					DDI-IND-NSSO-EUMS-2005-v1 </_Study ID_>
<_Data collection from (M/Y)_>	07/2005 </_Data collection from (M/Y)_>
<_Data collection to (M/Y)_>	06/2006 </_Data collection to (M/Y)_>
<_Source of dataset_> 			http://microdata.gov.in/nada43/index.php/catalog/113 </_Source of dataset_>
<_Sample size (HH)_> 			78,879 </_Sample size (HH)_>
<_Sample size (IND)_> 			377,377 </_Sample size (IND)_>
<_Sampling method_>

"The 62nd round (July 2005 - June 2006) of NSS was earmarked for survey on unorganised manufacturing enterprises,
annual survey of consumer expenditure and survey on employment � unemployment.
The sampling design adopted for the survey was essentially a stratified multi-stage one
for both rural and urban areas. Two frames were used for this survey viz. List frame and Area frame.
List frame was used only for urban sector and that too for selection of manufacturing
enterprises only and thus is not relevant for discussion. Area frame was adopted for
both rural and urban sectors for selection of First Stage Units (FSU) .
For the area frame, the list of villages as per census 2001 (for Manipur, 1991 census
was used since 2001 census list was not available) was used as frame for the rural sector
and the latest available list of UFS blocks was used as frame in the urban sector.
However, EC-98 was used as frame for the 27 towns with population 10 lakhs or more (as per Census 2001).
The ultimate stage units (USU) were households, in both the sectors. In the case of large
villages/ blocks requiring hamlet-group (hg)/ sub-block (sb) formation, one intermediate
stage was the selection of two hgs/ sbs from each FSU." (from MOSPI)


											</_Sampling method_>
<_Geographic coverage_> 		State Level </_Geographic coverage_>
<_Currency_> 					Indian Rupee </_Currency_>
-----------------------------------------------------------------------

<_ICLS Version_>			ICLS 13 </_ICLS Version_>
<_ISCED Version_>			ISCED 1997 </_ISCED Version_>
<_ISCO Version_>			ISCO 1988 </_ISCO Version_>
<_OCCUP National_>			NCO 1968 </_OCCUP National_>
<_ISIC Version_>			ISIC 3.1 </_ISIC Version_>
<_INDUS National_>			NIC 2004 </_INDUS National_>

-----------------------------------------------------------------------

<_Version Control_>

* Date: 2022-09-25 Changes to more accurately define what is a first jobs and a second job in 12 month recall.
	Done corretly for lstatus and empstat but other variables were not capturing this concept
	accurately. Were sometimes using the subsidiary info wholesale, especially not using contract or social security benefits (e.g., not using Social Security 2 for both first and second jobs.)
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

*----------1.2: Set directories------------------------------*

* Define path sections
local server  "Y:/GLD"
local country "IND"
local year    "2005"
local survey  "EUS"
local vermast "V01"
	local veralt "V05"

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

* Start with Block 5.3 as this has several lines per individual
use "`path_in_stata'/Block-6-Persons-daily-activity-time-disposition-reecords.dta", clear

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

destring B6_q4, gen(priority_tag)
gen num_status = priority_tag
* Classify the level of priority
recode priority_tag 11/72=1 81 82=2 91/98=3 99=.

* Decreasingorder of number of days worked
gen neg_days = -(B6_q14)


sort Person_key priority_tag neg_days num_status
bys Person_key: gen runner = _n

* Extract original serial number
gen original_serial = substr(Activity_slno_key, -1, 1)
destring original_serial, replace

* How many cases wherein this priority order is not followed
count if B6_q4 ! = B6_q18 & runner==1 //0
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
destring B6_q3, replace
keep B6_q4 B6_q5 B6_q14 B6_q15 - B6_q20 Hhold_key  B6_q1 runner

/*==============================================================================
Issue: Current weekly activity is constant across Person id, but there are cases
		wherein the industry and occupation for each activity vary! Ideally, there
		should be 1:1 correspondence between NIC/NCO and CWA

Resolve: Include the NIC/NCO in the reshaping to wide, then keep only the first instance
But first, make sure that the first instance for employed is nonmissing
==============================================================================*/

reshape wide B6_q4 B6_q5 B6_q14 - B6_q17 B6_q19 B6_q20, i(Hhold_key B6_q1) j(runner)

destring B6_q18, gen(cwa_e)

*==============================================================================
* Need to count how many non-zero responses for industry/occupation variables

count if B6_q191 == "" & inrange(cwa_e, 11, 72) //zero!
count if B6_q201 == "" & inrange(cwa_e, 11, 72)

* there are 913 employed people with no occupation code

count if missing(B6_q201) & (!missing(B6_q202) | !missing(B6_q203) | !missing(B6_q204)) & inrange(cwa_e, 11, 72)
* 2 cases wherein occupation code is recorded under the second instance
* Move this to first instance; ignore second instance

replace B6_q201 = B6_q202 if missing(B6_q201)& !missing(B6_q202) & inrange(cwa_e, 11, 72)

count if B6_q201 == "" & inrange(cwa_e, 11, 72)
* Still 911 employed people with no occupation code. Nothing we can do!
* 911/137,450 employed people = 0.6%

* Next step, drop second, third and fourth NIC/NCO variables
drop B6_q192 B6_q193 B6_q194 B6_q202 B6_q203 B6_q204
ren B6_q191 B6_q19
ren B6_q201 B6_q20

* Make sure that CWA = first activity
count if B6_q41 != B6_q18 //zero

* Make sure that CWA is available for all
count if missing(B6_q18)  //zero

* Make sure that second is not missing when third is not missing
count if missing(B6_q42) & !missing(B6_q43) //zero

**** Looks like data is in good shape!

tempfile weekly_act
save `weekly_act'

* Generate unique id variable at person level
egen Person_key = concat(Hhold_key B6_q1)

** Begin merging the other datasets

* Merge with block 4
merge m:1 Person_key using "`path_in_stata'/Block-4-Persons-demographic-particulars-records.dta" , keep(master match) nogen

* Start with Block 1
merge m:1 Hhold_key using "`path_in_stata'/Block-1-2-Household-ID-records.dta" , keep(master match) nogen

* Block 5
merge 1:1 Person_key using "`path_in_stata'/Block-5-Persons-usual-activity-records.dta" , keep(master match) nogen


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
	gen int year = 2005
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
	replace int_year = 2005 if inlist(SubRound,"1","2")
	replace int_year = 2006 if inlist(SubRound,"3","4")
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen  int_month = substr(B2_q2i, -4, 2)
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
	egen str9 hhid = concat(FSU Segment stage2stratum Hhhld_SlNo)
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
/* <_pid_note>

	Because there are so many variables for the same sample individual id, I drop
	them and keep only the data from block 5

</_pid_note> */
	egen  str11 pid = concat(hhid B6_q1)
	label var pid "Individual ID"
	isid pid
*</_pid_>


*<_weight_>
/* <_weight_note>

	From the Use of Multiplier for Sch-10 and Sch-10.1 document

</_weight_note> */
	gen weight = WGT_Comb

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
	gen wave = SubRound
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
	label de lblsubnatid1  28 "28 - Andhra Pradesh" 12 "12 - Arunachal Pradesh" 18 "18 - Assam" 10 "10 - Bihar" 30 "30 - Goa" 24 "24 - Gujarat" 6 "6 - Haryana" 2 "2 - Himachal Pradesh" 1 "1 - Jammu & Kashmir" 29 "29 - Karnataka" 32 "32 - Kerala" 23 "23 - Madhya Pradesh" 27 "27 - Maharastra" 14 "14 - Manipur" 17 "17 - Meghalaya" 15 "15 - Mizoram" 13 "13 - Nagaland" 21 "21 - Orissa" 3 "3 - Punjab" 8 "8 - Rajasthan" 11 "11 - Sikkim" 33 "33 - Tamil Nadu" 16 "16 - Tripura" 9 "9 - Uttar Pradesh" 19 "19 - West Bengal" 35 "35 - Andaman & Nicober" 4 "4 - Chandigarh" 26 "26 - Dadra & Nagar Haveli" 25 "25 - Daman & Diu" 7 "7 - Delhi" 31 "31 - Lakshadweep" 34 "34 - Pondicheri" 22 "22 - Chhattisgarh" 20 "20 - Jharkhand" 5 "5 - Uttaranchal"
	label values subnatid1 lblsubnatid1
	* Convert numeric into string
	decode subnatid1, gen(subnatid1_str)
	rename subnatid1 subnatid1_num
	rename subnatid1_str subnatid1
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	egen subnatid2 = concat(State District), punct(-)
	label var subnatid2 "Admin 2 - District"
	replace subnatid2 = "35-01 - Andamans" if subnatid2 == "35-01"
	replace subnatid2 = "35-02 - Nicobars" if subnatid2 == "35-02"
	replace subnatid2 = "28-11 - Srikakulam" if subnatid2 == "28-11"
	replace subnatid2 = "28-12 - Vizianagaram" if subnatid2 == "28-12"
	replace subnatid2 = "28-13 - Visakhapatnam" if subnatid2 == "28-13"
	replace subnatid2 = "28-14 - East Godavari" if subnatid2 == "28-14"
	replace subnatid2 = "28-15 - West Godavari" if subnatid2 == "28-15"
	replace subnatid2 = "28-16 - Krishna" if subnatid2 == "28-16"
	replace subnatid2 = "28-17 - Guntur" if subnatid2 == "28-17"
	replace subnatid2 = "28-18 - Prakasam" if subnatid2 == "28-18"
	replace subnatid2 = "28-19 - Nellore" if subnatid2 == "28-19"
	replace subnatid2 = "28-01 - Adilabad" if subnatid2 == "28-01"
	replace subnatid2 = "28-02 - Nizamabad" if subnatid2 == "28-02"
	replace subnatid2 = "28-04 - Medak" if subnatid2 == "28-04"
	replace subnatid2 = "28-05 - Hyderabad" if subnatid2 == "28-05"
	replace subnatid2 = "28-06 - Rangareddi" if subnatid2 == "28-06"
	replace subnatid2 = "28-07 - Mahbubnagar" if subnatid2 == "28-07"
	replace subnatid2 = "28-03 - Karimnagar" if subnatid2 == "28-03"
	replace subnatid2 = "28-08 - Nalgonda" if subnatid2 == "28-08"
	replace subnatid2 = "28-09 - Warangal" if subnatid2 == "28-09"
	replace subnatid2 = "28-10 - Khammam" if subnatid2 == "28-10"
	replace subnatid2 = "28-20 - Cuddapah" if subnatid2 == "28-20"
	replace subnatid2 = "28-21 - Kurnool" if subnatid2 == "28-21"
	replace subnatid2 = "28-22 - Anantapur" if subnatid2 == "28-22"
	replace subnatid2 = "28-23 - Chittoor" if subnatid2 == "28-23"
	replace subnatid2 = "12-01 - Tawang" if subnatid2 == "12-01"
	replace subnatid2 = "12-02 - West Kameng" if subnatid2 == "12-02"
	replace subnatid2 = "12-03 - East Kameng" if subnatid2 == "12-03"
	replace subnatid2 = "12-04 - Papum Pare" if subnatid2 == "12-04"
	replace subnatid2 = "12-05 - Lower Subansiri" if subnatid2 == "12-05"
	replace subnatid2 = "12-06 - Upper Subansiri" if subnatid2 == "12-06"
	replace subnatid2 = "12-07 - West Siang" if subnatid2 == "12-07"
	replace subnatid2 = "12-08 - East Siang" if subnatid2 == "12-08"
	replace subnatid2 = "12-09 - Upper Siang" if subnatid2 == "12-09"
	replace subnatid2 = "12-10 - Dibang Valley" if subnatid2 == "12-10"
	replace subnatid2 = "12-11 - Lohit" if subnatid2 == "12-11"
	replace subnatid2 = "12-12 - Changlang" if subnatid2 == "12-12"
	replace subnatid2 = "12-13 - Tirap" if subnatid2 == "12-13"
	replace subnatid2 = "18-12 - Lakhimpur" if subnatid2 == "18-12"
	replace subnatid2 = "18-13 - Dhemaji" if subnatid2 == "18-13"
	replace subnatid2 = "18-14 - Tinsukia" if subnatid2 == "18-14"
	replace subnatid2 = "18-15 - Dibrugarh" if subnatid2 == "18-15"
	replace subnatid2 = "18-16 - Sibsagar" if subnatid2 == "18-16"
	replace subnatid2 = "18-17 - Jorhat" if subnatid2 == "18-17"
	replace subnatid2 = "18-18 - Golaghat" if subnatid2 == "18-18"
	replace subnatid2 = "18-01 - Kokrajhar" if subnatid2 == "18-01"
	replace subnatid2 = "18-02 - Dhubri" if subnatid2 == "18-02"
	replace subnatid2 = "18-03 - Goalpara" if subnatid2 == "18-03"
	replace subnatid2 = "18-04 - Bongaigaon" if subnatid2 == "18-04"
	replace subnatid2 = "18-05 - Barpeta" if subnatid2 == "18-05"
	replace subnatid2 = "18-06 - Kamrup" if subnatid2 == "18-06"
	replace subnatid2 = "18-07 - Nalbari" if subnatid2 == "18-07"
	replace subnatid2 = "18-19 - Karbi Anglong" if subnatid2 == "18-19"
	replace subnatid2 = "18-20 - North Cachar Hills" if subnatid2 == "18-20"
	replace subnatid2 = "18-21 - Cachar" if subnatid2 == "18-21"
	replace subnatid2 = "18-22 - Karimganj" if subnatid2 == "18-22"
	replace subnatid2 = "18-23 - HaiLakandi" if subnatid2 == "18-23"
	replace subnatid2 = "18-08 - Darrang" if subnatid2 == "18-08"
	replace subnatid2 = "18-09 - Marigaon" if subnatid2 == "18-09"
	replace subnatid2 = "18-10 - Nagaon" if subnatid2 == "18-10"
	replace subnatid2 = "18-11 - Sonitpur" if subnatid2 == "18-11"
	replace subnatid2 = "10-01 - Champaran   (W)" if subnatid2 == "10-01"
	replace subnatid2 = "10-02 - Champaran    (E)" if subnatid2 == "10-02"
	replace subnatid2 = "10-03 - Sheohar" if subnatid2 == "10-03"
	replace subnatid2 = "10-04 - Sitamarhi" if subnatid2 == "10-04"
	replace subnatid2 = "10-05 - Madhubani" if subnatid2 == "10-05"
	replace subnatid2 = "10-06 - Supaul" if subnatid2 == "10-06"
	replace subnatid2 = "10-07 - Araria" if subnatid2 == "10-07"
	replace subnatid2 = "10-08 - Kishanganj" if subnatid2 == "10-08"
	replace subnatid2 = "10-09 - Purnia" if subnatid2 == "10-09"
	replace subnatid2 = "10-10 - Katihar" if subnatid2 == "10-10"
	replace subnatid2 = "10-11 - Madhepura" if subnatid2 == "10-11"
	replace subnatid2 = "10-12 - Saharsa" if subnatid2 == "10-12"
	replace subnatid2 = "10-13 - Darbhanga" if subnatid2 == "10-13"
	replace subnatid2 = "10-14 - Muzaffarpur" if subnatid2 == "10-14"
	replace subnatid2 = "10-15 - Gopalganj" if subnatid2 == "10-15"
	replace subnatid2 = "10-16 - Siwan" if subnatid2 == "10-16"
	replace subnatid2 = "10-17 - Saran" if subnatid2 == "10-17"
	replace subnatid2 = "10-18 - Vaishali" if subnatid2 == "10-18"
	replace subnatid2 = "10-19 - Samastipur" if subnatid2 == "10-19"
	replace subnatid2 = "10-20 - Begusarai" if subnatid2 == "10-20"
	replace subnatid2 = "10-21 - Khagaria" if subnatid2 == "10-21"
	replace subnatid2 = "10-22 - Bhagalpur" if subnatid2 == "10-22"
	replace subnatid2 = "10-23 - Banka" if subnatid2 == "10-23"
	replace subnatid2 = "10-24 - Munger" if subnatid2 == "10-24"
	replace subnatid2 = "10-25 - Lakhisarai" if subnatid2 == "10-25"
	replace subnatid2 = "10-26 - Sheikhpura" if subnatid2 == "10-26"
	replace subnatid2 = "10-27 - Nalanda" if subnatid2 == "10-27"
	replace subnatid2 = "10-28 - Patna" if subnatid2 == "10-28"
	replace subnatid2 = "10-29 - Bhojpur" if subnatid2 == "10-29"
	replace subnatid2 = "10-30 - Buxar" if subnatid2 == "10-30"
	replace subnatid2 = "10-31 - Kaimur    Bhabua" if subnatid2 == "10-31"
	replace subnatid2 = "10-32 - Rohtas" if subnatid2 == "10-32"
	replace subnatid2 = "10-33 - Jehanabad" if subnatid2 == "10-33"
	replace subnatid2 = "10-34 - Aurangabad" if subnatid2 == "10-34"
	replace subnatid2 = "10-35 - Gaya" if subnatid2 == "10-35"
	replace subnatid2 = "10-36 - Nawada" if subnatid2 == "10-36"
	replace subnatid2 = "10-37 - Jamui" if subnatid2 == "10-37"
	replace subnatid2 = "04-01 - Chandigarh" if subnatid2 == "04-01"
	replace subnatid2 = "22-01 - Koriya" if subnatid2 == "22-01"
	replace subnatid2 = "22-02 - Surguja" if subnatid2 == "22-02"
	replace subnatid2 = "22-03 - Jashpur" if subnatid2 == "22-03"
	replace subnatid2 = "22-04 - Raigarh" if subnatid2 == "22-04"
	replace subnatid2 = "22-05 - Korba" if subnatid2 == "22-05"
	replace subnatid2 = "22-06 - Janjgir-Champa" if subnatid2 == "22-06"
	replace subnatid2 = "22-07 - Bilaspur" if subnatid2 == "22-07"
	replace subnatid2 = "22-08 - Kawardha" if subnatid2 == "22-08"
	replace subnatid2 = "22-09 - Rajnandgaon" if subnatid2 == "22-09"
	replace subnatid2 = "22-10 - Durg" if subnatid2 == "22-10"
	replace subnatid2 = "22-11 - Raipur" if subnatid2 == "22-11"
	replace subnatid2 = "22-12 - Mahasamund" if subnatid2 == "22-12"
	replace subnatid2 = "22-13 - Dhamtari" if subnatid2 == "22-13"
	replace subnatid2 = "22-14 - Kanker" if subnatid2 == "22-14"
	replace subnatid2 = "22-15 - Bastar" if subnatid2 == "22-15"
	replace subnatid2 = "22-16 - Dantewada" if subnatid2 == "22-16"
	replace subnatid2 = "26-01 - Dadra and Nagar Havelira" if subnatid2 == "26-01"
	replace subnatid2 = "25-01 - Diu" if subnatid2 == "25-01"
	replace subnatid2 = "25-02 - Daman" if subnatid2 == "25-02"
	replace subnatid2 = "07-01 - North West" if subnatid2 == "07-01"
	replace subnatid2 = "07-02 - North" if subnatid2 == "07-02"
	replace subnatid2 = "07-03 - North East" if subnatid2 == "07-03"
	replace subnatid2 = "07-04 - East" if subnatid2 == "07-04"
	replace subnatid2 = "07-05 - New Delhi" if subnatid2 == "07-05"
	replace subnatid2 = "07-06 - Central" if subnatid2 == "07-06"
	replace subnatid2 = "07-07 - West" if subnatid2 == "07-07"
	replace subnatid2 = "07-08 - South West" if subnatid2 == "07-08"
	replace subnatid2 = "07-09 - South" if subnatid2 == "07-09"
	replace subnatid2 = "30-01 - North Goa" if subnatid2 == "30-01"
	replace subnatid2 = "30-02 - South Goa" if subnatid2 == "30-02"
	replace subnatid2 = "24-17 - Panch Mahals" if subnatid2 == "24-17"
	replace subnatid2 = "24-18 - Dohad" if subnatid2 == "24-18"
	replace subnatid2 = "24-19 - Vadodara" if subnatid2 == "24-19"
	replace subnatid2 = "24-20 - Narmada" if subnatid2 == "24-20"
	replace subnatid2 = "24-21 - Bharuch" if subnatid2 == "24-21"
	replace subnatid2 = "24-22 - Surat" if subnatid2 == "24-22"
	replace subnatid2 = "24-23 - The Dangs" if subnatid2 == "24-23"
	replace subnatid2 = "24-24 - Navsari" if subnatid2 == "24-24"
	replace subnatid2 = "24-25 - Valsad" if subnatid2 == "24-25"
	replace subnatid2 = "24-04 - Mahesana" if subnatid2 == "24-04"
	replace subnatid2 = "24-05 - Sabar Kantha" if subnatid2 == "24-05"
	replace subnatid2 = "24-06 - Gandhinagar" if subnatid2 == "24-06"
	replace subnatid2 = "24-07 - Ahmedabad" if subnatid2 == "24-07"
	replace subnatid2 = "24-15 - Anand" if subnatid2 == "24-15"
	replace subnatid2 = "24-16 - Kheda" if subnatid2 == "24-16"
	replace subnatid2 = "24-02 - Bans Kantha" if subnatid2 == "24-02"
	replace subnatid2 = "24-03 - Patan" if subnatid2 == "24-03"
	replace subnatid2 = "24-01 - Kachchh" if subnatid2 == "24-01"
	replace subnatid2 = "24-08 - Surendranagar" if subnatid2 == "24-08"
	replace subnatid2 = "24-09 - Rajkot" if subnatid2 == "24-09"
	replace subnatid2 = "24-10 - Jamnagar" if subnatid2 == "24-10"
	replace subnatid2 = "24-11 - Porbandar" if subnatid2 == "24-11"
	replace subnatid2 = "24-12 - Junagadh" if subnatid2 == "24-12"
	replace subnatid2 = "24-13 - Amreli" if subnatid2 == "24-13"
	replace subnatid2 = "24-14 - Bhavnagar" if subnatid2 == "24-14"
	replace subnatid2 = "06-01 - Panchkula" if subnatid2 == "06-01"
	replace subnatid2 = "06-02 - Ambala" if subnatid2 == "06-02"
	replace subnatid2 = "06-03 - Yamunanagar" if subnatid2 == "06-03"
	replace subnatid2 = "06-04 - Kurukshetra" if subnatid2 == "06-04"
	replace subnatid2 = "06-05 - Kaithal" if subnatid2 == "06-05"
	replace subnatid2 = "06-06 - Karnal" if subnatid2 == "06-06"
	replace subnatid2 = "06-07 - Panipat" if subnatid2 == "06-07"
	replace subnatid2 = "06-08 - Sonipat" if subnatid2 == "06-08"
	replace subnatid2 = "06-14 - Rohtak" if subnatid2 == "06-14"
	replace subnatid2 = "06-15 - Jhajjar" if subnatid2 == "06-15"
	replace subnatid2 = "06-18 - Gurgaon" if subnatid2 == "06-18"
	replace subnatid2 = "06-19 - Faridabad" if subnatid2 == "06-19"
	replace subnatid2 = "06-09 - Jind" if subnatid2 == "06-09"
	replace subnatid2 = "06-10 - Fatehabad" if subnatid2 == "06-10"
	replace subnatid2 = "06-11 - Sirsa" if subnatid2 == "06-11"
	replace subnatid2 = "06-12 - Hisar" if subnatid2 == "06-12"
	replace subnatid2 = "06-13 - Bhiwani" if subnatid2 == "06-13"
	replace subnatid2 = "06-16 - Mahendragarh" if subnatid2 == "06-16"
	replace subnatid2 = "06-17 - Rewari" if subnatid2 == "06-17"
	replace subnatid2 = "02-02 - Kangra" if subnatid2 == "02-02"
	replace subnatid2 = "02-04 - Kullu" if subnatid2 == "02-04"
	replace subnatid2 = "02-05 - Mandi" if subnatid2 == "02-05"
	replace subnatid2 = "02-06 - Hamirpur" if subnatid2 == "02-06"
	replace subnatid2 = "02-07 - Una" if subnatid2 == "02-07"
	replace subnatid2 = "02-01 - Chamba" if subnatid2 == "02-01"
	replace subnatid2 = "02-03 - Lahul & Spiti" if subnatid2 == "02-03"
	replace subnatid2 = "02-08 - Bilaspur" if subnatid2 == "02-08"
	replace subnatid2 = "02-09 - Solan" if subnatid2 == "02-09"
	replace subnatid2 = "02-10 - Sirmaur" if subnatid2 == "02-10"
	replace subnatid2 = "02-11 - Shimla" if subnatid2 == "02-11"
	replace subnatid2 = "02-12 - Kinnaur" if subnatid2 == "02-12"
	replace subnatid2 = "01-13 - Jammu" if subnatid2 == "01-13"
	replace subnatid2 = "01-14 - Kathua" if subnatid2 == "01-14"
	replace subnatid2 = "01-09 - Doda" if subnatid2 == "01-09"
	replace subnatid2 = "01-10 - Udhampur" if subnatid2 == "01-10"
	replace subnatid2 = "01-11 - Punch" if subnatid2 == "01-11"
	replace subnatid2 = "01-12 - Rajauri" if subnatid2 == "01-12"
	replace subnatid2 = "01-01 - Kupwara" if subnatid2 == "01-01"
	replace subnatid2 = "01-02 - Baramula" if subnatid2 == "01-02"
	replace subnatid2 = "01-03 - Srinagar" if subnatid2 == "01-03"
	replace subnatid2 = "01-04 - Badgam" if subnatid2 == "01-04"
	replace subnatid2 = "01-05 - Pulwama" if subnatid2 == "01-05"
	replace subnatid2 = "01-06 - Anantnag" if subnatid2 == "01-06"
	replace subnatid2 = "01-07 - Leh*     Ladakh" if subnatid2 == "01-07"
	replace subnatid2 = "01-08 - Kargil*" if subnatid2 == "01-08"
	replace subnatid2 = "20-01 - Garhwa" if subnatid2 == "20-01"
	replace subnatid2 = "20-02 - Palamu" if subnatid2 == "20-02"
	replace subnatid2 = "20-14 - Ranchi" if subnatid2 == "20-14"
	replace subnatid2 = "20-15 - Lohardaga" if subnatid2 == "20-15"
	replace subnatid2 = "20-16 - Gumla" if subnatid2 == "20-16"
	replace subnatid2 = "20-17 - Singhbhum  (W)" if subnatid2 == "20-17"
	replace subnatid2 = "20-18 - Singhbhum    (E)" if subnatid2 == "20-18"
	replace subnatid2 = "20-03 - Chatra" if subnatid2 == "20-03"
	replace subnatid2 = "20-04 - Hazaribag" if subnatid2 == "20-04"
	replace subnatid2 = "20-05 - Kodarma" if subnatid2 == "20-05"
	replace subnatid2 = "20-06 - Giridih" if subnatid2 == "20-06"
	replace subnatid2 = "20-07 - Deoghar" if subnatid2 == "20-07"
	replace subnatid2 = "20-08 - Godda" if subnatid2 == "20-08"
	replace subnatid2 = "20-09 - Sahibganj" if subnatid2 == "20-09"
	replace subnatid2 = "20-10 - Pakaur" if subnatid2 == "20-10"
	replace subnatid2 = "20-11 - Dumka" if subnatid2 == "20-11"
	replace subnatid2 = "20-12 - Dhanbad" if subnatid2 == "20-12"
	replace subnatid2 = "20-13 - Bokaro" if subnatid2 == "20-13"
	replace subnatid2 = "29-10 - Uttara Kannada" if subnatid2 == "29-10"
	replace subnatid2 = "29-16 - Udupi" if subnatid2 == "29-16"
	replace subnatid2 = "29-24 - Dakshina Kannada" if subnatid2 == "29-24"
	replace subnatid2 = "29-15 - Shimoga" if subnatid2 == "29-15"
	replace subnatid2 = "29-17 - Chikmagalur" if subnatid2 == "29-17"
	replace subnatid2 = "29-23 - Hassan" if subnatid2 == "29-23"
	replace subnatid2 = "29-25 - Kodagu" if subnatid2 == "29-25"
	replace subnatid2 = "29-18 - Tumkur" if subnatid2 == "29-18"
	replace subnatid2 = "29-19 - Kolar" if subnatid2 == "29-19"
	replace subnatid2 = "29-20 - Bangalore" if subnatid2 == "29-20"
	replace subnatid2 = "29-21 - Bangalore ( Rural )" if subnatid2 == "29-21"
	replace subnatid2 = "29-22 - Mandya" if subnatid2 == "29-22"
	replace subnatid2 = "29-26 - Mysore" if subnatid2 == "29-26"
	replace subnatid2 = "29-27 - Chamarajanagar" if subnatid2 == "29-27"
	replace subnatid2 = "29-01 - Belgaum" if subnatid2 == "29-01"
	replace subnatid2 = "29-02 - Bagalkot" if subnatid2 == "29-02"
	replace subnatid2 = "29-03 - Bijapur" if subnatid2 == "29-03"
	replace subnatid2 = "29-04 - Gulbarga" if subnatid2 == "29-04"
	replace subnatid2 = "29-05 - Bidar" if subnatid2 == "29-05"
	replace subnatid2 = "29-06 - Raichur" if subnatid2 == "29-06"
	replace subnatid2 = "29-07 - Koppal" if subnatid2 == "29-07"
	replace subnatid2 = "29-08 - Gadag" if subnatid2 == "29-08"
	replace subnatid2 = "29-09 - Dharwad" if subnatid2 == "29-09"
	replace subnatid2 = "29-11 - Haveri" if subnatid2 == "29-11"
	replace subnatid2 = "29-12 - Bellary" if subnatid2 == "29-12"
	replace subnatid2 = "29-13 - Chitradurga" if subnatid2 == "29-13"
	replace subnatid2 = "29-14 - Davanagere" if subnatid2 == "29-14"
	replace subnatid2 = "32-01 - Kasaragod" if subnatid2 == "32-01"
	replace subnatid2 = "32-02 - Kannur" if subnatid2 == "32-02"
	replace subnatid2 = "32-03 - Wayanad" if subnatid2 == "32-03"
	replace subnatid2 = "32-04 - Kozhikode" if subnatid2 == "32-04"
	replace subnatid2 = "32-05 - Malappuram" if subnatid2 == "32-05"
	replace subnatid2 = "32-06 - Palakkad" if subnatid2 == "32-06"
	replace subnatid2 = "32-07 - Thrissur" if subnatid2 == "32-07"
	replace subnatid2 = "32-08 - Ernakulam" if subnatid2 == "32-08"
	replace subnatid2 = "32-09 - Idukki" if subnatid2 == "32-09"
	replace subnatid2 = "32-10 - Kottayam" if subnatid2 == "32-10"
	replace subnatid2 = "32-11 - Alappuzha" if subnatid2 == "32-11"
	replace subnatid2 = "32-12 - Pathanamthitta" if subnatid2 == "32-12"
	replace subnatid2 = "32-13 - Kollam" if subnatid2 == "32-13"
	replace subnatid2 = "32-14 - Thiruvananthapuram" if subnatid2 == "32-14"
	replace subnatid2 = "31-01 - Lakshadweepshadweep" if subnatid2 == "31-01"
	replace subnatid2 = "23-08 - Tikamgarh" if subnatid2 == "23-08"
	replace subnatid2 = "23-09 - Chhatarpur" if subnatid2 == "23-09"
	replace subnatid2 = "23-10 - Panna" if subnatid2 == "23-10"
	replace subnatid2 = "23-13 - Satna" if subnatid2 == "23-13"
	replace subnatid2 = "23-14 - Rewa" if subnatid2 == "23-14"
	replace subnatid2 = "23-15 - Umaria" if subnatid2 == "23-15"
	replace subnatid2 = "23-16 - Shahdol" if subnatid2 == "23-16"
	replace subnatid2 = "23-17 - Sidhi" if subnatid2 == "23-17"
	replace subnatid2 = "23-11 - Sagar" if subnatid2 == "23-11"
	replace subnatid2 = "23-12 - Damoh" if subnatid2 == "23-12"
	replace subnatid2 = "23-31 - Vidisha" if subnatid2 == "23-31"
	replace subnatid2 = "23-32 - Bhopal" if subnatid2 == "23-32"
	replace subnatid2 = "23-33 - Sehore" if subnatid2 == "23-33"
	replace subnatid2 = "23-34 - Raisen" if subnatid2 == "23-34"
	replace subnatid2 = "23-18 - Neemuch" if subnatid2 == "23-18"
	replace subnatid2 = "23-19 - Mandsaur" if subnatid2 == "23-19"
	replace subnatid2 = "23-20 - Ratlam" if subnatid2 == "23-20"
	replace subnatid2 = "23-21 - Ujjain" if subnatid2 == "23-21"
	replace subnatid2 = "23-22 - Shajapur" if subnatid2 == "23-22"
	replace subnatid2 = "23-23 - Dewas" if subnatid2 == "23-23"
	replace subnatid2 = "23-24 - Jhabua" if subnatid2 == "23-24"
	replace subnatid2 = "23-25 - Dhar" if subnatid2 == "23-25"
	replace subnatid2 = "23-26 - Indore" if subnatid2 == "23-26"
	replace subnatid2 = "23-30 - Rajgarh" if subnatid2 == "23-30"
	replace subnatid2 = "23-38 - Katni" if subnatid2 == "23-38"
	replace subnatid2 = "23-39 - Jabalpur" if subnatid2 == "23-39"
	replace subnatid2 = "23-40 - Narsimhapur" if subnatid2 == "23-40"
	replace subnatid2 = "23-41 - Dindori" if subnatid2 == "23-41"
	replace subnatid2 = "23-42 - Mandla" if subnatid2 == "23-42"
	replace subnatid2 = "23-43 - Chhindwara" if subnatid2 == "23-43"
	replace subnatid2 = "23-44 - Seoni" if subnatid2 == "23-44"
	replace subnatid2 = "23-45 - Balaghat" if subnatid2 == "23-45"
	replace subnatid2 = "23-27 - W. Nimar" if subnatid2 == "23-27"
	replace subnatid2 = "23-28 - Barwani" if subnatid2 == "23-28"
	replace subnatid2 = "23-29 - E. Nimar" if subnatid2 == "23-29"
	replace subnatid2 = "23-35 - Betul" if subnatid2 == "23-35"
	replace subnatid2 = "23-36 - Harda" if subnatid2 == "23-36"
	replace subnatid2 = "23-37 - Hoshangabad" if subnatid2 == "23-37"
	replace subnatid2 = "23-01 - Sheopur" if subnatid2 == "23-01"
	replace subnatid2 = "23-02 - Morena" if subnatid2 == "23-02"
	replace subnatid2 = "23-03 - Bhind" if subnatid2 == "23-03"
	replace subnatid2 = "23-04 - Gwalior" if subnatid2 == "23-04"
	replace subnatid2 = "23-05 - Datia" if subnatid2 == "23-05"
	replace subnatid2 = "23-06 - Shivpuri" if subnatid2 == "23-06"
	replace subnatid2 = "23-07 - Guna" if subnatid2 == "23-07"
	replace subnatid2 = "27-21 - Thane" if subnatid2 == "27-21"
	replace subnatid2 = "27-22 - Mumbai Suburban" if subnatid2 == "27-22"
	replace subnatid2 = "27-23 - Mumbai" if subnatid2 == "27-23"
	replace subnatid2 = "27-24 - Raigarh" if subnatid2 == "27-24"
	replace subnatid2 = "27-32 - Ratnagiri" if subnatid2 == "27-32"
	replace subnatid2 = "27-33 - Sindhudurg" if subnatid2 == "27-33"
	replace subnatid2 = "27-25 - Pune" if subnatid2 == "27-25"
	replace subnatid2 = "27-26 - Ahmadnagar" if subnatid2 == "27-26"
	replace subnatid2 = "27-30 - Solapur" if subnatid2 == "27-30"
	replace subnatid2 = "27-31 - Satara" if subnatid2 == "27-31"
	replace subnatid2 = "27-34 - Kolhapur" if subnatid2 == "27-34"
	replace subnatid2 = "27-35 - Sangli" if subnatid2 == "27-35"
	replace subnatid2 = "27-01 - Nandurbar" if subnatid2 == "27-01"
	replace subnatid2 = "27-02 - Dhule" if subnatid2 == "27-02"
	replace subnatid2 = "27-03 - Jalgaon" if subnatid2 == "27-03"
	replace subnatid2 = "27-20 - Nashik" if subnatid2 == "27-20"
	replace subnatid2 = "27-15 - Nanded" if subnatid2 == "27-15"
	replace subnatid2 = "27-16 - Hingoli" if subnatid2 == "27-16"
	replace subnatid2 = "27-17 - Parbhani" if subnatid2 == "27-17"
	replace subnatid2 = "27-18 - Jalna" if subnatid2 == "27-18"
	replace subnatid2 = "27-19 - Aurangabad" if subnatid2 == "27-19"
	replace subnatid2 = "27-27 - Bid" if subnatid2 == "27-27"
	replace subnatid2 = "27-28 - Latur" if subnatid2 == "27-28"
	replace subnatid2 = "27-29 - Osmanabad" if subnatid2 == "27-29"
	replace subnatid2 = "27-04 - Buldana" if subnatid2 == "27-04"
	replace subnatid2 = "27-05 - Akola" if subnatid2 == "27-05"
	replace subnatid2 = "27-06 - Washim" if subnatid2 == "27-06"
	replace subnatid2 = "27-08 - Wardha" if subnatid2 == "27-08"
	replace subnatid2 = "27-09 - Nagpur" if subnatid2 == "27-09"
	replace subnatid2 = "27-14 - Yavatmal" if subnatid2 == "27-14"
	replace subnatid2 = "27-07 - Amravati" if subnatid2 == "27-07"
	replace subnatid2 = "27-10 - Bhandara" if subnatid2 == "27-10"
	replace subnatid2 = "27-11 - Gondiya" if subnatid2 == "27-11"
	replace subnatid2 = "27-12 - Gadchiroli" if subnatid2 == "27-12"
	replace subnatid2 = "27-13 - Chandrapur" if subnatid2 == "27-13"
	replace subnatid2 = "14-04 - Bishnupur" if subnatid2 == "14-04"
	replace subnatid2 = "14-05 - Thoubal" if subnatid2 == "14-05"
	replace subnatid2 = "14-06 - Imphal West" if subnatid2 == "14-06"
	replace subnatid2 = "14-07 - Imphal East" if subnatid2 == "14-07"
	replace subnatid2 = "14-01 - Senapati" if subnatid2 == "14-01"
	replace subnatid2 = "14-02 - Tamenglong" if subnatid2 == "14-02"
	replace subnatid2 = "14-03 - Churachandpur" if subnatid2 == "14-03"
	replace subnatid2 = "14-08 - Ukhrul" if subnatid2 == "14-08"
	replace subnatid2 = "14-09 - Chandel" if subnatid2 == "14-09"
	replace subnatid2 = "17-01 - West Garo Hills" if subnatid2 == "17-01"
	replace subnatid2 = "17-02 - East Garo Hills" if subnatid2 == "17-02"
	replace subnatid2 = "17-03 - South Garo Hills" if subnatid2 == "17-03"
	replace subnatid2 = "17-04 - West Khasi Hills" if subnatid2 == "17-04"
	replace subnatid2 = "17-05 - Ri Bhoi" if subnatid2 == "17-05"
	replace subnatid2 = "17-06 - East Khasi Hills" if subnatid2 == "17-06"
	replace subnatid2 = "17-07 - Jaintia Hills" if subnatid2 == "17-07"
	replace subnatid2 = "15-01 - Mamit" if subnatid2 == "15-01"
	replace subnatid2 = "15-02 - Kolasib" if subnatid2 == "15-02"
	replace subnatid2 = "15-03 - Aizwal" if subnatid2 == "15-03"
	replace subnatid2 = "15-04 - Champhai" if subnatid2 == "15-04"
	replace subnatid2 = "15-05 - Serchip" if subnatid2 == "15-05"
	replace subnatid2 = "15-06 - Lunglei" if subnatid2 == "15-06"
	replace subnatid2 = "15-07 - Lawngtlai" if subnatid2 == "15-07"
	replace subnatid2 = "15-08 - Saiha" if subnatid2 == "15-08"
	replace subnatid2 = "13-01 - Mon" if subnatid2 == "13-01"
	replace subnatid2 = "13-02 - Tuensang" if subnatid2 == "13-02"
	replace subnatid2 = "13-03 - Mokokchung" if subnatid2 == "13-03"
	replace subnatid2 = "13-04 - Zunheboto" if subnatid2 == "13-04"
	replace subnatid2 = "13-05 - Wokha" if subnatid2 == "13-05"
	replace subnatid2 = "13-06 - Dimapur" if subnatid2 == "13-06"
	replace subnatid2 = "13-07 - Kohima" if subnatid2 == "13-07"
	replace subnatid2 = "13-08 - Phek" if subnatid2 == "13-08"
	replace subnatid2 = "21-08 - Baleshwar" if subnatid2 == "21-08"
	replace subnatid2 = "21-09 - Bhadrak" if subnatid2 == "21-09"
	replace subnatid2 = "21-10 - Kendrapara" if subnatid2 == "21-10"
	replace subnatid2 = "21-11 - Jagatsinghapur" if subnatid2 == "21-11"
	replace subnatid2 = "21-12 - Cuttack" if subnatid2 == "21-12"
	replace subnatid2 = "21-13 - Jajapur" if subnatid2 == "21-13"
	replace subnatid2 = "21-16 - Nayagarh" if subnatid2 == "21-16"
	replace subnatid2 = "21-17 - Khordha" if subnatid2 == "21-17"
	replace subnatid2 = "21-18 - Puri" if subnatid2 == "21-18"
	replace subnatid2 = "21-19 - Ganjam" if subnatid2 == "21-19"
	replace subnatid2 = "21-20 - Gajapati" if subnatid2 == "21-20"
	replace subnatid2 = "21-21 - Kandhamal ( Phoolbani )" if subnatid2 == "21-21"
	replace subnatid2 = "21-22 - Baudh" if subnatid2 == "21-22"
	replace subnatid2 = "21-23 - Sonapur" if subnatid2 == "21-23"
	replace subnatid2 = "21-24 - Balangir" if subnatid2 == "21-24"
	replace subnatid2 = "21-25 - Nuapada" if subnatid2 == "21-25"
	replace subnatid2 = "21-26 - Kalahandi" if subnatid2 == "21-26"
	replace subnatid2 = "21-27 - Rayagada" if subnatid2 == "21-27"
	replace subnatid2 = "21-28 - Nabarangapur" if subnatid2 == "21-28"
	replace subnatid2 = "21-29 - Koraput" if subnatid2 == "21-29"
	replace subnatid2 = "21-30 - Malkangiri" if subnatid2 == "21-30"
	replace subnatid2 = "21-01 - Bargarh" if subnatid2 == "21-01"
	replace subnatid2 = "21-02 - Jharsuguda" if subnatid2 == "21-02"
	replace subnatid2 = "21-03 - Sambalpur" if subnatid2 == "21-03"
	replace subnatid2 = "21-04 - Debagarh" if subnatid2 == "21-04"
	replace subnatid2 = "21-05 - Sundargarh" if subnatid2 == "21-05"
	replace subnatid2 = "21-06 - Kendujhar" if subnatid2 == "21-06"
	replace subnatid2 = "21-07 - Mayurbhanj" if subnatid2 == "21-07"
	replace subnatid2 = "21-14 - Dhenkanal" if subnatid2 == "21-14"
	replace subnatid2 = "21-15 - Anugul" if subnatid2 == "21-15"
	replace subnatid2 = "34-01 - Yanam" if subnatid2 == "34-01"
	replace subnatid2 = "34-02 - Pondicherry" if subnatid2 == "34-02"
	replace subnatid2 = "34-03 - Mahe" if subnatid2 == "34-03"
	replace subnatid2 = "34-04 - Karaikal" if subnatid2 == "34-04"
	replace subnatid2 = "03-01 - Gurdaspur" if subnatid2 == "03-01"
	replace subnatid2 = "03-02 - Amritsar" if subnatid2 == "03-02"
	replace subnatid2 = "03-03 - Kapurthala" if subnatid2 == "03-03"
	replace subnatid2 = "03-04 - Jalandhar" if subnatid2 == "03-04"
	replace subnatid2 = "03-05 - Hoshiarpur" if subnatid2 == "03-05"
	replace subnatid2 = "03-06 - Nawanshahr" if subnatid2 == "03-06"
	replace subnatid2 = "03-07 - Rupnagar" if subnatid2 == "03-07"
	replace subnatid2 = "03-08 - Fatehgarh Sahib" if subnatid2 == "03-08"
	replace subnatid2 = "03-09 - Ludhiana" if subnatid2 == "03-09"
	replace subnatid2 = "03-10 - Moga" if subnatid2 == "03-10"
	replace subnatid2 = "03-11 - Firozpur" if subnatid2 == "03-11"
	replace subnatid2 = "03-12 - Muktsar" if subnatid2 == "03-12"
	replace subnatid2 = "03-13 - Faridkot" if subnatid2 == "03-13"
	replace subnatid2 = "03-14 - Bathinda" if subnatid2 == "03-14"
	replace subnatid2 = "03-15 - Mansa" if subnatid2 == "03-15"
	replace subnatid2 = "03-16 - Sangrur" if subnatid2 == "03-16"
	replace subnatid2 = "03-17 - Patiala" if subnatid2 == "03-17"
	replace subnatid2 = "08-03 - Bikaner" if subnatid2 == "08-03"
	replace subnatid2 = "08-15 - Jodhpur" if subnatid2 == "08-15"
	replace subnatid2 = "08-16 - Jaisalmer" if subnatid2 == "08-16"
	replace subnatid2 = "08-17 - Barmer" if subnatid2 == "08-17"
	replace subnatid2 = "08-18 - Jalor" if subnatid2 == "08-18"
	replace subnatid2 = "08-19 - Sirohi" if subnatid2 == "08-19"
	replace subnatid2 = "08-20 - Pali" if subnatid2 == "08-20"
	replace subnatid2 = "08-06 - Alwar" if subnatid2 == "08-06"
	replace subnatid2 = "08-07 - Bharatpur" if subnatid2 == "08-07"
	replace subnatid2 = "08-08 - Dhaulpur" if subnatid2 == "08-08"
	replace subnatid2 = "08-09 - Karauli" if subnatid2 == "08-09"
	replace subnatid2 = "08-10 - Sawai Madhopur" if subnatid2 == "08-10"
	replace subnatid2 = "08-11 - Dausa" if subnatid2 == "08-11"
	replace subnatid2 = "08-12 - Jaipur" if subnatid2 == "08-12"
	replace subnatid2 = "08-21 - Ajmer" if subnatid2 == "08-21"
	replace subnatid2 = "08-22 - Tonk" if subnatid2 == "08-22"
	replace subnatid2 = "08-24 - Bhilwara" if subnatid2 == "08-24"
	replace subnatid2 = "08-25 - Rajsamand" if subnatid2 == "08-25"
	replace subnatid2 = "08-26 - Udaipur" if subnatid2 == "08-26"
	replace subnatid2 = "08-27 - Dungarpur" if subnatid2 == "08-27"
	replace subnatid2 = "08-28 - Banswara" if subnatid2 == "08-28"
	replace subnatid2 = "08-23 - Bundi" if subnatid2 == "08-23"
	replace subnatid2 = "08-29 - Chittaurgarh" if subnatid2 == "08-29"
	replace subnatid2 = "08-30 - Kota" if subnatid2 == "08-30"
	replace subnatid2 = "08-31 - Baran" if subnatid2 == "08-31"
	replace subnatid2 = "08-32 - Jhalawar" if subnatid2 == "08-32"
	replace subnatid2 = "08-01 - Ganganagar" if subnatid2 == "08-01"
	replace subnatid2 = "08-02 - Hanumangarh" if subnatid2 == "08-02"
	replace subnatid2 = "08-04 - Churu" if subnatid2 == "08-04"
	replace subnatid2 = "08-05 - Jhunjhunun" if subnatid2 == "08-05"
	replace subnatid2 = "08-13 - Sikar" if subnatid2 == "08-13"
	replace subnatid2 = "08-14 - Nagaur" if subnatid2 == "08-14"
	replace subnatid2 = "11-01 - North  ( Mongam )" if subnatid2 == "11-01"
	replace subnatid2 = "11-02 - West ( Gyalshing )" if subnatid2 == "11-02"
	replace subnatid2 = "11-03 - South  ( Nimachai )" if subnatid2 == "11-03"
	replace subnatid2 = "11-04 - East ( Gangtok )" if subnatid2 == "11-04"
	replace subnatid2 = "33-01 - Thiruvallur" if subnatid2 == "33-01"
	replace subnatid2 = "33-02 - Chennai" if subnatid2 == "33-02"
	replace subnatid2 = "33-03 - Kancheepuram" if subnatid2 == "33-03"
	replace subnatid2 = "33-04 - Vellore" if subnatid2 == "33-04"
	replace subnatid2 = "33-06 - Tiruvanamalai" if subnatid2 == "33-06"
	replace subnatid2 = "33-07 - Viluppuram" if subnatid2 == "33-07"
	replace subnatid2 = "33-18 - Cuddalore" if subnatid2 == "33-18"
	replace subnatid2 = "33-14 - Karur" if subnatid2 == "33-14"
	replace subnatid2 = "33-15 - Tiruchirappalli" if subnatid2 == "33-15"
	replace subnatid2 = "33-16 - Perambalur" if subnatid2 == "33-16"
	replace subnatid2 = "33-17 - Ariyalur" if subnatid2 == "33-17"
	replace subnatid2 = "33-13 - Dindigul" if subnatid2 == "33-13"
	replace subnatid2 = "33-23 - Sivaganga" if subnatid2 == "33-23"
	replace subnatid2 = "33-24 - Madurai" if subnatid2 == "33-24"
	replace subnatid2 = "33-25 - Theni" if subnatid2 == "33-25"
	replace subnatid2 = "33-26 - Virudhunagar" if subnatid2 == "33-26"
	replace subnatid2 = "33-19 - Nagapattinam" if subnatid2 == "33-19"
	replace subnatid2 = "33-20 - Thiruvarur" if subnatid2 == "33-20"
	replace subnatid2 = "33-21 - Thanjavur" if subnatid2 == "33-21"
	replace subnatid2 = "33-22 - Pudukkottai" if subnatid2 == "33-22"
	replace subnatid2 = "33-27 - Ramanathapuram" if subnatid2 == "33-27"
	replace subnatid2 = "33-28 - Toothukudi" if subnatid2 == "33-28"
	replace subnatid2 = "33-29 - Tirunelveli" if subnatid2 == "33-29"
	replace subnatid2 = "33-30 - Kanniyakumari" if subnatid2 == "33-30"
	replace subnatid2 = "33-05 - Dharmapuri" if subnatid2 == "33-05"
	replace subnatid2 = "33-08 - Salem" if subnatid2 == "33-08"
	replace subnatid2 = "33-09 - Namakkal" if subnatid2 == "33-09"
	replace subnatid2 = "33-10 - Erode" if subnatid2 == "33-10"
	replace subnatid2 = "33-11 - The Nilgiris" if subnatid2 == "33-11"
	replace subnatid2 = "33-12 - Coimbatore" if subnatid2 == "33-12"
	replace subnatid2 = "16-01 - West Tripura" if subnatid2 == "16-01"
	replace subnatid2 = "16-02 - South Tripura" if subnatid2 == "16-02"
	replace subnatid2 = "16-03 - Dhalai" if subnatid2 == "16-03"
	replace subnatid2 = "16-04 - North Tripura" if subnatid2 == "16-04"
	replace subnatid2 = "09-01 - Saharanpur" if subnatid2 == "09-01"
	replace subnatid2 = "09-02 - Muzaffarnagar" if subnatid2 == "09-02"
	replace subnatid2 = "09-03 - Bijnor" if subnatid2 == "09-03"
	replace subnatid2 = "09-04 - Moradabad" if subnatid2 == "09-04"
	replace subnatid2 = "09-05 - Rampur" if subnatid2 == "09-05"
	replace subnatid2 = "09-06 - J Phule Nagar" if subnatid2 == "09-06"
	replace subnatid2 = "09-07 - Meerut" if subnatid2 == "09-07"
	replace subnatid2 = "09-08 - Baghpat" if subnatid2 == "09-08"
	replace subnatid2 = "09-09 - Ghaziabad" if subnatid2 == "09-09"
	replace subnatid2 = "09-10 - G. Buddha Nagar" if subnatid2 == "09-10"
	replace subnatid2 = "09-24 - Sitapur" if subnatid2 == "09-24"
	replace subnatid2 = "09-25 - Hardoi" if subnatid2 == "09-25"
	replace subnatid2 = "09-26 - Unnao" if subnatid2 == "09-26"
	replace subnatid2 = "09-27 - Lucknow" if subnatid2 == "09-27"
	replace subnatid2 = "09-28 - Rae Bareli" if subnatid2 == "09-28"
	replace subnatid2 = "09-33 - Kanpur Dehat" if subnatid2 == "09-33"
	replace subnatid2 = "09-34 - Kanpur Nagar" if subnatid2 == "09-34"
	replace subnatid2 = "09-42 - Fatehpur" if subnatid2 == "09-42"
	replace subnatid2 = "09-46 - Barabanki" if subnatid2 == "09-46"
	replace subnatid2 = "09-43 - Pratapgarh" if subnatid2 == "09-43"
	replace subnatid2 = "09-44 - Kaushambi" if subnatid2 == "09-44"
	replace subnatid2 = "09-45 - Allahabad" if subnatid2 == "09-45"
	replace subnatid2 = "09-47 - Faizabad" if subnatid2 == "09-47"
	replace subnatid2 = "09-48 - Ambedkar Nag." if subnatid2 == "09-48"
	replace subnatid2 = "09-49 - Sultanpur" if subnatid2 == "09-49"
	replace subnatid2 = "09-50 - Bahraich" if subnatid2 == "09-50"
	replace subnatid2 = "09-51 - Shrawasti" if subnatid2 == "09-51"
	replace subnatid2 = "09-52 - Balrampur" if subnatid2 == "09-52"
	replace subnatid2 = "09-53 - Gonda" if subnatid2 == "09-53"
	replace subnatid2 = "09-54 - Siddharthnagar" if subnatid2 == "09-54"
	replace subnatid2 = "09-55 - Basti" if subnatid2 == "09-55"
	replace subnatid2 = "09-56 - S. Kabir Nagar" if subnatid2 == "09-56"
	replace subnatid2 = "09-57 - Maharajganj" if subnatid2 == "09-57"
	replace subnatid2 = "09-58 - Gorakhpur" if subnatid2 == "09-58"
	replace subnatid2 = "09-59 - Kushinagar" if subnatid2 == "09-59"
	replace subnatid2 = "09-60 - Deoria" if subnatid2 == "09-60"
	replace subnatid2 = "09-61 - Azamgarh" if subnatid2 == "09-61"
	replace subnatid2 = "09-62 - Mau" if subnatid2 == "09-62"
	replace subnatid2 = "09-63 - Ballia" if subnatid2 == "09-63"
	replace subnatid2 = "09-64 - Jaunpur" if subnatid2 == "09-64"
	replace subnatid2 = "09-65 - Ghazipur" if subnatid2 == "09-65"
	replace subnatid2 = "09-66 - Chandauli" if subnatid2 == "09-66"
	replace subnatid2 = "09-67 - Varanasi" if subnatid2 == "09-67"
	replace subnatid2 = "09-68 - S.R.Nagar  ( Bhadohi )" if subnatid2 == "09-68"
	replace subnatid2 = "09-69 - Mirzapur" if subnatid2 == "09-69"
	replace subnatid2 = "09-70 - Sonbhadra" if subnatid2 == "09-70"
	replace subnatid2 = "09-35 - Jalaun" if subnatid2 == "09-35"
	replace subnatid2 = "09-36 - Jhansi" if subnatid2 == "09-36"
	replace subnatid2 = "09-37 - Lalitpur" if subnatid2 == "09-37"
	replace subnatid2 = "09-38 - Hamirpur" if subnatid2 == "09-38"
	replace subnatid2 = "09-39 - Mahoba" if subnatid2 == "09-39"
	replace subnatid2 = "09-40 - Banda" if subnatid2 == "09-40"
	replace subnatid2 = "09-41 - Chitrakoot" if subnatid2 == "09-41"
	replace subnatid2 = "09-11 - Bulandshahr" if subnatid2 == "09-11"
	replace subnatid2 = "09-12 - Aligarh" if subnatid2 == "09-12"
	replace subnatid2 = "09-13 - Hathras" if subnatid2 == "09-13"
	replace subnatid2 = "09-14 - Mathura" if subnatid2 == "09-14"
	replace subnatid2 = "09-15 - Agra" if subnatid2 == "09-15"
	replace subnatid2 = "09-16 - Firozabad" if subnatid2 == "09-16"
	replace subnatid2 = "09-17 - Etah" if subnatid2 == "09-17"
	replace subnatid2 = "09-18 - Mainpuri" if subnatid2 == "09-18"
	replace subnatid2 = "09-19 - Budaun" if subnatid2 == "09-19"
	replace subnatid2 = "09-20 - Bareilly" if subnatid2 == "09-20"
	replace subnatid2 = "09-21 - Pilibhit" if subnatid2 == "09-21"
	replace subnatid2 = "09-22 - Shahjahanpur" if subnatid2 == "09-22"
	replace subnatid2 = "09-23 - Kheri" if subnatid2 == "09-23"
	replace subnatid2 = "09-29 - Farrukhabad" if subnatid2 == "09-29"
	replace subnatid2 = "09-30 - Kannauj" if subnatid2 == "09-30"
	replace subnatid2 = "09-31 - Etawah" if subnatid2 == "09-31"
	replace subnatid2 = "09-32 - Auraiya" if subnatid2 == "09-32"
	replace subnatid2 = "05-01 - Uttarkashi" if subnatid2 == "05-01"
	replace subnatid2 = "05-02 - Chamoli" if subnatid2 == "05-02"
	replace subnatid2 = "05-03 - Rudraprayag" if subnatid2 == "05-03"
	replace subnatid2 = "05-04 - Tehri Garhwal" if subnatid2 == "05-04"
	replace subnatid2 = "05-05 - Dehradun" if subnatid2 == "05-05"
	replace subnatid2 = "05-06 - Garhwal" if subnatid2 == "05-06"
	replace subnatid2 = "05-07 - Pithoragarh" if subnatid2 == "05-07"
	replace subnatid2 = "05-08 - Bageshwar" if subnatid2 == "05-08"
	replace subnatid2 = "05-09 - Almora" if subnatid2 == "05-09"
	replace subnatid2 = "05-10 - Champawat" if subnatid2 == "05-10"
	replace subnatid2 = "05-11 - Nainital" if subnatid2 == "05-11"
	replace subnatid2 = "05-12 - Udham Singh Nagar" if subnatid2 == "05-12"
	replace subnatid2 = "05-13 - Hardwar" if subnatid2 == "05-13"
	replace subnatid2 = "19-01 - Darjiling" if subnatid2 == "19-01"
	replace subnatid2 = "19-02 - Jalpaiguri" if subnatid2 == "19-02"
	replace subnatid2 = "19-03 - Koch Bihar" if subnatid2 == "19-03"
	replace subnatid2 = "19-04 - Uttar Dinajpur" if subnatid2 == "19-04"
	replace subnatid2 = "19-05 - Dakshin Dinajpur" if subnatid2 == "19-05"
	replace subnatid2 = "19-06 - Maldah" if subnatid2 == "19-06"
	replace subnatid2 = "19-07 - Murshidabad" if subnatid2 == "19-07"
	replace subnatid2 = "19-08 - Birbhum" if subnatid2 == "19-08"
	replace subnatid2 = "19-10 - Nadia" if subnatid2 == "19-10"
	replace subnatid2 = "19-11 - North 24-Parganas" if subnatid2 == "19-11"
	replace subnatid2 = "19-17 - Kolkata" if subnatid2 == "19-17"
	replace subnatid2 = "19-18 - South 24-Parganas" if subnatid2 == "19-18"
	replace subnatid2 = "19-09 - Barddhaman" if subnatid2 == "19-09"
	replace subnatid2 = "19-12 - Hugli" if subnatid2 == "19-12"
	replace subnatid2 = "19-16 - Howrah" if subnatid2 == "19-16"
	replace subnatid2 = "19-13 - Bankura" if subnatid2 == "19-13"
	replace subnatid2 = "19-14 - Puruliya" if subnatid2 == "19-14"
	replace subnatid2 = "19-15 - Medinipur" if subnatid2 == "19-15"
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

	gen relationharm = B4_q3
	destring relationharm, replace
	recode relationharm (3 5 = 3) (7=4) (4 6 8 = 5) (9=6) (0=.)
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = B4_q3
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	destring B4_q6, gen(marital)
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

/* <_school>

This variable is not available in the 2007 dataset.
However, it is available in other years

</_school> */
	destring B4_q9, gen(school)
	recode school (1/20 = 0) (21/40 = 1)
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen byte literacy = .
	replace literacy = 0 if B4_q7 == "01"
	replace literacy = 1 if !inlist(B4_q7, "01") & !missing(B4_q7)
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
	replace educat7= 1 if genedulev<=4 & !missing(genedulev)
	replace educat7 = 2 if genedulev == 5 // Primary incomplete
	replace educat7 = 3 if genedulev == 6 // Primary complete
	replace educat7 = 4 if genedulev == 7 // Secondary incomplete
	replace educat7 = 5 if genedulev == 8 | genedulev == 10 // Secondary complete
	replace educat7 = 6 if genedulev ==11
	replace educat7= 7 if genedulev==12 | genedulev==13
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
 	gen educat_orig = B4_q7
 	label var educat_orig "Original survey education code"
 *</_educat_orig_>


*<_educat_isced_>
	destring B4_q7, gen(genedulev)
	gen educat_isced = .
	replace educat_isced = 0 if genedulev == 5
	replace educat_isced = 100 if genedulev == 6
	replace educat_isced = 200 if genedulev == 7
	replace educat_isced = 300 if genedulev == 8 | genedulev == 10
	replace educat_isced = 400 if genedulev == 11
	replace educat_isced = 500 if genedulev == 12
	replace educat_isced = 600 if genedulev == 13
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
	gen vocational = 1 if inlist(B4_q11, "1", "2", "3", "4")
	replace vocational = 0 if B4_q11 == "5"
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
	destring B6_q41, gen(lstatus)
	recode lstatus  (11/72 98 = 1) (81=2) (82 91/97=3) (99=.)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = .
	replace potential_lf = 0 if lstatus == 3
	replace potential_lf = 1 if B6_q41 == "82"
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
	destring B6_q41, gen(nlfreason)
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
	destring B6_q41, gen(empstat)
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
	gen industry_orig = B6_q19
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

	gen industrycat_isic = substr(industry_orig,1,4)
	
	* Corrections as explained in the note
	replace industrycat_isic = "1710" if inlist(industrycat_isic, "1713", "1714")
	replace industrycat_isic = "1720" if inlist(industrycat_isic, "1724", "1725")
	
	replace industrycat_isic = "2710" if inlist(industrycat_isic, "2711", "2712", "2713", "2714", "2715")
	replace industrycat_isic = "2710" if inlist(industrycat_isic, "2716", "2717", "2718", "2719")
	
	replace industrycat_isic = "" if lstatus != 1
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
	gen occup_orig = B6_q20
	replace occup_orig = "" if lstatus != 1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>

*<_occup_>
	gen nco_68 = occup_orig
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
	drop x_indic nco_68 nco_04 isco_88 code_04
*</_occup_>


*<_occup_isco_>
	gen nco_68 = occup_orig
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
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_wage_no_compen_>
	gen double wage_no_compen = B6_q151
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
	gen whours = 8*B6_q141
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
	gen has_job_primary = inlist(B6_q41,"11", "12", "21", "31", "41", "51") | inlist(B6_q41, "61", "62", "71", "72", "98")
	destring B6_q42, gen(empstat_2)
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
	gen industry_orig_2 = B6_q52
	replace industry_orig_2 = "" if lstatus != 1
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	gen industrycat_isic_2 = industry_orig_2 + "00"
	replace industrycat_isic_2 = "" if missing(empstat_2)
	replace industrycat_isic_2 = "" if industrycat_isic_2 == "00"
	
	
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
	replace industrycat10_2=3 if red_indus>=15 & red_indus<=37
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
	gen occup_isco_2 =  .
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
	gen double wage_no_compen_2 = B6_q152
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
	gen whours_2 = 8*B6_q142
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
	destring B5_q3, gen(primary_help)
	recode primary_help  11/72=1 81 82=2 91/98=3 99=.
	destring B5_q8, gen(secondary_help)
	recode secondary_help  11/72=1 81 82=2 91/98=3 99=.
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
	destring B5_q3, gen(nlfreason_year)
	recode nlfreason_year 11/82=. 91=1 92 93=2 94=3 95=4 96/99=5
	replace nlfreason_year = . if lstatus_year != 3 | (age < minlaborage & age != .)
	label var nlfreason_year "Reason not in the labor force - 12 month recall"
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
	destring B5_q3, gen(empstat_y1)
	recode empstat_y1 (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72=1) (81/99=.)
	destring B5_q8, gen(empstat_y2)
	recode empstat_y2 (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72=1) (81/99=.)

	gen empstat_year = empstat_y1
	replace empstat_year = empstat_y2 if adders == 1

	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status", replace
	label values empstat_year lblempstat_year
	drop empstat_y1 empstat_y2
*</_empstat_year_>

*<_ocusec_year_>
/* <_ocusec_year_note>

	Ocusec question is only to those with who are not in agriculture. Since this is 52% of employment
	it is left blank as cannot be answered for the majority of workers.
</_ocusec_year_note> */

	gen byte ocusec_year = .
	label var ocusec_year "Sector of activity primary job 12 day recall"
	la de lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_year lblocusec_year
*</_ocusec_year_>

*<_industry_orig_year_>
	gen industry_orig_year = B5_q5
	replace industry_orig_year = B5_q10 if adders == 1
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
	gen occup_orig_year = B5_q6
	replace occup_orig_year = B5_q11 if adders == 1
	replace occup_orig_year = "" if lstatus_year != 1
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


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
	drop x_indic nco_68 nco_04 isco_88 code_04
*</_occup_year_>


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
	destring B5_q8, gen(empstat_2_year)
	recode empstat_2_year (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72=1) (81/99=.)
	replace empstat_2_year = . if lstatus_year != 1
	replace empstat_2_year = . if seconds != 1

	label var empstat_2_year "Employment status during past week secondary job 12 month recall"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status", replace
	label values empstat_2_year lblempstat_2_year
*</_empstat_2_year_>


*<_ocusec_2_year_>
	gen byte ocusec_2_year = .
	label var ocusec_2_year "Sector of activity secondary job 12 day recall"
	la de lblocusec_2_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_2_year lblocusec_2_year
*</_ocusec_2_year_>


*<_industry_orig_2_year_>
	gen industry_orig_2_year = B5_q10 if seconds == 1
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
	gen occup_orig_2_year = B5_q11 if seconds == 1
	replace occup_orig_2_year = "" if missing(empstat_2_year)
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


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

	merge m:1 nco_68 using "`path_in_stata'/India_occup_correspondences.dta", nogen keep(match master)

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

save "`path_output'/`out_file'", replace

*</_% SAVE_>
