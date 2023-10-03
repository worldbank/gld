* Begin with the version
version 16

* Define the command
capture program drop gldpanel_age_histo

program gldpanel_age_histo, rclass
    syntax [, hhid(varname) pid(varname) year(varname) age(varname) wave(varname)]

    * If not specified, default to given variable names
    if "`hhid'" == "" local hhid hhid
    if "`pid'" == "" local pid pid
    if "`year'" == "" local year year
    if "`age'" == "" local age age
    if "`wave'" == "" local wave wave

    tempvar earliest_year agetag first_wave_year minage age_d diff_age actual_diff odd_diff id_odd_diff
    tempvar id_diff_age agetag_year minage_year age_d_year diff_age_year id_diff_age_year

    * Check for odd repetitions (e.g., an ID from 2009 is reused in 2015)
    quietly {
        bys `hhid' `pid' : egen `earliest_year' = min(`year')
        bys `hhid' `pid' `year': gen `first_wave_year' = `wave' if _n == 1
	
        gen `actual_diff' = `year' - `earliest_year'
        gen `odd_diff' = `actual_diff' > 1
        bys `hhid' `pid': egen `id_odd_diff' = max(`odd_diff')

        gen `agetag' = `age' if `year' == `earliest_year' & `wave' == `first_wave_year'
        bys `hhid' `pid': egen `minage' = min(`agetag')
        gen `age_d' = `age' - `minage'
        gen `diff_age' = !(inlist(`age_d', 0, 1))
        bys `hhid' `pid': egen `id_diff_age' = max(`diff_age')

        bys `hhid' `pid' `year': gen `agetag_year' = `age' if `wave' == `first_wave_year'
        bys `hhid' `pid' `year': egen `minage_year' = min(`agetag_year')
        gen `age_d_year' = `age' - `minage_year'
        gen `diff_age_year' = !(inlist(`age_d_year', 0, 1))
        bys `hhid' `pid': egen `id_diff_age_year' = max(`diff_age_year')

        label var `age_d_year' "Age difference within year"
        label var `age_d' "Age difference across years"
    }

    * Create a histogram to show distribution of age difference
    histogram `age_d' if !inlist(`age_d', 0, 1) & inrange(`age_d', -40, 40) & `id_odd_diff'!=1, discrete fraction graphregion(color(white)) 
    
end
