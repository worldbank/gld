# Weights and PSA Checks

Lightweight manual checks to ensure that final appended weight variables and Labor Force Participation measures align with figures in PSA publications.

## Expanded Population

This table gives the expanded population for the appended, four-round dataset for the entire year. It should generally reflect the population of the Philippines at that time.

+--------+----------------------+
| Year   | Expanded Population  |
+========+======================+
| 1997   |                      |
+--------+----------------------+
| 1998   |                      |
+--------+----------------------+
| 1999   |                      |
+--------+----------------------+
| 2000   |                      |
+--------+----------------------+
| 2001   |                      |
+--------+----------------------+
| 2002   |                      |
+--------+----------------------+
| 2003   |                      |
+--------+----------------------+
| 2004   |                      |
+--------+----------------------+
| 2005   |                      |
+--------+----------------------+
| 2006   |                      |
+--------+----------------------+
| 2007   |                      |
+--------+----------------------+
| 2008   |                      |
+--------+----------------------+
| 2009   |                      |
+--------+----------------------+
| 2010   |                      |
+--------+----------------------+
| 2011   |                      |
+--------+----------------------+
| 2012   |                      |
+--------+----------------------+
| 2013   |                      |
+--------+----------------------+
| 2014   |                      |
+--------+----------------------+
| 2015   |                      |
+--------+----------------------+
| 2016   |                      |
+--------+----------------------+
| 2017   |                      |
+--------+----------------------+
| 2018   |                      |
+--------+----------------------+
| 2019   |                      |
+--------+----------------------+

## Labor Force Participation

This table gives select year-round labor force participation figures from our final datasets and from the PSA's publication. Note that only relevant observations were included in our datasets for analysis -- e.g., only Janurary/round 1 observations when comparing to the PSA's January publication for that year. Labor Force Participation includes the percent of observations who report as employed or unemployed; it excludes those who are not in the labor force.

The I2D2 Figures can be obtained on any final year dataset with the following command in Stata

```{stata}
tab lstatus [aw=wgt]            ///
	  if  age     >= lb_mod_age  ///
	  &   month   == 4          // substitute the correct numerical month (1-12)
```

+--------+-------------------+-------------+--------------+
| Year   | Round/Month       | I2D2 Figure | PSA Figure   |
+========+===================+:===========:+:============:+
| 1997   | (round 2) April   | 66.96       | 68.8         |
+--------+-------------------+-------------+--------------+
| 2003   | (round 2) April   | 67.13       | 67.1         |
+--------+-------------------+-------------+--------------+
| 2005   | (round 4) October | 64.77       | 64.8         |
+--------+-------------------+-------------+--------------+
| 2008   | (round 3) July    | 64.25       | 64.3         |
+--------+-------------------+-------------+--------------+
| 2009   | (round 4) October | 63.98       | 64.0         |
+--------+-------------------+-------------+--------------+
| 2012   | (round 1) January | 64.12       | 64.2         |
+--------+-------------------+-------------+--------------+
| 2013   | (round 1) January | 64.08       | 64.1         |
+--------+-------------------+-------------+--------------+
| 2014   | (round 2) April   | 65.21       | 65.2         |
+--------+-------------------+-------------+--------------+

: Source: Philippine Statistics Authority Integrated Survey of Household Bulletins
