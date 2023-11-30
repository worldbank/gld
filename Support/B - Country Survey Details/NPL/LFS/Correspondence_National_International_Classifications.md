# Correspondences between national and international classifications

This document describes the methodology used to map national industrial and occupational codes to their international counterparts. Two versions of the International Standard Industrial Classification (ISIC) and International Standard Classification of Occupations (ISCO) were used in NPL 1998, 2008, and 2017. Accordingly, there are two sets of national classifications that correspond to each version of international classification: *Nepal Standard Industrial Classification* (NSIC) and *Nepal Standard Classification of Occupation* (NSCO). But we do not have the specific number of the of NSIC's and NSCO's versions. The international version used in each year and their counterparts with links to their official documents are listed below. Please note that 1998 and 2008 use the same international and national classifications. Since we do not have the specific version name of NSIC and NSCO, NSIC and NSCO are named after the year in the table. 

| **Year**	| **ISIC** | **NSIC** | **ISCO** | **NSCO** |  
| :-------:	| :------: | :-------:| :-------:| :-------:| 
| [1998](utilities/2008_classification.pdf)  | ISIC Rev.3 | NSIC 1998 & 2008 | ISCO-88 | NSCO 1998 & 2008 | 
| [2008](utilities/2008_classification.pdf)  | ISIC Rev.3 | NSIC 1998 & 2008 | ISCO-88 | NSCO 1998 & 2008 | 
| [2017](utilities/2017_classification.pdf)  | ISIC Rev.4 | NSIC 2017 | ISCO-08 | NSCO 2017 | 


In general, we only mapped 1994-2018 as earlier years like 1989-1993 do not have two-digit industrial or occupational codes; and recent year, 2019, only has one-digit variables which directly corresponds to the top level of ISIC/ISCO. 

Years between 2011 and 2015 have multiple variables using different versions of KBJI and KBLI at different digital levels. The decision rule for choosing one version is *the newest version with at least two digits*.


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


![IDN_occup_time_series](utilities/IDN_occup.png)

The mapping algorithm, which divides assignments by education level for greater accuracy, [can be found here](utilities/Additional%20Data/mapping_idn_occup.do), the outputted `.dta` file used to do the mapping [at three digits can be downloaded](utilities/Additional%20Data/kji_corresp_3d.dta) and [here at two digits](utilities/Additional%20Data/kji_corresp_2d.dta).
