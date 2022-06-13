

* APPEND THE DATASETS
global path_output "C:\Users\wb510859\OneDrive - WBG\GLD-Harmonization\510859_AS\THA\THA_2021_LFS\THA_2021_LFS_v01_M_v01_A_GLD\Data\Harmonized"

use "$path_output\THA_2021_LFS_V01_M_V01_A_GLD_Q1.dta", clear
append using "$path_output\THA_2021_LFS_V01_M_V01_A_GLD_Q2.dta"
append using "$path_output\THA_2021_LFS_V01_M_V01_A_GLD_Q3.dta"
append using "$path_output\THA_2021_LFS_V01_M_V01_A_GLD_Q4.dta"

save "$path_output\THA_2021_LFS_V01_M_V01_A_GLD_ALL.dta"