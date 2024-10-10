clear 

*---- Append 2014 to 2022 data
foreach year of numlist 2014/2022 {
	
	append using "Y:/GLD/ARM/ARM_`year'_LFS\ARM_`year'_LFS_V01_M_V03_A_GLD/Data/Harmonized/ARM_`year'_LFS_V01_M_V03_A_GLD_ALL.dta" 
	
	
}

*---- Create variables for comparison
gen     lfp_old_series = .
replace lfp_old_series = weight            if inlist(lstatus,1,2) & inrange(year,2014,2017)
replace lfp_old_series = weight_old_series if inlist(lstatus,1,2) & inrange(year,2018,2019)

gen     wap_old_series = .
replace wap_old_series = weight            if inlist(lstatus,1,2,3) & inrange(year,2014,2017)
replace wap_old_series = weight_old_series if inlist(lstatus,1,2,3) & inrange(year,2018,2019)

gen     lfp_new_series = .
replace lfp_new_series = weight            if inlist(lstatus,1,2) & inrange(year,2018,2022)

gen     wap_new_series = .
replace wap_new_series = weight            if inlist(lstatus,1,2,3) & inrange(year,2018,2022)

gen     lfp_cmb_series = .
replace lfp_cmb_series = weight            if inlist(lstatus,1,2)

gen     wap_cmb_series = .
replace wap_cmb_series = weight            if inlist(lstatus,1,2,3)


*---- Collapse data to get by year
collapse (sum) lfp_* wap_*, by(year)

// Loop through all variables in the dataset
foreach var of varlist * {
    // Replace 0 with missing value (.)
    replace `var' = . if `var' == 0
}
*list

*---- Add in official data

gen lfp_off = .
replace lfp_off = 1375700 if year == 2014
replace lfp_off = 1316400 if year == 2015
replace lfp_off = 1226300 if year == 2016
replace lfp_off = 1230700 if year == 2017
replace lfp_off = 1293800 if year == 2018
replace lfp_off = 1318100 if year == 2019
replace lfp_off = 1286700 if year == 2020
replace lfp_off = 1287300 if year == 2021
replace lfp_off = 1311300 if year == 2022
 

*---- Plot

// Determine the range of years
summarize year
local min_year = r(min)
local max_year = r(max)

twoway (line lfp_old_series year) (line lfp_new_series year) (line lfp_off year), ///
    title("Plot of ARM LFP over years by weight variable") ///
     xlabel(`min_year'(1)`max_year', grid) ylabel(, grid) ///
    legend(order(1 "LFP with weight 204-17, old weigth 2018-19" 2 "LFP with weight 2018-2022" 3 "LFP ARMSTAT Data") ///
	position(6) row(3))
	
gr export "Y:/GLD/ARM/ARM_2022_LFS/ARM_2022_LFS_V01_M_V03_A_GLD/Work/weight_timelines.png", replace	
