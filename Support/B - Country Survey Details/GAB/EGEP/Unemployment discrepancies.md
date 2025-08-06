# Discrepancy in unemployment estimates in EGEP

Unemployment rates differ across sources because they apply different concepts. In GLD, we follow the ILO “strict” definition—looked for work in the past 30 days and available to start within the next two weeks, yielding an estimate of 11%. In contrast, the *national definition of unemployed* includes those that fit the ILO definition **and** the *"hidden" unemployed*, i.e., those who are discouraged due to lack of jobs or do not know how to look for work. Using this national definition of unemployment, we get an estimate of 21%. These estimates are close to unemplyoment estimates reported in the World Bank Poverty Assessment, which reports about 14% under the same ILO definition and 23% when including hidden unemployment. SSA POV, covering those looking in the past 30d ays, reports about 12%, close to the GLD estimate of ~14%.

The EGEP 2017 official report presents 26% while citing an ILO-consistent definition. We note the discrepancy relative to GLD and other sources but do not provide further interpretation here. See table below for a side-by-side reference.

| Source                     | Definition                                                      | UR estimate | Notes                                                              |
|---------------------------|------------------------------------------------------------------|-------------|--------------------------------------------------------------------|
| [WB Poverty Assessment](Utilities/Gabon-Poverty-Assessment.pdf)     | National definition (incl. hidden unemployment)                                   | 23%         | Estimate found in page 98; definition in page 97                   |
| [WB Poverty Assessment](Utilities/Gabon-Poverty-Assessment.pdf)     | Looking in the past 30 days and available within the next 2 weeks                                               | 14%         | Estimate found in page 98                                          |
| [EGEP 2017 Official Report](Utilities/02%20-%20RAPPORT_DE__SYNTHESE.pdf) | Looking in the past 30 days and available within the next 2 weeks| 26%         | Estimate found in page 100; definition of unemployed in page 98    |
| SSA POV data              | Looking in past 30 days                                          | 12%         |                                                                    |
| WB GLD data               | Looking in the past 30 days and available within the next 2 weeks| 10%         |                                                                    |
| WB GLD data               | Looking in past 30 days                                          | 14%       |          
| WB GLD data               | National definition (incl. hidden unemployment)                                         | 21%       |          |

## Coding for `lstatus` consistent with *ILO* definition of unemployment

```
gen byte lstatus = .
	
	* Employed: engaged in economic activity in past 7 days or absent
	replace lstatus = 1 if s04a_01_1==1 | s04a_01_2==1 | s04a_02_1==1 | s04a_02_2==1 | s04a_02_3==1 | s04a_02_4==1 | s04a_02_5==1 | s04a_03_1==1 | s04a_03_2 ==1 ///
	| s04a_03_3==1 | s04a_04==1 | s04a_05==1 | s04a_06==1

	* Unemployed: looked for work in past 7 or 30 days & available immediately or in the next 2 weeks (based on ILO standard)
	replace lstatus = 2 if (s04a_09 == 1 | s04a_10 == 1) &  inlist(s04a_12, 1,2)

	* Not in the labor force
	replace lstatus = 3 if missing(lstatus) & age >= minlaborage & !missing(s04a_00)
```

## Coding for `lstatus_alt` consistent with *national* definition of unemployment

```
	gen byte lstatus_alt = .
	
	* Employed: engaged in economic activity in past 7 days or absent
	replace lstatus_alt = 1 if s04a_01_1==1 | s04a_01_2==1 | s04a_02_1==1 | s04a_02_2==1 | s04a_02_3==1 | s04a_02_4==1 | s04a_02_5==1 | s04a_03_1==1 | s04a_03_2 ==1 ///
	| s04a_03_3==1 | s04a_04==1 | s04a_05==1 | s04a_06==1

	* Unemployed: looked for work in past 7 or 30 days
	replace lstatus_alt = 2 if (s04a_09 == 1 | s04a_10 == 1) & lstatus_alt != 1
	
	* Define hidden unemployed: those not know how to search for job and discouraged due to lack of opportunities
	replace lstatus_alt = 2 if inlist(s04a_11, 11, 12) & lstatus_alt != 1
	
	* Not in the labor force
	replace lstatus_alt = 3 if missing(lstatus_alt) & age >= minlaborage & !missing(s04a_00)
```

**Here is the breakdown by labor status using the ILO definition of unemployment:**

<img src="Utilities/waterfall.png" width="1200" height="600">

**Here is the breakdown by labor status using the national definition of unemployment:**

<img src="Utilities/waterfall_alt.png" width="1300" height="600">

