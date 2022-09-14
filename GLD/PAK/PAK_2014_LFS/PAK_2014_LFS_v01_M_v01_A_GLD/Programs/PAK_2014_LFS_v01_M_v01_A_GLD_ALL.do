 
/*%%=============================================================================================
	0: GLD Harmonization Preamble
================================================================================================*/

/* -----------------------------------------------------------------------
<_Program name_>				PAK_2014_LFS_v01_M_v01_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata MP 16.1 <_Application_>
<_Author(s)_>					Wolrd Bank Job's Group </_Author(s)_>
<_Date created_>				2022-05-28 </_Date created_>
-------------------------------------------------------------------------
<_Country_>						Pakistan(PAK) </_Country_>
<_Survey Title_>				Labour Force Survey </_Survey Title_>
<_Survey Year_>					2014 </_Survey Year_>
<_Study ID_>					PAK_2014_LFS_v01_M </_Study ID_>
<_Data collection from (M/Y)_>	[July/2014] </_Data collection from (M/Y)_>
<_Data collection to (M/Y)_>	[June/2015] </_Data collection to (M/Y)_>
<_Source of dataset_> 			Pakistan Bureau of Statistics </_Source of dataset_>
								https://www.pbs.gov.pk/content/microdata
<_Sample size (HH)_> 			41,627 </_Sample size (HH)_>
<_Sample size (IND)_> 			264,136 </_Sample size (IND)_>
<_Sampling method_> 			Stratified two-stage cluster sampling method </_Sampling method_>
<_Geographic coverage_> 		Four major provinces plus Islamabad. </_Geographic coverage_>
<_Currency_> 					Pakistani Rupee </_Currency_>
-----------------------------------------------------------------------
<_ICLS Version_>				ICLS 13 </_ICLS Version_>
<_ISCED Version_>				ISCED-2011 </_ISCED Version_>
<_ISCO Version_>				ISCO-08 </_ISCO Version_>
<_OCCUP National_>				PSCO 2015 </_OCCUP National_>
<_ISIC Version_>				ISIC Rev.4 </_ISIC Version_>
<_INDUS National_>				PSIC 2010 </_INDUS National_>
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

local 	drive 	`"Z"'
local 	cty 	`"PAK"'
local 	usr		`"573465_JT"'
local 	surv_yr `"2014"'
local 	year 	"`drive':\GLD-Harmonization\\`usr'\\`cty'\\`cty'_`surv_yr'_LFS"
local 	main	"`year'\\`cty'_`surv_yr'_LFS_v01_M"
local 	stata	"`main'\data\stata"
local 	gld 	"`year'\\`cty'_`surv_yr'_LFS_v01_M_v01_A_GLD"
local 	i2d2	"`year'\\`cty'_`surv_yr'_LFS_v01_M_v01_A_I2D2"
local 	code 	"`gld'\Programs"
local 	id_data "`gld'\Data\Harmonized"

local input "`stata'"
local output "`id_data'"


*----------1.3: Database assembly------------------------------*

* All steps necessary to merge datasets (if several) to have all elements needed to produce
* harmonized output in a single file

	use "`input'\lfs2014-15.dta", clear

/*%%=============================================================================================
	2: Survey & ID
================================================================================================*/

{

*<_countrycode_>
	gen str4 countrycode="PAK"
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
	gen icls_v="ICLS-13"
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
	gen int year=2014
	label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen str3 vermast="V01"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen str3 veralt="V01"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen harmonization="GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	gen int_year=2014
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen int_month=7
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
	tostring PROCESS_CODE, gen(Prcode)
	gen hhid=Prcode
	label var hhid "Household id"
*</_hhid_>


*<_pid_>
	gen person_id=SEC4_COL1
	tostring person_id, replace format(%02.0f)
	egen str12 pid=concat(hhid person_id), p("0")
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
	gen weight=new_weight
	label var weight "Household sampling weight"
*</_weight_>


*<_psu_>
	gen str3 psu=substr(Prcode,7,2)
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen str2 ssu=substr(Prcode, 9, 2)
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	gen str2 stratum=substr(Prcode,2,2)
	destring stratum, gen(strata)
	label var strata "Strata"
*</_strata_>


*<_wave_>
	gen wave=SURVEY_PERIOD
	label var wave "Survey wave"
*</_wave_>

}

/*%%=============================================================================================
	3: Geography
================================================================================================*/

{

*<_urban_>
	gen str1 urban=substr(Prcode,5,1)
	destring urban, replace
	recode urban 1=0 2=1 3=.
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
	gen subnatid1=substr(Prcode,1,1)
	destring subnatid1, replace
	label de lblsubnatid1 1 "1-Khyber/Pakhtoonkhua" 2 "2-Punjab" 3 "3-Sindh" 4 "4-Balochistan" 5 "5-Federally Administered Tribal Areas" 6 "6-Islamabad" 7 "7-Gilgit-Baltistian" 8 "8-AJ & Kashmir"
	label values subnatid1 lblsubnatid1
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	gen city_code=substr(Prcode,1,3)
	destring city_code, replace
	merge m:m city_code using "`stata'\PAK_city_code_2014.dta"
	drop if _merge==2
	egen city_fullname=concat(city_code city_name_unite), punct(-)
	labmask city_code, values(city_fullname)
	rename city_code subnatid2
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	gen byte subnatid3=.
	label de lblsubnatid3 1 "1 - Name"
	label values subnatid3 lblsubnatid3
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
	decode subnatid1, gen(province)
	gen province2=substr(province,3,.)
	egen subnatidsurvey=concat(urban province2),p(-)
	label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>


/* <_subnatid1_prev>
	subnatid1_prev is coded as missing unless the classification used for subnatid1 has changed since the previous survey.
</_subnatid1_prev> */


*<_subnatid1_prev_>
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
	gen member_count=1 if SEC4_COL2<8
	replace member_count=0 if mi(member_count)
	bys hhid: egen byte hsize=sum(member_count)
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen age=SEC4_COL6
	replace age=98 if age>98 & age!=.
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male=SEC4_COL5
	recode male 2=0
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen byte relationharm=SEC4_COL2
	recode relationharm 4=3 5=4 6 7=5 8 9=6
	replace relationharm=1 if pid=="4212100315009" 
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs=SEC4_COL2
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital=SEC4_COL7
	recode marital 2=1 1=2 3=5 
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	gen eye_dsablty=.
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty=.
	label var eye_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty=.
	label var eye_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord=.
	label var eye_dsablty "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty=.
	label var eye_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty=.
	label var eye_dsablty "Disability related to communicating"
*</_comm_dsablty_>

}


/*%%=============================================================================================
	5: Migration
================================================================================================*/


{

*<_migrated_mod_age_>
	gen migrated_mod_age=10
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time=99
	label var migrated_ref_time "Reference time applied to migration questions"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen migrated_binary=cond(SEC4_COL15==1, 0, 1)
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	replace migrated_binary=. if age<migrated_mod_age
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


/* <_migrated_years_note>
   Information is on years living in current place (which is equal
   to years since left previous residence). However, info is 
   code 2 for less than a year,
   code 3 to 6 for 1 to 4 years,
   code 7 for 5 to 9 years,
   code 8 for 10 or more years

   Code 0.5 for less than a year, half-point for 5-9 window (e.g., 7)
   and code 10 as a lower bound for the 10+ option  
</_migrated_years_note> */


*<_migrated_years_>
   gen migrated_years=.
   replace migrated_years=0.5 if SEC4_COL15==2
   replace migrated_years =SEC4_COL15-2 if inrange(SEC4_COL15,3,6)
   replace migrated_years=7 if SEC4_COL15==7
   replace migrated_years=10 if SEC4_COL15==8
   replace migrated_years=. if migrated_binary!=1
   replace migrated_years=. if age<migrated_mod_age
   label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban=SEC4_COL17
	recode migrated_from_urban 0=. 1=0 2=1 
	replace migrated_from_urban=. if migrated_binary!=1
	replace migrated_from_urban=. if age<migrated_mod_age
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen migrated_from_cat=.
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country"
	replace migrated_from_cat=. if migrated_binary!=1
	replace migrated_from_cat=. if age<migrated_mod_age
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen migrated_from_code=.
	replace migrated_from_code=. if migrated_binary!=1
	replace migrated_from_code=. if age<migrated_mod_age
	*label de lblmigrated_from_code
	*label values migrated_from_code lblmigrated_from_code
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country=.
	replace migrated_from_country=. if migrated_binary!=1
	replace migrated_from_country=. if age<migrated_mod_age
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason=SEC4_COL18
	recode migrated_reason (1/4 6=3) (5=2) (8/11=1) (14=4) (7 12/13 15=5) 
	replace migrated_reason=. if migrated_binary!=1
	replace migrated_reason=. if age<migrated_mod_age
	label de lblmigrated_reason 1 "Family reasons" 2 "Educational reasons" 3 "Employment" 4 "Forced (political reasons, natural disaster, …)" 5 "Other reasons"
	label values migrated_reason lblmigrated_reason
	label var migrated_reason "Reason for migrating"
*</_migrated_reason_>


}


/*%%=============================================================================================
	6: Education
================================================================================================*/


{

/*<_ed_mod_age_note>

Note that in the questionnaire, questions for literacy and education level are asked to 
all respondents without age restriction. 

But the current enrolment question is asked to people aged 5 and above. 
Tabbing age and literacy or age and education level will show that the two questions, 
literacy and education level were actually asked to people aged 5 and above as well instead of 
all people.

**Here is just part of an exmple of tabbing age and literacy, 0-15 years old
and all ages above 15 are NOT missed.**

. tab age SEC4_COL8, m

Individual |            SEC4_COL8
       age |         1          2          . |     Total
-----------+---------------------------------+----------
         0 |         0          0      5,385 |     5,385 
         1 |         0          0      6,179 |     6,179 
         2 |         0          0      8,038 |     8,038 
         3 |         0          0      8,554 |     8,554 
         4 |         0          0      8,662 |     8,662 
         5 |       683      7,933          0 |     8,616 
         6 |     1,822      6,585          0 |     8,407 
         7 |     2,855      5,560          0 |     8,415 
         8 |     4,416      4,995          0 |     9,411 
         9 |     3,364      2,591          0 |     5,955 
        10 |     6,411      2,629          0 |     9,040 
        11 |     3,802      1,103          0 |     4,905 
        12 |     6,396      1,898          0 |     8,294 
        13 |     4,591      1,293          0 |     5,884 
        14 |     5,589      1,764          0 |     7,353 
        15 |     4,525      1,419          0 |     5,944 


Therefore, the ed_mod_age was set to 5 as oppsed to 0.		
*<_ed_mod_age_note>*/


*<_ed_mod_age_>
	gen byte ed_mod_age=5
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


*<_school_>
	gen byte school=.
	replace school=0 if SEC4_COL10<=3
	replace school=1 if SEC4_COL10>3 & SEC4_COL10!=.
	replace school=. if age<ed_mod_age & age!=.
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen byte literacy=SEC4_COL8
	recode literacy 2=0
	replace literacy=. if age<ed_mod_age & age!=.
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen byte educy=.
	replace educy=0 if SEC4_COL9<=3
	replace educy=5 if SEC4_COL9==4
	replace educy=8 if SEC4_COL9==5
	replace educy=10 if SEC4_COL9==6
	replace educy=12 if SEC4_COL9==7
	replace educy=16 if SEC4_COL9==8
	replace educy=17 if SEC4_COL9==9
	replace educy=16 if SEC4_COL9==10
	replace educy=16 if SEC4_COL9==11
	replace educy=16 if SEC4_COL9==12
	replace educy=19 if SEC4_COL9==13
	replace educy=20 if SEC4_COL9==14
	replace educy=22 if SEC4_COL9==15
	replace educy=. if age<5 | !inrange(SEC4_COL9, 1, 15)
	replace educy=age if educy>age & !mi(educy) & !mi(age)
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7=SEC4_COL9
	recode educat7 (3=2) (4=3) (5/6=4) (8/15=7) 
	replace educat7=5 if SEC4_COL9==7&SEC4_COL10==1
	replace educat7=7 if SEC4_COL9==7&inrange(SEC4_COL10,8,15) 
	replace educat7=. if age<ed_mod_age 
	label var educat7 "Level of education 1"
	la de lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete"
	label values educat7 lbleducat7
*</_educat7_>


*<_educat5_>
	gen byte educat5=educat7
	recode educat5 (4=3) (5=4) (6 7=5)
	label var educat5 "Level of education 2"
	la de lbleducat5 1 "No education" 2 "Primary incomplete"  3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>


*<_educat4_>
	gen byte educat4=educat7
	recode educat4 (2 3 4=2) (5=3) (6 7=4)
	label var educat4 "Level of education 3"
	la de lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 lbleducat4
*</_educat4_>


*<_educat_orig_>
	gen educat_orig=SEC4_COL9
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
	gen educat_isced=SEC4_COL9
	replace educat_isced=. if !inrange(SEC4_COL9, 1, 15)
	recode educat_isced 1=. 2/3=20 3=100 4/6=244 7=344 8/12=660 13/14=760 15=860
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
	gen vocational=SEC4_COL11
	recode vocational (10/19=1) (20=0) 
	la de vocationallbl 1 "Yes" 0 "No"
	la values vocational vocationallbl
	label var vocational "Ever received vocational training"
*</_vocational_>


*<_vocational_type_>
	gen vocational_type=SEC4_COL11
	recode vocational_type (10/14=1) (15/19=2)
	label de lblvocational_type 1 "Inside Enterprise" 2 "External"
	label values vocational_type lblvocational_type
	label var vocational_type "Type of vocational training"
*</_vocational_type_>


/*<_vocational_length_l_>

Vocational training is asked in "weeks" in the questionnaire and it is not answered 
with a range, but a specific number of weeks. Therefore, the upper and lower limits
are the same here.

<_vocational_length_l_>*/


*<_vocational_length_l_>
	gen vocational_length_l=SEC4_COL13
	label var vocational_length_l "Length of training, lower limit"
*</_vocational_length_l_>


*<_vocational_length_u_>
	gen vocational_length_u=SEC4_COL13
	label var vocational_length_u "Length of training, upper limit"
*</_vocational_length_u_>


*<_vocational_field_orig_>
	gen code=SEC4_COL12
	merge m:1 code using "`stata'\PAK_training_code.dta", gen(_merge1)
	drop if _merge1==2
	gen vocational_field_orig=code
	labmask vocational_field_orig, values(training_field)
	label var vocational_field_orig "Field of training"
*</_vocational_field_orig_>


*<_vocational_financed_>
	gen vocational_financed=SEC4_COL14
	recode vocational_financed (2=4) (3=2) (4=5)
 	label de lblvocational_financed 1 "Employer" 2 "Government" 3 "Mixed Employer/Government" 4 "Own funds" 5 "Other"
	label var vocational_financed "How training was financed"
*</_vocational_financed_>

}

/*%%=============================================================================================
	8: Labour
================================================================================================*/

*<_minlaborage_>
	gen byte minlaborage=10 
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
	
/*<_lstatus_note>

Employed if work for profit or in a farm business; 
Unemployed if seeking (SEC9_COL1==1) and available [!mi(SEC9_COL5)] and unavailable to work
only because 
- illness
- will take a job within a month
- temporarily laid off
- apprentice and not willing to work
*<_lstatus_note>*/	

	
*<_lstatus_>
	gen byte lstatus=.
	replace lstatus=1 if inlist(1, SEC5_COL2, SEC5_COL3) | inlist(SEC5_COL4,1,2)
	replace lstatus=2 if lstatus!=1 & [SEC9_COL1==1 | !mi(SEC9_COL5) | inrange(SEC9_COL6,1,4)]
	replace lstatus=3 if lstatus==.
	replace lstatus=. if age<minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


/*<_potential_lf_>
Note: var "potential_lf" only takes value if the respondent is not in labor force. (lstatus==3)

"potential_lf" = 1 if the person is
1)available but not searching or SEC9_COL1==2 & inrange(SEC9_COL4, 1, 6)
2)searching but not immediately available to work or SEC9_COL1==1 & SEC9_COL4==7
</_potential_lf_>*/


*<_potential_lf_>
	gen byte potential_lf=.
	replace potential_lf=0 if lstatus==3
	replace potential_lf=1 if [SEC9_COL1==2 & inrange(SEC9_COL4, 1, 6)] | [SEC9_COL1==1 & SEC9_COL4==7]
	replace potential_lf=0 if [SEC9_COL1==1 & inrange(SEC9_COL4, 1, 6)] | [SEC9_COL1==2 & SEC9_COL4==7]
	replace potential_lf=. if age < minlaborage
	replace potential_lf=. if lstatus !=3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen byte underemployment=.
	replace underemployment=1 if SEC6_COL2==1
	replace underemployment=0 if SEC6_COL2==2
	replace underemployment=. if age < minlaborage
	replace underemployment=. if lstatus!=1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason=SEC9_COL6
	recode nlfreason (5=1) (6=2) (7=3) (11=4) (1/4 8/10 12=5)
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


/*<_unempldur_l_>

Unemployment duration in 2014 is a specific number of weeks/months/years. So the 
upper and lower bonds are the same.

*<_unempldur_l_>*/


*<_unempldur_l_>
	gen byte unempldur_l=SEC9_COL3_2
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=SEC9_COL3_2
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte empstat=.
	replace empstat=1 if SEC5_COL8<=4 
	replace empstat=2 if SEC5_COL8==11 | SEC5_COL8==12 
	replace empstat=3 if SEC5_COL8==5
	replace empstat=4 if (SEC5_COL8>=6 & SEC5_COL8<=10) | SEC5_COL8==13
	replace empstat=5 if SEC5_COL8==14
	replace empstat=. if !inrange(SEC5_COL8, 1, 14)
	replace empstat=. if lstatus!=1
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec=SEC5_COL11
	recode ocusec (1/3=1) (4=3) (5/9=2) (10=4)
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig=SEC5_COL10
	replace industry_orig=. if lstatus!=1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	gen industrycat_isic=SEC5_COL10
	tostring industrycat_isic, replace format(%04.0f)
	replace industrycat_isic="" if lstatus!=1 | industrycat_isic=="."
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen byte industrycat10=floor(SEC5_COL10/100)
	recode industrycat10 (1/3=1) (5/9=2) (10/33=3) (35/39=4) (41/43=5) (45/47 55/56=6) (49/53 58/63=7) (64/82=8) (84=9) (85/99=10)
	replace industrycat10=. if lstatus!=1
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
*</_industrycat10_>


*<_industrycat4_>
	gen byte industrycat4=industrycat10
	recode industrycat4 (1=1)(2 3 4 5=2)(6 7 8 9=3)(10=4)
	label var industrycat4 "1 digit industry classification (Broad Economic Activities), primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
	gen occup_orig=SEC5_COL9
	replace occup_orig=. if lstatus!=1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	gen occup_isco=SEC5_COL9
	tostring occup_isco, replace format(%04.0f)
	replace occup_isco="" if lstatus!=1 | occup_isco=="."
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_skill_>
	gen skill_level=substr(occup_isco, 1, 1)
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
	  gen occup=skill_level
	  replace occup=. if lstatus!=1
	  recode occup (0=10) 
	  label var occup "1 digit occupational classification, primary job 7 day recall"
  	  la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	  label values occup lbloccup
*</_occup_>


*<_wage_no_compen_>
	gen last_week=SEC7_COL33
	gen last_month=SEC7_COL43
	foreach v of varlist last_*{
		replace `v'=0 if SEC7_COL33>0 & SEC7_COL43>0 & !mi(SEC7_COL33) & !mi(SEC7_COL43)
		replace `v'=. if lstatus!=1
	}
	egen double wage_no_compen=rowtotal(last_week last_month), missing
	replace wage_no_compen=0 if empstat==2
	replace wage_no_compen=. if lstatus!=1
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
	gen byte unitwage=.
	replace unitwage=2 if wage_no_compen==SEC7_COL33
	replace unitwage=5 if wage_no_compen==SEC7_COL43
	replace unitwage=10 if wage_no_compen>SEC7_COL43&!mi(wage_no_compen)
	replace unitwage=. if lstatus!=1
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours=SEC5_COL17_1
	replace whours=. if lstatus!=1
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
	gen byte contract=SEC7_COL1
	recode contract (2/6=1) (7=0)
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
	gen byte socialsec=.
	replace socialsec=. if lstatus!=1
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec 1 "With social security" 0 "Without social secturity"
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen byte union=.
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	gen byte firmsize_l=SEC5_COL13
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u=SEC5_COL13
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels

{
*<_empstat_2_>
	gen byte empstat_2=SEC5_COL19
	recode empstat_2 (1/4=1) (11/12=2) (5=3) (6/10 13=4) (14=5)
	replace empstat_2=. if SEC5_COL18!=1
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2=SEC5_COL22
	recode ocusec_2 (1/3=1) (4 6=3) (5/9=2) (10=4)
	replace ocusec_2=. if SEC5_COL18!=1
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	la de lblocusec_2 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_2 lblocusec_2
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2=SEC5_COL21
	replace industry_orig_2=. if SEC5_COL18!=1
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	gen industrycat_isic_2=SEC5_COL21
	tostring industrycat_isic_2, replace format(%04.0f)
	replace industrycat_isic_2="" if SEC5_COL18!=1 | mi(SEC5_COL21) | industrycat_isic_2=="."
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen byte industrycat10_2=SEC5_COL21
	recode industrycat10_2 1/3=1 5/9=2 10/14=2 11/33=3 35/39=4 41/43=5 45/47=6 49/63=7 64/82=8 84=9 85/99=10
	replace industrycat10_2=. if SEC5_COL18!=1
	label var industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
	label values industrycat10_2 lblindustrycat10
*</_industrycat10_2_>


*<_industrycat4_2_>
	gen byte industrycat4_2=industrycat10_2
	recode industrycat4_2 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_2 "1 digit industry classification (Broad Economic Activities), secondary job 7 day recall"
	label values industrycat4_2 lblindustrycat4
*</_industrycat4_2_>


*<_occup_orig_2_>
	gen occup_orig_2=SEC5_COL20
	replace occup_orig_2=. if SEC5_COL18!=1
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen occup_isco_2=SEC5_COL20
	tostring occup_isco_2, replace format(%04.0f)
	replace occup_isco_2="" if SEC5_COL18!=1 | mi(SEC5_COL20) | occup_isco_2=="."
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_skill_2_>
	gen skill_level_2=substr(occup_isco_2, 1, 1)
	destring skill_level_2, replace
	gen occup_skill_2=.
	replace occup_skill_2=1 if skill_level_2==9
	replace occup_skill_2=2 if inrange(skill_level_2, 4, 8)
	replace occup_skill_2=3 if inrange(skill_level_2, 1, 3)
	replace occup_skill_2=. if skill_level_2==0 | SEC5_COL18!=1
	label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>


*<_occup_2_>
	gen occup_2=substr(occup_isco_2, 1, 1)
	destring occup_2, replace
	recode occup_2 (0=10)
	replace occup_2=. if SEC5_COL18!=1
	label var occup_2 "1 digit occupational classification secondary job 7 day recall"
	label values occup_2 lbloccup
*</_occup_2_>


*<_wage_no_compen_2_>
	gen double wage_no_compen_2=.
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2=.
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
	gen whours_2=SEC5_COL26
	replace whours_2=. if SEC5_COL18!=1
	label var whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>


*<_wmonths_2_>
	gen wmonths_2=.
	label var wmonths_2 "Months of work in past 12 months secondary job 7 day recall"
*</_wmonths_2_>


*<_wage_total_2_>
	gen wage_total_2=.
	label var wage_total_2 "Annualized total wage secondary job 7 day recall"
*</_wage_total_2_>


*<_firmsize_l_2_>
	gen byte firmsize_l_2=SEC5_COL24
	replace firmsize_l_2=. if SEC5_COL18!=1
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	gen byte firmsize_u_2=SEC5_COL24
	replace firmsize_l_2=. if SEC5_COL18!=1
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
	replace lstatus_year=. if age < minlaborage & age != .
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>

*<_potential_lf_year_>
	gen byte potential_lf_year=.
	replace potential_lf_year=. if age < minlaborage & age != .
	replace potential_lf_year = . if lstatus_year != 3
	label var potential_lf_year "Potential labour force status"
	la de lblpotential_lf_year 0 "No" 1 "Yes"
	label values potential_lf_year lblpotential_lf_year
*</_potential_lf_year_>


*<_underemployment_year_>
	gen byte underemployment_year =.
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
	gen industrycat_isic_year=.
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
	gen occup_isco_year=.
	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_skill_year_>
	gen occup_skill_year=.
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
	replace njobs=1 if SEC5_COL18==2
	replace njobs=2 if SEC5_COL18==1 & SEC5_COL27==3
	replace njobs=3 if SEC5_COL18==1 & SEC5_COL27==1
	replace njobs=4 if SEC5_COL18==1 & SEC5_COL27==2
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

save "`output'\PAK_2014_LFS_v01_M_v01_A_GLD_ALL.dta", replace

*</_% SAVE_>
