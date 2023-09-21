capture program drop create_panel_var

program create_panel_var
	syntax [, HHID]
	
    capture drop first_year 
    capture drop first_wave 
	capture drop earliest_year
	capture drop actual_diff 
	capture drop odd_diff 
	capture drop id_odd_diff
	
* This code should run if the variable "panel" does not exist

capture confirm variable panel
if _rc {
	dis "data does not have panel variable"
	
	capture confirm variable visit_no
	if _rc {
	dis "data does not have visit number"
	
	* Check for required variables before proceeding
		local vars "year wave hhid pid"
		foreach var of local vars {
			capture confirm variable `var'
			if _rc {
				di as error "Error: Variable `var' is not in the data. Please ensure that the variable is present!"
				exit 198
			}
		}


		dis "",  _newline(3)
		dis as result `" The panel variable is now being created"'
		display "* Initializing.....",
		display "***" _continue
		* Order the dataset by hhid, pid, year and wave
		quietly sort hhid pid year wave
		display "***" _continue

		* Check unique waves
		quietly levelsof wave, local(waves)
		quietly local n : word count `waves'
		display "***" _continue

		* Store the first instance of year and wave for each individual
		quietly sort hhid year wave
		display "***" _continue
		quietly by hhid: gen first_year = year if _n == 1
		display "***" _continue
		quietly by hhid: gen first_wave = wave if _n == 1
		display "***" _continue

		* Fill the missing cases by the last non-missing answer
		quietly replace first_year = first_year[_n-1] if missing(first_year)
		  display "***" _continue

		quietly replace first_wave = first_wave[_n-1] if missing(first_wave)
		display "***" _continue

		* Concatenate the values to create the panel variable
		quietly egen panel = concat(first_year first_wave), punct(-)
		display "***", _newline
		display "Panel variable created"
		
		
		* Next generate a variable for visit number
		
	}
	
	else {
	
	if countrycode == "IND" {
		dis as result `" The panel variable is now being created for India"'
		display "* Initializing.....",
		qui sum year
		local minyear = r(min)
		
		qui destring visit_no, ignore("V") replace
		qui destring wave, ignore("Q") replace
		
		tempvar quarter_monotonic
		gen `quarter_monotonic' = wave + 8 * floor((year - `minyear') / 2)

		tempvar tens ones
		gen `tens' = 1 + floor((`quarter_monotonic' - visit_no) / 8)
		gen `ones' = 1 + mod(`quarter_monotonic' - visit_no, 8)
		gen panel_num = `tens' * 10 + `ones'
		tostring panel_num, gen(panel)
		
		* Deviate from Nils, instead adopt panel nomenclature used in the report (which starts with P)
		replace panel = "P" + panel
		}
	
	else {
		sort  hhid pid year wave 
		qui destring visit_no, ignore("V") replace
		quietly egen panel = concat(year wave) if visit_no == 1, punct(-)
		quietly replace panel = panel[_n-1] if missing(panel)

	}
		
	}
}

    if "`hhid'" == "hhid" {
        capture drop hhid_panel
        gen hhid_panel = hhid + panel
		replace hhid = hhid_panel
    }
	
else {
	
	display "Panel variable already exists"
	
}

    * Display unique panels and tabulate year and wave for each panel
    quietly levelsof panel, local(panels)
    foreach panel of local panels {
        display "* Displaying panel: `panel'",
        dis "This is panel: `panel'"
        tab year wave if panel == "`panel'"
    }

	
	* Check that there are no odd repetitions (i.e., an ID from 2009 is re-use in 2015)
	quietly{
	bys hhid : egen earliest_year = min(year)
	gen actual_diff = year - earliest_year
	gen odd_diff = actual_diff > 1
	bys hhid : egen id_odd_diff = max(odd_diff)
	capture label define lbl_id_odd_diff 0 "Consecutive" 1 "Non-consecutive years"
	label values id_odd_diff lbl_id_odd_diff
	}
	

* If there are odd cases, tell user
quietly : count if id_odd_diff == 1
* If r(N) > 1 there are cases
if `r(N)' > 0 {
    dis "There are cases in the data were the same PID is present in non-subsequent years." as error
	dis "For a rotating QLFS no person is in more than 4 quarters so they can be at most" as error
	dis "in year t and t+1. However, we have cases in t and t+x where x > 1." as error
	dis "These cases can be identified by having variable odd_diff == 1." as error
	dis "Please inspect before proceeding." as error
	dis "See breakdown below by panel:" as error

	tab panel id_odd_diff
}

else{

quietly drop earliest_year actual_diff odd_diff id_odd_diff

}

end
