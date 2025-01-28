
*========================================================================*
* Code to convert the manual correspondence in the SCIAN 2007 spreadsheet
*========================================================================*

* Define paths
local spreadsheet_path "Y:/GLD-Harmonization/529026_MG/Countries/MEX/SCIAN codes/Input/ENOE_SCIAN_2004_Codes.xlsx"
local output_path "Y:/GLD-Harmonization/529026_MG/Countries/MEX/SCIAN codes/Output/SCIAN_04_ISIC_4.dta"

* Import file
import excel "`spreadsheet_path'", sheet("Manual correspondences") cellrange(A7:F186) firstrow clear

* Rename variables, keep only relevant, save
rename (Clave Code) (scian isic)
keep scian isic
destring scian, replace
save "`output_path'", replace