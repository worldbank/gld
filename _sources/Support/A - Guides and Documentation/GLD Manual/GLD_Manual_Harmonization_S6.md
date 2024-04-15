# Education

## Mapping and Description of Variables

### ed_mod_age

Codifies the minimum age for which education questions are asked. For example, if education information is only requested from those 4 years and older the variable should be set to 4.

### school

Codifies whether the person is currently (i.e., at the time of the survey) attending formal education. The codes are:

0 = No

1 = Yes

### literacy

Codifies whether person can read and write in at least one language. The codes are:

0 = No

1 = Yes

### educy

Codifies the number of years spent in education.

### educat7

Classifies the highest level of education attained by the respondent to seven levels. The codes are:

1 = No education

2 = Primary incomplete

3 = Primary complete

4 = Secondary incomplete

5 = Secondary complete

6 = Higher than secondary but not university

7 = University incomplete or complete

The concept of secondary complete includes all students who have had attended at least one year (complete or incomplete) of upper secondary education (as defined in the ISCED Mappings of UNESCO). That is attendance and completion of “junior high” shall be coded as secondary incomplete while attendance to “senior high school” even if for one year, will be coded as secondary complete.

### educat5

Classifies the highest level of education attained by the respondent to five levels. The codes are:

1 = No education

2 = Primary incomplete

3 = Primary complete but secondary incomplete

4 = Secondary complete

5 = Some tertiary/post-secondary

### educat4

Classifies the highest level of education attained by the respondent to four levels. The codes are:

1 = No education

2 = Primary (complete or incomplete)

3 = Secondary (complete)

4 = Tertiary (complete or incomplete)  

Note: Code as primary education anyone who has undergone some schooling but has not finished secondary education.

### educat_orig

Original education code as in the raw survey data. If the original survey has a single variable coding the education information, simply copy (gen educat_orig = survey_education_var).

If the survey has two or more variables that need to be used to codify education, leave this missing and – if possible – make a note both in the do code and in the survey introduction notes.

As an example, below is the codification in the Mexican LFS. Here, education is both a grade (part 1 of question 13) and the number of years spent in that grade (part 2). In such a case _educat_orig_ is to be left missing.

<br></br>
![Example of how educat orig is in MEX questionnaire](images/vars_educat_orig.png.png)
<br></br>


### educat_isced

Code of the highest educational level attained as per the International Standard Classification of Education (ISCED). Note that the preamble to the harmonization code should record what version of ISCED is being used.

Moreover, the code should always be as long as the longest depth available for the ISCED version. For example, the latest version at the time of writing (ISCED 2011) has up to three digits. Where the first digit is the level, the first two digits are the category, and all three digits codify the sub-category.

As an example, level 2 codifies “Lower secondary education”, 24 “Lower secondary general education”, and 242 “Sufficient for partial level completion, without direct access to upper secondary education”. Every code should be three digits long. If we only know the level (here 2) add two zeroes after it (here: 200). If we only have the category information (here 24) add a zero to reach three digits (here 240).

## Lessons Learned and Challenges

Text

## Tabular Overview of Variables

| Module Code | Variable name | Variable label | Notes |
| --- | --- | --- | --- |
| Education | ed_mod_age | Education module minumum age | &nbsp; |
| Education | school | Currently in school | &nbsp; |
| Education | literacy | Individual can read and write | &nbsp; |
| Education | educy | Years of education | &nbsp; |
| Education | educat7 | Level of education 7 categories | No option for "Other", as opposed to I2D2, anything not in these categories is to be set to missing |
| Education | educat5 | Level of education 5 categories | &nbsp; |
| Education | educat4 | Level of education 4 categories | &nbsp; |
| Education | educat_orig | Original education code | Code if there is a single original education variable (as is in most cases). If there are two or more variables, leave missing, make a note of it. |
| Education | educat_isced | International Standard Classification of Education (ISCED A) | Codes are for example:  <br><br/>2 Lower secondary education  <br>24 General  <br>242 Partial level completion, without direct access to upper secondary education  <br><br/>Should be coded as 200, 240, and 242 respectively. |

