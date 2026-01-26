# Defining the labor force

KCHS defines labor force status using the standard ILO-style logic (worked or had a job attachment in the reference week; otherwise unemployed if actively seeking and available). That said, the questionnaire structure forces a few practical choices in implementation. In particular, (i) employment is inferred from a set of activity-status flags plus a duration-based “temporary absence” rule, and (ii) job search is not asked directly, so we infer it from reported search methods. Below is the exact logic used in the code.

## 1. Employed

We classify a person as **employed** if they indicate **any economic activity** in the reference week, based on the activity-status question. Specifically, a person is treated as employed if they report being any of the following:
- Wage employee  
- Self-employed (non-farm)  
- Self-employed (farm/agricultural holding)  
- Unpaid family worker (non-farm household enterprise)  
- Unpaid family worker (agriculture/livestock)  
- Apprentice  
- Volunteer  

We then extend employment to people with **job attachment via temporary absence**, based on the survey’s skip logic. A person is classified as employed if they report being absent from work and the **absence duration is less than 3 months**. The code treats this duration threshold as the practical job-attachment cutoff implied by the questionnaire flow (absence beyond that is not treated as attached in the absence of usable earnings-retention detail in the dataset).

###  Alignment with ICLS-19
Since the passing of the [resolution concerning statistics of work, employment and labour underutilization](https://www.ilo.org/global/statistics-and-databases/standards-and-guidelines/resolutions-adopted-by-international-conferences-of-labour-statisticians/WCMS_230304/lang--en/index.htm) in 2013 at the 19th International Conference of Labour Statisticians (ICLS) surveys are at risk of a series break due to the change in the concept of employment.

In short, the ICLS 19 resolution restricts employment to *work performed for others in exchange for pay or profit*, meaning that own consumption work (e.g., subsistence agriculture or building housing for oneself) are not counted as employment.

While the questionnaire collects information on whether household agricultural production is mainly for sale or for own consumption, the instrument does not operationally treat respondents whose production is mainly for own use as outside employment in the core labour-force derivations. Accordingly, the baseline employment flag used for lstatus retains these respondents as employed under the survey’s operational definition. For users who wish to align more closely with the ICLS-19, we provide an alternate employment recode that excludes subsistence (own-use) producers using the code below:

```
* Define subsistence farmers
	gen subsistence_farmers = inlist(d10, 3, 4)
	replace lstatus = . if lstatus == 1 & subsistence_farmers == 1

```

## 2. Unemployed

We classify a person as **unemployed** if they meet two conditions:
1) **Active job search (or future starter),** and  
2) **Available to start work within two weeks.**

### (a) Active job search (inferred from search methods)

The survey does not ask a single direct “did you look for work?” question. Instead, it records whether specific **job-search methods** were used. We therefore infer job search as follows:
- If the respondent reports using **at least one** job-search method, we classify them as **seeking work**.
- If they report **no methods** and the “no methods used” item is affirmed, we classify them as **not seeking**.

The code explicitly checks consistency between “any method used” and the “no methods used” item and asserts there are no contradictions.

### (b) Availability within two weeks

Availability is based on the survey question about how soon the respondent could start work if offered a job. To align with a two-week ILO-style threshold, the code treats respondents as **available** if they report being able to start:
- Immediately,  
- Within 1 week, or  
- Within 2 weeks.  

Responses implying a longer start horizon (for example, more than 2 weeks) or “not available” are treated as not available for unemployment classification.

### (c) Future starters

The code also classifies some respondents as unemployed even if they did not report search methods, if they indicate they have **already found a job and will start in the future** (“future starters”). These respondents are counted as unemployed **only if** they also satisfy the same **two-week availability** condition.

