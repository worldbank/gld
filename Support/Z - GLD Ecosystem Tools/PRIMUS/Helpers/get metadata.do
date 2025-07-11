/*
Part 1: Reconciling GLD and Datalibweb surveys

This Stata script performs a reconciliation check between surveys uploaded to the Global Labor Database (GLD) and those stored in Datalibweb. It first extracts and processes metadata from folder structures in the GLD directory to identify available surveys. It then retrieves the corresponding metadata from Datalibweb. By merging both sources, the script identifies inconsistencies, missing surveys, and version mismatches. Based on this comparison, the script classifies each case into specific upload scenarios, which determine the appropriate upload procedure to PRIMUS (e.g., new upload, version update, or raw/harmonized mismatch). Finally, it generates an Excel report that includes (1) a guide sheet explaining each variable and (2) two data sheets: one summarizing cases requiring action and another flagging anomalies. This file serves as a decision-support tool for managing uploads into the PRIMUS system.
*/

*===========================================================================
* Extracting survey names and constructing identifiers from the GLD folder
*===========================================================================

* Clear any previous Excel output to avoid confusion
	shell del "${primusfolder}/gld_dlw_reconcile*.xlsx"

	clear
    set obs 1  
    gen fullid = ""  
	gen surveyid = ""
    
	local first_level_folders: dir "${gldfolder}" dirs "*"
        
	foreach first in `first_level_folders' {
		local second_level_folders: dir "${gldfolder}/`first'" dirs "*"
		
		foreach second in `second_level_folders' {
			local third_level_folders: dir "${gldfolder}/`first'/`second'" dirs "*"

			foreach third in `third_level_folders' {
				set obs `=_N + 1'
				replace fullid = upper("${gldfolder}/`first'/`second'/`third'") in `=_N'
				replace surveyid = upper("`third'") in `=_N'
			}
		}
	}
		
	drop if missing(fullid)
        
	split surveyid, parse("_")
	ren surveyid1 country
	ren surveyid2 years
	ren surveyid3 survname
	ren surveyid4 vermast
	ren surveyid6 veralt
		
	gen col = surveyid8
	replace col = surveyid5 if missing(col)
		
	drop if col == "M"

	bys country years survname col (vermast veralt): gen order = _n
    bys country years survname col: egen order_max = max(order)
	keep if order == order_max
          
	drop fullid surveyid5 surveyid7 surveyid8 order order_max
        
    duplicates drop country years survname, force
        
    tempfile gld_meta
    save `gld_meta'
        
*===========================================================================
* Extracting survey names and constructing identifiers from Datalibweb
*===========================================================================

	capture quietly datalibweb, type(gld) repo(create filename)

	capture confirm variable module
	if _rc {
		di as error "Check for token validity"
		exit 1
	}

	capture quietly datalibweb, type(gld) repo(erase filename, force)
        
	replace survname = upper(survname)
	keep surveyid country years survname vermast veralt
        
	merge 1:1 country years survname vermast veralt using `gld_meta'
       
	keep if _merge != 3
		
	count
	if r(N) == 0 {
		display as text "The datalibweb is up to date with GLD"
		exit 0
	}
				
	sort country years survname vermast veralt
	duplicates tag country years survname, gen(dup1)
	duplicates tag country years survname vermast veralt, gen(dup2)
        
	gen version_update = dup1 == 1 & dup2 == 0
	gen add_new = dup1 == 0 & dup2 == 0
		
	gen errorflag = dup1 == 0 & dup2 == 0 & _merge == 1
	replace add_new = . if errorflag == 1
        
	gen source = "GLD" if _merge == 2
	replace source = "Datalibweb" if _merge == 1
		
	replace col = "Datalibweb" if missing(col)
	replace add_new = . if add_new == 0

	preserve
	keep if errorflag ==1 
	keep country years survname vermast veralt 
	gen comment = "File not in GLD but in datalibweb. Odd!"
		
	tempfile error
	save `error', replace
	
	restore

* Case 2 and 3 (version update cases) 
	preserve
	
	qui keep if version_update == 1 
	qui drop col _merge
	bys country years survname (source): gen runner = _n
	quietly: reshape wide vermast veralt source surveyid, i(country years survname) j(runner)
		
	rename surveyid2 surveyid
	rename veralt2 veralt_gld
	rename veralt1 veralt_dlw
	rename vermast2 vermast_gld		
	rename vermast1 vermast_dlw
		
	gen case_type = "2 - update harm" if (vermast_dlw == vermast_gld) & (veralt_dlw != veralt_gld)
	replace case_type = "3 - update raw & harm" if (vermast_dlw != vermast_gld) 
		
	gen rawdir = "${gldfolder}" + "/" + country + "/" + country + "_" + years + "_" + survname + "/" + country + "_" + years + "_" + survname + "_" + vermast_gld + "_M/Data/Stata"	
	gen harmdir = "${gldfolder}" + "/" + country + "/" + country + "_" + years + "_" + survname + "/" + country + "_" + years + "_" + survname + "_" + vermast_gld + "_M_" + veralt_gld + "_A_GLD/Data/Harmonized"
	
	tempfile case23
	save `case23'
	
	restore

* Case 1 - new uploads
	qui keep if add_new == 1

	gen vermast_dlw = "NA"
	gen veralt_dlw = "NA"
	rename vermast vermast_gld
	rename veralt veralt_gld
		
	gen case_type = "1 - new upload"
	gen digit_alt = substr(veralt_gld, -2, 2)
	gen digit_mast = substr(vermast_gld, -2, 2)

	destring digit_alt, replace
	destring digit_mast, replace
	
	replace case_type = "4 - new upload, several versions" if ((digit_alt>1 | digit_mast>1) & veralt_dlw == "NA")
	drop digit_alt digit_mast
	
	gen rawdir = "${gldfolder}" + "/" + country + "/" + country + "_" + years + "_" + survname + "/" + country + "_" + years + "_" + survname + "_" + vermast_gld + "_M/Data/Stata"
	gen harmdir = "${gldfolder}" + "/" + country + "/" + country + "_" + years + "_" + survname + "/" + country + "_" + years + "_" + survname + "_" + vermast_gld + "_M_" + veralt_gld + "_A_GLD/Data/Harmonized"

	append using `case23'
	save `case23', replace

* Guide Sheet
	preserve
	
	clear
		input str20 varname str100 definition
		"case_type"  "Type of case that informs the action steps for PRIMUS upload"
		"country"    "3-digit ISO country name"
		"years"      "Year of survey"
		"surveyid"   "Survey ID referenced in the xml creation code"
		"vermast_dlw"   "Version of the master file uploaded in datalibweb"
		"veralt_dlw"    "Version of the harmonized file uploaded in datalibweb"
		"vermast_gld"   "Version of the master file uploaded in GLD"
		"veralt_gld"    "Version of the harmonized file uploaded in GLD"
		"rawdir"     "Folder containing the raw data files. This will be used in PRIMUS upload"
		"harmdir"    "Folder containing the harmonized data files. This will be used in xml creation and PRIMUS upload"
		end

	local date = c(current_date)
	local time = c(current_time)
	local formatted_date = subinstr("`date'", " ", "_", .) 
	local filename "gld_dlw_reconcile_`formatted_date'.xlsx"

	export excel using "${primusfolder}/`filename'", replace firstrow(variables) sheet("Guide")
		
	restore

* Main Sheet
	keep case_type country years surveyid vermast_dlw veralt_dlw vermast_gld veralt_gld rawdir harmdir 
	order case_type country years surveyid vermast_dlw veralt_dlw vermast_gld veralt_gld rawdir harmdir 	
	
	export excel using "${primusfolder}/`filename'",  firstrow(variables) sheet("Main", modify)

* Flags Sheet
	use `error', clear
	export excel using "${primusfolder}/`filename'",  firstrow(variables) sheet("Flags", modify)
	
	display "Excel file created: ${primusfolder}/`filename'"
