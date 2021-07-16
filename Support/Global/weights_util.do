* weights_util.do
* a lightweight util designed to check weight variables on a preloaded dataset.

preserve

loc 	month = 1				// set to numerical 1-12 month


* Labor Force Participation
tab 	lstatus [aw=wgt] 		///
		if age 	 >= lb_mod_age 	///
		&  month == `month'

		
* Expanded Population
* Thank you Junying for this part!
gen 	count = 1
sum 	count [aw=wgt]
di 		"the expanded population for the year is ~ `r(sum)'"


* Weights+population by round 
bysort 	month: sum wgt 

foreach month in 1 4 7 10 {
	sum wgt if month == `month'
	di 		"In month `month' the expanded population is ~ `r(sum)'"
}


restore
