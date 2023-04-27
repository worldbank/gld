# Introduction
Since the passing of the [resolution concerning statistics of work, employment and labour underutilization](https://www.ilo.org/global/statistics-and-databases/standards-and-guidelines/resolutions-adopted-by-international-conferences-of-labour-statisticians/WCMS_230304/lang--en/index.htm) in 2013 at the 19th International Conference of Labour Statisticians (ICLS) surveys are at risk of a series break due to the change in the concept of employment.

In short, the ICLS 19 resolution restricts employment to *work performed for others in exchange for pay or profit*, meaning that own consumption work (e.g., subsistence agriculture or building housing for oneself) are not counted as employment.

The GLD codes the harmonization’s `lstatus’ variable based on this concept starting with the 2015-16 QLFS as information becomes available on respondents' intention for economic activity to distinguish between working for pay or own consumption. 

# Current coding for the 2020 ILFS

Currently, the code used to create the `lstatus` variable (which distinguishes between employment, unemployment, and out of the labour force) is the following:

```
  ***************************
  * Create Variable
  ***************************
	gen byte lstatus = .
  
  
  ***************************
  * Define those employed
  ***************************
  
	* E1 - Did some work
	replace lstatus = 1 if Q13F == 1 | Q13G == 1 | Q13H == 1
  
	* E2 - Did some work, including farm work and it was 50%+ for sale
	replace lstatus = 1 if (Q13D <= 7 & Q13E <= 2)
	
	* E3 - Did not work but temporarily absent from paid job
	replace lstatus = 1 if (Q13F == 2 | Q13G == 2 | Q13H == 2) & (inlist(Q13J,1,4))
  
	* E4 - Did not work but temporarily absent from commercial farming
   	 replace lstatus = 1 if (Q13F == 2 | Q13G == 2 | Q13H == 2) & (inlist(Q13J,2,3)) & (inlist(Q13N,1,2)) & (Q13K == 1 | (inrange(Q13K,2,5) & Q13M == 1 ) )


  ***************************
  * Define those unemployed
  ***************************
  
	* U1 - Unemployed is no work + took steps to find work and would accept
	replace lstatus = 2 if (Q13F == 2 & Q13G == 2 & Q13H == 2 & Q13IA == 2) & (Q15A == 1 & Q15D ==1)
  
	* U2 - Unemployed is farm work but not for market + steps and willing
	replace lstatus = 2 if (Q13D <= 7 &  Q13E >= 3) & (Q15A == 1 & Q15D ==1)
  
	* U3 - Unemployed is no work, nothing to return to + steps and willing
	replace lstatus = 2 if (Q13F == 2 | Q13G == 2 | Q13H == 2) & (inlist(Q13J,2,3)) & (inlist(Q13N,3,4)) & (Q15A == 1 & Q15D ==1)
	
  
  ***************************
  * Define those NLF
  ***************************
  
	* N1 - Not in the labour force (NLF) is: no work, no steps
	replace lstatus = 3 if (Q13F == 2 & Q13G == 2 & Q13H == 2 & Q13IA == 2) & (Q15A == 2)
  
	* N2 - NLF is: work but not for market and no steps
	replace lstatus = 3 if (Q13D <= 7 &  Q13E >= 3) & (Q15A == 2)
  
	* N3 - NLF is: no work nothing to return + no steps
	replace lstatus = 3 if (Q13F == 2 | Q13G == 2 | Q13H == 2) & (inlist(Q13J,2,3)) & (inlist(Q13N,3,4)) & (Q15A == 2)

	* N4 - NLF is: no work + took steps to find work but would not accept
	replace lstatus = 3 if (Q13F == 2 & Q13G == 2 & Q13H == 2 & Q13IA == 2) & (Q15A == 1 & Q15D == 2)
  
        * N5 - NLF is: work but not for market + steps yet not willing
	replace lstatus = 3 if (Q13D <= 7 &  Q13E >= 3) & (Q15A == 1 & Q15D ==2)
  
	* N6 - NLF is: no work, nothing to return to + steps yet not willing
	replace lstatus = 3 if (Q13F == 2 | Q13G == 2 | Q13H == 2) & (inlist(Q13J,2,3)) & (inlist(Q13N,3,4)) & (Q15A == 1 & Q15D ==2)
```

The steps U2, N2, and N5 are the ones where people are working on non-market-exchange farm work (the only subsistence activity coded in the survey). These are the codes that need to change to make a time series that is comparable to the old ICLS definition used in the other surveys.


# Coding to convert the 2020 ILFS to the old definition

Thus, to obtain a unique series with the old definition we would need to code:

```
  ***************************
  * Create Variable
  ***************************
	gen byte lstatus = .
  
  
  ***************************
  * Define those employed
  ***************************
  
	* E1 - Did some work
	replace lstatus = 1 if Q13F == 1 | Q13G == 1 | Q13H == 1
  
	* E2 - Did some work, including farm work and it was 50%+ for sale
	replace lstatus = 1 if (Q13D <= 7 & Q13E <= 2)
	
	* E3 - Did not work but temporarily absent from paid job
	replace lstatus = 1 if (Q13F == 2 | Q13G == 2 | Q13H == 2) & (inlist(Q13J,1,4))
  
	* E4 - Did not work but temporarily absent from commercial farming
   	replace lstatus = 1 if (Q13F == 2 | Q13G == 2 | Q13H == 2) & (inlist(Q13J,2,3)) & (inlist(Q13N,1,2)) & (Q13K == 1 | (inrange(Q13K,2,5) & Q13M == 1 ) )


  ***************************
  * Define those unemployed
  ***************************
  
	* U1 - Unemployed is no work + took steps to find work and would accept
	replace lstatus = 2 if (Q13F == 2 & Q13G == 2 & Q13H == 2 & Q13IA == 2) & (Q15A == 1 & Q15D ==1)
  
	* U2 - Unemployed is farm work but not for market + steps and willing
        * CHANGE --> For old definition, work not for market is still employment: lstatus to 1
	replace lstatus = 1if (Q13D <= 7 &  Q13E >= 3) & (Q15A == 1 & Q15D ==1)
  
	* U3 - Unemployed is no work, nothing to return to + steps and willing
	replace lstatus = 2 if (Q13F == 2 | Q13G == 2 | Q13H == 2) & (inlist(Q13J,2,3)) & (inlist(Q13N,3,4)) & (Q15A == 1 & Q15D ==1)
	
  
  ***************************
  * Define those NLF
  ***************************
  
	* N1 - Not in the labour force (NLF) is: no work, no steps
	replace lstatus = 3 if (Q13F == 2 & Q13G == 2 & Q13H == 2 & Q13IA == 2) & (Q15A == 2)
  
	* N2 - NLF is: work but not for market and no steps
        * CHANGE --> For old definition, work not for market is still employment: lstatus to 1
	replace lstatus = 1 if (Q13D <= 7 &  Q13E >= 3) & (Q15A == 2)
  
	* N3 - NLF is: no work nothing to return + no steps
	replace lstatus = 3 if (Q13F == 2 | Q13G == 2 | Q13H == 2) & (inlist(Q13J,2,3)) & (inlist(Q13N,3,4)) & (Q15A == 2)

	* N4 - NLF is: no work + took steps to find work but would not accept
	replace lstatus = 3 if (Q13F == 2 & Q13G == 2 & Q13H == 2 & Q13IA == 2) & (Q15A == 1 & Q15D == 2)
  
        * N5 - NLF is: work but not for market + steps yet not willing
        * CHANGE --> For old definition, work not for market is still employment: lstatus to 1
	replace lstatus = 1 if (Q13D <= 7 &  Q13E >= 3) & (Q15A == 1 & Q15D ==2)
  
	* N6 - NLF is: no work, nothing to return to + steps yet not willing
	replace lstatus = 3 if (Q13F == 2 | Q13G == 2 | Q13H == 2) & (inlist(Q13J,2,3)) & (inlist(Q13N,3,4)) & (Q15A == 1 & Q15D ==2)
```
