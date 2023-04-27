# Introduction
Since the passing of the [resolution concerning statistics of work, employment and labour underutilization](https://www.ilo.org/global/statistics-and-databases/standards-and-guidelines/resolutions-adopted-by-international-conferences-of-labour-statisticians/WCMS_230304/lang--en/index.htm) in 2013 at the 19th International Conference of Labour Statisticians (ICLS) surveys are at risk of a series break due to the change in the concept of employment.

In short, the ICLS 19 resolution restricts employment to *work performed for others in exchange for pay or profit*, meaning that own consumption work (e.g., subsistence agriculture or building housing for oneself) are not counted as employment.

The GLD codes the harmonization’s `lstatus` variable based on this concept starting with the 2015-16 QLFS as information becomes available on respondents' intention for economic activity to distinguish between working for pay or own consumption. 

# Current coding for the 2015-16 QLFS

Currently, the code used to create the `lstatus` variable (which distinguishes between employment, unemployment, and out of the labour force) is the following:

```
*<_lstatus_>
	gen byte lstatus = .
	*------------------------------------------------------------------------
	* Define the employed
	*------------------------------------------------------------------------
	** E1. Worked in the past 7 days
	replace lstatus = 1 if q31 == 1
	
	** E2.  Absent from work in the past 7 days
	replace lstatus = 1 if q32 == 1 & q31 == 2
	
	** E3. Worked at least 1 hour to produce goods/services for own consumption with the main intention of selling
	replace lstatus = 1 if (q33 == 1 & q35 == 1)
	
	** E4. Absent from work involving activity described in E3
	replace lstatus = 1 if (q33 == 2 & q34 == 1 & q35 == 1)

	** E5. People who reported not engaging in any activity in the past 7 days but emp == 1 and worked mainly for pay or profit
	replace lstatus = 1 if emp == 1 & q35 == 1
	
	** E6. People with primary activity for own consumption but with secondary activity for pay or profit
	replace lstatus = 1 if q55 == 1 & q56 == 1
		
	* These people either had primary activity in subsistence farming or had not enough information to evaluate labor status based on the above categories of employed (e.g., reported producing goods for own consumption but missing value for main intention of selling). While the latter category is suspicious, and the alternative to recode lstatus as missing completely is not a  bad idea, it is 
	
	* There are 19,372 people who are tagged as employed by the survey, but not in lstatus simply because they are subsistence farmers.
	
	*------------------------------------------------------------------------
	* Define the unemployed
	*------------------------------------------------------------------------
	replace lstatus = 2 if q77 == 1 & q81 == 1
	
	*------------------------------------------------------------------------
	* Define the NLF
	*------------------------------------------------------------------------
	replace lstatus = 3 if missing(lstatus)
	
	replace lstatus = . if age < minlaborage
```

The steps U2, N2, and N5 are the ones where people are working on non-market-exchange farm work (the only subsistence activity coded in the survey). These are the codes that need to change to make a time series that is comparable to the old ICLS definition used in the other surveys.


# Coding to convert the 2015-16 QLFS to the old definition

Thus, to obtain a unique series with the old definition we would need to code:

```
	*------------------------------------------------------------------------
	* Define the employed
	*------------------------------------------------------------------------
	** E1. Worked in the past 7 days
	replace lstatus = 1 if q31 == 1
	
	** E2.  Absent from work in the past 7 days
	replace lstatus = 1 if q32 == 1 & q31 == 2
	
	** E3. Worked at least 1 hour to produce goods/services for own consumption
	** => Change to remove filter for working for profit
	replace lstatus = 1 if (q33 == 1)
	
	** E4. Absent from work involving activity described in E3
	** => Change to remove filter for working for profit
	replace lstatus = 1 if (q33 == 2 & q34 == 1)

	** E5. People who reported not engaging in any activity in the past 7 days but emp == 1 
	** => Change to remove filter for working for profit
	replace lstatus = 1 if emp == 1
	
	** E6. People with primary activity for own consumption but with secondary activity for pay or profit
	** => If primary activity for own consumption treated as employed, this is no longer necessary
	**replace lstatus = 1 if q55 == 1 & q56 == 1
```
