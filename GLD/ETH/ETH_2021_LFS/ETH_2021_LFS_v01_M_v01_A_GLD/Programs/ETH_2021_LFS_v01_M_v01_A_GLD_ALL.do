 
/*%%=============================================================================================
	0: GLD Harmonization Preamble
================================================================================================*/

/* -----------------------------------------------------------------------
<_Program name_>				ETH_2021_LFS_v01_M_v01_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata MP 16.1 <_Application_>
<_Author(s)_>					Wolrd Bank Job's Group </_Author(s)_>
<_Date created_>				2022-11-11 </_Date created_>
-------------------------------------------------------------------------
<_Country_>						Ethiopia(ETH) </_Country_>
<_Survey Title_>				National Labour Force Survey </_Survey Title_>
<_Survey Year_>					2021 </_Survey Year_>
<_Study ID_>					ETH_2021_LFS_v01_M </_Study ID_>
<_Data collection from (M/Y)_>	[March/2021] </_Data collection from (M/Y)_>
<_Data collection to (M/Y)_>	[June/2021] </_Data collection to (M/Y)_>
<_Source of dataset_> 			Central Statistical Agency </_Source of dataset_>
								Data is not publicly accessible. World Bank internal use only.
<_Sample size (HH)_> 			 </_Sample size (HH)_>
<_Sample size (IND)_> 			174,613 </_Sample size (IND)_>
<_Sampling method_> 			Stratified two-stage cluster sampling method was used. 
								Enumeration areas(EAs) are considered as Primary Sampling Unit
								and the households are the Secondary Sampling Unit. </_Sampling method_>
<_Geographic coverage_> 		All country is covered except the Tigray region. </_Geographic coverage_>
<_Currency_> 					Ethiopian Birr </_Currency_>
-----------------------------------------------------------------------
<_ICLS Version_>				ICLS 13 </_ICLS Version_>
<_ISCED Version_>				ISCED-2011 </_ISCED Version_>
<_ISCO Version_>				ISCO-08 </_ISCO Version_>
<_OCCUP National_>				NOIC </_OCCUP National_>
<_ISIC Version_>				ISIC Rev.4 </_ISIC Version_>
<_INDUS National_>				NOIC  </_INDUS National_>
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
local server  "Z:\GLD-Harmonization\573465_JT"
local country "ETH"
local year    "2021"
local survey  "LFS"
local vermast "v01"
local veralt  "v01"

* From the definitions, set path chunks
local level_1      "`country'_`year'_`survey'"
local level_2_mast "`level_1'_`vermast'_M"
local level_2_harm "`level_1'_`vermast'_M_`veralt'_A_GLD"

* From chunks, define path_in, path_output folder
local path_in_stata "`server'\\`country'\\`level_1'\\`level_2_mast'\Data\Stata"
local path_in_other "`server'\\`country'\\`level_1'\\`level_2_mast'\Data\Original"
local path_output   "`server'\\`country'\\`level_1'\\`level_2_harm'\Data\Harmonized"

* Define Output file name
local out_file "`level_2_harm'_ALL.dta"


*----------1.3: Database assembly------------------------------*

* All steps necessary to merge datasets (if several) to have all elements needed to produce
* harmonized output in a single file

	use "`path_in_stata'\NLFS2021.dta", clear

/*%%=============================================================================================
	2: Survey & ID
================================================================================================*/

{

*<_countrycode_>
	gen str4 countrycode="ETH"
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
	gen int year=2021
	label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen str3 vermast="v01"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen str3 veralt="v01"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen harmonization="GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	gen int_year=2021
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen int_month=3
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


/*<_hhid_note_>
According to the annual report, the total number of households should be 49,916, 
6,587 more than what we got here using ID01 to ID08.
*<_hhid_note_>*/


*<_hhid_>
	foreach var of varlist ID101-ID107 ID108{
		tostring `var', gen(str_`var') format(%03.0f)
	}
	egen hhid=concat(str_ID101 str_ID102 str_ID103 str_ID104 str_ID105 str_ID106 str_ID107 ID108)
	label var hhid "Household id"
*</_hhid_>


/*<_pid_note_>
12 different observations have the duplicated PIDs with other household members. 
They were assigned with the same relationship with the household head, i.e., two household
heads within the same household. 

For duplicated hyousehold heads, I kept head for the elder one between the two same pids.
*<_pid_note_>*/


*<_pid_>
	gen lf201=LF201
	tostring lf201, gen(str_LF201) format(%02.0f)    
	egen pid0=concat(hhid str_LF201)
	gsort hhid -LF205
	bys hhid: gen counter=_n
	replace lf201=counter if lf201!=counter
	drop str_LF201
	tostring lf201, gen(str_LF201) format(%02.0f)
	egen pid=concat(hhid str_LF201)
	label var pid "Individual ID"
	drop pid0 counter
*</_pid_>


*<_weight_>
	*gen weight=weight
	label var weight "Household sampling weight"
*</_weight_>


/*<_psu_note_>
In the official annual report, there is supposed to be 1686 EAs (766 major urban, 
380 other urban and 540 rural). However, we only got 1673 EAs. 
*<_psu_note_>*/


*<_psu_>
	egen psu=group(ID101 ID102 ID103 ID104 ID105 ID106 ID107)	
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu=hhid
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	gen strata=. 
	label var strata "Strata"
*</_strata_>


*<_wave_>
	gen wave=.
	label var wave "Survey wave"
*</_wave_>

}

/*%%=============================================================================================
	3: Geography
================================================================================================*/

{

*<_urban_>
	gen urban=ID104
	recode urban (8=0) (1/5=1)
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
	label var urban "Location is urban"
*</_urban_>


*<_subnatid1_>
	gen subnatid1_prep=ID101
	label de lblsubnatid1 2 "2-Affar" 3 "3-Amhara" 4 "4-Oromia" 5 "5-Somalie" 6 "6-Benishangul-Gumuz" 7 "7-SNNPR" 8 "8-Sidama" 12 "12-Gambela" 13 "13-Harari" 14 "14-Addis Ababa" 15 "15-Dire Dawa"
	label values subnatid1_prep lblsubnatid1
	decode subnatid1_prep, gen(subnatid1)
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	drop str_ID101 str_ID102
	tostring ID101, gen(str_ID101)
	tostring ID102, gen(str_ID102)
	egen subnatid2=concat(str_ID101 str_ID102), punct("-")
	merge m:m subnatid2 using "`path_in_stata'\ETH_zone_name_2021.dta"
	replace Zone="Misrak Hararge" if Zone=="Mierak Hararge"
	replace Zone="Misrak Wollega" if Zone=="Misiraki Wollega"
	replace Zone="Debub Omo" if Zone=="debub Omo"
	replace Zone="Gamo Gofa" if Zone=="gamo Gofa"
	replace Region="Sidama" if Region=="SIDAMA"
	replace Zone="Basketo Special" if Zone=="basketo Special"
	egen zonename=concat(Region Zone), punct("-")
	replace subnatid2=zonename
	drop Region rcode rcode_str Zone zcode zcode_str _merge zonename
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	gen id101=ID101
	tostring id101 ID102 ID103, gen(id101str id102str id103str) format(%02.0f) 
	egen subnatid3=concat(id101str id102str id103str)
	merge m:m subnatid3 using "`path_in_stata'/ETH_wereda_name_2021.dta"
	drop if _merge!=3
	replace wereda_name="Gudeya Bila" if wereda_name=="Gudaya Bila"
	replace wereda_name="Chencha" if wereda_name=="chencha"
	replace wereda_name="arbaminch" if wereda_name=="Arba Minch"
	replace wereda_name="konson" if wereda_name=="Konso"
	replace wereda_name="Amaro" if wereda_name=="amaro"
	egen Subnatid3=concat(subnatid3 wereda_name), punct("-") 
	drop subnatid3 Region rcode Zone zcode wereda_name wcode _merge
	rename Subnatid3 subnatid3
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>	
	decode ID101, gen(region_name)
	decode urban, gen(urban_name)
	egen subnatidsurvey=concat(region_name urban_name), punct("-")
	label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>


/* <_subnatid1_prev_note_>
subnatid1_prev is coded as missing unless the classification used for subnatid1 has changed since the previous survey.
</_subnatid1_prev_note_> */


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
	bys hhid: gen counter=_n
	bys hhid: egen hsize=max(counter)
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen age=LF205
	replace age=98 if age>98 & age!=.
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male=LF204
	recode male 2=0
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female", modify
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen byte relationharm=LF203
	recode relationharm (3/5=3) (6=4) (7 9=5) (8 10=6)
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm lblrelationharm
	
	gen head=1 if relationharm==1
	bys hhid: egen headcount=total(head)
	
	bys hhid head: egen age_max=max(age) if headcount==2
	replace relationharm=5 if head==1 & headcount==2 & age!=age_max
	
	drop head headcount
	gen head=1 if relationharm==1
	bys hhid: egen headcount=total(head)
	drop head headcount age_max
*</_relationharm_>


*<_relationcs_>
	gen relationcs=LF203
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital=LF215
	recode marital (1=2) (2=1) (3 5=4) (4=5) (6=3)  
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed", modify
	label values marital lblmarital
*</_marital_>


/*<_eye_dsablty_note_>
The age restriction of the disability section is 5 years+.
*<_eye_dsablty_note_>*/


*<_eye_dsablty_>
	gen eye_dsablty=LF216_A
	la de lbleye_dsablty 1 "No" 2 "Yes-some" 3 "Yes-a lot" 4 "Cannot at all"
	label values eye_dsablty lbleye_dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty=LF216_B
	la de lblhear_dsablty 1 "No" 2 "Yes-some" 3 "Yes-a lot" 4 "Cannot at all"
	label values hear_dsablty lblhear_dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty=LF216_D
	la de lblwalk_dsablty 1 "No" 2 "Yes-some" 3 "Yes-a lot" 4 "Cannot at all"
	label values walk_dsablty lblwalk_dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord=LF216_E
	la de lblconc_dsord 1 "No" 2 "Yes-some" 3 "Yes-a lot" 4 "Cannot at all"
	label values conc_dsord lblconc_dsord
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty=LF216_F
	la de lblslfcre_dsablty 1 "No" 2 "Yes-some" 3 "Yes-a lot" 4 "Cannot at all"
	label values slfcre_dsablty lblslfcre_dsablty
	label var eye_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty=LF216_C
	la de lblcomm_dsablty 1 "No" 2 "Yes-some" 3 "Yes-a lot" 4 "Cannot at all"
	label values comm_dsablty lblcomm_dsablty
	label var eye_dsablty "Disability related to communicating"
*</_comm_dsablty_>

}


/*%%=============================================================================================
	5: Migration
================================================================================================*/

{
*<_migrated_mod_age_>
	gen migrated_mod_age=0
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time=5
	label var migrated_ref_time "Reference time applied to migration questions"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen migrated_binary=cond(LF601==98, 0, 1)
	label de lblmigrated_binary 0 "No" 1 "Yes"
	replace migrated_binary=. if age<migrated_mod_age
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
   gen migrated_years=LF601 if inrange(LF601, 1, 97)
   replace migrated_years=0.5 if LF601==0
   replace migrated_years=. if migrated_binary!=1
   replace migrated_years=. if age<migrated_mod_age
   label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban=LF606
	recode migrated_from_urban (2=0) 
	replace migrated_from_urban=. if migrated_binary!=1
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	replace migrated_from_urban=. if age<migrated_mod_age
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


/*<_migrated_from_cat_note_>
Detailed questions like region or zone of precious residence, area of previous 
residence and reasons for migration were asked only to recent migrants who moved
our from their original place during the 5 years prior to the date of the interview. 
*<_migrated_from_cat_note_>*/


*<_migrated_from_cat_>
	gen wcode=substr(subnatid3, 1,6)
	gen zcode=substr(subnatid3, 1,4)
	gen rcode=substr(subnatid3, 1,2)
	gen migrated_from_cat=.
	replace migrated_from_cat=1 if wcode==LF605_WEREDA & migrated_binary==1 & LF604==58
	replace migrated_from_cat=2 if zcode==LF605_ZONE & migrated_binary==1 & LF604==58 & migrated_from_cat==.
	replace migrated_from_cat=3 if rcode==LF605_REGION & migrated_binary==1 & LF604==58 & migrated_from_cat==.
	replace migrated_from_cat=4 if rcode!=LF605_REGION & migrated_binary==1 & LF604==58 & migrated_from_cat==.
	replace migrated_from_cat=5 if migrated_binary==1 & !mi(LF604) & LF604!=58 & migrated_from_cat==.
	replace migrated_from_cat=. if age<migrated_mod_age
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	destring LF605_REGION LF605_ZONE LF605_WEREDA, replace
	gen migrated_from_code=cond(LF605_WEREDA<.,LF605_WEREDA,cond(LF605_ZONE<.,LF605_ZONE,cond(LF605_REGION<.,LF605_ZONE,LF604)))
	replace migrated_from_code=. if migrated_binary!=1
	replace migrated_from_code=. if age<migrated_mod_age
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country=LF604
	replace migrated_from_country=. if migrated_binary!=1
	replace migrated_from_country=. if age<migrated_mod_age
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason=LF607
	recode migrated_reason (5 8 10=1) (4=2) (1 2=3) (6 7=4) (3 9 11 12=5)
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

*<_ed_mod_age_>
	gen byte ed_mod_age=5
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


*<_school_>
	gen school=.
	replace school=LF207 if LF207==1
	replace school=0 if LF207==2|LF207==3
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen byte literacy=LF206
	recode literacy (2=0)
	replace literacy=. if age<ed_mod_age & age!=.
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes", modify
	label values literacy lblliteracy
*</_literacy_>


/*<_educy_note_>

The old curriculum in Ethiopia follows a 6-2-4 structure:
6 years of primary education
2 years of lower seconday
4 years of upper secondary 
and 2-3 years of diploma or one year of tearcher training follows that;

The new curriculum follows a 4-4-2-2 structure:
1-4 basic education/first-cycle primary
5-8 general primary education/secondary-cycle primary
9-10 general secondary education
11-12 preparatory secondary education

The educy in 2021 takes kindergarten(3 levels) into account as 
there are three separate categories of kindergarten listed in the raw dataset.
And they should be treated differently compared to those who have never
received education.	  
*<_educy_note_>*/		  


*<_educy_>
	gen byte educy=LF208 if inrange(LF208,1,17)
	replace educy=0 if inlist(LF208,3,44,96,99)
	replace educy=11 if LF208==18|LF208==19
	replace educy=12 if LF208==20
	replace educy=LF208-12 if inrange(LF208,21,24)
	replace educy=13 if inlist(LF208,25,26,27,33,34,35)
	replace educy=15 if LF208==28
	replace educy=16 if LF208==29
	replace educy=17 if LF208==30
	replace educy=18 if LF208==31
	replace educy=21 if LF208==32
	replace educy=LF208-35 if inrange(LF208,36,38)
	replace educy=LF208-35 if inrange(LF208,39,41)
	replace educy=LF208-34 if inrange(LF208,42,44)
	replace educy=. if age<ed_mod_age & age!=.  
	replace educy=age if educy>age & !mi(educy) & !mi(age)
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7=.
	replace educat7=1 if educy==0
	replace educat7=2 if educy<6 
	replace educat7=3 if educy==6
	replace educat7=4 if educy>=9 & educy <12
	replace educat7=5 if educy==12
	replace educat7=6 if educy==13 & LF208!=27
	replace educat7=7 if educy>13 & !mi(educy)
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
	gen educat_orig=LF208
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
	gen educat_isced=.
	replace educat_isced=020 if inlist(LF208,36,37,38)
	replace educat_isced=100 if inrange(LF208,1,8)
	replace educat_isced=244 if inlist(LF208,9,10,21,22)
	replace educat_isced=344 if inlist(LF208,11,12,18,19,20,23,24)
	replace educat_isced=254 if inlist(LF208,13,25)
	replace educat_isced=353 if inlist(LF208,14,15)
	replace educat_isced=453 if inlist(LF208,16,17)
	replace educat_isced=660 if inrange(LF208,26,29)
	replace educat_isced=660 if inrange(LF208,33,35)
	replace educat_isced=760 if inrange(LF208,30,31)
	replace educat_isced=860 if LF208==32
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
	gen vocational=LF209
	recode vocational (2=0) 
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
	label var vocational_length_l "Length of training, lower limit"
*</_vocational_length_l_>


*<_vocational_length_u_>
	gen vocational_length_u=.
	label var vocational_length_u "Length of training, upper limit"
*</_vocational_length_u_>


*<_vocational_field_orig_>
	gen vocational_field_orig=LF210
	decode LF210, gen(training_field)
	labmask vocational_field_orig, values(training_field) 
	label var vocational_field_orig "Field of training"
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
	gen byte minlaborage=5
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
	gen byte lstatus=.
	replace lstatus=1 if LF301==1 | LF304<4
	replace lstatus=2 if LF304==4 & LF401==1
	replace lstatus=3 if LF304==4 & LF401==2
	replace lstatus=3 if lstatus==. 
	replace lstatus=. if age<minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF", modify
	label values lstatus lbllstatus
*</_lstatus_>


/*<_potential_lf_note_>
Note: var "potential_lf" only takes value if the respondent is not in labor force. (lstatus==3)

"potential_lf"=1 if the person is
1)available but not searching or LF405==1 & LF401==2
2)searching but not immediately available to work or LF405==2 & LF401==1
</_potential_lf_note_>*/


*<_potential_lf_>
	gen byte potential_lf=.
	replace potential_lf=1 if [LF405==1 & LF401==2] | [LF405==2 & LF401==1]
	replace potential_lf=0 if [LF405==1 & LF401==1] | [LF401==2 & LF405==2]
	replace potential_lf=. if age < minlaborage
	replace potential_lf=. if lstatus!=3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen byte underemployment=.
	replace underemployment=1 if LF325==1
	replace underemployment=0 if LF325==2
	replace underemployment=. if age < minlaborage
	replace underemployment=. if lstatus!=1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason=LF406
	recode nlfreason (1=2) (3=1) (8/9=3) (2 5/7 10/11=5)
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


/*<_unempldur_l_note_>
The duration of being unemployed is a single number. 
*<_unempldur_l_note_>*/


*<_unempldur_l_>
	gen byte unempldur_l=LF411
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=LF411
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
/*<_empstat_note_>
According to the annual report, employment status of a person was classified into:
- employer
- paid employee
- self employed
- unpaid family worker
- member of producers' cooperative
- apprentice
- "other"

"Paid employees" include:
- government employees
- government parasitatal employees
- private organization employees
- NGO employees
- domestic employees
- other paid employees
*<_empstat_note_>*/


*<_empstat_>
	gen byte empstat=LF308
	recode empstat (1/8=1) (9 10=4) (11 12=2) (13=3) (14/16=5)
	replace empstat=. if lstatus!=1
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec=LF308
	recode ocusec (1/2=1) (3/5 7/8=2) (6 9/16=4)
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig=LF307
	replace industry_orig=. if lstatus!=1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	gen industrycat_isic=LF307
	replace industrycat_isic=1079 if LF307==1076|LF307==1077
	replace industrycat_isic=990 if LF307==999
	replace industrycat_isic=4799 if LF307==4792
	replace industrycat_isic=9410 if LF307==9413
	replace industrycat_isic=. if inrange(LF307, 1105, 1107)
	tostring industrycat_isic, replace format(%04.0f)
	replace industrycat_isic="" if lstatus!=1 | industrycat_isic=="." 
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen long industrycat10=floor(LF307/100)
	recode industrycat10 (2/3=1) (5/9=2) (10/33=3) (35/39=4) (41/43=5) (45/47 55/56=6) (49/53 58/63=7) (64/82=8) (84=9) (85/99=10)
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
	gen occup_orig=LF306
	replace occup_orig=. if lstatus!=1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>	
	gen code_o=LF306
	merge m:1 code_o using "`path_in_stata'\ETH_2021_occup_isco.dta" 
	replace code_o=. if code_h=="drop" 
	tostring code_o,format(%04.0f) replace	
	replace code_o=code_h if !mi(code_h)&code_h!="drop"
	replace code_o="" if code_o=="."
	rename code_o occup_isco
	drop _merge code_h
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
	gen byte occup=floor(LF306/1000)
	replace occup=. if lstatus!=1
	recode occup (0=10) 
	label var occup "1 digit occupational classification, primary job 7 day recall"
  	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>


*<_wage_no_compen_>
	gen double wage_no_compen=LF321
	replace wage_no_compen=0 if empstat==2
	replace wage_no_compen=. if lstatus!=1
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
	gen byte unitwage=LF319 
	recode unitwage (1=9) (2=1) (3=2) (4=3) (6=8) (7=10)
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours=LF302_TOTAL
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
	gen byte contract=LF317
	recode contract (1/3=1) (4/5=0)
	replace contract=. if lstatus!=1
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte healthins=.
	replace healthins=. if lstatus!=1
	label var healthins "Employment has health insurance primary job 7 day recall"
	*la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen byte socialsec=.
	replace socialsec=. if lstatus!=1
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	*la de lblsocialsec 1 "With social security" 0 "Without social secturity"
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen byte union=.
	label var union "Union membership at primary job 7 day recall"
	*la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	gen byte firmsize_l=.
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u=.
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels

{
*<_empstat_2_>
	gen byte empstat_2=.
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2=.
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	la de lblocusec_2 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish", modify
	label values ocusec_2 lblocusec_2
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2=.
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	gen industrycat_isic_2=.
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen byte industrycat10_2=.
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
	gen occup_orig_2=.
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen occup_isco_2=.
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_skill_2_>
	gen occup_skill_2=.
	label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>


*<_occup_2_>
	gen occup_2=.
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
	gen whours_2=.
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
	gen byte firmsize_l_2=.
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
	replace lstatus_year=1 if lstatus==1|LF501==1|LF502==1
	replace lstatus_year=2 if inlist(LF502,2,3)
	replace lstatus_year=3 if inlist(LF502,4,13)
	replace lstatus_year=3 if lstatus_year==.
	replace lstatus_year=. if age<minlaborage & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>


*<_potential_lf_year_>
	gen byte potential_lf_year=.
	replace potential_lf_year=. if age<minlaborage & age!=.
	replace potential_lf_year=. if lstatus_year!=3
	label var potential_lf_year "Potential labour force status"
	la de lblpotential_lf_year 0 "No" 1 "Yes"
	label values potential_lf_year lblpotential_lf_year
*</_potential_lf_year_>


*<_underemployment_year_>
	gen byte underemployment_year=.
	replace underemployment_year=. if age<minlaborage & age!=.
	replace underemployment_year=. if lstatus_year==1
	label var underemployment_year "Underemployment status"
	la de lblunderemployment_year 0 "No" 1 "Yes"
	label values underemployment_year lblunderemployment_year
*</_underemployment_year_>


*<_nlfreason_year_>
	gen byte nlfreason_year=LF502
	recode nlfreason_year (1/3=.) (4 7 8 9 11 12=5) (5=1) (6=4) (10=3)
	replace nlfreason_year=. if lstatus_year
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
	gen byte empstat_year=LF503
	recode empstat_year (1/8=1) (9 10=4) (11 12=2) (13=3) (14/16=5)
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>


*<_ocusec_year_>
	gen byte ocusec_year=LF503
	recode ocusec_year (1/2=1) (3/5 7/8=2) (6 9/16=4)
	replace ocusec_year=. if lstatus_year!=1
	label var ocusec_year "Sector of activity primary job 12 day recall"
	la de lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_year lblocusec_year
*</_ocusec_year_>


*<_industry_orig_year_>
	gen industry_orig_year=LF505
	replace industry_orig_year=. if lstatus_year!=1
	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	gen industrycat_isic_year=LF505	
	replace industrycat_isic_year=1079 if LF505==1076|LF505==1077
	replace industrycat_isic_year=990 if LF505==999
	replace industrycat_isic_year=4799 if LF505==4792
	replace industrycat_isic_year=9410 if LF505==9413
	replace industrycat_isic_year=. if inrange(LF505, 1105, 1107)
	tostring industrycat_isic_year, replace format(%04.0f)
	replace industrycat_isic_year="" if lstatus_year!=1
	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>


*<_industrycat10_year_>
	gen byte industrycat10_year=floor(LF505/100)
	recode industrycat10_year (2/3=1) (5/9=2) (10/33=3) (35/39=4) (41/43=5) (45/47 55/56=6) (49/53 58/63=7) (64/82=8) (84=9) (85/99=10)
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
	gen occup_orig_year=LF504
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>	
	gen code_o=LF504
	merge m:1 code_o using "`path_in_stata'\ETH_2021_occup_isco.dta" 
	replace code_o=. if code_h=="drop" 
	tostring code_o,format(%04.0f) replace	
	replace code_o=code_h if !mi(code_h)&code_h!="drop"
	replace code_o="" if code_o=="."
	drop _merge code_h
	rename code_o occup_isco_year
	replace occup_isco_year="" if lstatus_year!=1
	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_skill_year_>
	gen skill_level_year=substr(occup_isco_year, 1, 1)
	destring skill_level_year, replace
	gen occup_skill_year=.
	replace occup_skill_year=1 if skill_level_year==9
	replace occup_skill_year=2 if inrange(skill_level_year, 4, 8)
	replace occup_skill_year=3 if inrange(skill_level_year, 1, 3)
	replace occup_skill_year=. if skill_level_year==0 | lstatus_year!=1
	la de lblskill_year 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_year lblskill_year
	label var occup_skill_year "Skill based on ISCO standard primary job 12 month recall"
*</_occup_skill_year_>


*<_occup_year_>
	gen byte occup_year=floor(LF504/1000)
	replace occup_year=. if lstatus_year!=1
	recode occup_year (0=10) 

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

save "`path_output'\ETH_2021_LFS_v01_M_v01_A_GLD_ALL.dta", replace

*</_% SAVE_>
