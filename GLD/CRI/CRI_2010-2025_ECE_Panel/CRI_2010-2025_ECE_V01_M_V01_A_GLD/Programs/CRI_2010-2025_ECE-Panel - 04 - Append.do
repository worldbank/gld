/*==============================================================================
* 04: Append the data
*==============================================================================*/
* Create variable for full name
gen fullname = dirname + "\" + filename

* Process filelist rows directly so Windows paths with spaces remain intact.
qui count
local nfiles = r(N)
assert `nfiles' >= 1

local firstfile = fullname[1]
use `"`firstfile'"', clear
tempfile panelfile
save `panelfile', replace

if `nfiles' > 1 {
    forvalues i = 2/`nfiles' {
        local file = fullname[`i']
        append using `"`file'"', force
        display `"`file'"'
        save `panelfile', replace
    }
}

use `panelfile', clear

* The appended dataset remains in memory for the next auxiliary step.
* No persistent .dta file is saved here.
