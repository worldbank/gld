* Read in txt files using the dicitonarie sof first visits (revisits only in urban places)

local cd_folder "Y:\GLD\IND\IND_2019_PLFS\IND_2019_PLFS_v01_M\Data\Original"
local out_folder "Y:\GLD\IND\IND_2019_PLFS\IND_2019_PLFS_v01_M\Data\Stata"

* Set working directory
cd "`cd_folder'"
clear

* Read in HH level info
infix using hhv1

* Save HH level info
save "`out_folder'\IND_2019_PLFS_raw_HH_Stata.dta", replace

* Read in IND level info
clear
infix using perv1

* Save IND level info
save "`out_folder'\IND_2019_PLFS_raw_IND_Stata.dta", replace
