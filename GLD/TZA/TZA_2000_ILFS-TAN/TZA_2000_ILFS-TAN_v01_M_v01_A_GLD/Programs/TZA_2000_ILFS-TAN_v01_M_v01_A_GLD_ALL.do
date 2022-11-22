/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				TZA_2000_ILFS-TAN_v01_M_v01_A_GLD_ALL </_Program name_>
<_Application_>					Stata 17 <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2022-08-24 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						TZA </_Country_>
<_Survey Title_>				Tanzanian Integrated Labour Force Survey </_Survey Title_>
<_Survey Year_>					2000 </_Survey Year_>
<_Study ID_>					https://microdatalib.worldbank.org/index.php/catalog/90 </_Study ID_>
<_Data collection from_>		April/2000 </_Data collection from_>
<_Data collection to_>			March/2001 </_Data collection to_>
<_Source of dataset_> 			

Shared by country office, degree of "publicness" unknown. Technically should be on the 
national NADA site (https://nbs.go.tz/tnada/index.php/catalog/?page=1&ps=15), but this
site can be buggy.
											</_Source of dataset_>
<_Sample size (HH)_> 				11,158  </_Sample size (HH)_>
<_Sample size (IND)_> 				43,558  </_Sample size (IND)_>
<_Sampling method_>
 				
The sampling frame for the current National Master Sample (NMS) is based on the preliminary results of the 1988 population census. For the 2000/01 ILFS the primary sampling unit (PSU) was the village for the rural and EA for urban areas respectively. A probability proportional to size without replacement (ppswor) - systematic sampling procedure was used for the selection of PSU. About two months before the commencement of the field work a household listing exercise was done from mid February 2000 to mid March 2000 on the NMS clusters taking about two weeks. All households within each cluster were listed. The household listings gave the sampling frame of households for each cluster.

								</_Sampling method_>
<_Geographic coverage_> 		 Mainland Tanzania only </_Geographic coverage_>
<_Currency_> 					Tanzanian Shilling </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS 13 </_ICLS Version_>
<_ISCED Version_>				ISCED 1997 </_ISCED Version_>
<_ISCO Version_>				ISC0 1988 </_ISCO Version_>
<_OCCUP National_>				TASCO </_OCCUP National_>
<_ISIC Version_>				ISIC 2 </_ISIC Version_>
<_INDUS National_>				Tanzanian adaption of ISIC 2 </_INDUS National_>

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

local path_in "Z:\GLD-Harmonization\510859_AS\TZA\TZA_2000_ILFS-TAN\TZA_2000_ILFS-TAN_v01_M\Data\Stata"
local path_output "Z:\GLD-Harmonization\510859_AS\TZA\TZA_2000_ILFS-TAN\TZA_2000_ILFS-TAN_v01_M_v01_A_GLD\Data\Harmonized"

*----------1.3: Database assembly------------------------------*

/*
* Read in file of answers of those age 1-9
use "`path_in'\lfs1-9.dta"
egen idhaux=concat(region district ward eano hhno)
egen idpaux=concat(region district ward eano hhno personno)

tempfile lfs_1_9
save `lfs_1_9'

* Read in file HH10
use "`path_in'\HH10_DRV.dta",clear
egen idhaux=concat(region district ward eano hhno)

tempfile hh_10
save `hh_10', replace

"`path'\Original\lfs1-9.dta"

*/

* Use file that is names LFS-10 that has the answers from those 10 and above.
* This file has a sample size of 43,558 individuals, matching that on the ILO site for the ILFS
* https://www.ilo.org/surveyLib/index.php/catalog/511/data-dictionary
use "`path_in'\LFS-10.dta",clear
append using "`path_in'\LFS1-9.dta"

/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode = "TZA"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "ILFS"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "LFS"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	* Based on analytical report, the conceptual basis of the LFS is the 12th ICLS
	gen icls_v = "ICLS-13"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	gen isced_version = "isced_1997"
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
* Based on academic papers, TASCO is based on ISCO 1988
	gen isco_version = "isco_1988"
	label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
	gen isic_version = "isic_2"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	gen int year = 2000
	label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen vermast = "v01"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen veralt = "v01"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen harmonization = "GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>

	* It is not clear if the quarters follow standard definition or based on the survey calendar, which started April 2000
	* In retrospect, we are able to replicate the LFPR and unemployment rates with the following qtr and month equivalents:
		
		
/*	qtr			month in report				unemp (w/pot lf)	official unemp			
	1			April - June'00				7.17				7	
	2			July - September'00			6.64				7
	3			October - December'00		3.72				4
	4			January - March	'01			3.2					3				
	
	
	qtr			month in report				lfpr (w/pot lf)		official lfpr			
	1			April - June'00				74.58				74	
	2			July - September'00			76.25				76
	3			October - December'00		83.77				84
	4			January - March	'01			84.29				84				
	
	Thus, from here we conclude that the qtr values in the dataset do not correspond to the standard calendar year
	but rather on the survey year; i.e;
	
	qtr 1 - April to July 2000
	qtr 2 - July to September 2000
	qtr 3 - October to December 2000
	qtr 4 - January to March 2001
	
	*/
	
	destring qtr, replace
	gen int_year = 2000 if inrange(qtr, 1, 3)
	replace int_year = 2001 if qtr ==4
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen  int_month = .
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
	egen hhid = concat(region district ward eano hhno)
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	egen  pid = concat(region district ward eano hhno personno)
	isid pid
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
	gen weight = adjwt
	
	* weight is missing for individuals aged between 0 - 9
	* since this is a hh based weight, we can get from family members
	
	* check first if it varies within HH
	distinct hhid adjwt, joint
	bys hhid adjwt: gen nvals = _n == 1 if !missing(adjwt)
	by hhid: replace nvals = sum(nvals)
    by hhid: replace nvals = nvals[_N] 

	assert nvals == 1
	
	bys hhid: egen hhwgt = max(adjwt)
	replace weight = hhwgt if missing(adjwt)
	label var weight "Survey sampling weight"
*</_weight_>


*<_psu_>
	egen psu = concat(region district ward eano)
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = hhid
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
/* <_strata_note>

	The documentation (download at
	https://www.ilo.org/surveyLib/index.php/catalog/511/related-materials) says that the survey was,
	in the rural area:
	
	1) sample two villages were selected from each of the 50 super strata;
	2) From each selected village a sample of 80 households was drawn and 
		for each household size the following allocation:
		Household size	| Selected Households
		1-4				| 26
		5-7				| 27
		8+				| 27
		
	The super strata are unknown and not in the data. The household size element can also
	not be asserted. However, the data does not seem to agree with this.
	There are indeed 100 PSUs in the rural area as indicated. But, of the 7,728 households in the
	rura area, only 431 have a household size of 8 or more people, so the stratification cannot
	be recreated as we don't have the information of, for example, the "super strata", nor
	confirmed, as the data do not seem to agree with the statements.
	
	In the urban 122 EAs the number of HHs was variable by income:
		* 35 HHs in High income EAs
		* 33 HHs in middle income EAs
		* 30 HHs in low income EAs
	In turn and in each income group, the number of households should be divided by household 
	size.
	
	The household size make up of the actual interviews bears no resemblence
	with the purported stratification, where at least a third of households should have
	8 or more members.
	
	From the methodology Appendix 2
	(https://www.ilo.org/surveyLib/index.php/catalog/511/related-materials)	
	we can extract which EAs are high, and middle income. That is the only information that can be
	coded as stratification.
</_strata_note> */

	gen strata = .
	replace strata = 1 if geog2 == "1"
	replace strata = 2 if inlist(psu,"023032003","036042010","036082007","044022008","044062007","044202008","071052002","071052115","071072081") | inlist(psu,"071112047","071122044","072062004","072062046","072072007","072112008","072132008","073122024","073152023") | inlist(psu,"116102007","193042018","193112009") 
	replace strata = 3 if inlist(psu,"014032001","023032012","036092011","071122070","071062003","072162006","072182013") | inlist(psu,"116032003","193042012")
	replace strata = 4 if missing(strata)
	label var strata "Strata"
*</_strata_>


*<_wave_>
	/* Again for this, note that the qtr values do not follow the standard calendar year, but the survey year; i.e.:
	qtr 1 - April to July 2000
	qtr 2 - July to September 2000
	qtr 3 - October to December 2000
	qtr 4 - January to March 2001 							*/
	
	gen wave = qtr
	label var wave "Survey wave"
	
*</_wave_>

}


/*%%=============================================================================================
	3: Geography
==============================================================================================%%*/

{

*<_urban_>
	
	gen byte urban = 1 if inlist(geog, "1", "2")
	replace urban = 0 if geog == "3"
	
	* Fill in data for children aged 1 - 9 because dataset does not contain that variable
	bys hhid: egen urban_max = max(urban)
	replace urban = urban_max
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
/* <_subnatid1_note>

Based on the methodology note, the survey is meant to be represenative at rural, Dar es Salaam, and other urban. We use this geographic levels for subnatid1

</_subnatid1_note> */

	gen str subnatid1 = "Rural" if urban == 0 
	replace subnatid1 = "Other urban" if urban == 1
	replace subnatid1 = "Dar es Salaam" if region == "07"
	
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	gen subnatid2 = ""
	replace subnatid2 = "1 - Dodoma" if region == "01"
	replace subnatid2 = "2 - Arusha" if region == "02"
	replace subnatid2 = "3 - Kilimanjaro" if region == "03"
	replace subnatid2 = "4 - Tanga" if region == "04"
	replace subnatid2 = "5 - Morogoro" if region == "05"
	replace subnatid2 = "6 - Pwani" if region == "06"
	replace subnatid2 = "7 - Dar es salaam" if region == "07"
	replace subnatid2 = "8 - Lindi" if region == "08"
	replace subnatid2 = "9 - Mtwara" if region == "09"
	replace subnatid2 = "10 - Ruvuma" if region == "10"
	replace subnatid2 = "11 - Iringa" if region == "11"
	replace subnatid2 = "12 - Mbeya" if region == "12"
	replace subnatid2 = "13 - Singida" if region == "13"
	replace subnatid2 = "14 - Tabora" if region == "14"
	replace subnatid2 = "15 - Rukwa" if region == "15"
	replace subnatid2 = "16 - Kigoma" if region == "16"
	replace subnatid2 = "17 - Shinyanga" if region == "17"
	replace subnatid2 = "18 - Kagera" if region == "18"
	replace subnatid2 = "19 - Mwanza" if region == "19"
	replace subnatid2 = "20 - Mara" if region == "20"
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	gen str subnatid3 = ""
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
/* <_subnatidsurvey_note>

Based on the report, survey is representative at rural, Dar es Salaam, and other urban

</_subnatidsurvey_note> */
	gen str subnatidsurvey = "subnatid1"
	label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>


*<_subnatid1_prev_>
/* <_subnatid1_prev_note>

	This is the earliest survey in the GLD, so we leave this part missing. 
	
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

* Since there is no household size variable, we code it based on the number of individuals interviewed in the household

	bys hhid: gen hsize = _N
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = sex == "1"
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	destring relhead, gen(relationharm)
	recode relationharm (4 = 3) (5 = 4) (6 = 5) (7 8 = 6)
	
	* Make sure that there is only 1 head per household
	gen head = relationharm == 1
	bys hhid: egen tothead = sum(head)
	
	assert tothead == 1
	
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	destring relhead, gen(relationcs)
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	destring marstat, gen(marital)
	
	recode marital (1 = 2) (2 = 1) (3 = 5)
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

	* The age lower bound is based on the fact that the dataset used contains data only for individuals aged 10 and above
	* In the questionnaire, it is explicitly stated that the migration questions are asked for individuals 5 and above
	
	gen migrated_mod_age = 10
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time = 99
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen migrated_binary = (migra1!="1")
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>

	* The values in the survey are expressed as ranges, but the GLD variable is represented as an integer. We take the midpoint
	gen migrated_years = . if migra1 == "1" | migra1 == "9"
	replace migrated_years = 0.5 if migra1 == "2"
	replace migrated_years = 2 if migra1 == "3"
	replace migrated_years = 4 if migra1 == "4"
	replace migrated_years = 5 if migra1 == "5"
	
	label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban = 1 if migra2 == "2"
	replace migrated_from_urban = 0 if migra2 == "1"
	replace migrated_from_urban = . if migrated_binary != 1
	
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
	destring migra3, gen(migrated_reason)
	recode migrated_reason (1 2 4 5 = 3) (6 = 1) (7 = 2) (8 = 5)
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

Like in the migration module, we code the application age to 10 despite the explicit mention in the questionnaire that it applies to individuals aged 5 and above. Again, this is a constraint on the side of the dataset used rather than intended by the questionnaire

</_ed_mod_age_note> */

gen byte ed_mod_age = 10
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school= edstat == "2"
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	destring literacy, replace
	recode literacy (5 = 0) (2 3 4 = 1) (9 = .)
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen byte educy =.
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7 = .
	replace educat7 = 1 if edstat == "3"
	
	* There are 3 people with edstat = 1 (i.e., completed school) but missing value for educa. However, these people have information on educa2 - but we don't know what this variable is about.
	
	* As a recourse, let's see the relationship between this variable and edstat
	
	tab educa2 edstat
	* here we can see taht educa2 = 1 corresponds almost entirely to edstat = 3 (not completed school). Based on this, we make the judgment that these people who claimed to have "completed school" may actually be miscoded for "not completed any school". Hence, add this to educat 7 = 0
	* note that we reflect on the codes the two levels of secondary education: ordinary level ending at Form 4 = secondary complete, and advanced level ending in Form 6 is higher than secondary but not university. This is based on the recommendations of the Tanzania Country Office
	
	replace educat7 = 1 if educa2 == "1" & edstat  == "1"
	replace educat7 = 2 if inlist(educa, "02", "03", "04", "05", "06", "07")
	replace educat7 = 3 if inlist(educa, "08", "09")
	replace educat7 = 4 if inlist(educa, "10", "11", "12")
	replace educat7 = 5 if educa == "13"
	replace educat7 = 6 if inlist(educa, "14", "15")
	replace educat7 = 7 if inlist(educa, "16", "17")
	
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
	gen educat_orig = educa
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
/* Here, I use ISCED 1997 with the following co
	
	ISCED code 			Equivalent
		0				Pre primary
		1				Primary
		2				Lower secondary
		3				Upper secondary
		5				First stage of tertiary (Bachelor's and Master's)
		6				Second stage of tertiary (PhD)


*/
	gen educat_isced = 0 if educat7 == 2
	replace educat_isced = 1 if inrange(educat7,3,4) 
	replace educat_isced = 2 if educat7 == 5
	replace educat_isced = 3 if educat7 == 6 
	replace educat_isced = 5 if educat7 == 7

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
	destring typtrain, gen(vochelp)
	gen vocational = 0 if vochelp == 1
	replace vocational = 1 if inrange(vochelp, 2, 10)
	replace vocational = . if vochelp == 99
	
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

*<_vocational_field_original_>
	gen vocational_field_original = subtrain
	label var vocational_field_original "Field of training"
*</_vocational_field_original_>

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

/* <_minlaborage_note>

Like in the migration module, we code the application age to 10 despite the explicit mention
in the questionnaire that the Qs applies to individuals aged 5 and above. Again, this is a constraint
on the side of the dataset used rather than intended by the questionnaire.

Also, most of the reports on labor in the analytical report use 10 as the lower cut-off age
and this is mentioned as well in reports in later year surveys.

</_minlaborage_note> */

	gen byte minlaborage = 10
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>

	gen byte lstatus = .
	replace lstatus = 1 if curract == "1" | (curract == "2" & tempabs == "1")
	replace lstatus = 2 if avaiwork == "1" & findwork == "1"
	replace lstatus = 3 if avaiwork == "2" 
	replace lstatus = 3 if avaiwork == "1" & findwork == "2" 
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = 0 if lstatus == 3
	replace potential_lf = 1 if lstatus == 3 & findwork == "2"
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
	* Only asks for reasons not looking for work which is a small subset of those not in the LF
	gen byte nlfreason=.
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	* Only asks how long have been available for work rather than explicitly being unemployed
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
	tab mstatus lstatus
	* There is a code "0" for mstatus, which has no equivalent description in the codebook
	* A total of 149 employed individuals are assigned this value. Leave it missing. 
	destring mstatus, gen(empstat)
	recode empstat (4 5 = 2) (2 = 3) (3 6 = 4) (0 = .)
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	destring msector, gen(ocusec)
	recode ocusec (1 2 3 = 1) (0 4 5 6 7 8 9 10 = 2) 
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig = mind
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	* Q21 (industry classification) is not asked for individuals reported working as unpaid family helper or self-employed in agricultural sector.
	* Instead, they are asked the specific main activity (Q18b), which can be converted to ISIC codes
	
	gen industryhelper = mind
	
	* It is not clear what ISIC version is used here. NO information from available documentation
	* Check which ISIC version would allow us to match all the codes here.
	

	preserve
		gen code2d = substr(industryhelper, 1, 2)

		foreach x in isic2 isic3 isic3_1 isic4{
		merge m:1 code2d using "`path_in'/`x'.dta"
		rename _merge _merge_`x'
		
		display "`x'"
		distinct code2d if _merge_`x' == 1
		
		}
		
	restore
	
	* Perfectly matches all 2 digit codes for ISIC 2. Note, however, that on a separate exercise, the 4 digit codes do not perfectly match ISIC 2
	* The survey guide is clear that the industry codes are an national adaption of the ISIC
	* Thus, we take ISIC at the 2 digits and add two zeroes
	
	gen industrycat_isic = substr(industryhelper, 1, 2)
	replace industrycat_isic = industrycat_isic + "00" if !missing(industrycat_isic)
	
	**Code ISIC version 2 for fishing (1), crop growing (2), and livestock (3)
	
	replace industrycat_isic = "1300" if magrwk == "1"
	replace industrycat_isic = "1100" if magrwk == "2"
	replace industrycat_isic = "1100" if magrwk == "3"	
	
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen isic2d = substr(industrycat_isic, 1, 2)
	destring isic2d, replace
	
	gen byte industrycat10 = 1 if inrange(isic2d, 10, 13)
	replace industrycat10 = 2 if inrange(isic2d, 20, 29)
	replace industrycat10 = 3 if inrange(isic2d, 30, 39)
	replace industrycat10 = 4 if inrange(isic2d, 40, 42)
	replace industrycat10 = 5 if isic2d == 50
	replace industrycat10 = 6 if inrange(isic2d, 60, 63)
	replace industrycat10 = 7 if inrange(isic2d, 70, 72)
	replace industrycat10 = 8 if inrange(isic2d, 80, 83)
	replace industrycat10 = 9 if isic2d == 91
	replace industrycat10 = 10 if isic2d == 90 | inrange(isic2d, 92, 96)
	
	
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
	gen occup_orig = mtask
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>

* We only know that it TASCO is based on ISCO'88, but not clear what degree of similarity by digit levels

	gen mtask_4 = mtask
	gen mtask_3 = substr(mtask, 1, 3)
	gen mtask_2 = substr(mtask, 1, 2)
	
preserve

	use "`path_in'\isco.dta", clear
	
	keep if version == "isco_1988"
	
	gen mtask_4 = code
	
	tempfile mtask_4
	save `mtask_4'

restore

preserve

	use "`path_in'\isco.dta", clear

	
	keep if version == "isco_1988"
	
	gen mtask_3 = substr(code, 1, 3)
	duplicates drop mtask_3, force
	tempfile mtask_3
	save `mtask_3'

restore

preserve

	use "`path_in'\isco.dta", clear

	
	keep if version == "isco_1988"
	
	gen mtask_2 = substr(code, 1, 2)
	duplicates drop mtask_2, force
	tempfile mtask_2
	save `mtask_2'

restore

*merge m:1 mtask_4 using `mtask_4', nogen
*merge m:1 mtask_3 using `mtask_3', nogen
merge m:1 mtask_2 using `mtask_2', nogen keep(master match)


* Based on this, we can use the 2 digit TASCO for ISCO
* One discrepancy involves the code "53" in TASCO which does not exist in ISCO
* But upon inspection: ISCO code "51" is split between TASCO codes "51" and "52"
* And ISCO code "52" is equivalent to TASCO code "53"

*tab mtask_2 if _merge == 1 

replace mtask_2 = "51" if mtask_2 == "52"
replace mtask_2 = "52" if mtask_2 == "53"
 
	
	gen occup_isco = mtask_2 + "00" if !missing(mtask_2)
	replace occup_isco = "0110" if occup_isco == "0100"
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_skill_>
	gen occup_helper = substr(occup_isco, 1, 1)
	destring occup_helper, gen(occup_skill)
	recode occup_skill (1/3 = 3) (4/8 = 2) (9 = 1) (0 = .)

	la de lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lblskill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_occup_>
	destring occup_helper, gen(occup)
	replace occup = 10 if occup == 0
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>


*<_wage_no_compen_>
	gen double wage_no_compen = .
	replace wage_no_compen = empinc
	
	* Note that the empinc variable captures paid employment income from primary and secondary activity
	* Thus, we see below that there are non-paid employees and self-employed under empstat that have non-missing values for this variable
	
	tab empstat if !missing(empinc)
	
	* We want this variable to only capture those who has paid employment as their primary activity
	replace wage_no_compen = . if empstat !=1
	
	* Same logic applies for self-employment. Note that from the survey language, self-employed also covers employers
	tab empstat if !missing(sempinc)
	
	* We cannot use semp inc bec this is in gross terms. Subtract expenses
	* but problem is period used for expenses not the same for income
	
	tab psempinc psempexp
	
	gen dissimilar_periods = psempinc != psempexp
	
	tab dissimilar_periods
	* There are 83 obs
	
	* For these cases, we want to recode income and expenditure values to monthly (if weekly)
	
	gen net_income = sempinc - sempexp if dissimilar_periods == 0
	
	gen sempinc_helper = sempinc * 4.33 if psempinc == "1" & dissimilar_periods == 1
	gen sempexp_helper = sempexp * 4.33 if psempexp == "1" & dissimilar_periods == 1
	
	
	replace net_income = sempinc_helper - sempexp_helper if dissimilar_periods == 1
	
	replace wage_no_compen = net_income if empstat == 4 | empstat == 3

	gen net_income_period = psempinc if dissimilar_periods == 0
	replace net_income_period = "2" if dissimilar_periods == 1
	
	* Based on the questionnaire, this applies only to self-employed in non-agriculture
	tab engagr if !missing(sempinc)
	* Based on this information -- N = 460 (8%) are in agriculture

	gen helper = 1 if engagr != "1" & !missing(sempinc)
	tab helper sstatus 
	
	replace wage_no_compen = . if helper == 1
	drop helper
	
	* Also, we have a bit of information on agricultural self-employment income, but only for urban respondents. First let's see if it is consistent with urban
	gen agrinc_dummy = !missing(agrinc)
	tab agrinc_dummy urban
	* only 4 respondents reporting rural with response here. Set to missing!
	
	replace wage_no_compen = agrinc if engagr == "1" & urban == 1
	
	* Following the procedure above, we are able to populate wage values for paid employees
	tab empstat if !missing(wage_no_compen)

	* But only one-fifth for those who are self-employed. This should be fine since wage is expected almost exclusively from paid employees
	* Self employed individuals are likely to experience irregularities in income flows

	
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
	* Note that the wording in the codebook is confusing. Self-employment income is said to be "monthly", but there is a follow-up question asking for the reference period, indicated by the variable "psempinc". Based on descriptive statistics, the numbers make sense. Average sempinc for weekly is 33000 but for monthly is 142000 (~4.3X = number of weeks in a month). Hence, we should take the time period indicated by this variable. For paid employment income, it is safe to assume it is monthly bec there is no follow-up question asking for reference period.
	
	gen byte unitwage = 5 if !missing(wage_no_compen)
	replace unitwage = 2 if !missing(wage_no_compen) & (net_income_period == "1" | pagrinc == "1")
	
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	* First check if hours from primary and secondary activities add up to total hours
	egen tothours_helper = rowtotal(uhoursm uhourso)
	assert tothours_helper == uhourst if lstatus == 1
	
	drop tothours_helper

	* Check for combined primary and secondary hours that add up to more than total hours possible in a week == 168
	count if uhourst >=168 & !missing(uhourst)
	* For this individual, hours worked in main activity is 84, which is not impossible, so decide to keep this
	
	gen whours = uhoursm if lstatus == 1
	
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	* Asks how many months the enterprise (non-agriculture, self-employed) operated in past 12 months
	gen wmonths = mnwork if empstat == 3 | empstat == 4
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
/* <_wage_total_note>

If works full year with the same reported monthly income, multiply wage_no_compen by 12

</_wage_total_note> */
	gen wage_total = wage_no_compen * 12
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
	* Q33 asks about contribution to social security or trade union. Since not exclusively for SS, leave this missing
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
	* Questions are not asked for unpaid family helper in agriculture and those working in own farm or shamba
	
	tab mnume mstatus
	* There is value for mstatus = 6 (working in own farm or shamba) for one individual if not supposed to
	replace mnume = "" if mstatus == "6" | mstatus == "0"

	gen byte firmsize_l = .
	replace firmsize_l = 1 if mnume == "2"
	replace firmsize_l = 6 if mnume == "3"
	replace firmsize_l = 11 if mnume == "4"
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u= .
	replace firmsize_u = 5 if mnume == "2"
	replace firmsize_u = 10 if mnume == "3"
	replace firmsize_u = . if mnume == "4"
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	destring sstatus, gen(empstat_2)
	recode empstat_2 (4 5 = 2) (2 = 3) (3 6 = 4) (0 = .)
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>



*<_ocusec_2_>
	destring ssector, gen(ocusec_2)
	recode ocusec_2 (1 2 3 = 1) (0 4 5 6 7 8 9 10 = 2) 	
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen industry_orig_2 = sind
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>

*<_industrycat_isic_2_>
	
	gen industryhelper2 = sind
	gen industrycat_isic_2 = substr(industryhelper2, 1, 2)
	
	replace industrycat_isic_2 = industrycat_isic_2 + "00" if !missing(industrycat_isic_2)

	**Code ISIC version 2 for fishing (1), crop growing (2), and livestock (3)
	
	replace industrycat_isic_2 = "1300" if sagrwk == "1"
	replace industrycat_isic_2 = "1100" if sagrwk == "2"
	replace industrycat_isic_2 = "1100" if sagrwk == "3"	
	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen isic2d_2 = substr(industrycat_isic_2, 1, 2)
	destring isic2d_2, replace
	
	gen byte industrycat10_2 = 1 if inrange(isic2d_2, 10, 13)
	replace industrycat10_2 = 2 if inrange(isic2d_2, 20, 29)
	replace industrycat10_2 = 3 if inrange(isic2d_2, 30, 39)
	replace industrycat10_2 = 4 if inrange(isic2d_2, 40, 42)
	replace industrycat10_2 = 5 if isic2d_2 == 50
	replace industrycat10_2 = 6 if inrange(isic2d_2, 60, 63)
	replace industrycat10_2 = 7 if inrange(isic2d_2, 70, 72)
	replace industrycat10_2 = 8 if inrange(isic2d_2, 80, 83)
	replace industrycat10_2 = 9 if isic2d_2 == 91
	replace industrycat10_2 = 10 if isic2d_2 == 90 | inrange(isic2d_2, 92, 96)	
	
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
	gen occup_orig_2 = stask
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen occup_helper2= substr(occup_orig_2, 1, 2)
	
	replace occup_helper2 = "51" if occup_helper2 == "52"
	replace occup_helper2 = "52" if occup_helper2 == "53"
 
	gen occup_isco_2 = occup_helper2 + "00" if !missing(occup_helper2)

	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_skill_2_>
	drop occup_helper2
	gen occup_helper2 = substr(occup_isco_2, 1, 1)
	destring occup_helper2, gen(occup_skill_2)
	recode occup_skill_2 (1/3 = 3) (4/8 = 2) (9 = 1) (0 = .)
	la de lblskill2 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_2 lblskill2
	label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>


*<_occup_2_>
	destring occup_helper2, gen(occup_2)
	replace occup_2 = 10 if occup_2 == 0
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
	gen whours_2 = uhourso if !missing(empstat_2)
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
	replace firmsize_l_2 = 1 if snume == "2"
	replace firmsize_l_2 = 6 if snume == "3"
	replace firmsize_l_2 = 11 if snume == "4"	
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	gen byte firmsize_u_2= .
	replace firmsize_u_2 = 5 if snume == "2"
	replace firmsize_u_2 = 10 if snume == "3"
	replace firmsize_u_2 = . if snume == "4"	
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
	egen week_total = rowtotal(whours whours_2)
	gen t_hours_total = week_total * 52
	
	* Set an upper bound as the max hours available in a year
	replace t_hours_total = . if t_hours_total > 24*7*52
	
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
	
	* In the variable "usact", it is asked if people have worked at all in the past 12 months
	* A follow-up is made to ask which of the past 12 months the respondent has worked full time or part time, not worked but available, not worked and not available
	
	* There is a contradictory case of 56 people who claimed to have done any work activity (i.e., usact == 1) but also claimed to not have worked and not available for work in any of the past 12 months (i.e., uacte == 12)
	destring usact, gen(usact_n)
	count if usact_n == 1 & uacte == 12
	
	assert uacta == 0 & uactb == 0 & uactc == 0 if usact_n ==1 & uacte == 12
	* This means that they reported not having worked a single month, consistent to the story above
	
	replace usact_n = 2 if usact_n == 1 & uacte == 12
	
	* Same is found for those reporting to be unemployed for 12 months, but usact == 1
	count if usact_n == 1 & uactd == 12
	assert uacta == 0 & uactb == 0 & uactc == 0 if usact_n ==1 & uactd == 12

	replace usact_n = 2 if usact_n == 1 & uactd == 12

	* By modifying usact_n, we imply that we apply more weight to the information on the detailed monthly work activity than the yes/no question in usact
	
	gen helper_nlf = .
	replace helper_nlf = 0 if usact_n == 2
	replace helper_nlf = 1 if uacte == 12 & !missing(helper_nlf)
	* There are 5,657 who are NLF entire 12 months
	

	gen helper_unemp = 0 if usact_n == 2
	replace helper_unemp = 1 if uactd == 12 & !missing(helper_unemp)
	* There are 1,532 who are unemployed entire 12 months
	
	* If we add all 12 month NLF and unemployed, total is 7,109. There is a residual of 7433 - 7109 = 324 individuals.
	* Question is: should we tag these individuals as unemployed or NLF?
	* Solution is to assign the status they were for more months
	* For example: individual X spent more 5 months studying in a given year and began looking for work afterwards, but never found in the remainder of the year
	* This individual should be tagged as unemployed
	
	* Before anything, first confirm symmetry
	qui count if inrange(uactd, 7, 11) & usact_n == 2
	local uactd_7_11 = r(N)
	
	qui count if inrange(uacte, 1, 5) & usact_n == 2
	local uacte_1_5 = r(N)
	
	assert `uactd_7_11' == `uacte_1_5'
	
	
	qui count if inrange(uacte, 7, 11) & usact_n == 2
	local uacte_7_11 = r(N)
	
	qui count if inrange(uactd, 1, 5) & usact_n == 2
	local uactd_1_5 = r(N)
	
	assert `uacte_7_11' == `uactd_1_5'
	
	
	replace helper_unemp = 1 if inrange(uactd, 7, 11) & usact_n == 2
	replace helper_nlf = 1 if inrange(uacte, 7, 11) & usact_n == 2
	
		
	qui count if uacte == 6 & usact_n == 2
	local uacte_6 = r(N)
	
	qui count if uactd == 6 & usact_n == 2
	local uactd_6 = r(N)
	
	assert `uacte_6' == `uactd_6'
	
	* Do random assignment: unemp == 1 & nlf == 0
	
	set seed 500
	gen random_unemp = runiform() if uacte == 6 & usact_n == 2
	gen random_unemp_int = round(random_unemp)
	
	replace helper_unemp = 1 if random_unemp_int == 1
	
	gen byte lstatus_year = .
	
	replace lstatus_year =  1 if usact_n == 1
	replace lstatus_year =  2 if helper_unemp == 1
	replace lstatus_year =  3 if helper_nlf == 1
	replace lstatus_year=. if age < minlaborage & age != .
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
	drop helper_nlf
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
	destring unowork, gen(nlfreason_year)
	replace nlfreason_year = . if lstatus_year !=3 | age < minlaborage & age != .
	recode nlfreason_year (3/5 = 2) (6 = 3) (8 = 4) (7 9 = 5) (10 96 98 = .)
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
	replace ocusec_year = 2 if uwork == "01" | inlist(uwork, "05", "06", "07", "08", "09", "10")
	replace ocusec_year = 1 if inlist(uwork, "02", "03", "04")
	replace ocusec_year = . if lstatus_year!=1 | age < minlaborage & age != .

	
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

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_original vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_original vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

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

save "`path_output'\TZA_2000_ILFS-TAN_v01_M_v01_A_GLD_ALL.dta", replace

*</_% SAVE_>
