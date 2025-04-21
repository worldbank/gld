
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				[Name of your do file] </_Program name_>
<_Application_>					[Name of your software (STATA) and version] <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				YYYY-MM-DD </_Date created_>

-------------------------------------------------------------------------

<_Country_>					[Country_Name (CCC)] </_Country_>
<_Survey Title_>				[SurveyName] </_Survey Title_>
<_Survey Year_>					[Year of start of the survey] </_Survey Year_>
<_Study ID_>					[Microdata Library ID if present] </_Study ID_>
<_Data collection from_>			[MM/YYYY] </_Data collection from_>
<_Data collection to_>				[MM/YYYY] </_Data collection to_>
<_Source of dataset_> 				[Source of data, e.g. NSO] </_Source of dataset_>
<_Sample size (HH)_> 				[#] </_Sample size (HH)_>
<_Sample size (IND)_> 				[#] </_Sample size (IND)_>
<_Sampling method_> 				[Brief description] </_Sampling method_>
<_Geographic coverage_> 			[To what level is data significant] </_Geographic coverage_>
<_Currency_> 					[Currency used for wages] </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				[Version of ICLS for Labor Questions] </_ICLS Version_>
<_ISCED Version_>				[Version of ICLS for Labor Questions] </_ISCED Version_>
<_ISCO Version_>				[Version of ICLS for Labor Questions] </_ISCO Version_>
<_OCCUP National_>				[Version of ICLS for Labor Questions] </_OCCUP National_>
<_ISIC Version_>				[Version of ICLS for Labor Questions] </_ISIC Version_>
<_INDUS National_>				[Version of ICLS for Labor Questions] </_INDUS National_>

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
set varabbrev off

*----------1.2: Set directories------------------------------*

* Define path sections
local server  "Y:/GLD"
local country "GHA"
local year    "2012"
local survey  "GLSS"
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

* All steps necessary to merge datasets (if several) to have all elements needed to produce
* harmonized output in a single file

/*
cd "`path_in_stata'/PARTA"
local files    : dir . files "*.dta"
foreach v of local files {
	display " .... "
	display "THIS IS `v'"
	use "`v'", clear
	duplicates r
	duplicates drop 
}

*For PART A, one file has duplicates: sec6q10, 38 duplicate observations in all variables. 
*/

/*
cd "`path_in_stata'/PARTB"
local files    : dir . files "*.dta"
foreach v of local files {
	display " .... "
	display "THIS IS `v'"
	use "`v'", clear
	duplicates r
}

*For PART B, two files have duplicates: sec11eb1, 31 duplicate observations in all variables AND sec12a, 2 duplicate observations in all variables. 

*/

use "`path_in_stata'/g6loc_edt.dta", clear
merge 1:1 HID using "`path_in_stata'/SEC0.dta", nogenerate
merge 1:m HID using "`path_in_stata'/SEC1.dta", nogenerate
foreach sec in SEC2a SEC2b SEC2c SEC3a SEC3b SEC3c SEC3d SEC3e SEC4a SEC4b SEC4c SEC4d SEC4e SEC4f SEC4g SEC4h SEC4hs SEC5a {
	merge 1:1 HID PID using "`path_in_stata'/`sec'.dta", nogenerate assert(master match)
}


/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode = "GHA"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "GLSS"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "LSMS"
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
	gen isco_version = "isco_2008"
	label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
	gen isic_version = "isic_4"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	drop year
	gen int year = 2012
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
	gen int_year = ydatesup
	replace int_year = ydate if missing(int_year)
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen  int_month = mdatesup
	replace int_month = mdate if missing(int_month)
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
	
	*There are some cases that the date is not within the fieldwork interval (18/10/2012 to 17/10/2013): 57 observations, compare the dates with hh of the same enumeration area.
	gen wrong_date = (int_month>10 & int_year==2013) | (int_month==10 & int_year==2013 & ddatesup > 17)
	* fre clust if wrong_date == 1
	bys clust: egen correct_month = mode(int_month)
	bys clust: replace int_month = correct_month if wrong_date == 1 & int_month != correct_month
	* The remaining 2 obs have int_day issues
*</_int_month_>


*<_hhid_>
/* <_hhid_note>

	Raw data has Household ID
	
</_hhid_note> */
	gen hhid = subinstr(HID, "/", "", 1)
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	tostring PID, gen(pid_str) format(%02.0f)
	egen  pid = concat(hhid pid_str)
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
	*gen weight = .
	label var weight "Survey sampling weight"
*</_weight_>


*<_weight_m_>
	gen weight_m = .
	label var weight_m "Survey sampling weight to obtain national estimates for each month"
*</_weight_m_>


*<_weight_q_>
	gen weight_q = .
	label var weight_q "Survey sampling weight to obtain national estimates for each quarter"
*</_weight_q_>


*<_psu_>
	gen psu = clust
	label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = hhid
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
==============================================================================================%%*/

{

*<_urban_>
	gen byte urban = loc2
	recode urban (2 = 0)
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
/* <_subnatid1_note>

	The variable is string and country-specific categorical. Numeric entries are coded in string format using the following naming convention: "1 – Hatay". That is, the variable itself is to be string, not a labelled numeric vector. 
	
	Example of entries would be "1 - Alaska",  "2 - Arkansas", ...

</_subnatid1_note> */
	decode region, gen(region_str)
	egen subnatid1 = concat(region region_str), punct(" - ")
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	gen subregion = region*100+district
	gen subregion1    ="101 - Jomoro"									if subregion==	101
	replace subregion1="102 - Ellembelle"								if subregion==	102
	replace subregion1="103 - Nzema East"								if subregion==	103
	replace subregion1="104 - Ahanta West"								if subregion==	104
	replace subregion1="105 - Sekondi-Takoradi"							if subregion==	105
	replace subregion1="106 - Shama"									if subregion==	106
	replace subregion1="107 - Mpohor-Wassa East"						if subregion==	107
	replace subregion1="108 - Tarkwa Nsuaem"							if subregion==	108
	replace subregion1="109 - Prestea/Huni Valley"						if subregion==	109
	replace subregion1="110 - Wassa Amenfi East"						if subregion==	110
	replace subregion1="111 - Wassa Amenfi West"						if subregion==	111
	replace subregion1="112 - Aowin Suaman"								if subregion==	112
	replace subregion1="113 - Sefwi Akontobra"							if subregion==	113
	replace subregion1="114 - Sefwi Wiawso"								if subregion==	114
	replace subregion1="115 - Sefwi Bibiani-Ahwiaso Bekwai"				if subregion==	115
	replace subregion1="116 - Juabeso"									if subregion==	116
	replace subregion1="117 - Bia"										if subregion==	117
	replace subregion1="201 - Komenda/Edina/Eguafo/Abirem"				if subregion==	201
	replace subregion1="202 - Cape Coast   South"						if subregion==	202
	replace subregion1="203 - Abura/Asebu/Kwamankese"					if subregion==	203
	replace subregion1="204 - Mfantsiman"								if subregion==	204
	replace subregion1="205 - Ajumanku/Enyan/Essiam"					if subregion==	205
	replace subregion1="206 - Gomoa West"								if subregion==	206
	replace subregion1="207 - Effutu"									if subregion==	207
	replace subregion1="208 - Gomoa East"								if subregion==	208
	replace subregion1="209 - Awutu Senya"								if subregion==	209
	replace subregion1="210 - Agona East"								if subregion==	210
	replace subregion1="211 - Agona West"								if subregion==	211
	replace subregion1="212 - Asikuma/Odoben /Brakwa"					if subregion==	212
	replace subregion1="213 - Assin South"								if subregion==	213
	replace subregion1="214 - Assin North"								if subregion==	214
	replace subregion1="215 - Twifo/Heman/Lower Denkyira"				if subregion==	215
	replace subregion1="216 - Upper Denkyira East"						if subregion==	216
	replace subregion1="217 - Upper Denkyira West"						if subregion==	217
	replace subregion1="301 - Weija (Ga South)"							if subregion==	301
	replace subregion1="302 - Ga West"									if subregion==	302
	replace subregion1="303 - Ga East"									if subregion==	303
	replace subregion1="304 - AMA"										if subregion==	304
	replace subregion1="305 - Adenta"									if subregion==	305
	replace subregion1="306 - Ledzokuku/Krowor"							if subregion==	306
	replace subregion1="307 - Ashaiman"									if subregion==	307
	replace subregion1="308 - Tema West/Tema East/Kpone Katamanso"		if subregion==	308
	replace subregion1="309 - Dangbe West"								if subregion==	309
	replace subregion1="310 - Dangbe East"								if subregion==	310
	replace subregion1="401 - South Tongu"								if subregion==	401
	replace subregion1="402 - Keta Municipal"							if subregion==	402
	replace subregion1="403 - Ketu South"								if subregion==	403
	replace subregion1="404 - Ketu North"								if subregion==	404
	replace subregion1="405 - Akatsi"									if subregion==	405
	replace subregion1="406 - North Tongu"								if subregion==	406
	replace subregion1="407 - Adaklu Anyigbe"							if subregion==	407
	replace subregion1="408 - Ho"										if subregion==	408
	replace subregion1="409 - South Dayi"								if subregion==	409
	replace subregion1="410 - Norh Dayi (Kpando)"						if subregion==	410
	replace subregion1="411 - Hohoe"									if subregion==	411
	replace subregion1="412 - Biakoye"									if subregion==	412
	replace subregion1="413 - Jasikan"									if subregion==	413
	replace subregion1="414 - Kadjebi"									if subregion==	414
	replace subregion1="415 - Krachi East"								if subregion==	415
	replace subregion1="416 - Krachi West"								if subregion==	416
	replace subregion1="417 - Nkwanta South"							if subregion==	417
	replace subregion1="418 - Nkwanta North"							if subregion==	418
	replace subregion1="501 - Birim South"								if subregion==	501
	replace subregion1="502 - Birim  Central Municipal"					if subregion==	502
	replace subregion1="503 - West Akim"								if subregion==	503
	replace subregion1="504 - Suhum/Kraboa Coaltar"						if subregion==	504
	replace subregion1="505 - Akwapim South"							if subregion==	505
	replace subregion1="506 - Akwapim North"							if subregion==	506
	replace subregion1="507 - New Juaben Municipal"						if subregion==	507
	replace subregion1="508 - Yilo Krobo"								if subregion==	508
	replace subregion1="509 - Lower Manya Krobo"						if subregion==	509
	replace subregion1="510 - Asuogyaman"								if subregion==	510
	replace subregion1="511 - Upper Manya Krobo"						if subregion==	511
	replace subregion1="512 - Fanteakwa"								if subregion==	512
	replace subregion1="513 - East Akim"								if subregion==	513
	replace subregion1="514 - Kwaebibirem"								if subregion==	514
	replace subregion1="515 - Akyemansa"								if subregion==	515
	replace subregion1="516 - Birim North"								if subregion==	516
	replace subregion1="517 - Atiwa"									if subregion==	517
	replace subregion1="518 - Kwahu West"								if subregion==	518
	replace subregion1="519 - Kwahu South"								if subregion==	519
	replace subregion1="520 - Kwahu East"								if subregion==	520
	replace subregion1="521 - Kwahu North"								if subregion==	521
	replace subregion1="601 - Atwima Mponua"							if subregion==	601
	replace subregion1="602 - Amansie West"								if subregion==	602
	replace subregion1="603 - Amansie Central"							if subregion==	603
	replace subregion1="604 - Adansi South"								if subregion==	604
	replace subregion1="605 - Obuasi Municipal"							if subregion==	605
	replace subregion1="606 - Adansi North"								if subregion==	606
	replace subregion1="607 - Bekwai Municipal"							if subregion==	607
	replace subregion1="608 - Bosome Freho"								if subregion==	608
	replace subregion1="609 - Asante Akim South"						if subregion==	609
	replace subregion1="610 - Asante Akim North"						if subregion==	610
	replace subregion1="611 - Ejisu Juaben"								if subregion==	611
	replace subregion1="612 - Bosumtwi"									if subregion==	612
	replace subregion1="613 - Atwima Kwanwoma"							if subregion==	613
	replace subregion1="614 - KMA"										if subregion==	614
	replace subregion1="615 - Atwima Nwabiagya"							if subregion==	615
	replace subregion1="616 - Ahafo Ano South"							if subregion==	616
	replace subregion1="617 - Ahafo Ano North"							if subregion==	617
	replace subregion1="618 - Offinso Municipal"						if subregion==	618
	replace subregion1="619 - Afigya Kwabre"							if subregion==	619
	replace subregion1="620 - Kwabre  East"								if subregion==	620
	replace subregion1="621 - Sekyere South"							if subregion==	621
	replace subregion1="622 - Mampong Municipal"						if subregion==	622
	replace subregion1="623 - Sekyere East"								if subregion==	623
	replace subregion1="624 - Sekyere Afram Plains"						if subregion==	624
	replace subregion1="625 - Sekyere Central"							if subregion==	625
	replace subregion1="626 - Ejura Sekye Dumasi"						if subregion==	626
	replace subregion1="627 - Offinso North"							if subregion==	627
	replace subregion1="701 - Asunafo South"							if subregion==	701
	replace subregion1="702 - Asunafo North"							if subregion==	702
	replace subregion1="703 - Asutifi"									if subregion==	703
	replace subregion1="704 - Dormaa Municipal"							if subregion==	704
	replace subregion1="705 - Dormaa East"								if subregion==	705
	replace subregion1="706 - Tano South"								if subregion==	706
	replace subregion1="707 - Tano North"								if subregion==	707
	replace subregion1="708 - Sunyani Municipal"						if subregion==	708
	replace subregion1="709 - Sunyani West"								if subregion==	709
	replace subregion1="710 - Berekum"									if subregion==	710
	replace subregion1="711 - Jaman South"								if subregion==	711
	replace subregion1="712 - Jaman North"								if subregion==	712
	replace subregion1="713 - Tain"										if subregion==	713
	replace subregion1="714 - Wenchi"									if subregion==	714
	replace subregion1="715 - Techiman"									if subregion==	715
	replace subregion1="716 - Nkoranza South"							if subregion==	716
	replace subregion1="717 - Nkoranza North"							if subregion==	717
	replace subregion1="718 - Atebubu Amantin"							if subregion==	718
	replace subregion1="719 - Sene"										if subregion==	719
	replace subregion1="720 - Pru"										if subregion==	720
	replace subregion1="721 - Kintampo South"							if subregion==	721
	replace subregion1="722 - Kintampo"									if subregion==	722
	replace subregion1="801 - Bole"										if subregion==	801
	replace subregion1="802 - Sawla/Tuna/Kalba"							if subregion==	802
	replace subregion1="803 - West Gonja"								if subregion==	803
	replace subregion1="804 - Gonja Central"							if subregion==	804
	replace subregion1="805 - East Gonja"								if subregion==	805
	replace subregion1="806 - Kpandai"									if subregion==	806
	replace subregion1="807 - Nanumba South"							if subregion==	807
	replace subregion1="808 - Nanumba North"							if subregion==	808
	replace subregion1="809 - Zabzugu Tatali"							if subregion==	809
	replace subregion1="810 - Yendi"									if subregion==	810
	replace subregion1="811 - Tamale (South/Central/North)"				if subregion==	811
	replace subregion1="812 - Tolon Kumbugu"							if subregion==	812
	replace subregion1="813 - Savelugu Nanton"							if subregion==	813
	replace subregion1="814 - Karaga"									if subregion==	814
	replace subregion1="815 - Gushiegu"									if subregion==	815
	replace subregion1="816 - Saboba"									if subregion==	816
	replace subregion1="817 - Chereponi"								if subregion==	817
	replace subregion1="818 - Bunkpurugu Yonyo"							if subregion==	818
	replace subregion1="819 - East Mamprusi"							if subregion==	819
	replace subregion1="820 - West Mamprusi"							if subregion==	820
	replace subregion1="901 - Builsa"									if subregion==	901
	replace subregion1="902 - Kasena Nankana West"						if subregion==	902
	replace subregion1="903 - Kasena Nankana East"						if subregion==	903
	replace subregion1="904 - Bolgatanga"								if subregion==	904
	replace subregion1="905 - Talensi Nabdam"							if subregion==	905
	replace subregion1="906 - Bongo"									if subregion==	906
	replace subregion1="907 - Bawku West"								if subregion==	907
	replace subregion1="908 - Garu Tempane"								if subregion==	908
	replace subregion1="909 - Bawku Municipal"							if subregion==	909
	replace subregion1="1001 - Wa West"									if subregion==	1001
	replace subregion1="1002 - Wa Municipal"							if subregion==	1002
	replace subregion1="1003 - Wa East"									if subregion==	1003
	replace subregion1="1004 - Sissala East"							if subregion==	1004
	replace subregion1="1005 - Nadowli"									if subregion==	1005
	replace subregion1="1006 - Jirapa"									if subregion==	1006
	replace subregion1="1007 - Sissala West"							if subregion==	1007
	replace subregion1="1008 - Lambussie Karni"							if subregion==	1008
	replace subregion1="1009 - Lawra"									if subregion==	1009
	
	gen str subnatid2 = subregion1
	
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
	gen hsize = hhsize
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen age = s1q5y
	*In addition, in the case of children aged less than or equal to 60 months(5 years), variable age should be expressed in the number of completed years and months in decimals.
	replace age = s1q5y + (s1q5m / 12) if !missing(s1q5y) & !missing(s1q5m) & inrange(s1q5y,0,4)
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = s1q2
	recode male (2 = 0)
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen relationharm = s1q3
	recode relationharm (4 7 8 = 5) (5 = 4) (6 = 3) (9 10 11 = 6)
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	decode s1q3, gen(relationcs)
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital = s1q6
	recode marital (2 = 3) (3 = 4) (6 = 2)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
/* <_eye_dsablty_note>

	The questionnarie only ask What type of disability does (NAME) have? if the respondent has any serious disability that limits his/her full participation in life activities.
	
</_eye_dsablty_note> */
	gen eye_dsablty = 1
	replace eye_dsablty = 4 if s3aq27 == 1
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
	label values eye_dsablty dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty = 1
	replace hear_dsablty = 4 if s3aq27 == 2
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values hear_dsablty dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty = 1
	replace walk_dsablty = 4 if s3aq27 == 4
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values walk_dsablty dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord = 1
	replace conc_dsord = 4 if s3aq27 == 5
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values conc_dsord dsablty
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty  = 1
	replace slfcre_dsablty = 4 if s3aq27 == 6
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values slfcre_dsablty dsablty
	label var slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty = 1
	replace comm_dsablty = 4 if  s3aq27 == 3
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
	gen migrated_mod_age = 7
	label var migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>


*<_migrated_ref_time_>
	gen migrated_ref_time = 99
	label var migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>


*<_migrated_binary_>
	gen migrated_binary = !missing(s5aq4a)
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen migrated_years = s5aq4a
	label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban = .
	replace migrated_from_urban = 1 if inrange(s5aq6,1,11)
	replace migrated_from_urban = 0 if s5aq6 == 12
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
/* <_migrated_from_cat_note>

	* 1 to 10 are the capital cities of each region (subnatid1 code respective)
		* if city region is different from subnatid1 var, code 4
		* if city region is the same as subnatid1 var, code 6
		
(s5aq6):
	1. Sekondi/Takoradi
	2. Cape Coast 
	3. Accra  
	4. Ho  
	5. Koforidua  
	6. Kumasi  
	7. Sunyani  
	8. Tamale  
	9. Bolgatanga  
	10. Wa  
	11. Other urban area  
	12. Rural area  
	96. Other ECOWAS  
	97. Africa other than ECOWAS  
	98. Outside Africa  

</_migrated_from_cat_note> */
	gen migrated_from_cat = .
	replace migrated_from_cat = 4 if s5aq6 != region & inrange(s5aq6,1,10)
	replace migrated_from_cat = 6 if s5aq6 == region & inrange(s5aq6,1,10) & missing(migrated_from_cat)
	replace migrated_from_cat = 6 if inlist(s5aq6,11,12)
	replace migrated_from_cat = 5 if inlist(s5aq6,96,97,98)
	
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country" 6 "Within country, admin unknown" 7 "Wholly unknow"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen mig_help = s5aq6 if migrated_from_cat == 4
	label define lbmig_help 1 "Western" 2 "Central" 3 "Greater Accra" 4 "Volta" 5 "Eastern" ///
    6 "Ashanti" 7 "Brong Ahafo" 8 "Northern" 9 "Upper East" 10 "Upper West"
	label values mig_help lbmig_help
	decode mig_help, gen(sub1_mig_str)
	egen migrated_from_code = concat(s5aq6 sub1_mig_str) if !missing(mig_help), punct(" - ")
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country = "Other ECOWAS" if s5aq6 == 96
	replace migrated_from_country = "Africa other than ECOWAS" if s5aq6 == 97
	replace migrated_from_country = "Other World" if s5aq6 == 98
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason = s5aq10
	recode migrated_reason (1 2 3 = 3) (4 5 6 7 = 1) (8 10 11 12 = 4) (9 = 2) (13 = 5)
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

Education module is only asked to those 03 and older.

</_ed_mod_age_note> */

gen byte ed_mod_age = 3
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school = (s2aq5 == 1)
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
/* <_literacy_note>

Literacy questions made to 11 years or older

</_literacy_note> */
	gen byte literacy = .
	replace literacy = 1 if [inrange(s2cq1,1,3) | inrange(s2cq2,2,9)] & [inrange(s2cq3,1,3) | inrange(s2cq4,2,9)]
	replace literacy = 0 if missing(literacy)
	replace literacy = . if inrange(age,0,10)
	egen no_literacy_response = rowmiss(s2cq1 s2cq2 s2cq3 s2cq4)
	replace literacy = . if no_literacy_response == 4
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen byte educy = .
	
	replace educy = 0 if inlist(s2aq2, 0, 1) // None & Pre-school
	replace educy = s2aq2 - 10 if inrange(s2aq2, 11, 23) // (P1 - M4)
	replace educy = s2aq2 - 14 if inrange(s2aq2, 24, 27) // (SS1/SHS1 - SHS4)
	replace educy = 13 if inrange(s2aq2,28,34) // (S1 - U6)
	replace educy = 15 if s2aq2 == 41 // Vocational/Technical
	replace educy = 16 if inlist(s2aq2, 42, 43) // Technical Training & Nursing
	replace educy = 16 if s2aq2 == 51 // Polytechnic
	replace educy = 17 if inlist(s2aq2, 52) // University
	replace educy = 19 if s2aq2 == 53 //Other Tertiary (assume master and PHD)
	replace educy = . if s2aq2 == 61 // Other 
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen byte educat7 = .
	replace educat7 = 1 if inlist(s2aq2,1) | s2aq1 == 2 
	replace educat7 = 2 if inlist(s2aq2,11,12,13,14,15) & missing(educat7)
	replace educat7 = 3 if inlist(s2aq2,16) & missing(educat7)
	replace educat7 = 4 if inlist(s2aq2,17,18,19,20,21,22,23) & missing(educat7)
	replace educat7 = 5 if inlist(s2aq2,24,25,26,27,28,29,30,31,32,33,34) & missing(educat7)
	replace educat7 = 6 if inlist(s2aq2,41,42,43,51) & missing(educat7)
	replace educat7 = 7 if inlist(s2aq2,52,53) & missing(educat7)
	label var educat7 "Level of education 1"
	la de lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete"
	label values educat7 lbleducat7
*</_educat7_>


*<_educat5_>
	gen byte educat5 = educat7
	recode educat5 (4 = 3) (5 = 4) (6 7 = 5)
	label var educat5 "Level of education 2"
	la de lbleducat5 1 "No education" 2 "Primary incomplete"  3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>


*<_educat4_>
	gen byte educat4 = educat7
	recode educat4 (2 3 4 = 2) (5 = 3) (6 7 = 4)
	label var educat4 "Level of education 3"
	la de lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 lbleducat4
*</_educat4_>


*<_educat_orig_>
	decode s2aq2, gen(educat_orig)
	label var educat_orig "Original survey education code"
*</_educat_orig_>

**# Bookmark #1
*<_educat_isced_>
	gen educat_isced = .
	label var educat_isced "ISCED standardised level of education"
*</_educat_isced_>


*----------6.1: Education cleanup------------------------------*

*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
local ed_vars "school literacy educy educat7 educat5 educat4 educat_orig educat_isced"

foreach ed_var of local ed_vars {
	cap confirm numeric variable `ed_var'
	if _rc == 0 { // is indeed numeric
		replace `ed_var' = . if ( age < ed_mod_age & !missing(age) )
	}
	else { // is not
		replace `ed_var' = "" if ( age < ed_mod_age & !missing(age) )
	}
}


*</_% Correction min age_>


}


/*%%=============================================================================================
	7: Training
==============================================================================================%%*/


{

*<_vocational_>
	gen vocational = s4aq36
	replace vocational = s4eq26 if missing(vocational)
	replace vocational = s2cq14 if missing(vocational)
	recode vocational (2 = 0) (3 = .)
	label de lblvocational 0 "No" 1 "Yes"
	label values vocational lblvocational
	label var vocational "Ever received vocational training"
*</_vocational_>


*<_vocational_type_>
	gen vocational_type = .
	label de lblvocational_type 1 "Inside Enterprise" 2 "External"
	label values vocational_type lblvocational_type
	label var vocational_type "Type of vocational training"
*</_vocational_type_>


*<_vocational_length_l_>
	gen vocational_length_l = s4aq37m 
	replace vocational_length_l = s4eq27m if missing(vocational_length_l)
	label var vocational_length_l "Length of training in months, lower limit"
*</_vocational_length_l_>


*<_vocational_length_u_>
	gen vocational_length_u = vocational_length_l
	label var vocational_length_u "Length of training in months, upper limit"
*</_vocational_length_u_>


*<_vocational_field_orig_>
	decode s4aq38, gen(vocational_field_orig)
	decode s2cq15, gen(vocational_field_orig_2)
	replace vocational_field_orig = vocational_field_orig_2 if s2cq14 == 1
	label var vocational_field_orig "Original field of training information"
*</_vocational_field_orig_>


*<_vocational_financed_>
	gen vocational_financed = s4aq39
	recode vocational_financed (2 = 4) (3 = 1)  (4 6 = 5) (1 = 2)
	gen vocational_financed_2 = s4eq29
	recode vocational_financed_2 (1 = 4) (2 = 1) (3 = 5) (4 = 2) (6 7 = 5)
	replace vocational_financed = vocational_financed_2 if missing(vocational_financed)
	label de lblvocational_financed 1 "Employer" 2 "Government" 3 "Mixed Employer/Government" 4 "Own funds" 5 "Other"
	label values vocational_financed lblvocational_financed
	label var vocational_financed "How training was financed"
*</_vocational_financed_>

}


/*%%=============================================================================================
	8: Labour
==============================================================================================%%*/


*<_minlaborage_>
	gen byte minlaborage = 5
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>

	gen byte lstatus = .
	
	*Code employed
	replace lstatus = 1 if s4aq1 == 1 | s4aq2 == 1 | s4aq3 == 1
	
	*Code unemployed
	gen active = 1 if inlist(s4dq2,1,2)
	gen passive = 1 if inlist(s4dq1,1,2)
	replace lstatus = 2 if active == 1 & passive == 1 & missing(lstatus)
	
	*Code NLF
	replace lstatus = 3 if missing(lstatus)
	
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = (active == 1 | passive == 1)
	replace potential_lf = . if age < minlaborage & !missing(age)
	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen byte underemployment = s4cq1
	recode underemployment (2 = 0) (3 = .)
	replace underemployment = . if age < minlaborage & !missing(age)
	replace underemployment = . if lstatus != 1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason = s4dq10
	recode nlfreason (3 4 7/16 = 5) (5 = 4) (6 = 3)
	replace nlfreason = 1 if s4dq4 == 13 & missing(nlfreason)
	replace nlfreason = 2 if s4dq4 == 11 & missing(nlfreason)
	replace nlfreason = 1 if s4dq4 == 16 & missing(nlfreason)
	replace nlfreason = 4 if s4dq4 == 10 & missing(nlfreason)
	replace nlfreason = 5 if !missing(s4dq4) & missing(nlfreason)
	replace nlfreason = . if age < minlaborage & !missing(age)
	replace nlfreason = . if lstatus != 3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l = s4dq7
	recode unempldur_l (0 = .) (1 = 0) (2 = 1) (4 = 6) (5 = 12) (6 = 24) (7 = 24)
	replace unempldur_l = . if lstatus != 2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u = s4dq7
	recode unempldur_u (0 = .) (2 = 3) (3 = 6) (4 = 12) (5 = 24) (6 = 24) (7 = .)
	replace unempldur_u = . if lstatus != 2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte empstat = s4aq20 
	recode empstat (2 5 = 3) (3 6 = 4) (4 7 10 = 2) (8 9 = 1) (11 = 5)
	replace empstat = . if lstatus != 1
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec = s4aq21
	recode ocusec (2 = 1) (4 5 6 7 8 = 2) (9 = 4) (10 = .)
	replace ocusec = . if lstatus != 1
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	decode s4aq7, gen(industry_orig)
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	tostring s4aq7, gen(industrycat_isic) format(%04.0f)
	replace industrycat_isic = "" if industrycat_isic == "."
	replace industrycat_isic = "0729" if industrycat_isic == "0722" |industrycat_isic == "0723" // gold and diamond mining 
	replace industrycat_isic = "8620" if industrycat_isic == "8630"
	
	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	
	/*
	preserve 
	drop if missing(industrycat_isic)
	int_classif_universe, var(industrycat_isic) universe(ISIC)
	count
	list
	assert `r(N)' == 0
	restore 
	*/

	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen byte industrycat10 = real(substr(industrycat_isic,1,2))
	recode industrycat10 (1/3 = 1) (5/9 = 2) (10/33 = 3) (35/39 = 4) (41/43 = 5) (45/47 55/56 = 6) (49/53 58/63 = 7) (64/82 = 8) (84 = 9) (85/99 = 10)
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
*</_industrycat10_>


*<_industrycat4_>
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
	decode s4aq6, gen(occup_orig)
	replace occup_orig = "" if lstatus != 1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	tostring s4aq6, gen(occup_isco) format(%04.0f)
	replace occup_isco = "" if occup_isco == "."
	replace occup_isco = "7510" if occup_isco == "7517" | occup_isco == "7518"
	
	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	/*
	preserve 
	drop if missing(occup_isco)
	int_classif_universe, var(occup_isco) universe(ISCO)
	count
	list
	assert `r(N)' == 0
	restore
	*/
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	gen byte occup = real(substr(occup_isco,1,1))
	replace occup = 10 if occup == 0
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
	gen double wage_no_compen = s4aq18a
	replace wage_no_compen = . if lstatus != 1
	replace wage_no_compen = . if empstat == 2 | s4aq18a == 0
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>

/* <_unitwage_note>
	Unitwage refers to the unit used to record wage_no_compen, *not* the unit of
	general wage payent. For example, PHL LFS asks about wage periodicity, then
	asks for basic daily pay. The value of that pay would be wage_no_compen,
	while unitwage is code 1 ("Daily") for all, regardless of the periodicity.
</_unitwage_note> */

	gen byte unitwage = s4aq18b
	recode unitwage (0 = 10) (4 = 5) (5 = 6) (6 = 8) (7 = .)
	replace unitwage = . if missing(wage_no_compen)
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours = s4aq9 if lstatus == 1
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	gen wmonths = .
	replace wmonths = 12 if inrange(s4aq8y,1,99) | inrange(s4aq8m,12,99)
	replace wmonths = s4aq8m if inrange(s4aq8m,0,11) & missing(wmonths)
	replace wmonths = 1 if wmonths == 0
	replace wmonths = . if lstatus != 1
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
/* <_wage_total_note>

	Use gross wages when available and net wages only when gross wages are not available.
	This is done to make it easy to compare earnings in formal and informal sectors.

</_wage_total_note> */

	
	*payment in form of goods and services 
	gen wage_compen = s4aq23a
	replace wage_compen = . if lstatus != 1
	replace wage_compen = . if empstat == 2 | s4aq23a == 0
	
	gen unitwage_compen = s4aq23b
	recode unitwage_compen (0 = 10) (4 = 5) (5 = 6) (6 = 8) (7 = .)
	replace unitwage_compen = . if missing(wage_compen)
	
	gen unitwage_no_compen = unitwage

	foreach var in compen no_compen {
		gen annual_wage_`var' = .
		replace annual_wage_`var' = (wage_`var')*5*4.3*wmonths if unitwage_`var'==1 //Wage in daily unit
		replace annual_wage_`var' = (wage_`var')*4.3*wmonths if unitwage_`var' == 2 // Wage in weekly unit
		replace annual_wage_`var' = (wage_`var')*2.15*wmonths if unitwage_`var' == 3 // Wage in every two weeks unit
		replace annual_wage_`var' = (wage_`var')/2*wmonths if unitwage_`var' == 4 // Wage in every two months unit
		replace annual_wage_`var' = (wage_`var')*wmonths if unitwage_`var' == 5 // Wage in monthly unit
		replace annual_wage_`var' = (wage_`var')/3*wmonths if unitwage_`var' == 6 // Wage in every quarterly unit
		replace annual_wage_`var' = (wage_`var')/6*wmonths if unitwage_`var' == 7 // Wage in every six months unit
		replace annual_wage_`var' = (wage_`var')/12*wmonths if unitwage_`var' == 8 // Wage in annual unit
		replace annual_wage_`var' = (wage_`var')*whours*4.3*wmonths if unitwage_`var' == 9 // Wage in hourly unit
	}
	
	*Sum all
	egen  wage_total = rowtotal(annual_wage_no_compen annual_wage_compen), missing
	replace wage_total = . if lstatus != 1 | wage_total == 0 | empstat == 2 
	
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen byte contract = s4aq24 if lstatus == 1
	recode contract (2 3 = 0)
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte healthins = s4aq29 if lstatus == 1
	recode healthins (2 = 0)
	label var healthins "Employment has health insurance primary job 7 day recall"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen byte socialsec = s4aq28
	replace socialsec = s4aq30 if inlist(socialsec,.,2)
	recode socialsec (2 = 0)
	replace socialsec = . if lstatus != 1
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
	gen firmsize_l = s4aq35
	replace firmsize_l = . if inlist(s4aq35,9998,9999) | lstatus != 1 
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen firmsize_u = firmsize_l
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen byte empstat_2 = s4bq8
	recode empstat_2 (2 5 = 3) (3 6 = 4) (4 7 10 = 2) (8 9 = 1) (11 = 5)
	replace empstat_2 = . if lstatus != 1
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2 = s4bq9
	replace ocusec_2 = . if lstatus != 1
	recode ocusec_2 (2 = 1) (4 5 6 7 8 = 2) (9 = 4) (10 = .)
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	decode s4bq2, gen(industry_orig_2)
	replace industry_orig_2 = "" if empstat_2 == . | lstatus != 1
	label var industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	tostring s4bq2, gen(industrycat_isic_2) format(%04.0f)
	replace industrycat_isic_2 = "" if industrycat_isic_2 == "."
	replace industrycat_isic_2 = "0729" if industrycat_isic_2 == "0722" |industrycat_isic_2 == "0723" // gold and diamond mining 
	replace industrycat_isic_2 = "8620" if industrycat_isic_2 == "8630"
	replace industrycat_isic_2 = "3320" if industrycat_isic_2 == "3323"
	replace industrycat_isic_2 = "" if empstat_2 == . | lstatus != 1
	
	/*
	preserve 
	drop if missing(industrycat_isic_2)
	int_classif_universe, var(industrycat_isic_2) universe(ISIC)
	count
	list
	assert `r(N)' == 0
	restore 
	*/

	label var industrycat_isic_2 "ISIC code of secondary job 7 day recall"
*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen byte industrycat10_2 =  real(substr(industrycat_isic_2,1,2))
	recode industrycat10_2 (1/3 = 1) (5/9 = 2) (10/33 = 3) (35/39 = 4) (41/43 = 5) (45/47 55/56 = 6) (49/53 58/63 = 7) (64/82 = 8) (84 = 9) (85/99 = 10)
	replace industrycat10_2 = . if empstat_2 == . | lstatus != 1
	label var industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
	label values industrycat10_2 lblindustrycat10
*</_industrycat10_2_>


*<_industrycat4_2_>
	gen byte industrycat4_2 = industrycat10_2
	recode industrycat4_2 (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label var industrycat4_2 "Broad Economic Activities classification, secondary job 7 day recall"
	label values industrycat4_2 lblindustrycat4
*</_industrycat4_2_>


*<_occup_orig_2_>
	decode s4bq1, gen(occup_orig_2)
	replace occup_orig_2 = "" if missing(empstat_2) | lstatus != 1
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	tostring s4aq6, gen(occup_isco_2) format(%04.0f)
	replace occup_isco_2 = "" if occup_isco_2 == "."
	replace occup_isco_2 = "7510" if occup_isco_2 == "7517" | occup_isco_2 == "7518"
	replace occup_isco_2 = "" if empstat_2 == . | lstatus != 1
	
	/*
	preserve 
	drop if missing(occup_isco_2)
	int_classif_universe, var(occup_isco_2) universe(ISCO)
	count
	list
	assert `r(N)' == 0
	restore
	*/


	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_2_>
	gen byte occup_2 = real(substr(occup_isco_2,1,1))
	replace occup_2 = 10 if occup_2 == 0
	replace occup_2 = . if empstat_2 == . | lstatus != 1
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
	gen double wage_no_compen_2 = s4bq7a
	replace wage_no_compen_2 = . if empstat_2 == . | lstatus != 1
	replace wage_no_compen_2 = . if empstat_2 == 2 | s4bq7a == 0
	label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte unitwage_2 = s4bq7b
	recode unitwage_2 (0 = 10) (4 = 5) (5 = 6) (6 = 8) (7 = .)
	replace unitwage_2 = . if missing(wage_no_compen_2)

	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
	gen whours_2 = s4bq4 if !missing(empstat_2) | lstatus == 1
	label var whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>


*<_wmonths_2_>
	gen wmonths_2 = .
	replace wmonths_2 = 12 if inrange(s4bq3y,1,99) | inrange(s4bq3m,12,99)
	replace wmonths_2 = s4bq3m if inrange(s4bq3m,0,11) & missing(wmonths_2)
	replace wmonths_2 = 1 if wmonths_2 == 0
	replace wmonths_2 = . if missing(empstat_2) | lstatus != 1

	label var wmonths_2 "Months of work in past 12 months secondary job 7 day recall"
*</_wmonths_2_>


*<_wage_total_2_>
	*payment in form of goods and services 
	gen wage_compen_2 = s4bq11a
	replace wage_compen_2 = . if empstat_2 == . | lstatus != 1
	replace wage_compen_2 = . if empstat_2 == 2 | s4bq11a == 0
	
	gen unitwage_compen_2 = s4bq11b
	recode unitwage_compen_2 (0 = 10) (4 = 5) (5 = 6) (6 = 8) (7 = .)
	replace unitwage_compen_2 = . if missing(wage_compen_2)
	
	gen unitwage_no_compen_2 = unitwage_2

	foreach var in compen_2 no_compen_2 {
		gen annual_wage_`var' = .
		replace annual_wage_`var' = (wage_`var')*5*4.3*wmonths_2 if unitwage_`var'==1 //Wage in daily unit
		replace annual_wage_`var' = (wage_`var')*4.3*wmonths_2 if unitwage_`var' == 2 // Wage in weekly unit
		replace annual_wage_`var' = (wage_`var')*2.15*wmonths_2 if unitwage_`var' == 3 // Wage in every two weeks unit
		replace annual_wage_`var' = (wage_`var')/2*wmonths_2 if unitwage_`var' == 4 // Wage in every two months unit
		replace annual_wage_`var' = (wage_`var')*wmonths_2 if unitwage_`var' == 5 // Wage in monthly unit
		replace annual_wage_`var' = (wage_`var')/3*wmonths_2 if unitwage_`var' == 6 // Wage in every quarterly unit
		replace annual_wage_`var' = (wage_`var')/6*wmonths_2 if unitwage_`var' == 7 // Wage in every six months unit
		replace annual_wage_`var' = (wage_`var')/12*wmonths_2 if unitwage_`var' == 8 // Wage in annual unit
		replace annual_wage_`var' = (wage_`var')*whours_2*4.3*wmonths_2 if unitwage_`var' == 9 // Wage in hourly unit
	}
	
	*Sum all
	egen  wage_total_2 = rowtotal(annual_wage_no_compen_2 annual_wage_compen_2), missing
	replace wage_total_2 = . if lstatus != 1 | wage_total_2 == 0 | inlist(empstat_2,.,2)

	label var wage_total_2 "Annualized total wage secondary job 7 day recall"
*</_wage_total_2_>


*<_firmsize_l_2_>
	gen firmsize_l_2 = s4bq20
	recode firmsize_l_2 (9998 9999 = .)
	replace firmsize_l_2 = . if lstatus != 1 | empstat == .
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	gen firmsize_u_2 = firmsize_l_2
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
	gen t_hours_1 = (whours * wmonths)
	replace t_hours_1 = 0 if t_hours_1 == . & lstatus == 1
	gen t_hours_2 = (whours_2 * wmonths_2)
	replace t_hours_2 = 0 if t_hours_2 == . & lstatus == 1
	egen t_hours_total = rowtotal(t_hours_1  t_hours_2) if lstatus == 1, missing  
	label var t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
	
	gen wage_nocompen_total_1 = .
	replace wage_nocompen_total_1 = (wage_no_compen)*5*4.3*wmonths if unitwage ==1 //Wage in daily unit
	replace wage_nocompen_total_1 = (wage_no_compen)*4.3*wmonths if unitwage == 2 // Wage in weekly unit
	replace wage_nocompen_total_1 = (wage_no_compen)*2.15*wmonths if unitwage == 3 // Wage in every two weeks unit
	replace wage_nocompen_total_1 = (wage_no_compen)/(2*wmonths) if unitwage == 4 // Wage in every two months unit
	replace wage_nocompen_total_1 = (wage_no_compen)*(wmonths) if unitwage == 5 // Wage in monthly unit
	replace wage_nocompen_total_1 = (wage_no_compen)/(3*wmonths) if unitwage == 6 // Wage in every quarterly unit
	replace wage_nocompen_total_1 = (wage_no_compen)/(6*wmonths) if unitwage == 7 // Wage in every six months unit
	replace wage_nocompen_total_1 = (wage_no_compen)/(12*wmonths) if unitwage == 8 // Wage in annual unit
	replace wage_nocompen_total_1 = (wage_no_compen)*whours*4.3*wmonths if unitwage == 9 // Wage in hourly unit
	
	gen wage_nocompen_total_2 = .
	replace wage_nocompen_total_2 = (wage_no_compen_2)*5*4.3*wmonths_2 if unitwage_2 ==1 //Wage in daily unit
	replace wage_nocompen_total_2 = (wage_no_compen_2)*4.3*wmonths_2 if unitwage_2 == 2 // Wage in weekly unit
	replace wage_nocompen_total_2 = (wage_no_compen_2)*2.15*wmonths_2 if unitwage_2 == 3 // Wage in every two weeks unit
	replace wage_nocompen_total_2 = (wage_no_compen_2)/(2*wmonths_2) if unitwage_2 == 4 // Wage in every two months unit
	replace wage_nocompen_total_2 = (wage_no_compen_2)*(wmonths_2) if unitwage_2 == 5 // Wage in monthly unit
	replace wage_nocompen_total_2 = (wage_no_compen_2)/(3*wmonths_2) if unitwage_2 == 6 // Wage in every quarterly unit
	replace wage_nocompen_total_2 = (wage_no_compen_2)/(6*wmonths_2) if unitwage_2 == 7 // Wage in every six months unit
	replace wage_nocompen_total_2 = (wage_no_compen_2)/(12*wmonths_2) if unitwage_2 == 8 // Wage in annual unit
	replace wage_nocompen_total_2 = (wage_no_compen_2)*wmonths_2*4.3*wmonths_2 if unitwage_2 == 9 // Wage in hourly unit

	egen t_wage_nocompen_total = rowtotal(wage_nocompen_total_1 wage_nocompen_total_2), missing
	replace t_wage_nocompen_total = . if lstatus != 1
	label var t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
	egen t_wage_total = rowtotal(wage_total wage_total_2), missing
	replace t_wage_total = . if lstatus != 1
	label var t_wage_total "Annualized total wage for all jobs 7 day recall"
*</_t_wage_total_>


*----------8.6: 12 month reference overall------------------------------*

{

*<_lstatus_year_>
	gen byte lstatus_year = .
	
	*Code employed
	replace lstatus_year = 1 if s4eq1 == 1 | s4eq2 == 1 | s4eq3 == 1
	
	*Code unemployed
	*at least one week available and seeking for job in the last 12 months
	gen active_yr = 1 if !inlist(s4gq3,0,.)
	gen passive_yr = 1 if !inlist(s4gq2,0,.)
	replace lstatus_year = 2 if active_yr == 1 & passive_yr == 1 & missing(lstatus_year)

	*Code NLF
	replace lstatus_year = 3 if missing(lstatus_year)

	replace lstatus_year = . if age < minlaborage & !missing(age)
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>


*<_potential_lf_year_>
	gen byte potential_lf_year = (active_yr == 1 | passive_yr == 1)
	replace potential_lf_year = . if age < minlaborage & !missing(age)
	replace potential_lf_year = . if lstatus_year != 3
	label var potential_lf_year "Potential labour force status"
	la de lblpotential_lf_year 0 "No" 1 "Yes"
	label values potential_lf_year lblpotential_lf_year
*</_potential_lf_year_>


*<_underemployment_year_>
	gen byte underemployment_year = .
	replace underemployment_year = . if age < minlaborage & !missing(age)
	replace underemployment_year = . if lstatus_year == 1
	label var underemployment_year "Underemployment status"
	la de lblunderemployment_year 0 "No" 1 "Yes"
	label values underemployment_year lblunderemployment_year
*</_underemployment_year_>


*<_nlfreason_year_>
	gen byte nlfreason_year = s4gq7
	recode nlfreason_year (3 = 4) (4 6 7 8 = 5) (5 = 3)
	replace nlfreason_year = 5 if !missing(s4gq5) & missing(nlfreason_year)
	replace nlfreason_year = . if age < minlaborage & !missing(age)
	replace nlfreason_year = . if lstatus_year != 3

	label var nlfreason_year "Reason not in the labor force"
	la de lblnlfreason_year 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason_year lblnlfreason_year
*</_nlfreason_year_>


*<_unempldur_l_year_>
	gen byte unempldur_l_year = s4gq1/4.3 if lstatus_year == 2 // week to month unit
	replace unempldur_l_year = s4gq2/4.3 if s4gq1 == 0 & lstatus_year == 2 // 1 obs
	
	label var unempldur_l_year "Unemployment duration (months) lower bracket"
*</_unempldur_l_year_>


*<_unempldur_u_year_>
	gen byte unempldur_u_year = unempldur_l_year
	label var unempldur_u_year "Unemployment duration (months) upper bracket"
*</_unempldur_u_year_>

}

*----------8.7: 12 month reference main job------------------------------*

{

*<_empstat_year_>
	gen byte empstat_year = s4eq14
	recode empstat_year (2 5 = 3) (3 6 = 4) (4 7 10 = 2) (8 9 = 1) (11 = 5)
	replace empstat_year = . if lstatus_year !=1
	label var empstat_year "Employment status during past week primary job 12 month recall"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>

*<_ocusec_year_>
	gen byte ocusec_year = s4eq15
	recode ocusec_year (2 = 1) (4 5 6 7 8 = 2) (9 = 4) (10 = .)
	replace ocusec_year = . if lstatus_year != 1
	label var ocusec_year "Sector of activity primary job 12 month recall"
	la de lblocusec_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_year lblocusec_year
*</_ocusec_year_>


*<_industry_orig_year_>
	decode s4eq7, gen(industry_orig_year)
	replace industry_orig_year = "" if lstatus_year != 1
	label var industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	tostring s4eq7, gen(industrycat_isic_year) format(%04.0f)
	replace industrycat_isic_year = "" if industrycat_isic_year == "."
	replace industrycat_isic_year = "0729" if industrycat_isic_year == "0722" |industrycat_isic_year == "0723" // gold and diamond mining 
	replace industrycat_isic_year = "8620" if industrycat_isic_year == "8630"
	replace industrycat_isic_year = "4300" if industrycat_isic_year == "4350"
	replace industrycat_isic_year = "5100" if industrycat_isic_year == "5141"
	replace industrycat_isic_year = "7500" if industrycat_isic_year == "7517"
	replace industrycat_isic_year = "9600" if industrycat_isic_year == "9606"
	replace industrycat_isic_year = "" if lstatus_year != 1

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	/*
	preserve 
	drop if missing(industrycat_isic_year)
	int_classif_universe, var(industrycat_isic_year) universe(ISIC)
	count
	list
	assert `r(N)' == 0
	restore 
	*/
	label var industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>

*<_industrycat10_year_>
	gen byte industrycat10_year = real(substr(industrycat_isic_year,1,2))
	recode industrycat10_year (1/3 = 1) (5/9 = 2) (10/33 = 3) (35/39 = 4) (41/43 = 5) (45/47 55/56 = 6) (49/53 58/63 = 7) (64/82 = 8) (84 = 9) (85/99 = 10)
	replace industrycat10_year = . if lstatus_year != 1
	label var industrycat10_year "1 digit industry classification, primary job 12 month recall"
	la de lblindustrycat10_year 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10_year lblindustrycat10_year
*</_industrycat10_year_>


*<_industrycat4_year_>
	gen byte industrycat4_year = industrycat10_year
	recode industrycat4_year (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label var industrycat4_year "Broad Economic Activities classification, primary job 12 month recall"
	la de lblindustrycat4_year 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4_year lblindustrycat4_year
*</_industrycat4_year_>


*<_occup_orig_year_>
	decode s4eq7, gen(occup_orig_year)
	replace occup_orig_year = "" if lstatus_year != 1
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	tostring s4eq6, gen(occup_isco_year) format(%04.0f)
	replace occup_isco_year = "" if occup_isco_year == "."
	replace occup_isco_year = "7510" if occup_isco_year == "7517" | occup_isco_year == "7518"
	replace occup_isco_year = "" if lstatus_year != 1


	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	/*
	preserve 
	drop if missing(occup_isco_year)
	int_classif_universe, var(occup_isco_year) universe(ISCO)
	count
	list
	assert `r(N)' == 0
	restore
	*/
	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_year_>
	gen byte occup_year = real(substr(occup_isco_year,1,1))
	replace occup_year = 10 if occup_year == 0
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
	gen double wage_no_compen_year = s4eq11a
	replace wage_no_compen_year = . if lstatus_year != 1
	replace wage_no_compen_year = . if empstat_year == 2 | s4eq11a == 0
	label var wage_no_compen_year "Last wage payment primary job 12 month recall"
*</_wage_no_compen_year_>


*<_unitwage_year_>
	gen byte unitwage_year = s4eq11b
	recode unitwage_year (0 = 10) (4 = 5) (5 = 6) (6 = 8) (7 = .)
	replace unitwage_year = . if missing(wage_no_compen_year)
	label var unitwage_year "Last wages' time unit primary job 12 month recall"
	la de lblunitwage_year 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_year lblunitwage_year
*</_unitwage_year_>


*<_whours_year_>
	gen help_whours_year = .
	replace help_whours_year = s4eq12a * 5 if s4eq12b == 1 // daily
	replace help_whours_year = s4eq12a/2 if s4eq12b == 3 // forthnightly
	replace help_whours_year = s4eq12a/4.3 if s4eq12b == 4 // monthly
	replace help_whours_year = (s4eq12a)/(4.3*3) if s4eq12b == 5 // quarterly
	replace help_whours_year = (s4eq12a)/(4.3*12) if s4eq12b == 6 // yearly
	gen whours_year = help_whours_year
	replace whours_year = s4eq25 if missing(whours_year)
	replace whours_year = . if inrange(s4eq25,169,999)
	replace whours_year = . if lstatus_year != 1
	label var whours_year "Hours of work in last week primary job 12 month recall"
*</_whours_year_>


*<_wmonths_year_>
	gen wmonths_year = s4eq24/4.3 if lstatus_year == 1
	replace wmonths_year = 12 if inrange(wmonths_year,12.0001,99)
	replace wmonths_year = 1 if wmonths_year == 0
	label var wmonths_year "Months of work in past 12 months primary job 12 month recall"
*</_wmonths_year_>


*<_wage_total_year_>
	
	*Other types of salary
	foreach var in food accomodation transport other {
		gen wage_`var'_year = s4eq17a if "`var'" == "food"
		replace wage_`var'_year = s4eq19a if "`var'" == "accomodation"
		replace wage_`var'_year = s4eq21a if "`var'" == "transport"
		replace wage_`var'_year = s4eq23a if "`var'" == "other"
		
		replace wage_`var'_year = . if lstatus_year != 1
		replace wage_`var'_year = . if empstat_year == 2 | wage_`var'_year == 0

		gen unitwage_`var'_year = s4eq17b if "`var'" == "food"
		replace unitwage_`var'_year = s4eq19b if "`var'" == "accomodation"
		replace unitwage_`var'_year = s4eq21b if "`var'" == "transport"
		replace unitwage_`var'_year = s4eq23b if "`var'" == "other"
		
		recode unitwage_`var'_year (0 = 10) (4 = 5) (5 = 6) (6 = 8) (7 = .)
		replace unitwage_`var'_year = . if missing(wage_`var'_year)
	}
	
	gen unitwage_no_compen_year = unitwage_year
	
    foreach var in food_year accomodation_year transport_year other_year no_compen_year {
		quietly {
		gen annual_wage_`var' = .
		replace annual_wage_`var' = (wage_`var')*5*4.3*wmonths_year if unitwage_`var'==1 //Wage in daily unit
		replace annual_wage_`var' = (wage_`var')*4.3*wmonths_year if unitwage_`var' == 2 // Wage in weekly unit
		replace annual_wage_`var' = (wage_`var')*2.15*wmonths_year if unitwage_`var' == 3 // Wage in every two weeks unit
		replace annual_wage_`var' = (wage_`var')/2*wmonths_year if unitwage_`var' == 4 // Wage in every two months unit
		replace annual_wage_`var' = (wage_`var')*wmonths_year if unitwage_`var' == 5 // Wage in monthly unit
		replace annual_wage_`var' = (wage_`var')/3*wmonths_year if unitwage_`var' == 6 // Wage in every quarterly unit
		replace annual_wage_`var' = (wage_`var')/6*wmonths_year if unitwage_`var' == 7 // Wage in every six months unit
		replace annual_wage_`var' = (wage_`var')/12*wmonths_year if unitwage_`var' == 8 // Wage in annual unit
		replace annual_wage_`var' = (wage_`var')*whours_year*4.3*wmonths_year if unitwage_`var' == 9 // Wage in hourly unit
		}
    }
	

    *Sum all
	egen wage_total_year = rowtotal(annual_wage_no_compen_year annual_wage_food_year annual_wage_accomodation_year annual_wage_transport_year annual_wage_other_year),missing
	replace wage_total_year = . if lstatus_year != 1 | wage_total_year == 0 | empstat_year == 2 

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
	gen byte empstat_2_year = s4fq9
	recode empstat_2_year (2 5 = 3) (3 6 = 4) (4 7 10 = 2) (8 9 = 1) (11 = 5)
	replace empstat_2_year = . if s4fq1 != 1
	replace empstat_2_year = . if lstatus_year != 1
	label var empstat_2_year "Employment status during past week secondary job 12 month recall"
	label values empstat_2_year lblempstat_year
*</_empstat_2_year_>


*<_ocusec_2_year_>
	gen byte ocusec_2_year = s4fq10
	recode ocusec_2_year (2 = 1) (4 5 6 7 8 = 2) (9 = 4) (10 = .)
	replace ocusec_2_year = . if s4fq1 != 1
	label var ocusec_2_year "Sector of activity secondary job 12 month recall"
	la de lblocusec_2_year 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_2_year lblocusec_2_year
*</_ocusec_2_year_>


*<_industry_orig_2_year_>
	decode s4fq3, gen(industry_orig_2_year) 
	replace industry_orig_2_year = "" if s4fq1 != 1 | lstatus_year != 1
	label var industry_orig_2_year "Original survey industry code, secondary job 12 month recall"
*</_industry_orig_2_year_>


*<_industrycat_isic_2_year_>
	tostring s4fq3, gen(industrycat_isic_2_year) format(%04.0f)
	replace industrycat_isic_2_year = "" if industrycat_isic_2_year == "."
	replace industrycat_isic_2_year = "0729" if industrycat_isic_2_year == "0722" |industrycat_isic_2_year == "0723" // gold and diamond mining 
	replace industrycat_isic_2_year = "8600" if industrycat_isic_2_year == "8630"
	replace industrycat_isic_2_year = "" if s4fq1 != 1 | lstatus_year != 1
	/*
	preserve 
	drop if missing(industrycat_isic_2_year)
	int_classif_universe, var(industrycat_isic_2_year) universe(ISIC)
	count
	list
	assert `r(N)' == 0
	restore 
	*/

	label var industrycat_isic_2_year "ISIC code of secondary job 12 month recall"
*</_industrycat_isic_2_year_>


*<_industrycat10_2_year_>
	gen byte industrycat10_2_year = real(substr(industrycat_isic_2_year,1,2))
	recode industrycat10_2_year (1/3 = 1) (5/9 = 2) (10/33 = 3) (35/39 = 4) (41/43 = 5) (45/47 55/56 = 6) (49/53 58/63 = 7) (64/82 = 8) (84 = 9) (85/99 = 10)
	replace industrycat10_2_year = . if s4fq1 != 1 | lstatus_year != 1
	label var industrycat10_2_year "1 digit industry classification, secondary job 12 month recall"
	label values industrycat10_2_year lblindustrycat10_year
*</_industrycat10_2_year_>


*<_industrycat4_2_year_>
	gen byte industrycat4_2_year = industrycat10_2_year
	recode industrycat4_2_year (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
	label var industrycat4_2_year "Broad Economic Activities classification, secondary job 12 month recall"
	label values industrycat4_2_year lblindustrycat4_year
*</_industrycat4_2_year_>


*<_occup_orig_2_year_>
	decode s4fq2, gen(occup_orig_2_year)
	replace occup_orig_2_year = "" if s4fq1 != 1 | lstatus_year != 1
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
	tostring s4fq2, gen(occup_isco_2_year) format(%04.0f)
	replace occup_isco_2_year = "" if occup_isco_2_year == "."
	replace occup_isco_2_year = "" if s4fq1 != 1 | lstatus_year != 1
	replace occup_isco_2_year = "7510" if occup_isco_2_year == "7517" | occup_isco_2_year == "7518"
	
	/*
	preserve 
	drop if missing(occup_isco_2)
	int_classif_universe, var(occup_isco_2_year) universe(ISCO)
	count
	list
	assert `r(N)' == 0
	restore
	*/


	label var occup_isco_2_year "ISCO code of secondary job 12 month recall"
*</_occup_isco_2_year_>


*<_occup_2_year_>
	gen byte occup_2_year = real(substr(occup_isco_2_year,1,1))
	replace occup_2_year = 10 if occup_2_year == 0
	replace occup_2_year = . if s4fq1 != 1 | lstatus_year != 1
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
	gen double wage_no_compen_2_year = s4fq7a
	replace wage_no_compen_2_year = . if s4fq1 != 1 | empstat_2_year == 2 | s4fq7a == 0 | lstatus_year != 1
	label var wage_no_compen_2_year "Last wage payment secondary job 12 month recall"
*</_wage_no_compen_2_year_>


*<_unitwage_2_year_>
	gen byte unitwage_2_year = s4fq7b
	recode unitwage_2_year (0 = 10) (4 = 5) (5 = 6) (6 = 8) (7 = .)
	replace unitwage_2_year = . if wage_no_compen_2_year == .
	label var unitwage_2_year "Last wages' time unit secondary job 12 month recall"
	label values unitwage_2_year lblunitwage_year
*</_unitwage_2_year_>


*<_whours_2_year_>
	gen whours_2_year = s4fq8a 
	replace whours_2_year = s4fq14 if missing(whours_2_year)
	replace whours_2_year = . if s4fq1 != 1 | lstatus_year != 1
	replace whours_2_year = . if whours_2_year > whours_year & !missing(whours_2_year) & !missing(whours_year)
	replace whours_2_year = . if inrange(whours_2_year,169,999)
	label var whours_2_year "Hours of work in last week secondary job 12 month recall"
*</_whours_2_year_>


*<_wmonths_2_year_>
	gen wmonths_2_year = s4fq13/4.3 if s4fq1 == 1 & lstatus_year == 1
	replace wmonths_2_year = 12 if inrange(wmonths_2_year,12.0001,99)
	replace wmonths_2_year = 1 if wmonths_2_year == 0
	label var wmonths_2_year "Months of work in past 12 months secondary job 12 month recall"
*</_wmonths_2_year_>


*<_wage_total_2_year_>

	*payment in form of goods and services 
	gen wage_goods_2_year = s4fq12a
	replace wage_goods_2_year = . if s4fq1 != 1 | lstatus_year != 1
	replace wage_goods_2_year = . if empstat_2_year == 2 | s4fq12a == 0
	
	gen unitwage_goods_2_year = s4fq12b
	recode unitwage_goods_2_year (0 = 10) (4 = 5) (5 = 6) (6 = 8) (7 = .)
	replace unitwage_goods_2_year = . if missing(wage_goods_2_year)
	
	gen unitwage_no_compen_2_year = unitwage_2_year
	
    foreach var in  goods_2_year no_compen_2_year {
		quietly {
		gen annual_wage_`var' = .
		replace annual_wage_`var' = (wage_`var')*5*4.3*wmonths_2_year if unitwage_`var'==1 //Wage in daily unit
		replace annual_wage_`var' = (wage_`var')*4.3*wmonths_2_year if unitwage_`var' == 2 // Wage in weekly unit
		replace annual_wage_`var' = (wage_`var')*2.15*wmonths_2_year if unitwage_`var' == 3 // Wage in every two weeks unit
		replace annual_wage_`var' = (wage_`var')/2*wmonths_2_year if unitwage_`var' == 4 // Wage in every two months unit
		replace annual_wage_`var' = (wage_`var')*wmonths_2_year if unitwage_`var' == 5 // Wage in monthly unit
		replace annual_wage_`var' = (wage_`var')/3*wmonths_2_year if unitwage_`var' == 6 // Wage in every quarterly unit
		replace annual_wage_`var' = (wage_`var')/6*wmonths_2_year if unitwage_`var' == 7 // Wage in every six months unit
		replace annual_wage_`var' = (wage_`var')/12*wmonths_2_year if unitwage_`var' == 8 // Wage in annual unit
		replace annual_wage_`var' = (wage_`var')*whours_2_year*4.3*wmonths_2_year if unitwage_`var' == 9 // Wage in hourly unit
		}
    }
	

    *Sum all
	egen wage_total_2_year = rowtotal(annual_wage_no_compen_2_year annual_wage_goods_2_year),missing
	replace wage_total_2_year = . if lstatus_year != 1 | wage_total_2_year == 0 | empstat_2_year == 2 

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
	gen t_hours_1_year = (whours_year * wmonths_year)
	replace t_hours_1 = 0 if t_hours_1_year == . & lstatus_year == 1
	gen t_hours_2_year = (whours_2_year * wmonths_2_year)
	replace t_hours_2_year = 0 if t_hours_2_year == . & lstatus_year == 1

	gen t_hours_total_year = t_hours_1_year + t_hours_2_year if lstatus_year == 1
	label var t_hours_total_year "Annualized hours worked in all jobs 12 month month recall"
*</_t_hours_total_year_>


*<_t_wage_nocompen_total_year_>

	gen wage_nocompen_total_1_year = .
	replace wage_nocompen_total_1_year = (wage_no_compen_year)*5*4.3*wmonths_year if unitwage_year == 1 // Wage in daily unit
	replace wage_nocompen_total_1_year = (wage_no_compen_year)*4.3*wmonths_year if unitwage_year == 2 // Wage in weekly unit
	replace wage_nocompen_total_1_year = (wage_no_compen_year)*2.15*wmonths_year if unitwage_year == 3 // Wage in every two weeks unit
	replace wage_nocompen_total_1_year = (wage_no_compen_year)/(2*wmonths_year) if unitwage_year == 4 // Wage in every two months unit
	replace wage_nocompen_total_1_year = (wage_no_compen_year)*(wmonths_year) if unitwage_year == 5 // Wage in monthly unit
	replace wage_nocompen_total_1_year = (wage_no_compen_year)/(3*wmonths_year) if unitwage_year == 6 // Wage in every quarterly unit
	replace wage_nocompen_total_1_year = (wage_no_compen_year)/(6*wmonths_year) if unitwage_year == 7 // Wage in every six months unit
	replace wage_nocompen_total_1_year = (wage_no_compen_year)/(12*wmonths_year) if unitwage_year == 8 // Wage in annual unit
	replace wage_nocompen_total_1_year = (wage_no_compen_year)*whours_year*4.3*wmonths_year if unitwage_year == 9 // Wage in hourly unit

	gen wage_nocompen_total_2_year = .
	replace wage_nocompen_total_2_year = (wage_no_compen_2_year)*5*4.3*wmonths_2_year if unitwage_2_year == 1 // Wage in daily unit
	replace wage_nocompen_total_2_year = (wage_no_compen_2_year)*4.3*wmonths_2_year if unitwage_2_year == 2 // Wage in weekly unit
	replace wage_nocompen_total_2_year = (wage_no_compen_2_year)*2.15*wmonths_2_year if unitwage_2_year == 3 // Wage in every two weeks unit
	replace wage_nocompen_total_2_year = (wage_no_compen_2_year)/(2*wmonths_2_year) if unitwage_2_year == 4 // Wage in every two months unit
	replace wage_nocompen_total_2_year = (wage_no_compen_2_year)*(wmonths_2_year) if unitwage_2_year == 5 // Wage in monthly unit
	replace wage_nocompen_total_2_year = (wage_no_compen_2_year)/(3*wmonths_2_year) if unitwage_2_year == 6 // Wage in every quarterly unit
	replace wage_nocompen_total_2_year = (wage_no_compen_2_year)/(6*wmonths_2_year) if unitwage_2_year == 7 // Wage in every six months unit
	replace wage_nocompen_total_2_year = (wage_no_compen_2_year)/(12*wmonths_2_year) if unitwage_2_year == 8 // Wage in annual unit
	replace wage_nocompen_total_2_year = (wage_no_compen_2_year)*wmonths_2_year*4.3*wmonths_2_year if unitwage_2_year == 9 // Wage in hourly unit

	egen t_wage_nocompen_total_year = rowtotal(wage_nocompen_total_1_year wage_nocompen_total_2_year), missing
	replace t_wage_nocompen_total_year = . if lstatus_year != 1
	label var t_wage_nocompen_total_year "Annualized wage in all jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_total_year_>


*<_t_wage_total_year_>
	egen t_wage_total_year = rowtotal(wage_total_year wage_total_2_year), missing
	replace t_wage_total_year = . if lstatus_year != 1
	label var t_wage_total_year "Annualized total wage for all jobs 12 month recall"
*</_t_wage_total_year_>


*----------8.11: Overall across reference periods------------------------------*


*<_njobs_>
	gen njobs = 1 if lstatus == 1 | lstatus_year == 1
	replace njobs = 2 if empstat_2 != . | empstat_2_year != .
	replace njobs = 0 if missing(njobs)
	label var njobs "Total number of jobs"
*</_njobs_>


*<_t_hours_annual_>
	egen t_hours_annual = rowtotal(t_hours_total  t_hours_total_year), missing
	label var t_hours_annual "Total hours worked in all jobs in the previous 12 months"
*</_t_hours_annual_>


*<_linc_nc_>
	egen linc_nc = rowtotal(t_wage_nocompen_total t_wage_nocompen_total_year), missing
	replace linc_nc = . if missing(t_wage_nocompen_total) & missing(t_wage_nocompen_total_year)
	label var linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."
*</_linc_nc_>


*<_laborincome_>
	egen laborincome = rowtotal(t_wage_total t_wage_total_year), missing
	replace laborincome = . if missing(t_wage_total) & missing(t_wage_total_year)
	label var laborincome "Total annual t_wage_total labor income in all jobs, incl. bonuses, etc."
*</_laborincome_>


*----------8.13: Labour cleanup------------------------------*

{
*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
	local lab_vars "minlaborage lstatus nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome"

	foreach lab_var of local lab_vars {
		cap confirm numeric variable `lab_var'
		if _rc == 0 { // is indeed numeric
			replace `lab_var' = . if ( age < minlaborage & !missing(age) )
		}
		else { // is not
			replace `lab_var' = "" if ( age < minlaborage & !missing(age) )
		}

	}

*</_% Correction min age_>
}


/*%%=============================================================================================
	9: Final steps
==============================================================================================%%*/

quietly{

*<_% KEEP VARIABLES - ALL_>

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu ssu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu ssu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

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

foreach kept_var of local kept_vars {
	
	capture assert missing(`kept_var')
	if !_rc drop `kept_var'
   
}

*</_% DELETE MISSING VARIABLES_>


*<_% COMPRESS_>

compress

*</_% COMPRESS_>


*<_% SAVE_>

save "`path_output'/`out_file'", replace

*</_% SAVE_>
