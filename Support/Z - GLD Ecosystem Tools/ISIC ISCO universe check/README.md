# Checking whether ISIC or ISCO codes in harmonized data are in the ISIC/ISCO universe

## What is the potential problem

When harmonizing ISIC or ISCO information (for example in variable `industrycat_isic`), there may be particular codes harmonized from the raw survey that actually do not exist in the universe of possible ISIC or ISCO codes.

For example, in ISIC Revision 3, the Division 36 has only two groups (three-digit codes): `361` and `369`. In particular, `361` has no further unit (four-digit code) divisions and thus is `3610`. The below image is an [excerpt from this PDF version of ISIC Rev 3](https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/ISIC_Rev_3_English.pdf).
<br></br>
![ISIC Rev 3 example](utilities/isic_3_36.png)
<br></br>
In the case of a survey used in the past, the variable `industrycat_isic` actually showed the following codes:
<br></br>
![Division 36 sub cases](utilities/isic_3611_3612_example.png)
<br></br>

There are two possible explanations for this. Either the code was entered wrongly (data entry mistake) or the code actually comes from a national classification that has a more detailed breakdown. That is, the group `361 – Manufacture of furniture` has in this country two distinct and different units `3611` and `3612`.

In either case, this represents an error in the harmonization as the values of `industrycat_isic` should be wholly within the range of possible values of the specific ISIC revision the survey deals with. 

The quality checks have been updated to spot whether there are values outside of the ISIC or ISCO universes in either of the `* _isic[_*]` or `*_isco[_*]` - or their second job counterparts. However, this will only alert users to the fact that there are values outside. It does not tell the user which ones.


## Installing and using the `int_classif_universe` command

This is what the `int_classif_universe.ado` file helps users with. To make it work, users only need to install it in the `ado/plus/i` folder, where Stata user-written programs are stored. The below is an example of the folder in Windows.

<br></br>
![Stata ado folder in Windows](utilities/store_in_ado_plus.png)
<br></br>

Once it is installed, the user needs to open the harmonized filed with the out-of-universe ISIC or ISCO values. Then they need to run the command, with the name of the industrycat_isic or occup_isco version of interest as an argument to the `var([varname])` option and `isic` or `isco` (or all caps version) as argument to the `universe([isco/isic])` option.

For example, for `industrycat_isic` this is
```
int_classif_universe, var(industrycat_isic) universe(ISIC)
```

This will read in the corresponding ISIC universe data, merge it to the harmonized data, and reduce it to the cases where `industrycat_isic` has non-missing values that are outside the ISIC universe. In the last step the function reduces the information so the data frame contains only each out-of-universe code once, giving the number of instances that these codes appear in the sample, plus some general survey information. The below is an example where the output from the case with the additional `3611` and `3612` codes is listed on the console.

<br></br>
![Stata ado folder in Windows](utilities/list_output.png)
<br></br>

We can observe that there is a total of 15 codes that are outside the possible code for ISIC Rev. 3. A total of 2112 instances in the survey have inexistant codes. Over two thirds of those come from our observed additional `3611` and `3612` codes (1456 instances).

Now the users have the information to look at which codes need correcting more easily. This is open to interpretation and should be discussed with other team members. One option is to simply set the codes to missing. Another option would be to reduce the detail level to the one present in ISIC Rev. 3. That is, to add the line 

```
replace industrycat_isic = “3610” if inlist(industrycat_isic, “3611”, “3612”)
```

to the code harmonizing `industrycat_isic`.

## Sources

The full list of ISIC and ISCO codes are read from the lists stored in the Checks folder ([link here](https://github.com/worldbank/gld/blob/main/Support/D%20-%20Q%20Checks/Helper%20Programs)). The R code used to create that file is [also available there](https://github.com/worldbank/gld/blob/main/Support/D%20-%20Q%20Checks/Helper%20Programs/create_isic_isco_txt.R).
