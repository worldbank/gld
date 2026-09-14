/*============================================================================== 
  06: Panel quality diagnostics

  Prerequisite: the appended data are in memory and 05 has created hhid_2,
  pid_2, visit_no_derived, panel_derived, wave_num, and period.
  This file produces diagnostic output and graphs only; it does not save a .dta.
==============================================================================*/

* Check that household-wave information maps to one derived visit number.
gldpanel_wave_visit_check, ///
    hhid(hhid_2) year(year) wave(wave_num) ///
    visit_no(visit_no_derived)
capture drop vw_tag

* Check for reconstructed-ID reuse outside consecutive survey years.
gldpanel_id_check, ///
    hhid(hhid_2) pid(pid_2) ///
    year(year) wave(wave_num)

isid pid_2 year wave

* Inspect the derived entry cohorts.
levelsof panel_derived, local(panels)
foreach p of local panels {
    display "Derived panel: `p'"
    tab year wave if panel_derived == "`p'"
}

/*============================================================================== 
  Quality graphs
==============================================================================*/

* GLD diagnostics require a numeric variable named wave. Keep the standardized
* Q1-Q4 wave variable intact by restoring it immediately after the tests.
rename wave wave_label
rename wave_num wave

*----------Age-sex matches-----------------------------------------------------*
gldpanel_issue_check, hhid(hhid_2) pid(pid_2)
graph export "${path_work}/age_sex_matches.png", replace

*----------Sources of mismatch-------------------------------------------------*
gldpanel_check_source, hhid(hhid_2) pid(pid_2)
graph export "${path_work}/source_mismatches.png", replace

*----------PID attrition-------------------------------------------------------*
gldpanel_attrition, hhid(hhid_2) pid(pid_2) wave(wave) ///
    visit_no(visit_no_derived) consecutive_waves
graph export "${path_work}/attrition_consecutive_waves.png", replace

gldpanel_attrition, hhid(hhid_2) pid(pid_2) wave(wave) ///
    visit_no(visit_no_derived) any_wave
graph export "${path_work}/attrition_any_wave.png", replace

gldpanel_attrition, hhid(hhid_2) pid(pid_2) wave(wave) ///
    visit_no(visit_no_derived) all_waves
graph export "${path_work}/attrition_all_waves.png", replace

* Restore the standard harmonized wave variable for the final dataset.
rename wave wave_num
rename wave_label wave
