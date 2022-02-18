/*%%=============================================================================================
	0: GLD Harmonization Preamble
==============================================================================================%%*/

/* -----------------------------------------------------------------------

<_Program name_>				PHL_2013_GLD_LFS.do </_Program name_>
<_Application_>					Stata 15 <_Application_>
<_Author(s)_>					World Bank Jobs Group </_Author(s)_>
<_Date created_>				2022-02-17 </_Date created_>

-------------------------------------------------------------------------

<_Country_>						Philippines (PHL) </_Country_>
<_Survey Title_>				Labor Force Survey </_Survey Title_>
<_Survey Year_>					2013 </_Survey Year_>
<_Study ID_>					[Microdata Library ID if present] </_Study ID_>
<_Data collection from_>		[01/2013] </_Data collection from_>
<_Data collection to_>			[10/2013] </_Data collection to_>
<_Source of dataset_> 			[Source of data, e.g. NSO] </_Source of dataset_>
<_Sample size (HH)_> 			39274 </_Sample size (HH)_>
<_Sample size (IND)_> 			202742 </_Sample size (IND)_>
<_Sampling method_> 			Geographic regions divided into PSUs of ~100-400 Households for further processing </_Sampling method_>
<_Geographic coverage_> 		1st-level Subdivision (Region) </_Geographic coverage_>
<_Currency_> 					[Currency used for wages] </_Currency_>

-----------------------------------------------------------------------

<_ICLS Version_>				ICLS-13 </_ICLS Version_>
<_ISCED Version_>				[Version of ICLS for Labor Questions] </_ISCED Version_>
<_ISCO Version_>				ISCO 88 </_ISCO Version_>
<_OCCUP National_>				PSOC 92 </_OCCUP National_>
<_ISIC Version_>				ISIC 4 </_ISIC Version_>
<_INDUS National_>				PSIC 2009 </_INDUS National_>

-----------------------------------------------------------------------
<_Version Control_>

Unitwage was coded as per payment period not wage_non_compen timeframe

</_Version Control_>

-------------------------------------------------------------------------*/


/*%%=============================================================================================
	1: Setting up of program environment, dataset
==============================================================================================%%*/

*----------1.1: Initial commands------------------------------*
cap log close
clear
set more off
set mem 800m

* install packages
local user_commands ietoolkit scores missings mdesc iefieldkit  //Fill this list will all user-written commands this project requires
 foreach command of local user_commands {
     cap which `command'
     if _rc == 111 {
         ssc install `command'
     }
 }

*----------1.2: Set directories------------------------------*

** DIRECTORY

	local 	cty3 	"PHL" 			// set this to the three letter country/economy abbreviation
	local 	surv_yr  = 2013			// set this to the survey year

** RUN SETTINGS
	local 	cb_pause = 0		// 1 to pause+edit the exported codebook for harmonizing varnames, else 0
	local 	append 	 = 1 		// 1 to run iecodebook append, 0 if file is already appended.
	local 	drop 	 = 1 		// 1 to drop variables with all missing values, 0 otherwise


	local 	year 		"Y:\GLD\\`cty3'\\`cty3'_`surv_yr'_LFS" // top data folder

	local 	main		"`year'\\`cty3'_`surv_yr'_LFS_v01_M"
	local 	 stata		"`main'\Data\Stata"
	local 	gld 		"`year'\\`cty3'_`surv_yr'_LFS_v01_M_v02_A_GLD"
	local 	 code 		"`gld'\Programs"
	local 	 gld_data 	"`gld'\Data\Harmonized"

	local 	lb_mod_age	15	// labor module minimun age (inclusive)
	local 	ed_mod_age	5	// labor module minimun age (inclusive)

	local 	weightvar 	pwgt // final weightvar

** LOG FILE
	log using `"`gld_data'\\`cty3'_`surv_yr'_I2D2_LFS.log"', replace


** FILES
	* input
	local round1 `"`stata'\LFSjan13.dta"'
	local round2 `"`stata'\LFSapr13.dta"'
	local round3 `"`stata'\LFSjul13.dta"'
	local round4 `"`stata'\LFS OCT2013.dta"'

	local isic_key 	 `"`stata'\PHL_PSIC_ISIC_09_key.dta"' // 4 digit
	local isco_key 	 `"`stata'\PHL_PSOC92_ISCO88_08_key.dta"' // 2 digit

    local adm2_labs	 `"`stata'\GLD_PHL_admin2_labels.dta"'

* ouput
	local path_output `"`gld_data'\\`cty3'_`surv_yr'_LFS_v01_M_v02_A_GLD_ALL.dta"'

** VALUES
	local n_round 	4			// numer of survey rounds




*----------1.3: Database assembly------------------------------*

* All steps necessary to merge datasets (if several) to have all elements needed to produce
* harmonized output in a single file

	iecodebook append ///
		`"`round1'"' `"`round2'"' `"`round3'"' `"`round4'"' /// survey files
		using `"`main'\Doc\\`cty3'_`surv_yr'_append_template-IN.xlsx"' /// output just created above
		, clear surveys(JAN2013 APR2013 JUL2013 OCT2013) generate(round) // survey names


/*%%=============================================================================================
	2: Survey & ID
==============================================================================================%%*/

{

*<_countrycode_>
	gen str4 countrycode = "PHL"
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
	gen icls_v = "ICLS-13"
	label var icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>

*<_isced_version_>
	gen isced_version = ""
	label var isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>


*<_isco_version_>
	gen isco_version = "isco_1988"
	label var isco_version "Version of ISCO used"
*</_isco_version_>


*<_isic_version_>
	gen isic_version = "isic_4"
	label var isic_version "Version of ISIC used"
*</_isic_version_>


*<_year_>
	gen int year = `surv_yr'
	label var year "Year of survey"
*</_year_>


*<_vermast_>
	gen vermast = "v01"
	label var vermast "Version of master data"
*</_vermast_>


*<_veralt_>
	gen veralt = "v02"
	label var veralt "Version of the alt/harmonized data"
*</_veralt_>


*<_harmonization_>
	gen harmonization = "GLD"
	label var harmonization "Type of harmonization"
*</_harmonization_>


*<_int_year_>
	gen int_year= `surv_yr'
	label var int_year "Year of the interview"
*</_int_year_>


*<_int_month_>
	gen  int_month = svymo
	label de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"

* ensure that months reflec the round. See issue #52
replace int_month = 1 	if round == 1
replace int_month = 4 	if round == 2
replace int_month = 7 	if round == 3
replace int_month = 10 	if round == 4

*</_int_month_>


*<_hhid_>
/* <_hhid_note>

	The variable should be a string made up of the elements to define it, that is psu code, ssu, ...
	Each element should always be as long as needed for the longest element. That is, if there are
	60 psu coded 1 through 60, codes should be 01, 02, ..., 60. If there are 160 it should be 001,
	002, ..., 160.

	Since individual Household ID variables were not always provided for the Philippines, yet the household
	line number variables were provided, it was possible to approximate the household groupings by other variables.
	However, this process was not perfectly clean, so checks for duplicates were needed. Please refer to the
	"Household_IDs.md" in Guides and Documentation for additional explanation. The two variables, hhid and pid
	will be produced in conjunction, the labelled in the html brackets.

</_hhid_note> */
** HOUSEHOLD IDENTIFICATION NUMBER

** HOUSEHOLD IDENTIFICATION NUMBER
	loc idhvars 	hhnum   							// store idh vars in local


	ds `idhvars',  	has(type numeric)					// filter out numeric variables in local
	loc numlist 	= r(varlist)						// store numeric vars in local
	loc stringlist 	: list idhvars - numlist			// non-numeric vars in stringlist

	* starting locals
	loc len = 14											// declare the length of each element in digits
	loc idh_els ""										// start with empty local list

	* make each numeric var string, including leading zeros
	foreach var of local numlist {
		tostring `var'	///								// make the numeric vars strings
			, generate(idh_`var') ///					// gen a variable with this prefix
			force format(`"%0`len'.0f"')				// ...and the specified number of digits in local

		loc idh_els 	`idh_els' idh_`var'				// add each variable to the local list

	}

		* add the round variable
		tostring round	///							// make the numeric vars strings
			, generate(idh_round) ///					// gen a variable with this prefix
			force format(`"%01.0f"')				// ...and the specified number of digits in local

		loc idh_els 	`idh_els' idh_round				// add each variable to the local list


	* concatenate all elements to form idh: hosehold id
	egen idh=concat( `idh_els' )						// concatenate vars we just made. code drops vars @ end

	label var idh "Household id"




** INDIVIDUAL IDENTIFICATION NUMBER
	bys idh: gen n_fam = _n								// generate family member number

	* repeat same process from above, but only with n_fam.
	* 	note, assuming that the only necessary individaul identifier is family member, which is numeric
	*	so, not following processing for sorting numeric/non-numeric variables.

	loc idpvars 	cc101_lno 							// store relevant idp vars in local
	ds `idpvars',  	has(type numeric)					// filter out numeric variables in local
	loc rlist 		= r(varlist)						// store numeric vars in local

	* make new values with desired length of each variable
	loc len = 2											// declare the length of each element in digits
	loc idp_els ""										// start with empty local list

	foreach var of local idpvars {
		tostring `var'	///								// make numeric variables strings
			, generate(idp_`var') ///					// generate a variable with this prefix
			force format(`"%0`len'.0f"')				// ...and the specified number of digits in local

		loc idp_els 	`idp_els' idp_`var'				// add each variable to the local list

	}

	* concatenate to form idp: individual id
	egen idp=concat( `idp_els' )						// concatenate vars we just made. code drops vars @ end

	sort idh idp
	label var idp "Individual id"

** ID CHECKS
	isid idh idp 										// household and individual id uniquely identify

	rename hhid hhid_orig
	gen  hhid = idh  									// make hhid from idh in module
	label var hhid "Household ID"

*</_hhid_>


*<_pid_>
** INDIVIDUAL IDENTIFICATION NUMBER
	egen 		pid = concat(hhid idp) 		// generated from sub-module above.
	label var 	pid "Individual ID"

	isid 		hhid pid
*</_pid_>


*<_weight_>
	rename 		weight weight_orig
	gen 		weight = pwgt / 4
	label 		var weight "Household sampling weight"
*</_weight_>


*<_psu_>
	rename 		psu psu_orig
	gen 		psu = psu_orig
	label 		var psu "Primary sampling units"
*</_psu_>


*<_ssu_>
	gen ssu = .
	label var ssu "Secondary sampling units"
*</_ssu_>


*<_strata_>
	gen strata = stratum
	label var strata "Strata"
*</_strata_>


*<_wave_>
	gen wave = "Q1"

	replace 		wave = 	"Q1"	if round == 1
	replace 		wave = 	"Q2"	if round == 2
	replace 		wave = 	"Q3"	if round == 3
	replace 		wave = 	"Q4"	if round == 4

	label var 		wave "Survey wave"

*</_wave_>

}

/*%%=============================================================================================
	3: Geography
==============================================================================================%%*/

{

*<_urban_>
	gen byte 		urban = .
	replace 		urban = urb2k1970
	recode 			urban (2 = 0) 		// change rural=2 to rural=0
	label var 		urban "Location is urban"
	la de 			lblurban 1 "Urban" 0 "Rural"
	label values 	urban lblurban
*</_urban_>


*<_subnatid1_>
/* <_subnatid1>

	Labels are to be defined as # - Name like 1 "1 - Alaska" 2 "2 - Arkansas".

</_subnatid1> */
	gen byte 		subnatid1 = creg
	label de 		lblsubnatid1 	///
					 1   "1 - Ilocos"			///
					 2	 "2 - Cagayan Valley"	///
					 3   "3 - Central Luzon"	///
	 						/// Southern Tagalog has been split into Calabarzon and Mimaropa
					 5   "5 - Bicol"			///
					 6	 "6 - Western Visayas"	///
					 7   "7 - Central Visayas"	///
					 8	 "8 - Eastern Visayas"	///
					 9   "9 - Zamboanga Peninsula"	///
					 10  "10 - Northern Mindanao"	///
					 11  "11 - Davao"	///
					 12  "12 - Soccsksargen"		///
					 13  "13 - National Capital Region"				///
					 14  "14 - Cordillera Administrative Region"		///
					 15  "15 - Autonomous Region of Muslim Mindanao"	///
					 16  "16 - Caraga" ///
					 /// value 17 exists only in raw data, not in recoded version
					 18  "18 - Negros Island Region" /// this region appears occasionally in data
				 	 							///
				 	 41	 "41 - Calabarzon"	/// formerly part of Southern Tagalog
				 	 42  "42 - Mimaropa"		// formerly part of Southern Tagalog

	label values 	subnatid1 lblsubnatid1
	label var 		subnatid1 "Subnational ID at First Administrative Level"
*</_subnatid1_>


*<_subnatid2_>
	* import the labels
	loc 			n_obs = _n 	// store no. obs before merge

	preserve

		use  `adm2_labs' , clear

		* Many thanks to DIME who have figured this out
		* https://github.com/worldbank/iefieldkit/blob/master/src/ado_files/iecodebook.ado
		count
		local 		n_labs = `r(N)' 	// store the number of total labels
		forvalues 	v = 1 / `n_labs' {	// store each value/label pair in a value label local

			local theNextValue  = value[`v']
			local theNextLabel  = label_gld[`v']
			local theValueLabel = "lblsubnatid2"

			local L`theValueLabel'	`" `L`theValueLabel'' `theNextValue' "`theNextLabel'" "'
		}

	restore

	* now hop over to the main dataset our local and apply the label
	// define the value label
	foreach label in `theValueLabel' {
		label def 	`label' `L`label'', replace
	}

	// generate the variable and apply the labels.
	gen byte 		subnatid2 = prov
	label values 	subnatid2 lblsubnatid2
	label var 		subnatid2 "Subnational ID at Second Administrative Level"

*</_subnatid2_>


*<_subnatid3_>
	gen byte subnatid3 = .
	*label de lblsubnatid3 1 "1 - Name"
	*label values subnatid3 lblsubnatid3
	label var subnatid3 "Subnational ID at Third Administrative Level"
*</_subnatid3_>


*<_subnatidsurvey_>
	gen subnatidsurvey = "subnatid1"
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
	sort hhid
	by hhid: egen hsize= count(c05_rel <= 8 | c05_rel == 11) // includes non-family members, not boarders or domestic workers.
	label var 	hsize "Household size"

	* check
	qui mdesc 	hsize
	assert 		r(miss) == 0

*</_hsize_>


*<_age_>
	gen 		age = c07_age
	replace 	age	= 98 	if age>=98 & age!=.
	label var 	age "Individual age"
*</_age_>


*<_male_>
	gen 		male = c06_sex
	recode 		male (2 = 0)						// female=2 recoded to female=0
	label var 	male "Sex - Ind is male"
	la de 		lblmale 	1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


*<_relationharm_>
	gen 		relationharm = .
	replace 	relationharm = c05_rel
	recode 		relationharm (4 5 6 8  	= 5) /// siblings, children in law, grandchildren, other rel of hh head="other relatives"
					(7 			= 4)	/// parents of hh head become "parents"
					(9 10 11 	= 6) 	// boarders and domestic workers become "other/non-relatives"

	label var 	relationharm "Relationship to the head of household - Harmonized"
	la de 		lblrelationharm  ///
				1 "Head of household" ///
				2 "Spouse" ///
				3 "Children" ///
				4 "Parents" ///
				5 "Other relatives" ///
				6 "Other and non-relatives"
	label values relationharm  lblrelationharm

	* other relationharm operations
	gen 		jh=(relationharm==1)
	bys hhid: 	egen hh=sum(jh) // hh is the count of hh heads per family

	/*Note: if number of Household Heads is >1, all relevant HH head info is set to missing.
			In this case the only relevant variable is head*/
	replace 	relationharm=. if hh>1

*</_relationharm_>


*<_relationcs_>
	gen relationcs = c05_rel
	label var relationcs "Relationship to the head of household - Country original"
*</_relationcs_>


*<_marital_>
	gen byte 		marital = c08_mstat
	recode 			marital 	///
					(1=2) 	///	"single" -> "never married"
					(2=1) /// "married" -> "married"
					(3=5)	/// "divorced/separated" -> "divorced/separated"
					(5 6=.) // "unknown" and "annulled" -> missing
	label var 		marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values 	marital lblmarital
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

Education module is only asked to those 5 and older.

</_ed_mod_age_note> */

gen byte ed_mod_age = 5
label var ed_mod_age "Education module application age"

*</_ed_mod_age_>

*<_school_>
	gen byte school= a02_cursch
	recode school (2 = 0)		// 2 was "no", recode to 0. Keep 1=Yes same.
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


*<_educy_>
	gen byte educy =.
	label var educy "Years of education"
*</_educy_>


*<_educat7_>
	/*Please refer to the "Education_Levels.md" for a detailed discussion on
	classificition of how each level is classified and why,
	available in github repository. */

	gen byte educat7=.

	replace educat7=1 if j12c09_grade==0 | j12c09_grade == 10 	// "No education" and "Preschool" -> "No Education"
	replace educat7=2 if j12c09_grade>=210 &  j12c09_grade<=260	// Grades 1-7 to "Primary Incomplete"
	replace educat7=3 if j12c09_grade==280						// "Elementary Graduate" to "Primary Complete"
	replace educat7=4 if j12c09_grade>=310 &  j12c09_grade<=340 	// First-Fourth year in High school -> "secondary incomplete"
	replace educat7=5 if j12c09_grade==350						// "High school graduate" -> "secondary complete"
	replace educat7=6 if j12c09_grade>=410 &  j12c09_grade<=501 	// Post secondary + Basic Programs -> "Higher secondary not uni"
	replace educat7=6 if j12c09_grade>=502 & 	j12c09_grade<=699	// Basic Program degrees to "Higher secondary not uni"
	replace educat7=7 if j12c09_grade>= 810 & j12c09_grade <= . // all labelled uni levels Advanced Degree" -> "University"


	label var educat7 "Level of education 1"
	la de lbleducat7 	1 "No education" ///
						2 "Primary incomplete" ///
						3 "Primary complete" ///
						4 "Secondary incomplete" ///
						5 "Secondary complete" ///
						6 "Higher than secondary but not university" ///
						7 "University incomplete or complete"
	label values educat7 lbleducat7
	replace educat7=. if age < ed_mod_age // restrict universe to students at or above primary school age

*</_educat7_>


*<_educat5_>
	gen byte educat5 = educat7
	recode educat5 (4=3) (5=4) (6 7=5)
	label var educat5 "Level of education 2"
	la de lbleducat5 	1 "No education" ///
						2 "Primary incomplete"  ///
						3 "Primary complete but secondary incomplete" ///
						4 "Secondary complete" ///
						5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
	replace educat5=. if age < ed_mod_age // restrict universe to students at or above primary school age
*</_educat5_>


*<_educat4_>
	gen byte educat4 = educat7
	recode educat4 (2 3 4 = 2) (5=3) (6 7=4)
	label var educat4 "Level of education 3"
	la de lbleducat4 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 lbleducat4
	replace educat4=. if age < ed_mod_age // restrict universe to students at or above primary school age
*</_educat4_>


*<_educat_orig_>
	gen educat_orig = j12c09_grade
	label var educat_orig "Original survey education code"
*</_educat_orig_>




*<_educat_isced_>
	gen educat_isced = .
	label var educat_isced "ISCED standardised level of education"
*</_educat_isced_>


*----------6.1: Education cleanup------------------------------*

*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
local ed_var "school literacy educy educat7 educat5 educat4 educat_isced"
foreach v of local ed_var {
	replace `v'=. if ( age < ed_mod_age & !missing(age) )
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
==============================================================================================%%*/


*<_minlaborage_>
	gen byte minlaborage = 15
	label var minlaborage "Labor module application age"
*</_minlaborage_>


*----------8.1: 7 day reference overall------------------------------*

{
*<_lstatus_>
	gen byte 		lstatus = newempstat
	replace 		lstatus = . if age < minlaborage
	label var 		lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF" // raw values always same as new
	label values 	lstatus lbllstatus
*</_lstatus_>


*<_potential_lf_>
	gen byte 		potential_lf = 0

	replace 		potential_lf = 1 if (c37_avail == 1 & c38_lookw == 2) ///
										| (c37_avail == 2 & c38_lookw == 1)
	replace 		potential_lf = . if age < minlaborage & age != .
	replace 		potential_lf = . if lstatus != 3
	label var 		potential_lf "Potential labour force status"
	la de 			lblpotential_lf 0 "No" 1 "Yes"
	label values 	potential_lf lblpotential_lf
*</_potential_lf_>


*<_underemployment_>
	gen byte 		underemployment = 0

	replace 		underemployment = 1 if c23_pwmore == 1
	replace 		underemployment = . if age < minlaborage & age != .
	replace 		underemployment = . if lstatus != 1
	label var 		underemployment "Underemployment status"
	la de 			lblunderemployment 0 "No" 1 "Yes"
	label values 	underemployment lblunderemployment
*</_underemployment_>


*<_nlfreason_>
	gen byte 		nlfreason= .
	replace 		nlfreason=1 	if c42_wynot==8
	replace 		nlfreason=2 	if c42_wynot==7
	replace 		nlfreason=3 	if c42_wynot==6
	replace 		nlfreason=4 	if c42_wynot==3
	replace 		nlfreason=5 	if c42_wynot==1 | c42_wynot==2 | c42_wynot==4 | c42_wynot==5 | c42_wynot==9
	replace 		nlfreason=. 	if lstatus!=3 		// restricts universe to non-labor force
	label var 		nlfreason "Reason not in the labor force"
	la de 			lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values 	nlfreason lblnlfreason
*</_nlfreason_>


*<_unempldur_l_>
	gen byte 		unempldur_l=c40_weeks/4.2
	label var 		unempldur_l "Unemployment duration (months) lower bracket"
	replace 		unempldur_l=. if lstatus!=2 	  // restrict universe to unemployed only

*</_unempldur_l_>


*<_unempldur_u_>
	gen byte 		unempldur_u=c40_weeks/4.2
	label var 		unempldur_u "Unemployment duration (months) upper bracket"
	replace 		unempldur_u=. if lstatus!=2 	  // restrict universe to unemployed only

*</_unempldur_u_>
}


*----------8.2: 7 day reference main job------------------------------*


{
*<_empstat_>
	gen byte 		empstat=.
	replace 		empstat=1 	if c19_pclass==0 | c19_pclass==1 | c19_pclass==2 | c19_pclass==5
	replace 		empstat=2 	if c19_pclass==6
	replace 		empstat=3	if c19_pclass==4
	replace 		empstat=4 	if c19_pclass==3
	replace 		empstat=. 	if lstatus!=1 	// includes universe restriction
	label var 		empstat 	"Employment status during past week primary job 7 day recall"
	la de 			lblempstat 	1 "Paid employee" ///
								2 "Non-paid employee" ///
								3 "Employer" ///
								4 "Self-employed" ///
								5 "Other, workers not classifiable by status"
	label values 	empstat lblempstat
*</_empstat_>


*<_ocusec_>
	gen byte 		ocusec = .
	replace 		ocusec = 1 	if c19_pclass == 2
	replace 		ocusec = 2 	if inlist(c19_pclass, 0, 1, 3, 4, 5, 6)

	label var 		ocusec 		"Sector of activity primary job 7 day recall"
	la de 			lblocusec 	1 "Public Sector, Central Government, Army" ///
								2 "Private, NGO" ///
								3 "State owned" ///
								4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
*</_ocusec_>


*<_industry_orig_>
	gen 			industry_orig = c18_pkb
	label var 		industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>


*<_industrycat_isic_>
	/* The key that matches industry codes is in string format to maintain leading/trailing
		zeros, so we will change the format here to string if necessary */
	/* The key that matches industry codes is in string format to maintain leading/trailing
		zeros, so we will change the format here to string if necessary */

	loc matchvar   	c18_pkb
	loc n 			1

	qui ds 			industry_orig, has(type numeric) 	// capture numeric var if is numeric
	loc isicvar 	= r(varlist)						// store this in a local
	loc len 		: list sizeof isicvar 				// store the length of this local (1 or 0)

		if (`len' == 1) {
															// run this if == 1 (ie, if industry_orig is numeric)
			tostring industry_orig	///						// make the numeric vars strings
				, generate(industry_orig_str) ///			// gen a variable with this prefix
				force //


		}


	// merge sub-module with isic key

	gen class = `matchvar'
	tostring 	class ///
				, format(`"%04.0f"') replace


	merge 		m:1 ///
				class ///
				using `isic_key' ///
				, generate(isic_merge_`n') ///
				keep(master match) // "left join"; remove obs that don't match from using
				* the string variable in isic4 will is industrycat_isic

	// replace one code that I know doesn't match
	rename 		isic4	isic4_`n'
	replace 	isic4_`n' = "6810" 	if `matchvar' == 6819

	tab 		isic_merge_`n' 		if `matchvar' != .


	gen 		industrycat_isic = isic4_`n'  	// the string variable becomes industrycat_isic

	drop 		class 				// no longer needed, maintained in matchvar


	*// industrycat_isic already generated above in submodule
	label var 		industrycat_isic "ISIC code of primary job 7 day recall"

	*</_industrycat_isic_>


*<_industrycat10_>
	gen byte 		industrycat10=.
	replace 		industrycat10=1 	if c18_pkb >= 100 	& c18_pkb <= 399	// "Agriculture, Forestry, Fishing" coded to "Agriculture"
	replace 		industrycat10=2 	if c18_pkb >= 500 	& c18_pkb <= 999	// "Mining and Quarrying" coded to "Mining"
	replace 		industrycat10=3 	if c18_pkb >= 1000 	& c18_pkb <= 3399 	// "Manufacturing" coded to "Manufacturing"
	replace 		industrycat10=4 	if c18_pkb >= 3500 	& c18_pkb <= 3900	// "Water supply, sewerage, etc" coded to "Public Utiltiy"
	replace 		industrycat10=5 	if c18_pkb >= 4100 	& c18_pkb <= 4399	// "Construction" coded to "Construction"
	replace 		industrycat10=6 	if c18_pkb >= 4500 	& c18_pkb <= 4799	// "Wholesale/retail, repair of vehicles" to "Commerce"
	replace 		industrycat10=7 	if c18_pkb >= 4900 	& c18_pkb <= 5399	// "Transport+storage" to "Transport". UN codes include storage
	replace 		industrycat10=6 	if c18_pkb >= 5500 	& c18_pkb <= 5699	// "Accommodation+Food" to "Commerce"
	replace 		industrycat10=7 	if c18_pkb >= 5800 	& c18_pkb <= 6399	// "Information+communication" to "Transport/Communication"
	replace 		industrycat10=8 	if c18_pkb >= 6400 	& c18_pkb <= 8299	// "Misc Business Services" to "Business Services"
	replace 		industrycat10=9 	if c18_pkb >= 8400 	& c18_pkb <= 8499	// "public administration/defense" to "public administration"
	replace 		industrycat10=10	if c18_pkb >= 8500 	& c18_pkb <= 9950	// "Other services" including direct education to "other"

	label var 		industrycat10 "1 digit industry classification, primary job 7 day recall"
	la de 			lblindustrycat10 	///
					1 "Agriculture" 	2 "Mining" ///
					3 "Manufacturing"	4 "Public utilities" ///
					5 "Construction"  	6 "Commerce" ///
					7 "Transport and Comnunications" ///
					8 "Financial and Business Services" ///
					9 "Public Administration" ///
					10 "Other Services, Unspecified"
	label values 	industrycat10 lblindustrycat10
*</_industrycat10_>


*<_industrycat4_>
	gen 			byte industrycat4 = industrycat10
	recode 			industrycat4 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var 		industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	la de 			lblindustrycat4 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values 	industrycat4 lblindustrycat4
*</_industrycat4_>


*<_occup_orig_>
	gen 			occup_orig = c16_procc
	label var 		occup_orig "Original occupation record primary job 7 day recall"
	replace 		occup_orig=. if lstatus!=1 			// restrict universe to employed only
	replace 		occup_orig=. if age < minlaborage	// restrict universe to working age
*</_occup_orig_>


*<_occup_isco_>
* in 2013, raw variable is numeric, 4-digits, but since there is no provided PSOC to ISCO
* conversion, at 4 digits, substring to 2 and match at 2
	loc matchvar   	c16_procc
	loc n 			1

	qui ds 			occup_orig, has(type numeric) 	// capture numeric var if is numeric
	loc iscovar 	= r(varlist)						// store this in a local
	loc len 		: list sizeof iscovar 				// store the length of this local (1 or 0)

		if (`len' == 1) {
															// run this if == 1 (ie, if occup_orig is numeric)
			tostring occup_orig	///						// make the numeric vars strings
				, generate(occup_orig_str) ///			// gen a variable with this prefix
				force
		}


	// merge sub-module with isco key

	gen psoc92_4dig = `matchvar'
	tostring 	psoc92_4dig ///
				, format(`"%04.0f"') replace

	gen psoc92  = substr(psoc92_4dig, 1,2)

	merge 		m:1 ///
				psoc92 ///
				using `isco_key' ///
				, generate(isco_merge_`n') ///
				keep(master match) // "left join"; remove obs that don't match from using


	rename 		isco88_sub_major_pad	isco88_sub_major_`n'

	drop 		psoc92 				// no longer needed, maintained in matchvar
	gen 		occup_isco = isco88_sub_major_`n'
	label var 	occup_isco "ISCO code of primary job 7 day recall"

*</_occup_isco_>


*<_occup_>


	* generate occupation variable
	gen byte occup=floor(c16_procc/1000)		// this handles most of recoding automatically.
	recode occup 0 = 10	if 	c16_procc<=129 	// recode "armed forces" to appropriate label
	recode occup 0 = 99	if 	(c16_procc == 930) // recode "Not classifiable occupations"


	/* Note that the raw variable, procc lists values, 94-99 for which there are no associated occupation
	   codes. Given that the raw data indicate that these individauls do have valid, non-missing occupations,
	   and that these occupations cannot be matched to our classificaitons with certainty, I have coded them as "other" */

	label var 		occup "1 digit occupational classification, primary job 7 day recall"
	la de 			lbloccup 	///
					1 "Managers" 	2 "Professionals" ///
					3 "Technicians" 4 "Clerks" ///
					5 "Service and market sales workers" ///
					6 "Skilled agricultural" ///
					7 "Craft workers" ///
					8 "Machine operators" ///
					9 "Elementary occupations" ///
					10 "Armed forces"  ///
					99 "Others"
	label values 	occup lbloccup
	replace 		occup=. if lstatus!=1 		// restrict universe to employed only
	replace 		occup=. if age < minlaborage	// restrict universe to working age
*</_occup_>


*<_occup_skill_>
	gen 			occup_skill = .
	replace 		occup_skill = 1 	if occup == 9
	replace 		occup_skill = 2 	if occup >=4 & occup <= 8
	replace 		occup_skill = 3 	if occup >=1 & occup <= 3
	replace 		occup_skill = 4 	if occup == 10
	replace 		occup_skill = 5 	if occup == 99
	la de 			lblskill 1 "Low skill" 2 "Medium skill" 3 "High skill" 4 "Armed Forces" 5 "Not Classified"
	label values 	occup_skill lblskill
	label var 		occup_skill "Skill based on ISCO standard primary job 7 day recall"
*</_occup_skill_>


*<_wage_no_compen_>
	gen 			double wage_no_compen = c27_pbasic
	replace 		wage_no_compen = . if 	wage_no_compen == 99999
	label var 		wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>


*<_unitwage_>
	gen byte unitwage = 1
	replace unitwage = . if lstatus != 1

	label var 		unitwage "Last wages' time unit primary job 7 day recall"
	la de 			lblunitwage ///
					1 "Daily" ///
					2 "Weekly" ///
					3 "Every two weeks" ///
					4 "Bimonthly"  ///
					5 "Monthly" ///
					6 "Trimester" ///
					7 "Biannual" ///
					8 "Annually" ///
					9 "Hourly" ///
					10 "Other"
	label values 	unitwage lblunitwage
*</_unitwage_>


*<_whours_>
	gen whours 		= c22_phours
	label var whours "Hours of work in last week primary job 7 day recall"
    replace 		whours = 84 	if whours > 84 & whours != . 	// replace unrealistic work weeks
*</_whours_>


*<_wmonths_>
	gen wmonths 	= .
	label var 		wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>


*<_wage_total_>
/* <_wage_total_note>

	Use gross wages when available and net wages only when gross wages are not available.
	This is done to make it easy to compare earnings in formal and informal sectors.

</_wage_total_note> */

	* No month data available for annualization
	gen wage_total 	= .
	label var wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>


*<_contract_>
	gen byte 		contract = .
	label var 		contract "Employment has contract primary job 7 day recall"
	la de 			lblcontract 0 "Without contract" 1 "With contract"
	label values 	contract lblcontract
*</_contract_>


*<_healthins_>
	gen byte 		healthins = .
	label var 		healthins "Employment has health insurance primary job 7 day recall"
	la de 			lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values 	healthins lblhealthins
*</_healthins_>


*<_socialsec_>
	gen byte 		socialsec = .
	label var 		socialsec "Employment has social security insurance primary job 7 day recall"
	la de 			lblsocialsec 1 "With social security" 0 "Without social secturity"
	label values 	socialsec lblsocialsec
*</_socialsec_>


*<_union_>
	gen byte 		union = .
	label var 		union "Union membership at primary job 7 day recall"
	la de 			lblunion 0 "Not union member" 1 "Union member"
	label values 	union lblunion
*</_union_>


*<_firmsize_l_>
	gen byte 		firmsize_l = .
	label var 		firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>


*<_firmsize_u_>
	gen byte 		firmsize_u= .
	label var 		firmsize_u "Firm size (upper bracket) primary job 7 day recall"
*</_firmsize_u_>

}


*----------8.3: 7 day reference secondary job------------------------------*
* Since labels are the same as main job, values are labelled using main job labels

{
*<_empstat_2_>
	gen byte 		empstat_2 = .
	label var 		empstat_2 "Employment status during past week secondary job 7 day recall"
	label values 	empstat_2 lblempstat
*</_empstat_2_>


*<_ocusec_2_>
	gen byte	 	ocusec_2 = .
	label var 		ocusec_2 "Sector of activity secondary job 7 day recall"
	label values 	ocusec_2 lblocusec
*</_ocusec_2_>


*<_industry_orig_2_>
	gen 			industry_orig_2 = j03_okb
	label var 		industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>


*<_industrycat_isic_2_>
	/* The key that matches industry codes is in string format to maintain leading/trailing
		zeros, so we will change the format here to string if necessary */

	loc matchvar   	j03_okb
	loc n 			2

	qui ds 			industry_orig_2, has(type numeric) 	// capture numeric var if is numeric
	loc isicvar 	= r(varlist)						// store this in a local
	loc len 		: list sizeof isicvar 				// store the length of this local (1 or 0)

		if (`len' == 1) {
															// run this if == 1 (ie, if industry_orig_2 is numeric)
			tostring industry_orig_2	///						// make the numeric vars strings
				, generate(industry_orig_2_str) ///			// gen a variable with this prefix
				force //


		}


	// merge sub-module with isic key

	gen class = `matchvar'
	tostring 	class ///
				, format(`"%04.0f"') replace


	merge 		m:1 ///
				class ///
				using `isic_key' ///
				, generate(isic_merge_`n') ///
				keep(master match) // "left join"; remove obs that don't match from using
				* the string variable in isic4 will is industrycat_isic

	// replace one code that I know doesn't match
	rename 		isic4	isic4_`n'
	replace 	isic4_`n' = "6810" 	if `matchvar' == 6819

	tab 		isic_merge_`n' 		if `matchvar' != .


	gen 		industrycat_isic_2 = isic4_`n'  	// the string variable becomes industrycat_isic

	drop 		class 				// no longer needed, maintained in matchvar


	*// industrycat_isic already generated above in submodule
	label var 		industrycat_isic_2 "ISIC code of secondary job 7 day recall"


*</_industrycat_isic_2_>


*<_industrycat10_2_>
	gen byte 		industrycat10_2 = .


	replace 		industrycat10_2=1 	if j03_okb >= 100 	& j03_okb <= 399	// "Agriculture, Forestry, Fishing" coded to "Agriculture"
	replace 		industrycat10_2=2 	if j03_okb >= 500 	& j03_okb <= 999	// "Mining and Quarrying" coded to "Mining"
	replace 		industrycat10_2=3 	if j03_okb >= 1000 	& j03_okb <= 3399 	// "Manufacturing" coded to "Manufacturing"
	replace 		industrycat10_2=4 	if j03_okb >= 3500 	& j03_okb <= 3900	// "Water supply, sewerage, etc" coded to "Public Utiltiy"
	replace 		industrycat10_2=5 	if j03_okb >= 4100 	& j03_okb <= 4399	// "Construction" coded to "Construction"
	replace 		industrycat10_2=6 	if j03_okb >= 4500 	& j03_okb <= 4799	// "Wholesale/retail, repair of vehicles" to "Commerce"
	replace 		industrycat10_2=7 	if j03_okb >= 4900 	& j03_okb <= 5399	// "Transport+storage" to "Transport". UN codes include storage
	replace 		industrycat10_2=6 	if j03_okb >= 5500 	& j03_okb <= 5699	// "Accommodation+Food" to "Commerce"
	replace 		industrycat10_2=7 	if j03_okb >= 5800 	& j03_okb <= 6399	// "Information+communication" to "Transport/Communication"
	replace 		industrycat10_2=8 	if j03_okb >= 6400 	& j03_okb <= 8299	// "Misc Business Services" to "Business Services"
	replace 		industrycat10_2=9 	if j03_okb >= 8400 	& j03_okb <= 8499	// "public administration/defense" to "public administration"
	replace 		industrycat10_2=10	if j03_okb >= 8500 	& j03_okb <= 9950	// "Other services" including direct education to "other"


	label var 		industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
	label values 	industrycat10_2 lblindustrycat10
*</_industrycat10_2_>


*<_industrycat4_2_>
	gen byte 		industrycat4_2 = industrycat10_2
	recode 			industrycat4_2 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var 		industrycat4_2 "Broad Economic Activities classification, secondary job 7 day recall"
	label values 	industrycat4_2 lblindustrycat4
*</_industrycat4_2_>


*<_occup_orig_2_>
	gen 			occup_orig_2 = j02_otocc
	label var 		occup_orig_2 "Original occupation record secondary job 7 day recall"
*</_occup_orig_2_>


*<_occup_isco_2_>
	loc matchvar   	j02_otocc
	loc n 			2

	qui ds 			occup_orig_2, has(type numeric) 	// capture numeric var if is numeric
	loc iscovar 	= r(varlist)						// store this in a local
	loc len 		: list sizeof iscovar 				// store the length of this local (1 or 0)

		if (`len' == 1) {
															// run this if == 1 (ie, if occup_orig is numeric)
			tostring occup_orig_2	///						// make the numeric vars strings
				, generate(occup_orig_2_str) ///			// gen a variable with this prefix
				force
		}


	// merge sub-module with isco key

	gen psoc92 = `matchvar'
	tostring 	psoc92 ///
				, format(`"%02.0f"') replace

	merge 		m:1 ///
				psoc92 ///
				using `isco_key' ///
				, generate(isco_merge_`n') ///
				keep(master match) // "left join"; remove obs that don't match from using


	rename 		isco88_sub_major_pad	isco88_sub_major_`n'

	drop 		psoc92 				// no longer needed, maintained in matchvar
	gen 		occup_isco_2 = isco88_sub_major_`n'
	label var 	occup_isco_2 "ISCO code of secondary job 7 day recall"
*</_occup_isco_2_>


*<_occup_skill_2_>
	gen 			occup_skill_2 = .
	la de 			lblskill2 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values 	occup_skill_2 lblskill2
	label var 		occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
*</_occup_skill_2_>


*<_occup_2_>
	gen byte 		occup_2=floor(j02_otocc/1000)		// this handles most of recoding automatically.
	recode 			occup_2 0 = 10	if 	j02_otocc<=129 	// recode "armed forces" to appropriate label
	recode 			occup_2 0 = 99	if 	(j02_otocc == 930) // recode "Not classifiable occupations"


	label var 		occup_2 "1 digit occupational classification secondary job 7 day recall"
	label values 	occup_2 lbloccup
*</_occup_2_>


*<_wage_no_compen_2_>
	gen 			double wage_no_compen_2 = j07_obasic
	replace 		wage_no_compen_2 = . if wage_no_compen_2 == 99999
	label var 		wage_no_compen_2 "Last wage payment secondary job 7 day recall"
*</_wage_no_compen_2_>


*<_unitwage_2_>
	gen byte 		unitwage_2 = j06_obasis
	replace 		unitwage_2 = . if 	unitwage >= 11 // replace potential missing values
	recode 			unitwage_2 (0 1 5 6 7 = 10) /// other
								(2 = 9) /// hourly
								(3 = 1) /// daily
								(4 = 5) // monthly

	label var 		unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values 	unitwage_2 lblunitwage
*</_unitwage_2_>


*<_whours_2_>
	gen 			whours_2 = j05_ohours
	label var 		whours_2 "Hours of work in last week secondary job 7 day recall"
*</_whours_2_>


*<_wmonths_2_>
	gen 			wmonths_2 = .
	label var 		wmonths_2 "Months of work in past 12 months secondary job 7 day recall"
*</_wmonths_2_>


*<_wage_total_2_>
	gen 			wage_total_2 = .
	label var 		wage_total_2 "Annualized total wage secondary job 7 day recall"
*</_wage_total_2_>


*<_firmsize_l_2_>
	gen byte 		firmsize_l_2 = .
	label var 		firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>


*<_firmsize_u_2_>
	gen byte 		firmsize_u_2 = .
	label var 		firmsize_u_2 "Firm size (upper bracket) secondary job 7 day recall"
*</_firmsize_u_2_>

}


*----------8.4: 7 day reference additional jobs------------------------------*

*<_t_hours_others_>
	gen 			t_hours_others = .
	label var 		t_hours_others ///
					"Annualized hours worked in all but primary and secondary jobs 7 day recall"
*</_t_hours_others_>


*<_t_wage_nocompen_others_>
	gen 			t_wage_nocompen_others = .
	label var 		t_wage_nocompen_others ///
					"Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_others_>


*<_t_wage_others_>
	gen 			t_wage_others = .
	label var 		t_wage_others ///
					"Annualized wage in all but primary and secondary jobs (12-mon ref period)"
*</_t_wage_others_>



*----------8.5: 7 day reference total summary------------------------------*
/*since no data exist on working months over the previous 12 month period,
	no asumptions will be made to extrapolate the 7-day reference period
	over the previous 12-month period. These data will simply be left as
	missing and left to the user to self-generate or make assumptions at
	her or his will.

	egen 			t_hours_total = rowtotal(whours whours_2 t_hours_others, missing) // missing obs treated as 0
	label var 		t_hours_total "Annualized hours worked in all jobs 7 day recall"
	replace 		t_hours_total = . 	if whours == . & whours_2 == . & t_hours_others == .
	*/
*<_t_hours_total_>
	*<_t_hours_total_note>
	* ILO defines yearly working hours as 48 * weekly estimate.
	*</_t_hours_total_note>
	egen 			t_hours_total = rowtotal(whours whours_2 t_hours_others), missing // missing obs treated as 0
	replace 		t_hours_total = t_hours_total * 48
	label var 		t_hours_total "Annualized hours worked in all jobs 7 day recall"
	replace 		t_hours_total = . 	if whours == . & whours_2 == . & t_hours_others == .
*</_t_hours_total_>


*<_t_wage_nocompen_total_>
	*<_t_wage_nocompen_total_>
	egen 			t_wage_nocompen_total = rowtotal(wage_total wage_total_2 t_wage_others), missing
	label var 		t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"
	replace 		t_wage_nocompen_total = . 	if wage_total == . & wage_total_2 == . & t_wage_others == .
*</_t_wage_nocompen_total_>


*<_t_wage_total_>
	/*no bonusus or compensation listed in wage, so same as nocomp variagble */
	gen 			t_wage_total = t_wage_nocompen_total
	label var 		t_wage_total "Annualized total wage for all jobs 7 day recall"
*</_t_wage_total_>



*----------8.6: 12 month reference overall------------------------------*
/*Note: sub-modules 8.6, 8.7, 8.8. 8.9, and 8.10 do not apply to PHL because there
 are no questions related to the previous 12-month reference period in the survey.*/

{

*<_lstatus_year_>
	gen byte 		lstatus_year = .
	replace 		lstatus_year=. 			if age < minlaborage & age != .
	label var 		lstatus_year 			"Labor status during last year"
	la de 			lbllstatus_year 		1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values 	lstatus_year 			lbllstatus_year
*</_lstatus_year_>

*<_potential_lf_year_>
	gen byte 		potential_lf_year = .
	replace 		potential_lf_year=. 	if age < minlaborage & age != .
	replace 		potential_lf_year = . 	if lstatus_year != 3
	label var 		potential_lf_year 		"Potential labour force status"
	la de 			lblpotential_lf_year 	0 "No" 1 "Yes"
	label values 	potential_lf_year 		lblpotential_lf_year
*</_potential_lf_year_>


*<_underemployment_year_>
	gen byte 		underemployment_year = .
	replace 		underemployment_year = . if age < minlaborage & age != .
	replace 		underemployment_year = . if lstatus_year == 1
	label var 		underemployment_year 	"Underemployment status"
	la de 			lblunderemployment_year 0 "No" 1 "Yes"
	label values 	underemployment_year 	lblunderemployment_year
*</_underemployment_year_>


*<_nlfreason_year_>
	gen byte 		nlfreason_year=.
	label var 		nlfreason_year 			"Reason not in the labor force"
	la de 			lblnlfreason_year 		1 "Student" 2 "Housekeeper" ///
											3 "Retired" 4 "Disable" 5 "Other"
	label values 	nlfreason_year 			lblnlfreason_year
*</_nlfreason_year_>


*<_unempldur_l_year_>
	gen byte 		unempldur_l_year=.
	label var 		unempldur_l_year 		"Unemployment duration (months) lower bracket"
	replace 		unempldur_l=. if lstatus!=2 	  // restrict universe to unemployed only
*</_unempldur_l_year_>


*<_unempldur_u_year_>
	gen byte 		unempldur_u_year=.
	label var 		unempldur_u_year 		"Unemployment duration (months) upper bracket"
	replace 		unempldur_u=. if lstatus!=2 	  // restrict universe to unemployed only
*</_unempldur_u_year_>


}

*----------8.7: 12 month reference main job------------------------------*

{

*<_empstat_year_>
	gen byte 		empstat_year = .
	label var 		empstat_year "Employment status during past week primary job 12 month recall"
	la de 			lblempstat_year ///
					1 "Paid employee" 	2 "Non-paid employee" ///
					3 "Employer" 		4 "Self-employed" ///
					5 "Other, workers not classifiable by status"
	label values 	empstat_year lblempstat_year
*</_empstat_year_>

*<_ocusec_year_>
	gen byte 		ocusec_year = .
	label var 		ocusec_year "Sector of activity primary job 12 day recall"
	la de 			lblocusec_year ///
					1 "Public Sector, Central Government, Army" ///
					2 "Private, NGO" ///
					3 "State owned" ///
					4 "Public or State-owned, but cannot distinguish"
	label values 	ocusec_year lblocusec_year
*</_ocusec_year_>

*<_industry_orig_year_>
	gen 			industry_orig_year = .
	label var 		industry_orig_year "Original industry record main job 12 month recall"
*</_industry_orig_year_>


*<_industrycat_isic_year_>
	gen 			industrycat_isic_year = .
	label var 		industrycat_isic_year "ISIC code of primary job 12 month recall"
*</_industrycat_isic_year_>

*<_industrycat10_year_>
	gen byte 		industrycat10_year = .
	label var 		industrycat10_year "1 digit industry classification, primary job 12 month recall"
	la de 			lblindustrycat10_year ///
					1 "Agriculture" ///
					2 "Mining" ///
					3 "Manufacturing" ///
					4 "Public utilities" ///
					5 "Construction"  ///
					6 "Commerce" ///
					7 "Transport and Comnunications" ///
					8 "Financial and Business Services" ///
					9 "Public Administration" ///
					10 "Other Services, Unspecified"
	label values 	industrycat10_year lblindustrycat10_year
*</_industrycat10_year_>


*<_industrycat4_year_>
	gen byte 		industrycat4_year=industrycat10_year
	recode 			industrycat4_year (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var 		industrycat4_year ///
					"Broad Economic Activities classification, primary job 12 month recall"
	la de 			lblindustrycat4_year 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values 	industrycat4_year lblindustrycat4_year
*</_industrycat4_year_>


*<_occup_orig_year_>
	gen 			occup_orig_year = .
	label var 		occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>


*<_occup_isco_year_>
	gen 			occup_isco_year = ""
	label var 		occup_isco_year "ISCO code of primary job 12 month recall"
*</_occup_isco_year_>


*<_occup_skill_year_>
	gen 			occup_skill_year = .
	la de 			lblskillyear 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values 	occup_skill_year lblskillyear
	label var 		occup_skill_year "Skill based on ISCO standard primary job 12 month recall"
*</_occup_skill_year_>


*<_occup_year_>
	gen 			byte occup_year = .
	label var 		occup_year "1 digit occupational classification, primary job 12 month recall"
	la de 			lbloccup_year ///
					1 "Managers" ///
					2 "Professionals" ///
					3 "Technicians" ///
					4 "Clerks" ///
					5 "Service and market sales workers" ///
					6 "Skilled agricultural" ///
					7 "Craft workers" ///
					8 "Machine operators" ///
					9 "Elementary occupations" ///
					10 "Armed forces"  ///
					99 "Others"
	label values 	occup_year lbloccup_year
*</_occup_year_>


*<_wage_no_compen_year_> --- this var has the same name as other and when quoted in the keep and order codes is repeated.
	gen double 		wage_no_compen_year = .
	label var 		wage_no_compen_year "Last wage payment primary job 12 month recall"
*</_wage_no_compen_year_>


*<_unitwage_year_>
	gen byte 		unitwage_year = .
	label var 		unitwage_year "Last wages' time unit primary job 12 month recall"
	la de 			lblunitwage_year ///
					1 "Daily" 			2 "Weekly" ///
					3 "Every two weeks" 4 "Bimonthly"  ///
					5 "Monthly" 		6 "Trimester" ///
					7 "Biannual" 		8 "Annually" ///
					9 "Hourly" 			10 "Other"
	label values 	unitwage_year lblunitwage_year
*</_unitwage_year_>


*<_whours_year_>
	gen 			whours_year = .
	label var 		whours_year "Hours of work in last week primary job 12 month recall"
*</_whours_year_>


*<_wmonths_year_>
	gen 			wmonths_year = .
	label var 		wmonths_year "Months of work in past 12 months primary job 12 month recall"
*</_wmonths_year_>


*<_wage_total_year_>
	gen 			wage_total_year = .
	label var 		wage_total_year "Annualized total wage primary job 12 month recall"
*</_wage_total_year_>


*<_contract_year_>
	gen byte 		contract_year = .
	label var 		contract_year "Employment has contract primary job 12 month recall"
	la de 			lblcontract_year 0 "Without contract" 1 "With contract"
	label values 	contract_year lblcontract_year
*</_contract_year_>


*<_healthins_year_>
	gen byte 		healthins_year = .
	label var 		healthins_year "Employment has health insurance primary job 12 month recall"
	la de 			lblhealthins_year 0 "Without health insurance" 1 "With health insurance"
	label values 	healthins_year lblhealthins_year
*</_healthins_year_>


*<_socialsec_year_>
	gen byte 		socialsec_year = .
	label var 		socialsec_year "Employment has social security insurance primary job 7 day recall"
	la de 			lblsocialsec_year 1 "With social security" 0 "Without social secturity"
	label values 	socialsec_year lblsocialsec_year
*</_socialsec_year_>


*<_union_year_>
	gen byte 		union_year = .
	label var 		union_year "Union membership at primary job 12 month recall"
	la de 			lblunion_year 0 "Not union member" 1 "Union member"
	label values 	union_year lblunion_year
*</_union_year_>


*<_firmsize_l_year_>
	gen byte 		firmsize_l_year = .
	label var 		firmsize_l_year "Firm size (lower bracket) primary job 12 month recall"
*</_firmsize_l_year_>


*<_firmsize_u_year_>
	gen byte 		firmsize_u_year = .
	label var 		firmsize_u_year "Firm size (upper bracket) primary job 12 month recall"
*</_firmsize_u_year_>




}


*----------8.8: 12 month reference secondary job------------------------------*

{

*<_empstat_2_year_>
	gen byte 		empstat_2_year = .
	label var 		empstat_2_year "Employment status during past week secondary job 12 month recall"
	label values 	empstat_2_year lblempstat_year
*</_empstat_2_year_>


*<_ocusec_2_year_>
	gen byte 		ocusec_2_year = .
	label var 		ocusec_2_year "Sector of activity secondary job 12 day recall"
	la de 			lblocusec_2_year ///
					1 "Public Sector, Central Government, Army" ///
					2 "Private, NGO" ///
					3 "State owned" ///
					4 "Public or State-owned, but cannot distinguish"
	label values 	ocusec_2_year lblocusec_2_year
*</_ocusec_2_year_>



*<_industry_orig_2_year_>
	gen 			industry_orig_2_year = .
	label var 		industry_orig_2_year "Original survey industry code, secondary job 12 month recall"
*</_industry_orig_2_year_>



*<_industrycat_isic_2_year_>
	gen 			industrycat_isic_2_year = .
	label var 		industrycat_isic_2_year "ISIC code of secondary job 12 month recall"
*</_industrycat_isic_2_year_>


*<_industrycat10_2_year_>
	gen byte 		industrycat10_2_year = .
	label var 		industrycat10_2_year "1 digit industry classification, secondary job 12 month recall"
	label values 	industrycat10_2_year lblindustrycat10_year
*</_industrycat10_2_year_>


*<_industrycat4_2_year_>
	gen byte 		industrycat4_2_year=industrycat10_2_year
	recode 			industrycat4_2_year (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	label var 		industrycat4_2_year "Broad Economic Activities classification, secondary job 12 month recall"
	label values 	industrycat4_2_year lblindustrycat4_year
*</_industrycat4_2_year_>


*<_occup_orig_2_year_>
	gen 			occup_orig_2_year = .
	label var 		occup_orig_2_year "Original occupation record secondary job 12 month recall"
*</_occup_orig_2_year_>


*<_occup_isco_2_year_>
	gen 			occup_isco_2_year = ""
	label var 		occup_isco_2_year "ISCO code of secondary job 12 month recall"
*</_occup_isco_2_year_>


*<_occup_skill_2_year_>
	gen 			occup_skill_2_year = .
	la de 			lblskilly2 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values 	occup_skill_2_year lblskilly2
	label var 		occup_skill_2_year "Skill based on ISCO standard secondary job 12 month recall"
*</_occup_skill_2_year_>


*<_occup_2_year_>
	gen 			byte occup_2_year = .
	label var 		occup_2_year "1 digit occupational classification, secondary job 12 month recall"
	label values 	occup_2_year lbloccup_year
*</_occup_2_year_>


*<_wage_no_compen_2_year_>
	gen double 		wage_no_compen_2_year = .
	label var 		wage_no_compen_2_year "Last wage payment secondary job 12 month recall"
*</_wage_no_compen_2_year_>


*<_unitwage_2_year_>
	gen byte 		unitwage_2_year = .
	label var 		unitwage_2_year "Last wages' time unit secondary job 12 month recall"
	label values 	unitwage_2_year lblunitwage_year
*</_unitwage_2_year_>


*<_whours_2_year_>
	gen 			whours_2_year = .
	label var 		whours_2_year "Hours of work in last week secondary job 12 month recall"
*</_whours_2_year_>


*<_wmonths_2_year_>
	gen 			wmonths_2_year = .
	label var 		wmonths_2_year "Months of work in past 12 months secondary job 12 month recall"
*</_wmonths_2_year_>


*<_wage_total_2_year_>
	gen 			wage_total_2_year = .
	label var 		wage_total_2_year "Annualized total wage secondary job 12 month recall"
*</_wage_total_2_year_>

*<_firmsize_l_2_year_>
	gen byte 		firmsize_l_2_year = .
	label var 		firmsize_l_2_year "Firm size (lower bracket) secondary job 12 month recall"
*</_firmsize_l_2_year_>


*<_firmsize_u_2_year_>
	gen byte 		firmsize_u_2_year = .
	label var 		firmsize_u_2_year "Firm size (upper bracket) secondary job 12 month recall"
*</_firmsize_u_2_year_>




}


*----------8.9: 12 month reference additional jobs------------------------------*


*<_t_hours_others_year_>
	gen 			t_hours_others_year = .
	label var 		t_hours_others_year ///
					"Annualized hours worked in all but primary and secondary jobs 12 month recall"
*</_t_hours_others_year_>

*<_t_wage_nocompen_others_year_>
	gen 			t_wage_nocompen_others_year = .
	label var 		t_wage_nocompen_others_year ///
					"Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_others_year_>

*<_t_wage_others_year_>
	gen 			t_wage_others_year = .
	label var 		t_wage_others_year ///
					"Annualized wage in all but primary and secondary jobs 12 month recall"
*</_t_wage_others_year_>



*----------8.10: 12 month total summary------------------------------*


*<_t_hours_total_year_>
	gen 			t_hours_total_year = .
	label var 		t_hours_total_year "Annualized hours worked in all jobs 12 month month recall"
*</_t_hours_total_year_>


*<_t_wage_nocompen_total_year_>
	gen 			t_wage_nocompen_total_year = .
	label var 		t_wage_nocompen_total_year ///
					"Annualized wage in all jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_total_year_>


*<_t_wage_total_year_>
	gen 			t_wage_total_year = .
	label var 		t_wage_total_year "Annualized total wage for all jobs 12 month recall"
*</_t_wage_total_year_>


*----------8.11: Overall across reference periods------------------------------*


*<_njobs_>
	*<_njobs_note>
	* The provided njobs data appears to be inconsistent with data, so I dedicded not to include.
	*</_njobs_note>

	gen 			njobs = .
	label var 		njobs "Total number of jobs"
*</_njobs_>


*<_t_hours_annual_>
	/*ILO defines approximate annual working hours as weekly total * 48 */
	gen 			t_hours_annual = t_hours_total
	label var 		t_hours_annual "Total hours worked in all jobs in the previous 12 months"
*</_t_hours_annual_>


*<_linc_nc_>
	gen 			linc_nc = t_wage_nocompen_total
	label var 		linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."
*</_linc_nc_>


*<_laborincome_>
	gen 			laborincome = t_wage_total
	label var 		laborincome ///
					"Total annual individual labor income in all jobs, incl. bonuses, etc."
*</_laborincome_>



*----------8.13: Labour cleanup------------------------------*

{
*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
	local lab_var 	minlaborage lstatus nlfreason unempldur_l unempldur_u empstat ocusec industry_orig ///
					industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup ///
					wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union ///
					firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 ///
					industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 ///
					whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others ///
					t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year nlfreason_year ///
					unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year ///
					industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year ///
					unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year ///
					union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year ///
					industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year ///
					occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year ///
					wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year ///
					t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs ///
					t_hours_annual linc_nc laborincome

* make a second iternation that excludes lstatus variables
	local except 	lstatus lstatus_year
	local lab_var2 	: list lab_var - except


	foreach v of local lab_var {
		cap confirm numeric variable `v'
		if _rc == 0 { 	// is indeed numeric
			replace `v'=. if ( age < minlaborage & !missing(age) )
		}
		else { 			// is not
			replace `v'= "" if ( age < minlaborage & !missing(age) )
		}

	}

*</_% Correction min age_>


*<_% Correction lstatus_>

/* <_correction_lstatus_note>

	The labor module information should only be applicable to those who are "employed"
	or classified as lstatus == 1

</_correction_lstatus_note> */
	* use labvar2 because we don't want to replace lstatus, etc in this case
	foreach v of local lab_var2 {
		cap confirm numeric variable `v'
		if _rc == 0 { 	// is indeed numeric
			replace `v'=. if ( lstatus !=1 & !missing(lstatus) )
		}
		else { 			// is not
			replace `v'= "" if ( lstatus !=1 & !missing(lstatus) )
		}

	}

*</_% Correction lstatus_>


}


/*%%=============================================================================================
	9: Final steps
==============================================================================================%%*/

quietly{

*<_% KEEP VARIABLES - ALL_>

	keep 	countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata ///
			wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code ///
			gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty ///
			conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban ///
			migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 ///
			educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field vocational_financed ///
			minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig ///
			industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours ///
			wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 ///
			industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 ///
			unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others ///
			t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year ///
			nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year ///
			industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year ///
			unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year ///
			firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year ///
			industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year ///
			wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year ///
			firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year ///
			t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order 	countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave ///
			urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code ///
			gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty ///
			conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years ///
			migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy ///
			educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u ///
			vocational_field vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u ///
			empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup ///
			wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ///
			ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 ///
			occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 ///
			t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year ///
			potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year ///
			industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year ///
			occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year ///
			healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year ///
			industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year ///
			occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year ///
			wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year ///
			t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual ///
			linc_nc laborincome

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

save `"`path_output'"', replace

*</_% SAVE_>
