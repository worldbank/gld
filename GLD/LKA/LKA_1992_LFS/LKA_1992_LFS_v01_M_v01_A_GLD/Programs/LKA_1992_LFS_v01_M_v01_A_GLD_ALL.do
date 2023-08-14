 
/*%%=============================================================================================
	0: GLD Harmonization Preamble
================================================================================================*/

/* -----------------------------------------------------------------------
<_Program name_>				LKA_1992_LFS_V01_M_V01_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata SE 16.1 <_Application_>
<_Author(s)_>					Wolrd Bank Job's Group </_Author(s)_>
<_Date created_>				2023-08-07 </_Date created_>
-------------------------------------------------------------------------
<_Country_>						Sri Lanka (LKA) </_Country_>
<_Survey Title_>				National Labour Force Survey </_Survey Title_>
<_Survey Year_>					1992 </_Survey Year_>
<_Study ID_>					LKA_1992_LFS_v01_M </_Study ID_>
<_Data collection from (M/Y)_>	[Jan/1992] </_Data collection from (M/Y)_>
<_Data collection to (M/Y)_>	[Dec/1992] </_Data collection to (M/Y)_>
<_Source of dataset_> 			Survey conducted by LKA Department of 
								Census and Statistics, 
								Ministry Policy Planning and Implementation;
								Data was acquired internally through I2D2.</_Source of dataset_>
								Can be downloaded from http://nada.statistics.gov.lk/index.php/catalog but 
								with only 25% of the full file through registration. 
<_Sample size (HH)_> 			18,828 </_Sample size (HH)_>
<_Sample size (IND)_> 			91,624 </_Sample size (IND)_>
<_Sampling method_> 			A stratified two-stage probability sample design
								used with census blocks as PSUs and housing units
								as secondary and final sampling units. </_Sampling method_>
<_Geographic coverage_> 		9 provinces devided into urban and rural areas 
								and the greater colombo area. </_Geographic coverage_>
								- Greater Colombo (Colombo MC+Dehiwela-Mt.Lavinia MC+Kotte UC)
								- Western Province (Remainder)
								- Southern Province
								- Northern Province
								- Eastern Province
								- North Western Province
								- North Central Province
								- Uva Province
								- Sabaragamuwa Province
<_Currency_> 					Sri Lanka Rupee </_Currency_>
-----------------------------------------------------------------------
<_ICLS Version_>				ICLS 13 </_ICLS Version_>
<_ISCED Version_>				ISCED-2011 </_ISCED Version_>
<_ISCO Version_>				ISCO 88 </_ISCO Version_>
<_OCCUP National_>				N/A </_OCCUP National_>
<_ISIC Version_>				ISIC Rev.3 </_ISIC Version_>
<_INDUS National_>				N/A </_INDUS National_>
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
local server  "Y:\GLD-Harmonization\573465_JT"
local country "LKA"
local year    "1992"
local survey  "LFS"
local vermast "V01"
local veralt  "V01"

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

	*use "`path_in_stata'\lfsdata.dta", clear
	use "C:\Users\IrIs_\OneDrive - Georgetown University\GLD\LKA\LKA_1992_LFS\LKA_1992_LFS_v01_M\Data\Stata\lfsdata.dta"


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
	gen icls_v="ICLS-13"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	gen isced_version="isced_2011"
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
	gen isco_version="isco_1988"
	label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
	gen isic_version="isic_3"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	*gen int year=`year'
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
	gen int_year=`year'
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen int_month=month
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


/*<_hhid_>

According to the questionnaire, total housing units surveyed should be 10,080 in 
total in a year; 2,520 per quarter (10 HH from each sampling block, 252 blocks per 
quarter).

Without knowing if household ID changes every month (i.e. same household surveyed 
consecutively in two months are assigned with the same ID), two ways to try to code
hhid:

1) A combination with "month":
	
	egen hhid=concat(month province sector district block hhid_orig), punct("-")
	preserve
	keep quarter hhid
	duplicates drop
	
. tab quarter

    quarter |      Freq.     Percent        Cum.
------------+-----------------------------------
         01 |      4,239       25.33       25.33
         02 |      4,141       24.75       50.08
         03 |      4,150       24.80       74.88
         04 |      4,203       25.12      100.00
------------+-----------------------------------
      Total |     16,733      100.00
	  
This way produces much more than 2,520 housing units per quarter.	  


2) A combination without "month": 
	
	egen hhid=concat(province sector district block hhid_orig), punct("-")
	preserve
	keep quarter month hhid
	duplicates drop
	bys quarter hhid: gen hhcount=cond(_N==1,1,_n)
	replace hhcount=0 if hhcount!=1
	bys quarter: egen hhcount_ttl=sum(hhcount)
	
	. tab quarter hhcount_ttl

           |                 hhcount_ttl
   quarter |      1789       1810       1827       1839 |     Total
-----------+--------------------------------------------+----------
        01 |         0          0          0      4,239 |     4,239 
        02 |     4,141          0          0          0 |     4,141 
        03 |         0      4,150          0          0 |     4,150 
        04 |         0          0      4,203          0 |     4,203 
-----------+--------------------------------------------+----------
     Total |     4,141      4,150      4,203      4,239 |    16,733 

This way produces less housing unit per quarter.

However, coding hhid without month will lead to duplicates of households within the same month.

We included month into hhid coding which will produce 18,828 unique household ids
per year, accounting for 94.14% of the target of 20,000 households.

*<_hhid_>*/


*<_hhid_>
	foreach v of varlist month province sector district{
		tostring `v', replace format(%02.0f)
	}	
	rename hhid hhid_orig
	gen hhno=hh_unit+hhid_orig
	egen hhid=concat(month province sector subsector district block hhno)
	label var hhid "Household id"
*</_hhid_>


*<_pid_>
	tostring p1, gen(strp_id) format(%02.0f)
	egen pid=concat(hhid strp_id), punct("-")
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
	*gen weight=wt_hh
	label var weight "Household sampling weight"
*</_weight_>


/*<_psu_note_>

	egen psu1=concat(quarter_str province_str sector_str district_str block_str)
	egen psu2=concat(month_str province_str sector_str district_str block_str)
	egen psu3=concat(province_str sector_str district_str block_str)

Unique counts of PSU per year:

psu1:689
psu2:1,684
psu3:174
	
. tab quarter psuttl1

           |             psuttl1
   quarter |       171        173        174 |     Total
-----------+---------------------------------+----------
         1 |         0          0     23,053 |    23,053 
         2 |    22,778          0          0 |    22,778 
         3 |    22,792          0          0 |    22,792 
         4 |         0     23,001          0 |    23,001 
-----------+---------------------------------+----------
     Total |    45,570     23,001     23,053 |    91,624 
	 
	 
. tab quarter psuttl2

           |             psuttl2
   quarter |       417        419        424 |     Total
-----------+---------------------------------+----------
         1 |         0          0     23,053 |    23,053 
         2 |    22,778          0          0 |    22,778 
         3 |         0     22,792          0 |    22,792 
         4 |         0          0     23,001 |    23,001 
-----------+---------------------------------+----------
     Total |    22,778     22,792     46,054 |    91,624 

	 
. tab quarter psuttl3

           |             psuttl3
   quarter |       171        173        174 |     Total
-----------+---------------------------------+----------
         1 |         0          0     23,053 |    23,053 
         2 |    22,778          0          0 |    22,778 
         3 |    22,792          0          0 |    22,792 
         4 |         0     23,001          0 |    23,001 
-----------+---------------------------------+----------
     Total |    45,570     23,001     23,053 |    91,624 

*<_psu_note_>*/


*<_psu_>
	egen psu=concat(month province sector district block)
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu=hhid
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	egen strata=concat(province sector district)
	label var strata "Strata"
*</_strata_>


*<_wave_>
	gen wave=quarter
	label var wave "Survey wave"
*</_wave_>

}

/*%%=============================================================================================
	3: Geography
================================================================================================*/

{

*<_urban_>
	gen urban=.
	replace urban=1 if subsector=="0"
	replace urban=0 if subsector=="2"|subsector=="1"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
	label var urban "Location is urban"
*</_urban_>


/*<_subnatid1_note_>

In 1992, Northern and Western provinces were excluded.

*<_subnatid1_note_>*/


*<_subnatid1_>
	destring province, gen(pronum)
	gen subnatid1=pronum
	label de lblsubnatid1 1 "1 - Western" 2 "2 - Central" 3 "3 - Southern" 4 "4 - Northern Area" 5 "5 - Eastern" 6 "6 - North-western" 7 "7 - North-central" 8 "8 - Uva" 9 "9 - Sabaragamuwa"
	label values subnatid1 lblsubnatid1
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	gen subnatid2=province+district
	destring subnatid2, replace
	label de lblsubnatid2 11 "11-Colombo" 12 "12-Gampaha" 13 "13-Kalutara" 21 "21-Kandy" 22 "22-Matale" 23 "23-Nuwara Eliya" 31 "31-Galle" 32 "32-Matara" 33 "33-Hambantota" 41 "41-Jaffna" 42 "42-Kilinochchi" 43 "43-Mannar" 51 "51-Batticaloa" 53 "53-Trincomalee" 61 "61-Kurunegala" 62 "62-Puttalam" 71 "71-Anradhapura" 72 "72-Polonnaruwa" 81 "81-Badulla" 82 "82-Moneragala" 91 "91-Ratnapura" 92 "92-Kegalle"
	label values subnatid2 lblsubnatid2
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	gen subnatid3=.
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>	
	decode urban, gen(urban_name)
	decode subnatid2, gen(disname)
	egen subnatidsurvey=concat(disname urban_name), punct("-")
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
	bys hhid: egen hsize=max(p1)
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	*gen age=.
	replace age=98 if age>98 & age!=.
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male=sex
	recode male 2=0
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


/*<_relationharm_note_>

189 households have no household head; 139 of which do not have household member 
number one, meaning hh member ID starting from 2 or other numbers. 

5 households have only children in the households and the olderest
are either 15 or 10 years old. These three households were not assigned with household heads. 
"04910104021"
"06620104031"
"12720101071" 
"10322303061"
"04620101021"

5 households contain only non-relatives and thus they also stay put without household head assigned.
02210301041 
02210301071
02210301081
02210301091
07100113081
02210301051		

Other households that have multipal household heads are mainly because of reporting error,
i.e. all household members are reported as the household head. In these situations,
we only kept member identified as No.1 as the head, others "Other Relatives".

One household "03100102101" is a special case in that its member ID starts from 3 and
there are only "Other relatives" and "Children" originally in the household. 
Considering the two children are adults (25 and 22), we coded the 25-year old
child as the head. 	  

*<_relationharm_note_>*/


*<_relationharm_>
	gen byte relationharm=p3
	recode relationharm (7/9=6)
	
	gen head=1 if relationharm==1
	bys hhid: egen headsum=total(head)
	bys hhid: egen olderest=max(age) if !mi(age)&relationharm!=6
	bys hhid: egen pidmin=min(p1)
	replace relationharm=1 if relationharm!=6&headsum==0&p1==1&age>17
	gen relative=1 if inrange(relationharm,1,5)
	replace relative=0 if relative!=1
	replace head=1 if relationharm==1
	bys hhid: egen headsum0=total(head)
	bys hhid: egen any=total(relative)
	
	replace relationharm=1 if headsum0==0&age==olderest&olderest>17
	replace head=1 if relationharm==1
	bys hhid: egen headsum1=total(head)
	
	replace relationharm=5 if headsum1==2&head==1&age<18&age!=olderest
	replace relationharm=5 if headsum1==2&head==1&p1!=1
	replace head=. if relationharm!=1
	bys hhid: egen headsum2=total(head)
	
	replace relationharm=5 if inrange(headsum2,3,6)&p1!=1
	replace relationharm=1 if pid=="03100102101-06"


	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm lblrelationharm
	drop head-headsum2 
*</_relationharm_>


*<_relationcs_>
	gen relationcs=p3
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital=maritals 
	recode marital (1=2) (2=1) (3=5) (5=4)
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

{
*<_migrated_mod_age_>
	gen migrated_mod_age=12
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time=99
	label var migrated_ref_time "Reference time applied to migration questions"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen migrated_binary=.
	replace migrated_binary=0 if inrange(B_19,11,42)&mi(B_20A)&mi(B_21)&mi(B_22)
	replace migrated_binary=1 if !mi(B_21)
	label de lblmigrated_binary 0 "No" 1 "Yes"
	replace migrated_binary=. if age<migrated_mod_age
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


/* <_migrated_years_note_> 

In the questionnaire the years of migration is divided into two parts:
Year and Month. So the var “migrated_years” is a combination of year
and month converted into year's term.

</_migrated_years_note_> */


*<_migrated_years_>
   gen migrated_years=.
   gen migyear=round(B_20B/12,0.1)
   replace migrated_years=B_20A+migyear
   replace migrated_years=. if migrated_binary!=1
   replace migrated_years=. if age<migrated_mod_age
   label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban=.
	replace migrated_from_urban=. if age<migrated_mod_age
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen migrated_from_cat=.
	replace migrated_from_cat=5 if inlist(B_21,2,3,54,55,56,57,58,60,88,90)
	
	gen migregion=.
	replace migregion=1 if inrange(B_21,11,13)
	replace migregion=2 if inrange(B_21,21,25)
	replace migregion=3 if inrange(B_21,31,34)
	replace migregion=4 if inrange(B_21,41,42)
	replace migrated_from_cat=4 if migregion!=subnatid1&migrated_binary==1&!mi(migregion)
	
	gen migdis=.
	replace migdis=B_21 if inrange(B_21,11,42) 
	replace migrated_from_cat=3 if migregion==subnatid1&(migdis!=subnatid2&!mi(migdis))
	
	replace migrated_from_cat=2 if migdis==subnatid2&!mi(migdis)
	
	replace migrated_from_cat=. if age<migrated_mod_age|migrated_binary!=1
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen migrated_from_code=B_21 if migrated_from_cat==2 
	replace migrated_from_code=migregion if inlist(migrated_from_cat,3,4) 
	replace migrated_from_code=. if migrated_from_cat==5
	replace migrated_from_code=. if migrated_binary!=1
	replace migrated_from_code=. if age<migrated_mod_age
	label de lblmigcode 1 "1.Eastern" 2 "2.Northern" 3 "3.Southern" 4 "4.Western Area" 12 "12. Kenema" 13 "13. Kono" 21 "21. Bombali" 22 "22. Kambia" 23 "23. Koinadugu" 24 "24. Port Loko" 25 "25. Tonkolili" 31 "31. Bo" 32 "32. Bonthe" 33 "33. Moyamba" 34 "34. Pujehun" 41 "41. Western Rural" 42 "42. Western Urban"
	label values migrated_from_code lblmigcode
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
	
	drop migyear migregion migdis 
*</_migrated_from_code_>


*<_migrated_from_country_>
	decode B_21, gen(migrated_from_country)
	replace migrated_from_country="" if !inlist(B_21,2,3,54,55,56,57,58,60,88,90)
	replace migrated_from_country="LBR" if B_21==2
	replace migrated_from_country="GIN" if B_21==3
	replace migrated_from_country="GMB" if B_21==54
	replace migrated_from_country="GHA" if B_21==55
	replace migrated_from_country="GNB" if B_21==56
	replace migrated_from_country="CIV" if B_21==57
	replace migrated_from_country="MLI" if B_21==58
	replace migrated_from_country="NGA" if B_21==60
	replace migrated_from_country="Other African countries" if B_21==88
	replace migrated_from_country="Other non-African countries" if B_21==90
	replace migrated_from_country="" if migrated_binary!=1
	replace migrated_from_country="" if age<migrated_mod_age
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason=B_22
	recode migrated_reason (1=3) (2=1) (3 7 9=5) (4=2) (5/6 8=4)
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
	replace school=0 if B_2==2
	replace school=1 if B_2==1
	replace school=. if age<ed_mod_age & age!=.
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school lblschool
*</_school_>


*<_literacy_>
	gen byte literacy=B_1
	recode literacy (2/4=0) 
	replace literacy=. if age<ed_mod_age & age!=.
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


/*<_educy_note_>

Original categorization of the highest educational level ever attended of 
variable B_5 is:

0	(no label)
1	Sub-Standard A, Grade 1 and Nursery 1 ---> 1 year
2	Standard 1, Grade 2 and Class 1 ---> 2 year
3	Standard 2, Grade 3 and Class 2 ---> 3 year
4	Standard 3, Grade 4 and Class 3 ---> 4 year
5	Standard 4, Grade 5 and Class 4 ---> 5 year
6	Standard 5, Grade 6 and Class 5 ---> 6 year
7	Standard 6, Grade 6 and Class 6 ---> 6 year
8	Grade 7 and JSS 1 ---> 7 year
9	Form 1 and JSS 2 ---> 8 year
10	Form 2 and JSS 3 ---> 9 year
11	Form 3 and SSS 1 ---> 10 year
12	Form 4 and SSS 2 ---> 11 year
13	Form 5 (GCE), Form 6 Lower/SSS 3 ---> 12 year
14	Form 6 Lower, Form 6 and Form 6 upper/SSS 4 ---> 13 year
15	Form 6 Upper and GCE (A) ---> 13 year
16	College Students  ---> 17 year
17	University Undergraduate Students  ---> 17 year
18	Certificates  ---> 16 year
19	Diploma  ---> 17 year
20	Post Graduate Diploma Students ---> 18 year
21	Bachelors Degree ---> 17 year
22	Masters Degree or Higher ---> 18 year
*<_educy_note_>*/		  


*<_educy_>
	gen byte educy=.
	replace educy=B_5 if inrange(B_5,1,6)
	replace educy=B_5-1 if inrange(B_5,7,14)
	replace educy=13 if B_5==15
	replace educy=16 if B_5==18
	replace educy=17 if inlist(B_5,16,17,19,21)
	replace educy=18 if B_5==20|B_5==22
	replace educy=. if age<5
	replace educy=. if educy>age & !mi(educy) & !mi(age)
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7=.
	replace educat7=1 if B_2==2
	replace educat7=2 if inrange(B_5,1,5)
	replace educat7=3 if inrange(B_5,6,7)
	replace educat7=4 if inrange(B_5,8,13)
	replace educat7=5 if inrange(B_5,14,15)
	replace educat7=6 if inrange(B_5,18,19)
	replace educat7=7 if inlist(B_5,16,17,20,21,22)
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
	gen educat_orig=B_5
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
	gen educat_isced=.
	replace educat_isced=100 if inrange(B_5,1,7) 
	replace educat_isced=244 if inrange(B_5,8,10) 
	replace educat_isced=344 if inrange(B_5,11,14) 
	replace educat_isced=344 if inrange(B_5,11,14) 
	replace educat_isced=354 if B_5==15
	replace educat_isced=554 if B_5==18
	replace educat_isced=665 if inlist(B_5,16,17,19,21)
	replace educat_isced=767 if B_5==22
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
	gen vocational=B_12
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


/*<_vocational_field_orig_note_>

764 observations answered that they did not compete training (B_12==2)) but they
answered the area of their trainings. 

*<_vocational_field_orig_note_>*/


*<_vocational_field_orig_>
	gen vocational_field_orig=B_17
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
/*<_lstatus_note_>

Better to use the questions to code variables instead of the "Enumerator CHECK"
question as the latter have some errors.	

*<_lstatus_note_>*/

	
*<_lstatus_>
	gen byte lstatus=.
	gen temp=1 if D_2==1|D_2==2|D_2==3|D_3==1|D_3==2|D_4==1
	replace lstatus=1 if C_1A==1|C_1B==1|C_1C==1|C_1D==1
	replace lstatus=1 if lstatus!=1&temp==1
	replace lstatus=2 if temp!=1&lstatus!=1&D_5==1&D_9==1
	replace lstatus=3 if lstatus==. 
	replace lstatus=. if age<minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


/*<_potential_lf_note_>
Note: var "potential_lf" only takes value if the respondent is not in labor force. (lstatus==3)

"potential_lf"=1 if the person is
1)available but not searching or D_9==1 & D_5==2
2)searching but not immediately available to work or D_9==2 & D_5==1
</_potential_lf_note_>*/


*<_potential_lf_>
	gen byte potential_lf=.
	replace potential_lf=1 if [D_9==1 & D_5==2] | [D_9==2 & D_5==1]
	replace potential_lf=0 if [D_9==1 & D_5==1] | [D_9==2 & D_5==2]
	replace potential_lf=. if age < minlaborage
	replace potential_lf=. if lstatus!=3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen byte underemployment=.
	replace underemployment=1 if I_1==1&inrange(I_7,1,3)
	replace underemployment=0 if I_1==2
	replace underemployment=. if age<minlaborage
	replace underemployment=. if lstatus!=1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason=D_6
	recode nlfreason (1/2=4) (3 6 8/15=5) (4=1) (5=3) (7=2)
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l=D_8
	recode unempldur_l (1=0) (2=1) (4=6) (5=12) (6=24)
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=D_8
	recode unempldur_u (2=3) (3=6) (4=12) (5=24) (6=.)
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte empstat=E_9
	recode empstat (2 8=1) (3 5=4) (6/7=5) (9=2)
	replace empstat=. if lstatus!=1
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec=E_10
	recode ocusec (1/2=1) (3 8 10=4) (4=3) (5/7 9=2) 
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig=E_4 
	replace industry_orig=. if lstatus!=1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	gen industrycat_isic=E_4 
	tostring industrycat_isic, format(%04.0f) replace
	replace industrycat_isic="" if industrycat_isic=="."
	replace industrycat_isic="" if lstatus!=1
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen long industrycat10=floor(E_4/100)
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
	gen occup_orig=E_3
	replace occup_orig=. if lstatus!=1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	gen str4 occup_isco=string(E_3, "%04.0f") 
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
	 gen occup=floor(E_3/1000)
	 recode occup (0=10)
	 replace occup=. if lstatus!=1
	 label var occup "1 digit occupational classification, primary job 7 day recall"
  	 la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	 label values occup lbloccup
*</_occup_>


/*<_wage_no_compen_note_>

One observations has answered "000.821.000" to question E_19C, and one 
"000.000.000" to question E_19D were coded missing.

In the questionnaire, "000,000,088" is an indication of greater than or equal to 
1 billion Leones whereas zero means no payment.

*<_wage_no_compen_note_>*/


*<_wage_no_compen_>
	destring E_19C, gen(cash_num) ignore(".") 
	destring E_19D, gen(goods_num) ignore(".")
	replace cash_num=. if E_19C=="000.821.000"
	gen double wage_no_compen=cash_num+goods_num
	replace wage_no_compen=wage_no_compen/E_19B if inlist(E_19A,1,2)
	replace wage_no_compen=wage_no_compen/E_19B if E_19A==3&!inlist(E_19B,1,2)
	replace wage_no_compen=wage_no_compen/E_19B if E_19A==4&!inlist(E_19B,1,2,3)
	replace wage_no_compen=. if lstatus!=1
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
	gen byte unitwage=.
	replace unitwage=1 if E_19A==2
	replace unitwage=2 if E_19A==3&E_19B!=2
	replace unitwage=3 if E_19A==3&E_19B==2
	replace unitwage=4 if E_19A==4&E_19B==2
	replace unitwage=5 if E_19A==4&E_19B!=2&E_19B!=3
	replace unitwage=6 if E_19A==4&E_19B==3
	replace unitwage=9 if E_19A==1
	replace unitwage=. if lstatus!=1
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


/*<_whours_note_>

E_5 is the number of DAYs the respondent worked in the past week;
E_6 is the average work hours per day in the past week. 

90 observations worked more than 20 hours on average in the past week, 7 worked more
than 24 hours which is impossible;
and 1 observation worked 8 days in the past week which is also impossible.

People who have already stated that they were temporarily not working were coded 
missing for work hours in the past week.

*<_whours_note_>*/


*<_whours_>
	gen day=E_5 if inrange(E_5,1,7) 
	gen hour=E_6 if inrange(E_6,1,24)
	gen whours=day*hour
	replace whours=. if temp==1
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
	gen byte contract=.
	replace contract=1 if !mi(E_12)
	replace contract=0 if E_12==.&lstatus==1
	replace contract=. if lstatus!=1
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte healthins=.
	replace healthin=1 if E_18==1
	replace healthin=0 if E_18==2
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
	replace union=1 if inrange(H_1,1,3)
	replace union=0 if H_1==4
	replace union=. if lstatus!=1
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
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
	gen byte empstat_2=F_10 if inrange(F_10,1,9)
	recode empstat_2 (2 8=1) (3 5=4) (6/7=5) (9=2)
	replace empstat_2=. if lstatus!=1|F_1!=1
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2=F_11 if inrange(F_11,1,10)
	recode ocusec_2 (1/2=1) (3 8 10=4) (4=3) (5/7 9=2) 
	replace ocusec_2=. if lstatus!=1|F_1!=1
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	la de lblocusec_2 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_2 lblocusec_2
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2=F_5
	replace industry_orig_2=. if F_1!=1
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	gen industrycat_isic_2=F_5
	tostring industrycat_isic_2, format(%04.0f) replace
	replace industrycat_isic_2="" if industrycat_isic_2=="."
	replace industrycat_isic_2="" if F_1!=1
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen long industrycat10_2=floor(F_5/100)
	recode industrycat10_2 (2/3=1) (5/9=2) (10/33=3) (35/39=4) (41/43=5) (45/47 55/56=6) (49/53 58/63=7) (64/82=8) (84=9) (85/99=10)
	replace industrycat10_2=. if F_1!=1
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
	gen occup_orig_2=F_4
	replace occup_orig_2=. if F_1!=1
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen str4 occup_isco_2=string(F_4,"%04.0f")
	replace occup_isco_2="" if occup_isco_2=="."
	replace occup_isco_2="" if F_1!=1
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_skill_2_>
	gen skill_level_2=substr(occup_isco_2,1,1)
	destring skill_level_2, replace 
	gen occup_skill_2=.
	replace occup_skill_2=1 if skill_level_2==9
	replace occup_skill_2=2 if inrange(skill_level_2,4,8)
	replace occup_skill_2=3 if inrange(skill_level_2,1,3)
	replace occup_skill_2=. if skill_level_2==0|F_1!=1
	label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>


*<_occup_2_>
	gen occup_2=floor(F_4/1000)
	recode occup_2 (0=10)
	replace occup_2=. if F_1!=1
	label var occup_2 "1 digit occupational classification secondary job 7 day recall"
	label values occup_2 lbloccup
*</_occup_2_>


*<_wage_no_compen_2_>
	destring (F_20C), gen(cash_2)
	destring (F_20D), gen(goods_2)
	gen double wage_no_compen_2=cash_2+goods_2
	replace wage_no_compen_2=wage_no_compen_2/F_20B if inlist(F_20,1,2)
	replace wage_no_compen_2=wage_no_compen_2/F_20B if F_20==3&!inlist(F_20B,1,2)
	replace wage_no_compen_2=wage_no_compen_2/F_20B if F_20==4&!inlist(F_20B,1,2,3)
	replace wage_no_compen_2=. if F_1!=1
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2=.
	replace unitwage_2=1 if F_20==2
	replace unitwage_2=2 if F_20==3&F_20B!=2
	replace unitwage_2=3 if F_20==3&F_20B==2
	replace unitwage_2=4 if F_20==4&F_20B==2
	replace unitwage_2=5 if F_20==4&F_20B!=2&F_20B!=3
	replace unitwage_2=6 if F_20==4&F_20B==3
	replace unitwage_2=9 if F_20==1
	replace unitwage_2=. if F_1!=1
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>


/*<_whours_2_note_>

There are some errors in the reported work hours. 20 observations' main and secondary
jobs count more than 168 hours in total.

Observation "04-330602292-01", for an instance, has worked 168 hours each for main
and secondary job. 

*<_whours_2_note_>*/


*<_whours_2_>
	gen day_2=F_6 if inrange(F_6,1,7)
	gen hour_2=F_7 if inrange(F_7,1,24)
	gen whours_2=day_2*hour_2
	replace whours_2=. if F_1!=1
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

/*<_lstatus_year_note_>

The G section actually asks for the economic activities in the last 12 months 
in stead of the past week. But it does not have questions sufficient for coding 
labor status unemployed and non-labor force, nor potential labor force.

*<_lstatus_year_note_>*/


*<_lstatus_year_>
	gen byte lstatus_year=.
	replace lstatus_year=. if age<minlaborage & age!= .
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>


*<_potential_lf_year_>
	gen byte potential_lf_year=.
	replace potential_lf_year=. if age<minlaborage&age!= .
	replace potential_lf_year=. if lstatus_year!= 3
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
	gen byte empstat_year=G_10 
	recode empstat_year (2 8=1) (3 5=4) (6/7=5) (9=2)
	replace empstat_year=. if G_2!=1
	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>


*<_ocusec_year_>
	gen byte ocusec_year=G_11
	recode ocusec_year (1/2=1) (3 8 10=4) (4=3) (5/7 9=2)
	replace ocusec_year=. if G_2!=1
	label var ocusec_year "Sector of activity primary job 12 day recall"
	la de lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_year lblocusec_year
*</_ocusec_year_>


*<_industry_orig_year_>
	gen industry_orig_year=G_7
	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	gen industrycat_isic_year=G_7
	tostring industrycat_isic_year, format(%04.0f) replace
	replace industrycat_isic_year="" if industrycat_isic_year=="."
	replace industrycat_isic_year="" if G_1!=1
	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>


*<_industrycat10_year_>
	gen byte industrycat10_year=floor(G_7/100)
	recode industrycat10_year (2/3=1) (5/9=2) (10/33=3) (35/39=4) (41/43=5) (45/47 55/56=6) (49/53 58/63=7) (64/82=8) (84=9) (85/99=10)
	replace industrycat10_year=. if G_1!=1
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
	gen occup_orig_year=G_6
	replace occup_orig_year=. if G_1!=1
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	gen str4 occup_isco_year=string(G_6,"%04.0f")
	replace occup_isco_year="" if G_1!=1|occup_isco_year=="."
	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_skill_year_>
	gen skill_level_year=substr(occup_isco_year,1,1)
	destring skill_level_year, replace
	gen occup_skill_year=.
	replace occup_skill_year=1 if skill_level_year==9
	replace occup_skill_year=2 if inrange(skill_level_year,4,8)
	replace occup_skill_year=3 if inrange(skill_level_year,1,3)
	replace occup_skill_year=. if skill_level_year==0|G_1!=1
	label var occup_skill_year "Skill based on ISCO standard primary job 12 month recall"
*</_occup_skill_year_>


*<_occup_year_>
	gen byte occup_year=floor(G_6/1000)
	replace occup_year=. if G_1!=1
	label var occup_year "1 digit occupational classification, primary job 12 month recall"
	la de lbloccup_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_year lbloccup_year
*</_occup_year_>


*<_wage_no_compen_year_>
	destring G_20C, gen (cash_year)
	destring G_20D, gen(goods_year)
	gen double wage_no_compen_year=cash_year+goods_year
	replace wage_no_compen_year=wage_no_compen_year/G_20B if inlist(G_20,1,2)
	replace wage_no_compen_year=wage_no_compen_year/G_20B if G_20==3&!inlist(G_20,1,2)
	replace wage_no_compen_year=wage_no_compen_year/G_20B if G_20==4&!inlist(G_20,1,2,3)
	replace wage_no_compen_year=. if G_1!=1
	label var wage_no_compen_year "Last wage payment primary job 12 month recall"
*</_wage_no_compen_year_>


*<_unitwage_year_>
	gen byte unitwage_year=.
	replace unitwage_year=1 if G_20==2
	replace unitwage_year=2 if G_20==3&G_20B!=2
	replace unitwage_year=3 if G_20==3&G_20B==2
	replace unitwage_year=4 if G_20==4&G_20B==2
	replace unitwage_year=5 if G_20==4&G_20B!=2&G_20B!=3
	replace unitwage_year=6 if G_20==4&G_20B==3
	replace unitwage_year=6 if G_20==4&G_20B==1
	replace unitwage_year=. if G_1!=1
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
	replace contract_year=1 if !mi(G_13)
	replace contract_year=0 if G_1==1&mi(G_13)
	replace contract_year=. if G_1!=1
	label var contract_year "Employment has contract primary job 12 month recall"
	la de lblcontract_year 0 "Without contract" 1 "With contract"
	label values contract_year lblcontract_year
*</_contract_year_>


*<_healthins_year_>
	gen byte healthins_year=1 if G_19==1
	replace healthins_year=0 if G_19==2
	replace healthins_year=. if G_1!=1
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
	replace njobs=1 if lstatus==1&F_1!=1
	replace njobs=2 if lstatus==1&F_1==1
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

save "`path_output'\\`level_2_harm'_ALL.dta", replace

*</_% SAVE_>
