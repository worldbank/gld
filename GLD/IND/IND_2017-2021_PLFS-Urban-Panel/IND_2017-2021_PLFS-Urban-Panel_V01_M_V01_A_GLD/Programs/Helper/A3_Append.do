/*==============================================================================
* A3: Append the data
*==============================================================================*/
* Create variable for full name
gen fullname = dirname + "\" + filename

levelsof fullname if _n == 1, local(firstfile)
levelsof fullname if _n != 1, local(otherfiles)

use `firstfile', clear
tempfile panelfile

foreach file of local otherfiles{
    append using "`file'", force
	save `panelfile', replace
	
}

use `panelfile', clear

save "${path_output}/paneldata_${country}.dta", replace