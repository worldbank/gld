# Introduction to the GLD

## What is GLD?

The Global Labor Database (GLD) is part of the World Bank initiatives to harmonize labor force surveys and household surveys with a relevant labor module. Its mission is to create an open and transparent harmonization with sufficient contextual information to allow data analysts to use, alter, and expand the harmonization. In this sense, contextual information goes beyond code, questionnaires, and reports, and includes discussions of how particularly salient choices in the coding were made or changes that took place in the country, that are relevant to understand the survey but are not to be found in a report or the data. An example of this would be changes to the currency or the administrative divisions. 

The GLD aims to be an open-source database, meaning that as much information should be accessible to as many people as possible, considering relevant data privacy concerns. It also strives to be transparent, making all steps that create the harmonization traceable, from raw data acquisition to harmonized variable coding. In this sense, all steps of the harmonization process are documented and made available, including the survey documentation, code and notes that allow users to fully comprehend the survey design and the choices made in the harmonization. The availability of the codes and documentation enables users to customize and add variables not in the GLD harmonization. Most harmonization efforts provide users with a "take it or leave it" option, but the GLD's open and transparent approach allows users to trace and deviate from the standard harmonization at any point, giving them a head start regardless of where they wish to jump in.

Finally, the GLD follows up and expands on the previous initiative to harmonized household surveys, the International Income Distribution Database (I2D2). The I2D2 was superseded by the Global Monitoring Database (GMD), which however focused on household budget surveys and did not harmonize labor force surveys. The GLD was created to remedy this gap in the survey type coverage and complement it, with a stronger focus on labor market information through an expanded dictionary and more rigorous validation of labor indicators.

## What is the objective of GLD?

Surveys serve to inform about key indicators and questions that policy makers monitor, target, and evaluate. Appended across time and space, they are used for comparison and benchmarking. The objective of GLD is to make the process of producing these estimates easier, traceable, and reproducible for all World Bank staff and, wherever possible, for all researchers worldwide.

The issue in generating indicators is time-consuming process of harmonization, which requires reading both data files and survey materials in detail to understand what to code and how, as well as many steps of validation. This effort only needs to be done once and well to serve as the springboard for all users.

The first objective of GLD is thus to create a database of harmonized surveys with comprehensive and reliable labor market information that can be used in analytical work, freeing up teams from the work of having to create the harmonization in the first place. By creating a harmonized output, this database can be fed into other products that automate analytical processes like country level jobs diagnostics. The complementarity with the GMD data dictionary makes these products simpler and richer.

The second objective of GLD is to allow users to go beyond the standard dataset, to support them in delving deeper into their analyses and comparisons to find more profound insights. GLD empowers such customized approach by providing all codes and technical reports, as well as documenting all intricacies of the survey discovered while harmonizing so that users can focus on answering the questions they need answering, not on figuring out in what year an administrative boundary was changed and how the sample size was thus affected.

## Who is the intended audience?

Target users of GLD include researchers, data analysts and practitioners in the international development community, statistical offices, ministries of labor, of economy and planning and other relevant government agencies analyzing labor market data to monitor and analyze labor market outcomes, and to inform the design of labor policies. These users can exploit two kinds of uses of the GLD. 

The first use is the “as-is” harmonization. This refers to the user taking the harmonized data files as prepared by the data team and using those variables (or combinations thereof) for their analysis.

The second use is the “amended” or “hacked” harmonization. This refers to the user wanting to go beyond the prepared harmonization. This may be, for example, because they are interested in another specific variable from the survey, present in the questionnaire but not harmonized as not common in most surveys. In this case, the user can still utilize the harmonization do file to standardize most variables (as concepts like education level or labor status are likely still going to be relevant) but in addition add other ones. This use entails editing the harmonization code and/or adding to it at specific points to serve the users purpose without them needing to process the survey entirely.

## What are the principles guiding GLD?

GLD follows a set of principles to guide its development and maintenance. In this introduction we focus on (a) data acquisition and GLD expansion, (b) transparency and data access, (c) data quality and validation, and (d) complementarities with similar data efforts.

### Data acquisition and GLD expansion

As of April 2024, holds 343 surveys from Y countries (1 high-income countries, 9 upper medium-income, 11 lower middle-income, and 9 low-income countries). 

The initial choice of countries was driven by the availability of multiple LFS over time for the same countries. Thereafter, the GLD team has established selection guidelines to try to balance the GLD country coverage across income groups, regions, and time.

However, acquiring new surveys is mostly determined by data availability, that is, whether it is possible to acquire new data for us or whether the National Statistical Office (NSO) of countries do not permit the sharing of survey data. That is, even if we lack surveys from a particular region and we would like to include it, we cannot. Moreover, we prefer open data. If the choice is between two surveys from different countries and, all else being equal, one is in the public domain or at least can be shared freely within the World Bank while the other is not, the former would be preferred. Finally, certain countries may not run, or run very seldomly a labor force survey. Such a country would be a blind spot of GLD despite our best efforts.

Beyond these restrictions the GLD selects surveys by trying to (i) even out income levels, (ii) ensure topicality. Evening out income levels means to try to have GLD represent as best as possible the world by income levels. [For fiscal year 2024](https://blogs.worldbank.org/en/opendata/new-world-bank-group-country-classifications-income-level-fy24), about 38% of countries are high-income, each 25% lower and upper middle income, and 11% low income. GLD is less focused on high-income countries, but for the remaining categories we aim to keep countries so that they do not swerve too far off from these relative weights.

Evening topicality means to try to keep surveys up to date. In general, we view a surveys as in date if it is from the previous four years (e.g., from at least 2020 in 2024). Thus, both between regions and within regions, the choice in surveys to add to GLD should reflect an effort to not just be present at all income levels but to have up to date surveys for all.
Transparency and data access

GLD is designed to be as transparent as possible. Every step of our harmonization should be transparent and traceable. In addition, all the outputs produced by the GLD team (harmonization code and documentation of survey details, choices made during harmonization) are shared freely to all on GitHub, a web platform for collaborative software development and version control.

Access to the raw and harmonized microdata is limited due to the data protection restrictions such data warrants. Data is stored on a server managed by the GLD team. We aim, as explained below, to use data sources we can share at least with World Bank colleagues whenever possible. Data that is accessible in such a way is stored on a server all World Bank staff may access. Data is also accessible via datalibweb and the microdata library. These two sources should contain all surveys on GLD, although some of them may require permission to be shared on a case-by-case basis. More details on this in the section on [accessing GLD further below](https://worldbank.github.io/gld/Support/A%20-%20Guides%20and%20Documentation/GLD%20Manual/GLD_Manual_Overview.html#accessing-gld-information).

### Data quality and validation

Central to the GLD objective of being a reliable source for cross country comparisons and benchmarking is to ensure data are of the highest quality. Only then is it possible to leverage large datasets and use GLD as an input into automated analytical workflows.

To validate the harmonization, the GLD team has three main tools. The first is the validation done with country office colleagues and NSO staff when harmonizing. GLD harmonizers are in touch with relevant colleagues with domain knowledge to understand the survey (knowledge they can then document and share) and ensure their mapping of variables from the raw data to the harmonized variables is sensible.

Once the harmonization is finalized, there are two automated quality check procedures. The first checks the survey for integrity and coherence with external sources (e.g., is the calculated labor force participation in line with what ILO, WDI report). The second checks a series of surveys in a country over time to detect any unexpected jumps in the series.

Finally, via direct exchange with the GLD team or on the online GitHub platform, users can alert the team of issues in the harmonization that had made it through, nonetheless. A process of updating the harmonization then kicks in to try to correct any issues as quickly as possible. For a more detailed description of all quality checks, please see our [section on data validation](https://worldbank.github.io/gld/Support/A%20-%20Guides%20and%20Documentation/GLD%20Manual/GLD_Manual_Validation.html).

### Complementarities (and differences) with similar data efforts

The two efforts that work in a similar space are the ILO’s [ILOSTAT data platform](https://ilostat.ilo.org/data/) and the Global Monitoring Database. The ILOSTAT platform provides users with an extensive set of indicators, not just on labor markets, but also on other socioeconomic and sociodemographic information. It is based on indicators created from a process of harmonized raw data from the [ILO Survey Catalogue](https://www.ilo.org/surveyLib/index.php/home).

However, the catalog is only accessible to ILO staff. Moreover, no harmonization codes are made available and thus what the user can access are indicators at the national level. Hence, while ILOSTAT is a great resource to obtain country level indicators for the most common topics, GLD can complement this via allowing users going deeper and leveraging the full microdata, running regressions or calculating indicators at sub-national level.

In contrast to ILOSTAT, the Global Monitoring Database (GMD) is also a database of survey microdata, providing users with responses at the individual level. GMD focuses on household budget surveys and thus includes variables on household consumption and calculates certain consumption aggregates not present in GLD. ON the other hand, GLD has more detailed labor variables, especially providing (wherever possible) industry and occupation information using [ISIC](https://unstats.un.org/unsd/classifications/Econ/isic) and [ISCO](https://ilostat.ilo.org/resources/concepts-and-definitions/classification-occupation/) codes to the fullest depth possible. As both use a common set of variables, both can be used as inputs to automated analytical tools. This is the case, for example for the Jobs Indicators database ([JOIN](https://datacatalog.worldbank.org/int/search/dataset/0037526/global_jobs_indicators_database)), which reads in data from GMD, GLD, and I2D2 to create country indicators.

## How can GLD be sustainable?

Maintaining the level of detail provided by the GLD is a significant undertaking that requires a serious investment of resources. The World Bank is the right organization to house such an effort due to the externalities generated by a public effort to create accessible data. 

To maintain the costs of the effort low and ensure the sustainability of the project as it scales and requires more management, two things are necessary: 1) a strong collaboration with regional data teams (already established with the South Asia team), and 2) the creation of a community of users on GitHub, a web platform for collaborative software development and version control, initially among World Bank colleagues but hopefully from around the world eventually, to leverage their input through a collaborative yet curated wiki approach.  
