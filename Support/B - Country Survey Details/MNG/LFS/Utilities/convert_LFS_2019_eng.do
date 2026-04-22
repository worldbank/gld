clear
set more off
set varabbrev off

if "`c(username)'" == "wb510859" {
	local server "C:/Users/`c(username)'/OneDrive - WBG/GLD - Current Contributors/510859_AS"
}
else {
	local server "C:/Users/`c(username)'/WBG/GLD - Current Contributors/510859_AS"
}
local country "MNG"
local year    "2019"
local survey  "LFS"
local vermast "V02"

local level_1      "`country'_`year'_`survey'"
local level_2_mast "`level_1'_`vermast'_M"

local path_in_stata "`server'/`country'/`level_1'/`level_2_mast'/Data/Stata"
local path_in_other "`server'/`country'/`level_1'/`level_2_mast'/Data/Original"

import spss using "`path_in_other'/LFS_2019_eng.sav", clear
rename *, upper

/*
The NADA 2019 V02 SPSS file does not retain LOCATION, although the DDI and the
earlier V01 raw file include it. The V01 and V02 files match one-to-one on
PSU SSU QUARTER P2 for all 44,240 records, with checked core person variables
unchanged. We therefore recover LOCATION from the matched V01 raw file here so
the harmonization do-file can code urban/rural status without extrapolating
from province.
*/
tempfile v02_source location_v01
save `v02_source'

* Start with V01 raw data
use "`server'/`country'/`level_1'/MNG_2019_LFS_V01_M/Data/Stata/3.-LFSdata_2019_eng.dta", clear
rename *, upper
isid PSU SSU QUARTER P2
keep PSU SSU QUARTER P2 LOCATION
rename LOCATION LOCATION_V01
save `location_v01'

use `v02_source', clear
isid PSU SSU QUARTER P2
merge 1:1 PSU SSU QUARTER P2 using `location_v01'
assert _merge == 3
drop _merge

capture confirm variable LOCATION
if _rc {
	rename LOCATION_V01 LOCATION
}
else {
	count if LOCATION != LOCATION_V01 & !missing(LOCATION, LOCATION_V01)
	assert r(N) == 0
	drop LOCATION_V01
}

label define lbl_location2019 1 "Capital city" 2 "Aimag center" 3 "Village" 4 "Soum center" 5 "Rural", replace
label values LOCATION lbl_location2019
label var LOCATION "Location (recovered from matched 2019 V01 raw file)"

save "`path_in_stata'/LFS_2019_eng.dta", replace
