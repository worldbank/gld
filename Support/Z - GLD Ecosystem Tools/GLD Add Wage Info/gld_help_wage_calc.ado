
* Start program
program define gld_help_wage_calc, rclass

* LOGIC: This code does the coding of the wage. We have three options, both can be present or not
*        thus we have 2^3 options (8). We differentiate year vs week (y/w), hourly vs month (h/m),
*        and wage worker vs all (w/a). It can be thus:
*			% Option W-M-W: 7 day recall / monthly wage / wage workers
*			% Option W-M-A: 7 day recall / monthly wage / wage workers
*			% Option W-H-W: 7 day recall / monthly wage / wage workers
*			% Option W-H-A: 7 day recall / monthly wage / wage workers
*			% Option Y-M-W: 7 day recall / monthly wage / wage workers
*			% Option Y-M-A: 7 day recall / monthly wage / wage workers
*			% Option Y-H-W: 7 day recall / monthly wage / wage workers
*			% Option Y-H-A: 7 day recall / monthly wage / wage workers

	* Define version, syntax
    version 18.0
    syntax [, YEAR HOUR ALL]

	* Do everything quietly as we want this to happen in the background
	quietly {
		
		* If year empty --> 7D
		if "`year'" == "" {
			
			* If hour empty --> Monthly
			if "`hour'" == "" {
				
				* If all empty --> Wage workers
				if "`all'" == "" {
					
					* Option W-M-W
					gen month_wage = .
					replace month_wage = wage_no_compen*4.333 if unitwage == 2 // (weekly)
					replace month_wage = wage_no_compen*2.167 if unitwage == 3 // (every two weeks)
					replace month_wage = wage_no_compen*2     if unitwage == 4 // (bi-monthly)
					replace month_wage = wage_no_compen	      if unitwage == 5 // (monthly)
					replace month_wage = wage_no_compen/3     if unitwage == 6 // (Trimester)
					replace month_wage = wage_no_compen/6     if unitwage == 7 // (Biannual)
					replace month_wage = wage_no_compen/12    if unitwage == 8 // (Annual)
					
					* Hourly we multiply by the weekly hours, then 4.333 to take the week to month
					replace month_wage = wage_no_compen*whours*4.333 if unitwage == 9 // (Hourly wage)
					
					* Daily, we assume 5 days of labour. Not because of a strict weokweek but that too,
					* moslty the idea of daily workers potentially not being able to obtain work every day
					replace month_wage = wage_no_compen*5*4.33 if unitwage == 1 // (daily)
					
					replace month_wage = . if empstat != 1 // Clean up 
					label variable month_wage "Employee monthly wage - 7D"
					
				} // Close wage workers
								
				* If all present --> All workers
				if "`all'" != "" {
					
					* Option W-M-A
					gen month_wage = .
					replace month_wage = wage_no_compen*4.333 if unitwage == 2 // (weekly)
					replace month_wage = wage_no_compen*2.167 if unitwage == 3 // (every two weeks)
					replace month_wage = wage_no_compen*2     if unitwage == 4 // (bi-monthly)
					replace month_wage = wage_no_compen	      if unitwage == 5 // (monthly)
					replace month_wage = wage_no_compen/3     if unitwage == 6 // (Trimester)
					replace month_wage = wage_no_compen/6     if unitwage == 7 // (Biannual)
					replace month_wage = wage_no_compen/12    if unitwage == 8 // (Annual)
					
					* Hourly we multiply by the weekly hours, then 4.333 to take the week to month
					replace month_wage = wage_no_compen*whours*4.333 if unitwage == 9 // (Hourly wage)
					
					* Daily, we assume 5 days of labour. Not because of a strict weokweek but that too,
					* moslty the idea of daily workers potentially not being able to obtain work every day
					replace month_wage = wage_no_compen*5*4.33 if unitwage == 1 // (daily)
					
					replace month_wage = . if lstatus != 1 // Clean up 
					label variable month_wage "Employed monthly wage - 7D"
					
				} // Close all workers
				
			} // Close monthly
			
			* If hour present --> Hourly
			if "`hour'" != "" {
				
				* If all empty --> Wage workers
				if "`all'" == "" {
					
					* Option W-H-W
					gen helper_wkwg = .
					replace helper_wkwg = wage_no_compen*7    if unitwage == 1 // (daily)
					replace helper_wkwg = wage_no_compen      if unitwage == 2 // (weekly)
					replace helper_wkwg = wage_no_compen/2    if unitwage == 3 // (every two weeks)
					replace helper_wkwg = wage_no_compen/2.17 if unitwage == 4 // (bi-monthly)
					replace helper_wkwg = wage_no_compen/4.33 if unitwage == 5 // (monthly)
					replace helper_wkwg = wage_no_compen/13   if unitwage == 6 // (Trimester)
					replace helper_wkwg = wage_no_compen/26   if unitwage == 7 // (Biannual)
					replace helper_wkwg = wage_no_compen/52   if unitwage == 8 // (Annual)
					
					gen hour_wage = helper_wkwg / whours  // hourly wage
					replace hour_wage = wage_no_compen if unitwage == 9 // (Hourly wage)
					replace hour_wage = . if empstat != 1 // Clean up if centred on employees
					label variable hour_wage "Employee hourly wage - 7D"
					drop helper_wkwg
					
				} // Close wage workers
								
				* If all present --> All workers
				if "`all'" != "" {
					
					* Option W-H-A
					gen helper_wkwg =.
					replace helper_wkwg = wage_no_compen*7    if unitwage == 1 // (daily)
					replace helper_wkwg = wage_no_compen      if unitwage == 2 // (weekly)
					replace helper_wkwg = wage_no_compen/2    if unitwage == 3 // (every two weeks)
					replace helper_wkwg = wage_no_compen/2.17 if unitwage == 4 // (bi-monthly)
					replace helper_wkwg = wage_no_compen/4.33 if unitwage == 5 // (monthly)
					replace helper_wkwg = wage_no_compen/13   if unitwage == 6 // (Trimester)
					replace helper_wkwg = wage_no_compen/26   if unitwage == 7 // (Biannual)
					replace helper_wkwg = wage_no_compen/52   if unitwage == 8 // (Annual)
					
					gen hour_wage = helper_wkwg / whours  // hourly wage
					replace hour_wage = wage_no_compen if unitwage == 9 // (Hourly wage)
					replace hour_wage = . if lstatus != 1 // Clean up if centred on employees
					label variable hour_wage "Employed hourly wage - 7D"
					drop helper_wkwg
					
				} // Close all workers
				
			} // Close hourly
			
		} // Close calculate for 7 day period
		
		* If year present --> 12M
		if "`year'" != "" {
			
			* If hour empty --> Monthly
			if "`hour'" == "" {
				
				* If all empty --> Wage workers
				if "`all'" == "" {
					
					* Option Y-M-W
					gen month_wage_year = .
					replace month_wage_year = wage_no_compen_year*4.333 if unitwage_year == 2 // (weekly)
					replace month_wage_year = wage_no_compen_year*2.167 if unitwage_year == 3 // (every two weeks)
					replace month_wage_year = wage_no_compen_year*2     if unitwage_year == 4 // (bi-monthly)
					replace month_wage_year = wage_no_compen_year	      if unitwage_year == 5 // (monthly)
					replace month_wage_year = wage_no_compen_year/3     if unitwage_year == 6 // (Trimester)
					replace month_wage_year = wage_no_compen_year/6     if unitwage_year == 7 // (Biannual)
					replace month_wage_year = wage_no_compen_year/12    if unitwage_year == 8 // (Annual)
					
					* Hourly we multiply by the weekly hours, then 4.333 to take the week to month
					replace month_wage_year = wage_no_compen_year*whours_year*4.333 if unitwage_year == 9 // (Hourly wage)
					
					* Daily, we assume 5 days of labour. Not because of a strict weokweek but that too,
					* moslty the idea of daily workers potentially not being able to obtain work every day
					replace month_wage_year = wage_no_compen_year*5*4.33 if unitwage_year == 1 // (daily)
					
					replace month_wage_year = . if empstat_year != 1 // Clean up 
					label variable month_wage_year "Employee monthly wage - 12M"
					
				} // Close wage workers
								
				* If all present --> All workers
				if "`all'" != "" {
					
					* Option Y-M-A
					gen month_wage_year = .
					replace month_wage_year = wage_no_compen_year*4.333 if unitwage_year == 2 // (weekly)
					replace month_wage_year = wage_no_compen_year*2.167 if unitwage_year == 3 // (every two weeks)
					replace month_wage_year = wage_no_compen_year*2     if unitwage_year == 4 // (bi-monthly)
					replace month_wage_year = wage_no_compen_year	      if unitwage_year == 5 // (monthly)
					replace month_wage_year = wage_no_compen_year/3     if unitwage_year == 6 // (Trimester)
					replace month_wage_year = wage_no_compen_year/6     if unitwage_year == 7 // (Biannual)
					replace month_wage_year = wage_no_compen_year/12    if unitwage_year == 8 // (Annual)
					
					* Hourly we multiply by the weekly hours, then 4.333 to take the week to month
					replace month_wage_year = wage_no_compen_year*whours_year*4.333 if unitwage_year == 9 // (Hourly wage)
					
					* Daily, we assume 5 days of labour. Not because of a strict weokweek but that too,
					* moslty the idea of daily workers potentially not being able to obtain work every day
					replace month_wage_year = wage_no_compen_year*5*4.33 if unitwage_year == 1 // (daily)
					
					replace month_wage_year = . if lstatus_year != 1 // Clean up 
					label variable month_wage_year "Employed monthly wage - 12M"
					
				} // Close all workers
				
			} // Close monthly
			
			* If hour present --> Hourly
			if "`hour'" != "" {
				
				* If all empty --> Wage workers
				if "`all'" == "" {
					
					* Option Y-H-W
					gen helper_wkwg =.
					replace helper_wkwg = wage_no_compen_year*7    if unitwage_year == 1 // (daily)
					replace helper_wkwg = wage_no_compen_year      if unitwage_year == 2 // (weekly)
					replace helper_wkwg = wage_no_compen_year/2    if unitwage_year == 3 // (every two weeks)
					replace helper_wkwg = wage_no_compen_year/2.17 if unitwage_year == 4 // (bi-monthly)
					replace helper_wkwg = wage_no_compen_year/4.33 if unitwage_year == 5 // (monthly)
					replace helper_wkwg = wage_no_compen_year/13   if unitwage_year == 6 // (Trimester)
					replace helper_wkwg = wage_no_compen_year/26   if unitwage_year == 7 // (Biannual)
					replace helper_wkwg = wage_no_compen_year/52   if unitwage_year == 8 // (Annual)
					
					gen hour_wage_year     = helper_wkwg / whours_year  // hourly wage
					replace hour_wage_year = wage_no_compen_year if unitwage_year == 9 // (Hourly wage)
					replace hour_wage_year = . if empstat_year != 1 // Clean up if centred on employees
					label variable hour_wage_year "Employee hourly wage - 12M"
					drop helper_wkwg
					
				} // Close wage workers
								
				* If all present --> All workers
				if "`all'" != "" {
					
					* Option Y-H-A
					gen helper_wkwg =.
					replace helper_wkwg = wage_no_compen_year*7    if unitwage_year == 1 // (daily)
					replace helper_wkwg = wage_no_compen_year      if unitwage_year == 2 // (weekly)
					replace helper_wkwg = wage_no_compen_year/2    if unitwage_year == 3 // (every two weeks)
					replace helper_wkwg = wage_no_compen_year/2.17 if unitwage_year == 4 // (bi-monthly)
					replace helper_wkwg = wage_no_compen_year/4.33 if unitwage_year == 5 // (monthly)
					replace helper_wkwg = wage_no_compen_year/13   if unitwage_year == 6 // (Trimester)
					replace helper_wkwg = wage_no_compen_year/26   if unitwage_year == 7 // (Biannual)
					replace helper_wkwg = wage_no_compen_year/52   if unitwage_year == 8 // (Annual)
					
					gen hour_wage_year     = helper_wkwg / whours_year  // hourly wage
					replace hour_wage_year = wage_no_compen_year if unitwage_year == 9 // (Hourly wage)
					replace hour_wage_year = . if lstatus_year != 1 // Clean up if centred on employees
					label variable hour_wage_year "Employed hourly wage - 12M"
					drop helper_wkwg
					
				} // Close all workers
				
			} // Close hourly
						
		} // Close calculate for 12 month period
		
	} // End quietly
	
end
