## How to read the harmonization code

Each harmonization do file starts with a header that gives relevant context information (see Box 1, next page) that helps understand the harmonization process not only for other users but for the harmonizers themselves at later points in time. It contains four blocks:

- Information on the code, the harmonizer, and the creation date.
- Details on the survey context
- Details on the versions of the standard classifications used
- Version control history, detailing the date and the contents of any changes performed. 
  - An example would be the fact that a previous harmonization was using the wrong industry classification code, distorting the industry category variables. Then we would enter the date of the change and an explanation of why this was necessary and what changes were done.
 
*Box 1 - GLD Harmonization Template Preamble*
```
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

After the box, the harmonization code is divided into 9 sections. Sections 2 to 8 cover variables of the different blocks of the data dictionary (e.g., geography, socio-demographic, education, …), while Section 1 describes the set up of the environment and assembly of raw data into a single file (if raw data is spread over several files). It is here users would need to update folder and file paths and name if they are using a different storing system (e.g., their server is labelled “E” instead of “Y”). Section 9 does the final clean up to keep only variables in the dictionary that have values (i.e., we do not keep variables that have missing values for all respondents), in the correct order. Data is also compressed and unused labels are discarded so the final output is as size-efficient as possible.

Each section is be tagged according to the following rules (see example in Box 2):

- The section marker starts with /*%% followed by the equal sign to pad out the line
- The section title is indented, starting with a number, colon, and section title
- The section marker closes with a line of equal signs ended by %%*/ (inverse of start)

*Box 2 - Section header example*
```
/*%%========================================================================
1: Setting up of program environment, dataset
========================================================================%%*/
```

Within the “variable” sections 2 to 8, all harmonized variables in the in each section in the data are tagged according to the following convention (see example in Box 3 - Variable tagging example):

- The beginning of the code relating to a harmonized variable should be proceeded by *<_var_>
- The end of the code relating to the variable creation should read *</_var_> where “var” is the harmonized variable being created.
- Variables that are already named (e.g. if "hhid" is already defined) should be noted when the file when opened, using the same convention as above. Between the "open" and "close" codes, a starred outline should read:"*'var' brought in from 'source'"
- If a variable is created more than once (for example, hhid is created from several sources, then used to merge), it should be tagged only once.
- For example, the variable “lfstatus” is created only for individuals with age of 15 and above, then one can put the variable-specific note as follow: *<_lfstatus_note_> Only for individuals with age of 15 and above *</_lfstatus_note_>.

*Box 3 - Variable tagging example*
```
*<_hhid_>
/* <_hhid_note>

The variable should be a string made up of the elements to define it, that is psu code, ssu, ...
Each element should always be as long as needed for the longest element. That is, if there are 60 psu coded 1 through 60, codes should be 01, 02, ..., 60. If there are 160 it should be 001, 002, ..., 160.

</_hhid_note> */
	egen hhid = concat( [Elements] )
	label var hhid "Household ID"
*</_hhid_>

*<_pid_>
	gen pid = 
	label var pid "Individual ID"
*</_pid_>
```

There are two useful purposes of tagging the harmonization variables: (1) tagging is useful when cross checking the definitions of harmonized variables overtime, and when comparing the comparability of such variables with different countries; (2) tagging will improve the automated updating of the DDI by adding the block of codes used for generating the harmonized variables in the variable description of the DDI. Tagging will also improve the transparency of the metadata DDI for basic users in the Microdata Library. Tagging should be done for one variable at a time, not a group of variables.
