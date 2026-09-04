/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				BGD_2024_QLFS_V01_M_V01_A_GLD.do </_Program name_>
<_Application_>					Stata 17 </_Application_>
<_Author(s)_>					World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_>				2026-07-30 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						Bangladesh (BGD) </_Country_>
<_Survey Title_>				Bangladesh Quarterly Labour Force Survey (QLFS) </_Survey Title_>
<_Survey Year_>					2024 </_Survey Year_>
<_Study ID_>					BGD_2024_QLFS </_Study ID_>
<_Data collection from_>		01/2024 </_Data collection from_>
<_Data collection to_>			12/2024 </_Data collection to_>
<_Source of dataset_> 			Bangladesh Bureau of Statistics (BBS) </_Source of dataset_>
<_Sample size (HH)_> 			 </_Sample size (HH)_>
<_Sample size (IND)_> 			 </_Sample size (IND)_>
<_Sampling method_> 			Stratified multi-stage probability sampling </_Sampling method_>
<_Geographic coverage_> 		 </_Geographic coverage_>
<_Currency_> 					Bangladeshi Taka (BDT) </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS 19th Conference (ICLS-19, 2013 standards) </_ICLS Version_>
<_ISCED Version_>				ISCED 2011 </_ISCED Version_>
<_ISCO Version_>				ISCO-08 </_ISCO Version_>
<_OCCUP National_>				BBS adapted national occupational classification aligned to ISCO-08 </_OCCUP National_>
<_ISIC Version_>				ISIC Rev.4 </_ISIC Version_>
<_INDUS National_>				BBS national industry classification mapped to ISIC Rev.4 </_INDUS National_>
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
local server  "C:/Users/wb611670/WBG/GLD - 611670_SF"
local country "BGD"
local year    "2024"
local survey  "QLFS"
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

*================ Q1 2024 =================

*============================================================
* 1. Roster and disability
*    Identify duplicated households and create HHNO mapping
*============================================================

use "`path_in_stata'/BBS_LFS_Q1_2024_Roster_Disability.dta", clear

* Preserve original observation order
gen long _order = _n

*------------------------------------------------------------
* Identify duplicated households
*
* A duplicated household is defined as having the same:
* QUARTER HHNO PSU EAUM
* with duplicated person IDs (HR_LN)
*------------------------------------------------------------

duplicates tag QUARTER HHNO PSU EAUM HR_LN, gen(_dup)

bysort QUARTER HHNO PSU EAUM: egen byte _duphh = max(_dup > 0)

*------------------------------------------------------------
* Identify the second household within each duplicated HHNO
*
* HR_LN restarts/decreases when the second household begins
*------------------------------------------------------------

bysort QUARTER HHNO PSU EAUM (_order): ///
    gen byte _copy = ///
    sum(HR_LN <= HR_LN[_n-1] & _n > 1) ///
    if _duphh == 1

replace _copy = 0 if _duphh == 1 & missing(_copy)

*------------------------------------------------------------
* Give each duplicated household group a sequential number
* and assign new HHNO:
*
* group 1 -> 999
* group 2 -> 998
* group 3 -> 997
* ...
*------------------------------------------------------------

egen long _hhgroup = group(QUARTER HHNO PSU EAUM) if _duphh == 1

gen long _newhhno = 1000 - _hhgroup if _duphh == 1

*------------------------------------------------------------
* Save household-level mapping
*------------------------------------------------------------

preserve

    keep if _duphh == 1
    keep QUARTER HHNO PSU EAUM _newhhno
    duplicates drop QUARTER HHNO PSU EAUM, force
    tempfile q1_hhmap
    save `q1_hhmap', replace

restore

*------------------------------------------------------------
* Recode duplicated copy in roster
*------------------------------------------------------------

gen byte _recodehh = (_duphh == 1 & _copy >= 1)
replace HHNO = _newhhno if _recodehh

* Reassign person IDs in corrected households:
* 99, 98, 97, 96, ...
bysort QUARTER PSU EAUM HHNO (_order): replace HR_LN = 100 - _n if _recodehh

* Check corrected households
list QUARTER PSU EAUM HHNO HR_LN ///
    if _recodehh, ///
    sepby(QUARTER PSU EAUM HHNO)


drop _order _dup _duphh _copy _hhgroup _newhhno _recodehh

tempfile q1_roster
save `q1_roster', replace

*============================================================
* 2. Socio-economic
*============================================================

use "`path_in_stata'/BBS_LFS_Q1_2024_Socio_Economic.dta", clear

gen long _order = _n

* Attach duplicate-household mapping
merge m:1 QUARTER HHNO PSU EAUM using `q1_hhmap', keep(master match) nogen

*------------------------------------------------------------
* For duplicated HHNOs:
* keep first household unchanged;
* assign new HHNO to second copy
*------------------------------------------------------------

bysort QUARTER HHNO PSU EAUM (_order): gen byte _copy = _n - 1 if !missing(_newhhno)

replace HHNO = _newhhno if !missing(_newhhno) & _copy >= 1
drop _order _copy _newhhno

tempfile q1_socio_econ
save `q1_socio_econ', replace

*============================================================
* 3. Employment and education
*============================================================

use "`path_in_stata'/BBS_LFS_Q1_2024_Employment_Education.dta", clear

* Remove observations with missing person IDs
drop if missing(EMP_HRLN)

gen long _order = _n

* Attach duplicate-household mapping
merge m:1 QUARTER HHNO PSU EAUM using `q1_hhmap', keep(master match) nogen

*------------------------------------------------------------
* Identify second household based on person-ID restart
*------------------------------------------------------------

bysort QUARTER HHNO PSU EAUM (_order): ///
    gen byte _copy = ///
    sum(EMP_HRLN <= EMP_HRLN[_n-1] & _n > 1) ///
    if !missing(_newhhno)

replace _copy = 0 if !missing(_newhhno) & missing(_copy)

gen byte _recodehh = (!missing(_newhhno) & _copy >= 1)

* Assign new HHNO
replace HHNO = _newhhno if _recodehh

* Assign new person IDs:
* 99, 98, 97, ...
bysort QUARTER PSU EAUM HHNO (_order): replace EMP_HRLN = 100 - _n if _recodehh

drop _order _copy _newhhno _recodehh

tempfile q1_edu
save `q1_edu', replace

*============================================================
* 4. Migration
*============================================================

use "`path_in_stata'/BBS_LFS_Q1_2024_Migration.dta", clear

* Remove observations with missing person IDs
drop if missing(MGT_LN)

gen long _order = _n

* Attach duplicate-household mapping
merge m:1 QUARTER HHNO PSU EAUM using `q1_hhmap', keep(master match) nogen

*------------------------------------------------------------
* Identify second household based on person-ID restart
*------------------------------------------------------------

bysort QUARTER HHNO PSU EAUM (_order): ///
    gen byte _copy = ///
    sum(MGT_LN <= MGT_LN[_n-1] & _n > 1) ///
    if !missing(_newhhno)

replace _copy = 0 if !missing(_newhhno) & missing(_copy)

gen byte _recodehh = (!missing(_newhhno) & _copy >= 1)

* Assign new HHNO
replace HHNO = _newhhno if _recodehh

* Assign new person IDs:
* 99, 98, 97, ...
bysort QUARTER PSU EAUM HHNO (_order): replace MGT_LN = 100 - _n if _recodehh

drop _order _copy _newhhno _recodehh

tempfile q1_mgt
save `q1_mgt', replace

*============================================================
* 5. Merge Q1 modules
*============================================================

use `q1_roster', clear
merge m:1 QUARTER HHNO PSU EAUM using `q1_socio_econ', nogen

gen EMP_HRLN = HR_LN
drop if missing(EMP_HRLN)

merge 1:1 QUARTER HHNO PSU EAUM EMP_HRLN using `q1_edu', nogen

gen MGT_LN = EMP_HRLN
drop if missing(MGT_LN)

merge 1:1 QUARTER HHNO PSU EAUM MGT_LN using `q1_mgt', nogen

tempfile q1_data
save `q1_data', replace

*================ Q2 2024 =================
use "`path_in_stata'/BBS_LFS_Q2_2024_Roster_Disability.dta", clear

merge m:1 QUARTER HHNO PSU EAUM using ///
    "`path_in_stata'/BBS_LFS_Q2_2024_Socio_Economic.dta", nogen

gen EMP_HRLN = HR_LN

merge 1:1 QUARTER HHNO PSU EAUM EMP_HRLN using ///
    "`path_in_stata'/BBS_LFS_Q2_2024_Employment_Education.dta", nogen
drop if missing(EMP_HRLN)

gen MGT_LN = EMP_HRLN

merge 1:1 QUARTER HHNO PSU EAUM MGT_LN using ///
    "`path_in_stata'/BBS_LFS_Q2_2024_Migration.dta", nogen
drop if missing(MGT_LN)

tempfile q2_data
save `q2_data', replace

*================ Q3 2024 =================
use "`path_in_stata'/BBS_LFS_Q3_2024_Roster_Disability.dta", clear

merge m:1 QUARTER HHNO PSU EAUM using ///
    "`path_in_stata'/BBS_LFS_Q3_2024_Socio_Economic.dta", nogen

gen EMP_HRLN = HR_LN

merge 1:1 QUARTER HHNO PSU EAUM EMP_HRLN using ///
    "`path_in_stata'/BBS_LFS_Q3_2024_Employment_Education.dta", nogen
drop if missing(EMP_HRLN)

gen MGT_LN = EMP_HRLN

merge 1:1 QUARTER HHNO PSU EAUM MGT_LN using ///
    "`path_in_stata'/BBS_LFS_Q3_2024_Migration.dta", nogen
drop if missing(MGT_LN)

tempfile q3_data
save `q3_data', replace


*================ Q4 2024 =================

*---------------- Roster: identify duplicate households ----------------
use "`path_in_stata'/BBS_LFS_Q4_2024_Roster_Disability.dta", clear

gen long _order = _n
duplicates tag QUARTER HHNO PSU EAUM HR_LN, gen(_dup)
bys QUARTER HHNO PSU EAUM: egen byte _duphh = max(_dup > 0)
bys QUARTER HHNO PSU EAUM (_order): gen byte _copy = ///
    sum(HR_LN <= HR_LN[_n-1] & _n > 1) if _duphh
replace _copy = 0 if _duphh & missing(_copy)

egen _hhgroup = group(QUARTER HHNO PSU EAUM) if _duphh
gen _newhhno = 1000 - _hhgroup if _duphh

preserve
keep if _duphh
keep QUARTER HHNO PSU EAUM _newhhno
duplicates drop
tempfile q4_hhmap
save `q4_hhmap', replace
restore

gen byte _recode = _duphh & _copy >= 1
replace HHNO = _newhhno if _recode
bys QUARTER PSU EAUM HHNO (_order): replace HR_LN = 100 - _n if _recode
drop _order _dup _duphh _copy _hhgroup _newhhno _recode

tempfile q4_roster
save `q4_roster', replace


*---------------- Socio-economic ----------------
use "`path_in_stata'/BBS_LFS_Q4_2024_Socio_Economic.dta", clear
gen _order = _n
merge m:1 QUARTER HHNO PSU EAUM using `q4_hhmap', keep(master match) nogen
bys QUARTER HHNO PSU EAUM (_order): gen _copy = _n - 1 if !missing(_newhhno)
replace HHNO = _newhhno if !missing(_newhhno) & _copy >= 1
drop _order _copy _newhhno

tempfile q4_socio_econ
save `q4_socio_econ', replace


*---------------- Employment and education ----------------
use "`path_in_stata'/BBS_LFS_Q4_2024_Employment_Education.dta", clear
drop if missing(EMP_HRLN)

gen _order = _n
merge m:1 QUARTER HHNO PSU EAUM using `q4_hhmap', keep(master match) nogen
bys QUARTER HHNO PSU EAUM (_order): gen _copy = ///
    sum(EMP_HRLN <= EMP_HRLN[_n-1] & _n > 1) if !missing(_newhhno)
replace _copy = 0 if !missing(_newhhno) & missing(_copy)
gen _recode = !missing(_newhhno) & _copy >= 1
replace HHNO = _newhhno if _recode
bys QUARTER PSU EAUM HHNO (_order): replace EMP_HRLN = 100 - _n if _recode
drop _order _copy _newhhno _recode

tempfile q4_edu
save `q4_edu', replace


*---------------- Migration ----------------
use "`path_in_stata'/BBS_LFS_Q4_2024_Migration.dta", clear
drop if missing(MGT_LN)

gen _order = _n
merge m:1 QUARTER HHNO PSU EAUM using `q4_hhmap', keep(master match) nogen
bys QUARTER HHNO PSU EAUM (_order): gen _copy = ///
    sum(MGT_LN <= MGT_LN[_n-1] & _n > 1) if !missing(_newhhno)
replace _copy = 0 if !missing(_newhhno) & missing(_copy)
gen _recode = !missing(_newhhno) & _copy >= 1
replace HHNO = _newhhno if _recode
bys QUARTER PSU EAUM HHNO (_order): replace MGT_LN = 100 - _n if _recode
drop _order _copy _newhhno _recode

tempfile q4_mgt
save `q4_mgt', replace


*---------------- Merge Q4 ----------------
use `q4_roster', clear

merge m:1 QUARTER HHNO PSU EAUM using `q4_socio_econ', nogen

gen EMP_HRLN = HR_LN
drop if missing(EMP_HRLN)
merge 1:1 QUARTER HHNO PSU EAUM EMP_HRLN using `q4_edu', nogen

gen MGT_LN = EMP_HRLN
merge 1:1 QUARTER HHNO PSU EAUM MGT_LN using `q4_mgt', nogen

tempfile q4_data
save `q4_data', replace


* Append all quarters into a single dataset
clear
append using `q1_data' `q2_data' `q3_data' `q4_data'

use "`path_in_stata'/BGD_2024_QLFS_V01_M.dta", clear


/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{


*<_countrycode_>
	gen str4 countrycode = "BGD"
	label var countrycode "Country code"
*</_countrycode_>


*<_survname_>
	gen survname = "QLFS"
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
	gen isced_version = "ISCED 2011"
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
    gen int year = 2024
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
    gen int_year = 2024
    label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
    gen int_month = V1_MONTH
    replace int_month = V2_MONTH if missing(int_month)
    replace int_month = V3_MONTH if missing(int_month)
    replace int_month = . if int_month > 12

    label define lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" ///
                               7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
    label values int_month lblint_month
    label var int_month "Month of the interview"
*</_int_month_>


*<_hhid_>
    /* <_hhid_note>
        The variable should be a string made up of the elements to define it, that is psu code, ssu, ...
        Each element should always be as long as needed for the longest element. That is, if there are
        60 psu coded 1 through 60, codes should be 01, 02, ..., 60. If there are 160 it should be 001,
        002, ..., 160.
    </_hhid_note> */
    gen psu_str = string(PSU, "%04.0f")
    gen eaum_str  = string(EAUM, "%03.0f")
    gen hh_str  = string(HHNO, "%03.0f")
    egen hhid = concat(psu_str eaum_str hh_str)
    label var hhid "Household ID"
*</_hhid_>


*<_pid_>
    gen lineno_str = string(EMP_HRLN, "%02.0f")
	replace lineno_str = string(HR_LN, "%02.0f") if missing(lineno_str)
    gen mgt_str  = string(MGT_LN, "%03.0f")
    gen mlab = "m"
    egen mgt_ln = concat(mgt_str mlab)
    replace lineno_str = mgt_ln if missing(EMP_HRLN)
    egen pid = concat(hhid lineno_str)
//     duplicates drop pid qtr, force // 0 obs dropped
    drop mgt_str mlab mgt_ln
    label var pid "Individual ID"
*</_pid_>

*<_weight_>
    gen weight = .
    replace weight = wgt_2024q1 if QUARTER == 1
    replace weight = wgt_2024q2 if QUARTER == 2
    replace weight = wgt_2024q3 if QUARTER == 3
    replace weight = wgt_2024q4 if QUARTER == 4
    replace weight = weight/4
    sum weight
    label var weight "Survey sampling weight (annual pooled adjusted /4)"
*</_weight_>


*<_weight_m_>
    gen weight_m = .
    label var weight_m "Survey sampling weight to obtain national estimates for each month"
*</_weight_m_>


*<_weight_q_>
    gen weight_q = .
    replace weight_q = wgt_2024q1 if QUARTER == 1
    replace weight_q = wgt_2024q2 if QUARTER == 2
    replace weight_q = wgt_2024q3 if QUARTER == 3
    replace weight_q = wgt_2024q4 if QUARTER == 4
    label var weight_q "Survey sampling weight to obtain national estimates for each quarter"
*</_weight_q_>


*<_psu_>
    gen psu = PSU
    label var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
    gen ssu = EAUM
    label var ssu "Secondary sampling units (Enumeration Area)"
*</_ssu_>


*<_strata_>
    gen strata = .
    label var strata "Strata"
*</_strata_>


*<_wave_>
    gen wave = QUARTER
    label var wave "Survey wave (1=Q1,2=Q2,3=Q3,4=Q4)"
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
    gen byte urban = .
    replace urban = 1 if BBS_geo == 1
    replace urban = 0 if BBS_geo == 2
    label var urban "Location is urban"
    la de lblurban 1 "Urban" 0 "Rural"
    label values urban lblurban
*</_urban_>


*<_subnatid1_>
/* <_subnatid1_note>
    The variable is string and country-specific categorical. Numeric entries are coded in string format using the following naming convention: "1 – Hatay". That is, the variable itself is to be string, not a labelled numeric vector. 
    
    Example of entries would be "1 - Alaska",  "2 - Arkansas", ...
</_subnatid1_note> */
    gen str subnatid1 = ""
    replace subnatid1 = "10 - Barisal"    if DIV_CODE == 10
    replace subnatid1 = "20 - Chittagong" if DIV_CODE == 20
    replace subnatid1 = "30 - Dhaka"      if DIV_CODE == 30
    replace subnatid1 = "40 - Khulna"     if DIV_CODE == 40
    replace subnatid1 = "45 - Mymensingh" if DIV_CODE == 45
    replace subnatid1 = "50 - Rajshahi"   if DIV_CODE == 50
    replace subnatid1 = "55 - Rangpur"    if DIV_CODE == 55
    replace subnatid1 = "60 - Sylhet"     if DIV_CODE == 60
    label var subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
    gen str subnatid2 = ""
    tostring UPZ_CODE, gen(temp_upz_str)
    replace subnatid2 = temp_upz_str + " - " + UPZ
    drop temp_upz_str
    label var subnatid2 "Subnational ID at Second Administrative Level"
*</_subnatid2_>


*<_subnatid3_>
    gen str subnatid3 = ""
    label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
/* <_subnatidsurvey_note>
    Variable denoting lowest administrative info to which the survey is still significant.
    See entry in GLD Guidelines (https://github.com/worldbank/gld/blob/main/Support/A%20-%20Guides%20and%20Documentation/GLD_1.0_Guidelines.docx) for more details
</_subnatidsurvey_note> */
    gen str subnatidsurvey = subnatid2
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
	bys hhid: egen hsize = count(pid)
	label var hsize "Household size"
*</_hsize_>

*<_age_>
    gen age = HR_04
    label var age "Individual age"
*</_age_>


*<_male_>
    gen male = HR_03
    recode male 2=0 3=.
    label var male "Sex - Ind is male"
    la de lblmale 1 "Male" 0 "Female"
    label values male lblmale
*</_male_>


*<_relationharm_>
    * checking no more than 1 hhead
    
    gen rela = HR_02
    
    gen head = rela==1
    bys hhid QUARTER: egen tot_head = sum(head)
    
    count if tot_head!=1
    
    gen neg_age = -(age)
    
    sort hhid QUARTER male neg_age 
    by hhid QUARTER: gen hhorder = _n
    replace hhorder = . if hhorder!=1
    
    replace rela = 1 if hhorder==1 & tot_head!=1
    replace rela = 5 if hhorder!=1 & rela ==1 & tot_head!=1
    
    drop tot_head head
    gen head = rela==1
    bys hhid QUARTER: egen tot_head = sum(head)
    
    assert tot_head ==  1
    drop tot_head head 

    gen relationharm = HR_02
    recode relationharm 7=5 8=6
    label var relationharm "Relationship to the head of household - Harmonized"
    la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
    label values relationharm  lblrelationharm
*</_relationharm_>


*<_relationcs_>
    gen relationcs = HR_02
    label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
    gen byte marital = HR_06
    recode marital 3=5 5=4
    label var marital "Marital status"
    la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
    label values marital lblmarital
*</_marital_>

*<_eye_dsablty_>
    gen eye_dsablty = difsee
    recode eye_dsablty (0 = 1)(1 = 2)
    label define dsablty 1 "No – no difficulty" 2 "Yes – some difficulty" 3 "Yes – a lot of difficulty" 4 "Cannot do at all"
    label values eye_dsablty dsablty
    label var eye_dsablty "Disability related to eyesight"
*</_eye_dsablty_>


*<_hear_dsablty_>
    gen hear_dsablty = difhear
    recode hear_dsablty (0 = 1)(1 = 2)
    label values hear_dsablty dsablty
    label var hear_dsablty "Disability related to hearing"
*</_hear_dsablty_>


*<_walk_dsablty_>
    gen walk_dsablty = difwalk
    recode walk_dsablty (0 = 1)(1 = 2)
    label values walk_dsablty dsablty
    label var walk_dsablty "Disability related to walking or climbing stairs"
*</_walk_dsablty_>


*<_conc_dsord_>
    gen conc_dsord = difremember
    recode conc_dsord (0 = 1)(1 = 2)
    label values conc_dsord dsablty
    label var conc_dsord "Disability related to concentration or remembering"
*</_conc_dsord_>


*<_slfcre_dsablty_>
    gen slfcre_dsablty = difselfcare
    recode slfcre_dsablty (0 = 1)(1 = 2)
    label values slfcre_dsablty dsablty
    label var slfcre_dsablty "Disability related to selfcare"
*</_slfcre_dsablty_>


*<_comm_dsablty_>
    gen comm_dsablty = difcommunicate
    recode comm_dsablty (0 = 1)(1 = 2)
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
	replace migrated_years = . if migrated_binary != 1
	label var migrated_years "Years since latest migration"
*</_migrated_years_>


*<_migrated_from_urban_>
	gen migrated_from_urban = .
	replace migrated_from_urban = . if migrated_binary != 1
	label de lblmigrated_from_urban 0 "Rural" 1 "Urban"
	label values migrated_from_urban lblmigrated_from_urban
	label var migrated_from_urban "Migrated from area"
*</_migrated_from_urban_>


*<_migrated_from_cat_>
	gen migrated_from_cat = .
	replace migrated_from_cat = . if migrated_binary != 1
	label de lblmigrated_from_cat 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country" 6 "Within country, admin unknown" 7 "Wholly unknow"
	label values migrated_from_cat lblmigrated_from_cat
	label var migrated_from_cat "Category of migration area"
*</_migrated_from_cat_>


*<_migrated_from_code_>
	gen migrated_from_code = ""
	replace migrated_from_code = "" if migrated_binary != 1
	label var migrated_from_code "Code of migration area as subnatid level of migrated_from_cat"
*</_migrated_from_code_>


*<_migrated_from_country_>
	gen migrated_from_country = ""
	replace migrated_from_country = "" if migrated_binary != 1
	label var migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>


*<_migrated_reason_>
	gen migrated_reason = .
	replace migrated_reason = . if migrated_binary != 1
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

Education module is only asked to those 5 and older.

</_ed_mod_age_note> */
gen byte ed_mod_age = .
replace ed_mod_age = 5
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school = .
	replace school = EDU_01 if age >= ed_mod_age
	label var school "Attending school"
	la de lblschool 0 "No" 1 "Yes"
	label values school  lblschool
*</_school_>

*<_literacy_>
	gen byte literacy = .
	replace literacy = EDU_02 if age >= ed_mod_age
	label var literacy "Individual can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>

*<_educy_>
	gen byte educy = .
	replace educy = EDU_03 if age >= ed_mod_age & EDU_03 < 90
	replace educy = . if EDU_03 >= 90
	label var educy "Years of education"
*</_educy_>

*<_educat7_>
	*Warning: There is limited information on the structure and meaning of the codes of this section most of the decisions made are not based on official sources.
	
	//the raw data has two variables EDU_03 and EDU_04 that exclusive the one from the other. the first one describes the current level people are attending and the latter describes the highest class or grade of degree that people have passed. There is also a variable EDU_02 that gives people three alternatives (yes attending school, yes attended in the past or never attended). The three combined help in coding the educat7 with precision. 
	
	gen byte educat7=.
	
	**** 1 GLD No education 
	//it is assumed that people which respond that never attended an education center will be coded here. Any pre school information and no class passed is also considered as No education because they are not possible to be coded as other ocupation incomplete based on the GLD guidelines. 
	
	replace educat7=1 if (EDU_03==0 | EDU_04==0 ) 
	replace educat7=1 if EDU_02==3
	
	**** 2 Primary Incomplete
	
	// it is assumed that  from class 1 to Class 4 it is primary incomplete.
	
	replace educat7=2 if (inrange(EDU_03,1,4) | inrange(EDU_04,1,4)) & inrange(EDU_02,1,2) 
	
	**** 3 Primary Complete
	// it is assumed that class 5 alone is the end of primary, if you do a tab in EDU_04 or in EDU_03 you can see that the frequency number for class 5 is much higher than class 6 or 4 which could mean the end of an education cycle.
	
	replace educat7=3 if (EDU_03==5 | EDU_04==5) & inrange(EDU_02,1,2)
	
	**** 4 Secondary Incomplete 
	
	// it is assumed that from class 6 to 9 it is secondary incomplete
	
	replace educat7=4 if (inrange(EDU_03,6,9) | inrange(EDU_04,6,9)) & inrange(EDU_02,1,2)
	
	**** 5 Secondary Complete
	
	// how to differentiate between secondary completion and vocational? HSC and SSC can be both? We have assumed SSC , HSC and Diploma to be secondary complete.
	
	replace educat7=5 if (inrange(EDU_03,10,12) | inrange(EDU_04,10,12)) & inrange(EDU_02,1,2)
	
		// religious education is not coded as per label on the variable for category 16 (no class was assigned)
	
	**** 6 Higher than secondary but not university 
	//no way to differentiate 
	
	**** 7 University Incomplete and complete
	// it is assumed that bachelors , masters and PhD are university level education
	replace educat7=7 if (inrange(EDU_03,13,15) | inrange(EDU_04,13,15)) & inrange(EDU_02,1,2)
	
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
	gen educat_orig = .
	replace educat_orig = EDU_04 if age >= ed_mod_age
	label var educat_orig "Original survey education code"
*</_educat_orig_>

*<_educat_isced_>
	gen educat_isced = .
	replace educat_isced = 0 if educat7 == 1
	replace educat_isced = 1 if educat7 == 2
	replace educat_isced = 2 if educat7 == 3
	replace educat_isced = 3 if educat7 == 4
	replace educat_isced = 4 if educat7 == 5
	replace educat_isced = 5 if educat7 == 6
	replace educat_isced = 6 if educat7 == 7
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
	gen vocational = VT_01
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
	gen vocational_length_l = VT_02
	recode vocational_length_l 1/4=1 5=4 
	label var vocational_length_l "Length of training in months, lower limit"
*</_vocational_length_l_>


*<_vocational_length_u_>
	gen vocational_length_u = VT_02
	recode vocational_length_u 1/4=3 5=6 6=.
	label var vocational_length_u "Length of training in months, upper limit"
*</_vocational_length_u_>


*<_vocational_field_orig_>
	tostring VT_03, gen(vocational_field_orig) 
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
	gen byte minlaborage = 15
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{

*<_lstatus_>
	gen byte lstatus = .
	replace lstatus = 1 if EMP_01==1 | EMP_02==1 | inrange(EMP_05, 1, 4) | inrange(EMP_07, 1, 5) | EMP_08==1 | EMP_09==1
	replace lstatus = 2 if (JSA_01==1 & JSA_06==1 | JSA_02==1 & JSA_06==1 ) & lstatus != 1
	replace lstatus = 3 if  missing(lstatus)
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte potential_lf = .
	replace potential_lf=1 if lstatus==3 & JSA_06==1 | JSA_06==2
	replace potential_lf = . if age < minlaborage & !missing(age)
	replace potential_lf = . if lstatus != 3
	label var potential_lf "Potential labour force status"
	la de lblpotential_lf 0 "No" 1 "Yes"
	label values potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen byte underemployment = .
	replace underemployment = . if age < minlaborage & !missing(age)
	replace underemployment = . if lstatus != 1
	label var underemployment "Underemployment status"
	la de lblunderemployment 0 "No" 1 "Yes"
	label values underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte nlfreason=JSA_07
	recode nlfreason 3=4  4=3 5/99=5
	replace nlfreason = . if lstatus != 3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte unempldur_l=JSA_04
	recode unempldur_l 1=. 2=1 4=6 5=12 6=24 7=.99
	replace unempldur_l = . if lstatus != 2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>


*<_unempldur_u_>
	gen byte unempldur_u=JSA_04
	recode unempldur_u 1=. 2=3 3=6 4=11 5=23 6=. 7=.99
	replace unempldur_u = . if lstatus != 2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte empstat=MJ_05
	recode empstat 2=1 3=1 4=1 5=3 6=4 7=2 8=5 99=.
	replace empstat = . if lstatus != 1
	label var empstat "Employment status during past week primary job 7 day recall"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte ocusec = MJ_09
	recode ocusec 3=1 4=2 5=2 6=2 7=2 8=2 9=2 99=2
	replace ocusec = . if lstatus != 1
	label var ocusec "Sector of activity primary job 7 day recall"
	la de lblocusec 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen industry_orig = string(MJ_04C, "%05.0f")
	replace industry_orig = "" if lstatus != 1
	label var industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>

	* The raw industry codes appear to provide more detail than can be
	* reliably mapped to valid ISIC Rev. 4 classes. Therefore, retain the
	* first two digits and code the variable at the ISIC division level.
	
	gen industrycat_isic = substr(industry_orig, 1, 2) + "00" ///
		if !missing(industry_orig)

	* Special treatment of raw code 000, following the existing assumption
	replace industrycat_isic = "2000" if substr(industry_orig, 1, 3) == "000"

	* Remove invalid string missing-value representations
	replace industrycat_isic = "" if ///
		inlist(industrycat_isic, ".000", ".00", "0000")

	* The following source codes could not be identified in the available
	* BSIC documentation and are therefore left uncoded.
	replace industrycat_isic = "" if inlist(industry_orig, ///
    "34191", "48121", "48212", "54101", ///
    "57211", "57526", "83921")
	
	preserve
		drop if missing(industrycat_isic)
		int_classif_universe, var(industrycat_isic) universe(ISIC)
		count
		list
		assert `r(N)' == 0
	restore

	label var industrycat_isic ///
		"ISIC code of primary job 7 day recall"

*</_industrycat_isic_>

*<_industrycat10_>
	gen isic2d = substr(industrycat_isic, 1, 2)
	destring isic2d, replace
	gen  industrycat10 = isic2d
	recode industrycat10 (1/3=1) (5/9 = 2) (10/33 = 3) (35/39 = 4) (41/43 = 5) (45/47 55/56 = 6) (49/53 58/63 = 7) (64/82 = 8) (84 = 9) (85/99 = 10)	
	drop isic2d
	replace industrycat10 = . if lstatus != 1
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
	gen occup_orig_h = floor(MJ_02C)
	gen occup_orig= string(occup_orig_h, "%04.0f")
	label var occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>


*<_occup_isco_>

/* <_occup_isco_note>
	The source occupation variable follows a detailed national/adapted
	classification. Where the first four digits do not correspond to a valid
	ISCO-08 unit group, the code is retained at the most detailed valid
	higher level available.

	There is also a set of individuals with industry information but no
	occupation code. Most are concentrated in agricultural industries and
	report producing mainly for own consumption. These observations are
	assigned to code 6300, subsistence farmers, fishers, hunters and gatherers.
</_occup_isco_note> */

	* Initial four-digit occupation code
	gen occup_isco = substr(occup_orig, 1, 4)
	replace occup_isco = "" if inlist(occup_isco, "", ".", ".000")

	*------------------------------------------------------------------
	* Explicit mappings supported by the existing harmonization
	*------------------------------------------------------------------
	replace occup_isco = "0110" if occup_orig == "0120"
	replace occup_isco = "0210" if inlist(occup_orig, "0211", "0220", "0230")
	replace occup_isco = "0200" if inlist(occup_orig, "0221", "0231", "0240")
	replace occup_isco = "0310" if inlist(occup_orig, "0320", "0330")

	replace occup_isco = "1113" if occup_orig == "1115"
	replace occup_isco = "1120" if inlist(occup_orig, "1121", "1122")
	replace occup_isco = "1210" if occup_orig == "1214"
	replace occup_isco = "1200" if occup_orig == "1234"
	replace occup_isco = "1310" if inlist(occup_orig, "1314", "1316")
	replace occup_isco = "1320" if occup_orig == "1329"
	replace occup_isco = "1340" if occup_orig == "1347"
	replace occup_isco = "1300" if inlist(occup_orig, "1364", "1366")
	replace occup_isco = "1439" if occup_orig == "1433"

	replace occup_isco = "2120" if occup_orig == "2121"
	replace occup_isco = "2141" if occup_orig == "2147"
	replace occup_isco = "2150" if occup_orig == "2156"
	replace occup_isco = "2230" if inlist(occup_orig, "2232", "2233", "2234")
	replace occup_isco = "2250" if occup_orig == "2254"
	replace occup_isco = "2359" if inlist(occup_orig, ///
		"2311", "2331", "2332", "2333", "2343", "2357")
	replace occup_isco = "2310" if occup_orig == "2319"
	replace occup_isco = "2340" if occup_orig == "2347"
	replace occup_isco = "2300" if inlist(occup_orig, "2363", "2369")
	replace occup_isco = "2400" if occup_orig == "2459"
	replace occup_isco = "2500" if inlist(occup_orig, ///
		"2537", "2545", "2551", "2554", "2557")
	replace occup_isco = "2610" if inlist(occup_orig, "2613", "2614")
	replace occup_isco = "2620" if occup_orig == "2624"
	replace occup_isco = "2630" if occup_orig == "2639"

	replace occup_isco = "3220" if occup_orig == "3223"
	replace occup_isco = "3230" if occup_orig == "3231"
	replace occup_isco = "3240" if occup_orig == "3241"
	replace occup_isco = "3320" if occup_orig == "3325"
	replace occup_isco = "3350" if occup_orig == "3356"
	replace occup_isco = "3410" if occup_orig == "3414"

	replace occup_isco = "4110" if occup_orig == "4111"
	replace occup_isco = "4100" if occup_orig == "4142"
	replace occup_isco = "4200" if occup_orig == "4241"
	replace occup_isco = "4310" if inlist(occup_orig, "4314", "4317")
	replace occup_isco = "4320" if occup_orig == "4324"
	replace occup_isco = "4300" if occup_orig == "4341"

	replace occup_isco = "5110" if occup_orig == "5114"
	replace occup_isco = "5120" if inlist(occup_orig, "5121", "5122")
	replace occup_isco = "5100" if occup_orig == "5183"
	replace occup_isco = "5210" if occup_orig == "5214"
	replace occup_isco = "5220" if occup_orig == "5224"
	replace occup_isco = "5230" if inlist(occup_orig, "5233", "5234")
	replace occup_isco = "5200" if inlist(occup_orig, "5252", "5253")
	replace occup_isco = "5300" if inlist(occup_orig, "5332", "5351")
	replace occup_isco = "5419" if inlist(occup_orig, "5415", "5416", "5417")

	replace occup_isco = "6110" if occup_orig == "6115"
	replace occup_isco = "6100" if occup_orig == "6160"
	replace occup_isco = "6210" if inlist(occup_orig, "6211", "6212", "6213")
	replace occup_isco = "6320" if inlist(occup_orig, ///
		"6312", "6321", "6322", "6329", "6333")

	replace occup_isco = "7110" if occup_orig == "7118"
	replace occup_isco = "7130" if occup_orig == "7135"
	replace occup_isco = "7100" if occup_orig == "7155"
	replace occup_isco = "7230" if occup_orig == "7239"
	replace occup_isco = "7410" if inlist(occup_orig, ///
		"7414", "7416", "7418", "7419")
	replace occup_isco = "7420" if occup_orig == "7423"
	replace occup_isco = "7400" if inlist(occup_orig, ///
		"7431", "7435", "7454")
	replace occup_isco = "7512" if occup_orig == "7517"
	replace occup_isco = "7520" if occup_orig == "7527"
	replace occup_isco = "7530" if inlist(occup_orig, ///
		"7539", "7554", "7555", "7556", "7557")
	replace occup_isco = "7532" if occup_orig == "7551"
	replace occup_isco = "8153" if occup_orig == "7552"
	replace occup_isco = "8154" if occup_orig == "7553"

	replace occup_isco = "8120" if occup_orig == "8123"
	replace occup_isco = "8160" if inlist(occup_orig, "8161", "8162")
	replace occup_isco = "8170" if occup_orig == "8173"
	replace occup_isco = "8180" if occup_orig == "8184"
	replace occup_isco = "8210" if occup_orig == "8218"
	replace occup_isco = "8200" if inlist(occup_orig, ///
		"8221", "8222", "8223", "8231", "8233", "8253")
	replace occup_isco = "8300" if occup_orig == "8301"
	replace occup_isco = "8320" if occup_orig == "8323"

	replace occup_isco = "9110" if occup_orig == "9113"
	replace occup_isco = "9100" if inlist(occup_orig, "9131", "9141")
	replace occup_isco = "9200" if inlist(occup_orig, "9221", "9249")
	replace occup_isco = "9300" if inlist(occup_orig, ///
		"9301", "9349", "9361")
	replace occup_isco = "9310" if occup_orig == "9316"
	replace occup_isco = "9320" if occup_orig == "9323"
	replace occup_isco = "9410" if occup_orig == "9414"
	replace occup_isco = "9400" if occup_orig == "9441"
	replace occup_isco = "9510" if inlist(occup_orig, "9511", "9512")
	replace occup_isco = "9520" if occup_orig == "9521"
	replace occup_isco = "9500" if occup_orig == "9531"
	replace occup_isco = "9610" if occup_orig == "9616"

	*------------------------------------------------------------------
	* Remaining invalid national/adapted codes:
	* retain them at a broader ISCO level rather than guessing a
	* specific four-digit unit group.
	*------------------------------------------------------------------

	* Armed forces: broader major-group code
	replace occup_isco = "0000" if inlist(occup_isco, ///
		"0001", "0121", "0161", "0243", "0265")

	* Managers
	replace occup_isco = "1100" if inlist(occup_isco, "1123", "1180")
	replace occup_isco = "1200" if occup_isco == "1245"
	replace occup_isco = "1310" if occup_isco == "1313"
	replace occup_isco = "1410" if inlist(occup_isco, "1413", "1419")
	replace occup_isco = "1420" if occup_isco == "1421"

	* Professionals
	replace occup_isco = "2120" if inlist(occup_isco, "2122", "2123")
	replace occup_isco = "2130" if occup_isco == "2138"
	replace occup_isco = "2220" if occup_isco == "2223"
	replace occup_isco = "2310" if occup_isco == "2312"
	replace occup_isco = "2320" if inlist(occup_isco, "2322", "2327")
	replace occup_isco = "2330" if inlist(occup_isco, "2334", "2337")
	replace occup_isco = "2340" if inlist(occup_isco, "2345", "2349")
	replace occup_isco = "2300" if occup_isco == "2395"
	replace occup_isco = "2430" if occup_isco == "2438"
	replace occup_isco = "2400" if occup_isco == "2441"
	replace occup_isco = "2400" if occup_isco == "2466"
	replace occup_isco = "2500" if inlist(occup_isco, ///
		"2531", "2559", "2561")

	* Technicians and associate professionals
	replace occup_isco = "3230" if occup_isco == "3233"
	replace occup_isco = "3320" if inlist(occup_isco, "3326", "3329")
	replace occup_isco = "3410" if occup_isco == "3416"
	replace occup_isco = "3400" if occup_isco == "3441"

	* Clerical support workers
	replace occup_isco = "4110" if inlist(occup_isco, "4112", "4113")
	replace occup_isco = "4120" if occup_isco == "4123"
	replace occup_isco = "4200" if occup_isco == "4231"
	replace occup_isco = "4320" if occup_isco == "4329"
	replace occup_isco = "4300" if inlist(occup_isco, "4331", "4333")

	* Service and sales workers
	replace occup_isco = "5100" if occup_isco == "5155"
	replace occup_isco = "5210" if inlist(occup_isco, "5213", "5215")
	replace occup_isco = "5230" if inlist(occup_isco, "5231", "5232")
	replace occup_isco = "5250" if inlist(occup_isco, "5254", "5257")
	replace occup_isco = "5200" if occup_isco == "5262"

	* Skilled agricultural workers
	replace occup_isco = "6130" if inlist(occup_isco, "6131", "6132")
	replace occup_isco = "6100" if occup_isco == "6161"
	replace occup_isco = "6210" if occup_isco == "6216"
	replace occup_isco = "6300" if occup_isco == "6313"

	* Craft and related trades workers
	replace occup_isco = "7140" if occup_isco == "7141"
	replace occup_isco = "7100" if inlist(occup_isco, ///
		"7151", "7152", "7172")
	replace occup_isco = "7210" if inlist(occup_isco, "7216", "7218")
	replace occup_isco = "7330" if inlist(occup_isco, "7331", "7333")
	replace occup_isco = "7300" if occup_isco == "7341"
	replace occup_isco = "7410" if occup_isco == "7417"
	replace occup_isco = "7430" if occup_isco == "7436"
	replace occup_isco = "7510" if occup_isco == "7518"

	* Plant and machine operators
	replace occup_isco = "8210" if occup_isco == "8215"
	replace occup_isco = "8320" if occup_isco == "8329"

	* Elementary occupations
	replace occup_isco = "9220" if occup_isco == "9229"
	replace occup_isco = "9310" if inlist(occup_isco, "9314", "9319")
	replace occup_isco = "9320" if occup_isco == "9324"
	replace occup_isco = "9300" if occup_isco == "9343"
	replace occup_isco = "9620" if occup_isco == "9625"

	*------------------------------------------------------------------
	* Subsistence agricultural workers with missing occupation
	*------------------------------------------------------------------
	replace occup_isco = "6300" if ///
		inlist(MJ_04C, 1131, 1411, 1441, 1461) & ///
		inrange(EMP_05, 3, 4) & missing(MJ_02C)
		
	* These source codes cannot be assigned to a valid ISCO-08
	* four-digit unit group based on the available documentation.
	local invalid_occup ///
	0141 1141 1230 1244 1437 2154 2239 2452 2465 ///
	2534 2541 3234 3235 3317 4119 4151 4153 4233 ///
	5149 5326 5250 6124 6126 6141 6151 7219 7226 7426 ///
	7445 7503 7525 8214 8314 8333 9118 9220 9231 9322 ///
	9325 9373 9392 9515 9626

	foreach code of local invalid_occup {
		replace occup_isco = "" if occup_isco == "`code'"
	}
	replace occup_isco = "" if occup_isco == "."

	*------------------------------------------------------------------
	* Validation
	*------------------------------------------------------------------
	preserve
		drop if missing(occup_isco)
		int_classif_universe, var(occup_isco) universe(ISCO)
		count
		list
		assert `r(N)' == 0
	restore

	replace occup_isco = "" if lstatus != 1

	label var occup_isco "ISCO code of primary job 7 day recall"

*</_occup_isco_>

*<_occup_>
	gen isco2d = substr(occup_isco, 1, 2)
	destring isco2d, replace
	gen  occup = isco2d
	recode occup (1/3=10) (11/14=1) (21/26=2) (31/35=3) (41/44=4) (51/54=5) (61/63=6) (71/75=7) (81/83=8) (91/96=9)
	drop isco2d
	replace occup = 6 if inlist(MJ_04C, 1131, 1411, 1441, 1461) & inrange(EMP_05, 3, 4) & mi(MJ_02C)
	replace occup = . if lstatus != 1
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
	gen double wage_no_compen = MJ_15A if lstatus==1
	recode wage_no_compen (0 = .)
	replace wage_no_compen = . if lstatus != 1
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
	replace unitwage = . if lstatus !=1
	label var unitwage "Last wages' time unit primary job 7 day recall"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours = WT_01MJ
	replace whours = . if whours == 0 | whours == 99
	replace whours = . if lstatus != 1
	label var whours "Hours of work in last week primary job 7 day recall"
*</_whours_>


*<_wmonths_>
	gen wmonths = .
	replace wmonths = . if lstatus != 1
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
	gen byte contract = MJ_06
	recode contract 1/2=1 3=0 97=.
	replace contract = . if lstatus != 1
	label var contract "Employment has contract primary job 7 day recall"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte healthins = (MJ_08H != "")
	replace healthins = . if lstatus != 1
	label var healthins "Employment has health insurance primary job 7 day recall"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen byte socialsec = .
	replace socialsec=1 if  MJ_08=="A"
	replace socialsec=0 if socialsec!=1
	label var socialsec "Employment has social security insurance primary job 7 day recall"
	la de lblsocialsec 1 "With social security" 0 "Without social secturity"
	label values socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen byte union = .
	replace union = . if lstatus != 1
	label var union "Union membership at primary job 7 day recall"
	la de lblunion 0 "Not union member" 1 "Union member"
	label values union lblunion
*</_union_>


*<_firmsize_l_>
	gen firmsize_l = MJ_12
	recode firmsize_l 3=5 4=10 5=25 6=100 7=250
	replace firmsize_l = . if lstatus != 1
	label var firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
*there are two different missings perhaps ask mario about this.
	gen firmsize_u= MJ_12
	recode firmsize_u 1=. 2=4 3=6 4=11 5=23 6=. 7=.
	replace firmsize_u = . if lstatus != 1
	label var firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


{
*<_empstat_2_>
    gen byte empstat_2 = SJ_03
    recode empstat_2 2=1 3=1 4=1 5=3 6=4 7=2 8=5
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
    label var occup_isco_2 "ISIC code of secondary job 7 day recall"
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
    gen double wage_no_compen_2 = SJ_05A
    label var wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
    gen byte unitwage_2 = 5
    label var unitwage_2 "Last wages' time unit secondary job 7 day recall"
    label values unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
    gen whours_2 = WT_01SJ
    replace whours_2 = . if whours_2 == 0 | whours_2 == 99
    replace whours_2 = . if lstatus!= 1
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
