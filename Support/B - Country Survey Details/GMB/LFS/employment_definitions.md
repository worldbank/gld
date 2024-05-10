# Introduction

Due to the changes in employment definitions in GLFS 2022-23 aimed at incorporating the latest international statistical standards on labor, the ```lstatus```  variable is not comparable. 

It is not possible to match both definitions due to the lack of information in the questionnaires.

The following subsections will outline the main differences between the two surveys.

# Framework for identifying the employed in the GLFS

Both questionnaires used information on current activity to define employment through the ***Employment last 7 days*** block. Questions EMP1 to EMP17 (EMP18 for GLFS 2022-23).

# Employed

Respondents considered as employed in GLFS 2018 under ```lstatus``` are not the same as those in GLFS 2022-23.

GLFS 2018 only considers Paid Employees, self-employed individuals, and employers as being in the employed status. Remember that ```empstat != . if lstatus == 1```.

<img src= utilities/empstat.png alt=Empstatus width=750 height=650>

This arises from the fact that the questionnaire's structure did not account for this type of population. As shown in the images below, individuals who respond to ```EMP5 >= 5``` and do not have any other type of employment are assigned questions related to job search and availability.

<img src= utilities/employment_questions_2018a.png alt=employment_questions_2018a>
<img src= utilities/employment_questions_2018b.png alt=employment_questions_2018b>

(Note: There is another question for unpaid farmers which asks about the destination of the produced goods but is not related to this subsection.)

Consequently, populations such as unpaid workers (e.g., Homemakers working on non-farm family businesses) who do not have any other type of employment, are classified within the spectrum of unemployment or considered outside the labor force.

<img src= utilities/unpaid_workers.png alt=Unpaid_workers>

GLFS 2022-23, on the other hand, incorporates new questions that involve non-paid employees in the categorization of employment.

The questionnaire applies the **CM** block to employed individuals, beginning with question **CM1**.

<img src= utilities/employment_questions_2022a.png alt=employment_questions_2022a>
<img src= utilities/employment_questions_2022b.png alt=employment_questions_2022b>

# Unemployed and Non-LF

The methodology used in GLFS 2018 to determine the unemployed population and those outside the labor force differs from that in 2022-23.

GLFS 2018 defines unemployment as all those persons of working age who were not in employment, carried out activities to seek employment during a specified recent period, and were currently available to take up employment given a job opportunity.

The questionnaire considers as unemployed (apply unemployment block) a not working or unpaid family worker in a subsistence business, available for work and looking for work. In other words **EMP13 == yes**. 
 
 <img src= utilities/unemployment_questions_2018a.png alt=unemployment_questions_2018a>

On the other hand, in GLFS 2022-23, the unemployment rate conforms to the definition by ILO. (see document The Gambia Labour Force Survey (GLFS 2022-23) Analytical Report): 

```
The unemployment rate in this survey conforms to the definition by ILO, which is defined as persons of working age unemployed who meet the following three conditions:
 -  Not been employed, i.e., not to have worked for pay or profit during the reference period. A person can be unemployed while being
    engaged in other forms of work such as own-use production work, volunteer work or unpaid trainee work. The distinction between
    employment and own-use production of goods is based on the main intended destination of the production. Production of goods mainly intended for sale or exchange are included in employment.
 -  To have actively looked for a paid job or to start a business in the past four weeks.
 -  To have been available for a job during the reference period or in the two coming weeks.  
However, persons who have already found a job and who will start their new job within three months are considered as unemployed.
```

Although the two definitions may seem similar, the unemployed population in 2018, if the methodology of 2023 is used, would be much smaller.

<img src= utilities/lstatus_2018vs2022.png alt=lstatus_2018vs2022>

Even though it's possible to adapt the methodology from 2022-23 to 2018, achieving a perfect match isn't possible due to the mentioned **employed** population issue.
