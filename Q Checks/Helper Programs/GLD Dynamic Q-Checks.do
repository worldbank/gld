

use "C:\Users\wb529026\OneDrive - WBG\Documents\Country Work\IND\IND_1993_NSS50-SCH10\IND_1993_NSS50-SCH10_v01_M_v01_A_GLD\Data\Harmonized\IND_1993_NSS50-SCH10_V01_M_V01_A_GLD.dta"

append using "C:\Users\wb529026\OneDrive - WBG\Documents\Country Work\IND\IND_1999_NSS55-SCH10\IND_1999_NSS55-SCH10_v01_M_v01_A_GLD\Data\Harmonized\IND_1999_NSS55-SCH10_V01_M_V01_A_GLD.dta"


local vars = "industrycat10 educat7"
local var_count : word count `vars'

forvalues i = 1/`var_count' {
	
	local use_var : word `i' of `vars' 

	levelsof year
	local years_in_data `r(levels)'
	local number_of_year `r(r)'
	
	local kdensity_command "twoway"
	
	forvalues k = 1/`number_of_year' {
		
		local use_year : word `k' of `years_in_data'
		
		if `k' != `number_of_year' { // if not the last
			local kdensity_command = "`kdensity_command'" + " kdensity `use_var' [aw = weight] if year == `use_year' ||"
		}
		else {
			local kdensity_command = "`kdensity_command'" + " kdensity `use_var' [aw = weight] if year == `use_year'"
		}
		
	}
	`kdensity_command'
	graph export "${path_to_output_folder}" + "\" + "`use_var'" + "_density.png", replace
} 

