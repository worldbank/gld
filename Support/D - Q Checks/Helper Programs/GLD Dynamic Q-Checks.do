/*==================================================
project:       Perform Dynamic Quality Checks for GLD
Author:        Mario Gronert 
E-email:       mgronert@worldbank.org
url:           
Dependencies:  distinct, mdesc
----------------------------------------------------
Creation Date:    	08 Apr 2021
Modification Date:	08 Apr 2021   
Do-file version:    01
References:          
Output: Dynamic Overview Graphs
==================================================*/

/*==================================================
              0: Program set up
==================================================*/

version 16
set varabbrev off, permanently

*----------0.1: Set necessary paths

* Find all files in helper folder
local helper_files : dir "${path_to_helpers}" files "helper_*.do" // only the actual helpers progs


*----------0.2: Call in helper programmes

foreach helper_file in `helper_files' {
  local bridge = "${path_to_helpers}" + "\" + "`helper_file'"
  run "`bridge'"
}


/*==================================================
              1: Make density plots over categories
==================================================*/


*----------1.1: Append all harmonizations

use "${path_to_harmonization}", clear

foreach harmonization of global path_to_other_harmonization {

	if "`harmonization'" != "" {
		append using "`harmonization'"
	}
}

*----------1.2: Evaluate if others have been appended

levelsof year
local number_of_years `r(r)'


*----------1.3: Create density graphs of categories if appended
if `number_of_years' > 1 { // only run if there are other years to compare

	foreach var of global dynamic_graph_vars {
		
		cap confirm variable `var'
		if _rc == 0 { // if var exists since if not not here to be looked at
		
			levelsof year
			local years_in_data `r(levels)'
			local number_of_years `r(r)'
				
			local kdensity_command "twoway"
			local legend_labels " legend("
				
			forvalues k = 1/`number_of_years' {
			
				local use_year : word `k' of `years_in_data'				
				if `k' != `number_of_years' { // if not the last
					local kdensity_command = "`kdensity_command'" + " kdensity `var' [aw = weight] if year == `use_year' ||"
					local legend_labels = "`legend_labels'" + " label(`k' `use_year')"
					}
				else {
					local kdensity_command = "`kdensity_command'" + " kdensity `var' [aw = weight] if year == `use_year'"
					local legend_labels = "`legend_labels'" + " label(`k' `use_year'))"
				}		
			}
		local kdensity_command = "`kdensity_command'" + ", xtitle(`var')" + "`legend_labels'"
		`kdensity_command'
		local plot_saving_path = "${path_to_output_folder}" + "\" + "`var'" + "_density.png"
		graph export "`plot_saving_path'", replace
				
		}
	}
}
