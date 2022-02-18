Education Levels: Philippines GLD
================

-   [Survey Years 1997 - 2011
    (PSCED 1997)](#survey-years-1997---2011-psced-1997)
    -   [Values Specific to PSCED 1997](#values-specific-to-psced-1997)
    -   [Notes Specific to PSCED 1997](#notes-specific-to-psced-1997)
-   [Survey Years 2012 - 2018
    (PSCED 2008)](#survey-years-2012---2018-psced-2008)
    -   [Education levels](#education-levels)
    -   [Values specific to the 2008
        PSCED](#values-specific-to-the-2008-psced)
    -   [Notes specific to 2008 PSCED](#notes-specific-to-2008-psced)
-   [Survey Years 2019 +](#survey-years-2019-)
    -   [Education Levels](#education-levels-1)
    -   [Notes specific to the 2017 PSCED
        Classification](#notes-specific-to-the-2017-psced-classification)

The following label classification explain the codification from raw survey label levels to GLD categories. Note that, according to the 2017 Philippine Standard Classification of Education document, the education system was adjusted in 2018 in accordance with new legislation, linked [here](http://www.unesco.org/education/edurights/media/docs/e119986abbd26ebda9c3d8c18929b4487205d4d6.pdf).

It appears both in the 2017 PSCED and the data labels that this change did not occur until the 2018 year, meaning that data for 2017 is still classified under the old system.

## Survey Years 1997 - 2011 (PSCED 1997)

Luckily the education levels are fairly self explanatory for the first few years. In 2008 PSCED, we see that there is no level in 1997 schema for post-secondary or “secondary but not university” level.

| PSA Labels / Ranges of Labels  | GLD Level                         | Notes |
|--------------------------------|-----------------------------------|-------|
| No Grade Completed             | No Education                      |       |
| Grade 1 - 3, Grade 4, Grade 5  | Primary Incomplete                |       |
| Elementary Graduate            | Primary Complete                  |       |
| First - Third Year High School | Secondary Incomplete              |       |
| High School Graduate           | Secondary Complete                |       |
| College Undergraduate          | University Complete or Incomplete |       |

### Values Specific to PSCED 1997

Note that in PSA documentation for [previous years](http://psada.psa.gov.ph/index.php/catalog/11/datafile/F5), values `40` - `98` refer to what appear to be completed bachelors or other advanced degrees. I code these values as `University Complete or Incomplete`.

### Notes Specific to PSCED 1997

It seems that “College” usually refers to Post-secondary/Tertiary University in the labeling since [the most recent/similar documentation](http://psada.psa.gov.ph/index.php/catalog/11/datafile/F5) makes no reference to post-secondary, non-university education.

## Survey Years 2012 - 2018 (PSCED 2008)

These survey years appear to be coded according to the 2008 Philippine Statistical Classification of Education Document, accessible [here](https://psa.gov.ph/content/philippine-standard-classification-education-psced).

### Education levels

| Group                    | Typical Age | Levels in group |
|--------------------------|-------------|-----------------|
| Primary                  | 6-11        | 6               |
| Secondary                | 12-15       | 4               |
| Post-Secondary/Technical | 16-19       | 4               |
| Tertiary/Baccalaureate   | 16-20       | 4               |
| Tertiary/Post-Grad       | 21-22       | 2+              |

| PSA Labels / Ranges of Labels                                | GLD Level \|                      | Notes                                                                                                  |
|--------------------------------------------------------------|-----------------------------------|--------------------------------------------------------------------------------------------------------|
| No Grade Completed                                           | No Education                      |                                                                                                        |
| Preschool                                                    | No Education                      |                                                                                                        |
| Grade 1 - Grade 7                                            | Primary Incomplete                | PSCED permits a 7th primary school year                                                                |
| K-12 Grade 1 - Grade 5                                       | Primary Incomplete                |                                                                                                        |
| Elementary Graduate                                          | Primary Complete                  |                                                                                                        |
| K-12 Grade 6                                                 | Primary Complete                  |                                                                                                        |
| SPED Undergraduate                                           | Primary Complete                  |                                                                                                        |
| First - Fourth Year High School                              | Secondary Incomplete              |                                                                                                        |
| K-12 Grade 7 - Grade 9                                       | Secondary Incomplete              |                                                                                                        |
| High School Graduate                                         | Secondary Complete                |                                                                                                        |
| SPED Graduate                                                | Secondary Complete                |                                                                                                        |
| K-12 Secondary Grade 10                                      | Secondary Complete                |                                                                                                        |
| K-12 Secondary Grade 11-12                                   | Post-Secondary, not University    |                                                                                                        |
| First - Third Year Post-Secondary                            | Post-Secondary, not University    |                                                                                                        |
| Basic Programs                                               | Post-Secondary, not University    | These appear to refer to various classes of Associate degree programs                                  |
| \[x\] Program                                                | Post-Secondary, not University    | PSCED lists Associate Programs in the inter-secondary-University range as they appear in the data here |
| First - Second Year Post-Secondary                           | Post-Secondary, not University    | PSCED says usually are terminal, job-preparation programs                                              |
| Post-Secondary Courses - \[x\] Course                        | Post-Secondary, not University    |                                                                                                        |
| First - Sixth Year of College                                | University Incomplete or Complete |                                                                                                        |
| College Undergraduate                                        | University Incomplete or Complete |                                                                                                        |
| Post-Baccalaureate                                           | University Incomplete or Complete |                                                                                                        |
| First - Sixth Year of College                                | University Incomplete or Complete |                                                                                                        |
| Academic Degrees of First-Stage/Baccalaureate - \[x\] Degree | University Incomplete or Complete |                                                                                                        |
| Masters, Doctorate                                           | University Incomplete or Complete |                                                                                                        |
|                                                              |                                   |                                                                                                        |

### Values specific to the 2008 PSCED

Note that PSA documentation for [other years in the same schema](http://psada.psa.gov.ph/index.php/catalog/175/datafile/F1) lists values between `502` and `689` as various completed degrees for associate-level, pre-professional programs. I will assume these values refer to these same programs, and code them as `Post-Secondary, not University`.

### Notes specific to 2008 PSCED

Some years contain two education grade variables that appear to correspond to the grade level under the 1997 and 2008 classification schemas – ie, two variable in the same survey round or data file. Sometimes this varible is called `c09_grd` for the old schema and usually the variable for the new schema is called `j12c09_grade`. While
it may be convenient to use the 1997-schema variable, I decided to use the 2008-year one (usually the `j12c09_grade`) because it wasn’t clear that all years contained the 1997 year cognate variable and because, in theory, these years should be classified under the new schema anyway.

Furthermore, some years, such as 2016, have various names for the “highest grade completed” variable for within-year rounds, but *usually* only one variable in each file, but not always. We have to be very mindful of the variable names that refer to the new, 2008 coding schema and the old coding schema. An easy way to distinguish is the new coding schema variable has far more numeric or factor levels. In 2016, we want to use `j12c09_grade` in the January round, (not `c09_grd`), `pufc07_grade` in April, July, and October rounds.

#### Additional Notes for survey year 2016

Once the variable names for 2016 have been harmonized, the values themselves differ across rounds/months within 2016. (A small caveat is that the January values are labelled factors whereas the following three rounds are unlabeled integers, but the January values have integer values behind the labels, and these numeric values are the values to which I’m referring.)

The numeric values for January and April coincide; values for July and October coincide, but these two groups of values differ from each other. The January/April group most closely aligns with the 2016 survey published by the PSA. Since the July/October values have no value labels and there’s no reasonable inference to classify the values, I’m only going to categorize education for the first two rounds and leave the observations for July and October as missing for the time being.

#### Additional Notes for survey year 2017

All rounds for 2017 seems to follow the same numeric schema set in the July/October grouping of 2016. However, the situation is slightly different from that of 2016: all rounds/months have the same numeric values and the values labels do not contain key levels such as those that indicate secondary completion. Furthermore, there is descriptive evidence to assume that the values in 2017 are the same “meaning” as the values in 2018, which are labelled and follow about the same distribution and value pattern. `Education_2017_Checks.Rmd` produces this evidence by comparing the distribution of values for education attainment in 2017 and 2018. For the time being, I will assume that, without complete value labels in 2017, that the similarly-distributed values in 2018 will suffice.

#### Additional Notes for survey year 2018

All relevant raw “grade” variables are in labelled factor form, so no cross-checking of numeric/factor data types is needed as in 2016. 

## Survey Years 2019 +

These survey years follow the newest PSA classification for [2017](https://psa.gov.ph/content/philippine-standard-classification-education-psced). The biggest difference in these years is the inclusion of two additional years in secondary school.

### Education Levels

Note that Secondary now includes 4 years of Junior High School and 2 years of Senior High School. Also, this classification scheme specifically denotes tracks for special needs education, but does not provide enough information for our classification requirements.

The big unknown is K-12 Programs. The 2017 PSCED doesn’t have any explicit information on what should be done with K-12 programs. For now, I will simply make the assumption that `grade 1` in K-12 corresponds to `grade 1` in the chart below. I will also assume that if the student has completed `grade 6` and `grade 12` then they have completed Primary and Secondary respectively, since under the new schema, secondary has been expanded from 4 to 6 years, which would correspond to grade 12.

| Group                       | Typical Age | Levels in group |
|-----------------------------|-------------|-----------------|
| Pre-Primary                 | 5           | 1               |
| Primary                     | 6-11        | 6               |
| Secondary                   | 12-18       | 6               |
| Post-Secondary non-tertiary |             |                 |
| Short-Cycle Tertiary        |             |                 |
| Bachelors                   |             |                 |
| Masters                     |             |                 |
| Doctorate                   |             |                 |

| PSA Labels / Ranges of Labels                                | GLD Level \|                      | Notes                                   |
|--------------------------------------------------------------|-----------------------------------|-----------------------------------------|
| No Grade Completed                                           | No Education                      |                                         |
| Preschool                                                    | No Education                      |                                         |
| Kindergarten                                                 | No Education                      | PSCED says Primary begins at grade 1    |
| IPed / SPED (lower value)                                    | Primary Incomplete                | No info on completion                   |
| Grade 1 - Grade 7                                            | Primary Incomplete                | PSCED permits a 7th primary school year |
| Grade 6 or Grade 7 Graduate                                  | Primary Complete                  |                                         |
| IPed / SPED (higher value)                                   | Primary Incomplete                | No info on completion                   |
| Elementary Graduate                                          | Primary Complete                  |                                         |
| Grade 7 - 9 / First - Third Year High School                 | Secondary Incomplete              |                                         |
| Grade 10 / High School Graduate                              | Secondary Incomplete              |                                         |
| Grade 11, \[x\] Track                                        | Secondary Incomplete              |                                         |
| Grade 12, \[x\] Track                                        | Secondary Complete                | In new schema, Secondary is 6 years     |
| Basic Programs, Certificates, 40000- and 50000-level degrees | Post-Secondary, Non-University    |                                         |
| Undergraduate, Basic Programs or Equivalent                  | University Incomplete or Complete |                                         |
| Masters, 70000 level                                         | University Incomplete or Complete |                                         |
| Doctorate, 80000 level                                       | University Incomplete or Complete |                                         |

### Notes specific to the 2017 PSCED Classification

Similar to some of the years in the 2008 PSCED Classification above, some survey years have values within the same year, between different-month rounds that do not correspond. Also similarly, some of these “mismatched” values are labelled, and some are not.

#### Additional Notes for survey year 2019

The first two rounds of 2019, January and April, are factor labelled data types and the second two, July and October, are integer, without labels. The underlying value labels for all may, in theory, be the same. However, the underlying values for the first two rounds are slightly different than those of the second two. The PSCED 2017 codebooks is uite extensive and clear that the values and labels for the first two rounds are *almost* exactly correct, expect for a few exception in early school year groupings: it appears that the some education categories have been grouped and the resulting grouping has been formed into a numeric value that does not appear in the codebook.

For example, instead of listing out the “raw” values for grade 1, grade 2, grade 3, grade 4, and grade 5 – and making labels for each – the data has been constructed with a “new” value `y` that represents “grades 1-5” with a label such as “Grades 1-5”. Neither this value nor label appear in the 2017 PSCED, nor the numeric versions of the variables in other rounds. The original values that represent grades 1, grades 2, grades 3, etc do not appear in the factor labelled data variables, nor is there an
“original” integer variable available.

This “grouping” appears to have been constructed for: - grades 1 - 5 - grades 7 - 9

Furthermore, there are key non-grouped levels that, similarly, do not appear in the 2017 PSCED codebook, including those for: - Grade 10, but whose value *does not* appear in the integer data for other rounds - Grade 11, and whose value *does* appear in the integer data for other rounds - Grade 12, and whose value *does* appear in the integer data for other rounds

Additionally, for the integer-labelled data (July and October rounds), there are a number of numeric values that do not appear in the PSCED 2017 Codebook, similarly to the 2008 Schema situation. While many of these values could be inferred based on patterns and counts from previous years (ie, clusters of digits that end in 1, 2, and 3 refer to primary grades 1, 2, and 3), there’s no way to confirm these inferences – they are merely guesses without some sort of documentation evidence.

For the time being, I am simply going to leave the education levels missing for the final two rounds until more information can be gathered, which seems the safest choice for now. Thus, I will only code based on the labelled factor/January and April rounds initially.
