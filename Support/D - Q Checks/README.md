# GLD quality checks

## What the checks are

These are the quality checks for GLD, to evaluate the harmonization. They are made up of four blocks. The first checks the format and contents of the data, to make sure variables are in line with the data dictionary. The second block makes comparisons with external data sources (ILO, UN, ...) to evaluate the output being produced. The third block evaluates the missing data and whether missing cases are in line with ex-ante expectations. The fourth block makes bivariate comprisons to ensure the relationships between concepts are consistent (e.g., people with occupations classified as "Professional" mostly have higher levels of education). The last block evaluates the wage information.

## How they are run

The user needs to have a local copy of these files. Once on their system, the only code they need to to change is the "Template_Q_Checks.do" file. Specifically, defining the three "globals" in the section "01. User completed this section". These are: 

- [helper] The path to the folder containing the latest version of the helper programs which are called in section "02. Run checks", 
- [mydata] The path to the dta file the user wants to evaluate, and
- [output] The path to the folder where the checks output is to be saved.
