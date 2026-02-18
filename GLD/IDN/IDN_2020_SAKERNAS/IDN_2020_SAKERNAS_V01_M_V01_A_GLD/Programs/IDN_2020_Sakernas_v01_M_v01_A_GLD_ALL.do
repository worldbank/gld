
/*%%=============================================================================================
	0: GLD Harmonization Preamble
================================================================================================*/

/* -----------------------------------------------------------------------
<_Program name_>				IDN_2020_Sakernas_v01_M_v01_A_GLD.do </_Program name_>
<_Application_>					Stata MP 16.1 <_Application_>
<_Author(s)_>					Wolrd Bank Job's Group </_Author(s)_>
<_Date created_>				2026-01-09 </_Date created_>
-------------------------------------------------------------------------
<_Country_>						Indonesia (IDN) </_Country_>
<_Survey Title_>				Survei Angkatan Kerja Nasional (The National Labor Force Survey) </_Survey Title_>
<_Survey Year_>					2020 </_Survey Year_>
<_Study ID_>					IDN_2020_Sakernas_v01_M </_Study ID_>
<_Data collection from (M/Y)_>	[MM/YYYY] </_Data collection from (M/Y)_>
<_Data collection to (M/Y)_>	[MM/YYYY] </_Data collection to (M/Y)_>
<_Source of dataset_> 			Shared with Job's Group by the World Bank Indonesia Team
								data request form required to get the access</_Source of dataset_>
<_Sample size (HH)_> 			N/A </_Sample size (HH)_>
<_Sample size (IND)_> 			793,202 </_Sample size (IND)_>
<_Sampling method_> 			Two-stage cluster sampling method </_Sampling method_>
<_Geographic coverage_> 		Province & District </_Geographic coverage_>
<_Currency_> 					Indonesian Rupiah </_Currency_>
---------------------------------------------------------------------------------------
<_ICLS Version_>				ICLS 13 </_ICLS Version_>
<_ISCED Version_>				ISCED-2011 </_ISCED Version_>
<_ISCO Version_>				N/A </_ISCO Ver UP National_>
<_OCCUP National_>				KBJI 2014 </_OCCUP National_>
<_ISIC Version_>				N/A </_ISIC Version_>
<_INDUS National_>				KBLI 2015 </_INDUS National_>
---------------------------------------------------------------------------------------

<_Version Control_>

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
local server  "C:\Users\wb611670\WBG\GLD - 611670_SF"
local country "IDN"
local year    "2020"
local survey  "SAKERNAS"
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

	use "`path_in_stata'\sak20aug_coding.dta", clear

/*%%=============================================================================================
	2: Survey & ID
================================================================================================*/

{

*<_countrycode_>
	gen str4 countrycode = "IDN"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "Sakernas"
	label var survname "Survey acronym"
*</_survname_>


*<_survey_>
	gen survey = "Survei Angkatan Kerja Nasional"
	label var survey "Survey type"
*</_survey_>


*<_icls_v_>
	gen icls_v = "ICLS-13"
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
	gen isic_version = ""
	label var isic_version "Version of ISIC used"
*</_isic_version_>

/*<_year_note_>
340 obs with year not 2020 with all variables as missing values. Here we drop them.
<_year_note_>*/

*<_year_>
	drop if year != 2020
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
	gen int_year = 2020
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen int_month= 8
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
	duplicates report kode_prov kode_kab klasifikas id_nks no_dsrt k1	// 16 duplicates

	// check for duplicates
	sort kode_prov kode_kab klasifikas id_nks no_dsrt k1
		quietly by kode_prov kode_kab klasifikas id_nks no_dsrt k1: gen dup = cond(_N==1,0,_n)
	tab dup	// there are 16 duplicates.
	order kode_prov kode_kab klasifikas id_nks no_dsrt k1
	*br if dup>0	// the duplicates occurs because multiple members are given the same person id (k1) within the same household.

	foreach x of varlist kode_prov kode_kab no_dsrt {
		tostring `x', gen(`x'_str) format(%02.0f)
	}
	
	tostring klasifikas, gen(klasifikas_str)
	tostring id_nks, gen(id_nks_str) format(%05.0f)

	gen hhid=kode_prov_str+kode_kab_str+klasifikas_str+id_nks_str+no_dsrt_str
	label var hhid "Household id"
*</_hhid_>

*<_pid_>
	preserve
	collapse (max) dup, by(hhid)
	count	// 302,264 households
	tempfile dup
	save `dup', replace
	restore

	drop dup
	merge m:1 hhid using `dup', nogen

	clonevar pid0=k1
	sort hhid k1 urutan
	by hhid: gen pidurutan = mod(_n-1,_N)+1
	replace pid0=pidurutan if dup>0

	tostring pid0, gen(pid0_str) format(%02.0f)
 
	gen pid=hhid+pid0_str
	duplicates report pid	// uniquely identified
	label var pid "Individual ID"
*</_pid_>


*<_weight_>
// 	gen weight = final_weig
	label var weight "Survey sampling weight"
*</_weight_>


/*<_psu_note_>

We do know that the primary sampling unit of Sakernas is census block and the
census block number is in the questionnaire. However this information is not
provided due to it is part of the confidential information withheld by the NSO.

<_psu_note_>*/


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
================================================================================================*/

{

*<_urban_>
// 	gen byte urban = klasifikas
// 	recode urban (2=0)
// 	label var urban "Location is urban"
// 	la de lblurban 1 "Urban" 0 "Rural"
// 	label values urban lblurban
*</_urban_>


*<_subnatid1_>
	destring(kode_prov), replace
	gen byte subnatid1_copy =  kode_prov
	label de lblsubnatid1 11 "11 - ACEH" 12 "12 - SUMATERA UTARA" 13 "13 - SUMATERA BARAT" 14 "14 - RIAU" 15 "15 - JAMBI" 16 "16 - SUMATERA SELATAN" 17 "17 - BENGKULU" 18 "18 - LAMPUNG" 19 "19 - KEPULAUAN BANGKA BELITUNG" 21 "21 - KEPULAUAN RIAU" 31 "31 - DKI JAKARTA" 32 "32 - JAWA BARAT" 33 "33 - JAWA TENGAH" 34 "34 - DI YOGYAKARTA" 35 "35 - JAWA TIMUR" 36 "36 - BANTEN" 51 "51 - BALI" 52 "52 - NUSA TENGGARA BARAT" 53 "53 - NUSA TENGGARA TIMUR" 61 "61 - KALIMANTAN BARAT" 62 "62 - KALIMANTAN TENGAH" 63 "63 - KALIMANTAN SELATAN" 64 "64 - KALIMANTAN TIMUR" 65 "65 - KALIMANTAN UTARA" 71 "71 - SULAWESI UTARA" 72 "72 - SULAWESI TENGAH" 73 "73 - SULAWESI SELATAN" 74 "74 - SULAWESI TENGGARA" 75 "75 - GORONTALO" 76 "76 - SULAWESI BARAT" 81 "81 - MALUKU" 82 "82 - MALUKU UTARA" 91 "91 - PAPUA BARAT" 94 "94 - PAPUA"
	label values subnatid1_copy lblsubnatid1
	decode subnatid1_copy, gen(subnatid1)
	drop subnatid1_copy
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	gen kabcode=kode_prov*100 + kode_kab
	gen subnatid2 = "1101 - SIMEULUE" if kabcode==1101
	replace subnatid2 = "1102 - ACEH SINGKIL" if kabcode==1102
	replace subnatid2 = "1103 - ACEH SELATAN" if kabcode==1103
	replace subnatid2 = "1104 - ACEH TENGGARA" if kabcode==1104
	replace subnatid2 = "1105 - ACEH TIMUR" if kabcode==1105
	replace subnatid2 = "1106 - ACEH TENGAH" if kabcode==1106
	replace subnatid2 = "1107 - ACEH BARAT" if kabcode==1107
	replace subnatid2 = "1108 - ACEH BESAR" if kabcode==1108
	replace subnatid2 = "1109 - PIDIE" if kabcode==1109
	replace subnatid2 = "1110 - BIREUEN" if kabcode==1110
	replace subnatid2 = "1111 - ACEH UTARA" if kabcode==1111
	replace subnatid2 = "1112 - ACEH BARAT DAYA" if kabcode==1112
	replace subnatid2 = "1113 - GAYO LUES" if kabcode==1113
	replace subnatid2 = "1114 - ACEH TAMIANG" if kabcode==1114
	replace subnatid2 = "1115 - NAGAN RAYA" if kabcode==1115
	replace subnatid2 = "1116 - ACEH JAYA" if kabcode==1116
	replace subnatid2 = "1117 - BENER MERIAH" if kabcode==1117
	replace subnatid2 = "1118 - PIDIE JAYA" if kabcode==1118
	replace subnatid2 = "1171 - BANDA ACEH" if kabcode==1171
	replace subnatid2 = "1172 - SABANG" if kabcode==1172
	replace subnatid2 = "1173 - LANGSA" if kabcode==1173
	replace subnatid2 = "1174 - L HOKSEUMAWE" if kabcode==1174
	replace subnatid2 = "1175 - SUBULUSSALAM" if kabcode==1175
	replace subnatid2 = "1201 - NIAS" if kabcode==1201
	replace subnatid2 = "1202 - MANDAILING NATAL" if kabcode==1202
	replace subnatid2 = "1203 - TAPANULI SELATAN" if kabcode==1203
	replace subnatid2 = "1204 - TAPANULI TENGAH" if kabcode==1204
	replace subnatid2 = "1205 - TAPANULI UTARA" if kabcode==1205
	replace subnatid2 = "1206 - TOBA SAMOSIR" if kabcode==1206
	replace subnatid2 = "1207 - LABUHAN BATU" if kabcode==1207
	replace subnatid2 = "1208 - ASAHAN" if kabcode==1208
	replace subnatid2 = "1209 - SIMALUNGUN" if kabcode==1209
	replace subnatid2 = "1210 - DAIRI" if kabcode==1210
	replace subnatid2 = "1211 - KARO" if kabcode==1211
	replace subnatid2 = "1212 - DELI SERDANG" if kabcode==1212
	replace subnatid2 = "1213 - LANGKAT" if kabcode==1213
	replace subnatid2 = "1214 - NIAS SELATAN" if kabcode==1214
	replace subnatid2 = "1215 - HUMBANG HASUNDUTAN" if kabcode==1215
	replace subnatid2 = "1216 - PAKPAK BHARAT" if kabcode==1216
	replace subnatid2 = "1217 - SAMOSIR" if kabcode==1217
	replace subnatid2 = "1218 - SERDANG BEDAGAI" if kabcode==1218
	replace subnatid2 = "1219 - BATU BARA" if kabcode==1219
	replace subnatid2 = "1220 - PADANG LAWAS UTARA" if kabcode==1220
	replace subnatid2 = "1221 - PADANG LAWAS" if kabcode==1221
	replace subnatid2 = "1222 - LABUHAN BATU SELATAN" if kabcode==1222
	replace subnatid2 = "1223 - LABUHAN RATU UTARA" if kabcode==1223
	replace subnatid2 = "1224 - NIAS UTARA" if kabcode==1224
	replace subnatid2 = "1225 - NIAS BARAT" if kabcode==1225
	replace subnatid2 = "1271 - SIBOLGA" if kabcode==1271
	replace subnatid2 = "1272 - TANJUNG BALAI" if kabcode==1272
	replace subnatid2 = "1273 - PEMATANG SIANTAR" if kabcode==1273
	replace subnatid2 = "1274 - TEBING TINGGI" if kabcode==1274
	replace subnatid2 = "1275 - MEDAN" if kabcode==1275
	replace subnatid2 = "1276 - BINJAI" if kabcode==1276
	replace subnatid2 = "1277 - PADANG SIDEMPUAN" if kabcode==1277
	replace subnatid2 = "1278 - GUNUNG SITOLI" if kabcode==1278
	replace subnatid2 = "1301 - KEPULAUAN MENTAWAI" if kabcode==1301
	replace subnatid2 = "1302 - PESISIR SELATAN" if kabcode==1302
	replace subnatid2 = "1303 - SOLOK" if kabcode==1303
	replace subnatid2 = "1304 - SAWAHLUNTO/SIJUNJUNG" if kabcode==1304
	replace subnatid2 = "1305 - TANAH DATAR" if kabcode==1305
	replace subnatid2 = "1306 - PADANG PARIAMAN" if kabcode==1306
	replace subnatid2 = "1307 - AGAM" if kabcode==1307
	replace subnatid2 = "1308 - LIMA PULUH KOTO" if kabcode==1308
	replace subnatid2 = "1309 - PASAMAN" if kabcode==1309
	replace subnatid2 = "1310 - SOLOK SELATAN" if kabcode==1310
	replace subnatid2 = "1311 - DHARMASRAYA" if kabcode==1311
	replace subnatid2 = "1312 - PASAMAN BARAT" if kabcode==1312
	replace subnatid2 = "1371 - PADANG" if kabcode==1371
	replace subnatid2 = "1372 - SOLOK" if kabcode==1372
	replace subnatid2 = "1373 - SAWAHLUNTO" if kabcode==1373
	replace subnatid2 = "1374 - PADANG PANJANG" if kabcode==1374
	replace subnatid2 = "1375 - BUKIT TINGGI" if kabcode==1375
	replace subnatid2 = "1376 - PAYAKUMBUH" if kabcode==1376
	replace subnatid2 = "1377 - PARIAMAN" if kabcode==1377
	replace subnatid2 = "1401 - KUANTAN SINGIGI" if kabcode==1401
	replace subnatid2 = "1402 - INDRAGIRI HULU" if kabcode==1402
	replace subnatid2 = "1403 - INDRAGIRI HILIR" if kabcode==1403
	replace subnatid2 = "1404 - PELALAWAN" if kabcode==1404
	replace subnatid2 = "1405 - SIAK" if kabcode==1405
	replace subnatid2 = "1406 - KAMPAR" if kabcode==1406
	replace subnatid2 = "1407 - ROKAN HULU" if kabcode==1407
	replace subnatid2 = "1408 - BENGKALIS" if kabcode==1408
	replace subnatid2 = "1409 - ROKAN HILIR" if kabcode==1409
	replace subnatid2 = "1410 - KEPULAUAN MERANTI" if kabcode==1410
	replace subnatid2 = "1471 - PEKAN BARU" if kabcode==1471
	replace subnatid2 = "1473 - DUMAI" if kabcode==1473
	replace subnatid2 = "1501 - KERINCI" if kabcode==1501
	replace subnatid2 = "1502 - MERANGIN" if kabcode==1502
	replace subnatid2 = "1503 - SAROLANGUN" if kabcode==1503
	replace subnatid2 = "1504 - BATANG HARI" if kabcode==1504
	replace subnatid2 = "1505 - MUARO JAMBI" if kabcode==1505
	replace subnatid2 = "1506 - TANJUNG JABUNG TIMUR" if kabcode==1506
	replace subnatid2 = "1507 - TANJUNG JABUNG BARAT" if kabcode==1507
	replace subnatid2 = "1508 - TEBO" if kabcode==1508
	replace subnatid2 = "1509 - BUNGO" if kabcode==1509
	replace subnatid2 = "1571 - JAMBI" if kabcode==1571
	replace subnatid2 = "1572 - SUNGAI PENUH" if kabcode==1572
	replace subnatid2 = "1601 - OGAN KOMERING ULU" if kabcode==1601
	replace subnatid2 = "1602 - OGAN KOMERING ILIR" if kabcode==1602
	replace subnatid2 = "1603 - MUARA ENIM" if kabcode==1603
	replace subnatid2 = "1604 - LAHAT" if kabcode==1604
	replace subnatid2 = "1605 - MUSI RAWAS" if kabcode==1605
	replace subnatid2 = "1606 - MUSI BANYUASIN" if kabcode==1606
	replace subnatid2 = "1607 - BANYUASIN" if kabcode==1607
	replace subnatid2 = "1608 - OGAN KOMERING ULU SELATAN" if kabcode==1608
	replace subnatid2 = "1609 - OGAN KOMERING ULU TIMUR" if kabcode==1609
	replace subnatid2 = "1610 - OGAN ILIR" if kabcode==1610
	replace subnatid2 = "1611 - EMPAT LAWANG" if kabcode==1611
	replace subnatid2 = "1612 - PENUKAL ABAB LEMATANG ILIR" if kabcode==1612
	replace subnatid2 = "1613 - MUSI RAWAS UTARA" if kabcode==1613
	replace subnatid2 = "1671 - PALEMBANG" if kabcode==1671
	replace subnatid2 = "1672 - PRABUMULIH" if kabcode==1672
	replace subnatid2 = "1673 - PAGAR ALAM" if kabcode==1673
	replace subnatid2 = "1674 - LUBUK LINGGAU" if kabcode==1674
	replace subnatid2 = "1701 - BENGKULU SELATAN" if kabcode==1701
	replace subnatid2 = "1702 - REJANG LEBONG" if kabcode==1702
	replace subnatid2 = "1703 - BENGKULU UTARA" if kabcode==1703
	replace subnatid2 = "1704 - KAUR" if kabcode==1704
	replace subnatid2 = "1705 - SELUMA" if kabcode==1705
	replace subnatid2 = "1706 - MUKOMUKO" if kabcode==1706
	replace subnatid2 = "1707 - LEBONG" if kabcode==1707
	replace subnatid2 = "1708 - KEPAHIANG" if kabcode==1708
	replace subnatid2 = "1709 - BENGKULU TENGAH" if kabcode==1709
	replace subnatid2 = "1771 - BENGKULU" if kabcode==1771
	replace subnatid2 = "1801 - LAMPUNG BARAT" if kabcode==1801
	replace subnatid2 = "1802 - TANGGAMUS" if kabcode==1802
	replace subnatid2 = "1803 - LAMPUNG SELATAN" if kabcode==1803
	replace subnatid2 = "1804 - LAMPUNG TIMUR" if kabcode==1804
	replace subnatid2 = "1805 - LAMPUNG TENGAH" if kabcode==1805
	replace subnatid2 = "1806 - LAMPUNG UTARA" if kabcode==1806
	replace subnatid2 = "1807 - WAY KANAN" if kabcode==1807
	replace subnatid2 = "1808 - TULANG BAWANG" if kabcode==1808
	replace subnatid2 = "1809 - PESAWARAN" if kabcode==1809
	replace subnatid2 = "1810 - PRINGSEWU" if kabcode==1810
	replace subnatid2 = "1811 - MESUJI" if kabcode==1811
	replace subnatid2 = "1812 - TULANG BAWANG BARAT" if kabcode==1812
	replace subnatid2 = "1813 - PESISIR BARAT" if kabcode==1813
	replace subnatid2 = "1871 - BANDAR LAMPUNG" if kabcode==1871
	replace subnatid2 = "1872 - METRO" if kabcode==1872
	replace subnatid2 = "1901 - BANGKA" if kabcode==1901
	replace subnatid2 = "1902 - BELITUNG" if kabcode==1902
	replace subnatid2 = "1903 - BANGKA BARAT" if kabcode==1903
	replace subnatid2 = "1904 - BANGKA TENGAH" if kabcode==1904
	replace subnatid2 = "1905 - BANGKA SELATAN" if kabcode==1905
	replace subnatid2 = "1906 - BELITUNG TIMUR" if kabcode==1906
	replace subnatid2 = "1971 - PANGKAL PINANG" if kabcode==1971
	replace subnatid2 = "2101 - KARIMUN" if kabcode==2101
	replace subnatid2 = "2102 - BINTAN" if kabcode==2102
	replace subnatid2 = "2103 - NATUNA" if kabcode==2103
	replace subnatid2 = "2104 - LINGGA" if kabcode==2104
	replace subnatid2 = "2105 - KEPULAUAN ANAMBAS" if kabcode==2105
	replace subnatid2 = "2171 - BATAM" if kabcode==2171
	replace subnatid2 = "2172 - TANJUNG PINANG" if kabcode==2172
	replace subnatid2 = "3101 - KEPULAUAN SERIBU" if kabcode==3101
	replace subnatid2 = "3171 - JAKARTA SELATAN" if kabcode==3171
	replace subnatid2 = "3172 - JAKARTA TIMUR" if kabcode==3172
	replace subnatid2 = "3173 - JAKARTA PUSAT" if kabcode==3173
	replace subnatid2 = "3174 - JAKARTA BARAT" if kabcode==3174
	replace subnatid2 = "3175 - JAKARTA UTARA" if kabcode==3175
	replace subnatid2 = "3201 - BOGOR" if kabcode==3201
	replace subnatid2 = "3202 - SUKABUMI" if kabcode==3202
	replace subnatid2 = "3203 - CIANJUR" if kabcode==3203
	replace subnatid2 = "3204 - BANDUNG" if kabcode==3204
	replace subnatid2 = "3205 - GARUT" if kabcode==3205
	replace subnatid2 = "3206 - TASIKMALAYA" if kabcode==3206
	replace subnatid2 = "3207 - CIAMIS" if kabcode==3207
	replace subnatid2 = "3208 - KUNINGAN" if kabcode==3208
	replace subnatid2 = "3209 - CIREBON" if kabcode==3209
	replace subnatid2 = "3210 - MAJALENGKA" if kabcode==3210
	replace subnatid2 = "3211 - SUMEDANG" if kabcode==3211
	replace subnatid2 = "3212 - INDRAMAYU" if kabcode==3212
	replace subnatid2 = "3213 - SUBANG" if kabcode==3213
	replace subnatid2 = "3214 - PURWAKARTA" if kabcode==3214
	replace subnatid2 = "3215 - KARAWANG" if kabcode==3215
	replace subnatid2 = "3216 - BEKASI" if kabcode==3216
	replace subnatid2 = "3217 - BANDUNG BARAT" if kabcode==3217
	replace subnatid2 = "3218 - PANGANDARAN" if kabcode==3218
	replace subnatid2 = "3271 - BOGOR" if kabcode==3271
	replace subnatid2 = "3272 - SUKABUMI" if kabcode==3272
	replace subnatid2 = "3273 - BANDUNG" if kabcode==3273
	replace subnatid2 = "3274 - CIREBON" if kabcode==3274
	replace subnatid2 = "3275 - BEKASI" if kabcode==3275
	replace subnatid2 = "3276 - DEPOK" if kabcode==3276
	replace subnatid2 = "3277 - CIMAHI" if kabcode==3277
	replace subnatid2 = "3278 - TASIKMALAYA" if kabcode==3278
	replace subnatid2 = "3279 - BANJAR" if kabcode==3279
	replace subnatid2 = "3301 - CILACAP" if kabcode==3301
	replace subnatid2 = "3302 - BANYUMAS" if kabcode==3302
	replace subnatid2 = "3303 - PURBALINGGA" if kabcode==3303
	replace subnatid2 = "3304 - BANJARNEGARA" if kabcode==3304
	replace subnatid2 = "3305 - KEBUMEN" if kabcode==3305
	replace subnatid2 = "3306 - PURWOREJO" if kabcode==3306
	replace subnatid2 = "3307 - WONOSOBO" if kabcode==3307
	replace subnatid2 = "3308 - MAGELANG" if kabcode==3308
	replace subnatid2 = "3309 - BOYOLALI" if kabcode==3309
	replace subnatid2 = "3310 - KLATEN" if kabcode==3310
	replace subnatid2 = "3311 - SUKOHARJO" if kabcode==3311
	replace subnatid2 = "3312 - WONOGIRI" if kabcode==3312
	replace subnatid2 = "3313 - KARANGANYAR" if kabcode==3313
	replace subnatid2 = "3314 - SRAGEN" if kabcode==3314
	replace subnatid2 = "3315 - GROBOGAN" if kabcode==3315
	replace subnatid2 = "3316 - BLORA" if kabcode==3316
	replace subnatid2 = "3317 - REMBANG" if kabcode==3317
	replace subnatid2 = "3318 - PATI" if kabcode==3318
	replace subnatid2 = "3319 - KUDUS" if kabcode==3319
	replace subnatid2 = "3320 - JEPARA" if kabcode==3320
	replace subnatid2 = "3321 - DEMAK" if kabcode==3321
	replace subnatid2 = "3322 - SEMARANG" if kabcode==3322
	replace subnatid2 = "3323 - TEMANGGUNG" if kabcode==3323
	replace subnatid2 = "3324 - KENDAL" if kabcode==3324
	replace subnatid2 = "3325 - BATANG" if kabcode==3325
	replace subnatid2 = "3326 - PEKALONGAN" if kabcode==3326
	replace subnatid2 = "3327 - PEMALANG" if kabcode==3327
	replace subnatid2 = "3328 - TEGAL" if kabcode==3328
	replace subnatid2 = "3329 - BREBES" if kabcode==3329
	replace subnatid2 = "3371 - MAGELANG" if kabcode==3371
	replace subnatid2 = "3372 - SURAKARTA" if kabcode==3372
	replace subnatid2 = "3373 - SALATIGA" if kabcode==3373
	replace subnatid2 = "3374 - SEMARANG" if kabcode==3374
	replace subnatid2 = "3375 - PEKALONGAN" if kabcode==3375
	replace subnatid2 = "3376 - TEGAL" if kabcode==3376
	replace subnatid2 = "3401 - KULON PROGO" if kabcode==3401
	replace subnatid2 = "3402 - BANTUL" if kabcode==3402
	replace subnatid2 = "3403 - GUNUNG KIDUL" if kabcode==3403
	replace subnatid2 = "3404 - SLEMAN" if kabcode==3404
	replace subnatid2 = "3471 - YOGYAKARTA" if kabcode==3471
	replace subnatid2 = "3501 - PACITAN" if kabcode==3501
	replace subnatid2 = "3502 - PONOROGO" if kabcode==3502
	replace subnatid2 = "3503 - TRENGGALEK" if kabcode==3503
	replace subnatid2 = "3504 - TULUNGAGUNG" if kabcode==3504
	replace subnatid2 = "3505 - BLITAR" if kabcode==3505
	replace subnatid2 = "3506 - KEDIRI" if kabcode==3506
	replace subnatid2 = "3507 - MALANG" if kabcode==3507
	replace subnatid2 = "3508 - LUMAJANG" if kabcode==3508
	replace subnatid2 = "3509 - JEMBER" if kabcode==3509
	replace subnatid2 = "3510 - BANYUWANGI" if kabcode==3510
	replace subnatid2 = "3511 - BONDOWOSO" if kabcode==3511
	replace subnatid2 = "3512 - SITUBONDO" if kabcode==3512
	replace subnatid2 = "3513 - PROBOLINGGO" if kabcode==3513
	replace subnatid2 = "3514 - PASURUAN" if kabcode==3514
	replace subnatid2 = "3515 - SIDOARJO" if kabcode==3515
	replace subnatid2 = "3516 - MOJOKERTO" if kabcode==3516
	replace subnatid2 = "3517 - JOMBANG" if kabcode==3517
	replace subnatid2 = "3518 - NGANJUK" if kabcode==3518
	replace subnatid2 = "3519 - MADIUN" if kabcode==3519
	replace subnatid2 = "3520 - MAGETAN" if kabcode==3520
	replace subnatid2 = "3521 - NGAWI" if kabcode==3521
	replace subnatid2 = "3522 - BOJONEGORO" if kabcode==3522
	replace subnatid2 = "3523 - TUBAN" if kabcode==3523
	replace subnatid2 = "3524 - LAMONGAN" if kabcode==3524
	replace subnatid2 = "3525 - GRESIK" if kabcode==3525
	replace subnatid2 = "3526 - BANGKALAN" if kabcode==3526
	replace subnatid2 = "3527 - SAMPANG" if kabcode==3527
	replace subnatid2 = "3528 - PAMEKASAN" if kabcode==3528
	replace subnatid2 = "3529 - SUMENEP" if kabcode==3529
	replace subnatid2 = "3571 - KEDIRI" if kabcode==3571
	replace subnatid2 = "3572 - BLITAR" if kabcode==3572
	replace subnatid2 = "3573 - MALANG" if kabcode==3573
	replace subnatid2 = "3574 - PROBOLINGGO" if kabcode==3574
	replace subnatid2 = "3575 - PASURUAN" if kabcode==3575
	replace subnatid2 = "3576 - MOJOKERTO" if kabcode==3576
	replace subnatid2 = "3577 - MADIUN" if kabcode==3577
	replace subnatid2 = "3578 - SURABAYA" if kabcode==3578
	replace subnatid2 = "3579 - BATU" if kabcode==3579
	replace subnatid2 = "3601 - PANDEGLANG" if kabcode==3601
	replace subnatid2 = "3602 - LEBAK" if kabcode==3602
	replace subnatid2 = "3603 - TANGERANG" if kabcode==3603
	replace subnatid2 = "3604 - SERANG" if kabcode==3604
	replace subnatid2 = "3671 - TANGERANG" if kabcode==3671
	replace subnatid2 = "3672 - CILEGON" if kabcode==3672
	replace subnatid2 = "3673 - SERANG" if kabcode==3673
	replace subnatid2 = "3674 - TANGERANG SELATAN" if kabcode==3674
	replace subnatid2 = "5101 - JEMBRANA" if kabcode==5101
	replace subnatid2 = "5102 - TABANAN" if kabcode==5102
	replace subnatid2 = "5103 - BADUNG" if kabcode==5103
	replace subnatid2 = "5104 - GIANYAR" if kabcode==5104
	replace subnatid2 = "5105 - KLUNGKUNG" if kabcode==5105
	replace subnatid2 = "5106 - BANGLI" if kabcode==5106
	replace subnatid2 = "5107 - KARANG ASEM" if kabcode==5107
	replace subnatid2 = "5108 - BULELENG" if kabcode==5108
	replace subnatid2 = "5171 - DENPASAR" if kabcode==5171
	replace subnatid2 = "5201 - LOMBOK BARAT" if kabcode==5201
	replace subnatid2 = "5202 - LOMBOK TENGAH" if kabcode==5202
	replace subnatid2 = "5203 - LOMBOK TIMUR" if kabcode==5203
	replace subnatid2 = "5204 - SUMBAWA" if kabcode==5204
	replace subnatid2 = "5205 - DOMPU" if kabcode==5205
	replace subnatid2 = "5206 - BIMA" if kabcode==5206
	replace subnatid2 = "5207 - SUMBAWA BARAT" if kabcode==5207
	replace subnatid2 = "5208 - LOMBOK UTARA" if kabcode==5208
	replace subnatid2 = "5271 - KOTA MATARAM" if kabcode==5271
	replace subnatid2 = "5272 - KOTA BIMA" if kabcode==5272
	replace subnatid2 = "5301 - SUMBA BARAT" if kabcode==5301
	replace subnatid2 = "5302 - SUMBA TIMUR" if kabcode==5302
	replace subnatid2 = "5303 - KUPANG" if kabcode==5303
	replace subnatid2 = "5304 - TIMOR TENGAH SELATAN" if kabcode==5304
	replace subnatid2 = "5305 - TIMOR TENGAH UTARA" if kabcode==5305
	replace subnatid2 = "5306 - BELU" if kabcode==5306
	replace subnatid2 = "5307 - ALOR" if kabcode==5307
	replace subnatid2 = "5308 - LEMBATA" if kabcode==5308
	replace subnatid2 = "5309 - FLORES TIMUR" if kabcode==5309
	replace subnatid2 = "5310 - SIKKA" if kabcode==5310
	replace subnatid2 = "5311 - ENDE" if kabcode==5311
	replace subnatid2 = "5312 - NGADA" if kabcode==5312
	replace subnatid2 = "5313 - MANGGARAI" if kabcode==5313
	replace subnatid2 = "5314 - ROTE NDAO" if kabcode==5314
	replace subnatid2 = "5315 - MANGGARAI BARAT" if kabcode==5315
	replace subnatid2 = "5316 - SUMBA TENGAH" if kabcode==5316
	replace subnatid2 = "5317 - SUMBA BARAT DAYA" if kabcode==5317
	replace subnatid2 = "5318 - NAGEKEO" if kabcode==5318
	replace subnatid2 = "5319 - MANGGARAI TIMUR" if kabcode==5319
	replace subnatid2 = "5320 - SABU RAIJUA" if kabcode==5320
	replace subnatid2 = "5321 - MALAKA" if kabcode==5321
	replace subnatid2 = "5371 - KUPANG" if kabcode==5371
	replace subnatid2 = "6101 - SAMBAS" if kabcode==6101
	replace subnatid2 = "6102 - BENGKAYANG" if kabcode==6102
	replace subnatid2 = "6103 - LANDAK" if kabcode==6103
	replace subnatid2 = "6104 - PONTIANAK" if kabcode==6104
	replace subnatid2 = "6105 - SANGGAU" if kabcode==6105
	replace subnatid2 = "6106 - KETAPANG" if kabcode==6106
	replace subnatid2 = "6107 - SINTANG" if kabcode==6107
	replace subnatid2 = "6108 - KAPUAS HULU" if kabcode==6108
	replace subnatid2 = "6109 - SEKADAU" if kabcode==6109
	replace subnatid2 = "6110 - MELAWI" if kabcode==6110
	replace subnatid2 = "6111 - KAYONG UTARA" if kabcode==6111
	replace subnatid2 = "6112 - KUBU RAYA" if kabcode==6112
	replace subnatid2 = "6171 - KOTA PONTIANAK" if kabcode==6171
	replace subnatid2 = "6172 - KOTA SINGKAWANG" if kabcode==6172
	replace subnatid2 = "6201 - KOTAWARINGIN BARAT" if kabcode==6201
	replace subnatid2 = "6202 - KOTAWARINGIN TIMUR" if kabcode==6202
	replace subnatid2 = "6203 - KAPUAS" if kabcode==6203
	replace subnatid2 = "6204 - BARITO SELATAN" if kabcode==6204
	replace subnatid2 = "6205 - BARITO UTARA" if kabcode==6205
	replace subnatid2 = "6206 - SUKAMARA" if kabcode==6206
	replace subnatid2 = "6207 - LAMANDAU" if kabcode==6207
	replace subnatid2 = "6208 - SERUYAN" if kabcode==6208
	replace subnatid2 = "6209 - KATINGAN" if kabcode==6209
	replace subnatid2 = "6210 - PULANG PISAU" if kabcode==6210
	replace subnatid2 = "6211 - GUNUNG MAS" if kabcode==6211
	replace subnatid2 = "6212 - BARITO TIMUR" if kabcode==6212
	replace subnatid2 = "6213 - MURUNG RAYA" if kabcode==6213
	replace subnatid2 = "6271 - PALANGKA RAYA" if kabcode==6271
	replace subnatid2 = "6301 - TANAH LAUT" if kabcode==6301
	replace subnatid2 = "6302 - KOTA BARU" if kabcode==6302
	replace subnatid2 = "6303 - BANJAR" if kabcode==6303
	replace subnatid2 = "6304 - BARITO KUALA" if kabcode==6304
	replace subnatid2 = "6305 - TAPIN" if kabcode==6305
	replace subnatid2 = "6306 - HULU SUNGAI SELATAN" if kabcode==6306
	replace subnatid2 = "6307 - HULU SUNGAI TENGAH" if kabcode==6307
	replace subnatid2 = "6308 - HULU SUNGAI UTARA" if kabcode==6308
	replace subnatid2 = "6309 - TABALONG" if kabcode==6309
	replace subnatid2 = "6310 - TANAH BUMBU" if kabcode==6310
	replace subnatid2 = "6311 - BALANGAN" if kabcode==6311
	replace subnatid2 = "6371 - BANJARMASIN" if kabcode==6371
	replace subnatid2 = "6372 - BANJAR BARU" if kabcode==6372
	replace subnatid2 = "6401 - PASIR" if kabcode==6401
	replace subnatid2 = "6402 - KUTAI BARAT" if kabcode==6402
	replace subnatid2 = "6403 - KUTAI" if kabcode==6403
	replace subnatid2 = "6404 - KUTAI TIMUR" if kabcode==6404
	replace subnatid2 = "6405 - BERAU" if kabcode==6405
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
	gen subnatid3 = .
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
	gen subnatidsurvey = "subnatid2"
	label var subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>


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
	gen byte hsize = jlh_art
	label var hsize "Household size"
*</_hsize_>


*<_age_>
	confirm var age
	label var age "Individual age"
*</_age_>


*<_male_>
	gen male = gender
	label var male "Sex - Ind is male"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen byte relationharm = k3
	recode relationharm (3 4 5 6=3) (7=4) (8=5) (9 10 11=6)
	label var relationharm "Relationship to the head of household - Harmonized"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm lblrelationharm
*</_relationharm_>


*<_relationcs_>
	gen relationcs = k3
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte marital = r4
	recode marital (1=2) (2=1) (3=4) (4=5)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


*<_eye_dsablty_>
	gen eye_dsablty = r8a
	label var eye_dsablty "Disability related to eyesight"
	la de lbleye_dsablty 1 "No" 2 "Yes-some" 3 "Yes-a lot" 4 "Cannot at all"
	label values eye_dsablty lbleye_dsablty
*</_eye_dsablty_>


*<_hear_dsablty_>
	gen hear_dsablty = r8b
	label var hear_dsablty "Disability related to hearing"
	la de lblhear_dsablty 1 "No" 2 "Yes-some" 3 "Yes-a lot" 4 "Cannot at all"
	label values hear_dsablty lblhear_dsablty
*</_hear_dsablty_>


*<_walk_dsablty_>
	gen walk_dsablty = r8c
	label var walk_dsablty "Disability related to walking or climbing stairs"
	la de lblwalk_dsablty 1 "No" 2 "Yes-some" 3 "Yes-a lot" 4 "Cannot at all"
	label values walk_dsablty lblwalk_dsablty
*</_walk_dsablty_>


*<_conc_dsord_>
	gen conc_dsord = .
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
	gen slfcre_dsablty  = .
	label var slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
	gen comm_dsablty = r8e
	label var comm_dsablty "Disability related to communicating"
	la de lblcomm_dsablty 1 "No" 2 "Yes-some" 3 "Yes-a lot" 4 "Cannot at all"
	label values comm_dsablty lblcomm_dsablty
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
	gen byte ed_mod_age = 5
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


*<_school_>
	gen byte school = r5
	recode school (1 3=0) (2=1)
	replace school = . if age < ed_mod_age & age!=.
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school lblschool
*</_school_>


*<_literacy_>
	gen byte literacy = .
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


/*<_educy_note_>

Years of education, or "educy" (and all other related variables were left missing)
because of the unclear mapping for "Not finished primary school yet".

According to isced-2011 mappings, there are day care centre, playgroup, and
kindergarten as pre-primary education before 7 years old. Whether to map
primary unfinished to those options depends on specific assumptions and research
needs. Therefore, variable "educy" was left missing and so were educat7, educat5,
and educat4.

In 2019, there is no such category as "No education" nor missing observations. So
probably the survey grouped "no education" into "not yet completed primary school".

Original code list of variable "b5_r1a" in the dataset:
1.Not yet completed primary school
2.Non-formal primary school (Paket A)
3.Primary School for special needs
4.Primary school
5.Non-formal junior high school (Paket B)
6.Junior high school for special needs
7.Junior high school
8.Non-formal senior high school (Paket C)
9.Senior high school for special needs
10.Senior high school
11.Vocational high school(SMK/MAK)
12.Diploma I/II
13.Diploma III
14.Diploma IV/Bachelor
15.Master
16.Doctoral
</_educy_note_>*/


*<_educy_>
	gen byte educy = .
	replace educy = . if age < ed_mod_age & age!=.
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	recode r6a (1=2) (2=3) (3=4) (4=5) (8=7), gen(educat7)
	replace educat7=1 if r5==1
	recode educat7 (1=2) (3=4) (5=6) (6=7) if r5==2
	replace educat7 = . if age < ed_mod_age & age!=.
	label var educat7 "Level of education 1"
	la de lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete"
	label values educat7 lbleducat7
*</_educat7_>


*<_educat5_>
	gen byte educat5 = educat7
	recode educat5 (4=3) (5=4) (6/7=5)
	replace educat5 = . if age < ed_mod_age & age!=.
	label var educat5 "Level of education 2"
	la de lbleducat5 1 "No education" 2 "Primary incomplete"  3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>


*<_educat4_>
	gen byte educat4 = educat5
	replace educat4 = . if age < ed_mod_age & age!=.
	recode educat4 (3=2) (4=3) (5=4)
	label var educat4 "Level of education 3"
	la de lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 lbleducat4
*</_educat4_>


*<_educat_orig_>
	gen educat_orig = r6a
	label var educat_orig "Original survey education code"
*</_educat_orig_>


*<_educat_isced_>
	gen educat_isced = r6a
	recode educat_isced (1=020) (2/4=100) (5/7=244) (8/11=344) (12=454) (13=550) (14=660) (15=760) (16=860)
	label var educat_isced "ISCED standardised level of education"
*</_educat_isced_>


*<_educat_isced_v_>
	gen educat_isced_v="ISCED-2019"
	label var educat_isced_v "Version of the ISCED used"
*</_educat_isced_v_>

*----------6.1: Education cleanup------------------------------*

*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
local ed_var school literacy educy educat7 educat5 educat4 educat_isced
foreach v of local ed_var {
	replace `v' = . if ( age < ed_mod_age & !missing(age) )
}
replace educat_isced_v = "" if ( age < ed_mod_age & !missing(age) )
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
	gen byte lstatus = .
	replace lstatus = 1 if r9a==1 | r9b==1 | r9c==1 | r10a==1
    replace lstatus = 2 if (r22a==1 | r22b==1) & missing(lstatus)
    replace lstatus = 3 if (r22a==2 & r22b==2) & missing(lstatus)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>

/*<_potential_lf_note_>
Note: var "potential_lf" is missing if the respondent is in labor force or unemployed; it only takes value if the respondent is not in labor force. (lstatus==3)

"potential_lf" = 1 if the person is
1)available but not searching 
2)searching but not immediately available to work 
	 
in IDN 2020, there's variables showing whether the person has searched for work but no variable for whether this person was available.

</_potential_lf_note_>*/

*<_potential_lf_>
	gen byte potential_lf = .
// 	replace potential_lf = 1 if [b5_r18b==1 & b5_r12a==2 & b5_r12b==2] | [b5_r18b==2 & ((b5_r12a==1) | (b5_r12b==1))]
// 	replace potential_lf = 0 if [b5_r18b==1 & (b5_r12a==1 | b5_r12b==1)] | [b5_r18b==2 & b5_r12a==2 & b5_r12b==2]
// 	replace potential_lf = . if age < minlaborage & age != .
// 	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen byte underemployment = .
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


/*<_nlfreason_note_>

The original variable "r25a" for 7-day reference period:
	1  Already had a job, but not starting to work yet
	2  Having a new business but not starting to work yet
	3  Desperate: feeling hopeless to get a job
	4  Already had a job/business
	5  Other activities (household/school)
	6  Lack of infrastructure (assets, roads, transportation, employment services) or no capital
	7  Feer of being infected with Covid-19
	8  Social/Physical distancing, self-quarantine
	9  Unable to do a job
	10 Other
However, these categories does not fit with our definitions of nlfreason

<_nlfreason_note_>*/


*<_nlfreason_>
	gen byte nlfreason = .
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


/*<_unempldur_l_note_>

The original variable "r23a"(year) "r23b"(month) is the period of seeking job. Therefore, the lower
and upper bound of unemploymenmt duration are the same. They are in fact the length
of unemployment period.

<_unempldur_l_note_>*/


*<_unempldur_l_>
	gen byte unempldur_l = r23a*12+r23b
	replace unempldur_l = . if lstatus != 2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u = r23a*12+r23b
	replace unempldur_u = . if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	recode r12a (1 2=4) (4/6=1) (7=2), gen(empstat)
	replace empstat=.  if lstatus!=1
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec = .
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


/*<_industry_orig_note_>

Variable "r13a_kateg" is the 1 digit industrycode with 17 categories

<_industry_orig_note_>*/


*<_industry_orig_>
	gen industry_orig = r13a_kateg
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


/*<_industrycat_isic_note_>

Because variable "r13a_kateg" only has 17 digits, it was not mapped to ISIC.

<_industrycat_isic_note_>*/


*<_industrycat_isic_>
	gen industrycat_isic = .
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>
	recode r13a_kateg (5=4) (6=5) (7 9=6) (8 10=7) (11/13=8) (14=9) (15/17=10), gen(industrycat10)
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	replace industrycat10 = . if lstatus!=1
	label values industrycat10 lblindustrycat10
*</_industrycat10_>


*<_industrycat4_>
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var industrycat4 "1 digit industry classification (Broad Economic Activities), primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>


/*<_occup_orig_note_>

Variable "r13b_kbji2" uses KBJI 2014 and it has one digit and 9 categories in total.

<_occup_orig_note_>*/


*<_occup_orig_>
	gen occup_orig = r13b_kbji2
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>
	gen occup_isco = ""
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>


*<_occup_skill_>
	gen occup_skill = r13b_kbji2
	recode occup_skill (1/3=3) (4/8=2) (9=1) (0=.)
	replace occup_skill = . if lstatus!=1
	label define lbl_occup_skill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lbl_occup_skill
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_occup_>
	gen occup = r13b_kbji2
	replace occup = 10 if occup==0
	replace occup = . if lstatus!=1
	label var occup "1 digit occupational classification, primary job 7 day recall"
  	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and market sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces" 99 "Others"
	label values occup lbloccup
*</_occup_>

*<_wage_no_compen_>
	gen double wage_no_compen = .
	replace wage_no_compen=r14a1+r14a2 if empstat==1
	recode wage_no_compen (0=.)
	label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
	gen byte unitwage = 5 if !missing(wage_no_compen)
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours= r16a
	replace whours = . if lstatus!=1
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	gen wmonths = .
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


/*<_wage_total_note_>

adapted from EAPLFS code

<_wage_total_note_>*/


*<_wage_total_>
	gen wage_total=(r14a1+r14a2)*12 if empstat==1
	recode wage_total (0=.)
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

*<_firmsize_l_note>
* in IDN 2020, the question is "How many workers/employees/staff are paid?"
* therefore the lower bound and the upper bound are the same
*<_firmsize_l_note>

*<_firmsize_l_>
	gen byte firmsize_l = r12b
	replace firmsize_l = . if lstatus!=1
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte firmsize_u = r12b
	replace firmsize_u = . if lstatus!=1
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
	gen byte empstat_2 =.
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
*</_empstat_2_>


*<_ocusec_2_>
	gen byte ocusec_2 = .
	label var ocusec_2 "Sector of activity secondary job 7 day recall"
	la de lblocusec_2 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec_2 lblocusec_2
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
	gen byte industrycat4_2 = .
	label var industrycat4_2 "1 digit industry classification (Broad Economic Activities), secondary job 7 day recall"
	label values industrycat4_2 lblindustrycat4
*</_industrycat4_2_>


*<_occup_orig_2_>
	gen occup_orig_2 = ""
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	gen occup_isco_2 = ""
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_skill_2_>
	gen occup_skill_2 = .
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
	gen whours_2 = .
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
	label var t_wage_nocompen_others "Annualized wage in all but primary & secondary jobs excl. bonuses, etc. 7 day recall"
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
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>

*<_potential_lf_year_>
	gen byte potential_lf_year = .
	replace potential_lf_year = . if age < minlaborage & age != .
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
	gen byte nlfreason_year = .
	label var nlfreason_year "Reason not in the labor force"
	la de lblnlfreason_year 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason_year lblnlfreason_year
*</_nlfreason_year_>


*<_unempldur_l_year_>
	gen byte unempldur_l_year = .
	label var unempldur_l_year "Unemployment duration (months) lower bracket"
*</_unempldur_l_year_>


*<_unempldur_u_year_>
	gen byte unempldur_u_year = .
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
	label var ocusec_year "Sector of activity primary job 12 day recall"
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
	gen byte industrycat4_year = industrycat10_year
	recode industrycat4_year (1=1) (2 3 4 5 =2) (6 7 8 9=3) (10=4)
	label var industrycat4_year "1 digit industry classification (Broad Economic Activities), primary job 12 month recall"
	la de lblindustrycat4_year 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4_year lblindustrycat4_year
*</_industrycat4_year_>


*<_occup_orig_year_>
	gen occup_orig_year = .
	label var occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	gen occup_isco_year = .
	label var occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_skill_year_>
	gen occup_skill_year = .
	label var occup_skill_year "Skill based on ISCO standard primary job 12 month recall"
*</_occup_skill_year_>


*<_occup_year_>
	gen byte occup_year = .
	label var occup_year "1 digit occupational classification, primary job 12 month recall"
	la de lbloccup_year 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_year lbloccup_year
*</_occup_year_>


*<_wage_no_compen_year_>
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
	label var ocusec_2_year "Sector of activity secondary job 12 day recall"
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
	gen byte industrycat4_2_year = industrycat10_2_year
	recode industrycat4_2_year (1=1) (2 3 4 5 =2) (6 7 8 9=3) (10=4)
	label var industrycat4_2_year "1 digit industry classification (Broad Economic Activities), secondary job 12 month recall"
	label values industrycat4_2_year lblindustrycat4_year
*</_industrycat4_2_year_>


*<_occup_orig_2_year_>
	gen occup_orig_2_year = .
	label var occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
	gen occup_isco_2_year = .
	label var occup_isco_2_year "ISCO code of secondary job 12 month recall"
*</_occup_isco_2_year_>


*<_occup_skill_2_year_>
	gen occup_skill_2_year = .
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
	label var t_wage_nocompen_others_year "Annualized wage in all but primary & secondary jobs excl. bonuses, etc. 12 month recall)"
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
	replace njobs = 1 if lstatus ==1 & empstat_2 ==.
	replace njobs = 2 if lstatus ==1 & empstat_2 !=.
	replace njobs = 0 if lstatus !=1
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
	gen laborincome = .
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
