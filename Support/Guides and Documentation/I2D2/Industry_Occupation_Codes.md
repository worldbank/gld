# Industry and Occupation Codes

This document provides a brief overview of the industry coding and occupation coding in I2D2. Note that the information is only recorded for individuals who, because of age minimums in each survey, have been included in the labor module.

## Industry Codes
The codes for the main job are given here based on the UN International Standard Industrial Classification (revision 3.1).  The main categories subsume the following codes:
|value | Category Description | UN ISCIC Category |
|-----|-----------------------------------------|-----------------|
|1| Agriculture, Hunting, Fishing | 01-05|
|2| Mining| 10-14|
|3| Manufacturing |15-37|
|4| Electricity and Utilities| 40-41|
|5| Construction |45|
|6| Commerce |50-55|
|7| Transportation, Storage and Communication |60-64|
|8| Financial, Insurance and Real Estate |65-74|
|9| Services: Public Administration |75|
|10| Other Services | 80 -99|

The raw data naturally spans different categtorization schemes over time. Principally, there are the 1994 PSCIC and the [2009 PSCIC](http://psa.gov.ph/content/philippine-standard-industrial-classification-psic); the latter went into effect in Janurary 2012. Since these codes are available on the PSA website and are quite detailed, a the most useful overview here is a short table that summarizes the changes in the metadata. A detailed version of this table, along with individual labls, can be found by running `label_tools.R`.

|scheme | PSCIC | Years Applicable | Characteristics | Coding methodology |
|-----|------|--------------|----------------------------|-----------------|
|1| 1994 |97-00 |First digit nearly always aligns with I2D2 desired code | `floor([var]/10)` then adjust by case |
|2| 1994 | 01-11| Departure from first-digit pattern, vals range from 1-99 | `gen industry1 = .` then manually replace|
|3| 2009 |12,13 | Values range from 100 - 9999, first 2 digits usually correspond to key level | code manually by ranges |
|4| 2009 |14,15,16 | Values range from 1-99 but first two digits corrospond to same first two in scheme#3  | `gen industry1 = .` then manually replace |
|5| 2009 | 2017| Mix of schemas 3 and 4 depending on month/round  | code with block conditionals on survey month/round |
|6| 2009 | 2018, 2019| ~5% Labeled, values range from 1-99, like schema 2;4. first two digits corrospond to same first two in scheme#3   | `gen industry1 = .` then manually replace |
