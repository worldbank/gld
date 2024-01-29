# Correspondences between national and international classifications

This document describes the methodology used to map national industrial and occupational codes to their international counterparts. As mentioned in the introduction page, the only national and international versions of classification confirmed are SLSIC 4 and SLSCO-08, corresponding to ISIC rev.4 and ISCO-08 respectively. Hence, `industrycat_isic` and `occup_isco` were only harmonized in years between 2013 and 2021. Both industry and occupation were harmonized at the four-digit level. Here are the complete [SLSIC](utilities/isic_isco/SLSIC_4.xlsx) and [SLSCO](utilities/isic_isco/SLSCO_08.xlsx) code lists can be accessed through the links. 

**Industry**

Regarding industrial classification, SLSIC 4 and ISIC rev.4 do not have any differences on the four-digit level. The original industrial codes in the raw data set are already four-digit and thus can be converted to ISIC codes automatically. The harmonization process only set original codes that do not exist in the SLSIC codebook to missing.  

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
| 5414 | Security Guards | 5411 | Protective services workers |
| 5415 | Home Guards | 5411 | Protective services workers |
| 5416 | Drivers | 5411 | Protective services workers |
| 5419 | Protective Service Workers NEC | 5411 | Protective services workers |
| 6111 | Field Crops and Vegetable Growers  (Excluding Cereal Crops, Estate Crops and Minor Export Crops) - Market -oriented | 6110 | Market gardeners and crop growers |
| 6112 | Cereal Crop Cultivators (Excluding Paddy) (Market -oriented) | 6110 | Market gardeners and crop growers |
| 6113 | Paddy Cultivators (Market -oriented) | 6110 | Market gardeners and crop growers |
| 6114 | Tea Cultivators (Market -oriented) | 6110 | Market gardeners and crop growers |
| 6115 | Rubber Cultivators (Market -oriented) | 6110 | Market gardeners and crop growers |
| 6116 | Coconut Cultivators (Market -oriented) | 6110 | Market gardeners and crop growers |
| 6117 | Minor Export Crops Cultivators (Market -oriented) | 6110 | Market gardeners and crop growers |
| 6118 | Gardeners, Horticultural and Nursery Growers (Market -oriented)| 6110 | Market gardeners and crop growers |
| 6119 | Mixed Crops Growers (Market -oriented)| 6110 | Market gardeners and crop growers |
| 6222 | Ornamental Fish Workers (Market -oriented)| 6220 | Fishery workers, hunters and trappers |
| 6223 | Inland Water Fishery Workers (Market -oriented)| 6222 | Inland and coastal waters fishery workers |
| 6224 | Inland Water Fishery Workers (Market -oriented)| 6222 | Inland and coastal waters fishery workers |
| 6225 | Deep-sea Fishery Workers (Market -oriented) | 6223 | Deep-sea fishery workers |
| 6226 | Hunters and Trappers (Market -oriented) | 6224 | Hunters and trappers |
| 6311 | Agricultural Farm Supervisors | 2132 | Farming, forestry and fisheries advisers |
| 6312 | Forestry Supervisors | 2132 | Farming, forestry and fisheries advisers |
| 6320 | Fishery Supervisors  | 2132 | Farming, forestry and fisheries advisers |
| 6330 | Livestock and Dairy Farm Supervisors   | 2132 | Farming, forestry and fisheries advisers |
| 6411 | Subsistence Crop Farmers | 6310 | Subsistence crop farmers |
| 6412 | Subsistence Crop Farmers NEC | 6310 | Subsistence crop farmers |
| 6420 | Subsistence Livestock Farmers | 6320 | Subsistence livestock farmers |
| 6430 | Subsistence Mixed Crop and Livestock Farmers | 6330 | Subsistence mixed crop and livestock farmers |
| 6440 | Subsistence Fishers, Hunters, Trappers and Gatherers | 6340 | Subsistence fishers, hunters, trappers and gatherers |
| 7116 | Masons (General) | 7110 | Building frame and related trades workers |
| 7517 | Other Products  Makers | 7510 | Food processing and related trades workers |
| 8213 | Electronic Equipment Assemblers | 8210 | Assemblers |
| 8214 | Metal, Rubber and Plastic Products Assemblers | 8210 | Assemblers |
| 8215 | Wood and Related  Products Assemblers| 8210 | Assemblers |
| 8216 | Paperboard, Textile and Related Products Assemblers| 8210 | Assemblers |
| 8321 | Motor  Cycle Drivers | 8320 | Car, van and motorcycle drivers |
| 9217 | Garden and Horticultural Labourers | 9210 | Agricultural, forestry and fishery labourers |
| 9218 | Forestry Labourers | 9210 | Agricultural, forestry and fishery labourers |
| 9219 | Fishery and Aquaculture Labourers | 9210 | Agricultural, forestry and fishery labourers |
| 9322 | Other Manufacturing Labourers | 9320 | Manufacturing labourers |
| 9335 | Transport Labourers | 9330 | Transport and storage labourers |





*(We will update this documentation along with LKA GLD if we get more information on correspondence tables for SLSIC and SLSCO in the future for other years. Please feel free to contact the GLD focal point (gld@worldbank.org) if you know anything that might help map Sri Lanka's industrial or occupational codes. Thanks!)*
