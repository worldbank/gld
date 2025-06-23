********************************************************************************
* Creation of Concordance Tables Repository
* 1. Industrial Sections for ISIC Tables
* 2. From local industry codes to ISIC Rev 4
* 3. From local occupation codes to ISCO 08
********************************************************************************

// Setup

*Main Directory: ISCO ISIC Correspondence Tool
*if "`c(username)'" == "raimu" global maindir "D:/Dropbox/Trabajos/World Bank/ISCO ISIC Correspondence Tool/"
if "`c(username)'" == "raimu" global maindir "C:/Users/raimu/Dropbox/Trabajos/World Bank/ISCO ISIC Correspondence Tool/"
if "`c(username)'" == "..."   global maindir "..."

*Working Directories
global outpath "${maindir}Data/Intermediate Data/Concordance Tables/"

// Export Data Program

cap program drop outdata
program define outdata
{
syntax, outname(str)
	save "`outname'", replace
	outsheet using "`outname'.txt", replace delim(";")
}
end

********************************************************************************
* 1. ISIC Industries
********************************************************************************

*ISIC REV 4
local isic_rev4 "http://web.archive.org/web/20190825071008/https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/ISIC_Rev_4_english_structure.Txt"

*ISIC Rev 31
local isic_rev31 "http://web.archive.org/web/20190825070429/https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/ISIC_Rev_3_1_english_structure.txt"

*ISIC Rev 3
local isic_rev3 "http://web.archive.org/web/20190825072508/https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/ISIC_Rev_3_english_structure.txt"

*ISIC Rev 2
local isic_rev2 "http://web.archive.org/web/20190825072508/https://unstats.un.org/unsd/classifications/Econ/Download/In%20Text/ISIC_Rev_3_english_structure.txt"

// ISIC Rev 4

*Stable Source
clear 
insheet using "`isic_rev4'"
keep if _n > 1
gen l = length(v1)
gen isic_rev4_4dig = v1 if l == 4
gen section = v1 if l == 1
destring isic_rev4_4dig, replace force
replace section = section[_n - 1] if mi(section)
drop if mi(isic_rev4_4dig)
sort section, stable
encode section, gen(isic_rev4_secdig)
keep isic_rev4_secdig isic_rev4_4dig
tempfile isic_rev4
save `isic_rev4', replace
outdata, outname(${outpath}isic_rev4)

// ISIC Rev 31

*Stable Source
clear 
insheet using "`isic_rev31'"
keep if _n > 1
gen l = length(v1)
gen isic_rev31_4dig = v1 if l == 4
gen section = v1 if l == 1
destring isic_rev31_4dig, replace force
replace section = section[_n - 1] if mi(section)
drop if mi(isic_rev31_4dig)
sort section, stable
encode section, gen(isic_rev31_secdig)
keep isic_rev31_secdig isic_rev31_4dig
tempfile isic_rev31
save `isic_rev31', replace
outdata, outname(${outpath}isic_rev31)

// ISIC Rev 3

*Stable Source
clear 
insheet using "`isic_rev3'"
split v1, parse(" ")
drop v1
ren v11 v1
keep if _n > 1
gen l = length(v1)
gen isic_rev3_4dig = v1 if l == 4
gen section = v1 if l == 1
destring isic_rev3_4dig, replace force
replace section = section[_n - 1] if mi(section)
drop if mi(isic_rev3_4dig)
sort section, stable
encode section, gen(isic_rev3_secdig)
keep isic_rev3_secdig isic_rev3_4dig
tempfile isic_rev3
save `isic_rev3', replace
outdata, outname(${outpath}isic_rev3)

// ISIC Rev 2

*Stable Source
clear 
insheet using "`isic_rev2'"
split v1, parse(" ")
drop v1
ren v11 v1
keep if _n > 1
gen l = length(v1)
gen isic_rev2_4dig = v1 if l == 4
gen section = v1 if l == 1
destring isic_rev2_4dig, replace force
replace section = section[_n - 1] if mi(section)
drop if mi(isic_rev2_4dig)
sort section, stable
encode section, gen(isic_rev2_secdig)
keep isic_rev2_secdig isic_rev2_4dig
tempfile isic_rev2
save `isic_rev2', replace
outdata, outname(${outpath}isic_rev2)

********************************************************************************
* 2. Direct Industry Concordances Lists 
********************************************************************************

// ISIC Correspondences

*RS: I couldn't work a way to retrieve the tables from the wayback machine rather than the current webpage

*From ISIC Rev 2 to ISIC Rev 3
local isic_rev2_isic_rev3 "https://unstats.un.org/unsd/classifications/Econ/tables/ISIC/ISIC2_ISIC3/ISIC2-ISIC3.txt" // "https://web.archive.org/web/20211230210223/https://unstats.un.org/unsd/classifications/Econ/tables/ISIC/ISIC2_ISIC3/ISIC2-ISIC3.txt"

*From ISIC Rev 2 to ISIC Rev 31
local isic_rev2_isic_rev31 "https://unstats.un.org/unsd/classifications/Econ/tables/ISIC/ISIC2_ISIC31/ISIC_Rev_2-ISIC_Rev_3_1_correspondence.txt" // "http://web.archive.org/web/20190825070618/https://unstats.un.org/unsd/classifications/Econ/tables/ISIC/ISIC2_ISIC31/ISIC_Rev_2-ISIC_Rev_3_1_correspondence.txt"

*From ISIC Rev 3 to ISIC Rev 31
local isic_rev3_isic_rev31 "https://unstats.un.org/unsd/classifications/Econ/tables/ISIC/ISIC31_ISIC3/ISIC_Rev_31-ISIC_Rev_3_correspondence.txt" // "http://web.archive.org/web/20190825070622/https://unstats.un.org/unsd/classifications/Econ/tables/ISIC/ISIC31_ISIC3/ISIC_Rev_31-ISIC_Rev_3_correspondence.txt"

*From ISIC Rev 31 to ISIC Rev 3
local isic_rev31_isic_rev3 "https://unstats.un.org/unsd/classifications/Econ/tables/ISIC/ISIC3_ISIC31/ISIC_Rev_3-ISIC_Rev_3_1_correspondence.txt" // "https://web.archive.org/web/20211230210114/https://unstats.un.org/unsd/classifications/Econ/tables/ISIC/ISIC3_ISIC31/ISIC_Rev_3-ISIC_Rev_3_1_correspondence.txt"

*From ISIC Rev 31 to ISIC Rev 4
local isic_rev31_isic_rev4 "https://unstats.un.org/unsd/classifications/Econ/tables/ISIC/ISIC31_ISIC4/ISIC31_ISIC4.txt" // "http://web.archive.org/web/20190825070712/https://unstats.un.org/unsd/classifications/Econ/tables/ISIC/ISIC31_ISIC4/ISIC31_ISIC4.txt"

*From ISIC Rev 4 to ISIC Rev 31
local isic_rev4_isic_rev31 "https://unstats.un.org/unsd/classifications/Econ/tables/ISIC/ISIC4_ISIC31/ISIC4_ISIC31.txt" // "https://web.archive.org/web/20211230210307/https://unstats.un.org/unsd/classifications/Econ/tables/ISIC/ISIC4_ISIC31/ISIC4_ISIC31.txt"

foreach d in isic_rev2_isic_rev3 isic_rev2_isic_rev31 isic_rev3_isic_rev31 isic_rev31_isic_rev3 isic_rev31_isic_rev4 isic_rev4_isic_rev31{

*Load Data
	clear 
	insheet using ``d''
	tokenize "`d'", parse("_")
	local from = subinstr("`3'","rev","",.)
	local to = subinstr("`7'","rev","",.)
	
*Rename Variables	
	cap ren isic`from' isic_rev`from'_4dig
	if _rc != 0 cap ren rev`from' isic_rev`from'_4dig
	cap ren isic`to' isic_rev`to'_4dig
	if _rc != 0 ren rev`to' isic_rev`to'_4dig
	
*Organize Output	
	keep isic_rev`from'_4dig isic_rev`to'_4dig
	drop if mi(isic_rev`from'_4dig) | mi(isic_rev`to'_4dig)
	bys isic_rev`from'_4dig isic_rev`to'_4dig: keep if _n == 1
	destring isic_rev`from'_4dig isic_rev`to'_4dig, replace force
	
*Merge Sections	
	merge m:1 isic_rev`from'_4dig using "${outpath}isic_rev`from'", keep(master matched) nogen
	merge m:1 isic_rev`to'_4dig using "${outpath}isic_rev`to'", keep(master matched) nogen
	bys isic_rev`from'_4dig isic_rev`to'_4dig: keep if _n == 1	
	outdata, outname(${outpath}from_isic_rev`from'_to_isic_rev`to'_direct)
}

********************************************************************************
* 3. Reverse Industry Concordances Lists 
********************************************************************************

foreach d in 2_3 2_31{
	tokenize "`d'", parse("_")
	local from `1'
	local to `3'
	use "${outpath}from_isic_rev`from'_to_isic_rev`to'_direct", clear
	merge m:1 isic_rev`from'_4dig using "${outpath}isic_rev`from'", keep(master matched) nogen
	merge m:1 isic_rev`to'_4dig using "${outpath}isic_rev`to'", keep(master matched) nogen
	bys isic_rev`from'_4dig isic_rev`to'_4dig: keep if _n == 1		
	outdata, outname("${outpath}from_isic_rev`to'_to_isic_rev`from'_reverse")
}

********************************************************************************
* 4. Indirect Industry Concordances Lists 
********************************************************************************

*From ISIC Rev 2 to ISIC Rev 4, through ISIC Rev 31
use "${outpath}from_isic_rev2_to_isic_rev31_direct", clear
joinby isic_rev31_4dig using "${outpath}from_isic_rev31_to_isic_rev4_direct", unmatched(both)
keep *_rev2_* *_rev4_*
merge m:1 isic_rev2_4dig using "${outpath}isic_rev2", /*keep(master matched)*/ nogen
merge m:1 isic_rev4_4dig using "${outpath}isic_rev4", /*keep(master matched)*/ nogen
keep if !mi(isic_rev2_4dig) & !mi(isic_rev4_4dig)
bys isic_rev2_4dig isic_rev4_4dig: keep if _n == 1
outdata, outname("${outpath}from_isic_rev2_to_isic_rev4_indirect")

*From ISIC Rev 4 to ISIC Rev 2, through ISIC Rev 31
use "${outpath}from_isic_rev4_to_isic_rev31_direct", clear
joinby isic_rev31_4dig using "${outpath}from_isic_rev2_to_isic_rev31_direct", unmatched(both)
keep *_rev2_* *_rev4_*
merge m:1 isic_rev4_4dig using "${outpath}isic_rev4", /*keep(master matched)*/ nogen
merge m:1 isic_rev2_4dig using "${outpath}isic_rev2", /*keep(master matched)*/ nogen
keep if !mi(isic_rev2_4dig) & !mi(isic_rev4_4dig)
bys isic_rev2_4dig isic_rev4_4dig: keep if _n == 1
outdata, outname("${outpath}from_isic_rev4_to_isic_rev2_indirect")

*From ISIC Rev 3 to ISIC Rev 4, through ISIC Rev 31
use "${outpath}from_isic_rev3_to_isic_rev31_direct", clear
joinby isic_rev31_4dig using "${outpath}from_isic_rev31_to_isic_rev4_direct", unmatched(both)
keep *_rev3_* *_rev4_*
merge m:1 isic_rev3_4dig using "${outpath}isic_rev3", /*keep(master matched)*/ nogen
merge m:1 isic_rev4_4dig using "${outpath}isic_rev4", /*keep(master matched)*/ nogen
keep if !mi(isic_rev3_4dig) & !mi(isic_rev4_4dig)
bys isic_rev3_4dig isic_rev4_4dig: keep if _n == 1
outdata, outname("${outpath}from_isic_rev3_to_isic_rev4_indirect")

*From ISIC Rev 4 to ISIC Rev 3, through ISIC Rev 31
use "${outpath}from_isic_rev31_to_isic_rev3_direct", clear
joinby isic_rev31_4dig using "${outpath}from_isic_rev4_to_isic_rev31_direct", unmatched(both)
keep *_rev3_* *_rev4_*
merge m:1 isic_rev4_4dig using "${outpath}isic_rev4", /*keep(master matched)*/ nogen
merge m:1 isic_rev3_4dig using "${outpath}isic_rev3", /*keep(master matched)*/ nogen
keep if !mi(isic_rev4_4dig) & !mi(isic_rev3_4dig)
bys isic_rev4_4dig isic_rev3_4dig: keep if _n == 1
outdata, outname("${outpath}from_isic_rev4_to_isic_rev3_indirect")
