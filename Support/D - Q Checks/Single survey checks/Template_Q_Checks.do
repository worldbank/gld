/*******************************************************************************
								
                       GLD CHECKS. Latest verison is 1.5. 
                              Run All Checks 
		   	   																   
*******************************************************************************/

*-- Step 1 - Clean up before start -----------------------------------------------*

	clear all
	set more off
	set more off
	set varabbrev off
	macro drop  csurvey cyear ccode3 ccode2 mydate output mydata helper

*-- Step 2 - User defined arguments (Your input is needed in this step) ----------*

	** Path to "Helper programs" folder <-- INPUT --
	global helper "C:\Users\IrIs_\Documents\WB_gld\Support\D - Q Checks\Single survey checks\Helper_programs_1.5" 
		
	** Path to GLD data file            <-- INPUT -- 
	global mydata "C:\Users\IrIs_\OneDrive\Desktop\WB\Jobs Group\FY2023\SLE\SLE\SLE_2014_LFS\SLE_2014_LFS_V01_M_V01_A_GLD\Data\Harmonized\SLE_2014_LFS_V01_M_V01_A_GLD_ALL.dta" 
	
	** Choose output folder             <-- INPUT --
	global output "C:\Users\IrIs_\OneDrive\Desktop\WB\Jobs Group\FY2023\SLE\SLE\SLE_2014_LFS\SLE_2014_LFS_V01_M_V01_A_GLD\Work"
	
		
*-- Step - 3 Run the quality checks -----------------------------------------------*

	do "${helper}/A1.01_prepare_GLD.do"
	
	* Block 1. Format & contents 
	do "${helper}/B1.01_SubnatID_Hierarchy_GLD.do" 
	do "${helper}/B1.02_in_range_test_wrapper_GLD.do"   
	do "${helper}/B1.03_VarLists_GLD.do"  
	do "${helper}/B1.04_Format_Checks_GLD.do"  
	
	* Block 2. External data  
	do "${helper}/B2.01_ext_ddA_GLD.do" 
	do "${helper}/B2.02_ext_ddB_GLD.do"   
	do "${helper}/B2.03_ext_ddC_GLD.do"   
	
	do "${helper}/B2.04_ext_num_GLD.do"	 
	
	do "${helper}/B2.05_ext_figA_GLD.do"    
	do "${helper}/B2.06_ext_figB1_GLD.do"   
	do "${helper}/B2.07_ext_figB2_GLD.do"
	do "${helper}/B2.08_ext_figB3_GLD.do"
	do "${helper}/B2.09_ext_figC_GLD.do"  
	
	do "${helper}/B2.10_ext_flag_GLD.do"  
	
	* Block 3. Missing values
	do "${helper}/B3.01_missing_GLD.do"  
	
	* Block 4. Bivariate data 
	do "${helper}/B4.01_bivariate_GLD.do" 
	
	* Block 5. Wage analysis 
	do "${helper}/B5.01_wage_GLD.do" 
