# Tanzania's education system

## Introduction

Tanzania's education system is complex. Education policy is decided autonomously for Mainland Tanzania and Zanzibar. An education reform in 2006 introduced changes in Zanzibar reducing primary education from 7 years to 6 years, but this has not been implemented until 2010. Mainland Tanzania followed suit and began implementation of a similar scheme in 2016. Along with these changes, and not to be confused with the similarity in numbers, the primary entry age is also reduced from 7 to 6. But before 2010, and for the longest time, both Zanzibar and Mainland Tanzania operate under the same scheme. As an implication, individuals in 2014 and 2020 rounds complete primary education at different year levels: the threshold for primary complete is Standard 7 pre-reform, and Standard 6 post-reform. 

## Coding issue

This policy background raises the question on how "primary completed" should be coded in the GLD harmonization, particularly when the raw variable for educational attainment is detailed at the education year level. This is a concern specifically for the 2014 round where individuals in Zanzibar are a mix of the old and new scheme, and for 2020 round where the mix of the two schemes occur in both Zanzibar and Mainland Tanzania. Unfortunately, there is no variable indicating which individuals are on the old and new schemes in any of the ILFS rounds, so coding decisions need to rely on the theoretical age for the affected group to proxy for reform-affected individuals. 

For more information on the Tanzania's education system, refer to this [UNICEF report](Utilities/Tanzania-2018-Global-Initiative-Out-of-School-Children-Country-Report.pdf)

## Framework
The logic adopted here is to determine the potentially-affected age group in each of the rounds to determine whether the plurality of the sample are potentially in the old or new scheme. For instance, if there were more people in the 2014 round beyond the potentially-affected age group, then the coding should use Standard 7; otherwise, it should use Standard 6. Bias will result in either way (i.e., Standard 7 as threshold will exert upward bias on primary incomplete, and Standard 6 on primary complete), but the objective of this process is to select the threshold that minimizes it. 

The first question in this process is how to determine the potentially-affected age group. Assuming that the reform kicks in immediately for the incoming Standard 6 cohort, theoretically 13 years old at that time (also consistent with the age cut-off in this [UNICEF report](Utilities/Tanzania-2018-Global-Initiative-Out-of-School-Children-Country-Report.pdf)), then in the Zanzibar 2014 round, these individuals should be 17 years old, which also becomes the upper bound for the potentially-affected age group. The lower bound is simply 13 years old, assuming that these children enter based on the pre-reform primary entry age of 7. In the 2020 round, the upper bound is set to 23 years old (= 17 + 6) for Zanzibar and 17 years old for Mainland Tanzania. The lower bound is set at age 13 for Mainland Tanzania, and age 12 for Zanzibar since the change in primary entry age is likely to have taken into effect by then. The distribution of these potentially-affected age groups are presented below:

| **Survey   round** | **Description**       | **Age range**            | **% (weighted)** | **N (unweighted)** |
|--------------------|-----------------------|--------------------------|------------------|--------------------|
|     ZNZ   2014     | Proxy for post-reform | 13 - 17 years old        |      11.51%      |        4,213       |
|                    | Proxy for pre-reform  | 18 years old and   above |      50.33%      |       18,635       |
|     TAN   2020     | Proxy for post-reform | 13 - 17 years old        |      11.46%      |        5,689       |
|                    | Proxy for pre-reform  | 18 years old and   above |      48.36%      |       26,633       |
|     ZNZ   2020     | Proxy for post-reform | 12 - 23 years old        |      25.84%      |        5,882       |
|                    | Proxy for pre-reform  | 24 years old and   above |      39.89%      |        9,011       |

Based on this output, there are more individuals in the pre-reform group. An implication of that following the logic described above is to set Standard 7 as the cut-off for primary complete. Consequently, the estimates for primary complete will understate the true value as the post-reform individuals are treated as primary incomplete even after completing all 6 years of primary education. 

## Proposed coding for primary complete

Users who want to capture the distribution following this reform may want to consider the use of age range as proxies. There are limitations to our assumptions (e.g., children may start later than the primary entry age) but doing so may have a reduce the bias from generalizing based on age group plurality. The following lines of code can be added before the closing htlm tag for ```educat7``` in the 2014 and 2020 do files:

```
*-----------------------------
* For 2014 ZNZ code
*-----------------------------
* Q17A_EDUCA  = 6 represents Standard 6
replace educat7 = 3 if inrange(age, 13, 17) & Q17A_EDUCA == 6 & inrange(s1, 1, 3)

*-----------------------------
* For 2020 code
*-----------------------------
encode subnatid1, gen(s1)

* Q11D = 6 represents Standard 6
* Recode for Mainland Tanzania: 
replace educat7 = 3 if inrange(age, 13, 17) & Q11D == 6 & inrange(s1, 1, 3)

* Recode for Zanzibar
replace educat7 = 3 if inrange(age, 12, 23) & Q11D == 6 & inrange(s1, 4, 5)

drop s1
```
## Coding the ILFS education categories in the GLD

To summarize, the GLD harmonization converts the ILFS education codes as follows:

| **ILFS education levels**                | **GLD equivalent ```(educat7)```**                 |
|------------------------------------------|----------------------------------------------|
| Preschool                                | 1 - No education                             |
| Standards 1 - 6                          | 2 - Primary incomplete                       |
| Standards 7 - 8                          | 3 - Primary complete                         |
| Forms 1 - 3                              | 4 - Secondary incomplete                     |
| Form 4                                   | 5 - Secondary complete                       |
| Form 5   and 6, post-secondary trainings | 6 - Higher than secondary but not university |
| Tertiary level                           | 7 - University complete or incomplete        |

Note that Tanzania has two levels for secondary education: (1) ordinary level (Forms 1 - 4) and (2) advanced level (Forms 5 and 6). The final year of ordinary level, Form 4, is coded as secondary complete, and while the advanced levels are coded as higher than secondary but not university. This is consistent with our education coding in India where secondary education is split between lower and upper secondary. 
