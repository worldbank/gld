clear all

loc   vars  industry_orig industrycat_isic occup_orig occup_isco
loc   vars2 isic_merge_1 isic_merge_2 isco_merge_1 isco_merge_2

foreach y in 2012 2013 2017 {
  use "Y:\GLD-Harmonization\551206_TM\PHL\PHL_`y'_LFS\PHL_`y'_LFS_v01_M_v01_A_GLD\Data\Harmonized\PHL_`y'_LFS_v01_M_v01_A_GLD.dta"

  di "Year `y'"

  qui {
    ds
    loc varlist = r(varlist)

    loc touse : list varlist & vars
  }

  mdesc `touse'

  qui {
    ds
    loc varlist = r(varlist)

    loc touse : list varlist & vars2
  }

  foreach var of local touse {
    tab `var' // only provides global estimate, not exactly what we want, need to specify if "original var != ."
  }

  di "------------------------------------------"
}
