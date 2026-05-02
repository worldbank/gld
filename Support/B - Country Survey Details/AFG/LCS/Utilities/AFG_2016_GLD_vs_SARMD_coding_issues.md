# GLD vs SARMD Coding Review

This note summarizes the main coding differences found when comparing the GLD harmonization to the SARMD labor work-file logic. It only covers variables where the two approaches may change who is included, excluded, or left uncoded in the final output.

Files reviewed:
- GLD: `AFG_2016_LCS_V01_M_V01_A_GLD_ALL.do`
- SARMD: `AFG_2016_LCS_v01_M_v03_A_SARMD_LBR.do).do`

## Labor status

Labor status is being built in two very different ways. The GLD reconstructs it from the questionnaire, while SARMD simply recodes the prebuilt `activity_status` variable. That matters because the GLD rule is transparent: it shows exactly who is treated as employed, unemployed, or outside the labor force based on the survey questions. SARMD may still be reasonable, but it depends entirely on how `activity_status` was produced upstream.

### Raw coding details

| Variable | Raw code | Raw meaning | GLD treatment | SARMD treatment |
|---|---:|---|---|---|
| `q12_2` to `q12_7` | `1` | worked in one of the detailed work activities | employed | depends on `activity_status` |
| `q12_8` | `1` | temporarily absent from work | employed | depends on `activity_status` |
| `q12_10` | `1` | available for work | required for unemployment | absorbed upstream in `activity_status` |
| `q12_11` | `1` | searched for work | unemployed if also available | absorbed upstream in `activity_status` |
| `q12_12` | `8` | already found work | unemployed if also available | absorbed upstream in `activity_status` |
| `activity_status` | `2` | employed summary | not used directly | employed |
| `activity_status` | `3` | unemployed summary | not used directly | unemployed |
| `activity_status` | `4` | non-LF summary | not used directly | non-LF |

### Code snippets

GLD:

```stata
replace lstatus = 1 if q12_2 == 1 | q12_3 == 1 | q12_4 == 1 | q12_5 == 1 | q12_6 == 1 | q12_7 == 1
replace lstatus = 1 if q12_8 == 1
replace lstatus = 2 if q12_11 == 1 & q12_10 == 1 & missing(lstatus)
replace lstatus = 2 if q12_12 == 8 & q12_10 == 1 & missing(lstatus)
replace lstatus = 3 if missing(lstatus)
```

SARMD:

```stata
recode activity_status (2=1) (3=2) (4=3), gen(lstatus)
```

## Reason out of labor force

The two versions are mostly similar, except for how they treat apprentices. In the questionnaire, `q12_12==6` is “apprentice.” The GLD treats that as `other`, while SARMD treats it as `student`. The GLD keeps it in `other` because student usually means someone who is doing schooling, while an apprentice may be in training but that is not automatically the same thing as formal schooling.

### Raw coding details

| Variable | Raw code | Raw meaning | GLD treatment | SARMD treatment |
|---|---:|---|---|---|
| `q12_12` | `1` | housework | housekeeper | housekeeper |
| `q12_12` | `2` | student | student | student |
| `q12_12` | `3` | retired / too old | retired | retired |
| `q12_12` | `4` | illness / injury | disabled | disabled |
| `q12_12` | `5` | handicapped | disabled | disabled |
| `q12_12` | `6` | apprentice | other | student |
| `q12_12` | `7` to `14` | other reasons, including no jobs, family restrictions, and similar cases | other | other |

### Code snippets

GLD:

```stata
replace nlfreason = 1 if q12_12 == 2
replace nlfreason = 2 if q12_12 == 1
replace nlfreason = 3 if q12_12 == 3
replace nlfreason = 4 if inlist(q12_12,4,5)
replace nlfreason = 5 if inlist(q12_12,6,7,8,9,10,11,12,13,14)
```

SARMD:

```stata
recode q12_12 (5=4) (6=1) (7/14=5), gen(nlfreason)
```

## Labor income

The GLD keeps a usable annual labor-income variable, while SARMD leaves it missing. This is one of the more important practical differences in the 2016 comparison. The GLD uses the available annual labor-income aggregate `t_wage_total_year`. SARMD drops that information.

### Code snippets

GLD:

```stata
gen laborincome = t_wage_total_year
```

SARMD:

```stata
cap gen laborincome=.
```
