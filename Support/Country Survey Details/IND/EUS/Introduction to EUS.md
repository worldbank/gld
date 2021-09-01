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

<br></br>
![Manual](/Support/Country%20Survey%20Details/IND/EUS/utilities/manual_activities.PNG)
<br></br> 

For the purposes of the GLD harmonization, the labour status and primary activity details over the 12-month reference period are taken from the usual principal activity if the person is employed as their principal activity, from the subsidiary if they are not employed in their principal activity (e.g., housekeeping or student as principal activity) but are working on their subsidiary activity. Only if they are active on both will the subsidiary activity be used to harmonize a second job. The below matrix presents an overview of these choices.

<br></br>
![Manual](/Support/Country%20Survey%20Details/IND/EUS/utilities/twelve_month_coding.PNG)
<br></br> 

### Definition of the 7-day labour recall

**To be filled.**