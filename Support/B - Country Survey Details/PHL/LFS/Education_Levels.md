Education Levels: Philippines GLD
================

-   [Survey Years 1997 - 2011
    (PSCED 1997)](#survey-years-1997---2011-psced-1997)
    -   [Values Specific to PSCED 1997](#values-specific-to-psced-1997)
    -   [Notes Specific to PSCED 1997](#notes-specific-to-psced-1997)
-   [Survey Years 2012 - 2018
    (PSCED 2008)](#survey-years-2012---2018-psced-2008)
    -   [Survey Years 2012 to April
        2016](#survey-years-2012-to-april-2016)
    -   [Survey Years July 2016 to
        2018](#survey-years-july-2016-to-2018)
    -   [Education levels](#education-levels)
    -   [Values specific to the 2008
        PSCED](#values-specific-to-the-2008-psced)
    -   [Notes specific to 2008 PSCED](#notes-specific-to-2008-psced)
-   [Survey Years 2019 +](#survey-years-2019-)
    -   [Education Levels](#education-levels-1)
    -   [Notes specific to the 2017 PSCED
        Classification](#notes-specific-to-the-2017-psced-classification)

The following discussion explains the codification from raw survey education labels to GLD categories. The main organizing principle is that different groups of survey years rely on different evidence. In some periods the raw values can be read directly from labelled survey categories, while in others the harmonization relies on comparisons across rounds and adjacent years. Note that, according to the 2017 Philippine Standard Classification of Education document, the education system was adjusted in 2018 in accordance with new legislation, linked [here](http://www.unesco.org/education/edurights/media/docs/e119986abbd26ebda9c3d8c18929b4487205d4d6.pdf).

The labeled 2018 rounds make the later K-12 structure explicit. In practice, the 2017 harmonization uses that same later structure as the closest labeled reference, since the 2017 values line up closely with the 2018 patterns even though the labels are less complete.

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

These survey years are documented by the PSA under the 2008 Philippine Standard Classification of Education (PSCED), accessible [here](utilities/433680126-PSCEd-2008.pdf). However, the raw survey values are not consistent with PSCED 2008 at the first digit. The official PSCED 2008 structure uses the first digit to represent the level of education, with `1xx` for primary, `2xx` for secondary, `4xx` for post-secondary non-tertiary, `5xx` for first-stage tertiary or baccalaureate, and `6xx` for second-stage tertiary or post-graduate education. The raw survey files instead use two different survey-specific coding structures over this period.

### Survey Years 2012 to April 2016

For 2012 to April 2016, the raw survey files use a compressed attainment ladder in which `2xx` values correspond to primary grades, `3xx` values correspond to secondary grades, and `4xx` values correspond to post-secondary education. For this reason, the harmonization uses the raw survey labels and within-survey value patterns rather than applying the official PSCED 2008 first-digit rule mechanically.

The raw variables used for this earlier period are not fully uniform across years. For 2012 and 2013 the detailed education variable is `j12c09_grade`. For 2014 and 2015 both `c09_grd` and `j12c09_grade` appear in the raw data, but the harmonization relies on the more detailed `j12c09_grade`. In 2016, the January round also contains both variables and again relies on `j12c09_grade`, while the April round uses `pufc07_grade`.

The basis for this cluster is the raw labeled education categories themselves. The labels for primary, secondary, post-secondary, college, and post-baccalaureate are sufficiently stable across these rounds to support a direct mapping into GLD, even though the first digit does not line up with PSCED 2008.

The tables below summarize the main inconsistency between the official PSCED 2008 first-digit rules and the education values observed in the raw survey variables used for harmonization in 2012 to April 2016.

| PSCED 2008 first digit | Official PSCED 2008 level name |
|------------------------|--------------------------------|
| `1xx`                  | Primary / elementary |
| `2xx`                  | Secondary / high school |
| `4xx`                  | Post-secondary non-tertiary |
| `5xx`                  | First-stage tertiary / baccalaureate |
| `6xx`                  | Second-stage tertiary / post-graduate |

| Raw survey value range, 2012 to April 2016 | Typical raw labels | Meaning in raw survey files |
|---------------------------------------------|--------------------|-----------------------------|
| `2xx`                             | Grade 1 to Grade 6 | Primary grades |
| `280`                             | Elementary Graduate | Primary complete |
| `3xx`                             | First Year to Fourth Year High School | Secondary grades |
| `350`                             | High School Graduate | Secondary complete |
| `4xx`                             | First Year Post-Secondary, Second Year Post-Secondary | Post-secondary education |
| `5xx`                             | Basic Programs, field-specific programs | Higher-education field groups in the raw survey data, but not a clean literal PSCED level marker |
| `6xx`                             | Field-specific programs | Higher-education field groups in the raw survey data, but not a clean literal PSCED level marker |
| `8xx`, `900`                      | First Year College to Post-Baccalaureate | Explicit college years and post-baccalaureate |

### Survey Years July 2016 to 2018

Beginning in July 2016, the raw survey values shift to a later structure tied to the K-12 transition. The July and October 2016 rounds, and then all rounds in 2017 and 2018, follow this later structure. These later rounds also deviate from PSCED 2008 at the first digit, because the `4xx` series no longer refers to post-secondary non-tertiary education. Instead, the `400` series refers to basic-school grades.

The basis for this cluster is slightly different by year. For July and October 2016, the values are unlabeled, so the mapping relies on the internal pattern of the code ladder and its continuity with 2017 and the labelled 2018 data. For 2017, the rounds are also effectively interpreted using the same later structure, with 2018 serving as the main labelled reference year. For 2018, the labels are explicit and confirm the interpretation of the `400`, `500`, `600`, and `700+` ranges.

In this later structure, the broad pattern is:

| Raw survey value range, July 2016 to 2018 | Typical raw labels | Meaning in raw survey files |
|-------------------------------------------|--------------------|-----------------------------|
| `<=110`                                   | No Grade Completed, Preschool | No education |
| `110` to `160`                            | Grade 1 to Grade 6 | Primary incomplete |
| `170`, `180`, `191`, `460`                | Grade 6 or Grade 7 graduate, SPED undergraduate, Grade 6 - K to 12 Program | Primary complete |
| `210` to `240`, `470` to `490`            | First Year to Fourth Year High School, Grade 7 to Grade 9 - K to 12 Program | Secondary incomplete |
| `250`, `192`, `500`                       | High School Graduate, SPED graduate, Grade 10 - K to 12 Program | Secondary complete |
| `410` to `450`                            | Grade 1 to Grade 5 - K to 12 Program | Primary incomplete in the K-12 ladder, despite the `4xx` prefix |
| `510` to `520`                            | Grade 11 to Grade 12 - K to 12 Program | Post-secondary / higher secondary bridge in GLD terms |
| `601` to `699`                            | First Year Post Secondary, Second Year Post Secondary, Post Secondary Courses Non-Tertiary Education | Post-secondary, not university |
| `701` to `950`                            | First Year College to post-baccalaureate degrees | University or above |

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

Note that PSA documentation for [other years in the same schema](http://psada.psa.gov.ph/index.php/catalog/175/datafile/F1) lists values between `502` and `689` as various completed degrees for associate-level, pre-professional programs. In practice, these values need to be interpreted using the raw survey labels and surrounding value structure rather than the official PSCED first digit alone.

### Notes specific to 2008 PSCED

Some years contain two education grade variables that appear to correspond to the old and new classification schemas, that is, two education variables within the same survey round or data file. Sometimes this variable is called `c09_grd` for the old schema and the variable for the newer schema is called `j12c09_grade`. While it may be convenient to use the older variable, the harmonization generally relies on the newer, more detailed variable because it aligns more closely with the labels actually used in the 2012-2016 files.

Furthermore, some years, such as 2016, use different variable names for the highest grade completed across rounds. We therefore need to be careful about which variable carries the more detailed education ladder. In 2016, the harmonization uses `j12c09_grade` in the January round, rather than the coarser `c09_grd`, and `pufc07_grade` in the April, July, and October rounds.

#### Additional Notes for survey year 2016

Once the variable names for 2016 have been harmonized, the values themselves still differ across rounds. The January values are labelled factors, while the following three rounds are unlabeled integers. January and April follow one numeric pattern, while July and October follow a later pattern that is also used in 2017 and, with labels, in 2018.

For this reason, the harmonization uses different within-year mappings for 2016. January is standardized from `j12c09_grade`, not the coarser `c09_grd`. January and April are coded using the earlier 2012-2015 style attainment structure, while July and October are coded using the later structure that continues through 2017 and, with labels, 2018. In that later structure, the `400` series corresponds to basic-school grades under the K-12 system rather than post-secondary education, which is another way in which these rounds depart from the official PSCED 2008 first-digit logic.

#### Additional Notes for survey year 2017

All rounds for 2017 seems to follow the same numeric schema set in the July/October grouping of 2016. However, the situation is slightly different from that of 2016: all rounds/months have the same numeric values and the values labels do not contain key levels such as those that indicate secondary completion. Furthermore, there is descriptive evidence to assume that the values in 2017 are the same “meaning” as the values in 2018, which are labelled and follow about the same distribution and value pattern. `Education_2017_Checks.Rmd` produces this evidence by comparing the distribution of values for education attainment in 2017 and 2018. For the time being, I will assume that, without complete value labels in 2017, that the similarly-distributed values in 2018 will suffice.

#### Additional Notes for survey year 2018

All relevant raw “grade” variables are in labelled factor form, so no cross-checking of numeric/factor data types is needed as in 2016. 

## Survey Years 2019 +

These survey years follow the newer PSA classification introduced under the 2017 PSCED. In contrast to the earlier periods, the 2019 raw values are broadly consistent with the PSCED 2017 first-digit structure: `0` for early childhood, `1` for primary, `2` for lower secondary, `3` for upper secondary, `4` for post-secondary non-tertiary, `5` for short-cycle tertiary, `6` for bachelor level, `7` for master level, and `8` for doctoral level. The biggest difference in these years is the inclusion of two additional years in secondary school.

The basis for this cluster is therefore different again. For January and April 2019, the labelled values themselves already line up closely with the PSCED 2017 ladder. For July and October 2019, the values are numeric and unlabeled, so the interpretation relies on the broad continuity of the same prefix structure rather than on complete value labels.

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
| Grade 10 / High School Graduate                              | Secondary Complete                |                                         |
| Grade 11, \[x\] Track                                        | Secondary Incomplete              |                                         |
| Grade 12, \[x\] Track                                        | Secondary Complete                | In new schema, Secondary is 6 years     |
| Basic Programs, Certificates, 40000- and 50000-level degrees | Post-Secondary, Non-University    | Includes post-secondary non-tertiary and short-cycle tertiary |
| Undergraduate, bachelor-level or equivalent, 60000 level     | University Incomplete or Complete |                                         |
| Masters, 70000 level                                         | University Incomplete or Complete |                                         |
| Doctorate, 80000 level                                       | University Incomplete or Complete |                                         |

### Notes specific to the 2017 PSCED Classification

Similar to some of the years in the 2008 PSCED Classification above, some survey years have values within the same year, between different-month rounds that do not correspond. Also similarly, some of these “mismatched” values are labelled, and some are not.

#### Additional Notes for survey year 2019

The first two rounds of 2019, January and April, are factor labelled data types and the second two, July and October, are integer, without labels. The underlying values for the first two rounds are slightly different from those of the second two, but the broad prefix structure is the same and follows the PSCED 2017 ladder much more closely than in earlier years.

The first two rounds use grouped values that do not appear literally in the PSCED 2017 codebook. For example, the data use grouped values such as `10010` for grades 1 to 5 and `24010` for grades 7 to 9, rather than listing each detailed school grade separately. The later two rounds then use a more detailed unlabeled version of the same broad structure, with values such as `10011` to `10018`, `24011` to `24015`, `40001` to `40003`, `50001` to `50003`, and `60001` to `60006`.

For this reason, the harmonization treats January and April as the labelled reference rounds and extends the same broad ladder to July and October. The main basis is that the first digit remains stable and informative across all four rounds: `0` for early childhood, `1` for primary, `2` for lower secondary, `3` for upper secondary, `4` for post-secondary non-tertiary, `5` for short-cycle tertiary, `6` for bachelor level, `7` for master level, and `8` for doctoral level. The later-quarter detailed codes are therefore mapped back to the same GLD education ladder rather than being left missing.
