# Introduction

At the 19th ICLS in 2013, a significant development emerged with the adoption of the [Resolution concerning statistics of work, employment, and labor underutilization](https://www.ilo.org/resource/resolution-concerning-statistics-work-employment-and-labour). This led to a change in the concept of employment compared to ICLS-13.

In essence, the ICLS-19 resolution delineates **employment** as work conducted for pay or profit. Whereas activities performed exchange for remuneration, like own-use production work, volunteer work, and unpaid trainee work, are classified as **other forms of work**.

Therefore, in order to compare GLFS 2018 and 2023 with surveys which employ ICLS-13, it is necessary to modify the coding of  variable ```lstatus``` using the questionnaire.

## Framework for identifying employment in the GLFS

Both questionnaires used information on current activity to define employment through the ***Employment last 7 days*** block. Questions EMP1 to EMP17 (EMP18 for GLFS 2023).

## 2018 GLFS 

###  Current coding for the 2018 GLFS

The variable ```lstatus``` in 2018 is defined as:

```
  ***************************
  * Create Variable
  ***************************
	gen byte lstatus = .
	
	
	***************************
  * Define those employed
  ***************************
  
    * The survey asks the main activity in the last 7 days (EMP5). The respondent is consider as employed if he answers: 
      * 1) A paid employee of someone who is not a member of your HH
      * 2) A paid worker on HH farm or non-farm business enterprise
    replace 
      * 3) An employer
      * 4) A worker non-agricultural own account worker, without employees
    
      replace lstatus = 1 if inlist(emp5,1,2,3,4) 
  
    * If the respondent answers 5 to 7 options:
      * 5) Unpaid workers (e.g., homemaker, working on non-farm family business)
      * 6) Unpaid farmers
      * 7) None of the above
    * But has another permanent/long term job (yes in EMP6)
      
      replace lstatus = 1 if (inlist(emp5,5,6,7) & emp6 == 1)
      
    * If the respondent is an unpaid farmer (EMP5 == 6) and his work is intended for sale (1) or mainly (2) in EMP12
    * EMP12 is only asked to unpaid farmers
    
     replace lstatus = 1 if inlist(emp12,1,2)
     
  ***************************
  * Define those unemployed
  ***************************
  
    * Unemployment is now defined among those still with no lstatus (for whom lstatus == .)
    
    * Unemployed is no work (lstatus == .) + took steps to find work and would accept
    replace lstatus = 2 if inlist(emp8,2,3) & emp9 == 1
  
  ***************************
  * Define those NLF
  ***************************
  
	* Not in the labour force is the remainder
	* Not in the labour force (NLF) is: old enough to answer (age >= 15) and lstatus still missing
	
	replace lstatus = 3 if missing(lstatus)
	
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>
```

### (Re)Coding the 2018 GLFS to fit the ICLS-13 definition

In converting back to the old definition, the approach adopted here is to create a variable that identifies those that are engaged in non-market farming. The code below should be pasted after the code creating the ```lstatus``` variable based on the 2018 definition.

```     
  *Create an indicator "emp_diff" that identifies the difference between definitions (emp_diff)
	 gen emp_diff = 0 if inrange(lstatus, 2, 3)
	*Add those in non market farming
	 replace emp_diff = 1 if emp_diff == 0 & inrange(emp12, 3, 4) 
  
  * Use emp_diff to generate 2018 definition
	replace lstatus = 1 if emp_diff == 1
	
	replace lstatus = . if age < minlaborag
```

We can go further an try to overwrite the employment status, occupation sector, industry and occupation of those that we assume would have - under the old definition - been recorded with their own consumption definition under the previous employment definition.

```     
  *Unpaid farmers are considered as self-employed
	 replace empstat = 4 if emp_diff == 1
	 
	*Assume Unpaid farmers work in the agricultural sector.
	replace industrycat10 = 1 if emp_diff == 1
	
	*Assume Unpaid farmers work in Skilled agricultural occupations.
	replace occup = 6 if emp_diff == 1
```
Finally, do the last bits of cleaning up to ensure the other labour variables are in line with what could be expected for own-consumption workers.

```
  * WAGE (send to missing)
  replace wage_no_compen = . if emp_diff == 1 
  
  * WHOURS (send to missing)
  replace whours = . if emp_diff == 1 
  
  * CONTRACT (send to missing)
  replace contract = . if emp_diff == 1 
  
  * SOCIAL SECURITY (send to missing)
  replace socialsec = . if emp_diff == 1
  
  * UNION (send to missing)
  replace union = . if emp_diff == 1 
  
  * NLF Reason (send to missing)
  replace nlfreason = . if emp_diff == 1 
  
  * FIRMSIZE (set to 0, self employed)
  replace firmsize_l = 0 if emp_diff == 1 
  replace firmsize_u = 0 if emp_diff == 1
```

## 2023 GLFS

###  Current coding for the 2023 GLFS

The variable ```lstatus``` in 2023 is defined as:

```
  ***************************
  * Create Variable
  ***************************
	gen byte lstatus = .
	
	
	***************************
  * Define those employed
  ***************************
	* There are four events that lead to question CM1 (first question of the employed)

    * 1) Yes to EMP4 (Code 1): work for someone else for pay, for one or more hours.
    * 2) Code "D" in EMP13: (run or do any kind of business, farming or other activity to generate income or help in a family business/farm) AND (Is a work diffrerent of farming, rearing farm animals and fishing).
    * 3) Ag work is only for sale (1) or mainly (2) in EMP14.
    * 4) Ag work was hired by someone else (code 1 in EMP15).
    
    replace lstatus = 1 if (emp4 == 1) | (emp13 == "D") | (inlist(emp14,1,2)) | (emp15 == 1)
 
  ***************************
  * Define those unemployed
  ***************************
    * Unemployment is now defined among those still with no lstatus (for whom lstatus == .)
    * Unemployed is no work (lstatus == .) + Union of active search (yes to js1 or js2) and passive search (yes to js4 or js7 or js7b)

    gen active = js1 == 1 | js2 == 1
    gen passive = js4 == 1 | (js7 == 1 | js7b == 1)
    replace lstatus = 2 if active == 1 & passive == 1 & mi(lstatus)
    

  ***************************
  * Define those NLF
  ***************************
  	* Not in the labour force is the remainder
  	* N1 - Not in the labour force (NLF) is: old enough to answer (age >= 5) and lstatus still missing
  	
  	replace lstatus = 3 if missing(lstatus)
	
  ***************************
  * Exceptions
  ***************************	
	*1) Respondents who answer (11) No method (confirms no job search) in js3 are considered Out of labour force, despite their answer in js1 or js2.
	replace lstatus = 3 if js3 == 11

  *2) There are 4607 people 15 and over who were not interviewed (var ii8 is code 2)
  *Sending them all to lstatus 3 would lopside the data. Keep them as missing.
   replace lstatus = . if ii8 == 2
	
	
  	replace lstatus = . if age < minlaborage
  	label var lstatus "Labor status"
  	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
  	label values lstatus lbllstatus
  *</_lstatus_>
```

### (Re)Coding the 2023 GLFS to fit the ICLS-13 definition

In converting back to the old definition, the approach adopted here is to create a variable that identifies those that are engaged in non-market farming. The code below should be pasted after the code creating the ```lstatus``` variable based on the 2023 definition.

```     
  *Create an indicator "emp_diff" that identifies the difference between definitions (emp_diff)
	 gen emp_diff = 0 if inrange(lstatus, 2, 3)
	*Add those in non market farming
	 replace emp_diff = 1 if emp_diff == 0 & inrange(emp14, 3, 4) 
  
  *Use emp_diff to generate 2018 definition
	replace lstatus = 1 if emp_diff == 1
	
	replace lstatus = . if age < minlaborag
```

The survey contains information on time spent on production for own use and his economic activity, this is available for: non market farming and respondents who work for someone else for pay, for one or more hours (Yes to EMP4), that have done unpaid work in farming or fishing for his household or family last week.

First, We need to identify this population.
```
  emp_diff = 0 if lstatus == 1
  replace emp_diff = 1 if emp_diff == 0 & !missing(emp16a)
  replace emp_diff = 2 if emp_diff == 0 & !missing(opa2a)
  label define lbl_own 0 "other" 1 "unpaid farmer" 2 "dual job"
	label values emp_diff lbl_diff
	label var emp_diff "ICLS-13 Own use production individuals"
```

If a dual job individual spends more time in production for own use than his main job. We could consider to update his job information.

First, We need to identify them.
```
  *Calculate spent hours in the last week of dual job individuals (days*hours)
  gen dual_own_whours = opa3 * opa4 if emp_diff == 2 & (opa4 != 97)
  
  *Identify dual job individual who are mainly self-employed workers
  gen new_own_use_2023 = 0 if lstatus == 1
  replace new_own_use_2023 = 1 if emp_diff == 2 & [(dual_own_whours > wkt2 & !mi(wkt2) & !inlist(wkt2, 997, 0)) | (mi(wkt2) & dual_own_whours > wkt1  & !mi(wkt1) & !inlist(wkt1, 997, 0))]

```
We can go further an try to overwrite the employment status, occupation sector, industry, occupation, economic activity and worked hours of those that we assume would have - under the old definition - been recorded with their own consumption definition under the previous employment definition.

```
  *Unpaid farmers are considered as self-employed
	 replace empstat = 4 if new_emp_2023 == 1 | new_own_use_2023 == 1
	 
	*Update economic activity
	replace industry_orig = emp16a if emp_diff == 1
	replace industry_orig = opa2a if new_own_use_2023 == 1
	 
	*Assume Unpaid farmers work in the agricultural sector.
	replace industrycat10 = 1 if new_emp_2023 == 1 | new_own_use_2023 == 1
	
	*Assume Unpaid farmers work in Skilled agricultural occupations.
	replace occup = 6 if new_emp_2023 == 1 | new_own_use_2023 == 1
	
	*Update whours
	replace whours = emp17 * emp18 if emp_diff == 1 & (emp18 != 97)
	replace whours = opa3 * opa4 if new_own_use_2023 == 1 & (opa4 != 97)
	
	*
```

Finally, do the last bits of cleaning up to ensure the other labour variables are in line with what could be expected for own-consumption workers.

```
  * WAGE (send to missing)
  replace wage_no_compen = . if new_emp_2023 == 1 | new_own_use_2023 == 1
  
  * CONTRACT (send to missing)
  replace contract = . if new_emp_2023 == 1 | new_own_use_2023 == 1
  
  * SOCIAL SECURITY (send to missing)
  replace socialsec = . if new_emp_2023 == 1 | new_own_use_2023 == 1
  
  * UNION (send to missing)
  replace union = . if new_emp_2023 == 1 | new_own_use_2023 == 1
  
  * NLF Reason (send to missing)
  replace nlfreason = . if new_emp_2023 == 1 | new_own_use_2023 == 1 
  
  * FIRMSIZE (set to 0, self employed)
  replace firmsize_l = 0 if new_emp_2023 == 1 | new_own_use_2023 == 1 
  replace firmsize_u = 0 if new_emp_2023 == 1 | new_own_use_2023 == 1
```
