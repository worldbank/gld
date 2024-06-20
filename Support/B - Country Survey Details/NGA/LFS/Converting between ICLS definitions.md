# Introduction
Since the passing of the [resolution concerning statistics of work, employment and labour underutilization](https://www.ilo.org/global/statistics-and-databases/standards-and-guidelines/resolutions-adopted-by-international-conferences-of-labour-statisticians/WCMS_230304/lang--en/index.htm) in 2013 at the 19th International Conference of Labour Statisticians (ICLS) surveys are at risk of a series break due to the change in the concept of employment.

In short, the ICLS 19 resolution restricts employment to *work performed for others in exchange for pay or profit*, meaning that own consumption work (e.g., subsistence agriculture or building housing for oneself) are not counted as employment.

The GLD codes the harmonization’s `lstatus’ variable based on the concept used in the survey. This has been the case for all years in the Rwanda LFS. Nonetheless, it possible to alter the code so that it matches the previous definition.

# Current coding for the each survey of the Nigeria ILFS

Currently, the code used to create the `lstatus` variable (which distinguishes between employment, unemployment, and out of the labour force) is the following:

```
 *<_lstatus_>
	gen byte lstatus = .
	
	*E1: Worked for someone else for pay
	replace lstatus = 1 if atw1 == 1
	
	*E2: Ran or did any kind of business or farming
	replace lstatus = 1 if atw2 == 1
	
	*E3: Helped in a household business
	replace lstatus = 1 if atw3 == 1
	
	*E4: Absent from paid job or income generating activity
	replace lstatus = 1 if abs1a == 1
	
	*E5: Absent from unpaid job or income generating activity
	replace lstatus = 1 if abs1b == 1
	
	*U1: Looking for work/to do business in the past month, and available to work in the past week
	* Wanted to work: only asked for people who did not look for a job
	replace lstatus = 2 if (um1_1 == 1 | um1_2 == 1)  & (um10a == 1 | um10b == 1)

	*N1: NLF if worked but activity is mainly non-market (when <50 % of produce for own consumption)
	replace lstatus = 3 if lstatus == 1 & (atw2 == 1 | atw3 == 1) & (agf2a == 3 | (agf2a == 2 & inrange(agf2b, 1, 2)))
	
	*N2: All others
	replace lstatus = 3 if missing(lstatus) & age>=minlaborage
	
	
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>

 
```



# Removed lines of code to match the old definition

Thus, to obtain a unique series with the old definition we would first need to identify the subsistence farmers, specifically those whose majority (>50%) of agricultral produce are meant for household consumption. These are easily
identified in "N1"; thus, deleting the lines of code under this category will automatically classify the subsistence farmers as employed.

```
 *<_lstatus_>
	gen byte lstatus = .
	
	*E1: Worked for someone else for pay
	replace lstatus = 1 if atw1 == 1
	
	*E2: Ran or did any kind of business or farming
	replace lstatus = 1 if atw2 == 1
	
	*E3: Helped in a household business
	replace lstatus = 1 if atw3 == 1
	
	*E4: Absent from paid job or income generating activity
	replace lstatus = 1 if abs1a == 1
	
	*E5: Absent from unpaid job or income generating activity
	replace lstatus = 1 if abs1b == 1
	
	*U1: Looking for work/to do business in the past month, and available to work in the past week
	* Wanted to work: only asked for people who did not look for a job
	replace lstatus = 2 if (um1_1 == 1 | um1_2 == 1)  & (um10a == 1 | um10b == 1)

	* Delete N1

	*N2: All others
	replace lstatus = 3 if missing(lstatus) & age>=minlaborage
	
	
	replace lstatus = . if age < minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
*</_lstatus_>

 
```


# Comparing indicators between old and new definition

The size of the subsistence farmers in Rwanda is large, ranging between 33% and 48% of the working age population. For this reason, indicator estimates are very sensitive to the definition used. 

| **Year** | **% of working age** |
|:---:|:---:|:---:|
| 2022 Q4 | 48% |
| 2023 Q1-Q3 |45% |

 
 
