Geographic Administrative Levels
================

-   [Weights and PSA Checks](#weights-and-psa-checks)
    -   [Weight Variables](#weight-variables)
    -   [Expanded Population + Labor Force Participation by Year](#expanded-population--labor-force-participation-by-year)
    -   [Labor Force Participation](#labor-force-participation)

# Weights and PSA Checks

Lightweight manual checks to ensure that final appended weight variables and Labor Force Participation measures align with figures in PSA
publications.

## Weight Variables

This table clarifies the raw weight variable that is used in GLD in order to emulate the closest results possible to those from the PSA. Year years 1998-2001 only include one data file. All raw weight variables are appended into `wgt` in the GLD final dataset.

| Year | January    | April      | July       | October    |
|------|------------|------------|------------|------------|
| 1997 | rfadj      | rfadj      | rfadj      | rfadj      |
| 1998 | rfadj      | .          | .          | .          |
| 1999 | rfadj      | .          | .          | .          |
| 2000 | rfadj      | .          | .          | .          |
| 2001 | rfadj      | .          | .          | .          |
| 2002 | rfadj      | rfadj      | rfadj      | rfadj      |
| 2003 | rfadj      | rfadj      | cfwgt      | cfwgt      |
| 2004 | fwgt       | fwgt       | fwgt       | cfwgt      |
| 2005 | fwgt       | fwgt       | fwgt       | fwgt       |
| 2006 | fwgt       | fwgt       | cfwgt      | cfwgt      |
| 2007 | fwgt       | fwgt       | fwgt       | fwgt       |
| 2008 | fwgt       | fwgt       | fwgt       | fwgt       |
| 2009 | fwgt       | fwgt       | fwgt       | fwgt       |
| 2010 | fwgt       | fwgt       | fwgt       | fwgt       |
| 2011 | fwgt       | fwgt       | fwgt       | fwgt       |
| 2012 | pwgt       | pwgt       | pwgt       | pwgt       |
| 2013 | pwgt       | pwgt       | pwgt       | pwgt       |
| 2014 | fwgt       | fwgt       | fwgt       | fwgt       |
| 2015 | pwgt       | pwgt       | pwgt       | pwgt       |
| 2016 | weight     | weight     | weight     | weight     |
| 2017 | pufpwgtprv | pufpwgtprv | pufpwgtprv | pufpwgtprv |
| 2018 | pufpwgtprv | pufpwgtprv | pufpwgtprv | pufpwgtprv |
| 2019 | pufpwgtprv | pufpwgtprv | pufpwgtprv | pufpwgtprv |

## Expanded Population + Labor Force Participation by Year

This table gives the expanded population for the appended, four-round dataset for the entire year. It should generally reflect the population of the Philippines at that time, but for some years it does not. All effort has been made to ensure that the raw, incoming weight data has been coded appropriately. All numbers are reported in millions (1,000,000) of people ages 15 and over (inclusive). The Annual PSA reports are only available starting in 2016. 

| Year | GLD Expanded Population | PSA Stated Population | GLD LFP | PSA LFP |
|------|-------------------------|-----------------------|---------|---------|
| 1997 |                         |                       |         |         |
| 1998 |                         |                       |         |         |
| 1999 |                         |                       |         |         |
| 2000 |                         |                       |         |         |
| 2001 |                         |                       |         |         |
| 2002 |                         |                       |         |         |
| 2003 |                         |                       |         |         |
| 2004 |                         |                       |         |         |
| 2005 |                         |                       |         |         |
| 2006 |                         |                       |         |         |
| 2007 |                         |                       |         |         |
| 2008 |                         |                       |         |         |
| 2009 |                         |                       |         |         |
| 2010 |                         |                       |         |         |
| 2011 |                         |                       |         |         |
| 2012 |                         |                       |         |         |
| 2013 |                         |                       |         |         |
| 2014 | 65.7 M                  |                       | 64.41%  |         |
| 2015 | 67.9 M                  | .                     | 63.61%  | .       |
| 2016 | 70.4 M                  | 68.1 M                | 63.42%  | 63.4%   |
| 2017 | 72.1 M                  | 69.9 M                | 61.20%  | 61.2%   |
| 2018 | 73.6 M                  | 71.3 M                | 60.92%  | 60.9%   |
| 2019 | 75.1 M                  | 72.9 M                | 61.28%  | 61.3%   |

Source: [PSA Labor Force Survey Releases](https://psa.gov.ph/statistics/survey/labor-and-employment/labor-force-survey)

## Labor Force Participation

This table gives select year-round labor force participation figures from our final datasets and from the PSA’s publication. Note that only relevant observations were included in our datasets for analysis – e.g., only Janurary/round 1 observations when comparing to the PSA’s January publication for that year. Labor Force Participation includes the percent of observations who report as employed or unemployed; it excludes those who are not in the labor force.

The GLD Figures can be obtained on any final year dataset with the following command in Stata, or by running the `weights_util.do` script available on the repository.

``` stata
tab lstatus [aw=wgt]            ///
      if  age     >= lb_mod_age  ///
      &   month   == 4          // substitute the correct numerical month (1-12)
```

| Year | Round/Month       | GLD Population | PSA Population | GLD LFP | PSA LFP |
|------|-------------------|----------------|----------------|:-------:|:-------:|
| 1997 | (round 2) April   | 711,454 M      | 31.4 M         | 66.96 % | 68.8 %  |
| 2003 | (round 2) April   | 806,825 M      | 51.6 M         | 67.13 % | 67.1 %  |
| 2005 | (round 4) October | 56.1 M         | 54.8 M         | 64.77 % | 64.8 %  |
| 2008 | (round 3) July    | 59.8 M         | 58.1 M         | 64.25 % | 64.3 %  |
| 2009 | (round 4) October | 61.7 M         | 59.7 M         | 63.98 % | 64.0 %  |
| 2012 | (round 1) January | 64.6 M         | 62.6 M         | 64.12 % | 64.2 %  |
| 2013 | (round 1) January | 65.9 M         | 63.6 M         | 64.08 % | 64.1 %  |
| 2014 | (round 2) April   | 65.9 M         | 63.7 M         | 65.21 % | 65.2 %  |
| 2016 | (round 1) January | 69.4           | 67.1 M         | 63.31 % | 63.3 %  |
| 2017 | (round 2) April   | 71.9 M         | 69.6 M         | 61.36 % | 61.4 %  |

Source: Philippine Statistics Authority Integrated Survey of Household Bulletins, [PSA Labor Force Survey Releases](https://psa.gov.ph/statistics/survey/labor-and-employment/labor-force-survey)
