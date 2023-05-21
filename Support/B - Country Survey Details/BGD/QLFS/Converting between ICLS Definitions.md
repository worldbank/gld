# Introduction
Since the passing of the [resolution concerning statistics of work, employment and labour underutilization](https://www.ilo.org/global/statistics-and-databases/standards-and-guidelines/resolutions-adopted-by-international-conferences-of-labour-statisticians/WCMS_230304/lang--en/index.htm) in 2013 at the 19th International Conference of Labour Statisticians (ICLS) surveys are at risk of a series break due to the change in the concept of employment.

In short, the ICLS 19 resolution restricts employment to *work performed for others in exchange for pay or profit*, meaning that own consumption work (e.g., subsistence agriculture or building housing for oneself) are not counted as employment.

While the 2015-16 QLFS provides information that would allow harmonizers to distinguish those working for own consumption, the survey still treats these workers as employed and the GLD harmonization process follows this approach. However, users can consider the code below should they want to define the employed exclusively based on work in exchange of pay or profit. 

# Current coding for the QLFS

For both the 2015-16 and 2016-17, the code used to create the `lstatus` variable (which distinguishes between employment, unemployment, and out of the labour force) is the following:


```
	*------------------------------------------------------------------------
	* Define the employed
	*------------------------------------------------------------------------
	** E1. Worked in the past 7 days
	replace lstatus = 1 if q31 == 1
	
	** E2.  Absent from work in the past 7 days
	replace lstatus = 1 if q32 == 1 & q31 == 2
	
	** E3. Worked at least 1 hour to produce goods/services for own consumption
	replace lstatus = 1 if (q33 == 1)
	
	** E4. Absent from work involving activity described in E3
	replace lstatus = 1 if (q33 == 2 & q34 == 1)

	** E5. People who reported not engaging in any activity in the past 7 days but emp == 1 
	replace lstatus = 1 if emp == 1


```




# Coding to convert to the new definition

Thus, to obtain a unique series with the new definition, i.e., to exclude those working for own consumption, we would need to code:

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

```

