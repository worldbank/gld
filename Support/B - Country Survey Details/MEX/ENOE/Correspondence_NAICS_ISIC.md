# Correspondence of Mexican Industry Classification to International Codes

## Overview of industry codes used in ENOE(-N)

The below table shows the classifications used at different points in time in the ENOE(-N) surveys to code the industry workers are in. 

| From     | To      | Survey | Version Used | Notes                                         |
| -------- | ------- | ------ | -------------| --------------------------------------------- |
| Q1 2005  | Q2 2012 | ENOE   | SCIAN 04     |                                               |
| Q3 2005  | Q4 2022 | ENOE   | SCIAN 07     | ENOE de facto not run from Q2 2020 to Q4 2022 |
| Q3 2020  | Q2 2021 | ENOE-N | SCIAN 07     |                                               |
| Q3 2021  | Q4 2022 | ENOE-N | SCIAN 18     |                                               |
| Q1 2023  | Current | ENOE   | SCIAN 18     |                                               |

## Detail of classification

The SCIAN (NAICS in the English acronym) is a detailed system of organising industry shared by Mexico, the United Stated of America, and Canada. It reaches six levels of (six digits) of aggregation, going from broad categories to narrow niches. Given that the survey only uses people's descriptions of their work and transforms these into codes, the Mexican statistical offices (INEGI) chose to use a reduced, idiosyncratic classification system (of around 180 distinct codes).

## Source of information

The codes used for SCIAN 07 and SCIAN 18 are available online on the INEGI website. Users can find it [here](https://www.inegi.org.mx/programas/enoe/15ymas/#documentacion) under the drop down menu option "Clasificadores" (Classifiers). 

We have, moreover, received comparison tables between [Scian 2004 and 2007](utilities/Tabla%20comparativa%20SCIAN-2004%20y%202007.xlsx) and between [SCIAN 2007 and 2018](utilities/Tabla%20comparativa%20SCIAN%202007%20-%202018.xlsx) from INEGI after reaching out to the (very helpful) team in Mexico. 

## Processing of information

The correspondence tables where converted into separate files for each SCIAN version. Then the codes were manually recoded to the 4th revision of ISIC. The individual files are avaiable for [SCIAN 04](utilities/ENOE_SCIAN_2004_Codes.xslx), [SCIAN 07](utilities/ENOE_SCIAN_2007_Codes.xslx), and [SCIAN 18](utilities/ENOE_SCIAN_2018_Codes.xslx). These are converted into `.dta` files using Stata do files ([for 2004](utilities/Convert_SCIAN_04_ISIC_4_to_dta.do), [for 2007](utilities/Convert_SCIAN_07_ISIC_4_to_dta.do), and [for 2018](utilities/Convert_SCIAN_18_ISIC_4_to_dta.do)). The `.dta` files are also made available ([for 2004](utilities/SCIAN_04_ISIC_4.dta), [2007](utilities/SCIAN_07_ISIC_4.dta), and [2018](utilities/SCIAN_18_ISIC_4.dta)).