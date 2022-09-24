# Introduction

For the GLD, the information coded in the original PNAD surveys is converted to ISIC information at the two-digit level. This document first describes the logic of the process and then provides users with the underlying conversions tables, conversion algorithms, as well as the generated `dta` files used in the harmonization codes.

It is organized as follows: First, we give an overview of the industry classifications in PNAD and PNADC; second, we explain how it is converted to ISIC rev 3.0; finally, we discuss the major compatibilization issues.

# Overview of occupation classification used in PNAD and PNADC

Information regarding the industry respondents are employed in is coded in the Brazilian National Household Sample Survey (PNAD) using the codes of the [National Economic Activity Classification]( https://concla.ibge.gov.br/classificacoes/correspondencias/atividades-economicas.html) (Classificacão Nacional de Atividades Econômicas, CNAE), which has the same version from 1981 to 2001, then was adapted to Household National Economic Activity Classification (shortened as CNAE-Dom in Portuguese) 1.0 in 2002.

Table below summarizes the process, showing the CNAE versions, the years they are used in PNAD, and where they are been mapping to, either on the intermediate or final step.


| Year      | Classification used in raw data | Survey | Intermediate classification needed | Intermediate depth | Target classification | Target depth |
|-----------|---------------------------------|--------|------------------------------------|--------------------|-----------------------|--------------|
| 1981/2001 | CNAE 1980/1991                  | PNAD   | CNAE-DOM 1.0                       | Two Digits         | Isic rev 3            | Two Digits   |
| 2002/2011 | CNAE-DOM 1.0                    | PNAD   | --------                           | Two Digits         | Isic rev 3            | Two Digits   |



# Converting national system to international system

For the years using CNAE 1980/1991 the information is first converted to CNAE-DOM 1.0 information, using the file [`Ind_Corresp_198090s.dta`](utilities/Additional%20Data/Ind_Corresp_198090s.dta).

Then information in CNAE-Dom 1.0 is mapped to ISIC Revision 3. This last mapping is nearly perfect except for CNAE-Dom 1.0 category 53 – inexistent in ISIC – needing to be mapped to either 51 or 52.


Table below shows which codes starting with `53` are mapped to ISIC Rev 3 code `51`. All other Brazilian codes starting with `53` are mapped to ISIC REv 3 code `52`.

| Years          | Codes (original classification)                                                                |
|----------------|------------------------------------------------------------------------------------------------|
|  2002-2011     | 53010 - Commercial representatives and trade agents                                            |
|                | 53020 - Trading of agricultural products                                                       |
|                | 53066 - Trading of waste and scrap                                                             |
|                | 53067 - Trade in extractive products of mineral origin                                         |



# Issues with conversion and definitional changes

This section discusses the effects unifying to a single international classification when the underlying systems are different. The following is a non-exhaustive list of the main relevant points.

## Changes in the definition of employed population

In 1992, the definition of employed population in the PNAD was expanded. To capture certain groups of people involved in economic activity that, previously, were not included, the concept of work became more comprehensive. Thus, the concept of occupation began to encompass work in production for their own consumption, in agricultural activity and construction work for their own use. In addition, the PNAD incorporated unpaid work, regardless of the number of hours worked. Until the year 1990, unpaid work was only considered as employment only when it was performed for at least 15 hours, so there was a great expansion of the employed population in the PNAD carried out in 1992, in relation to the PNAD of 1990.

Note that, in PNADC, on the other hand, for an unpaid worker to be considered as employed, he/she must have worked at least on hour. Moreover, unpaid work in aid of a religious, charitable or cooperative institutions was no longer considered employment in PNADC, along with work in production for own consumption or in construction for own use.  Finally, in PNADC, some restrictions were introduced regarding the time of leave to consider the person as employed.


That change affected mostly agricultural and construction sectors. Therefore, there are level shifts on some groups associated with the employment definition changes in 1992 and 2012. They affected sector 01 (Agriculture), 05 (Fishery) and 90 (Mining and Construction Labourers).


## Effect of change from 1980/1991 CNAE to CNAE-Dom 1.0

### ISIC Sector 17 (Manufacture of textiles)

In 1980/1991 CNAE, there are only two codes which corresponds to manufacturing of textiles (‘240 – Manufacturing of Textiles’ and ‘241 – Household Manufacturing of Textiles’), which are (through the intermediate CNAE-Dom 1.0) mapped into 17. Regardless, employment levels in the 1990s are still considerably lower to the one observed in 2002, for no identifiable reason.

### ISIC Sector 23 (Manufacturing of derivatives of oil and alcohol)

In 1980s/1990s CNAE, manufacturing of alcohol is part of industry of chemicals.  That means that the latter has higher employment level up to 2001.


### ISIC Sectors 27 to 33

There is a lack of detail  in 1980/1991 CNAE associated with manufacturing of metals (codes 27, 28 and 29 in both CNAE-Dom 1.0 and ISIC rev. 3), for which it only had ‘110 – Metallurgy’ (mapped into 27), ‘120 – Manufacturing of Mechanics’ (mapped into 28) and ‘130 – Manufacturing of electric and communication products’ (mapped into 32). That makes sector 27 and 32 to have a higher level in the 1980s and 1990s than the following years. On the other hand, sector 28 has a lower level in the 1980s and 1990s, and there is no employment at all in this period associated to sectors 30 (Manufacture of office, accounting and computing machinery), 31 (Manufacture of electrical machinery and apparatus), 33 (Manufacture of medical, precision and optical instruments, watches and clocks).

### Sectors 34 and 35 (transport equipment)

In 1980/1991 CNAE, there is only code for manufacture of transport equipment, in contrast to ISIC 3.0, which has sector 34 (Manufacture of motor vehicles, trailers and semi-trailers) and 35 (Manufacture of other transport equipment). We map it into sector 34 , since, when splitting it into the two categories, the first corresponded to 80% of all employments in 2002.

### Sectors 51 and 93

In 1980/1991 CNAE, there are employment codes associated with sector 51 (Wholesome Trade) that are included into ‘auxiliary activities’ (codes 582, 583 and 584), which, however, also includes industries that would be mapped into sector 93 (Other service activities).  We map them into sector 51, making it to have a higher employment level up to 2001.

### Other compatibility issues

There are other minor employment level shifts observed in 2002, because of the compatibility issues from one classification to the other. Some of those have no identifiable reason, such as in sectors 63 (Supporting and auxiliary transport activities; activities of travel agencies) 70 (real estate activities) and 73 (research and development).


## Effect of change from CNAE-Dom 1.0 to CNAE-Dom 2.0

In 2012, most level shifts are due to changes from ISIC 3.0 to ISIC 4.0, which CNAE-Dom 2.0 was created to correspond to.

### Sector 24 (manufacturing of chemicals)

Some chemicals are coded as ‘manufacturing of optical, photographic and cinematographic equipment and instruments and blank, magnetic and optical media’ and ‘Other diverse products’ in CNAE-Dom 2.0, which are mapped to other sectors.

### Sector 25 (Manufacturing of rubber and plastic)

In CNAE-dom 2.0, manufacturing of plastic starts including equipment and accessories for professional safety and protection.

### Sectors 28 and 29

CNAE-Dom 2.0 included firearms and ammunition in sector 28 (Manufacture of fabricated metal products, except machinery and equipment), which was in sector 29 (Manufacture of machinery and equipment) in CNAE-Dom 1.0.

Also, in CNAE-dom 2.0, there is a new category defined as ‘Installation, maintenance and repair of machines and equipment’, which corresponds partly to manufacturing codes from 28 to 36 (excluding 30). It will arbitrarily be coded as 29.

### Sectors 37 and 90

In CNAE-Dom 2.0, ‘recycling’ (37) and ‘sewage and refuse disposal, sanitation and similar activities’ (90) were aggregated as one category.


### Sector 70 (Real Estate Activities)

In CNAE-Dom 2.0, some industries in that sector were recategorized as construction and combined services for maintenance of buildings.
