/*==============================================================================
* B1: Create the panel variables
*==============================================================================*/

	
*<_panel_>

	capture confirm variable panel
	if _rc==0 {
		display "panel is already available in the data. Do not create"
	}
	* Create panel variable out of visit numbers
	* Credits to Nils Enevoldsen for this code:
	destring wave, ignore("Q") gen(wave_num)

	gen quarter_monotonic = wave_num + 8 * floor((year - 2017) / 2)

	// Generate Panel ID, numbered as in PLFS documentation
	// This logic might break with future PLFS releases. In particular, it assumes that
	// the "tens place" increments every two rounds, and the "ones place" resets every
	// two rounds.
	tempvar tens ones
	gen `tens' = 1 + floor((quarter_monotonic - visit_no) / 8)
	gen `ones' = 1 + mod(quarter_monotonic - visit_no, 8)
	gen panel_num = `tens' * 10 + `ones'
	tostring panel_num, gen(panel)

	
	* Slight deviation from Nils, instead adopt panel nomenclature used in the report (which starts with P)
	replace panel = "P" + panel

    * Display unique panels and tabulate year and wave for each panel
    quietly levelsof panel, local(panels)
    foreach panel of local panels {
        display "* Displaying panel: `panel'",
        dis "This is panel: `panel'"
        tab year wave if panel == "`panel'"
    }
	
	drop wave_num panel_num
*</_panel_>

*<_visit_no_>

	capture confirm variable visit_no
	if _rc==0 {
		display "visit_no is already available in the data. Do not create"
	}
		

*</_visit_no_>

*<_hhid_panel_>
	
	gen hhid_panel = hhid + panel

*</_hhid_panel_>


*<_pid_panel_

* Create PID variable adding panel information
	* First extract the individual number
	gen rosternum = substr(pid, -2, 2)
	gen pid_panel = hhid + panel + rosternum
	drop rosternum
	
	isid pid_panel wave

*</_pid_panel_>

