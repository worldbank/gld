* Read in txt files using the dicitonarie sof first visits (revisits only in urban places)

* Set working directory
cd "C:\Users\wb529026\OneDrive - WBG\Documents\Country Work\IND\IND_2018_PLFS\IND_2018_PLFS_v01_M\Data\Original"
clear

* Read in HH level info
infix using hh104_fv_final

* Save HH level info
save "C:\Users\wb529026\OneDrive - WBG\Documents\Country Work\IND\IND_2018_PLFS\IND_2018_PLFS_v01_M\Data\Stata\IND_2018_PLFS_raw_HH_Stata.dta", replace

* Read in IND level info
clear
infix using per104_fv_final

* Save IND level info
save "C:\Users\wb529026\OneDrive - WBG\Documents\Country Work\IND\IND_2018_PLFS\IND_2018_PLFS_v01_M\Data\Stata\IND_2018_PLFS_raw_IND_Stata.dta", replace

* Read in IND level info - Revisit
clear
infix using per104_rv_final

* Save IND level info
save "C:\Users\wb529026\OneDrive - WBG\Documents\Country Work\IND\IND_2018_PLFS\IND_2018_PLFS_v01_M\Data\Stata\IND_2018_PLFS_raw_IND_RV_Stata.dta", replace