capture program drop gldpanel_id_check

program gldpanel_id_check
	
    capture drop first_year 
    capture drop first_wave 
	capture drop earliest_year
	capture drop actual_diff 
	capture drop odd_diff 
	capture drop id_odd_diff
	capture drop dup
	
	syntax [, hhid(varname) pid(varname) wave(varname) year(varname)]

	
		* If not specified, default to given variable names
    if "`hhid'" == "" local hhid hhid
	if "`pid'" == "" local pid pid
    if "`year'" == "" local year year
    if "`wave'" == "" local wave wave
	
	
		* Store the first instance of `year' and `wave' for each individual
		quietly sort `hhid' `year' `wave'
		quietly by `hhid': gen first_year = `year' if _n == 1
		quietly by `hhid': gen first_wave = `wave' if _n == 1

		* Fill the missing cases by the last non-missing answer
		quietly replace first_year = first_year[_n-1] if missing(first_year)

		quietly replace first_wave = first_wave[_n-1] if missing(first_wave)


		
		

	* Check that there are no odd repetitions (i.e., an ID from 2009 is re-use in 2015)
	quietly{
	bys `hhid' : egen earliest_year = min(`year')
	gen actual_diff = `year' - earliest_year
	gen odd_diff = actual_diff > 1
	bys `hhid' : egen id_odd_diff = max(odd_diff)
	capture label define lbl_id_odd_diff 0 "Consecutive" 1 "Non-consecutive `year's"
	label values id_odd_diff lbl_id_odd_diff
	}
	

* If there are odd cases, tell user
quietly : count if id_odd_diff == 1
* If r(N) > 1 there are cases
if `r(N)' > 0 {
    dis as error "There are cases in the data were the same PID is present in non-subsequent `year's." 
	dis as error "For a rotating QLFS no person is in more than 4 quarters so they can be at most" 
	dis as error "in `year' t and t+1. However, we have cases in t and t+x where x > 1." 
	dis as error "These cases can be identified by having variable odd_diff == 1." 
	dis as error "Please inspect before proceeding." 
	dis as error "See breakdown below by `year':" 

	tab `year' id_odd_diff

	
}

qui duplicates tag `pid' `year' `wave', gen(dup)
quietly : count if dup != 0
if `r(N)' > 0 {
	
	label var dup "Non-unique HHID within `year'"
	capture label define duplab 0 "Non-issue" 1 "Issue"
	label values dup duplab
	
	dis as error "There is re-use of the same PID within `year' across `wave's! See below:" 

	tab `year' dup
	

}


else{

quietly drop earliest_year actual_diff odd_diff id_odd_diff dup

}

end
