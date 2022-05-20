/*==================================================
project:       Define lists of vars for Q checks
Author:        Mario Gronert 
E-email:       mgronert@worldbank.org
url:           
Dependencies:  
----------------------------------------------------
Creation Date:    22 Jan 2021
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              1: All vars
==================================================*/

global all_vars countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight psu strata wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

/*==================================================
              2: All numeric vars
==================================================*/

global numeric_vars year int_year int_month weight urban gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_financed minlaborage lstatus nlfreason unempldur_l unempldur_u empstat ocusec industrycat10 industrycat4 occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industrycat10_2 industrycat4_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industrycat10_year industrycat4_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industrycat10_2_year industrycat4_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

/*==================================================
              3: All string vars
==================================================*/

global string_vars countrycode survname survey icls_v isced_version isco_version isic_version vermast veralt harmonization hhid pid subnatid1 subnatid2 subnatid3 subnatid1_prev subnatid2_prev subnatid3_prev subnatidsurvey migrated_from_country vocational_field_orig industrycat_isic occup_isco industrycat_isic_2 occup_isco_2 industrycat_isic_year occup_isco_year industrycat_isic_2_year occup_isco_2_year
   
/*==================================================
              4: Vars that do not change
==================================================*/

global invariant_vars countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization migrated_ref_time minlaborage

/*==================================================
              5: Vars that should change
==================================================*/

global change_should_vars weight strata wave psu urban subnatid1 subnatid2 subnatid3 subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason school literacy educy educat7 educat5 educat4 vocational vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed lstatus nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isic occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isic_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isic_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isic_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

/*==================================================
              6: Vars that do not change within HH
==================================================*/

* Note, vars that should not change at all are not included since they are already covered
* e.g., if countrycode is not unique, that is caught in 4, if varies within HH redundant.
global hh_level_vars int_year int_month hhid weight strata wave psu urban subnatid1 subnatid2 subnatid3 subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize

/*==================================================
              7: Categorical variables
==================================================*/

*----------7.1: Categorical - 0 / 1
global cat_0_1 urban male migrated_binary school literacy vocational contract healthins socialsec union contract_year healthins_year socialsec_year union_year

*----------7.2: Categorical - 1 / 3
global cat_1_3 lstatus lstatus_year

*----------7.3: Categorical - 1 / 4
global cat_1_4 eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty educat4 ocusec industrycat4 ocusec_2 industrycat4_2 ocusec_year industrycat4_year ocusec_2_year industrycat4_2_year

*----------7.4: Categorical - 1 / 5
global cat_1_5 marital migrated_from_cat migrated_reason educat5 vocational_financed nlfreason empstat empstat_2 nlfreason_year empstat_year empstat_2_year

*----------7.5: Categorical - 1 / 6
global cat_1_6 relationharm

*----------7.6: Categorical - 1 / 7
global cat_1_7 educat7

*----------7.7: Categorical - 1 / 10
global cat_1_10 industrycat10 unitwage industrycat10_2 unitwage_2 industrycat10_year unitwage_year industrycat10_2_year unitwage_2_year

*----------7.8: Categorical - 1 / 10 + 99
global cat_1_10_99 occup occup_2 occup_year occup_2_year

*----------7.9: Categorical - 1 / 12
global cat_1_12 int_month wmonths wmonths_2 wmonths_year wmonths_2_year

*----------7.10: Categorical - 1 / 84
global cat_1_84 whours whours_2 whours_year whours_2_year

*----------7.11: Categorical - 1 / 3120
global cat_1_3120 t_hours_others t_hours_total t_hours_others_year t_hours_total_year t_hours_annual

* global containing list names
global cat_list_names cat_0_1 cat_1_3 cat_1_4 cat_1_5 cat_1_6 cat_1_7 cat_1_10 cat_1_10_99 cat_1_12 cat_1_84 cat_1_3120

/*==================================================
              8: Consistency Survey & ID Module
==================================================*/

*----------8.1: Three letter strings
global surv_str3 countrycode vermast veralt

/*==================================================
              9: Consistency Geography Module
==================================================*/

*----------9.1: Admin ID structure
global subnat_hierarchy ""subnatid1 subnatid2 subnatid3" "subnatid1_prev subnatid2_prev subnatid3_prev" "gaul_adm1_code gaul_adm2_code gaul_adm3_code""

/*==================================================
              10: Consistency Demography Module
==================================================*/

/*==================================================
              11: Consistency Migration Module
==================================================*/

*----------11.1: Questions not posed if migrated_binary is No
global never_migrated migrated_years migrated_from migrated_from_cat migrated_from_code migrated_from_country migrated_reason
 
/*==================================================
              12: Consistency Education Module
==================================================*/

/*==================================================
              13: Consistency Training Module
==================================================*/

*----------13.1: Questions not posed if migrated_binary is No
global never_trained vocational_type vocational_length_l vocational_length_u vocational_field_orig vocational_financed

/*==================================================
              14: Consistency Labour Module
==================================================*/

*----------14.1: Questions not posed to unemployed 7 day ref
global not_posed_unemployed_week nlfreason empstat ocusec industry_orig industry_orig_v industrycat_isic industrycat_isic_v industrycat10 industrycat4 occup_orig occup_orig_v occup_isco occup_isco_v occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industry_orig_v_2 industrycat_isic_2 industrycat_isic_v_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_orig_v_2 occup_isco_2 occup_isco_v_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total

*----------14.2: Questions not posed to unemployed 12 month ref
global not_posed_unemployed_year nlfreason_year empstat_year ocusec_year industry_orig_year industry_orig_v_year industrycat_isic_year industrycat_isic_v_year industrycat10_year industrycat4_year occup_orig_year occup_orig_v_year occup_isco_year occup_isco_v_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industry_orig_v_2_year industrycat_isic_2_year industrycat_isic_v_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_orig_v_2_year occup_isco_2_year occup_isco_v_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year

*----------14.3: Questions not posed to NLF individuals 7 day ref
global not_posed_nlf_week unempldur_l unempldur_u empstat ocusec industry_orig industry_orig_v industrycat_isic industrycat_isic_v industrycat10 industrycat4 occup_orig occup_orig_v occup_isco occup_isco_v occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industry_orig_v_2 industrycat_isic_2 industrycat_isic_v_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_orig_v_2 occup_isco_2 occup_isco_v_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total

*----------14.4: Questions not posed to NLF individuals 12 month ref
global not_posed_nlf_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industry_orig_v_year industrycat_isic_year industrycat_isic_v_year industrycat10_year industrycat4_year occup_orig_year occup_orig_v_year occup_isco_year occup_isco_v_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industry_orig_v_2_year industrycat_isic_2_year industrycat_isic_v_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_orig_v_2_year occup_isco_2_year occup_isco_v_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year

*----------14.5: Industry 10 and 4 catgories concordance
global industry_cat_concordance ""industrycat10 industrycat4" "industrycat10_2 industrycat4_2" "industrycat10_year industrycat4_year" "industrycat10_2_year industrycat4_2_year""

*----------14.6: ISIC codes check
global isic_check industrycat_isic industrycat_isic_2 industrycat_isic_year industrycat_isic_2_year

*----------14.7: ISCO codes check
global isco_check occup_isco occup_isco_2 occup_isco_year occup_isco_2_year

*----------14.8: Check industry_orig to industrycat10 agreements
global industry_alignment `""industry_orig industrycat10" "industry_orig_2 industrycat10_2" "industry_orig_year industrycat10_year" "industry_orig_2_year industrycat10_2_year""'

*----------14.9: Check wage has always unitwage info tied to it
global wage_and_unit `""wage_no_compen unitwage" "wage_no_compen_2 unitwage_2" "wage_no_compen_year unitwage_year" "wage_no_compen_2_year unitwage_2_year""'


/*==================================================
              15: Dynamic comparison vars
==================================================*/

global dynamic_graph_vars = "educat7 educat5 educat4 educat_isced industrycat10 industrycat4 industrycat10_2 industrycat4_2 industrycat10_year industrycat4_year industrycat10_2_year industrycat4_2_year"

/*==================================================
              16: International classification version
==================================================*/

global int_class_versions = "isced_version isco_version isic_version"
