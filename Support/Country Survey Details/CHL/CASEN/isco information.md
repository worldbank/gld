
# OCCUPATION CATEGORIES IN CASEN

The CASEN is not a labour survey, yet it contains a dedicated labour section with a short list of questions that describe the labour status of the surveyed population. The labour section follows the ICLS-13 and ICLS-19 question designs and uses the ISCO accepted classification for most of the years.
Below we will describe the ISCO information available in the data harmonized following the documentation available in the official CASEN website.  Wherever posible we will provide details for the user, yet as some of the information publicly available is limited we encourage the user to get in touch with the INE or the Ministry of Social Development to get a more detailed breakdown. 

## List of ISCO version per year

 Year	| ISCO Version | 
| :-------	| :-------- | 
| 1990	| Not Available	|
| 1992-2017	| ISCO 1988	|

The documentation reveals that the CASEN works with the 1988 ISCO codes, yet there is not clarity onto whether the classification in the years 2011 onwards represents the 1988 ISCO or a version created by the INE for the survey.

There is a website from the INE that states a [new Chilean ISCO (CIUO) version](https://www.ine.cl/institucional/buenas-practicas/clasificaciones), but no information in the CASEN documentation suggests these were used in the survey. Furthermore, in the [documentation of CASEN](http://observatorio.ministeriodesarrollosocial.gob.cl/storage/docs/casen/2017/Libro_de_Codigos_Casen_2017.pdf) for the year 2017, it is stated that the ISCO classification used is ISCO 1988 (see page 252) with no further details on national versions. 


## About codes that do not match the international ISCO classification

The years with occupation classification information have glitches on the labelling. Example:


ISCO 88 (ILO)	| ISCO 88 (CASEN) | 
| :-------	| :-------- | 
| 1	| 100	|
| 12	| 120|
| 122	| 122|


Figure 1. Shows that in the left side the ISCO classification has three levels represented by the number of digits in each. Yet in the right side we can see that the information in the raw CASEN files give us no difference in the number of digits so it is natural to confuse many of the digits with zero at the end as part of the last digit group, instead these are the upper digit classifications. In the harmonization point out this abnormalities in the do files.

