/*==================================================
project:       Perform Quality Checks for GLD
Author:        Mario Gronert 
E-email:       mgronert@worldbank.org
url:           
Dependencies:  
----------------------------------------------------
Creation Date:    26 Jan 2021
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

* Program to check hierarchy of administrative level info
capture program drop subnat_hierarchy
program subnat_hierarchy, rclass
syntax anything

	local counting: word count `anything'
	local var1 : word 1 of `anything'
	local var2  : word 2 of `anything'
	local var3  : word 3 of `anything'
	local check = 0
	qui: count 
	local tot_obs = r(N)
	
	if `counting' != 3 {
		dis as error "Function needs three level inputs from high to low: admin 1, 2, 3"
		exit
	}
	
	cap confirm variable `var3'
	if _rc == 0 { // level 3 exists
	
		qui : count if missing(`var3')
		if `r(N)' != `tot_obs' { // var3 exists and takes on actual values, var 2 needs values
		
			cap confirm variable `var2'
			if _rc != 0 local check = 1 // if var3 yes but var2 no -> error
			if _rc == 0 { // if var2 exists check it is not all missing
			
				qui : count if missing(`var2')
				if `r(N)' == `tot_obs' local check = 1 // if var3, var2 exists but all missing -> error
				
			} // end var2 exists
		} // end var 3 has values other than all missing
	} // end var3 exists
		
	cap confirm variable `var2'
	if _rc == 0 { // level 2 exists
	
		qui : count if missing(`var2')
		if `r(N)' != `tot_obs' { // var2 exists and takes on actual values, var 1 needs values
		
			cap confirm variable `var1'
			if _rc != 0 local check = 1 // if var2 yes but var1 no -> error
			if _rc == 0 { // if var1 exists check it is not all missing
			
				qui : count if missing(`var1')
				if `r(N)' == `tot_obs' local check = 1 // if var2, var1 exists but all missing -> error
				
			} // end var1 exists
		} // end var 2 has values other than all missing
	} // end var2 exists
	
	return scalar check = `check'
	
end

