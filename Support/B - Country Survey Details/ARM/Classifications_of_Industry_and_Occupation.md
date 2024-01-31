# Classifications of Industry and Occupation of Armenian Labour Force Survey

As mentioned in the introduction page, the classifications of industry and occupation applied in ARM LFS are single-version international classifications and they only used the major groups classified by letters. This document will briefly describe the harmonization process and provide the complete lists of industry and occupation letters along with their labels. 

**Industry ISIC Rev.4**

All years used ISIC Rev.4 in the raw datasets. Hence, all of their original industry variables contain the same categories as follows:

| **Major Group Letter**	| **Industry Name**	| **10-Group Categorization**	| **4-Group Categorization**	|
|:-----------------------:|:-----------------:|:---------------------------:|:---------------------------:|	 	
| A | A-Agriculture | Agriculture | Agriculture |
| B | B-Mining and quarrying | Mining | Industry |
| C | C-Manufacturing | Manufacturing | Industry |
| D | D-Electricity | Public Utilities | Industry |
| E | E-Water supply | Public Utilities | Industry |
| F | F-Construction | Construction | Industry |
| G | G-Wholesale and retale trade | Commerce | Services |
| H | H-Transportation and storage | Transport & Communication | Services |
| I | I-Accommodation and food service activities | Commerce | Services |
| J | J-Information and communication | Transport & Communication | Services |
| K | K-Financial and insurance activities | Financial & Business Services | Services |
| L | L-Real estate activities | Financial & Business Services | Services |
| M | M-Professional, scientific and technical activities | Financial & Business Services | Services |
| N | N-Administrative and support service activities | Financial & Business Services | Services |
| O | O-Public administration and defence; compulsory social security | Public Administration | Services|
| P | P-Education | Other | Other |
| Q | Q-Human health and social work activities | Other | Other |
| R | R-Arts, entertainment and recreation | Other | Other |
| S | S-Other service activites | Other | Other |
| T | T-Activities of HH as employers | Other | Other |
| U | U-Activities of extraterritorial organizations and bodies | Other | Other |

The "Major Group Letter" column is the only infomation contained in the original industry variables; "Industry Name" is from ISIC Rev.4 to match the letters in the raw datasets; "10-Group Categorization" shows how we mapped the letters in the raw datasets to our GLD variable `industrycat10` whereas "4-Group Categorization" shows mapping from 10-group to a broader level categorization. 

**Occupation**

Mapping occupational codes takes longer since SLSCO-08 and ISCO-08 have more discrepancies than industry dose. SLSCO-08 has very similar structure and classification at the major group, or the three-digit level. SLSCO-08 is mainly different from ISCO in that below each four-digit subgroup where five-digit minor groups should represent more narrowly defined occupation, the four-digit subgroup codes are repeated attached with different occupation labels. This might be an intention to include all specific occupations and keep their original occupation description that belong to a known subgroup. Although this is a significant difference from ISCO's structure, this difference in fact does not affect our mapping, as the upper-level subgroup stays unchanged.

Below is the detailed corresponding table that covers all the differences in subgroups' codes. 

| **SLSCO-08 Code**	| **SLSCO-08 Occupation**	| **ISCO-08 Code**	| **ISCO-08 Occupation**	|
|:----:|:---------:|:----:|:--------------------------:|	 	
| 0110 | Commissioned Armed Forces Officers | 100 | Commissioned Armed Forces Officers |
| 0120 | Non-commissioned Armed Forces Officers | 200 | Non-commissioned Armed Forces Officers |
| 0130 | Armed Forces Occupations Other Ranks | 300 | Armed Forces Occupations, Other Ranks |
| 2414 | Assessors | 3315 | Valuers and loss assessors |
| 3349 | Administrative and Specialized Secretaries NEC | 3340 | Administrative and specialized secretaries |
| 3360 | Other Government Associate Professionals | 3350 | Government regulatory associate professionals |
| 3441 | Artistic and Cultural Associate Professionals | 3430 | Artistic, cultural and culinary associate professionals |
| 3441 | Artistic and Cultural Associate Professionals | 3430 | Artistic, cultural and culinary associate professionals |
| 5121 | Chefs | 5120 | Cooks |
| 5122 | Cooks | 5120 | Cooks |
| 5411 | Fire Fighters | 5411 | Protective services workers |
| 5412 | Police Officers | 5411 | Protective services workers |
| 5413 | Prison Guards | 5411 | Protective services workers |

*(We will update this documentation along with LKA GLD if we get more information on correspondence tables for SLSIC and SLSCO in the future for other years. Please feel free to contact the GLD focal point (gld@worldbank.org) if you know anything that might help map Sri Lanka's industrial or occupational codes. Thanks!)*
