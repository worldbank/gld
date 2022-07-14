
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				[KEN_2020_KCHSP_V01_M_V01_A_GLD] </_Program name_>
<_Application_>					[STATA 16] <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2022-07-08 </_Date created_>

-------------------------------------------------------------------------

<_Country_>					[Kenya (KEN)] </_Country_>
<_Survey Title_>				[KCHSP Kenya continous household survey programme] </_Survey Title_>
<_Survey Year_>					[2020] </_Survey Year_>
<_Study ID_>					[N/A] </_Study ID_>
<_Data collection from_>			[01/2020] </_Data collection from_>
<_Data collection to_>				[12/2020] </_Data collection to_>
<_Source of dataset_> 				[Kenya National Bureau of Statistics] </_Source of dataset_>
<_Sample size (HH)_> 				[] </_Sample size (HH)_>
<_Sample size (IND)_> 				[] </_Sample size (IND)_>
<_Sampling method_> 				[N/A] </_Sampling method_>
<_Geographic coverage_> 			[The survey covers all the Counties in Kenya based on the following levels National, Urban, Rural and County] </_Geographic coverage_>
<_Currency_> 					[Kenyan Shilling] </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS-13 </_ICLS Version_>
<_ISCED Version_>				ISCED-2011 </_ISCED Version_>
<_ISCO Version_>				N/A </_ISCO Version_>
<_OCCUP National_>				KNOCS kenya national occupation survey </_OCCUP National_>
<_ISIC Version_>				ISIC REV. 4 </_ISIC Version_>
<_INDUS National_>				N/A </_INDUS National_>

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

*----------1.2: Set directories------------------------------*

local path_in "Z:\GLD-Harmonization\582018_AQ\KEN\KEN_2020_KCHSP\KEN_2020_KCHSP_v01_M\Data\Stata"
local path_output "Z:\GLD-Harmonization\582018_AQ\KEN\KEN_2020_KCHSP\KEN_2020_KCHSP_v01_M_v01_A_GLD\Data\Harmonized\"

*----------1.3: Database assembly------------------------------*

* All steps necessary to merge datasets (if several) to have all elements needed to produce
* harmonized output in a single file

use "`path_in'\kchsp2020_annual_hhm.dta"
merge m:1 hhid qrt clid using "`path_in'\kchsp2020_annual_hh.dta", force

save "`path_in'\data_2020_final.dta", replace


/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode = "KEN"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "KCHSP"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "Household survey "
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	gen icls_v = "ICLS-[13]"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	gen isced_version = "isced_2011"
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
	gen isco_version = ""
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
	gen vermast = "V01"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen veralt = ""
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen harmonization = "GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	gen int_year=.
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
	tostring hhid, gen(hhid_str) format (%02.0f)
	tostring clid, gen(clid_str) format (%04.0f)
	tostring qrt, gen(qrt_str) format (%01.0f)
	drop hhid
	egen hhid= concat(hhid_str clid_str qrt_str)
	drop hhid_str clid_str qrt_str
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	tostring b01, gen(b_str) format (%02.0f)
	egen  pid = concat(hhid b_str)
	isid pid 
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
	gen weight = .
	label var weight "Survey sampling weight"
*</_weight_>


*<_psu_>
	gen psu = .
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = .
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	gen strata = .
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
	gen byte urban=resid
	recode urban 1=0 2=1
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
/* <_subnatid1_note>

	The variable is string and country-specific categorical. Numeric entries are coded in string format using the following naming convention: “1 – Hatay”. That is, the variable itself is to be string, not a labelled numeric vector. 
	
	Example of entries would be "1 - Alaska",  "2 - Arkansas", ...

</_subnatid1_note> */
	tostring a01, gen(subnatid1)
	replace subnatid1=" 1 - Mombasa "  if subnatid1=="1"
	replace subnatid1="2 - Kwale"  if subnatid1=="2"
	replace subnatid1="3 - Kilifi"  if subnatid1=="3"
	replace subnatid1="4 - Tana River"  if subnatid1=="4"
	replace subnatid1="5 - Lamu"  if subnatid1=="5"
	replace subnatid1="6 - Taita Taveta"  if subnatid1=="6"
	replace subnatid1="7 - Garissa"  if subnatid1=="7"
	replace subnatid1="8 - Wajir"  if subnatid1=="8"
	replace subnatid1="9 - Mandera" if subnatid1=="9"
	replace subnatid1= "10 - Marsabit"  if subnatid1=="10"
	replace subnatid1= "11 - Isiolo"  if subnatid1=="11"
	replace subnatid1= "12 - Meru " if subnatid1=="12"
	replace subnatid1="13 - Tharaka Nithi" if subnatid1=="13"
	replace subnatid1= " 14 - Embu"  if subnatid1=="14"
	replace subnatid1= "15 - Kitui"  if subnatid1=="15"
	replace subnatid1= " 16 - Machakos " if subnatid1=="16"
	replace subnatid1="17 - Makueni"  if subnatid1=="17"
	replace subnatid1=" 18 - Nyandarua" if subnatid1=="18"
	replace subnatid1= "19 - Nyeri"  if subnatid1=="19"
	replace subnatid1=   "20 - Kirinyaga" if subnatid1=="20"
	replace subnatid1= "21 - Murang'a" if subnatid1=="21"
	replace subnatid1="22 - Kiambu "  if subnatid1=="22"
	replace subnatid1= "23 - Turkana" if subnatid1=="23"
	replace subnatid1="24 - West Pokot" if subnatid1=="24"
	replace subnatid1="25 - Samburu" if subnatid1=="25"
	replace subnatid1="26 - Trans Nzoia" if subnatid1=="26"
	replace subnatid1= "27 - Uasin Gishu" if subnatid1=="27"
	replace subnatid1= "28 - Elgeyo Marakwet" if subnatid1=="28"
	replace subnatid1= "29 - Nandi" if subnatid1=="29"
	replace subnatid1= "30 - Baringo" if subnatid1=="30"
	replace subnatid1= "31 - Laikipia" if subnatid1=="31"
	replace subnatid1= "32 - Nakuru"  if subnatid1=="32"
	replace subnatid1=   "33 - Narok"  if subnatid1=="33"
	replace subnatid1=   "34 - Kajiado" if subnatid1=="34"
	replace subnatid1=   "35 - Kericho" if subnatid1=="35"
	replace subnatid1=  "36 - Bomet"  if subnatid1=="36"
	replace subnatid1=  "37 - Kakamega"  if subnatid1=="37"
	replace subnatid1=  "38 - Vihiga"  if subnatid1=="38"
	replace subnatid1= "39 - Bungoma"  if subnatid1=="39"
	replace subnatid1=  "40 - Busia" if subnatid1=="40"
	replace subnatid1= "41 - Siaya" if subnatid1=="41"
	replace subnatid1=   "42 - Kisumu" if subnatid1=="42"
	replace subnatid1=  "43 - Homa Bay" if subnatid1=="43"
	replace subnatid1= "44 - Migori" if subnatid1=="44"
	replace subnatid1="45 - Kisii" if subnatid1=="45"
	replace subnatid1="46 - Nyamira" if subnatid1=="46"
	replace subnatid1= "47 - Nairobi" if subnatid1=="47"
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
	gen str subnatidsurvey = "subnatid1"
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
	gen hsize = a12
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen age = b05_years
	replace age=. if b05_years>112
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = b04
	recode male 2=0
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen relationharm = b03
	recode relationharm 4/5=5 6=4 7/10=5 11=6
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = b03
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital = b07
	recode marital 1/2=1 4/5=4 6=5 7=2
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
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen migrated_years = round(2020-b12_year)
	recode migrated_years 1020=. 1021=.
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
*the codes next to the name come from subnatid1 yet the other in the variable data was different hence the replace commands.
	gen migrated_from_code = ""
	replace migrated_from_code= "47 - Nairobi" if b11==1
	replace migrated_from_code= "18 - Nyandarua"  if b11==2
	replace migrated_from_code= "19 - Nyeri"  if b11==3
	replace migrated_from_code=   "20 - Kirinyaga" if b11==4
	replace migrated_from_code= "21 - Murang'a" if b11==5
	replace migrated_from_code="22 - Kiambu "  if b11==6
	replace migrated_from_code=" 1 - Mombasa "  if b11==7
	replace migrated_from_code="2 - Kwale"  if b11==8
	replace migrated_from_code="3 - Kilifi"  if b11==9
	replace migrated_from_code="4 - Tana River"  if b11==10
	replace migrated_from_code="5 - Lamu"  if b11==11
	replace migrated_from_code="6 - Taita Taveta"  if b11==12
	replace migrated_from_code= "10 - Marsabit"  if b11==13
	replace migrated_from_code= "11 - Isiolo"  if b11==14
	replace migrated_from_code= "12 - Meru " if b11==15
	replace migrated_from_code="13 - Tharaka Nithi" if b11==16
	replace migrated_from_code= " 14 - Embu"  if b11==17
	replace migrated_from_code= "15 - Kitui"  if b11==18
	replace migrated_from_code= " 16 - Machakos " if b11==19
	replace migrated_from_code="17 - Makueni"  if b11==20
	replace migrated_from_code="7 - Garissa"  if b11==21
	replace migrated_from_code="8 - Wajir"  if b11==22
	replace migrated_from_code="9 - Mandera" if b11==23
	replace migrated_from_code= "41 - Siaya" if b11==24
	replace migrated_from_code=   "42 - Kisumu" if b11==25
	replace migrated_from_code=  "43 - Homa Bay" if b11==26
	replace migrated_from_code= "44 - Migori" if b11==27
	replace migrated_from_code="45 - Kisii" if b11==28
	replace migrated_from_code="46 - Nyamira" if b11==29
	replace migrated_from_code= "23 - Turkana" if b11==30
	replace migrated_from_code="24 - West Pokot" if b11==31
	replace migrated_from_code="25 - Samburu" if b11==32
	replace migrated_from_code="26 - Trans Nzoia" if b11==33
	replace migrated_from_code= "30 - Baringo" if b11==34
	replace migrated_from_code= "27 - Uasin Gishu" if b11==35
	replace migrated_from_code= "28 - Elgeyo Marakwet" if b11==36
	replace migrated_from_code= "29 - Nandi" if b11==37
	replace migrated_from_code= "31 - Laikipia" if b11==38
	replace migrated_from_code= "32 - Nakuru"  if b11==39
	replace migrated_from_code=   "33 - Narok"  if b11==40
	replace migrated_from_code=   "34 - Kajiado" if b11==41
	replace migrated_from_code=   "35 - Kericho" if b11==42
	replace migrated_from_code=  "36 - Bomet"  if b11==43
	replace migrated_from_code=  "37 - Kakamega"  if b11==44
	replace migrated_from_code=  "38 - Vihiga"  if b11==45
	replace migrated_from_code= "39 - Bungoma"  if b11==46
	replace migrated_from_code=  "40 - Busia" if b11==47
	*label de lblmigrated_from_code
	*label values migrated_from_code lblmigrated_from_code
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	decode b11, gen(helper_3)
	gen migrated_from_country= helper_3 if b11>47
	replace migrated_from_country="cote" if b11==60
	drop helper_3
	replace migrated_from_country = upper( migrated_from_country)
	replace migrated_from_country=substr(migrated_from_country,1,3)
	
	replace migrated_from_country="BHR" if  migrated_from_country=="BAH"
	replace migrated_from_country="CHL" if  migrated_from_country=="CHI"
	replace migrated_from_country="CRI" if  migrated_from_country=="COS"
	replace migrated_from_country="CIV" if  migrated_from_country=="COT"
	replace migrated_from_country="DNK" if  migrated_from_country=="DEN"
	replace migrated_from_country="MWI" if  migrated_from_country=="MAL"
	replace migrated_from_country="SDN" if  migrated_from_country=="SUD"
	replace migrated_from_country="TZA" if  migrated_from_country=="UNI"
	
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>

*<_migrated_reason_>
	gen migrated_reason = b13
	recode migrated_reason 1/3=3 4=5 5/6=1 7=2 8/9=5 10=5 11=4 96=5 98=.
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

gen byte ed_mod_age = 3
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school=c03
	recode school 2=0
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
	gen byte educy =.
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7 =c08
	recode educat7 22/32=7 34/36=6 97=1 99=. 1/7=2 8=3 12/14=4 15=5 16/21=6 33=3 34=5 35/36=6 37=5 9/10=4 11=5
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
	gen educat_orig = c08
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
	gen educat_isced = .
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
	gen byte minlaborage =5
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>

	gen byte lstatus = .
	replace lstatus = 1 if !missing(d11) // Answers question relative to employment
	replace lstatus = 2 if d15__16 == 0 & (!missing(d18) & d18 != 6) // Looking and available
	replace lstatus = 3 if d15__16 == 1 | (d15__16 == 0 & d18 == 6) // Now looking or looking but not available
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	*10 people in working age do not provide information for any labour question.
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = .
	replace potential_lf = 0 if lstatus == 3
	replace potential_lf = 1 if d15__16 == 0 & d18 == 6 // Those looking but not available
	replace potential_lf = 1 if d15__16 == 1 & (!missing(d18) & !inrange(d18,6,8)) // Those not looking but available
	replace potential_lf = . if age < minlaborage & age != .
	replace potential_lf = . if lstatus != 3
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
	gen byte nlfreason=d17
	recode nlfreason 8=1 4=2 2=4 17=3 1=5 3=5 5/7=5 9/16=5 18/19=5 96=5
	label var nlfreason "Reason not in the labor force" 
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	replace nlfreason=. if lstatus!=3
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l=.
	replace unempldur_l=0 if d20==1
	replace unempldur_l=2 if d20==2
	replace unempldur_l=4 if d20==3
	replace unempldur_l=7 if d20==4
	replace unempldur_l=13 if d20==5
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=.
	replace unempldur_u=1 if d20==1
	replace unempldur_u=3 if d20==2
	replace unempldur_u=6 if d20==3
	replace unempldur_u=12 if d20==4
	replace unempldur_u=. if d20==5
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	
	gen byte empstat=d13_primary
	encode d13_primaryother, gen (d13_helper_1)
	replace empstat=5 if inrange(d13_helper_1,1,10)
	replace empstat=5 if d13_helper_1==12
	recode empstat 2=1 8=2 5/7=5 96=5
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
	drop d13_helper_1
	replace empstat=. if lstatus!=1
*</_empstat_>


*<_ocusec_>
	gen byte ocusec = d24
	recode ocusec 5=3 1/4=1 6/7=1 8/20=2 96=2
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig = d23
	replace industry_orig="" if lstatus!=1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	gen industrycat_isic = string(d23_isic, "%04.0f")
	replace industrycat_isic="" if lstatus!=1
	replace industrycat_isic="8510" if d23_isic==8511
	replace industrycat_isic="8210" if d23_isic==9495
	label var industrycat_isic "ISIC code of primary job 7 day recall"
	replace industrycat_isic="" if lstatus!=1
*</_industrycat_isic_>


*<_industrycat10_>
	gen byte industrycat10 = .
	replace industrycat10 = 1 if inrange(d23_isic,111,322)
	replace industrycat10= 2 if inrange(d23_isic,710,990)
	replace industrycat10= 3 if inrange(d23_isic,1010,3320)
	replace industrycat10= 4 if inrange(d23_isic,3510,3830)
	replace industrycat10= 5 if inrange(d23_isic,4100,4390)
	replace industrycat10= 6 if inrange(d23_isic,4510,4799)
	replace industrycat10= 7 if inrange(d23_isic,4911,5320)
	replace industrycat10= 6 if inrange(d23_isic,5510,5630)
	replace industrycat10= 7 if inrange(d23_isic,5911,6399)
	replace industrycat10= 8 if inrange(d23_isic,6411,6820)
	replace industrycat10= 10 if inrange(d23_isic,6910,8299)
	replace industrycat10= 9 if inrange(d23_isic,8411,8430)
	replace industrycat10= 10 if inrange(d23_isic,8510,9900)
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
*the job classification is based on the national occupation classification
	gen occup_orig = d22_knocs
	replace occup_orig=. if lstatus!=1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	gen occup_isco = .
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	gen byte occup = .
	gen occup_help=floor(d22_knocs/100) if d22_knocs!=11
	replace occup_help=1 if d22_knocs==11
	replace occup=occup_help
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
	replace occup=. if lstatus!=1
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
	gen double wage_no_compen = d40_basic 
	replace wage_no_compen=. if lstatus!=1
	*around 3000 people informed they recieve a salary monthly but do not say how much.
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>

/* <_unitwage_note>
	Unitwage refers to the unit used to record wage_no_compen, *not* the unit of
	general wage payent. For example, PHL LFS asks about wage periodicity, then
	asks for basic daily pay. The value of that pay would be wage_no_compen,
	while unitwage is code 1 ("Daily") for all, regardless of the periodicity.
</_unitwage_note> */

	gen byte unitwage = 1
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	replace unitwage=. if lstatus!=1
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours =d27
	recode whours 0=.
	replace whours=. if d27>84
	replace whours=. if lstatus!=1
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	gen wmonths = d31
	recode wmonths 0=.
	replace wmonths=. if lstatus!=1
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
/* <_wage_total_note>

	Use gross wages when available and net wages only when gross wages are not available.
	This is done to make it easy to compare earnings in formal and informal sectors.

</_wage_total_note> */
	gen wage_total = (wage_no_compen+d41+d42+d43+d44)
	replace wage_total=. if lstatus!=1
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen byte contract = d47_type
	recode contract 4=0 1/3=1
	*on the basis that any agreemtn verbal, implied or written between the parties in considered contract.
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
	replace contract=. if lstatus!=1
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
	gen byte union = d50
	recode union 2=0
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
	replace union=. if lstatus!=1
*</_union_>


*<_firmsize_l_>
	gen byte firmsize_l = .
	replace firmsize_l=0 if d25==1
	replace firmsize_l=1 if d25==2
	replace firmsize_l=2 if d25==3
	replace firmsize_l=5 if d25==4
	replace firmsize_l=10 if d25==5
	replace firmsize_l=20 if d25==6
	replace firmsize_l=50 if d25==7
	replace firmsize_l=100 if d25==8
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u= .
	replace firmsize_u=. if d25==1
	replace firmsize_u=. if d25==2
	replace firmsize_u=4 if d25==3
	replace firmsize_u=9 if d25==4
	replace firmsize_u=19 if d25==5
	replace firmsize_u=49 if d25==6
	replace firmsize_u=99 if d25==7
	replace firmsize_u=. if d25==8
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}



*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen byte empstat_2=d13_secondary
	encode d13_secondaryother, gen (d13_helper)
	replace empstat_2=1 if d13_helper==1
	replace empstat_2=5 if d13_helper==2
	replace empstat_2=4 if d13_helper==3
	recode empstat_2 2=1 5/6=5 8=2 96=5
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2 = d57
	recode ocusec_2 5=3 6=1 7=1 8/20=2 96=2
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2 = d56_code
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	gen industrycat_isic_2 = string(d56_code, "%04.0f")
	replace industrycat_isic_2="" if lstatus!=1
	replace industrycat_isic_2="" if industrycat_isic_2=="."
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen byte industrycat10_2 = .
	replace industrycat10_2 = 1 if inrange(d56_code,111,322)
	replace industrycat10_2= 2 if inrange(d56_code,710,990)
	replace industrycat10_2= 3 if inrange(d56_code,1010,3320)
	replace industrycat10_2= 4 if inrange(d56_code,3510,3830)
	replace industrycat10_2= 5 if inrange(d56_code,4100,4390)
	replace industrycat10_2= 6 if inrange(d56_code,4510,4799)
	replace industrycat10_2= 7 if inrange(d56_code,4911,5320)
	replace industrycat10_2= 6 if inrange(d56_code,5510,5630)
	replace industrycat10_2= 7 if inrange(d56_code,5911,6399)
	replace industrycat10_2= 8 if inrange(d56_code,6411,6820)
	replace industrycat10_2= 10 if inrange(d56_code,6910,8299)
	replace industrycat10_2= 9 if inrange(d56_code,8411,8430)
	replace industrycat10_2= 10 if inrange(d56_code,8510,9900)
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
	gen occup_orig_2 = d55_code
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen occup_isco_2 = ""
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_2_>
	gen byte occup_2 = .
	gen occup_help_2=floor(d55_code/100) if d55_code!=11
	replace occup_help_2=1 if d55_code==11
	replace occup_2=occup_help_2
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
	gen whours_2 = d59
	recode whours_2 0=.
	replace whours_2=. if d59>36
	label var whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>


*<_wmonths_2_>
	gen wmonths_2 = d62
	recode wmonths_2 0=.
	label var wmonths_2 "Months of work in past 12 months secondary job 7 day recall"
*</_wmonths_2_>


*<_wage_total_2_>
	gen wage_total_2 = d63
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
	gen t_wage_others = d65*12
	label var t_wage_others "Annualized wage in all but primary and secondary jobs (12-mon ref period)"
*</_t_wage_others_>


*----------8.5: 7 day reference total summary------------------------------*


*<_t_hours_total_>
	gen t_hours_total = whours + whours_2 + t_hours_others
	label var t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
	gen t_wage_nocompen_total = wage_no_compen
	label var t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
	gen t_wage_total = wage_total + wage_total_2 +t_wage_others
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
	gen double wage_no_compen_year =.
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
	gen t_wage_total_year = t_wage_total
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
	gen linc_nc = t_wage_total
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


*<_% DELETE MISSING VARIABLES_>

quietly: describe, varlist
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

save "`path_output'\KEN_2020_KCHSP_V01_M_V01_A_GLD_ALL.dta", replace 

*</_% SAVE_>