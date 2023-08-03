# Introduction
Since the passing of the [resolution concerning statistics of work, employment and labour underutilization](https://www.ilo.org/global/statistics-and-databases/standards-and-guidelines/resolutions-adopted-by-international-conferences-of-labour-statisticians/WCMS_230304/lang--en/index.htm) in 2013 at the 19th International Conference of Labour Statisticians (ICLS) surveys are at risk of a series break due to the change in the concept of employment.

In short, the ICLS 19 resolution restricts employment to *work performed for others in exchange for pay or profit*, meaning that own consumption work (e.g., subsistence agriculture or building housing for oneself) are not counted as employment.

The GLD codes the harmonization’s `lstatus’ variable based on the concept used in the survey. In the case of the Mongolia LFS this change occurs in 2019, when the survey switches to new definition. As a result, [time series data](Utilities/ts_employed.png) show a decrease in the size of employed in 2019 round. However, the code can be altered to try to match the previous definition.


# Current coding for the 2019, 2020 and 2021 LFS

Currently, the code used to create the `lstatus` variable (which distinguishes between employment, unemployment, and out of the labour force) is the following:

```
  ************************
	* Define the employed
	************************
	* E1: Work for wage
	gen byte lstatus=1 if B04 ==1 
	
	* E2: Engage in business or support activity in non-agriculture
	replace lstatus = 1 if D01A == 5

	* E3: Absent from paid job or business but continues to get paid
	replace lstatus = 1 if C06 == 1

	* E4: Household engaged in animal husbandry, AND animal raised or products derived from animal are mainly for sale
	replace lstatus =  1 if D03 == 1| D04 == 1 | D07 == 1 | D07A == 1
	
	* E5: Hired to engage in animal husbandry
	replace lstatus =  1 if D08== 1

	* E6: Engaged in farming, fishing or logging
	replace lstatus = 1 if  inlist(D02, 1, 2)

	************************
	* Define the unemployed
	************************	
	* Estimates of the unemployed from the official report only includes those who were looking for work in the past 30 days, regardless of availability (H10)
	gen look = (H01A == 1 | H01B == 1)
	replace lstatus=2 if look == 1 & H10 == 1
	
	************************
	* Define the NLF
	************************
	replace lstatus=3 if missing(lstatus) & age>= minlaborage
	replace lstatus=. if age<minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>
```


# Coding to convert the 2019, 2020 and 2021 LFS to the old definition

In converting back to the old definition, the approach adopted here is simply to cast a wide net and include all individuals regardless of whether the intention for economic activity is for sale or for own consumption. The code below allowed us to replicate the estimates of the employed by the ILO for 2019 onwards:

``
  ************************
	* Define the employed
	************************
  * E1: Engaged in wage employment, or business/support activity in agriculture or non-agriculture
  gen lstatus = 1 if B04 == 1 | B05 == 1 | B06 == 1

  * E2: Individual continues to get paid despite of absence from work
	replace lstatus = 1 if C06 == 1

  * E3: Individual is engaged in agricultural or non-agricultural activities regardless of intention to sell
	replace lstatus = 1 if inrange(D01A, 1, 5) | inrange(D01B, 1, 4)

	************************
	* Define the unemployed
	************************	
	* Estimates of the unemployed from the official report only includes those who were looking for work in the past 30 days, regardless of availability (H10)
	gen look = (H01A == 1 | H01B == 1)
	replace lstatus=2 if look == 1 & H10 == 1
	
	************************
	* Define the NLF
	************************
	replace lstatus=3 if missing(lstatus) & age>= minlaborage
	replace lstatus=. if age<minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus

```


