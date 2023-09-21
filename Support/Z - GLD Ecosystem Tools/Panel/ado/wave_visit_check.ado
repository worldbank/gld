capture program drop wave_visit_check

program define wave_visit_check, rclass
    version 16

    syntax [, hhid(varname) wave(varname) year(varname) visit_no(varname) correction]
	
	* If not specified, default to given variable names
    if "`hhid'" == "" local hhid hhid
    if "`year'" == "" local year year
    if "`wave'" == "" local wave wave
    if "`visit_no'" == "" local visit_no visit_no

	tempvar x v_w_match helper max_val visituser
	capture drop `visit_no'_corrected
	capture drop vw_tag
	
	
    qui bys `hhid' `year' `wave' `visit_no': gen `x' = _n == 1
    qui bys `hhid' `year' `wave': egen `v_w_match' = sum(`x')

    qui gen vw_tag = "CHECK" if `v_w_match' > 1

    if "`correction'" == "correction" {
        qui bys `hhid' `year' `wave' `visit_no': gen `helper' = _N
        qui replace `helper' = . if vw_tag!="CHECK"
        qui bys `hhid' `year' `wave' vw_tag: egen `max_val' = max(`helper')
        qui gen `visituser' = `visit_no' if `max_val' == `helper' & !missing(`helper')
        qui bys `hhid' `year' `wave' vw_tag: egen `visit_no'_corrected = max(`visituser')
		label var visit_no_corrected "Corrected visit number"
    }

    qui count if vw_tag == "CHECK"
    if r(N) == 0 {
        display "Wave information is uniquely assigned to a visit number"
    }
    else {
        display as error "Wave information is NOT uniquely assigned to a visit number. Caution when using visit number to create panel variable!"
        display as error "Total cases = `r(N)''"
    }
end

