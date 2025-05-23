# Conversion from ICLS-19 to ICLS-13 version

## Overview

At the 19th ICLS in 2013, a significant development emerged with the adoption of the [Resolution concerning statistics of work, employment, and labor underutilization](https://www.ilo.org/resource/resolution-concerning-statistics-work-employment-and-labour). This led to a change in the concept of employment compared to ICLS-13.

In essence, the ICLS-19 resolution delineates **employment** only as work conducted for pay or profit. Activities performed not in exchange for remuneration, like own-use production work, volunteer work, and unpaid trainee work, are classified as **other forms of work**.

The GLD harmonizes data to the standard used in the design and reporting of the survey. Therefore, the 2012 GLSS is coded using ICLS-13 and the 2016 uses ICLS-19 (see variable `icls_v` in each survey). To compare GLSS 2012 (ICLS-13) with 2013 (ICLS-19) directly it is necessary to modify the coding of  variable `lstatus` using the nuances of the questionnaire.

## Framework for identifying employment in the GLSS

All questionnaires used information on current activity to define employment through the ***Economic Activity*** section in part A ***Employment last 7 days***.

## From current coding to the ICLS-13 definition

In converting to the old definition, the approach adopted here is to create a variable that identifies those that are engaged in activities for market exchange as well as those that work without (or mostly without) market exchange. Figure 1 below shows an example of one of the relevant building blocks in the questionnaire for the employment definition.

<figure>

<figcaption><b>Figure 1 </b><i> Farm Enterprise Questions - GLSS 2016 </i></figcaption>

<img src="utilities/Farming_ownuse_2016.PNG" alt="Farming_ownuse_2016_ICLS"/>

</figure>

In this case, if we code 1 for question 6, we can capture the employees according to the ICLS-13 definition (includes all subcategories denoted in question 8). This strategy should be applied to all relevant questions in this section (question 1 to 30, part A - section 4)

The code below applies this procedure to all relevant questions. It should be pasted *after* the code creating the ```lstatus``` variable as coded in the 2016 harmonization code file. 

```     
  * Create an indicator "emp_diff" that identifies the difference between definitions (emp_diff)
  gen emp_diff = 0 if inrange(lstatus, 2, 3)

  * Define the broader ICLS-13 concept
  gen icls_13 = 1 if s4aq2 == 1 | s4aq4 == 1 | s4aq6 == 1  | s4aq9 == 1  |  s4aq12 == 1  | ///
  inlist(s4aq15,1,2) | inlist(s4aq17,1,2,3) | s4aq19 == 1 | s4aq22 == 1 | s4aq23 == 1 |    ///
  s4aq25 == 1 | s4aq27 == 1 | inlist(s4aq28,1,2) | inlist(s4aq29,1,2,3) | s4aq30 == 1

  * Replace emp_diff is one if ICLS-19 is not employed but ICLS-13 yes
  replace emp_diff = 1 if emp_diff == 0 & icls_13 == 1
  
  * Use emp_diff to replace cases that differ
  replace lstatus = 1 if emp_diff == 1
```

The GLSS asks the subsequent questions about the main job of all individuals who worked for at least one hour in the past seven days, regardless of the market interaction. Therefore, it is possible to run the code only changing variable `lstatus` and other variables such as employment status, industry, occupation, or other labor-related variables are unaffected by either definition of employment.
