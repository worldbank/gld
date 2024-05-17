# Introduction

**GLFS 2018** relies on the definitions outlined in the 15th International Conference of Labour Statisticians (ICLS) from 1993, as amended by the [18th ICLS](https://www.ilo.org/sites/default/files/wcmsp5/groups/public/@dgreports/@stat/documents/meetingdocument/wcms_099134.pdf) in 2008, to define the economically active population. However, **GLFS 2022-23** aimed to align with the latest international statistical standards on labor, adopted the definitions provided by the [19th ICLS](https://www.unescap.org/sites/default/files/ILO_overview_of_the_19th%20ICLS.pdf), which expanded the scope of work and recognized a broader range of productive activities. Consequently, the `lstatus` variable is not directly comparable between the surveys.

It is not possible to match both definitions due to the lack of information in the questionnaires.

# Framework for identifying employment in the GLFS

Both questionnaires used information on current activity to define employment through the ***Employment last 7 days*** block. Questions EMP1 to EMP17 (EMP18 for GLFS 2023).

# Employment definitions

Respondents considered as employed in **GLFS 2018** under ```lstatus```variable are not identical to those in GLFS **2022-23**. This discrepancy arises because the ```lstatus``` and ```empstat``` definitions are not consistent between the two surveys

The definition of ```lstatus``` for **GLFS 2018** is:
``` 
According to the international definition, the employed population includes all persons above a specified age who did some work in the reference period either for pay in cash or in kind (paid employees) or who were in self-emp loyment for profit, plus persons temporarily absent from their work. Self- employment includes persons working on their own farms selling most or all their produce or doing any other income generating activities. This report uses the international definition of employment.

``` 

The definition of ```lstatus``` for **GLFS 2023** is:

``` 
The employed are all those persons of working age who, during the previous week, were engaged in any activity to produce goods or provide services in exchange for pay or to generate profit (in cash or in kind). 
They comprise: 
  - employed persons 'at work', i.e. who worked in a job for at least one hour; 
  - employed persons 'not at work' due to temporary absence from a job, or to working-time arrangements (such as shift work, flexitime and compensatory leave for overtime). 

``` 

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

while **GLFS 2018** solely considers Paid Employees, self-employed individuals, and employers as being categorized as employed, **GLFS 2022-23** additionally includes Non-paid employees

### Questionnaries

The **GLFS 2018** questionnaire determines the labor status based on this questions:

<figure>
  <figcaption><b>Fig. 1</b><i> Employment question - GLFS 2018 </i></figcaption>
  <img src= utilities/emp_questions_2018a.png alt=emp_questions_2018a>
  <img src= utilities/emp_questions_2018b.PNG alt=emp_questions_2018b>
  
</figure>

The **GLFS 2022-23** questionnaire determines the labor status based this questions:

<figure>
  <figcaption><b>Fig. 2</b><i> Employment question - GLFS 2022-23 </i></figcaption>
  <img src= utilities/employment_questions_2022a.png alt=employment_questions_2022a>
  <img src= utilities/employment_questions_2022b.png alt=employment_questions_2022b>
  
</figure>

(Note: The questionnaire applies the **CM** block to employed individuals, beginning with question **CM1**.)

### Survey comparison


The questions of **GLFS 2018** are targeted towards the type of work the respondent does, whereas those of **2022-23** focus on more general questions about workplace actions that encompass various types of employment.

**GLFS 2018** structure does not consider as employed the unpaid workers (e.g., Homemakers working on non-farm family businesses) or another job not considered in ```EMP5``` question as employed. As shown in the images above, individuals who respond to ```EMP5 >= 5``` and do not have any other type of employment are assigned questions related to job search and availability.


<figure>
  <figcaption><b>Fig. 3</b><i> Unemployment questions - GLFS 2018 </i></figcaption>
  <img src= utilities/unemployment_question_2018.PNG alt=unemployment_question_2018>
  
</figure>

(Note: There is another question for unpaid farmers which asks about the destination of the produced goods, The labour status depends of their answer.)

Consequently, thus type of population who do not have any other type of employment, are classified within the spectrum of unemployment or considered outside the labor force.

<figure>
  <figcaption><b>Fig. 4</b><i> Unpaid workers and none of above labour status - GLFS 2018 </i></figcaption>
  <img src= utilities/unpaid_workers.png alt=Unpaid_workers>
  
</figure>


On the other hand, **GLFS 2023** with broader questions, involve non-paid employees in the categorization of employment.

<figure>
  <figcaption><b>Fig. 5</b><i> Employment status - 2018 vs 2022-23 </i></figcaption>
  <img src= utilities/empstat.png alt=Empstatus width=750 height=650>
  
</figure>


### Match employment definitions

It is not possible to unify the definitions of employed population due to the lack of information in the questionnaires: 

**Change Labour of 2018: unpaid workers ```EMP5 == 5``` and none of above population ```EMP5 == 7```  to ```lstatus == employed```**

There are no questions available to ascertain their employment status. For instance, there are no questions about their interaction within the business market or whether they have been hired by someone.

**Change Labour of 2023: ```empstat == Non-paid employees```  to ```lstatus == unemployed```**

No job search questions were assigned to them. We do not know whether they are unemployed or Non-LF.


