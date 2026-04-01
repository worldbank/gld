
# Employment Status

The discussion below continues to apply to the Mongolia LFS over time. For the
recent rounds, the main status-in-employment question remains broadly
comparable. The main new issue is in 2024, when the questionnaire reorganizes
the employee payment block. To approximate the previous rounds as closely as
possible, the GLD continues to derive `empstat` from the main status question
and uses the 2024 payment-type question `E18` only to separate remunerated
employee or apprentice cases from explicitly unpaid ones.

The table below summarizes the mapping between the harmonized employment
categories in `empstat` and the categories in the raw dataset. These mappings
generate estimates consistent with the ILO for each of the ICSE-93 status of
employment categories.

| `empstat` | Raw employment-status categories |
|--------------------------------------------------|-------------------------------------------------------------------------------------------|
| Employer | In his/her own business activity or ina business operated by a household or family member **and** regularly hires workers, Employer |
| Self-employed | In a business operated by a household or family member, Employed in animal husbandry, Own account worker, Self employer [sic] |
| Paid employee | As an employee for someone else, As an apprentice, intern, Paid employee, Paid employee on contract, Paid employee under civil law |
| Non-paid employee | Helping a family member who works for someone else, Unpaid family worker |
| Other, workers not classifiable by status | Member of cooperative, Other |

When examining the mappings, several noteworthy trends emerge. The figure below
shows a significant decrease in *non-paid employees*, especially during
2008-2010 and 2018-2019.

<br>
<img src="Utilities/MNG_empstat.png" width="600" height="550">
<br>

From 2008 to 2010, *non-paid employees* declined sharply from ~206,000 to
~100,000, while there was a corresponding increase in *paid employees*. In the
years 2018 and 2019, category wording shifted from "unpaid family worker" to
"helping a family member who works for someone else". Accompanying this
semantic shift, estimates recorded a marked decrease, from about 45,000 in
2018 to roughly 7,600 in 2019. Despite this change, the GLD mapping continues
to classify both under *non-paid employee*, mirroring the ILO treatment of
both as *contributing family workers*. These changes are consistent with ILO
estimates for these periods.

**ILO estimates for 2008 and 2010**

<br>

<img src="Utilities/ilo_empstat_08_10.PNG" width="1000" height="600">

<br>

**ILO estimates of contributing family workers for 2018 and 2019**

<br>

<img src="Utilities/ilo_empstat_18_19.png" width="1000" height="150">

<br>

According to ILO, the number of unpaid family workers in 2018 is half of that
in 2010 and near vanishing in 2019, despite the labour force growing overall
in absolute terms. This confirms the GLD estimates. Users should be wary of
the effect this anomaly may have in their analyses.

## Recent rounds: 2022 to 2024

For the recent rounds, the main status in employment question remains `E04`,
which preserves the broad comparability of `empstat` across 2022, 2023, and
2024. The relevant categories are:

- `1` In his/her own business activity
- `2` In a business operated by a household or family member
- `3` As an employee for someone else
- `4` As an apprentice, intern
- `5` Helping a family member who works for someone else

The recent harmonized rounds contain the following numbers of observations:

| Round | Individual count | HH count | Nonmissing `empstat` |
| --- | ---: | ---: | ---: |
| 2022 | 52,195 | 6,957 | 20,679 |
| 2023 | 49,903 | 6,582 | 19,988 |
| 2024 | 49,654 | 6,584 | 19,334 |

The mapping used in the recent rounds is summarized below.

| Raw status category | 2022 GLD mapping | 2023 GLD mapping | 2024 GLD mapping |
| --- | --- | --- | --- |
| `E04 = 1` In his/her own business activity | Self-employed, unless `E07 = 1`, then employer | Self-employed, unless `E07 = 1` or `2`, then employer | Self-employed, unless `E07 = 1` or `2`, then employer |
| `E04 = 2` In a business operated by a household or family member | Self-employed, unless `E07 = 1`, then employer | Self-employed, unless `E07 = 1` or `2`, then employer | Self-employed, unless `E07 = 1` or `2`, then employer |
| `E04 = 3` As an employee for someone else | Paid employee | Paid employee if `E11 = 1`, non-paid employee if `E11 = 2` | Paid employee if `E18 = 1/7`, non-paid employee if `E18 = 8` |
| `E04 = 4` As an apprentice, intern | Paid employee | Paid employee if `E11 = 1`, non-paid employee if `E11 = 2` | Paid employee if `E18 = 1/7`, non-paid employee if `E18 = 8` |
| `E04 = 5` Helping a family member who works for someone else | Non-paid employee | Non-paid employee | Non-paid employee |

The most important recent difference is in 2024. The questionnaire is not
entirely inconsistent with the 2022 and 2023 rounds, because the broad
status-in-employment question `E04` remains the same. However, the employee
payment block is organized differently. In 2024, employee and apprentice cases
report the type of payment in `E18`, with the relevant categories:

- `1` wage or salary
- `2` paid by piece or work completed
- `3` commissions
- `4` tips
- `5` fee for the service
- `6` meals or accommodation
- `7` payment with products
- `8` none of the above, including unpaid

For this reason, the 2024 GLD keeps the same broad mapping from `E04` and uses
`E18` only to separate remunerated employee or apprentice cases from
explicitly unpaid ones. The 2024 GLD therefore codes `E04 = 3` or `4` with
`E18` in `1/7` as paid employee and `E18 = 8` as non-paid employee. This best
approximates the earlier methodology while respecting the 2024 questionnaire
structure.
