/*==============================================================================
* A1: List all the harmonized datasets
*==============================================================================*/


filelist, dir("${path_work}") pat("*.dta")

/*
* Create an empty master dataset
clear
qui gen str filepath = ""
tempfile master
qui save "`master'"

* Capture only harmonized file (for efficiency). Takes too long if all folders are opened!
local versions_mas "V01 V02"
local versions_alt "V01 V02 V03 V04 V05 V06 V07 V08 V09 V10" // add more versions as needed or generate 

foreach year of global years {
    foreach ver1 in `versions_mas' {
        foreach ver2 in `versions_alt' {
            local dir_full "${server}\\${country}\\Updated\\${country}_`year'_${survey_i}\\${country}_`year'_${survey_i}_`ver1'_M_`ver2'_A_GLD\Data\Harmonized"

            capture quietly dir "`dir_full'"
            if _rc == 0 {
				display "`dir_full' is stored"
                filelist, dir("`dir_full'") pat("*.dta")             
                append using "`master'"			
				save "`master'", replace
            }
        }
    }
}

* Load the final master filelist
use "`master'", clear



*/