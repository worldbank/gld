clear all

loc   vars industry_orig industrycat_isic occup_orig occup_isco

foreach y in 2012 2013 2017 {
  use "Y:\GLD-Harmonization\551206_TM\PHL\PHL_`y'_LFS\PHL_`y'_LFS_v01_M_v01_A_GLD\Data\Harmonized\PHL_`y'_LFS_v01_M_v01_A_GLD.dta"

  di "Year `y'"

  qui {
    ds
    loc varlist = r(varlist)

    loc touse : list varlist & vars
  }

  mdesc `touse'

  di "------------------------------------------"
}
