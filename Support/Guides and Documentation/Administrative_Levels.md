# Geographic Administrative Levels: Philippines I2D2
This document describes how first and second level adminsitrative divisions in the Philippines are coded over time in the LFS survey in the I2D2 context.

## Region
The Philippines has 16 regions as the first level administrative division in 1997, according to the PSA's [Integrated Survey of Household's Bulletin](https://psa.gov.ph/sites/default/files/ISHB_series%20no.%2089_Labor%20Force_January%201997.pdf). This classification schema also appears in the labelled data through the April round of 2003. Thereafter, in the July round of 2003, Region IV is split into two seperate regions A and B, creating a 17th region. This adminsitrative change is documented in the [July 2003 PSA ISH document](https://psa.gov.ph/sites/default/files/ISHB_series%20no.%20117_Labor%20Force_July%202003%20.pdf).

The Region varibles, although named differently across years, usually arrive in factor labelled data types. Occasionally they arrive as integer, usually with the same underlying numeric values. The way the apparance of the Region IV split/17th Region shows in the data is through the introduction of two new values that do not appear prior to July of 2003. A shortened example is given below, with the Region Labels contained in the cells.



| Value               |   LFS 2003: April | LFS 2003: July |
|---------|-----------------------|----------------------|
| 4  |    Region IV   |			- |
| 41 |   -   | Region IV-A |
| 42 | - | Region IV-B |

### Small changes in the values for Region IV-A and -B
Beginning in the 2016 year, value codes for Region IV-A changes from `41` to `4` and Region IV-B changes from `42` to `17`. This pattern continues through the year 2020.


### Differences between factor and numeric

Some region variables are numeric and some are factor labelled, but their underlying values are not always the same. Wheras the value and labeling schema is stable across survey rounds and years, minus the small change for Region IV-A and -B above, the numeric variable cognate appears to change sometimes, so we should be mindful of this.

For example, the numeric variable for region in October 2002 matches the values for the factor labelled variables in the same year; so does the July 2006 numeric one. However, the factor and numeric values for the year 2016 differ. What is more, the conflicting values for `41`/`42` and `4`/`17` in theory refer to the same region that was made into two separate regions in 2003 (see above). However, the numeric values will have to be inferred based on clues such as previous quarter's codes and distributions of counts.

|          | *numeric* | *labelled*| *numeric* | *numeric*|
| Value    |   Jan (1) | Apr (2) | Jul (3) | Oct (4) |
|---------|------------|-----------|-----------|-----------|
| 1  | x	| x	| x	| x	|
| 2	 | x	| x	| x	| x	|
| 3  | x	| x	| x	| x	|
| 4	 |  	| **x**	| **x**	| **x**	|
| 5  | x	| x	| x	| x	|
| 6	 | x	| x	| x	| x	|
| 7  | x	| x	| x	| x	|
| 8	 | x	| x	| x	| x	|
| 9  | x	| x	| x	| x	|
| 10 | x	| x	| x	| x	|
| 11 | x	| x	| x	| x	|
| 12 | x	| x	| x	| x	|
| 13 | x	| x	| x	| x	|
| 14 | x	| x	| x	| x	|
| 15 | x	| x	| x	| x	|
| 16 | x	| x	| x	| x	|
| 17 |  	| *x*| *x*| *x*	|
| 18 |  	| 	|  	| x	|
| 41 | **x**	|  	|  	|  	|
| 42 | *x*	|  	|  	|  	|


### The need to recode
The I2D2 doesn't require region recoding for variable construction, but we do have a responsibility to ensure cross-round harmonization. That is, we need to make sure that the resulting data produces values that mean the same thing in all survey rounds for that year. In some cases, this requires recoding if we append multiple survey rounds.

### Evidence for recoding
Supporting documentation `Region_Recode_Checks.Rmd` provides provisional stylized evidence to support recoding as suggested above for 2016. In short, the markdown document shows that recoding in the way described above produces very similar distributions of observations in all four rounds.

### Responsible and Reproducible Recoding
All recoding will be done openly and in-script, which is available in this respository. Furthermore, given the complexities outlined, the original region variable provided by the PSA will be left in with the survey data -- labelled or not -- as it arrived to us.

### Recoding 2016 - 2020
Since the [July 2003 PSA ISH document](https://psa.gov.ph/sites/default/files/ISHB_series%20no.%20117_Labor%20Force_July%202003%20.pdf) describes the Region schema as 17 Regions with an additional region (being produced by Region IV's split into two), I will ensure that all years after 2003 follow this labeling schema. This means that the recoding schedule for 2016 will be replicated for years 2017 and onward: all factor **and** numeric values that refer to `4` or `Region IV-A` will be recoded to `41`/`Region IV-A`; values of `17`/`Region IV-B` will be recoded to `42`/`Region IV-B` to be aligned with previous years.

The resulting coding and labeling schema looks like this:

| Value    |   Before July 2003 | Starting July 2003 |
|---------|----------------------------|------------------------------|
| 1  | Ilocos	| Ilocos	|
| 2	 | Cagayan Valley	| Cagayan Valley	|
| 3  | Central Luzon	| Central Luzon	|
| 4	 | Southern Tagalog 	| .	|
| 5  | Bicol	| Bicol	|
| 6	 | Western Visayas	| Western Visayas	|
| 7  | Central Visayas	| Central Visayas	|
| 8	 | Eastern Visayas	| Eastern Visayas	|
| 9  | Western Mindanao	| Zamboanga Peninsula	|
| 10 | Northern Mindanao	| Northern Mindanao	|
| 11 | Southern Mindanao	| Davao	|
| 12 | Central Mindanao	| Soccsksargen	|
| 13 | National Capital Region	| National Capital Region	|
| 14 | Cordillera Administrative Region	| Cordillera Administrative Region	|
| 15 | Autonomous Region of Muslim Mindanao	| Autonomous Region in Muslim Mindanao	|
| 16 | Caraga	| Caraga	|
| 17 |  .	| .|
| 18 |  .	| 	Negros Island Region|
| 41 | .|  Calabarzon	|
| 42 | .	|  Mimaropa	|

### What to do for 2003?
The data for 2003 are provided in the two-system labeled scheme for January+April and July+October as described above. However, the [Janurary and April months](https://psa.gov.ph/node/33231/33231/33231/33231/33231?combine=2003) of the ISH list the *new* post-July/labeling scheme as the scheme they utilized.

Furthermore, there is a methematical reason why we cannot just use the given January+April and July+October values and labels as-is: the weight variable provided in each survey file round takes the region into account. If we suddendly change the region variable, the weight variable would be out of sync with the data and incorrect.

#### Coding 2003
 After discussion with the team, the reccommended solution is to recreate the regions by constructing them from grouping the provinces into their associated regional clusters. However, the July round does not contain the province data, so this solution will have to be put on pause for the time being. 


## Province
The 2nd Administrative Level is Province. The value labels appear to be stable across rounds and years, with no mention of changes in the 2003 adminstrative revisions above. Furthermore, the some rounds are numeric while others are labeled. In later years, beginning in 2014, the variable only appears as a numeric data type accompanied, in some months, with a secondary variable `_name` that stores the province name in string format.
