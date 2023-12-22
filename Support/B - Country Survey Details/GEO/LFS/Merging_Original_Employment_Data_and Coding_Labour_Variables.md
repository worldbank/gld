# Merging Extra Data and Coding Labour Variables for 2017-2022

The extra data we received from the NSO includes all questions from Section A *Activity during the reference week, agricultural work and, market orientation* and two income questions from Section B *Main Job*. In addition to the question-based variables, the data also contains ID, quarter, and weight variables for uniquely identifying observations.  

Before harmonization, for each year, we merged the confidential labour data from NSO into the raw data downloaded from the NSO website using weight and ID variables. And then we used the assembled data sets for harmonization, which allows us to code `lstatus`, `potential_lf`, and `wage_no_compen` from the very original variables pulled out directly from the survey instead of using the derived variables. 
 
# Coding Labour Variables

In the public raw data set, `Employed`, `Unemployed`, `Unemployed_soft`, `Inactive` and `Inactive_soft` are the derived labour variables. The main issue with derived variables is that there is no way to validate the estimates to ensure the definition applied aligns with ours. Especially in Georgia's case, both unemployment and non-labour force have two variables each following a "strict" or a "soft" ILO standard, which we did not fully understand. The exact definition was not explained in any documentation.

Using the extra data from NSO, WE  

```
 gen byte lstatus=.
	egen seeking=rowmin(G2_1_Methods_used_to_find_work-G2_97_Methods_used_to_find_work)
	replace lstatus=1 if A1==1|A2==1|A3==1|A4==1|A5==1|A6==1|A9==1|A10==1|A10==3
	replace lstatus=2 if (G1_agreement_to_start_a_work==1|seeking==1)&G9_Availability_to_start_working==1
	replace lstatus=3 if lstatus==. 
	replace lstatus=. if age<minlaborage
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
```

