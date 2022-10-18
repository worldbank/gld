/*******************************************************************************
								
                       GLD CHECKS. Latest verison is 1.3. 
                              Run All Checks 
		   	   																   
*******************************************************************************/

	clear all
	set more off
	set more off
	set varabbrev off
	macro drop  csurvey cyear ccode3 ccode2 mydate output mydata helper

*-- 01. User completes this section 

	** Path to "Helper programs" folder 
	global helper "/Users/elenacasanovas/Documents/03_WB/01_GLD/USER_VERSION/D - Q Checks/Helper programs_1.2" 
		
	** Path to GLD data file 
	// global mydata "/Users/elenacasanovas/Documents/03_WB/01_GLD/USER_VERSION/IND_2019_PLFS_V01_M_V01_A_GLD_ALL.dta" 
	// global mydata "/Users/elenacasanovas/Documents/03_WB/01_GLD/USER_VERSION/IND_2011_EUS_V01_M_V01_A_GLD_ALL.dta" 
	// global mydata "/Users/elenacasanovas/Documents/03_WB/01_GLD/USER_VERSION/MEX_2016_ENOE_V01_M_V02_A_GLD_ALL.dta" 
	// global mydata "/Users/elenacasanovas/Documents/03_WB/01_GLD/USER_VERSION/MEX_2016_ENOE_V01_M_V02_A_GLD_ALL.dta" 
	// global mydata "/Users/elenacasanovas/Documents/03_WB/01_GLD/USER_VERSION/ZAF_2019_QLFS_v01_M_v02_A_GLD_ALL.dta"  
	global mydata "/Users/elenacasanovas/Documents/03_WB/01_GLD/USER_VERSION/TUR_2018_HLFS_V01_M_V01_A_GLD_ALL.dta"
	
	** Choose output folder
	global output "/Users/elenacasanovas/Documents/03_WB/01_GLD/USER_VERSION/D - Q Checks/Work"
	
		
*-- 02. Run checks 
	do "${helper}/00_prepare_GLD.do"
	
	* Block 1. Format & contents 
	do "${helper}/01_SubnatID_Hierarchy_GLD.do" 
	do "${helper}/02_in_range_test_wrapper_GLD.do"   
	do "${helper}/03_VarLists_GLD.do"  
	do "${helper}/04_Format_Checks_GLD.do"  
	
	* Block 2. External data  
	do "${helper}/05_ext_ddA_GLD.do" 
	do "${helper}/06_ext_ddB_GLD.do"   
	do "${helper}/07_ext_ddC_GLD.do"   

	do "${helper}/08_ext_num_GLD.do"	 
	do "${helper}/09_ext_figA_GLD.do"    
	do "${helper}/10_ext_figB1_GLD.do"   
	do "${helper}/11_ext_figB2_GLD.do" 
	do "${helper}/12_ext_figC_GLD.do"  
	do "${helper}/13_ext_flag_GLD.do"  
	
	* Block 3. Missing values
	do "${helper}/14_missing_GLD.do"  
	
	* Block 4. Bivariate data 
	do "${helper}/15_bivariate_GLD.do" 
	
	* Block 5. Wage analysis 
	do "${helper}/16_wage_GLD.do" 

	