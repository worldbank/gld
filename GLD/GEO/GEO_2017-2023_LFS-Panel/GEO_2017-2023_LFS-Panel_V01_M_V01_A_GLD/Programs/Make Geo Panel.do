
*****************************************
*****************************************
*****       Make GEO Panel         ******
*****************************************
*****************************************

clear all

*********************************
* Append all GEO cases
*********************************

foreach year of numlist 2017/2023 {
	
	append using "C:/Users/wb529026/WBG/GLD - GLD Files/GEO/GEO_`year'_LFS/GEO_`year'_LFS_V01_M_V02_A_GLD/Data/Harmonized/GEO_`year'_LFS_V01_M_V02_A_GLD_ALL.dta"
	
}


*********************************
* Make panel IDs
*********************************

* Make new, "true" hhid
gen first_dash = strpos(hhid, "-")
gen hhid_panel = substr(hhid, 1, first_dash - 1)

* Find second instance for PID
gen second_dash = first_dash + strpos(substr(pid, first_dash + 1, .), "-")
gen hlp_pid_panel = substr(pid, second_dash + 1, .)
egen pid_panel = concat(hhid_panel hlp_pid_panel), punct("-")

*********************************
* Create visit numbers
*********************************

* First make year, quarter information. We need this to be numeric.
* Will make year and quareter infor a decimal point. Not write, but a
* monotonic transformation
gen quarter = wave
replace quarter = quarter/10
gen year_q = year + quarter

bys pid : egen first_appearance = min(year_q)
tab first_appearance

bysort pid_panel (year_q) : gen visit_number = _n
tab visit_number

*********************************
* Check Panel ID
*********************************

gldpanel_id_check, hhid(hhid_panel) pid(pid_panel) 

gldpanel_issue_check, hhid(hhid_panel) pid(pid_panel) 

* There are 12.68% of the PIDs (panel) that have a difference larger than 1.
* This is not odd given that the is a 2 in / 2 out / 2 in setup. Still, evaluate
bys hhid_panel pid_panel : egen earliest_year = min(year)
bys hhid_panel pid_panel year: egen first_wave_year = min(wave)
	
gen agetag = age if year == earliest_year & wave == first_wave_year
bys hhid_panel pid_panel: egen minage = min(agetag)
gen age_d = age - minage
gen diff_age = !(inlist(age_d, 0, 1))
bys hhid_panel pid_panel: egen id_diff_age = max(diff_age)
tab age_d

* Out of the 24,634 diff_age flagged cases, 22,378 are of two years diff (90%)
* The other 10% (2,256) have cases that look like honest mistakes or actual changes in
* the person: see the first and second case of 
list hhid_panel pid_panel year int_year int_month wave age male relationharm earliest_year first_wave_year agetag minage age_d diff_age id_diff_age if inlist(pid_panel, "00144-05", "00174-06")

* Just in case, drop those cases. Note that we are identifying individuals with 
* one such case of difference. Hence more than 2,256 rows will be dropped.
gen diff_age_2 = !(inrange(age_d, 0, 2))
bys hhid_panel pid_panel: egen id_diff_age_2 = max(diff_age_2)
drop if id_diff_age_2 == 1

* Changes in relation with the head are normal if the person moved (to heaven
* or somewhere else), and it is 1.3%. But drop those that change sex
bys hhid_panel pid_panel: egen diff_sex = sd(male)
replace diff_sex = (diff_sex > 0 & !missing(diff_sex))
bys hhid_panel pid_panel: egen id_diff_sex = max(diff_sex)
drop if id_diff_sex == 1

*********************************
* Save output
*********************************

save "C:/Users/wb529026/WBG/GLD - GLD/GEO/GEO_2017-2023_LFS-Panel/GEO_2017-2023_LFS-Panel_V01_M_V01_A_GLD/Data/GEO_2017-2023_LFS-Panel_V01_M_V01_A_GLD_ALL.dta", replace