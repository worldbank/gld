# Correspondence between NAICS Mexico and ISIC

Information regarding the industry respondents are employed in is coded in the Encuesta Nacional de Ocupación y Empleo (ENOE) using the codes of the [North American Industry Classification System](http://en.www.inegi.org.mx/app/scian/) (shortened as NAICS in English and SCIAN in Spanish). 

## Data as present in survey raw data

The image below shows the answers to the relevant question (`p4a1` asks for the industry the company the respondent works for is in) for the dataset from the first quarter of 2010:

<br></br>
![SCIAN ENOE example](/Support/Country%20Survey%20Details/MEX/ENOE/images/scian_example_2010.PNG)
<br></br>

There are two things to note here. The first is that the information is at the four digit level (length of `p4a` is always 4), while NAICS is structured as a 6 digit system. Secondly, in some cases the information is only at the three-digit level. This is when the last digit is a zero (see higlighted cases above). The questionnaire allows respondents to describe their industry and this description is later converted into a code by the enumerators. If the information is insufficient to make a four-digit classification a higher level classification is done and the three-digit coded is padded with a zero so that all answers hace the same length. Note finally that the shown 14 codes cover 50% of all answers.

## Correspondance information available

The Mexican Statistics Institute INEGI has [website dedicated to NAICS](https://www.inegi.org.mx/app/scian/) where it stores general information in the classificaiton and - most importantly for concordance purposes -  comparative tables between the different NAICS versions and the different ISCO versions. The image below shows the available comparisons in July 2021:  

<br></br>
![SCIAN available options](/Support/Country%20Survey%20Details/MEX/ENOE/images/scian_options.PNG)
<br></br>

Of importance for the years covered by GLD (2005 to 2020) are the four classifications highlighted. Of the four, the latter three are mapped to ISIC Revision 4 while the earliest (NAICS 2002) is mapped to ISIC Revision 3.1.

The information is available as both a PDF and an Excel File. The image below shows the first lines of the first sheet of the 2007 to ISIC 4 Excel document:

<br></br>
![SCIAN Excel example](/Support/Country%20Survey%20Details/MEX/ENOE/images/scian_07_example_xlsx.PNG)
<br></br>

Note how the first sheet contains the NAICS to ISIC mapping, while the second sheet maps the inverse relation. Note further that NAICS codes are all at 6 digit level in the comparison tables provided by the National Statistics Office (NSO) while the ISIC code is just at 4 digits.

The last piece of information to understand before proceeding with creating a mapping `.dta` that can be used in the harmonization is the fact that mapping is not perfect in the correspondence tables provided by the NSO. In the above image this is the case (e.g., 111121 maps to 0111) but this is not always so. The image below shows how NAICS code 111410 maps to five (!) different and distinct ISIC codes.

<br></br>
![SCIAN Imperfect Matching](/Support/Country%20Survey%20Details/MEX/ENOE/images/scian_imperfect_match.PNG)
<br></br>

## Creating a map between NAICS and ISIC

### Overall mapping logic

The overall mapping is done in two steps. The first step is to create an `R` code that reads in the Excel file from the NSO, cleans it (note in the image how there are empty lines between two NAICS codes) and equates four-digit NAICS codes (since information in ENOE is at four-digits, as shown at the top) to an ISIC code. The code generates a `.dta` file that lists all possible unique NAICS codes and provides the corresponding ISIC code.

The second step is to use the `.dta` created in the first step in the harmonization. That is to merge in the correspondance table when harmonizing and use matched ISIC codes to generate the GLD `industrycat_isic` variable.

### Generating the `R` code and resulting `.dta` file

The mapping of NAICS to ISIC codes is performed by a user written `R` code. It reads from the relevant NSO correpsondence Excel file (NAICS 2002, 2007, 2013, and 2018) stored under `MEX_[YYYY]_ENOE\MEX_[YYYY]_ENOE_v01_M\Doc` and writes the comparison `.dta` file merged in the harmonization under `MEX_[YYYY]_ENOE\MEX_[YYYY]_ENOE_v01_M\Data\Stata`. The corresponding `R` itself is stored under `MEX_[YYYY]_ENOE\MEX_[YYYY]_ENOE_v01_M\Programs`. Note that the actual files are stored on a World Bank server - this repository only tracks code files.

The first step in the process is to reduce the NSO correspondece six-digit system to the four digits covered in the ENOE. This creates duplicates as there are 17 codes between `111110` and `111199` for NAICS-07 that are reduced to `1111`. (The examples in this explainer are based on the NAICS-07 to ISIC 4 conversion as well as the ENOE 2010 data, the logic however holds for all correspondences).

The second step is to compare the correspondence of NAICS four-digit codes to ISIC four-digit codes, and count the number of total cases and the number of matches to each code. The image below shows this process for some of the first codes:

<br></br>
![SCIAN Reducation Logic](/Support/Country%20Survey%20Details/MEX/ENOE/images/scian_07_2010_match_1.PNG)
<br></br>

The table shows  that of the 16 codes that start with `1111` all of them match to ISIC code `0111`, while one matches to `0112`. The 9 NAICS codes that start with `1112` match to three different ISIC four digit codes. However, further down, codes starting with `1121` and `1122` all match to one specific four-digit ISIC code - perfect matches.At this stage, only perfect matches are kept. All other matches (i.e., those like `1111` and `1112`) are sent to the third step.

The third step matches each four-digit NAICS code at the three-digit level to the three digit ISIC equivalent. This is exemplified in the snapshot below:

<br></br>
![SCIAN Reducation Logic](/Support/Country%20Survey%20Details/MEX/ENOE/images/scian_match_2_df_example.PNG)
<br></br>

At this level, all 17 NAICS codes starting with `1111` map to an ISIC code starting with `011` (i.e., `pct` value is 100). Now we have a perfect match for it as well. For NAICS codes starting with `1112` there is no such perfect match. 8 out of 9 map to ISIC codes starting with `011` but one maps to `0112`. Again we only keep perfect matches. Also, the next step may seem already clear, that is, to map the four-digit NAICS code to ISIC two-digit codes. It is clear from the above image that this will yield a perfect match for `1112` as both start with `01`.

Hence, the fourth step comparres NAICS four-digit to ISIC two-digit. 

<br></br>
![SCIAN Reducation Logic](/Support/Country%20Survey%20Details/MEX/ENOE/images/scian_match_3_df_example.PNG)
<br></br>

### Merging in the information

Previously, codes 
## Caveats and extensions

### Caveat - What the mapping does and does not do

### Extension - What you may add if you would be available







<br></br>
![SCIAN Matching Output](/Support/Country%20Survey%20Details/MEX/ENOE/images/example_concordance_output.PNG)
<br></br>
