# ENEIC panel structure and validation (2024 Q4–2025 Q4)

This document compares the rotating-panel design described by INE in the [2025 ENEIC questionnaire](utilities/GTM_2025_ENEIC_QR-All.pdf#page=9) (PDF page 9) with patterns observed in the harmonized person files for 2024 Q4 through 2025 Q4. It examines household overlap and person-ID consistency separately.

## Intended panel structure

INE describes ENEIC as a rotating panel that follows some households over time while gradually renewing the sample. The questionnaire states that 80% of households remain each quarter and 20% new households enter. This is the planned sample rotation; it need not equal the overlap among completed interviews in the released files. The cited page does not specify how many consecutive quarters each recruited household is scheduled to participate.

The 80% figure is an aggregate design share, not necessarily a constant household-level retention probability. Households at different stages of a rotation can have different probabilities of appearing in the next quarter. The questionnaire page does not specify a fixed number of visits or establish a five-quarter tenure.

## Data and approach

The analysis appended the harmonized ENEIC person files for 2024 Q4 through 2025 Q4. For household overlap, it retained one record per `hhid` per quarter and counted IDs present in each adjacent-quarter pair. Person-level consistency was checked separately using repeated `hhid`–`pid` combinations and recorded age and sex (`male`). All counts and percentages below are **unweighted file diagnostics**, not estimates of the planned sample rotation.

## Observed household overlap

| Transition | Households in earlier quarter | Seen in both quarters | Earlier-quarter households seen again | Later-quarter households seen previously |
|---|---:|---:|---:|---:|
| 2024 Q4 → 2025 Q1 | 13,649 | 9,832 | 72.0% | 72.8% |
| 2025 Q1 → 2025 Q2 | 13,502 | 9,870 | 73.1% | 75.2% |
| 2025 Q2 → 2025 Q3 | 13,129 | 9,786 | 74.5% | 72.9% |
| 2025 Q3 → 2025 Q4 | 13,423 | 9,813 | 73.1% | 74.7% |

The two percentages for each transition use different denominators: the earlier-quarter retention rate divides by households in the earlier quarter, while the later-quarter return rate divides by households in the later quarter. Neither reaches 80%. In each later quarter, about 25–27% of household IDs were absent from the immediately preceding quarter. These absent IDs should not automatically be interpreted as newly recruited households.

Quarterly household totals range from 13,129 to 13,649. The counts suggest that households no longer observed are broadly offset by IDs not present in the previous quarter, but an absent ID may reflect a missed interview rather than sample entry. The diagnostic found **26 household-quarter observations** in which a previously observed household ID returned after a gap.

## Cohorts and rotation stage

Among households first observed in the available 2025 files, next-quarter overlap is higher than the overall adjacent-quarter rates. Of the 3,670 IDs first observed in Q1, 3,078 (83.9%) appear in Q2. Of 3,252 IDs first observed in Q2, 2,923 (89.9%) appear in Q3. Of 3,628 IDs first observed in Q3, 3,093 (85.3%) appear in Q4.

Pooling the available cohort transitions, next-quarter presence is **86.2%** at first observation, **78.0%** one quarter after first observation, and **67.7%** two quarters after first observation. This pattern may reflect rotation stage, but later stages include fewer cohorts and the comparison is not controlled for time or cohort composition. First observation in these files is not the same as the household’s assigned rotation group.

The 2024 Q4 file is the beginning of the available series, not necessarily the beginning of a rotation cohort. Of its 13,649 household IDs, 9,832 appear in 2025 Q1, 6,799 in Q2, 4,179 in Q3, and 2,911 in Q4. The final count is **21.3%** of the initial group. Its proximity to 20% does not establish the panel tenure or demonstrate that the planned rotation was followed, because the initial file may contain households at different rotation stages.

## Person-ID consistency checks

In the appended files, `year wave hhid pid` uniquely identifies each person-quarter record. Among **107,029 distinct `hhid`–`pid` combinations**, 188 have more than one recorded value of `male`, and 483 have an age decrease or an age range greater than one year. Among the **73,002 combinations observed in at least two quarters**, these are approximately **0.26%** and **0.66%**, respectively. The groups can overlap; do not add their counts.

These are consistency diagnostics, not definitive person-identity validation. People can share the same sex and similar ages, and source responses can be erroneous. Conversely, age changes flagged by this rule may be valid: a sequence of 19, 20, 20, 20, and 21 across 2024 Q4–2025 Q4 may depend on exact interview dates. Treat flags as cases for review, not confirmed linkage errors.

## Assessment and caveats

The harmonized files show **72.0–74.5% earlier-quarter household retention** and **72.8–75.2% later-quarter return**, below the questionnaire’s intended 80% household retention. Person-ID consistency checks show relatively few flagged combinations, but cannot establish that every repeated ID represents the same person. The identifiers appear practically useful for longitudinal analysis, but the available evidence does not establish why observed household overlap differs from the planned rotation.

The difference may reflect nonresponse, replacements, differences between sampled dwellings and completed household interviews, or limitations in the available identifiers. Readers with additional information about ENEIC's rotation design, sample assignments, or the construction of household identifiers are invited to share it with the GLD team. Household overlap and identifier consistency will be monitored as more quarters are incorporated, including 2026 Q1-Q4.

---