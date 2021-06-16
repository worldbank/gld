README.md

# Overview
In this directory you will find a `.do` file and an `.R` script under a similar name. The `.do` file is the primary script, so run this must be run first. It will pause in the middle for you to edit the `.xlsx` and run the R script so you can resume code running in "one click". It's clunky but it does work.

## 1. First run the .do file, generate and edit `-template-IN-R.xlsx`
One of the first tasks it performs is appending all relevant within-year rounds of the LFS data. This is done through `iecodebook`, which is a command that harmonizes variable names, labels, and value labels across survey rounds by generating an `.xlsx` file of the metadata contained in the rounds to be appended (before they are appended). Run this file (the name will change by year), but the command will always generate a raw "output" template with the suffix of `template.xlsx`. All code assumes you work and save your codebooks in the same `~/Doc` directory.

Duplicate and edit the `template.xlsx` file. Save your new version with the suffix `template-IN-R.xlsx` because this will go into the R script next. If you need help working with `iecodebook`, it was developed internally by an awesome team in DIME, and there are instructions here: https://dimewiki.worldbank.org/Iecodebook. 

## 2. R script, reads `-template-IN-R.xlsx` and writes `-template-IN-S.xlsx`
However for large and complex value labels it's more efficient to harmonize them automatically, which is what the R script does: it reads the output `template-IN-R.xlsx` (which you have edited) from `iecodebook`, creates harmonized value labels, and writes them into the correct place in a **third** copy `-template-IN-S.xlsx`. The "S" indicates that this copy will be read into Stata, and that's how the code in the `.do` file is written.

## 3. Finally, edit the `-template-IN-S.xlsx` to remove NA cells
There's a bug in the workflow -- sorry :( . Open the `-template-IN-S.xlsx` file to the "survey" sheet. Do a "Find and replace" (Control+H) for "NA" and replace with a null string or "" (literally nothing in the second cell). Check the boxes "match case" and "entire cell contents" and do "replace all". Save this copy.

## 4. Resume running the .do file
by pressing 'q' and enter in the console after you've done all the above. I know this is annoying but you have saved yourself hours over doing this entirely manually, and made many fewer errors.