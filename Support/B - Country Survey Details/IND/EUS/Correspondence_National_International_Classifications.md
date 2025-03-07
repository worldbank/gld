# Correspondences between national and international classifications

This document describes the methodology used to map information on occupation coded in the survey per the national classification schemes to the international ISIC and ISCO codes. The table below gives an overview of the different national classifications used in the surveys and the international ISIC and ISCO versions they were mapped to.

| Year of survey	| NCO version	| ISCO version	| NIC version	| ISIC version	|
| :----:		    | :----:	    | :----:	    | :----:	    | :----:	|
| 1983			    | NCO 1968	    | ISCO-88	    | NIC 1970	    | ISIC-2	|
| 1987			    | NCO 1968	    | ISCO-88	    | NIC 1970	    | ISIC-2	|
| 1993			    | NCO 1968	    | ISCO-88	    | NIC 1987	    | ISIC-2	|
| 1999			    | NCO 1968	    | ISCO-88	    | NIC 1998	    | ISIC-3	|
| 2004			    | NCO 1968	    | ISCO-88	    | NIC 1998	    | ISIC-3	|
| 2005			    | NCO 1968	    | ISCO-88	    | NIC 2004	    | ISIC-3.1	|
| 2007			    | NCO 2004	    | ISCO-88	    | NIC 2004	    | ISIC-3.1	|
| 2009			    | NCO 2004	    | ISCO-88	    | NIC 2004	    | ISIC-3.1	|
| 2011			    | NCO 2004	    | ISCO-88	    | NIC 2008	    | ISIC-4	|

## Correspondence in occupation classification

The occupation is classified in the EUS using two different code structures. The 1983 through 2005 surveys use the 1968 National Classification of occupations while the latter three surveys from 2007 to 2011 use the 2004 version. In all cases occupation is recorded at the three-digit level.

The harmonization team could not find any correspondence tables on the official website of the Ministry of Statistics and Programme Implementation (MOSPI). Hence the method used was to rely on the correspondence develop by Mses. Saloni Khurana and Kanika Mahajan in their [technical appendix](utilities/NCO_concordance.pdf) to their paper [Evolution of wage inequality in India (1983-2017)](utilities/wp2020-167.pdf). The harmonization team is thankful to them for their research and kindness in sharing their work.

The technical appendix consists of two tables. The first is the concordance between NCO 1968 and NCO 2004. The second details the concordance between NCO 2004 and ISCO-88. The PDF we [convert into an Excel file](utilities/occupation_correspondences.xlsx). For surveys with NCO 1968 coding, the codes are first translated to NCO 2004 codes, then subsequently to ISCO-88 ones. For years with NCO 2004 classification, these codes are directly mapped to the corresponding ISCO-88 codes. Both steps are [performed by this R code](utilities/convert_occup_concordance_to_dta.R) which produces the two `dta` files used in the harmonization code: [India_occup_correspondences.dta](utilities/Additional%20Data/India_occup_correspondences.dta) for the conversion from NCO 1968 to ISCO-88 and [India_nco_04_to_isco_88.dta](utilities/Additional%20Data/India_nco_04_to_isco_88.dta) to convert in the later years from NCO 2004 directly to ISCO-88.

### Correspondence in industry classification

The industry classification in the EUS uses five different classification systems. Codes for the 1983 and 1993 surveys (NIC 1970 and NCI 1987 respectively) are recorded at three-digit level while subsequent surveys are recorded at five-digit level.

From the NIC 1998 version onwards (used in the 1999 survey), the Indian National Industry Classification is based in toto on the corresponding latest ISIC version at the time, adding a fifth digit to extend the coding to accommodate all previous NIC 1987 codes. Hence from the 1999 survey onwards, the ISIC codes can be generated by extracting the first four digits of the Indian NIC code.

For NIC 1970, the [MOSPI site on NIC 1987](http://mospi.nic.in/classification/national-industrial-classification/national-industrial-classification-1987) has two annex documents. The [first document](utilities/annexure_1_NIC1987.pdf) is the concordance between NIC 1970 and NIC 1987. The [second document](utilities/annexure_2_NIC1987.pdf) is the correspondence from NIC 1987 to ISIC-2 (referred to here as ISIC 1968).

The first document is used to translate 1970 codes to 1987 codes, then the second concordance table is used to create the ISIC-2 codes. For 1987, the second concordance table is used directly to create the codes.

The mapping of codes for 1970 is done in two steps: first the 1970 codes are translated into 1987 codes using the first document mentioned above. Since there are very few changes this is done in the harmonization code itself.

The second step is to map from NIC 1987 to ISIC-2. The aforementioned second document was manually [transcribed into an Excel file](utilities/nic_87_to_isic_68.xlsx) and [converted into a Stata file](utilities/nic87_to_isic2.dta). This file is merged in to convert the codes from the national classification to the international version.

For the 1993 EUS only the second step is necessary, as the information is already coded as NIC 1987.
