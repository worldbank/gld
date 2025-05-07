 
/*%%=============================================================================================
	0: GLD Harmonization Preamble
================================================================================================*/

/* -----------------------------------------------------------------------
<_Program name_>				GEO_2023_LFS_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata SE 16.1 <_Application_>
<_Author(s)_>					Wolrd Bank Job's Group </_Author(s)_>
<_Date created_>				2025-1-26 </_Date created_>
-------------------------------------------------------------------------
<_Country_>						Georgia (GEO) </_Country_>
<_Survey Title_>				Labour Force Survey </_Survey Title_>
<_Survey Year_>					2023 </_Survey Year_>
<_Study ID_>					GEO_2023_LFS_v01_M </_Study ID_>
<_Data collection from (M/Y)_>	[Jan/2023] </_Data collection from (M/Y)_>
<_Data collection to (M/Y)_>	[Dec/2023] </_Data collection to (M/Y)_>
<_Source of dataset_> 			Survey conducted by National Statistics Office of Georgia.
								Georgia national stats office website.</_Source of dataset_>
								*OPENLY ACCESSIBLE: 		 
								https://www.geostat.ge/en/modules/categories/130/labour-force-survey-databases*
<_Sample size (HH)_> 			21,065 </_Sample size (HH)_>
<_Sample size (IND)_> 		    72,825  </_Sample size (IND)_>
<_Sampling method_> 			Stratified random sampling </_Sampling method_>
<_Geographic coverage_> 		Whole country </_Geographic coverage_>
<_Currency_> 					Georgian Lari </_Currency_>
-----------------------------------------------------------------------
<_ICLS Version_>				ICLS 13 </_ICLS Version_>
<_ISCED Version_>				ISCED-2011 </_ISCED Version_>
<_ISCO Version_>				ISCO 08 </_ISCO Version_>
<_OCCUP National_>				ISCO 08 (used directly in the raw data set)	 </_OCCUP National_>
<_ISIC Version_>				ISIC Rev.4 </_ISIC Version_>
<_INDUS National_>				NACE Rev.2 (NACE Rev.1 also provided in the raw data set) </_INDUS National_>
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

* Define path sections
local server  "Y:/GLD-Harmonization/529026_MG/Countries"
local country "GEO"
local year    "2023"
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

* Open Demographic details, all ages
use "`path_in_stata'/LFS_Demographic_ENG_2023.dta"

* Merge in extra file w/ migration vars, all ages (file not publicly available)
merge 1:1 UID MemberNo using "`path_in_stata'/add_2.dta", assert(match) nogen

* Merge in labour module, ages 15+
merge 1:1 UID MemberNo using "`path_in_stata'/LFS_ECSTAT_ENG_2023.dta", assert(match master) nogen
	
* Merge in labour modules additional questions, 15+ (file not publicly available)
merge 1:1 UID MemberNo using "`path_in_stata'/add_1.dta", assert(match master) nogen


* Drop those Ages 15+ who miss A1, those have no weights and should be answering
* Hence not initially listed but not part of the HHs and thus part of the 
* questionnaire
drop if mi(A1) & Age >= 15 & !mi(Age)

/*%%=============================================================================================
	2: Survey & ID
================================================================================================*/

{

*<_countrycode_>
	gen str4 countrycode="`country'"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname="LFS"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey="LFS"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	gen icls_v="ICLS-19"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	gen isced_version="isced_2011"
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
	gen isco_version="isco_2008"
	label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
	gen isic_version="isic_4"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	gen int year=`year'
	label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen str3 vermast="`vermast'"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen str3 veralt="`veralt'"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen harmonization="GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	gen int_year=Year
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen int_month=Month
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>

/*<_hhid_note_>
 
	UID is unique household ID in a quarter. However, to build the panel we want
	Diary ID. To still make it unique at the year level, add quarter info

*<_hhid_note_>*/
	tostring DiaryID,   gen(helper_hhid_1) format(%05.0f)
	tostring QuarterNo, gen(helper_hhid_2) format(%03.0f)
	
	egen hhid = concat(helper_hhid_1 helper_hhid_2), punct(-)
	label var hhid "Household id"
*</_hhid_>


*<_pid_>
	tostring MemberNo, gen(MemberNo_str) format(%02.0f)
	egen pid = concat(hhid MemberNo_str), punct(-)
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
	
	* Weight variable is missing for those under 15 - apply household median 
	* value to those missing. Note: in all HHs with more than one person (if
	* just one SD is 0), SD is at most 1 in half the cases, at most 10 for 95%
	* of households - when P_weights interquartile range is 106 to 241, so this 
	* seems a reasonable system to correct for missin values that will not bias
	* results (not affect labour market info anyway as it is 15+)
	bys hhid : egen weight_sd = sd(P_Weights)
	preserve
		bys hhid : keep if _n == 1
		summ weight_sd, d
	restore
	
	gen hlpr_wgt = P_Weights
	bys hhid : egen hlpr_med_wgt = median(P_Weights)
	replace hlpr_wgt = hlpr_med_wgt if mi(hlpr_wgt)
	
	bys QuarterNo : gen pop_q = _N
	gen pop_t = _N
	gen weight = hlpr_wgt*(pop_q/pop_t)
	label var weight "Survey sampling weight"
	
	* Estimated population for 2023 thus is 3,643,916.
	* Population for 2023 as on GeoStat is  3,736,400. A bit off this year,
	* but OK. 
*</_weight_>


*<_weight_m_>
	gen weight_m = .
	label var weight_m "Survey sampling weight to obtain national estimates for each month"
*</_weight_m_>


*<_weight_q_>
	gen weight_q = hlpr_wgt
	label var weight_q "Survey sampling weight to obtain national estimates for each quarter"
*</_weight_q_>


*<_psu_>
	gen psu=.
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu=.
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	gen strata=.
	label var strata "Strata"
*</_strata_>


*<_wave_>
	gen wave=.
	replace wave = 1 if QuarterNo == 107
	replace wave = 2 if QuarterNo == 108
	replace wave = 3 if QuarterNo == 109
	replace wave = 4 if QuarterNo == 110
	label var wave "Survey wave - Quarter"
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
================================================================================================*/

{

*<_urban_>
	gen urban=.
	replace urban=1 if Urban_Rural==1
	replace urban=0 if Urban_Rural==2
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
	label var urban "Location is urban"
*</_urban_>


*<_subnatid1_>
	gen subnatid1=""
	replace subnatid1="11 - Tbilisi" if Region==11
	replace subnatid1="15 - Adjara" if Region==15
	replace subnatid1="23 - Guria" if Region==23
	replace subnatid1="26 - Imereti" if Region==26
	replace subnatid1="29 - Kakheti" if Region==29
	replace subnatid1="32 - Mtskheta-Mtianeti" if Region==32
	replace subnatid1="35 - Racha-Lechkhumi and Kvemo Svaneti" if Region==35
	replace subnatid1="38 - Samegrelo-Zemo Svaneti" if Region==38
	replace subnatid1="41 - Samtskhe-Javaxeti" if Region==41
	replace subnatid1="44 - Kvemo Kartli" if Region==44
	replace subnatid1="47 - Shida Kartli" if Region==47
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	gen subnatid2=""
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	gen subnatid3=""
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>	
	decode urban, gen(urban_name)
	egen subnatidsurvey=concat(subnatid1 urban_name), punct("-")
	replace subnatidsurvey="" if subnatidsurvey=="-"
	label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>                


*<_subnatid1_prev_>

/* <_subnatid1_prev_note_>
subnatid1_prev is coded as missing unless the classification used for subnatid1 has changed since the previous survey.
</_subnatid1_prev_note_> */

	gen subnatid1_prev=.
	label var subnatid1_prev "Classification used for subnatid1 from previous survey"
*</_subnatid1_prev_>


*<_subnatid2_prev_>
	gen subnatid2_prev=.
	label var subnatid2_prev "Classification used for subnatid2 from previous survey"
*</_subnatid2_prev_>


*<_subnatid3_prev_>
	gen subnatid3_prev=.
	label var subnatid3_prev "Classification used for subnatid3 from previous survey"
*</_subnatid3_prev_>


*<_gaul_adm1_code_>
	gen gaul_adm1_code=.
	label var gaul_adm1_code "Global Administrative Unit Layers (GAUL) Admin 1 code"
*</_gaul_adm1_code_>


*<_gaul_adm2_code_>
	gen gaul_adm2_code=.
	label var gaul_adm2_code "Global Administrative Unit Layers (GAUL) Admin 2 code"
*</_gaul_adm2_code_>


*<_gaul_adm3_code_>
	gen gaul_adm3_code=.
	label var gaul_adm3_code "Global Administrative Unit Layers (GAUL) Admin 3 code"
*</_gaul_adm3_code_>

}

/*%%=============================================================================================
	4: Demography
================================================================================================*/

{

*<_hsize_>
	gsort hhid -Age
	bys hhid: gen count=_n
	bys hhid: egen hsize=max(count)
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen age = Age
	replace age = 98 if age > 98 & age != .
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = Sex
	recode male (1=0) (2=1) 
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>

/*<_relationharm_note_>

One household do not have any household head because it is composed of only
non-relatives. Its hhid is 126440.

*<_relationharm_note_>*/

	gen byte relationharm=Relationship
	recode relationharm (4 8=3) (5 6=4) (7 9 10=5) (11=6)
	
	gen head=relationharm==1
	bys hhid: egen headsum=sum(head)
	replace relationharm=1 if inrange(relationharm,1,5)&headsum==0&count==1

	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm lblrelationharm
*<_relationharm_>
	

*<_relationcs_>
	gen relationcs=Relationship
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen marital=Marital_Status
	recode marital (3=2) 
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	gen eye_dsablty=.
	la de lbleye_dsablty 1 "No" 2 "Yes-some" 3 "Yes-a lot" 4 "Cannot at all"
	label values eye_dsablty lbleye_dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty=.
	la de lblhear_dsablty 1 "No" 2 "Yes-some" 3 "Yes-a lot" 4 "Cannot at all"
	label values hear_dsablty lblhear_dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty=.
	la de lblwalk_dsablty 1 "No" 2 "Yes-some" 3 "Yes-a lot" 4 "Cannot at all"
	label values walk_dsablty lblwalk_dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord=.
	la de lblconc_dsord 1 "No" 2 "Yes-some" 3 "Yes-a lot" 4 "Cannot at all"
	label values conc_dsord lblconc_dsord
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty=.
	la de lblslfcre_dsablty 1 "No" 2 "Yes-some" 3 "Yes-a lot" 4 "Cannot at all"
	label values slfcre_dsablty lblslfcre_dsablty
	label var eye_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty=.
	la de lblcomm_dsablty 1 "No" 2 "Yes-some" 3 "Yes-a lot" 4 "Cannot at all"
	label values comm_dsablty lblcomm_dsablty
	label var eye_dsablty "Disability related to communicating"
*</_comm_dsablty_>

}


/*%%=============================================================================================
	5: Migration
================================================================================================*/


*<_migrated_mod_age_>

/*<_migrated_mod_age_note_>

15 is actually an application age for the whole survey.

<_migrated_mod_age_note_>*/

	gen migrated_mod_age = 0
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time =  13
	label var migrated_ref_time "Reference time applied to migration questions"
*</_migrated_ref_time_>


*<_migrated_binary_>
	* Should be all who have not code 1 or 2 in YYYY_Q15 have the year, there
	* are also ~1,400 missing, these are set to not migrated as well (miss 
	* subsequent questions)
	gen migrated_binary = 0
	replace migrated_binary = 1 if inrange(YYYY_Q15, 2010, 2023)
	label de lblmigrated_binary 0 "No" 1 "Yes"
	replace migrated_binary = . if age < migrated_mod_age
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>                                                                                                                             
               
*<_migrated_years_>
   gen migrated_years = 2023 - YYYY_Q15
   replace migrated_years = . if migrated_binary != 1
   replace migrated_years = . if age < migrated_mod_age
   label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban = .
	replace migrated_from_urban = 1 if Q17 == 1
	replace migrated_from_urban = 0 if Q17 == 2
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	replace migrated_from_urban = . if age < migrated_mod_age
	replace migrated_from_urban = . if migrated_binary != 1
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen mig_hlp_same_region = Q16 == Region if !mi(Q16)
	
	gen migrated_from_cat=.
	replace migrated_from_cat = 3 if mig_hlp_same_region == 1
	replace migrated_from_cat = 4 if mig_hlp_same_region == 0 & Q16 != 99
	replace migrated_from_cat = 5 if mig_hlp_same_region == 0 & Q16 == 99
	replace migrated_from_cat = . if age < migrated_mod_age
	replace migrated_from_cat = . if migrated_binary != 1
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country" 6 "Within country, admin unknown" 7 "Wholly unknow"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen migrated_from_code = ""

	replace migrated_from_code = "11 - Tbilisi" 						  if Q16 == 11
	replace migrated_from_code = "12 - Abkhazia" 						  if Q16 == 12
	replace migrated_from_code = "15 - Adjara" 							  if Q16 == 15
	replace migrated_from_code = "23 - Guria" 							  if Q16 == 23
	replace migrated_from_code = "26 - Imereti" 					      if Q16 == 26
	replace migrated_from_code = "29 - Kakheti" 						  if Q16 == 29
	replace migrated_from_code = "32 - Mtskheta-Mtianeti" 				  if Q16 == 32
	replace migrated_from_code = "35 - Racha-Lechkhumi and Kvemo Svaneti" if Q16 == 35
	replace migrated_from_code = "38 - Samegrelo-Zemo Svaneti" 			  if Q16 == 38
	replace migrated_from_code = "41 - Samtskhe-Javaxeti" 				  if Q16 == 41
	replace migrated_from_code = "44 - Kvemo Kartli" 					  if Q16 == 44
	replace migrated_from_code = "47 - Shida Kartli" 					  if Q16 == 47


	replace migrated_from_code = "" if age < migrated_mod_age
	replace migrated_from_code = "" if migrated_binary != 1
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country = ""
	replace migrated_from_country = "" if migrated_binary != 1
	replace migrated_from_country = "" if age < migrated_mod_age
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason = Q18
	recode migrated_reason (1 2=3) (3=2) (7 8=1) (4/6 97=5)
	replace migrated_reason = . if migrated_binary != 1
	replace migrated_reason = . if age < migrated_mod_age
	label de lblmigrated_reason 1 "Family reasons" 2 "Educational reasons" 3 "Employment" 4 "Forced (political reasons, natural disaster, …)" 5 "Other reasons"
	label values migrated_reason lblmigrated_reason
	label var migrated_reason "Reason for migrating"
*</_migrated_reason_>




/*%%=============================================================================================
	6: Education
================================================================================================*/


{
*<_ed_mod_age_>

/*<_ed_mod_age_note>

15 is actually an application age for the whole survey.

*<_ed_mod_age_note>*/

	gen byte ed_mod_age=15
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


*<_school_>
	gen school=.
	replace school=. if age<ed_mod_age & age!=.
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school lblschool
*</_school_>


*<_literacy_>
	gen byte literacy=.
	replace literacy=0 if Education==1
	replace literacy=1 if inrange(Education,2,13)
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>

/*<_educy_note_>

Original categorization of the highest educational level ever attended of 
variable Education is:

1. Illiterate 
2. Has no education but can read and write 
3. Pre-primary education 
4. Primary education 
5. Basic general education (lower secondary)
6. Secondary general education (upper secondary)
7. Vocational education without secondary general education
8. Vocational education on the base of lower secondary education with secondary general education certificate 
9. Vocational education on the base of secondary general education (except higher professional education)
10. Higher professional education or equivalent
11. Bachelor or equivalent 
12. Master or equivalent
13. Doctor or equivalent

*<_educy_note_>*/

	gen byte educy=.
	replace educy=0 if inrange(Education,0,1)
	replace educy=3 if Education==3
	replace educy=9 if Education==4
	replace educy=12 if Education==5
	replace educy=15 if Education==6
	replace educy=12 if Education==7
	replace educy=13 if Education==8
	replace educy=17 if Education==9|Education==10
	replace educy=19 if Education==11
	replace educy=21 if Education==12
	replace educy=24 if Education==12
	replace educy=. if age<ed_mod_age
	replace educy=. if educy>age & !mi(educy) & !mi(age)
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7=.
	replace educat7=1 if inrange(Education,0,1)
	replace educat7=2 if Education==3
	replace educat7=3 if Education==4
	replace educat7=4 if inlist(Education,5,7)
	replace educat7=5 if inlist(Education,6,8,9)
	replace educat7=6 if Education==10
	replace educat7=7 if inlist(Education,11,12,13)
	replace educat7=. if age<ed_mod_age
	label var educat7 "Level of education 1"
	la de lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete"
	label values educat7 lbleducat7
*</_educat7_>


*<_educat5_>
	gen byte educat5=educat7
	recode educat5 (4=3) (5=4) (6 7=5)
	replace educat5=. if age<ed_mod_age	
	label var educat5 "Level of education 2"
	la de lbleducat5 1 "No education" 2 "Primary incomplete"  3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5 
*</_educat5_>


*<_educat4_>
	gen byte educat4=educat5
	replace educat4=. if age<ed_mod_age
	recode educat4 (3=2) (4=3) (5=4)
	label var educat4 "Level of education 3"
	la de lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 lbleducat4
*</_educat4_>


*<_educat_orig_>
	gen educat_orig=Education
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
	gen educat_isced=.
	replace educat_isced=020 if Education==3
	replace educat_isced=100 if Education==4
	replace educat_isced=244 if Education==5
	replace educat_isced=344 if Education==6
	replace educat_isced=353 if inrange(Education,7,9)
	replace educat_isced=454 if Education==10
	replace educat_isced=660 if Education==11
	replace educat_isced=760 if Education==12
	replace educat_isced=860 if Education==13
	replace educat_isced=. if age<ed_mod_age
	label var educat_isced "ISCED standardised level of education"
*</_educat_isced_>


*<_educat_isced_v_>
	gen educat_isced_v="ISCED-2011"
	label var educat_isced_v "Version of the ISCED used"
*</_educat_isced_v_>

*----------6.1: Education cleanup------------------------------*

*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
local ed_var school literacy educy educat7 educat5 educat4 educat_isced
foreach v of local ed_var {
	replace `v'=. if ( age < ed_mod_age & !missing(age) )
}
replace educat_isced_v="." if ( age < ed_mod_age & !missing(age) )
*</_% Correction min age_>

}

/*%%=============================================================================================
	7: Training
================================================================================================*/

{

*<_vocational_>
	gen vocational=.
	la de vocationallbl 1 "Yes" 0 "No"
	la values vocational vocationallbl
	label var vocational "Ever received vocational training"
*</_vocational_>


*<_vocational_type_>
	gen vocational_type=.
	label de lblvocational_type 1 "Inside Enterprise" 2 "External"
	label values vocational_type lblvocational_type
	label var vocational_type "Type of vocational training"
*</_vocational_type_>


*<_vocational_length_l_>
	gen vocational_length_l=.
	replace vocational_length_l=. if vocational!=1
	label var vocational_length_l "Length of training in months, lower limit"
*</_vocational_length_l_>


*<_vocational_length_u_>
	gen vocational_length_u=.
	replace vocational_length_l=. if vocational!=1
	label var vocational_length_u "Length of training in months, upper limit"
*</_vocational_length_u_>


*<_vocational_field_orig_>
	gen vocational_field_orig=.
	replace vocational_field_orig=. if vocational!=1
	label var vocational_field_orig "Original field of training information"
*</_vocational_field_orig_>


*<_vocational_financed_>
	gen vocational_financed=.
 	label de lblvocational_financed 1 "Employer" 2 "Government" 3 "Mixed Employer/Government" 4 "Own funds" 5 "Other"
	label var vocational_financed "How training was financed"
*</_vocational_financed_>

}

/*%%=============================================================================================
	8: Labour
================================================================================================*/

*<_minlaborage_>
	gen byte minlaborage=15
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{	
*<_lstatus_>

/*<_lstatus_note_>

Regarding umemployed, it has unemployed based on ILO strict definition and soft 
definition. The unemployed population defined by soft definition has 3,551 more 
observations than the strict definition. 

. tab Unemployed Unemployed_soft, m

Unemployed |
 according |
    to the |
Internatio |
nal Labour | Unemployed according
Organizati | to the International
  on (ILO) |  Labour Organization
    strict |  (ILO) soft criteri
     crite |        No        Yes |     Total
-----------+----------------------+----------
        No |    51,697      3,551 |    55,248 
       Yes |         0      5,014 |     5,014 
-----------+----------------------+----------
     Total |    51,697      8,565 |    60,262 

But based on the previous years we know the strict definition of unemployment alligns
with our definition. We used the original variable "Unemployed" directly.

*<_lstatus_note_>*/

	gen byte lstatus=.
	egen seeking=rowtotal(G3_1_Methods_used_to_find_work-G3_97_Methods_used_to_find_work), missing
	replace seeking=0 if seeking==.
	replace seeking=1 if seeking>0

	replace lstatus=1 if inlist(A1_5,1,2)| inlist(A1_6,1,2)|A2==1|A3==1|A4==1|inrange(A6,6,9)|A7==1|A8==1|A9==1
	replace lstatus=. if lstatus==1&[inlist(A1_5,3,4)|inlist(A1_6,3,4)]&[A5==2|A6==12|A7==2|A9==2]
	replace lstatus=2 if seeking==1&_v8==1&lstatus!=1
	replace lstatus=3 if lstatus==. 
	replace lstatus=. if age<minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>

/*<_potential_lf_note_>
Note: var "potential_lf" only takes value if the respondent is not in labor force. (lstatus==3)

"potential_lf"=1 if the person is
1)available but not searching
2)searching but not immediately available to work 

But since we only have the availability variable "_v9" and do not have the seeking variable,
we have to code PLF using the processed variable "Potential_Labour_Force_PLF" already in the 
dataset. It seems to be coded following the same rule we have.

. tab PLF_Seeking_not_available Potential_Labour_Force_PLF
 
 Potential |
    Labour |
   Force - |
   Seeking |   Potential Labour
       not |         Force
 available |        No        Yes |     Total
-----------+----------------------+----------
        No |    52,222      8,012 |    60,234 
       Yes |         0         28 |        28 
-----------+----------------------+----------
     Total |    52,222      8,040 |    60,262
	 
. tab PLF_Available_not_seeking Potential_Labour_Force_PLF

 Potential |
    Labour |
   Force - |
 Available |   Potential Labour
       not |         Force
   seeking |        No        Yes |     Total
-----------+----------------------+----------
        No |    52,222         28 |    52,250 
       Yes |         0      8,012 |     8,012 
-----------+----------------------+----------
     Total |    52,222      8,040 |    60,262
	 
*</_potential_lf_note_>*/

	gen potential_lf=.
	replace potential_lf=1 if (seeking==1&_v9==2)|(seeking==0&_v9==1)
	replace potential_lf=0 if (seeking==1&_v9==1)|(seeking==0&_v9==2)
	
	replace potential_lf=. if age < minlaborage
	replace potential_lf=. if lstatus!=3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>

/*<_underemployment_note_>

The questionnaire actually has questions about "willingness and availability" to work 
for more hours but they are not in the raw dataset.

*<_underemployment_note_>*/

	gen byte underemployment=.
	replace underemployment=. if age<minlaborage
	replace underemployment=. if lstatus!=1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason=.
	replace nlfreason=1 if OutsidetheLabourForce_student==1
	replace nlfreason=2 if OutsidetheLabourForce_homemaker==1
	replace nlfreason=3 if OutsidetheLabourForce_pensioner==1
    replace nlfreason=4 if OutsidetheLabourForce_disabled==1
	replace nlfreason=5 if OutsidetheLabourForce_emp_agency==1|OutsidetheLabourForce_discourage==1|OutsidetheLabourForce_other==1
	replace nlfreason=. if age<minlaborage
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l=G4_Unemployment_Spin
	recode unempldur_l (1=0) (2=1) (3=3) (4=6) (5=12) (6=18) (7=24) (8=48) 
	replace unempldur_l=. if age<minlaborage
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=G4_Unemployment_Spin
	recode unempldur_u (1=1) (2=2) (3=5) (4=11) (5=17) (6=23) (7=47) (8=.) 
	replace unempldur_u=. if age<minlaborage
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte empstat=Status
	recode empstat (2=3) (3=2) (4=1) (97=5)
	replace empstat=4 if empstat==3&B26_Employed_at_local_unit==1
	replace empstat=. if lstatus!=1|age<minlaborage
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec=Sector_ownership
	recode ocusec (1 3 4 =1) (2=2) (97 98=.)
	replace ocusec=. if lstatus!=1|age<minlaborage
	la de lblocusec 1 "State-owned" 2 "Private-owned"
	label values ocusec lblocusec
	
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig=Brunch                                                                
	replace industry_orig=. if lstatus!=1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	* We use NACE2. Bring in with the crosswalk cases when NACE2 != ISIC, 
	* otherwise use NACE2
	tostring Brunch, gen(nace2_code) format(%04.0f)
	replace nace2_code = "" if nace2_code == "."

	merge m:1 nace2_code using "`path_in_stata'/nace2_isic4_crosswalk.dta", keepusing(isic4) keep(master match) nogen
	replace isic4 = nace2_code if mi(isic4) & !mi(nace2_code)
	
	rename isic4 industrycat_isic
	replace industrycat_isic = "" if lstatus!=1 
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	destring nace2_code, replace
	gen industrycat10=floor(nace2_code/100)
	recode industrycat10 (1/3=1) (5/9=2) (10/33=3) (35/39=4) (41/43=5) (45/47 55/56=6) (49/53 58/63=7) (64/82=8) (84=9) (85/99=10)	
	replace industrycat10=. if lstatus!=1
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
*</_industrycat10_>



*<_industrycat_nace2_>
	gen industrycat_nace2=floor(nace2_code/100)
	recode industrycat_nace2 (1/3=1) (5/9=2) (10/33=3) (35 = 4) (36/39=5) (41/43=6) (45/47=7) (49/53 = 8) (55/56 = 9) (58/63 = 10) ///
	                     (64/66 = 11) (68 = 12) (69 / 75 = 13) (77 / 82 = 14) (84 = 15) (85 = 16)  ///
						 (86/88 = 17) (90/ 93= 18) (94 / 96= 19) (97/99 = 20)
	
	replace industrycat_nace2=. if lstatus!=1
	
	la de lblindustrycat_nace2  1 "Agriculture" ///
								2 "Mining" ///
								3 "Manufacturing" ///
								4 "Electricity and gas" ///
								5 "Water and sewerage" ///
								6 "Construction"  ///
								7 "Wholesale and retail" ///
								8 "Transport and storage" ///
								9 "Accommodation and food services" ///
								10 "Information and communication" ///
								11 "Financial and insurance" ///
								12 "Real estate" ///
								13 "Professionals activities" ///
								14 "Administrative activities" ///
								15 "Public administration" ///
								16 "Education" ///
								17 "Health and social work" ///
								18 "Arts, entertainment, and rec." ///
								19 "Other services" ///
								20 "Household activities", modify

	label values industrycat_nace2 lblindustrycat_nace2 
	drop nace2_code
*<_industrycat_nace2_>



*<_industrycat4_>
	gen byte industrycat4=industrycat10
	recode industrycat4 (1=1)(2 3 4 5=2)(6 7 8 9=3)(10=4)
	label var industrycat4 "1 digit industry classification (Broad Economic Activities), primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
	gen occup_orig=Occupation
	replace occup_orig=. if lstatus!=1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	tostring Occupation, gen(occup_isco) format(%04.0f)
	replace occup_isco="" if lstatus!=1 | occup_isco=="." 
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_skill_>
	gen b5=string(Occupation, "%04.0f")
	gen skill_level=substr(b5, 1, 1)
	destring skill_level, replace
	gen occup_skill=.
	replace occup_skill=1 if skill_level==9
	replace occup_skill=2 if inrange(skill_level, 4, 8)
	replace occup_skill=3 if inrange(skill_level, 1, 3)
	replace occup_skill=. if skill_level==0 | lstatus!=1
	la de lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lblskill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_occup_>
	 gen occupnum=substr(b5,1,1)
	 destring occupnum, gen(occup)
	 replace occup=10 if occup==0
	 replace occup=. if lstatus!=1
	 label var occup "1 digit occupational classification, primary job 7 day recall"
  	 la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	 label values occup lbloccup
*</_occup_>


*<_wage_no_compen_>

/*<_wage_no_compen_note_>

Question B24 asks the specific amount of earnings whereas B25 asks the brackets of 
earnings in case that the respondents do not recall the exact amount. 

- 11,278 observations out of 16,361 paid observations answered B24_2 with a specific
number of their income, which gives 68.93% of paid employees values for wage. 
- 5,056 observations out of 16,361 paid observations have missing values for B24_2
whereas 29 observations answered B24_2 zero. 

The idea here is classify those with codes into salary groups as per B18, then obtain the
average wage of them by (1) sex, (2) urb/rur area, (3) occupation, and (4) industry.
 
*<_wage_no_compen_note_>*/

     * Overall --> wage info (here the variable, for us it should be wage_no_compen)
     * to missing if value is 0. Should be 63 changes in 2017.

     gen B24_2_help=B24_2
     replace B24_2_help=. if B24_2_help==0

     * First replace outliers by
     winsor2 B24_2_help, suffix(_w) cuts(1 99)

     * Create salary categories based on winsor values
     gen salary_cat=.
     replace salary_cat=1 if inrange(B24_2_help_w, 1, 100)
     replace salary_cat=2 if inrange(B24_2_help_w, 101, 200)
     replace salary_cat=3 if inrange(B24_2_help_w, 201, 400)
     replace salary_cat=4 if inrange(B24_2_help_w, 401, 600)
     replace salary_cat=5 if inrange(B24_2_help_w, 601, 800)
     replace salary_cat=6 if inrange(B24_2_help_w, 801, 1000)
     replace salary_cat=7 if inrange(B24_2_help_w, 1001, 1500)
     replace salary_cat=8 if inrange(B24_2_help_w, 1501, 2000)
     replace salary_cat=9 if inrange(B24_2_help_w, 2001, 99999999)

     * PReserve to collapse, so we can merge the info in
     preserve

     * Collpase by industry, sex, and salary categories
     collapse (mean)B24_2_help_w[iw=weight], by(industrycat10 occup male urban salary_cat)

     * Rename variable, otherwise when merging in, master version of an equally name one will be kept
     rename B24_2_help_w wage_group_estimate

     * Rename salary_cat to B25 since this is what we want the info to latch on to
     rename salary_cat B25
     tempfile salary_helper
     save "`salary_helper'"
     list
     
	 * Restore, merge in
     restore
     merge m:1 industrycat10 occup male urban B25 using "`salary_helper'", keep(master matched) nogen

     * Create wage variable
     gen wage_no_compen=.

     * Fill it first with values that are accurate
     replace wage_no_compen=B24_2 if B24_1==1 & B24_2!=0

     * Now add the categorised means
     replace wage_no_compen=wage_group_estimate if B24_1==77&!missing(wage_group_estimate)

     * Keep only for employed employees, label
     replace wage_no_compen=. if lstatus!=1 & empstat!=1
     label var wage_no_compen "Last wage payment primary job 7 day recall"
	 
*</_wage_no_compen_>


*<_unitwage_>
	gen byte unitwage=5
	replace unitwage=. if lstatus!=1 | empstat==2
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours=M_Actually_worked
	replace whours=. if lstatus!=1|M_Actually_worked==0	
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	gen wmonths=.
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
	gen wage_total=.
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen byte contract=.
	replace contract=1 if !mi(B12_Agreement_type)
	replace contract=0 if mi(B12_Agreement_type)
	replace contract=. if lstatus!=1
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte healthins=.
	replace healthins=. if lstatus!=1
	label var healthins "Employment has health insurance primary job 7 day recall"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>

/*<_socialsec_note_>

Question B21 in the questionnaire asks the contributions to the pension fund.
But this question is not in the dataset.

*<_socialsec_note_>*/

	gen byte socialsec=.
	replace socialsec=. if lstatus!=1
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec 1 "With social security" 0 "Without social secturity"
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen byte union=.
	replace union=. if lstatus!=1
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	gen byte firmsize_l=B26_Employed_at_local_unit if inrange(B26_Employed_at_local_unit,1,6)
	recode firmsize_l (3=5) (4=11) (5=20) (6=50)
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u=B26_Employed_at_local_unit if inrange(B26_Employed_at_local_unit,1,6)
	recode firmsize_u (2=4) (3=10) (4=19) (5=49) (6=.)
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels

{
*<_empstat_2_>
	gen byte empstat_2=Second_Status 
	recode empstat_2 (2=3) (3=2) (4=1) (97=5)
	replace empstat_2=. if lstatus!=1|Second_Job!=1
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2=Second_Sector 
	recode ocusec_2 (4=1) (1=3) (3=2)
	replace ocusec_2=. if lstatus!=1|Second_Job!=1
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	la de lblocusec_2 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_2 lblocusec_2
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2=Second_Brunch
	replace industry_orig_2=. if lstatus!=1|Second_Job!=1
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	tostring Second_Brunch, gen(nace2_code) format(%04.0f)
	replace nace2_code = "" if nace2_code == "."

	merge m:1 nace2_code using "`path_in_stata'/nace2_isic4_crosswalk.dta", keepusing(isic4) keep(master match) nogen
	replace isic4 = nace2_code if mi(isic4) & !mi(nace2_code)
	
	rename isic4 industrycat_isic_2
	replace industrycat_isic_2 = "" if lstatus!=1 | Second_Job!=1
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	destring nace2_code, replace
	gen industrycat10_2 = floor(nace2_code/100)
	recode industrycat10_2 (1/3=1) (5/9=2) (10/33=3) (35/39=4) (41/43=5) (45/47 55/56=6) (49/53 58/63=7) (64/82=8) (84=9) (85/99=10)	
	replace industrycat10_2 = . if lstatus!=1 | Second_Job!=1
	label var industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
	label values industrycat10_2 lblindustrycat10
*</_industrycat10_2_>


*<_industrycat4_2_>
	gen byte industrycat4_2 = industrycat10_2
	recode industrycat4_2 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_2 "1 digit industry classification (Broad Economic Activities), secondary job 7 day recall"
	label values industrycat4_2 lblindustrycat4
*</_industrycat4_2_>


*<_occup_orig_2_>
	gen occup_orig_2 = Second_Ocupation
	replace occup_orig_2 = . if lstatus!=1 | Second_Job!=1
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	tostring Second_Ocupation, gen(occup_isco_2) format(%04.0f)
	replace occup_isco_2="" if lstatus!=1 | occup_isco_2=="." | Second_Job!=1
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_skill_2_>
	gen d4=string(Second_Ocupation, "%04.0f")
	gen skill_level_2 = substr(d4,1,1)
	destring skill_level_2, replace 
	gen occup_skill_2 = .
	replace occup_skill_2 = 1 if skill_level_2 == 9
	replace occup_skill_2 = 2 if inrange(skill_level_2,4,8)
	replace occup_skill_2 = 3 if inrange(skill_level_2,1,3)
	replace occup_skill_2 = . if skill_level_2 == 0 | lstatus != 1 | Second_Job != 1
	label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>


*<_occup_2_>
	gen occup_2=substr(d4,1,1)
	destring occup_2, replace
	recode occup_2 (0=10)
	replace occup_2 = . if lstatus != 1 | Second_Job != 1
	label var occup_2 "1 digit occupational classification secondary job 7 day recall"
	label values occup_2 lbloccup
*</_occup_2_>


*<_wage_no_compen_2_>
	gen wage_no_compen_2 = .
	replace wage_no_compen_2=. if lstatus!=1|Second_Job!=1|empstat_2==2
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2 = .
	replace unitwage_2 = . if lstatus != 1 |Second_Job != 1
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
	gen whours_2 = S_Actually_worked
	replace whours_2 = . if lstatus != 1 | Second_Job != 1 | S_Actually_worked == 0
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
	gen byte firmsize_u_2=.
	label var firmsize_u_2 "Firm size (upper bracket) secondary job 7 day recall"
*</_firmsize_u_2_>

}

*----------8.4: 7 day reference additional jobs------------------------------*

*<_t_hours_others_>
	gen t_hours_others=.
	label var t_hours_others "Annualized hours worked in all but primary and secondary jobs 7 day recall"
*</_t_hours_others_>


*<_t_wage_nocompen_others_>
	gen t_wage_nocompen_others=.
	label var t_wage_nocompen_others "Annualized wage in all but primary & secondary jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_others_>


*<_t_wage_others_>
	gen t_wage_others=.
	label var t_wage_others "Annualized wage in all but primary and secondary jobs (12-mon ref period)"
*</_t_wage_others_>


*----------8.5: 7 day reference total summary------------------------------*


*<_t_hours_total_>
	gen t_hours_total=.
	label var t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
	gen t_wage_nocompen_total=.
	label var t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
	gen t_wage_total=.
	label var t_wage_total "Annualized total wage for all jobs 7 day recall"
*</_t_wage_total_>


*----------8.6: 12 month reference overall------------------------------*

{
*<_lstatus_year_>
	gen byte lstatus_year=.
	replace lstatus_year=. if age<minlaborage
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>


*<_potential_lf_year_>
	gen byte potential_lf_year=.
	replace potential_lf_year=. if age<minlaborage
	replace potential_lf_year=. if lstatus_year!=3
	label var potential_lf_year "Potential labour force status"
	la de lblpotential_lf_year 0 "No" 1 "Yes"
	label values potential_lf_year lblpotential_lf_year
*</_potential_lf_year_>


*<_underemployment_year_>
	gen byte underemployment_year=.
	replace underemployment_year=. if age<minlaborage&age!=.
	replace underemployment_year=. if lstatus_year==1
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
	gen byte empstat_year=.
	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>


*<_ocusec_year_>
	gen byte ocusec_year=.
	label var ocusec_year "Sector of activity primary job 12 day recall"
	la de lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_year lblocusec_year
*</_ocusec_year_>


*<_industry_orig_year_>
	gen industry_orig_year=.
	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	gen industrycat_isic_year=""
	replace industrycat_isic_year="" if industrycat_isic_year=="."
	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>


*<_industrycat10_year_>
	gen byte industrycat10_year=.
	label var industrycat10_year "1 digit industry classification, primary job 12 month recall"
	la de lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_year lblindustrycat10_year
*</_industrycat10_year_>


*<_industrycat4_year_>
	gen byte industrycat4_year=industrycat10_year
	recode industrycat4_year (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_year "1 digit industry classification (Broad Economic Activities), primary job 12 month recall"
	la de lblindustrycat4_year 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4_year lblindustrycat4_year
*</_industrycat4_year_>


*<_occup_orig_year_>
	gen occup_orig_year=.
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	gen str4 occup_isco_year=""
	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_skill_year_>
	gen skill_level_year=substr(occup_isco_year,1,1)
	destring skill_level_year, replace
	gen occup_skill_year=.
	replace occup_skill_year=1 if skill_level_year==9
	replace occup_skill_year=2 if inrange(skill_level_year,4,8)
	replace occup_skill_year=3 if inrange(skill_level_year,1,3)
	replace occup_skill_year=. if skill_level_year==0
	label var occup_skill_year "Skill based on ISCO standard primary job 12 month recall"
*</_occup_skill_year_>


*<_occup_year_>
	gen byte occup_year=.
	label var occup_year "1 digit occupational classification, primary job 12 month recall"
	la de lbloccup_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_year lbloccup_year
*</_occup_year_>


*<_wage_no_compen_year_>
	gen double wage_no_compen_year=.
	label var wage_no_compen_year "Last wage payment primary job 12 month recall"
*</_wage_no_compen_year_>


*<_unitwage_year_>
	gen byte unitwage_year=.
	label var unitwage_year "Last wages' time unit primary job 12 month recall"
	la de lblunitwage_year 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_year lblunitwage_year
*</_unitwage_year_>


*<_whours_year_>
	gen whours_year=.
	label var whours_year "Hours of work in last week primary job 12 month recall"
*</_whours_year_>


*<_wmonths_year_>
	gen wmonths_year=.
	label var wmonths_year "Months of work in past 12 months primary job 12 month recall"
*</_wmonths_year_>


*<_wage_total_year_>
	gen wage_total_year=.
	label var wage_total_year "Annualized total wage primary job 12 month recall"
*</_wage_total_year_>


*<_contract_year_>
	gen byte contract_year=.
	label var contract_year "Employment has contract primary job 12 month recall"
	la de lblcontract_year 0 "Without contract" 1 "With contract"
	label values contract_year lblcontract_year
*</_contract_year_>


*<_healthins_year_>
	gen byte healthins_year=.
	label var healthins_year "Employment has health insurance primary job 12 month recall"
	la de lblhealthins_year 0 "Without health insurance" 1 "With health insurance"
	label values healthins_year lblhealthins_year
*</_healthins_year_>


*<_socialsec_year_>
	gen byte socialsec_year=.
	label var socialsec_year "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec_year 1 "With social security" 0 "Without social secturity"
	label values socialsec_year lblsocialsec_year
*</_socialsec_year_>


*<_union_year_>
	gen byte union_year=.
	label var union_year "Union membership at primary job 12 month recall"
	la de lblunion_year 0 "Not union member" 1 "Union member"
	label values union_year lblunion_year
*</_union_year_>


*<_firmsize_l_year_>
	gen byte firmsize_l_year=.
	label var firmsize_l_year "Firm size (lower bracket) primary job 12 month recall"
*</_firmsize_l_year_>


*<_firmsize_u_year_>
	gen byte firmsize_u_year=.
	label var firmsize_u_year "Firm size (upper bracket) primary job 12 month recall"
*</_firmsize_u_year_>

}


*----------8.8: 12 month reference secondary job------------------------------*

{

*<_empstat_2_year_>
	gen byte empstat_2_year=.
	label var empstat_2_year "Employment status during past week secondary job 12 month recall"
	label values empstat_2_year lblempstat_year
*</_empstat_2_year_>


*<_ocusec_2_year_>
	gen byte ocusec_2_year=.
	label var ocusec_2_year "Sector of activity secondary job 12 day recall"
	la de lblocusec_2_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_2_year lblocusec_2_year
*</_ocusec_2_year_>



*<_industry_orig_2_year_>
	gen industry_orig_2_year=.
	label var industry_orig_2_year "Original survey industry code, secondary job 12 month recall"
*</_industry_orig_2_year_>



*<_industrycat_isic_2_year_>
	gen industrycat_isic_2_year=.
	label var industrycat_isic_2_year "ISIC code of secondary job 12 month recall"
*</_industrycat_isic_2_year_>


*<_industrycat10_2_year_>
	gen byte industrycat10_2_year=.
	label var industrycat10_2_year "1 digit industry classification, secondary job 12 month recall"
	label values industrycat10_2_year lblindustrycat10_year
*</_industrycat10_2_year_>


*<_industrycat4_2_year_>
	gen byte industrycat4_2_year=industrycat10_2_year
	recode industrycat4_2_year (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_2_year "1 digit industry classification (Broad Economic Activities), secondary job 12 month recall"
	label values industrycat4_2_year lblindustrycat4_year
*</_industrycat4_2_year_>


*<_occup_orig_2_year_>
	gen occup_orig_2_year=.
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
	gen occup_isco_2_year=.
	label var occup_isco_2_year "ISCO code of secondary job 12 month recall"
*</_occup_isco_2_year_>


*<_occup_skill_2_year_>
	gen occup_skill_2_year=.
	label var occup_skill_2_year "Skill based on ISCO standard secondary job 12 month recall"
*</_occup_skill_2_year_>


*<_occup_2_year_>
	gen byte occup_2_year=.
	label var occup_2_year "1 digit occupational classification, secondary job 12 month recall"
	label values occup_2_year lbloccup_year
*</_occup_2_year_>


*<_wage_no_compen_2_year_>
	gen double wage_no_compen_2_year=.
	label var wage_no_compen_2_year "Last wage payment secondary job 12 month recall"
*</_wage_no_compen_2_year_>


*<_unitwage_2_year_>
	gen byte unitwage_2_year=.
	label var unitwage_2_year "Last wages' time unit secondary job 12 month recall"
	label values unitwage_2_year lblunitwage_year
*</_unitwage_2_year_>


*<_whours_2_year_>
	gen whours_2_year=.
	label var whours_2_year "Hours of work in last week secondary job 12 month recall"
*</_whours_2_year_>


*<_wmonths_2_year_>
	gen wmonths_2_year=.
	label var wmonths_2_year "Months of work in past 12 months secondary job 12 month recall"
*</_wmonths_2_year_>


*<_wage_total_2_year_>
	gen wage_total_2_year=.
	label var wage_total_2_year "Annualized total wage secondary job 12 month recall"
*</_wage_total_2_year_>


*<_firmsize_l_2_year_>
	gen byte firmsize_l_2_year=.
	label var firmsize_l_2_year "Firm size (lower bracket) secondary job 12 month recall"
*</_firmsize_l_2_year_>


*<_firmsize_u_2_year_>
	gen byte firmsize_u_2_year=.
	label var firmsize_u_2_year "Firm size (upper bracket) secondary job 12 month recall"
*</_firmsize_u_2_year_>

}


*----------8.9: 12 month reference additional jobs------------------------------*


*<_t_hours_others_year_>
	gen t_hours_others_year=.
	label var t_hours_others_year "Annualized hours worked in all but primary and secondary jobs 12 month recall"
*</_t_hours_others_year_>


*<_t_wage_nocompen_others_year_>
	gen t_wage_nocompen_others_year=.
	label var t_wage_nocompen_others_year "Annualized wage in all but primary & secondary jobs excl. bonuses, etc. 12 month recall)"
*</_t_wage_nocompen_others_year_>


*<_t_wage_others_year_>
	gen t_wage_others_year=.
	label var t_wage_others_year "Annualized wage in all but primary and secondary jobs 12 month recall"
*</_t_wage_others_year_>


*----------8.10: 12 month total summary------------------------------*


*<_t_hours_total_year_>
	gen t_hours_total_year=.
	label var t_hours_total_year "Annualized hours worked in all jobs 12 month month recall"
*</_t_hours_total_year_>


*<_t_wage_nocompen_total_year_>
	gen t_wage_nocompen_total_year=.
	label var t_wage_nocompen_total_year "Annualized wage in all jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_total_year_>


*<_t_wage_total_year_>
	gen t_wage_total_year=.
	label var t_wage_total_year "Annualized total wage for all jobs 12 month recall"
*</_t_wage_total_year_>


*----------8.11: Overall across reference periods------------------------------*


*<_njobs_>
	gen njobs=.
	replace njobs=1 if lstatus==1&Second_Job!=1
	replace njobs=2 if lstatus==1&Second_Job==1
	replace njobs=. if lstatus!=1
	label var njobs "Total number of jobs"
*</_njobs_>


*<_t_hours_annual_>
	gen t_hours_annual=.
	label var t_hours_annual "Total hours worked in all jobs in the previous 12 months"
*</_t_hours_annual_>


*<_linc_nc_>
	gen linc_nc=.
	label var linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."
*</_linc_nc_>


*<_laborincome_>
	gen laborincome=.
	label var laborincome "Total annual individual labor income in all jobs, incl. bonuses, etc."
*</_laborincome_>


/*
* adding new variables
recode Permanency_of_the_job (4=1) (1 2 3 5=2) (98 =.), gen(perm)
lab define lbl_perm 1 "Permanent jobs" 2 "Temporary, seasonal, and odd jobs" 
lab val perm lbl_perm 

recode B26_Employed_at_local_unit (1/3=1) (4 = 2) (5=3) (6=4) (98=.), gen(size)


//gen formal = B23_Enterprise_registered
clonevar distance = B37_commute_time
replace distance = . if inlist(B37_commute_time, 77, 99)
*/

*----------8.13: Labour cleanup------------------------------*


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



/*%%=============================================================================================
	9: Final steps
==============================================================================================%%*/



*<_% KEEP VARIABLES - ALL_>

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu ssu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome /* perm size distance */ industrycat_nace2

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu ssu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome /*perm size distance*/ industrycat_nace2

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



*<_% DELETE MISSING VARIABLES_>

describe, varlist
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

save "`path_output'/`level_2_harm'_ALL.dta", replace

*</_% SAVE_>
