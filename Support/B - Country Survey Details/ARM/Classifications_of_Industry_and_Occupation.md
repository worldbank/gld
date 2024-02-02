# Classifications of Industry and Occupation of Armenian Labour Force Survey

As mentioned in the introduction page, the classifications of industry and occupation applied in ARM LFS are single-version international classifications and they only used the major groups classified by letters. This document will briefly describe the harmonization process and provide the complete lists of industry and occupation letters along with their labels. 

**Industry ISIC Rev.4**

All years used ISIC Rev.4 in the raw datasets. Hence, all their original industry variables contain the same categories as follows:

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

The "Major Group Letter" column is the only information contained in the original industry variables; "Industry Name" is from ISIC Rev.4 to match the letters in the raw datasets; "10-Group Categorization" shows how we mapped the letters in the raw datasets to our GLD variable `industrycat10` whereas "4-Group Categorization" shows mapping from 10-group to a broader level categorization, `industrycat4`. 

**Occupation ISCO-08**

In the same sense as industry, all years used ISCO-08 for occupation in the raw datasets. Hence, all their original occupation variables contain the same categories as follows:

| **Major Group Number**	| **Occupation Name**	| **Skill Level**	|
|:-----------------------:|:-------------------:|:-----------------:|
| 1 | 1. Managers | Skill Level 3 and 4 (high)|
| 2 | 2. Professionals | Skill Level 3 and 4 (high)|
| 3 | 3. Technicians and associate professionals | Skill Level 3 and 4 (high)|
| 4 | 4. Clerical support workers | Skill Level 2 (medium)|
| 5 | 5. Service and sales workers | Skill Level 2 (medium)|
| 6 | 6. Skilled agricultural, forestry and fishery workers | Skill Level 2 (medium)|
| 7 | 7. Craft and related trades workers | Skill Level 2 (medium)|
| 8 | 8. Plant and machine operators, and assemblers | Skill Level 2 (medium)|
| 9 | 9. Elementry occupations | Skill Level 1 (low)|

Unlike industry for which we harmonized `industrycat10` and `industrycat4`, we only coded `occup_skill` for occupation. And the last column "Skill Level" shows the correspondence. 
