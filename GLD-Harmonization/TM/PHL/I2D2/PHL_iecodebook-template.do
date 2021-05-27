* PHL_iecodebook-template.do
* runs iecodebook template to create a template for variable names and labels used once in project 

local 	path `"Y:\GLD-Harmonization\551206_TM\PHL"'
use 	`"`path'\PHL_1997_LFS\PHL_1997_LFS_v01_M\Data\Stata\LFS APR1997.dta"', clear 

iecodebook template using "`path'\PHL_docs\PHL-template.xlsx", replace

clear 