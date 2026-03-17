# Education in the Mauritius CMPHS

## Overview

In the Mauritius CMPHS, educational attainment is primarily recorded by year level. The raw education attainment variable does not identify levels beyond secondary schooling in a way that is sufficient for GLD harmonization.

To identify post-secondary attainment, the harmonization relies on a separate variable that records the respondent's qualification. This variable follows the National Standard Classification of Education (NSCED), Mauritius' adaptation of the International Standard Classification of Education (ISCED), and is used to distinguish higher levels of education.

## Classification used in the qualification variable

The qualification variable is based on NSCED for most years and on NSCED-97 in 2011 and 2012, corresponding to the adaptations of ISCED 1976 and ISCED 1997, respectively.

| Year | Classification in survey | International compatibility |
|:----:|:------------------------:|:---------------------------:|
| 2001-2010 | NSCED | ISCED 1976 |
| 2011-2012 | NSCED-97 | ISCED 1997 |

## Mapping of qualification codes to GLD education categories

The harmonization relies on the first digit of the qualification code to identify the broad education level.

The qualification variable is used only to identify post-secondary attainment. Codes `0` to `3` are not used to construct `educat7`, since levels up to secondary are already identified from the main raw education variable. The qualification variable is used only for codes `4` to `8`, which distinguish post-secondary and university education.

The table below summarizes the interpretation used in the GLD harmonization.

| Code | ISCED level | Description | Qualification  | GLD harmonized category |
|:----:|:-----------:|:------------|:----------------------|:------------------------|
| 0 | 0 | Pre-primary |  | Not used in harmonization |
| 1 | 1 | Primary | Certificate of Primary Education | Not used in harmonization |
| 2 | 2 | Lower secondary | Pre-Voc (Yr I - IIII) | Not used in harmonization |
| 3 | 3 | Upper secondary | National Trade Certificate (NTC) Level 3, Certificate | Not used in harmonization |
| 4 | 4 | Post-secondary | NTC Level 2, Certificate | Higher than secondary but not university |
| 5 | 5 | First stage of tertiary education | Diploma | Higher than secondary but not university |
| 6 | 5 | First stage of tertiary education | Degree (BSc) | University incomplete or complete |
| 7 | 5 | First stage of tertiary education | Master degree | University incomplete or complete |
| 8 | 6 | Second stage of tertiary education | MPhil/PhD | University incomplete or complete |

In the GLD harmonization, codes `4` and `5` are grouped as `Higher than secondary but not university`, while codes `6` to `8` are grouped as `University incomplete or complete`.

## Sample coding logic

Below is an illustration of the coding logic used to harmonize the qualification information into GLD education categories.

```stata
*<_educat7_>
	gen byte educat7=.
	replace educat7=1 if educationlevel==1 | educy==0
	replace educat7=2 if educationlevel>=11 & educationlevel<=16
	replace educat7=3 if educationlevel==17
	replace educat7=4 if educationlevel>=21 & educationlevel<=26
	replace educat7=5 if educationlevel>=27 & educationlevel<=31
	
	* Use qualification variable for post-secondary attainment
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
Users interested in the post-secondary field of study information can refer to the variable educat_orig, which retains the original education coding from the survey. This variable contains both the raw education information up to secondary level and the more detailed qualification information for post-secondary education. These can be distinguished by the number of digits: the raw education information is stored in two digits, except in 2012 when it is stored in three digits, while the post-secondary qualification information is stored in three digits, except in 2012 when it is stored in four digits.

However, the meaning of the detailed qualification or field of study codes is not fully documented in the materials available to the GLD team, and these codes are not fully compatible with ISCED categories. Their detailed interpretation is therefore beyond the scope of the GLD harmonization, and users interested in this information would need to determine the meaning of the raw codes separately.

