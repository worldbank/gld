/* ------- -------- ------ ------- --------- ------ ------ ------ ---- --- --- --- --- -- -- --- -- -- --
name: MEX_MAIN.do
description: calls all MEX scripts for I2D2+GLD, edited from iecodebook script

-- -- -- --- ---- ---- ---- ---- ------- -------- --------- --------- ------------- ---------------------*/




   * Internal project folder paths. Same no matter user
   * ---------------------

	loc 	cty 	"MEX" 			// set to three letter country/economy code





* Run settings
* 	Set to 1 to run, 0 otherwise
* ---------------------


** survey type settings.
* you can allow either or I2D2/GLD code to run

loc 	i2d2 		1 	// 1 will allow i2d2 code to run, 0 otherwise
loc 	gld 		0 	// 1 will allow GLD code to run, 0 otherwise

** Survey Year settings.
* you can run a specific year by setting to 1

loc 	mex1997		0
loc 	mex1998 	0
loc 	mex1999 	0
loc 	mex2000 	0
loc 	mex2001 	0
loc 	mex2002		0
loc 	mex2003		0
loc 	mex2004		0
loc 	mex2005 	0
loc 	mex2006  	0
loc 	mex2007 	0
loc 	mex2008		0
loc 	mex2009 	0
loc 	mex2010		0
loc 	mex2011 	0
loc 	mex2012		1
loc 	mex2013		0
loc 	mex2014		0
loc 	mex2015 	0
loc 	mex2016  	0
loc 	mex2017 	0
loc 	mex2018		0
loc 	mex2019 	0
loc 	mex2020 	0

* Run
* ---------------------

* Run I2D2 code
if (`i2d2' == 1) {
forvalues year = 1997/2020 {
    if (`mex`year''==1) {
		do `"${code}/`cty'/`cty'_`year'_LFS/`cty'_`year'_LFS_v01_M_v01_A_I2D2/Programs/`cty'_`year'_I2D2_LFS.do"'
	}
}
}

* Run GLD code
if (`gld' == 1) {
forvalues year = 1997/2020 {
    if (`mex`year''==1) {
		do `"${code}/`cty'/`cty'_`year'_LFS/`cty'_`year'_LFS_v01_M_v01_A_GLD/Programs/`cty'_`year'_GLD_LFS.do"'
	}
}
}
