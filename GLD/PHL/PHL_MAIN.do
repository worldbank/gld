/* ------- -------- ------ ------- --------- ------ ------ ------ ---- --- --- --- --- -- -- --- -- -- --
name: PHL_MAIN.do
description: calls all PHL scripts for I2D2+GLD, edited from iecodebook script

-- -- -- --- ---- ---- ---- ---- ------- -------- --------- --------- ------------- ---------------------*/




   * Internal project folder paths. Same no matter user
   * ---------------------

	loc 	cty 		"PHL" 			// set to three letter country/economy code

	gl 		PHL_data 	`"Y:/GLD-Harmonization/551206_TM/PHL/PHL_data"' // PHL global data folder
	gl 		  adm2_labs	`"${PHL_data}/GLD/GLD_PHL_admin2_labels.dta"'





* Run settings
* 	Set to 1 to run, 0 otherwise
* ---------------------


** survey type settings.
* you can allow either or I2D2/GLD code to run

loc 	i2d2 		0	// 1 will allow i2d2 code to run, 0 otherwise
loc 	gld 		1 	// 1 will allow GLD code to run, 0 otherwise
loc 	checks_i2 	0	// 1 to run i2d2 check main script
loc 	checks_gld 	1 	// 1 to run gld checks


** Survey Year settings.
* you can run a specific year by setting to 1

loc 	phl1997		1
loc 	phl1998 	1
loc 	phl1999 	1
loc 	phl2000 	1
loc 	phl2001 	1
loc 	phl2002		1
loc 	phl2003		1
loc 	phl2004		1
loc 	phl2005 	1
loc 	phl2006  	0 // individually
loc 	phl2007 	0 // ind
loc 	phl2008		1 
loc 	phl2009 	1
loc 	phl2010		1
loc 	phl2011 	1
loc 	phl2012		1
loc 	phl2013		1
loc 	phl2014		0 // ind
loc 	phl2015 	1
loc 	phl2016  	1
loc 	phl2017 	0 // ind
loc 	phl2018		1
loc 	phl2019 	1
loc 	phl2020 	1

* Run
* ---------------------

* Run I2D2 code
if (`i2d2' == 1) {
forvalues year = 1997/2019 {
    if (`phl`year''==1) {
		do `"${code}/`cty'/`cty'_`year'_LFS/`cty'_`year'_LFS_v01_M_v01_A_I2D2/Programs/`cty'_`year'_I2D2_LFS.do"'
	}
}
}

* Run GLD code
if (`gld' == 1) {
forvalues year = 1997/2019 {
    if (`phl`year''==1) {
		do `"${code}/`cty'/`cty'_`year'_LFS/`cty'_`year'_LFS_v01_M_v01_A_GLD/Programs/`cty'_`year'_LFS_v01_M_v01_A_GLD_ALL.do"'
	}
}
}

* Run I2D2 Checks
if (`checks_i2' == 1) {
	forvalues year = 1997/2019 {
		do 	`"${clone}/gld/Support/I2D2 Check/PHL/PHL_`year'_I2D2_Check.do"'
	}
}


* Run GLD Checks
if (`checks_gld' == 1) {
	forvalues year = 1997/2019 {
		do 	`"${code}/`cty'/`cty'_`year'_LFS/`cty'_`year'_LFS_v01_M_v01_A_GLD/Programs/`cty'_GLD_q_checks_`year'_MAIN.do"'
	}
}
