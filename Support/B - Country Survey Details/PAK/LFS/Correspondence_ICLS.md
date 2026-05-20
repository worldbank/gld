# Introduction
Since the passing of the [resolution concerning statistics of work, employment and labour underutilization](https://www.ilo.org/global/statistics-and-databases/standards-and-guidelines/resolutions-adopted-by-international-conferences-of-labour-statisticians/WCMS_230304/lang--en/index.htm) in 2013 at the 19th International Conference of Labour Statisticians (ICLS) surveys are at risk of a series break due to the change in the concept of employment.

In short, the ICLS 19 resolution restricts employment to *work performed for others in exchange for pay or profit*, meaning that own consumption work (e.g., subsistence agriculture or building housing for oneself) are not counted as employment.

# Coding to convert the 2024 ILFS to the old definition

In converting back to the 13th ICLS definition, the approach adopted here is to identify workers engaged in subsistence or own-use agricultural production who are excluded from employment under the 19th ICLS. In the 2024 PAK LFS, these workers are precisely identified by whether they produce mainly or solely for family use — the skip pattern that routes them out of the employment module entirely. Since these workers never reach the employment questions, their industry, occupation, and employment status must be imputed: they are assigned to agriculture (industrycat10 = 1), skilled agricultural occupations (occup = 6), and self-employment (empstat = 4), consistent with their activity type. The code below is suggested to conduct comparision analysis with surveys that use the old ICLS definition. 
```
* ------------------------------------------------------------------
* ICLS 13th BRIDGE CODE — PAK LFS 2024
* Reconstructs employment variables as they would appear under ICLS 13
* The excluded group: subsistence/own-use agricultural producers
* identified by S5C10 = 3 or 4 (products mainly/only for family use)
* These workers were skipped to Section 9 under ICLS 19 and have
* no employment module responses (S5C11, S5C12, S5C13 all missing)
* ------------------------------------------------------------------

* LSTATUS: add back as employed
gen lstatus_old = lstatus
replace lstatus_old = 1 if inrange(s5c10, 3, 4)
label var lstatus_old "Labor status - 13th ICLS definition"

* EMPSTAT: self-employed (independent worker, code 4)
* Subsistence producers have no employer and work on own account
gen empstat_old = empstat
replace empstat_old = 4 if inrange(s5c10, 3, 4)
replace empstat_old = . if lstatus_old != 1
label var empstat_old "Employment status - 13th ICLS definition"

* INDUSTRYCAT10: Agriculture (category 1, ISIC 0100-0399)
* All these workers came through S5C8 farming/rearing/fishing
gen industrycat10_old = industrycat10
replace industrycat10_old = 1 if inrange(s5c10, 3, 4)
replace industrycat10_old = . if lstatus_old != 1
label var industrycat10_old "Industry category - 13th ICLS definition"

* OCCUP: Skilled agricultural workers (category 6, ISCO 6000-6999)
gen occup_old = occup
replace occup_old = 6 if inrange(s5c10, 3, 4)
replace occup_old = . if lstatus_old != 1
label var occup_old "Occupation - 13th ICLS definition"

```

When we apply different definitions to the employment, industry and occupation variables, we find that the difference amounts to 3,357 workers — those engaged in own-use agricultural production who are employed under the 13th ICLS but excluded under the 19th. This raises the total employed from 99,768 to 103,125, and the employment-to-population ratio from 43.23% to 44.68%. The difference is concentrated entirely in agriculture: the industry share rises from 35.75% to 37.84%, and the skilled agricultural occupation share from 30.37% to 32.64%. On employment status, self-employment proportions change from 35.37% to 37.48%, reflecting the assumption that subsistence producers are own-account workers. Non-agricultural categories remain with the same proportions.


| Concept (all 15+) | Value 2020 ICLS-13 | Value 2024 ICLS-13 | Value 2024 ICLS-19 |
|---|---|---|---|
| Employment share | 49.35% | 42.65% | 43.23% |
| Unemployment share | 2.92% | 4.30% | 3.16% |
| Share of wage employed | 42.19% | 41.29% | 42.68% |
| Share of employed in Ag (industry) | 37.15% | 37.84% | 35.75% |
| Share of employed as farmers (occupation) | 33.82% | 32.64% | 30.37% |


Note on cross-year comparability: The values presented in this table should not be interpreted as trends or used for direct cross-year comparison. Differences across columns reflect a combination of factors including:

(1) The 2020 round was implemented under ICLS-13 definitions, while the 2024 round includes estimates under both ICLS-13 and ICLS-19. The shift in the definitions framework affects the classification of labor force status and should be taken into account when comparing values across years.

(2)  Between 2020 and 2024, the questionnaire introduced a single new category — "independent worker without employee" — to subsume the various types of own-account workers previously captured separately for agricultural and non-agricultural activities. This change in how employment status is elicited is likely to have affected the way workers are classified, and is reflected in the data in a notable increase in the share of workers categorized as self-employed. Comparisons of employment status shares across years should be interpreted with this in mind.

(3) The Pakistan LFS is generally representative at the province and urban/rural levels. The 2020 round was an exception, having been designed to be representative to the district level, resulting in a broader and more granular sample. Differences in geographic coverage and sample composition across rounds may affect the resulting estimates independently of any actual changes in labor market outcomes.


