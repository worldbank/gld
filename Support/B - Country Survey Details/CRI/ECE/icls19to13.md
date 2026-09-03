# Converting ECE employment indicators from ICLS-19 to ICLS-13

## Overview

The Costa Rica Continuous Employment Survey (ECE) identifies employment as work performed for pay or profit. Activities carried out entirely for own consumption are recorded separately and are not included in the standard GLD employment indicator. This treatment is more closely aligned with the ICLS-19 employment concept.

Under the broader ICLS-13 concept, certain own-use production activities were included within employment. This note describes how users can produce an alternative ICLS-13-compatible version of the relevant GLD variables using information available in the ECE questionnaire. The standard harmonized files remain coded as `ICLS-19`.

## Identifying own-use production work

The ECE records three types of own-use production activity during the previous week:

- `I1A`: agricultural production, livestock care and related production exclusively for own consumption;
- `I5`: construction or major repairs to the household's own dwelling; and
- `I6`: textiles or sewing produced exclusively for household use.

Each activity has a corresponding measure of hours worked during the previous week: `I1B`, `I5A` and `I6A`, respectively.

Coverage differs across survey years. `I1A` and `I1B` provide the applicable information throughout 2010 - 2025. Although `I5`, `I5A`, `I6` and `I6A` exist in the earlier files, they are not populated in 2010 - 2013. Consequently, the conversion for 2010 - 2013 captures only the agricultural component of own-use production work, whereas all three components can be identified from 2014 onward.

## Applying the conversion in GLD variable order

The corrections below follow the order of the labor variables in the ECE harmonization `.do` file. Each code block should be inserted immediately after the corresponding GLD variable block. Temporary variables created after `lstatus` are retained until the last correction.

### `lstatus`

After creating `lstatus`, identify persons added to employment under the alternative definition. This first block also records the hours spent on each activity and identifies the principal own-use activity. When multiple activities are reported, the one with the greatest number of hours is selected. Ties are resolved in the following order: agriculture, construction and manufacturing.

```stata
* Identify persons outside employment who performed own-use production work
gen byte emp_diff = inrange(lstatus, 2, 3) & ///
    (I1A == 1 | I5 == 1 | I6 == 1)

* Convert labor-force status and document the alternative standard
replace lstatus = 1 if emp_diff == 1
replace icls_v = "ICLS-13"
replace lstatus = . if age < minlaborage & !missing(age)

* Retain hours only for reported own-use activities
gen double __h_agriculture   = I1B if I1A == 1
gen double __h_construction  = I5A if I5  == 1
gen double __h_manufacturing = I6A if I6  == 1

* Identify the principal activity by hours
egen double __ownuse_max = rowmax( ///
    __h_agriculture __h_construction __h_manufacturing)
gen byte __ownuse_main = 1 if emp_diff == 1 & ///
    __h_agriculture == __ownuse_max
replace __ownuse_main = 2 if emp_diff == 1 & missing(__ownuse_main) & ///
    __h_construction == __ownuse_max
replace __ownuse_main = 3 if emp_diff == 1 & missing(__ownuse_main) & ///
    __h_manufacturing == __ownuse_max
```

For 2010 - 2013, `I5` and `I6` are entirely missing, so the expression runs but only `I1A == 1` can identify additional workers.

### `nlfreason`

This variable does not apply after the person has been reclassified as employed.

```stata
replace nlfreason = . if emp_diff == 1
```
### `empstat`

The regular employment-position questions are not administered to these own-use producers. The conversion therefore treats them as self-employed. This is a documented assumption rather than a directly observed characteristic.

```stata
replace empstat = 4 if emp_diff == 1 & missing(empstat)
```

### `industrycat10`

Broad industry is assigned from the principal own-use activity.

| Principal activity | `industrycat10` |
|---|---:|
| Agriculture (`I1A`) | 1 Agriculture |
| Construction or major repairs (`I5`) | 5 Construction |
| Textiles or sewing (`I6`) | 3 Manufacturing |

```stata
replace industrycat10 = 1 if emp_diff == 1 & __ownuse_main == 1
replace industrycat10 = 5 if emp_diff == 1 & __ownuse_main == 2
replace industrycat10 = 3 if emp_diff == 1 & __ownuse_main == 3
```

### `occup`

Agricultural own-use production is assigned to skilled agricultural occupations. Construction, repairs, textiles and sewing are assigned to craft workers.

```stata
replace occup = 6 if emp_diff == 1 & __ownuse_main == 1
replace occup = 7 if emp_diff == 1 & inlist(__ownuse_main, 2, 3)
```


### `wage_no_compen` and `unitwage`

Market-job earnings are unavailable and should remain missing.

```stata
replace wage_no_compen = . if emp_diff == 1
replace unitwage       = . if emp_diff == 1
```

### `whours`

Unlike the other detailed job characteristics, hours can be calculated directly from the questionnaire. `whours` is the sum of hours across all reported own-use activities, not only the principal activity.

```stata
egen double __ownuse_hours = rowtotal( ///
    __h_agriculture __h_construction __h_manufacturing)
replace whours = __ownuse_hours if emp_diff == 1
```

### `wmonths` and `wage_total`

Months worked and total market-job earnings cannot be recovered for the own-use activities.

```stata
replace wmonths    = . if emp_diff == 1
replace wage_total = . if emp_diff == 1
```

### `contract`, `healthins`, `socialsec`, `union`, `firmsize_l` and `firmsize_u`

These regular main-job characteristics are unavailable or not applicable to the converted workers.

```stata
replace contract   = . if emp_diff == 1
replace healthins  = . if emp_diff == 1
replace socialsec  = . if emp_diff == 1
replace union      = . if emp_diff == 1
replace firmsize_l = . if emp_diff == 1
replace firmsize_u = . if emp_diff == 1
```

After the last correction, remove the temporary variables but retain `emp_diff` if users need to identify the observations affected by the conversion.

```stata
drop __h_agriculture __h_construction __h_manufacturing ///
    __ownuse_hours __ownuse_max __ownuse_main
```

This conversion produces an analytical approximation of the ICLS-13 employment concept. The assumptions used for `empstat`, `industrycat10`, `industrycat4`, `occup` and `occup_skill` should be considered when interpreting results. The reported own-use hours, by contrast, come directly from the questionnaire.

