# Occupation comparability in COD E123

The GLD `occup` variable is available in the 2004 and 2012 COD E123 harmonized files, but users should be cautious when comparing agricultural and elementary occupations across rounds. The main issue is not that agricultural employment disappears between rounds. Rather, similar agricultural work appears to be classified under different occupation groups in the two rounds.

Among employed persons with non-missing occupation, the weighted share coded as elementary occupations is much higher in 2004, while the weighted share coded as skilled agricultural work is much higher in 2012. The broad industry distribution is more stable: agriculture remains the largest industry category in both rounds.

| Variable/category | 2004 weighted share | 2012 weighted share |
|---|---:|---:|
| `occup` = Skilled agricultural | 8.45% | 58.51% |
| `occup` = Elementary occupations | 66.47% | 10.50% |
| `industrycat10` = Agriculture | 71.50% | 64.82% |

This difference is driven by a small number of detailed occupation codes. In 2004, most agricultural workers are coded to ISCO 921/9210, which maps to elementary occupations. In 2012, the dominant agricultural occupation codes are ISCO 621/6210 and 611/6110, which map to skilled agricultural occupations.

| Detailed occupation code | Description | 2004 weighted share of employed | 2012 weighted share of employed |
|---|---|---:|---:|
| 921/9210 | Agricultural, fishery and related labourers | 62.94% | 6.97% |
| 621/6210 | Subsistence agricultural and fishery workers | 3.06% | 38.57% |
| 611/6110 | Market gardeners and crop growers | 4.41% | 17.88% |

For this reason, changes over time in `occup` categories 6 and 9 should not be interpreted mechanically as a real shift from elementary to skilled agricultural occupations. For broad analysis of agricultural employment across the 2004 and 2012 rounds, `industrycat10` is likely to provide a more stable comparison than `occup`.
