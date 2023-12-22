# Merging Extra Data and Coding Labour Variables for 2017-2022
Since the passing of the [resolution concerning statistics of work, employment and labour underutilization](https://www.ilo.org/global/statistics-and-databases/standards-and-guidelines/resolutions-adopted-by-international-conferences-of-labour-statisticians/WCMS_230304/lang--en/index.htm) in 2013 at the 19th International Conference of Labour Statisticians (ICLS) surveys are at risk of a series break due to the change in the concept of employment.

In short, the ICLS 19 resolution restricts employment to *work performed for others in exchange for pay or profit*, meaning that own consumption work (e.g., subsistence agriculture or building housing for oneself) are not counted as employment.

The GLD codes the harmonization’s `lstatus` variable based on the concept used in the survey. In the case of the Georgian LFS this change occurs after 2019, when the survey switches to new definition. As a result, [time series data](utilities/GEO_lstatus.png) show a decrease in the size of employed and labor force participants for the 2020-2022 round. However, the code can be altered to try to match the previous definition. And this operation can be done conveniently taking advantage of the questionnaire's structure. 

# Framework for identifying the employed in the 2020-2022 GEO LFS


Note that the above only covers the employment status. These added workers should also have information on their occupation sector, employment sector, industry, occupation, ... Own consumption workers are by definition self-employed and in the private sector. Regarding their industry and occupation, question A1.9 directly provides their industrial classification codes in NACE rev.2. And in 2020-2022, own-consumption workers' industry ranges from NACE rev.2 111 to 322, which are all in "Agriculture". As for occupation, users could refer to for-salary workers' occupations with the same industry codes. The data shows that own-consumption workers' industrial codes are mostly in "Elementary Occupations".  
