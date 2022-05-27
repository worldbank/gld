
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				[EGY_2007_LFS_V01_M_V01_A_GLD_ALL.do] </_Program name_>
<_Application_>					[STATA 16] <_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2022-04-08 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						[Egypt (EGY)] </_Country_>
<_Survey Title_>				[Labour Force Survey] </_Survey Title_>
<_Survey Year_>					[2007] </_Survey Year_>
<_Study ID_>					[Economic Research Forum ] </_Study ID_>
<_Data collection from_>			[01/2007] </_Data collection from_>
<_Data collection to_>				[12/2007] </_Data collection to_>
<_Source of dataset_> 				[Central Agency for Public Mobilization and Statistics (CAPMAS)Central Agency for Public Mobilization and Statistics (CAPMAS)] </_Source of dataset_>
<_Sample size (HH)_> 			77,215	 </_Sample size (HH)_>
<_Sample size (IND)_> 		 331,005 </_Sample size (IND)_>
<_Sampling method_> 				[systematic random sample.] </_Sampling method_>
<_Geographic coverage_> 		regional 	[To what level is data significant] </_Geographic coverage_>
<_Currency_> 					[Egyptian pound] </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS 13 </_ICLS Version_>
<_ISCED Version_>				ISCED 1997 </_ISCED Version_>
<_ISCO Version_>			ISCO 1988 </_ISCO Version_>
<_OCCUP National_>				N/A </_OCCUP National_>
<_ISIC Version_>				ISIC REV 3 </_ISIC Version_>
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

local path_in "Z:\GLD-Harmonization\582018_AQ\EGY\EGY_2007_LFS\EGY_2007_LFS_v01_M\Data\Stata"

local path_output "Z:\GLD-Harmonization\582018_AQ\EGY\EGY_2007_LFS\EGY_2007_LFS_v01_M_v01_A_GLD\Data\Harmonized"

*----------1.3: Database assembly------------------------------*

* All steps necessary to merge datasets (if several) to have all elements needed to produce
* harmonized output in a single file

*Use household file as a base
use "`path_in'\Egypt 2007-LFS HH-V1.dta"

*Merge to individual file
merge 1:m caseser using "`path_in'\Egypt 2007-LFS IND-V1.dta"
drop _merge



/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode = "EGY"
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
	gen icls_v = "ICLS-[13]"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>


*<_isced_version_>
	gen isced_version = "isced_1997"
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
	gen isco_version = "isco_1988"
	label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
	gen isic_version = "isic_3"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	*gen int year = .
	label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen str3 vermast = "V01"
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
	gen int_year=year
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
	tostring caseser, gen(hhid) format(%05.0f)
	label var hhid "Household ID"
*</_hhid_>


*<_pid_>
	tostring pnum, gen(pid_helper) format(%01.0f)
	egen pid=concat(hhid pid_helper)
	label var pid "Individual ID"
	isid hhid pid
*</_pid_>


*<_weight_>
	gen weight = pweight
	label var weight "Survey sampling weight"
*</_weight_>


*<_psu_>
	gen psu = psunum
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
	gen wave = round
	label var wave "Survey wave"
*</_wave_>

}


/*%%=============================================================================================
	3: Geography
==============================================================================================%%*/

{

*<_urban_>
	gen byte urban =rururb
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
/* <_subnatid1_note>

	The variable is string and country-specific categorical. Numeric entries are coded in string format using the following naming convention: “1 – Hatay”. That is, the variable itself is to be string, not a labelled numeric vector.

	Example of entries would be "1 - Alaska",  "2 - Arkansas", ...

</_subnatid1_note> */
	gen subnatid1 = reg
	tostring subnatid1, replace force
	replace subnatid1="1 - Cairo"  if subnatid1=="818001"
	replace subnatid1="2 - Alexandria" if subnatid1=="818002"
	replace subnatid1="3 - Port Said" if subnatid1=="818003"
	replace subnatid1="4 - Suez" if subnatid1=="818004"
	replace subnatid1="5 - Damietta" if subnatid1=="818011"
	replace subnatid1="6 - Dakahlia" if subnatid1=="818012"
	replace subnatid1="7 - Sharkia" if subnatid1=="818013"
	replace subnatid1="8 - Kalyoubia" if subnatid1=="818014"
	replace subnatid1="9 - Kafr-El- sheik" if subnatid1=="818015"
	replace subnatid1="10 - Gharbia" if subnatid1=="818016"
	replace subnatid1="11 - Menoufia" if subnatid1=="818017"
	replace subnatid1="12 - Behira" if subnatid1=="818018"
	replace subnatid1="13 - Ismaelia" if subnatid1=="818019"
	replace subnatid1="14 - Giza" if subnatid1=="818021"
	replace subnatid1="15 - Beni- Suef" if subnatid1=="818022"
	replace subnatid1="16 - Fayoum" if subnatid1=="818023"
	replace subnatid1="17 - Menia" if subnatid1=="818024"
	replace subnatid1="18 - Asyout" if subnatid1=="818025"
	replace subnatid1="19 - Suhag" if subnatid1=="818026"
	replace subnatid1="20 - Qena" if subnatid1=="818027"
	replace subnatid1="21 - Aswan" if subnatid1=="818028"
	replace subnatid1="22 - Luxor" if subnatid1=="818029"
	replace subnatid1="23 - Red Sea" if subnatid1=="818031"
	replace subnatid1="24 - El-wadi El-Gidid" if subnatid1=="818032"
	replace subnatid1="25 - Matrouh" if subnatid1=="818033"
	replace subnatid1="26 - North Sinai" if subnatid1=="818034"
	replace subnatid1="27 - South Sinai" if subnatid1=="818035"
	/*label define lblsubnatid1 818001 "1 - Cairo"  818002 "2 - Alexandria"  818003 "3 - Port Said" 818004 "4 - Suez" 818011"5 - Damietta" 818012 "6 - Dakahlia" 818013 "7 - Sharkia" 818014 "8 - Kalyoubia" 818015 "9 - Kafr-El- sheik" 818016 "10 - Gharbia" 818017 "11 - Menoufia" 818018 "12 - Behira" 818019 "13 - Ismaelia" 818021 "14 - Giza" 818022 "15 - Beni- Suef" 818023 "16 - Fayoum" 818024 "17 - Menia" 818025 "18 - Asyout" 818026 "19 - Suhag" 818027 "20 - Qena" 818028 "21 - Aswan" 818029 "22 - Luxor" 818031 "23 - Red Sea" 818032 "24 - El-wadi El-Gidid" 818033 "25 - Matrouh" 818034 "26 - North Sinai" 818035 "27 - South Sinai"*/
	/*label values subnatid1 lblsubnatid1*/
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	gen subnatid2 = area
	tostring subnatid2, replace force
	replace	subnatid2="1-El Tebein"	if subnatid2=="8180101"
	replace	subnatid2="2-Helwan"	if subnatid2=="8180102"
	replace	subnatid2="3-15 of May"	if subnatid2=="8180103"
	replace	subnatid2="4-EL Maadi"	if subnatid2=="8180104"
	replace	subnatid2="5-Masr El Kadima"	if subnatid2=="8180106"
	replace	subnatid2="6-Al Sayeda Zeinab"	if subnatid2=="8180107"
	replace	subnatid2="7-El Khalifa"	if subnatid2=="8180108"
	replace	subnatid2="8-Abdeen"	if subnatid2=="8180109"
	replace	subnatid2="9-Bolaq"	if subnatid2=="8180112"
	replace	subnatid2="10-Darb al-Ahmar"	if subnatid2=="8180114"
	replace	subnatid2="11-El-Gamaleya"	if subnatid2=="8180115"
	replace	subnatid2="12-Bab Al-Sharia"	if subnatid2=="8180116"
	replace	subnatid2="13-El Sharabia"	if subnatid2=="8180118"
	replace	subnatid2="14-Shubra"	if subnatid2=="8180119"
	replace	subnatid2="15-Rod El Farag"	if subnatid2=="8180120"
	replace	subnatid2="16-El sahel"	if subnatid2=="8180121"
	replace	subnatid2="17-El waly"	if subnatid2=="8180122"
	replace	subnatid2="18-Hadayek El Kobba"	if subnatid2=="8180123"
	replace	subnatid2="19-El Zaton"	if subnatid2=="8180124"
	replace	subnatid2="20-El Mataria"	if subnatid2=="8180125"
	replace	subnatid2="21-Madinet nasr"	if subnatid2=="8180126"
	replace	subnatid2="22-Tani madinet nasr"	if subnatid2=="8180127"
	replace	subnatid2="23-Masr El Gedida"	if subnatid2=="8180128"
	replace	subnatid2="24-El Nozha"	if subnatid2=="8180129"
	replace	subnatid2="25-Ain Shams"	if subnatid2=="8180130"
	replace	subnatid2="26-El Zawya El Hamra"	if subnatid2=="8180131"
	replace	subnatid2="27-El salam"	if subnatid2=="8180132"
	replace	subnatid2="28-El zamalek"	if subnatid2=="8180133"
	replace	subnatid2="29-Manshiyat Naser"	if subnatid2=="8180134"
	replace	subnatid2="30-El Basteen"	if subnatid2=="8180135"
	replace	subnatid2="31-El-Marg"	if subnatid2=="8180136"
	replace	subnatid2="32-El Montaza"	if subnatid2=="8180201"
	replace	subnatid2="33-Awel El Ramel"	if subnatid2=="8180202"
	replace	subnatid2="34-Sidi Gaber"	if subnatid2=="8180203"
	replace	subnatid2="35-Bab Sharq"	if subnatid2=="8180204"
	replace	subnatid2="36-Moharam Bek"	if subnatid2=="8180205"
	replace	subnatid2="37-El Attareen"	if subnatid2=="8180206"
	replace	subnatid2="38-El Mansheya"	if subnatid2=="8180207"
	replace	subnatid2="39-Karmoz"	if subnatid2=="8180208"
	replace	subnatid2="40-El Laban"	if subnatid2=="8180209"
	replace	subnatid2="41-Mena El Basal"	if subnatid2=="8180211"
	replace	subnatid2="42-El Dekhela"	if subnatid2=="8180212"
	replace	subnatid2="43-El Ameriya"	if subnatid2=="8180213"
	replace	subnatid2="44-New Borg El Arab City"	if subnatid2=="8180216"
	replace	subnatid2="45-Tani El Ramel"	if subnatid2=="8180217"
	replace	subnatid2="46-El-Sharq"	if subnatid2=="8180301"
	replace	subnatid2="47-El-Arab"	if subnatid2=="8180302"
	replace	subnatid2="48-El-Manakh"	if subnatid2=="8180303"
	replace	subnatid2="49-Port Fuad"	if subnatid2=="8180304"
	replace	subnatid2="50-El-Ganoub"	if subnatid2=="8180306"
	replace	subnatid2="51-El-Zohour"	if subnatid2=="8180307"
	replace	subnatid2="52-Suez"	if subnatid2=="8180401"
	replace	subnatid2="53-Arbaeen"	if subnatid2=="8180402"
	replace	subnatid2="54-Faisal"	if subnatid2=="8180404"
	replace	subnatid2="55-Ganayen"	if subnatid2=="8180405"
	replace	subnatid2="56-Markaz Dumyat"	if subnatid2=="8181102"
	replace	subnatid2="57-Farskor"	if subnatid2=="8181103"
	replace	subnatid2="58-Kafr Saad"	if subnatid2=="8181104"
	replace	subnatid2="59-New Dumyat City"	if subnatid2=="8181105"
	replace	subnatid2="60-El-Zarqa"	if subnatid2=="8181107"
	replace	subnatid2="61-Qism Awel El Mansoura"	if subnatid2=="8181201"
	replace	subnatid2="62-Qism Tani El Mansoura"	if subnatid2=="8181202"
	replace	subnatid2="63-Markaz El Mansoura"	if subnatid2=="8181203"
	replace	subnatid2="64-Aga"	if subnatid2=="8181204"
	replace	subnatid2="65-El Senbellawein"	if subnatid2=="8181205"
	replace	subnatid2="66-El Matareya"	if subnatid2=="8181206"
	replace	subnatid2="67-Manzala"	if subnatid2=="8181207"
	replace	subnatid2="68-Bilqas"	if subnatid2=="8181208"
	replace	subnatid2="69-Dikirnis"	if subnatid2=="8181209"
	replace	subnatid2="70-Sherbin"	if subnatid2=="8181210"
	replace	subnatid2="71-Talkha"	if subnatid2=="8181211"
	replace	subnatid2="72-Qism Mit Ghamr"	if subnatid2=="8181212"
	replace	subnatid2="73-Markaz Mit Ghamr"	if subnatid2=="8181213"
	replace	subnatid2="74-Menyet El-Nasr"	if subnatid2=="8181214"
	replace	subnatid2="75-El-Gammaliyyah"	if subnatid2=="8181215"
	replace	subnatid2="76-Temay Alamded"	if subnatid2=="8181216"
	replace	subnatid2="77-Mit Salsil"	if subnatid2=="8181217"
	replace	subnatid2="78-Beni Obeid"	if subnatid2=="8181218"
	replace	subnatid2="79-Mahalet Dimna"	if subnatid2=="8181219"
	replace	subnatid2="80-Nabaroh"	if subnatid2=="8181221"
	replace	subnatid2="81-Qism Awel Zagazig"	if subnatid2=="8181301"
	replace	subnatid2="82-Qism Tani Zagazig"	if subnatid2=="8181302"
	replace	subnatid2="83-Markaz El Zagazig"	if subnatid2=="8181303"
	replace	subnatid2="84-Abu Hammad"	if subnatid2=="8181304"
	replace	subnatid2="85-Abu Kabeer"	if subnatid2=="8181305"
	replace	subnatid2="86-Markaz El-Hosayneya"	if subnatid2=="8181306"
	replace	subnatid2="87-Bilbeis"	if subnatid2=="8181308"
	replace	subnatid2="88-Qism Awel 10th of Ramadan City"	if subnatid2=="8181309"
	replace	subnatid2="89-Diarb Negm"	if subnatid2=="8181310"
	replace	subnatid2="90-Qism Faqous"	if subnatid2=="8181311"
	replace	subnatid2="91-Markaz Faqous"	if subnatid2=="8181312"
	replace	subnatid2="92-Kafr Saqr"	if subnatid2=="8181313"
	replace	subnatid2="93-Minya Al Qamh"	if subnatid2=="8181314"
	replace	subnatid2="94-Hihya"	if subnatid2=="8181315"
	replace	subnatid2="95-Markaz Mashtoul as Souq"	if subnatid2=="8181316"
	replace	subnatid2="96-Al Ibrahimiah"	if subnatid2=="8181317"
	replace	subnatid2="97-Markaz Awlad Saqr"	if subnatid2=="8181319"
	replace	subnatid2="98-Al Qurayn"	if subnatid2=="8181320"
	replace	subnatid2="99-Qism Banha"	if subnatid2=="8181401"
	replace	subnatid2="100-Markaz Banha"	if subnatid2=="8181402"
	replace	subnatid2="101-El Khanka"	if subnatid2=="8181403"
	replace	subnatid2="102-El Qanater El Khayreyya"	if subnatid2=="8181404"
	replace	subnatid2="103-Shibin Al-Qanater"	if subnatid2=="8181405"
	replace	subnatid2="104-Qism Awel Shubra El-Kheima"	if subnatid2=="8181406"
	replace	subnatid2="105-Qism Tani Shubra El-Kheima"	if subnatid2=="8181407"
	replace	subnatid2="106-Tukh"	if subnatid2=="8181408"
	replace	subnatid2="107-Qism Qalyub"	if subnatid2=="8181409"
	replace	subnatid2="108-Markaz Qalyub"	if subnatid2=="8181410"
	replace	subnatid2="109-Kafr Shukr"	if subnatid2=="8181411"
	replace	subnatid2="110-El Khosous"	if subnatid2=="8181412"
	replace	subnatid2="111-Qism Kafr El Sheik"	if subnatid2=="8181501"
	replace	subnatid2="112-Markaz Kafr El Sheik"	if subnatid2=="8181502"
	replace	subnatid2="113-Markaz El Burlos"	if subnatid2=="8181503"
	replace	subnatid2="114-Markaz Beila"	if subnatid2=="8181504"
	replace	subnatid2="115-Qism Desouk"	if subnatid2=="8181505"
	replace	subnatid2="116-Markaz Desouk"	if subnatid2=="8181506"
	replace	subnatid2="117-Sidi Salem"	if subnatid2=="8181507"
	replace	subnatid2="118-Fuwa"	if subnatid2=="8181508"
	replace	subnatid2="119-Qallin"	if subnatid2=="8181509"
	replace	subnatid2="120-Metoubes"	if subnatid2=="8181510"
	replace	subnatid2="121-Al Hamool"	if subnatid2=="8181511"
	replace	subnatid2="122-El Riyad"	if subnatid2=="8181512"
	replace	subnatid2="123-Qism Awel Tanta"	if subnatid2=="8181601"
	replace	subnatid2="124-Qism Tani Tanta"	if subnatid2=="8181602"
	replace	subnatid2="125-Markaz Tanta"	if subnatid2=="8181603"
	replace	subnatid2="126-El-Santa"	if subnatid2=="8181604"
	replace	subnatid2="127-Qism Awel El-Mahalla El-Kubra"	if subnatid2=="8181605"
	replace	subnatid2="128-Qism Tani El-Mahalla El-Kubra"	if subnatid2=="8181606"
	replace	subnatid2="129-Markaz El-Mahalla El-Kubra"	if subnatid2=="8181607"
	replace	subnatid2="130-Bassyoun"	if subnatid2=="8181608"
	replace	subnatid2="131-Zifta"	if subnatid2=="8181609"
	replace	subnatid2="132-Samannoud"	if subnatid2=="8181610"
	replace	subnatid2="133-Kotoor"	if subnatid2=="8181611"
	replace	subnatid2="134-Kafr El-Zayat"	if subnatid2=="8181612"
	replace	subnatid2="135-Qism Shibin El-Kawm"	if subnatid2=="8181701"
	replace	subnatid2="136-Markaz Shibin El-Kawm"	if subnatid2=="8181702"
	replace	subnatid2="137-Ashmoun"	if subnatid2=="8181703"
	replace	subnatid2="138-Bagour"	if subnatid2=="8181704"
	replace	subnatid2="139-Al-Shohada"	if subnatid2=="8181705"
	replace	subnatid2="140-Berket El-Sabaa"	if subnatid2=="8181706"
	replace	subnatid2="141-Tala"	if subnatid2=="8181707"
	replace	subnatid2="142-Quesna"	if subnatid2=="8181708"
	replace	subnatid2="143-Markaz Menouf"	if subnatid2=="8181709"
	replace	subnatid2="144-Sers El-Lyan"	if subnatid2=="8181710"
	replace	subnatid2="145-Qism Damanhur"	if subnatid2=="8181801"
	replace	subnatid2="146-Markaz Damanhur"	if subnatid2=="8181802"
	replace	subnatid2="147-Abou El Matamer"	if subnatid2=="8181803"
	replace	subnatid2="148-Abu Hummus"	if subnatid2=="8181804"
	replace	subnatid2="149-El Delengat"	if subnatid2=="8181805"
	replace	subnatid2="150-El Mahmoudiyah"	if subnatid2=="8181806"
	replace	subnatid2="151-Etay El Barud"	if subnatid2=="8181807"
	replace	subnatid2="152-Hosh Issa"	if subnatid2=="8181808"
	replace	subnatid2="153-Rashid"	if subnatid2=="8181809"
	replace	subnatid2="154-Shubrakhit"	if subnatid2=="8181810"
	replace	subnatid2="155-Qism Kafr El-Dawwar"	if subnatid2=="8181811"
	replace	subnatid2="156-Markaz Kafr El-Dawwar"	if subnatid2=="8181812"
	replace	subnatid2="157-Kom Hamada"	if subnatid2=="8181813"
	replace	subnatid2="158-Rahmaniya"	if subnatid2=="8181815"
	replace	subnatid2="159-Edko"	if subnatid2=="8181816"
	replace	subnatid2="160-Badr"	if subnatid2=="8181818"
	replace	subnatid2="161-Qism Awel Ismaelia"	if subnatid2=="8181901"
	replace	subnatid2="162-Qism Tani Ismaelia"	if subnatid2=="8181902"
	replace	subnatid2="163-Qism Talet Ismaelia"	if subnatid2=="8181903"
	replace	subnatid2="164-Markaz Talet Ismaelia"	if subnatid2=="8181904"
	replace	subnatid2="165-Tel-El-Kebir"	if subnatid2=="8181905"
	replace	subnatid2="166-El Qantara Gharb"	if subnatid2=="8181906"
	replace	subnatid2="167-Fayed"	if subnatid2=="8181907"
	replace	subnatid2="168-Qism Imbabah"	if subnatid2=="8182101"
	replace	subnatid2="169-Agouza"	if subnatid2=="8182102"
	replace	subnatid2="170-Dokki"	if subnatid2=="8182103"
	replace	subnatid2="171-Qism El Giza"	if subnatid2=="8182104"
	replace	subnatid2="172-Bulaq ad Dakrur"	if subnatid2=="8182105"
	replace	subnatid2="173-El Aharam"	if subnatid2=="8182106"
	replace	subnatid2="174-El Hawamdia"	if subnatid2=="8182108"
	replace	subnatid2="175-Markaz El Giza"	if subnatid2=="8182109"
	replace	subnatid2="176-El Badrashen"	if subnatid2=="8182110"
	replace	subnatid2="177-El Saf"	if subnatid2=="8182111"
	replace	subnatid2="178-El Ayat"	if subnatid2=="8182112"
	replace	subnatid2="179-Embaba"	if subnatid2=="8182113"
	replace	subnatid2="180-Etfeih"	if subnatid2=="8182115"
	replace	subnatid2="181-Oseim"	if subnatid2=="8182116"
	replace	subnatid2="182-El Warak"	if subnatid2=="8182117"
	replace	subnatid2="183-Omrania"	if subnatid2=="8182118"
	replace	subnatid2="184-Kerdasa"	if subnatid2=="8182120"
	replace	subnatid2="185-Qism Beni suef"	if subnatid2=="8182201"
	replace	subnatid2="186-Markaz Beni suef"	if subnatid2=="8182202"
	replace	subnatid2="187-El fashn"	if subnatid2=="8182204"
	replace	subnatid2="188-El Wasta"	if subnatid2=="8182205"
	replace	subnatid2="189-Ihnasiya"	if subnatid2=="8182206"
	replace	subnatid2="190-Bpa"	if subnatid2=="8182207"
	replace	subnatid2="191-Smsta"	if subnatid2=="8182208"
	replace	subnatid2="192-Nasser"	if subnatid2=="8182209"
	replace	subnatid2="193-Qism Fayoum"	if subnatid2=="8182301"
	replace	subnatid2="194-Markaz Fayoum"	if subnatid2=="8182302"
	replace	subnatid2="195-Ibsheway"	if subnatid2=="8182303"
	replace	subnatid2="196-Atsa"	if subnatid2=="8182304"
	replace	subnatid2="197-Snores"	if subnatid2=="8182305"
	replace	subnatid2="198-Tamiya"	if subnatid2=="8182306"
	replace	subnatid2="199-Youssef El Seddik"	if subnatid2=="8182307"
	replace	subnatid2="200-Qism El Minya"	if subnatid2=="8182401"
	replace	subnatid2="201-Markaz El Minya"	if subnatid2=="8182402"
	replace	subnatid2="202-Abu Qirqas"	if subnatid2=="8182404"
	replace	subnatid2="203-El Idwa"	if subnatid2=="8182405"
	replace	subnatid2="204-Beni Mazar"	if subnatid2=="8182406"
	replace	subnatid2="205-Deir Mawas"	if subnatid2=="8182407"
	replace	subnatid2="206-Samalut"	if subnatid2=="8182408"
	replace	subnatid2="207-Matai"	if subnatid2=="8182409"
	replace	subnatid2="208-Maghagha"	if subnatid2=="8182410"
	replace	subnatid2="209-Qism Mallawi"	if subnatid2=="8182411"
	replace	subnatid2="210-Markaz Mallawi"	if subnatid2=="8182412"
	replace	subnatid2="211-Qism Awel Asyut"	if subnatid2=="8182501"
	replace	subnatid2="212-Qism Tani Asyut"	if subnatid2=="8182502"
	replace	subnatid2="213-Markaz Asyut"	if subnatid2=="8182503"
	replace	subnatid2="214-Abnub"	if subnatid2=="8182504"
	replace	subnatid2="215-Markaz Abutig"	if subnatid2=="8182505"
	replace	subnatid2="216-El Badari"	if subnatid2=="8182506"
	replace	subnatid2="217-Sahel Selim"	if subnatid2=="8182507"
	replace	subnatid2="218-El Ghanayem"	if subnatid2=="8182508"
	replace	subnatid2="219-El Quseyya"	if subnatid2=="8182509"
	replace	subnatid2="220-Dairut"	if subnatid2=="8182510"
	replace	subnatid2="221-Manfalut"	if subnatid2=="8182512"
	replace	subnatid2="222-El Fateh"	if subnatid2=="8182513"
	replace	subnatid2="223-Qism Awel Sohag"	if subnatid2=="8182601"
	replace	subnatid2="224-Qism Tani Sohag"	if subnatid2=="8182602"
	replace	subnatid2="225-Markaz Sohag"	if subnatid2=="8182603"
	replace	subnatid2="226-Markaz Akhmim"	if subnatid2=="8182604"
	replace	subnatid2="227-El-Balyana"	if subnatid2=="8182605"
	replace	subnatid2="228-El-Maragha"	if subnatid2=="8182606"
	replace	subnatid2="229-El Minshah"	if subnatid2=="8182607"
	replace	subnatid2="230-Dar el-Salam"	if subnatid2=="8182608"
	replace	subnatid2="231-Qism Girga"	if subnatid2=="8182609"
	replace	subnatid2="232-Markaz Girga"	if subnatid2=="8182610"
	replace	subnatid2="233-Juhaynah El Gharbyah"	if subnatid2=="8182611"
	replace	subnatid2="234-Sakulta"	if subnatid2=="8182612"
	replace	subnatid2="235-Tima"	if subnatid2=="8182613"
	replace	subnatid2="236-Markaz Tahta"	if subnatid2=="8182614"
	replace	subnatid2="237-Qism Tahta"	if subnatid2=="8182615"
	replace	subnatid2="238-El-Usayrat"	if subnatid2=="8182617"
	replace	subnatid2="239-Qism Qena"	if subnatid2=="8182701"
	replace	subnatid2="240-Markaz Qena"	if subnatid2=="8182702"
	replace	subnatid2="241-Abu Tesht"	if subnatid2=="8182703"
	replace	subnatid2="242-Armant"	if subnatid2=="8182704"
	replace	subnatid2="243-Esna"	if subnatid2=="8182705"
	replace	subnatid2="244-Dishna"	if subnatid2=="8182706"
	replace	subnatid2="245-Qus"	if subnatid2=="8182707"
	replace	subnatid2="246-Nag Hammadi"	if subnatid2=="8182708"
	replace	subnatid2="247-Naqada"	if subnatid2=="8182709"
	replace	subnatid2="248-Farshout"	if subnatid2=="8182710"
	replace	subnatid2="249-Qift"	if subnatid2=="8182711"
	replace	subnatid2="250-El Waqf"	if subnatid2=="8182712"
	replace	subnatid2="251-Qism Aswan"	if subnatid2=="8182801"
	replace	subnatid2="252-Markaz Aswan"	if subnatid2=="8182802"
	replace	subnatid2="253-Edfu"	if subnatid2=="8182803"
	replace	subnatid2="254-Kom Ombo"	if subnatid2=="8182804"
	replace	subnatid2="255-Nasr"	if subnatid2=="8182805"
	replace	subnatid2="256-Deraw"	if subnatid2=="8182806"
	replace	subnatid2="257-Qism Luxor"	if subnatid2=="8182901"
	replace	subnatid2="258-Markaz Luxor"	if subnatid2=="8182902"
	replace	subnatid2="259-Qism Awel Hurghada"	if subnatid2=="8183101"
	replace	subnatid2="260-Kharga"	if subnatid2=="8183201"
	replace	subnatid2="261-Paris"	if subnatid2=="8183204"
	replace	subnatid2="262-Mersa Matruh"	if subnatid2=="8183301"
	replace	subnatid2="263-El Hamam"	if subnatid2=="8183302"
	replace	subnatid2="264-Qism Tani  El Arish"	if subnatid2=="8183402"
	replace	subnatid2="265-Qism Talet  El Arish"	if subnatid2=="8183403"
	replace	subnatid2="266-Bir el Abd"	if subnatid2=="8183405"
	replace	subnatid2="267-Rafah"	if subnatid2=="8183409"
	replace	subnatid2="268-El-Tor"	if subnatid2=="8183501"
	replace	subnatid2="269-Ras Sedr"	if subnatid2=="8183502"
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
	gen hsize = tpnum
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	*gen age = age
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = sex
	recode male 2=0
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen relationharm = rel
	recode relationharm (5 6 7=5) (8=6)
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = rel
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital = mart
	recode marital (2 3=1) (1=2)
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
	gen migrated_binary = immigr
	recode migrated_binary (1 2=1) (3=0)
	label de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated"
*</_migrated_binary_>


*<_migrated_years_>
	gen migrated_years = (2007-curresd_y)
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
	label de lblmigrated_from_code 1 ""
	label values migrated_from_code lblmigrated_from_code
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country = .
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason = curresd_r
	recode migrated_reason 10=3 20=2 30=1 40=1 50=1 90=5 999=.
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

	gen byte ed_mod_age = 6
	label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school=attsch
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>


*<_literacy_>
	gen byte literacy = lit
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


*<_educy_>
	gen byte educy =yeduc
	replace educy=. if age < educy & (age != . & educy != .)
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	gen  educat7=educ_d
	label var educat7 "Level of education 1"
	*assuming that read and write is incomplete primary
	recode educat7 110=1 130=2 210=3  220=4 310=5 320=5 400=6 500=7 600=7 999=.
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
	gen educat_orig = educ_d
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
==============================================================================================%%*/


*<_minlaborage_>
*15 to 64
	gen byte minlaborage =15
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
	gen byte lstatus = .
	replace lstatus=1 if mas==1
	replace lstatus=2 if mas==2
	replace lstatus=3 if lfs==2
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = .
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
	gen byte nlfreason=.
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
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
	gen byte empstat=emps
	recode empstat 2=3 3=4 4=2 99=.
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec = sector
	recode ocusec (2=3) (3=2) (5=.) (6=.) (99=.)
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig = ind_unrec
	tostring industry_orig, replace
	replace industry_orig="" if ind_unrec==.
	replace industry_orig="" if ind_unrec==0
	replace industry_orig="" if ind_unrec==11
	replace industry_orig="" if lstatus!=1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	gen ind_helper=ind_unrec
	recode ind_helper 11=. 0=.
	gen industrycat_isic= string(ind_helper,"%04.0f")
	replace industrycat_isic = "" if industrycat_isic =="."
	replace industrycat_isic = "3610" if inlist(industrycat_isic, "3611", "3612")
	replace industrycat_isic = "3699" if inlist(industrycat_isic, "3811", "3813","3814","3819")
	replace industrycat_isic = "1550" if inlist(industrycat_isic, "1555")
	replace industrycat_isic = "1720" if inlist(industrycat_isic, "1724")
	replace industrycat_isic = "5260" if inlist(industrycat_isic, "5261", "5262","5263", "5264", "5269")
	replace industrycat_isic = "9300" if inlist(industrycat_isic, "9999")
	replace industrycat_isic = "9300" if inlist(industrycat_isic, "9998")
	drop ind_helper
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
*education and health put in other (10) because there is no correspondance (public or private?) rental was put in other business services 8
	gen industrycat10=substr(industrycat_isic, 1,2)
	destring industrycat10, replace force
	recode industrycat10 2=1 5=1 10/14=2 15/37=3 40/41=4 45=5 50/52=6 60/64=7 65/67=8 74=8 75=9 90/93=9 95/99=10 80/85=10 70/73=8 55=6 38=3
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
	gen occup_orig = string(occ_unrec)
	replace occup_orig="" if occ_unrec==.
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	* Occ unrec does not align with ISCO 88 and we have no correspondence table.
	* Thus occup is left missing
	gen occup_isco=.
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_skill_>
*isco-88
	gen occup_skill = (occ/10)
	recode occup_skill 99.8=. 99.9=.
	recode occup_skill (1/3=3) (4/8=2) (9=1)
	la de lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lblskill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_occup_>
*correspondance 88 and 08
	gen byte occup = (occ/10)
	recode occup 99.8=. 99.9=.
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>

*<_wage_no_compen_>
	gen double wage_no_compen = round(totwag)
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>

/* <_unitwage_note>
	Unitwage refers to the unit used to record wage_no_compen, *not* the unit of
	general wage payent. For example, PHL LFS asks about wage periodicity, then
	asks for basic daily pay. The value of that pay would be wage_no_compen,
	while unitwage is code 1 ("Daily") for all, regardless of the periodicity.
</_unitwage_note> */

	gen byte unitwage = 5
	replace unitwage=. if lstatus!=1
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours = hrswk
	replace whours=. if hrswk>84
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
	gen byte contract = empcont
	recode contract 100=1 200=0 999=.
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
	gen byte socialsec = socsec
	recode socialsec 99=.
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
	gen byte firmsize_l = .
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u= .
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


*<_occup_skill_2_>
	gen occup_skill_2 = .
	la de lblskill2 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill_2 lblskill2
	label var occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>


*<_occup_2_>
	gen byte occup_2 = .
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
	gen whours_2 = hrswksc
	*it is not logical to work more than 140 hours a day, people that said they work more than 56 will be violating the logical rule, as a result we put them as missing. The user should not use this variable to test whether the individual has a second job.
	replace whours_2=. if hrswksc>56
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
	gen t_wage_others = .
	label var t_wage_others "Annualized wage in all but primary and secondary jobs (12-mon ref period)"
*</_t_wage_others_>


*----------8.5: 7 day reference total summary------------------------------*


*<_t_hours_total_>
	*gen t_hours_total = .
	gen helper_totalh=(whours+whours_2)
	gen t_hours_total = helper_totalh
	replace t_hours_total=. if helper_totalh>140
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


*<_njobs_
	gen njobs_helper_1=1 if secjob==1
	gen njobs_helper_2=1 if inrange(emps,1,4)
	gen njobs = (njobs_helper_1 + njobs_helper_2)
	replace njobs=. if lstatus!=1
	label var njobs "Total number of jobs"
*</_njobs_>


*<_t_hours_annual_>
	gen t_hours_annual = t_hours_total
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

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

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

save "`path_output'\EGY_2007_LFS_V01_M_V01_A_GLD_ALL.dta", replace

*</_% SAVE_>
