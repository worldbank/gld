* Read in txt files using the dicitonarie sof first visits (revisits only in urban places)

* Set working directory
cd "C:\Users\wb529026\OneDrive - WBG\Documents\Country Work\IND\IND_2017_PLFS\IND_2017_PLFS_v01_M\Data\Original"
clear

* Read in HH level info
infix using FHH_FV

* Save HH level info
save "C:\Users\wb529026\OneDrive - WBG\Documents\Country Work\IND\IND_2017_PLFS\IND_2017_PLFS_v01_M\Data\Stata\IND_2017_PLFS_raw_HH_Stata.dta", replace

* Read in IND level info - First Visit
clear
infix using FPER_FV

* Save IND level info
save "C:\Users\wb529026\OneDrive - WBG\Documents\Country Work\IND\IND_2017_PLFS\IND_2017_PLFS_v01_M\Data\Stata\IND_2017_PLFS_raw_IND_Stata.dta", replace

* Read in IND level info - Revisit
clear
infix using FPER_RV

* Save IND level info
save "C:\Users\wb529026\OneDrive - WBG\Documents\Country Work\IND\IND_2017_PLFS\IND_2017_PLFS_v01_M\Data\Stata\IND_2017_PLFS_raw_IND_RV_Stata.dta", replace

