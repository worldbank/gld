/* ------- -------- ------ ------- --------- ------ ------ ------ ---- --- --- --- --- -- -- --- -- -- --
name: PHL_MAIN.do
description: calls all PHL scripts for I2D2+GLD, edited from iecodebook script

-- -- -- --- ---- ---- ---- ---- ------- -------- --------- --------- ------------- ---------------------*/




   * Internal project folder paths. Same no matter user
   * ---------------------

	loc 	cty 		"PHL" 			// set to three letter country/economy code

	gl 		PHL_data 	`"${GLD}:/GLD-Harmonization/551206_TM/PHL/PHL_data"' // PHL global data folder
	gl 		  adm2_labs	`"${PHL_data}/GLD/GLD_PHL_admin2_labels.dta"'





* Run settings
* 	Set to 1 to run, 0 otherwise
* ---------------------


** survey type settings.
* you can allow either or I2D2/GLD code to run

loc 	i2d2 		0	// 1 will allow i2d2 code to run, 0 otherwise
loc 	gld 		1 	// 1 will allow GLD code to run, 0 otherwise
loc 	checks_i2 	0	// 1 to run i2d2 check main script


** Survey Year settings.
* you can run a specific year by setting to 1

loc 	phl1997		0
loc 	phl1998 	0
loc 	phl1999 	0
loc 	phl2000 	0
loc 	phl2001 	0
loc 	phl2002		0
loc 	phl2003		0
loc 	phl2004		0
loc 	phl2005 	0
loc 	phl2006  	0
loc 	phl2007 	0
loc 	phl2008		0
loc 	phl2009 	0
loc 	phl2010		0
loc 	phl2011 	0
loc 	phl2012		0
loc 	phl2013		0
loc 	phl2014		0
loc 	phl2015 	0
loc 	phl2016  	0
loc 	phl2017 	1
loc 	phl2018		0
loc 	phl2019 	0
loc 	phl2020 	0

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
		do `"${code}/`cty'/`cty'_`year'_LFS/`cty'_`year'_LFS_v01_M_v01_A_GLD/Programs/`cty'_`year'_GLD_LFS.do"'
	}
}
}

* Run I2D2 Checks
if (`checks_i2' == 1) {
	forvalues year = 1997/2019 {
		do 	`"${clone}/gld/Support/I2D2 Check/PHL/PHL_`year'_I2D2_Check.do"'
	}
}
