* weights_util.do
* a lightweight util designed to check weight variables on a preloaded dataset.
cls
preserve

loc 	month = 1				// set to numerical 1-12 month

*__________________ By wave ____ _____ _____ __ __ _

* Generate by-round weight variable 
gen 	wgt_rnd = wgt*4 		// only for in-round population
gen 	count = 1


* Weights by round
bysort 	month: sum wgt 

* Labor Force Partic + Population by Round 
foreach month in 1 4 7 10 {
di "For the `month' month"
* Labor Force Participation
tab 	lstatus [aw=wgt_] 		///
		if age 	 >= lb_mod_age 	///
		&  month == `month'

* Total Population 
sum 	count [aw=wgt_rnd] 	if month == `month'
svyset 	_n [pw=wgt_rnd] 
svy: 	total count 		if month == `month'	

* Working age Population 
sum 	count [aw=wgt_rnd] 	if month == `month' ///
							& age >= lb_mod_age
svyset 	_n [pw=wgt_rnd] 
svy: 	total count 		if month == `month'	///
							& age >= lb_mod_age

}


*__________________ Full Year ____ _____ _____ __ __ _
* Total working Population
** Using Junying's method 
sum 	count [aw=wgt]
di 		"the expanded population for the year is ~ `r(sum)'"


** Using Angelo's method 
svyset _n [pw=wgt] 
svy: total count 


** Working Age population
svyset _n [pw=wgt] 
svy: total count if age >= lb_mod_age


* Labor Force Participation 
tab 	lstatus [aw=wgt] 		///
		if age 	 >= lb_mod_age 	

restore

