capture program drop range_wrap

program range_wrap, rclass
syntax anything [, Missing]
	local counting: word count `anything'
	local varName : word 1 of `anything'
	local lowLim  : word 2 of `anything'
	local uppLim  : word 3 of `anything'
	qui: count 
	local tot_obs = r(N)
	
	if `counting' != 3 {
		dis as error "Function needs three inputs for -inrange-: var + 2 values"
		exit
	}
	
	if missing(`"`missing'"'){
		local f_call = "cap count if inrange(" + "`varName'" + "," + "`lowLim'" + "," + "`uppLim'" + ")"
	}
	else {
		local f_call = "cap count if inrange(" + "`varName'" + "," + "`lowLim'" + "," + "`uppLim'" + ") | missing(" + "`varName'" + ")"
	}
	
	`f_call'
	* if variable does not exist
	if _rc == 111 {
		local ratio = .
	}
	* if exists 
	else {
		local ratio = (`tot_obs' - r(N)) / `tot_obs'
	}
	return scalar ratio = `ratio'

end

