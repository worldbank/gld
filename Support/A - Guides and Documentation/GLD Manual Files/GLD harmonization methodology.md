# GLD harmonization methodology  

For the purposes of this section, harmonization refers only to the act of converting the raw microdata into the variables of the GLD data dictionary. 

## Defining the boundaries of GLD harmonization

The scope of the GLD harmonization is the data dictionary. However, not always the information in the survey fits the concept in the data dictionary. For example, if the questionnaire asks respondents whether the respondent or their employer “contribute to social or private security” is that sufficient to code the `socialsec` variable? Similarly, with a view to the objective of comparison and benchmarking, how should the harmonization handle change to concepts over time, like changes to the definition of employment or administrative areas? 

To define the boundaries of the harmonization, the GLD team follows two principles: (i) each survey is harmonized independently; and (ii) in unclear situations, users are empowered to take informed decisions, rather than having the GLD team making choices for users.

The principle that surveys are harmonized independently means that each survey is harmonized based on the standard and realities present at the time of its collection and processing. Changes introduced in subsequent surveys are not applied retrospectively. For example, if new geographical regions or occupation classifications are introduced, previous surveys will reflect the older versions without any retroactive adjustments.

The principle to allow users to make informed decisions means to provide comprehensive information about changes and document their impact on the data (for example, the [updated occupation classifications in Pakistan](https://github.com/worldbank/gld/blob/main/Support/B%20-%20Country%20Survey%20Details/PAK/LFS/Correspondence_National_International_Classifications.md) and [changes in the definition of employment in Tanzania](https://github.com/worldbank/gld/blob/main/Support/B%20-%20Country%20Survey%20Details/TZA/ILFS/Converting%20between%20ICLS%20Definitions.md)).

However, the GLD harmonization takes a conservative approach, making minimal assumptions and deferring significant decisions to users. This ensures data accuracy and transparency, allowing users to make well-informed choices based on their research objectives.

Unifying elements that have changed over time across multiple surveys or taking leaps on questions that fit the data dictionary only partially is outside the scope of the harmonization. Users are provided with the necessary context and information to bridge these gaps according to their requirements.

##  The structure of the harmonization code

The GLD harmonization code template begins with a header or preamble summarising key survey aspects (see Box 1, below). It contains four blocks:

1.	Information on the code, the author, and the creation date.
2.	Details on the survey context
3.	Details on the versions of the standard classifications used
4.	Version control history, detailing the date and the contents of any changes performed 

```
Box 1 - GLD Harmonization Template Preamble

/*%%=================================================================
	0: GLD Harmonization Preamble
===================================================================*/
/* ----------------------------------------------------------------- 

<_Program name_> [Name of your do file] </_Program name_> 
<_Application_> [Name of your software (STATA) and version] <_Application_> 
<_Author(s)_> [Name(s) of author(s)] </_Author(s)_> 
<_Date created_> YYYY-MM-DD </_Date created_> 

------------------------------------------------------------------ 

<_Country_> [Country_Name (CCC)] </_Country_> 
<_Survey Title_> [SurveyName] </_Survey Title_> 
<_Survey Year_> [Year of start of the survey] </_Survey Year_> 
<_Study ID_> [Microdata Library ID if present] </_Study ID_> 
<_Data collection from_> [MM/YYYY] </_Data collection from_> 
<_Data collection to_> [MM/YYYY] </_Data collection to_> 
<_Source of dataset_> [Source of data, e.g. NSO] </_Source of dataset_> 
<_Sample size (HH)_> [#] </_Sample size (HH)_> 
<_Sample size (IND)_> [#] </_Sample size (IND)_> 
<_Sampling method_> [Brief description] </_Sampling method_> 
<_Geographic coverage_> [To what level is data significant] </_Geographic coverage_> 
<_Currency_> [Currency used for wages] </_Currency_> 

-------------------------------------------------------------------- 

<_ICLS Version_>	 [Version of ICLS for Labor Questions] </_ICLS Version_> 
<_ISCED Version_> [Version of ISCED used to code] </_ISCED Version_> 
<_ISCO Version_>	 [Version of ISCO used to code] </_ISCO Version_> 
<_OCCUP National_> [Version of national occupation code] </_OCCUP National_> 
<_ISIC Version_> [Version of ISIC used to code] </_ISIC Version_> 
<_INDUS National_> [Version of national industry code] </_INDUS National_> 

---------------------------------------------------------------------

<_Version Control_> 
* Date: [YYYY-MM-DD] - [Description of changes]
* Date: [YYYY-MM-DD] - [Description of changes]
</_Version Control_>

-------------------------------------------------------------------*/
```

After the box, the harmonization code is divided into 9 sections. Section 1 contains the codes to set up file and folder paths and assemble the dataset to harmonize from the raw data. It is at this step users would need to update folder and file paths and name if they are using a different storing system (e.g., their server is labelled “E” instead of “Y”).

Sections 2 to 8 cover variables of the different blocks of the data dictionary (e.g., geography, socio-demographic, education, …). Section 9 does the final clean up to keep only variables in the dictionary that have values (i.e., we do not keep variables that have missing values for all respondents), in the correct order. Data is also compressed and unused labels are discarded so the final output is as size-efficient as possible.

Each section is be tagged according to the following rules (see example in Box 2):

- The section marker starts with /*%% followed by the equal sign to pad out the line
- The section title is indented, starting with a number, colon, and section title
- The section marker closes with a line of equal signs ended by %%*/ (inverse of start)

```
Box 2 - Section header example

/*%%=================================================================
1: Setting up of program environment, dataset
=================================================================%%*/
```

Within the “variable” sections 2 to 8, all harmonized variables in the in each section in the data are tagged according to the following convention (see example in Box 3 - Variable tagging example):

- The beginning of the code relating to a harmonized variable should be proceeded by *<_var_> where “var” is the harmonized variable being created.
- The end of the code relating to the variable creation should read *</_var_>.
- Variables that are already named (e.g. if "hhid" exists in raw data file) should be noted. Between the "open" and "close" tags, a starred outline should read:"*'var' present in 'source'".
- If a variable requires more extensive or explicit comments, these should be written between note tags. The note tag is the same as the variable tag only followed by “_note” (e.g., “note_var”). For example, the variable “lstatus” is created in an uncommon or unexpected way, then harmonizers can add the variable-specific note as follow: *<_lstatus_note_> Text explaining issues with variable, why which choices made *</_lfstatus_note_> (see Box 3 below).

```
Box 3 - Variable tagging example
*<_wage_no_compen_>

/*<_wage_no_compen_note_>

The wage questions in the questionnaire are organized into two parts: the first part asks for the specific number of income if the given respondent could recall and was willing to answer; the second part provides different categories of income range if the given respondent could not recall or was not willing to answer the first part. 

The general logic here is to impute wage values for people who only answered an income range. We used industry, occupation, income categories and gender to estimate their specific income values. 

21.86% of total non-missing wage values were imputed using this method.
*<_wage_no_compen_note_>*/

     * Overall --> wage info 
     * Set values of 0 to missing
	 gen wage14=E14_1+E14_2
     replace wage14=. if wage14==0

     * First replace outliers by
     winsor2 wage14, suffix(_w) cuts(1 99)

     * Create salary categories based on winsor values
     gen salary_cat=.
     replace salary_cat=1 if inrange(wage14_w, 1, 55000)

[…]

     * Keep only for employed employees, label
     replace wage_no_compen=. if lstatus!=1|empstat==2
     label var wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>
```

There are two useful purposes of tagging the harmonization variables: (1) tagging is useful when cross checking the definitions of harmonized variables overtime, and when comparing the comparability of such variables with different countries; (2) tagging will improve the automated updating of the DDI by adding the block of codes used for generating the harmonized variables in the variable description of the DDI. Tagging will also improve the transparency of the metadata DDI for basic users in the Microdata Library. Tagging should be done for one variable at a time, not a group of variables.

## GLD data dictionary

This section defines one by one each variable in the data dictionary and how they should be harmonized. It is divided into blocks as is done in the harmonization code. Each block section then also contains some lessons learned if any and a tabular overview of the variables.