<img src="/docs/assets/images/WB_Jobs_logo_color.svg" alt="drawing" align="right" width="200"/>
<br>

# Welcome to the Global Labor Database Repository 

## What is the problem we are addressing? 

Household surveys may vary greatly not only from one country to the next, but also within a country over time. Recall periods may change. Similarly, concepts like the categories of unemployment duration can be coded as “*less than a week // more than a week but less than a month // between one month and two months // …*” in one country and simply “*less than a month // more than a month but fewer than three // …*” in another. Thus, a unified standard is necessary to make them comparable.
Moreover, even in cases where the data is harmonized, the harmonization may not serve your particular purpose as you would have needed to add some variables and change the definition of the harmonization slightly to fit your purposes. Yet if the harmonized data is a finished data file, there is little to be done.
Consequently, you may well need to redo the whole harmonization yourself. That is a big investment, one that is inefficient for large projects and potentially prohibitive for smaller ones.

## How does this repository help with this?

This repository provides you with the codes for the surveys we harmonized to the standard, comparable data dictionary of the *Global Labor Database* (GLD). It is based on the data dictionary developed for the World Bank’s Global Monitoring Database (GMD).
This repository does not provide you with the data but rather with the codes so you can run the harmonization yourself and amend and adjust it to your needs without needing to redo the whole process.

The support documentation provides context information on the survey like the sampling strategy followed or which industrial classification was used to identify employment sectors and how these were converted to ISIC codes if the original used a difference classification scheme.

## How do you use repository?

The repository has three folders containing the harmonization codes (folder GLD), the support information (folder Support), and the [contents for the GLD website](https://worldbank.github.io/gld/) (folder docs). It contains many branches on which the team works, but the **main** branch represents the most up to date version for public use.

### Finding the harmonization code

You may find the harmonization code in the [GLD folder](https://github.com/worldbank/gld/tree/main/GLD). Inside, the folders are structured according to [the World Bank Microdata Library naming convention](https://github.com/worldbank/gld/blob/main/Support/Guides%20and%20Documentation/For%20context%20-%20Microdata%20Library%20Folder%20and%20File%20Naming%20Management.docx). That is, at the first level the countries, identified by their [ISO three letter codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3). Inside each country it is organized by denoting the year of survey start and the acronym of the survey. Inside this is the GLD harmonization, wherein finally, under *Programs* you may find the harmonization.
Note that this represents the structure as it is stored on the World Bank server. On the repository we only place the harmonization code and GitHub will jump or overlook any folders it ignores. That is, inside the folder it may look like this:

Figure 1. Example of contents of GLD/IND folder
<br></br>
![](/docs/assets/images/ind_code_example.png)
<br></br>

Here you can see two folders are jumped to directly get to the *Programs* folder where the harmonization code is stored.

### Finding the context information

There are two types of support information. The first are guides and documentation. This includes the GLD guide and its data dictionary. These are stored in the [Guides and Documentation folder](/Support/Guides and Documentation).

The second type of information is the survey context information. This can be found in the [Country Survey Details folder](/Support/Country Survey Details). This folder is structured similarly to the GLD folder by the three letter country code followed by, within country, the survey acronym. Inside each country and survey folder you may find the *Introduction* text. The below is an example of the folder for the Indian EUS survey.

Figure 2. Example of contents of Indian EUS country survey details folder
<br></br>
![](/docs/assets/images/ind_csd_example.png)
<br></br>

In this case, in addition to `1. Introduction to EUS.md` we have three other markdown files that explain other aspects of the survey. However, these will be referenced first in the introduction document. The introduction is always numbered with a one to be on top of the list for easier access as it is the gateway document.

The utilities folder contains all the files (e.g., images, code, tables) referenced in the markdown files.

## How can you help with this repository?

If you wish to help improve this repository, you are more than welcome to – and we’d greatly appreciate it. There are three major ways to help us out.

### Report your experience

The simplest way is to just tell us about your experience. Did you find everything you needed? Were you able to run all the files? Was the process comprehensible to you? Feedback on your experience interacting with the repository helps us improve it, so please feel free to get in touch with the [GLD Focal Point](mailto:gld@worldbank.org).

### Report errors you spotted

In addition to reporting on your experience, as you run and use the harmonization you may spot errors in the code. We harmonize conscientiously and run our harmonization through a set of checks, yet some errors we cannot spot. If you spot any of those please either write to the [GLD Focal Point](mailto:gld@worldbank.org) or, even better, raise an issue we can all see, if possible with a link to [particular section of the code in question](https://docs.github.com/en/github/writing-on-github/working-with-advanced-formatting/creating-a-permanent-link-to-a-code-snippet).

### Harmonize a new survey yourself 

Finally, if you are working on a project that needs a harmonization, please feel free to do it to our standard, we’d be excited to host your contribution. You may find the [data dictionary](https://github.com/worldbank/gld/blob/main/Support/Guides%20and%20Documentation/GLD_Dictionary_v01.xlsx) on our site as well as [the GLD harmonization template](/Support/Templates/GLD_Harmonization_Template.do). You may fork our repository, run through [the quality checks](/Support/Q%20Checks) and create a pull request and we will review it to add it to the collection.

### Other support

We would welcome any other support you may be able to give, such as improvements to the quality checks, the documentation of the survey details, or other documents – even this very same Readme. 
