** CONVERSION OF TSIC TO ISIC

import excel "C:\Users\wb510859\OneDrive - WBG\GLD-Harmonization\510859_AS\THA\THA_2021_LFS\THA_2021_LFS_v01_M\Data\Original\TSIC to ISIC.xlsx", sheet("Sheet1") firstrow clear

* Duplicates test: TSIC is not unique
duplicates report TSIC

* Use first observed equivalence
duplicates drop TSIC, force

* Save the file
save "C:\Users\wb510859\OneDrive - WBG\GLD-Harmonization\510859_AS\THA\THA_2021_LFS\THA_2021_LFS_v01_M\Data\Stata\TSIC_to_ISIC_v3.dta", replace

