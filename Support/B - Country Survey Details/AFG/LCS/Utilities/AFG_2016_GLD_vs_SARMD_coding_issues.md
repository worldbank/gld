# GLD vs SARMD Coding Review

This note summarizes the main coding differences found when comparing the GLD harmonization to the SARMD labor work-file logic. It only covers variables where the two approaches may change who is included, excluded, or left uncoded in the final output.

Files reviewed:
- GLD: `AFG_2016_LCS_V01_M_V01_A_GLD_ALL.do`
- SARMD: `AFG_2016_LCS_v01_M_v03_A_SARMD_LBR.do).do`

## Labor status

The given `activity_status` variable should not replace the questionnaire-based GLD labor-status coding in this survey. The main reason is that it does not line up cleanly with the survey flow. The GLD rebuilds labor status directly from the labor questions. SARMD collapses the given `activity_status` variable into employed, unemployed, and non-LF. Those two approaches agree on the narrow unemployment core, but they differ in some important places. Most notably, the given `activity_status` variable treats some people as unemployed even though they reported current-week work or temporary absence from work. It also treats some apprentices, temporarily laid-off people, and similar cases as employed even though they do not fall into the GLD employment branch.

The current-week work questions ask whether the person:
- worked for a business, organization, or person outside the household
- did farm work
- did non-agricultural own-account work or work in a household business
- produced durable goods for own household use

The module then adds:
- a summary check for whether any of those work activities was done
- a follow-up asking whether the person did any such activity even for only one hour
- a temporary-absence question asking whether the person had work but was absent from it in the last week

If the person is not in the work branch, the questionnaire then asks:
- whether the person was available for work
- whether the person tried to find work or start a business
- the main reason for not looking for work

So the questionnaire itself separates the work branch from the nonworking branch. That is why the GLD treats current-week work and temporary absence as employment first, then applies the unemployment rule only to people who are still outside employment.

### Bucket breakdown

This table shows how the GLD questionnaire buckets line up with the given `activity_status` variable among adults age 14 and above.

| Variable or branch | Plain meaning | GLD classification | Activity status = employed | Activity status = underemployed | Activity status = unemployed | Activity status = inactive | Activity status missing |
|---|---|---|---:|---:|---:|---:|---:|
| `q12_2==1` | worked outside the household | employed | 7,066 | 1,671 | 112 | 0 | 0 |
| `q12_3==1` | did farm work | employed | 10,073 | 3,782 | 1,977 | 0 | 0 |
| `q12_4==1` | did nonfarm own-account work | employed | 6,999 | 1,334 | 213 | 0 | 0 |
| `q12_5==1` | produced durable goods for own use | employed | 302 | 187 | 249 | 0 | 0 |
| `q12_7==1` | reported some work even for only one hour | employed | 66 | 27 | 76 | 0 | 0 |
| `q12_8==1` | temporarily absent from work | employed | 335 | 0 | 155 | 1 | 0 |
| `q12_10==1` and `q12_11==1` | available and looking for work | unemployed | 0 | 0 | 4,077 | 0 | 0 |
| `q12_10==1` and `q12_12==8` | available and already found work | unemployed | 0 | 0 | 13 | 0 | 0 |
| `q12_10==1` only | available but not looking | non-LF / potential LF | 256 | 0 | 1,723 | 2,321 | 0 |
| `q12_11==1` only | not available but looking | non-LF / potential LF | 0 | 0 | 20 | 0 | 0 |
| `q12_12==8` without availability | not available but already found work | non-LF | 0 | 0 | 83 | 0 | 0 |
| residual | everything else | non-LF | 1,971 | 3 | 2,475 | 35,280 | 1,034 |

### Suspicious treatments in the given `activity_status` variable

The clearest red flag is the group of people who are tagged as unemployed in the given `activity_status` variable even though they are already in one of the GLD employment-side buckets.

| Employment bucket | Tagged as unemployed in `activity_status` | With `q12_10` available = 1 | With `q12_11` search = 1 |
|---|---:|---:|---:|
| worked outside the household | 112 | 0 | 0 |
| did farm work | 1,977 | 0 | 0 |
| did nonfarm own-account work | 213 | 0 | 0 |
| produced durable goods for own use | 249 | 0 | 0 |
| reported some work even for only one hour | 76 | 0 | 0 |
| temporarily absent | 155 | 0 | 0 |

This table is hard to reconcile with the questionnaire flow. These people are already in the work branch, yet they are still treated as unemployed in the given `activity_status` variable, and none of them have observed availability or search responses.

- `2,218` people are tagged as employed in the given `activity_status` variable even though they do not fall into the GLD employment buckets. These are mostly:
  - `1,108` apprentices
  - `1,084` temporarily laid-off people
  - `26` people in military service
- `4,297` people are tagged as unemployed in the given `activity_status` variable even though GLD places them outside unemployment. The largest visible reasons in this group are:
  - `2,567` with `q12_12==12` no jobs available
  - `544` with `q12_12==10` waiting for busy season
  - `83` with `q12_12==8` already found work but not available under the GLD rule
- There is also `1` person who is temporarily absent from work but is tagged as inactive in the given `activity_status` variable

### GLD 2013 and 2016 comparison

The GLD labor-status totals themselves look stable across the two Afghanistan rounds, which makes the questionnaire-based GLD treatment easier to defend. It is also useful to compare those totals with the 2016 SARMD-style collapse of the given `activity_status` variable.

| Year | Source | Status | Unweighted count | Weighted population |
|---|---|---|---:|---:|
| 2013 | GLD | employed | 38,223 | 56,924,905 |
| 2013 | GLD | unemployed | 3,118 | 5,262,155 |
| 2013 | GLD | non-LF | 43,264 | 71,153,527 |
| 2016 | GLD | employed | 34,548 | 57,937,069 |
| 2016 | GLD | unemployed | 4,090 | 6,712,551 |
| 2016 | GLD | non-LF | 45,150 | 79,230,580 |
| 2016 | SARMD-style `activity_status` | employed | 34,072 | 57,841,147 |
| 2016 | SARMD-style `activity_status` | unemployed | 11,080 | 17,160,704 |
| 2016 | SARMD-style `activity_status` | non-LF | 37,602 | 67,030,492 |
| 2016 | SARMD-style `activity_status` | missing | 1,034 | 1,847,857 |

The biggest contrast is in unemployment. Under the GLD, the weighted unemployed population rises from about 5.26 million in 2013 to about 6.71 million in 2016. Under the 2016 SARMD-style `activity_status` collapse, the weighted unemployed population would instead jump to about 17.16 million. That is a much larger break across rounds, and it is hard to reconcile with the questionnaire evidence reviewed above.

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

## Sector of activity (`ocusec`)

The GLD and SARMD use the same broad `ocusec` treatment in 2016: salaried public-sector workers are public, while day labourers, private salaried workers, self-employed workers, employers, and unpaid family workers are treated as non-public. The possible concern is day labourers. In the raw industry coding, two-digit code `91` is public administration and defence, while the one-digit code `9` is the broader community, social, and personal services group. Only 40 day labourers in 2016, or 0.75 percent of all day labourers, are in two-digit industry `91`. The comparable 2013 figure is 52 cases, or 0.87 percent of day labourers. This is worth noting, but it is too small to justify treating all day labourers as public or ambiguous.

### Code snippets

GLD:

```stata
gen byte ocusec = .
replace ocusec = 1 if q12_13 == 3
replace ocusec = 2 if inlist(q12_13,1,2,4,5,6)
replace ocusec=. if lstatus!=1
```

SARMD:

```stata
recode q12_13 (1 2 4 5 6=2) (3=1), gen(ocusec)
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
