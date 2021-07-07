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

** DIRECTORY

	local 	cty3 	"PHL" 	// set this to the three letter country/economy abbreviation
	local 	usr		`"551206_TM"' // set this to whatever Mario named your folder
	local 	surv_yr `"2003"'	// set this to the survey year

** RUN SETTINGS
	local 	cb_pause = 0	// 1 to pause+edit the exported codebook for harmonizing varnames, else 0
	local 	append 	 = 1	// 1 to run iecodebook append, 0 if file is already appended.


	local 	year 		"${GLD}:\GLD-Harmonization\\`usr'\\`cty3'\\`cty3'_`surv_yr'_LFS" // top data folder

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
	local round1 `"`stata'\LFS JAN2003.dta"'
	local round2 `"`stata'\LFS APR2003.dta"'
	local round3 `"`stata'\LFS JUL2003.dta"'
	local round4 `"`stata'\LFS OCT2003.dta"'

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

do `"${code}/PHL/PHL_2003_LFS/PHL_2003_LFS_v01_M_v01_A_I2D2/Programs/PHL_2003_I2D2_LFS_JAN.do"'
do `"${code}/PHL/PHL_2003_LFS/PHL_2003_LFS_v01_M_v01_A_I2D2/Programs/PHL_2003_I2D2_LFS_APR.do"'
do `"${code}/PHL/PHL_2003_LFS/PHL_2003_LFS_v01_M_v01_A_I2D2/Programs/PHL_2003_I2D2_LFS_JUL.do"'
*do `"${code}/PHL/PHL_2003_LFS/PHL_2003_LFS_v01_M_v01_A_I2D2/Programs/PHL_2003_I2D2_LFS_OCT.do"'

** HARMONIZE VARIABLE NAMES, LABELS











/*

/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL
	keep sample ccode year intv_year month idh idp wgt strata psu urb ///
				reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
				cellphone computer internet hhsize head gender age soc marital ed_mod_age ///
				everattend atschool literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age ///
				lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason ///
				unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig ///
				firmsize_l firmsize_u whours wage unitwage contract  empstat_2 ///
				empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
				healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious ///
				yrmove rprevious_time_ref pci pci_d pcc pcc_d reg02_orig reg03_orig


** ORDER VARIABLES
	order sample ccode year intv_year month idh idp wgt strata psu urb	///
				reg01 reg02 reg03 reg04 reg02_orig reg03_orig  ///
				ownhouse water electricity toilet landphone ///
				cellphone computer internet hhsize head gender age soc marital ///
				ed_mod_age everattend atschool literacy educy edulevel1 edulevel2 ///
				edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year ///
				njobs njobs_year ocusec nlfreason unempldur_l unempldur_u industry ///
				industry1 industry_orig occup occup_orig firmsize_l firmsize_u ///
				whours wage unitwage contract empstat_2 empstat_2_year ///
				industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
				healthins socialsec union rbirth_juris rbirth rprevious_juris ///
				rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d

	compress


** DELETE MISSING VARIABLES
	local keep ""
	qui levelsof ccode, local(cty)
	foreach var of varlist urb - pcc_d {
	qui sum `var'
	scalar sclrc = r(mean)
	if sclrc==. {
	     display as txt "Variable " as result "`var'" as txt " for ccode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
	}
	else {
	     local keep `keep' `var'
	}
	}
	keep sample ccode year intv_year month  idh idp wgt strata psu `keep'



** MISSING VALUES
	*Declare varlist which cannot contain missings
	loc	nomissvars sample ccode year intv_year month idh idp wgt strata psu hhsize ed_mod_age lb_mod_age

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


	save `"`id_data'\\`cty3'_`surv_yr'_I2D2_LFS.dta"', replace

	log close


	clear









******************************  END OF DO-FILE  *****************************************************/
