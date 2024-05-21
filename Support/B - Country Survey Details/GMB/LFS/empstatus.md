# Introduction

The employment status ```empstat``` in **GLFS 2018** is not consistent with **GLFS 2023**. This discrepancy is due to the differences in the categories that distinguish employment between the two surveys.

To understand this difference, We will define the employment status for each survey and show the coding used in the questionnaire to define ```empstat```. And finally, We are going to analyze the possibility of harmonizing both definitions.


## Employment status definitions

The definition of ```empstat``` for **GLFS 2018** is:   

``` 
Status in employment is distinguished by the following categories: Employees, Employers, Own-account  workers,  Contributing  family  workers  and  Members  of  producers' cooperatives. However, this report used the following categories: 
  - Paid employees are persons who perform work for a wage or salary in cash or kind. It includes permanent, 
    temporary and casual paid employees.
  - The self-employed (non-agriculture) are persons who perform work for profit or family gain in their own  
    non-agricultural  enterprise. This  includes small and  large  business persons working on their own enterprises. The category is sub-divided into those with employees and those without employees.
  - The employers are workers who, working as own-account or with a few partners, hold a 'self-employment job', 
    and, in this capacity, on a continuous basis have engaged one or more persons to work for them in their business as employee(s).

```
The definition of ```empstat``` for **GLFS 2023** is: 

```
Status in employment refers to the type of work relationship a person has in his/her job, taking into account the kind of economic risk and degree of authority that the person experiences in their job. The survey data distinguish four statuses in employment: employee, employer, own-account worker and contributing family worker.

```

while **GLFS 2018** solely considers Paid Employees, self-employed individuals, and employers as being categorized as employed, **GLFS 2023** additionally includes Non-paid employees.

##  Current coding for the 2018 GLFS

The variable ```empstat``` in 2018 is defined as:

```
  ***************************
  * Create Variable
  ***************************
  	gen byte empstat = .
	
	*************************************
  * Define employment status categories
  *************************************
    *(EMP17) Can I just check in this job were working as:
      *1) A paid employee of someone who is not a member of your hh
      *2) A paid worker on hh farm or non-farm business enterprise
      *3) An employer
      *4) A worker on own account, without employees
  
    replace empstat = 1 if inlist(emp17,1,2)
  	replace empstat = 3 if emp17 == 3
  	replace empstat = 4 if emp17 == 4
  	replace empstat = 5 if empstat == . & lstatus == 1 //zero observations
  
  	replace empstat = . if lstatus != 1
  	label var empstat "Employment status during past week primary job 7 day recall"
  	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
  	label values empstat lblempstat
```

##  Current coding for the 2023 GLFS

The variable ```empstat``` in 2023 is defined as:

```
  ***************************
  * Create Variable
  ***************************
  	gen byte empstat = .
	
	*************************************
  * Define employment status categories
  *************************************
    *(CM5) (Do/does) (you/NAME) work…?
      *1) As an [Employee]
      *2) In (Your/His/Her) Own Business Activity
      *3) Helping in a Family or Household Business
      *4) As an Apprentice, Intern
      *5) Helping a Family Member Who Works for Someone Else

    *For those in their own business (CM5 == 2), to differentiate between SO and Employer use:
      *(CM7) Does the business hire any paid employees on a regular basis?
          *1) YES
          *2) NO
          
    replace empstat = 1 if inlist(cm5,1,4)
    replace empstat = 2 if cm5 == 3
    replace empstat = 3 if cm5 == 2 & cm7 == 1
    replace empstat = 4 if cm5 == 2 & cm7 == 2
    replace empstat = 5 if cm5 == 5
		  
	***************************
  * Exception
  ***************************
	  *(CM6) Who usually makes the decisions about the running of the family business?
    	*1) You/Name
      *2) You/Name Together with Others
      *3) Other Family Member(s) Only
      *4) Other (Non-Related) Person(s) Only
      
	  *If the respondent answer (3) to CM5 and (1 or 2) to CM6. Code them as:
		  *(Employer) If answer 1 to CM7
		  *(Self-employed) If answer 2 to CM7

    replace empstat = 3 if cm5 == 3 & inlist(cm6,1,2) & cm7 == 1
	  replace empstat = 4 if cm5 == 3 & inlist(cm6,1,2) & cm7 == 2
  
  	replace empstat = . if lstatus != 1
  	label var empstat "Employment status during past week primary job 7 day recall"
  	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
  	label values empstat lblempstat
```




## Survey comparison

Considering the above, we can see that **GLFS 2023** includes non-paid employees in option 3 of question ```CM5```  (Helping in a Family or Household Business). Meanwhile, **GLFS 2018** does not include this population in question ``` EMP17```.

This circumstance arises due to **GLFS 2018**  does not consider as employed the unpaid workers (e.g., Homemakers working on non-farm family businesses) or another job not considered in ```EMP5``` question. This question is responsible for creating the ```lstatus``` variable. For more information on how ```lstatus``` is coded in 2018, see this [document](icls19to13.md).

Individuals who respond ```EMP5 >= 5``` and do not have any other type of employment are assigned questions related to job search and availability.


<figure>
  <figcaption><b>Fig. 3</b><i> Unemployment questions - GLFS 2018 </i></figcaption>
   <img src= utilities/unpaid_questions_2018.PNG alt=unpaid_question_2018>
   <img src= utilities/unemployed_questions_2018.PNG alt=unemployment_question_2018>
  
</figure>

(Note: There is another question for **unpaid farmers** which asks about the destination of the produced goods, The labour status depends of their answer.)

Consequently, individuals of this population who do not have any other form of employment are classified as either unemployed or considered outside the labor force.

<figure>
  <figcaption><b>Fig. 4</b><i> Unpaid workers and none of above labour status - GLFS 2018 </i></figcaption>
  <img src= utilities/unpaid_workers.PNG alt=Unpaid_workers>
  
</figure>

Hence, there are not Non-paid employees in **GLFS 2018**

<figure>
  <figcaption><b>Fig. 5</b><i> Employment status - 2018 vs 2023 </i></figcaption>
  <img src= utilities/empstat.PNG alt=Empstatus width=750 height=650>
  
</figure>


## Harmonice ```empstat``` between both surveys

It is not possible to unify the definitions of ```empstat``` due to the lack of information in both questionnaires.

Below, we present the possible methods of harmonization and explain why they are not feasible:

**Change Labour of 2018: unpaid workers ```EMP5 == 5``` and none of above population ```EMP5 == 7```  change to ```lstatus == employed``` and this population will have ```empstat == Non-paid employees``` **

There are no questions available to ascertain their employment status. For instance, there are no questions about their interaction within the business market or whether they have been hired by someone.

**Change Labour of 2023: ```empstat == Non-paid employees```  to ```lstatus == unemployed```**

They were not assigned any job search questions. We do not know whether they are unemployed or Non-LF.


