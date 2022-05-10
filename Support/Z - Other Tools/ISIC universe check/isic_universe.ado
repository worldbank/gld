********************************************************************************
* ISIC Universe Tool														   *
********************************************************************************


capture program drop isic_universe
program define isic_universe
{		


syntax, var(varname)

*---------- 1: Read in isic universe, save as temp

* Record what isic version this file has
local isic_version = isic_version in 1

* Preserve harmonization file to read in ISIC universe, save
preserve

* Read in ISIC codes
import delimited "https://raw.githubusercontent.com/worldbank/gld/main/Support/D%20-%20Q%20Checks/Helper%20Programs/isic_codes.txt", delimiter(comma) varnames(1) clear 

* Reduce to only cases of said version
keep if version == "`isic_version'"

* Save as temp
tempfile isic_universe
save `isic_universe'

restore
 

*---------- 2: Make comparison, show which cases are problematic

qui : gen code = `var'

* Merge with ISIC universe, keeping only code variable from using, only match and master
qui : merge m:1 code using `isic_universe', keepusing(code) keep(master match)

* Reduce to only those with ISIC values and not in the universe (_merge takes value 1)
keep if !missing(`var') & _merge == 1

* Generate variable that counts instances
gen instances = 1

collapse (count) instances (first) countrycode year isic_version, by(industrycat_isic)

}
end
