# Discrepancy in unemployment estimates in EGEP

Unemployment rates differ across sources because they apply different concepts. In GLD, we follow the ILO “strict” definition—looked for work in the past 30 days and available to start within the next two weeks, yielding an estimate of 11%. The World Bank Poverty Assessment reports about 14% under the same ILO definition and 23% when including hidden unemployment, i.e., people not currently searching but willing to take a job. SSA POV, which uses a search-only variant, reports about 12%, close to the GLD estimate of ~14%.

On identifying hidden unemployed,  the EGEP questionnaire does not include a direct item to identify them. One could approximate it using “reasons for not being in the labor force,” but we did not implement that derivation here.

The EGEP 2017 official report presents 26% while citing an ILO-consistent definition. We note the discrepancy relative to GLD and other sources but do not provide further interpretation here. See table below for a side-by-side reference.

| Source                     | Definition                                                      | UR estimate | Notes                                                              |
|---------------------------|------------------------------------------------------------------|-------------|--------------------------------------------------------------------|
| [WB Poverty Assessment](Utilities/Gabon-Poverty-Assessment.pdf)     | Including hidden unemployment                                    | 23%         | Estimate found in page 98; definition in page 97                   |
| [WB Poverty Assessment](Utilities/Gabon-Poverty-Assessment.pdf)     | Looking in the past 30 days and available within the next 2 weeks                                               | 14%         | Estimate found in page 98                                          |
| [EGEP 2017 Official Report](Utilities/02%20-%20RAPPORT_DE__SYNTHESE.pdf) | Looking in the past 30 days and available within the next 2 weeks| 26%         | Estimate found in page 100; definition of unemployed in page 98    |
| SSA POV data              | Looking in past 30 days                                          | 12%         |                                                                    |
| WB GLD data               | Looking in the past 30 days and available within the next 2 weeks| 11%         |                                                                    |
| WB GLD data               | Looking in past 30 days                                          | 14.0%       |          |

We have derived the unemployed as follows:


