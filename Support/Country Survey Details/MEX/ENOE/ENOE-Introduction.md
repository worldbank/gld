Introduction to the Mexican Labour Force Survey (ENOE)
================

## What is the data?
The codes under the GLD/MEX folder contain harmonized data from 2005 to 2020 harmonize for the Mexican Labour Force and Unemployment Survey (ENOE).

## Where can the data be found?

The microdata is free and publicly available on the National Institute of Statistics and Geography (INEGI). INEGI created a [dedicated website](https://www.inegi.org.mx/programas/enoe/15ymas/#Microdatos) that records ENOE and all previous versions, besides it contains complete information to understand the framework of the ENOE.

## What is significance level?

The results are reported by gender and geographic location (urban or rural). At the national level the information is reported for "localidades", federative unite and autorepresented cities. Furthere details can be found in the dedicated sample design of each survey year [report](https://www.inegi.org.mx/app/biblioteca/ficha.html?upc=702825190613).

## Other Noteworthy Aspects

### The ENOE

ENOE or "Encuesta Nacional de Ocupación y Empleo" is a national
survey that records labor information from the Mexican population. The
Survey is conducted quarterly with two different questionnaires 
i.e., extended and basic versions. 

### Evolution of the ENOE questionnaires

In the past fifteen years, the Mexican national statistics institute
(INEGI) published five updates (Table 1) of the labor force questionnaire or
ENOE. The ENOE has two versions: the extended version and the basic
version. Every quarter, the INEGI conducts labor surveys using either
version.

Figure 1. Type of questionnaire used in ENOE
<br></br>
![](/Support/Country%20Survey%20Details/MEX/ENOE/utilities/ENOEversions.png)
<br></br>
Note.- Image taken from ["Conociendo la base de datos de la ENOE"](https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/doc/con_basedatos_proy2010.pdf) by INEGI

Table 1. ENOE questionnaire revision by year

| Year         | Version Q1                                                                                            |
| ------------ | ----------------------------------------------------------------------------------------------------- |
| 2005 to 2006 | [First Extended Version](https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/doc/c_amp_v1.pdf)  |
| 2007         | [First Basic Version](https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/doc/c_bas_v1.pdf)     |
| 2008         | [Second Basic Version](https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/doc/c_bas_v2.pdf)    |
| 2009         | [Second Extended Version](https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/doc/c_amp_v2.pdf) |
| 2010 to 2012 | [Third Extended Version](https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/doc/c_amp_v3.pdf)  |
| 2013 to 2015 | [Fourth Extended Version](https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/doc/c_amp_v4.pdf) |
| 2016 to 2020 | [Fifth Extended Version](https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/doc/c_amp_v5.pdf)  |

— [Author made. based on ENOE
Questionnaires](https://www.inegi.org.mx/programas/enoe/15ymas/)

### Information used in the GLD harmonization

Since ENOE reports quarterly results using different questionnaires, the 
harmonization team choose between annualizing quarterly results or choosing 
one quarter with mostly similar questionnaire questions. The fact that there 
is no unique questionnaire for the entire year introduces seasonality in 
the input, which could impact the process of data analysis for the user.

Annualizing data means that the results from extended and basic version 
questionnaires would merge which may cause lose of information. In table 2. 
the team summarized the list of absent topics in the extended and 
the basic questionnaire versions.

| Extended Version                                                                               | Basic Version                                                                                                                    |
| ---------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Questions about situation after losing a job and the length of unemployment or job inactivity. | Questions about migration and additional labor opportunities (second job).                                                       |
|                                                                                                | Questions on financial, social and economic support such as syndicate enrollment, public social welfare benefits, and insurance. |

— [Author made. based on ENOE
Questionnaires](https://www.inegi.org.mx/programas/enoe/15ymas/)

After analyzing the questionnaire versions, the team concluded that using 
quarterly questionnaires data reduces seasonality because INEGI collected quarter one 
data across the years using the extended version. The only exception 
is quarter one data for years 2007 and 2008.

The INEGI compiled comprehensive information on the questionnaires. For instance, methodology of the process for the most [recent version](https://www.inegi.org.mx/app/biblioteca/ficha.html?upc=702825190613), and [previous versions](https://www.inegi.org.mx/app/biblioteca/ficha.html?upc=702825190613). Similarly, the user can use the [interviewer manuals](https://www.inegi.org.mx/app/biblioteca/ficha.html?upc=702825006555) to follow the perspective of the surveyors in [the basic](https://www.inegi.org.mx/app/biblioteca/ficha.html?upc=702825006554) and other versions. 

Further information or questions about the microdata in this webpage can be directed to World Bank Jobs Group.
