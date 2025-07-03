*-------------------------------------------------------------------------------
* Phase 1: Prepare the files
*-------------------------------------------------------------------------------

* Get date and time
	global csvname = "tranxids_${datestamp}_${timestamp}.csv"
	local csvpath = "${logfolder}/${csvname}"


* I need to first create an empty log file where all the transaction IDs will be later stored (important for uploading and confirming uploads)
	file open tranxlog using "`csvpath'", write replace
	file write tranxlog "surveyid,tranxid_harmonized,tranxid_raw,notes" _n
	file close tranxlog

* The code below only picks up the only xlsx file that starts with gld_dlw_reconcile 
* and loads it. I want it to be clean!
	local prefix "gld_dlw_reconcile"

	local files: dir "${primusfolder}" files "`prefix'*.xlsx"
	local matched_file : word 1 of `files'

	if "`matched_file'" == "" {
		display as error "No matching file found."
		exit 1
	}

	import excel using "${primusfolder}/`matched_file'", sheet("Main") firstrow clear

/*----------------------------------------------------------------------------
Filling in intermediate versions
------------------------------------------------------------------------------
PRIMUS requires all sequential versions to be represented. This becomes complicated when there are versions in-between the latest version and the 
last uploaded version in datalibweb. 

For example: version 1 is available in DLW, and version 3 is already available in GLD. PRIMUS would require version 2 to be uploaded
already in DLW before version 3 is uploaded. 

The solution here is to add rows for all the intermediate versions that are pre-requisites for the upload of the latest version
------------------------------------------------------------------------------*/
* Remove panels
	if "${includepanels}" == "No" {
		drop if strlen(years) > 4 & strlen(years) < 99
		drop if regexm(lower(surveyid), "panel")
	}

* Convert versions to numeric
	gen vera_dlw_num = real(substr(trim(veralt_dlw), 2, .))
	gen vera_gld_num = real(substr(trim(veralt_gld), 2, .))
	gen verm_dlw_num = real(substr(trim(vermast_dlw), 2, .))
	gen verm_gld_num = real(substr(trim(vermast_gld), 2, .))
	replace vera_dlw_num = 0 if (vera_dlw_num > vera_gld_num) & (verm_gld_num > verm_dlw_num)

* There are cases where none has been uploaded in DLW but 2 versions already exist. They are
* tagged as NA in the versions. Need to create two rows for these too. 
	replace vera_dlw_num = 0 if veralt_dlw == "NA"
	replace verm_dlw_num = 0 if veralt_dlw == "NA"

* Save original row in a temp file
	tempfile original
	save `original', replace

* Keep only rows where we need to add intermediate versions
*keep if vera_gld_num > vera_dlw_num
	gen n_new = vera_gld_num - vera_dlw_num
	gen n_new_r = verm_gld_num - verm_dlw_num

* Expand to fill in intermediate versions for raw
	expand n_new_r if n_new_r>1 & !missing(n_new_r)
	gen offset_r = _n
	bysort surveyid (offset_r): replace offset_r = _n
	gen new_vermnum = verm_dlw_num + offset_r 

* Expand to fill in intermediate versions for harmonized
	expand n_new if n_new>1 & !missing(n_new)
	gen offset = _n
	bysort surveyid (offset): replace offset = _n
	gen new_vernum = vera_dlw_num + offset 

* Update veralt_gld and fix veralt_dlw
	replace vermast_gld = "V" + string(new_vermnum, "%02.0f") if n_new_r>1 & !missing(n_new_r)
	replace veralt_gld = "V" + string(new_vernum, "%02.0f") if n_new>1 & !missing(n_new)

* Update surveyid using prefix + new veralt_gld
	gen surveyid_prefix = substr(surveyid, 1, strpos(surveyid, "_V") - 1)
	replace surveyid = surveyid_prefix + "_" + vermast_gld + "_M_" + veralt_gld + "_A_GLD"
	replace surveyid = subinstr(surveyid, "/", "", .)

* Build dynamic folder name based on year
	split surveyid, parse("_")
	gen survey_folder = country + "_" + years + "_" + surveyid3

* Dynamically locate base path
	gen p1 = strpos(harmdir, survey_folder)
	gen base_path = substr(harmdir, 1, p1 - 1) if p1 > 0

* Update harmdir
	replace harmdir = base_path + survey_folder + "/" + surveyid + "/Data/Harmonized"

* Identify original to reclassify gap surveys as "2 - update harm"
	merge 1:1 surveyid using `original'
	ren _merge tag

	sort country years surveyid3 vermast_gld veralt_gld
	by country years surveyid3: gen runner = _n

	gen vera_gld_num2 = real(substr(trim(veralt_gld), 2, .))
	gen verm_gld_num2 = real(substr(trim(vermast_gld), 2, .))

	replace case_type = "2 - update harm" if inrange(vera_gld_num2, 2, 99) & inrange(verm_gld_num2, 1, 99) & inlist(case_type, "3 - update raw & harm", "4 - new upload, several versions")

* I add this variable in case we need to upload two versions requiring one-at-a-time uploads.
* If there are two versions uploaded within a short period of time, then this has to be updated but that will be highly unlikely
	keep if runner == 1

* Clean up
	drop offset new_vernum vera_dlw_num vera_gld_num n_new p1 surveyid_prefix base_path survey_folder surveyid1-surveyid8

* Ensure output folders exist
	capture mkdir "${primusfolder}/XML files"
	capture mkdir "${primusfolder}/ZIP files"

* Loop over each folder
	forvalues i = 1/`=_N' {

		preserve
		* Read variables from Excel
		local hd = harmdir[`i']
		local case = case_type[`i']
		local sid = surveyid[`i']
		local country = country[`i']
		local year = years[`i']
		local veralt = veralt_gld[`i']
		local vermast = vermast_gld[`i']
		local tailharm = "_M_" + "`veralt'" + "_A_GLD"
		local tailraw=  "_" + "`vermast'" + "_M"

		local sid_base = subinstr("`sid'", "`tailharm'", "_M", .)
		local survey_prefix = subinstr("`sid_base'", "`tailraw'", "", .)

		local xmlout = "${primusfolder}/XML files"

		* Construct .dta file path and XML output path
		local dtafile = "`hd'/`sid'_ALL.dta"
		local fname = "`sid'_ALL"
		local xmlfile = "`xmlout'/`fname'.xml"

		* Display progress
		di "Running primus_xml_gld for `dtafile'"

		* Run XML export only if the .dta file exists
		capture confirm file "`dtafile'"
		if _rc == 0 {
			use "`dtafile'", clear
			
			* Check for required variable
			capture confirm variable lstatus
			if _rc {
				di as error "Variable lstatus is not available. Check!"
				file open tranxlog using "`csvpath'", write append
				file write tranxlog "`sid',NA,NA,Labor status is not found. Cannot create XML!" _n
				file close tranxlog
				restore
				continue
			}
			
			primus_xml_gld, ///
				xmlout("`xmlfile'") ///
				country("`country'") ///
				year("`year'") ///
				surveyid("`sid'") ///
				filename(`fname')
		}
		
		else {
			di in red "File not found: `dtafile'"
			file open tranxlog using "`csvpath'", write append
			file write tranxlog "`sid',NA,NA,Dataset is not available! Check if missing or inconsistent name" _n
			file close tranxlog
			restore
			continue
		}


	*******************************
	* For harmonized file
	*******************************
	* Build source folder and destination zip path. Here I need to use backward slashes
	* because shell robocopy will not accept forward slashes
		local folder_to_zip = "${gldfolder}\\`country'\\`survey_prefix'\\`sid'"
		local zip_dest = "${primusfolder}\\ZIP files\\`sid'.zip"

		local clean_folder = "${primusfolder}\\temp\\primus_clean_`sid'"
		shell mkdir "`clean_folder'"

	* Use robocopy to copy only allowed subfolders
		shell robocopy "`folder_to_zip'" "`clean_folder'" /E /XD Work

	* Get the folder size and load that output into a macro
		tempname outfile
		tempfile sizefile

		shell powershell -NoProfile -Command "((Get-ChildItem \"`clean_folder'\" -Recurse | Measure-Object Length -Sum).Sum / 1GB).ToString('N2')" > "`sizefile'"

		file open `outfile' using "`sizefile'", read text
		file read `outfile' line
		file close `outfile'

	* Store and display the result
		local folder_size = trim("`line'")
		display "Folder size: `folder_size' GB"
		
		local folder_size_num = real("`folder_size'")
		
	* 1.4 GB because there is a limit set by PRIMUS (only <1.5 GB), if folder is above this, PRIMUS will not let you upload
	* For harmonized folder, I will not create a zip file nor upload in the system
		if `folder_size_num' < filelimit {
			display "Folder is small enough. Proceeding to zip..."
			shell tar.exe -a -c -f "`zip_dest'" -C "`clean_folder'" Data Doc Programs
		}
		
		if `folder_size_num' > filelimit & !missing(`folder_size_num') {
			display "Folder is larger than 1.4 GB. Skipping zip."
			file open tranxlog using "`csvpath'", write append
			file write tranxlog "`sid',NA,NA,Too large: harmonized folder size is `folder_size_num' GB" _n
			file close tranxlog
			
	* When the data file is greater than 1.4 GB, we need to create a DOC file with the note saying reach out to GLD team
	* This allows us to pick up the data from the datalibweb and prevent it from being prompted to upload
	* Below, I create a doc file in the technical folder so that there is always a valid file in the folder
	* and explanation for the missing data in DLW
		file open notefile using "`clean_folder'/Doc/Technical/Where_to_find_the_data.doc", write replace
		file write notefile "The full data cannot be uploaded to Datalibweb because it is too big. To access the data, write an email with the subject name = 'GLD large data request' to the GLD team: gld@worldbank.org, copying Mario Gronert (mgronert@worldbank.org)"
		file close notefile
		
		shell tar.exe -a -c -f "`zip_dest'" -C "`clean_folder'"  Doc Programs

		}

	* We need a separate process for cases 1, 3 and 4 because these involve uploading/updating raw folder
	if "`case'" == "1 - new upload" | "`case'" == "3 - update raw & harm" | "`case'" == "4 - new upload, several versions"  {
	    
	*******************************
	* For raw file
	*******************************
	* Build source folder and destination zip path
		local folder_to_zip_r = "${gldfolder}\\`country'\\`survey_prefix'\\`sid_base'"
		local zip_dest_r = "${primusfolder}\\ZIP files\\`sid_base'.zip"
	
	* Below, I want to get the size of the raw folder bec of file size limits imposed by PRIMUS
		tempname outfile
		tempfile sizefile

		shell powershell -NoProfile -Command "((Get-ChildItem '`folder_to_zip_r'' -Recurse | Measure-Object Length -Sum).Sum / 1GB).ToString('N2')" > "`sizefile'"

	* Load that output into a macro
		file open `outfile' using "`sizefile'", read text
		file read `outfile' line
		file close `outfile'

	* Store and display the result
		local folder_size = trim("`line'")
		display "Raw Folder size: `folder_size' GB"
		
		local folder_size_num_r = real("`folder_size'")
		display `folder_size_num_r'
		
	* There is a limit set by PRIMUS (only <1.5 GB), if folder is above this, PRIMUS will not let you upload.
	* Filelimit here is a scalar set in the parent do file. Adjust there as needed
	* I will not include data sub-folder in the zip file bc presumably this is the file big in size
		
		if `folder_size_num_r' < filelimit {
			display "Raw folder is small enough. Proceeding to zip..."
			shell tar.exe -a -c -f "`zip_dest_r'" -C "`folder_to_zip_r'" Data Doc Programs
		}
	
		
		else {
		    tempname clean
			local clean_rawfolder = "${primusfolder}/temp/primus_clean_`sid_base'"

			shell mkdir "`clean_rawfolder'"

		* Use robocopy to copy only allowed subfolders
			shell robocopy "`folder_to_zip_r'" "`clean_rawfolder'" /E /XD Data

		* Create a basic .doc file with message
			file open notefile using "`clean_rawfolder'/Doc/Technical/Note.doc", write replace
			file write notefile "Data file not uploaded because it is too big"
			file close notefile
			
			shell tar.exe -a -c -f "`zip_dest_r'" -C "`clean_rawfolder'"  Doc Programs

			display "Excluded data folder."
		}


	}


	*-------------------------------------------------------------------------------
	* Phase 2: Upload the files
	*-------------------------------------------------------------------------------
	* Upload harmonized folder

	* Start with XML file. Processid = 14 is for harmonized as assigned by PRIMUS team.
		capture noisily primus upload, processid(14) surveyid(`sid') type(harmonized) xmlbl infile(`xmlfile') new

		* Get transaction ID
		local tranxid_harm `r(prmTransId)'
		
		if _rc {
			* Default generic message
			local errmsg "There is an error in uploading to PRIMUS. Possibly transaction already exists!"

			file open tranxlog using "`csvpath'", write append
			file write tranxlog "`sid',`tranxid_harm',NA,`errmsg'" _n
			file close tranxlog
			restore
			continue
		}
		
		

	* Upload all other files in the same tranxid. 
		capture noisily primus upload, processid(14) surveyid(`sid') type(harmonized) infile(`zip_dest') zip tranxid(`tranxid_harm')
		
		if _rc {
			local errmsg "There is an error in uploading to PRIMUS. Possibly harmonized transaction already exists!"

			file open tranxlog using "`csvpath'", write append
			file write tranxlog "`sid',`tranxid_harm',NA,`errmsg'" _n
			file close tranxlog
			restore
			continue
		}

	* Upload raw folder
		if "`case'" == "1 - new upload" | "`case'" == "3 - update raw & harm"  | "`case'" == "4 - new upload, several versions" {
			
	* Processid= 15 is for GLD RAW as defined by the PRIMUS team
		capture noisily primus upload, processid(15) surveyid(`sid_base') type(raw) infile(`zip_dest_r') zip new
		
		if _rc {
			local errmsg "There is an error in uploading to PRIMUS. Possibly raw transaction already exists!"
			file open tranxlog using "`csvpath'", write append
			file write tranxlog "`sid',NA,NA,`errmsg'" _n
			file close tranxlog
			restore
			continue
		}

		* Get transaction ID
			local tranxid_raw `r(prmTransId)'

		}

	* Below, I create a log for cases where raw upload was not possible: (a) case 2; (b) too large folder
		if "`case'" == "2 - update harm" {
			local folder_size_num_r = 0
		}

		if `folder_size_num_r' < filelimit & "`case'" != "2 - update harm"{
			file open tranxlog using "`csvpath'", write append 
			file write tranxlog "`sid',`tranxid_harm',`tranxid_raw', Upload successful for raw and harmonized" _n
			file close tranxlog
		}

		if `folder_size_num_r' < filelimit & "`case'" == "2 - update harm"{
			file open tranxlog using "`csvpath'", write append
			file write tranxlog "`sid',`tranxid_harm',NA, Upload successful but no raw upload bec case 2" _n
			file close tranxlog
		}

		if `folder_size_num_r' > filelimit {
			file open tranxlog using "`csvpath'", write append
			file write tranxlog "`sid',`tranxid_harm',`tranxid_raw', raw data not uploaded bec too big: `folder_size_num_r' GB" _n
			file close tranxlog  
		}

	* Log when file is too big
		if `folder_size_num' > filelimit {
			file open tranxlog using "`csvpath'", write append
			file write tranxlog "`sid',`tranxid_harm',`tranxid_raw', harmonized data not uploaded bec too big: `folder_size_num' GB" _n
			file close tranxlog  
		}

	* Clean up
		shell del /Q "`clean_folder'"
		shell del /Q "${primusfolder}/ZIP files/*"


restore

}




