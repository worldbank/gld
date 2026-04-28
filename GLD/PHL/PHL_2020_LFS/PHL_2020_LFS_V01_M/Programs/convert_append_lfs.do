clear
set more off
set mem 800m
set varabbrev off

if "`c(username)'" == "wb510859" {
	local server "C:/Users/`c(username)'/OneDrive - WBG/GLD - Current Contributors/510859_AS"
}
else {
	local server "C:/Users/`c(username)'/WBG/GLD - Current Contributors/510859_AS"
}
local country "PHL"
local year    "2020"
local survey  "LFS"
local vermast "V01"

local level_1      "`country'_`year'_`survey'"
local level_2_mast "`level_1'_`vermast'_M"

local path_in_stata "`server'/`country'/`level_1'/`level_2_mast'/Data/Stata"
local path_in_other "`server'/`country'/`level_1'/`level_2_mast'/Data/Original"

* Files were originally downloaded as a set of zip files representing each survey month
* Convert each csv file into Stata, rename then append

local months January April July October

tempfile master

foreach month of local months {
    local filename "LFS PUF `month' 2020"
    
	capture confirm file "`path_in_other'/`filename'.csv"
	
	if _rc==0 {
	display "`filename' exists"
    * Import the CSV file
    import delimited "`path_in_other'/`filename'.csv", clear stringcols(_all)
	
	}
	
	else {
	display "use alternative filename"
	import delimited "`path_in_other'/`filename' - HHMEM.csv", clear stringcols(_all)

	}
	capture confirm variable pufc09a_work
	if _rc == 0 {
		ren pufc09a_work pufc09a_arrangement
	}
	* Loop over all variables in the dataset
	foreach var of varlist _all {
		* Check if the variable name contains an underscore
		if strpos("`var'", "_") > 0 {
			* Extract the part of the variable name after the underscore
			local newname = substr("`var'", strpos("`var'", "_") + 1, .)
			
			capture confirm variable `newname'
        
			* If the variable exists (_rc is 0), append "1" to the new variable name
			if _rc == 0 {
				local newname = "`newname'1"
			}
			* Rename the variable to this new name
			rename `var' `newname'
		}
		* If no underscore is found, do nothing (retain the original name)
	}
	
	    
    * Append the data to a master dataset
    if "`month'" == "January" {
        * If this is the first file, simply rename it to the master dataset
        save `master'
    }
    else {
        * For subsequent files, append them to the master dataset
        append using `master'
		save `master', replace
    }

	display "`month' appended"
}

foreach var of varlist pufreg pufurb2015-pufsvyyr pufnewempstat pufrpl-wqtr{
	destring `var', replace
}

* Label the variables
* Variable: pufurb2015_vs1 - 2015Urban-RuralFIES

label variable pufurb2015 "2015Urban-RuralFIES"
label define pufurb2015lbl 1 "Urban" 2 "Rural" 
label values pufurb2015 pufurb2015lbl

* Variable: pufsvymo_vs1 - Survey Month
label variable pufsvymo "Survey Month"
label define pufsvymolbl 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August"  9 "September" 10 "October" 11 "November" 12 "December"
label values pufsvymo pufsvymolbl

* Variable: pufc01_lno_vs1 - C101-Line Number
label variable lno "C101-Line Number"

*Label definitions for 'wynot'
label variable wynot "C26-Reason for not Looking for Work"

label define wynot_lbl 0 "ECQ/Lockdown/Covid-19 Pandemic" ///
1 "Tired/Believe no Work Available" ///
2 "Awaiting Results of Previous Job Application" ///
3 "Temporary Illness/Disability" ///
4 "Bad Weather" ///
5 "Wait for rehire/Job Recall" ///
61 "Too young/old" ///
62 "Retired" ///
63 "Permanent disability" ///
7 "Household, family duties" ///
8 "Schooling" ///
9 "Others"

label values wynot wynot_lbl

label var pocc "Previous occupation"
label var procc "Present occupation"
label var pkb "Present industry"
label var qkb "Previous industry"
* Variable: sex
label variable sex "C04-Sex"
label define sex 1 "Male" 2 "Female" 
label values sex sex


* Variable: pufc06_mstat_vs1 - C06-Marital Status
label variable mstat "C06-Marital Status"
label define mstat 1 "Single" 2 "Married" 3 "Widowed" 4 "Divorce/Separate" 5 "Annulled" 6 "Unknown" 
label values mstat mstat

* Variable: pufc10_conwr_vs1 - C10-Overseas Filipino Indicator
label variable conwr "C10-Overseas Filipino Indicator"
label define conwr 1 "Overseas Contract Workers" 2 "Workers other than OCW" 3 "Employees in Philippine Embassy, Consulates & other Missions" 4 "Students abroad/Tourists" 5 "Resident" 
label values conwr conwr


* Variable: pufc11_work_vs1 - C11-Work Indicator
label variable work "C11-Work Indicator"
label define work 1 "YES" 2 "NO" 
label values work work

* Variable: pufc17_natem_vs1 - C17-Nature of Employment (Primary Occupation)
label variable natem "C17-Nature of Employment (Primary Occupation)"
label define natem 1 "Permanent Job/Business/Unpaid Family Work" 2 "Short-Term/Seasonal Job/Business/Unpaid Family Work" 3 "Worked for Different Employers on Day to Day or Week to Week Basis" 
label values natem natem

* Variable: pufc12_job_vs1 - C12-Job Indicator
label variable job "C12-Job Indicator"
label define job 1 "yes" 2 "no" 3 "no, temporarily" 
label values job job

* Variable: pufc20_pwmore_vs1 - C20-Want More Hours of Work
label variable pwmore "C20-Want More Hours of Work"
label define pwmore 1 "yes" 2 "no" 
label values pwmore pwmore

* Variable: pufc21_pladdw_vs1 - C21-Look for Additional Work
label variable pladdw "C21-Look for Additional Work"
label define pladdw 1 "yes" 2 "no" 
label values pladdw pladdw

* Variable: pufc08_cursch_vs1 - C08-Currently Attending School
label variable cursch "C08-Currently Attending School"
label define cursch 1 "yes" 2 "no" 
label values cursch cursch

* Variable: pufc09_gradtech_vs1 - C09-Graduate of technical/vocational course
label variable gradtech "C09-Graduate of technical/vocational course"
label define gradtech 1 "yes" 2 "no" 
label values gradtech gradtech

* Variable: pufc09a_nformal_vs1 - C09a - Currently Attending Non-formal Training for Skills Development
label variable nformal "C09a - Currently Attending Non-formal Training for Skills Development"
label define nformal 1 "Yes" 2 "No" 
label values nformal nformal

* Label definitions for 'wwm48h'
label variable wwm48h "C29-Reasons for Working More than 48 Hours during the past week"

label define wwm48h_lbl 11 "Wanted more earnings" ///
12 "Requirements of the job" ///
13 "Exceptional week" ///
14 "Ambition, passion for job" ///
15 "ECQ/Lockdown/Covid-19 Pandemic" ///
19 "Other reasons" ///
20 "Variable working time / nature of work" ///
21 "Holidays" ///
22 "Poor business condition" ///
23 "Reduction in clients / work" ///
24 "Low or off season" ///
25 "Bad weather, natural disaster" ///
26 "Strike or labour dispute" ///
27 "Start / end / change of job" ///
28 "Could only find part time work" ///
29 "School training" ///
30 "Personal / family reasons" ///
31 "Health / medical limitations" ///
32 "ECQ/Lockdown/Covid-19 Pandemic" ///
39 "Other reasons, specify"

label values wwm48h wwm48h_lbl

* Variable: pufc22_pfwrk_vs1 - C22-First Time to Work
label variable pfwrk "C22-First Time to Work"
label define pfwrk 1 "yes" 2 "no" 
label values pfwrk pfwrk

* Variable: pufc19_phours_vs3 - Total Hours Worked
label variable phours "Total Hours Worked in the past week"

* Variable: pufc23_pclass_vs1 - C23-Class of Worker (Primary Occupation)
label variable pclass "C23-Class of Worker (Primary Occupation)"
label define pclass 0 "Private Household" 1 "Private Establishment" 2 "Gov't/Gov't Corporation" 3 "Self Employed" 4 "Employer" 5 "With pay (Family owned Business)" 6 "Without Pay (Family owned Business)" 
label values pclass pclass

* Variable: pufc26_ojob_vs1 - C26-Other Job Indicator
label variable ojob "C26-Other Job Indicator"
label define ojob 1 "Yes" 2 "No" 
label values ojob ojob

* Variable: pufc24_pbasis_vs1 - C24-Basis of Payment (Primary Occupation)
label variable pbasis "C24-Basis of Payment (Primary Occupation)"
label define pbasis 0 "In Kind only" 1 "Per piece" 2 "Per Hour" 3 "Per Day" 4 "Monthly" 5 "Pakyaw" 6 "Other S./Wages" 7 "Not salaries/wages(Commission Basis)" 
label values pbasis pbasis

* Variable: pufc30_lookw_vs1 - C30-Looked for Work or Tried to Establish Business during the past week
label variable lookw "C30-Looked for Work or Tried to Establish Business during the past week"
label define lookw 1 "yes" 2 "no" 
label values lookw lookw

* Variable: pufc36_avail_vs1 - C36-Available for Work
label variable avail "C36-Available for Work"
label define avail 1 "yes available" 2 "not available" 
label values avail avail

* Variable: pufc38_prevjob_vs1 - C38-Previous Job Indicator
label variable prevjob "C38-Previous Job Indicator"
label define prevjob 1 "yes" 2 "no" 
label values prevjob pufc38_prevjob_vs1_lbl

* Variable: pufnewempstat_vs1 - New Employment Criteria (jul 05, 2005)
label variable pufnewempstat "New Employment Criteria (jul 05, 2005)"
label define pufnewempstat 1 "EMPLOYED" 2 "UNEMPLOYED" 3 "NOT IN THE LABOR FORCE" 
label values pufnewempstat pufnewempstat

* Variable: pufc35_ltlookw_vs1 - C35-When Last Looked for Work
label variable ltlookw "C35-When Last Looked for Work"
label define ltlookw 1 "Within last month" 2 "One to six months ago" 3 "More than six months ago" 
label values ltlookw ltlookw

* Variable: pufc37_willing_vs1 - C37-Willingness to take up work during the past week or withing two weeks
label variable willing "C37-Willingness to take up work during the past week or withing two weeks"
label define willing 1 "yes" 2 "no" 
label values willing willing

* Variable: pufc27_njobs_vs1 - C27-Number of Jobs during the past week
label variable njobs "C27-Number of Jobs during the past week"
label define njobs 0 "valid" 
label values njobs njobs

* Variable: pufc28_thours_vs1 - C28-Total Hours Worked for all Jobs
label variable thours "C28-Total Hours Worked for all Jobs"

* Variable: pufc31_flwrk_vs1 - C31-First Time to Look for Work
label variable flwrk "C31-First Time to Look for Work"
label define ftwork1 1 "yes" 2 "no" 
label values flwrk ftwork1

* Variable: pufc32_jobsm_vs1 - C32-Job Search Method
label variable jobsm "C32-Job Search Method"
label define jobsm 1 "registered in public employment agency" 2 "registered in private employment agency" 3 "approached employer directly" 4 "approached relatives or friends" 5 "placed or answered advertisements" 6 "others" 
label values jobsm jobsm

* Variable: weeks - Number of Weeks Looking for Work
label variable weeks "Number of Weeks Looking for Work"
label define weeks 1 "less than 4" 4 "4  to  9" 10 "10 to 19" 20 "20 and over" 
label values weeks weeks

* Region
label variable pufreg "Region"

label define pufreg_lbl 1 "Region I (Ilocos Region)" ///
2 "Region II (Cagayan Valley)" 3 "Region III (Central Luzon)" ///
4 "Region IV-A (CALABARZON)" 5 "Region V (Bicol Region)" ///
6 "Region VI (Western Visayas)" 7 "Region VII (Central Visayas)" ///
8 "Region VIII (Eastern Visayas)" 9 "Region IX (Zamboanga Peninsula)" ///
10 "Region X (Northern Mindanao)" 11 "Region XI (Davao Region)" ///
12 "Region XII (SOCCSKSARGEN)" 13 "National Capital Region (NCR)" ///
14 "Cordillera Administrative Region (CAR)" 15 "Autonomous Region in Muslim Mindanao (ARMM)" ///
16 "Region XIII (Caraga)" 17 "MIMAROPA Region"

label values pufreg pufreg_lbl

* Label definitions for 'rel'
label variable rel "C03-Relationship to Household Head"
label define rel_lbl 1 "Head" 2 "Wife/Spouse" 3 "Son/daughter" ///
4 "Brothers/sisters" 5 "Son/daughter_law" 6 "Grandchildren" ///
7 "Father/Mother" 8 "Other Relative" 9 "Boarder" 10 "Domestic Helper" ///
11 "Non_Relative"
label values rel rel_lbl


save "`path_in_stata'/PHL_LFS_2020.dta", replace
