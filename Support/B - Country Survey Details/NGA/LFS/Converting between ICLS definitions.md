# Introduction
Since the passing of the [resolution concerning statistics of work, employment and labour underutilization](https://www.ilo.org/global/statistics-and-databases/standards-and-guidelines/resolutions-adopted-by-international-conferences-of-labour-statisticians/WCMS_230304/lang--en/index.htm) in 2013 at the 19th International Conference of Labour Statisticians (ICLS) surveys are at risk of a series break due to the change in the concept of employment.

In short, the ICLS 19 resolution restricts employment to *work performed for others in exchange for pay or profit*, meaning that own consumption work (e.g., subsistence agriculture or building housing for oneself) are not counted as employment.

The GLD codes the harmonization's `lstatus` variable based on the concept used in the survey. This applies to all years of the Nigeria LFS (2022 and 2024). This document describes the current coding approach and explains how to adapt it to match the pre-ICLS 19 definition, covering all variables affected.

# Current coding for each survey of the Nigeria LFS

The current code identifies subsistence farmers — those whose agricultural produce is mainly for own consumption — and excludes them from employment at source. The `agf2*` variables only route respondents into employment when produce is primarily market-oriented (`agf2b == 4` or `5`, `agf2c == 1` or `3`, `agf2d == 1`). Those who farm mainly for own consumption never receive `lstatus = 1` and fall through to not-in-labour-force (N). The key steps for `lstatus` are:

```stata
*<_lstatus_>
	gen byte lstatus = .

	*E: Assign employed for any of the options that lead to MJJ1
	replace lstatus = 1 if atw1 == 1
	replace lstatus = 1 if agf1b_4 == 1
	replace lstatus = 1 if agf2a == 1
	replace lstatus = 1 if agf2b == 4
	replace lstatus = 1 if agf2b == 5
	replace lstatus = 1 if agf2c == 1
	replace lstatus = 1 if agf2c == 3
	replace lstatus = 1 if agf2d == 1

	*U: Looking for work/to do business in the past month, and available to work in the past week
	replace lstatus = 2 if (um1_1 == 1 | um1_2 == 1) & um10a == 1

	*N: All others
	replace lstatus = 3 if missing(lstatus) & age >= minlaborage

	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>
```

# Coding for the Old ICLS definition

To match the pre-ICLS 19 definition, subsistence farmers must be counted as employed. The approach used is to identify them via the `agf3*` section of the questionnaire: all subsistence farmers answer this section (specifically `agf3bclean` captures the type of agricultural activity), and non-respondents to this section are not subsistence farmers. A helper indicator `emp_old_icls` is constructed and used to add these individuals to employment, as well as to fill in all downstream labour market variables. The same approach applies to both 2022 and 2024.

## `lstatus`

```stata
	* Incorporate all that reply to agf3bclean
	gen emp_old_icls = !missing(agf3bclean)
	replace lstatus = 1 if emp_old_icls == 1

	*U: Guard unemployment to those not already employed
	replace lstatus = 2 if (um1_1 == 1 | um1_2 == 1) & um10a == 1 & missing(lstatus)
```

Two changes relative to the current code: (1) subsistence farmers are added to employment via `emp_old_icls`; (2) the unemployment condition gains a `missing(lstatus)` guard to prevent overwriting the newly employed.

## `empstat`

Subsistence farmers are self-employed with no employees, so they are assigned category 4:

```stata
	* Add self-employed for own account ag
	replace empstat = 4 if emp_old_icls == 1
```

## `ocusec`

They are assigned to the private/NGO sector (category 2):

```stata
	* Add own account
	replace ocusec = 2 if emp_old_icls == 1
```

## `industrycat_isic`

Their ISIC code is drawn directly from `agf3bclean`, which records the type of agricultural activity:

```stata
	* Add own account
	gen isic_own_acount_help = string(agf3bclean, "%04.0f")
	replace industrycat_isic = isic_own_acount_help if emp_old_icls == 1
```

## `occup_isco`

They are assigned ISCO 6300 (subsistence farmers and fishers):

```stata
	* Add own account
	replace occup_isco = "6300" if emp_old_icls == 1
```

## `whours`

Hours are constructed from `agf4` (days worked per week) multiplied by `agf5` (hours worked per day):

```stata
	* Add own account
	gen oa_hours_help = agf4 * agf5 if inrange(agf4, 1, 7)
	replace whours = oa_hours_help if emp_old_icls == 1
```

All other variables (e.g., `wage_no_compen`, `unitwage`, `contract`) remain missing for this group, as the questionnaire does not collect that information for subsistence farmers.

# Size of subsistence farmers population in Nigeria

The size of the subsistence farmers is not as significant as in other countries (e.g., Rwanda is over 30% of working age population), covering only ~4% of the working age population.

| **Year** | **% of working age** |
|:---:|:---:|
| 2022 Q4 | 4.6% |
| 2023 Q1-Q3 | 3.8% |



