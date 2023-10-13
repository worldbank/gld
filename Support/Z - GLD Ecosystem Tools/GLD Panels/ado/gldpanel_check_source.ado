capture program drop gldpanel_check_source

program gldpanel_check_source
	
preserve 

* Capture drop
local drop_vars possibletwins twins_runner wave_order diff group_id tag count_tag count_tag_hh mix_up tag_pid count_tag_pid count_tag_pid_panel tag_group num_switch count_member_switch num_distinct_group_id fraction_switches issue_subtype id_diff_age_sex_u agetag minage age_d diff_age id_diff_age id_diff_sex earliest_year first_wave_year count_distinct_group tag_pid_panel

foreach v of local drop_vars {
    capture drop `v'
}

* Add syntax
	 syntax [, hhid(varname) pid(varname) age(varname) sex(varname) wave(varname) year(varname)]
	 
	 * If not specified, default to given variable names
    if "`hhid'" == "" local hhid hhid
    if "`pid'" == "" local pid pid
    if "`age'" == "" local age age
    if "`sex'" == "" local sex male
    if "`year'" == "" local year year
    if "`wave'" == "" local wave wave

quietly{
bys `hhid' `pid' `year': gen first_wave_year = `wave' if _n == 1
replace first_wave_year = first_wave_year[_n-1] if missing(first_wave_year)

bys `hhid' `pid' : egen earliest_`year' = min(`year')
gen `age'tag = `age' if `year' == earliest_`year' & `wave' == first_`wave'_`year'
bys `hhid' `pid': egen min`age' = min(`age'tag)
gen `age'_d = `age' - min`age'
gen diff_`age' = !(inlist(`age'_d, 0, 1))
bys `hhid' `pid': egen id_diff_`age' = max(diff_`age')

* Check if odd_diff is zero, but people have different characteristics
bys `hhid' `pid': egen diff_sex x= sd(`sex')
replace diff_sex = (diff_sex > 0 & !missing(diff_sex))
bys `hhid' `pid': egen id_diff_sex = max(diff_sex)


gen id_diff_`age'_sex_u = (id_diff_`age' == 1 | id_diff_sex == 1)

duplicates tag `hhid' `sex' `age' `wave', gen(possibletwins)

bys `hhid' `age' `sex': gen twins_runner = _n if possibletwins == 1
replace twins_runner = 0 if possibletwins == 0
 
* Generate a new variable 'group_id' to identify the start of each group of consecutive `wave's
capture confirm string variable `wave'
if _rc == 0 {
	* Sort your data by `hhid' and `wave'
	sort `hhid' `pid' `year' `wave'

	* Generate a `wave'_order variable
	bysort `hhid' `pid' `year': gen `wave'_order = _n	
}

else{
	gen `wave'_order = `wave'
}

sort  `hhid'  twins_runner `sex' `age' `year' `wave'   

gen diff = `wave'_order - `wave'_order[_n-1] if _n > 1
replace diff = 0 if `wave'_order == 1

* This code works only if there is a valid re-use of `pid' between `year's -- that is not the case for MNG
replace diff = 1 if `wave'_order == 1 & (`age' - `age'[_n-1]== 0 | `age' - `age'[_n-1] == 1) & (`sex' == `sex'[_n-1])
replace diff = 1 if inrange(diff, 2, 4)
replace diff = 0 if diff < 0 
bys `hhid' twins_runner `male': replace diff = 0 if abs(`age' - `age'[_n-1]) > 1 & `wave'_order!= 1

gen group_id = sum(diff != 1)


************************************************************************
* Identify mixed up hhs and potential break in HH in the dwelling
************************************************************************
egen tag = tag(group_id `pid')
bys group_id: egen count_tag = total(tag)
bys `hhid': egen count_tag_hh = max(count_tag)
gen mix_up = count_tag_hh > 1
distinct `hhid' if mix_up == 1
distinct `hhid'

egen tag_`pid' = tag(`pid' group_id)
bys `pid': egen count_tag_`pid' = total(tag_`pid')

sort `year' `hhid' `pid' 
duplicates tag group_id, gen(tag_group)
bys `hhid': egen count_distinct_group = total(tag_group)

bys `hhid' `pid': egen num_switch = nvals(group_id)
bys `hhid' `pid': replace num_switch = . if _n!=1
replace num_switch = . if num_switch == 1

bys `hhid': egen count_member_switch = sum(num_switch)
bys `hhid': egen num_distinct_group_id = nvals(group_id)
gen fraction_switches = count_member_switch/num_distinct_group_id

gen issue_subtype = 1 if mix_up == 1
replace issue_subtype = 2 if mix_up == 0 & fraction_switches == 1
replace issue_subtype = 3 if mix_up == 0 & fraction_switches>0 & fraction_switches < 1
*replace issue_subtype = 4 if id_diff_`age'_sex_u == 1 & missing(issue_subtype)

replace issue_subtype = . if id_diff_`age'_sex_u == 0

collapse (max) issue_subtype id_diff_`age'_sex_u, by(`pid')
gen indcount = 1

collapse (sum) indcount, by(issue_subtype id_diff_`age'_sex_u)

egen tot_ind = sum(indcount) if !missing(issue_subtype)
levelsof tot_ind, local(tot_ind)
label var indcount

label define lblissue_subtype 1 "Roster mix-up" 2 "Same ID for diff HH" 3 "HH composition change"
label values issue_subtype lblissue_subtype

graph hbar (sum) indcount, over(issue_subtype) ///
 title("Source of mismatch: ${country}") subtitle("") graphregion(color(white)) ylabel(, nogrid) ytitle("Number of individuals (total = `tot_ind')") ///
 note("Based on the universe of age OR sex mismatch." "Discrepancies from total arise when it is difficult to determine"  "the source of mismatch: e.g., age falls by one year in a revisit")

local drop_vars possibletwins twins_runner wave_order diff group_id tag count_tag count_tag_hh mix_up tag_pid count_tag_pid count_tag_pid_panel tag_group num_switch count_member_switch num_distinct_group_id fraction_switches issue_subtype id_diff_age_sex_u agetag minage age_d diff_age id_diff_age id_diff_sex earliest_year first_wave_year count_distinct_group tag_pid_panel

* Ensure none of the created variables created are left
foreach v of local drop_vars {
    capture drop `v'
}
	restore
	}
	
end
