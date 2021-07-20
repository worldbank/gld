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

## Mapping information


# Other details


<br></br>
![SCIAN Imperfect Matching](/Support/Country%20Survey%20Details/MEX/ENOE/images/scian_imperfect_match.PNG)
<br></br>




<br></br>
![SCIAN Reducation Logic](/Support/Country%20Survey%20Details/MEX/ENOE/images/reduced_scian_matching.PNG)
<br></br>

<br></br>
![SCIAN Matching Output](/Support/Country%20Survey%20Details/MEX/ENOE/images/example_concordance_output.PNG)
<br></br>