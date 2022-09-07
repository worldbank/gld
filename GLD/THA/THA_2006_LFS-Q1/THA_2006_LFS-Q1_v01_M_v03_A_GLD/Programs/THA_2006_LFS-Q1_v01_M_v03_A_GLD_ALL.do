
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------
<_Program name_>				THA_2006_LFS_v01_M_v01_A_Q1.do </_Program name_>
<_Application_>					Stata 17 <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2022-01-08 </_Date created_>
-------------------------------------------------------------------------
<_Country_>						Thailand (THA) </_Country_>
<_Survey Title_>				Labor Force Survey 2006 Q1 </_Survey Title_>
<_Survey Year_>					2006 </_Survey Year_>
<_Study ID_>					N.A. </_Study ID_>
<_Data collection from_>		January 2006 </_Data collection from_>
<_Data collection to_>			March 2006 </_Data collection to_>
<_Source of dataset_> 			NSO </_Source of dataset_>
<_Sample size (HH)_> 			63,839 </_Sample size (HH)_>
<_Sample size (IND)_> 			210,929 </_Sample size (IND)_>
<_Sampling method_> 			

A stratified two-stage sampling was adopted to the survey: Bangkok Metroplois and the  provinces constituted the strata. Each stratum (excluding Bangkok Metropolis) was divided into two parts according to the type of local administration, namely municipal areas and non-municipal areas. The primary and secondary sampling units were enumeration areas (EAs) for municipal areas and non-municipal areas and private households and persons in the collective households respectively.


 </_Sampling method_>
<_Geographic coverage_> 
		
Data is significant at the national level

<_Currency_> 					Thailand Baht </_Currency_>
-----------------------------------------------------------------------
<_ICLS Version_>				ICLS 13 </_ICLS Version_>
<_ISCED Version_>				ISCED 2011 </_ISCED Version_>
<_ISCO Version_>				ISCO 1988 </_ISCO Version_>
<_OCCUP National_>				Based on ISCO 1988 </_OCCUP National_>
<_ISIC Version_>				ISIC version 3 </_ISIC Version_>
<_INDUS National_>				ISIC version 3 </_INDUS National_>
-----------------------------------------------------------------------
<_Version Control_>
* Date: [2022-01-08] - Prepared initial code
* Date: [2022-06-15] - Added codes that harmonize data for specific variables, including school attendance, ISCO and ISIC codes, etc...
* Date: [2022-07-11] - Updated ISCED version
* Date: [2022-08-31] - Correct industrycat10 - ISIC conversion, ensure that code 0 is set to missing for relationharm, update ICLS

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

global path_in "Z:\GLD-Harmonization\510859_AS\THA\THA_2006_LFS-Q1\THA_2006_LFS-Q1_v01_M\Data\Stata"

global path_output "Z:\GLD-Harmonization\510859_AS\THA\THA_2006_LFS-Q1\THA_2006_LFS-Q1_v01_M_v03_A_GLD\Data\Harmonized"

*----------1.3: Database assembly------------------------------*

* All steps necessary to merge datasets (if several) to have all elements needed to produce
* harmonized output in a single file

	use "$path_in\lfs491.dta", clear
/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

* First: drop the duplicates
duplicates drop
*<_countrycode_>
	gen str4 countrycode = "THA"
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
	drop year
	gen int year = 2006
	label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen vermast = "V01"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen veralt = "V03"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>

*<_harmonization_>
	gen harmonization = "GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	gen int_year= 2006
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen  int_month = month
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
/* <_hhid_note>

	In this survey, the HHID can be determined based on the following information:
	
	- reg (Region)
	- cwd (Province)
	- area (Municipal/sanitary/nonmunicipal)
	- tmb (tambon or sub-district)
	- blkv (Block village)
	- hh_no  (Household No)
	
</_hhid_note> */

	* First, convert to string
	
	foreach var of varlist reg cwd area blkv tmb hh_no line_no {
	    tostring `var', gen(`var'_str)
	
	}
	
	* Make sure elements are consistent in length
	replace cwd_str = "0" + cwd_str if length(cwd_str) == 1
	replace tmb_str = "0" + tmb_str if length(tmb_str) == 1

	
	replace blkv_str = "0" + blkv_str if length(blkv_str)==2
	replace blkv_str = "00" + blkv_str if length(blkv_str) == 1
	
	replace line_no_str =  "0" + line_no_str if length(line_no_str)==1
	replace hh_no_str =  "0" + hh_no_str if length(hh_no_str)==1

	egen hhid = concat(reg_str cwd_str tmb_str area_str blkv_str hh_no_str)
	label var hhid "Household ID"
	
*</_hhid_>


*<_pid_>
	
	egen pid = concat(hhid line_no_str)
	label var pid "Individual ID"
	
	isid pid

*</_pid_>


*<_weight_>
	* Note rather than this is an individual sampling weight rather than HH
	
	gen weight = wt
	label var weight "Household sampling weight"
	
*</_weight_>


*<_psu_>

	egen psu = concat(reg_str cwd_str area_str blkv_str)
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = hhid
	label var ssu "Secondary sampling units"
*</_ssu_>



*<_strata_>
	gen strata = cwd_str
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

	/*<_urban_note_>
	
	The data does not classify by urban/rural. Instead, classifications were made by municipal/non-municipal/sanitary. Whether these can be mapped to urban/rural have yet to be determined. TO be safe, leave this variable missing
	
	</_urban_note> */
	gen byte urban = area
	recode urban (2 = 0)
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
/* <_subnatid1_note>

	Labels are to be defined as # - Name like 1 "1 - Alaska" 2 "2 - Arkansas"
	
	</_subnatid1_note>
	
</_subnatid1> */
	gen byte subnatid1 = reg
	
	label define lblsubnatid1 1 "1 - Bangkok Metropolis" 2 "2 - Central" 3 "3 - North"  4 "4 - Northeast"  5 "5 - South"

	label values subnatid1 lblsubnatid1
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	
	gen subnatid2 = cwd

label de lblsubnatid2 10 "10 - Bangkok Metropolis" 11 "11 - Samut Prakan" ///
		12 "12 - Nonthaburi"	13 "13 - Pathum Thani" 14 "14 - Phra Nakhon Si Ayutthaya"  ///
		15 "15 - Ang Thong" 16 "16 - Lop Buri" 17 "17 - Sing Buri" 18 "18 - Chai Nat" ///
		19 "19 - Saraburi" 20 "20 - Chon Buri"	21 "21 - Rayong"	22 "22 - Chanthaburi" /// 
		23 "23 - Trat" 24 "24 - Chachoengsao" 25 "25 - Prachin Buri" ///
		26 "26 - Nakhon Nayok" 27 "27 - Sa Kaeo" 30 "30 - Nakhon Ratchasima" ///
		31 "31 - Buri Ram" 32 "32 - Surin" 33 "33 - Si Sa Ket" 34 "34 - Ubon Ratchathani" ///
		35 "35 - Yasothon" 36 "36 - Chaiyaphum" 37 "37 - Am Nat Charoen" ///
		38 "38 - Bueng Kan" 39 "39 - Nong Bua Lam Phu" 40 "40 - Khon Kaen" ///
		41 "41 - Udon Thani" 42 "42 - Loei" 43 "43 - Nong Khai" 44 "44 - Maha Sarakham" ///
		45 "45 - Roi Et" 46 "46 - Kalasin" 47 "47 - Sakon Nakhon"	48 "48 - Nakhon Phanom"  ///
		49 "49 - Mukdahan" 50 "50 - Chiang Mai"	51 "51 - Lamphun" 52 "52 - Lampang" 53 "53 - Uttaradit"  ///
		54 "54 - Phrae"	55 "55 - Nan" 56 "56 - Phayao" 57 "57 - Chiang Rai" 58 "58 - Mae Hong Son" ///
		60 "60 - Nakhon Sawan" 61 "61 - Uthai Thani"  62 "62 - Kamphaeng Phet" 63 "63 - Tak" 64 "64 - Sukhothai" /// 
		65 "65 - Phitsanulok"	66 "66 - Phichit" 67 "67 - Phetchabun" 70 "70 - Ratchaburi" ///
		71 "71 - Kanchanaburi" 72 "72 - Suphan Buri" 73 "73 - Nakhon Pathom" ///
		74 "74 - Samut Sakhon" 75 "75 - Samut Songkhram" 76 "76 - Phetchaburi"	///
		77 "77 - Prachuap Khiri Khan" 80 "80 - Nakhon Si Thammarat" 81 "81 - Krabi" ///
		82 "82 - Phangnga" 83 "83 - Phuket" 84 "84 - Surat Thani" ///
		85 "85 - Ranong" 86 "86 - Chumphon" 90 "90 - Songkhla" 91 "91 - Satun" 92 "92 - Trang" ///
		93 "93 - Phatthalung" 94 "94 - Pattani" 95 "95 - Yala" 96 "96 - Narathiwat"
			
		
	label values subnatid2 lblsubnatid2
	label var subnatid2 "Subnational ID at Second Administrative Level"
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

	gen subnatid1_prev = subnatid1
	recode subnatid1_prev (3 = 1) (4 = 2) (5 = 3) (2 = 4) (1 = 5)
	label de lblsubnatid1_prev 1 "1 - North" 2 "2 - Northeast" 3 "3 - South" 4 "4 - Central" 5 "5 - Bangkok Metropolis"
	label values subnatid1_prev lblsubnatid1_prev

	label var subnatid1_prev "Classification used for subnatid1 from previous survey"
*</_subnatid1_prev_>

*<_subnatid2_prev_>
	merge m:1 subnatid2 using "$path_in\changwad_subnatid2_prev.dta", keep(master match)
	label var subnatid2_prev "Classification used for subnatid2 from previous survey"
	
	label de lblsubnatid2_prev  101 "1 - Mae Hong Son" 102 "2 - Chiang Mai"	103 "3 - Phayao" ///
	104 "4 - Chiang Rai" 105 "5 - Nan" 106 "6 - Lamphun" 107 "7 - Lampang" 108 "8 - Phrae" 109 "9 - Tak" ///
	110 "10 - Sukhothai" 111 "11 - Uttaradit" 112 "12 - Kamphaeng Phet" 113 "13 - Phichit" 114 "14 - Uthai Thani" ///
	115 "15 - Nakhon Sawan" 116 "16 - Phitsanulok" 117 "17 - Phetchabun" ///
	201 "1 - Loei"	202 "2 - Udon Thani" 203 "3 - Nong Khai" 204 "4 - Sakon Nakhon" ///
	205 "5 - Nakhon Phanom" 206 "6 - Kalasin" 207 "7 - Roi Et" 208 "8 - Maha Sarakham"  ///
	209 "9 - Khon Daen" 210 "10 - Chaiyaphum" 211 "11 - Nakhon Ratchasima" 212 "12 - Buri Ram" ///
	213 "13 - Surin" 214 "14 - Si Sa Ket" 215 "15 - Ubon Ratchathani" 216 "16 - Yasothon" ///
	217 "17 - Mukdahan" 274 "74 - Nong Bua Lam Phu" 275 "75 - Am Nat Charoen" 301 "1 - Chumphon" 302 "2 - Ranong" 303 "3 - Surat Thani" ///
	304 "4 - Phangnga" 305 "5 - Phuket" 306 "6 - Krabi" 307 "7 - Nakhon Si Thammarat" ///
	308 "8 - Phatthalung" 309 "9 - Songkhla" 310 "10 - Trang" 311 "11 - Satun" ///
	312 "12 - Pattani" 313 "13 - Yala" 314 "14 - Narathiwat" 401 "1 - Kanchanaburi" ///
	402 "2 - Suphan Buri" 403 "3 - Ratchaburi" 404 "4 - Prachuap Khiri Khan" ///
	405 "5 - Phetchaburi" 406 "6 - Nakhon Pathom" 407 "7 - Samut Songkhram"	/// 
	408 "8 - Samut Sakhon" 409 "9 - Saraburi" 410 "10 - Lop Buri" ///
	411 "11 - Phranakhon Si Ayutthaya" 412 "12 - Ang Thong" 413 "13 - Sing Buri" ///
	414 "14 - Chai Nat" 415 "15 - Trat" 416 "16 - Chanthaburi" 417 "17 - Rayong" 418 "18 - Chon Buri" ///
	419 "19 - Prachin Buri" 420 "20 - Nakhon Nayok" 421 "21 - Chachoengsao" ///
	422 "22 - Nonthaburi" 423 "23 - Pathum Thani" 424 "24 - Sumut Prakan" 476 "76 - Sa Kaeo" ///
	501 "1 - Bangkok Metropolis"

	label values subnatid2_prev lblsubnatid2_prev

* convert codes to string
	sdecode subnatid1, replace
	sdecode subnatid1_prev, replace
	sdecode subnatid2, replace
	sdecode subnatid2_prev, replace

*</_subnatid2_prev_>


*<_subnatid3_prev_>
	gen subnatid3_prev = .
	label var subnatid3_prev "Classification used for subnatid3 from previous survey"
*</_subnatid3_prev_>

/*<_gaul_adm_code_notes>

Based on this reference (https://data.humdata.org/dataset/cod-ab-tha):

level 0 = country
level 1 = province
level 2 = district
level 3 = subdistrict/tambon

* But for the available datasets, the district (amphoe) and tambon are NA

Hence, leave adm2 and adm3 missing

</_gaul_adm_code_notes>*/

*<_gaul_adm1_code_>
	gen gaul_adm1_code = subnatid2
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
	
	* First check if MEMBERS has the same if we were to recreate HH size
	bys hhid: gen hsize = _N

	label var hsize "Household size"
*</_hsize_>


*<_age_>
	ren age age2
	gen age = age2
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = sex
	recode male (2=0)
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>

	* First check if there are instances where there are no or more than 1 HH head
	gen head = rela==1
	bys hhid: egen tot_head = sum(head)
	
	count if tot_head!=1
	
	gen neg_age = -(age)
	
	sort hhid sex neg_age listing
	by hhid: gen hhorder = _n
	replace hhorder = . if hhorder!=1
	
	replace rela = 1 if hhorder==1 & tot_head!=1
	replace rela = 5 if hhorder!=1 & rela ==1 & tot_head!=1
	
	drop tot_head head
	gen head = rela==1
	bys hhid: egen tot_head = sum(head)
	
	assert tot_head ==  1
	
	gen relationharm = rela
	recode relationharm (3 4 = 3) (7 = 4) (5 6 8= 5) (9 = 6) (0 = .)
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = rela
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen marital = mrstat
	recode marital (2 = 1) (1= 2) (5 = 4) (3 = 5) (6=.)
	* Code 6 = been married but do not know the status (left missing since <~0.1% of obs anyway)

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

	
	* Note: there are a few cases of individuals who reported that they do not know where they migrated from

		
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
</_ed_mod_age_note> */

gen byte ed_mod_age = 15
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school= study
	replace school = . 
	recode school (2=0)
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>

* There is no literacy variable in the dataset
	gen byte literacy = .
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen byte educy =.
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7 = re_ed
	recode educat7 (5 6 7  = 5) (8 9 10  = 6) (11 12 13 = 7)  (14 15 = .)
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
	gen educat_orig = re_ed
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>

capture confirm variable edcode

	if !_rc {
		gen re_ed = edcode
	}
	
	gen educat_isced = ""
	replace educat_isced = "0" if re_ed == 2 
	replace educat_isced = "1" if re_ed == 3 
	replace educat_isced = "2A" if re_ed == 4 
	replace educat_isced = "3A" if re_ed == 5 
	replace educat_isced = "3B" if re_ed == 6 
	replace educat_isced = "3A" if re_ed == 7 
	replace educat_isced = "3C" if inrange(re_ed, 8, 10)
	replace educat_isced = "5A" if inrange(re_ed, 11, 13)


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
	gen byte minlaborage = 15 
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
	gen byte lstatus = .
	replace lstatus = . if age < minlaborage
	replace lstatus = 1 if wklw == 1 | perjob == 1 | receive == 1
	replace lstatus = 2 if seeking == 1 | (seeking == 2 & available == 1)
	replace lstatus = 3 if (seeking == 3 & available == 2) | (seeking == 3 & available ==1) | (seeking == 2 & available == 2)
	
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>



*<_potential_lf_>
	gen byte potential_lf = .
	replace potential_lf = 0 if lstatus == 3
	replace potential_lf = 1 if (seeking == 3 & available == 1) | (seeking == 2 & available == 2)
	replace potential_lf = . if age < minlaborage & age != .	
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>


	gen byte underemployment = .
	replace underemployment = . if age < minlaborage & age != .
	replace underemployment = . if lstatus != 1
	replace underemployment = 1 if lstatus == 1 & add_hwk == 1
	replace underemployment = 0 if lstatus == 1 & add_hwk == 2
	
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason=.
	replace nlfreason = 1 if reunwk == 2
	replace nlfreason = 2 if reunwk == 1
	replace nlfreason = 3 if reunwk == 4 & age >= 60
	replace nlfreason = 4 if reunwk == 5
	replace nlfreason = 5 if reunwk == 3 | reunwk == 6 | reunwk == 7 | (reunwk== 4 & age<60 & !missing(age))
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>

*<_unempldur_l_>
	gen byte unempldur_l= 0 if dr_unem == 1
	replace unempldur_l = 1 if dr_unem == 2
	replace unempldur_l = 3 if dr_unem == 3
	replace unempldur_l = 6 if dr_unem == 4
	replace unempldur_l = 9 if dr_unem == 5
	replace unempldur_l = 11.9 if dr_unem == 6
	replace unempldur_l = . if dr_unem == 9 | lstatus!=2 
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u= 1 if dr_unem == 1
	replace unempldur_u = 2.9 if dr_unem == 2
	replace unempldur_u = 5.9 if dr_unem == 3
	replace unempldur_u = 8.9 if dr_unem == 4
	replace unempldur_u = 11.9 if dr_unem == 5
	replace unempldur_u = . if dr_unem == 6
	replace unempldur_u = . if dr_unem == 9 | lstatus!=2 	
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte empstat= .
	replace empstat = 1 if status == 4 | status == 5 | status == 6
	replace empstat = 2 if status == 3
	replace empstat = 3 if status == 1
	replace empstat = 4 if status == 2
	replace empstat = 5 if status == 7 | status == 8
	
	replace empstat =. if lstatus!=1
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec = .
	replace ocusec = 1 if status == 2
	replace ocusec = 2 if status == 1 | status == 3 | status == 4 | status == 5
	replace ocusec = 3 if status == 6
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>

*<_industry_orig_>

	gen industry_orig = indus
	tostring industry_orig, replace
	replace industry_orig = "0" + industry_orig if length(industry_orig) == 3
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	gen industrycat_isic = industry_orig
	
	* There are codes not in ISIC v3 -- set to missing
	replace industrycat_isic = "" if inlist(industrycat_isic, "1599", "3999", "5299", "9304", "9999")
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>



*<_industrycat10_>
	gen isic_1d = substr(industrycat_isic, 1, 1)
	gen isic_2d = substr(industrycat_isic, 1, 2)
	
	destring isic_1d, replace
	destring isic_2d, replace
	
	gen byte industrycat10 = .
	replace industrycat10 = 1 if isic_1d == 0
	replace industrycat10 = 2 if inrange(isic_2d, 10, 14)
	replace industrycat10 = 3 if inrange(isic_2d, 15, 37)
	replace industrycat10 = 4 if inrange(isic_2d, 40, 41)
	replace industrycat10 = 5 if isic_2d == 45
	replace industrycat10 = 6 if isic_1d == 5
	replace industrycat10 = 7 if inrange(isic_2d, 60, 64)
	replace industrycat10 = 8 if inrange(isic_2d, 65, 74)
	replace industrycat10 = 9 if isic_2d == 75
	replace industrycat10 = 10 if inrange(isic_2d, 80, 99)
	
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
	tostring occup, gen(occup_orig)
	replace occup_orig = "" if lstatus!=1 
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	gen occup_isco = occup_orig
	replace occup_isco = "" if inlist(occup_isco, "1299", "2999", "3999", "9970")
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_skill_>

	gen occup_1d = substr(occup_isco, 1, 1)
	destring occup_1d, replace
	gen occup_skill = 1 if occup_1d == 9
	replace occup_skill = 2 if inrange(occup_1d, 4, 8)
	replace occup_skill = 3 if inrange(occup_1d, 1, 3)
	
	la de lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lblskill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>

*<_occup_>
	drop occup
	gen occup = substr(occup_isco, 1, 1)
	destring occup, replace
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>

*<_wage_no_compen_>
	gen double wage_no_compen =  baht
	replace baht = . if baht == 99999
	replace wage_no_compen = . if lstatus!=1
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
	gen byte unitwage = .
	replace unitwage = 1 if wage_type == 2
	replace unitwage = 2 if wage_type == 3
	replace unitwage = 5 if wage_type == 4
	replace unitwage = 6 if wage_type == 5
	replace unitwage = 9 if wage_type == 1
	replace unitwage = . if wage_type == 6
	replace unitwage = . if lstatus!=1 
	replace unitwage = . if missing(wage_no_compen)
	
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>

*<_whours_>
	gen whours = hour_po
	replace whours = . if hour_po == 0
	replace whours = . if lstatus!=1
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


*<_healthins_>uni
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
	replace firmsize_l = 1 if size== 1
	replace firmsize_l = 5 if size == 2
	replace firmsize_l = 10 if size == 3
	replace firmsize_l = 20 if size == 4
	replace firmsize_l = 50 if size == 5
	replace firmsize_l = 100 if size == 6
	replace firmsize_l = 200 if size == 7
	replace firmsize_l = . if size == 9

	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u = .
	replace firmsize_u = 4 if size == 1
	replace firmsize_u = 9 if size == 2
	replace firmsize_u = 19 if size == 3
	replace firmsize_u = 49 if size == 4
	replace firmsize_u = 99 if size == 5
	replace firmsize_u = 199 if size == 6
	replace firmsize_u = . if size == 7
	replace firmsize_u = . if size == 9	
	
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
	gen t_hours_total = total_hr
	replace t_hours_total = . if total_hr== 0 | (total_hr>140 & !missing(total_hr))
	replace t_hours_total = t_hours_total * 52
	
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
* Set missing values for unemployed with responses on occupation and industry questions
foreach var of varlist ocusec empstat industry_orig industrycat_isic industrycat10  industrycat4 occup_orig occup occup_isco wage_no_compen unitwage firmsize_l firmsize_u {
	cap confirm numeric variable `var'
	
	if _rc==0 {
		replace `var' = . if lstatus !=1
	}
	else {
		replace `var' = "" if lstatus !=1
	}
}
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

save "$path_output\THA_2006_LFS-Q1_v01_M_v03_A_GLD_ALL.dta", replace

*</_% SAVE_>
