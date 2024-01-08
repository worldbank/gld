/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				IND_2018_PLFS_V01_M_V02_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata 16 <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2021-11-30 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						India </_Country_>
<_Survey Title_>				Periodic Labour Force Survey </_Survey Title_>
<_Survey Year_>					2018 </_Survey Year_>
<_Study ID_>					DDI-IND-CSO-PLFS-2018-19 </_Study ID_>
<_Data collection from_>		07/2018 </_Data collection from_>
<_Data collection to_>			06/2019 </_Data collection to_>
<_Source of dataset_> 			https://www.mospi.gov.in/web/mospi/download-tables-data/-/reports/view/templateTwo/16201?q=TBDCAT </_Source of dataset_>
<_Sample size (HH)_> 			[#] </_Sample size (HH)_>
<_Sample size (IND)_> 			[#] </_Sample size (IND)_>
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

* Date: 2022-09-24 - Correct educat7, ocusec, change subnatid1 to string, improve subnatidsurvey

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

local path_in "Y:/GLD/IND/IND_2018_PLFS/IND_2018_PLFS_v01_M/Data/Stata"
local path_output "Y:/GLD/IND/IND_2018_PLFS/IND_2018_PLFS_v01_M_v02_A_GLD/Data/Harmonized"

*----------1.3: Database assembly------------------------------*

use "`path_in'\IND_2018_PLFS_raw_IND_Stata.dta", clear

gen str1 h_1 = string(sample_sg_b_no,"%01.0f")
gen str1 h_2 = string(ss_stratum,"%01.0f")
gen str2 h_3 = string(hh_num,"%02.0f")

egen str9 hh_key = concat(fsu h_1 h_2 h_3)
drop h_*

tempfile ind_file
save `ind_file'

use "`path_in'\IND_2018_PLFS_raw_HH_Stata.dta", clear

gen str1 h_1 = string(sample_sg_b_no,"%01.0f")
gen str1 h_2 = string(ss_stratum,"%01.0f")
gen str2 h_3 = string(hh_num,"%02.0f")

egen str9 hh_key = concat(fsu h_1 h_2 h_3)
drop h_*

merge 1:m hh_key using `ind_file', assert(match)
drop _merge hh_key


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
	gen int year = 2018
	label var year "Year of survey"
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
	gen int_year= .
	replace int_year = 2018 if inlist(quarter,"Q5","Q6")
	replace int_year = 2019 if inlist(quarter,"Q7","Q8")
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>

	gen  int_month = month
	replace int_month = . if month == 0
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
	gen wave = .
	label var wave "Survey wave"
*</_wave_>

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
	label de lblsubnatid1 28 "28 - Andhra Pradesh" 12 "12 - Arunachal Pradesh" 18 "18 - Assam" 10 "10 - Bihar" 30 "30 - Goa" 24 "24 - Gujrat" 6 "6 - Haryana" 2 "2 - Himachal Pradesh" 1 "1 - Jammu & Kashmir" 29 "29 - Karnataka" 32 "32 - Kerala" 23 "23 - Madhya Pradesh" 27 "27 - Maharastra" 14 "14 - Manipur" 17 "17 - Meghalaya" 15 "15 - Mizoram" 13 "13 - Nagaland" 21 "21 - Odisha" 3 "3 - Punjab" 8 "8 - Rajasthan" 11 "11 - Sikkim" 33 "33 - Tamil Nadu" 16 "16 - Tripura" 9 "9 - Uttar Pradesh" 19 "19 - West Bengal" 35 "35 - Andaman & Nicober" 4 "4 - Chandigarh" 26 "26 - Dadra & Nagar Haveli" 25 "25 - Daman & Diu" 7 "7 - Delhi" 31 "31 - Lakshadweep" 34 "34 - Pondicheri" 22 "22 - Chhattisgarh" 20 "20 - Jharkhand" 5 "5 - Uttaranchal" 36 "36 - Telangana"
	label values subnatid1 lblsubnatid1
	
	* Convert numeric into string
	decode subnatid1, gen(subnatid1_str)
	rename subnatid1 subnatid1_num
	rename subnatid1_str subnatid1
	
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	gen byte subnatid2 = district
	label values subnatid2 lblsubnatid2
	label var subnatid2 "District code"
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
	* Variable age already exists in original data
	*gen age = .
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

	bys hhid: gen one=1 if rel_head == 1
	bys hhid: egen temp=count(one)
	tab temp
	assert `r(r)' == 1
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
	gen vocational_field_orig = field_training
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
	recode nlfreason (11/81 98=.) (91=1) (92 93=2) (94=3) (95=4) (82 96 97=5)
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
	tostring occup_orig, gen(nco_04)
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
	gen occup = .
	replace occup = floor(occup_orig/100) if lstatus == 1 & (age >= minlaborage & age != .)
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
	gen empstat_y1 = p_status_code
	recode empstat_y1 (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72=1) (81/99=.)
	gen empstat_y2 = s_status_code
	recode empstat_y2 (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72=1) (81/99=.)

	gen empstat_year = empstat_y1
	replace empstat_year = empstat_y2 if adders == 1

	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status", replace
	label values empstat_year lblempstat_year
	drop empstat_y1 empstat_y2
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
	merge m:1 nco_04 using "`path_in'/India_nco_04_to_isco_88.dta", nogen keep(match master)

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
	gen has_job_primary = inlist(p_status_code,11,12,21,31,41,51)
	gen empstat_2_year = s_status_code
	recode empstat_2_year (11=4) (12=3) (61 62 21=2) (31 41 42 51 52 71 72=1) (81/99=.)
	replace empstat_2_year = . if lstatus_year != 1
	replace empstat_2_year = . if has_job_primary == 0 & !missing(empstat_2_year)
	label var empstat_2_year "Employment status during past week secondary job 12 month recall"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2_year lblempstat_2_year
	drop has_job_primary
*</_empstat_2_year_>


*<_ocusec_2_year_>
	gen byte ocusec_2_year = .
	replace ocusec_2_year=1 if s_ent_type_code ==5
	replace ocusec_2_year=2 if inlist(s_ent_type_code ,1,2,3,4,8,10,11,12)
	replace ocusec_2_year=3 if inlist(s_ent_type_code ,6,7)
	replace ocusec_2_year=. if s_ent_type_code==19
	replace ocusec_2_year = . if missing(empstat_2_year)
	label var ocusec_2_year "Sector of activity secondary job 12 month recall"
	la de lblocusec_2_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_2_year lblocusec_2_year
*</_ocusec_2_year_>


*<_industry_orig_2_year_>
	gen industry_orig_2_year = s_industry_nic_code
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
	gen occup_orig_2_year = s_occupation_nco_code
	replace occup_orig_2_year = "" if missing(empstat_2_year)
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
	gen nco_04 = occup_orig_2_year
	merge m:1 nco_04 using "`path_in'/India_nco_04_to_isco_88.dta", nogen keep(match master)

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

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

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

save "`path_output'\IND_2018_PLFS_V01_M_V02_A_GLD_ALL.dta", replace

*</_% SAVE_>
