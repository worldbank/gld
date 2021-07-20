# Country and Survey Specific Details

The files in this folder cover further explanations and background information to better comprehend the harmonization of individual surveys, like the Mexican Encuesta Nacional de Ocupación y Empleo (ENOE) or the Philippines Labour Force Survey.  

The aim of GLD is that any harmonization code should be sufficient to understand the process of converting the raw data into the harmonized output. However, there are generally two cases where more information may be either helpful or necessary:

1. Background details unearthed during the harmonization and
2. Creation and use of additional data files in addition to raw data.

## Background details

As users (Jobs Group Team Members, consultants, or users of this repository) work on the harmonization, they unearth a lot of information about the survey and its context. This information is cast into the harmonization but further details may be helpful for users who wish to go deeper. 

An example of this would be the education information. As education policies in different countries are updated and curriculums are renewed, the structure and lenght of say primary and secondary education may change. The new class structure will be reflected in the answer codes of the questionnaires. Harmonizers who have studied the changes of the curriculum over time may be able to provide background information on how to better understand what primary and secondary education may mean over time, for example by pointing out that, in country X, prior to 2010 primary education was 5 years, secondary 7 and since then primary takes 6 years to complete, as does secondary. This kind of information is presented here, whenever relevant and possible.

## Additional files

The GLD, as stated above, aims to present a straight line from raw data to harmonization. However, in order to provide valuable information and complete the harmonization, it is sometimes necessary to add - and even create - supplementary data. The most common case for this is the conrrespondance between national and international classifications. 

The International Standard Industrial Classification of All Economic Activities ([ISIC](https://unstats.un.org/unsd/classifications/Econ/isic)) is an international standard for classifying the industry of a particular activity. It is published by the United Nations and is the international standard GLD harmonizes to. However, most countries have a national system to classify economic activity. Most often it will be based on ISIC, but this is not assured.

For example, Mexico uses the [North American Industry Classification System](http://en.www.inegi.org.mx/app/scian/) which has not direct correspondance with ISIC although official correspondance tables do exists that show how to match values. These correspondances are often imperfect (see image below of a Mexican example where one NAICS code matches five different ISIC codes) but can still be used to create an approximation to best map values from a national classification to the international standard.

<br></br>
![SCIAN Imperfect Matching](/Support/Country%20Survey%20Details/MEX/ENOE/images/scian_imperfect_match.PNG)
<br></br>

In order to provide users an understanding of how the correspondance was created, i.e., the additional file that is used for the harmonization, this country and survey specific information is stored here.

## Structure of the folder

The folder is structured in a two step fashion. The first step is the country, represented by the three letter country code. Inside the country, the survey acronym is used to identify the specific survey for which additional information is available to the user. In the Mexican example, further details about the Encuesta Nacional de Ocupación y Empleo can thus be found under `MEX/ENOE`.
