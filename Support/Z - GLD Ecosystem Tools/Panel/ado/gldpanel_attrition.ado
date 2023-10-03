capture program drop gldpanel_attrition

program define gldpanel_attrition, rclass
    version 16

    syntax [, hhid(varname) pid(varname) wave(varname) year(varname) visit_no(varname) sex(varname) age(varname) consecutive_waves any_wave all_waves]
	
	* If not specified, default to given variable names
    if "`hhid'" == "" local hhid hhid
	if "`pid'" == "" local pid pid
    if "`year'" == "" local year year
    if "`wave'" == "" local wave wave
    if "`visit_no'" == "" local visit_no visit_no
    if "`sex'" == "" local sex male
    if "`age'" == "" local age age


* Create important variables
tempvar appearances appearance_1 appearance_1_3 visit_1_3 visit_2_4 attrition_rate attrition_rate_matches total first_wave_year earliest_year agetag minage age_d diff_age id_diff_age diff_sex id_diff_sex age_d diff_age_wave diff_sex_wave age_discrepancy_tag sex_discrepancy_tag appearance_1_max appearance_1_3_max

qui bys `pid': gen `appearances' = _N
qui gen `appearance_1' = `appearances' == 1
qui gen `appearance_1_3' = inrange(`appearances', 1, 3)
qui gen `total' = 1

* Check if odd_diff is zero, but people have different characteristics
qui bys `hhid' `pid': egen `diff_sex' = sd(`sex')
qui replace `diff_sex' = (`diff_sex' > 0 & !missing(`diff_sex'))
qui bys `hhid' `pid': egen `id_diff_sex' = max(`diff_sex')

qui bys `hhid' `pid': egen `earliest_year' = min(`year')
qui bys `hhid' `pid' `year': gen `first_wave_year' = `wave' if _n == 1
qui replace `first_wave_year' = `first_wave_year'[_n-1] if missing(`first_wave_year')
	
qui gen `agetag' = `age' if `year' == `earliest_year' & `wave' == `first_wave_year'
qui bys `hhid' `pid': egen `minage' = min(`agetag')

qui gen `age_d' = `age' - `minage'
qui gen `diff_age' = !(inlist(`age_d', 0, 1))
bys `hhid' `pid': egen `id_diff_age' = max(`diff_age')

* Calculate Inter-wave Differences
    sort `hhid' `pid' `year' `wave'
    qui by `hhid' `pid': gen `diff_age_wave' = `age' - `age'[_n-1]
    qui by `hhid' `pid': gen `diff_sex_wave' = (`sex' != `sex'[_n-1])

    * Tag Discrepant Records
    qui gen `age_discrepancy_tag' = (abs(`diff_age_wave') > 1 & _n > 1)
    qui gen `sex_discrepancy_tag' = (`diff_sex_wave' & _n > 1)


* Check if none of the options were specified
    if "`consecutive_waves'" == "" & "`any_wave'" == "" & "`all_waves'" == "" {
        di as error "Program is required to add a feature, choose among 'consecutive_waves', 'any_wave', or 'all_waves'"
        exit
    }

	
if "`consecutive_waves'" == "consecutive_waves" {

preserve

* Original attrition rate
sort `pid' `visit_no'
qui bys `pid': gen `visit_1_3' = 1 if inrange(`visit_no', 1, 3) 
qui bys `pid': gen `visit_2_4' = 1 if inrange(`visit_no', 2, 4) & `visit_no'[_n-1] == `visit_no' - 1
sort `year' `wave'
collapse (sum) `visit_1_3' `visit_2_4', by(`year' `wave')

qui gen `attrition_rate' = (`visit_1_3'[_n-1] - `visit_2_4')/(`visit_1_3'[_n-1])*100
* Negative values because possible increase in individuals in HHs

tempfile a1
qui save `a1'

restore

preserve

* Alternative attrition rate

sort `pid' `visit_no'
qui bys `pid': gen `visit_1_3' = 1 if inrange(`visit_no', 1, 3) 
by `pid': gen `visit_2_4' = 1 if inrange(`visit_no', 2, 4) & `visit_no'[_n-1] == `visit_no' - 1 & `age_discrepancy_tag' == 0 & `sex_discrepancy_tag' == 0
sort `year' `wave'
collapse (sum) `visit_1_3' `visit_2_4', by(`year' `wave')

qui gen `attrition_rate_matches' = (`visit_1_3'[_n-1] - `visit_2_4')/(`visit_1_3'[_n-1])*100

keep `year' `wave' `attrition_rate_matches'
qui merge 1:1 `year' `wave' using `a1'


graph bar (sum) `attrition_rate' `attrition_rate_matches', over(`wave') over(`year') ///
 title("Attrition between waves") subtitle("") graphregion(color(white)) ylabel(, nogrid) ytitle("% attrition relative to previous wave") legend( label (1 "Full data") label (2 "Age and sex matches only"))
 
restore


}

if "`any_wave'" == "any_wave" {

* Original attrition
preserve

qui keep if `visit_no' == 1

sort `year' `wave'
collapse (sum) `appearance_1' `total', by(`year' `wave')
qui gen `attrition_rate' = (`appearance_1'/`total')*100
qui replace `attrition_rate' = . if `attrition_rate' == 100

tempfile a2
qui save `a2'

restore

* Alternative attrition_rate
preserve
replace `appearance_1' = 1 if inrange(`visit_no', 2, 4) & `age_discrepancy_tag' == 1 & `sex_discrepancy_tag' == 1
qui bys `pid': egen `appearance_1_max' = max(`appearance_1')

qui keep if `visit_no' == 1

sort `year' `wave'
collapse (sum) `appearance_1_max' `total', by(`year' `wave')

qui gen `attrition_rate_matches' = (`appearance_1_max'/`total')*100
list
qui replace `attrition_rate_matches' = . if `attrition_rate_matches' == 100

keep `year' `wave' `attrition_rate_matches'
qui merge 1:1 `year' `wave' using `a2'


graph bar (sum) `attrition_rate' `attrition_rate_matches', over(`wave') over(`year') ///
 title("Attrition rate: any subsequent wave") subtitle("") graphregion(color(white)) ylabel(, nogrid) ytitle("% attrition relative to first appearance") legend( label (1 "Full data") label (2 "Age and sex matches only"))
 
restore

}

if "`all_waves'" == "all_waves" {

* Calculate attrition across `wave's (only 4 appearances)

* Original attrition
preserve
qui keep if `visit_no' == 1

sort `year' `wave'
collapse (sum) `appearance_1_3' `total', by(`year' `wave')
qui gen `attrition_rate' = (`appearance_1_3'/`total')*100
qui replace `attrition_rate' = . if `attrition_rate' == 100

tempfile a3
qui save `a3'
restore

* Alternative attrition
preserve 

qui replace `appearance_1_3' = 1 if inrange(`visit_no', 2, 4) & `age_discrepancy_tag' == 1 & `sex_discrepancy_tag' == 1
qui bys `pid': egen `appearance_1_3_max' = max(`appearance_1_3')

qui keep if `visit_no' == 1

sort `year' `wave'
collapse (sum) `appearance_1_3_max' `total', by(`year' `wave')
 
qui gen `attrition_rate_matches' = (`appearance_1_3_max'/`total')*100
qui replace `attrition_rate_matches' = . if `attrition_rate_matches' == 100

qui keep `year' `wave' `attrition_rate_matches'
qui merge 1:1 `year' `wave' using `a3'

graph bar (sum) `attrition_rate' `attrition_rate_matches', over(`wave') over(`year') ///
 title("Attrition rate: all subsequent waves") subtitle("") graphregion(color(white)) ylabel(, nogrid) ytitle("% attrition relative to first appearance") legend( label (1 "Full data") label (2 "Age and sex matches only"))
 
 restore
}


end