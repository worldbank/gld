
* DO ALL THE DATASETS
global alldofiles "C:\Users\wb510859\OneDrive - WBG\GLD-Harmonization\510859_AS\THA\ALL_DO_FILES"

do "$alldofiles\THA_2014_LFS_v01_M_v01_A_Q1.do"
do "$alldofiles\THA_2014_LFS_v01_M_v01_A_Q2.do"
do "$alldofiles\THA_2014_LFS_v01_M_v01_A_Q3.do"
do "$alldofiles\THA_2014_LFS_v01_M_v01_A_Q4.do"


* APPEND THE DATASETS
global path_output "C:\Users\wb510859\OneDrive - WBG\GLD-Harmonization\510859_AS\THA\THA_2014_LFS\THA_2014_LFS_v01_M_v01_A_GLD\Data\Harmonized"


use "$path_output\THA_2014_LFS_V01_M_V01_A_GLD_Q1.dta", clear
append using "$path_output\THA_2014_LFS_V01_M_V01_A_GLD_Q2.dta"
append using "$path_output\THA_2014_LFS_V01_M_V01_A_GLD_Q3.dta"
append using "$path_output\THA_2014_LFS_V01_M_V01_A_GLD_Q4.dta"

save "$path_output\THA_2014_LFS_V01_M_V01_A_GLD_ALL.dta", replace

* RUN THE QUALITY CHECKS
do "C:\Users\wb510859\OneDrive - WBG\GLD-Harmonization\510859_AS\THA\THA_2014_LFS\THA_2014_LFS_v01_M_v01_A_GLD\Programs\Q checks\Template - Run all Q-Checks.do"