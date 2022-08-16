 # For users of the DANE public microdata 
 
The user should follow the recommendations below to assemble the [microdata](https://microdatos.dane.gov.co/catalog/MICRODATOS/about_collection/23/?per_page=5) used with the do files on this page, 

1. The microdata for the GEIH is available in various formats such as .stata, .txt, .sav and .csv. The data has a monthly frequency (From January to December). However, the user could find that not all formats are available for every month. For instance, in [2017](https://microdatos.dane.gov.co//catalog/458/get_microdata), the data for the first few months of the year is available in .sav, .txt and .csv formats; while for the same year, the data for the months of october through december is available in .stata, .txt and .csv formats.

2. For the WBG users, the harmonization team prepared do files that pre-process the monthly data into one file, please check the following [link](https://github.com/worldbank/gld/blob/015c30b7fc304de7db57da1f78732b17952286e0/Support/B%20-%20Country%20Survey%20Details/COL/GEIH/utilities/convert_sav_2_dta.do) for a sample, if you help with this please contact the email on the bottom of this page.

3. Migration data is accessible online as a separate monthly datasets that need to be assembled and merged to the general GEIH data. In the GLD harmonization we have proposed a process for merging the migration data to the working file.

4. Generally, the creation of household and individual ID codes never uses the variable denoting the month during which the survey took place. In the do-files from 2009, 2011 and 2020, the harmonization team included a longer process which does include month information against ID values to recognize duplicates. That is, there are different household that erroneously have the same household ID. Since the interviews took place at different points in time, the month variable is necessary to split these false duplicates.

5. The data for  "Amazonia & Orinoquía" and the City of "San Andrés" had been included separate from the rest. Yet, the codes to merge monthly to annual data followed for all years have been the same as with the main GEIH files. File locations for the unified files are available in the harmonized do-files.

Please note that the GLD programs folder is only available for authorized users within the World Bank. for further questions and requests kindly contact gld@worldbank.org.





