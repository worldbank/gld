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
   * Tom (WB local)             			      	  1    //
   * other users			           				  2    //

   *Set this value to the user currently using this file
   global user  1



   * Root folder globals
   * ---------------------

    if $user == 1 {
        global data		""					// data folder
		global GLD 		"Y"					// set this to the letter the GLD drive is on your computer
        global clone	"C:/Users/WB551206/local/GitHub" // github/code top folder
    }


	if $user == 2 {
	global data		"" 			// replace with folder above data repo
	global GLD 		""			// set this to the letter the GLD drive is on your computer
	global clone	"" // replace with folder above github folder
    }





   * Internal project folder paths. Same no matter user
   * ---------------------

	global  PHL 	`"${clone}/gld/GLD-Harmonization/TM/PHL/I2D2"'





* Run settings
* 	Set to 1 to run, 0 otherwise
* ---------------------

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
loc 	phl2010		1
loc 	phl2011 	0
loc 	phl2012		0
loc 	phl2013		0
loc 	phl2014		0
loc 	phl2015 	0
loc 	phl2016  	0
loc 	phl2017 	0
loc 	phl2018		0
loc 	phl2019 	0
loc 	phl2020 	0

* Run
* ---------------------

forvalues year = 1997/2020 {
    if (`phl`year''==1) {
		do `"${PHL}/PHL_`year'_I2D2_LFS.do"'
	}
}
