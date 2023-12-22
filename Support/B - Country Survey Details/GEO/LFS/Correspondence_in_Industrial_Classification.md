# General Introduction

This document describes the methodology used to map national industrial and occupational codes to their international counterparts. As mentioned in the main introduction page, two versions of national and international classifications of industry were used throughout the six years: Statistical classification of Economic Activities in the European Community (NACE) rev.1 and rev.2 for national classification, and International Standard Industrial Classification (ISIC) rev.3 and rev.4 for international classification. 

However, for all six years, we did a mapping between NACE rev.2 and ISIC rev.4. From 2017 to 2021, the original industry variable was coded in both NACE rev.1 and rev.2 in the raw data sets, even though the official records state that 2017-2019 used NACE rev.1. It might be the case that NSO updated the old raw data sets and mapped NACE rev.1 to NACE rev.2 when LFS began to use NACE rev.2. We used NACE rev.2 One reason is that 2022 does not use NACE rev.1. And since NACE rev.2 is the common version for all years, we used NACE rev.2 to make industry more comparable. The other reason is that mapping was more difficult to conduct between NACE rev.1 and ISIC rev.3 because of the considerable amount of re-codings and the difficulty of converting correspondence documents from a PDF format to an EXCEL format. Below is a table demonstrating the national and international versions used in each year. 

| **Year**	| **National Classification**	| **International Classification**	|
| :------:	| :-------:		        | :-------:	        	|
| 2017      |  NACE Rev. **1**        | ISIC Rev. **3**         | 
| 2018      |  NACE Rev. **1**        | ISIC Rev. **3**        |
| 2019      |  NACE Rev. **1**        | ISIC Rev. **3**         |
| 2020      |  NACE Rev. **2**        | ISIC Rev. **4**         |
| 2021      |  NACE Rev. **2**        | ISIC Rev. **4**         | 
| 2022      |  NACE Rev. **2**        | ISIC Rev. **4**         | 

Regarding occupation, the GEO LFS used International Standard Classification of Occupation (ISCO) 1998 and 2008 directly. So the classification of occupation does not need to be mapped from a national classification to an international classification. Therefore, this document only shows the correspondence between NACE rev.2 and ISIC rev.4.  

## Correspondence in industrial classification

**NACE rev.2 vs. ISIC rev.4**

The correspondence table between the two classifications is available from various online resources. Here is a comprehensive [document](utilities/isic_isco/NACE_ISIC_correspondence.pdf) showing the corresponding relationships among NACE rev.2, NACE rev.1.1, and ISIC rev.4 at four-digit level. Using this document, we were able to map NACE rev.2 to ISIC rev.4 at four-digit level.

The full re-coding list can be accessed in both [*.dta*](utilities/isic_isco/nace2_isic4_crosswalk.dta) format and [*.xlsx*](utilities/isic_isco/NACE_ISIC_crosswalk.xlsx) format and will not be demonstrated here, since more than 300 categories were re-mapped.
