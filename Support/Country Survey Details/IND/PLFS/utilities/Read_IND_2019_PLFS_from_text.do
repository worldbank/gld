* Read in txt files using the dicitonarie sof first visits (revisits only in urban places)

* Set working directory
cd "C:\Users\wb529026\OneDrive - WBG\Documents\Country Work\IND\IND_2019_PLFS\IND_2019_PLFS_v01_M\Data\Original"
clear

* Read in HH level info
infix using hhv1

* Save HH level info
save "C:\Users\wb529026\OneDrive - WBG\Documents\Country Work\IND\IND_2019_PLFS\IND_2019_PLFS_v01_M\Data\Stata\IND_2019_PLFS_raw_HH_Stata.dta", replace

* Read in IND level info
clear
infix using perv1

* Save IND level info
save "C:\Users\wb529026\OneDrive - WBG\Documents\Country Work\IND\IND_2019_PLFS\IND_2019_PLFS_v01_M\Data\Stata\IND_2019_PLFS_raw_IND_Stata.dta", replace
