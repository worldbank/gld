# Overview to the GLD

## What is this document? What does it do? How is it structured?

This document is thought as a companion for the GLD user. It should work both as a primer for users new to GLD to understand it and as a reference book for experienced users to check processes and concepts. Finally, it is thought as a living document that ought to be updated as GLD progresses.

The next sub-section will give a run-through of the GLD process to provide an overview of how GLD works. Beyond it this manual is divided into five sections. The first covers how GLD information can be accessed. This includes not only what steps to take to access surveys but also how data and information are archived to know where to look for specific information in new surveys.

The second section covers the harmonization process. This is primarily made up of the discussion of the GLD data dictionary and the definition of every variable. It also discusses the harmonization processes as run by the GLD team, how to read a harmonization code, and what is not covered by the harmonization.

The third section concerns data validation. Describes how data is validated via the different quality checks (and how to read these) as well as checking with colleagues. Finally discusses how data are validated (continuously) after publishing a harmonization.

The fourth section instructs users how to best use the outputs of the GLD, from the “as-is” harmonization to piggybacking on the harmonization code and deviating to create a user-desired, customized harmonization.

The fifth section discusses how users can help improve GLD and make it an open collaboration vehicle. This goes from simply alerting the GLD team of errors in a harmonization to wholesale integration of a harmonization.

## Can you give a rundown of the GLD process?

First step is to obtain the raw data and the documentation as well as establishing the access rights to the data. Access rights can range from publicly accessible data (e.g., downloadable on the National Statistical Office – NSO – website) to restricted information (e.g., shared for a particular project, can only be used for it, nothing else). The documentation can come from the initial data share but is often expanded by checking microdata databases (e.g., ILO survey library) and through research done when harmonizing (e.g., looking for a national industry classification document when trying to code industry variables).

Once it is clear we have all the information to begin we create the relevant survey variables on our internal server. The folders follow the World Bank microdata archiving standard, consisting of a top folder of the type CCC_YYYY_\[SurveyName\], where CCC is the ISO three letter code for the country, YYYY the year of survey start (e.g., for a survey spanning from July 2017 to June 2018 YYYY is 2017), and [SurveyName] is the survey name (e.g., ENPE, LFS, …). Inside each is a folder for the raw data and one for the harmonized. [MORE: SEE RELEVANT SECTION].

The folder with the data is placed in the working folder for the person working on it so that, while assigned to them, it is accessible to all GLD harmonizers, to be able to access it, act on it even if the person is not working. The harmonizer in charge then will get to work and get acquainted with the survey and start harmonizing. Most often, during the harmonization process the harmonizer reaches out to either the NSO or country office colleagues (or both) to understand further details of the survey (e.g., how changes in administrative boundaries took place).  

Once the harmonizer has finished coding all possible variables for all years, they will run tow kinds of quality checks. 1) Within year checks that evaluate whether the survey is coherent with itself (correct variable definitions, sensible coding (most people with a professional occupation (doctors, lawyers) have above secondary education)) and with external data (e.g., compare the labor force participation (LFP) calculated from the harmonized data with that from WDI or ILOSTAT). 2) Across years checks that evaluate whether there are any unexpected jumps in the time series (e.g., LFP has an abrupt fall from one year to the next).

The results are discussed with the GLD focal point and case-by-case decisions are taken. For example, even if the harmonized data LFP is different from that of the WDI or ILOSTAT, the “divergent” information will be kept if the coding adheres to the GLD standard and is equal to the one reported by the NSO. An abrupt fall in the LFP may be warranted if a change in the definition of employment was introduced during the years covered.

Finally, the harmonizer will write the “Country Survey Details” (CSD). This represents meta information that cannot be coded into the data nor properly explained in the comments to the harmonization code. This may be notes on changes to the employment definition over time and how to potentially try to code by an older definition. The CSD starts with a document called “1. Introduction to [Survey Name]” for which there is a common template. Additional, more detailed information is covered by ad-hoc documents.

## Accessing GLD information (covers all: codes, documentation, etc.)

This section describes where GLD information is stored, how to access it and how information is organized.

## Where is the information stored?

Data, that is raw survey data, harmonization codes and outputted harmonized data, as well as survey documentation (questionnaires, reports) are stored on a dedicated server the Jobs Group controls. This includes both the finalized versions of the harmonization and the intermediate work as the teams harmonize data. 

The datalibweb team have access to the finalized GLD and thus information is automatically shared with datalibweb and made accessible with and through their system. Additionally, there is a GLD collection at the World Bank Microdata Library. 

Lastly, the contextual information on the survey (e.g., denoting changes to the currency or the administrative units over time) are stored, along with the harmonization codes, the data quality check codes, and any other software in the GLD ecosystem on the GLD GitHub repository. What GitHub is and how to interact with it is covered by the next point.

## What is GitHub? How do I interact with it? 

GitHub is a web-based platform that allows developers and programmers to store, manage, and collaborate on software projects. It is a central hub where people can upload, download, and work on code files, as well as track changes, report issues, and discuss ideas. GitHub is built on the Git version control system, which lets multiple people work on the same project simultaneously without overwriting each other's work.
The core feature of GitHub is the "repository," which is essentially an online folder that contains all the files and revision history for a particular software project. Users can create their own repositories to store their code, or contribute to existing repositories created by others. GitHub provides a user-friendly web interface, as well as desktop and mobile apps, to make it easy for people to access and manage their repositories.

When you interact with a GitHub repository, you have the ability to "clone" it, which creates a local copy on your own computer. From there, you can make changes, add new files, and commit those changes back to the central repository. GitHub also supports "branching," which allows multiple versions of a project to be developed in parallel. Users can then submit "pull requests" to propose incorporating their changes into the main branch of the project.

Beyond just code storage and version control, GitHub enables collaboration by allowing users to report bugs, suggest improvements, and discuss the direction of a project through the repository's online tools. This collaborative nature has made GitHub an essential platform for open-source software development, as well as a valuable resource for teams working on a project concurrently.

## How do I access GLD information, gain access to it?

Access to the GLD information depends on which source is being accessed to use and the precise access rights.

Directly on the GLD server there are two versions of the GLD. One is the finalized harmonization for all surveys, one the finalized harmonization for all server that are “for official use”, that is: that can be accessed by any World Bank staff member. Access to the folder containing the latter can be granted to any staff member (with a working World Bank email address and at least a virtual desktop). You may reach out to the GLD Focal point (gld@worldbank.org) to be granted access. Once granted you may [follow these instructions](link to the document with instructions) to map your computer to the network drive. 

Access to the full GLD is limited to the members of the Jobs Group. Specific access to files can be discussed on a case-by-case basis but would require reaching out to the GLD Focal Point.

Access through datalibweb is mediated through the datalibweb Stata package [link here](https://github.com/worldbank/datalibweb) and the intranet site [link here](http://datalibweb/). datalibweb is a data system specifically designed to enable users to access the most up to date versions of non-harmonized (original/raw) and harmonized datasets of different collections across Global Practices in the World Bank Group. 
Generally, datalibweb allows, on Stata, either a click-and-select option to obtain individual surveys or more programmatically access to various surveys using the function syntax. Before working on it, users need to accept the general disclaimer on the intranet site. For surveys not accessible directly on Stata, users may request access via the intranet site. Please review the datalibweb sites and reach out to the datalibweb team (datalibweb@worldbank.org) for more details.

Access to the World Bank Micro Data Library (MDL) requires access to the World Bank intranet. Note that there is the public library (microdata.worldbank.org) and the internal (microdatalib.worldbank.org). The GLD collection is only accessible on the latter [link here](https://microdatalib.worldbank.org/index.php/catalog/gld/?page=1&ps=15&repo=gld). Users only need to login and can use the navigation pane to find the individual surveys.

XXXXX Add a screenshot with boxes marking where to login, how the navigation pane looks like. XXXXX

The [GLD GitHub repository](https://github.com/worldbank/gld) is open to all users, both from the World Bank and external. All harmonization codes, CSD, and tools can be found here. More details on what GitHub is and how to interact with it are in [the relevant sub-section](link to it).

## In what format is the information I access?

Information can be broadly classified in three categories: raw and harmonized data, harmonization code, and other information. Raw data can be in any number of formats, depending on how it was published by the NSO or shared with the GLD team. Inside the GLD folder system

## When can I access information, when not?

Access to information generated by the GLD team on the GitHub repository is free and accessible at any moment. Access to the harmonized and raw data depends on the access rights of the raw data. While the GLD team endeavors to make them accessible to all, this cannot be assured.

Raw and harmonized data, even if in the public domain, can only be shared internally within the World Bank. Surveys not present on the public server (public here meaning: accessible to all staff) or not directly downloadable on datalibweb or on the Microdata Library are understood to be not accessible. Note that access rights might change over time (i.e., a survey which was restricted can be made open to all – and vice-versa). Please note that the introduction to the Country Survey Details of the survey should denote the nature of the data and thus access. It should also be updated if there are any changes.

## How do I obtain access for what is not accessible initially?

There are two routes to obtain access to GLD information that is not freely accessible to World Bank staff. On datalibweb, via the datalibweb intranet site you can select the surveys that are not public you wish to access. This has the added advantage that a user can request access for others while making theirs. For access to the server you may contact the GLD focal point (gld@worldbank.org). Access to the surveys on the Microdata Library are limited via the restrictions imposed on the site. There is no direct redress option unless one is specifically stated in the survey entry.

## How is the information I access organized?

Information for the Global Labor Database’s files and folders follows the structure used by the Microdata library. The original document is [accessible under the Guides and Documentation section](https://github.com/worldbank/gld/blob/main/Support/A%20-%20Guides%20and%20Documentation/WB%20Microdata%20Lib%20Folder%20and%20File%20Naming%20Management.docx). That document goes into finer detail and is a good read. This document exemplifies how this is implemented in the case of the Brazilian Continuous Household Survey (PNADC) for 2019.

The overall folder structure for this survey should look like shown in nested list below. This means, within the overall survey folder (BRA_2019_PNADC) we find three folders at the same level. The first is the survey itself (name only includes the version numbering for the “Master” data), while the other two are for the “Adaptions” with their version number and the code for what kind of adaption (or harmonization) was chosen.

Note that the survey description always follows the structure CCC_YYYY_SurveyName, where CCC is the [ISO Alpha-3 country code](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3), YYYY the year of survey start, and SurveyName the name or acronym of the survey. It can contain both letters and numbers. If words need to be separated this is done via a dash (“-“) to ensure all blocks are separated via underscores (“_”).

* BRA_2019_PNADC
  * BRA_2019_PNADC_V01_M
    * Data
      * Original
      * Stata
    * Doc
      * Questionnaires
      * Technical
    * Programs
  * BRA_2019_PNADC_V01_M_V01_A_GLD
    * Data
      * Harmonized
      * [Additional Data]
    * Doc
      * Questionnaires
      * Technical
    * Programs
    * Work
  * BRA_2019_PNADC_V01_M_V02_A_GLD
    * \[ ::Same as for V01_A:: \]

Inside the master data folder there are three folders: Data, Doc, and Programs. Data itself is divided into Original and Stata. The former contains all files as downloaded if the original download is not in Stata format (i.e., not a .dta file), the latter contains the Stata survey microdata.

Any code changing the raw data is stored in the *Programs* folder. For example, code converting raw data from other formats to dta, that is, reading from *Data/Original*, converting it, and storing it in *Data/Stata*, would be stored under *Programs*.

The last folder, *Doc*, contains all further documentation that is needed to work on the survey. It should be divided into two further folders: *Questionnaires*, containing the questionnaires and all other necessary document to understand the questionnaire and its flow; and *Technical*, containing all other technical information (e.g., reports, national occupation classifications, etc.).

As a best practice, it is advised to leave in the *doc* folder a small Readme file (commonly titled “Where is this data from – ReadMe.txt”) to give information about where the source material is from. This is important for future colleagues, so they can trace information establish the access policy.

The structure for each of the harmonization folders is roughly the same, only with added version numbering and collection name (GLD). The *Data/Harmonized* folder shall contain the harmonized output in ‘.dta’ form (in this case BRA_2019_PNADC_V01_M_V##_A_GLD.dta). The *Data/Additional Data* folder is an optional contains data not in the raw data that is needed to create the harmonization. For example, if the conversion of the national industry classification to the international version is done via merging in an extra file, this file would be placed under *Data/Additional Data*. If no such files were used the folder need not exist.
The harmonization code (i.e., the code that takes the *Data/Stata* input from the master folder system and saves output in *Data/Harmonized*) is stored in the Programs folder (and in this case would be BRA_2019_PNADC_v01_M_v01_A_\[###\].do).

The *Doc* folder contains any other documentation necessary to describe and understand the survey. Note this is the same content as in ‘BRA_2019_PNADC_v01_M/Doc’ in the example above. Content should be in both at the same time – a small price on duplication we believe is worth for ease of finding for the user.

The *Work* folder contains any output created during the harmonization that is not the final harmonization. For example, if you needed to create a subfile of the survey containing only households from a certain region for inspection or any other process you may need during your work, these outputs should be stored here. *Data/Harmonized* should only contain finalized files, here you may store any intermediate results.

The organization of the information on GitHub follows a similar, yet different pattern. On the landing page there are two relevant folders where information is contained: *GLD* and *Support*. The former contains the harmonization codes for the GLD surveys while the latter contains all additional information to understand and leverage both the GLD surveys and the GLD ecosystem. The other folders contain information to make the repository work and are not further discussed here.

[ IMAGE of the landing site with the two folders highlighted  ]

The *GLD* folder follows the logic described above, with a `CCC/CCC_YYYY_Survey-Name/CCC …` structure. The only difference is that it only contains the harmonized folder (i.e., `_V##_M_V##_A_GLD`) and in there only the *Programs* folder.

The *Support* folder has six subfolders. Subfolder *A – Guides and Documentation* contains individual documents that explain the functioning and rules of GLD. In part they are constituents of this manual (i.e., the information in them is also here) but are kept separate for easier sharing. For example, the next section will explain all the variables in GLD, but the data dictionary is available there as a standalone document for ease of review and sharing. In part these are documents referenced in this manual (e.g., the World Bank Micro Data Library folder and file naming convention).

The subfolder *B – Country Survey Details* contains the metainformation on surveys that cannot be coded into the harmonization or the harmonization code – or need more explaining to be understood. The structure of the folder starts with the three-letter code of the country, within which are the surveys, listed by their name or initials (e.g., LFS, ENE, SAKERNAS). Inside each survey folder there should always be at least one element: the introduction file. All other files and folders are optional and depend on the situation. Below and example of this structure.

* B – Country Survey Details
  * CCA
    * Survey-1
      * 1. Introduction to CCA Survey-1.md
      * \[Other_issue_in_detail.md\]
      * \[utilities\]
    * Survey-2
  * CCB
    * Survey

The introduction file starts with “1.” as GitHub orders files alphanumerically and this file should be at the top always. It should always read as Introduction to CCC (or country name) survey. It contains the basic information every user should read before starting work on a survey. The first part is standardized and is the same for all surveys – further down the template for this document is introduced. The standardized part informs the user of what the survey is, where the information is from (and if public, where to get it), what the sampling procedure was and to what geographic level the information is statistically significant. The latter part called “Other noteworthy aspects” allows the harmonizers to expand on non-standard issues that are of relevance to that particular survey in that specific country.

If the introduction contains images or references some document, these are stored in the *utilities* folder, a sort of catch-all for the survey. Similarly, if a topic requires more in-depth discussion, it will be referenced in the introduction, but then discussed in detail in a separated file (e.g., how to deal with a break in the definition of employment over a series). Any images or documents referenced here should also be stored in the utilities folder.

The subfolder *C - Templates* contains the GLD templates. Currently, there are three. The harmonization code template, the code to create new GLD structured folders, and the template for the CSD introduction. These should allow new harmonizers to create new harmonizations using the same structures.

The subfolder *D – Q Checks* contains the GLD quality checks. There are two types of checks. The checks to be done to each survey (e.g., the 2019 Indian PLFS) and the checks to be done (once all are ready) to a series of years of surveys (e.g., years 2017 to 2022 of the Indian PLFS). The former are in the *Single survey checks* folder, while the latter are in the *Survey series checks* folder. The details of how the checks work is contained in the [Validation section](link to it).

The subfolder *E – Community Guidelines* contains the guidelines to interact with the GLD team on GitHub. This refers to the conduct we expect from users as well as checklists to ensure any action is as impactful as possible. Further details of how interact with the team are contained in the [Improving GLD section]( Link to it ).