# Correspondences between national and international classifications

This document describes the methodology used to map national industrial and occupational codes to their international counterparts. As mentioned in the introduction page, the only national and international versions of classification confirmed are SLSIC 4 and SLSCO-08, corresponding to ISIC rev.4 and ISCO-08 respectively. Hence, `industrycat_isic` and `occup_isco` were only harmonized in years between 2013 and 2021. Both industry and occupation were harmonized at the four-digit level. Here are the complete [SLSIC](utilities/isic_isco/SLSIC_4.xlsx) and [SLSCO](utilities/isic_isco/SLSCO_08.xlsx) code lists can be accessed through the links. 

Regarding industrial classification, SLSIC 4 and ISIC rev.4 do not have any differences on the four-digit level. The original industrial codes in the raw data set can be converted to ISIc codes automatically. The harmonization process only set original codes that do not exist in the SLSIC codebook to missing.  

Mapping occupational codes takes longer since SLSCO-08 and ISCO-08 have more discrepancies than industry dose. 


*(We will update this documentation along with IDN GLD if we get more information on correspondence tables for KBJI and KBLI in the future. Please feel free to contact the GLD focal point (gld@worldbank.org) if you know anything that might help map Indonesia's industrial or occupational codes. Thanks!)*


## Correspondence in industry classification

**KBLI 1997 to ISIC Rev.3**

The KBLI-1997 document has an Indonesian version at three-digit level online for free, as the link attached above in the table. KBLI-1997 has more sub-categories than ISIC Rev.3 at three-digit level. In these cases, we mapped additional sub-categories in KBLI-1997 to their upper level. Below we listed the differences between the two classifications and how we mapped them. The full correspondence table is [here](utilities/Industry_correspondences.xlsx) with an English version of KBLI-1997 translated by online software.  

| **KBLI-1997 Code**	| **KBLI-1997 Industry**	| **ISIC Rev.3 Code**	| **ISIC Rev.3 Industry**	|
| :-----------------------:	| :---------------------------:	| :-------------:|:----------------:|	 	
| 101 | Mining of coal, peat extraction, and coal gasification | 100 | Mining of coal and lignite; extraction of peat |
| 102 | Briquette productions| 100 | Mining of coal and lignite; extraction of peat |
| 174 | Import trade, except car and motorcycle trade         | 170 |  Manufacture of textiles|
| 262 | Porcelain product industry              | 260 | Manufacture of other non-metallic mineral products |
| 263 | Clay product industry              | 260 | Manufacture of other non-metallic mineral products |
| 264 | Cement, calx and plaster, as well as cement and calx product industry | 260 | Manufacture of other non-metallic mineral products |
| 265 | Stone product industry | 260 | Manufacture of other non-metallic mineral products |
| 266 | Asbestos product industry | 260 | Manufacture of other non-metallic mineral products |
| 531 | Export trade based on fees or contract | - | (Coded missing) |
| 532 | Export trade of agricultural raw materials, live animals, food, beverages, tobacco | - | (Coded missing) |
| 533 | Export trade of textiles, clothing and household goods | - | (Coded missing) |
| 534 | Export trade of intermediate products non-agricultural products, secondhands goods and the remaining unused (scrap) | - | (Coded missing) |
| 535 | Export trade of machinery, spare parts and accessories thereof | - | (Coded missing) |
| 539 | Other export trade | - | (Coded missing) |
| 541 | Import trade based on fees or contract | - | (Coded missing) |
| 542 | Import trade of agricultural raw materials, live animals, food, beverages, and tobacco | - | (Coded missing) |
| 543 | Import trade of textiles, apparel, leather and household goods | - | (Coded missing) |
| 544 | Import trade of intermediate non-agricultural products, secondhands goods and the remaining unused (scrap) | - | (Coded missing) |
| 545 | Import trade of machinery, spare parts and accessories thereof | - | (Coded missing) |
| 549 | Other import trade | - | (Coded missing) |
| 631 | Loading and unloading of goods services | 630 | Supporting and auxiliary transport activities; activities of travel agencies |
| 632 | Warehousing, cold storage services, and bonded zone services | 630 | Supporting and auxiliary transport activities; activities of travel agencies |
| 633 | Supporting services except loading/unloading services and warehousing | 630 | Supporting and auxiliary transport activities; activities of travel agencies |
| 634 | Travel services | 630 | Supporting and auxiliary transport activities; activities of travel agencies |
| 635 | Shipping and packing services | 630 | Supporting and auxiliary transport activities; activities of travel agencies |
| 639 | Other import trade | 630 | Supporting and auxiliary transport activities; activities of travel agencies |
| 703 | Tourism destinations and water tourism provision | 700 | Real estate activities |

**KBLI 2000 to ISIC Rev.3**

The KBLI-2000 document has an English version available online. At three-digit level, it is same as KBLI-1997. So mapping different categories for KBLI-2000 to ISIC Rev.3 is same as KBLI-1997. Kindly refer to the table in the last section. 

**KBLI 2005 to ISIC Rev.3**

The KBLI-2005 document is in Indonesian but it compares not only between KBLI 2005 and ISIC Rev.3 but also between KBLI-2005 and KBLI-2009. KBLI-2005 follows the same structure as ISIC Rev.3, which has 15 major groups. The differences between KBLI-2005 and ISIC Rev.3 at two-digit level are quite rare. Here is a short list showing the differences when mapping at two-digit level. The full correspondence table is [here](utilities/Industry_correspondences.xlsx) with an English version of KBLI-2005 translated by online software.

| **KBLI-2005 Code**	| **KBLI-2005 Industry**	| **ISIC Rev.3 Code**	| **ISIC Rev.3 Industry**	|
| :-----------------------:	| :---------------------------:	| :-------------:|:----------------:|	 	
| 52 | Retail trade, except cars and motorcycles             | 52 |  Retail trade, except of motor vehicles and motorcycles; repair of personal and household goods |
| 53 | Export trade, except for trade in cars and motorcycles| 52 |  Retail trade, except of motor vehicles and motorcycles; repair of personal and household goods |
| 54 | Import trade, except car and motorcycle trade         | 52 |  Retail trade, except of motor vehicles and motorcycles; repair of personal and household goods|
| 00 | Activities that has no clear boundaries               | -  |  (Coded missing)|




## Correspondence in occupation classification
