# Introduction

At the 19th ICLS in 2013, a significant development emerged with the adoption of the [Resolution concerning statistics of work, employment, and labour underutilization](https://www.ilo.org/resource/resolution-concerning-statistics-work-employment-and-labour). This led to a change in the concept of employment compared to ICLS-13.

In essence, the ICLS-19 resolution defines **employment** only as work conducted for pay or profit. Activities not performed in exchange for remuneration, such as own-use production work, volunteer work, and unpaid trainee work, are classified as **other forms of work**.

Therefore, in order to compare GEIH rounds from 2022 onwards with earlier GEIH rounds, it is necessary to adjust the coding of the employment status variable `lstatus` using the information available in the questionnaire. In particular, this note explains how to approximate an ICLS-13-compatible employment definition by identifying individuals who are not classified as employed under the current GEIH definition but report own-use production of goods.

## Framework for identifying employment

The GEIH questionnaire identifies current employment through the labour force and employed persons sections. For the backward recoding proposed in this note, we use the additional information collected in section **K. Other forms of work**, which records unpaid activities related to own-use production of goods.

This section includes activities such as producing food products, making clothing, fetching water, building or improving the household dwelling, working in crops or gardens for household consumption, raising animals, fishing or hunting, extracting minerals, and collecting firewood. These activities are used to identify individuals who are not classified as employed under the current GEIH definition but could be considered employed under an ICLS-13-compatible definition.

Volunteer work activities reported in the same section are not included in this recoding. For further information, users can review the GEIH questionnaire [GEIH 2024 questionnaire](utilities/FORMULARIO_GEIH_2024).

## Backward coding to the ICLS-13 definition

To approximate the older ICLS-13 employment definition, the approach adopted here is to create a variable that identifies individuals who are not classified as employed under the current GEIH/ICLS-19 definition, but who report engaging in own-use production of goods in section **K. Other forms of work**.

The code below should be pasted after the code creating the `lstatus` variable. The resulting variable `emp_diff` identifies the difference between the current ICLS-19-compatible definition and the approximate ICLS-13-compatible definition.

```     
*Create an indicator "emp_diff" that identifies the difference between definitions (emp_diff)

*Own-use production of goods from section K
capture drop own_use_goods
gen byte own_use_goods = 0

foreach v in p3089 p3091 p3092 p3093 p3094 p3095 p3096 p3097 {
    replace own_use_goods = 1 if `v' == 1
}

*Individuals not employed under ICLS-19, but potentially employed under ICLS-13
capture drop emp_diff
gen byte emp_diff = 0 if inrange(lstatus, 2, 3)

*Add those engaged in own-use production of goods
replace emp_diff = 1 if emp_diff == 0 & own_use_goods == 1

*Use emp_diff to generate approximate ICLS-13 definition
replace lstatus = 1 if emp_diff == 1

replace lstatus = . if age < minlaborage
```

We can go further an try to overwrite the employment status, occupation sector, industry and occupation of those that we assume would have - under the new definition - been recorded with their own consumption definition under the new employment definition.

```     
*------------------------------------------------------------
* Further recoding for individuals added under the approximate
* ICLS-13 definition.
*
* Section K includes different own-use production activities.
*------------------------------------------------------------

* Own-use goods producers are treated as self-employed
replace empstat = 4 if emp_diff == 1

*------------------------------------------------------------
* Broad industry: ISIC Rev. 4
* industrycat_isic is string.
*
* We use broad recoverable categories:
* 0100 = Agriculture, forestry and fishing, broad division 01 proxy
* 1000 = Manufacture of food products
* 1400 = Manufacture of wearing apparel
* 3600 = Water collection, treatment and supply
* 4100 = Construction of buildings
*------------------------------------------------------------

replace industrycat_isic = "1000" if emp_diff == 1 & p3089 == 1 & missing(industrycat_isic)  // Food products
replace industrycat_isic = "1400" if emp_diff == 1 & p3091 == 1 & missing(industrycat_isic)  // Wearing apparel
replace industrycat_isic = "3600" if emp_diff == 1 & p3092 == 1 & missing(industrycat_isic)  // Water collection/supply
replace industrycat_isic = "4100" if emp_diff == 1 & p3093 == 1 & missing(industrycat_isic)  // Construction
replace industrycat_isic = "0100" if emp_diff == 1 & p3094 == 1 & missing(industrycat_isic)  // Crops/garden
replace industrycat_isic = "0100" if emp_diff == 1 & p3095 == 1 & missing(industrycat_isic)  // Animals/hunting/fishing, broad agriculture proxy
replace industrycat_isic = "0200" if emp_diff == 1 & p3097 == 1 & missing(industrycat_isic)  // Forestry/firewood

* p3096 mixes different minerals, so detailed ISIC is not assigned.

*------------------------------------------------------------
* Aggregate industry: industrycat10
*------------------------------------------------------------

replace industrycat10 = 3 if emp_diff == 1 & p3089 == 1 & missing(industrycat10)  // Manufacturing
replace industrycat10 = 3 if emp_diff == 1 & p3091 == 1 & missing(industrycat10)  // Manufacturing
replace industrycat10 = 4 if emp_diff == 1 & p3092 == 1 & missing(industrycat10)  // Utilities
replace industrycat10 = 5 if emp_diff == 1 & p3093 == 1 & missing(industrycat10)  // Construction
replace industrycat10 = 1 if emp_diff == 1 & p3094 == 1 & missing(industrycat10)  // Agriculture
replace industrycat10 = 1 if emp_diff == 1 & p3095 == 1 & missing(industrycat10)  // Agriculture/forestry/fishing
replace industrycat10 = 2 if emp_diff == 1 & p3096 == 1 & missing(industrycat10)  // Mining
replace industrycat10 = 1 if emp_diff == 1 & p3097 == 1 & missing(industrycat10)  // Forestry

*------------------------------------------------------------
* Broad occupation: ISCO-08
* occup_isco is string.
*
* We use major groups:
* 6000 = Skilled agricultural, forestry and fishery workers
* 7000 = Craft and related trades workers
* 9000 = Elementary occupations
*------------------------------------------------------------

replace occup_isco = "7000" if emp_diff == 1 & p3089 == 1 & missing(occup_isco)  // Food processing
replace occup_isco = "7000" if emp_diff == 1 & p3091 == 1 & missing(occup_isco)  // Garment/clothing
replace occup_isco = "9000" if emp_diff == 1 & p3092 == 1 & missing(occup_isco)  // Water collection
replace occup_isco = "7000" if emp_diff == 1 & p3093 == 1 & missing(occup_isco)  // Construction
replace occup_isco = "6000" if emp_diff == 1 & p3094 == 1 & missing(occup_isco)  // Crops/garden
replace occup_isco = "6000" if emp_diff == 1 & p3095 == 1 & missing(occup_isco)  // Animals/hunting/fishing
replace occup_isco = "9000" if emp_diff == 1 & p3096 == 1 & missing(occup_isco)  // Mineral extraction
replace occup_isco = "9000" if emp_diff == 1 & p3097 == 1 & missing(occup_isco)  // Firewood collection

*------------------------------------------------------------
* Aggregate occupation: occup
*------------------------------------------------------------

replace occup = 7 if emp_diff == 1 & p3089 == 1 & missing(occup)  // Craft and related trades
replace occup = 7 if emp_diff == 1 & p3091 == 1 & missing(occup)  // Craft and related trades
replace occup = 9 if emp_diff == 1 & p3092 == 1 & missing(occup)  // Elementary occupations
replace occup = 7 if emp_diff == 1 & p3093 == 1 & missing(occup)  // Craft and related trades
replace occup = 6 if emp_diff == 1 & p3094 == 1 & missing(occup)  // Skilled agricultural workers
replace occup = 6 if emp_diff == 1 & p3095 == 1 & missing(occup)  // Skilled agricultural/fishery workers
replace occup = 9 if emp_diff == 1 & p3096 == 1 & missing(occup)  // Elementary occupations
replace occup = 9 if emp_diff == 1 & p3097 == 1 & missing(occup)  // Elementary occupations
```
Weekly hours can be partially recovered from section K. The questionnaire reports days and hours per day for own-use production activities during the last four weeks. Therefore, `whours` is approximated by summing days times hours per day across section K own-use production activities and dividing the total by four. This is not strictly equivalent to reference-week hours, so users should interpret it with caution.

```
*------------------------------------------------------------
* Approximate weekly hours
*
* Section K reports days and hours per day during the last
* four weeks. We approximate weekly hours by dividing by four.
*------------------------------------------------------------

capture drop whours_ownuse
gen double whours_ownuse = 0 if emp_diff == 1

foreach v in p3089 p3091 p3092 p3093 p3094 p3095 p3096 p3097 {
    replace whours_ownuse = whours_ownuse + (`v's1 * `v's2) ///
        if emp_diff == 1 & `v' == 1 & !missing(`v's1, `v's2)
}

replace whours_ownuse = whours_ownuse / 4 if emp_diff == 1
replace whours = whours_ownuse if emp_diff == 1
```

Finally, the remaining job-related variables cannot be reliably recovered from section K. These variables are therefore set to missing, while firm size is set to 1 because own-use producers are treated as self-employed.

```stata
*------------------------------------------------------------
* Remaining labour variables
*------------------------------------------------------------

replace wage_no_compen = . if emp_diff == 1
replace contract       = . if emp_diff == 1
replace socialsec      = . if emp_diff == 1
replace union          = . if emp_diff == 1
replace nlfreason      = . if emp_diff == 1

replace firmsize_l = 1 if emp_diff == 1
replace firmsize_u = 1 if emp_diff == 1
```