---
layout: default
title: Obtain raw data
parent: Harmonization Process
nav_order: 1
---

# Obtain and store raw data and information

All raw data should be on the World Bank’s dedicated GLD server (wbntpcifs), from which harmonizers should have at least read rights. A description of how to map servers on Windows [can be found here on the repository](https://github.com/worldbank/gld/blob/main/Support/Guides%20and%20Documentation/How%20Map%20Network%20Server.docx). If you do not have access to the server (i.e., you are not allowed to map the server) please get in touch with the [GLD Focal Point](mailto:gld@worldbank.org).

The data should be placed under the pertinent folder, survey, and version folder (see the rules on the [folder and file structure here](https://github.com/worldbank/gld/blob/main/Support/Guides%20and%20Documentation/For%20context%20-%20Microdata%20Library%20Folder%20and%20File%20Naming%20Management.docx)), under *Data/Original* for any original data in non-Stata format and *Data/Stata* for data either originally in Stata or converted into it from the original raw data.

Under the *Doc* folder you should find (and place) all the documents necessary to understand the survey (e.g., questionnaires, methodology description, reports, …). Under *Programs* you should place any code used to amend or create source data. For example, if the original data is in non-Stata format, the program used to convert it from that format into Stata (which itself need not be Stata code) should be stored here. 

Another example would be the program to make a certain classification scheme readable in Stata. For instance, the survey data codifying occupations in country X uses the national classification scheme. You have a document (in CSV, PDF, or other format) describing the correspondence between this scheme and the international ISCO scheme, which is the one we wish to harmonize to. Any code used to convert the document (which should be in the *Doc* folder) into a `.dta` file (stored in *Data/Stata*) should be stored as well under *Programs*.