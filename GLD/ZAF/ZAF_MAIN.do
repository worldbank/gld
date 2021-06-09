/* ------- -------- ------ ------- --------- ------ ------ ------ ---- --- --- --- --- -- -- --- -- -- --
name: ZAF_MAIN.do
description: calls all ZAF scripts for I2D2+GLD, edited from iecodebook script

-- -- -- --- ---- ---- ---- ---- ------- -------- --------- --------- ------------- ---------------------*/




   * Internal project folder paths. Same no matter user
   * ---------------------

	loc 	cty 	"ZAF" 			// set to three letter country/economy code





* Run settings
* 	Set to 1 to run, 0 otherwise
* ---------------------


** survey type settings.
* you can allow either or I2D2/GLD code to run

loc 	i2d2 		1 	// 1 will allow i2d2 code to run, 0 otherwise
loc 	gld 		0 	// 1 will allow GLD code to run, 0 otherwise

** Survey Year settings.
* you can run a specific year by setting to 1

loc 	zaf1997		0
loc 	zaf1998 	0
loc 	zaf1999 	0
loc 	zaf2000 	0
loc 	zaf2001 	0
loc 	zaf2002		0
loc 	zaf2003		0
loc 	zaf2004		0
loc 	zaf2005 	0
loc 	zaf2006  	0
loc 	zaf2007 	0
loc 	zaf2008		0
loc 	zaf2009 	0
loc 	zaf2010		0
loc 	zaf2011 	0
loc 	zaf2012		1
loc 	zaf2013		0
loc 	zaf2014		0
loc 	zaf2015 	0
loc 	zaf2016  	0
loc 	zaf2017 	0
loc 	zaf2018		0
loc 	zaf2019 	0
loc 	zaf2020 	0

* Run
* ---------------------

* Run I2D2 code
if (`i2d2' == 1) {
forvalues year = 1997/2020 {
    if (`zaf`year''==1) {
		do `"${code}/`cty'/`cty'_`year'_LFS/`cty'_`year'_LFS_v01_M_v01_A_I2D2/Programs/`cty'_`year'_I2D2_LFS.do"'
	}
}
}

* Run GLD code
if (`gld' == 1) {
forvalues year = 1997/2020 {
    if (`zaf`year''==1) {
		do `"${code}/`cty'/`cty'_`year'_LFS/`cty'_`year'_LFS_v01_M_v01_A_GLD/Programs/`cty'_`year'_GLD_LFS.do"'
	}
}
}
