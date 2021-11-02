
/*%%=============================================================================================
	0: GLD Harmonization Preamble
================================================================================================*/

/* -----------------------------------------------------------------------
<_Program name_>				ZAF_2009_QLFS_v01_M_v01_A_GLD_ALL.do </_Program name_>
<_Application_>					Stata MP 16.1 <_Application_>
<_Author(s)_>					Wolrd Bank Job's Group </_Author(s)_>
<_Date created_>				2021-06-20 </_Date created_>
-------------------------------------------------------------------------
<_Country_>						South Africa(ZAF) </_Country_>
<_Survey Title_>				Labor Market Dynamics in South Africa </_Survey Title_>
<_Survey Year_>					2009 </_Survey Year_>
<_Study ID_>					ZAF_2009_LMDSA_v01_M </_Study ID_>
<_Data collection from (M/Y)_>	[MM/YYYY] </_Data collection from (M/Y)_>
<_Data collection to (M/Y)_>	[MM/YYYY] </_Data collection to (M/Y)_>
<_Source of dataset_> 			DataFirst </_Source of dataset_>
								https://www.datafirst.uct.ac.za/dataportal/index.php/catalog/237
<_Sample size (HH)_> 			47,334 </_Sample size (HH)_>
<_Sample size (IND)_> 			173,412</_Sample size (IND)_>
<_Sampling method_> 			Stratified two-stage cluster sampling method </_Sampling method_>
<_Geographic coverage_> 		Province </_Geographic coverage_>
<_Currency_> 					South African Rand </_Currency_>
-----------------------------------------------------------------------
<_ICLS Version_>				ICLS 13 </_ICLS Version_>
<_ISCED Version_>				ISCED-2011 </_ISCED Version_>
<_ISCO Version_>				ISCO-88 </_ISCO Version_>
<_OCCUP National_>				SASCO-2003 </_OCCUP National_>
<_ISIC Version_>				ISIC Rev 3 </_ISIC Version_>
<_INDUS National_>				SIC 5 </_INDUS National_>

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
local 	cty 	`"ZAF"'
local 	usr		`"573465_JT"'
local 	surv_yr `"2009"'
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

	use "`input'\lmdsa_2009_v1.1_20150407.dta", clear

/*%%=============================================================================================
	2: Survey & ID
================================================================================================*/

{

*<_countrycode_>
	gen str4 countrycode="ZAF"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "QLFS"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "QLFS"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	gen icls_v = "ICLS-13"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_year_>
	gen int year = 2009
	label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen str3 vermast = "V01"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen str3 veralt = "V01"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen harmonization = "GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	gen int_year= 2009
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen int_month=.
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
	gen hhid=UQNO
	label var hhid "Household id"
*</_hhid_>


*<_pid_>
	egen pid=concat(hhid PERSONNO), p("0")
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
	gen weight = Weight
	label var weight "Household sampling weight"
*</_weight_>


*<_psu_>
	gen psu=substr(UQNO, 1, 8)
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu=.
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	gen strata=stratum
	label var strata "Strata"
*</_strata_>


*<_wave_>
	tostring Qtr, gen(wave) format(%02.0f)
	replace wave="Q"+substr(wave, 2, 1)
	label var wave "Survey wave"
*</_wave_>

}

/*%%=============================================================================================
	3: Geography
================================================================================================*/

{
/*<_urban_>
It is not clear how the three categories are defined because the code list in the
documentation does not match the raw dataset. According to QLFS documentation and
urbanization stats from:
https://data.worldbank.org/indicator/SP.URB.TOTL.IN.ZS?locations=ZA,
the final code list should be
1=urban formal(urban)
2=urban informal(urban)
4=tribal areas(rural)
5=rural formal(rural)
</_urban_>*/


*<_urban_>
	gen byte urban=Geo_type
	recode urban 1/2=1 4/5=0
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
	gen byte subnatid1 = .
	replace subnatid1 = 1 if Province == 1
	replace subnatid1 = 2 if Province == 2
	replace subnatid1 = 3 if Province == 3
	replace subnatid1 = 4 if Province == 4
	replace subnatid1 = 5 if Province == 5
	replace subnatid1 = 6 if Province == 6
	replace subnatid1 = 7 if Province == 7
	replace subnatid1 = 8 if Province == 8
	replace subnatid1 = 9 if Province == 9
	label de lblsubnatid1 1 "1 - Western Cape" 2 "2 - Eastern Cape" 3 "3 - Northern Cape" 4 "4 - Free State" 5 "5 - KwaZulu-Natal" 6 "6 - North West" 7 "7 - Gauteng" 8 "8 - Mpumalanga" 9 "9 - Limpopo"
	label values subnatid1 lblsubnatid1
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	gen byte subnatid2 = .
	replace subnatid2 = 1 if Metro_code == 0
	replace subnatid2 = 2 if Metro_code == 71
	replace subnatid2 = 3 if Metro_code == 72
	replace subnatid2 = 4 if Metro_code == 73
	replace subnatid2 = 5 if Metro_code == 74
	replace subnatid2 = 6 if Metro_code == 75
	replace subnatid2 = 7 if Metro_code == 76
	label de lblsubnatid2 1 "1 - Non-Metro" 2 "2 - Cape Town" 3 "3 - eThekweni" 4 "4 - eKhurhuleni" 5 "5 - Johannesburg" 6 "6 - Nelson Mandela Metro" 7 "7 - Tshwane"
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


/* <_subnatid1_prev>
	subnatid1_prev is coded as missing unless the classification used for subnatid1 has changed since the previous survey.
</_subnatid1_prev> */


*<_subnatid1_prev_>
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
================================================================================================*/

{

*<_hsize_>
	egen tag=tag(pid hhid)
	egen hsize=total(tag), by(hhid)
	drop tag
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen age = Q14AGE
	replace age=98 if age>98 & age!=.
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = Q13GENDER
	recode male 2=0
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>

/*<_relationharm_>

Not asked, all we know is that the person with personal number equal to 1 is the head, the problem is that in some cases that person is not present, probably because he/she didn't spend four nights or more in this household. In those cases I assigned the eldest adult male (or female absent male) present as the household head.
42 observations were dropped due to no male memeber or multiple same old male (or female) members.
Age of majority is 18 in South Africa.

DROPS:
OBS: 42
HH: 16

Subnational ID at |
            First |
   Administrative |
            Level |      Freq.     Percent        Cum.
------------------+-----------------------------------
 1 - Western Cape |         19       45.24       45.24
 2 - Eastern Cape |          7       16.67       61.90
3 - Northern Cape |          3        7.14       69.05
   4 - Free State |          2        4.76       73.81
5 - KwaZulu-Natal |          2        4.76       78.57
   6 - North West |          2        4.76       83.33
      7 - Gauteng |          1        2.38       85.71
      9 - Limpopo |          6       14.29      100.00
------------------+-----------------------------------
            Total |         42      100.00

Note: 575 observations are under 18 (or not adult) yet are household heads because
they are originally asigned as the head --- their PERSONNO is 1.

</_relationharm_>*/

*<_relationharm_>
	gen byte relationharm=1 if PERSONNO==1
	bys hhid: egen hh=sum(relationharm==1)
	bys hhid: egen maxage=max(Q14AGE)
	replace maxage=. if maxage<18
	replace relationharm=1 if hh==0 & Q14AGE==maxage
	bys hhid: egen hh2=sum(relationharm==1)
	drop hh
	preserve
	collapse (max) relationharm, by(pid hhid hh2)
	bys hhid: egen hh3=sum(relationharm)
	drop hh2
	tempfile head_collapse
	save `head_collapse'
	restore
	merge m:1 pid hhid using `head_collapse'
	drop _merge
	replace relationharm=. if hh3==2 & Q13GENDER==2 & relationharm==1
	bys hhid: egen hh4=sum(relationharm==1)
	preserve
	collapse (max) relationharm, by(pid hhid hh4)
	bys hhid: egen hh5=sum(relationharm)
	save `head_collapse', replace
	restore
	merge m:1 pid hhid using `head_collapse'
	drop _merge
	bys hhid: egen male_present=max(Q13GENDER)
	replace male_present=0 if male_present==2
	replace relationharm=1 if hh5==0 & maxage>=18 & maxage<. & age==maxage & male_present==0
	preserve
	collapse (max) relationharm, by(pid hhid hh5)
	bys hhid: egen hh6=sum(relationharm)
	save `head_collapse', replace
	restore
	merge m:1 hhid pid using `head_collapse'
	drop if hh6!=1
	bys pid: egen head_max=max(!missing(relationharm))
	bys pid: egen head_min=min(!missing(relationharm))
	replace relationharm=1 if head_max==1&head_min==0
	drop _merge hh2 hh3 hh4 hh5 hh6 head_* _merge maxage male_present
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = relationharm
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital = Q16MARITALSTATUS
	recode marital 5=2 2=3 3=5
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
================================================================================================*/


{

*<_ed_mod_age_>

/* <_ed_mod_age_note>

Education module is only asked to those 0 and older.

</_ed_mod_age_note> */

	gen byte ed_mod_age = 0
	label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school = .
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


/*<_educy_>

The National Technical Certificate level 1, 2, and 3 are mapped to grade 10, 11, and 12
respectively. In South Africa, one option for students is to exit school with GETC
or grade 9 and enter a technical education program at N1, proceeding to N2.

224 observations' years of education exceed their age:

           |   Highest education
Individual |         level
       age | Bachelors  Bachelors
	       |  Degree     Degree &
		   |	            Post
		   |		    Graduate  |     Total
-----------+----------------------+----------
         1 |         2          1 |         3
         2 |        11          1 |        12
         3 |        18          0 |        18
         4 |        33          0 |        33
         5 |        11          0 |        11
         6 |         5          0 |         5
         7 |         2          3 |         5
         8 |        11          3 |        14
         9 |         9          2 |        11
        10 |        13          5 |        18
        11 |        14          5 |        19
        12 |         5          4 |         9
        13 |         9          2 |        11
        14 |        24          7 |        31
        15 |        19          5 |        24
-----------+----------------------+----------
     Total |       186         38 |       224

</_educy_>*/


*<_educy_>
	gen byte educy=Q17EDUCATION if inrange(Q17EDUCATION,0,12)
	replace educy=Q17EDUCATION-3 if inrange(Q17EDUCATION,13,18)
	replace educy=11 if inrange(Q17EDUCATION,19,20)
	replace educy=12 if inrange(Q17EDUCATION,21,22)
	replace educy=16 if inlist(Q17EDUCATION,23,25, 26)
	replace educy=19 if inlist(Q17EDUCATION,24,27,28)
	replace educy=. if inlist(Q17EDUCATION,29,30)
	replace educy=0 if Q17EDUCATION==98
	replace educy=. if age<ed_mod_age & age!=.
	replace educy=age if educy>age & !mi(educy) & !mi(age)
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7 = Education_Status
	recode educat7 7=.
	replace educat7=7 if inrange(Q17EDUCATION,21,28)
	replace educat7=. if age<ed_mod_age & age!=.
	label var educat7 "Level of education 1"
	la de lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete"
	label values educat7 lbleducat7
*</_educat7_>


*<_educat5_>
	gen byte educat5 = educat7
	recode educat5 (4=3) (5=4) (6 7=5)
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
	gen educat_orig = Q17EDUCATION
	label var educat_orig "Original survey education code"
*</_educat_orig_>


/*<_educat_isced_>

Var "Q17EDUCATION": What is the highest level of education that... has sucessfully completed?

No match for var "Q17EDUCATION" category 19-"Certificate with less than Grade 12/Std 10"
and 20-"Diploma with less than Grade 12/Std 10". So category 19 and 20 are left missing.

ISCED codes:http://uis.unesco.org/en/isced-mappings

Category 24-"Post Higher Diploma (Masters; Doctoral Diploma)" is mapped to the lower
bound -- "Master's'" in ISCED code.

</_educat_isced_>*/


*<_educat_isced_>
	gen educat_isced = Q17EDUCATION
	recode educat_isced 0=020 1/7=100 8/9=244 19/20=. 10/15=344 16=254 17=353 18=454 21=443 22=550 23=660 24=760 25/26=660
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
	gen vocational = .
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
	gen byte minlaborage = 15
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
	la de Status 2 "Unemployed" 3 "Discouraged job seeker" 4 "Other not economically active", modify
	gen byte lstatus = Status
 	recode lstatus 4=3
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


/*<_potential_lf_>
Note: var "potential_lf" is missing if the respondent is in labor force or unemployed; it only takes value if the respondent is not in labor force. (Status==3)

"potential_lf" = 1 if the person is
1)available but not searching or (Q39==1 & Q31ALOOKWRK ==2)
2)searching but not immediately available to work (Q31ALOOKWRK==1 & Q39!=1)

**********Including people who might have started business/were trying to start business**********
1)available but not starting any kind of business (Q310STARTBUSNS==1 & Q31BSTARTBUSNS==2)
2)starting business but not immediately available to work (Q31BSTARTBUSNS==1 & Q310STARTBUSNS==2)

Q31ALOOKWRK "looking for any kind of job in the last 4 weeks?"
Q31BSTARTBUSNS "trying to start a ny kin of business in the last 4 weeks?"
Q39JOBOFFER "availability if a suitable job were offered in last week"
Q310STARTBUSNS "Start a business if the circumstances have allowed?"
</_potential_lf_>*/


*<_potential_lf_>
	gen byte potential_lf = .
	replace potential_lf=1 if ( Status==3 & Q39JOBOFFER==1 & Q31ALOOKWRK==2 ) | (Status==3 & Q31ALOOKWRK==1 & Q39JOBOFFER!=1) | (Status==3 & Q310STARTBUSNS==1 & Q31BSTARTBUSNS==2) | (Status==3 & Q31BSTARTBUSNS==1 & Q310STARTBUSNS==2)
	replace potential_lf=0 if potential_lf!=1
	replace potential_lf = . if age < minlaborage & age != .
	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen byte underemployment = .
	replace underemployment=1 if (Q422MOREHRS==1 | Q422MOREHRS==3) | Q425STARTXWRK==1
	replace underemployment = . if age < minlaborage & age != .
	replace underemployment = . if lstatus == 1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason=Q35YNOTWRK
	recode nlfreason 4=3 3 5/7=5
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l=Q36TIMESEEK
	recode unempldur_l 1=0 2=3 3=6 4=9 5=12 6=36 7=61 8=.
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=Q36TIMESEEK
	recode unempldur_u 1=2 2=5 3=8 4=11 5=35 6=60 7 8=.
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte empstat=Q45WRK4WHOM
	recode empstat 4=2 2=3 3=4
	replace empstat=. if lstatus!=1
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec=Q415TYPEBUSNS
	recode ocusec 3/5=2 2=3 6=.
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig=Q43INDUSTRY
	replace industry_orig=. if lstatus!=1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	tostring Q43INDUSTRY, gen(indus_string)
	gen industrycat_isic=substr(indus_string, 1, 2) if Q43INDUSTRY>100
	replace industrycat_isic=indus_string if Q43INDUSTRY<100
	destring industrycat_isic, replace
	recode industrycat_isic (11=01) (12=02) (13=05) (21=10) (22=11) (23=12) (24=13) (25=14) (29=.) (30=15) (31=17) (32=20) (33=23) (34=26) (35=27) (36=31) (37=32) (38=34) (39=36) (41=40) (42=41) (50=45) (61=51) (62=52) (63=50) (64=55) (71=60) (72=61) (73=62) (74=63) (75=64) (81=65) (82=66) (83=67) (84=70) (85=71) (86=72) (87=73) (88=74) (91=75) (92=80) (93=85) (94=90) (95=91) (96=92) (99=93) (01=95) (02=99)

	replace industrycat_isic=16 if Q43INDUSTRY==306
	replace industrycat_isic=18 if inrange(Q43INDUSTRY, 314, 315)
	replace industrycat_isic=19 if inrange(Q43INDUSTRY, 316, 317)
	replace industrycat_isic=21 if Q43INDUSTRY==323
	replace industrycat_isic=22 if inrange(Q43INDUSTRY, 324, 325)
	replace industrycat_isic=24 if inrange(Q43INDUSTRY, 334, 335)
	replace industrycat_isic=25 if inrange(Q43INDUSTRY, 337, 338)
	replace industrycat_isic=28 if inrange(Q43INDUSTRY, 354, 355)
	replace industrycat_isic=29 if inrange(Q43INDUSTRY, 356, 358)
	replace industrycat_isic=30 if Q43INDUSTRY==359
	replace industrycat_isic=33 if inrange(Q43INDUSTRY, 374, 375)
	replace industrycat_isic=35 if inrange(Q43INDUSTRY, 384, 387)
	replace industrycat_isic=37 if Q43INDUSTRY==395
	gen industrycat_isic2=industrycat_isic*100
	drop industrycat_isic
	tostring industrycat_isic2, gen(industrycat_isic) format(%04.0f)
	drop industrycat_isic2
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen byte industrycat10=indus
	recode industrycat10 9 11=10
	replace industrycat10=9 if inrange(Q43INDUSTRY,911,917)
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
*</_industrycat10_>


*<_industrycat4_>
	gen byte industrycat4=industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4 "1 digit industry classification (Broad Economic Activities), primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
	gen occup_orig=Q42OCCUPATION
	replace occup_orig=. if lstatus!=1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	tostring Q42OCCUPATION, gen(occup_string)
	gen occupcat_isco=substr(occup_string, 1, 3)
	merge m:1 occupcat_isco using "C:\Users\wb573465\Desktop\ZAF_archive\GLD ISCO mapping files\ISCO\isco88_sasco03_mapping.dta"
	drop if _merge==2
	destring isco_88, replace
	gen occup_isco=isco_88*10
	replace occup_isco=9000 if Q42OCCUPATION==9999
	tostring occup_isco, replace
	drop _merge occup_string occupcat_isco sasco_occup isco_88 isco_occup
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_skill_>
	gen skill_level=substr(occup_isco, 1, 1)
	destring skill_level, replace
	gen occup_skill = .
	replace occup_skill=1 if inrange(skill_level, 1, 3)
	replace occup_skill=2 if inrange(skill_level, 4, 8)
	replace occup_skill=3 if inrange(skill_level, 9, 9)
	drop skill_level
	la de lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lblskill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_occup_>
	recode occup 10=9 11=.
	replace occup=. if Q42OCCUPATION==9999
	replace occup=10 if Q42OCCUPATION==5164
	replace occup=. if lstatus!=1
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>


*<_wage_no_compen_>
	gen double wage_no_compen=.
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
	gen byte unitwage=.
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


/*<_whours_>

Variable "Q418HRSWRK" is working hours for people who only have one job and it is missing for people who have more than one job.

Variable "Hrswrk" is equal to "Q418HRSWRK" for people who have one job and it is equal to variable "Q420TOTALHRSWRK" for thoes who have more than one job.

	egen primary=rowmax(Q420FIRSTHRSWRK Q420SECONDHRSWRK)
	replace primary=Q418HRSWRK if primary==. & Q418HRSWRK!=.
	gen first=1 if (primary==Q420FIRSTHRSWRK & primary !=.) | (primary==Q418HRSWRK & primary !=.)
	replace first=0 if primary!=. & primary==Q420SECONDHRSWRK

The main job was decided based on time spent.
0.14% of people who have jobs spend more time on their second job.

   first |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |        123        0.14        0.14
          1 |     90,657       99.86      100.00
------------+-----------------------------------
      Total |     90,780      100.00

<_whours_>*/

*<_whours_>
	gen whours=Q418HRSWRK
	egen primary=rowmax(Q420FIRSTHRSWRK Q420SECONDHRSWRK)
	replace whours=primary if Q418HRSWRK==.
	replace whours=. if lstatus!=1
	drop primary
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	gen wmonths=.
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


/* <_wage_total>
	Use gross wages when available and net wages only when gross wages are not available.
	This is done to make it easy to compare earnings in formal and informal sectors.
</_wage_total> */


*<_wage_total_>
	gen wage_total=.
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen byte contract=Q411CONTRACTTYPE
	recode contract 2=0
	replace contract=. if lstatus!=1
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte healthins=Q49MEDICAL
	recode healthins 2=0 3=.
	replace healthins=. if lstatus!=1
	label var healthins "Employment has health insurance primary job 7 day recall"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen byte socialsec=Q46PENSION
	recode socialsec 2=0 3=.
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
	gen byte firmsize_l=Q416NRWORKERS
	recode firmsize_l 1=0 2=1 3=2 4=5 5=10 6=20 7=50 8 99=.
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u=Q416NRWORKERS
	recode firmsize_u 1=0 2=1 3=4 4=9 5=19 6=49 7 8 99=.
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>


/*<_Labor_status_&_ISIC/ISCO_>

Recode ISIC and ISCO vars to missing if lstatus is not "1-employed".
Because ISIC and ISCO are string variables, their missing values should be ""
instead of ".".

10 observations have missing values for labor status while have "actual" non-missing
values for ISIC and ISCO variables.

<_Labor_status_&_ISIC/ISCO_>*/


*<_Labor_status_&_ISIC/ISCO_>
	replace industrycat_isic="" if lstatus!=1
	replace occup_isco="" if lstatus!=1
*</_Labor_status_&_ISIC/ISCO_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen byte empstat_2=.
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2=.
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
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
	gen byte occup_2=.
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
	gen njobs=Q41MULTIPLEJOBS
	recode njobs 2=1
	recode njobs 1=.
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
	gen laborincome=t_wage_total_year
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
================================================================================================*/

quietly{

*<_% KEEP VARIABLES - ALL_>

keep countrycode survname survey icls_v year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

order countrycode survname survey icls_v year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

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

save "`output'\ZAF_2009_QLFS_v01_M_v01_A_GLD_ALL.dta", replace

*</_% SAVE_>
