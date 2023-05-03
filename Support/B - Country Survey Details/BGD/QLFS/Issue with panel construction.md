# Issues with panel construction in the QLFS

## Overview of the Issues
The QLFS employs a rotating panel survey design in which the same household is interviewed for two consecutive quarters before being replaced. Typically, a combination of household information and line numbers serves as the panel identifier to track households and individuals across quarters. However, when comparing variables that should remain relatively stable or unchanged between two rounds, certain logical inconsistencies may arise, indicating potential issues in data entry and/or panel identification.

Here are a few examples illustrating these challenges:

**Age.**  Instances have been observed where the reported age of the same individual drastically changes between two consecutive quarters.
One way to examine the scale of this problem is by analyzing the frequency of age differences within the panel identifier across different years.
While a one-year difference may be tolerable, considering the likelihood that an individual's birth date falls between 
two survey rounds, the problem becomes more substantial when larger age discrepancies occur. 
In particular, such inconsistencies may lead to misrepresentations within the working-age population, which may affect the overall reliability of the survey findings.

| **Age   difference within panel id** | **2015** | **2016** |
|---|---|---|
| Equal to 0 | 261,626 | 273,323 |
| Equal to 1 | 90,279 | 108,849 |
| Equal to 2 | 40,996 | 35,349 |
| Between 3 and 9 | 77,267 | 52,782 |
| 10 and above | 33,583 | 23,581 |

If the inconsistencies were random, the overall impact on the reliability of the findings might be minimal. Tabulating for labor status with and without these inconsistent panels show that the estimates do not change significantly. Below, the variable `lstatus_restricted` defines labor status only for individuals with age difference equal to zero or 1.  

<img src="Utilities/lstatus_age.png" alt="issueage" width="350" height="350">


Disaggregating labor status by education also shows that results do not vary significantly. 

<img src="Utilities/educ_age.png" alt="issueage" width="500" height="350">





## Recommendations
