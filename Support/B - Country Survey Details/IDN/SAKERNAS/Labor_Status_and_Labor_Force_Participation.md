# Labor status and labor force participation rate

This document shows the details of coding `lstatus` for the three groups of years mentioned in the [Introduction to SAKERNAS.](/Support/B%20-%20Country%20Survey%20Details/IDN/SAKERNAS/1.Introduction.to.SAKERNAS.md)


## 1989-1999
>The questionnaires of these years follow the same structure and have the same labor force module questions. Simply following the order of the questions can locate all the conditions needed to decide the employed, the unemployed, and non-labor force population.

**Labor module in the questionnaire**

![labor_1989](utilities/labor_1989.png)

Starting from question 4 in this module, question 4, 5 and 6 were used for defining `lstatus==1`*(employed)*. 
```
Question 4 = 1: work primarily in the previous week
Question 5 = 1: work at least 1 hour in the previous week
Question 6 = 1: have a job but are not temporarily working
```

Because the questionnaire is desinged in such way that people who have job will be led to question 8, question 6 is the minimum requirement for "being employed". Thus `lstatus=2` *(unemployed)* is: 
```
Question 6 = 2: people who do not have work
Question 13 = 1: seeking a job 
```

In this way, *non-labor force* becomes clear as same answer to question 6 as unemployed yet not seeking a job. 

## 2000-2016
>The labor force module has become more complete and questions are more well-guided during this time period. The Only for Working Household Members block states clearly the requirements for people to answer this block, which is a clear clue to code employed people.

**Labor module in the questionnaire**

![labor_2000](utilities/labor_2000.png)

As shown in the screenshot above, work hours (Q6) is only asked to who are employed. It is stated clearly how the questionnaire defines *employed*, which is consistent with ours for 1989-1999:
```
Question 2B = 1: work primarily in the previous week
Question 3 = 1: work at least 1 hour in the previous week
Question 4 = 1: have a job but are not temporarily working
```

Both *unemployed* and *non-labor force* groups do not answer question 6. They only differentiate each other in whether they were seeking a job.
```
Question 5 = 1: seeking a job – unemployed / 2: not seeking a job – non-labor force
```



## Correspondence in industry classification

The original variable `Q43INDUSTRY` in QLFS coded industries is at three-digit level. The [online documentation of SIC 5](http://www.statssa.gov.za/additional_services/sic/descrip6.htm) provides a conversion table between SIC 5 and ISIC Rev.3, although only at two-digit level. As shown in the screenshot below, in most cases, the harmonization would be a one-to-one exclusive matching process, i.e. SIC \#11 will be mapped to ISIC \#01. But in some cases, the relationship is not exclusive but multiple in ISIC to one in SIC, i.e. SIC \#15 and SIC \#16 match SIC \#30. The solution is to go to a lower three-digit level in SIC to find minor-groups with narrower definition for each category, \#15 and \#16 in this case, in ISIC.


