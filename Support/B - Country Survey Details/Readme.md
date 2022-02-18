# Country and Survey Specific Details

The files in this folder cover explanations and background information of the harmonization process of individual country surveys, such as the Mexican Encuesta Nacional de Ocupación y Empleo (ENOE) or the Philippines Labour Force Survey.  

The aim of the GLD Project is that one harmonized code suffices to guide the user through the translation process from raw data to harmonized output. However, there are two cases where more information may be either helpful or necessary:

1. Unknown background details unearthed during the harmonization and,
2. The creation and use of additional data files in addition to raw data.

## Background details

As users (Jobs Group Team Members, consultants, or users of this repository) work on the harmonization, they unearth survey details and additional information about its context. The project aimed at including all relevant pieces of information in the final outputs. Yet, users who wish to go deeper into country-specific survey details may find this section a good starting point. 

An example of this would be the education section. Governments update education policies and renew curriculums often. For instance, the changes may include shifts in the structure and length of primary and secondary education schemes. As a result, the national statistics officers will develop new codes with the new class structure, which will impact the national survey questionnaires. 

The harmonization team has studied the changes in the curriculum over time. Thus, they can provide background information to understand the characteristics of the education system structure. For example, before 2010, country "X"'s primary education lasted five years, while secondary education lasted seven. Ever since, primary education now takes up to six years to complete, as does secondary school. 

## Additional files

The GLD project wishes to harmonize industries across years using the ISIC classifications. The International Standard Industrial Classification of All Economic Activities ([ISIC](https://unstats.un.org/unsd/classifications/Econ/isic)) is an international standard for economic activities within industries published by the United Nations. However, most countries have a national system to classify economic activities, which often emulates ISIC. 

For example, Mexico uses the [North American Industry Classification System](http://en.www.inegi.org.mx/app/scian/) which has no direct link to ISIC. Although, the NSO built official comparison tables to match values. These tables are imperfect (see the image below about the mapping of NAICS to five different ISIC codes) but help map the values on the national classifications to the international standards.

<br></br>
![SCIAN Imperfect Matching](/Support/Country%20Survey%20Details/MEX/ENOE/utilities/scian_imperfect_match.png)
<br></br>

In this section, the team developed notes on the additional files, country, and survey-specific information used for the harmonization. The mentioned notes are stored here.

## Structure of the folder

The folder is structured in a two step fashion. The first step is the country, represented by the three letter country code. Inside the country, the survey acronym is used to identify the specific survey for which additional information is available to the user. In the Mexican example, further details about the Encuesta Nacional de Ocupación y Empleo can thus be found under `MEX/ENOE`.
