# Introduction

The information on occupation coded in the original surveys is converted in GLD to ISCO-88 information at two digits. This document describes the logic of the process and then provides users with the underlying conversions tables as `dta` files used in the harmonization codes.

It is organized as follows: First, we give an overview of the occupation classifications in PNAD and PNADC; second, we explain how it is converted to ISCO-88; finally, we discuss the major compatibilization issues.

# Overview of occupation classification used in PNAD and PNADC

Information regarding which occupation respondents are employed in is coded in the Brazilian National Household Sample Survey (PNAD) using the codes of the [Brazilian Classification of Occupations](https://concla.ibge.gov.br/documentacao/cronologia/cbo.html) (CBO, in Portuguese).

Table below shows the CBO versions, the years they are used in PNAD, and where they are been mapping to.

| Years     | Classification used in raw data | Target classification | Target depth
|-----------|---------------------------------|-----------------------|--------------|
| 1981/1990 | CBO 1980                        | ISCO 1988             | Two Digits   |
| 1992/2001 | CBO 1991                        | ISCO 1988             | Two Digits   |
| 2002/2011 | CBO Domiciliar (CBO-Dom)        | ISCO 1988             | Two Digits   |

# Converting national system to international system

The overall mapping is done in one step. We use three different `.dta` to carry out the harmonization at the 2 digits level. That is to merge in the correspondence table when harmonizing and use matched ISCO codes to generate the GLD `occup_isco` variable. The [`isco_88_cbo_80_DD.dta`](utilities/Additional%20Data/isco_88_cbo_80_DD.dta) maps 1981-1990 PNADs occupation codes to ISCO-88, while files [`isco_88_cbo_91_DD.dta`](utilities/Additional%20Data/isco_88_cbo_91_DD.dta), and [`isco_88_cbo_dom_DD.dta`](utilities/Additional%20Data/isco_88_cbo_dom_DD.dta) do the same for 1992-2001 PNADs and 2002-2011 PNADs, respectively.

# Issues with conversion and definitional changes

This section discusses the effects unifying to a single international classification when the underlying systems are different. The following points are just examples.

## Changes in the definition of employed population

In 1992, the definition of employed population in the PNAD was expanded. To capture certain groups of people involved in economic activity that, previously, were not included, the concept of work became more comprehensive. Thus, the concept of occupation began to encompass work in production for their own consumption, in agricultural activity and construction work for their own use. In addition, the PNAD incorporated unpaid work, regardless of the number of hours worked. Until the year 1990, unpaid work was only considered as employment only when it was performed for at least 15 hours, so there was a great expansion of the employed population in the PNAD carried out in 1992, in relation to the PNAD of 1990.

Note that in PNADC, on the other hand, for a unpaid worker to be considered as employed, he/she must have worked at least on hour. Moreover, unpaid work in aid of a religious, charitable or cooperative institutions was no longer considered employment in PNADC, along with work in production for own consumption or in construction for own use. Finally, in PNADC, some restrictions were introduced regarding the time of leave to consider the person as employed.


That change affected mostly agricultural and construction workers. Therefore, there are level shifts on some groups associated with the employment definition changes in 1992 and 2012. They affected group 62 (Subsistence Agricultural and Fishery Workers), 92 (Agricultural, Fishery and Related Labourer) and 93 (Mining and Construction Labourers).


## Effect of change from CBO 1980/1991 to CBO-dom

### Group 11 (Legislators and Senior Officials)

There is an aggregated code in CBO 1980/1991, denominated '21 - Directors, assessors and chief executives in the public service' which includes mostly occupations that should be mapped into group 11, but also others that should be mapped into other categories (especially in major groups 2 and 3). Therefore, as we map it into group 11, employment level is higher up to 1990 in comparison to later years.

### Group 33(Teaching Associate Professionals)

In CBO 1980/1991, there is only one category which can be mapped into Group 33, whereas there are more of those in listed in CBO-dom and COD.

### Group 81 (Stationary-Plant and Related Operators)

In CBO-dom, there is a more detailed and longer list of occupation categories which maps into this group, artificially increasing it compared to the other classifications.


## Effect of change from CBO-dom to COD

### Major Group 1 (Legislators, Senior Officials and Managers)

In PNADC, employment level in major group 1 (which maps perfectly to ISCO) is considerably higher than in PNAD, although they correspond to the same occupations.

### Group 81 (Stationary-Plant and Related Operators)

In CBO-dom, there is a more detailed and longer list of occupation categories which maps into this group, artificially increasing it compared to the other classifications.
