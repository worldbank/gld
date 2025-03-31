# ICLS version

## Overview

At the 19th ICLS in 2013, a significant development emerged with the adoption of the [Resolution concerning statistics of work, employment, and labor underutilization](https://www.ilo.org/resource/resolution-concerning-statistics-work-employment-and-labour). This led to a change in the concept of employment compared to ICLS-13.

In essence, the ICLS-19 resolution delineates **employment** only as work conducted for pay or profit. Activities performed not in exchange for remuneration, like own-use production work, volunteer work, and unpaid trainee work, are classified as **other forms of work**.

Therefore, in order to compare AHIES 2022 and 2023 with GLD ICLS-13 surveys it is necessary to modify the coding of  variable `lstatus` using the nuances of the questionnaire.

## Framework for identifying employment in the AHIES

All questionnaires used information on current activity to define employment through the ***Economic Activity*** section in part A ***Current Economic Activity Status and Characteristics of Main Job***.

## Current coding to the ICLS-13 definition

In converting to the old definition, the approach adopted here is to create a variable that identifies those that are engaged in non-market and market activities. See the Figure 1 below for the relevant parts in the questionnaire.

<figure>

<figcaption><b>Figure 1</b><i> Farm Enterprise Questions - AHIES 2022 and 2023 </i></figcaption>

<img src="utilities/Farming_ownuse_2022-23.PNG" alt="Farming_ownuse_2022-23"/>

</figure>

In this case, if we code 1 to 4 for question 10 (or code 1 to question 7), we can capture the employees according to the ICLS-13 definition. This strategy should be applied to all relevant questions in this section (question 1 to 37, part A - section 4)

The code below should be pasted after the code creating the ```lstatus``` variable. 

```     
  *Create an indicator "emp_diff" that identifies the difference between definitions (emp_diff)
	 gen emp_diff = 0 if inrange(lstatus, 2, 3)
	*Add those in non market interaction
	 gen icls_13 = 1 if  s4aq1 == 1 | s4aq4 == 1 | inrange(s4aq10,1,4) | inrange(s4aq14,1,4) | inrange(s4aq18,1,4) | inrange(s4aq19,1,4) | s4aq22 == 1 | s4aq29 == 1 | s4aq29a == 1 | inrange(s4aq31,1,4) | inrange(s4aq33,1,4) | inrange(s4aq35,1,4) | inrange(s4aq36,1,2)
	 replace emp_diff = 1 if emp_diff == 0 & icls_13 == 1
  
  * Use emp_diff to generate ICLS-13 definition
	replace lstatus = 1 if emp_diff == 1
	
	replace lstatus = . if age < minlaborage
```
We can go further an try to overwrite the employment status, occupation sector, industry and occupation of those that we assume would have - under the old definition - been recorded with their own consumption definition under the previous employment definition.

```     
  *Own consmuption farm/non-famr enterprises is considered as self-employed
	 replace empstat = 4 if [inrange(s4aq10,3,4)|inrange(s4aq14,3,4) | inrange(s4aq18,3,4) | inrange(s4aq19,3,4) | inrange(s4aq31,3,4) | inrange(s4aq33,3,4) | inrange(s4aq35,3,4)] & emp_diff == 1 & missing(empstat)
	 *Family help in farm/non-famr enterprises is considered as Non-paid employee
	 replace empstat = 2 if inrange(s4aq10,3,4) & emp_diff == 1 & missing(empstat)
	 
	*Assume farmers work in the agricultural sector.
	replace industrycat10 = 1 if [inrange(s4aq10,3,4)|inrange(s4aq14,3,4) | inrange(s4aq19,3,4) | inrange(s4aq31,3,4) | inrange(s4aq35,3,4) ] & emp_diff == 1 & missing(industrycat10)
	
	*Assume farmers work in Skilled agricultural occupations.
	replace occup = 6 if [inrange(s4aq10,3,4)|inrange(s4aq14,3,4) | inrange(s4aq19,3,4) | inrange(s4aq31,3,4) | inrange(s4aq35,3,4) ] & emp_diff == 1 & missing(occup)
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

```

