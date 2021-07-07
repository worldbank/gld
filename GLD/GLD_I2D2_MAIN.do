/* ------- -------- ------ ------- --------- ------ ------ ------ ---- --- --- --- --- -- -- --- -- -- --
name: GLD_I2D2_MAIN.do
description: calls all scripts for I2D2 and GLD, edited from iecodebook script

-- -- -- --- ---- ---- ---- ---- ------- -------- --------- --------- ------------- ---------------------*/



*iefolder*0*StandardSettings****************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 0:  INSTALL PACKAGES AND STANDARDIZE SETTINGS
   *
   *           - Install packages needed to run all dofiles called
   *            by this master dofile.
   *           - Use ieboilstart to harmonize settings across users
   *
   * ******************************************************************** *

*iefolder*0*End_StandardSettings************************************************
*iefolder will not work properly if the line above is edited
	clear all
	macro drop _all
   *Install all packages that this project requires:
   *(Note that this never updates outdated versions of already installed commands, to update commands use adoupdate)
   local user_commands ietoolkit scores  //Fill this list will all user-written commands this project requires
   foreach command of local user_commands {
       cap which `command'
       if _rc == 111 {
           ssc install `command'
       }
   }

   *Standardize settings accross users
   ieboilstart, version(12.1)          //Set the version number to the oldest version used by anyone in the project team
   `r(version)'                        //This line is needed to actually set the version from the command above

*iefolder*1*FolderGlobals*******************************************************
*iefolder will not work properly if the line above is edited

   * ******************************************************************** *
   *
   *       PART 1:  PREPARING FOLDER PATH GLOBALS
   *
   *           - Set the global box to point to the project folder
   *            on each collaborator's computer.
   *           - Set other locals that point to other folders of interest.
   *
   * ******************************************************************** *







   * Users
   * -----------

   *User Number:
   * Alexandra		             			      	  1    //
   * Angelo					           				  2    //
   * Junying					           				3    //
   * Mario					           				  4    //
   * Tom					           				  5    //
   * Other					           				  6    //

   *Set this value to the user currently using this file
   global user  5



   * Root folder globals
   * ---------------------

    if $user == 5 {
        global data		""					// data folder
		global GLD 		"Y"					// set this to the letter the GLD drive is on your computer
		global i2d2 	"Z"					// set this to the letter the I2D2 drive is on your computer
        global clone	"C:/Users/WB551206/local/GitHub" // github/code top folder
    }


	if $user == 1 {
	global data		"" 			// replace with folder above data repo
	global GLD 		""			// set this to the letter the GLD drive is on your computer
	global i2d2 	""					// set this to the letter the I2D2 drive is on your computer
	global clone	"" // replace with folder above github folder
    }

	if $user == 2 {
	global data		"" 			// replace with folder above data repo
	global GLD 		""			// set this to the letter the GLD drive is on your computer
	global i2d2 	""					// set this to the letter the I2D2 drive is on your computer
	global clone	"" // replace with folder above github folder
    }

	if $user == 3 {
	global data		"" 			// replace with folder above data repo
	global GLD 		""			// set this to the letter the GLD drive is on your computer
	global i2d2 	""					// set this to the letter the I2D2 drive is on your computer
	global clone	"" // replace with folder above github folder
    }

	if $user == 4 {
	global data		"" 			// replace with folder above data repo
	global GLD 		""			// set this to the letter the GLD drive is on your computer
	global i2d2 	""					// set this to the letter the I2D2 drive is on your computer
	global clone	"" // replace with folder above github folder
    }

	if $user == 6 {
	global data		"" 			// replace with folder above data repo
	global GLD 		""			// set this to the letter the GLD drive is on your computer
	global i2d2 	""					// set this to the letter the I2D2 drive is on your computer
	global clone	"" // replace with folder above github folder
    }



   * Internal project folder paths. Same no matter user
   * ---------------------

	global  code 	`"${clone}/gld/GLD"'


   * Internal project files. Same no matter user
   * ---------------------
	global id2d_dicitonary  `""'
	global gld_dicitonary  	`"${clone}/gld/Support/Guides and Documentation/GLD_Dictionary_2021_04.xlsx"'





* Run settings
* 	Set to 1 to run, 0 otherwise
* ---------------------

loc 	BRA		0
loc 	IND 	0
loc 	MEX 	0
loc 	PHL 	1
loc 	ZAF 	0



* Run
* ---------------------


if (`BRA'==1) {
	do `"${code}/BRA/BRA_MAIN.do"'
}
if (`IND'==1) {
	do `"${code}/IND/IND_MAIN.do"'
}
if (`MEX'==1) {
	do `"${code}/MEX/MEX_MAIN.do"'
}
if (`PHL'==1) {
	do `"${code}/PHL/PHL_MAIN.do"'
}
if (`ZAF'==1) {
	do `"${code}/ZAF/ZAF_MAIN.do"'
}
