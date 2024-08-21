
* Start program
program define gld_help_thresh, rclass

	* Define version, syntax
    version 18.0
    syntax [, THREshold(real 75) WORKer(string) YEAR]

	* Do everything quietly as we want this to happen in the background
	quietly {
		
		* If year empty --> 7D
		if "`year'" == "" {
			
			* Generate variables that we need for check: if employed, if employee, if those and wage info
			gen l1  = lstatus == 1 & age > 14
			gen e1  = empstat == 1 & age > 14
			gen wg  = !mi(wage_no_compen) & !mi(unitwage) & !mi(whours)
			gen wl1 = wg == 1 & l1 == 1
			gen we1 = wg == 1 & e1 == 1
			
			* Collapse by country, year to obtain scores
			collapse (sum) l1 e1 wl1 we1, by(countrycode year)
			
			* Depending on whether we are using all workers or wage workers, create threshold
			if "`worker'" == "waged" gen threshold = (we1/e1)*100
			if "`worker'" == "all"   gen threshold = (wl1/l1)*100
			label variable threshold "Share of workers with wage information - 7D"
			
			* Keep only relevant info
			keep countrycode year threshold
			
		} // Close 7 Day check
		
		* If year present --> 12M
		if "`year'" != "" {
			
			* Generate variables that we need for check: if employed, if employee, if those and wage info
			gen l1  = lstatus_year == 1 & age > 14
			gen e1  = empstat_year == 1 & age > 14
			gen wg  = !mi(wage_no_compen_year) & !mi(unitwage_year) & !mi(whours_year)
			gen wl1 = wg == 1 & l1 == 1
			gen we1 = wg == 1 & e1 == 1
			
			* Collapse by country, year to obtain scores
			collapse (sum) l1 e1 wl1 we1, by(countrycode year)
			
			* Depending on whether we are using all workers or wage workers, create threshold
			if "`worker'" == "waged" gen threshold_year = (we1/e1)*100
			if "`worker'" == "all"   gen threshold_year = (wl1/l1)*100
			label variable threshold_year "Share of workers with wage information - 12M"
			
			* Keep only relevant info
			keep countrycode year threshold_year
						
		} // Close 12 Month check
		
	} // End quietly
	
end
