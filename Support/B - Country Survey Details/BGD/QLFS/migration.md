# Migration Section

This page only applies for the migration code in the 2022 GLD harmonization. 

The raw microdata contains separate files for questionnaire section. The migration section is separated in quarterly files that need to be combined. However, unique identifiers of each file are not easy to match because the migration section has a different unique identifier that has not been documented to our knowledge. 

As the data is, the individuals that migrated in each household are identified with an ID code that differs to the ID code from the rest of the files. A feasible way to identify the individuals in the household that informed about their migration patterns is to match them through other individual characteristic such as age and gender, unfortunately this could lead to imprecise matching when ae or gender are the same within household. 

The GLD team tried to include the information from the migration section into the GLD harmonized version through matching with age and gender and household ID, we ended up with around 800 observations added to the master file but becasue we do not have a precise documentation onto why the IDs in the migration section are different, the team decided to drop this code and report it here for the user to decide this alternate version. 


## Proposed Code



