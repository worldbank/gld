# Changes in industry and occupation classification

In most years, the Thailand LFS have adopted the ISIC and ISCO to classify the industries and occupations of the respondents. While Thailand has its industrial classification system with different versions over the years, it has maintained to use the ISIC not until 2011 when it began using the Thailand Industrial Classification (TSIC) for 2009. On the other hand, Thailand does not have a country-specific occupational classification system and has always used the ISCO for occupational codes.

The changes in the occupational and industrial classification systems have occurred at the same time. Between 1985 and 2000, Thailand LFS adopted the ISCO 1958 and ISIC version 1. Starting 2001, it adopted the ISCO 1988 and ISIC version 3. And in 2011, it began using the ISCO 2008 and the TSIC 2009. 

The ISCO 1958 is outdated and not compatible with the specifications of the occupational variables in the GLD. Nonetheless, it is possible to convert the ISCO 1958 to ISCO 1988 using a two-stage process. We first convert the ISCO 1958 to ISCO 1968 at the three-digit level since the ISCO team's correspondence table can only go up to 3 digits. The next stage involves converting the ISCO 1968 to ISCO 1988 following the correspondence table available in the ISCO website. Ultimately, the ISCO 1988 codes we derive are only up to 3 digits. 

An issue faced in the conversion process is the  many-to-many correspondence when mapping the ISCO 1968 codes with the ISCO 1988 at the three-digit level. In the example below, the code “0-23” can be mapped to two distinct three-digit ISCO 1988 codes (i.e., “213” and “214”). We select the ISCO 1988 code with the greater number of occurrences, which in this case is “214”. When the number of occurrences is equally split between two codes, the code that is lower in value is chosen. That is, if the frequency counts are split between “315” and “316”, “315” will be selected because 315 < 316. There is no logic to this and merely an arbitrary rule selection. 

![image](https://user-images.githubusercontent.com/76545296/176477588-1c59dedf-2aa8-4887-a294-8761160abfe5.png)
