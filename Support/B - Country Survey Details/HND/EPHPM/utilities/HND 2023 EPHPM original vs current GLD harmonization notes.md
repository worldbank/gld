# HND 2023 EPHPM original vs current GLD harmonization notes

Date reviewed: 2026-05-14

## Scope

This note compares the current HND 2023 EPHPM GLD working do-file with the original GitHub do-file. It follows the GLD comparison-note style: each section starts with the issue, explains the raw variable meaning where needed, states the current GLD treatment, then contrasts the original approach and explains the practical consequence.

Comparator do-files:

- Current GLD working version: `Downloads/HND/HND_2023_EPHPM/HND_2023_EPHPM_V01_M_V01_A_GLD/Programs/HND_2023_EPHPM_V01_M_V01_A_GLD_ALL.do`
- Original GitHub version: `Documents/GitHub/gld/GLD/HND/HND_2023_EPHPM/HND_2023_EPHPM_V01_M_V01_A_GLD/Programs/HND_2023_EPHPM_V01_M_V01_A_GLD_ALL.do`

## `educat7`

The issue in `educat7` is that the original code sometimes let a constructed years-of-schooling value override the meaning of the raw education category. In the questionnaire, `ED05` records the highest education level already attained, while `ED10` and `ED13` record the level and grade currently attended by current students. The current GLD code uses those raw level and grade variables directly and leaves `educy` missing. The original code first constructed `educy`, then used `educy` thresholds to assign `educat7`.

### Discrepancy summary

Using the current module-age rule (`ed_mod_age = 3`) for both approaches, 416 people are coded differently in `educat7`.

| Raw situation, in plain English | Current GLD treatment | Original treatment | Why it matters | People |
|---|---|---|---|---:|
| Currently attending basic education, grade 7. Since grade 7 is the current grade, the person has completed grade 6. | Primary complete | Secondary incomplete | The current code treats current grade 7 students as having completed primary, not as already having incomplete secondary attainment. | 342 |
| Highest education is technical higher education, with reported years or grades in that track. | Higher non-university | Secondary incomplete or secondary complete | The current code respects technical higher education as a post-secondary technical track. | 54 |
| Currently attending technical higher education. | Higher non-university | Secondary incomplete | The current code uses the level being attended rather than converting the person through a secondary-years threshold. | 17 |
| Highest education is basic education, but the reported grade or year is unknown or no response. | Missing | Secondary incomplete | The current code avoids assigning secondary incomplete when the basic-education grade is unknown. | 3 |

### GLD code

```stata
gen byte educy = .

replace `nivel' = 1 if ED05 == 4 & ED08 <= 5
replace `nivel' = 2 if ED05 == 4 & ED08 == 6
replace `nivel' = 3 if ED05 == 4 & inrange(ED08, 7, 9)
replace `nivel' = 3 if ED05 == 5 & ED08 <= 2
replace `nivel' = 4 if ED05 == 5 & ED08 >= 3 & ED08 != 99
replace `nivel' = 5 if ED05 == 6
replace `nivel' = 5 if ED05 == 7
replace `nivel' = 6 if inlist(ED05, 8, 9, 10, 11)

replace `nivel' = 1 if `current_student' == 1 & ED10 == 4 & inrange(ED13, 1, 6)
replace `nivel' = 2 if `current_student' == 1 & ED10 == 4 & ED13 == 7
replace `nivel' = 3 if `current_student' == 1 & ED10 == 4 & inrange(ED13, 8, 9)
replace `nivel' = 3 if `current_student' == 1 & ED10 == 5
replace `nivel' = 5 if `current_student' == 1 & inlist(ED10, 6, 7)
replace `nivel' = 6 if `current_student' == 1 & inlist(ED10, 8, 9, 10)
```

### Comparator code

```stata
replace educy = ED08 if ED05 == 4
replace educy = 9 + ED08 if inlist(ED05, 5, 6) & !missing(ED08)
replace educy = max(ED13 - 1, 0) if `current_student' == 1 & ED10 == 4 & !missing(ED13)
replace educy = 8 + ED13 if `current_student' == 1 & inlist(ED10, 5, 6) & !missing(ED13)

replace `nivel' = 3 if ED05 == 4 & educy >= 7
replace `nivel' = 3 if inlist(ED05, 5, 6) & educy <= 11
replace `nivel' = 4 if inlist(ED05, 5, 6) & educy >= 12
replace `nivel' = 3 if `current_student' == 1 & ED10 == 4 & !missing(educy) & educy >= 6
replace `nivel' = 3 if `current_student' == 1 & inlist(ED10, 5, 6)
```

The current GLD treatment is preferred because it keeps the harmonized category anchored in the education level reported by the survey. This is especially important for technical higher education, which should not be pushed into secondary categories by a years-of-schooling approximation.

## `ed_mod_age`, `educy`, `educat5`, and `educat4`

The issue in the education support variables is that the original code did not set an education module age and separately rebuilt `educat5` and `educat4` from the old `educy`-based ladder. The current GLD code sets `ed_mod_age = 3`, leaves `educy` missing, and derives `educat5` and `educat4` from `educat7`.

### Discrepancy summary

| Variable | Current GLD treatment | Original treatment | Why it matters |
|---|---|---|---|
| `ed_mod_age` | Set to 3 | Left missing | The current code documents the observed minimum age for education attendance or attainment responses. |
| `educy` | Left missing | Constructed from raw education level and grade variables | The current code avoids reporting years of schooling when the user asked to leave `educy` missing. |
| `educat5` | Derived from `educat7` | Rebuilt separately from the old `nivel` ladder | This keeps coarser education variables consistent with `educat7`. |
| `educat4` | Derived from `educat7` | Rebuilt separately from the old `nivel` ladder | This keeps coarser education variables consistent with `educat7`. |

### GLD code

```stata
gen byte ed_mod_age = 3
gen byte educy = .

gen byte educat5 = educat7
recode educat5 (4=3) (5=4) (6/7=5)

gen byte educat4 = educat7
recode educat4 (2 3 4 = 2) (5=3) (6 7=4)
```

### Comparator code

```stata
gen byte ed_mod_age = .

gen byte educy = .
replace educy = 0 if inlist(ED05, 1, 2, 3)
replace educy = ED08 if ED05 == 4
replace educy = 9 + ED08 if inlist(ED05, 5, 6) & !missing(ED08)

gen byte educat5 = .
gen byte educat4 = .
```

The practical consequence is that the current file has internally consistent education categories, while years of schooling remains intentionally uncoded.

## `pid`, `vermast`, and `veralt`

The issue in the identifier and version variables is format consistency. The current GLD code builds `pid` from the household identifier and the two-digit person number without an underscore. It also stores `vermast` and `veralt` as `V01`, matching the folder and file naming convention. The original code used an underscore in `pid` and stored version values as `01`.

### Discrepancy summary

| Variable | Current GLD treatment | Original treatment | Why it matters |
|---|---|---|---|
| `pid` | `hhid + string(NPER, "%02.0f")` | `hhid + "_" + string(NPER, "%02.0f")` | The current ID remains unique and follows the requested no-underscore format. |
| `vermast` | `V01` | `01` | The current value matches GLD version notation. |
| `veralt` | `V01` | `01` | The current value matches GLD version notation. |

### GLD code

```stata
gen str20 pid = hhid + string(NPER, "%02.0f")
gen str3 vermast = "V01"
gen str3 veralt = "V01"
```

### Comparator code

```stata
gen str20 pid = hhid + "_" + string(NPER, "%02.0f")
gen vermast = "01"
gen veralt = "01"
```

The change affects string format, not the underlying person-identification logic.

## `migrated_from_code`

The issue in `migrated_from_code` is that the original code stored raw numeric geography codes that were hard to compare with the harmonized subnational identifiers. The current GLD code keeps the same `migrated_from_cat` categories but writes `migrated_from_code` in the same readable style as `subnatid` variables, such as `801 - Distrito Central`, `5 - Cortes`, or `2 - Norte`.

### Discrepancy summary

| Migration category | Current GLD treatment | Original treatment | People |
|---|---|---|---:|
| Same municipality | Municipality code and name when available | Raw municipality code only | 421 |
| Same department | Department code and name | Raw department code only | 964 |
| Same region | Region code and name | Region code and name | 608 |
| Other department | Department code and name | Raw department code only | 2,005 |
| Other country or unknown | Blank `migrated_from_code`; country stored separately when known | Same treatment | 72 |

### GLD code

```stata
replace migrated_from_code = subnatid3 if migrated_from_cat == 1
replace migrated_from_code = subnatid2 if migrated_from_cat == 2
replace migrated_from_code = __prev_admin1 if migrated_from_cat == 3
replace migrated_from_code = "5 - Cortes" if migrated_from_cat == 4 & CD04_DEPT == 5
```

### Comparator code

```stata
replace migrated_from_code = string(CD04_MUNI, "%03.0f") if migrated_from_cat == 1
replace migrated_from_code = string(CD04_DEPT, "%02.0f") if migrated_from_cat == 2
replace migrated_from_code = __prev_admin1 if migrated_from_cat == 3
replace migrated_from_code = string(CD04_DEPT, "%02.0f") if migrated_from_cat == 4
```

This is a readability and comparability change. It does not change whether a person is coded as a migrant or which migration-origin category they are assigned to.

## `minlaborage`, `potential_lf`, `underemployment`, `nlfreason`, `unempldur_l`, `unempldur_u`, and `ocusec`

The issue in the labor block is that the original code left several GLD labor-status extension variables blank and set the minimum labor age to 5. The current GLD code sets `minlaborage = 15` and fills selected labor variables from the questionnaire flow where the raw questions support them.

### Discrepancy summary

| Variable | Current GLD treatment | Original treatment | Nonmissing people in current output |
|---|---|---|---:|
| `minlaborage` | 15 | 5 | 20,308 |
| `potential_lf` | Coded for people outside the labor force using availability and job-search-related questions | Missing | 6,347 |
| `underemployment` | Coded for employed people using desire and availability for more hours | Missing | 7,498 |
| `nlfreason` | Coded for people outside the labor force using the stated reason for not searching or not working | Missing | 6,367 |
| `unempldur_l` and `unempldur_u` | Coded from exact reported duration without work; lower and upper bounds are equal | Missing | 531 |
| `ocusec` | Coded from `OC609`, separating public-sector workers from other workers | Missing | 7,498 |

### GLD code

```stata
gen byte minlaborage = 15

replace potential_lf = 0 if lstatus == 3 & inlist(CA512, 1, 2) & inlist(CA511, 1, 2, 3, 4)
replace potential_lf = 1 if lstatus == 3 & CA512 == 1 & inlist(CA511, 2, 3, 4)

replace underemployment = 0 if lstatus == 1 & !missing(CA522)
replace underemployment = 1 if lstatus == 1 & CA522 == 1 & CA523 == 1

replace nlfreason = 1 if lstatus == 3 & CA514 == 4
replace nlfreason = 2 if lstatus == 3 & CA514 == 5
replace nlfreason = 3 if lstatus == 3 & inlist(CA514, 1, 2, 3)

replace unempldur_l = `unempldur_months' if lstatus == 2
replace unempldur_u = `unempldur_months' if lstatus == 2

replace ocusec = 1 if lstatus == 1 & inlist(OC609, 1, 4, 9)
replace ocusec = 2 if lstatus == 1 & inlist(OC609, 2, 3, 5, 6, 7, 8, 10, 11)
```

### Comparator code

```stata
gen byte minlaborage = 5
gen byte potential_lf = .
gen byte underemployment = .
gen byte nlfreason = .
gen byte unempldur_l = .
gen byte unempldur_u = .
gen byte ocusec = .
```

The current treatment captures useful labor-market information that was present in the questionnaire but not incorporated in the original harmonization.

## `industrycat10` and `occup`

The issue in industry and occupation is internal consistency with detailed classification codes. The current GLD code derives `industrycat10` from the first two digits of `industrycat_isic`, so the broad industry group follows the detailed ISIC code. For occupation, the current code treats raw first-two-digit values `98` and `99` as missing because they are not valid broad occupation groups.

### Discrepancy summary

| Variable | Current GLD treatment | Original treatment | Why it matters |
|---|---|---|---|
| `industrycat10` | Derived from the first two digits of `industrycat_isic` | Derived from a separate sector-map category, with a household-service override | The current code keeps broad industry downstream from detailed ISIC coding. |
| `occup` | Leaves first-two-digit `98` and `99` missing | Mapped first-two-digit `98` to `occup = 99` | The current code avoids assigning invalid broad occupation codes. |

### GLD code

```stata
gen byte `isic2' = real(substr(industrycat_isic, 1, 2)) if industrycat_isic != ""
replace industrycat10 = 1 if inrange(`isic2', 1, 3)
replace industrycat10 = 2 if inrange(`isic2', 5, 9)
replace industrycat10 = 3 if inrange(`isic2', 10, 33)
replace industrycat10 = 9 if `isic2' == 84
replace industrycat10 = 10 if inrange(`isic2', 85, 99)

replace occup = . if inlist(`occup_first_two', "98", "99")
```

### Comparator code

```stata
gen byte industrycat10 = sector_map10
replace industrycat10 = 10 if inlist(__sector_code, "97000", "98000") & CATEGOP == 3 & OC609 == 3

replace occup = 99 if `occup_first_two' == "98"
```

The current treatment is more conservative for occupation and more internally coherent for industry.

## `wage_no_compen`, `unitwage`, `whours`, and wage-total variables

The issue in the wage block is that the original code populated broader wage-total and annualized labor-income variables from income aggregates that may mix concepts beyond wage payments. The current GLD code keeps `wage_no_compen` and `wage_no_compen_2`, codes `unitwage` only when a wage value is observed, sets zero weekly hours to missing, and leaves broader wage-total concepts missing.

### Discrepancy summary

| Variable or group | Current GLD treatment | Original treatment | Current output consequence |
|---|---|---|---|
| `wage_no_compen`, `wage_no_compen_2` | Kept | Kept | Primary wage observed for 6,965 people; secondary wage observed for 424 people. |
| `unitwage`, `unitwage_2` | Coded only when the corresponding wage value is observed | Coded from employment status or secondary-job signal | Unit values now match observed wage values exactly. |
| `whours`, `whours_2` | Zero weekly hours set to missing | Zero weekly hours retained | Current output has no zero values in weekly hours. |
| `wage_total`, `wage_total_2`, `t_wage_nocompen_total`, `t_wage_total`, `linc_nc`, `laborincome` | Left missing | Populated from wage and broader income aggregates | The current output avoids unsupported total wage and annual labor-income concepts. |

### GLD code

```stata
replace unitwage = 5 if !missing(wage_no_compen)
replace unitwage_2 = 5 if !missing(wage_no_compen_2)

replace whours = . if whours == 0
replace whours_2 = . if whours_2 == 0

gen double wage_total = .
gen double wage_total_2 = .
gen double linc_nc = .
gen double laborincome = .
```

### Comparator code

```stata
replace unitwage = 5 if !missing(empstat)
replace unitwage_2 = 5 if CA519 >= 2 & `secondary_hours_seen' > 0

gen double wage_total = YTRAOP
replace wage_total = wage_no_compen if missing(wage_total)

gen double wage_total_2 = YTRAOS
replace wage_total_2 = wage_no_compen_2 if missing(wage_total_2)

gen linc_nc = 12 * t_wage_nocompen_total
gen laborincome = 12 * t_wage_total
```

The current treatment is narrower but cleaner: it keeps directly supported wage values and avoids presenting broader income aggregates as if they were harmonized wage totals.

## `socialsec`, `contract`, `healthins`, and `union`

The issue in job-formality variables is that the questionnaire items do not cleanly support all GLD concepts. The current GLD code leaves `socialsec`, `contract`, `healthins`, and `union` missing. The original code attempted to code `socialsec` from `OC613`, but that raw item does not cleanly identify social security coverage in the GLD sense.

### Discrepancy summary

| Variable | Current GLD treatment | Original treatment | Why it matters |
|---|---|---|---|
| `socialsec` | Missing | Coded from `OC613` | The current code avoids using a source item that may mix concepts. |
| `contract` | Missing | Missing | No direct supported coding was identified. |
| `healthins` | Missing | Missing | Health insurance is not coded because the available source information may combine social security and health-insurance concepts. |
| `union` | Missing | Missing | No direct supported coding was identified. |

### GLD code

```stata
gen byte contract = .
gen byte healthins = .
gen byte socialsec = .
gen byte union = .
```

### Comparator code

```stata
gen byte socialsec = .
replace socialsec = 0 if lstatus == 1 & OC613 == 1
replace socialsec = 1 if lstatus == 1 & OC613 == 2
replace socialsec = . if lstatus != 1 | OC613 == 9
```

The current treatment is conservative. It avoids turning an ambiguous source variable into a GLD formality measure.

## Employment-specific cleanup

The issue in employment-specific variables is that job details should not remain populated for people who are unemployed or outside the labor force. The current GLD code forces employment-specific variables to missing when `lstatus != 1`. The original code did not include this final cleanup step.

### GLD code

```stata
local employed_vars "empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u ..."

foreach emp_var of local employed_vars {
    capture confirm variable `emp_var'
    if !_rc {
        capture confirm numeric variable `emp_var'
        if _rc == 0 {
            replace `emp_var' = . if lstatus != 1
        }
        else {
            replace `emp_var' = "" if lstatus != 1
        }
    }
}
```

### Comparator code

The original do-file did not have an equivalent final employment-specific cleanup block.

This matters because the final harmonized file should not imply that unemployed people or people outside the labor force have current-job characteristics.

## Output cleanup consequence

The current do-file drops variables that are entirely missing before saving. This means some intentionally uncoded variables may not appear in the final harmonized `.dta`. That is expected. The harmonization decision should still remain visible in the do-file and review notes.
