
***************************************
** Code for IND PLFS Urban Panel     **
** Assess Panel Quality              **
***************************************


*---------- Age sex matches ------------------------------*
gldpanel_issue_check, hhid(hhid_panel) pid(pid_panel)
graph export "${path_work}/age_sex_matches.png", replace

*---------- Sources of mismatch ------------------------------*
gldpanel_check_source, hhid(hhid_panel) pid(pid_panel)
graph export "${path_work}/source_mismatches.png", replace

*---------- PID Attrition ------------------------------*
* Case of India, change wave so that it runs in sets of four
gen tempwave = wave
replace tempwave = "Q1" if wave == "Q5"
replace tempwave = "Q2" if wave == "Q6"
replace tempwave = "Q3" if wave == "Q7"
replace tempwave = "Q4" if wave == "Q8"

gldpanel_attrition, hhid(hhid_panel) pid(pid_panel) wave(tempwave) consecutive_waves
graph export "${path_work}/attrition_consecutive_waves.png", replace

gldpanel_attrition, hhid(hhid_panel) pid(pid_panel) wave(tempwave) any_wave
graph export "${path_work}/attrition_any_wave.png", replace

gldpanel_attrition, hhid(hhid_panel) pid(pid_panel) wave(tempwave) all_waves
graph export "${path_work}/attrition_all_waves.png", replace
