********************************************************************************
* ISIC ISCO Universe Tool														   *
********************************************************************************


capture program drop int_classif_universe
program define int_classif_universe
{		


syntax, var(varname) universe(str)

*---------- 1: Evaluate input

if !ustrregexm("`universe'", "^(isco|ISCO|isic|ISIC)$") {
	di as error "universe is a string of the following forms isic, ISIC, isco, ISCO. You entered `universe'. Please review"
	exit 198
}

if (ustrregexm("`universe'", "^(isco|ISCO)$")) & (ustrregexm("`var'", "(isic)")){
	di as error "Universe is ISCO but variable is from the ISIC realm. Please review"
	exit 198
}

if (ustrregexm("`universe'", "^(isic|ISIC)$")) & (ustrregexm("`var'", "(isco)")){
	di as error "Universe is ISIC but variable is from the ISCO realm. Please review"
	exit 198
}

if !ustrregexm("`var'", "(_isco|_isic)") {
	di as error "Variable `var' is not one of the variables with ISCO/ISIC information. Please review"
	exit 198
}

*---------- 2: Process for ISIC

if ustrregexm("`universe'", "^(isic|ISIC)$") {
	
	
	*---------- 2.1: Read in isic universe, save as temp

	* Record what isic version this file has
	local isic_version = isic_version in 1

	* Preserve harmonization file to read in ISIC universe, save
	preserve
	
	* World Bank VDI has sometimes problems with executing the comand below to read from a website directly
	* Have reached out to IT, in the works. Workaround found is to relax the SSL encryption. This can be dangerous
	* if you don't know the site. Here we do. Nonetheless, setting is instantly reverted after executing command.
	set sslrelax on
	
	* Read in ISIC codes
	import delimited "https://raw.githubusercontent.com/worldbank/gld/main/Support/D%20-%20Q%20Checks/Helper%20Programs/isic_codes.txt", delimiter(comma) varnames(1) clear 


	set sslrelax off
	
	* Reduce to only cases of said version
	keep if version == "`isic_version'"

	* Save as temp
	tempfile isic_universe
	save `isic_universe'

	restore
	
	*---------- 2.2: Make comparison, show which cases are problematic

	qui : gen code = `var'

	* Merge with ISIC universe, keeping only code variable from using, only match and master
	qui : merge m:1 code using `isic_universe', keepusing(code) keep(master match)

	* Reduce to only those with ISIC values and not in the universe (_merge takes value 1)
	keep if !missing(`var') & _merge == 1

	* Count if there are any cases left
	qui: count
	
	* If there are none, stop
	if `r(N)' == 0 {
	    
		dis _newline
		dis "{bf:     All good here!}"
		dis _newline
		exit, clear
		
	}
	else {
	    
	* Generate variable that counts instances
	gen instances = 1
	
	collapse (count) instances (first) countrycode year isic_version, by(`var')
		
	}


}

*---------- 3: Process for ISCO

if ustrregexm("`universe'", "^(isco|ISCO)$") {
	
	
	*---------- 3.1: Read in isco universe, save as temp

	* Record what isco version this file has
	local isco_version = isco_version in 1

	* Preserve harmonization file to read in ISIC universe, save
	preserve
	
	* Same SSL process as for ISIC
	set sslrelax on

	* Read in ISCO codes
	import delimited "https://raw.githubusercontent.com/worldbank/gld/main/Support/D%20-%20Q%20Checks/Helper%20Programs/isco_codes.txt", delimiter(comma) varnames(1) clear 

	set sslrelax off

	* Reduce to only cases of said version
	keep if version == "`isco_version'"

	* Save as temp
	tempfile isco_universe
	save `isco_universe'

	restore
	
	*---------- 3.2: Make comparison, show which cases are problematic

	qui : gen code = `var'

	* Merge with ISCO universe, keeping only code variable from using, only match and master
	qui : merge m:1 code using `isco_universe', keepusing(code) keep(master match)

	* Reduce to only those with ISIC values and not in the universe (_merge takes value 1)
	keep if !missing(`var') & _merge == 1

	* Count if there are any cases left
	qui: count
	
	* If there are none, stop
	if `r(N)' == 0 {
	    
		dis _newline
		dis "{bf:     All good here!}"
		dis _newline
		exit, clear
		
	}
	else {
	    
	* Generate variable that counts instances
	gen instances = 1
	
	collapse (count) instances (first) countrycode year isco_version, by(`var')
		
	}

} 

}
end
