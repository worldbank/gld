
-   [Introduction to Bangladesh Labor Force Survey (BGD
    QLFS)](#introduction-to-bangladesh-labor-force-survey-bgd-lfs)
    -   [What is the BGD QLFS?](#what-is-the-bgd-lfs)
    -   [What does the BGD QLFS cover?](#what-does-the-bgd-lfs-cover)
    -   [Where can the data be found?](#where-can-the-data-be-found)
    -   [What is the sampling
        procedure?](#what-is-the-sampling-procedure)
    -   [What is the significance
        level?](#what-is-the-significance-level)
    -   [Other noteworthy aspects](#other-noteworthy-aspects)

# Introduction to Bangladesh Quarterly Labor Force Survey (BGD QLFS)

## What is the BGD QLFS?

The Bangladesh Quarterly Labor Force Survey (QLFS) succeeds the annual LFS after its first survey was conducted between 2015 and 2016. The QLFS mainly differs from the annual LFS by providing nationally-representative data on a quarterly basis, and offers a more detailed understanding of labor market dynamics. Specifically, the questionnaire is aligned with the ICLS-19, with questions aimed to gather information on the individuals' own-use production of goods and services, a crucial aspect of the informal labor market and subsistence activities in Bangladesh.

## What does the BGD QLFS cover?

The Bangladesh QLFS is a quarterly labor force survey with information on demographic characteristics, education, and labor market activities over the past 7 days. The harmonized years and sample sizes used in the GLD harmonization are as follows:

| Year | HH count | Individual count |
|---|---|---|
| 2015-16 |          121,082  |                      503,756  |
| 2016-17 |          122,455|                      493,886  |

Unlike its precedessor, the Bangladesh QLFS implements a rotational sampling design, in which households were interviewed for two consecutive quarters before being replaced. In the frequency table above, household and individuals were counted distinctly per round. This means that an individual that is interviewed two consecutive quarters is counted twice in the reported frequency table. 

## Where can the data be found?

The datasets are not accessible to the public and researchers have to request the data from the Bangladesh Bureau of Statistics. The World Bank has been granted access to the datasets, if you work or are part of the World Bank Group, kindly contact the Jobs Group with a formal request for access to gld@worldbank.org

## What is the sampling procedure?

The Bangladesh QLFS employs a two-stage stratified sampling design to gather representative data on the country's labor force. This sampling methodology involves selecting Primary Sampling Units (PSUs) in the first stage and households within each PSU in the second stage. Both stages employ random selection techniques, ensuring the sample's representativeness. In the 2015-16 and 2016-17 rounds, the QLFS implemented a rotational panel strategy, where some households in each cluster were replaced by new ones every two quarters.

## What is the significance level?

The official reports detail estimates by area of residence (urban or rural), and the first level administrative units, called *divisions* in Bangladesh. In contrast to the LFS, the QLFS allows breakdown of estimates at a greater level of detail. Disaggregation is possible at a quarterly basis, and area of residence by divisions. However, the GLD data uses annual weights. Data for quarterly weights is available for the 2016-2017 round, but not for the 2015-2016 round. 

## Other noteworthy aspects

### Concept of employment

Since the passing of the [resolution concerning statistics of work, employment and labour underutilization](https://www.ilo.org/global/statistics-and-databases/standards-and-guidelines/resolutions-adopted-by-international-conferences-of-labour-statisticians/WCMS_230304/lang--en/index.htm) in 2013 at the 19th International Conference of Labour Statisticians (ICLS) surveys are at risk of a series break due to the change in the concept of employment.

In short, the ICLS 19 resolution restricts employment to *work performed for others in exchange for pay or profit*, meaning that own consumption work (e.g., subsistence agriculture or building housing for oneself) are not counted as employment.

The Bangladesh QLFS reports is consistent with the LFS in defining employment that includes individuals working for their own consumption. Although this definition does not align with international standards, the QLFS series contain information on individuals' intentions for economic activity, whether for sale or own consumption. This information can be used to code employment to exclude individuals whose primary intention for economic activity is own consumption. This approach allows us to adopt a definition of employment that aligns with international standards. However, adopting this break in definition makes it challenging to meaningfully compare data over time. To address this, we provide a code that enables us to identify employment using the previous definition. The precise details can be found in a [separate document here](Converting%20between%20ICLS%20Definitions.md)


### Household ID

The datasets received do not contain ID information. In the GLD project, we have created IDs to provide the best user experience based on geographic identifiers. The household ID is formed based on information on the primary sampling unit and the household identification number. 

### Geographic Information

As of the time of writing (April 2023) Bangladesh is composed of eight administrative divisions: Dhaka, Chittagong, Khulna, Barisal, Rajshahi, Sylhet, Rangpur, and Mymensingh (see figure below). 

<br></br>
![BGD_divisions](Utilities/bgd_divisions.png)
<br></br>

The table below shows the divisions as of writing and what divisions they belonged to at the earliest survey (currently 2005)

| Divisions as of april 2023    | Divisions in 2005             |
|:-----------------------------:|:------------------------------|
| Barisal                       | Barisal                       |
| Chittagong                    | Chittagong                    |
| Dhaka                         | Dhaka                         |
| Khulna                        | Khulna                        |
| Mymenshingh                   | Dhaka                         |
| Rajshahi                      | Rajshahi                      |
| Rangpur                       | Rajshahi                      |
| Sylhet                        | Sylhet                        |

The division of Rangpur was created in 2010, splitting off Rajshahi, and consists of the districts of Dinajpur, Kurigram, Gaibandha, Lalmonirhat, Nilphamari, Panchagarh, Rangpur, and Thakurgaon.

The division of Mymensingh was created in 2015, splitting off Dhaka, and consists of the districts of Jamalpur. Mymensingh, Netrokona, and Sherpur.

### Employment: Industry Classification

The Bangladesh Labor Force Survey (QLFS) employs its national industry classification system called the Bangladesh Standards for Industrial Classification (BSIC), which is adapted from the International Standards for Industrial Classification (ISIC).

| Year | Classification in survey | ISIC revision mapped to | How mapped                |
|:----:|:------------------------:|:-----------------------:|:--------------------------|
| 2005 | BSIC 2001                | ISIC revision 3         | With correspondence table |
| 2010 | BSIC 2009                | ISIC revision #         | First two digits          |
| 2013 | Unknonw                  | ISIC revision #         | First two digits          |

For 2005, the correspondence is done at four digits based on [a PDF table](Utilities/BSIC_code.pdf), which we converted into a `.dta` file that is read in the harmonization process. The [file is available here](Utilities/Additional%20Data/bsic_isic_mapping.dta).

For 2009, ##TEXT##

In the case of 2013, the actual version is unkonwn, but a manual review of the codes agrees with the fact the coding is based on ISIC revision #. However, since the full correspondence is unknown, only the first two two digits are mapped to.

** Original text **
BSIC and ISIC classifications are comparable at the two-digit level. Over the years, the BSIC has been updated, resulting in different versions being used throughout the LFS. For instance, the 2005 LFS utilizes the BSIC 2001, which is comparable to ISIC version 3, while all subsequent rounds employ the BSIC 2009, which is in line with ISIC version 4.

A [correspondence table](Utilities/BSIC_code.pdf) is available for mapping BSIC 2001 codes to ISIC version 3 codes at the four-digit level. However, the team is currently gathering reference materials to determine how to map the BSIC 2009 to ISIC version 4 at the four-digit level. In the meantime, two-digit BSIC codes are used to identify the corresponding ISIC version 4 codes.
** End original text **

### Employment: Occupation Classification

**Kindly include a table a description as above for industry**

The Bangladesh Labor Force Survey (LFS) utilizes two different occupational classifications to identify respondents' occupations. According to survey documentation, the International Standard Classification of Occupations (ISCO) was used in the 2005 and 2010 rounds, while the Bangladesh Standard of Occupational Classification (BSOC) 2012 was used in the 2013, 2015, and 2016 rounds.

Although the survey documentation states that the occupational codes used in the 2005 and 2010 rounds were equivalent to ISCO 1988, some four-digit occupational codes could not be found within the ISCO 1988 list at the same level. Also, we do not possess a correspondence table to map the BSOC 2012 codes to the ISCO 2008 codes. Given the issues mentioned, we recourse to using the two-digit LFS occupational codes to identify the corresponding ISCO codes while continue our efforts to gather more resources for a precise mapping of occupational codes with ISCO.

