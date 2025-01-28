
***************************************
** Code for MEX ENOE Panel           **
** Create the panel vars from the    **
** appended file                     **
***************************************


*<_panel_>

	capture confirm variable panel
	if _rc==0 {
		display "panel is already available in the data. Do not create"
	}
	
*</_panel_>

*<_visit_no_>

	capture confirm variable visit_no
	if _rc==0 {
		display "visit_no is already available in the data. Do not create"
	}
		
*</_visit_no_>

*<_type_of_interview_>
	* type of interview introduced in covid times
	replace type_of_interview = 1 if mi(type_of_interview)
*</_type_of_interview_>

	* Make type, panel string
	tostring type_of_interview, gen(type_str) format("%01.0f")
	tostring panel, gen(panel_str) format("%02.0f")

*<_hhid_panel_>
	gen hhid_panel = hhid + type_str + panel_str
	label var hhid_panel "Household ID (panel)"
*</_hhid_panel_>

*<_pid_panel_>

* Create PID variable adding panel information
	* First extract the individual number
	gen rosternum = substr(pid, -2, 2)
	gen pid_panel = hhid_panel + rosternum
	drop rosternum
	
	*isid pid_panel wave
	label var pid_panel "Person ID (panel)"
*</_pid_panel_>

* Clean up

quietly{

order panel, before(visit_no)
order hhid_panel, after(hhid)
order pid_panel, after(pid)

}

* Regular diagnostic was designed for cases with four quarters
* Diagnostic: Check for re-use of HHID outside panel
*gldpanel_id_check, hhid(hhid_panel) pid(pid_panel)

* No person should be in the survey more than five times
cap drop runner
bys pid_panel (int_year wave) : gen runner = _n
quietly: summ runner
assert `r(max)' == 5

* Check changes in sex
bys pid_panel: egen sd_male = sd(male)
* 1031 cases with changes, look like errors

* Create weights for 2020
* 2020 is a special case since we have q1 from one survey q3 and 4 from ENOE-N 
gen help_1 = 1 if year == 2020
egen help_2 = total(help_1) if year == 2020
bys wave : egen help_3 = total(help_1) if year == 2020
gen help_4 = help_3/help_2
replace weight = weight_q*help_4 if year == 2020
drop help_*

* Check
/*
preserve
gen w = weight/1000000
collapse (sum) w, by(year)
list
restore
*/

* Check age diff
bys pid_panel (int_year wave) : egen age_min = min(age)
bys pid_panel (int_year wave) : egen age_max = max(age)
gen age_diff = age_max - age_min
tab age_diff
* 4386 cases with an age diff greater than 2


* Clean up
drop if mi(age)
drop if inrange(sd_male, 0.01, 1)