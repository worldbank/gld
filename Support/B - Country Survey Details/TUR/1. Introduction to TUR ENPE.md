#

# Industry classification
The Tunisia ENPE uses the Nomenclature des Activitées Tunisiennes (NAT) to classify industries. However, the industry codes 
in the raw datasets use two-digit classification that does not align with the NAT, except for the 2001 survey, which only had the 
3 digit NAT codes available. We use the correspondence table below recreated from other years when both 
3 digit NAT codes and two-digit aggregated classification are available. 

| Code Range  | Description                    | English Translation                                |
|-------------|--------------------------------|----------------------------------------------------|
| 011 - 081   | 0. Ag/For/Fish                 | AGRICULTURE, HUNTING, AND FISHING                  |
| 111 - 191   | 10. Agro industry              | AGRICULTURAL AND FOOD INDUSTRIES                   |
| 211 - 222   | 20. ind.mat.cons.cer           | BUILDING MATERIALS, CERAMICS                       |
| 311 - 381   | 30. ind.meca.et elec           | MECHANICAL AND ELECTRICAL INDUSTRIES               |
| 412 - 452   | 40. ind. chimiques             | CHEMICAL INDUSTRY                                  |
| 511 - 553   | 50. ind text                   | TEXTILE AND CLOTHING INDUSTRY                      |
| 611 - 624   | 60. ind other man              | OTHER MANUFACTURING INDUSTRIES                     |
| 651 - 653   | 65. mines                      | MINES                                              |
| 661 - 663   | 66. extr raf pet/gaz           | OIL AND GAS EXTRACTION AND REFINING                |
| 671         | 67. prod/dis elec              | PRODUCTION AND DISTRIBUTION OF ELECTRICITY         |
| 681         | 68. prod/dis eau               | PRODUCTION AND DISTRIBUTION OF WATER               |
| 701 - 715   | 69. btp                        | BUILDING AND PUBLIC WORKS                          |
| 731 - 759   | 72. commerce                   | COMMERCE                                           |
| 771 - 780   | 76. services: trasn/telecom    | TRANSPORT; TELECOMMUNICATION                       |
| 801 - 812   | 79. services: hotel/rest       | HOTELS AND RESTAURANTS                             |
| 831 - 841   | 82. services: banques/insurance| BANKS AND INSURANCE                                |
| 861 - 885   | 85. services: act.imm.repar.se | REAL ESTATE, REPAIRS, SERVICES                     |
| 901 - 924   | 89. services: act. serv. soc. cul | SOCIAL AND CULTURAL SERVICES                      |
| 942 - 973   | 93. services: act. educ.sant.ad | EDUCATION, HEALTH, AND ADMINISTRATIVE SERVICES    |
| 982         | 98. services: act. extr. territ. | EXTRA-TERRITORIAL ACTIVITIES                      |
| 991         | 99. services: act. mal. designee | Not Applicable/Available (requires translation)   |
