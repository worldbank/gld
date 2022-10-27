/*******************************************************************************
								
                            GLD CHECKS Version 1.4
                          00. Prepare to run checks  	  
		   	   																   
*******************************************************************************/	


*-- 01. Install necessary modules to run the checks 
	local modules winsor2 wbopendata dbnomics insheetjson libjson moss distinct
	foreach m in `modules' {
		cap which `m'
		if _rc {
			ssc install `m'
		} 
	}

*-- 02. Extract relevant info from GLD data 
	use "$mydata", clear
	keep countrycode year survey
	duplicates drop
	
	levelsof countrycode, local(ccode3) clean
	global ccode3 `ccode3'
	
	levelsof year, local(cyear) clean
	global cyear `cyear'
	
	levelsof survey, local(csurvey) clean
	global csurvey `csurvey'
	
	
*-- 03. Generate folders
	clear
	set obs 1
	gen date   = "${S_DATE}"
	split date, p(" ")
	gen year   = substr(date3,3,2)
	gen mydate = date1 + date2 + year
	levelsof mydate, clean
	global mydate `r(levels)'
	clear 

	if `"`c(os)'"' == "MacOSX" {                                 // for mac
		shell rm -r "$output/${ccode3}_${cyear}_${mydate}"  
	}
	if `"`c(os)'"' == "Windows" {                               // for windows
		shell rmdir "$output\\${ccode3}_${cyear}_${mydate}" /s /q  
	}
	
	* Before making the folders, need to check whether they exist
	* try to change the working directory to it, if folder inexistant, fails
	cap cd "${output}/${ccode3}_${cyear}_${mydate}"
	if _rc != 0 {
		
		mkdir "${output}/${ccode3}_${cyear}_${mydate}"   	             
		mkdir "${output}/${ccode3}_${cyear}_${mydate}/01_summary"     
		
	}
	
	
*-- 04. Match to 2-digit ccode 
	import delimited "${helper}/ccodes.csv", varnames(1) encoding(UTF-8) clear
	keep if cc3 == "$ccode3"
	levelsof cc2, local(ccode2) clean
	global ccode2 `ccode2'


************************   New features in version 1.4  ************************	
 
 *- 1. File B2.09: Create summary image only if there are any flags
 *- 2. File B2.01: Drop urban before creating summary, compare if remainder fits external
 *- 3. File B3.01: Check lstatus if > minlaborage, labour ones if lstatus == 1, urban
 *- 4. File B4.01: Expand checks to include ISCO-08 / ISIC 3 & 3.1
 *- 5. File B4.01: Adapt lstatus <-> empstat check to be more informative
 *- 6. File A1.01: Ensure UTF-8 enconding when reading ccodes.csv 
 *- 7. -- ALL -- : Restructure file names to blocks, numbers within blocks

************************   New features in version 1.3  ************************	
	
 *- 1. Do-file 06,	13. Industry, 02. ILO   added "if" block for robustness
 *- 2. Do-file 06,	13. Industry, 03. ILO   added "if" block for robustness
 *- 3. Do-file 06,	14. Sevices, [multiple] added "if" block for robustness
 *- 4. Do-file 06,	15. *ndustry category   added "if" block for robustness
 *- 5. Do-file 06,	Change ccode from string "IND" to global "$ccode3" 
	
************************   New features in version 1.2  ************************

 *-  1. Template. Deleted manual installation of necessary modules 
 *-  2. Do-file 00, line 9. Automatically install necessary modules 
 *-  3. Do-file 04, line 1069. Order output & summary block 
 *-  4. Do-file 05, line 16. set sslrelax on if dbnomics does not work  
 *-  5. Do-file 05, line 43. Corrected ${series2}, global added
 *-  6. Do-file 05, (multiple). Robust in case of missing download 
 *-  7. Do-file 06, line 1091. Services external check w/ "services" & "other"
 *-  8. Do-file 06, (multiple). Robust in case of missing download
 *-  9. Do-file 07, (multiple). Robust in case of missing download
 *- 10. Do-file 09, line 194. Added ccode 3 to figure title 
 *- 11. Do-file 10, line 192. Added ccode 3 to figure title
 *- 12. Do-file 11, line 50. Added ccode 3 to figure title
 *- 13. Do-file 15, lines 252, 386, 468, 653. Treat missing as 0.0 
 *- 14. Do-file 15, line 509. Flag occupations where industry is 0.0
 *- 15. Do-file 15, line 252. Varlist changed to employed-total 
 
**************************   END OF THE DO-FILE  *******************************		
	
	
	
