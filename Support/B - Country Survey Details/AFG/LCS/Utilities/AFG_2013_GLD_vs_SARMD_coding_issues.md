# GLD vs SARMD Coding Review

This note summarizes the main coding differences found when comparing the GLD harmonization to the SARMD work-file logic. It only covers variables where the two approaches may change who is included, excluded, or left uncoded in the final output.

Files reviewed:
- GLD: `AFG_2013_LCS_V01_M_V01_A_GLD_ALL.do`
- SARMD: `AFG_2013_LCS_v01_M_v04_A_SARMD_IND.do`

## Labor status

Labor status differs mainly in how unemployment is defined, and there is also a smaller difference in how marginal work is captured. The GLD treats someone as unemployed only if that person was available for work and either searched for work or had already found a job and was waiting to start. SARMD is broader on unemployment because it counts some people as unemployed even when they were not available. The GLD is also broader on marginal employment because it keeps people who were not captured by the earlier detailed work questions but later said that they had in fact done some work. That affects 106 adults who answered No to `q_11_2` through `q_11_6` but then answered Yes to `q_11_7`, which asks whether they did any work at all, even for a short time.

### Mismatch counts

| GLD result | SARMD result | Count |
|---|---|---:|
| Employed | Missing | 106 |
| Unemployed | Non-LF | 10 |
| Non-LF | Unemployed | 170 |
| Non-LF | Missing | 178 |

### Raw coding details

| Variable | Raw code | Raw meaning | GLD treatment | SARMD treatment |
|---|---:|---|---|---|
| `q_11_2` to `q_11_5` | `1` | worked in one of the detailed work activities | employed | employed |
| `q_11_6` | `1` | summary confirmation of work in `q_11_2` to `q_11_5` | employed | employed |
| `q_11_7` | `1` | later confirmed doing any work at all, even for a short time | employed | not used directly |
| `q_11_8` | `1` | usually works, but temporarily absent | employed | employed |
| `q_11_10` | `1` | available for work | required for unemployment | not required |
| `q_11_11` | `1` | tried to find work | unemployed if also available | unemployed even if availability is not imposed |
| `q_11_12` | `8` | already found work | unemployed if also available | unemployed |
| `q_11_12` | `9` | temporary laid off | not enough on its own for unemployment | unemployed |

### Code snippets

GLD:

```stata
replace lstatus = 1 if inlist(1,q_11_2,q_11_3,q_11_4,q_11_5,q_11_6,q_11_7,q_11_8)
replace lstatus = 2 if missing(lstatus) & q_11_10 == 1 & q_11_11 == 1
replace lstatus = 2 if missing(lstatus) & q_11_10 == 1 & q_11_12 == 8
replace lstatus = 3 if missing(lstatus)
```

SARMD:

```stata
gen lstatus=1 if inlist(1, q_11_2, q_11_3, q_11_4, q_11_5, q_11_6)
replace lstatus=1 if q_11_8==1
replace lstatus=2 if q_11_11==1 | q_11_12==8 | q_11_12==9
replace lstatus=3 if q_11_11==2
```

## Sector of activity (`ocusec`)

Some employed people are left without a sector classification in the SARMD version. In the questionnaire, `q_11_13==3` is “salaried worker, public sector,” while `q_11_13==1`, `2`, `4`, `5`, and `6` all fall outside that category and should map to the non-public side. The GLD does that. SARMD only codes `q_11_13==3` as public and `q_11_13==2` as private, so some valid workers are left uncoded.

### Raw coding details

| Variable | Raw code | Raw meaning | GLD treatment | SARMD treatment |
|---|---:|---|---|---|
| `q_11_13` | `1` | day labourer | non-public | missing |
| `q_11_13` | `2` | salaried worker, private sector | non-public | private |
| `q_11_13` | `3` | salaried worker, public sector | public | public |
| `q_11_13` | `4` | self-employed without paid employees | non-public | missing |
| `q_11_13` | `5` | self-employed with paid employees | non-public | missing |
| `q_11_13` | `6` | unpaid family worker | non-public | missing |

### Code snippets

GLD:

```stata
gen byte ocusec=q_11_13
recode ocusec 3=1 1 2 4/6=2 .a=.
replace ocusec=. if lstatus!=1
```

SARMD:

```stata
gen byte ocusec=1 if q_11_13==3
replace ocusec=2 if q_11_13==2
replace ocusec=. if lstatus!=1
```

## Reason out of labor force (`nlfreason`)

The two versions are mostly similar, except for how they treat apprentices. In the questionnaire, `q_11_12==6` is “being apprentice.” The GLD treats that as `other`, while SARMD treats it as `student`. The GLD keeps it in `other` because student usually means someone who is doing schooling, while an apprentice may be in training but that is not automatically the same thing as formal schooling.

### Raw coding details

| Variable | Raw code | Raw meaning | GLD treatment | SARMD treatment |
|---|---:|---|---|---|
| `q_11_12` | `1` | student/pupil | student | student |
| `q_11_12` | `2` | housewife/housekeeping | housekeeper | housewife |
| `q_11_12` | `3` | retired/too old | retired | retired |
| `q_11_12` | `4` | illness/injury | disabled | disabled |
| `q_11_12` | `5` | handicapped | disabled | disabled |
| `q_11_12` | `6` | being apprentice | other | student |
| `q_11_12` | `7` | in military service | other | other |
| `q_11_12` | `8` | have already found work | other if non-LF | missing |
| `q_11_12` | `9` | temporary laid off | other if non-LF | missing |
| `q_11_12` | `10` to `13` | waiting season / no jobs / family restrictions / other | other | other |
| `q_11_12` | `14` | other | other | carried through as `14`, outside the labeled 1 to 5 range |

### Code snippets

GLD:

```stata
gen byte nlfreason=q_11_12
recode nlfreason 5=4 6/14=5 .a=.
replace nlfreason=. if lstatus!=3
```

SARMD:

```stata
recode q_11_12 (5=4) (6=1) (7 10/13=5) (8/9=.), gen(nlfreason)
replace nlfreason=. if lstatus!=3
```

## Literacy

The SARMD version is less conservative than GLD. The survey asks literacy directly in `q_10_2`. The GLD relies mainly on that answer. SARMD also forces some people to be literate based on the schooling track they completed. That means SARMD is inferring literacy from schooling history, while GLD stays closer to the reported answer.

### Code snippets

GLD:

```stata
gen byte literacy=q_10_2
recode literacy 2=0 .a=.
replace literacy=. if age<ed_mod_age & age!=.
```

SARMD:

```stata
gen byte literacy= q_10_2
recode literacy (2=0)
replace literacy = 1 if (q_10_5==1 & inrange(q_10_6,1,19)) | inrange(q_10_5,2,6)
replace literacy=. if age<6
```

## Years of education (`educy`)

The SARMD version edits the raw years-of-education variable more aggressively than GLD. The survey records completed years in `q_10_6`. The GLD mostly keeps that reported value, apart from age-based restrictions. SARMD fills in years for several schooling tracks when the raw value is zero and applies stronger consistency edits. This makes SARMD more imputed, while GLD stays closer to the reported number of years.

### Code snippets

GLD:

```stata
gen byte educy=q_10_6
replace educy=. if age<ed_mod_age | educy==.a
```

SARMD:

```stata
gen educy = q_10_6
replace educy=6  if q_10_5==2 & educy==0
replace educy=9  if q_10_5==3 & educy==0
replace educy=12 if q_10_5==4 & educy==0
replace educy=12 if q_10_5==5 & educy==0
replace educy=16 if q_10_5==6 & educy==0
replace educy=. if educy>age+1 & educy<. & age!=.
```

## Education ladder (`educat7`)

The two versions differ in how they handle the education ladder, especially Islamic schooling. The survey records schooling track in `q_10_5` and completed grade in `q_10_6`. The GLD uses both pieces together and places Islamic schooling on the education ladder by grade completed. SARMD instead leaves Islamic schooling as not classified. This means GLD keeps more usable information from the raw education record.

### Raw coding details

| Variable | Raw code | Raw meaning | GLD treatment | SARMD treatment |
|---|---:|---|---|---|
| `q_10_5==7` with grades `1` to `5` | Islamic school, low grades | primary incomplete | not classified |
| `q_10_5==7` with grade `6` | Islamic school at primary threshold | primary complete | not classified |
| `q_10_5==7` with grades `7` to `9` | Islamic school above primary threshold | secondary incomplete | not classified |
| `q_10_5==7` with grades `10` to `12` | Islamic school upper grades | secondary complete | not classified |
| `q_10_5==7` with grades `13` to `14` | Islamic school highest grades | post-secondary / tertiary ladder placement | not classified |

### Code snippets

GLD:

```stata
replace educat7=1 if q_10_5==7 & q_10_6==0
replace educat7=2 if q_10_5==7 & inrange(q_10_6,1,5)
replace educat7=3 if q_10_5==7 & q_10_6==6
replace educat7=4 if q_10_5==7 & inrange(q_10_6,7,9)
replace educat7=5 if q_10_5==7 & inrange(q_10_6,10,12)
replace educat7=6 if q_10_5==7 & inrange(q_10_6,13,14)
```

SARMD:

```stata
replace educat7=9 if q_10_5==7
```

## Wage time unit (`unitwage`)

The SARMD version does not line up well with the questionnaire for self-employed workers. In the survey, `q_11_13==4` is “self-employed without paid employees” and `q_11_13==5` is “self-employed with paid employees.” Both groups use `q_11_16`, which is labeled “average monthly profit.” The GLD therefore treats those workers as monthly. SARMD treats those same workers as annual. Since the questionnaire itself says monthly profit, the GLD treatment is more consistent with the source.

### Raw coding details

| Variable | Raw code | Raw meaning | GLD treatment | SARMD treatment |
|---|---:|---|---|---|
| `q_11_13` | `1` | day labourer | daily | daily |
| `q_11_13` | `2` | salaried worker, private sector | monthly | monthly |
| `q_11_13` | `3` | salaried worker, public sector | monthly | monthly |
| `q_11_13` | `4` | self-employed without paid employees | monthly | annual |
| `q_11_13` | `5` | self-employed with paid employees | monthly | annual |
| `q_11_13` | `6` | unpaid family worker | missing | missing |

### Supporting wage questions

| Variable | Questionnaire meaning |
|---|---|
| `q_11_14` | daily wage in past week |
| `q_11_15` | monthly salary |
| `q_11_16` | average monthly profit |

### Code snippets

GLD:

```stata
replace wage_no_compen=q_11_14 if q_11_13==1
replace wage_no_compen=q_11_15 if inlist(q_11_13,2,3)
replace wage_no_compen=q_11_16 if inlist(q_11_13,4,5)

replace unitwage = 1 if q_11_13 == 1
replace unitwage = 5 if inlist(q_11_13,2,3,4,5)
```

SARMD:

```stata
gen wage=q_11_14 if q_11_13==1
replace wage=q_11_15 if inlist(q_11_13,2,3)
replace wage=q_11_16 if inlist(q_11_13,4,5)

gen byte unitwage=q_11_13
recode unitwage 2 3=5 4 5=8 6=. .a=.
```

## Urban classification (Kuchi)

The two versions differ in how they treat Kuchi households in the urban variable. The survey distinguishes Kuchi as a separate nomadic population group rather than a standard fixed-location household type. The GLD leaves Kuchi missing in `urban`. SARMD folds Kuchi into rural. The GLD approach is more conservative because it does not impose an urban-rural classification the survey did not directly make.

### Code snippets

GLD:

```stata
gen byte urban=q_1_5
recode urban 2=0 3=.
```

SARMD:

```stata
recode q_1_5 (2=0)(3=0), gen(urban)
```

## PSU

The two versions use different raw fields for PSU. GLD uses `q_1_3`, while SARMD uses `q_1_4`. This is not just a cosmetic difference because PSU is part of the sample design. Any change here should be based on the sampling documentation rather than on harmonization convenience.

### Code snippets

GLD:

```stata
gen psu=q_1_3
```

SARMD:

```stata
gen psu= q_1_4
```

## Household size

The two versions do not build household size in the same way. GLD uses the delivered household-size field, while SARMD rebuilds household size from the roster. Those two approaches are not always equivalent when a survey has special member categories or roster quirks. Unless there is evidence the delivered household size is wrong, the GLD approach is the safer default.

### Code snippets

GLD:

```stata
gen hsize = hh_size
```

SARMD:

```stata
gen z=1
bys hhid: egen hsize=sum(z)
```

## Original industry and occupation codes

GLD keeps the more detailed original industry and occupation codes, while SARMD often substitutes grouped versions in those original-code slots. The GLD approach preserves more of the raw classification detail for later review.

### Code snippets

GLD:

```stata
gen industry_orig=q_11_19
gen occup_orig=q_11_20
```

SARMD:

```stata
gen industry_orig=q_11_19_b
gen occup_orig=q_11_20_b
```
