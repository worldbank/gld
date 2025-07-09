* TASK 2: Approve the data

* == > User input required <== *
* Define the location of the folders where either data or helper do files are being read from, or where outputs will be stored.
* Please use backward slash because forward slashes creates issue with Windows commands
global primusfolder "C:\Users\\`c(username)'\WBG\GLD - Current Contributors\510859_AS\PRIMUS"
global gldfolder "C:\Users\\`c(username)'\WBG\GLD - GLD"
global logfolder "C:\Users\\`c(username)'\WBG\GLD - Current Contributors\510859_AS\PRIMUS\log files"
* == > End user input  <== * (from here is all should work automatically if all paths correct)

global datestamp = subinstr("`=c(current_date)'", " ", "_", .)  
global timestamp = subinstr("`=c(current_time)'", ":", "-", .)  

* Create a log file
log using "${logfolder}/task2_${datestamp}_${timestamp}.log"

* Load the Excel file
import delimited using "${logfolder}/latest.csv", varnames(1) clear

gen status = ""
capture confirm string variable tranxid_harmonized
if !_rc {
    drop if tranxid_harmonized == "NA" | missing(tranxid_harmonized)
}

* Bec there is a glitch in PRIMUS (error 502), which happens
* when iterating multiple approvals,  we want the code to ignore this and keep iterating
* through the loop until error 502 clears up (bec it eventually does!)
* THis means that the loop will go back to those with prior error 502 and try if it clears up

while _N > 0 {
* Loop over all rows
forvalues i = 1/`=_N' {
    *local case = case_type[`i']
    local surveyid = surveyid[`i']
    local tranx_h = tranxid_harmonized[`i']
    local tranx_r = tranxid_raw[`i']

    * Harmonized action (process 14)
    capture noisily primus action, tranxid(`tranx_h') decision(APPROVE) proc(14) comments("Approved")
	if _rc {
		display "${errcodep}"
		replace status = "${errcodep}"
		continue
	}
	
	else{
		replace status = "complete" in `i'
	}
	
    * Raw action (process 15)
    if "`tranx_r'" != "NA" | missing("`tranx_r'") {
		capture noisily primus action, tranxid(`tranx_r') decision(APPROVE) proc(15) comments("Approved")
		if _rc {
		continue
	}
    }	
}

* we dont want error 856 -- because this include the surveys that have already been uploaded
drop if status == "856" | status == "complete"
}

* Loop over all rows
forvalues i = 1/`=_N' {
    *local case = case_type[`i']
    local surveyid = surveyid[`i']
    local tranx_h = tranxid_harmonized[`i']
    local tranx_r = tranxid_raw[`i']

    * Harmonized action (process 14)
    capture noisily primus action, tranxid(`tranx_h') decision(APPROVE) proc(14) comments("Approved")
	if _rc {
		display "${errcodep}"
		replace status = "${errcodep}"
		continue
	}
	
	else{
		replace status = "complete" in `i'
	}
	
    * Raw action (process 15)
    if "`tranx_r'" != "NA" | missing("`tranx_r'") {
		capture noisily primus action, tranxid(`tranx_r') decision(APPROVE) proc(15) comments("Approved")
		if _rc {
		continue
	}
    }	
}


* Delete latest because we dont want the next run to pick this up!
erase "${logfolder}/latest.csv"

log close

