* Step 1 - Read in version from datalibweb
cap datalibweb, country(COL) year(2022) type(GMD) vermast(V01) veralt(V02) survey(GEIH) module(ALL) clear

* Step 2 - Create additional variables we may need
*<_harmonization_>
	cap drop harmonization
	gen harmonization = "GLD-Light"
	label var harmonization "Type of harmonization"
*</_harmonization_>
*<_weight_>
	* Weight is at times weight_p / weight_h in GMD surveys - often both and the same
	* Process is to
	*	1) Check if weight on its own present, nothing if yes
	*	2) If not present, check whether _p present, convert to weight
	*	3) If _p neither, check _h, convert to weight
	cap confirm variable weight
	if _rc != 0 {
		cap confirm variable weight_p
		if _rc == 0 {
			rename weight_p weight
		}
		else {
			cap confirm variable weight_h
			if _rc == 0 {
				rename weight_h weight
			}
		}
	}
	cap label var weight "Survey sampling weight"
*</_weight_>

* Step 3 -  Reduce to GLD dictionary
local keeplist "countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight weight_m weight_q psu ssu strata wave panel visit_no urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome"
local vars_to_keep ""
foreach var of local keeplist {
    cap confirm variable `var'
    if !_rc local vars_to_keep "`vars_to_keep' `var'"
}
dis "`vars_to_keep'"
* Keep only those variables (if any exist)
if "`vars_to_keep'" != "" {
    keep `vars_to_keep'
}
else {
    display as error "None of the variables in the keeplist exist in the dataset"
}

* Step 4 - Save
save "C:/Users/wb529026/WBG/GLD - GLD Files/COL/COL_2022_GEIH/COL_2022_GEIH_V01_M_V01_A_GLD/Data/Harmonized/COL_2022_GEIH_V01_M_V01_A_GLD_ALL.dta", replace
