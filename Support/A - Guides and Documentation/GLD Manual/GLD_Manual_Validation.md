# Validation

## How is the harmonization checked?

The harmonization is checked thoroughly and continuously, to ensure the output is the most accurate and reliable. There are three main processes. Chronologically the first are the checks performed during the harmonization. As the code is developed, the harmonizers evaluate the results they are getting on an ongoing basis. Moreover, they try to confirm at early stages some of the more difficult mappings, like the conversion of survey education codes to the categories of the harmonized education variables. This process includes reaching out to colleagues in country offices and partners at the statistical offices to validate choices.

The second process are the automated quality checks, made up of a standard code that uses the harmonization as input and it for internal and external consistency, as well as checking a series over surveys over time. They are the main source of validation and are discussed further in detail in the remainder of the section.


The third process starts after the harmonization is published: the user feedback. GLD encourages users to review the harmonization and the codes and alert the team of any issues that may still have slipped previous processes. Users can raise issues on GitHub ([more on this in this section](link to the section)) or reach out to the GLD Focal Point. The GLD Team has set up code pipelines to try to update harmonizations to respond to user feedback as quickly as possible. Your feedback is an integral part of GLD!

## What are the automated quality checks? What do they do?

The automated quality checks are two sets of functions, one in `Stata` one in `R` to evaluate the output of the harmonization. The `Stata` code evaluates each survey individually, that is we check the particular “IND_2018_PLFS” harmonization for coherence and consistency, both internally (e.g., is the urban/rural variables only codes urban or rural; do people classified as professionals have, on average, the education level we expect them to have) and externally (is the labor force participation from the survey in line with ILO, WDI?).

## What do the automated quality checks do? How do I interpret the output?

To interpret the results, users should differentiate between errors and flags. By errors we mean things in the harmonization that can be evaluated and are seen as wrong. An example would be an observation with value `3` in the `urban` variable, when the only possible values are `0`, `1`, or `NA` if the information is not available. 

Flags are issues with the data that hint at an issue. For example, if the variable `urban` has a high share of missing (i.e., `NA`) answers. This is uncommon and thus points to an issue, but it need not be incorrect: the underlying raw data may have an issue and the data are truly not available. For such cases, it is advisable to include the issue in the Country Survey Details, but no further correction of the harmonization code would be warranted.

The quality checks do not specifically name issues as errors or flags. This is for the user to evaluate, based on what the checks do, which is covered in the next two subsections.
