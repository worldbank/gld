
/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>		[SLV_2021_EHPM_V01_M_V01_A_GLD_ALL.do] </_Program name_>
<_Application_>			[STATA] </_Application_>
<_Author(s)_>			[The World Bank Jobs Group] </_Author(s)_>
<_Date created_>		[2026-04-22] </_Date created_>

-------------------------------------------------------------------------

<_Country_>				El Salvador (SLV) </_Country_>
<_Survey Title_>		Encuesta de Hogares de Propósitos Múltiples (EHPM) </_Survey Title_>
<_Survey Year_>			2021 </_Survey Year_>
<_Study ID_>			[Microdata Library ID if present] </_Study ID_>
<_Data collection from_>	01/2021 </_Data collection from_>
<_Data collection to_>		12/2021 </_Data collection to_>
<_Source of dataset_>		DIGESTYC – Dirección General de Estadística y Censos, El Salvador </_Source of dataset_>
<_Sample size (HH)_>		2021: 19,627  </_Sample size (HH)_>
<_Sample size (IND)_>		2021: 64,937 </_Sample size (IND)_>
<_Sampling method_>		Probabilistic, stratified multi-stage cluster sampling.
						Strata: region × area (urban/rural).
						</_Sampling method_>
<_Geographic coverage_>	National; 5 regions; 14 departments </_Geographic coverage_>
<_Currency_>			US Dollars (USD) — El Salvador adopted USD in 2001 </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>		[ICLS-13] </_ICLS Version_>
<_ISCED Version_>		[ISCED 2011] </_ISCED Version_>
<_ISCO Version_>		[ISCO-08 / CIUO-08] </_ISCO Version_>
<_OCCUP National_>		[CIUO-08 adapted — 1-digit groups available via ciuo414/ciuo436] </_OCCUP National_>
<_ISIC Version_>		[ISIC Rev. 4 / CIIU Rev. 4] </_ISIC Version_>
<_INDUS National_>		[CIIU Rev. 4 — 14-category aggregation via ciiu416/ciiu438] </_INDUS National_>

-----------------------------------------------------------------------

<_Version Control_>

* v01 – Initial harmonization 2021

</_Version Control_>

*/


/*%%=============================================================================================
	1: Setting up program environment, dataset
==============================================================================================%%*/

*----------1.1: Initial commands------------------------------*

clear all
set more off
set mem 800m
cap log close

*----------1.2: Set directories------------------------------*

local server  "C:/GLD/SLV"
local country "SLV"
local survey  "EHPM"
local vermast "V01"
local veralt  "V01"

local out_year "2021"
local level_2_harm "`country'_`out_year'_`survey'_`vermast'_M_`veralt'_A_GLD"
local path_output  "`server'/`country'/`level_2_harm'/Data/Harmonized"
local out_file     "`level_2_harm'_ALL.dta"

* Raw .dta file paths — adjust to your local directory
// local path_raw "`server'/`country'/Raw"

local path_raw "C:/Users/wb584706/OneDrive - WBG/Honduras/Data/Comparision Countries/El Salvador/Raw Data"


/*%%=============================================================================================
	1.3: Load and append all years
==============================================================================================%%*/

use "`path_raw'/EHPM 2021.dta", clear

cap confirm variable edicion
if _rc != 0 gen int edicion = 2021
replace edicion = 2021 if missing(edicion)



/*%%=============================================================================================
	2: Survey & ID Module
==============================================================================================%%*/

{

*<_countrycode_>
	gen str3 countrycode = "SLV"
	label var countrycode "Country code"
*</_countrycode_>

*<_survname_>
	gen str4 survname = "EHPM"
	label var survname "Survey acronym"
*</_survname_>

*<_survey_>
	gen str3 survey = "HHS"
	label var survey "Survey type"
*</_survey_>

*<_icls_v_>
	/* <_icls_v_note>
	   EHPM uses ICLS-13 definition: actpr=10 (Employed) includes own-consumption
	   agricultural workers and other marginal employment categories captured in
	   the detailed r4041–r4049 questions.
	</_icls_v_note> */
	gen str7 icls_v = "ICLS-13"
	label var icls_v "ICLS version underlying survey design"
*</_icls_v_>

*<_isced_version_>
	gen str10 isced_version = "isced_2011"
	label var isced_version "Version of ISCED used for edu categorization"
*</_isced_version_>

*<_isco_version_>
	gen str9 isco_version = "isco_2008"
	label var isco_version "Version of ISCO used"
*</_isco_version_>

*<_isic_version_>
	gen str6 isic_version = "isic_4"
	label var isic_version "Version of ISIC used"
*</_isic_version_>

*<_year_>
	gen int year = edicion
	label var year "Survey year"
*</_year_>

*<_vermast_>
	gen str3 vermast = "`vermast'"
	label var vermast "Version of master data"
*</_vermast_>

*<_veralt_>
	gen str3 veralt = "`veralt'"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>

*<_harmonization_>
	gen str3 harmonization = "GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>

*<_int_year_>
	gen int int_year = edicion
	label var int_year "Year of the interview"
*</_int_year_>

*<_int_month_>
	/* r015 = month of interview */
	gen byte int_month = int(r015) if !missing(r015)
	label var int_month "Month of the interview"
*</_int_month_>

*<_wave_>
	gen int wave = edicion
	label var wave "Survey wave (year)"
*</_wave_>

*<_hhid_>
	/* idboleta is unique within year; combine with edicion for cross-year uniqueness */
gen str20 hhid = string(edicion) + "_" + string(int(idboleta))
	label var hhid "Household ID"
*</_hhid_>

*<_pid_>
	gen str25 pid = hhid + "_" + string(int(r101))
	label var pid "Individual ID"
*</_pid_>

isid pid

*<_weight_>
	/* fac00 = DIGESTYC expansion factor in all years */
	gen double weight = fac00
	label var weight "Survey sampling weight (DIGESTYC expansion factor)"
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
	/* <_psu_note>
	   DIGESTYC does not release PSU/conglomerado codes in public files.
	   Folio (segment number) is the best available proxy for PSU.
	</_psu_note> */
	gen psu = (folio)
	label var psu "Primary sampling unit (proxy: folio/segment)"
*</_psu_>

*<_ssu_>
	gen ssu = hhid
	label var ssu "Secondary sampling unit"
*</_ssu_>

*<_strata_>
	/* <_strata_note>
	   estratoarea (2021–2023) = region × area strata.
	</_strata_note> */
	gen strata = .
	cap replace strata = long(estratoarea) if !missing(estratoarea)
	label var strata "Strata (region × urban/rural)"
*</_strata_>

}


/*%%=============================================================================================
	3: Geography Module
==============================================================================================%%*/

{

*<_urban_>
	/* <_urban_note>
	   area: 1=Urbano, 0=Rural (2021–2023).
	</_urban_note> */
	gen byte urban = .
	cap replace urban = int(area) 
	lab var urban "Urban (1) or rural (0)"
	lab define lblurban 1 "Urban" 0 "Rural"
	lab values urban lblurban
*</_urban_>

*<_subnatid1_>
	/* <_subnatid1_note>
	   region: 1=Occidental, 2=Central I, 3=Central II, 4=Oriental,
	           5=Área metropolitana de San Salvador
	</_subnatid1_note> */
	gen str40 subnatid1 = ""
	cap {
		replace subnatid1 = "1 - Occidental"                       if int(region) == 1
		replace subnatid1 = "2 - Central I"                        if int(region) == 2
		replace subnatid1 = "3 - Central II"                       if int(region) == 3
		replace subnatid1 = "4 - Oriental"                         if int(region) == 4
		replace subnatid1 = "5 - Area Metropolitana San Salvador"   if int(region) == 5
	}
	label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>

*<_subnatid2_>
	gen str30 subnatid2 = ""
	cap {
		replace subnatid2 = "1 - Ahuachapon"    if int(r004) == 1
		replace subnatid2 = "2 - Santa Ana"     if int(r004) == 2
		replace subnatid2 = "3 - Sonsonate"     if int(r004) == 3
		replace subnatid2 = "4 - Chalatenango"  if int(r004) == 4
		replace subnatid2 = "5 - La Libertad"   if int(r004) == 5
		replace subnatid2 = "6 - San Salvador"  if int(r004) == 6
		replace subnatid2 = "7 - Cuscatlan"     if int(r004) == 7
		replace subnatid2 = "8 - La Paz"        if int(r004) == 8
		replace subnatid2 = "9 - Cabanas"       if int(r004) == 9
		replace subnatid2 = "10 - San Vicente"  if int(r004) == 10
		replace subnatid2 = "11 - Usulutan"     if int(r004) == 11
		replace subnatid2 = "12 - San Miguel"   if int(r004) == 12
		replace subnatid2 = "13 - Morazan"      if int(r004) == 13
		replace subnatid2 = "14 - La Union"     if int(r004) == 14
	}
	label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>

*<_subnatid3_>
	gen str30 subnatid3 = ""
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>

*<_subnatidsurvey_>
	gen str10 subnatidsurvey = "subnatid1"
	label var subnatidsurvey "Administrative level at which survey is representative"
	
*</_subnatidsurvey_>


*</_subnatid1_prev_note> */
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
	label var gaul_adm1_code "GAUL code (first administrative level)"
*</_gaul_adm1_code_>

*<_gaul_adm2_code_>
	gen gaul_adm2_code = .
	label var gaul_adm2_code "GAUL code (second administrative level)"
*</_gaul_adm2_code_>

*<_gaul_adm3_code_>
	gen gaul_adm3_code = .
	label var gaul_adm3_code "GAUL code (third administrative level)"
*</_gaul_adm3_code_>

}


/*%%=============================================================================================
	4: Demography
==============================================================================================%%*/

{

*<_hsize_>
	/* r021a = number of household members (DIGESTYC-provided) */
	gen byte hsize = int(r021a) if !missing(r021a)
	/* Cross-check with within-hhid count */
	bysort hhid: gen hsize_check = _N
	replace hsize = hsize_check if missing(hsize)
	drop hsize_check
	label var hsize "Household size"
*</_hsize_>

*<_age_>
	gen byte age = int(r106) if !missing(r106)
	replace age = . if age < 0 | age > 120
	label var age "Individual age"
*</_age_>

*<_male_>
	/* r104: 1=Hombre, 2=Mujer */
	gen byte male = (int(r104) == 1) if !missing(r104)
	label var male "Sex - Ind is male"
	label define lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>

*<_relationharm_>
	/* <_relationharm_note>
	   r103: 1=Jefe(a), 2=Esposa(o)/compañera(o), 3=Hijo(a), 4=Padre/Madre,
	         5=Hermano(a), 6=Yerno/Nuera, 7=Nieto(a), 8=Suegro(a),
	         9=Otros familiares, 10=Empleada(o) doméstica(o), 11=Otros
	</_relationharm_note> */
	gen byte relationharm = .
	replace relationharm = 1 if int(r103) == 1                        // Head
	replace relationharm = 2 if int(r103) == 2                        // Spouse/partner
	replace relationharm = 3 if inlist(int(r103), 3)            // Children
	replace relationharm = 4 if inlist(int(r103), 4, 8)               // Parents, parents-in-law
	replace relationharm = 5 if inlist(int(r103), 5,6,7,9)               // Siblings, other relatives
	replace relationharm = 6 if inlist(int(r103), 10, 11)             // Domestic worker, others
	label var relationharm "Relationship to household head (harmonized)"
	la de lblrelationharm 1 "Head of household" 2 "Spouse" 3 "Children" ///
	    4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values relationharm lblrelationharm
*</_relationharm_>

*<_relationcs_>
	gen byte relationcs = int(r103)
	label var relationcs "Relationship to head of household - Country original"
*</_relationcs_>

*<_marital_>
	/* <_marital_note>
	   r107: 1=Acompañado(a), 2=Casado(a), 3=Viudo(a), 4=Divorciado(a),
	         5=Separado(a), 6=Soltero(a)
	</_marital_note> */
	gen byte marital = .
	replace marital = 1 if int(r107) == 2              // Married
	replace marital = 2 if int(r107) == 6              // Single/Never married
	replace marital = 3 if int(r107) == 1              // Living together (acompañado)
	replace marital = 4 if inlist(int(r107), 4, 5)     // Divorced/Separated
	replace marital = 5 if int(r107) == 3              // Widowed
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" ///
	    4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>

*<_eye_dsablty_>
	gen eye_dsablty = .
	label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>

*<_hear_dsablty_>
	gen hear_dsablty = .
	label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>

*<_walk_dsablty_>
	gen walk_dsablty = .
	label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>

*<_conc_dsord_>
	gen conc_dsord = .
	label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>

*<_slfcre_dsablty_>
	gen slfcre_dsablty = .
	label var slfcre_dsablty "Disability related to self-care"
*</_slfcre_dsablty_>

*<_comm_dsablty_>
	gen comm_dsablty = .
	label var comm_dsablty "Disability related to communicating"
*</_comm_dsablty_>

}


/*%%=============================================================================================
	5: Migration
==============================================================================================%%*/

{

*<_migrated_mod_age_>
	gen migrated_mod_age = 0
	label var migrated_mod_age "Migration module minimum age"
*</_migrated_mod_age_>

*<_migrated_ref_time_>
	gen migrated_ref_time = .
	label var migrated_ref_time "Reference time applied to migration questions (years)"
*</_migrated_ref_time_>

*<_migrated_binary_>
	/* <_migrated_binary_note>
	   EHPM asks about household members in the exterior (r01a) but not
	   individual-level birth place or internal migration. Set missing.
	   Remittances are captured separately.
	</_migrated_binary_note> */
	gen byte migrated_binary = .
	la de lblmigrated_binary 0 "No" 1 "Yes"
	label values migrated_binary lblmigrated_binary
	label var migrated_binary "Individual has migrated (1=Yes)"
*</_migrated_binary_>

*<_migrated_years_>
	gen migrated_years = .
	label var migrated_years "Years since latest migration"
*</_migrated_years_>

*<_migrated_from_urban_>
	gen migrated_from_urban = .
	la de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>

*<_migrated_from_cat_>
	gen byte migrated_from_cat = .
	la de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" ///
	    3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country" ///
	    6 "Within country, admin unknown" 7 "Wholly unknown"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>

*<_migrated_from_code_>
	gen migrated_from_code = .
	label var migrated_from_code "Code of migration area as subnatid level"
*</_migrated_from_code_>

*<_migrated_from_country_>
	gen str3 migrated_from_country = ""
	label var migrated_from_country "Code of migration country (ISO 3 Letter)"
*</_migrated_from_country_>

*<_migrated_reason_>
	gen migrated_reason = .
	label var migrated_reason "Reason for migration"
*</_migrated_reason_>

}


/*%%=============================================================================================
	6: Education 
==============================================================================================%%*/

{

*<_ed_mod_age_>
	gen byte ed_mod_age = 0
	label var ed_mod_age "Education module minimum age"
*</_ed_mod_age_>

*<_school_>
	/* r203: 1=Sí estudia actualmente, 2=No */
	gen byte school = .
	replace school = 1 if int(r203) == 1
	replace school = 0 if int(r203) == 2
	replace school = . if age < ed_mod_age
	label var school "Attending school"
	la define lblschool 0 "No" 1 "Yes"
	label values school lblschool
*</_school_>

*<_literacy_>
	/* r202a: 1=Sí (literate), 2=No, 3=Sí sólo leer (partial) */
	gen byte literacy = .
	replace literacy = 1 if inlist(int(r202a), 1, 3)  // Can read (and write, or only read)
	replace literacy = 0 if int(r202a) == 2
	replace literacy = . if age < ed_mod_age
	label var literacy "Individual can read and write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>

*<_educy_>
	/* <_educy_note>
	   aproba1 = total approved years of education (DIGESTYC-computed).
	   This is the most direct measure; use as primary source.
	   Cross-check: r214 (level) + r215 (grade) can reconstruct if needed.
	   El Salvador system: Parvularia(0yr), Básica(1–9), Media(10–12),
	   Superior no-univ(13–15), Superior univ(13–17+)
	</_educy_note> */
	gen byte educy = int(aproba1) if !missing(aproba1) & aproba1 >= 0
	replace educy = . if educy > 25 | educy < 0
	replace educy = . if age < ed_mod_age
	label var educy "Years of education"
*</_educy_>

*<_educat7_>
	
	
	gen byte educat7 = .
	replace educat7 = 1 if inlist(int(r214), 8, 0, 1) | missing(r214)  // None/pre-primary
	replace educat7 = 1 if int(r214) == 6                               // Educación especial → no education
	replace educat7 = 2 if int(r214) == 2 & inrange(int(r215), 1, 5)   // Básica grades 1-5: primary incomplete
	replace educat7 = 3 if int(r214) == 2 & int(r215) == 6             // Básica grade 6: primary complete
	replace educat7 = 4 if int(r214) == 2 & inrange(int(r215), 7, 8)   // Básica grades 7-8: lower secondary incomplete
	replace educat7 = 4 if int(r214) == 2 & int(r215) == 9             // Básica grade 9: lower secondary complete — maps to 4 not 5 (Media not yet done)
	replace educat7 = 4 if int(r214) == 3 & inrange(int(r215), 10, 11) // Media grades 10-11: upper secondary incomplete
	replace educat7 = 5 if int(r214) == 3 & int(r215) >= 12            // Media grade 12+: secondary complete
	replace educat7 = 6 if int(r214) == 5                              // Superior no universitario
	replace educat7 = 7 if int(r214) == 4                              // Superior universitario
	replace educat7 = . if age < ed_mod_age
	label var educat7 "Level of education 1"
	la de lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	    4 "Secondary incomplete" 5 "Secondary complete" ///
	    6 "Higher than secondary but not university" 7 "University incomplete or complete"
	label values educat7 lbleducat7
*</_educat7_>
	


*<_educat5_>
	gen byte educat5 = educat7
	recode educat5 (4=3) (5=4) (6 7=5)
	label var educat5 "Level of education 2"
	la de lbleducat5 1 "No education" 2 "Primary incomplete" ///
	    3 "Primary complete but secondary incomplete" 4 "Secondary complete" ///
	    5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>

*<_educat4_>
	gen byte educat4 = educat7
	recode educat4 (2 3 4=2) (5=3) (6 7=4)
	label var educat4 "Level of education 3"
	la de lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 lbleducat4
*</_educat4_>

*<_educat_orig_>
	gen byte educat_orig = int(r214)
	label var educat_orig "Original survey education code"
*</_educat_orig_>

*<_educat_isced_>
	gen int educat_isced = .
	label var educat_isced "ISCED-2011 education code"
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
	/* r425a: Has participated in training course at employer's institution (1=Sí, 2=No) */
	gen byte vocational = .
	replace vocational = 1 if int(r425a) == 1
	replace vocational = 0 if int(r425a) == 2
	label var vocational "Individual received vocational training (at work)"
	la de lblvocational 0 "No" 1 "Yes"
	label values vocational lblvocational
*</_vocational_>

*<_vocational_type_>
	gen vocational_type = .
	label var vocational_type "Type of vocational training"
*</_vocational_type_>

*<_vocational_length_l_>
	gen vocational_length_l = .
	label var vocational_length_l "Length of training (lower bracket, months)"
*</_vocational_length_l_>

*<_vocational_length_u_>
	gen vocational_length_u = .
	label var vocational_length_u "Length of training (upper bracket, months)"
*</_vocational_length_u_>

*<_vocational_field_orig_>
	gen vocational_field_orig = .
	label var vocational_field_orig "Original field of vocational training"
*</_vocational_field_orig_>

*<_vocational_financed_>
	gen vocational_financed = .
	label var vocational_financed "Vocational training financed by"
*</_vocational_financed_>

}


/*%%=============================================================================================
	8: Labour Module
==============================================================================================%%*/

{


*<_minlaborage_>
	gen byte minlaborage = 16
	label var minlaborage "Minimum age for labor module (16, per DIGESTYC)"
*</_minlaborage_>

*----------8.1: 7 day reference overall------------------------------*


*<_lstatus_>
	/* <_lstatus_note>
	   actpr (DIGESTYC-derived labor status):
	     10 = Occupied (Employed)
	     20 = Unemployed (Desocupado: 21=Cessante, 22=Aspirante, etc.)
	     30 = Inactive
	</_lstatus_note> */
	gen byte lstatus = .
	replace lstatus = 1 if inrange(int(actpr), 10, 19)   // Employed 
	replace lstatus = 2 if inrange(int(actpr), 20, 29)   // Unemployed
	replace lstatus = 3 if inrange(int(actpr), 30, 39)   // Inactive
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>

*<_potential_lf_>
	gen byte potential_lf = .
	replace potential_lf = 1 if lstatus == 3 & int(r406c) == 1
	replace potential_lf = 0 if lstatus == 3 & int(r406c) == 2
	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labor force"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>

*<_underemployment_>
	/* <_underemployment_note>
	   actse: 2=Subempleo visible (time-related), 3=Subempleo invisible (income-related)
	   GLD underemployment = time-related (visible) only
	</_underemployment_note> */
	gen byte underemployment = .
	replace underemployment = 1 if lstatus == 1 & int(actse) == 2   // Subempleo visible
	replace underemployment = 0 if lstatus == 1 & !inlist(int(actse), 2, .)
	replace underemployment = . if lstatus != 1
	label var underemployment "Underemployment"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>

*<_nlfreason_>
	gen byte nlfreason = .
	replace nlfreason = 1 if lstatus == 3 & int(r409) == 8           // Student
	replace nlfreason = 2 if lstatus == 3 & inlist(int(r409), 9, 12) // Housekeeper/family duties
	replace nlfreason = 3 if lstatus == 3 & int(r409) == 13          // Retired/pensioned
	replace nlfreason = 4 if lstatus == 3 & inlist(int(r409), 10, 11, 14) // Disabled/sick
	replace nlfreason = 5 if lstatus == 3 & inlist(int(r409), 1, 2, 3, 4, 5, 6, 7, 15, 16, 17, 18) // Other
	replace nlfreason = . if lstatus != 3
	label var nlfreason "Reason not in labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired/Pensioned" ///
	    4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>

*<_unempldur_l_>
	/* r407a_m = months searching; r407a_s = weeks (if less than a month) */
	gen byte unempldur_l = .
	replace unempldur_l = int(r407a_m) if lstatus == 2 & !missing(r407a_m) & r407a_m > 0
	replace unempldur_l = 0 if lstatus == 2 & missing(unempldur_l) & !missing(r407a_s) & r407a_s > 0
	replace unempldur_l = . if lstatus != 2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>
	gen byte unempldur_u = unempldur_l
replace unempldur_u = 1 if lstatus == 2 & !missing(r407a_s) & r407a_s > 0 & missing(r407a_m)
	replace unempldur_u = . if lstatus != 2	
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}

*----------8.2: 7 day reference main job------------------------------*

{
*<_empstat_>
	/* <_empstat_note>
	   r418 (Categoría ocupacional):
	     1=Empleador(a)/patrono(a) → 3 (Employer)
	     2=Cuenta propia con local, 3=Cuenta propia sin local → 4 (Self-employed)
	     4=Cooperativista → 4 (Self-employed)
	     5=Familiar no remunerado → 2 (Non-Paid Employee)
	     6=Asalariado(a) permanente, 7=Asalariado(a) temporal → 1 (Paid Employee)
	     8=Aprendiz → 2 (Non-Paid Employee)
	     9=Servicio doméstico → 1 (Paid Employee)
	     10=Otros → 5 (Other)
	</_empstat_note> */
	gen byte empstat = .
	replace empstat = 1 if inlist(int(r418), 6, 7, 9)    // Salaried permanent/temp + domestic
	replace empstat = 2 if inlist(int(r418), 5, 8)       // Unpaid family + apprentice
	replace empstat = 3 if int(r418) == 1                 // Employer
	replace empstat = 4 if inlist(int(r418), 2, 3, 4)    // Own-account (with/without premises, cooperative)
	replace empstat = 5 if int(r418) == 10               // Other
	replace empstat = . if lstatus != 1
	label var empstat "Employment status, primary job 7 day recall"
	la de lblempstat 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" ///
	    4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>

*<_ocusec_>
	/* <_ocusec_note>
	   r420: 1=Privado → 2, 2=Público → 1, 3=Organismo internacional → 2, 4=Otros → 4
	</_ocusec_note> */
	gen byte ocusec = .
	replace ocusec = 1 if int(r420) == 2   // Público
	replace ocusec = 2 if inlist(int(r420), 1, 3)  // Privado + Org. internacional
	replace ocusec = 4 if int(r420) == 4   // Others (cannot distinguish)
	replace ocusec = . if lstatus != 1
	label var ocusec "Sector of activity, primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>

*<_industry_orig_>
	/* r416 = raw CIIU Rev.4 code; ciiu416 = DIGESTYC 14-cat aggregation */
	gen industry_orig = r416 if lstatus == 1 & !missing(r416) 
	replace industry_orig = . if lstatus != 1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	gen industrycat_isic= r416
	replace industrycat_isic= . if lstatus!=1
	label var industrycat_isic "ISIC code of primary job 7 day recall"
*</_industrycat_isic_>


*<_industrycat10_>

	gen ind_helper = floor(r416 / 100) if lstatus == 1
	gen byte industrycat10 = .
	replace industrycat10 = 1  if inrange(ind_helper, 1, 3)            // Agriculture, forestry, fishing
	replace industrycat10 = 2  if inrange(ind_helper, 5, 9)            // Mining
	replace industrycat10 = 3  if inrange(ind_helper, 10, 33)          // Manufacturing
	replace industrycat10 = 4  if inrange(ind_helper, 35, 39)          // Electricity, gas, water
	replace industrycat10 = 5  if inrange(ind_helper, 41, 43)          // Construction
	replace industrycat10 = 6  if inrange(ind_helper, 45, 47) | inrange(ind_helper, 55, 56) // Commerce, hotels, restaurants
	replace industrycat10 = 7  if inrange(ind_helper, 49, 53) | inrange(ind_helper, 58, 63) // Transport, communications
	replace industrycat10 = 8  if inrange(ind_helper, 64, 82)          // Financial and business services
	replace industrycat10 = 9  if ind_helper == 84                     // Public administration
	replace industrycat10 = 10 if inrange(ind_helper, 85, 99)          // Other services
	replace industrycat10 = .  if lstatus != 1 | (age < minlaborage & age != .)
	drop ind_helper
	label var industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de lblindustrycat10 1 "Agriculture" 2 "Mining" 3 "Manufacturing" ///
	    4 "Public utilities" 5 "Construction" 6 "Commerce" ///
	    7 "Transport and Communications" 8 "Financial and Business Services" ///
	    9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 lblindustrycat10
*</_industrycat10_>*

*<_industrycat4_>
	gen byte industrycat4 = industrycat10
	recode industrycat4 (1=1)(2 3 4 5=2)(6 7 8 9=3)(10=4)
	replace industrycat4 = . if lstatus != 1
	label var industrycat4 "1 digit industry classification (Broad Economic Activities), primary job 7 day recall"
	la de lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 lblindustrycat4
*</_industrycat4_>

*<_occup_orig_>
	gen occup_orig = r414 if lstatus == 1
	replace occup_orig = . if lstatus != 1
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>

*<_occup_isco_>
	gen occup_isco = string((occup_orig), "%04.0f") if lstatus == 1 & !missing(occup_orig)
	replace occup_isco = "" if lstatus != 1
	label var occup_isco "ISCO code of primary job 7 day recall"
*</_occup_isco_>

*<_occup_>
	destring occup_isco, gen(occup_helper)
	gen byte occup = floor(occup_helper / 1000)
	replace occup = 10 if occup == 0   // Armed Forces (ISCO major group 0) → 10
	drop occup_helper
	replace occup = . if lstatus != 1
	label var occup "1 digit occupational classification, primary job 7 day recall"
	la de lbloccup 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	    5 "Service and market sales workers" 6 "Skilled agricultural" ///
	    7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" ///
	    10 "Armed forces" 99 "Others"
	label values occup lbloccup
*</_occup_>

*<_occup_skill_>
	gen byte occup_skill = .
	replace occup_skill = 3 if inlist(occup, 1, 2, 3)
	replace occup_skill = 2 if inlist(occup, 4, 5, 6, 7, 8)
	replace occup_skill = 1 if occup == 9
	replace occup_skill = . if lstatus != 1
	label var occup_skill "Skill based on ISCO standard primary job 7 day recall"
	la de lbloccup_skill 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill lbloccup_skill
*</_occup_skill_>

*<_wage_no_compen_>
	/* <_wage_no_compen_note>
	   For salaried workers: r424 = ingreso mensualizado por trabajo dependiente (gross).
	   Wages are in USD, monthly.
	   r424 is gross salary (before deductions); it is the closest to wage_no_compen
	   as it excludes in-kind benefits captured separately in r42505a–r42512a.
	</_wage_no_compen_note> */
*<_wage_no_compen_>
	gen double wage_no_compen = .
	replace wage_no_compen = r424 if empstat == 1 & lstatus == 1 & !missing(r424) & r424 > 0
	replace wage_no_compen = 0    if empstat == 2 & lstatus == 1   // non-paid = 0
	* Note: self-employed (empstat=4) and employers (empstat=3) left missing
	replace wage_no_compen = . if lstatus != 1
	label var wage_no_compen "Last wage payment, primary job, excl. non-wage comp. (USD monthly)"
*</_wage_no_compen_>*

*<_unitwage_>
	gen byte unitwage = 5   // Monthly in all years
	replace unitwage = . if missing(wage_no_compen)
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Twice monthly" ///
	    5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" ///
	    9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>

*<_whours_>
	/* <_whours_note>
	   h411a = actual hours worked last week (preferred).
	   h412a = usual weekly hours (fallback if h411a missing).
	</_whours_note> */
	gen whours = h411a if lstatus == 1 & !missing(h411a) & h411a > 0
	replace whours = h412a if lstatus == 1 & missing(whours) & !missing(h412a) & h412a > 0
	replace whours = . if whours > 168 | whours <= 0
	replace whours = . if lstatus != 1
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>

*<_wmonths_>
	gen wmonths = .
	label var wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
	gen wage_total = .
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>

*<_contract_>
	/* <_contract_note>
	   r419: Has signed work contract?
	     1=Sí, indefinite → contract=1 (permanent written contract)
	     2=Sí, plazo fijo → contract=1 (fixed-term written contract)
	     3=Sí, prueba; 4=Sí, servicio; 5=Sí, interinato; 6=Sí otro → contract=1
	     7=No → contract=0
	     8=No sabe/no responde → missing
	   GLD: contract=1 if any written/signed contract exists.
	</_contract_note> */
	gen byte contract = .
	replace contract = 1 if inlist(int(r419), 1, 2, 3, 4, 5, 6) & lstatus == 1
	replace contract = 0 if int(r419) == 7 & lstatus == 1
	replace contract = . if int(r419) == 8
	replace contract = . if lstatus != 1
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>

*<_healthins_>
	/* <_healthins_note>
	   El Salvador has three public health insurance schemes:
	   r422a = ISSS (general employees) — 1=afiliado, 2=cotizante, 3=No
	   r422b = Bienestar Magisterial (teachers) — mutually exclusive with ISSS
	   r422c = IPSFA (military) — mutually exclusive with ISSS
	   healthins=1 if covered by any public health scheme.
	   r422d (seguro colectivo) and r422e (seguro privado) excluded as these
	   are private/employer schemes, not social health insurance.
	</_healthins_note> */
	gen byte healthins = .
	replace healthins = 1 if lstatus == 1 & inlist(int(r422a), 1, 2)   // ISSS
	replace healthins = 1 if lstatus == 1 & inlist(int(r422b), 1, 2)   // Bienestar Magisterial
	replace healthins = 1 if lstatus == 1 & inlist(int(r422c), 1, 2)   // IPSFA (military)
	replace healthins = 0 if lstatus == 1 & missing(healthins)          // None of the above
	replace healthins = . if lstatus != 1
	label var healthins "Health insurance (ISSS/Bienestar Magisterial/IPSFA) coverage"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>

*<_socialsec_>
	/* <_socialsec_note>
	   r422f = AFP (private pension, mandatory for private sector) — 1=afiliado, 2=cotizante
	   r422g = INPEP (public sector pension) — 1=afiliado, 2=cotizante
	   socialsec=1 if contributing to any pension scheme.
	</_socialsec_note> */
	gen byte socialsec = .
	replace socialsec = 1 if lstatus == 1 & inlist(int(r422f), 1, 2)   // AFP
	replace socialsec = 1 if lstatus == 1 & inlist(int(r422g), 1, 2)   // INPEP
	replace socialsec = 0 if lstatus == 1 & missing(socialsec)          // Neither
	replace socialsec = . if lstatus != 1
	label var socialsec "Social security (AFP/INPEP pension) coverage"
	la de lblsocialsec 0 "Not covered" 1 "Covered"
	label values socialsec lblsocialsec
*</_socialsec_>

*<_union_>
	/* r443b2: Is active member of a labor union (sindicato)? (1=Sí, 2=No) */
	gen byte union = .
	replace union = 1 if int(r443b2) == 1 & lstatus == 1
	replace union = 0 if int(r443b2) == 2 & lstatus == 1
	replace union = . if lstatus != 1
	label var union "Union membership"
	la de lblunion 0 "Not a union member" 1 "Union member"
	label values union lblunion
*</_union_>

*<_firmsize_l_>
	/* r421: exact firm size. Special codes: 0=own-account (alone), 
	   99/98/988/995/998 = don't know. r421a: bracket fallback. */
	gen firmsize_l = .
	* Recode don't know codes to missing first
	replace firmsize_l = r421 if !missing(r421) & !inlist(r421, 98, 99, 988, 995, 998) & lstatus == 1
	replace firmsize_l = 1    if r421 == 0 & lstatus == 1   // solo own-account → size 1
	replace firmsize_l = 1    if missing(firmsize_l) & int(r421a) == 1 & lstatus == 1
	replace firmsize_l = 5    if missing(firmsize_l) & int(r421a) == 2 & lstatus == 1
	replace firmsize_l = 11   if missing(firmsize_l) & int(r421a) == 3 & lstatus == 1
	replace firmsize_l = 51   if missing(firmsize_l) & int(r421a) == 4 & lstatus == 1
	replace firmsize_l = 101  if missing(firmsize_l) & int(r421a) == 5 & lstatus == 1
	replace firmsize_l = .    if lstatus != 1
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>

*<_firmsize_u_>
	gen firmsize_u = .
	replace firmsize_u = r421 if !missing(r421) & !inlist(r421, 98, 99, 988, 995, 998) & lstatus == 1
	replace firmsize_u = 1    if r421 == 0 & lstatus == 1
	replace firmsize_u = 4    if missing(firmsize_u) & int(r421a) == 1 & lstatus == 1
	replace firmsize_u = 10   if missing(firmsize_u) & int(r421a) == 2 & lstatus == 1
	replace firmsize_u = 50   if missing(firmsize_u) & int(r421a) == 3 & lstatus == 1
	replace firmsize_u = 100  if missing(firmsize_u) & int(r421a) == 4 & lstatus == 1
	replace firmsize_u = .    if missing(firmsize_u) & int(r421a) == 5 & lstatus == 1
	replace firmsize_u = .    if lstatus != 1
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


*<_lstatus_2_>
	/* r432: Has secondary occupation? 1=Sí, 2=No */
	gen byte lstatus_2 = .
	replace lstatus_2 = 1 if int(r432) == 1 & lstatus == 1
	replace lstatus_2 = . if lstatus != 1
	label var lstatus_2 "Labor status, secondary job 7 day recall"
	la de lbllstatus_2 1 "Employed"
	label values lstatus_2 lbllstatus_2
*</_lstatus_2_>

*<_empstat_2_>
	/* EHPM does not ask employment category for secondary job */
	gen byte empstat_2 = .
	replace empstat_2 = . if lstatus_2 != 1
	label var empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 lblempstat
*</_empstat_2_>

*<_ocusec_2_>
	gen byte ocusec_2 = .
	replace ocusec_2 = . if lstatus_2 != 1
	label var ocusec_2 "Sector of activity, secondary job 7 day recall"
	label values ocusec_2 lblocusec
*</_ocusec_2_>

*<_industry_orig_2_>
	gen industry_orig_2 = r438 if lstatus_2 == 1 & !missing(r438) & r438 > 0
	replace industry_orig_2 = . if lstatus_2 != 1
	label var industry_orig_2 "Original industry code, secondary job 7 day recall "
*</_industry_orig_2_>

*<_industrycat10_2_>
	/* Use raw 4-digit r438 → floor/100 for 2-digit ISIC division, same as primary */
	gen ind_helper_2 = floor(r438 / 100) if lstatus_2 == 1
	gen byte industrycat10_2 = .
	replace industrycat10_2 = 1  if inrange(ind_helper_2, 1, 3)
	replace industrycat10_2 = 2  if inrange(ind_helper_2, 5, 9)
	replace industrycat10_2 = 3  if inrange(ind_helper_2, 10, 33)
	replace industrycat10_2 = 4  if inrange(ind_helper_2, 35, 39)
	replace industrycat10_2 = 5  if inrange(ind_helper_2, 41, 43)
	replace industrycat10_2 = 6  if inrange(ind_helper_2, 45, 47) | inrange(ind_helper_2, 55, 56)
	replace industrycat10_2 = 7  if inrange(ind_helper_2, 49, 53) | inrange(ind_helper_2, 58, 63)
	replace industrycat10_2 = 8  if inrange(ind_helper_2, 64, 82)
	replace industrycat10_2 = 9  if ind_helper_2 == 84
	replace industrycat10_2 = 10 if inrange(ind_helper_2, 85, 99)
	replace industrycat10_2 = .  if lstatus_2 != 1 | (age < minlaborage & age != .)
	drop ind_helper_2
	label var industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
	label values industrycat10_2 lblindustrycat10
*</_industrycat10_2_>

*<_industrycat4_2_>
	gen byte industrycat4_2 = industrycat10_2
	recode industrycat4_2 (1=1)(2 3 4 5=2)(6 7 8 9=3)(10=4)
	replace industrycat4_2 = . if lstatus_2 != 1
	label var industrycat4_2 "1 digit industry classification (4 categories), secondary job 7 day recall"
	label values industrycat4_2 lblindustrycat4
*</_industrycat4_2_>

*<_occup_orig_2_>
	/* r436 = raw 4-digit ISCO-08 code, all 4-digit (no 3-digit cases) */
	gen occup_orig_2 = r436 if lstatus_2 == 1
	replace occup_orig_2 = . if lstatus_2 != 1
	label var occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>

*<_occup_isco_2_>
	gen occup_isco_2 = string((occup_orig_2), "%04.0f") if lstatus_2 == 1 & !missing(occup_orig_2)
	replace occup_isco_2 = "" if lstatus_2 != 1
	label var occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>

*<_occup_2_>
	destring occup_isco_2, gen(occup_helper_2)
	gen byte occup_2 = floor(occup_helper_2 / 1000)
	replace occup_2 = 10 if occup_2 == 0   // Armed Forces → 10
	drop occup_helper_2
	replace occup_2 = . if lstatus_2 != 1
	label var occup_2 "1 digit occupational classification, secondary job 7 day recall"
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
	replace wage_no_compen_2 = r434 if lstatus_2 == 1 & !missing(r434) & r434 > 0
	replace wage_no_compen_2 = . if lstatus_2 != 1
	label var wage_no_compen_2 "Last wage payment, secondary job, excl. non-wage comp. (USD monthly)"
*</_wage_no_compen_2_>

*<_unitwage_2_>
	gen byte unitwage_2 = 5
	replace unitwage_2 = . if missing(wage_no_compen_2)
	label var unitwage_2 "Time unit of last wage payment, secondary job"
	label values unitwage_2 lblunitwage
*</_unitwage_2_>

*<_whours_2_>
	/* r433 = weekly hours for secondary job */
	gen whours_2 = r433 if lstatus_2 == 1 & !missing(r433) & r433 > 0
	replace whours_2 = . if whours_2 > 168 | whours_2 <= 0
	replace whours_2 = . if lstatus_2 != 1
	label var whours_2 "Hours worked last week, secondary job"
*</_whours_2_>

*<_wmonths_2_>
	gen byte wmonths_2 =.
	label var wmonths_2 "Months of work in past 12 months secondary job 7 day recall"
*</_wmonths_2_>

*<_wage_total_2_>
	gen double wage_total_2 = .
	label var wage_total_2 "Annualized total wage secondary job 7 day recall"
*</_wage_total_2_>

*<_firmsize_l_2_>
	/* r439: exact count. Special codes: 0=alone (→1), 988/998=don't know.
	   r439_1: bracket fallback (1=0-4, 2=5-10, 3=11-50, 4=51-100, 5=100+) */
	gen firmsize_l_2 = .
	replace firmsize_l_2 = r439  if !missing(r439) & !inlist(r439, 988, 998) & r439 > 0 & lstatus_2 == 1
	replace firmsize_l_2 = 1     if r439 == 0 & lstatus_2 == 1   // solo worker → size 1
	replace firmsize_l_2 = 1     if missing(firmsize_l_2) & int(r439_1) == 1 & lstatus_2 == 1
	replace firmsize_l_2 = 5     if missing(firmsize_l_2) & int(r439_1) == 2 & lstatus_2 == 1
	replace firmsize_l_2 = 11    if missing(firmsize_l_2) & int(r439_1) == 3 & lstatus_2 == 1
	replace firmsize_l_2 = 51    if missing(firmsize_l_2) & int(r439_1) == 4 & lstatus_2 == 1
	replace firmsize_l_2 = 101   if missing(firmsize_l_2) & int(r439_1) == 5 & lstatus_2 == 1
	replace firmsize_l_2 = .     if lstatus_2 != 1
	label var firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>

*<_firmsize_u_2_>
	gen firmsize_u_2 = .
	replace firmsize_u_2 = r439  if !missing(r439) & !inlist(r439, 988, 998) & r439 > 0 & lstatus_2 == 1
	replace firmsize_u_2 = 1     if r439 == 0 & lstatus_2 == 1
	replace firmsize_u_2 = 4     if missing(firmsize_u_2) & int(r439_1) == 1 & lstatus_2 == 1
	replace firmsize_u_2 = 10    if missing(firmsize_u_2) & int(r439_1) == 2 & lstatus_2 == 1
	replace firmsize_u_2 = 50    if missing(firmsize_u_2) & int(r439_1) == 3 & lstatus_2 == 1
	replace firmsize_u_2 = 100   if missing(firmsize_u_2) & int(r439_1) == 4 & lstatus_2 == 1
	replace firmsize_u_2 = .     if missing(firmsize_u_2) & int(r439_1) == 5 & lstatus_2 == 1
	replace firmsize_u_2 = .     if lstatus_2 != 1
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
	replace lstatus_year = . if age < minlaborage & !missing(age)
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>

*<_potential_lf_year_>
	gen byte potential_lf_year = .
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
	gen byte nlfreason_year = .
	label var nlfreason_year "Reason not in the labor force"
	la de lblnlfreason_year 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
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

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	preserve 
	*drop if missing(industrycat_isic_year)
	*int_classif_universe, var(industrycat_isic_year) universe(ISIC)
	count
	*list
	*assert `r(N)' == 0
	restore 

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
	recode industrycat4_year (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
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

	* Check that no errors --> using our universe check function, count should be 0 (no obs wrong)
	* https://github.com/worldbank/gld/tree/main/Support/Z%20-%20GLD%20Ecosystem%20Tools/ISIC%20ISCO%20universe%20check
	preserve 
	*drop if missing(occup_isco_year)
	*int_classif_universe, var(occup_isco_year) universe(ISCO)
	count
	*list
	*assert `r(N)' == 0
	restore

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
	gen byte industrycat4_2_year = industrycat10_2_year
	recode industrycat4_2_year (1 = 1) (2 3 4 5 = 2) (6 7 8 9 = 3) (10 = 4)
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

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu ssu strata wave  urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>
	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu ssu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

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

// save "`path_output'/`out_file'", replace

*</_% SAVE_>

save "C:\Users\wb584706\OneDrive - WBG\Honduras\Data\Comparision Countries\El Salvador\SLV_2021_EHPM\SLV_2021_EHPM_V01_M_V01_A_GLD\Data\Harmonized\SLV_2021_EHPM_V01_M_V01_A_GLD.dta"


