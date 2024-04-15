# Geography

## Mapping and Description of Variables

### urban

urban is a dummy variable that specifies the location type – urban or rural - of the household. This variable is country specific as each country uses its own criterion to distinguish urban from rural areas. In many cases there is no clear division between urban and rural areas, and areas are classified as “semi-urban” or “mixed”. Harmonizers are advised to classify such categories as “urban.”

Urban categories:

1 = Urban

0 = Rural

### subnatid1

subnatid1 refers to a subnational identifier at the highest level within the country’s administrative structure. This is typically a province or state. The variable is string and country-specific categorical. Numeric entries are coded in string format using the following naming convention: “1 – Hatay”. That is, the variable itself is to be string, not a labelled numeric vector.

### subnatid2

subnatid2 refers to a subnational identifier at which survey is representative at the second highest level within the country’s administrative structure. This is typically a district. The variable is string and country- specific categorical. Numeric entries are coded in string format using the following naming convention: “1 – Hatay”. That is, the variable itself is to be string, not a labelled numeric vector.

### subnatid3

subnatid3 refers to a sub-national identifier at which survey is representative at the third level within the country’s administrative structure. This is typically a sub-district. The variable is string and country-specific categorical. Numeric entries are coded in string format using the following naming convention: “1 – Hatay”. That is, the variable itself is to be string, not a labelled numeric vector.

### subnatid4

subnatid4 refers to a sub-national identifier at which survey is representative at the lowest level within the country’s administrative structure. In some countries, this is effectively a village. The variable is string and country-specific categorical. Numeric entries are coded in string format using the following naming convention: “1 – Hatay”. That is, the variable itself is to be string, not a labelled numeric vector.

### subnatidsurvey

subnatidsurvey is a string variable that refers to the lowest level of the administrative level at which the survey is representative. In most cases this will be equal to variable _subnatid1_ or _subnatid2_. However, in some cases the lowest level is classified in terms of urban, rural (i.e., variable _urban_) or any other regional categorization cannot be mapped to _subnatid#_.

The below example shows how to code _subnatidsurvey_ for a survey that is representative at the rural/urban level of the province (_subnatid1_).

| subnatid1 | urban | subnatidsurvey |
| --- | --- | --- |
| “1 – Province A” | 1   | “1 – Province A urban” |
| “1 – Province A” | 1   | “1 – Province A urban” |
| “1 – Province A” | 1   | “1 – Province A urban” |
| “1 – Province A” | 1   | “1 – Province A urban” |
| “1 – Province A” | 0   | “1 – Province A rural” |
| …   | …   | …   |
| “2 – Province B” | 0   | “2 – Province B rural” |
| “2 – Province B” | 0   | “2 – Province B rural” |
| “2 – Province B” | 0   | “2 – Province B rural” |
| “2 – Province B” | 0   | “2 – Province B rural” |
| “2 – Province B” | 1   | “2 – Province B urban” |
| “2 – Province B” | 1   | “2 – Province B urban” |

While the below is the example of a survey representative nationally, nationally at urban / rural level and at province level.

| subnatid1 | urban | subnatidsurvey |
| --- | --- | --- |
| “1 – Province A” | 1   | “1 – Province A” |
| “1 – Province A” | 1   | “1 – Province A” |
| “1 – Province A” | 1   | “1 – Province A” |
| “1 – Province A” | 1   | “1 – Province A” |
| “1 – Province A” | 0   | “1 – Province A” |
| …   | …   | …   |
| “2 – Province B” | 0   | “2 – Province B” |
| “2 – Province B” | 0   | “2 – Province B” |
| “2 – Province B” | 0   | “2 – Province B” |
| “2 – Province B” | 0   | “2 – Province B” |
| “2 – Province B” | 1   | “2 – Province B” |
| “2 – Province B” | 1   | “2 – Province B” |

The variable would contain survey representation at lowest level irrespective of its mapping to subnatids.

### subnatid1_prev

subnatid1_prev is coded as missing unless the classification used for subnatid1 has changed since the previous survey. In that case, it refers to the subnatid1 code used in the previous survey. This provides a way of tracking splits. For example, if province “32 – West Java” split into province “32 – West Java” and “36 – Banten” since the most recent survey, subnatid1_prev would be "32 – West Java” for cases when subnatid1 is either “32 – West Java” or “36 – Banten”.

### subnatid2_prev

subnatid2_prev is coded as missing unless the classification used for subnatid2 has changed since the previous survey. In that case, it refers to the subnatid2 code used in the previous survey.

### subnatid3_prev

subnatid3_prev is coded as missing unless the classification used for subnatid3 has changed since the previous survey. In that case, it refers to the subnatid3 code used in the previous survey.

### subnatid4_prev

subnatid4_prev is coded as missing unless the classification used for subnatid4 has changed since the previous survey. In that case, it refers to the subnatid4 code used in the previous survey.

### strata

strata refer to the division of the target population – typically the census sample frame -- into subpopulations based on auxiliary information that is known about the full population. Sampling is conducted separately for each strata. The strata should be mutually exclusive: every element in the population must be assigned to only one stratum. The strata should also be collectively exhaustive: no population element can be excluded. Sampling strata need to be considered when constructing the variance (or confidence intervals) of population estimates. strata is needed for the correct calculation of standard deviation for each sample design. Strata is numeric and country-specific. A unique identifier is created for each strata. In STATA, users are advised to specify strata through the svyset command. The variable is in string format with the following naming convention “code of stratum – stratum name”, for example: “1 – Dar-es-salaam”

### gaul_adm1_code

gaul_adm1_code is numeric and country-specific based on the GAUL database. It should be taken from the same data in the GAUL database (a copy of those codes is available at the D4G team, contact Minh Nguyen at [mnguyen3@worldbank.org](mailto:mnguyen3@worldbank.org) or David Newhouse at [dnewhouse@worldbank.org](mailto:dnewhouse@worldbank.org)) where the geographical area can be identified in the survey based on the name of the location/area. The number of unique values from the subnatid1 and the gaul_adm1_code could be different or the same. For example, in the case of a fictional country, if the highest-level representation is the state level (53 states) and Gaul also has 53 states, it is the same in this case. In a different example, the survey is representative at the level of statistical regions (7) while the identifiable GAUL code is at state level (53 states); with this setup, one can know how the seven statistical regions are constructed.

### gaul_adm2_code

gaul_adm2_code is numeric and country-specific based on the GAUL database. It should be taken from the same data in the GAUL database where the geographical area can be identified in the survey based on the name of the location/area.

## Lessons Learned and Challenges

- subnatid codes should reflect the most recent codes that pertain to that survey. subnatid_prev codes can be used to track splits and new administrative units that have been introduced since the previous survey. It is important to ensure there is consistency in geographic variables across time. Sub- nationally representative units may be added in later additions of surveys, so names of subnational units must be consistent across time. This will allow analysts to make the current administrative units “backwards-compatible” with little additional effort.
- Harmonizers should ensure the subnatid1 through subnatid4 are string variables NOT categorical.
- The urban variable cannot be different from zero or one.
```
count if urban!= 1 | urban!= 0
assert `r(N)’ == 0
```

## Tabular Overview of Variables

| Module Code | Variable name | Variable label | Notes |
| --- | --- | --- | --- |
| Geography | urban | Binary - Individual in urban area | &nbsp; |
| Geography | subnatid\[i\] | Subnational ID - \[ith\] level | Subnational ID at the ith level, listing as many as available |
| Geography | subnatidsurvey | Lowest level of Subnational ID | subnatidsurvey is a string variable that refers to the lowest level of the administrative level at which the survey is representative. In most cases this will be equal to “subnatid1” or “subnatid2”. However, in some cases the lowest level is classified in terms of urban, rural or any other regional categorization cannot be mapped to subnatids. The variable would contain survey representation at lowest level irrespective of its mapping to subnatids. |
| Geography | subnatid\[i\]\_prev | Subnatid previous - \[ith\] level | Previous subnatid if changed since last survey |
| Geography | strata | Strata | &nbsp; |
| Geography | gaul_adm\[i\]\_code | GAUL ADM\[i\] code | See en.wikipedia.org/wiki/Global_Administrative_Unit_Layers |

