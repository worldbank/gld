# Introduction
Since the passing of the [resolution concerning statistics of work, employment and labour underutilization](https://www.ilo.org/global/statistics-and-databases/standards-and-guidelines/resolutions-adopted-by-international-conferences-of-labour-statisticians/WCMS_230304/lang--en/index.htm) in 2013 at the 19th International Conference of Labour Statisticians (ICLS) surveys are at risk of a series break due to the change in the concept of employment.

In short, the ICLS 19 resolution restricts employment to *work performed for others in exchange for pay or profit*, meaning that own consumption work (e.g., subsistence agriculture or building housing for oneself) are not counted as employment.

The GLD codes the harmonization’s `lstatus` variable based on the concept used in the survey. In the case of the NPL LFS this change occurs between 2008 and 2017, when the survey switches to new definition. As a result, [time series data](utilities/NPL_lstatus.png) show a decrease in the size of employed and labor force participants between 2008 and 2017. However, the code can be altered to try to match the previous definition. And this operation can be done conveniently by taking advantage of the questionnaire's structure. 


# Framework for identifying the employed in the 2017 NPL LFS

The information on current activity was used to define the employed using Questions C01-C09 in the questionnaire. The general flow of section C, "Definition of Employment", involves first asking the individual if he/she engaged in any paid or unpaid activities in the past 7 days, the purpose of the activity (i.e., for sale or for family use), if no agricultural activities then any non-agricultural activities, and lastly if no activities engaged what was the reason; if the individual reports otherwise, he/she would be asked about information regarding temporary absence from employment (i.e. whether it is a paid leave or not). 


# Current coding for the 2017 NPL LFS

In 2017, the respondents who indicate that they either

1) worked for salary (C01 is Yes) or
2) engaged in business activities either paid (C02 is Yes) or unpaid (C03 is Yes) that where not in agriculture (C04 is No) or
3) engaged in agricultural activities (mainly) for sale/barter (C05 is either 1 or 2) or
4) were temporarily absent from work with wage/specific reasons (i.e., vacation, maternity leave, sickness/illness/accident, or shift work/variable timetable) (C07 between 1 and 4) or
5) return to the position they are absent for other reasons within 3 months (C08 is 1) or
6) continue receiving income from the work they are absent from (C09 is yes)

are considered employed. You can see below that all these answers will lead respondents to question D01 which is only for those employed.


![2017_sectionc](utilities/2017_sectionC.png)

![2017_sectionc_continued](utilities/2017_sectionC_employed.png)

The current coding for 2017 is therefore :

```
replace lstatus=1 if wrk_paid==1 | wrk_agri_sect==2 | inlist(purp_agripdct,1,2) | inrange(rsn_absent,1,4) | return_prd==1 | paidleave==1
```

in which the variables (named differently in the data but referring to the same questions) correspond to the conditions previously mentioned for a given respondent to be defined employed. 

# Coding to convert the 2017 NPL LFS to the old definition

## Identifying own-consumption workers 
In converting back to the old definition, the approach proposed below is to add people who chose category 3 and 4 for Question C05 to the employed population and assigning industries and occupations for them based on early years' records. Based on the current code we used to identify paid employees or workers who produce for sale/barter, we will use Section C and Section I, "Production of Goods for Household or Family Use", to identify people who were only working unpaid for own consumption and thus were excluded in the new definition.

The revised codes would be:
```
**Current Code**
replace lstatus=1 if wrk_paid==1|wrk_agri_sect==2|inlist(purp_agripdct,1,2)|inrange(rsn_absent,1,4)|return_prd==1|paidleave==1

**New code using purp_agripdct and Section I to identify people working for own consumption only**
replace lstatus=1 if inlist(purp_agripdct,3,4)& temp_absent==2

NOTE: the new code should yield 888 additional observations in 2017, meaning that 888 individuals only worked unpaid for family
consumption. And following the questions in Section C, they were directed to Section G, "Job Search and Availability" first,
and then were directed to Section I to describe the type of work they engaged in and the time they spent accordingly. For reference,
898 observations answered either category 3 or 4 to Question C05. The gap, 10 observations, includes 2 dual employment workers
(classified as working in other jobs) and 8 missing values for Question C06 (variable "temp_absent").
``` 

## Assigning industries and occupations

Own-consumption workers are by definition self-employed and in the private sector and the industry was by definition agriculture. 

Information from Section I can be used to extract further information if necessary. The questions are shown below:

![2017_sectionI_01](utilities/2017_sectionI_1.png)
![2017_sectionI_02](utilities/2017_sectionI_2.png)

Agricultural work questions are highlighted in yellow whereas the blue ones are non-agricultural. Kindly note that Section J, "Own-use Production of Services", also includes work for family consumption, such as unpaid care/help/assistance to family members. But we did not consider Section J because firstly, these unpaid services were not treated as types of "work" for own-consumption; and secondly, Section I and Section J are not mutually exclusive. Observations who were engaging in farm work for family consumption, for example, might also provide unpaid care to family members, causing a problem to industry and occupation assignments. 

Below are the distributions of own-consumption workers' activities in 2017. Agricultural work includes: farm work, fishing/hunting, and livestock tending. Non-agricultural work includes: collecting firewood, crafting, fetching water, house construction, and foodstuff preparation. 

|![2017_agriwork](utilities/NPL_2017_agriwork.png)|![2017_unpaidwork](utilities/NPL_2017_unpaidwork.png)|
|:-----------------------------------------------:|:---------------------------------------------------:|

According to the distribution of own-consumption workers' major industries and occupations in 1998 and 2008, the table below provides the options of industries and occupations for each type of work. It's worth mentioning that "Foodstuff Preparation" was named "Foodstuff Processing" in 2008, and the workers in 2008 were previously classified as "Skilled Agricultural Workers". We provide three options for "Foodstuff Preparation" based on 2008's distribution and ISCO-08. Both "Service and Market Sales Workers" and "Elementry Occupations" have sub-categories concerning food services and food sales. For example, "5212-Street Food Salespersons" of "Service and Market Sales Workers" and "9410-Food Preparation Assistants" of "Elementary Occupations".   

|**CATEGORY**|**Agricultural Work**|**Non-Agricultural Work**|
|:----------:|:-------------------:|:-----------------------:|
|**Industry**|     Agriculture     | 1) Collecting Firewood/Fetching Water/Foodstuff Preparation - Agriculture; 2) Crafting - Manufacture; 3) House Construction - Construction|
|**Occupation**| Elementry Occupation/Skilled Agricultural Worker| 1) Collecting Firewood/Fetching Water - Skilled Agricultural Worker; 2) Crafting/House Construction - Craft Workers; 3) Foodstuff Preparation -  Skilled Agricultural Workers/Service and Market Sales Worker/Elementary Occupations|

## Dual Employment Workers

When dealing with converting ICLS-19 surveys to ICLS-13 definitions we need to think also about workers who would, under ICLS-13 rules be working in two different jobs: the own-consumption work (not seen as employment under ICLS-19) and the other job they are being asked about in the ICLS-19 survey. We commonly refer to these workers as "dual employment" workers.

However, because of the ordering of the questions, very few can be identified. Since the survey asks first for other employed work and then for the business in non-agriculture, people who are in agriculture but do some other non-agriculture work will be asked to skip before they can inform us on their agricultural work.

Information from section I on household production can be used to potentially identify them. Using the code:

```
count if hhg_tot30 > 0 & lstatus == 1
```

which relies on the hours worked on any agricultural work (see I02 in the image of the questionnaire above), we can identify 7,530 individuals aged 15 and above who are employed and also work on own-production. Users may rely on the hours worked in this work (question I02 - `hhg_tot30`) and compare it to the hours work (question E02a or `acthr_mwrk`) to gain a sense of who could be seen as primarily working in agriculture. However, there are no defined rules. It is up to the users sense of the data to make that determination.
