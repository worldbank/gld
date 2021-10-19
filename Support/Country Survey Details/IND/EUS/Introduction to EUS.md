# Introduction to EUS

## What is the data?

The codes under GLD/IND folder system from 1987 to 2011 harmonize the data for the Indian National Sample Survey’s (NSS) Employment and Unemployment Surveys (EUS). 

## Where can the data be found?

The microdata are free and publicly available on the Ministry of Statistics and Programme Implementation’s (MOSPI) [National Data Archive of microdata]( http://microdata.gov.in/nada43/index.php/catalog/EUE). The website also provides all necessary documentation.

## To what level are results significant?

The official reports detail results by gender, sector (urban or rural), and state. That is, the unemployment rate of urban women in Madhya Pradesh can be safely reported.

## Other noteworthy aspects

### Changes in states over time

In the year 2000 three state reorganisations took place. In all cases the new states were carved out of existing states. These are:

- The creation of Chhattisgarh out of districts previously part of Madhya Pradesh,
- The creation of Uttarakhand (formerly Uttaranchal) out of districts previously part of Uttar Pradesh, and
- The creation of Jharkhand out of districts previously part of Bihar.

The 1999 survey (NSS round 55) started in July 1999 and ended in June 2000 and is the last to use the old state definitions. That is why 1999 and previous data have 32 distinct State codes under variable `subnatid1` while 2004 and older surveys have 35 distinct codes.

Note then that the code for Bihar, for example, exists throughout all years but represents a different entity before 2000 than it does after.

### Creating a consistent dataset throughout time

There are two strategies to create a dataset without breaks at the `subnatid1` (Admin-1) level. Note that this is not dine in the harmonization, as GLD harmonizes every survey independently. The information is given for completeness’ sake.

The first strategy is to impose the borders of pre-2000 throughout, that is, for example, to recode Bihar as always being formed out of Bihar pre-2000 and out of Bihar and Jharkhand post-2000. This has the advantage of ensuring all information is significant at state level. 

This can be done using the `subnatid1_prev` variable. This is missing for all states pre-2000 and for all states bar Jharkhand, Chhattisgarh, and Uttarakhand post-2000.

The second strategy is to recode the post-2000 states as if they had existed since the start of the survey series. TO do so you may use the `subnatid2` variable. This doesn’t code an administrative area but rather the regions used by the National Survey Sample (NSS) organisation (statistical regions). The districts covered by each region is detailed in the documentation. For the harmonized data this would be done in the following way:

```
Example code along these lines to be inputted
gen current_state = .
replace current_state = 20 if (reg02 == 10 & reg03 == 1) // Bihar to Jh
replace current_state = 22 if (reg02 == 23 & reg03 == 1) // MP to Chh
replace current_state = 5 if (reg02 == 9 & reg03 == 1) // UP to UK
replace current_state = reg02 if missing(current_state)
```

Note, however, that while estimates for these three states are significant post-2000 it cannot be assured whether this is the case for the states going back. For example, the unemployment rate for Jharkhand is significant for 2004. Whether it is significant for the NSS regions of Bihar in 1999 that make up current day Jharkhand cannot be determined here.

### Definition of the 12-month labour recall

The EUS does not directly ask respondents about their employment over the past 12 months but rather asks about their *usual principal activity* and their *subsidiary economic activity*. In such a situation, a full-time university student who works on the weekends at a petrol station, for example, would classify their principal activity as student. If we were to use only principal activity, we would code this individual as out of the labour force, missing the fact that they are employed as per their subsidiary economic activity. The image below is the classification of the different status in the EUS Instructions to Field Staff:

![Manual](/Support/Country%20Survey%20Details/IND/EUS/utilities/manual_activities.PNG)

For the purposes of the GLD harmonization, the labour status and primary activity details over the 12-month reference period are taken from the usual principal activity if the person is employed as their principal activity, from the subsidiary if they are not employed in their principal activity (e.g., housekeeping or student as principal activity) but are working on their subsidiary activity. Only if they are active on both will the subsidiary activity be used to harmonize a second job. The below matrix presents an overview of these choices.

![Manual](/Support/Country%20Survey%20Details/IND/EUS/utilities/twelve_month_coding.PNG)

### Definition of the 7-day labour recall

Likewise, the EUS does not directly ask respondents about their employment over the past 7 days but rather asks about the economic activities performed in the past 7 days and the number of days spent for each activity. Then, from these activities, the current weekly activity status (CWS) is determined based on the flow chart below. Unlike the principal activity status, the CWS is determined by favoring employment activities, i.e., activities corresponding to status codes 11 – 72. The implication of this determination procedure is that the employment status can already be determined directly from the CWS. Going back to the full-time student working part-time at the gasoline station: while this person spends more time as a student, the CWS will correspond to his work at the gasoline station as the procedure prioritizes employment activities regardless of the number of days spent in the past week.

![Manual](/Support/Country%20Survey%20Details/IND/EUS/utilities/flow_chart_current_week.PNG)

Determining the 7-day primary activity status is more straightforward compared to the 12-month status, but it is tricky to determine the 7-day secondary activity status especially when respondents report more than two activities. The harmonizer needs to have a clear understanding on how the activities should be sorted and how to settle the ties. Based on the flow chart above, the activity statuses should be ordered based on the following activity categories:

1. Activities corresponding to employed (activity status codes: 11 – 72)
2. Activities corresponding to unemployed (codes: 81 – 82)
3. Activities corresponding to being outside of the labor force (codes: 91 – 98)

The process in the flow chart above also specifies how to settle the ties: e.g., a respondent reporting two employment activities, say codes “11” and “72”. The activity with the more days spent will be ordered ahead of the other activity of the same category.  If activity “11” has more days spent than activity “72”, then activity “11” is tagged as the CWS, while the latter can be treated as the secondary activity status. Examples of the determination procedure are shown below:

![Manual](/Support/Country%20Survey%20Details/IND/EUS/utilities/table_current_week.PNG)

The flow chart, however, does not explain how to settle the ties when two activities of the same category have equal number of days spent. Instead, this is determined by deduction. Analysis from the 2009 and 2004 (NSS 61) surveys reveals that two activities of the same category and same number of days spent are resolved by the order of the activity status code. Suppose 3.5 days are spent for each of activities “11” and “72”. Treating both codes as ordinal numbers, it can be inferred that 11 is less than 72; and thus, “11” becomes the CWS. This way of resolving ties, however, biases towards status codes that are lower in order without any known meaningful intuition. For instance, status code “11” (self-employed in HH enterprise) is always going to be the default CWS if it is one of the respondent’s evenly divided employment activities.

**Specific case problems**

While the flowchart is clear that the CWS is determined from the list of activities, there are instances where the CWS is not among the activities performed during the past week. For instance, the record below from the 1999 survey reported two activities in the past week: “62” (*Had work in h.h. enterprise but did not work due to: Other reasons*) and “97” (*Others (including begging, prostitution, etc.*). Following the flow chart, the current weekly activity (B53_q20) should be code “62”; but instead, it is code “11”.

![Manual](/Support/Country%20Survey%20Details/IND/EUS/utilities/browse_1_current_week.PNG)

There are also cases where the given CWS is not equal to what would have been determined by the procedure. Below, for instance, a respondent from the 1993 survey reported three activities corresponding to codes “11”, “51” and “92”. Following the flow chart, activity code “11” should be the CWS as it recorded 3.5 days whereas activity “51” only recorded 2 days. However, the data tags activity “51” as the CWS instead. Whether this follows a different determination procedure or an encoding mistake cannot be confirmed.

![Manual](/Support/Country%20Survey%20Details/IND/EUS/utilities/browse_2_current_week.PNG)

In both cases where the determined CWS differs from the given CWS, the recommended approach is to accept the current weekly activity as the truth despite reneging from the determination rules. The logic behind this is that the current weekly activity is mapped to the industry and occupation variables that would not be compatible should the harmonizer use the determination procedure to tag the CWS. Meanwhile, the determined CWS would then be assigned to the secondary activity. Thus, in this case, the primary activity is “51” while the secondary activity is “11”.
