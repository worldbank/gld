# Introduction
Since the passing of the [resolution concerning statistics of work, employment and labour underutilization](https://www.ilo.org/global/statistics-and-databases/standards-and-guidelines/resolutions-adopted-by-international-conferences-of-labour-statisticians/WCMS_230304/lang--en/index.htm) in 2013 at the 19th International Conference of Labour Statisticians (ICLS) surveys are at risk of a series break due to the change in the concept of employment.

In short, the ICLS 19 resolution restricts employment to *work performed for others in exchange for pay or profit*, meaning that own consumption work (e.g., subsistence agriculture or building housing for oneself) are not counted as employment.

# Coding to convert the 2024 ILFS to the old definition

To apply the 13th ICLS definition, workers engaged in subsistence or own-use agricultural production are identified and added to the employed population. Under the 19th ICLS, these workers are excluded from employment by design: in the 2024 PAK LFS, the skip pattern routes respondents who produce mainly or solely for family use out of the employment module entirely, meaning they never reach the questions on industry, occupation, or employment status. For these workers, those variables are therefore assigned directly based on their activity type — agriculture (industrycat10 = 1), skilled agricultural occupations (occup = 6), and self-employment (empstat = 4). The code below implements this approach for surveys where the 13th ICLS definition is required.
```
* ------------------------------------------------------------------
* ICLS 13th BRIDGE CODE — PAK LFS 2024
* Reconstructs employment variables as they would appear under ICLS 13
* The excluded group: subsistence/own-use agricultural producers
* identified by extra_icls_13_emp == 1, which captures two paths:
*   (a) Went through S5C9 (farming/livestock/fishing, S5C9=1-3)
*       AND products mainly/only for family use (S5C10=3-4)
*   (b) Went through the S5C8 route (S5C1=S5C2=S5C3=S5C4=2,
*       S5C8=1-3) AND products mainly/only for family use (S5C10=3-4)
* Under ICLS 19 these workers are not employed; under ICLS 13 they are.
* ------------------------------------------------------------------

* IDENTIFY THE ICLS 13 ADDITIONAL GROUP
* These are workers who are NOT already classified as employed under ICLS 19
* (hence the missing(lstatus) condition), but would be employed under ICLS 13

gen extra_icls_13_emp = 0

* Path (a): routed through S5C9 as farming/livestock/fishing
*           AND products mainly or only for family use (S5C10 = 3 or 4)
replace extra_icls_13_emp = 1 if inrange(s5c9, 1, 3) & inrange(s5c10, 3, 4) & missing(lstatus)

* Path (b): routed through S5C8 (did not work, did not have job, no absence)
*           engaged in farming/rearing/fishing (S5C8 = 1-3)
*           AND products mainly or only for family use (S5C10 = 3 or 4)
replace extra_icls_13_emp = 1 if s5c1==2 & s5c2==2 & s5c3==2 & s5c4==2 ///
    & inrange(s5c8, 1, 3) & inrange(s5c10, 3, 4) & missing(lstatus)

* ------------------------------------------------------------------
* BRIDGE VARIABLES
* ------------------------------------------------------------------

* LSTATUS: add back as employed
gen lstatus_old = lstatus
replace lstatus_old = 1 if extra_icls_13_emp == 1
label var lstatus_old "Labor status - 13th ICLS definition"

* EMPSTAT: self-employed (independent worker, code 4)
* Subsistence producers have no employer and work on own account
gen empstat_old = empstat
replace empstat_old = 4 if extra_icls_13_emp == 1
replace empstat_old = . if lstatus_old != 1
label var empstat_old "Employment status - 13th ICLS definition"

* INDUSTRYCAT10: Agriculture (category 1, ISIC 0100-0399)
* All these workers came through farming/rearing/fishing routes
gen industrycat10_old = industrycat10
replace industrycat10_old = 1 if extra_icls_13_emp == 1
replace industrycat10_old = . if lstatus_old != 1
label var industrycat10_old "Industry category - 13th ICLS definition"

* OCCUP: Skilled agricultural workers (category 6, ISCO 6000-6999)
gen occup_old = occup
replace occup_old = 6 if extra_icls_13_emp == 1
replace occup_old = . if lstatus_old != 1
label var occup_old "Occupation - 13th ICLS definition"


```
We report below results under two ICLS definitions for the labour variables: employment, industry, and occupation. The difference between the two classifications amounts to approximately 2.2 million workers engaged in own-use agricultural production, who are counted as employed under the 13th ICLS but not under the 19th. As a result, total employed stands at 77,595,355 under ICLS-13 and 75,396,847 under ICLS-19, corresponding to employment-to-population ratios of 51.46% and 50.00% respectively. The share of wage employment is 43.26% under ICLS-13 and 43.75% under ICLS-19. The share of employed in agriculture is 34.44% under ICLS-13 and 32.53% under ICLS-19. The skilled agricultural occupation share is 29.52% under ICLS-13 and 27.47% under ICLS-19. Self-employment accounts for 36.06% under ICLS-13 and 35.84% under ICLS-19. Non-agricultural categories are unaffected by the classification choice.

| Concept (all 15+) | Value 2020 ICLS-13 | Value 2024 ICLS-13 | Value 2024 ICLS-19 |
|---|---|---|---|
| Employment share | 49.35% | 51.46% | 50% |
| Unemployment share* | 5.58% | 6.86% | 7.05% |
| Share of wage employed | 42.19% | 42.51% | 43.75% |
| Share of employed in Ag (industry) | 37.15% | 34.44% | 32.53% |
| Share of employed as farmers (occupation) | 33.82% | 29.52% | 27.47% |
Note*: Unemployment share is the value of unemployment divided by the labor force.

Note on cross-year comparability: The values presented in this table should not be interpreted as trends or used for direct cross-year comparison. Differences across columns reflect a combination of factors including:

(1) The 2020 round was implemented under ICLS-13 definitions, while the 2024 round includes estimates under both ICLS-13 and ICLS-19. The shift in the definitions framework affects the classification of labor force status and should be taken into account when comparing values across years.

(2)  Between 2020 and 2024, the questionnaire introduced a single new category — "independent worker without employee" — to subsume the various types of own-account workers previously captured separately for agricultural and non-agricultural activities. This change in how employment status is elicited is likely to have affected the way workers are classified, and is reflected in the data in the share of workers categorized as self-employed.

(3) The Pakistan LFS is generally representative at the province and urban/rural levels. The 2020 round was an exception, having been designed to be representative to the district level, resulting in a broader and more granular sample. Differences in geographic coverage and sample composition across rounds may affect the resulting estimates independently of any actual changes in labor market outcomes.


