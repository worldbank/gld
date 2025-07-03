* Load the Excel file
import delimited using "${logfolder}/${csvname}", varnames(1) clear

capture confirm string variable tranxid_harmonized
if !_rc {
    drop if tranxid_harmonized == "NA" | missing(tranxid_harmonized)

}

* Loop over all rows
forvalues i = 1/`=_N' {
    *local case = case_type[`i']
    local surveyid = surveyid[`i']
    local tranx_h = tranxid_harmonized[`i']
    local tranx_r = tranxid_raw[`i']

    * Harmonized action (process 14)
    primus action, tranxid(`tranx_h') decision(confirm) proc(14) comments("First base covered")

    * Raw action (process 15)
    if "`tranx_r'" != "NA" | missing("`tranx_r'") {
		primus action, tranxid(`tranx_r') decision(confirm) proc(15) comments("First base covered")
    }	
}

* We want to create another CSV file so the next day, we can find this for approval!
export delimited using "${logfolder}/latest.csv", replace


