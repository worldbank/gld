/* ------- -------- ------ ------- --------- ------ ------ ------ ---- --- --- --- --- -- -- --- -- -- --
name: PHL_I2D2_MAIN.do
description: calls all PHL scripts for I2D2, edited from iecodebook script

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
   local user_commands ietoolkit scores // labutil      //Fill this list will all user-written commands this project requires
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
   * Tom (WB local)             			      	  1    //
   * other users			           				  2    //

   *Set this value to the user currently using this file
   global user  1



   * Root folder globals
   * ---------------------

    if $user == 1 {
        global data		""					// data folder
        global clone		    "C:/Users/WB551206/local/GitHub" // github/code top folder
    }


	if $user == 2 {
	global data		"" 			// replace with folder above data repo
	global clone		    "" // replace with folder above github folder
    }





   * Internal project folder paths. Same no matter user
   * ---------------------

/Volumes/OWLS/gld-pre/gld/GLD-Harmonization/TM/PHL/I2D2

	global  PHL 	`"${clone}/gld/GLD-Harmonization/TM/PHL"'





* Run settings
* 	Set to 1 to run, 0 otherwise
* ---------------------

loc 	phl97	1
loc 	phl98 	1
loc 	phl99 	1
loc 	phl00 	1
loc 	phl01 	1
loc 	phl02	1
loc 	phl03	0
loc 	phl04	1


* Run
* ---------------------

if (`phl97'==1) {
	do `"${PHL}/PHL_1997_I2D2_LFS.do"'
}
if (`phl98'==1) {
	do `"${PHL}/PHL_1998_I2D2_LFS.do"'
}
if (`phl99'==1) {
	do `"${PHL}/PHL_1999_I2D2_LFS.do"'
}
if (`phl00'==1) {
	do `"${PHL}/PHL_2000_I2D2_LFS.do"'
}
if (`phl01'==1) {
	do `"${PHL}/PHL_2001_I2D2_LFS.do"'
}
if (`phl02'==1) {
	do `"${PHL}/PHL_2002_I2D2_LFS.do"'
}
if (`phl03'==1) {
	do `"${PHL}/PHL_2003_I2D2_LFS.do"'
}
if (`phl04'==1) {
	do `"${PHL}/PHL_2004_I2D2_LFS.do"'
}
