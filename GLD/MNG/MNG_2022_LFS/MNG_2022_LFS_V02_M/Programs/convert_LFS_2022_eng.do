clear
set more off
set varabbrev off

local server  "C:/Users/`c(username)'/WBG/GLD - Current Contributors/510859_AS"
local country "MNG"
local year    "2022"
local survey  "LFS"
local vermast "V02"

local level_1      "`country'_`year'_`survey'"
local level_2_mast "`level_1'_`vermast'_M"

local path_in_stata "`server'/`country'/`level_1'/`level_2_mast'/Data/Stata"
local path_in_other "`server'/`country'/`level_1'/`level_2_mast'/Data/Original"

import spss using "`path_in_other'/LFS_2022_eng.sav", clear
save "`path_in_stata'/LFS_2022_eng.dta", replace
