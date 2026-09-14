/*============================================================================== 
  Reconstruct longitudinal panel IDs for Costa Rica ECE

  This helper creates derived IDs only. It preserves hhid and pid as the
  cross-sectional identifiers and detects possible ID reuse across time.
==============================================================================*/

* Confirm the expected cross-sectional identifiers are available.
confirm variable hhid
confirm variable pid
confirm variable year
confirm variable wave
confirm variable age
confirm variable male

* Wave is harmonized as Q1 to Q4; retain a numeric version for time operations.
gen byte wave_num = real(substr(wave, 2, .))
assert inrange(wave_num, 1, 4)
label var wave_num "Numeric survey wave"

* Continuous quarterly time index. 2010 Q3 is the first ECE quarter available.
gen int period = year * 4 + wave_num
gen int time_index = period - (2010 * 4 + 3) + 1
assert time_index >= 1
label var period "Chronological quarterly index"
label var time_index "Sequential ECE quarter index (2010 Q3 = 1)"

* First-pass IDs: the current hhid does not contain the interview quarter.
gen str20 hhid_1 = hhid
gen str2 person_no = substr(pid, -2, 2)
gen str22 pid_1 = hhid_1 + person_no
label var hhid_1 "First-pass household linkage ID"
label var person_no "Roster line number extracted from pid"
label var pid_1 "First-pass person linkage ID"

* Each first-pass person must occur at most once in a survey quarter.
isid pid_1 year wave

*------------------------------------------------------------------------------
* 1. Find consecutive appearances of each first-pass person ID.
*------------------------------------------------------------------------------
sort pid_1 period
by pid_1: gen byte continuous_break = ///
    _n == 1 | period != period[_n - 1] + 1
by pid_1: gen int continuous_run = sum(continuous_break)
label var continuous_break "First appearance after an interrupted quarterly sequence"
label var continuous_run "Consecutive-appearance run within first-pass person ID"

*------------------------------------------------------------------------------
* 2. Identify implausible transitions within consecutive person runs.
*------------------------------------------------------------------------------
sort pid_1 continuous_run period
by pid_1 continuous_run: gen int prev_age = age[_n - 1]
by pid_1 continuous_run: gen byte prev_male = male[_n - 1]
by pid_1 continuous_run: gen int prev_year = year[_n - 1]

* A nonmissing sex change indicates a different person.
gen byte sex_break = !missing(male, prev_male) & male != prev_male

* Allow age to differ from elapsed calendar years by at most one year.
gen byte age_break = !missing(age, prev_age, year, prev_year) & ///
    abs((age - prev_age) - (year - prev_year)) > 1

by pid_1 continuous_run: gen byte person_break = ///
    _n == 1 | sex_break | age_break
label var sex_break "Sex-inconsistent transition within a consecutive run"
label var age_break "Age-inconsistent transition within a consecutive run"
label var person_break "Start of a derived person spell"

*------------------------------------------------------------------------------
* 3. Propagate person-level evidence to the household.
*------------------------------------------------------------------------------
preserve

    keep hhid_1 year wave wave_num period time_index person_break continuous_break

    * A person inconsistency inside a consecutive household sequence starts a
    * new household spell. First appearances alone do not trigger that break.
    gen byte __person_evidence = person_break & !continuous_break
    bysort hhid_1 year wave: egen byte evidence_break = max(__person_evidence)
    bysort hhid_1 year wave: keep if _n == 1
    drop __person_evidence person_break continuous_break

    sort hhid_1 period
    by hhid_1: gen byte time_break = ///
        _n == 1 | period != period[_n - 1] + 1
    gen byte household_break = time_break | evidence_break
    by hhid_1: gen int household_run = sum(household_break)

    * Visit number is derived from observed consecutive household appearances.
    bysort hhid_1 household_run (period): gen int visit_no_derived = _n

    * Panel cohort is the entry quarter of each reconstructed household spell.
    bysort hhid_1 household_run: egen int panel_entry_index = min(time_index)
    gen str8 panel_derived = "D" + string(panel_entry_index, "%03.0f")

    * Prefixing the household run separates later reuses of the same hhid_1.
    gen str25 hhid_2 = string(household_run, "%03.0f") + hhid_1

    label var evidence_break "Household break supported by person-level evidence"
    label var time_break "Household break caused by a gap in quarters"
    label var household_break "Start of a derived household spell"
    label var household_run "Derived spell number within first-pass household ID"
    label var visit_no_derived "Derived visit number within household spell"
    label var panel_derived "Derived household entry cohort (not an official INEC panel ID)"
    label var hhid_2 "Reconstructed longitudinal household ID"

    keep hhid_1 year wave household_run evidence_break time_break ///
         household_break visit_no_derived panel_derived hhid_2
    tempfile household_spells
    save `household_spells'
restore

merge m:1 hhid_1 year wave using `household_spells', nogen

* The reconstructed person ID preserves the household-person relationship.
gen str27 pid_2 = hhid_2 + person_no
label var pid_2 "Reconstructed longitudinal person ID"

*------------------------------------------------------------------------------
* 4. Diagnostics on reconstructed person IDs; these do not create new breaks.
*------------------------------------------------------------------------------
sort pid_2 period
by pid_2: gen byte __pid_2_sex_change = ///
    _n > 1 & !missing(male, male[_n - 1]) & male != male[_n - 1]
by pid_2: gen byte __pid_2_age_break = ///
    _n > 1 & !missing(age, age[_n - 1], year, year[_n - 1]) & ///
    abs((age - age[_n - 1]) - (year - year[_n - 1])) > 1
by pid_2: egen byte pid_2_male_inconsistent = max(__pid_2_sex_change)
by pid_2: egen byte pid_2_age_inconsistent = max(__pid_2_age_break)
by pid_2: egen int pid_2_n_waves = count(period)
gen byte pid_2_more_than_four_waves = pid_2_n_waves > 4

drop __pid_2_sex_change __pid_2_age_break
label var pid_2_male_inconsistent "Reconstructed PID has a remaining sex inconsistency"
label var pid_2_age_inconsistent "Reconstructed PID has a remaining age inconsistency"
label var pid_2_n_waves "Number of observed waves for reconstructed PID"
label var pid_2_more_than_four_waves "Reconstructed PID observed in more than four waves"

* Each reconstructed person-wave must be unique.
isid pid_2 year wave
