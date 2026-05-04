# Merging Extra Data and Coding Labour Variables for 2017-2024

The extra data we received from the NSO includes all questions from Section A *Activity during the reference week, agricultural work and, market orientation* and, for the earlier rounds, two income questions from Section B *Main Job*. In addition to the question-based variables, the data also contains ID, quarter, and weight variables for uniquely identifying observations.  

Before harmonization, for each year, we merged the labour data received from NSO into the raw data downloaded from the NSO website using weight and ID variables. We then used the assembled data sets for harmonization, which allows us to code `lstatus`, `potential_lf`, and `wage_no_compen` from the underlying survey variables rather than relying only on public derived variables. 
 
# Coding Labour Variables

In the public raw data set, `Employed`, `Unemployed`, `Unemployed_soft`, `Inactive` and `Inactive_soft` are the derived labour variables. The main issue with derived variables is that there is no way to validate the estimates to ensure the definition applied aligns with ours. Especially in Georgia's case, both unemployment and non-labour force have two variables each following a "strict" or a "soft" ILO standard. We could not find an explanation of what this precisely means in the documentation.

Using the extra data from NSO, we were able to code the employed population using questions from A1 to A10. The current coding is demonstrated below, in which all the answers that lead to section B are coded as employed. The employed estimate yielded by these codes is the same as the derived variable `Employed`, `Unemployed`, and `Inactive`. Disassembling the unemployment variable into the very original question-based variables, it includes:
1) people who answered G1 yes (have an agreement to start a job or will start own business within 3 months) and are available for starting a work (yes to G9);
2) people who are currently seeking jobs and would be able to start working (no to G1; 
answered either one of G2 and yes to G9). Therefore, we are sure that the "strict" definitions of unemployment and non-labour force align with our definition in the earlier rounds where the full question sequence is available.  

For the post-2019 rounds, GLD relies on the raw derived variable `Unemployed` to retain future starters consistently. This is especially important in 2024, because the received labour file does not retain `G1`, so future starters cannot be identified directly from the questionnaire items in the delivered data. The derived raw variable appears to preserve the within-three-month future-starter logic used in the earlier rounds and is therefore the preferred source for unemployment coding in those years.

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

# Coding Wage Variables

In the earlier GEO LFS rounds, paid employees are asked for their wages in two steps. The questionnaire first asks for the precise salary. If the respondent is unable to give a true estimate, they are then asked to report the bracket in which their salary lies (see screenshot of questionnaire below).

![wage_questionnaire](utilities/wage.png)

On average, about 80% of paid employees in the earlier rounds can name their precise salary, while about a fifth give a range-value answer. To use the interval information, we imputed salary for bracket-only cases. First, the wage information of those who know their precise salary was trimmed of outliers. Next, the mean salary was calculated by sex, urban/rural area, industry, and occupation within each wage bracket. For example, we calculated the mean salary of women in urban areas who worked in manufacturing as clerks and reported earnings between 800 and 1000 GEL. Then all urban women in the same sector and occupation who could not precisely tell us their wage but reported that bracket were assigned that mean salary. These estimates align roughly with the ILOSTAT data on salaries calculated from the Household Income and Expenditure Survey (see below).

The 2024 received wage data differ from the earlier rounds. Although the questionnaire still asks first for the exact amount and then for a bracket if needed, the delivered 2024 labour file retains only the bracketed earnings variable and not the exact amount. For this reason, the donor-based imputation used in the earlier rounds could not be reproduced in 2024. Instead, `wage_no_compen` in 2024 is approximated directly from the reported brackets.

![wage_estimates](utilities/wage_estimates.png)
