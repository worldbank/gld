
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				[ZMB_2012_LFS_V01_M_V01_A] </_Program name_>
<_Application_>					[STATA 17] <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2023-08-16 </_Date created_>

-------------------------------------------------------------------------

<_Country_>							[ZAMBIA (ZMB)] </_Country_>
<_Survey Title_>					[LABOUR FORCE SURVEY] </_Survey Title_>
<_Survey Year_>						[2012] </_Survey Year_>
<_Study ID_>						[N/A] </_Study ID_>
<_Data collection from_>			[] </_Data collection from_>
<_Data collection to_>				[] </_Data collection to_>
<_Source of dataset_> 				[Zambia Statistics Office] </_Source of dataset_>
<_Sample size (HH)_> 				[#] </_Sample size (HH)_>
<_Sample size (IND)_> 				[#] </_Sample size (IND)_>
<_Sampling method_> 				[two stage probabilistic, stratified, by enumeration areas] </_Sampling method_>
<_Geographic coverage_> 			[National, urban/rural] </_Geographic coverage_>
<_Currency_> 						[Zambia Kwacha] </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				[ICLS 13] </_ICLS Version_>
<_ISCED Version_>				[] </_ISCED Version_>
<_ISCO Version_>				[ISCO 2008] </_ISCO Version_>
<_OCCUP National_>				[N/A </_OCCUP National_>
<_ISIC Version_>				[ISIC v4] </_ISIC Version_>
<_INDUS National_>				[N/A] </_INDUS National_>

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
local server  "Y:/GLD-Harmonization/582018_AQ"
local country "ZMB"
local year    "2012"
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

* All steps necessary to merge datasets (if several) to have all elements needed to produce
* harmonized output in a single file

use "`path_in_stata'/2012LFS.dta", clear

/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode = "ZMB"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "LFS"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "labour force survey"
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
	* Report says data collection was november and december 2012, but no info in data
	gen int_year = 2012
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


	* First convert the variables we are going to use into strings of standard length
	gen str hlpr_prov    = string(prov,    "%02.0f")
	gen str hlpr_dist    = string(dist,    "%02.0f")
	gen str hlpr_const   = string(const,   "%03.0f")
	gen str hlpr_ward    = string(ward,    "%02.0f")
	gen str hlpr_cluster = string(cluster, "%03.0f")
	gen str hlpr_sbn     = string(sbn,     "%03.0f")
	gen str hlpr_hun     = string(hun,     "%02.0f")
	gen str hlpr_hhn     = string(hhn,     "%01.0f")
	
	egen hhid = concat(hlpr_*)
	label var hhid "Household ID"

*</_hhid_>


*<_pid_>

	rename pid pid_raw
	gen str hlpr_pid = string(pid_raw, "%02.0f")
	
	egen pid = concat(hhid hlpr_pid)
	label var pid "Individual ID"
	cap isid pid
	if _rc != 0 {
		dis "Not a unique ID - Beware"
	}
	
	* The above fails the isid pid test
	duplicates tag pid, gen(hlpr_dup)
	tab hlpr_dup
		
	* Of the 150 cases there are 24 households, all have just one HH head.
	distinct hhid if hlpr_dup == 1
	gen hlpr_test_hh_head = (a4 == 1)
	count if hlpr_test_hh_head & hlpr_dup == 1
	
	* The structure of the HHs also looks like they are one.
	* Hence we assume these really are single housheolds, just that the numbering inside the HH is wrong. We redo it.
	bys hhid (pid a4) : gen hlpr_numbering_in_hh = _n

	
	* Now recreate all, check
	drop hlpr_pid pid 
	gen str hlpr_pid = string(hlpr_numbering_in_hh, "%02.0f")
	egen pid = concat(hhid hlpr_pid)
	label var pid "Individual ID"
	isid pid
	drop hlpr_*
	
*</_pid_>


*<_weight_>
	*gen weight = weight
	label var weight "Survey sampling weight"
*</_weight_>


*<_psu_>
	gen psu = cluster
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
	gen byte urban = region
	recode urban (2=1) (1=0)
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
*province
/* <_subnatid1_note>

	The variable is string and country-specific categorical. Numeric entries are coded in string format using the following naming convention: “1 – Hatay”. That is, the variable itself is to be string, not a labelled numeric vector.

	Example of entries would be "1 - Alaska",  "2 - Arkansas", ...

</_subnatid1_note> */
	gen str subnatid1 = ""
	replace subnatid1 = "1 - Central" if prov==1
	replace subnatid1 = "2 - Copperbelt" if prov==2
	replace subnatid1 = "3 - Eastern" if prov==3
	replace subnatid1 = "4 - Luapula" if prov==4
	replace subnatid1 = "5 - Lusaka" if prov==5
	replace subnatid1 = "6 - Muchinga" if prov==6
	replace subnatid1 = "7 - Northern" if prov==7
	replace subnatid1 = "8 - North Western" if prov==8
	replace subnatid1 = "9 - Southern" if prov==9
	replace subnatid1 = "10 - Western" if prov==10
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	*district list (from 2010 census should be) taken from ILO listing
	* https://www.ilo.org/surveyLib/index.php/catalog/1303/data-dictionary/F2?file_name=ZMB_LFS_2012_STATA
	gen str subnatid2 = ""
	replace subnatid2="101 - Chibombo" if dist==101
	replace subnatid2="102 - Kabwe" if dist==102
	replace subnatid2="103 - Kapiri-Mposhi" if dist==103
	replace subnatid2="104 - Mkushi" if dist==104
	replace subnatid2="105 - Mumbwa" if dist==105
	replace subnatid2="106 - Serenje" if dist==106
	replace subnatid2="201 - Chililabombwe" if dist==201
	replace subnatid2="202 - Chingola" if dist==202
	replace subnatid2="203 - Kalulushi" if dist==203
	replace subnatid2="204 - Kitwe" if dist==204
	replace subnatid2="205 - Luanshya" if dist==205
	replace subnatid2="206 - Lufwanyama" if dist==206
	replace subnatid2="207 - Masaiti" if dist==207
	replace subnatid2="208 - Mpongwe" if dist==208
	replace subnatid2="209 - Mufulira" if dist==209
	replace subnatid2="210 - Ndola" if dist==210
	replace subnatid2="301 - Chadiza" if dist==301
	replace subnatid2="302 - Chipata" if dist==302
	replace subnatid2="303 - Katete" if dist==303
	replace subnatid2="304 - Lundazi" if dist==304
	replace subnatid2="305 - Mambwe" if dist==305
	replace subnatid2="306 - Nyimba" if dist==306
	replace subnatid2="307 - Petauke" if dist==307
	replace subnatid2="401 - Chienge" if dist==401
	replace subnatid2="402 - Kawambwa" if dist==402
	replace subnatid2="403 - Mansa" if dist==403
	replace subnatid2="404 - Milenge" if dist==404
	replace subnatid2="405 - Mwense" if dist==405
	replace subnatid2="406 - Nchelenge" if dist==406
	replace subnatid2="407 - Samfya" if dist==407
	replace subnatid2="501 - Chongwe" if dist==501
	replace subnatid2="502 - Kafue" if dist==502
	replace subnatid2="503 - Luangwa" if dist==503
	replace subnatid2="504 - Lusaka" if dist==504
	replace subnatid2="601 - Chama" if dist==601
	replace subnatid2="602 - Chinsali" if dist==602
	replace subnatid2="603 - Isoka" if dist==603
	replace subnatid2="604 - Mafinga" if dist==604
	replace subnatid2="605 - Mpika" if dist==605
	replace subnatid2="606 - Nakonde" if dist==606
	replace subnatid2="701 - Chilubi" if dist==701
	replace subnatid2="702 - Kaputa" if dist==702
	replace subnatid2="703 - Kasama" if dist==703
	replace subnatid2="704 - Luwingu" if dist==704
	replace subnatid2="705 - Mbala" if dist==705
	replace subnatid2="706 - Mporokoso" if dist==706
	replace subnatid2="707 - Mpulungu" if dist==707
	replace subnatid2="708 - Mungwi" if dist==708
	replace subnatid2="801 - Chavuma" if dist==801
	replace subnatid2="802 - Ikelenge" if dist==802
	replace subnatid2="803 - Kabompo" if dist==803
	replace subnatid2="804 - Kasempa" if dist==804
	replace subnatid2="805 - Mufumbwe" if dist==805
	replace subnatid2="806 - Mwinilunga" if dist==806
	replace subnatid2="807 - Solwezi" if dist==807
	replace subnatid2="808 - Zambezi" if dist==808
	replace subnatid2="901 - Choma" if dist==901
	replace subnatid2="902 - Gwembe" if dist==902
	replace subnatid2="903 - Itezhi-tezhi" if dist==903
	replace subnatid2="904 - Kalomo" if dist==904
	replace subnatid2="905 - Kazungula" if dist==905
	replace subnatid2="906 - Livingstone" if dist==906
	replace subnatid2="907 - Mazabuka" if dist==907
	replace subnatid2="908 - Monze" if dist==908
	replace subnatid2="909 - Namwala" if dist==909
	replace subnatid2="910 - Siavonga" if dist==910
	replace subnatid2="911 - Sinazongwe" if dist==911
	replace subnatid2="1001 - Kalabo" if dist==1001
	replace subnatid2="1002 - Kaoma" if dist==1002
	replace subnatid2="1003 - Lukulu" if dist==1003
	replace subnatid2="1004 - Mongu" if dist==1004
	replace subnatid2="1005 - Senanga" if dist==1005
	replace subnatid2="1006 - Sesheke" if dist==1006
	replace subnatid2="1007 - Shang'ombo" if dist==1007
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	*constituency list (from 2010 census should be) taken from ILO listing
	* https://www.ilo.org/surveyLib/index.php/catalog/1303/data-dictionary/F2?file_name=ZMB_LFS_2012_STATA
	gen str subnatid3 = ""
	replace subnatid3="1 - Chisamba" if const==1
	replace subnatid3="2 - Katuba" if const==2
	replace subnatid3="3 - Keembe" if const==3
	replace subnatid3="4 - Bwacha" if const==4
	replace subnatid3="5 - Kabwe" if const==5
	replace subnatid3="6 - KapiriMposhi" if const==6
	replace subnatid3="7 - MkushiNorth" if const==7
	replace subnatid3="8 - MkushiSouth" if const==8
	replace subnatid3="9 - Mumbezhi" if const==9
	replace subnatid3="10 - Mumbwa" if const==10
	replace subnatid3="11 - Nangoma" if const==11
	replace subnatid3="12 - Chitambo" if const==12
	replace subnatid3="13 - Muchinga" if const==13
	replace subnatid3="14 - Serenje" if const==14
	replace subnatid3="15 - Chililabombwe" if const==15
	replace subnatid3="16 - Chingola" if const==16
	replace subnatid3="17 - Nchanga" if const==17
	replace subnatid3="18 - Kalulushi" if const==18
	replace subnatid3="19 - Chimwemwe" if const==19
	replace subnatid3="20 - Kamfinsa" if const==20
	replace subnatid3="21 - Kwacha" if const==21
	replace subnatid3="22 - Nkana" if const==22
	replace subnatid3="23 - Wusakile" if const==23
	replace subnatid3="24 - Luanshya" if const==24
	replace subnatid3="25 - Roan" if const==25
	replace subnatid3="26 - Kankoyo" if const==26
	replace subnatid3="27 - Kantanshi" if const==27
	replace subnatid3="28 - Mufulira" if const==28
	replace subnatid3="29 - Kafulafuta" if const==29
	replace subnatid3="30 - Lufwanyama" if const==30
	replace subnatid3="31 - Masaiti" if const==31
	replace subnatid3="32 - Mpongwe" if const==32
	replace subnatid3="33 - BwanaMkubwa" if const==33
	replace subnatid3="34 - Chifubu" if const==34
	replace subnatid3="35 - Kabushi" if const==35
	replace subnatid3="36 - Ndola" if const==36
	replace subnatid3="37 - Chadiza" if const==37
	replace subnatid3="38 - Vubwi" if const==38
	replace subnatid3="39 - ChamaNorth" if const==39
	replace subnatid3="40 - ChamaSouth" if const==40
	replace subnatid3="41 - Chipangali" if const==41
	replace subnatid3="42 - ChipataCentral" if const==42
	replace subnatid3="43 - Kasenengwa" if const==43
	replace subnatid3="44 - Luangeni" if const==44
	replace subnatid3="45 - Milanzi" if const==45
	replace subnatid3="46 - Mkaika" if const==46
	replace subnatid3="47 - Sinda" if const==47
	replace subnatid3="48 - Chasefu" if const==48
	replace subnatid3="49 - Lumezi" if const==49
	replace subnatid3="50 - Lundazi" if const==50
	replace subnatid3="51 - Malambo" if const==51
	replace subnatid3="52 - Nyimba" if const==52
	replace subnatid3="53 - Kapoche" if const==53
	replace subnatid3="54 - Petauke" if const==54
	replace subnatid3="55 - Msanzala" if const==55
	replace subnatid3="56 - Kawambwa" if const==56
	replace subnatid3="57 - Mwansabombwe" if const==57
	replace subnatid3="58 - Pambashe" if const==58
	replace subnatid3="59 - Bahati" if const==59
	replace subnatid3="60 - Chembe" if const==60
	replace subnatid3="61 - Mansa" if const==61
	replace subnatid3="62 - Chipili" if const==62
	replace subnatid3="63 - Mambilima" if const==63
	replace subnatid3="64 - Mwense" if const==64
	replace subnatid3="65 - Chienge" if const==65
	replace subnatid3="66 - Nchelenge" if const==66
	replace subnatid3="67 - Bangweulu" if const==67
	replace subnatid3="68 - Chifunabuli" if const==68
	replace subnatid3="70 - Kafue" if const==70
	replace subnatid3="71 - Feira" if const==71
	replace subnatid3="72 - Chilanga" if const==72
	replace subnatid3="73 - Chongwe" if const==73
	replace subnatid3="74 - Rufunsa" if const==74
	replace subnatid3="75 - Chawama" if const==75
	replace subnatid3="76 - Kabwata" if const==76
	replace subnatid3="77 - Kanyama" if const==77
	replace subnatid3="78 - LusakaCentral" if const==78
	replace subnatid3="79 - Mandevu" if const==79
	replace subnatid3="80 - Matero" if const==80
	replace subnatid3="81 - Munali" if const==81
	replace subnatid3="82 - Chilubi" if const==82
	replace subnatid3="83 - Chinsali" if const==83
	replace subnatid3="84 - Shiwang'andu" if const==84
	replace subnatid3="85 - Mafinga" if const==85
	replace subnatid3="86 - IsokaWest" if const==86
	replace subnatid3="87 - Nakonde" if const==87
	replace subnatid3="88 - Chimbamilonga" if const==88
	replace subnatid3="89 - Kaputa" if const==89
	replace subnatid3="90 - Kasama" if const==90
	replace subnatid3="91 - Lukashya" if const==91
	replace subnatid3="92 - Malole" if const==92
	replace subnatid3="93 - Lubansenshi" if const==93
	replace subnatid3="94 - Lupososhi" if const==94
	replace subnatid3="95 - Mbala" if const==95
	replace subnatid3="96 - Mpulungu" if const==96
	replace subnatid3="97 - SengaHill" if const==97
	replace subnatid3="98 - Kanchibiya" if const==98
	replace subnatid3="99 - Mfuwe" if const==99
	replace subnatid3="100 - Mpika" if const==100
	replace subnatid3="101 - Lunte" if const==101
	replace subnatid3="102 - Mporokoso" if const==102
	replace subnatid3="103 - Chavuma" if const==103
	replace subnatid3="104 - KabompoEast" if const==104
	replace subnatid3="105 - KabompoWest" if const==105
	replace subnatid3="106 - Kasempa" if const==106
	replace subnatid3="107 - Mufumbwe" if const==107
	replace subnatid3="108 - Ikelenge" if const==108
	replace subnatid3="109 - MwinilungaWest" if const==109
	replace subnatid3="110 - SolweziCentral" if const==110
	replace subnatid3="111 - SolweziEast" if const==111
	replace subnatid3="112 - SolweziWest" if const==112
	replace subnatid3="113 - ZambeziEast" if const==113
	replace subnatid3="114 - ZambeziWest" if const==114
	replace subnatid3="115 - Choma" if const==115
	replace subnatid3="116 - Mbabala" if const==116
	replace subnatid3="117 - Pemba" if const==117
	replace subnatid3="118 - Gwembe" if const==118
	replace subnatid3="119 - Dundumwenze" if const==119
	replace subnatid3="120 - Kalomo" if const==120
	replace subnatid3="121 - Katombola" if const==121
	replace subnatid3="122 - Mapatizya" if const==122
	replace subnatid3="123 - Livingstone" if const==123
	replace subnatid3="124 - Chikankata" if const==124
	replace subnatid3="125 - Magoye" if const==125
	replace subnatid3="126 - Mazabuka" if const==126
	replace subnatid3="127 - Bweengwa" if const==127
	replace subnatid3="128 - Monze" if const==128
	replace subnatid3="129 - Moomba" if const==129
	replace subnatid3="130 - ItezhiTezhi" if const==130
	replace subnatid3="131 - Namwala" if const==131
	replace subnatid3="132 - Siavonga" if const==132
	replace subnatid3="133 - Sinazongwe" if const==133
	replace subnatid3="134 - Kalabo" if const==134
	replace subnatid3="135 - Liuwa" if const==135
	replace subnatid3="136 - Sikongo" if const==136
	replace subnatid3="137 - Kaoma" if const==137
	replace subnatid3="138 - Luampa" if const==138
	replace subnatid3="139 - Mangango" if const==139
	replace subnatid3="140 - LukuluEast" if const==140
	replace subnatid3="141 - LukuluWest" if const==141
	replace subnatid3="142 - Luena" if const==142
	replace subnatid3="143 - Mongu" if const==143
	replace subnatid3="144 - Nalikwanda" if const==144
	replace subnatid3="145 - Nalolo" if const==145
	replace subnatid3="146 - Senanga" if const==146
	replace subnatid3="147 - Sinjembela" if const==147
	replace subnatid3="148 - Mulobezi" if const==148
	replace subnatid3="149 - Mwandi" if const==149
	replace subnatid3="150 - Sesheke" if const==150
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
/* <_subnatidsurvey_note>

	Variable denoting lowest administrative info to which the survey is still significat.
	See entry in GLD Guidelines (https://github.com/worldbank/gld/blob/main/Support/A%20-%20Guides%20and%20Documentation/GLD_1.0_Guidelines.docx) for more details

</_subnatidsurvey_note> */
	gen     urban_1 = ""
	replace urban_1 = " - Urban" if urban==1
	replace urban_1 = " - Rural" if urban==0
	egen subnatidsurvey = concat(subnatid1 urban_1)
	label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>


*<_subnatid1_prev_>
/* <_subnatid1_prev_note>

	2011-11: Muchinga province formed from Chinsali, Isoka, Mafinga, Mpika, and Nakonde districts of Northern (former HASC code ZM.NO) and Chama district of Eastern 
	http://www.statoids.com/uzm.html

</_subnatid1_prev_note> */
	
	gen subnatid1_prev     = ""
	replace subnatid1_prev = "3 - Eastern" if prov == 6 & dist == 601
	replace subnatid1_prev = "7 - Northern" if prov == 6 & inrange(dist, 602, 606)
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
	gen hsize = hh_count
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	gen age = a3
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = a2
	recode male 2=0
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen relationharm = a4
	recode relationharm 4/9=5 10=4 11/15=5 16/17=6
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = a4
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital = a5
	recode marital 3=1 1=2 2=3 4/5=4 6=5
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	gen eye_dsablty = a6
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
	label values eye_dsablty dsablty
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty = a7
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values hear_dsablty dsablty
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty = a8
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values walk_dsablty dsablty
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord = a9
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values conc_dsord dsablty
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty  = a10
	label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all", replace
	label values slfcre_dsablty dsablty
	label var slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty = a11
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

/* <_ed_mod_age_note>

Education module is only asked to those XX and older.

</_ed_mod_age_note> */

	gen byte ed_mod_age = 5
	label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school=b2
	recode school 2=0
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	rename literacy literacy_1
	gen byte literacy = b1
	recode literacy 2=0
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
	
	* For those who never attended, no education
	replace educat7 = 1 if b2 == 2
	
	* Nursery is also no education 
	replace educat7 = 1 if b3 == 0
	
	* Primary incomplete is first 6 years of system
	replace educat7 = 2 if inrange(b3, 1, 6)
	
	* Primary complete at 7 years 
	replace educat7 = 3 if b3 == 7
	
	* Secondary incomplete years 8 and 9
	replace educat7 = 4 if inrange(b3, 8, 9)
	
	* Secondary complete years 10 to 12 plus those with A levels
	replace educat7 = 5 if inrange(b3, 10, 13)
	
	* Certificate is the in-between
	replace educat7 = 6 if inrange(b3, 14, 14)
	
	* University is Bachelor + Masters or higher
	replace educat7 = 7 if inrange(b3, 15, 16)
	
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
	gen educat_orig = b3
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
	gen vocational = b10
	recode vocational 2=0
	label de lblvocational 0 "No" 1 "Yes"
	label var vocational "Ever received vocational training"
*</_vocational_>

*<_vocational_type_>
	gen vocational_type = b11
	recode vocational_type (2/4 = 2) (5 = .)
	label de lblvocational_type 1 "Inside Enterprise" 2 "External"
	label values vocational_type lblvocational_type
	label var vocational_type "Type of vocational training"
*</_vocational_type_>

*<_vocational_length_l_>
	gen vocational_length_l = b12
	recode vocational_length_l 1=. 2=3 3=6 4=12 5=36
	label var vocational_length_l "Length of training in months, lower limit"
*</_vocational_length_l_>

*<_vocational_length_u_>
	gen vocational_length_u = b12
	recode vocational_length_u 1=2 2=5 3=11 4=35 5=.
	label var vocational_length_u "Length of training in months, upper limit"
*</_vocational_length_u_>

*<_vocational_field_orig_>
	gen str vocational_field_orig = ""
	replace  vocational_field_orig="1 -  General Agriculture " if b13==1
	replace  vocational_field_orig="2 -  Agriculture Engineering " if b13==2
	replace  vocational_field_orig="3 -  Fisheries Science " if b13==3
	replace  vocational_field_orig="4 -  Mushroom Growing " if b13==4
	replace  vocational_field_orig="5 -  Agro Forestry " if b13==5
	replace  vocational_field_orig="6 -  Forestry Management " if b13==6
	replace  vocational_field_orig="7 -  Agriculture Marketing " if b13==7
	replace  vocational_field_orig="8 -  Post Graduate Grain Management " if b13==8
	replace  vocational_field_orig="9 -  Agriculture Co-operative Management " if b13==9
	replace  vocational_field_orig="10 -  Agriculture Business Management " if b13==10
	replace  vocational_field_orig="11 -  Crop Science " if b13==11
	replace  vocational_field_orig="12 -  Animal Science " if b13==12
	replace  vocational_field_orig="15 -  Water Engineering " if b13==15
	replace  vocational_field_orig="16 -  Food and Nutrition " if b13==16
	replace  vocational_field_orig="17 -  Dairy Management " if b13==17
	replace  vocational_field_orig="19 -  Agriculture Journalism " if b13==19
	replace  vocational_field_orig="20 -  Poultry Farming " if b13==20
	replace  vocational_field_orig="21 -  Automotive  Engineering " if b13==21
	replace  vocational_field_orig="22 -  Auto Body Repair " if b13==22
	replace  vocational_field_orig="23 -  Motor Vehicle Engineering " if b13==23
	replace  vocational_field_orig="24 -  Auto Mechanics " if b13==24
	replace  vocational_field_orig="25 -  Heavy Duty Equipment Repair " if b13==25
	replace  vocational_field_orig="26 -  PVS Driver Training " if b13==26
	replace  vocational_field_orig="27 -  Automotive Electrical " if b13==27
	replace  vocational_field_orig="28 -  Motor Vehicle Care & Maintenance " if b13==28
	replace  vocational_field_orig="29 -  Telecommunications Operations " if b13==29
	replace  vocational_field_orig="30 -  Office Equipment  Repair " if b13==30
	replace  vocational_field_orig="31 -  Telecommunications and Electronics " if b13==31
	replace  vocational_field_orig="32 -  Electronics & Office Equipment Repa " if b13==32
	replace  vocational_field_orig="33 -  Aviation Security " if b13==33
	replace  vocational_field_orig="34 -  Aeronautical Information Services " if b13==34
	replace  vocational_field_orig="35 -  Private Pilot License " if b13==35
	replace  vocational_field_orig="37 -  Aeronautical Engeering " if b13==37
	replace  vocational_field_orig="38 -  Computer Short Course " if b13==38
	replace  vocational_field_orig="39 -  Short Courses " if b13==39
	replace  vocational_field_orig="40 -  Entrepreneurship " if b13==40
	replace  vocational_field_orig="41 -  Social Work " if b13==41
	replace  vocational_field_orig="42 -  Information Technology " if b13==42
	replace  vocational_field_orig="43 -  ZICA Technician " if b13==43
	replace  vocational_field_orig="44 -  Computer Studies " if b13==44
	replace  vocational_field_orig="45 -  Community Development " if b13==45
	replace  vocational_field_orig="46 -  Business Administration " if b13==46
	replace  vocational_field_orig="47 -  Sales & Marketing " if b13==47
	replace  vocational_field_orig="48 -  Economics " if b13==48
	replace  vocational_field_orig="49 -  IMIS " if b13==49
	replace  vocational_field_orig="50 -  Human Resources Mangement " if b13==50
	replace  vocational_field_orig="51 -  Project Management " if b13==51
	replace  vocational_field_orig="52 -  Clearing & Forwarding " if b13==52
	replace  vocational_field_orig="53 -  Chartered Institute of Purchasing & " if b13==53
	replace  vocational_field_orig="54 -  Tailoring and Designing " if b13==54
	replace  vocational_field_orig="55 -  Woodwork, Metalwork and Ceramics " if b13==55
	replace  vocational_field_orig="56 -  Brick laying & Construction " if b13==56
	replace  vocational_field_orig="57 -  Plumbing " if b13==57
	replace  vocational_field_orig="58 -  Catering & Housekeeping " if b13==58
	replace  vocational_field_orig="59 -  Carpentry " if b13==59
	replace  vocational_field_orig="60 -  Teaching " if b13==60
	replace  vocational_field_orig="61 -  Power Electrical " if b13==61
	replace  vocational_field_orig="62 -  Welding,/Metal fabricating " if b13==62
	replace  vocational_field_orig="63 -  Painting & Decorations " if b13==63
	replace  vocational_field_orig="64 -  Defence training " if b13==64
	replace  vocational_field_orig="65 -  Health/Nursing/pharmacy " if b13==65
	replace  vocational_field_orig="66 -  Banking/ financial management " if b13==66
	replace  vocational_field_orig="67 -  General machine operator " if b13==67
	replace  vocational_field_orig="68 -  General repairs " if b13==68
	replace  vocational_field_orig="69 -  Hair dressing " if b13==69
	replace  vocational_field_orig="70 -  General driver training " if b13==70
	replace  vocational_field_orig="99 -  Crafts/skills not classisfied elsew " if b13==99
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
	gen byte minlaborage =15
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>

/* <_lstatus_note>

The numbers from the report are based on the concept of employed, labour force we see in the derived variables.

It looks from reconstructing these, that they are not counting as employed those who are most of the time in the past week in school (see tab c1 employed if c3 == 1 & age > 14,m).

That is not the employment concept we work with, hence the numbers may disagree.

</_lstatus_note> */

	gen byte lstatus = .
	
	* Emplyed are those that are deemed to work by C1
	replace lstatus = 1 if inrange(c1, 1, 3)
	
	* Additionaly, since C1 is on most time, all those in C2
	replace lstatus = 1 if c2 == 1
	
	* Finally, those who did HH activities
	* ICLS change would be here, but no diff on % of market activity
	replace lstatus = 1 if c3 == 1
	
	* Unemployed are those who would be willing to accept a job and are loooking. Unfortunately, those who say yes to accepting a job or starting a business (g1) skip the question on looking.
	
	* Assume that those who would take on if available (passive) are looking.
	replace lstatus = 2 if g1==1

	* Remainder is NLF. Note that there are some small issues. We had 306 people who are not employed by the above definitions and g1 is missing (and are 15 or above). NLF by default, not by assertion.
	replace lstatus = 3 if missing(lstatus)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>

	* Potential LF are those who would not have started a job (g1 != 1) but have been looking (g3 == 1)
	gen byte potential_lf = 0 if lstatus == 3
	replace potential_lf = 1 if g3 == 1 & lstatus == 3
	replace potential_lf = . if age < minlaborage & age != .
	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen byte underemployment = .
	replace underemployment = . if age < minlaborage & age != .
	replace underemployment = . if lstatus != 1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason=.
	replace nlfreason = 1 if g5 == 4
	replace nlfreason = 2 if g5 == 5
	replace nlfreason = 3 if g5 == 13
	replace nlfreason = 4 if g5 == 8
	replace nlfreason = 5 if missing(nlfreason) & lstatus == 3 & !missing(g5)
	
	* There are 332 people who do not answer g5, leave missing
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l = .
	
	replace unempldur_l = 0  if lstatus == 2 & g7 == 1
	replace unempldur_l = 3  if lstatus == 2 & g7 == 2
	replace unempldur_l = 6  if lstatus == 2 & g7 == 3
	replace unempldur_l = 9  if lstatus == 2 & g7 == 4
	replace unempldur_l = 12 if lstatus == 2 & g7 == 5
	replace unempldur_l = 24 if lstatus == 2 & g7 == 6
	replace unempldur_l = 36  if lstatus == 2 & g7 == 7
	replace unempldur_l = 60  if lstatus == 2 & g7 == 8
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=.
	
	replace unempldur_u = 3  if lstatus == 2 & g7 == 1
	replace unempldur_u = 6  if lstatus == 2 & g7 == 2
	replace unempldur_u = 9  if lstatus == 2 & g7 == 3
	replace unempldur_u = 12 if lstatus == 2 & g7 == 4
	replace unempldur_u = 24 if lstatus == 2 & g7 == 5
	replace unempldur_u = 36 if lstatus == 2 & g7 == 6
	replace unempldur_u = 60 if lstatus == 2 & g7 == 7
	replace unempldur_u = .  if lstatus == 2 & g7 == 8
	
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte empstat=.
	* The data shared does not have variable D5, which is what we need.
	* Hope that in a new sharing effort it will be present.
	* What we do know from the questionnaire flow, is that people who answer section F
	* are employees (including apprentices), we can at least code those, leave rest missing
	replace empstat = 1 if !missing(fa1)
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	* Labelling in data different from questionnaire. 6 is embassy in data, private business in Qstnnaire
	gen byte ocusec = d14
	recode ocusec (1 2 6 = 1) (3 = 3) (4 5 7 8 = 2)
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig = d3_code
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	
	gen str industrycat_isic     = string(d3_code,     "%04.0f")
	replace industrycat_isic = "" if industrycat_isic == "."
	
	* From observation, only one error. Charcoal production as 0202 when is 0220
	replace industrycat_isic = "0220" if industrycat_isic == "0202"
	
	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	
	preserve 
	int_classif_universe, var(industrycat_isic) universe(ISIC)
	count
	assert `r(N)' == 0
	restore 

	replace industrycat_isic = "" if lstatus != 1
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	gen byte industrycat10 = .
	replace industrycat10=1 if inrange(industrycat_isic,"0100","0399")
	
	replace industrycat10=2 if inrange(industrycat_isic,"0500","0999")
	
	replace industrycat10=3 if inrange(industrycat_isic,"1000","3399")
	
	replace industrycat10=4 if inrange(industrycat_isic,"3500","3999")
	
	replace industrycat10=5 if inrange(industrycat_isic,"4100","4399")
	
	replace industrycat10=6 if inrange(industrycat_isic,"4500","4799")
	replace industrycat10=6 if inrange(industrycat_isic,"5500","5699")
	
	replace industrycat10=7 if inrange(industrycat_isic,"4900","5399")
	replace industrycat10=7 if inrange(industrycat_isic,"5800","6399")
	
	replace industrycat10=8 if inrange(industrycat_isic,"6400","8299")
	
	replace industrycat10=9 if inrange(industrycat_isic,"8400", "8499")
	
	replace industrycat10=10 if inrange(industrycat_isic,"8500","9999")
	
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
	
	* Ensure nothing left out
	replace industrycat10 = . if lstatus != 1
	count if !missing(industrycat_isic) & missing(industrycat10)
	assert `r(N)' == 0
*</_industrycat10_>


*<_industrycat4_>
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
	gen occup_orig = d2_code
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	gen str occup_isco = string(d2_code,     "%04.0f")
	replace occup_isco = "" if occup_isco == "."
	
	* From observation, only one error. Code 6311 (2 cases), assume it is 6310
	replace occup_isco = "6310" if occup_isco == "6311"
	
	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	
	preserve 
	int_classif_universe, var(occup_isco) universe(ISCO)
	count
	assert `r(N)' == 0
	restore 
	
	replace occup_isco = "" if lstatus != 1
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_>
	gen byte occup = .
	replace occup=1 if inrange(occup_isco,"1000","1499")
	replace occup=2 if inrange(occup_isco,"2000","2699")
	replace occup=3 if inrange(occup_isco,"3000","3599")
	replace occup=4 if inrange(occup_isco,"4000","4499")
	replace occup=5 if inrange(occup_isco,"5000","5499")
	replace occup=6 if inrange(occup_isco,"6000","6399")
	replace occup=7 if inrange(occup_isco,"7000","7599")
	replace occup=8 if inrange(occup_isco,"8000","8399")
	replace occup=9 if inrange(occup_isco,"9000","9699")
	replace occup=10 if inrange(occup_isco,"0000","0999")
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
	
	* Ensure nothing left out
	replace occup = . if lstatus != 1
	count if !missing(occup_isco) & missing(occup)
	assert `r(N)' == 0
*</_occup_>


*<_occup_skill_>
	gen occup_skill = .
	replace occup_skill = 3 if inrange(occup, 1, 3)
	replace occup_skill = 2 if inrange(occup, 4, 8)
	replace occup_skill = 1 if occup == 9
	replace occup_skill = . if lstatus != 1
	la de lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lblskill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_wage_no_compen_>

/* <_wage_no_compen_note>

	Wage is asked twice for employees, all should answer fa5, some fa4, however, there are, of 4511 answers 164
	who answer only fa4. 
	
	Add those in at second stage to not lose it even if tiny bit different as fa5 is wage after 
	deducting taxes, contributions. Also fa5 is asking for monthly for all, fa4 is on the time
	defined in fa1.
	
	Then employers and self employed are asked, depending on whether agriculture or not.
	If agriculture it is fb13 net sales income in the last 12 months, otherwise it is net income
	in the last month (fb6b)

	</_wage_no_compen_note> */

	* Create var
	gen double wage_no_compen = .
	
	* Add in monthly info from fa5b
	replace wage_no_compen = fa5b 
	
	* Add in people from fa4b for which we have unit info (fa1 code 5 is "other")
	replace wage_no_compen = fa4b if missing(fa5b) & !missing(fa4b) & inrange(fa1, 2, 4)
	
	* Add in business income from other than agriculture 
	replace wage_no_compen = fb6b if missing(wage_no_compen)
	
	* Add in business income from agriculture 
	replace wage_no_compen = fb13/12 if missing(wage_no_compen)
	
	replace wage_no_compen = . if lstatus != 1
	replace wage_no_compen = . if wage_no_compen <= 0
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>

/* <_unitwage_note>
	All info is monthly except for people from fa4b (very few)
</_unitwage_note> */

	gen byte unitwage = .
	replace unitwage = 5 if !missing(wage_no_compen)
	
	replace unitwage = 3 if missing(fa5b) & !missing(fa4b) & fa1 == 2
	replace unitwage = 2 if missing(fa5b) & !missing(fa4b) & fa1 == 3
	replace unitwage = 1 if missing(fa5b) & !missing(fa4b) & fa1 == 4

	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>

	* Info is days in the job in the week (e1a: 0-7) then hours per day (e2a: 0-24)
	gen whours=.
	replace whours = e1a * e2a
	replace whours = . if whours == 0
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
	gen byte contract = d12
	recode contract 2=0 9=.
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
	* Variable d6 not present in shared data
	gen byte socialsec = .
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec 1 "With social security" 0 "Without social secturity"
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen byte union = d10
	recode union 2=0 -9 9=.
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	* Note: Firmsize not asked of private sector workers only
	gen firmsize_l = d16
	recode firmsize_l 1=1 2=5 3=25 9=.
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen firmsize_u= d16
	recode firmsize_u 1=4 2=24 3=. 9=.
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


*<_occup_2_>
	gen byte occup_2 = .
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
	gen byte unitwage_2 = 5
	label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>

	* Info is days in the job in the week (e1a: 0-7) then hours per day (e2a: 0-24)
	gen whours_2 = .
	replace whours_2 = e1b * e2b
	replace whours_2 = . if whours_2 == 0
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

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

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
