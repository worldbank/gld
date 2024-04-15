# Demography

## Mapping and Description of Variables

### hsize

hsize codes the size of the household. This should not include individuals who may be living in the household but do not form an economic unit with the other household members (e.g., a live-in maid is not part of the household).

### age

age refers to the interval of time between the date of birth and the date of the survey. Every effort should be made to determine the precise and accurate age of each person, particularly of children and older persons. Information on age may be secured either by obtaining the date (year, month, and day) of birth or by asking directly for age at the person’s last birthday. In addition, in the case of children aged less than or equal to 60 months, variable age should be expressed in the number of completed years and months in decimals. For example, If the interview of a 4 years old was in December and he was born in June, his age should be recorded as 4.5. Lastly, if the information on age is not available, it should be coded as missing rather than some other value such as “99” or “999”.

### male

male is a dummy variable that specifies the sex – male or female – of an individual within a household. While constructing this variable, it is important to make sure that all relevant values are included. Variable values coded as ‘98’ or other numeric characters should be excluded from the values of the \`male’ variable. Sex of household member, two categories after harmonization:

1 = male

0 = female

### relationharm

relationharm is a string variable that indicates a relationship to the reference person of household (usually the head of household). Variable values coded as ‘98’ or other numeric characters should be excluded from the values of relationharm variable.

Relationship to head of household, six categories after harmonization:

1=head

2=spouse

3=children

4=parents

5=other relatives

6=non-relatives

Note: In cases where head is missing or a migrant, we assign spouse as the head of the household. If spouse is also not available, then we will use oldest member of the household as the head and recode all the relations to head accordingly.

### relationcs

relationcs is a country-specific categorical variable that indicates the relationship to the head of the household. The categories for relationship to the head of the household are defined according to the region or country requirements.

### marital

Marital is a categorical variable that refers to the personal status of each individual in relation to the marriage laws or customs of the country. The categories of marital status to be identified should include at least the following: (a) single (in other words, never married); (b) married; (c) married but separated;

(d) windowed and remarried; (e) divorced and not remarried. In some countries, category (b) may require a subcategory of persons who are contractually married but not yet living as man and wife. In all countries, category (c) should comprise both the legally and the de facto separated, who may be shown as separate subcategories if desired. The marital variable should not be imputed but rather calculated only for those to whom the question was asked (in other words, the youngest age at which information is collected may differ depending on the survey). The consistency between age and marital needs to be cross-checked. In most countries, there are also likely to be persons who were permitted to marry below the legal minimum age because of special circumstances. To permit international comparisons of data on marital status, however, any tabulations of marital status not cross-classified by exact age should at least distinguish between persons under 15 years of age and over. If it is not possible to distinguish between married and living together, then it should be assumed that the individual is married. Variable values coded as ‘98’ or other numeric characters should be excluded from the values of the ‘marital’ variable.

Marital status, five categories after harmonization:

1=married

2=never married

3=living together

4=divorced/separated

5=widowed

### eye_dsablty

eye_dsablty is a numerical variable that indicates whether an individual has any difficulty in seeing, even when wearing glasses. Categories after harmonization:

1 = No – no difficulty

2 = Yes – some difficulty

3 = Yes – a lot of difficulty

4 = Cannot do at all

### hear_dsablty

hear_dsablty is a numerical variable that indicates whether an individual has any difficulty in hearing even when using a hearing aid. Categories after harmonization:

1 = No – no difficulty

2 = Yes – some difficulty

3 = Yes – a lot of difficulty

4 = Cannot do at all

### walk_dsablty

walk_dsablty is a numerical variable that indicates whether an individual has any difficulty in walking or climbing steps. Categories after harmonization:

1 = No – no difficulty

2 = Yes – some difficulty

3 = Yes – a lot of difficulty

4 = Cannot do at all

### conc_dsord

conc_dsord is a numerical variable that indicates whether an individual has any difficulty concentrating or remembering. Categories after harmonization:

1 = No – no difficulty

2 = Yes – some difficulty

3 = Yes – a lot of difficulty

4 = Cannot do at all

### slfcre_dsablty

slfcre_dsablty is a numerical variable that indicates whether an individual has any difficulty with self-care such as washing all over or dressing. Categories after harmonization:

1 = No – no difficulty

2 = Yes – some difficulty

3 = Yes – a lot of difficulty

4 = Cannot do at all

### comm_dsablty

comm_dsablty is a numerical variable that indicates whether an individual has any difficulty communicating or understanding usual (customary) language. Categories after harmonization:

1 = No – no difficulty

2 = Yes – some difficulty

3 = Yes – a lot of difficulty

4 = Cannot do at all

## Lessons Learned and Challenges

Data sets that are harmonized incorrectly can lead to skewed and/or incorrect data analysis. Harmonizers should run a series of checks to ensure data is harmonized properly, including the following:

Check to make sure that age is an integer since 5 years old.
```
age/int(age)!= 1 & age!= . & age > 5
```
age cannot have negative or extreme values (>120)
```
(age &lt; 0 | age&gt;120) & age<.
```
Age cannot be missing
```
age==.
```
Male variable can only take one of two values 0 or 1 (or missing).
```
male!=. & male!= 1 & male!= 0
```
Check if male is missing.
```
male==.
```
Check to make sure that there is variation in male
```
egen sdmale = sd(male) // sdmale should not be 0
```
relationharm must be an integer in the range \[1,6\].
```
relationharm<1 & relationharm>6 & mod(relationharm, 1) == 1
```
marital must be an integer in the range \[1,5\].
```
mMarital<0 & marital>5 & mod(marital, 1) == 1
```
Children are “Never married” and should be coded as so even though it may be perceived as obvious. The marital status of individuals should be harmonized for all individuals. Harmonizers should check to make sure children are not systematically left with missing values for marital.
```
tab age marital, missing
```
weight cannot be missing
```
weight==.
```
Additionally, harmonizers should ensure that the household size variable is calculated correctly. Not all the individuals reported in a household that form the raw data are current household members. For example, for the EU-SILC survey, a household contains the current member, but also the members of the previous survey who have left the household for reasons such as death or migration.

## Tabular Overview of Variables

| Module Code | Variable name | Variable label | Notes |
| --- | --- | --- | --- |
| Demography | hsize | Household size |     |
| Demography | age | Age in years |     |
| Demography | male | Binary - Individual is male |     |
| Demography | relationharm | Relationship to head of household harmonized across all regions | GMD - Harmonized categories across all regions. Same as I2D2 categories. |
| Demography | relationcs | Relationship to head of household country/region specific | country or regionally specific categories |
| Demography | marital | Marital status |     |
| Demography | eye_dsablty | Difficulty seeing | See "Recommended Short Set of Questions" on <https://www.cdc.gov/nchs/washington_group/wg_questions.htm> |
| Demography | hear_dsablty | Difficulty hearing |
| Demography | walk_dsablty | Difficulty walking / steps |
| Demography | conc_dsord | Difficulty concentrating |
| Demography | slfcre_dsablty | Difficulty w/ selfcare |
| Demography | comm_dsablty | Difficulty communicating |