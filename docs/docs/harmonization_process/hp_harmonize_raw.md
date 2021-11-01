---
layout: default
title: Harmonize raw data
parent: Harmonization Process
nav_order: 2
---

# Harmonize raw data to GLD standard

Once you have the raw data you can proceed with harmonizing the data to the GLD standard. The easiest way to do so, and indeed the recommended way, is to use the harmonization template. This is to ensure each survey is harmonized in a consistent way, while reducing the typing effort. You may find the template on the GitHub repository [under Support/Templates](https://github.com/worldbank/gld/tree/main/Support/Templates).

It exemplifies the structure of the code, starting with a preamble to provide readers and users of the `.do` file basic information on the survey. It is followed by the database assembly (reading in a single file if all is in a single place or merging and appending bi if data are split over several files), followed by the variables divided into blocks by modules as recorded in the [data dictionary](../../data-dictionary). Note that the labour module, as the largest block, is further divided into subsections.

Each variable is surrounded with a `*<_varname_>` (at the start) and `*</_varname_>` (at the end) tag. This is to make clear (and machine readable) where the definition of a variable starts and ends. Any helper variables used to create the harmonized variable (i.e., variables not in the dictionary but used in the process) should be generated and dropped inside the tagged lines. You should not “cite” helper variables from inside another variable’s tagged lines (as much as possible). You may cite harmonized variables.

Whenever a longer explanation is needed on how and why a variable was coded in a specific way, please put a *tagged note* at the start of the code, starting with `/* <_varname_note>` and ending on `</_varname_note> */`.

The below is an example of how to the variable `hhid` for the household identifier:

```
*<_hhid_>
/* <_hhid_note>
	The variable should be a string made up of the elements to define it, that is psu code, ssu, ...
	Each element should always be as long as needed for the longest element. That is, if there are
	60 psu coded 1 through 60, codes should be 01, 02, ..., 60. If there are 160 it should be 001,
	002, ..., 160.
</_hhid_note> */
	gen hhid_helper_1 = variable_x
	gen hhid_helper_2 = variable_y 
	egen hhid = concat(hhid_helper_1 hhid_helper_2)
	label var hhid "Household ID"
	drop hhid_helper_*
*</_hhid_>
```
