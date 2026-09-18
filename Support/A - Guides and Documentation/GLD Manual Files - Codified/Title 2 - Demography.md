# Title 2. Demography

This title covers the variables of the Demography block of the harmonization
template. The variable labels below are the labels in the template.

| Section | Variable | Variable label |
|---|---|---|
| § 2.1 | `hsize` | Household size |
| § 2.2 | `age` | Individual age |
| § 2.3 | `male` | Sex - Ind is male |
| § 2.4 | `relationharm` | Relationship to the head of household - Harmonized |
| § 2.5 | `relationcs` | Relationship to the head of household - Country original |
| § 2.6 | `marital` | Marital status |
| § 2.7 | (all six below) | Disability variables: common rules |
| § 2.8 | `eye_dsablty` | Disability related to eyesight |
| § 2.9 | `hear_dsablty` | Disability related to hearing |
| § 2.10 | `walk_dsablty` | Disability related to walking or climbing stairs |
| § 2.11 | `conc_dsord` | Disability related to concentration or remembering |
| § 2.12 | `slfcre_dsablty` | Disability related to selfcare |
| § 2.13 | `comm_dsablty` | Disability related to communicating |

Every section has the same seven parts: (a) Definition, (b) Rule, (c) Order
of sources, (d) Exceptions, (e) Missing values, (f) Checks, and (g) Notes. A
part with no content says "[Reserved.]", so that each letter keeps its meaning
in every citation.

---

## § 2.1 `hsize`: Household size

**(a) Definition.** `hsize` codes the size of the household.

**(b) Rule.**

(1) `hsize` shall not include individuals who may be living in the household
but do not form an economic unit with the other household members (e.g., a
live-in maid is not part of the household).

(2) `hsize` shall count only current household members. Not all the
individuals reported in a household that form the raw data are current
household members.

**(c) Order of sources.** [Reserved.]

**(d) Exceptions.** [Reserved.]

**(e) Missing values.** § 1.1 applies.

**(f) Checks.** [Reserved.]

**(g) Notes.**

(1) *Illustration of (b)(2).* For the EU-SILC survey, a household contains
the current member, but also the members of the previous survey who have left
the household for reasons such as death or migration.

(2) *Relation to the roster.* Because of paragraph (b)(1), `hsize` can be
lower than the number of people in the roster. That result is correct.

(3) *Source.* `Demography.md` lines 5 to 7, and line 173.

---

## § 2.2 `age`: Individual age

**(a) Definition.** `age` refers to the interval of time between the date of
birth and the date of the survey.

**(b) Rule.**

(1) Every effort shall be made to determine the precise and accurate age of
each person, particularly of children and older persons.

(2) In the case of children aged less than or equal to 60 months, `age` shall
be expressed in the number of completed years and months in decimals.

**(c) Order of sources.** Information on age may be secured either by
obtaining the date (year, month, and day) of birth or by asking directly for
age at the person's last birthday. The harmonizer shall use the first source
that the survey has, in this order:

(1) The age at the person's last birthday, as asked directly.

(2) The date of birth. The harmonizer shall compute `age` at the date of the
interview.

(3) The date of birth, when the day of the interview is not available. The
harmonizer shall compute `age` at the month of the interview.

(4) The date of birth, when the month of the interview is not available. The
harmonizer shall compute `age` at the middle of the year of the interview
(1 July).

**(d) Exceptions.** [Reserved.]

**(e) Missing values.** § 1.1 applies, with one exception. If the NSO uses 98
or a higher value as a top code, for example "98 = 98 and older", that value
is an age. The harmonizer shall keep it and record the top code in the
do-file.

**(f) Checks.**

(1) `age` shall be an integer for a person older than 5.

```
age/int(age)!= 1 & age!= . & age > 5
```

(2) `age` shall not have negative or extreme values (>120).

```
(age < 0 | age>120) & age<.
```

(3) The harmonizer shall list the people with a missing `age`, and confirm
that no source in paragraph (c) gives an age for them.

```
age==.
```

**(g) Notes.**

(1) *Illustration of (b)(2).* If the interview of a 4 years old was in
December and he was born in June, his age should be recorded as 4.5.

(2) *Source.* `Demography.md` lines 9 to 11, and lines 113 to 129.

---

## § 2.3 `male`: Sex - Ind is male

**(a) Definition.** `male` is a dummy variable that specifies the sex, male or
female, of an individual within a household.

**(b) Rule.**

(1) Sex of household member, two categories after harmonization:

| Code | Label |
|---|---|
| 1 | Male |
| 0 | Female |

(2) While constructing this variable, it is important to make sure that all
relevant values are included.

**(c) Order of sources.** [Reserved.]

**(d) Exceptions.** [Reserved.]

**(e) Missing values.** § 1.1 applies.

**(f) Checks.**

(1) `male` can only take one of two values, 0 or 1 (or missing).

```
male!=. & male!= 1 & male!= 0
```

(2) The harmonizer shall list the people with a missing `male`.

```
male==.
```

(3) Check to make sure that there is variation in `male`.

```
egen sdmale = sd(male) // sdmale shall be greater than 0. A value of 0 means that every person has the same sex.
```

**(g) Notes.**

(1) *Source.* `Demography.md` lines 13 to 18, and lines 131 to 146.

---

## § 2.4 `relationharm`: Relationship to the head of household - Harmonized

**(a) Definition.** `relationharm` is an integer categorical variable that
indicates a relationship to the reference person of household (usually the
head of household).

**(b) Rule.** Relationship to head of household, six categories after
harmonization:

| Code | Label |
|---|---|
| 1 | Head of household |
| 2 | Spouse |
| 3 | Children |
| 4 | Parents |
| 5 | Other relatives |
| 6 | Other and non-relatives |

**(c) Order of sources.** Each household shall have one head. The harmonizer
shall choose the head in this order:

(1) The head of household that the survey reports.

(2) The spouse, in cases where the head is missing or a migrant.

(3) The oldest member of the household, if the spouse is also not available.

If the harmonizer uses paragraph (2) or (3), the harmonizer shall recode all
the relations to the head accordingly.

**(d) Exceptions.** [Reserved.]

**(e) Missing values.** § 1.1 applies.

**(f) Checks.**

(1) `relationharm` must be an integer in the range [1,6].

```
(relationharm < 1 | relationharm > 6 | mod(relationharm, 1) != 0) & !missing(relationharm)
```

**(g) Notes.**

(1) *Categories.* The categories are harmonized across all regions. They are
the same as the I2D2 categories.

(2) *Source.* `Demography.md` lines 20 to 33, and lines 149 to 153.

---

## § 2.5 `relationcs`: Relationship to the head of household - Country original

**(a) Definition.** `relationcs` is a country-specific categorical variable
that indicates the relationship to the head of the household. The categories
for relationship to the head of the household are defined according to the
region or country requirements.

**(b) Rule.** [Reserved. The type of `relationcs`, string or numeric, is an
open question. See issue
[#803](https://github.com/worldbank/gld/issues/803).]

**(c) Order of sources.** [Reserved.]

**(d) Exceptions.** [Reserved.]

**(e) Missing values.** § 1.1 applies.

**(f) Checks.** [Reserved.]

**(g) Notes.**

(1) *Open question.* Issue #803 also asks if a do-file may create
`relationcs` as a copy of `relationharm`. A copy holds the harmonized codes,
not the codes of the country.

(2) *Source.* `Demography.md` lines 35 to 37.

---

## § 2.6 `marital`: Marital status

**(a) Definition.** `marital` is a categorical variable that refers to the
personal status of each individual in relation to the marriage laws or
customs of the country.

**(b) Rule.**

(1) Marital status, five categories after harmonization:

| Code | Label |
|---|---|
| 1 | Married |
| 2 | Never Married |
| 3 | Living together |
| 4 | Divorced/Separated |
| 5 | Widowed |

(2) The harmonizer shall code the status of each person as follows:

| Status of the person | Code |
|---|---|
| Single, in other words never married | 2 |
| Married | 1 |
| Contractually married, but not yet living with the spouse | 1 |
| Living with a partner, but not married | 3 |
| Married but separated, legally or de facto | 4 |
| Divorced and not remarried | 4 |
| Widowed and not remarried | 5 |
| Remarried after a divorce or the death of a spouse | 1 |

(3) If it is not possible to distinguish between married and living
together, then it shall be assumed that the individual is married (code 1).

(4) The `marital` variable shall not be imputed but rather calculated only
for those to whom the question was asked (in other words, the youngest age at
which information is collected may differ depending on the survey).

**(c) Order of sources.** [Reserved.]

**(d) Exceptions.**

(1) A person below the youngest age at which the survey asks the marital
question shall be coded 2, "Never Married". The harmonizer shall record that
age in the do-file.

(2) Paragraph (1) applies only to people the survey did not ask. A person at
or above that age with no answer stays missing under § 1.1.

(3) [Reserved. An upper age limit for paragraph (1), for example 15, is an
open question. See issue
[#802](https://github.com/worldbank/gld/issues/802).]

**(e) Missing values.** § 1.1 applies.

**(f) Checks.**

(1) `marital` must be an integer in the range [1,5].

```
(marital < 1 | marital > 5 | mod(marital, 1) != 0) & !missing(marital)
```

(2) The consistency between `age` and `marital` needs to be cross-checked.
Under paragraph (d)(1), a person below the youngest age asked has code 2, so
a missing value for such a person is an error.

```
tab age marital, missing
```

**(g) Notes.**

(1) *Reason for paragraph (d)(1).* The exception follows the NSO. If the NSO
chose not to ask people below an age, it judged that they are not married.
The exception is still an assumption. In most countries, there are also
likely to be persons who were permitted to marry below the legal minimum age
because of special circumstances. Users should know that code 2 below the age
limit is imputed.

(2) *Use in tables.* To permit international comparisons of data on marital
status, any tabulations of marital status not cross-classified by exact age
should at least distinguish between persons under 15 years of age and over.

(3) *Source.* `Demography.md` lines 39 to 53, and lines 155 to 165.

---

## § 2.7 Disability variables: common rules

**(a) Scope.** This section applies to the six disability variables in
§ 2.8 to § 2.13. Each of those sections gives the definition of its variable.
The other parts of this section apply to all six.

**(b) Rule.** Categories after harmonization:

| Code | Label |
|---|---|
| 1 | No – no difficulty |
| 2 | Yes – some difficulty |
| 3 | Yes – a lot of difficulty |
| 4 | Cannot do at all |

**(c) Order of sources.** [Reserved.]

**(d) Exceptions.** [Reserved.]

**(e) Missing values.** § 1.1 applies.

**(f) Checks.** [Reserved.]

**(g) Notes.**

(1) *Questions.* See the Washington Group "[Recommended Short Set of
Questions](https://www.cdc.gov/nchs/washington_group/wg_questions.htm)" for
all disability questions.

(2) *Source.* `Demography.md` lines 55 to 107, and line 185.

---

## § 2.8 `eye_dsablty`: Disability related to eyesight

**(a) Definition.** `eye_dsablty` is a numerical variable that indicates
whether an individual has any difficulty in seeing, even when wearing
glasses.

**(b) Rule.** § 2.7 applies.

---

## § 2.9 `hear_dsablty`: Disability related to hearing

**(a) Definition.** `hear_dsablty` is a numerical variable that indicates
whether an individual has any difficulty in hearing even when using a hearing
aid.

**(b) Rule.** § 2.7 applies.

---

## § 2.10 `walk_dsablty`: Disability related to walking or climbing stairs

**(a) Definition.** `walk_dsablty` is a numerical variable that indicates
whether an individual has any difficulty in walking or climbing steps.

**(b) Rule.** § 2.7 applies.

---

## § 2.11 `conc_dsord`: Disability related to concentration or remembering

**(a) Definition.** `conc_dsord` is a numerical variable that indicates
whether an individual has any difficulty concentrating or remembering.

**(b) Rule.** § 2.7 applies.

---

## § 2.12 `slfcre_dsablty`: Disability related to selfcare

**(a) Definition.** `slfcre_dsablty` is a numerical variable that indicates
whether an individual has any difficulty with self-care such as washing all
over or dressing.

**(b) Rule.** § 2.7 applies.

---

## § 2.13 `comm_dsablty`: Disability related to communicating

**(a) Definition.** `comm_dsablty` is a numerical variable that indicates
whether an individual has any difficulty communicating or understanding usual
(customary) language.

**(b) Rule.** § 2.7 applies.

---

## Revision notes

This table lists every change from `Demography.md` and the reason for it.
Other text keeps the original sentences, with "should" changed to "shall" in
the rules.

| # | Change | Reason |
|---|---|---|
| 1 | The section "Lessons Learned and Challenges" is gone. Each check now sits under its variable, in part (f). | A reader finds all the rules for one variable in one place. |
| 2 | The check `weight==.` is not in this title. | `weight` is a Survey & ID variable. The check moves to that title when it is written. |
| 3 | The four statements about codes such as 98 are replaced by "§ 1.1 applies" in each section. | One rule in one place cannot contradict itself. The number 98 can be a real age. |
| 4 | The labels for `relationharm` codes 1 and 6 now match the template: "Head of household" and "Other and non-relatives". | The template is fixed, so the manual follows it. `GLD_Dictionary_v01.xlsx` still says "non-relatives" and needs the same change. |
| 5 | The checks for `relationharm` and `marital` are corrected. | The originals flag no value, not even 0, 7, or 2.5. They use `&` where they need `\|`, and `mod(x, 1) == 1` is never true. A Stata test confirmed the fault and the fix. |
| 6 | The `marital` check now starts at 1, not 0. | Code 0 is not a valid category. |
| 7 | The comment on the `male` check now says that `sdmale` must be greater than 0. | A value of 0 means no variation, which is the fault. A Stata test confirmed it. |
| 8 | The two category lists for `marital` are replaced by one table that maps each status to a template code. | The text and the code list did not match. The text also said "windowed and remarried", a typo for the UN category "widowed and not remarried". |
| 9 | `marital` has one exception to the rule against imputation: code 2 for a person below the youngest age asked. | The original said "should not be imputed" and also "Children are never married". See issue #802. |
| 10 | The rule for `relationcs` is reserved. | The type is an open question. See issue #803. |
| 11 | `age` has a new order of sources in part (c). | This rule is new. It comes from the GLD team. The reference date "1 July" is one reading of "the middle of the year", and it needs confirmation. |
| 12 | The check "Age cannot be missing" now lists the people with a missing age. | The rule allows a missing age when no source gives one, so the check cannot forbid it. |
| 13 | The rule for choosing the head of household is now an order of sources in § 2.4(c). | The original rule was already a sequence: head, then spouse, then oldest member. |
| 14 | The six disability sections refer to one common section, § 2.7. | The six sections repeated the same category list. |
| 15 | The examples are now notes, marked "Illustration". | An example explains a rule. It is not a rule. |
| 16 | The table "Overview of Variables" is now the list of sections at the top, with the labels from the template. | The table now also works as the table of contents. |
| 17 | `hsize` has a new note that it can be lower than the number of people in the roster. | The GLD team confirmed this. It follows from the rule on members who do not form an economic unit. |
