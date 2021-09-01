clear all
foreach y in 2012 2013 2017 {
  use "Y:\GLD-Harmonization\551206_TM\PHL\PHL_`y'_LFS\PHL_`y'_LFS_v01_M_v01_A_GLD\Data\Harmonized\PHL_`y'_LFS_v01_M_v01_A_GLD.dta"

  di "Year `y'"
  mdesc industry_orig industrycat_isic
  mdesc occup_orig occup_isco

  di "------------------------------------------"
}
