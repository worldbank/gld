********************************************************************************
* Program for industrial or occupational codes assignation
********************************************************************************

cap program drop gld_labels
program define gld_labels
{
syntax, classfrom(str) classto(str) dig(str)
foreach dim in from to{
	local root "https://github.com/worldbank/gld/main/Support/Z - Other Tools/Code/ISIC%20ISCO%20conversion%20tool/Labels/"
	preserve
	use "https://github.com/worldbank/gld/main/Support/Z - Other Tools/Code/ISIC%20ISCO%20conversion%20tool/Labels/`class`dim''_`dig'dig.dta", clear
	tempfile tomerge
	save `tomerge', replace
	restore
	merge m:1 `class`dim''_`dig'dig using `tomerge', keep(master matched) nogen 
}
}
end