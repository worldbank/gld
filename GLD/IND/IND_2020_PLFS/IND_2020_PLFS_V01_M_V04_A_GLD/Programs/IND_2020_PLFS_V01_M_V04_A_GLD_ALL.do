/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_> 			IND_2020_PLFS_V01_M_V04_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata 17 <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2023-08-08 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						India </_Country_>
<_Survey Title_>				Periodic Labour Force Survey </_Survey Title_>
<_Survey Year_>					2020 </_Survey Year_>
<_Study ID_>					DDI-IND-CSO-PLFS-2020-20 </_Study ID_>
<_Data collection from_>		07/2020 </_Data collection from_>
<_Data collection to_>			06/2020 </_Data collection to_>
<_Source of dataset_> 			https://www.mospi.gov.in/web/mospi/download-tables-data/-/reports/view/templateTwo/16201?q=TBDCAT </_Source of dataset_>
<_Sample size (HH)_> 			100344 </_Sample size (HH)_>
<_Sample size (IND)_> 			413405 </_Sample size (IND)_>
<_Sampling method_> 			A stratified multi-stage design was adopted. The first stage units
(FSU) were the Urban Frame Survey (UFS) blocks in urban areas and 2011 Population Census
villages (Panchayat wards for Kerala) in rural areas. The ultimate stage units (USU) were
households. As in usual NSS rounds, in the case of large FSUs one intermediate stage unit,
called hamlet group/sub-block, was formed </_Sampling method_>
<_Geographic coverage_> 		State Level </_Geographic coverage_>
<_Currency_> 					Indian Rupee </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS 13 </_ICLS Version_>
<_ISCED Version_>				ISCED 2011 </_ISCED Version_>
<_ISCO Version_>				ISCO 1988 </_ISCO Version_>
<_OCCUP National_>				NCO 2004 </_OCCUP National_>
<_ISIC Version_>				ISIC 4 </_ISIC Version_>
<_INDUS National_>				NIC 2008 </_INDUS National_>

-----------------------------------------------------------------------
<_Version Control_>

* Date: 2024-01-05 - Update vars subnatid2, subnatid3
* Date: 2024-02-07 - Update vars subnatid2, subnatid3
* Date: 2024-04-17 - Update vars subnatid1

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
local country "IND"
local year    "2020"
local survey  "PLFS"
local vermast "V01"
	local veralt "V04"

* From the definitions, set path chunks
local level_1	   "`country'_`year'_`survey'"
local level_2_mast "`level_1'_`vermast'_M"
local level_2_harm "`level_1'_`vermast'_M_`veralt'_A_GLD"

* From chunks, define path_in, path_output folder
local path_in_stata "`server'/`country'/`level_1'/`level_2_mast'/Data/Stata"
local path_in_other "`server'/`country'/`level_1'/`level_2_mast'/Data/Original"
local path_output   "`server'/`country'/`level_1'/`level_2_harm'/Data/Harmonized"


* Define Output file name
local out_file "`level_2_harm'_ALL.dta"

*----------1.3: Database assembly------------------------------*

use "`path_in_stata'\IND_2020_PLFS_raw_IND_Stata.dta", clear

gen str1 h_1 = string(sample_sg_b_no,"%01.0f")
gen str1 h_2 = string(ss_stratum,"%01.0f")
gen str2 h_3 = string(hh_num,"%02.0f")

egen str9 hh_key = concat(fsu h_1 h_2 h_3 visit)
drop h_*

tempfile ind_file
save `ind_file'

use "`path_in_stata'\IND_2020_PLFS_raw_HH_Stata.dta", clear

gen str1 h_1 = string(sample_sg_b_no,"%01.0f")
gen str1 h_2 = string(ss_stratum,"%01.0f")
gen str2 h_3 = string(hh_num,"%02.0f")

egen str9 hh_key = concat(fsu h_1 h_2 h_3 visit)
drop h_*

merge 1:m hh_key using `ind_file', assert(match)
drop _merge hh_key

* There are "temporary visitors" (N = 2,587) who are included in the survey. These individuals were asked for information relating to their previous place of residence prior to moving in after March 2020. But they were not asked at all other information found in other modules of the survey as they are not considered as part of the household. Hence for cleanliness of the data, they are dropped from the analysis

drop if !missing(ppe_d_lupr_tv)

/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode = "IND"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "PLFS"
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
	gen int_year= .
	replace int_year = 2020 if inlist(quarter,"Q5","Q6")
	replace int_year = 2021 if inlist(quarter,"Q7","Q8")
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>

	gen  int_month = month
	destring int_month, replace force
	replace int_month = . if !inrange(int_month,1,12)
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
/* <_hhid_note>

	Using sample first segment unit, segment block number,
	second stage stratum, and HH number.

</_hhid_note> */

	gen str1 h_1 = string(sample_sg_b_no,"%01.0f")
	gen str1 h_2 = string(ss_stratum,"%01.0f")
	gen str2 h_3 = string(hh_num,"%02.0f")

	egen hhid = concat(fsu h_1 h_2 h_3)
	label var hhid "Household ID"
	drop h_1 h_2 h_3
*</_hhid_>


*<_pid_>
	gen indiv_id = string(person_no,"%02.0f")
	egen  pid = concat(hhid indiv_id)
	label var pid "Individual ID"
	drop indiv_id
*</_pid_>


*<_weight_>
/* <_weight_note>

	Instructions say to use the multiplier divided by 100
	if nss == nsc, otherwise by 200. In addition divide by
	the number of quarters the area has been in.

</_weight_note> */
	gen weight = .
	replace weight = (mult/no_qrt)/100 if nss_code == nsc_code
	replace weight = (mult/no_qrt)/200 if nss_code != nsc_code
	count if missing(weight)
	label var weight "Household sampling weight"
*</_weight_>


*<_psu_>
	gen psu = fsu
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = hhid
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	gen strata = stratum
	label var strata "Strata"
*</_strata_>


*<_wave_>
	gen wave = quarter
	label var wave "Survey wave"
*</_wave_>

*<_panel_>
	gen str panel = ""
	label var panel "Panel individual belongs to"
*</_panel_>

*<_visit_no_>
	destring visit, ignore("V") gen(visit_no)
	label var visit "Visit number in panel"
*</_visit_no_>


}


/*%%=============================================================================================
	3: Geography
==============================================================================================%%*/

{

*<_urban_>
	gen byte urban = sector
	recode urban (1 = 0) (2 = 1)
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
	gen byte subnatid1 = state
	label de lblsubnatid1 28 "28 - Andhra Pradesh" 12 "12 - Arunachal Pradesh" 18 "18 - Assam" 10 "10 - Bihar" 30 "30 - Goa" 24 "24 - Gujarat" 6 "6 - Haryana" 2 "2 - Himachal Pradesh" 1 "1 - Jammu & Kashmir" 29 "29 - Karnataka" 32 "32 - Kerala" 23 "23 - Madhya Pradesh" 27 "27 - Maharastra" 14 "14 - Manipur" 17 "17 - Meghalaya" 15 "15 - Mizoram" 13 "13 - Nagaland" 21 "21 - Odisha" 3 "3 - Punjab" 8 "8 - Rajasthan" 11 "11 - Sikkim" 33 "33 - Tamil Nadu" 16 "16 - Tripura" 9 "9 - Uttar Pradesh" 19 "19 - West Bengal" 35 "35 - Andaman & Nicober" 4 "4 - Chandigarh" 26 "26 - Dadra & Nagar Haveli" 25 "25 - Daman & Diu" 7 "7 - Delhi" 31 "31 - Lakshadweep" 34 "34 - Pondicheri" 22 "22 - Chhattisgarh" 20 "20 - Jharkhand" 5 "5 - Uttaranchal" 36 "36 - Telangana"
	label values subnatid1 lblsubnatid1
	* Convert numeric into string
	decode subnatid1, gen(subnatid1_str)
	rename subnatid1 subnatid1_num
	rename subnatid1_str subnatid1
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>



*<_subnatid2_>
	gen hlp_state = string(state, "%02.0f")
	gen hlp_dist = string(district, "%02.0f")
	egen subnatid2 = concat(hlp_state hlp_dist), punct(-)
	label var subnatid2 "Admin 2 - District"
	replace subnatid2 = "01-01 - Kupwara" if subnatid2 == "01-01"
	replace subnatid2 = "01-02 - Badgam" if subnatid2 == "01-02"
	replace subnatid2 = "01-03 - Leh" if subnatid2 == "01-03"
	replace subnatid2 = "01-04 - Kargil" if subnatid2 == "01-04"
	replace subnatid2 = "01-05 - Punch" if subnatid2 == "01-05"
	replace subnatid2 = "01-06 - Rajouri" if subnatid2 == "01-06"
	replace subnatid2 = "01-07 - Kathua" if subnatid2 == "01-07"
	replace subnatid2 = "01-08 - Baramula" if subnatid2 == "01-08"
	replace subnatid2 = "01-09 - Bandipore" if subnatid2 == "01-09"
	replace subnatid2 = "01-10 - Srinagar" if subnatid2 == "01-10"
	replace subnatid2 = "01-11 - Ganderbal" if subnatid2 == "01-11"
	replace subnatid2 = "01-12 - Pulwama" if subnatid2 == "01-12"
	replace subnatid2 = "01-13 - Shupiyan" if subnatid2 == "01-13"
	replace subnatid2 = "01-14 - Anantnag" if subnatid2 == "01-14"
	replace subnatid2 = "01-15 - Kulgam" if subnatid2 == "01-15"
	replace subnatid2 = "01-16 - Doda" if subnatid2 == "01-16"
	replace subnatid2 = "01-17 - Ramban" if subnatid2 == "01-17"
	replace subnatid2 = "01-18 - Kishtwar" if subnatid2 == "01-18"
	replace subnatid2 = "01-19 - Udhampur" if subnatid2 == "01-19"
	replace subnatid2 = "01-20 - Reasi" if subnatid2 == "01-20"
	replace subnatid2 = "01-21 - Jammu" if subnatid2 == "01-21"
	replace subnatid2 = "01-22 - Samba" if subnatid2 == "01-22"
	replace subnatid2 = "02-01 - Chamba" if subnatid2 == "02-01"
	replace subnatid2 = "02-02 - Kangra" if subnatid2 == "02-02"
	replace subnatid2 = "02-03 - Lahul & Spiti" if subnatid2 == "02-03"
	replace subnatid2 = "02-04 - Kullu" if subnatid2 == "02-04"
	replace subnatid2 = "02-05 - Mandi" if subnatid2 == "02-05"
	replace subnatid2 = "02-06 - Hamirpur" if subnatid2 == "02-06"
	replace subnatid2 = "02-07 - Una" if subnatid2 == "02-07"
	replace subnatid2 = "02-08 - Bilaspur" if subnatid2 == "02-08"
	replace subnatid2 = "02-09 - Solan" if subnatid2 == "02-09"
	replace subnatid2 = "02-10 - Sirmaur" if subnatid2 == "02-10"
	replace subnatid2 = "02-11 - Shimla" if subnatid2 == "02-11"
	replace subnatid2 = "02-12 - Kinnaur" if subnatid2 == "02-12"
	replace subnatid2 = "03-01 - Gurdaspur" if subnatid2 == "03-01"
	replace subnatid2 = "03-02 - Kapurthala" if subnatid2 == "03-02"
	replace subnatid2 = "03-03 - Jalandhar" if subnatid2 == "03-03"
	replace subnatid2 = "03-04 - Hoshiarpur" if subnatid2 == "03-04"
	replace subnatid2 = "03-05 - Shahid Bhagat Singh Nagar" if subnatid2 == "03-05"
	replace subnatid2 = "03-06 - Fatehgarh Sahib" if subnatid2 == "03-06"
	replace subnatid2 = "03-07 - Ludhiana" if subnatid2 == "03-07"
	replace subnatid2 = "03-08 - Moga" if subnatid2 == "03-08"
	replace subnatid2 = "03-09 - Firozpur" if subnatid2 == "03-09"
	replace subnatid2 = "03-10 - Muktsar" if subnatid2 == "03-10"
	replace subnatid2 = "03-11 - Faridkot" if subnatid2 == "03-11"
	replace subnatid2 = "03-12 - Bathinda" if subnatid2 == "03-12"
	replace subnatid2 = "03-13 - Mansa" if subnatid2 == "03-13"
	replace subnatid2 = "03-14 - Patiala" if subnatid2 == "03-14"
	replace subnatid2 = "03-15 - Amritsar" if subnatid2 == "03-15"
	replace subnatid2 = "03-16 - Tarn Taran" if subnatid2 == "03-16"
	replace subnatid2 = "03-17 - Rupnagar" if subnatid2 == "03-17"
	replace subnatid2 = "03-18 - Sahibzada Ajit Singh Nagar" if subnatid2 == "03-18"
	replace subnatid2 = "03-19 - Sangrur" if subnatid2 == "03-19"
	replace subnatid2 = "03-20 - Barnala" if subnatid2 == "03-20"
	replace subnatid2 = "03-21 - Pathankot" if subnatid2 == "03-21"
	replace subnatid2 = "03-22 - Fazilka" if subnatid2 == "03-22"
	replace subnatid2 = "04-01 - Chandigarh" if subnatid2 == "04-01"
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
	replace subnatid2 = "06-01 - Panchkula" if subnatid2 == "06-01"
	replace subnatid2 = "06-02 - Ambala" if subnatid2 == "06-02"
	replace subnatid2 = "06-03 - Yamunanagar" if subnatid2 == "06-03"
	replace subnatid2 = "06-04 - Kurukshetra" if subnatid2 == "06-04"
	replace subnatid2 = "06-05 - Kaithal" if subnatid2 == "06-05"
	replace subnatid2 = "06-06 - Karnal" if subnatid2 == "06-06"
	replace subnatid2 = "06-07 - Panipat" if subnatid2 == "06-07"
	replace subnatid2 = "06-08 - Sonipat" if subnatid2 == "06-08"
	replace subnatid2 = "06-09 - Jind" if subnatid2 == "06-09"
	replace subnatid2 = "06-10 - Fatehabad" if subnatid2 == "06-10"
	replace subnatid2 = "06-11 - Sirsa" if subnatid2 == "06-11"
	replace subnatid2 = "06-12 - Hisar" if subnatid2 == "06-12"
	replace subnatid2 = "06-13 - Bhiwani" if subnatid2 == "06-13"
	replace subnatid2 = "06-14 - Rohtak" if subnatid2 == "06-14"
	replace subnatid2 = "06-15 - Jhajjar" if subnatid2 == "06-15"
	replace subnatid2 = "06-16 - Mahendragarh" if subnatid2 == "06-16"
	replace subnatid2 = "06-17 - Rewari" if subnatid2 == "06-17"
	replace subnatid2 = "06-18 - Gurgaon" if subnatid2 == "06-18"
	replace subnatid2 = "06-19 - Mewat" if subnatid2 == "06-19"
	replace subnatid2 = "06-20 - Faridabad" if subnatid2 == "06-20"
	replace subnatid2 = "06-21 - Palwal" if subnatid2 == "06-21"
	replace subnatid2 = "07-01 - North West Delhi" if subnatid2 == "07-01"
	replace subnatid2 = "07-02 - North Delhi" if subnatid2 == "07-02"
	replace subnatid2 = "07-03 - North East Delhi" if subnatid2 == "07-03"
	replace subnatid2 = "07-04 - East Delhi" if subnatid2 == "07-04"
	replace subnatid2 = "07-05 - New Delhi" if subnatid2 == "07-05"
	replace subnatid2 = "07-06 - Central Delhi" if subnatid2 == "07-06"
	replace subnatid2 = "07-07 - West Delhi" if subnatid2 == "07-07"
	replace subnatid2 = "07-08 - South West Delhi" if subnatid2 == "07-08"
	replace subnatid2 = "07-09 - South Delhi" if subnatid2 == "07-09"
	replace subnatid2 = "08-01 - Sri Ganganagar" if subnatid2 == "08-01"
	replace subnatid2 = "08-02 - Hanumangarh" if subnatid2 == "08-02"
	replace subnatid2 = "08-03 - Bikaner" if subnatid2 == "08-03"
	replace subnatid2 = "08-04 - Churu" if subnatid2 == "08-04"
	replace subnatid2 = "08-05 - Jhunjhunun" if subnatid2 == "08-05"
	replace subnatid2 = "08-06 - Alwar" if subnatid2 == "08-06"
	replace subnatid2 = "08-07 - Bharatpur" if subnatid2 == "08-07"
	replace subnatid2 = "08-08 - Dhaulpur" if subnatid2 == "08-08"
	replace subnatid2 = "08-09 - Karauli" if subnatid2 == "08-09"
	replace subnatid2 = "08-10 - Sawai Madhopur" if subnatid2 == "08-10"
	replace subnatid2 = "08-11 - Dausa" if subnatid2 == "08-11"
	replace subnatid2 = "08-12 - Jaipur" if subnatid2 == "08-12"
	replace subnatid2 = "08-13 - Sikar" if subnatid2 == "08-13"
	replace subnatid2 = "08-14 - Nagaur" if subnatid2 == "08-14"
	replace subnatid2 = "08-15 - Jodhpur" if subnatid2 == "08-15"
	replace subnatid2 = "08-16 - Jaisalmer" if subnatid2 == "08-16"
	replace subnatid2 = "08-17 - Barmer" if subnatid2 == "08-17"
	replace subnatid2 = "08-18 - Jalor" if subnatid2 == "08-18"
	replace subnatid2 = "08-19 - Sirohi" if subnatid2 == "08-19"
	replace subnatid2 = "08-20 - Pali" if subnatid2 == "08-20"
	replace subnatid2 = "08-21 - Ajmer" if subnatid2 == "08-21"
	replace subnatid2 = "08-22 - Tonk" if subnatid2 == "08-22"
	replace subnatid2 = "08-23 - Bundi" if subnatid2 == "08-23"
	replace subnatid2 = "08-24 - Bhilwara" if subnatid2 == "08-24"
	replace subnatid2 = "08-25 - Rajsamand" if subnatid2 == "08-25"
	replace subnatid2 = "08-26 - Dungarpur" if subnatid2 == "08-26"
	replace subnatid2 = "08-27 - Banswara" if subnatid2 == "08-27"
	replace subnatid2 = "08-28 - Chittaurgarh" if subnatid2 == "08-28"
	replace subnatid2 = "08-29 - Kota" if subnatid2 == "08-29"
	replace subnatid2 = "08-30 - Baran" if subnatid2 == "08-30"
	replace subnatid2 = "08-31 - Jhalawar" if subnatid2 == "08-31"
	replace subnatid2 = "08-32 - Udaipur" if subnatid2 == "08-32"
	replace subnatid2 = "08-33 - Pratapgarh" if subnatid2 == "08-33"
	replace subnatid2 = "09-01 - Saharanpur" if subnatid2 == "09-01"
	replace subnatid2 = "09-02 - Muzaffarnagar" if subnatid2 == "09-02"
	replace subnatid2 = "09-03 - Bijnor" if subnatid2 == "09-03"
	replace subnatid2 = "09-04 - Moradabad" if subnatid2 == "09-04"
	replace subnatid2 = "09-05 - Rampur" if subnatid2 == "09-05"
	replace subnatid2 = "09-06 - Jyotiba Phule Nagar" if subnatid2 == "09-06"
	replace subnatid2 = "09-07 - Meerut" if subnatid2 == "09-07"
	replace subnatid2 = "09-08 - Baghpat" if subnatid2 == "09-08"
	replace subnatid2 = "09-09 - Ghaziabad" if subnatid2 == "09-09"
	replace subnatid2 = "09-10 - Gautam Buddha Nagar" if subnatid2 == "09-10"
	replace subnatid2 = "09-11 - Bulandshahr" if subnatid2 == "09-11"
	replace subnatid2 = "09-12 - Aligarh" if subnatid2 == "09-12"
	replace subnatid2 = "09-13 - Mahamaya Nagar" if subnatid2 == "09-13"
	replace subnatid2 = "09-14 - Mathura" if subnatid2 == "09-14"
	replace subnatid2 = "09-15 - Agra" if subnatid2 == "09-15"
	replace subnatid2 = "09-16 - Firozabad" if subnatid2 == "09-16"
	replace subnatid2 = "09-17 - Mainpuri" if subnatid2 == "09-17"
	replace subnatid2 = "09-18 - Budaun" if subnatid2 == "09-18"
	replace subnatid2 = "09-19 - Bareilly" if subnatid2 == "09-19"
	replace subnatid2 = "09-20 - Pilibhit" if subnatid2 == "09-20"
	replace subnatid2 = "09-21 - Shahjahanpur" if subnatid2 == "09-21"
	replace subnatid2 = "09-22 - Kheri" if subnatid2 == "09-22"
	replace subnatid2 = "09-23 - Sitapur" if subnatid2 == "09-23"
	replace subnatid2 = "09-24 - Hardoi" if subnatid2 == "09-24"
	replace subnatid2 = "09-25 - Unnao" if subnatid2 == "09-25"
	replace subnatid2 = "09-26 - Lucknow" if subnatid2 == "09-26"
	replace subnatid2 = "09-27 - Rae Bareli" if subnatid2 == "09-27"
	replace subnatid2 = "09-28 - Farrukhabad" if subnatid2 == "09-28"
	replace subnatid2 = "09-29 - Kannauj" if subnatid2 == "09-29"
	replace subnatid2 = "09-30 - Etawah" if subnatid2 == "09-30"
	replace subnatid2 = "09-31 - Auraiya" if subnatid2 == "09-31"
	replace subnatid2 = "09-32 - Kanpur Dehat" if subnatid2 == "09-32"
	replace subnatid2 = "09-33 - Kanpur Nagar" if subnatid2 == "09-33"
	replace subnatid2 = "09-34 - Jalaun" if subnatid2 == "09-34"
	replace subnatid2 = "09-35 - Jhansi" if subnatid2 == "09-35"
	replace subnatid2 = "09-36 - Lalitpur" if subnatid2 == "09-36"
	replace subnatid2 = "09-37 - Hamirpur" if subnatid2 == "09-37"
	replace subnatid2 = "09-38 - Mahoba" if subnatid2 == "09-38"
	replace subnatid2 = "09-39 - Banda" if subnatid2 == "09-39"
	replace subnatid2 = "09-40 - Chitrakoot" if subnatid2 == "09-40"
	replace subnatid2 = "09-41 - Fatehpur" if subnatid2 == "09-41"
	replace subnatid2 = "09-42 - Pratapgarh" if subnatid2 == "09-42"
	replace subnatid2 = "09-43 - Kaushambi" if subnatid2 == "09-43"
	replace subnatid2 = "09-44 - Allahabad" if subnatid2 == "09-44"
	replace subnatid2 = "09-45 - Bara Banki" if subnatid2 == "09-45"
	replace subnatid2 = "09-46 - Faizabad" if subnatid2 == "09-46"
	replace subnatid2 = "09-47 - Ambedkar Nagar" if subnatid2 == "09-47"
	replace subnatid2 = "09-48 - Sultanpur" if subnatid2 == "09-48"
	replace subnatid2 = "09-49 - Bahraich" if subnatid2 == "09-49"
	replace subnatid2 = "09-50 - Shrawasti" if subnatid2 == "09-50"
	replace subnatid2 = "09-51 - Balrampur" if subnatid2 == "09-51"
	replace subnatid2 = "09-52 - Gonda" if subnatid2 == "09-52"
	replace subnatid2 = "09-53 - Siddharthnagar" if subnatid2 == "09-53"
	replace subnatid2 = "09-54 - Basti" if subnatid2 == "09-54"
	replace subnatid2 = "09-55 - Sant Kabir Nagar" if subnatid2 == "09-55"
	replace subnatid2 = "09-56 - Mahrajganj" if subnatid2 == "09-56"
	replace subnatid2 = "09-57 - Gorakhpur" if subnatid2 == "09-57"
	replace subnatid2 = "09-58 - Kushinagar" if subnatid2 == "09-58"
	replace subnatid2 = "09-59 - Deoria" if subnatid2 == "09-59"
	replace subnatid2 = "09-60 - Azamgarh" if subnatid2 == "09-60"
	replace subnatid2 = "09-61 - Mau" if subnatid2 == "09-61"
	replace subnatid2 = "09-62 - Ballia" if subnatid2 == "09-62"
	replace subnatid2 = "09-63 - Jaunpur" if subnatid2 == "09-63"
	replace subnatid2 = "09-64 - Ghazipur" if subnatid2 == "09-64"
	replace subnatid2 = "09-65 - Chandauli" if subnatid2 == "09-65"
	replace subnatid2 = "09-66 - Varanasi" if subnatid2 == "09-66"
	replace subnatid2 = "09-67 - Sant Ravidas Nagar (Bhadohi)" if subnatid2 == "09-67"
	replace subnatid2 = "09-68 - Mirzapur" if subnatid2 == "09-68"
	replace subnatid2 = "09-69 - Sonbhadra" if subnatid2 == "09-69"
	replace subnatid2 = "09-70 - Etah" if subnatid2 == "09-70"
	replace subnatid2 = "09-71 - Kanshiram Nagar" if subnatid2 == "09-71"
	replace subnatid2 = "10-01 - Pashchim Champaran" if subnatid2 == "10-01"
	replace subnatid2 = "10-02 - Purba Champaran" if subnatid2 == "10-02"
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
	replace subnatid2 = "10-31 - Kaimur (Bhabua)" if subnatid2 == "10-31"
	replace subnatid2 = "10-32 - Rohtas" if subnatid2 == "10-32"
	replace subnatid2 = "10-33 - Aurangabad" if subnatid2 == "10-33"
	replace subnatid2 = "10-34 - Gaya" if subnatid2 == "10-34"
	replace subnatid2 = "10-35 - Nawada" if subnatid2 == "10-35"
	replace subnatid2 = "10-36 - Jamui" if subnatid2 == "10-36"
	replace subnatid2 = "10-37 - Jehanabad" if subnatid2 == "10-37"
	replace subnatid2 = "10-38 - Arwal" if subnatid2 == "10-38"
	replace subnatid2 = "11-01 - North District" if subnatid2 == "11-01"
	replace subnatid2 = "11-02 - West District" if subnatid2 == "11-02"
	replace subnatid2 = "11-03 - South District" if subnatid2 == "11-03"
	replace subnatid2 = "11-04 - East District" if subnatid2 == "11-04"
	replace subnatid2 = "12-01 - Tawang" if subnatid2 == "12-01"
	replace subnatid2 = "12-02 - West Kameng" if subnatid2 == "12-02"
	replace subnatid2 = "12-03 - East Kameng" if subnatid2 == "12-03"
	replace subnatid2 = "12-04 - Papum Pare" if subnatid2 == "12-04"
	replace subnatid2 = "12-05 - Upper Subansiri" if subnatid2 == "12-05"
	replace subnatid2 = "12-06 - West Siang" if subnatid2 == "12-06"
	replace subnatid2 = "12-07 - East Siang" if subnatid2 == "12-07"
	replace subnatid2 = "12-08 - Upper Siang" if subnatid2 == "12-08"
	replace subnatid2 = "12-09 - Changlang" if subnatid2 == "12-09"
	replace subnatid2 = "12-10 - Tirap" if subnatid2 == "12-10"
	replace subnatid2 = "12-11 - Lower Subansiri" if subnatid2 == "12-11"
	replace subnatid2 = "12-12 - Kurung Kumey" if subnatid2 == "12-12"
	replace subnatid2 = "12-13 - Dibang Valley" if subnatid2 == "12-13"
	replace subnatid2 = "12-14 - Lower Dibang Valley" if subnatid2 == "12-14"
	replace subnatid2 = "12-15 - Lohit" if subnatid2 == "12-15"
	replace subnatid2 = "12-16 - Anjaw" if subnatid2 == "12-16"
	replace subnatid2 = "13-01 - Mon" if subnatid2 == "13-01"
	replace subnatid2 = "13-02 - Mokokchung" if subnatid2 == "13-02"
	replace subnatid2 = "13-03 - Zunheboto" if subnatid2 == "13-03"
	replace subnatid2 = "13-04 - Wokha" if subnatid2 == "13-04"
	replace subnatid2 = "13-05 - Dimapur" if subnatid2 == "13-05"
	replace subnatid2 = "13-06 - Phek" if subnatid2 == "13-06"
	replace subnatid2 = "13-07 - Tuensang" if subnatid2 == "13-07"
	replace subnatid2 = "13-08 - Longleng" if subnatid2 == "13-08"
	replace subnatid2 = "13-09 - Kiphire" if subnatid2 == "13-09"
	replace subnatid2 = "13-10 - Kohima" if subnatid2 == "13-10"
	replace subnatid2 = "13-11 - Peren" if subnatid2 == "13-11"
	replace subnatid2 = "14-01 - Senapati" if subnatid2 == "14-01"
	replace subnatid2 = "14-02 - Tamenglong" if subnatid2 == "14-02"
	replace subnatid2 = "14-03 - Churachandpur" if subnatid2 == "14-03"
	replace subnatid2 = "14-04 - Bishnupur" if subnatid2 == "14-04"
	replace subnatid2 = "14-05 - Thoubal" if subnatid2 == "14-05"
	replace subnatid2 = "14-06 - Imphal West" if subnatid2 == "14-06"
	replace subnatid2 = "14-07 - Imphal East" if subnatid2 == "14-07"
	replace subnatid2 = "14-08 - Ukhrul" if subnatid2 == "14-08"
	replace subnatid2 = "14-09 - Chandel" if subnatid2 == "14-09"
	replace subnatid2 = "15-01 - Mamit" if subnatid2 == "15-01"
	replace subnatid2 = "15-02 - Kolasib" if subnatid2 == "15-02"
	replace subnatid2 = "15-03 - Aizawl" if subnatid2 == "15-03"
	replace subnatid2 = "15-04 - Champhai" if subnatid2 == "15-04"
	replace subnatid2 = "15-05 - Serchhip" if subnatid2 == "15-05"
	replace subnatid2 = "15-06 - Lunglei" if subnatid2 == "15-06"
	replace subnatid2 = "15-07 - Lawngtlai" if subnatid2 == "15-07"
	replace subnatid2 = "15-08 - Saiha" if subnatid2 == "15-08"
	replace subnatid2 = "16-01 - West Tripura" if subnatid2 == "16-01"
	replace subnatid2 = "16-02 - South Tripura" if subnatid2 == "16-02"
	replace subnatid2 = "16-03 - Dhalai" if subnatid2 == "16-03"
	replace subnatid2 = "16-04 - North Tripura" if subnatid2 == "16-04"
	replace subnatid2 = "17-01 - West Garo Hills" if subnatid2 == "17-01"
	replace subnatid2 = "17-02 - East Garo Hills" if subnatid2 == "17-02"
	replace subnatid2 = "17-03 - South Garo Hills" if subnatid2 == "17-03"
	replace subnatid2 = "17-04 - West Khasi Hills" if subnatid2 == "17-04"
	replace subnatid2 = "17-05 - Ribhoi" if subnatid2 == "17-05"
	replace subnatid2 = "17-06 - East Khasi Hills" if subnatid2 == "17-06"
	replace subnatid2 = "17-07 - Jaintia Hills" if subnatid2 == "17-07"
	replace subnatid2 = "18-01 - Kokrajhar" if subnatid2 == "18-01"
	replace subnatid2 = "18-02 - Dhubri" if subnatid2 == "18-02"
	replace subnatid2 = "18-03 - Goalpara" if subnatid2 == "18-03"
	replace subnatid2 = "18-04 - Barpeta" if subnatid2 == "18-04"
	replace subnatid2 = "18-05 - Morigaon" if subnatid2 == "18-05"
	replace subnatid2 = "18-06 - Nagaon" if subnatid2 == "18-06"
	replace subnatid2 = "18-07 - Sonitpur" if subnatid2 == "18-07"
	replace subnatid2 = "18-08 - Lakhimpur" if subnatid2 == "18-08"
	replace subnatid2 = "18-09 - Dhemaji" if subnatid2 == "18-09"
	replace subnatid2 = "18-10 - Tinsukia" if subnatid2 == "18-10"
	replace subnatid2 = "18-11 - Dibrugarh" if subnatid2 == "18-11"
	replace subnatid2 = "18-12 - Sivasagar" if subnatid2 == "18-12"
	replace subnatid2 = "18-13 - Jorhat" if subnatid2 == "18-13"
	replace subnatid2 = "18-14 - Golaghat" if subnatid2 == "18-14"
	replace subnatid2 = "18-15 - Karbi Anglong" if subnatid2 == "18-15"
	replace subnatid2 = "18-16 - Dima Hasao" if subnatid2 == "18-16"
	replace subnatid2 = "18-17 - Cachar" if subnatid2 == "18-17"
	replace subnatid2 = "18-18 - Karimganj" if subnatid2 == "18-18"
	replace subnatid2 = "18-19 - Hailakandi" if subnatid2 == "18-19"
	replace subnatid2 = "18-20 - Bongaigaon" if subnatid2 == "18-20"
	replace subnatid2 = "18-21 - Chirang" if subnatid2 == "18-21"
	replace subnatid2 = "18-22 - Kamrup" if subnatid2 == "18-22"
	replace subnatid2 = "18-23 - Kamrup Metropolitan" if subnatid2 == "18-23"
	replace subnatid2 = "18-24 - Nalbari" if subnatid2 == "18-24"
	replace subnatid2 = "18-25 - Baksa" if subnatid2 == "18-25"
	replace subnatid2 = "18-26 - Darrang" if subnatid2 == "18-26"
	replace subnatid2 = "18-27 - Udalguri" if subnatid2 == "18-27"
	replace subnatid2 = "19-01 - Darjiling" if subnatid2 == "19-01"
	replace subnatid2 = "19-02 - Jalpaiguri" if subnatid2 == "19-02"
	replace subnatid2 = "19-03 - Koch Bihar" if subnatid2 == "19-03"
	replace subnatid2 = "19-04 - Uttar Dinajpur" if subnatid2 == "19-04"
	replace subnatid2 = "19-05 - Dakshin Dinajpur" if subnatid2 == "19-05"
	replace subnatid2 = "19-06 - Maldah" if subnatid2 == "19-06"
	replace subnatid2 = "19-07 - Murshidabad" if subnatid2 == "19-07"
	replace subnatid2 = "19-08 - Birbhum" if subnatid2 == "19-08"
	replace subnatid2 = "19-09 - Purba Barddhaman" if subnatid2 == "19-09"
	replace subnatid2 = "19-10 - Nadia" if subnatid2 == "19-10"
	replace subnatid2 = "19-11 - North Twenty Four Parganas" if subnatid2 == "19-11"
	replace subnatid2 = "19-12 - Hugli" if subnatid2 == "19-12"
	replace subnatid2 = "19-13 - Bankura" if subnatid2 == "19-13"
	replace subnatid2 = "19-14 - Puruliya" if subnatid2 == "19-14"
	replace subnatid2 = "19-15 - Haora" if subnatid2 == "19-15"
	replace subnatid2 = "19-16 - Kolkata" if subnatid2 == "19-16"
	replace subnatid2 = "19-17 - South Twenty Four Parganas" if subnatid2 == "19-17"
	replace subnatid2 = "19-18 - Paschim Medinipur" if subnatid2 == "19-18"
	replace subnatid2 = "19-19 - Purba Medinipur" if subnatid2 == "19-19"
	replace subnatid2 = "19-20 - Alipurduar" if subnatid2 == "19-20"
	replace subnatid2 = "19-21 - Kalimpong" if subnatid2 == "19-21"
	replace subnatid2 = "19-22 - Jhargram" if subnatid2 == "19-22"
	replace subnatid2 = "19-23 - Paschim Barddhaman" if subnatid2 == "19-23"
	replace subnatid2 = "20-01 - Garhwa" if subnatid2 == "20-01"
	replace subnatid2 = "20-02 - Chatra" if subnatid2 == "20-02"
	replace subnatid2 = "20-03 - Kodarma" if subnatid2 == "20-03"
	replace subnatid2 = "20-04 - Giridih" if subnatid2 == "20-04"
	replace subnatid2 = "20-05 - Deoghar" if subnatid2 == "20-05"
	replace subnatid2 = "20-06 - Godda" if subnatid2 == "20-06"
	replace subnatid2 = "20-07 - Sahibganj" if subnatid2 == "20-07"
	replace subnatid2 = "20-08 - Pakur" if subnatid2 == "20-08"
	replace subnatid2 = "20-09 - Dhanbad" if subnatid2 == "20-09"
	replace subnatid2 = "20-10 - Bokaro" if subnatid2 == "20-10"
	replace subnatid2 = "20-11 - Lohardaga" if subnatid2 == "20-11"
	replace subnatid2 = "20-12 - Purbi Singhbhum" if subnatid2 == "20-12"
	replace subnatid2 = "20-13 - Palamu" if subnatid2 == "20-13"
	replace subnatid2 = "20-14 - Latehar" if subnatid2 == "20-14"
	replace subnatid2 = "20-15 - Hazaribagh" if subnatid2 == "20-15"
	replace subnatid2 = "20-16 - Ramgarh" if subnatid2 == "20-16"
	replace subnatid2 = "20-17 - Dumka" if subnatid2 == "20-17"
	replace subnatid2 = "20-18 - Jamtara" if subnatid2 == "20-18"
	replace subnatid2 = "20-19 - Ranchi" if subnatid2 == "20-19"
	replace subnatid2 = "20-20 - Khunti" if subnatid2 == "20-20"
	replace subnatid2 = "20-21 - Gumla" if subnatid2 == "20-21"
	replace subnatid2 = "20-22 - Simdega" if subnatid2 == "20-22"
	replace subnatid2 = "20-23 - Pashchimi Singhbhum" if subnatid2 == "20-23"
	replace subnatid2 = "20-24 - Saraikela-Kharsawan" if subnatid2 == "20-24"
	replace subnatid2 = "21-01 - Bargarh" if subnatid2 == "21-01"
	replace subnatid2 = "21-02 - Jharsuguda" if subnatid2 == "21-02"
	replace subnatid2 = "21-03 - Sambalpur" if subnatid2 == "21-03"
	replace subnatid2 = "21-04 - Debagarh" if subnatid2 == "21-04"
	replace subnatid2 = "21-05 - Sundargarh" if subnatid2 == "21-05"
	replace subnatid2 = "21-06 - Kendujhar" if subnatid2 == "21-06"
	replace subnatid2 = "21-07 - Mayurbhanj" if subnatid2 == "21-07"
	replace subnatid2 = "21-08 - Baleshwar" if subnatid2 == "21-08"
	replace subnatid2 = "21-09 - Bhadrak" if subnatid2 == "21-09"
	replace subnatid2 = "21-10 - Kendrapara" if subnatid2 == "21-10"
	replace subnatid2 = "21-11 - Jagatsinghapur" if subnatid2 == "21-11"
	replace subnatid2 = "21-12 - Cuttack" if subnatid2 == "21-12"
	replace subnatid2 = "21-13 - Jajapur" if subnatid2 == "21-13"
	replace subnatid2 = "21-14 - Dhenkanal" if subnatid2 == "21-14"
	replace subnatid2 = "21-15 - Anugul" if subnatid2 == "21-15"
	replace subnatid2 = "21-16 - Nayagarh" if subnatid2 == "21-16"
	replace subnatid2 = "21-17 - Khordha" if subnatid2 == "21-17"
	replace subnatid2 = "21-18 - Puri" if subnatid2 == "21-18"
	replace subnatid2 = "21-19 - Ganjam" if subnatid2 == "21-19"
	replace subnatid2 = "21-20 - Gajapati" if subnatid2 == "21-20"
	replace subnatid2 = "21-21 - Kandhamal" if subnatid2 == "21-21"
	replace subnatid2 = "21-22 - Baudh" if subnatid2 == "21-22"
	replace subnatid2 = "21-23 - Subarnapur" if subnatid2 == "21-23"
	replace subnatid2 = "21-24 - Balangir" if subnatid2 == "21-24"
	replace subnatid2 = "21-25 - Nuapada" if subnatid2 == "21-25"
	replace subnatid2 = "21-26 - Kalahandi" if subnatid2 == "21-26"
	replace subnatid2 = "21-27 - Rayagada" if subnatid2 == "21-27"
	replace subnatid2 = "21-28 - Nabarangapur" if subnatid2 == "21-28"
	replace subnatid2 = "21-29 - Koraput" if subnatid2 == "21-29"
	replace subnatid2 = "21-30 - Malkangiri" if subnatid2 == "21-30"
	replace subnatid2 = "22-01 - Koriya" if subnatid2 == "22-01"
	replace subnatid2 = "22-02 - Surguja" if subnatid2 == "22-02"
	replace subnatid2 = "22-03 - Jashpur" if subnatid2 == "22-03"
	replace subnatid2 = "22-04 - Raigarh" if subnatid2 == "22-04"
	replace subnatid2 = "22-05 - Korba" if subnatid2 == "22-05"
	replace subnatid2 = "22-06 - Janjgir-Champa" if subnatid2 == "22-06"
	replace subnatid2 = "22-07 - Bilaspur" if subnatid2 == "22-07"
	replace subnatid2 = "22-08 - Kabeerdham" if subnatid2 == "22-08"
	replace subnatid2 = "22-09 - Rajnandgaon" if subnatid2 == "22-09"
	replace subnatid2 = "22-10 - Durg" if subnatid2 == "22-10"
	replace subnatid2 = "22-11 - Raipur" if subnatid2 == "22-11"
	replace subnatid2 = "22-12 - Mahasamund" if subnatid2 == "22-12"
	replace subnatid2 = "22-13 - Dhamtari" if subnatid2 == "22-13"
	replace subnatid2 = "22-14 - Uttar Bastar Kanker" if subnatid2 == "22-14"
	replace subnatid2 = "22-15 - Bastar" if subnatid2 == "22-15"
	replace subnatid2 = "22-16 - Narayanpur" if subnatid2 == "22-16"
	replace subnatid2 = "22-17 - Dakshin Bastar Dantewada" if subnatid2 == "22-17"
	replace subnatid2 = "22-18 - Bijapur" if subnatid2 == "22-18"
	replace subnatid2 = "22-19 - Balodabazar" if subnatid2 == "22-19"
	replace subnatid2 = "22-20 - Gariyaband" if subnatid2 == "22-20"
	replace subnatid2 = "22-21 - Kondagaon" if subnatid2 == "22-21"
	replace subnatid2 = "22-22 - Sukama" if subnatid2 == "22-22"
	replace subnatid2 = "22-23 - Bemetara" if subnatid2 == "22-23"
	replace subnatid2 = "22-24 - Balod" if subnatid2 == "22-24"
	replace subnatid2 = "22-25 - Mungeli" if subnatid2 == "22-25"
	replace subnatid2 = "22-26 - Surajpur" if subnatid2 == "22-26"
	replace subnatid2 = "22-27 - Balrampur" if subnatid2 == "22-27"
	replace subnatid2 = "23-01 - Sheopur" if subnatid2 == "23-01"
	replace subnatid2 = "23-02 - Morena" if subnatid2 == "23-02"
	replace subnatid2 = "23-03 - Bhind" if subnatid2 == "23-03"
	replace subnatid2 = "23-04 - Gwalior" if subnatid2 == "23-04"
	replace subnatid2 = "23-05 - Datia" if subnatid2 == "23-05"
	replace subnatid2 = "23-06 - Shivpuri" if subnatid2 == "23-06"
	replace subnatid2 = "23-07 - Tikamgarh" if subnatid2 == "23-07"
	replace subnatid2 = "23-08 - Chhatarpur" if subnatid2 == "23-08"
	replace subnatid2 = "23-09 - Panna" if subnatid2 == "23-09"
	replace subnatid2 = "23-10 - Sagar" if subnatid2 == "23-10"
	replace subnatid2 = "23-11 - Damoh" if subnatid2 == "23-11"
	replace subnatid2 = "23-12 - Satna" if subnatid2 == "23-12"
	replace subnatid2 = "23-13 - Rewa" if subnatid2 == "23-13"
	replace subnatid2 = "23-14 - Umaria" if subnatid2 == "23-14"
	replace subnatid2 = "23-15 - Neemuch" if subnatid2 == "23-15"
	replace subnatid2 = "23-16 - Mandsaur" if subnatid2 == "23-16"
	replace subnatid2 = "23-17 - Ratlam" if subnatid2 == "23-17"
	replace subnatid2 = "23-18 - Ujjain" if subnatid2 == "23-18"
	replace subnatid2 = "23-19 - Shajapur" if subnatid2 == "23-19"
	replace subnatid2 = "23-20 - Dewas" if subnatid2 == "23-20"
	replace subnatid2 = "23-21 - Dhar" if subnatid2 == "23-21"
	replace subnatid2 = "23-22 - Indore" if subnatid2 == "23-22"
	replace subnatid2 = "23-23 - Khargone (West Nimar)" if subnatid2 == "23-23"
	replace subnatid2 = "23-24 - Barwani" if subnatid2 == "23-24"
	replace subnatid2 = "23-25 - Rajgarh" if subnatid2 == "23-25"
	replace subnatid2 = "23-26 - Vidisha" if subnatid2 == "23-26"
	replace subnatid2 = "23-27 - Bhopal" if subnatid2 == "23-27"
	replace subnatid2 = "23-28 - Sehore" if subnatid2 == "23-28"
	replace subnatid2 = "23-29 - Raisen" if subnatid2 == "23-29"
	replace subnatid2 = "23-30 - Betul" if subnatid2 == "23-30"
	replace subnatid2 = "23-31 - Harda" if subnatid2 == "23-31"
	replace subnatid2 = "23-32 - Hoshangabad" if subnatid2 == "23-32"
	replace subnatid2 = "23-33 - Katni" if subnatid2 == "23-33"
	replace subnatid2 = "23-34 - Jabalpur" if subnatid2 == "23-34"
	replace subnatid2 = "23-35 - Narsimhapur" if subnatid2 == "23-35"
	replace subnatid2 = "23-36 - Dindori" if subnatid2 == "23-36"
	replace subnatid2 = "23-37 - Mandla" if subnatid2 == "23-37"
	replace subnatid2 = "23-38 - Chhindwara" if subnatid2 == "23-38"
	replace subnatid2 = "23-39 - Seoni" if subnatid2 == "23-39"
	replace subnatid2 = "23-40 - Balaghat" if subnatid2 == "23-40"
	replace subnatid2 = "23-41 - Guna" if subnatid2 == "23-41"
	replace subnatid2 = "23-42 - Ashoknagar" if subnatid2 == "23-42"
	replace subnatid2 = "23-43 - Shahdol" if subnatid2 == "23-43"
	replace subnatid2 = "23-44 - Anuppur" if subnatid2 == "23-44"
	replace subnatid2 = "23-45 - Sidhi" if subnatid2 == "23-45"
	replace subnatid2 = "23-46 - Singrauli" if subnatid2 == "23-46"
	replace subnatid2 = "23-47 - Jhabua" if subnatid2 == "23-47"
	replace subnatid2 = "23-48 - Alirajpur" if subnatid2 == "23-48"
	replace subnatid2 = "23-49 - Khandwa (East Nimar)" if subnatid2 == "23-49"
	replace subnatid2 = "23-50 - Burhanpur" if subnatid2 == "23-50"
	replace subnatid2 = "24-01 - Kachchh" if subnatid2 == "24-01"
	replace subnatid2 = "24-02 - Banas Kantha" if subnatid2 == "24-02"
	replace subnatid2 = "24-03 - Patan" if subnatid2 == "24-03"
	replace subnatid2 = "24-04 - Mahesana" if subnatid2 == "24-04"
	replace subnatid2 = "24-05 - Sabar Kantha" if subnatid2 == "24-05"
	replace subnatid2 = "24-06 - Gandhinagar" if subnatid2 == "24-06"
	replace subnatid2 = "24-07 - Ahmedabad" if subnatid2 == "24-07"
	replace subnatid2 = "24-08 - Surendranagar" if subnatid2 == "24-08"
	replace subnatid2 = "24-09 - Rajkot" if subnatid2 == "24-09"
	replace subnatid2 = "24-10 - Jamnagar" if subnatid2 == "24-10"
	replace subnatid2 = "24-11 - Porbandar" if subnatid2 == "24-11"
	replace subnatid2 = "24-12 - Junagadh" if subnatid2 == "24-12"
	replace subnatid2 = "24-13 - Amreli" if subnatid2 == "24-13"
	replace subnatid2 = "24-14 - Bhavnagar" if subnatid2 == "24-14"
	replace subnatid2 = "24-15 - Anand" if subnatid2 == "24-15"
	replace subnatid2 = "24-16 - Kheda" if subnatid2 == "24-16"
	replace subnatid2 = "24-17 - Panch Mahals" if subnatid2 == "24-17"
	replace subnatid2 = "24-18 - Dohad" if subnatid2 == "24-18"
	replace subnatid2 = "24-19 - Vadodara" if subnatid2 == "24-19"
	replace subnatid2 = "24-20 - Narmada" if subnatid2 == "24-20"
	replace subnatid2 = "24-21 - Bharuch" if subnatid2 == "24-21"
	replace subnatid2 = "24-22 - The Dangs" if subnatid2 == "24-22"
	replace subnatid2 = "24-23 - Navsari" if subnatid2 == "24-23"
	replace subnatid2 = "24-24 - Valsad" if subnatid2 == "24-24"
	replace subnatid2 = "24-25 - Surat" if subnatid2 == "24-25"
	replace subnatid2 = "24-26 - Tapi" if subnatid2 == "24-26"
	replace subnatid2 = "24-27 - Arvalli" if subnatid2 == "24-27"
	replace subnatid2 = "24-28 - Botad" if subnatid2 == "24-28"
	replace subnatid2 = "24-29 - Chhota Udepur" if subnatid2 == "24-29"
	replace subnatid2 = "24-30 - DevBhumi-Dwarka" if subnatid2 == "24-30"
	replace subnatid2 = "24-31 - Gir Somnath" if subnatid2 == "24-31"
	replace subnatid2 = "24-32 - Mahisagar" if subnatid2 == "24-32"
	replace subnatid2 = "24-33 - Morbi" if subnatid2 == "24-33"
	replace subnatid2 = "25-01 - Diu" if subnatid2 == "25-01"
	replace subnatid2 = "25-02 - Daman" if subnatid2 == "25-02"
	replace subnatid2 = "26-01 - Dadra & Nagar Haveli" if subnatid2 == "26-01"
	replace subnatid2 = "27-01 - Nandurbar" if subnatid2 == "27-01"
	replace subnatid2 = "27-02 - Dhule" if subnatid2 == "27-02"
	replace subnatid2 = "27-03 - Jalgaon" if subnatid2 == "27-03"
	replace subnatid2 = "27-04 - Buldana" if subnatid2 == "27-04"
	replace subnatid2 = "27-05 - Akola" if subnatid2 == "27-05"
	replace subnatid2 = "27-06 - Washim" if subnatid2 == "27-06"
	replace subnatid2 = "27-07 - Amravati" if subnatid2 == "27-07"
	replace subnatid2 = "27-08 - Wardha" if subnatid2 == "27-08"
	replace subnatid2 = "27-09 - Nagpur" if subnatid2 == "27-09"
	replace subnatid2 = "27-10 - Bhandara" if subnatid2 == "27-10"
	replace subnatid2 = "27-11 - Gondiya" if subnatid2 == "27-11"
	replace subnatid2 = "27-12 - Gadchiroli" if subnatid2 == "27-12"
	replace subnatid2 = "27-13 - Chandrapur" if subnatid2 == "27-13"
	replace subnatid2 = "27-14 - Yavatmal" if subnatid2 == "27-14"
	replace subnatid2 = "27-15 - Nanded" if subnatid2 == "27-15"
	replace subnatid2 = "27-16 - Hingoli" if subnatid2 == "27-16"
	replace subnatid2 = "27-17 - Parbhani" if subnatid2 == "27-17"
	replace subnatid2 = "27-18 - Jalna" if subnatid2 == "27-18"
	replace subnatid2 = "27-19 - Aurangabad" if subnatid2 == "27-19"
	replace subnatid2 = "27-20 - Nashik" if subnatid2 == "27-20"
	replace subnatid2 = "27-21 - Thane" if subnatid2 == "27-21"
	replace subnatid2 = "27-22 - Mumbai Suburban" if subnatid2 == "27-22"
	replace subnatid2 = "27-23 - Mumbai" if subnatid2 == "27-23"
	replace subnatid2 = "27-24 - Raigarh" if subnatid2 == "27-24"
	replace subnatid2 = "27-25 - Pune" if subnatid2 == "27-25"
	replace subnatid2 = "27-26 - Ahmadnagar" if subnatid2 == "27-26"
	replace subnatid2 = "27-27 - Bid" if subnatid2 == "27-27"
	replace subnatid2 = "27-28 - Latur" if subnatid2 == "27-28"
	replace subnatid2 = "27-29 - Osmanabad" if subnatid2 == "27-29"
	replace subnatid2 = "27-30 - Solapur" if subnatid2 == "27-30"
	replace subnatid2 = "27-31 - Satara" if subnatid2 == "27-31"
	replace subnatid2 = "27-32 - Ratnagiri" if subnatid2 == "27-32"
	replace subnatid2 = "27-33 - Sindhudurg" if subnatid2 == "27-33"
	replace subnatid2 = "27-34 - Kolhapur" if subnatid2 == "27-34"
	replace subnatid2 = "27-35 - Sangli" if subnatid2 == "27-35"
	replace subnatid2 = "28-01 - Srikakulam" if subnatid2 == "28-01"
	replace subnatid2 = "28-02 - Vizianagaram" if subnatid2 == "28-02"
	replace subnatid2 = "28-03 - Visakhapatnam" if subnatid2 == "28-03"
	replace subnatid2 = "28-04 - East Godavari" if subnatid2 == "28-04"
	replace subnatid2 = "28-05 - West Godavari" if subnatid2 == "28-05"
	replace subnatid2 = "28-06 - Krishna" if subnatid2 == "28-06"
	replace subnatid2 = "28-07 - Guntur" if subnatid2 == "28-07"
	replace subnatid2 = "28-08 - Prakasam" if subnatid2 == "28-08"
	replace subnatid2 = "28-09 - Sri Potti Sriramulu Nellore" if subnatid2 == "28-09"
	replace subnatid2 = "28-10 - Y.S.R. (Cuddapah)" if subnatid2 == "28-10"
	replace subnatid2 = "28-11 - Kurnool" if subnatid2 == "28-11"
	replace subnatid2 = "28-12 - Anantapur" if subnatid2 == "28-12"
	replace subnatid2 = "28-13 - Chittoor" if subnatid2 == "28-13"
	replace subnatid2 = "29-01 - Belgaum" if subnatid2 == "29-01"
	replace subnatid2 = "29-02 - Bagalkot" if subnatid2 == "29-02"
	replace subnatid2 = "29-03 - Bijapur" if subnatid2 == "29-03"
	replace subnatid2 = "29-04 - Bidar" if subnatid2 == "29-04"
	replace subnatid2 = "29-05 - Raichur" if subnatid2 == "29-05"
	replace subnatid2 = "29-06 - Koppal" if subnatid2 == "29-06"
	replace subnatid2 = "29-07 - Gadag" if subnatid2 == "29-07"
	replace subnatid2 = "29-08 - Dharwad" if subnatid2 == "29-08"
	replace subnatid2 = "29-09 - Uttara Kannada" if subnatid2 == "29-09"
	replace subnatid2 = "29-10 - Haveri" if subnatid2 == "29-10"
	replace subnatid2 = "29-11 - Bellary" if subnatid2 == "29-11"
	replace subnatid2 = "29-12 - Chitradurga" if subnatid2 == "29-12"
	replace subnatid2 = "29-13 - Davanagere" if subnatid2 == "29-13"
	replace subnatid2 = "29-14 - Shimoga" if subnatid2 == "29-14"
	replace subnatid2 = "29-15 - Udupi" if subnatid2 == "29-15"
	replace subnatid2 = "29-16 - Chikmagalur" if subnatid2 == "29-16"
	replace subnatid2 = "29-17 - Tumkur" if subnatid2 == "29-17"
	replace subnatid2 = "29-18 - Bangalore" if subnatid2 == "29-18"
	replace subnatid2 = "29-19 - Mandya" if subnatid2 == "29-19"
	replace subnatid2 = "29-20 - Hassan" if subnatid2 == "29-20"
	replace subnatid2 = "29-21 - Dakshina Kannada" if subnatid2 == "29-21"
	replace subnatid2 = "29-22 - Kodagu" if subnatid2 == "29-22"
	replace subnatid2 = "29-23 - Mysore" if subnatid2 == "29-23"
	replace subnatid2 = "29-24 - Chamarajanagar" if subnatid2 == "29-24"
	replace subnatid2 = "29-25 - Gulbarga" if subnatid2 == "29-25"
	replace subnatid2 = "29-26 - Yadgir" if subnatid2 == "29-26"
	replace subnatid2 = "29-27 - Kolar" if subnatid2 == "29-27"
	replace subnatid2 = "29-28 - Chikkaballapura" if subnatid2 == "29-28"
	replace subnatid2 = "29-29 - Bangalore (Rural)" if subnatid2 == "29-29"
	replace subnatid2 = "29-30 - Ramanagara" if subnatid2 == "29-30"
	replace subnatid2 = "30-01 - North Goa" if subnatid2 == "30-01"
	replace subnatid2 = "30-02 - South Goa" if subnatid2 == "30-02"
	replace subnatid2 = "31-01 - Lakshadweep" if subnatid2 == "31-01"
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
	replace subnatid2 = "33-01 - Thiruvallur" if subnatid2 == "33-01"
	replace subnatid2 = "33-02 - Chennai" if subnatid2 == "33-02"
	replace subnatid2 = "33-03 - Kancheepuram" if subnatid2 == "33-03"
	replace subnatid2 = "33-04 - Vellore" if subnatid2 == "33-04"
	replace subnatid2 = "33-05 - Tiruvannamalai" if subnatid2 == "33-05"
	replace subnatid2 = "33-06 - Viluppuram" if subnatid2 == "33-06"
	replace subnatid2 = "33-07 - Salem" if subnatid2 == "33-07"
	replace subnatid2 = "33-08 - Namakkal" if subnatid2 == "33-08"
	replace subnatid2 = "33-09 - Erode" if subnatid2 == "33-09"
	replace subnatid2 = "33-10 - The Nilgiris" if subnatid2 == "33-10"
	replace subnatid2 = "33-11 - Dindigul" if subnatid2 == "33-11"
	replace subnatid2 = "33-12 - Karur" if subnatid2 == "33-12"
	replace subnatid2 = "33-13 - Tiruchirappalli" if subnatid2 == "33-13"
	replace subnatid2 = "33-14 - Perambalur" if subnatid2 == "33-14"
	replace subnatid2 = "33-15 - Ariyalur" if subnatid2 == "33-15"
	replace subnatid2 = "33-16 - Cuddalore" if subnatid2 == "33-16"
	replace subnatid2 = "33-17 - Nagapattinam" if subnatid2 == "33-17"
	replace subnatid2 = "33-18 - Thiruvarur" if subnatid2 == "33-18"
	replace subnatid2 = "33-19 - Thanjavur" if subnatid2 == "33-19"
	replace subnatid2 = "33-20 - Pudukkottai" if subnatid2 == "33-20"
	replace subnatid2 = "33-21 - Sivaganga" if subnatid2 == "33-21"
	replace subnatid2 = "33-22 - Madurai" if subnatid2 == "33-22"
	replace subnatid2 = "33-23 - Theni" if subnatid2 == "33-23"
	replace subnatid2 = "33-24 - Virudhunagar" if subnatid2 == "33-24"
	replace subnatid2 = "33-25 - Ramanathapuram" if subnatid2 == "33-25"
	replace subnatid2 = "33-26 - Thoothukkudi" if subnatid2 == "33-26"
	replace subnatid2 = "33-27 - Tirunelveli" if subnatid2 == "33-27"
	replace subnatid2 = "33-28 - Kanniyakumari" if subnatid2 == "33-28"
	replace subnatid2 = "33-29 - Dharmapuri" if subnatid2 == "33-29"
	replace subnatid2 = "33-30 - Krishnagiri" if subnatid2 == "33-30"
	replace subnatid2 = "33-31 - Coimbatore" if subnatid2 == "33-31"
	replace subnatid2 = "33-32 - Tiruppur" if subnatid2 == "33-32"
	replace subnatid2 = "34-01 - Yanam" if subnatid2 == "34-01"
	replace subnatid2 = "34-02 - Puducherry" if subnatid2 == "34-02"
	replace subnatid2 = "34-03 - Mahe" if subnatid2 == "34-03"
	replace subnatid2 = "34-04 - Karaikal" if subnatid2 == "34-04"
	replace subnatid2 = "35-01 - Nicobars" if subnatid2 == "35-01"
	replace subnatid2 = "35-02 - North & Middle Andaman" if subnatid2 == "35-02"
	replace subnatid2 = "35-03 - South Andaman" if subnatid2 == "35-03"
	replace subnatid2 = "36-01 - Adilabad" if subnatid2 == "36-01"
	replace subnatid2 = "36-02 - Komaram Bheem" if subnatid2 == "36-02"
	replace subnatid2 = "36-03 - Mancherial" if subnatid2 == "36-03"
	replace subnatid2 = "36-04 - Nirmal" if subnatid2 == "36-04"
	replace subnatid2 = "36-05 - Nizamabad" if subnatid2 == "36-05"
	replace subnatid2 = "36-06 - Jagtial" if subnatid2 == "36-06"
	replace subnatid2 = "36-07 - Peddapalli" if subnatid2 == "36-07"
	replace subnatid2 = "36-08 - Jayashankar" if subnatid2 == "36-08"
	replace subnatid2 = "36-09 - Bhadradri" if subnatid2 == "36-09"
	replace subnatid2 = "36-10 - Mahabubabad" if subnatid2 == "36-10"
	replace subnatid2 = "36-11 - Warangal Rural" if subnatid2 == "36-11"
	replace subnatid2 = "36-12 - Warangal Urban" if subnatid2 == "36-12"
	replace subnatid2 = "36-13 - Karimnagar" if subnatid2 == "36-13"
	replace subnatid2 = "36-14 - Rajanna" if subnatid2 == "36-14"
	replace subnatid2 = "36-15 - Kamareddy" if subnatid2 == "36-15"
	replace subnatid2 = "36-16 - Sangareddy" if subnatid2 == "36-16"
	replace subnatid2 = "36-17 - Medak" if subnatid2 == "36-17"
	replace subnatid2 = "36-18 - Siddipet" if subnatid2 == "36-18"
	replace subnatid2 = "36-19 - Jangaon" if subnatid2 == "36-19"
	replace subnatid2 = "36-20 - Yadadri" if subnatid2 == "36-20"
	replace subnatid2 = "36-21 - Medchal-Malkajgiri" if subnatid2 == "36-21"
	replace subnatid2 = "36-22 - Hyderabad" if subnatid2 == "36-22"
	replace subnatid2 = "36-23 - Rangareddy" if subnatid2 == "36-23"
	replace subnatid2 = "36-24 - Vikarabad" if subnatid2 == "36-24"
	replace subnatid2 = "36-25 - Mahbubnagar" if subnatid2 == "36-25"
	replace subnatid2 = "36-26 - Jogulamba" if subnatid2 == "36-26"
	replace subnatid2 = "36-27 - Wanaparthy" if subnatid2 == "36-27"
	replace subnatid2 = "36-28 - Nagarkurnool" if subnatid2 == "36-28"
	replace subnatid2 = "36-29 - Nalgonda" if subnatid2 == "36-29"
	replace subnatid2 = "36-30 - Suryapet" if subnatid2 == "36-30"
	replace subnatid2 = "36-31 - Khammam" if subnatid2 == "36-31"
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

	Last changes occurred in 2014 (creation of Telangana)
	EUS 2011 has old, PLFS 2017 has new codes
	PLFS 2017 has the subnatid1_prev info, here no changes.

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
==============================================================================================%%*/

{

*<_hsize_>
	gen hsize = hh_size
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	ren age original_age
	gen new_age = regexr(original_age, "[^0-9]", "")
	destring new_age, gen(age)
	label var age "Individual age"
*</_age_>



*<_male_>
	gen male = .
	replace male = 1 if sex == 1
	replace male = 0 if sex == 2
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>

	bys hhid visit: gen one=1 if rel_head == 1
	bys hhid visit: egen temp=count(one)
	tab temp
	*assert `r(r)' == 1
	drop temp one

	gen relationharm = rel_head
	recode relationharm (3 5 = 3) (7=4) (4 6 8 = 5) (9=6) (0=.)
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = rel_head
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	* Var marital exists in raw
	*gen byte marital = .
	recode marital (1 = 2) (2 = 1) (3 = 5)
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
* Caveat: based on comparisons with the EUE 2007-08 survey, the migration rate did not change, deviating from the conclusions out of the 2011 Census which found an increase in domestic migration. 
* Comparability issues lie on selection methodology: in 2020-21, households were selected based on the number of members with secondary education, while in 2007-08, HH were selected based on having an out-migrant, receiving a remittance, and remaining households having at least one other type of migrants for employment purpose. 

*<_migrated_mod_age_>
	gen migrated_mod_age = 0
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time = 99
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen migrated_binary = (ppe_d_lupr == 1)
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
* Unlike in previous years, not availbale for 2020!
	gen migrated_years = .
	label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban = .
	replace migrated_from_urban = 1 if inlist(loc_lupr, 2, 4, 6)
	replace migrated_from_urban = 0 if inlist(loc_lupr, 1, 3, 5)
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen migrated_from_cat = .
	replace migrated_from_cat = 2 if inlist(loc_lupr, 1, 2)
	replace migrated_from_cat = 3 if inlist(loc_lupr, 3, 4)
	replace migrated_from_cat = 4 if inlist(loc_lupr, 5, 6)
	replace migrated_from_cat = 5 if loc_lupr == 7
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen migrated_from_code = state_lupr
	
	label values migrated_from_code lblsubnatid1
		
	* Convert numeric into string
	decode migrated_from_code, gen(migrated_from_code_str)
	rename migrated_from_code migrated_from_code_num
	rename migrated_from_code_str migrated_from_code
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
	replace migrated_reason = 3 if inlist(reason_d_lupr, 1, 2, 3)
	replace migrated_reason = 1 if inlist(reason_d_lupr, 4, 6)
	replace migrated_reason = 2 if reason_d_lupr == 5
	replace migrated_reason = 4 if inlist(reason_d_lupr, 7, 8, 9)
	replace migrated_reason = 5 if inlist(reason_d_lupr, 10, 11, 12, 13, 19)


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

gen byte ed_mod_age = 0
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school=.
	replace school = 0 if inrange(current_attendance,1,20)
	replace school = 1 if inrange(current_attendance,21,43)
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen byte literacy = .
	replace literacy = 0 if general_ed == 1
	replace literacy = 1 if general_ed != 1 & !missing(general_ed)
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen byte educy =.
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7 =.
	replace educat7 = 1 if inrange(general_ed,1,4)
	replace educat7 = 2 if general_ed == 5
	replace educat7 = 3 if general_ed == 6
	replace educat7 = 4 if general_ed == 7
	replace educat7 = 5 if inrange(general_ed,8,10)
	replace educat7 = 6 if general_ed == 11
	replace educat7 = 7 if inrange(general_ed,12,13)
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
	gen educat_orig = general_ed
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
	gen educat_isced = .
	replace educat_isced = 100 if general_ed == 6
	replace educat_isced = 244 if general_ed == 7
	replace educat_isced = 244 if general_ed == 8
	replace educat_isced = 344 if general_ed == 10
	replace educat_isced = 353 if general_ed == 11
	replace educat_isced = 660 if general_ed == 12
	replace educat_isced = 760 if general_ed == 13
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
	replace vocational = 1 if inrange(any_voc_training,1,5)
	replace vocational = 0 if inrange(any_voc_training,6,6)
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
	replace vocational_length_l = 1 if duration_train == 1
	replace vocational_length_l = 3 if duration_train == 2
	replace vocational_length_l = 6 if duration_train == 3
	replace vocational_length_l = 12 if duration_train == 4
	replace vocational_length_l = 18 if duration_train == 5
	replace vocational_length_l = 24 if duration_train == 6
	label var vocational_length_l "Length of training in months, lower limit"
*</_vocational_length_l_>


*<_vocational_length_u_>
	gen vocational_length_u = .
	replace vocational_length_u = 3 if duration_train == 1
	replace vocational_length_u = 6 if duration_train == 2
	replace vocational_length_u = 12 if duration_train == 3
	replace vocational_length_u = 18 if duration_train == 4
	replace vocational_length_u = 24 if duration_train == 5
	replace vocational_length_u = .  if duration_train == 6
	label var vocational_length_u "Length of training in months, upper limit"
*</_vocational_length_u_>


*<_vocational_field_orig_>
	sdecode field_training, gen(vocational_field_orig)
	label var vocational_field_orig "Field of training - As in original data"
*</_vocational_field_orig_>

*<_vocational_financed_>
	gen vocational_financed = .
	replace vocational_financed = 2 if fund_train == 1
	replace vocational_financed = 4 if fund_train == 2
	replace vocational_financed = 5 if fund_train == 9
	label de lblvocational_financed 1 "Employer" 2 "Government" 3 "Mixed Employer/Government" 4 "Own funds" 5 "Other"
	label var vocational_financed "How training was financed"
*</_vocational_financed_>

}


/*%%=============================================================================================
	8: Labour
==============================================================================================%%*/


*<_minlaborage_>
	gen byte minlaborage =0
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
	gen byte lstatus = cws
	recode lstatus  (11/72 98 = 1) (81=2) (82 91/97=3) (99=.)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = .
	replace potential_lf = 0 if lstatus == 3
	replace potential_lf = 1 if cws == 82
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
	gen nlfreason = cws
	recode nlfreason (11/81 98=.) (91=1) (92 93=2) (94=3) (95=4) (82 96 97 98=5)
	replace nlfreason = . if lstatus != 3 | (age < minlaborage & age != .)
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte empstat = cws
	recode empstat (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72 98 =1) (81/97 99=.)
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
	gen industry_orig = cws_nic
	replace industry_orig = . if lstatus != 1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	gen industrycat_isic = industry_orig
	tostring(industrycat_isic), replace format("%02.0f")
	replace industrycat_isic = "" if industrycat_isic == "."
	replace industrycat_isic = industrycat_isic + "00" if !missing(industrycat_isic)
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen red_indus = industry_orig
	gen byte industrycat10 = .

	replace industrycat10 = 1 if inrange(red_indus,1,3)
	replace industrycat10 = 2 if inrange(red_indus,5,9)
	replace industrycat10 = 3 if inrange(red_indus,10,33)
	replace industrycat10 = 4 if inrange(red_indus,35,39)
	replace industrycat10 = 5 if inrange(red_indus,41,43)
	replace industrycat10 = 6 if inrange(red_indus,45,47) | inrange(red_indus,55,56)
	replace industrycat10 = 7 if inrange(red_indus,49,53) | inrange(red_indus,58,63)
	replace industrycat10 = 8 if inrange(red_indus,64,82)
	replace industrycat10 = 9 if inrange(red_indus,84,84)
	replace industrycat10 = 10 if inrange(red_indus,85,99)

	replace industrycat10=. if lstatus != 1 | (age < minlaborage & age != .)
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
	drop red_indus
*</_industrycat10_>


*<_industrycat4_>
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
	gen occup_orig = cws_noc
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	gen nco_04 = occup_orig
	gen x_indic = regexm(nco_04, "x|X|y|y")
	replace nco_04 = "099" if x_indic == 1
	replace nco_04 = "0" + nco_04 if length(nco_04) == 2
	replace nco_04 = "00" + nco_04 if length(nco_04) == 1

	merge m:1 nco_04 using "`path_in_stata'/India_nco_04_to_isco_88.dta"

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
	gen occup = substr(occup_isco, 1,1)
	destring occup, replace
	replace occup = 99 if occup == 0
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>



*<_occup_skill_>
	gen occup_skill = .
	replace occup_skill = 3 if inrange(occup, 1, 3)
	replace occup_skill = 2 if inrange(occup, 4, 8)
	replace occup_skill = 1 if occup == 9
	label define lbl_occup_skill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lbl_occup_skill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_wage_no_compen_>
/* <_wage_no_compen_note>

	Data is different for different status codes. One for
	codes 41, 42, 51, another for 31, 71, 72, a last for codes
	11, 12, 21, 61, 62. The first group has daily earnings
	which need to be added, the others have for calendar
	month and past 30 days.

	It is the only wage information for 7 days.
</_wage_no_compen_note> */

	egen help_1 = rowtotal(wage_act_1_day_7 wage_act_1_day_6 wage_act_1_day_5 wage_act_1_day_4 wage_act_1_day_3 wage_act_1_day_2 wage_act_1_day_1)

	gen double wage_no_compen = .
	replace wage_no_compen = help_1 if inlist(cws,41,42,51)
	replace wage_no_compen = earnings_salaried if inlist(cws,31,71,72)
	replace wage_no_compen = earnings_selfemp if inlist(cws,11,12,21,61,62)

	label var wage_no_compen "Last wage payment primary job 7 day recall"
	drop help_1
*</_wage_no_compen_>


*<_unitwage_>
	gen byte unitwage = .
	replace unitwage = 2 if inlist(cws,41,42,51)
	replace unitwage = 5 if inlist(cws,31,71,72)
	replace unitwage = 5 if inlist(cws,11,12,21,61,62)

	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	egen help_1 = rowtotal(hours_act_1_day_7 hours_act_1_day_6 hours_act_1_day_5 hours_act_1_day_4 hours_act_1_day_3 hours_act_1_day_2 hours_act_1_day_1)

	gen whours = .
	replace whours = help_1 if lstatus == 1 & help_1 > 0
	label var whours "Hours of work in last week primary job 7 day recall"
	drop help_1
*</_whours_>


*<_wmonths_>
	gen wmonths = .
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
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
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u= .
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


*----------8.6: 12 month reference overall------------------------------*

{

*<_lstatus_year_>
/* <_lstatus_year_note>

	For a person to be employed use the concept of usual economic activity, that is principal
	activity and add secondary if the principal is not in employment byt secondary is.
	So a full time student working on the side is still in the labor force in this 12 month sense

	There is no code 98 for 12 months.

</_lstatus_year_note> */
	gen primary_help = p_status_code
	recode primary_help  11/72=1 81 82=2 91/98=3 99=.
	gen secondary_help = s_status_code
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
	replace underemployment_year = . if age < minlaborage & age != .
	replace underemployment_year = . if lstatus_year == 1
	label var underemployment_year "Underemployment status"
	la de lblunderemployment_year 0 "No" 1 "Yes"
	label values underemployment_year lblunderemployment_year
*</_underemployment_year_>


*<_nlfreason_year_>
	gen nlfreason_year = p_status_code
	recode nlfreason_year 11/82=. 91=1 92 93=2 94=3 95=4 96/99=5
	replace nlfreason_year = . if lstatus_year != 3 | (age < minlaborage & age != .)
	label var nlfreason_year "Reason not in the labor force - 12 month recall"
	la de lblnlfreason_year 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason_year lblnlfreason_year
*</_nlfreason_year_>


*<_unempldur_l_year_>
	gen byte unempldur_l_year=.
	replace unempldur_l_year = 0 if unem_dur == 1
	replace unempldur_l_year = 7 if unem_dur == 2
	replace unempldur_l_year = 13 if unem_dur == 3
	replace unempldur_l_year = 25 if unem_dur == 4
	replace unempldur_l_year = 37 if unem_dur == 5

	label var unempldur_l_year "Unemployment duration (months) lower bracket"
*</_unempldur_l_year_>


*<_unempldur_u_year_>
	gen byte unempldur_u_year=.
	replace unempldur_u_year = 6 if unem_dur == 1
	replace unempldur_u_year = 12 if unem_dur == 2
	replace unempldur_u_year = 24 if unem_dur == 3
	replace unempldur_u_year = 36 if unem_dur == 4
	replace unempldur_u_year = . if unem_dur == 5

	label var unempldur_u_year "Unemployment duration (months) upper bracket"
*</_unempldur_u_year_>

}

*----------8.7: 12 month reference main job------------------------------*

{

*<_empstat_year_>
	gen empstat_year= p_status_code
	recode empstat_year (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72=1) (81/99=.)
	gen empstat_y2 = s_status_code
	recode empstat_y2 (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72=1) (81/99=.)

	replace empstat_year = empstat_y2 if adders == 1

	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status", replace
	label values empstat_year lblempstat_year
	drop empstat_y2
*</_empstat_year_>


*<_ocusec_year_>
	gen help_1 = p_ent_type_code
	replace help_1 = s_ent_type_code if lstatus_year == 1 & missing(help_1)

	gen byte ocusec_year = .
	replace ocusec_year=1 if help_1==5
	replace ocusec_year=2 if inlist(help_1,1,2,3,4,8,10,11,12)
	replace ocusec_year=3 if inlist(help_1,6,7)
	replace ocusec_year=. if help_1==19
	label var ocusec_year "Sector of activity primary job 12 month recall"
	la de lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_year lblocusec_year
	drop help_1
*</_ocusec_year_>


*<_industry_orig_year_>
	gen help_1 = p_industry_code
	replace help_1 = s_industry_nic_code if lstatus_year == 1 & missing(help_1)
	gen industry_orig_year = help_1
	label var industry_orig_year "Original industry record main job 12 month recall"
	drop help_1
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	gen industrycat_isic_year = industry_orig_year
	replace industrycat_isic_year = substr(industrycat_isic_year,1,4)
	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>

*<_industrycat10_year_>
	gen red_indus =substr(industrycat_isic_year,1,2)
	destring red_indus, replace

	gen industrycat10_year=.
	replace industrycat10_year = 1 if inrange(red_indus,1,3)
	replace industrycat10_year = 2 if inrange(red_indus,5,9)
	replace industrycat10_year = 3 if inrange(red_indus,10,33)
	replace industrycat10_year = 4 if inrange(red_indus,35,39)
	replace industrycat10_year = 5 if inrange(red_indus,41,43)
	replace industrycat10_year = 6 if inrange(red_indus,45,47) | inrange(red_indus,55,56)
	replace industrycat10_year = 7 if inrange(red_indus,49,53) | inrange(red_indus,58,63)
	replace industrycat10_year = 8 if inrange(red_indus,64,82)
	replace industrycat10_year = 9 if inrange(red_indus,84,84)
	replace industrycat10_year = 10 if inrange(red_indus,85,99)
	replace industrycat10_year= . if lstatus_year != 1 | (age < minlaborage & age != .)
	label var industrycat10_year "1 digit industry classification, primary job 12 month recall"
	la de lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_year lblindustrycat10_year
	drop red_indus
*</_industrycat10_year_>


*<_industrycat4_year_>
	gen byte industrycat4_year=industrycat10_year
	recode industrycat4_year (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_year "Broad Economic Activities classification, primary job 12 month recall"
	la de lblindustrycat4_year 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4_year lblindustrycat4_year
*</_industrycat4_year_>


*<_occup_orig_year_>
	gen help_1 = p_occup_code
	replace help_1 = s_occupation_nco_code if lstatus_year == 1 & missing(help_1)

	gen occup_orig_year = help_1
	label var occup_orig_year "Original occupation record primary job 12 month recall"
	drop help_1
*</_occup_orig_year_>


*<_occup_isco_year_>
	gen nco_04 = occup_orig_year
	merge m:1 nco_04 using "`path_in_stata'/India_nco_04_to_isco_88.dta", nogen keep(match master)

	* Make isco four digit string
	tostring isco_88, replace
	replace isco_88 = "" if isco_88 == "."
	replace isco_88 = isco_88 + "0" if !missing(isco_88)

	gen occup_isco_year = isco_88
	replace occup_isco_year = "" if lstatus_year != 1
	label var occup_isco_year "ISCO code of primary job 12 month recall"
	drop nco_04 isco_88
*</_occup_isco_year_>


*<_occup_year_>
	gen occup_year = substr(occup_isco_year, 1,1)
	destring occup_year, replace
	
	label var occup_year "1 digit occupational classification, secondary job 12 month recall"
	la de lbloccup_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_year lbloccup_year
*</_occup_year_>


*<_occup_skill_year_>
	gen occup_skill_year = .
	replace occup_skill_year = 3 if inrange(occup_year, 1, 3)
	replace occup_skill_year = 2 if inrange(occup_year, 4, 8)
	replace occup_skill_year = 1 if occup == 9
	label define lbl_occup_skill_year 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_year lbl_occup_skill_year
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
	gen help_1 = p_type_contract
	replace help_1 = s_type_contract if lstatus_year == 1 & missing(help_1)

	gen byte contract_year = .
	replace contract_year = 0 if help_1 == 1
	replace contract_year = 1 if inrange(help_1,2,4)
	label var contract_year "Employment has contract primary job 12 month recall"
	la de lblcontract_year 0 "Without contract" 1 "With contract"
	label values contract_year lblcontract_year
	drop help_1
*</_contract_year_>


*<_healthins_year_>
	gen byte healthins_year = .
	label var healthins_year "Employment has health insurance primary job 12 month recall"
	la de lblhealthins_year 0 "Without health insurance" 1 "With health insurance"
	label values healthins_year lblhealthins_year
*</_healthins_year_>


*<_socialsec_year_>
	gen help_1 = p_social_sec
	replace help_1 = s_social_sec if lstatus_year == 1 & missing(help_1)

	gen byte socialsec_year = .
	replace socialsec_year = 1 if inrange(help_1,1,7)
	replace socialsec_year = 0 if help_1 == 8
	label var socialsec_year "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec_year 1 "With social security" 0 "Without social secturity"
	label values socialsec_year lblsocialsec_year
	drop help_1
*</_socialsec_year_>


*<_union_year_>
	gen byte union_year = .
	label var union_year "Union membership at primary job 12 month recall"
	la de lblunion_year 0 "Not union member" 1 "Union member"
	label values union_year lblunion_year
*</_union_year_>


*<_firmsize_l_year_>
	gen help_1 = p_no_workrs_ent
	replace help_1 = s_no_workrs_ent if lstatus_year == 1 & missing(help_1)

	gen byte firmsize_l_year = .
	replace firmsize_l_year = 1 if help_1 == 1
	replace firmsize_l_year = 6 if help_1 == 2
	replace firmsize_l_year = 10 if help_1 == 3
	replace firmsize_l_year = 20 if help_1 == 4
	label var firmsize_l_year "Firm size (lower bracket) primary job 12 month recall"
	drop help_1
*</_firmsize_l_year_>


*<_firmsize_u_year_>
	gen help_1 = p_no_workrs_ent
	replace help_1 = s_no_workrs_ent if lstatus_year == 1 & missing(help_1)

	gen byte firmsize_u_year = .
	replace firmsize_u_year = 5 if help_1 == 1
	replace firmsize_u_year = 9 if help_1 == 2
	replace firmsize_u_year = 19 if help_1 == 3
	replace firmsize_u_year = . if help_1 == 4

	label var firmsize_u_year "Firm size (upper bracket) primary job 12 month recall"
	drop help_1
*</_firmsize_u_year_>

}


*----------8.8: 12 month reference secondary job------------------------------*

{

*<_empstat_2_year_>
	gen empstat_2_year = s_status_code
	recode empstat_2_year (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72=1) (81/99=.)
	replace empstat_2_year = . if lstatus_year != 1
	replace empstat_2_year = . if seconds != 1
	label var empstat_2_year "Employment status during past week secondary job 12 month recall"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2_year lblempstat_2_year
*</_empstat_2_year_>


*<_ocusec_2_year_>
	gen byte ocusec_2_year = .
	replace ocusec_2_year=1 if s_ent_type_code ==5
	replace ocusec_2_year=2 if inlist(s_ent_type_code,1,2,3,4,8,10,11,12)
	replace ocusec_2_year=3 if inlist(s_ent_type_code ,6,7)
	replace ocusec_2_year=. if s_ent_type_code==19
	replace ocusec_2_year = . if missing(empstat_2_year)
	label var ocusec_2_year "Sector of activity secondary job 12 month recall"
	la de lblocusec_2_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_2_year lblocusec_2_year
*</_ocusec_2_year_>


*<_industry_orig_2_year_>
	gen industry_orig_2_year = s_industry_nic_code if seconds == 1
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


	gen industrycat10_2_year=.
	replace industrycat10_2_year = 1 if inrange(red_indus,1,3)
	replace industrycat10_2_year = 2 if inrange(red_indus,5,9)
	replace industrycat10_2_year = 3 if inrange(red_indus,10,33)
	replace industrycat10_2_year = 4 if inrange(red_indus,35,39)
	replace industrycat10_2_year = 5 if inrange(red_indus,41,43)
	replace industrycat10_2_year = 6 if inrange(red_indus,45,47) | inrange(red_indus,55,56)
	replace industrycat10_2_year = 7 if inrange(red_indus,49,53) | inrange(red_indus,58,63)
	replace industrycat10_2_year = 8 if inrange(red_indus,64,82)
	replace industrycat10_2_year = 9 if inrange(red_indus,84,84)
	replace industrycat10_2_year = 10 if inrange(red_indus,85,99)
	replace industrycat10_2_year= . if lstatus_year != 1 | (age < minlaborage & age != .)
	replace industrycat10_2_year= . if missing(empstat_2_year)
	label var industrycat10_2_year "1 digit industry classification, secondary job 12 month recall"
	la de lblindustrycat10_2_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_2_year lblindustrycat10_2_year
	drop red_indus
*</_industrycat10_2_year_>


*<_industrycat4_2_year_>
	gen byte industrycat4_2_year=industrycat10_2_year
	recode industrycat4_2_year (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_2_year "Broad Economic Activities classification, secondary job 12 month recall"
	label values industrycat4_2_year lblindustrycat4_year
*</_industrycat4_2_year_>


*<_occup_orig_2_year_>
	gen occup_orig_2_year = s_occupation_nco_code if seconds == 1
	replace occup_orig_2_year = "" if missing(empstat_2_year)
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
	gen nco_04 = occup_orig_2_year
	merge m:1 nco_04 using "`path_in_stata'/India_nco_04_to_isco_88.dta", nogen keep(match master)

	* Make isco four digit string
	tostring isco_88, replace
	replace isco_88 = "" if isco_88 == "."
	replace isco_88 = isco_88 + "0" if !missing(isco_88)

	gen occup_isco_2_year = isco_88
	replace occup_isco_2_year = "" if lstatus_year != 1
	label var occup_isco_2_year "ISCO code of secondary job 12 month recall"
	drop nco_04 isco_88
*</_occup_isco_2_year_>


*<_occup_2_year_>
	gen occup_2_year = substr(occup_orig_2_year, 1,1)
	destring occup_2_year, replace
	
	label var occup_2_year "1 digit occupational classification, secondary job 12 month recall"
	la de lbloccup_2_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2_year lbloccup_2_year
*</_occup_2_year_>


*<_occup_skill_2_year_>
	gen occup_skill_2_year = .
	replace occup_skill_2_year = 3 if inrange(occup_2_year, 1, 3)
	replace occup_skill_2_year = 2 if inrange(occup_2_year, 4, 8)
	replace occup_skill_2_year = 1 if occup_2_year == 9
	label define lbl_occup_skill_2_year 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_2_year lbl_occup_skill_2_year
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
	gen help_1 = .
	replace help_1 = s_no_workrs_ent if !missing(empstat_2_year)

	gen byte firmsize_l_2_year = .
	replace firmsize_l_2_year = 1 if help_1 == 1
	replace firmsize_l_2_year = 6 if help_1 == 2
	replace firmsize_l_2_year = 10 if help_1 == 3
	replace firmsize_l_2_year = 20 if help_1 == 4

	label var firmsize_l_2_year "Firm size (lower bracket) secondary job 12 month recall"
	drop help_1
*</_firmsize_l_2_year_>


*<_firmsize_u_2_year_>
	gen help_1 = .
	replace help_1 = s_no_workrs_ent if !missing(empstat_2_year)

	gen byte firmsize_u_2_year = .
	replace firmsize_u_2_year = 5 if help_1 == 1
	replace firmsize_u_2_year = 9 if help_1 == 2
	replace firmsize_u_2_year = 19 if help_1 == 3
	replace firmsize_u_2_year = . if help_1 == 4

	label var firmsize_u_2_year "Firm size (upper bracket) secondary job 12 month recall"
	drop help_1
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

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

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
