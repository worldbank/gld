# Correspondences between national and international classifications

This document describes the methodology used to map national industrial and occupational codes to their international counterparts. As mentioned in the introduction page, the only national and international versions of classification confirmed are SLSIC 4 and SLSCO-08, corresponding to ISIC rev.4 and ISCO-08 respectively. Hence, `industrycat_isic` and `occup_isco` were only harmonized in years between 2013 and 2021. Both industry and occupation were harmonized at the four-digit level. Here are the complete [SLSIC](utilities/isic_isco/SLSIC_4.xlsx) and [SLSCO](utilities/isic_isco/SLSCO_08.xlsx) code lists can be accessed through the links. 

**Industry**

Regarding industrial classification, SLSIC 4 and ISIC rev.4 do not have any differences on the four-digit level. The original industrial codes in the raw data set are already four-digit and thus can be converted to ISIc codes automatically. The harmonization process only set original codes that do not exist in the SLSIC codebook to missing.  

**Occupation**

Mapping occupational codes takes longer since SLSCO-08 and ISCO-08 have more discrepancies than industry dose. SLSCO-08 has very similar structure and classification at the major group, or the three-digit level. SLSCO-08 is mainly different from ISCO in that below each four-digit subgroup where five-digit minor groups should represent more narrowly-defined occupation, the four-digit subgroup codes are repeated attached with different occupation labels. This might be an intention to include all specific occupations and keep their original occupation description that belong to a known subgroup. Although this is a significant difference from ISCO's structure, this difference in fact does not affect our mapping, as the upper level subgroup stays unchanged.

Below is the detailed corresponding table that covers all the differences in subgroups' codes. 

| **SLSCO-08 Code**	| **SLSCO-08 Occupation**	| **ISCO-08 Code**	| **ISCO-08 Occupation**	|
|:----:|:---------:|:----:|:--------------------------:|	 	
| 2414 | Assessors | 3315 | Valuers and loss assessors |
| 3349 | Administrative and Specialized Secretaries NEC | 3340 | Administrative and specialized secretaries |
| 3360 | Other Government Associate Professionals | 3350 | Government regulatory associate professionals |
| 3441 | Artistic and Cultural Associate Professionals | 3430 | Artistic, cultural and culinary associate professionals |

*(We will update this documentation along with LKA GLD if we get more information on correspondence tables for SLSIC and SLSCO in the future for other years. Please feel free to contact the GLD focal point (gld@worldbank.org) if you know anything that might help map Sri Lanka's industrial or occupational codes. Thanks!)*
