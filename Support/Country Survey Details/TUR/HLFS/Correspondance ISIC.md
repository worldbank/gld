
# Correspondence between NACE-EU and ISIC

Information regarding the industry respondents are employed and is coded in the Turkish Household Labour Force Survey (HLFS) using the codes of the [Statistical Classification of Economic Activities in the European Community](https://ec.europa.eu/eurostat/ramon/nomenclatures/index.cfm?TargetUrl=LST_NOM_DTL&StrNom=NACE_REV2&StrLanguageCode=EN&IntPcKey=&StrLayoutCode=HIERARCHIC) (shortened as NACE). 

## Data as present in survey raw data

The image below shows the answers to the relevant question (`s33kod` asks for the economic activity of the local unit in which persons worked) of the 2010 survey :

<br></br>
![s33kod](/Support/Country%20Survey%20Details/TUR/HLFS/Utilities/s33kod.png)
<br></br>

The information is at the two digit level (length of `s33kod` has to be 4), while NACE is structured at a 4 digit level with the first year being a letter and not a number. Secondly, in some cases the information is only at the two-digit level.  If the information is insufficient to make a four-digit classification a higher level classification is done and the two-digit coded is padded with a zero so that all answers hace the same length. Note finally that the shown 14 codes cover 50% of all answers.

## Correspondance information available



## Creating a map between NAICS and ISIC

### Overall mapping logic



### Generating the `R` code and resulting `.dta` file


### Merging the correspondence with the survey data



## Caveats and extensions

### Caveat - What the mapping does and does not do

