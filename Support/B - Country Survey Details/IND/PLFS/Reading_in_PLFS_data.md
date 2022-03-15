# Reading in PLFS data

The PLFS data is not shared as a file with the usual extensions of survey files (e.g., `.dta`, `.sav`, or `.csv`) but rather as a text file. The text files are accompanied by [a data layout file](utilities/Data_LayoutPLFS.xlsx) that defines the length of each variable to be read in. 

For example, it defines that, in the household file, character positions 13 and 14 represent the state code, while character position 45 in the individual file represents the variable coding the marital status of the respondent.

To read this into `Stata` two steps are necessary. The first is to convert the information in the table into a `.dct` file. The image below shows the content of the same for 2019:

![Manual](utilities/dct_file.PNG)

As can be seen, it tells the computer program to read using the mentioned `.txt` file (make sure to reference the correct one as names may vary, users may have stored the information under different names) and then instructs in each line what type the variable should be, what name it should have, and which characters in the text correspond to it.

Once the `.dct` files have been created, you just need to create a `.do` file that instructs `Stata` to run the `.dct` file and store the generated files in the location of your choice.

As examples, you may find [here the `.dct` file for households](utilities/hhv1.dct) and [here the file for individuals](utilities/perv1.dct) for 2019, as well as [here the `.do` file calling them in](utilities/Read_IND_2019_PLFS_from_text.do) and storing the output. 

The character positions are the same for all years, but variable types may need to change from one year to the next. This is if non-numeric characters were introduced. For example, age in 2019 is a string as, wrongly, some special characters (`.` and `#`) have been coded in. This requires setting the variable as string. The harmonization code for 2019 then cleans these erroneous entries.
