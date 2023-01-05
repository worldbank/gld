# GLD single survey external checks - Detailed description

## Overview

The GLD external comparison checks are a series of checks that compare GLD data (aggregate moments) with comparable statistics from external sources. In particular, we check the following data from GLD surveys:

Block 1. Demographics (file `B2.01`)
1.	Total population (number)
2.	Gender split (% of female population)
3.	Urban population (% of total)
4.	Children (0-14 years old, % of total population)
5.	Working Age Population (15-64 years old, % of total population)
6.	Seniors (65+ years old, % of total population)

Block 2. Labor Force Variables (file `B2.02`)
7.	Labor force size (number)
8.	Labor force participation rate (labor force / working age population )
9.	Employment (number)
10.	Employment to population ratio (employed / working age population)
11.	Unemployment rate (unemployed / labor force)
12.	Agriculture (% of employment)
13.	Industry (% of employment)
14.	Services (% of employment)
15.	Industry category (% of employment)

Block 3. Wage variables (file `B2.03`)
16.	Average hourly wages

## Variable aggregation in GLD data

To construct aggregate indicators from the GLD surveys, we weight sums and means by the weight GLD variable. The demographic variables are fully described in the previous section and computed in the do file “01_checks_demo_GLD.do”.

The “Labor Force Variables” from block 2 are defined as follows:
* Labor force size is the number of persons aged 15+ that are either employed or unemployed.
* Labor force participation rate is the labor force size divided by the population aged 15+.
* Employment is the number of persons aged 15+ that are employed.
* Employment to population ratio is employment (as defined above) divided by the population aged 15+.
* Unemployment rate is the number of unemployed people over the number of employed plus unemployed people. Note: no age requirement.
* Agriculture is the number of people employed that work in the agricultural or primary sector, over total people employed, times 100. Note: no age requirement
* Industry is the number of people employed that work in the industrial or secondary sector, over total people employed, times 100. Note: no age requirement
* Services is the number of people employed that work in the service or tertiary sector, over total people employed, times 100. Note: no age requirement
Notice that agriculture, industry, and services are three economic activity categories that cover all possible employment sectors.
* Industry category consists on 10 economic activity categories that cover all possible employment sectors, at a more granular level than the categories in the previous point. This variable is actually a set of 10 variables, defined as the number of people in each industry category, divided by the number of people with information in the “industrycat10” variable in GLD.

## External comparison sources

Each variable listed in “1. Overview” is matched with one or more comparable variables from external sources.

The sources used are
* [World Development Indicators](https://datatopics.worldbank.org/world-development-indicators) (WDI), from the World Bank. This is a collection of development indicators compiled from international sources. The data is downloaded using the [Stata module wbopendata](https://datahelpdesk.worldbank.org/knowledgebase/articles/889464-wbopendata-stata-module-to-access-world-bank-data).  
* ILOSTAT, from the [International Labor Organization](https://ilostat.ilo.org/data), accessed through the [Stata module dbnomics](https://db.nomics.world), developed by the [CEPREMAP](http://www.cepremap.fr/en/).
* UNdata, from the [United Nations](https://data.un.org), also accessed through dbnomics.

Note that the external data updates periodically. The GLD checks, will automatically use the latest data available in each of these sources. The Annex contains a complete list of the variables selected from these sources, along with the GLD variables they are matched with.

## Output: content overview

The survey checks process will create a folder called `Block2_External`, containing two folders:

* 01_data
* 02_figures

Each file in the 01_data folder can be matched to a figure in 02_figures. It contains the necessary data to generate that figure. Each .dta file consists of the following variables:

* year: the year for each value in the data set.
* value: the relevant point estimate for each source, represented as a dot in the figures
* ub: the upper bound of the value, set at 1.1*value (10% above) for most variables.
* lb : the lower bound of the value, set at 0.1*value (10% below) for most variables.
* countrycode: the 2 or 3-digit code corresponding to the country of the survey
* source: string name of the source behind each value. One of the entries in this column will be “GLD”, the rest will be the external sources we use to compare

The figures folder contains 25 pdf files named Fig1.pdf to Fig16.pdf, with 10 versions of Fig15, called Fig15_1.pdf to Fig15_10.pdf. All are graphical representations of the quality check comparisons (more details in next section). Additionally, there are four group figures: 2A collects Figures 1 through 6, 2B1 Figures 7 through 14, 2B2 Figures 15_1 through 15_10, and 2C Figure 16.

Each figure in the folder “02_figures” is the graphical representation of and individual check run on the data from the input GLD survey, consisting of the following elements:

*	A title, indicating the variable being checked,
*	A y-axis, with the values the variable may take
*	An x-axis, which represents the different data sources: GLD (as the left-most x-axis value) and the one or multiple comparison sources (to its right)
*	The data, in red or blue segments:
  *	A red segment representing the GLD harmonized survey estimate.
  *	A blue segment representing the estimate drawn from an external source, the name of which is denoted in the x-axis tick label.
  *	A solid line means that the year of the data is the same as the year of the survey while a dashed line means that we are using data from a different year (as data for the given estimate was not available for the survey year)
  *	Each segment consists of two distinct parts: The first is a central point (dot or triangle) showing the precise estimate for each variable and source. The second are the lines stretching out above and below the central point representing an upper and lower bound of the estimate (commonly 10% above and below the point estimate).

These figures allow us to visually see if the values in GLD are close to the values from external sources. In the [Flags Methodology](##flags-methodology)” section we describe precisely the circumstances under which we consider the values to be “too far off”.

Additionally, the external check process places in the summary folder a PDF file ("B2_external_flags") with all figures that have been flagged. The role of this file is to present a snapshot of the variables whose estimates are clearly different from the external sources we use as comparison, which may indicate a problem in the harmonization or other issues that require our attention.

As well, an overview Excel file (called "B2_external_results.xlsx") is created, detailing the information behind each check. The rows are made up of a first row denoting column names and up to 25 for each of the checks undertaken to the GLD data. If there are fewer than 25 check rows, then some checks have not been performed. This happens when some variables are not available in the original GLD dataset (e.g., no urban/rural data recorded).

The file consists of the following 18 columns:
1.	Year: Year of the GLD survey, as described in “section 3. Output”.
2.	Country: ISO Alpha-3 country code of the country in the GLD survey.
3.	Survey: Type of GLD survey (for instance: LFS, QLFS, etc).
4.	Varchecked: Stands for “Variable checked” and is the variable we are testing in the GLD data.
5.	Varorder: Stands for “Variable order” and is a numeric variable ranging from 1 to the number of checks for that survey (up to 25). It allows us to sort the checks in the default order (starting with “Total population” and ending with “Average hourly wages”).
6.	Val_pe: Stands for “Value point-estimate”. This is the value for the variable in that row computed from GLD.
7.	Val_lb: Stands for “Value lower-bound”. It is the result of multiplying the val_pe by a number 0.95 (0.90 for the variable “average hourly wages”). By construction, this results in a value 5% (or 10%) lower than val_pe.
8.	Val_ub:  Stands for “Value upper-bound”. It is the result of multiplying the val_pe by a number 1.05 (1.10 for the variable “average hourly wages”). By construction, this results in a value 5% (or 10%) higher than val_pe.
9.	Com_pe: Stands for “Comparison point estimate”. It is the result of averaging all the values from external sources of the variable we are testing. That is, if we are using two external sources to test “total population” (eg. ILO and UN), com_pe will be the average of “total population” in each of these two sources. For whichever number of sources we are using, com_pe will be the average of the value in the sources we are using.
10.	Com_lb: Stands for “Comparison lower bound”.  It is the result of multiplying the com_pe by a number 0.95 (0.90 for the variable “average hourly wages”). By construction, this results in a value 5% (or 10%) lower than com_pe.
11.	Com_ub: Stands for “Comparison upper-bound”. It is the result of multiplying the com_pe by a number 1.05 (1.10 for the variable “average hourly wages”). By construction, this results in a value 5% (or 10%) higher than com_pe.
12.	Com_cases: Indicates how many actual values we are using to establish the comparison. Often times, two different external sources will report the exact same value, because they take the data from one another. For instance, WDI takes data from sources such as ILO. Therefore, if we look at the labor force size in WDI and in ILO, we will obtain the exact same point. Com_cases keeps track of this, and indicates how many different values we are dealing with, rounded to the 0.01 value.
13.	Diff: Reports the absolute difference between val_pe and com_pe. In the figures, this represents the distance between the dot in the GLD value and the average of the external sources’ dots.
14.	Dist1: The distance between the val_lb and com_ub. That is, the distance from the lower bound of the GLD value to the upper bound of the (average of) external sources. When this distance is positive, the lower bound of the GLD value is above the upper limit we give to the external sources, ie, our value is way above the external sources.
15.	Dist2: The distance between com_lb and val_ub. That is, the distance between the lower bound of the external sources and the upper bound of the GLD value. When this distance is positive, it means that the lower bound of the external sources is above the upper limit we give to the GLD value. That is, the external sources are (on average) well above the GLD value. That, our value is way below the external sources.
16.	F1: An indicator value that takes value of 1 when dist1 is positive (we omit the 0s). That is, it indicates when the GLD value is well above the external sources.
17.	F2: An indicator value that takes the value of 1 when dist2 is positive (again, we omit the 0s). It indicates when the GLD value is well below the external sources.
18.	Flag: An indicator value that takes the value 1 when either F1 or F2 are 1, 0 (or missing/blank) otherwise. That is, it indicates when a GLD variable is either well above or below the external sources’ estimate. Graphically, it means that the segment of the GLD value does not intersect the imaginary segment generated by the average of the external sources.


## Flags Methodology

This section details the flags methodology. Some parts have already been addressed in previous sections. Nonetheless this section explains the methodology in its entirety.

One of the main goals of the checks process is to detect GLD variables that differ substantially from that same variable as reported from external sources.

To conduct this analysis, we need the following elements
1.	A GLD variable
2.	A benchmark to compare the external variable with
3.	A measure of distance between (1) and (2)
4.	A threshold above which the distance in (3) is considered too large

For point (1), we use the GLD variables described in [Overview](##overview).

For point (2), we average the external variables listed in the Annex. Note that for each GLD variable we have one or more variables from external sources we wish to compare it to. By averaging all the variables from external sources, we guarantee we have one single benchmark per variable.

Two further clarifications on the benchmark values:

*	In the future, we may want to change this to a weighted average, to account for the fact that some sources matter more than others. In particular, we know not all external variables are from the same year. Hence, we may want to give a higher weight to the external sources that are from the same year as the variable.
*	We know that some external sources report the same value, because they ultimately come from the same source (e.g., WDI takes data from ILO). Note that at this point, we are not correcting for this: we are giving equal weights at all sources regardless of how “original” their values are.

Finally, it is worth noting that neither of the points mentioned above is guaranteed to affect the results. In fact, the results have proven to be fairly robust, and it is likely that a more elaborate weighting process will not translate in any noticeable differences in the output.

For point (3), to measure the distance between (1) GLD and (2) the average of the external sources, we consider two cases of particular interest:
•	For the cases in which the GLD data is above the external data, we calculate the distance between a lower bound of the GLD data and an upper bound of the external data. If this distance is positive, then the GLD is considerably above the external sources. If the distance is 0, it means that the lower bound of the GLD data is exactly the same as the upper bound of the external data. If the distance is negative, it means that the lower bound of the GLD data is below the upper bound of the external data. Thinking in terms of the segments represented in the figures, a negative distance represents an overlap between the GLD segment and the average of the external segments, and a positive distance means no intersection of the segments
•	For the cases in which the GLD data is below the external data, we proceed symmetrically. That is, we compute the difference between lower bound of the average of external values and the upper bound of the GLD data. If this distance is positive, then the lower bound of the external variables is above the upper bound of the GLD variable. That is, the GLD value is very far away from the comparison values. If the distance is 0, then the lower bound of the external variables coincides exactly with the upper bound of the GLD data. If it is negative, then the upper bound of the GLD data is higher than the lower bound of the external data, i.e., the segments intersect.

As explained above, a positive distance between the two points implies a large difference between the GLD values and the external values. Hence, these are the cases that we flag. That is, we will flag a GLD variable from the list in [Overview](##Overview) if any of the two following conditions hold:

*	The distance between the lower bound of the GLD data and the upper bound of average of the external data is positive.
*	The distance between the lower bound of the average of the external data and the upper bound of the GLD data is positive.

It remains to explain how we chose these upper and lower bounds, which effectively determine the thresholds we use to flag the data (point (4) in the list of required elements). Here, we use a threshold of 5% to compute the upper/lower bounds for all the variables, and 10% for the wage related variables. That is, for most variables, we will flag a GLD variable if the difference between the value it takes and the average of the external sources is equal or higher than 5% de value of the GLD variable plus 5% the value of the external sources.

Graphically, we will flag the variables where the GLD segment and the imaginary segment defined by the average of the external sources do not intersect.


## Annex

The exact indicators we use to establish the comparisons are the following:

1.	Total population
  1.	`SP.POP.TOTL`, Total population, WDI
  2.	`A.N.”CC”.W0.S1.S1._Z.POP._Z._Z._Z.PS._Z.N`, Total population, NA Main Aggregates, UNData
    *	Unit of measure: “PS” (persons)
  3.	`POP_2POP_GEO_NB`, Population by rural / urban areas -- UN estimates and projections, Nov. 2020 (thousands), ILO
    *	Classif1: "GEO_COV_NAT" (national geographic coverage)
  4.	`POP_2POP_SEX_AGE_NB`, Population by sex and age -- UN estimates and projections, Nov. 2021 (thousands), ILO
    *	Sex: SEX_T (total)
    *	Classif1: "AGE_10YRBANDS_TOTAL" (total age, classified in 10 year bands)

2.	Gender split (% of female population)
  1.	`SP.POP.TOTL.FE.ZS`, Population, female (% of total population), WDI
  2.	`POP_2POP_SEX_AGE_NB`, Population by sex and age -- UN estimates and projections, Nov. 2021 (thousands), ILO
    *	Sex: “SEX_F” & “SEX_T” (Female & Total. Female for the numerator, total for the denominator)
    *	Classif1: AGE_AGGREGATE_TOTAL (total age, classified in aggregates)
  3.	`POP_2POP_GEO_NB`, Population by rural / urban areas -- UN estimates and projections, Nov. 2020 (thousands), ILO
    *	Sex: “SEX_F” & “SEX_T” (Female & Total. Female for the numerator, total for the denominator)
    *	Classif1: “AGE_AGGREGATE_TOTAL” (total age, classified in aggregates)
    *	Classif2: “GEO_COV_NAT” (national geographic coverage)

3.	Urban population (% of total)
  1.	`SP.URB.TOTL.IN.ZS`, Urban population (% of total population), WDI
  2.	`POP_2POP_GEO_NB`, Population by rural / urban areas -- UN estimates and projections, Nov. 2020 (thousands), ILO
    *	Classif1: “GEO_COV_NAT” & “GEO_COV_URB (national & urban geographic coverage)

4.	Children (0-14 years old, % of total population)
  1.	`SP.POP.0014.TO.ZS`, Population ages 0-14 (% of total population), WDI
  2.	`POP_2POP_SEX_AGE_NB`, Population by sex and age -- UN estimates and projections, Nov. 2021 (thousands), ILO
    *	Sex: SEX_T (total)
    *	Classif1: “AGE_5YRBANDS_TOTAL”. In particular, we select age groups “AGE_5YRBANDS_Y00-04”, “AGE_5YRBANDS_Y05-09” and “AGE_5YRBANDS_Y10” to compute the numerator.
  3.	`POP_2POP_GEO_NB`, Population by rural / urban areas -- UN estimates and projections, Nov. 2020 (thousands), ILO
    *	Sex: SEX_T (total)
    *	Classif1: "AGE_5YRBANDS_TOTAL". In particular, we select age groups “AGE_5YRBANDS_Y00-04”, “AGE_5YRBANDS_Y05-09” and “AGE_5YRBANDS_Y10” to compute the numerator.
    *	Classif2: "GEO_COV_NAT"

5.	Adults (15-64 years old, % of total population)
  1.	`SP.POP.1564.TO.ZS`, Population ages 15-64 (% of total population), WDI
  2.	`POP_2POP_SEX_AGE_NB`, Population by sex and age -- UN estimates and projections, Nov. 2021 (thousands), ILO
    *	Sex: SEX_T (Total)
    *	Classif1: "AGE_5YRBANDS_TOTAL". In particular, we select age groups "AGE_5YRBANDS_Y15-19" , "AGE_5YRBANDS_Y20-24", "AGE_5YRBANDS_Y25-29", "AGE_5YRBANDS_Y30-34", "AGE_5YRBANDS_Y35-39, "AGE_5YRBANDS_Y40-44", "AGE_5YRBANDS_Y45-49”, "AGE_5YRBANDS_Y50-54", "AGE_5YRBANDS_Y55-59" and "AGE_5YRBANDS_Y60-64" to compute the numerator.
  3.	`POP_2POP_GEO_NB`, Population by rural / urban areas -- UN estimates and projections, Nov. 2020 (thousands), ILO
    *	Sex: SEX_T (total)
    *	Classif1: "AGE_5YRBANDS_TOTAL"". In particular, we select age groups "AGE_5YRBANDS_Y15-19" , "AGE_5YRBANDS_Y20-24", "AGE_5YRBANDS_Y25-29", "AGE_5YRBANDS_Y30-34", "AGE_5YRBANDS_Y35-39, "AGE_5YRBANDS_Y40-44", "AGE_5YRBANDS_Y45-49”, "AGE_5YRBANDS_Y50-54", "AGE_5YRBANDS_Y55-59" and "AGE_5YRBANDS_Y60-64" to compute the numerator.
    *	Classif2: "GEO_COV_NAT" (national geographic coverage)

6.	Seniors (65+ years old, % of total population)
  1.	`SP.POP.65UP.TO.ZS`, Population ages 65 and above (% of total population), WDI
  2.	`POP_2POP_SEX_AGE_NB`, Population by sex and age -- UN estimates and projections, Nov. 2021 (thousands), ILO
    *	Sex: SEX_T (total)
    *	Classif1: "AGE_5YRBANDS_TOTAL". In particular, we select age group "AGE_5YRBANDS_YGE65" to compute the numerator.
  3.	`POP_2POP_GEO_NB`, Population by rural / urban areas -- UN estimates and projections, Nov. 2020 (thousands), ILO
    *	Sex: SEX_T (total)
    *	Classif1: "AGE_5YRBANDS_TOTAL". In particular, we select age group "AGE_5YRBANDS_YGE65" to compute the numerator.
    *	Classif2: "GEO_COV_NAT" (national geographic coverage)

7.	Labor force size (number)
  1.	`SL.TLF.TOTL.IN`, Labor force, total, WDI
  2.	`EAP_TEAP_SEX_AGE_NB`, Labour force by sex and age (thousands), ILO
    *	Sex: SEX_T (total)
    *	Classif1: "AGE_10YRBANDS_TOTAL"
  3.	`EAP_2EAP_SEX_AGE_NB`, Labour force by sex and age -- ILO modelled estimates, Nov. 2021 (thousands), ILO
    *	Sex: SEX_T (total)
    *	Classif1: " AGE_YTHADULT_YGE15" (Age +15)

8.	Labor force participation rate (labor force/ total population)
  1.	`SL.TLF.CACT.ZS`, Labor force participation rate, total (% of total population ages 15+) (modeled ILO estimate), WDI
  2.	`SL.TLF.CACT.NE.ZS`, Labor force participation rate, total (% of total population ages 15+) (national estimate), WDI
  3.	`SL.TLF.CACT.NE.ZS`, Labor force participation rate, total (% of total population ages 15+) (national estimate), WDI
  4.	`EAP_DWAP_SEX_AGE_RT`, Labour force participation rate by sex and age (%), ILO
    *	Sex: SEX_T (total)
    *	Classif1: " AGE_YTHADULT_YGE15" (Age +15)
  5.	`EAP_2WAP_SEX_AGE_RT`, Labour force participation rate by sex and age – ILO modelled estimates, Nov. 2021 (%), ILO
    *	Sex: SEX_T (total)
    *	Classif1: " AGE_YTHADULT_YGE15" (Age +15)

9.	Employment (number)
  1.	`EMP_TEMP_SEX_AGE_NB`, Employment by sex and age (thousands), ILO
    *	Sex: SEX_T (total)
    *	Classif1: " AGE_YTHADULT_YGE15" (Age +15)
  2.	`EMP_2EMP_SEX_AGE_NB`, Employment by sex and age -- ILO modelled estimates, Nov. 2021 (thousands)
    *	Sex: SEX_T (total)
    *	Classif1: " AGE_YTHADULT_YGE15" (Age +15)

10.	Employment to population ratio (employed/ total population)
  1.	`SL.EMP.TOTL.SP.ZS`, Employment to population ratio, 15+, total (%) (modeled ILO estimate), WDI
  2.	`SL.EMP.TOTL.SP.NE.ZS`, Employment to population ratio, 15+, total (%) (national estimate), WDI
  3.	`EMP_DWAP_SEX_AGE_RT`, Employment-to-population ratio by sex and age (%), ILO
    *	Sex: SEX_T (total)
    *	Classif1: " AGE_YTHADULT_YGE15" (Age +15)
  4.	`EMP_2WAP_SEX_AGE_RT`, Employment-to-population ratio by sex and age -- ILO modelled estimates, Nov. 2021 (%), ILO
    *	Sex: SEX_T (total)
    *	Classif1: " AGE_YTHADULT_YGE15" (Age +15)

11.	Unemployment rate (unemployed/ labor force)
  1.	`SL.UEM.TOTL.ZS`, Unemployment, total (% of total labor force) (modeled ILO estimate), WDI
  2.	`SL.UEM.TOTL.NE.ZS`, Unemployment, total (% of total labor force) (national estimate), WDI
  3.	`UNE_DEAP_SEX_AGE_RT`, Unemployment rate by sex and age (%), ILO
    *	Sex: SEX_T (total)
    *	Classif1: " AGE_AGGREGATE_TOTAL" (Total age)
  4.	`UNE_2EAP_SEX_AGE_RT`, Unemployment rate by sex and age -- ILO modelled estimates, Nov. 2021 (%), ILO
    *	Sex: SEX_T (total)
    *	Classif1: " AGE_YTHADULT_YGE15" (Age +15)

12.	Agriculture (% of employment)
  1.	`SL.AGR.EMPL.ZS`, Employment in agriculture (% of total employment) (modeled ILO estimate), WDI
  2.	`EMP_TEMP_SEX_ECO_NB`, Employment by sex and economic activity (thousands), ILO
    *	Sex: SEX_T (total)
    *	Classif1: " ECO_SECTOR_AGR" and "ECO_SECTOR_TOTAL" (agriculture and total)
  3.	`EMP_2EMP_SEX_ECO_NB`, Employment by sex and economic activity -- ILO modelled estimates, Nov. 2020 (thousands), ILO
    *	Sex: SEX_T (total)
    *	Classif1: " ECO_SECTOR_AGR" and "ECO_SECTOR_TOTAL" (agriculture and total)

13.	Industry (% of employment)
  1.	`SL.IND.EMPL.ZS`, Employment in industry (% of total employment) (modeled ILO estimate), WDI
  2.	`EMP_TEMP_SEX_ECO_NB`, Employment by sex and economic activity (thousands), ILO
    *	Sex: SEX_T (total)
    *	Classif1: " ECO_SECTOR_IND" and "ECO_SECTOR_TOTAL" (industry and total)
  3.	`EMP_2EMP_SEX_ECO_NB`, Employment by sex and economic activity -- ILO modelled estimates, Nov. 2020 (thousands), ILO
    *	Sex: SEX_T (total)
    *	Classif1: " ECO_SECTOR_IND" and "ECO_SECTOR_TOTAL" (industry and total)

14.	Services (% of employment)
  1.	`SL.SRV.EMPL.ZS`, Employment in services (% of total employment) (modeled ILO estimate), WDI
  2.	`EMP_TEMP_SEX_ECO_NB`, Employment by sex and economic activity (thousands), ILO
    *	Sex: SEX_T (total)
    *	Classif1: " ECO_SECTOR_SER" and "ECO_SECTOR_TOTAL" (services and total)
  3.	`EMP_2EMP_SEX_ECO_NB`, Employment by sex and economic activity -- ILO modelled estimates, Nov. 2020 (thousands), ILO
    *	Sex: SEX_T (total)
    *	Classif1: " ECO_SECTOR_SER" and "ECO_SECTOR_TOTAL" (services and total)

15.	Industry category (% of employment)
  1.	`EMP_TEMP_SEX_ECO_NB`, Employment by sex and economic activity (thousands), ILO
    *	Sex: SEX_T (total)
    *	Classif1: ECO_ISIC4_TOTAL & ECO_ISIC4_A - ECO_ISIC4_U or
    *	ECO_ISIC3_TOTAL and ECO_ISIC3_A - ECO_ISIC3_X
  2.	`EMP_2EMP_SEX_ECO_NB`, Employment by sex and economic activity -- ILO modelled estimates, Nov. 2020 (thousands), ILO
    *	Sex: SEX_T (total)
    *	Classif1: ECO_DETAILS_TOTAL & ECO_ DETAILS _A - ECO_ DETAILS_RSTU

16.	Hourly wages
  1.	`EAR_HEES_SEX_OCU_NB`, Mean nominal hourly earnings of employees by sex and occupation (local currency), ILO
    *	Sex: SEX_T (total)
    *	Classif1 == "OCU_ISCO88_TOTAL" (Total occupations)
  2.	`NY.GDP.PCAP.CN`, GDP per capita (current LCU), ILO
    *	Times 2/3 (labor share), divided by 2080 (number of full time working-hours in a year, 40h/week*52weeks = 2080 h)
