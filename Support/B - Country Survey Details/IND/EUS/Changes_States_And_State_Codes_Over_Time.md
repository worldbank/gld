# Changes in states' coding in EUS over time

There are two moments of changes in the state make-up of India (the first administrative divisions of the country covered by the variable `subnatid1`). They in turn cause changes in the codes of the states. For example, the state of Arunachal Pradesh had the code 25 before 1993, code 3 in 1993 and 1999, and was given code 12 from 2004 onwards. 
In the year [1987 the union territory of Goa, Daman and Diu was split](https://en.wikipedia.org/wiki/Goa,_Daman_and_Diu) off with Goa being granted full statehood on its own and Daman and Diu becoming a separate union territory.

In the year 2000, three state reorganisations took place. In all cases the new states were carved out of existing states. These are:

- The creation of Chhattisgarh out of districts previously part of Madhya Pradesh,
- The creation of Uttarakhand (formerly Uttaranchal) out of districts previously part of Uttar Pradesh, and
- The creation of Jharkhand out of districts previously part of Bihar.

The variable `subantid1_prev` indicates to which subnatid1 code the area belonged to in the previous survey. Thus, surveys before 1993 have 31 distinct state codes, surveys between 1993 and 1999 have 32 distinct state codes, while surveys from 2004 have under `subnatid1`.

## Creating a consistent dataset throughout time

There are two strategies to create a dataset without breaks at the `subnatid1` (Admin-1) level. Note that this is not done in the harmonization, as GLD harmonizes every survey independently. The information is given for completeness’ sake.

The first strategy is to impose the old administrative borders throughout, that is, for example, to recode Bihar as always being formed out of Bihar pre-2000 and out of Bihar and Jharkhand post-2000. This has the advantage of ensuring all information is significant at state level. This can be done using the variable `subnatid1_prev`.

The second strategy is to classify states of the current days as if they had existed always. For example, as if Jharkhand had always existed. This requires analysing the regions and districts to know which parts of pre-2000 Bihar will come to form Jharkhand. Information is partly coded in `subnatid2` but it requires further study of the survey documentation and Indian administrative divisions over time. This is not covered here. Note further that this strategy does not assure statistically significant results (e.g., pre-2000 Bihar is representative for Bihar, not for parts of it). 

## Unifying state codes

To aid with unifying the codes into a single data file please see the Excel file with the [overview of state change codes](utilities/IND_EUS_State_Code_Changes.xlsx).
