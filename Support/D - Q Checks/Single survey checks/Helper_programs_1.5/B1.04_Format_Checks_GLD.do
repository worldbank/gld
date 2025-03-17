/*******************************************************************************
								
                            GLD CHECKS Version 1.5
                              01. Format checks 
		   	   																   
*******************************************************************************/	


/*==================================================
              0: Program set up
==================================================*/

version 16

cap mkdir "${output}/${ccode3}_${cyear}_${mydate}/Block1_Format"
	
*----------0.1: Set necessary paths

* Define path for postfile .dta
local postfile_path = "${output}/${ccode3}_${cyear}_${mydate}/Block1_Format/${ccode3}_${cyear}_${csurvey}_Q_Format_Checks.dta"

*----------0.2: Define postfile

tempname memhold
postfile `memhold' str20 Block str45 Var_Name str120 Test_Type Result Flag using "`postfile_path'", replace

*----------0.4: Read in file
use "${mydata}", clear

*----------0.5: Define global of total obs

qui : count
global overall_count = `r(N)'

*----------0.6: Read in isic universe, save as temp

cap confirm variable isic_version
if _rc == 0 { // if isic version info exists, otherwise cannot know which ISIC version to compare to

	* Record what isic version this file has
	local isic_version = isic_version in 1

	* Preserve harmonization file to read in ISIC universe, save
	preserve
	set sslrelax on
	import delimited "https://raw.githubusercontent.com/worldbank/gld/main/Support/D%20-%20Q%20Checks/Single%20survey%20checks/Helper_programs_1.5/isic_codes.txt", delimiter(comma) varnames(1) clear 
	set sslrelax off
	* Reduce to only cases of said version
	keep if version == "`isic_version'"

	* Save as temp
	tempfile isic_universe
	save `isic_universe'

	restore

}


*----------0.7: Read in isic universe, save as temp

cap confirm variable isco_version
if _rc == 0 { // if isic version info exists, otherwise cannot know which ISIC version to compare to

	* Record what isic version this file has
	local isco_version = isco_version in 1

	* Preserve harmonization file to read in ISIC universe, save
	preserve
	set sslrelax on
	import delimited "https://raw.githubusercontent.com/worldbank/gld/main/Support/D%20-%20Q%20Checks/Single%20survey%20checks/Helper_programs_1.5/isco_codes.txt", delimiter(comma) varnames(1) clear 
	set sslrelax off
	* Reduce to only cases of said version
	keep if version == "`isco_version'"

	* Save as temp
	tempfile isco_universe
	save `isco_universe'

	restore

}


/*==================================================
              1: Overall Survey adherence
==================================================*/

*----------1.1: Evaluate filename
local current_filename "`c(filename)'"
* either Mac or Windows environment, use very last slash, no matter the direction
local last_slash_back = strrpos("`current_filename'", "\")
local last_slash_forw = strrpos("`current_filename'", "/")
if `last_slash_back' > `last_slash_forw' {
	local last_slash `last_slash_back'
}
else {
	local last_slash `last_slash_forw'
}
local current_filename = substr("`current_filename'", `last_slash' + 1, .)
local check = regexm("`current_filename'", "^[a-zA-Z][a-zA-Z][a-zA-Z]_[0-9][0-9][0-9][0-9]_[a-zA-Z0-9-]+_[vV][0-9][0-9]_M_[vV][0-9][0-9]_A_[a-zA-Z][a-zA-Z][a-zA-Z]_[a-zA-Z_]+\.dta")
if `check' == 0 { // filename does not follow convention
	post `memhold' ("1. Overall") ("FileName") ("Filename being checked does not follow naming convention") (.) (1)
}

*----------1.2: Variable from dictionary not in the data
foreach var of global all_vars {
	cap confirm variable `var'
	if _rc != 0 {
		post `memhold' ("1. Overall") ("`var'") ("Variable not in data") (.) (1)
	}
}

*----------1.3: Variable in data that is not in dictionary
preserve
* First, drop vars from dictionary
foreach var of global all_vars {
	cap confirm variable `var'
	if _rc == 0 { // var from dictionary in data
		drop `var'
	}
}

* Now record what is left over
qui: describe, varlist
if `r(k)' > 0 { // there are vars left over after dropping dictionary
	foreach var in `r(varlist)' {
		post `memhold' ("1. Overall") ("`var'") ("Variable not in dictionary") (.) (1)
	}	
}

restore

*----------1.4: Variable has all missing
foreach var of global all_vars {
	cap confirm variable `var'
	if _rc == 0 { // if var exists since if not captured in 1.1
		qui : mdesc `var'
		if `r(percent)' == 100 { // if all are missing
			post `memhold' ("1. Overall") ("`var'") ("All values missing") (.) (99)
		}		
	}
}

*----------1.5: Check numeric variables
foreach var of global numeric_vars {
	cap confirm numeric variable `var'
	if _rc != 0 & _rc != 111 { // If neither numeric nor absent in the dataset
		post `memhold' ("1. Overall") ("`var'") ("A numeric var is not numeric") (.) (1)
	}
}

*----------1.6: Check string variables
foreach var of global string_vars {
	cap confirm string variable `var'
	if _rc != 0 & _rc != 111 { // If neither string nor absent in the dataset
		post `memhold' ("1. Overall") ("`var'") ("A string var is not string") (.) (1)
	}
}

*----------1.7: Check invariant variables do not change
foreach var of global invariant_vars {
	cap confirm variable `var'
	if _rc == 0 { // if var exists since if not captured in 1.1
		qui: distinct `var'
		if `r(ndistinct)' > 1 { // var takes more than one value
			post `memhold' ("1. Overall") ("`var'") ("Invariant variable takes 2+ values") (.) (1)
		}
	}
}

*----------1.8: Check variables that should vary but don't
foreach var of global change_should_vars {
	cap confirm variable `var'
	if _rc == 0 { // if var exists since if not captured in 1.1
		qui: distinct `var'
		if `r(ndistinct)' == 1 { // var takes just one value (r(ndistinct) == 1). All missing (r(ndistinct) == 0) is accepted
			post `memhold' ("1. Overall") ("`var'") ("Variable is unique in dataset") (.) (99)
		}
	}

}

*----------1.9: Check variables that should not change within HH

* Note unhappy with this as it is pretty loopy. However, the alternative with egen using by hhid and comparing mean to max (if equal no variance) only works for numeric, this solution does not depend on the type of variable being analysed.

* Wrap first in confirm hhid as some surveys may not have this (e.g., Sakernas)
cap confirm variable hhid
if _rc == 0 { 
    * hhid exists, can use it
    foreach var of global hh_level_vars {
		cap confirm variable `var'
		if _rc == 0 { // if var exists since if not captured in 1.1
			by hhid (`var'), sort: gen diff = `var'[1] != `var'[_N] // if equal, in group first == last
			qui : count if diff == 1
			if `r(N)' > 0 { // there are cases where diff is 1 (condition is true)
				post `memhold' ("1. Overall") ("`var'") ("Variable is not unique within HH") (.) (99)
			* Close if r(N) > 0
			}
			drop diff
		* Close if _rc == 0 for global var exists
		}
	* Close foreach var
	}
* Close hhid exists
}


*----------1.10: Categorical vars - Check whether values outside the range
qui: count 
local tot_obs = r(N) // count how many obs in total, store that value

foreach list of global cat_list_names { // loop through list of categorical global varlists
	
	local last_underscore = strrpos("`list'","_") // check whether simple range or added value (e.g. 99)
	if `last_underscore' != 6 { // cat_#_#_# case
		
		tokenize "`list'", parse("_")
		local low_lim = `3'
		local upp_lim = `5'
		local extra_n = `7'
		foreach var of global `list' {
		
			cap confirm variable `var'
			if _rc == 0 { // if var exists since if not captured in 1.1
			
				qui : count if inrange(`var', `low_lim', `upp_lim') | missing(`var') | `var' == `extra_n'
				local ratio = (`tot_obs' - r(N)) / `tot_obs'
				if `ratio' > 0 { // issue since some outside of range
				
					post `memhold' ("1. Overall") ("`var'") ("Variable values outside of range `low_lim', `upp_lim' (+ `extra_n') (ratio of cases ->)") (`ratio') (1)
					
				} // end if ratio >0
			} // end if _rc == 0
		} // end varlist
		
	} 
	else { // cat_#_# case
		
		tokenize "`list'", parse("_")
		local low_lim = `3'
		local upp_lim = `5'
		foreach var of global `list' {
		
			cap confirm variable `var'
			if _rc == 0 { // if var exists since if not captured in 1.1
			
				qui : count if inrange(`var', `low_lim', `upp_lim') | missing(`var')
				local ratio = (`tot_obs' - r(N)) / `tot_obs'
				if `ratio' > 0 { // issue since some outside of range
				
					post `memhold' ("1. Overall") ("`var'") ("Variable values outside of range `low_lim', `upp_lim' (ratio of cases ->)") (`ratio') (1)
					
				} // end if ratio >0 
			} // end if _rc == 0
		} // end varlist		
	} // end else
	

} // end list of category lists


*----------1.11: Check survey versions agree with version variables

* First read filename (from last slash) and lowercase 
local current_filename "`c(filename)'"
local last_slash = strrpos("`current_filename'", "\")
local current_filename = substr("`current_filename'", `last_slash' + 1, .)
gen helper_filename = "`current_filename'"
replace helper_filename = lower(helper_filename)
local current_filename = helper_filename
drop helper_filename

* Obtain position of master, alter (harmomize) versions
local position_master = strrpos("`current_filename'", "_m_")
local position_alter = strrpos("`current_filename'", "_a_")

* Make locals with that info
local eval_master = substr("`current_filename'", `position_master' - 3, 3)
local eval_alter  = substr("`current_filename'", `position_alter'  - 3, 3)

* Check master
cap confirm variable vermast 
if _rc == 0 { // if var exists since if not captured in 1.1
	replace vermast = lower(vermast)
	qui: count if vermast != "`eval_master'"
	if `r(N)' > 0 { // The version do not agree
		post `memhold' ("1. Overall") ("vermast") ("Version of Master per filename unequal to vermast") (.) (1)
	} // end if there are case of disagreement
} // end if var exists

* Check alter
cap confirm variable veralt 
if _rc == 0 { // if var exists since if not captured in 1.1
	replace veralt = lower(veralt)
	qui: count if veralt != "`eval_alter'"
	if `r(N)' > 0 { // The version do not agree
		post `memhold' ("1. Overall") ("veralt") ("Version of Alter per filename unequal to vermalt") (.) (1)
	} // end if there are case of disagreement
} // end if var exists


/*==================================================
              2: Consistency Survey & ID Module
==================================================*/

*----------2.1: countrycode vermast veralt are three letter strings
foreach var of global surv_str3 {
	cap confirm variable `var'
	if _rc == 0 { // if var exists since if not captured in 1.1
		cap confirm str3 var `var'
		if _rc != 0 { // variable is not three letter string
			post `memhold' ("2. Survey & ID") ("`var'") ("`var' is not str3 (possible even if all entries are ccc/v## -> gen str3 varName)") (.) (1)
		} // end if not three letter
	} // end if _rc == 0
}

*----------2.2: survname has no underscores
cap confirm variable survname
if _rc == 0 { // if var exists since if not captured in 1.1
	qui : count if !regex(survname, "^[a-zA-Z0-9-]+$")
	if `r(N)' > 0 { // survname is not just alphanumeric or dash
		post `memhold' ("2. Survey & ID") ("survname") ("Survey name should only be alphanumeric or contain a dash, no other characters") (.) (1)
	} // end if alphanum or dash
} // end if _rc == 0

*----------2.3: year is four digit
cap confirm variable year
if _rc == 0 { // if var exists since if not captured in 1.1
	qui : count if year < 1880 | year > ${currentyear}
	if `r(N)' > 0 { // year outside the norm
		post `memhold' ("2. Survey & ID") ("year") ("Variable year is not between 1880 and the current year") (.) (1)
	} // end if year odd
} // end if _rc == 0


*----------2.4: pid is unique at HH level
cap confirm variable pid
if _rc == 0 { // if var exists since if not captured in 1.1
	qui : distinct pid
	if `r(ndistinct)' != `r(N)' { // not unique_value
		local pid_unique_ratio = `r(ndistinct)' / `r(N)'
		post `memhold' ("2. Survey & ID") ("pid") ("pid is not unique. Distinct to total ratio ->") (`pid_unique_ratio') (1)
	} // end if pid not unique
} // end if _rc == 0

*----------2.5: isic, isco, isced versions are strings w/o spaces
foreach var of global int_class_versions {
	cap confirm variable `var'
	if _rc == 0 { // if var exists since if not captured in 1.1
		qui : count if !ustrregexm(`var', "^(isco_1968|isco_1988|isco_2008|isic_2|isic_3|isic_3\.1|isic_4|isced_1976|isced_1997|isced_2011)$")
		if `r(N)' > 0 { // not defined as in the possible options
			post `memhold' ("2. Survey & ID") ("`var'") ("Variable `var' is not correctly defined") (.) (1)
		} // end if not correctly defined
	} // end if _rc == 0
}
  
/*==================================================
              3: Consistency Geography Module
==================================================*/

*----------3.1: Administrative ID hierarchy 
* Hierarchy requires the upper admin level be present and has values if the lower one has
foreach three_vars of global subnat_hierarchy {
	subnat_hierarchy `three_vars' // user generated program
	if `r(check)' == 1 { // subnat_hierarchy is 1 if error
		post `memhold' ("3. Geography") ("`three_vars'") ("Admin ID structure is not hierarchically consistent") (.) (1)
	}
}

/*==================================================
              4: Consistency Demography Module
==================================================*/

*----------4.1: HH size differs from number of obs
cap confirm variable hsize hhid
if _rc == 0 { // if var exists since if not captured in 1.1
	bysort hhid: gen hh_size_verify = _N
	qui : count if hh_size_verify != hsize
	if `r(N)' >0 { // there are cases when it differs
		local hh_size_error_ratio = `r(N)' / $overall_count
		post `memhold' ("4. Demography") ("hsize") ("HHsize differs from number of obs per HH (ratio ->)") (`hh_size_error_ratio') (1)
		drop hh_size_verify
	* Close if r(N) > 0
	}
* Close if hsize & hhid exist
}


*----------4.2: Check age
cap confirm variable age
if _rc == 0 { // if var exists since if not captured in 1.1
	local check_age = 0 
	qui : count if age/int(age)!= 1 & age!= 0 & age!= . 
	if `r(N)' > 0 local check_age = `r(N)'
	qui : count if (age < 0 | age>120) & age<.
	if `r(N)' > 0 local check_age = `check_age' + `r(N)'
	if `check_age' > 0 {
		post `memhold' ("4. Demography") ("age") ("Age shows unexpected values (# of cases ->)") (`check_age') (1)
	}
}

*----------4.3: Only one head per HH
cap confirm variable relationharm hhid
if _rc == 0 { // if var exists since if not captured in 1.1
	
	qui : count if relationharm == 1
	local number_heads = `r(N)'
	qui : distinct hhid
	if `r(ndistinct)' != `number_heads' { // # of heads and # of HHs differs
	
		local hh_heads_ratio = `number_heads' / `r(ndistinct)'
		post `memhold' ("4. Demography") ("relationharm") ("Ratio of Heads to HHID is not 1 (ratio ->)") (`hh_heads_ratio') (1)
	* Close if `r(ndistinct)' != `number_heads'
	}
* Close if relationharm hhid exist
}

/*==================================================
              5: Migration
==================================================*/


*----------5.1: Check that no answers if never migrated
cap confirm migrated_binary 
if _rc == 0 { // if var exists, else captured in 1.1
	foreach var of global never_migrated {
		cap confirm variable var'
		if _rc == 0 { // if var exists count if answers when migrated_binary is 0
			qui : count if !missing(`var') & migrated_binary == 0
			if `r(N)' >0 { // there are cases with answers
				post `memhold' ("5. Migration") ("`var'") ("Variable `var' has answers although migrated_binary says neve trained (# of cases ->)") (`r(N)') (1)
		
			} // end cases with answers
		} // end var exists
	} // end vars loop
} // end migrated_binary exists
else {
	foreach var of global never_migrated {
		cap confirm variable var'
		if _rc == 0 { // if var exists but migrated_binary not, error
			post `memhold' ("5. Migration") ("`var'") ("Variable `var' has migration answers although the initial migrated_binary is missing") (.) (1)
		} // end var exists
	} // end vars loop
} // end migrated_binary does not exist


/*==================================================
              6: Consistency Education Module
==================================================*/

*----------6.1: educy is not a negative number, nor more than age
cap confirm variable educy
if _rc == 0 { // if var exists since if not captured in 1.1
	local check_educy = 0 
	qui : count if educy < 0 & educy != . 
	if `r(N)' > 0 local check_educy = `r(N)'
	qui : count if age < educy & (age != . & educy != .)
	if `r(N)' > 0 local check_educy = `check_educy' + `r(N)'
	if `check_educy' > 0 {
		post `memhold' ("6. Education") ("educy") ("Years in education shows unexpected values (# of cases ->)") (`check_educy') (1)
	}
}

*----------6.2: education hierarchy
* The logic of subnatid holds here, only inverted. If educat 7 is present, 5 cannot be missing,
* if 5 is present, 4 cannot be missing
cap confirm variable educat7 educat5 educat4
if _rc == 0 { // if vars exist since if not captured in 1.1
	subnat_hierarchy educat4 educat5 educat7
	if `r(check)' == 1 { // hierarchy not respected
		post `memhold' ("6. Education") ("educat*") ("Educat 4/5/7 hierarchy not respected") (.) (1)
	}
}

*----------6.3: education concordance 7 / 5
cap confirm variable educat7 educat5 
if _rc == 0 { // if vars exist since if not captured in 1.1
	qui : count if (educat7 == 1 & educat5 != 1) | (educat7 == 2 & educat5 != 2) | (educat7 == 3 & educat5 != 3) | (educat7 == 4 & educat5 != 3) | (educat7 == 5 & educat5 != 4) | (educat7 == 6 & educat5 !=5 ) | (educat7 == 7 & educat5 != 5)
	if `r(N)' > 0 { // Correspondance not kept
		post `memhold' ("6. Education") ("educat7 vs 5") ("Educat 5 <->7 correspondance not holding (number of cases ->)") (`r(N)') (1)
	}
}

*----------6.4: education concordance 5 / 4
cap confirm variable educat5 educat4 
if _rc == 0 { // if vars exist since if not captured in 1.1
	qui : count if (educat5 == 1 & educat4 != 1) | (educat5 == 2 & educat4 != 2) | (educat5 == 3 & educat4 != 2) | (educat5 == 4 & educat4 != 3) | (educat5 == 5 & educat4 != 4)
	if `r(N)' > 0 { // Correspondance not kept
		post `memhold' ("6. Education") ("educat5 vs 4") ("Educat 4 <-> 5 correspondance not holding (number of cases ->)") (`r(N)') (1)
	}
}


*----------6.5: Check ISCED codes
cap confirm educat_isced
if _rc == 0 { // if vars exist, else captured in 1.1
	qui : count if (educat_isced < 100 | educat_isced > 999) & !missing(educat_isced)
	if `r(N)' > 0 { // Non missing value of fewer or more than three digits
		post `memhold' ("6. Education") ("educat_isced") ("ISCED code is not three digits (number of cases ->)") (`r(N)') (1)
	}
}

/*==================================================
              7: Consistency Training Module
==================================================*/

*----------7.1: Check that no answers if never trained
cap confirm vocational 
if _rc == 0 { // if var exists, else captured in 1.1
	foreach var of global never_trained {
		cap confirm variable var'
		if _rc == 0 { // if var exists count if answers when vocational is 0
			qui : count if !missing(`var') & vocational == 0
			if `r(N)' >0 { // there are cases with answers
				post `memhold' ("7. Training") ("`var'") ("Variable `var' has answers although vocational says neve trained (# of cases ->)") (`r(N)') (1)
		
			} // end cases with answers
		} // end var exists
	} // end vars loop
} // end vocational exists
else {
	foreach var of global never_trained {
		cap confirm variable var'
		if _rc == 0 { // if var exists but vocational not, error
			post `memhold' ("7. Training") ("`var'") ("Variable `var' has vocational answers although the initial vocational is missing") (.) (1)
		} // end var exists
	} // end vars loop
} // end vocational does not exist


/*==================================================
              8: Consistency Labour Module
==================================================*/

*----------8.1: 7 day ref unemployed are only asked unemployment set questions
foreach var of global not_posed_unemployed_week {
	cap confirm variable lstatus `var'
	if _rc == 0 { // if var exists since if not captured in 1.1
	
		qui : count if lstatus == 2 & !missing(`var')
		if `r(N)' >0 { // there are cases with answers
			local unemp_7_wrong = `r(N)' / $overall_count
			post `memhold' ("8. Labour") ("`var'") ("Variable `var' has labour answers for the 7 day unemployed (ratio ->)") (`unemp_7_wrong') (1)
		
		} // end cases with answers
	} // end var exists
} // end

*----------8.2: 12 month ref unemployed are only asked unemployment set questions
foreach var of global not_posed_unemployed_year {
	cap confirm variable lstatus_year `var'
	if _rc == 0 { // if var exists since if not captured in 1.1
	
		qui : count if lstatus_year == 2 & !missing(`var')
		if `r(N)' >0 { // there are cases with answers
			local unemp_12_wrong = `r(N)' / $overall_count
			post `memhold' ("8. Labour") ("`var'") ("Variable `var' has labour answers for the 12 month unemployed (ratio ->)") (`unemp_12_wrong') (1)
		
		} // end cases with answers
	} // end var exists
} // end

*----------8.3: NLF asks for NLF reason 7 day recall
cap confirm variable lstatus nlfreason
if _rc == 0 { // if var exists since if not captured in 1.1
	
		qui : count if lstatus == 3
		local total_nlf = `r(N)'
		qui : count if lstatus == 3 & missing(nlfreason)
		if `r(N)' > 0 & `r(N)' < `total_nlf' { // Either all answered or all missing, in between -> error
			post `memhold' ("8. Labour") ("nlfreason") ("NLF individuals, some answered why NLF others did not, odd") (.) (1)

		} // end odd cases
}

*----------8.4: NLF asks for NLF reason 12 month recall
cap confirm variable lstatus_year nlfreason_year
if _rc == 0 { // if var exists since if not captured in 1.1
	
		qui : count if lstatus_year == 3
		local total_nlf = `r(N)'
		qui : count if lstatus_year == 3 & missing(nlfreason_year)
		if `r(N)' > 0 & `r(N)' < `total_nlf' { // Either all answered or all missing, in between -> error
			post `memhold' ("8. Labour") ("nlfreason_year") ("NLF individuals, some answered why NLF others did not, odd") (.) (1)

		} // end odd cases
}

*----------8.5: 7 day ref NLF are only asked NLF set questions
foreach var of global not_posed_nlf_week {
	cap confirm variable lstatus `var'
	if _rc == 0 { // if var exists since if not captured in 1.1
	
		qui : count if lstatus == 3 & !missing(`var')
		if `r(N)' >0 { // there are cases with answers
			local nlf_7_wrong = `r(N)' / $overall_count
			post `memhold' ("8. Labour") ("`var'") ("Variable `var' has labour answers for the 7 day NLF (ratio ->)") (`nlf_7_wrong') (1)
		
		} // end cases with answers
	} // end var exists
} // end

*----------8.6: 12 month ref NLF are only asked NLF set questions
foreach var of global not_posed_nlf_year {
	cap confirm variable lstatus_year `var'
	if _rc == 0 { // if var exists since if not captured in 1.1
	
		qui : count if lstatus_year == 3 & !missing(`var')
		if `r(N)' >0 { // there are cases with answers
			local nlf_12_wrong = `r(N)' / $overall_count
			post `memhold' ("8. Labour") ("`var'") ("Variable `var' has labour answers for the 12 month NLF (ratio ->)") (`nlf_12_wrong') (1)
		
		} // end cases with answers
	} // end var exists
} // end


*----------8.7: Industry10 and industry4 correspondance
foreach pair of global industry_cat_concordance {
	cap confirm variable `pair' 
	if _rc == 0 { // if pair of vars exists, else captured in 1.1
		local cat_10_var : word 1 of `pair'
		local cat_4_var  : word 2 of `pair'
		qui : count if (`cat_10_var' == 1 & `cat_4_var' != 1) | (`cat_10_var' == 2 & `cat_4_var' != 2) | (`cat_10_var' == 3 & `cat_4_var' != 2) | (`cat_10_var' == 4 & `cat_4_var' != 2) | (`cat_10_var' == 5 & `cat_4_var' != 2) | (`cat_10_var' == 6 & `cat_4_var' != 3) | (`cat_10_var' == 7 & `cat_4_var' != 3) | (`cat_10_var' == 8 & `cat_4_var' != 3) | (`cat_10_var' == 9 & `cat_4_var' != 3) | (`cat_10_var' == 10 & `cat_4_var' != 4)
		if `r(N)' > 0 { // Correspondance not kept
			post `memhold' ("8. Labour") ("`cat_10_var' and `cat_4_var'") ("10 industry cat and 4 industry cat do not correspond (number of cases ->)") (`r(N)') (1)
			
		} // end correspondance not kept
	} // end vars exist
} // end loop



*----------8.8: Wage logic primary, secondary, other - 7 day reference
* Logic would be (not necessarily wrong, just odd, want to check, that you make more money on
* your primary than on your secondary job; secondary makes more than other odd jobs)
* Step 1 - Establish which vars are in the data
foreach var in  wage_total wage_total_2 t_wage_others {
	cap confirm variable `var'
	if _rc == 0 local wage_present_vars = "`wage_present_vars'" + " " + "`var'"
}
* Step 2 - Check consistency of existing
local counting: word count `wage_present_vars'
if `counting' > 1{ // if just one var no point in checking

	local var1 : word 1 of `wage_present_vars'
	local var2  : word 2 of `wage_present_vars'
	qui count if `var1' < `var2' & ( !missing(`var1') | !missing(`var2') )
	local odd_wage_week = `r(N)'
	if `counting' == 3 { // do one more check if present
	
		local var3  : word 3 of `wage_present_vars'
		qui count if `var2' < `var3' & ( !missing(`var2') | !missing(`var3') )
		local odd_wage_week = `odd_wage_week' + `r(N)'
	} // end case three vars exist
	
	if `odd_wage_week' > 0 { // there are odd cases
		post `memhold' ("8. Labour") ("wage_total wage_total_2 t_wage_others") ("Total wage sums do not follow primary, secondary, other descendance - 7 day ref (number of cases ->)") (`odd_wage_week') (1)
	} // end odd cases
} // end Step 2



*----------8.9: Wage logic primary, secondary, other - 12 month reference
* Step 1 - Establish which vars are in the data
foreach var in  wage_total_year wage_total_2_year t_wage_others_year {
	cap confirm variable `var'
	if _rc == 0 local wage_present_vars = "`wage_present_vars'" + " " + "`var'"
}
* Step 2 - Check consistency of existing
local counting: word count `wage_present_vars'
if `counting' > 1{ // if just one var no point in checking

	local var1 : word 1 of `wage_present_vars'
	local var2  : word 2 of `wage_present_vars'
	qui count if `var1' < `var2' & ( !missing(`var1') & !missing(`var2') )
	local odd_wage_week = `r(N)'
	if `counting' == 3 { // do one more check if present
	
		local var3  : word 3 of `wage_present_vars'
		qui count if `var2' < `var3' & ( !missing(`var2') & !missing(`var3') )
		local odd_wage_week = `odd_wage_week' + `r(N)'
	} // end case three vars exist
	
	if `odd_wage_week' > 0 { // there are odd cases
		post `memhold' ("8. Labour") ("wage_total wage_total_2 t_wage_others") ("Total wage sums do not follow primary, secondary, other descendance - 12 month ref (number of cases ->)") (`odd_wage_week') (1)
	} // end odd cases
} // end Step 2



*----------8.10: Wage logic total w/ vs w/o compensation - 7 day reference
cap confirm variable t_wage_nocompen_total t_wage_total
if _rc == 0 { // if pair of vars exists, else captured in 1.1
	qui count if t_wage_total < t_wage_nocompen_total & ( !missing(t_wage_total) | !missing(t_wage_nocompen_total) )
	if `r(N)' > 0 { // there are cases where w/o comp is > than w/ comp
		post `memhold' ("8. Labour") ("t_wage_nocompen_total t_wage_total") ("7 day ref - Total wage w/o compensation is larger than w/ compensation (number of cases ->)") (`r(N)') (1)
	}
}



*----------8.11: Wage logic total w/ vs w/o compensation - 12 month reference
cap confirm variable t_wage_nocompen_total_year t_wage_total_year
if _rc == 0 { // if pair of vars exists, else captured in 1.1
	qui count if t_wage_total_year < t_wage_nocompen_total_year & ( !missing(t_wage_total_year) | !missing(t_wage_nocompen_total_year) )
	if `r(N)' > 0 { // there are cases where w/o comp is > than w/ comp
		post `memhold' ("8. Labour") ("t_wage_nocompen_total_y t_wage_total_y") ("12 month ref - Total wage w/o compensation is larger than w/ compensation (number of cases ->)") (`r(N)') (1)
	}
}


*----------8.12: Wage logic total w/ vs w/o compensation - Total on all 
cap confirm variable linc_nc laborincome
if _rc == 0 { // if pair of vars exists, else captured in 1.1
	qui count if laborincome < linc_nc & ( !missing(laborincome) | !missing(linc_nc) )
	if `r(N)' > 0 { // there are cases where w/o comp is > than w/ comp
		post `memhold' ("8. Labour") ("laborincome & linc_nc") ("1. Overall - Total wage w/o compensation is larger than w/ compensation (number of cases ->)") (`r(N)') (1)
	}
}


*----------8.13: Hours of work in total across jobs - 7 day ref
cap confirm variable whours whours_2
if _rc == 0 { // if pair of vars exists, else captured in 1.1
	egen whours_check = rowtotal(whours whours_2)
	qui count if whours_check > 168 // 168 means working 24/7
	if `r(N)' > 0 { // Odd cases
		post `memhold' ("8. Labour") ("whours whours_2") ("7 day recall - On two jobs working 24/7 days. Not humanly possible (number of cases ->)") (`r(N)') (1)
	} // end odd cases
	drop whours_check
} // end vars exist


*----------8.14: Hours of work in main job - 7 day ref
cap confirm variable whours weight
if _rc == 0 { // if pair of vars exists, else captured in 1.1
	
	preserve
	
	* Create a var to know whether value between 15 and 65 hours
	gen whours_within_15_65 = 0 if !missing(whours)
	replace whours_within_15_65 = 1 if !missing(whours) & inrange(whours,15, 65)
		
	collapse (mean) whours_within_15_65 [iw = weight]

	if whours_within_15_65 < 0.7 { // Flag if fewer than 70% work these "normal" hours
		
		levelsof whours_within_15_65, local(whours_within)
		post `memhold' ("8. Labour") ("whours") ("7 day recall - Share of people with work hours between 15 and 65 hours smaller than 70% (Actual share is ->)") (`whours_within') (1)
			
	} // close if value smaller than 70%
		
	restore
		
} // end vars exist


*----------8.15: Hours of work in total across jobs - 12 month ref
cap confirm variable whours_year whours_2_year
if _rc == 0 { // if pair of vars exists, else captured in 1.1
	egen whours_check = rowtotal(whours_year whours_2_year)
	qui count if whours_check > 168 // 168 means working 24/7
	if `r(N)' > 0 { // Odd cases
		post `memhold' ("8. Labour") ("whours whours_2") ("7 day recall - On two jobs working 24/7 days. Not humanly possible (number of cases ->)") (`r(N)') (1)
	} // end odd cases
	drop whours_check
} // end vars exist



*----------8.16: Hours of work in main job - 12 month ref
cap confirm variable whours_year weight
if _rc == 0 { // if pair of vars exists, else captured in 1.1
	
	preserve
	
	* Create a var to know whether value between 15 and 65 hours
	gen whours_within_15_65 = 0 if !missing(whours_year)
	replace whours_within_15_65 = 1 if !missing(whours_year) & inrange(whours_year,15, 65)
		
	collapse (mean) whours_within_15_65 [iw = weight]

	if whours_within_15_65 < 0.7 { // Flag if fewer than 70% work these "normal" hours
		
		levelsof whours_within_15_65, local(whours_within)
		post `memhold' ("8. Labour") ("whours_year") ("7 day recall - Share of people with work hours between 15 and 65 hours smaller than 70% (Actual share is ->)") (`whours_within') (1)
			
	} // close if value smaller than 70%
		
	restore
		
} // end vars exist



*----------8.17: Overall income w/o comp cannot be smaller than either 7 day or 12 month w/o comp income
* 7 day
cap confirm variable t_wage_nocompen_total // if this exists then laborincome needs to exist, both annualized data
if _rc == 0 {
	cap confirm variable linc_nc
	if _rc == 0 {
		qui : count if linc_nc < t_wage_nocompen_total | (missing(linc_nc) & !missing(t_wage_nocompen_total)) // since if missing byt t_wage_total exists, that does not evaluate true for the first (missing is larger) but would be odd.
		if `r(N)' > 0 { // Odd cases
			post `memhold' ("8. Labour") ("linc_nc & t_wage_nocompen_total") ("7 day recall total income w/o comp is smaller than any total income w/o comp (number of cases ->)") (`r(N)') (1)
		} // end odd case
	} // end _rc == 0 on linc_nc
	else {
		post `memhold' ("8. Labour") ("linc_nc & t_wage_nocompen_total") ("Variable t_wage_nocompen_total is in data but not linc_nc") (.) (1)
	} // end else (linc_nc not there)
} // end _rc == 0 on t_wage_nocompen_total

* 12 month
cap confirm variable t_wage_nocompen_total_year // if this exists then laborincome needs to exist, both annualized data
if _rc == 0 {
	cap confirm variable linc_nc
	if _rc == 0 {
		qui : count if linc_nc < t_wage_nocompen_total_year | (missing(linc_nc) & !missing(t_wage_nocompen_total_year)) // since if missing byt t_wage_total exists, that does not evaluate true for the first (missing is larger) but would be odd.
		if `r(N)' > 0 { // Odd cases
			post `memhold' ("8. Labour") ("linc_nc & t_wage_nocompen_total_year") ("12 month recall total income w/o comp is smaller than any total income w/o comp (number of cases ->)") (`r(N)') (1)
		} // end odd case
	} // end _rc == 0 on linc_nc
	else {
		post `memhold' ("8. Labour") ("linc_nc & t_wage_nocompen_total") ("Variable t_wage_nocompen_total_year is in data but not linc_nc") (.) (1)
	} // end else (linc_nc not there)
} // end _rc == 0 on t_wage_nocompen_total_year



*----------8.18: Overall income w/ comp cannot be smaller than either 7 day or 12 month w/ comp income
* 7 day
cap confirm variable t_wage_total // if this exists then laborincome needs to exist, both annualized data
if _rc == 0 {
	cap confirm variable laborincome
	if _rc == 0 {
		qui : count if laborincome < t_wage_total | (missing(laborincome) & !missing(t_wage_total)) // since if missing byt t_wage_total exists, that does not evaluate true for the first (missing is larger) but would be odd.
		if `r(N)' > 0 { // Odd cases
			post `memhold' ("8. Labour") ("laborincome & t_wage_total") ("7 day recall total income w/ comp is smaller than any total income w/ comp (number of cases ->)") (`r(N)') (1)
		} // end odd case
	} // end _rc == 0 on laborincome
	else {
		post `memhold' ("8. Labour") ("laborincome & t_wage_total") ("Variable t_wage_total is in data but not laborincome") (.) (1)
	} // end else (laborincome not there)
} // end _rc == 0 on t_wage_total

* 12 month
cap confirm variable t_wage_total_year // if this exists then laborincome needs to exist, both annualized data
if _rc == 0 {
	cap confirm variable laborincome
	if _rc == 0 {
		qui : count if laborincome < t_wage_total_year | (missing(laborincome) & !missing(t_wage_total_year)) // since if missing byt t_wage_total exists, that does not evaluate true for the first (missing is larger) but would be odd.
		if `r(N)' > 0 { // Odd cases
			post `memhold' ("8. Labour") ("laborincome & t_wage_total_year") ("12 month recall total income w/ comp is smaller than any total income w/ comp (number of cases ->)") (`r(N)') (1)
		} // end odd case
	} // end _rc == 0 on laborincome
	else {
		post `memhold' ("8. Labour") ("laborincome & t_wage_total_year") ("Variable t_wage_total_year is in data but not laborincome") (.) (1)
	} // end else (laborincome not there)
} // end _rc == 0 on t_wage_total_year



*----------8.19: Check ISIC code is length 1 (Letter) or length 4 (4 digit code)
foreach var of global isic_check {
	cap confirm string variable `var'
	if _rc == 0 { // if vars exist, is string (if not , captured in section 1)
	
		gen check_isic_length = length(`var') if !missing(`var')
		qui : count if !inlist(check_isic_length,1,4,.)
		if `r(N)' > 0 { // Non missing values other than 1 or 4 exist
		
		post `memhold' ("8. Labour") ("`var'") ("ISIC code is not of length 1 (Letter) or 4 (digits) (number of cases ->)") (`r(N)') (1)
		} // end recording odd cases
	drop check_isic_length
	} // end var exists as string
} // end loop over isic code vars


*----------8.20: Check ISCO codes
foreach var of global isco_check {
	cap confirm string variable `var'
	if _rc == 0 { // if vars exist, is string (if not , captured in section 1)
	
		gen check_isco_length = length(`var') 
		replace check_isco_length = . if missing(`var')
		qui : count if check_isco_length != 4 & !missing(check_isco_length)
		if `r(N)' > 0 { // Non missing values other than 4 exist
		
		post `memhold' ("8. Labour") ("`var'") ("ISC0 code is not of length 4 (digits) (number of cases ->)") (`r(N)') (1)
		} // end recording odd cases
	drop check_isco_length
	} // end var exists as string
} // end loop over isco code vars



*----------8.21: Check industry original variables versus industrycat10
* Run them in pairs (global is written to work in pairs)
foreach token of global industry_alignment{
	
	* Confirm pair exists, otherwise var missing done at the start
	cap confirm variable `token'
	if _rc == 0 {
		
		* Split the token into its elements
		tokenize "`token'"
		local orig "`1'"
		local cat "`2'"
		
		* Check if number of non-missing answers is equal
		qui : count if !missing(`1') & missing(`2')
		if `r(N)' > 0 { // There are cases when indus_orig not missing but induscat is
		
		post `memhold' ("8. Labour") ("`token'") ("indus_orig not missing but induscat10 is (number of cases ->)") (`r(N)') (1)
		
		} // end recording odd cases
		
	}
	
}


*----------8.22: lstatus has no missing values for 15-65

local lstatus_vars "lstatus lstatus_year"
foreach var of local lstatus_vars {
	
	cap confirm variable `var' age
	* if var exists, else issue captured in 1.1
	if _rc == 0 { 
				
		qui : count if missing(`var') & inrange(age,15,65)
		if `r(N)' > 0 { // There are cases when with missing lstatus in age range
		
			post `memhold' ("8. Labour") ("`var'") ("`var' has missing values (number of cases ->)") (`r(N)') (1)
			
		} // end recording odd cases
	} // end vars exist
} // end varlist



*----------8.23: isic vars are in universe

cap confirm variable isic_version
if _rc == 0 { // if isic version info exists, otherwise cannot know which ISIC version to compare to

	foreach var of global isic_check {
		
		cap confirm variable `var'
		if _rc == 0 { // if var exists, else issue captured in 1.1
			
			* Create variable code out of var
			qui : gen code = `var'
			* Merge with ISIC universe, keeping only code variable from using, only match and master
			qui : merge m:1 code using `isic_universe', keepusing(code) keep(master match)
			* Count if there are variables that exist in survey that are not in ISIC universe
			qui : count if !missing(`var') & _merge == 1
			if `r(N)' > 0 {
				
				post `memhold' ("8. Labour") ("`var'") ("`var' has ISIC codes not in ISIC universe (number of cases ->)") (`r(N)') (1)
				
			} // close cases that are concerning
			
			* Clean up for next iteration (or exit)
			qui : drop code _merge
			
		} // close if var exists
	} // close foreach

} // close if isic_version present


*----------8.24: isco vars are in universe

cap confirm variable isco_version
if _rc == 0 { // if isic version info exists, otherwise cannot know which ISIC version to compare to

	foreach var of global isco_check {
		
		cap confirm variable `var'
		if _rc == 0 { // if var exists, else issue captured in 1.1
			
			* Create variable code out of var
			qui : gen code = `var'
			* Merge with ISIC universe, keeping only code variable from using, only match and master
			qui : merge m:1 code using `isco_universe', keepusing(code) keep(master match)
			* Count if there are variables that exist in survey that are not in ISIC universe
			qui : count if !missing(`var') & _merge == 1
			if `r(N)' > 0 {
				
				post `memhold' ("8. Labour") ("`var'") ("`var' has ISCO codes not in ISCO universe (number of cases ->)") (`r(N)') (1)
				
			} // close cases that are concerning
			
			* Clean up for next iteration (or exit)
			qui : drop code _merge
			
		} // close if var exists
	} // close foreach

} // close if isic_version present


*----------8.25: Check wage info has unit info
foreach token of global wage_and_unit{
	
	* Split the token into its elements
	tokenize "`token'"
	local wage "`1'"
	local unit "`2'"
	
	* Confirm if there is wage, that there is unit
	cap confirm variable `wage'
	if _rc == 0 { // wage info exists
	
		cap confirm variable `unit'
		if _rc != 0 { // unit does not exist
		
		post `memhold' ("8. Labour") ("`token'") ("There is `wage' info but no `unit' info") (.) (1)
		
		}
	
	}
	
	* Confirm if there is unit, that there is wage
	cap confirm variable `unit'
	if _rc == 0 { // unit info exists
	
		cap confirm variable `wage'
		if _rc != 0 { // wage does not exist
		
		post `memhold' ("8. Labour") ("`token'") ("There is `unit' info but no `wage' info") (.) (1)
		
		}
	
	}
	
}


*----------8.26: ISCO version info present if ISCO vars
local check_8_24 0
foreach var of global isco_check {	
	
	cap confirm variable `var'
	if _rc == 0 { // if var exists, else issue captured in 1.1
	
		* Given that isco info var exists, check that ISCO version exists
		cap confirm variable isco_version
		if _rc != 0 {
			
			local check_8_24 1
			
		} // close if isco_version not present
	} // close if var exists
} // for each loop
if `check_8_24' == 1 {
	
	post `memhold' ("8. Labour") ("ISCO Info") ("There is an ISCO variable present but isco_version info is missing") (.) (1)
	
}


*----------8.27: ISIC version info present if ISIC vars
local check_8_25 0
foreach var of global isic_check {	
	
	cap confirm variable `var'
	if _rc == 0 { // if var exists, else issue captured in 1.1
	
		* Given that isic info var exists, check that ISIC version exists
		cap confirm variable isic_version
		if _rc != 0 {
			
			local check_8_25 1
			
		} // close if isic_version not present
	} // close if var exists
} // for each loop
if `check_8_25' == 1 {
	
	post `memhold' ("8. Labour") ("ISIC Info") ("There is an ISIC variable present but isic_version info is missing") (.) (1)
	
}


/*==================================================
              9: End
==================================================*/

* Close postfile
postclose `memhold'

* Open postfile, amend for key variables
use "`postfile_path'", clear

* Replace info for vars that cannot be missing
replace Test_Type = "Attention -- Var missing which cannot be missing" if inlist(Var_Name, "countrycode", "survname", "survey", "year", "vermast", "veralt", "harmonization", "pid", "weight")

* Replace info for key vars that *should* not be missing
replace Test_Type = "Key variable is missing - ensure correctness" if inlist(Var_Name, "male", "lstatus", "empstat", "urban", "educat7", "educat5", "educat4", "industrycat4", "industrycat_isic") | inlist(Var_Name, "industrycat10 unitwage", "occup_isco", "occup_skill", "occup", "wage_no_compen", "whours")

* Sort relevant info to the top
gen ordering = (Test_Type == "Variable not in data")
sort ordering Block Test_Type
drop ordering


/*==================================================
          10: Order & Save data to summary 
==================================================*/

	use "${output}/${ccode3}_${cyear}_${mydate}/Block1_Format/${ccode3}_${cyear}_${csurvey}_Q_Format_Checks.dta", clear 
	
	** Sort resutls 
	gen varsorder = 1 
	replace varsorder = 99 if Test_Type == "Variable not in data"
	sort varsorder Test_Type
	drop varsorder
	
	save "${output}/${ccode3}_${cyear}_${mydate}/Block1_Format/${ccode3}_${cyear}_${csurvey}_Q_Format_Checks.dta", replace
	
	** Export summary
	use "${output}/${ccode3}_${cyear}_${mydate}/Block1_Format/${ccode3}_${cyear}_${csurvey}_Q_Format_Checks.dta", clear 
	export excel using "${output}/${ccode3}_${cyear}_${mydate}/01_summary/B1_format_results.xlsx", firstrow(variables) replace	

/* End of do-file */
