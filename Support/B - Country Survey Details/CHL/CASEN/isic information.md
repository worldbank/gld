# INDUSTRY CLASSIFICATION INFORMATION

The CASEN is not a labour survey, yet it contains relevant information to the industry people work in thanks to the labour section. Below relevant issues to take in consideration while using the information harmonized. 

## ISIC versions per year

 Year	| ISCO Version | 
| :-------	| :-------- | 
| 1990	| No international correspondance*	|
| 1992-2009	| ISIC REV 2 	|
| 2011-2017	| ISIC REV 3	|

\* Check the [following file](https://github.com/worldbank/gld/blob/75228785e9686eae7bd0ea6d77988c4aaed4d647/Support/Country%20Survey%20Details/CHL/CASEN/utilities/Version%201990%20CASEN%20ISIC.xlsx) to get the codes used in 1990. For 1990 the NSO created a classification that differs from the international classification.

There is a website from the INE that states a [new Chilean ISIC (CIIU) version](https://www.ine.cl/institucional/buenas-practicas/clasificaciones), but no information in the CASEN documentation suggests these were used in the survey. 

## How many digits has ISIC?
Not all years have 4 digits in the raw database, we harmonized everything to 4 digits but note that the table below provides an insight on the original files.

 Year	| ISCO Version | 
| :-------	| :-------- | 
| 1990	|  2 digits*|
| 1992-1996	| 3 digits	|
| 1998-2017	| 4 digits	|

\* This is in reference to the Chilean CASEN national industry classification.

## About codes that do not match international ISIC classification

The harmonization team lists the codes that are present in the raw data ISIC classification but are absent of the ISIC international classification. We named them in the do files for reference. The team does not have a clear answer as to why these codes where placed where they are but the quantity of occurrences is not significant. 
