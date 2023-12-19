# Introduction
Since the passing of the [resolution concerning statistics of work, employment and labour underutilization](https://www.ilo.org/global/statistics-and-databases/standards-and-guidelines/resolutions-adopted-by-international-conferences-of-labour-statisticians/WCMS_230304/lang--en/index.htm) in 2013 at the 19th International Conference of Labour Statisticians (ICLS) surveys are at risk of a series break due to the change in the concept of employment.

In short, the ICLS 19 resolution restricts employment to *work performed for others in exchange for pay or profit*, meaning that own consumption work (e.g., subsistence agriculture or building housing for oneself) are not counted as employment.

The GLD codes the harmonization’s `lstatus’ variable based on the concept used in the survey. In the case of the Tanzanian LFS this change occurs in 2020/21, when the survey switches to new definition. As a result, [time series data](Utilities/01_A_1_LFP_over_years.png) show a decrease in the size of employed and labor force participants for the 2020-21 round. However, the code can be altered to try to match the previous definition.

# Framework for identifying the employed in the 2020 ILFS

The information on current activity were used to define the employed using Questions 13A - 13N in the questionnaire. The general flow of question involves first asking the individual if he/she engaged in an economic activity, agriculture or non-agriculture, in the past 7 days, and if the individual reports otherwise, he/she would be asked about information regarding temporary absence from employment. 


# Current coding for the 2020 ILFS

Currently, the code used to create the `lstatus` variable (which distinguishes between employment, unemployment, and out of the labour force) is the following:

```
  ***************************
  * Create Variable
  ***************************
	gen byte lstatus = .
  
  
  ***************************
  * Define those employed
  ***************************
  
    * Define the employment options from the questionnaire flow. Q13D asks for nay production form. If yes (range 1-7), asks for 
	* degree of market exchange (if 50%+, straight to labour), if not joins Q13D == 8 in Q13F, G, and H for employment options.
	* F, G, and H are flow outs, that is, if F is yes, striaght to labour, only if no goes to G, same relationship to H. Hence,
	* H == 2 only if F, G, also 2.
	
	* Note that the English questionnaire has a typo and if 13H = 2 and 13E is 3 or 4 (which needs to be, otherwise 13H not
	* asked), then Swahili version says go to 13IB, not 14A like in English. How to get to 13IA I don't know as it seems im-
	* possible. Does not matter because in either option if absent goes to Q13J so we can chose that.
	
	* Absence then can be from job or business (Q13J 1 or 4), which we will accept as employed if out for less than a month
	* or more than a month but still being paid (Q13M == 1).
	
	* Absence from agriculture needs to be for needs to be at less than a month and 50%+ for market exchange.
	
	* E1 - Did Ag work for market exchange
	replace lstatus = 1 if inrange(Q13E, 1, 2)
	
	* E2 - Did some other work (paid employment, F, business, G, or helping in business, H)
	replace lstatus = 1 if Q13F == 1 | Q13G == 1 | Q13H == 1
	
	* E3 - Did not work in categories defined by E1 or E2 but absent from paid job or business for less than a month
	replace lstatus = 1 if inlist(Q13J, 1, 4) & Q13K == 1
	
	* E4 - Did not work in categories defined by E1 or E2 but absent from paid job or business for over a month, still paid
	replace lstatus = 1 if inlist(Q13J, 1, 4) & inrange(Q13K, 2, 5) & Q13M == 1
	
	* E5 - Did not work in categories defined by E1 or E2 but absent from market farming for less than a month
	replace lstatus = 1 if inlist(Q13J, 2, 3) & Q13K == 1 & inrange(Q13N, 1, 2)

  ***************************
  * Define those unemployed
  ***************************
  
	* Unemployment is now defined among those still with no lstatus (for whom lstatus == .)
  
	* U1 - Unemployed is no work (lstatus == .) + took steps to find work and would accept
	replace lstatus = 2 if missing(lstatus) & (Q15A == 1 & Q15D ==1)
  
  ***************************
  * Define those NLF
  ***************************
  
	* Not in the labour force is the remainder
	  
	* N1 - Not in the labour force (NLF) is: old enough to answer (age >= 5) and lstatus still missing
	replace lstatus = 3 if missing(lstatus) & inrange(Q05B_AGE, 5, 99)
	
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>

```


# Coding to convert the 2020 ILFS to the old definition

In converting back to the old definition, the approach adopted here is to create a variable that identifies those that are engaged in non-market farming, and those who were absent for less than a month from non-market farming. The code below should be pasted after the code creating the `lstatus` variable based on the 2020 definition. 

```
	 *Create an indicator "emp_diff" that identifies the difference between definitions (emp_diff)
	gen emp_diff = 0 if inrange(lstatus, 2, 3) 
	* Add those in non market farming
	replace emp_diff = 1 if emp_diff == 0 & inrange(Q13E, 3, 4)
	* Add those absent for less than a month from non market farming
	replace emp_diff = 1 if emp_diff == 0 & Q13K == 1 & inrange(Q13N, 3, 4)
	
	* Use emp_diff to generate 2014 definition
	replace lstatus = 1 if emp_diff == 1
	
	replace lstatus = . if Q05B_AGE < 5

```

Users may also wish to  identify the dual employment workers, i.e., those that report working for own consumption and have a main job for pay or profit. 

```
	gen dual_emp_2020 = 0 if lstatus == 1
	replace dual_emp_2020 = 1 if dual_emp_2020 == 0 &  inrange(Q13D, 1, 5) & ( inrange(Q13E, 3, 4) | (Q13K == 1 & inrange(Q13N, 3, 4))  )
	replace dual_emp_2020 = 2 if dual_emp_2020 == 0 &  Q13D == 6 & inrange(Q13E, 3, 4)
	label define lbl_dual 0 "Not dual" 1 "Ag dual" 2 "Construction dual"
	label values dual_emp_2020 lbl_dual
	label var dual_emp_2020 "Dual employment"
```

We can go further an try to overwrite the occupation sector, employment status, industry and occupation of those that we assume would have - under the old definition - been recorded with their own consumption definition under the previous employment definition.

The first step is to identify those interviewed who have dual employment who are not in their market job working in agriculture or construction (if they already do, no need to update their information).

```
* Reduce industry information to two digits, map if not in agriculture (codes 01 - 03) or construction (codes 41 - 43).
gen ind = floor(Q23B_DETAILS_ISIC_CODES/100)
gen dual_non_ag_construction = .
replace dual_non_ag_construction = 1 if dual_emp_2020 == 1 & !inrange(ind,1,3) 
replace dual_non_ag_construction = 2 if dual_emp_2020 == 2 & !inrange(ind,41,43)
```

The next step to consider is whether the change is warranted. The key question is whether own consumption work is the main task the respondent does (in which case they would have been recorded with that info under the old definition) or whether it is a side job - in which case the non-consumption job should remain. The border set by the GLD team (reasonable people may disagree) is 25 hours a week. If the individual works 25 or fewer hours in their job, then we assume this is in fact a secondary one and their main job is the own-consumption work.

```
gen dual_switcher = .
replace dual_switcher = 1 if dual_non_ag_construction == 1 & whours < 25
replace dual_switcher = 2 if dual_non_ag_construction == 2 & whours < 25
label define lbl_switch 1 "Ag switch" 2 "Construction switch"
label values dual_switcher lbl_switch
label var dual_switcher "Dual switcher"
```

Own consumption workers are by definition self-employed and in the private sector. Their occupation and industry are defined by their work.

```
* OCUSEC (all to private)
replace ocusec = 2 if inrange(dual_switcher, 1, 2) | emp_diff == 1

* EMPSTAT (all self-employed)
replace empstat = 4 if inrange(dual_switcher, 1, 2) | emp_diff == 1

* INDUSTRY
* Assume if we have emp_diff it was agricutlure
replace industrycat10 = 1 if emp_diff == 1 | dual_switcher == 1
* Except for construction
replace industrycat10 = 5 if (emp_diff == 1 & Q13D == 6) | dual_switcher == 2

* OCCUPATION
* Assume if we have emp_diff it was agricutlure
replace occup = 6 if emp_diff == 1 | dual_switcher == 1
* Except for construction
replace occup = 7 if (emp_diff == 1 & Q13D == 6) | dual_switcher == 2
```

Finally, do the last bits of cleaning up to ensure the other labour variables are in line with what could be expected for own-consumption workers.

```
* WAGE (send to missing)
replace wage_no_compen = . if emp_diff == 1 | inrange(dual_switcher, 1, 2)

* WHOURS (send to missing)
replace whours = . if emp_diff == 1 | inrange(dual_switcher, 1, 2)

* CONTRACT (send to missing)
replace contract = . if emp_diff == 1 | inrange(dual_switcher, 1, 2)

* SOCIAL SECURITY (send to missing)
replace socialsec = . if emp_diff == 1 | inrange(dual_switcher, 1, 2)

* UNION (send to missing)
replace union = . if emp_diff == 1 | inrange(dual_switcher, 1, 2)

* NLF Reason (send to missing)
replace nlfreason = . if emp_diff == 1 | inrange(dual_switcher, 1, 2)

* FIRMSIZE (set to 0, self employed)
replace firmsize_l = 0 if emp_diff == 1 | inrange(dual_switcher, 1, 2)
replace firmsize_u = 0 if emp_diff == 1 | inrange(dual_switcher, 1, 2)
```
