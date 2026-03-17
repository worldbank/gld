# Education in the Mauritius CMPHS

## Overview

In the Mauritius CMPHS, educational attainment is primarily recorded by year level. The raw education attainment variable does not identify levels beyond secondary schooling in a way that is sufficient for GLD harmonization.

To identify post-secondary attainment, the harmonization relies on a separate variable that records the respondent's field of study or qualification. This variable follows an education classification system based on the Internationa and is used to distinguish higher levels of education.

## Classification used in the qualification variable

The qualification variable is based on ISCED 1976 in most years and on ISCED 1997 in 2011 and 2012.

| Year | Classification in survey | International compatibility |
|:----:|:------------------------:|:---------------------------:|
| 2001-2010 | ISCED-76-based classification | ISCED 1976 |
| 2011-2012 | NSCED-97 | ISCED 1997 |

## Mapping of qualification codes to GLD education categories

The harmonization relies on the first digit of the qualification code to identify the broad education level.

The qualification variable is used only to identify post-secondary attainment. Codes `0` to `3` are not used to construct `educat7`, since levels up to secondary are already identified from the main raw education variable. The qualification variable is used only for codes `4` to `8`, which distinguish post-secondary and university education.

 The table below summarizes the interpretation used in the GLD harmonization.

| Code | ISCED level | Description | Qualification example | GLD harmonized category |
|:----:|:-----------:|:------------|:----------------------|:------------------------|
| 0 | 0 | Pre-primary |  |  Not used in harmonization |
| 1 | 1 | Primary | CPE |  Not used in harmonization |
| 2 | 2 | Lower secondary | Pre-Voc (Yr I - IIII) | Not used in harmonization|
| 3 | 3 | Upper secondary | NTC Level 3, Certificate |  Not used in harmonization |
| 4 | 4 | Post-secondary | NTC Level 2, Certificate | Higher than secondary but not university |
| 5 | 5 | First stage of tertiary education | Diploma | Higher than secondary but not university |
| 6 | 5 | First stage of tertiary education | Degree (BSc) | University incomplete or complete |
| 7 | 5 | First stage of tertiary education | Master degree | University incomplete or complete |
| 8 | 6 | Second stage of tertiary education | MPhil/PhD | University incomplete or complete |

In the GLD harmonization, codes `4` and `5` are grouped as `Higher than secondary but not university`, while codes `6` to `8` are grouped as `University incomplete or complete`.

## Sample coding logic

Below is an illustration of the coding logic used to harmonize the qualification information into GLD education categories.

```
*<_educat7_>
	gen byte educat7=.
	replace educat7=1 if educationlevel==1 | educy==0
	replace educat7=2 if educationlevel>=11 & educationlevel<=16
	replace educat7=3 if educationlevel==17
	replace educat7=4 if educationlevel>=21 & educationlevel<=26
	replace educat7=5 if educationlevel>=27 & educationlevel<=31
	
	* Use ISCED from field of study vble
	gen qual1d = int(qualification/1000)
	replace educat7=6 if inlist(qual1d, 4, 5)
	replace educat7=7 if inlist(qual1d, 6, 7, 8)
	drop qual1d
	
	label var educat7 "Level of education 1"
	la de lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete"
	label values educat7 lbleducat7
*</_educat7_>
```

## Field of study information

## Field of study information

Users interested in the post-secondary field of study information can refer to the variable `educat_orig`, which retains the original education coding from the survey. This variable contains both the raw education information up to secondary level and the more detailed field of study or qualification information for post-secondary education. They can be distinguished by the number of digits: the raw education information are informed stored in two digits (three digits in 2012), while the field of study are in three digits (four digits in 2012)

However, the meaning of the detailed field of study codes is not fully documented in the materials available to the GLD team. In addition, these codes are not fully compatible with ISCED categories. 

