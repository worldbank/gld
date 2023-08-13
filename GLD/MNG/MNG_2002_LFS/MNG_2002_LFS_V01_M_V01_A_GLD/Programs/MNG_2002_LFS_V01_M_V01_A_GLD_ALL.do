
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				MNG_2002_LFS_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata 17 <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2023-05-28 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						MNG </_Country_>
<_Survey Title_>				Mongolia Labor Force Survey 2002 - 2003 </_Survey Title_>
<_Survey Year_>					2002 </_Survey Year_>
<_Study ID_>					[Microdata Library ID if present] </_Study ID_>
<_Data collection from_>		10/2002 </_Data collection from_>
<_Data collection to_>			09/2003 </_Data collection to_>
<_Source of dataset_> 			Mongolia NSO </_Source of dataset_>
<_Sample size (HH)_> 			12787 </_Sample size (HH)_>
<_Sample size (IND)_> 			49948 </_Sample size (IND)_>
<_Sampling method_> 			Using the 2000 Population Census, the survey designed a two-stage stratified random sampling frame, first selecting baghs (census enumeration areas) as primary units, then households within as secondary units. The frame implicitly stratified baghs by district and province, reflecting Mongolia's socio-economic division into nine strata: urban and rural sectors across Ulaanbaatar, Central, East, West, and Khangai regions. </_Sampling method_>
<_Geographic coverage_> 		National </_Geographic coverage_>
<_Currency_> 					Togrog/Tugrik </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS 13 </_ICLS Version_>
<_ISCED Version_>				ISCED 1997 </_ISCED Version_>
<_ISCO Version_>				ISCO 1988 </_ISCO Version_>
<_OCCUP National_>				Unknown </_OCCUP National_>
<_ISIC Version_>				ISIC version 3 </_ISIC Version_>
<_INDUS National_>				Unknown </_INDUS National_>

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

* Define path sections
local server  "Y:/GLD-Harmonization/510859_AS"
local country  "MNG"
local year  "2002"
local survey  "LFS"
local vermast  "V01"
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

* All steps necessary to merge datasets (if several) to have all elements needed to produce
* harmonized output in a single file
use "`path_in_stata'/LFS 2002-2003.dta", clear


/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode="MNG"
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
	gen isced_version = ""
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
	gen int year=2002
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
	gen int int_year= 2002 if d6 == 1
	replace int_year = 2003 if inrange(d6, 2, 4)
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen int_month=.
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
	gen hhid = id1
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	gen  pid = id2
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
	gen double weight=wg
	label var weight "Survey sampling weight"
*</_weight_>


*<_psu_>
	gen psu=d2
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = .
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
 
	* Stratification = Capital + 4 regions, by urban / rural
	gen region= 1 if d3==20  // Ulaanbaatar
	replace region= 2 if d3==6 | d3==8 | d3==11 | d3==13 | d3==14 | d3==19 | d3==22 // Central
	replace region= 3 if d3==7 | d3==12 | d3==18 // East
	replace region= 4 if d3==2 | d3==5 | d3==9 | d3==15 | d3==16 // West
	replace region= 5 if d3==1 | d3==3 | d3==4 | d3==10 | d3==17 | d3== 21 // Highlands
	la de lblreg 1 "Ulaanbaatar" 2 "Central" 3 "East" 4 "West" 5 " Highlands"  
	label values region lblreg
	sdecode region, gen(region_str)
	
	gen ur = .
	replace ur = 1 if d5==1 |d5==2 
	replace ur = 2 if d5==3 |d5==4
	la de lblur 1 "Urban" 2 "Rural"
	label values ur lblur
	sdecode ur, gen(ur_str)
	
	gen strata = region_str + " - " + ur_str
	
	label var strata "Strata"
*</_strata_>


*<_wave_>
	gen wave = d6
	la de lblint_month 1 "October-December 2002" 2 "January-March 2003" 3 "April-June 2003" 4 "July-September 2003"

	label var wave "Survey wave"
*</_wave_>

}


/*%%=============================================================================================
	3: Geography
==============================================================================================%%*/

{

*<_urban_>
	gen byte urban= ur 
	recode urban (2 = 0)
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
	tostring region, gen(regnum)
	gen subnatid1= regnum + " - " + region_str
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	gen byte div = d3
	la de lblsubnatid2 1 "Arhangai" 2 "Bayan-Ulgii" 3 "Bayanhongor" 4 "Bulgan" 5 "Govi-Altai" 6 "Dornogovi" 7 "Dornod" 8 "Dundgovi" 9 "Zavhan" 10 "Uvurhangai" 11 "Umnugovi" 12 "Suhbaatar" 13 "Selenge" 14 "Tuv" 15 "Uvs" 16 "Hovd" 17 "Huvsgul" 18 "Hentii" 19 "Darhan-Uul" 20 "Ulaanbaatar" 21 "Orhon" 22 "Govi-sumber"
	label values div lblsubnatid2
	
	sdecode div, gen(divname_str)
	tostring div, gen(divnum)
	
	gen subnatid2 = divnum + " - " + divname_str
	
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
	gen str subnatidsurvey = subnatid1
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
	gen hsize= hhn
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen byte age= v5
	replace age=98 if age>98
	label var age "Individual age"
*</_age_>


*<_male_>
	gen byte male=v3
	recode male (2 = 0)
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen byte relationharm=v2
	replace relationharm=5 if v2>=5 & v2<=10
	replace relationharm=6 if v2==11
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = v2
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital=.
	replace marital=1 if v9==2
	replace marital=2 if v9==1
	replace marital=3 if v9==3
	replace marital=4 if v9==4 | v9==5
	replace marital=5 if v9==6
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
	gen byte ed_mod_age=5
label var ed_mod_age "Education module application age"
*</_ed_mod_age_>

*<_school_>
	gen byte school=(v6a==1)
	replace school=. if v6a==.
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	* Literacy only asked to those without education. Assume those with at least primary education can read and write
	gen byte literacy= 1 if (v8==1 |v7>=2 & v7<=7)
	replace literacy= 0 if v8== 2
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen byte educy=.
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7=.
	replace educat7=1 if v7==1
	replace educat7=3 if v7==2
	replace educat7=4 if v7==3 
	replace educat7=5 if v7==4
	replace educat7=6 if v7==6  |  v7==5 
	replace educat7=7 if v7==7
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
	gen educat_orig = .
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
	gen byte minlaborage=5
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
	gen byte lstatus=.
	replace lstatus=1 if (v38>=1 & v38!=.) |(v39==1 & v38==0)
	replace lstatus=2 if lstatus!=1 & v63==1 & v68==1
	replace lstatus=3 if missing(lstatus)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = .
	replace potential_lf = 0 if lstatus == 3
	replace potential_lf = 1 if (v63 == 1 & v68 == 2) | (v63 != 1 & v68 == 1)
	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen byte underemployment = .
	replace underemployment = 0 if lstatus == 1
	replace underemployment = 1 if v59 == 1
	replace underemployment = . if age < minlaborage & age != .
	replace underemployment = . if lstatus != 1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason= .
	replace nlfreason = v63
	replace nlfreason = . if v63 == 1
	recode nlfreason (3 = 1) (4 5 = 3) (6 = 4)  (7 8 9 10 11 = 5)
	replace nlfreason = . if lstatus != 3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l=.
	replace unempldur_l=0 if v71==1
	replace unempldur_l=1 if v71==2
	replace unempldur_l=3 if v71==3
	replace unempldur_l=7 if v71==4
	replace unempldur_l=12 if v71==5
	replace unempldur_l=36 if v71==6
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=.
	replace unempldur_u=1 if v71==1
	replace unempldur_u=2 if v71==2
	replace unempldur_u=6 if v71==3
	replace unempldur_u=11 if v71==4
	replace unempldur_u=24 if v71==5
	replace unempldur_u=. if v71==6
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte empstat=5
	replace empstat=1 if v43==1 |  v43==2 
	replace empstat=2 if v43==6
	replace empstat=3 if v43==3
	replace empstat=4 if v43==5
	replace empstat=. if (lstatus!=1)
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec=2
	replace ocusec=4 if v44==31
	replace ocusec=1 if  v44==50
	replace ocusec=3 if v44==40
	replace ocusec=2 if v44==60
	replace ocusec=. if v44==.
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig=v42
	replace industry_orig=. if lstatus!=1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	gen industrycat_isic = string(industry_orig, "%03.0f") + "0" if !missing(industry_orig)
	replace industrycat_isic = "" if missing(industry_orig)
	
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>

	gen byte industrycat10 = .
	count if industrycat_isic != ""
	local nonmissing_count = r(N)

	if `nonmissing_count' >= 1 {
	gen isic_1d = substr(industrycat_isic, 1, 1)
	gen isic_2d = substr(industrycat_isic, 1, 2)
	
	destring isic_1d, replace
	destring isic_2d, replace

	replace industrycat10 = isic_2d
	recode industrycat10 (1/9 = 1) (10/14 = 2) (15/39 = 3) (40 41 = 4) (45 = 5) (50/59 = 6) (60/64 = 7) (65/74 = 8) (75 = 9) (76/99 = 10)
		
	drop isic_1d isic_2d
	}
	
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
	
*</_industrycat10_>

*<_industrycat4_>
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5=2)(6 7 8 9=3)(10=4)
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
	gen  occup_orig=v40
	replace occup_orig=. if lstatus!=1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	gen occup_isco = string(occup_orig) if !missing(occup_orig)
	
	* Replace the codes to 3-digit
	replace occup_isco = "2440" if occup_isco == "2447"
	replace occup_isco = "1210" if occup_isco == "1211"
	replace occup_isco = "5120" if occup_isco == "5124"
	replace occup_isco = "9310" if occup_isco == "9314"
	replace occup_isco = "4130" if occup_isco == "4134"
	replace occup_isco = "2440" if occup_isco == "2449"
	
	* Replace the codes to 1-digit
	replace occup_isco = "1000" if occup_isco == "1410"
	replace occup_isco = "5000" if occup_isco == "5490"
	
	* Code "9999" does not exist in isco 1988, but we have a category for this in occup variable
	replace occup_isco = "" if occup_isco == "9999"
	
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	gen byte occup=.
	replace occup=1 if v40>1000 & v40<2000
	replace occup=2 if v40>2000 & v40<3000
	replace occup=3 if v40>3000 & v40<4000
	replace occup=4 if v40>4000 & v40<5000
	replace occup=5 if v40>5000 & v40<6000
	replace occup=6 if v40>6000 & v40<7000
	replace occup=7 if v40>7000 & v40<8000
	replace occup=8 if v40>8000 & v40<9000
	replace occup=9 if v40>9000 & v40<10000
	replace occup=99 if v40==9999
	replace occup=. if (lstatus!=1)
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
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
	gen double wage_no_compen= .
	
	* Gets paid in cash
	replace wage_no_compen= v57a
	
	* Gets paid in kind
	replace wage_no_compen = v57b
	
	* Gets paid in cash and inkind
	replace wage_no_compen = v57a + v57b if !missing(v57a) & !missing(v57b)
	
	replace wage_no_compen=.  if (lstatus!=1) | wage_no_compen == 0
	
	replace wage_no_compen = wage_no_compen * 1000
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
	gen byte unitwage= 2
	replace unitwage=.  if (lstatus!=1) | missing(wage_no_compen)
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours= v45 if lstatus==1 & (v45>=1 & v45!=.) 
	replace whours=.  if (lstatus!=1)
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
	gen byte contract= .
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte healthins=.
	replace healthins=. if (lstatus!=1)
	label var healthins "Employment has health insurance primary job 7 day recall"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen byte socialsec=.
	replace socialsec=. if (lstatus!=1)
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
	gen byte firmsize_l= .
	replace firmsize_l=1 if v46==2
	replace firmsize_l=5 if v46==3
	replace firmsize_l=10 if v46==4
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u=.
	replace firmsize_u=4 if v46==2
	replace firmsize_u=9 if v46==3
	replace firmsize_u=. if v46==4
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen byte empstat_2= . 
	replace empstat_2=1 if v53==1 |  v53==2 
	replace empstat_2=2 if v53==6
	replace empstat_2=3 if v53==3
	replace empstat_2=4 if v53==5
	replace empstat_2=5 if v53==7
	replace empstat_2 = . if lstatus != 1
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2 = 2
	replace ocusec_2=4 if v54==31
	replace ocusec_2=1 if v54==50
	replace ocusec_2=3 if v54==40
	replace ocusec_2=2 if v54==60
	replace ocusec_2=. if v54==.
	replace ocusec_2 = . if missing(empstat_2)
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2=v52
	replace industry_orig_2=. if missing(empstat_2)
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	gen industrycat_isic_2 = string(industry_orig_2, "%03.0f") + "0" if !missing(industry_orig_2)
	replace industrycat_isic_2 = "" if missing(industry_orig_2) 
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>



*<_industrycat10_2_>
	gen byte industrycat10_2 = .
	count if industrycat_isic_2 != ""
	local nonmissing_count = r(N)

	if `nonmissing_count' >= 1 {
	gen isic_1d = substr(industrycat_isic_2, 1, 1)
	gen isic_2d = substr(industrycat_isic_2, 1, 2)
	
	destring isic_1d, replace
	destring isic_2d, replace

	
	replace industrycat10_2 = isic_2d
	recode industrycat10_2 (1/9 = 1) (10/14 = 2) (15/39 = 3) (40 41 = 4) (45 = 5) (50/59 = 6) (60/64 = 7) (65/74 = 8) (75 = 9) (76/99 = 10)
		
	drop isic_1d isic_2d
	}
	
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
	gen occup_orig_2 = v49
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen occup_isco_2 = string(occup_orig_2)
	* Replace the codes to 3-digit
	replace occup_isco_2 = "9310" if occup_isco_2 == "9314"
	replace occup_isco_2 = "2440" if occup_isco_2 == "2447"
	* Replace the codes to 1-digit
	replace occup_isco_2 = "9000" if occup_isco_2 == "9999"
	
	replace occup_isco_2 = "" if missing(occup_orig_2)
	/*
	replace occup_isco_2 = "2400" if occup_isco_2 == "2447"
	replace occup_isco_2 = "9300" if occup_isco_2 == "9314"
	replace occup_isco_2 = "" if occup_isco_2 == "9999"
	replace occup_isco_2 = "" if missing(occup_orig_2)
	
	*/
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_2_>
	gen byte occup_2=.
	replace occup_2=1 if v49>1000 & v49<2000
	replace occup_2=2 if v49>2000 & v49<3000
	replace occup_2=3 if v49>3000 & v49<4000
	replace occup_2=4 if v49>4000 & v49<5000
	replace occup_2=5 if v49>5000 & v49<6000
	replace occup_2=6 if v49>6000 & v49<7000
	replace occup_2=7 if v49>7000 & v49<8000
	replace occup_2=8 if v49>8000 & v49<9000
	replace occup_2=9 if v49>9000 & v49<10000
	replace occup_2=99 if v49==9999
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
	gen double wage_no_compen_2=  .
	
	* Gets paid in cash
	replace wage_no_compen_2= v58a
	
	* Gets paid in kind
	replace wage_no_compen_2 = v58b
	
	* Gets paid in cash and inkind
	replace wage_no_compen_2 = v58a + v58b if !missing(v58a) & !missing(v58b)

	replace wage_no_compen_2=. if missing(empstat_2) | wage_no_compen_2 == 0
	replace wage_no_compen_2= wage_no_compen_2*1000
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2= .
	replace unitwage_2 = 2 if !missing(wage_no_compen_2)
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
	gen whours_2 = v50
	replace whours_2 = . if missing(empstat_2)
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
	gen firmsize_l_2 = .
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	gen firmsize_u_2 = .
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
* Only asked if economically active (employed/unemployed) or employed most of the time. Assume unemployed if economically active and not employed most of the time
	gen byte lstatus_year= .
	replace lstatus_year = 1 if v74 == 1
	replace lstatus_year = 2 if v74 == 2 & v72 == 1
	replace lstatus_year = 3 if v72 == 2
	
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
	gen byte nlfreason_year= v73
	recode nlfreason_year (4 = 3) (6 = 4) (3 7 8 9 = 5)

	label var nlfreason_year "Reason not in the labor force"
	la de lblnlfreason_year 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason_year lblnlfreason_year
*</_nlfreason_year_>


*<_unempldur_l_year_>
	gen byte unempldur_l_year=.
	replace unempldur_l_year = 0 if v76 == 1
	replace unempldur_l_year = 3 if v76 == 2
	replace unempldur_l_year = 7 if v76 == 3
	replace unempldur_l_year = 12 if v76 == 4
	replace unempldur_l_year = 36 if v76 == 5
	replace unempldur_l_year = 60 if v76 == 6
	label var unempldur_l_year "Unemployment duration (months) lower bracket"
*</_unempldur_l_year_>


*<_unempldur_u_year_>
	gen byte unempldur_u_year=.
	replace unempldur_u_year = 3 if v76 == 1
	replace unempldur_u_year = 6 if v76 == 2
	replace unempldur_u_year = 11 if v76 == 3
	replace unempldur_u_year = 24 if v76 == 4
	replace unempldur_u_year = 48 if v76 == 5
	replace unempldur_u_year = . if v76 == 6
	label var unempldur_u_year "Unemployment duration (months) upper bracket"
*</_unempldur_u_year_>

}

*----------8.7: 12 month reference main job------------------------------*

{

*<_empstat_year_>
	gen byte empstat_year=5
	replace empstat_year=1 if v80==1 |  v80==2 
	replace empstat_year=2 if v80==6
	replace empstat_year=3 if v80==3
	replace empstat_year=4 if v80==5
	replace empstat_year=. if lstatus_year!=1
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
	gen industry_orig_year = v78
	replace industry_orig_year=. if lstatus_year!=1

	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_> 
	gen industrycat_isic_year = string(industry_orig_year, "%03.0f")  + "0" if !missing(industry_orig_year)	
	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>

*<_industrycat10_year_>
	gen byte industrycat10_year = .
	count if industrycat_isic_year != ""
	local nonmissing_count = r(N)

	if `nonmissing_count' >= 1 {	
	gen isic_1d = substr(industrycat_isic_year, 1, 1)
	gen isic_2d = substr(industrycat_isic_year, 1, 2)
	
	destring isic_1d, replace
	destring isic_2d, replace

	replace industrycat10_year = isic_2d
	recode industrycat10_year (1/9 = 1) (10/14 = 2) (15/39 = 3) (40 41 = 4) (45 = 5) (50/59 = 6) (60/64 = 7) (65/74 = 8) (75 = 9) (76/99 = 10)
		
		
	
	drop isic_1d isic_2d
	}
	label var industrycat10_year "1 digit industry classification, primary job 12 month recall"
	la de lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
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
	gen occup_orig_year = v77
	replace occup_orig_year = . if lstatus_year != 1
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	gen occup_isco_year = string(occup_orig_year)
	replace occup_isco_year = "" if occup_orig_year == .

	replace occup_isco_year = "1200" if occup_isco_year == "1211"
	replace occup_isco_year = "1000" if occup_isco_year == "1410"
	replace occup_isco_year = "2400" if occup_isco_year == "2447"
	replace occup_isco_year = "2400" if occup_isco_year == "2449"
	replace occup_isco_year = "4100" if occup_isco_year == "4134"
	replace occup_isco_year = "5100" if occup_isco_year == "5124"
	replace occup_isco_year = "5100" if occup_isco_year == "5189"
	replace occup_isco_year = "5000" if occup_isco_year == "5223"
	replace occup_isco_year = "5000" if occup_isco_year == "5251"
	replace occup_isco_year = "5000" if occup_isco_year == "5259"
	replace occup_isco_year = "5000" if occup_isco_year == "5320"
	replace occup_isco_year = "5000" if occup_isco_year == "5322"
	replace occup_isco_year = "5000" if occup_isco_year == "5324"
	replace occup_isco_year = "5000" if occup_isco_year == "5490"
	replace occup_isco_year = "9300" if occup_isco_year == "9314"
	replace occup_isco_year = "" if occup_isco_year == "9997"
	replace occup_isco_year = "" if occup_isco_year == "9999"


	
	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_year_>
	gen byte occup_year = .
	replace occup_year=1 if v77>1000 & v77<2000
	replace occup_year=2 if v77>2000 & v77<3000
	replace occup_year=3 if v77>3000 & v77<4000
	replace occup_year=4 if v77>4000 & v77<5000
	replace occup_year=5 if v77>5000 & v77<6000
	replace occup_year=6 if v77>6000 & v77<7000
	replace occup_year=7 if v77>7000 & v77<8000
	replace occup_year=8 if v77>8000 & v77<9000
	replace occup_year=9 if v77>9000 & v77<10000
	replace occup_year=99 if v77==9999
	replace occup_year = . if lstatus_year!=1
	
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


*<_wage_no_compen_year_>
* For the usual activity status, wages are either reported monthly or daily
	gen double wage_no_compen_year = .
	
	* Create month wage
	gen month_wage_year = v81a
	replace month_wage_year = . if month_wage_year == 0
	
	* Day wage
	gen day_wage_year = v81b
	replace day_wage_year = . if day_wage_year == 0
	
	* v81a and v81b are mutually exclusive!

	replace wage_no_compen_year = month_wage_year
	replace wage_no_compen_year = day_wage_year if !missing(day_wage_year)
	replace wage_no_compen_year = . if missing(empstat_year) | wage_no_compen_year == 0
	replace wage_no_compen_year = wage_no_compen_year*1000
	label var wage_no_compen_year "Last wage payment primary job 12 month recall"
*</_wage_no_compen_year_>


*<_unitwage_year_>
	gen byte unitwage_year = .
	replace unitwage_year = 5 if !missing(month_wage_year)
	replace unitwage_year = 1 if !missing(day_wage_year)
	drop day_wage_year month_wage_year
	
	replace unitwage_year = . if missing(empstat_year)

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
	gen firmsize_l_year = .
	label var firmsize_l_year "Firm size (lower bracket) primary job 12 month recall"
*</_firmsize_l_year_>


*<_firmsize_u_year_>
	gen firmsize_u_year = .
	label var firmsize_u_year "Firm size (upper bracket) primary job 12 month recall"
*</_firmsize_u_year_>

}


*----------8.8: 12 month reference secondary job------------------------------*

{

*<_empstat_2_year_>
	gen byte empstat_2_year= . 
	replace empstat_2_year=1 if v85==1 |  v85==2 
	replace empstat_2_year=2 if v85==6
	replace empstat_2_year=3 if v85==3
	replace empstat_2_year=4 if v85==5
	replace empstat_2_year=5 if v85==7
	replace empstat_2_year = . if lstatus_year!=1
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
	gen industry_orig_2_year = v84
	replace industry_orig_2_year = . if empstat_2_year == .
	label var industry_orig_2_year "Original survey industry code, secondary job 12 month recall"
*</_industry_orig_2_year_>



*<_industrycat_isic_2_year_>
	gen industrycat_isic_2_year = string(industry_orig_2_year, "%03.0f") + "0" if !missing(industry_orig_2_year)
	label var industrycat_isic_2_year "ISIC code of secondary job 12 month recall"
*</_industrycat_isic_2_year_>


*<_industrycat10_2_year_>
	gen byte industrycat10_2_year = .
	
	count if industrycat_isic_2_year != ""
	local nonmissing_count = r(N)

	if `nonmissing_count' >= 1 {	
	gen isic_1d = substr(industrycat_isic_2_year, 1, 1)
	gen isic_2d = substr(industrycat_isic_2_year, 1, 2)
	
	destring isic_1d, replace
	destring isic_2d, replace


	replace industrycat10_2_year = isic_2d
	recode industrycat10_2_year (1/9 = 1) (10/14 = 2) (15/39 = 3) (40 41 = 4) (45 = 5) (50/59 = 6) (60/64 = 7) (65/74 = 8) (75 = 9) (76/99 = 10)
		

	}

*<_industrycat4_2_year_>
	gen byte industrycat4_2_year=industrycat10_2_year
	recode industrycat4_2_year (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4_2_year "Broad Economic Activities classification, secondary job 12 month recall"
	label values industrycat4_2_year lblindustrycat4_year
*</_industrycat4_2_year_>


*<_occup_orig_2_year_>
	gen occup_orig_2_year = v83
	replace occup_orig_2_year = . if empstat_2_year == .
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
	gen occup_isco_2_year = string(occup_orig_2_year)
	replace occup_isco_2_year = "" if missing(occup_orig_2_year)
	
	replace occup_isco_2_year = "2400" if occup_isco_2_year == "2447"
	replace occup_isco_2_year = "9300" if occup_isco_2_year == "9314"
	replace occup_isco_2_year = "" if occup_isco_2_year == "9999"

	label var occup_isco_2_year "ISCO code of secondary job 12 month recall"
*</_occup_isco_2_year_>


*<_occup_2_year_>
	gen byte occup_2_year = .
	replace occup_2_year=1 if v83>1000 & v83<2000
	replace occup_2_year=2 if v83>2000 & v83<3000
	replace occup_2_year=3 if v83>3000 & v83<4000
	replace occup_2_year=4 if v83>4000 & v83<5000
	replace occup_2_year=5 if v83>5000 & v83<6000
	replace occup_2_year=6 if v83>6000 & v83<7000
	replace occup_2_year=7 if v83>7000 & v83<8000
	replace occup_2_year=8 if v83>8000 & v83<9000
	replace occup_2_year=9 if v83>9000 & v83<10000
	replace occup_2_year=99 if v83==9999
	replace occup_2_year = . if missing(empstat_2_year)
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
* There is no secondary activity earnings, only earnings from all occupations
* But we can impute secondary activity earnings by subtracting primary from all
	gen double wage_no_compen_2_year = .
	
	gen diff_month = v86a - v81a
	gen diff_day = v86b - v81b
	
	count if diff_month < 0 | diff_day < 0
	if `r(N)' == 0 {
	replace  wage_no_compen_2_year = diff_month
	replace  wage_no_compen_2_year = diff_day if !missing(diff_day)
	
	replace wage_no_compen_2_year = . if missing(empstat_2_year) | wage_no_compen_2_year == 0
	
	
	replace wage_no_compen_2_year = wage_no_compen_2_year * 1000 
	}
	
	
	label var wage_no_compen_2_year "Last wage payment secondary job 12 month recall"
*</_wage_no_compen_2_year_>


*<_unitwage_2_year_>
	gen byte unitwage_2_year = .
	replace unitwage_2_year = 5 if !missing(diff_month)
	replace unitwage_2_year = 1 if !missing(diff_day)
	replace unitwage_2_year = . if missing(wage_no_compen_2_year)
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
	gen firmsize_l_2_year = .
	label var firmsize_l_2_year "Firm size (lower bracket) secondary job 12 month recall"
*</_firmsize_l_2_year_>


*<_firmsize_u_2_year_>
	gen firmsize_u_2_year = .
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
	replace njobs = 1 if !missing(empstat_year) & missing(empstat_2_year)
	replace njobs = 2 if !missing(empstat_year) & !missing(empstat_2_year)

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

save "`path_output'/`out_file'", replace

*</_% SAVE_>
