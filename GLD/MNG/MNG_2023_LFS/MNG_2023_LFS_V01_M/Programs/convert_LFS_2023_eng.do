* Define path sections
local server  "C:/Users/`c(username)'/WBG/GLD - Current Contributors/510859_AS"
local country  "MNG"
local year  "2023"
local survey  "LFS"
local vermast  "V01"
local veralt  "V01"

* From the definitions, set path chunks
local level_1      "MNG_2023_LFS"
local level_2_mast "MNG_2023_LFS_V01_M"

* From chunks, define path_in, path_output folder
local path_in_stata "`server'/`country'/`level_1'/`level_2_mast'/Data/Stata"
local path_in_other "`server'/`country'/`level_1'/`level_2_mast'/Data/Original"

import spss using "`path_in_other'/LFS_2023_eng.sav", clear
save "`path_in_stata'/LFS_2023_eng.dta", replace
