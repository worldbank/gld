* weights_util.do
* a lightweight util designed to check weight variables on a preloaded dataset.

preserve

loc 	month = 4				// set to numerical 1-12 month

tab 	lstatus [aw=wgt] 		///
		if age >= lb_mod_age 	///
		&  month == `month'

* Thank you Junying for this part!
gen 	count = 1
sum 	count [aw=wgt]
di 		"the expanded population is ~ `r(sum)'"

restore
