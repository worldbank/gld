# Education Levels Codification

The following label classification explain the codification from raw survey label levels to I2D2 categories. Note that, according to the 2017 Philippine Standard Classification of Education document, the education system was adjusted in 2018 in accordance with new legislation, linked [here](http://www.unesco.org/education/edurights/media/docs/e119986abbd26ebda9c3d8c18929b4487205d4d6.pdf). It appears both in the 2017 PSCED and the data labels that this change did not occur until the 2018 year, meaning that data for 2017 is still classified under the old system.

## Survey Years 1997 - 2011 (PSCED 1997)
Luckily the education levels are fairly self explanatory for the first few years. In 2008 PSCED, we see that there is no level in 1997 schema for post-secondary or "secondary but not university" level.

 PSA Labels  / Ranges of Labels                 |   I2D2 Level | Notes |
|----------------------------------------|----------------------------|-------------------------|
|  No Grade Completed       |     No Education                        |
|   Grade 1 - 3, Grade 4, Grade 5 |  Primary Incomplete        |  
|   Elementary Graduate           |   Primary Complete                    |
|   First - Third Year High School      |    Secondary Incomplete       |
| High School Graduate  | Secondary Complete | 
| College Undergraduate | University Complete or Incomplete |


## Survey Years 2012 - 2018 (PSCED 2008)
These survey years appear to be coded according to the 2008 Philippine Statistical Classification of Education Document, accessible [here](https://psa.gov.ph/content/philippine-standard-classification-education-psced).

### Education levels

| Group | Typical Age | Levels in group |
|------|--------------|-----------------|
|Primary| 6-11| 6 |
|Secondary| 12-15 | 4 |
|Post-Secondary/Technical| 16-19 | 4 |
|Tertiary/Baccalaureate| 16-20 | 4 |
|Tertiary/Post-Grad | 21-22| 2+ |

| PSA Labels  / Ranges of Labels                 |   I2D2 Level | Notes |
|----------------------------------------|----------------------------|-------------------------|
|  No Grade Completed       |     No Education                        |
|  Preschool                |      No Education     |                    
|   Grade 1 - Grade 7                       |  Primary Incomplete        | PSCED permits a 7th primary school year |
| K-12 Grade 1 - Grade 5 | Primary Incomplete |
|   Elementary Graduate           |   Primary Complete                    |
|   K-12 Grade 6 |                        Primary Complete | 
|   First - Fourth Year High School      |    Secondary Incomplete       |
| K-12 Grade 7 - Grade 9 | Secondary Incomplete |
|   High School Graduate      |    Secondary Complete       |
| K-12 Secondary Grade 10 | Secondary Complete |
| K-12 Secondary Grade 11-12| Post-Secondary, not University|
|   First - Third Year Post-Secondary        |  Post-Secondary, not University                           |
|   Basic Programs                          |   Post-Secondary, not University                | These appear to refer to various classes of Associate degree programs
|   [x] Program            |  Post-Secondary, not University           |  PSCED lists Associate Programs in the inter-secondary-University range as they appear in the data here |
|   First - Second Year Post-Secondary        |  Post-Secondary, not University       | PSCED says usually are terminal, job-preparation programs
|  Post-Secondary Courses - [x] Course            |  Post-Secondary, not University           |   
|   First - Sixth Year of College      | University Incomplete or Complete                      |
|   College Undergraduate          | University Incomplete or Complete                            |
|   Post-Baccalaureate              | University Incomplete or Complete          |
|   First - Sixth Year of College      | University Incomplete or Complete                      |
|   Academic Degrees of First-Stage/Baccalaureate - [x] Degree      | University Incomplete or Complete                            |
|   Masters, Doctorate             | University Incomplete or Complete          |
|                             |                   | 



## Survey Years 2019 + 
These survey years follow the newest PSA classification for [2017](https://psa.gov.ph/content/philippine-standard-classification-education-psced). The biggest difference in these years is the inclusion of two additional years in secondary school. 

### Education Levels
Note that Secondary now includes 4 years of Junior High School and 2 years of Senior High School. Also, this classification scheme specifically denotes tracks for special needs education, but does not provide enough information for our classification requirements. 

The big unknown is K-12 Programs. The 2017 PSCED doesn't have any explicit information on what should be done with K-12 programs. For now, I will simply make the assumption that `grade 1` in K-12 corresponds to `grade 1` in the chart below. I will also assume that if the student has completed `grade 6` and `grade 12` then they have completed Primary and Secondary respectively.

| Group | Typical Age | Levels in group |
|------|--------------|-----------------|
|Pre-Primary | 5 | 1 |
|Primary| 6-11| 6 |
|Secondary | 12-18 | 6 |
|Post-Secondary non-tertiary|  
|Short-Cycle Tertiary|
|Bachelors | 
|Masters|
|Doctorate|



| PSA Labels  / Ranges of Labels                 |   I2D2 Level | Notes |
|----------------------------------------|----------------------------|-------------------------|
|  No Grade Completed       |     No Education                        |
|  Preschool                |      No Education     | 
| Kindergarten | No Education | PSCED says Primary begins at grade 1 |
|   Grade 1 - Grade 7                       |  Primary Incomplete        | PSCED permits a 7th primary school year |
|   Grade 6 or Grade 7 Graduate           |   Primary Complete                    |
| Elementary Graduate | Primary Complete | 
|   Grade 7 - 9 / First - Third Year High School      |    Secondary Incomplete       |
|   Grade 10 / High School Graduate      |    Secondary Incomplete       |
| Grade 11, [x] Track | Secondary Incomplete    | 
| Grade 12, [x] Track | Secondary Complete | In new schema, Secondary is 6 years| 
| Basic Programs, Certificates, 40000- and 50000-level degrees | Post-Secondary, Non-University|
| Undergraduate, Basic Programs or Equivalent | University Incomplete or Complete | 
| Masters, 70000 level | University Incomplete or Complete | 
| Doctorate, 80000 level | University Incomplete or Complete | 


