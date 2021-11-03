/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	PHILIPPINES
** COUNTRY ISO CODE	PHL
** YEAR	2003
** SURVEY NAME	Labor Force Survey
** SURVEY AGENCY	National Statistical Office
** UNIT OF ANALYSIS	Household and Individual
** INPUT DATABASES	LFS JAN2003
** RESPONSIBLE	 World Bank Jobs Group
** Created	4/4/2012
** Modified	24/5/2021
** NUMBER OF HOUSEHOLDS
** NUMBER OF INDIVIDUALS
** EXPANDED POPULATION
** NUMBER OF SURVEY ROUNDS: 4
**                                                                                                  **
******************************************************************************************************
*****************************************************************************************************/

/*****************************************************************************************************
*                                                                                                    *
                                   INITIAL COMMANDS
*                                                                                                    *
*****************************************************************************************************/


** INITIAL COMMANDS
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

** DIRECTORY

	local 	cty3 	"PHL" 	// set this to the three letter country/economy abbreviation
	local 	usr		`"551206_TM"' // set this to whatever Mario named your folder
	local 	surv_yr `"2003"'	// set this to the survey year

** RUN SETTINGS
	local 	cb_pause = 0	// 1 to pause+edit the exported codebook for harmonizing varnames, else 0
	local 	append 	 = 1	// 1 to run iecodebook append, 0 if file is already appended.
	local 	drop 	 = 1 	// 1 to drop variables with all missing values, 0 otherwise


	local 	year 		"Y:\GLD-Harmonization\\`usr'\\`cty3'\\`cty3'_`surv_yr'_LFS" // top data folder

	local 	main		"`year'\\`cty3'_`surv_yr'_LFS_v01_M"
	local 	 stata		"`main'\data\stata"
	local 	gld 		"`year'\\`cty3'_`surv_yr'_LFS_v01_M_v01_A_GLD"
	local 	i2d2		"`year'\\`cty3'_`surv_yr'_LFS_v01_M_v01_A_I2D2"
	local 	 code 		"`i2d2'\Programs"
	local 	 id_data 	"`i2d2'\Data\Harmonized"

	local 	lb_mod_age	15	// labor module minimun age (inclusive)
	local 	ed_mod_age	5	// labor module minimun age (inclusive)

** LOG FILE
	log using `"`id_data'\\`cty3'_`surv_yr'_I2D2_LFS.log"', replace


** FILES

	* processed
	local i2d2_1	`"`id_data'\rounds\PHL_2003_I2D2_LFS_JAN.dta"'
	local i2d2_2	`"`id_data'\rounds\PHL_2003_I2D2_LFS_APR.dta"'
	local i2d2_3	`"`id_data'\rounds\PHL_2003_I2D2_LFS_JUL.dta"'
	local i2d2_4	`"`id_data'\rounds\PHL_2003_I2D2_LFS_OCT.dta"'

** VALUES
	local n_round 	4			// numer of survey rounds
	local cases  	784844		// 184228 (Jan) + 183926 (APR) + 207974 (Jul) + 208716 (Oct) (Source: ILO from PSA)


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
/*	we will call each of the scripts that will run the code to harmonize and produce the relevant waves/rounds.
	Each round will produce a .dta file that will be appended later in this code. This script assumes you are
	running from the GLD_I2D2_MAIN.do, which has the relevant globals stored for the file paths. Otherwise, you
	will need to change them to the full local file path */
if (`drop' == 1) {
do `"${code}/PHL/PHL_2003_LFS/PHL_2003_LFS_v01_M_v01_A_I2D2/Programs/PHL_2003_I2D2_LFS_JAN.do"'
do `"${code}/PHL/PHL_2003_LFS/PHL_2003_LFS_v01_M_v01_A_I2D2/Programs/PHL_2003_I2D2_LFS_APR.do"'
do `"${code}/PHL/PHL_2003_LFS/PHL_2003_LFS_v01_M_v01_A_I2D2/Programs/PHL_2003_I2D2_LFS_JUL.do"'
do `"${code}/PHL/PHL_2003_LFS/PHL_2003_LFS_v01_M_v01_A_I2D2/Programs/PHL_2003_I2D2_LFS_OCT.do"'

}

** APPEND
use 				`i2d2_1'	///
					, clear

append 		using 	`i2d2_2' ///
					`i2d2_3' ///
					`i2d2_4'

** WEIGHT
** replace weight by 1/4 of weight variable (account for appending of 4 rounds )
replace wgt = wgt / 4 // this has previously been inversely scaled by 10000 

** ID OPERATIONS
	/*At this point in the data flow, we've proven that the household id (idh) and individual id (idp)
	 uniquely identify observations within rounds. But the formula that generates uniform length string
	 IDs means that this won't be unique across all 4 rounds when appended. We simply need to add the
	 round variable in string form to the idh string variable. Then idh idp will be unique */

	 ** Add round as a prefix to Household ID string variable
		tostring round	///								// make numeric variables strings
			, generate(round_str) ///					// generate a string version of round called round_str
			force format(`"%01.0f"')					// ...we know that round will only be 1 digit, fixed format


		egen idh_yr 	= concat(round_str idh)			// idh now becomes the concatenation of round_str and idh

		rename 			idh 	idh_round				// change the "old" idh var
		rename 			idh_yr 	idh 					// the new concatenated variable beomces idh

	 ** Final ID Check
	 isid 	idh idp








/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/




** ORDER KEEP VARIABLES
	ds
	loc 		vars = r(varlist)

	local 		order 														///
				sample ccode year intv_year month idh idp wgt strata psu urb	///
				reg01 reg02 reg03  reg02_orig reg03_orig  ///
				ownhouse water electricity toilet landphone ///
				cellphone computer internet hhsize head gender age soc marital ///
				ed_mod_age everattend atschool literacy educy edulevel1 edulevel2 ///
				edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year ///
				njobs njobs_year ocusec nlfreason unempldur_l unempldur_u industry ///
				industry1 industry_orig occup occup_orig firmsize_l firmsize_u ///
				whours wage unitwage contract empstat_2 empstat_2_year ///
				industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
				healthins socialsec union rbirth_juris rbirth rprevious_juris ///
				rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d round

	loc 		overlap : list order & vars

	keep 		`overlap'
	order 		`overlap'

	compress


** DELETE MISSING VARIABLES
	* if variables are missing on all values, drop them, unless they are listed as "key" variable

	* declare list of key variables that should never have missing observations
	loc	nomissvars sample ccode year intv_year month idh idp wgt strata psu hhsize ed_mod_age lb_mod_age round


	local missvars : 	list overlap - nomissvars


	if (`drop' == 1) {
		missings dropvars 	`missvars', force
	}


** OBSERVATION MISSING VALUES
	/*we know that some variables should not have missing values. Keep track of how many obs are missing
	for these variables only*/


	foreach var of local nomissvars {
		qui mdesc `var'
		loc nmiss = r(miss)
		cap assert r(miss) == 0
		if _rc {
			display as txt "Variable " as result "`var'" as txt " has `nmiss' observations."
		}
		else {
			display as txt "Variable " as result "`var'" as txt " has no missing observations."
		}
	}

** Drop Unused Value labels

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

	* Compare lists, if not
	local notused : list all_lab - used_lab 		// local `notused' defines value labs not in remaining vars
	local notused_len : list sizeof notused 		// store size of local

	* drop labels if the length of the notused vector is 1 or greater

	if `notused_len' >= 1 {
		label drop `notused'
	}
	else {
		di "There are no unused labels to drop"
	}

	save `"`id_data'\\PHL_2003_I2D2_LFS.dta"', replace

	log close


	clear









******************************  END OF DO-FILE  *****************************************************/
