Geographic Administrative Levels
================

-   [Region](#region)
    -   [Small changes in the values for Region IV-A and -B](#small-changes-in-the-values-for-region-iv-a-and--b)
    -   [Differences between factor and numeric](#differences-between-factor-and-numeric)
    -   [Descriptive Checks and Evidence for Recoding](#descriptive-checks-and-evidence-for-recoding)
    -   [The need to recode](#the-need-to-recode)
    -   [Responsible and Reproducible Recoding](#responsible-and-reproducible-recoding)
    -   [Recoding 2016 - 2020](#recoding-2016---2020)
    -   [Coding 2003](#coding-2003)
-   [Final Region Labels](#final-region-labels)
-   [Province](#province)
    -   [Province encoding methodology](#province-encoding-methodology)

This document describes how first and second level administrative divisions in the Philippines are coded over time in the LFS survey in the GLD context.

## Region

The Philippines has 16 regions as the first level administrative division in 1997, according to the PSA’s [Integrated Survey of Household’s Bulletin](https://psa.gov.ph/sites/default/files/ISHB_series%20no.%2089_Labor%20Force_January%201997.pdf).

This classification schema also appears in the labelled data through the April round of 2003. Thereafter, in the July round of 2003, Region IV is split into two separate regions A and B, creating a 17th region. This administrative change is documented in the [July 2003 PSA ISH document](https://psa.gov.ph/sites/default/files/ISHB_series%20no.%20117_Labor%20Force_July%202003%20.pdf).

The Region variables, although named differently across years, usually arrive in factor labelled data types. Occasionally they arrive as integer, usually with the same underlying numeric values. The way the appearance of the Region IV split/17th Region shows in the data is through the introduction of two new values that do not appear prior to July of 2003. A shortened example is given below, with the Region Labels contained in the cells.

| Value | LFS 2003: April | LFS 2003: July |
|-------|-----------------|----------------|
| 4     | Region IV       | \-             |
| 41    | \-              | Region IV-A    |
| 42    | \-              | Region IV-B    |

### Small changes in the values for Region IV-A and -B

Beginning in the 2016 year, value codes for Region IV-A changes from `41` to `4` and Region IV-B changes from `42` to `17`. This pattern continues through the year 2020.

### Differences between factor and numeric

Some region variables are numeric and some are factor labelled, but their underlying values are not always the same. Whereas the value and labeling schema is stable across survey rounds and years, minus the small change for Region IV-A and -B above, the numeric variable cognate appears to change sometimes, so we should be mindful of this.

For example, the numeric variable for region in October 2002 matches the values for the factor labelled variables in the same year; so does the July 2006 numeric one. However, the factor and numeric values for the year 2016 differ. What is more, the conflicting values for `41`/`42` and `4`/`17` in theory refer to the same region that was made into two separate regions in 2003 (see above). However, the numeric values will have to be inferred based on clues such as previous quarter’s codes and
distributions of counts.

| Value | Jan (1) | Apr (2) | Jul (3) | Oct (4) |
|-------|---------|---------|---------|---------|
| 1     | x       | x       | x       | x       |
| 2     | x       | x       | x       | x       |
| 3     | x       | x       | x       | x       |
| 4     |         | **x**   | **x**   | **x**   |
| 5     | x       | x       | x       | x       |
| 6     | x       | x       | x       | x       |
| 7     | x       | x       | x       | x       |
| 8     | x       | x       | x       | x       |
| 9     | x       | x       | x       | x       |
| 10    | x       | x       | x       | x       |
| 11    | x       | x       | x       | x       |
| 12    | x       | x       | x       | x       |
| 13    | x       | x       | x       | x       |
| 14    | x       | x       | x       | x       |
| 15    | x       | x       | x       | x       |
| 16    | x       | x       | x       | x       |
| 17    | .       | *x*     | *x*     | *x*     |
| 18    | .       | .       | .       | x       |
| 41    | **x**   | .       | .       | .       |
| 42    | *x*     | .       | .       | .       |

The following years have mixed numeric and factor data for their region variable equivalents across all survey rounds for that year; all others are factor labeled for all rounds within that year: - mixed numeric-factor 2006, 2016, 2017.

### Descriptive Checks and Evidence for Recoding

The markdown file `Region_Recode_Checks.Rmd` checks that the numeric variable descriptively aligns with the factor-coded variables within the same year. The code simply appends, recodes, and produces histograms by round for comparison. This visual check provides initial support to the idea that the numeric and factor values may likely refer to the same region, and therefore that the numeric and factor data may be appended safely.

### The need to recode

The I2D2 doesn’t require region recoding for variable construction, but in most cases the survey sampling is stratified at the region level, which has implications for other variables such as weights, etc. Furthermore, we do have a responsibility to ensure cross-round harmonization. That is, we need to make sure that the resulting data
produces values that mean the same thing in all survey rounds for that year. In some cases, this requires recoding if we append multiple survey rounds.

### Responsible and Reproducible Recoding

All recoding will be done openly and in-script, which is available in this repository. Furthermore, given the complexities outlined, the original region variable provided by the PSA will be left in with the survey data – labelled or not – as it arrived to us.

### Recoding 2016 - 2020

Since the [July 2003 PSA ISH document](https://psa.gov.ph/sites/default/files/ISHB_series%20no.%20117_Labor%20Force_July%202003%20.pdf) describes the Region schema as 17 Regions with an additional region (being produced by Region IV’s split into two), I will ensure that all years after 2003 follow this labeling schema. This means that the
recoding schedule for 2016 will be replicated for years 2017 and onward: all factor **and** numeric values that refer to `4` or `Region IV-A`
will be recoded to `41`/`Region IV-A`; values of `17`/`Region IV-B` will be recoded to `42`/`Region IV-B` to be aligned with previous years.

### Coding 2003

The data for 2003 are provided in the two-system labeled scheme for January & April and July & October as described above. However, the [Janurary and April months](https://psa.gov.ph/node/33231/33231/33231/33231/33231?combine=2003) of the ISH list the *new* post-July/labeling scheme as the scheme they utilized. I will simply code the data to match the “post” July 2003 scheme so that it matches the published data by the PSA.

Two key decisions were made in regards to harmonizing the 2003 region data: the first was to recode the first two rounds, January and April, to match the values and labels used in the final two rounds and in the documentation. In practicality, we did this by recoding the region based on the underlying province – since all provinces exist underneath a region. However, this recoding based on province has us arrive at a second key decision.

| Province Name      | New Region |
|--------------------|------------|
| Batangas           | Calabarzon |
| Cavite             | Calabarzon |
| Laguna             | Calabarzon |
| Quezon             | Calabarzon |
| Rizal              | Calabarzon |
| Marinduque         | Mimaropa   |
| Occidental Mindoro | Mimaropa   |
| Oriental Mindoro   | Mimaropa   |
| Palawan            | Mimaropa   |
| Romblon            | Mimaropa   |

Secondly, for January and April, we reassigned the province `Aurora` to the Region in which the documentation for [Janurary](https://psa.gov.ph/sites/default/files/ISHB_series%20no.115_Labor%20Force_Jan.%202003.pdf) and [April](https://psa.gov.ph/sites/default/files/ISHB_series%20no.%20116_Labor%20Force_April%202003%20.pdf)
says it belongs: `Central Luzon`.

After these two recoding decisions were completed in the code, all four rounds share the same values and value labels – the same as those found
in 2004 and subsequent years.

## Final Region Labels

The resulting coding and labeling schema looks like this, after the above recoding takes place:

| Value | Before 2003                          | Starting January 2003                |
|-------|--------------------------------------|--------------------------------------|
| 1     | Ilocos                               | Ilocos                               |
| 2     | Cagayan Valley                       | Cagayan Valley                       |
| 3     | Central Luzon                        | Central Luzon                        |
| 4     | Southern Tagalog                     | .                                    |
| 5     | Bicol                                | Bicol                                |
| 6     | Western Visayas                      | Western Visayas                      |
| 7     | Central Visayas                      | Central Visayas                      |
| 8     | Eastern Visayas                      | Eastern Visayas                      |
| 9     | Western Mindanao                     | Zamboanga Peninsula                  |
| 10    | Northern Mindanao                    | Northern Mindanao                    |
| 11    | Southern Mindanao                    | Davao                                |
| 12    | Central Mindanao                     | Soccsksargen                         |
| 13    | National Capital Region              | National Capital Region              |
| 14    | Cordillera Administrative Region     | Cordillera Administrative Region     |
| 15    | Autonomous Region of Muslim Mindanao | Autonomous Region in Muslim Mindanao |
| 16    | Caraga                               | Caraga                               |
| 17    | .                                    | .                                    |
| 18    | .                                    | Negros Island Region                 |
| 41    | .                                    | Calabarzon                           |
| 42    | .                                    | Mimaropa                             |

## Province

The 2nd Administrative Level is Province. The value labels appear to be mostly stable across rounds and years, with no mention of changes in the 2003 administrative revisions above. Furthermore, the some rounds are numeric while others are labeled. Starting in July 2003, the province variables are only encoded as numeric – some years afterwards have miscellaneous rounds also encoded with a secondary variable `_name` that stores the province name in string format. From the label data that exists, the labeled variables are stable across rounds within the same year, but appear to reflect small changes as provinces are added.

Without a main data source for the labels, a few assumptions will need to be made.

1.  **Transitive Property of Labels**: Adopting from the [mathematical transitive property](https://en.wikipedia.org/wiki/Transitive_relation), we have to assume that if value `1 = "Province 1"` in Year 1, Round 1, and `1 = "Province 1"` in Year 2, Year 3, and all other years available, then value `1 = "Province 1"` also in Years where we *do not* have label information.

2.  **Identity Property of Labels**: Similarly, we should also assume that each label’s value, when equivalent or virtually similar, actually refers to the same region. In other words, `"Province 1"` is actually the same `"Province 1"` every year. This may seem obvious, but sometimes regions and provinces go through political or
    geographic changes — such as divisions, combining, or changing of boundaries, etc — that may render them practically different, but named the same.

### Province encoding methodology

The `province_label_util.R` script harmonizes all province labels internal to the survey data and produces a set of key outputs, mainly:

1.  A `GLD_PHL_admin2_labels.Rdata` file, which contains

    -   `prov_labs_chr`: or the tabular object of province labels by numeric value over time which have been stored in string form in the original data

    -   `prov_labs_fct`: or the tabular object of province labels by numeric value which have been stored in factor form in the original data

    -   `prov_labs_final` : or the key product. It is the final tabular object that contains all province numeric values, harmonized value label, and character vector of original value labels. This object harmonizes the data from `prov_labs_chr` and `prov_labs_fct`.

2.  A .dta compatible version of `prov_labs_final` object.

#### How are the Labels Harmonized?

Conceptually, the harmonizer gave priority to internal data validity (e.g. internal to the survey data) and then proceeded to validate through secondary documents provided by the PSA. The code is guided by the following principles:

1.  First, collect all of the province labels for each numeric value — including both factor and string data

2.  Then, see if these labels are the same for each numeric value, or if they are different.

    1.  If they are the sall same, great! Then we have ourselves a label. Use that one!

    2.  If the labels are different, then have a human look and manually decide what the label should be.

In many cases, the labels for the same value were virtually the same — so the same label could be used. In the \~15 or so cases where manual labels had to be decided, most of these were due to re-ordering of words that a simple computer matching algorithm can’t see through, but a human can tell with confidence that the Provinces are in fact, the same one.

## Labels file

The data file used in the harmonization to create the admin labels is [available here](utilities/Additional%20Data/GLD_PHL_admin2_labels.dta).
