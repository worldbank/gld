/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	PHILIPPINES
** COUNTRY ISO CODE	PHL
** YEAR	2003
** Round/wave: 1 (completed in month of Janurary)
** SURVEY NAME	Labor Force Survey
** SURVEY AGENCY	National Statistical Office
** UNIT OF ANALYSIS	Household and Individual
** INPUT DATABASES	LFS JAN2003
** RESPONSIBLE	 World Bank Jobs Group
** Created	4/4/2012
** Modified	24/5/2021
** NUMBER OF HOUSEHOLDS
** NUMBER OF INDIVIDUALS
** EXPANDED POPULATION
** NUMBER OF SURVEY ROUNDS: 4
**                                                                                                  **
******************************************************************************************************
*****************************************************************************************************/

/*****************************************************************************************************
*                                                                                                    *
                                   INITIAL COMMANDS
*                                                                                                    *
*****************************************************************************************************/


** INITIAL COMMANDS
	cap log close
	clear
	set more off
	set mem 800m

** DIRECTORY

	local 	cty3 	"PHL" 	// set this to the three letter country/economy abbreviation
	local 	usr		`"551206_TM"' // set this to whatever Mario named your folder
	local 	surv_yr `"2003"'	// set this to the survey year

** RUN SETTINGS
	local 	cb_pause = 0	// 1 to pause+edit the exported codebook for harmonizing varnames, else 0
	local 	append 	 = 1	// 1 to run iecodebook append, 0 if file is already appended.


	local 	year 		"${GLD}:\GLD-Harmonization\\`usr'\\`cty3'\\`cty3'_`surv_yr'_LFS" // top data folder

	local 	main		"`year'\\`cty3'_`surv_yr'_LFS_v01_M"
	local 	 stata		"`main'\data\stata"
	local 	gld 		"`year'\\`cty3'_`surv_yr'_LFS_v01_M_v01_A_GLD"
	local 	i2d2		"`year'\\`cty3'_`surv_yr'_LFS_v01_M_v01_A_I2D2"
	local 	 code 		"`i2d2'\Programs"
	local 	 id_data 	"`i2d2'\Data\Harmonized"

	local 	lb_mod_age	15	// labor module minimun age (inclusive)
	local 	ed_mod_age	5	// labor module minimun age (inclusive)

** LOG FILE
	log using `"`id_data'\\`cty3'_`surv_yr'_I2D2_LFS.log"', replace


** FILES
	local round1 `"`stata'\LFS JAN2003.dta"'

** VALUES
	local n_round 	1			// numer of survey rounds
	local cases  	184228		// 184228 (Jan) + 183926 (APR) + 207974 (Jul) + 208716 (Oct) (Source: ILO from PSA)


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


*** use the appropriate round file
	use `"`round1'"', clear

** SAMPLE
	gen str7 sample = `"`cty3'"' + `"`surv_yr'"'

** COUNTRY
	gen str4 ccode=`"`cty3'"'
	label var ccode "Country code"


** YEAR
	gen int year=`surv_yr'
	label var year "Year of survey"


** YEAR OF INTERVIEW
	gen int intv_year=`surv_yr'
	label var intv_year "Year of the interview"


** MONTH OF INTERVIEW
	gen byte month=svymo
	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"


** HOUSEHOLD IDENTIFICATION NUMBER
	loc idhvars 	regn prov hcn 	// store idh vars in local

	ds `idhvars',  	has(type numeric)					// filter out numeric variables in local
	loc numlist 	= r(varlist)						// store numeric vars in local
	loc stringlist 	: list idhvars - numlist			// non-numeric vars in stringlist

	* starting locals
	loc len = 6											// declare the length of each element in digits
	loc idh_els ""										// start with empty local list

	* make each numeric var string, including leading zeros
	foreach var of local numlist {
		tostring `var'	///								// make the numeric vars strings
			, generate(idh_`var') ///					// gen a variable with this prefix
			force format(`"%0`len'.0f"')				// ...and the specified number of digits in local

		loc idh_els 	`idh_els' idh_`var'				// add each variable to the local list

	}

	* make each string variable numeric (as it should be), then string again with correct format
	foreach var of local stringlist {
		destring `var' /// 								// destring variable, make numeric version
			, gen(num_`var') ///						//
			force 										// force obs to num that are non numeric, ie to missing

		tostring num_`var'	///							// make the numeric vars strings
			, generate(idh_`var') ///					// gen a variable with this prefix
			force format(`"%0`len'.0f"')				// ...and the specified number of digits in local

		loc idh_els 	`idh_els' idh_`var'				// add each variable to the local list

	}


	* concatenate all elements to form idh: hosehold id
	egen idh=concat( `idh_els' )						// concatenate vars we just made. code drops vars @ end

	label var idh "Household id"




** INDIVIDUAL IDENTIFICATION NUMBER
	bys idh: gen n_fam = _n								// generate family member number

	* repeat same process from above, but only with n_fam.
	* 	note, assuming that the only necessary individaul identifier is family member, which is numeric
	*	so, not following processing for sorting numeric/non-numeric variables.

	loc idpvars 	c101_lno								// store relevant idp vars in local
	ds `idpvars',  	has(type numeric)					// filter out numeric variables in local
	loc rlist 		= r(varlist)						// store numeric vars in local

	* make new values with desired length of each variable
	loc len = 2											// declare the length of each element in digits
	loc idp_els ""										// start with empty local list

	foreach var of local idpvars {
		tostring `var'	///								// make numeric variables strings
			, generate(idp_`var') ///					// generate a variable with this prefix
			force format(`"%0`len'.0f"')				// ...and the specified number of digits in local

		loc idp_els 	`idp_els' idp_`var'				// add each variable to the local list

	}

	* concatenate to form idp: individual id
	egen idp=concat( `idp_els' )						// concatenate vars we just made. code drops vars @ end

	sort idh idp
	label var idp "Individual id"

** ID CHECKS
	isid idh idp 										// household and individual id uniquely identify




** HOUSEHOLD WEIGHTS
	/* The weight variable will be divided by the number of rounds per year to ensure the
	   weighting factor does not over-mutliply*/
	gen double wgt= rfadj/(`n_round')
	label var wgt "Household sampling weight"


** STRATA
	gen strata=stratum
	label var strata "Strata"


** PSU
	/*Survey includes psu variable*/
	label var psu "Primary sampling units"


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	label var urb "Urban/Rural"
	la de lblurb 1 "Urban" 2 "Rural"
	label values urb lblurb


**REGIONAL AREAS
	gen reg01 = regn
	label var reg01 "Macro regional areas"


** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen reg02 = regn
	label var reg02 "1st Level Administrative Division"


** REGIONAL AREA 2 DIGITS ADM LEVEL (ADMN2)
	gen reg03= prov
	label var reg03 "2nd Level Administrative Division"


** REGIONAL AREA 3 DIGITS ADM LEVEL (ADMN3)
	gen reg04=.
	label var reg04 "3rd Level Administrative Division"


** GEOGRAPHIC VARIABLE VALUE LABELS
	/*  Please see "Administrative_Levels.md" for a detailed explanation of the region and province
		recodings, available on the repository in the Guides and Documentation Folder.
		https://github.com/worldbank/gld

		Similarly, in the same location, "I2D2_Geographic_Nomenclature.md" describes the administrative
		divisions used in I2D2
 	*/

	* reg01 is the geo/admin var of interest, reg02 is the first/highest/largest admin variable

	* RECODE REGION
	*			(17= 42)		///  sometimes Mimaropa appears as value 17, recode to always be 42 for consistency

	* recode to Calabarzon
	recode 	reg01 reg02 	/// recode both of these variables
			(4 = 41) 		///
			if (svymo == 1 | svymo == 4)  	/// restrict only to first two rounds
			& inlist(prov, 10, 21, 34, 56, 58) 	// restricted to relevant provinces

	* recode to Mimaropa
	recode 	reg01 reg02 	/// recode both of these variables
			(4 = 42) 		///
			if (svymo == 1 | svymo == 4)  	/// restrict only to first two rounds
			& inlist(prov, 51, 52, 40, 53, 59) 	// restricted to relevant provinces

	* recode Aurora to Central Luzon
		* Aurora belongs in this region
	recode 	reg01 reg02 	///
			(4 = 3) 		///
			if (svymo == 1 | svymo == 4)  	/// restrict only to first two rounds
			& prov == 77

	* CREATE VALUE LABEL
	** define region value label: b= 2003 change
	la de lblreg02b			///
	 1   "Ilocos"			///
	 2	 "Cagayan Valley"	///
	 3   "Central Luzon"	///
	 						/// Southern Tagalog has been split into Calabarzon and Mimaropa
	 5   "Bicol"			///
	 6	 "Western Visayas"	///
	 7   "Central Visayas"	///
	 8	 "Eastern Visayas"	///
	 9   "Zamboanga Peninsula"	///
	 10  "Northern Mindanao"	///
	 11  "Davao"			///
	 12  "Soccsksargen"		///
	 13  "National Capital Region"				///
	 14  "Cordillera Administrative Region"		///
	 15  "Autonomous Region of Muslim Mindanao"	///
	 16  "Caraga" 	///
	 				/// value 17 exists only in raw data, not in recoded version
	 18  "Negros Island Region" /// this region appears occasionally in data
	 							///
	 41	 "Calabarzon"	/// formerly part of Southern Tagalog
	 42  "Mimaropa"		// formerly part of Southern Tagalog

	** label appropriate variable values
	label values 	reg01 reg02 	lblreg02b
pause on
pause
** RENAME ORIGINAL ADMIN VARIABLES
	* clonevar keeps value labels along with values; gen does not.
	clonevar reg02_orig = regn
	clonevar reg03_orig = prov

	la var reg02_orig "Original 1st Level Admin Variable"
	la var reg03_orig "Original 2nd Level Admin Variable"


** HOUSE OWNERSHIP
	gen byte ownhouse=.
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	gen byte water=.
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION
	gen byte electricity=.
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity


** TOILET PUBLIC CONNECTION
	gen byte toilet=.
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet


** LAND PHONE
	gen byte landphone=.
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone


** CELL PHONE
	gen byte cellphone=.
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone


** COMPUTER
	gen byte computer=.
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer


** INTERNET
	gen byte internet=.
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
	sort idh
	by idh: egen hhsize= count(c03_rel <= 8 | c03_rel == 11)
	* restrict by family role var, include all non-family members but not boarders/workers
	label var hhsize "Household size"

	* check
	mdesc hhsize
	assert r(miss) == 0


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen byte head=c03_rel				//  "head", "spouse", and children not recoded
	recode head 	(4 5 6 8  	= 5)	/// siblings, children in law, grandchildren, other rel of hh head="other relatives"
					(7 			= 4)	/// parents of hh head become "parents"
					(9 10 11 	= 6) 	// boarders and domestic workers become "other/non-relatives"
	replace ownhouse=. if head==6
	label var head "Relationship to the head of household"
	la de lblhead  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values head  lblhead
	gen jh=(head==1)
	bys idh: egen hh=sum(jh) // hh is the count of hh heads per family

	/*Note: if number of Household Heads is >1, all relevant HH head info is set to missing.
			In this case the only relevant variable is head*/
	replace head=. if hh>1

	*drop if hh==0


** GENDER
	gen byte gender=c04_sex
	label var gender "Gender"
	la de lblgender 1 "Male" 2 "Female"
	label values gender lblgender


** AGE
	gen byte age = c05_age
	label var age "Individual age"
	replace age=98 if age>=98 & age!=.


** SOCIAL GROUP
	gen byte soc=.
	label var soc "Social group"
	label values soc lblsoc


** MARITAL STATUS
	gen byte marital=c06_mstat
	recode marital (1=2) (2=1) (3=5)(5=.)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen byte ed_mod_age=`ed_mod_age'
	label var ed_mod_age "Education module application age"


** CURRENTLY AT SCHOOL
	*no related variable in survey
	gen byte atschool=.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	*no related variable in survey
	gen byte literacy=.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	*no related variable in survey
	gen byte educy=.
	label var educy "Years of education"


** EDUCATIONAL LEVEL 1
	/*Please refer to the "Education_Levels.md" for a detailed discussion on classificition of how each level is classified and why,
		available in github repository. */
	gen byte edulevel1=.
	replace edulevel1=1 if c07_grade==0			// "No Grade Completed" -> "No education"
	replace edulevel1=2 if c07_grade==1 	// "Elementary Undergraduate" -> " Primary Incomplete"
	replace edulevel1=3 if c07_grade==2 	// "Elementary Graduate" -> "Primary Complete"
	replace edulevel1=4 if c07_grade==3		// "High School Undergraduate" -> "Secondary Incomplete"
	replace edulevel1=5 if c07_grade==4		// "High school graduate" -> "Secondary Complete"
	replace edulevel1=7 if c07_grade==5 | ( c07_grade>=60 & c07_grade<=98) // "College Graduate" and "[x] Bachelors/Advanced Degree" -> "University"
	replace edulevel1=9 if c07_grade==99 	// where 99 == 'not reported'

	label var edulevel1 "Level of education 1"
	la de lbledulevel1 	1 "No education"	///
						2 "Primary incomplete" 	///
						3 "Primary complete" 	///
						4 "Secondary incomplete" ///
						5 "Secondary complete" 	///
						6 "Higher than secondary but not university" 	///
						7 "University incomplete or complete" 	///
						8 "Other" 			///
						9 "Unstated"

	label values edulevel1 lbledulevel1
	replace edulevel1=. if age < ed_mod_age // restrict universe to students at or above primary school age


** EDUCATION LEVEL 2
	gen byte edulevel2=edulevel1
	recode edulevel2 (4=3) (5=4)  (6/7=5) (8=.) (9=.)
	label var edulevel2 "Level of education 2"
	la de lbledulevel2 	1 "No education" 	///
						2 "Primary incomplete"  	///
						3 "Primary complete but secondary incomplete" 	///
						4 "Secondary complete" 		///
						5 "Some tertiary/post-secondary"
	label values edulevel2 lbledulevel2
	replace edulevel2=. if age < ed_mod_age // restrict universe to students at or above primary school age


** EDUCATION LEVEL 3
	gen byte edulevel3=edulevel1
	recode edulevel3 (2 3 =2) (4 5 =3) (6/7 =4) (8=.) (9=.)
	label var edulevel3 "Level of education 3"
	la de lbledulevel3 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values edulevel3 lbledulevel3
	replace edulevel3=. if age < ed_mod_age // restrict universe to students at or above primary school age



** EVER ATTENDED SCHOOL
	/*Note, ever attend will be true=1 if student if of school age and has completed at least grade 1 or is
		currently attending*/

	gen byte everattend=.
	replace everattend=1 if age >= ed_mod_age & (atschool==1 | (2 <= edulevel1 <= 8 ))
	replace everattend=0 if age >= ed_mod_age & atschool==0 & edulevel1==0
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend



/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/

** LABOR MODULE AGE
	gen byte lb_mod_age=`lb_mod_age'
	label var lb_mod_age "Labor module application age"


** LABOR STATUS
	/*Changing by using empst1_nso to determine lstatus, not work
	Note: creating own label, not using label from empst1_nso	*/
	gen byte lstatus=.
	replace lstatus=1 if empst1_nso==1
	replace lstatus=2 if empst1_nso==2
	replace lstatus=3 if empst1_nso==3
	replace lstatus=. if age < lb_mod_age // restrict universe to only those of working age
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** LABOR STATUS LAST YEAR
	/*Can this be adjusted to reflect new _nso labor status variable? */
	gen byte lstatus_year=.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 0 "Not employed"
	label values lstatus_year lbllstatus_year


** EMPLOYMENT STATUS
	gen byte empstat=.
	replace empstat=1 if c17_pclass==0 | c17_pclass==1 | c17_pclass==2 | c17_pclass==5
	replace empstat=2 if c17_pclass==6
	replace empstat=3 if c17_pclass==4
	replace empstat=4 if c17_pclass==3
	replace empstat=. if lstatus!=1 	// includes universe restriction
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** EMPLOYMENT STATUS LAST YEAR
	gen byte empstat_year=.
	replace empstat_year=. if lstatus_year!=1 // includes universe restriction
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year


** NUMBER OF TOTAL JOBS
	gen byte njobs=.
	label var njobs "Number of total jobs"
	replace njobs=. 	if 	age < lb_mod_age | lstatus != 1		// restrict universe to working age + workers


** NUMBER OF TOTAL JOBS LAST YEAR
	gen byte njobs_year=.
	replace njobs_year=. if age < lb_mod_age | lstatus_year!=1 	// restrict universe to working age + workers
	label var njobs_year "Number of total jobs during last year"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen byte ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1  	// restrict universe to employed only
	replace ocusec=. if age < lb_mod_age // restrict universe to working age



** REASONS NOT IN THE LABOR FORCE
	gen byte nlfreason=.
	replace nlfreason=1 if c40_wynot==8
	replace nlfreason=2 if c40_wynot==7
	replace nlfreason=3 if c40_wynot==6
	replace nlfreason=4 if c40_wynot==3
	replace nlfreason=5 if c40_wynot==1 | c40_wynot==2 | c40_wynot==4 | c40_wynot==5 | c40_wynot==9
	replace nlfreason=. if lstatus!=3 	// restricts universe to non-labor force
	replace nlfreason=. if age < lb_mod_age // restrict universe to working age
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l= c38_weeks/4.2
	label var unempldur_l "Unemployment duration (months) lower bracket"
	replace unempldur_l=. if age < lb_mod_age // restrict universe to working age
	replace unempldur_l=. if lstatus!=2 	  // restrict universe to unemployed only

	gen byte unempldur_u= c38_weeks/4.2
	label var unempldur_u "Unemployment duration (months) upper bracket"
	replace unempldur_l=. if age < lb_mod_age // restrict universe to working age
	replace unempldur_l=. if lstatus!=2 	  // restrict universe to unemployed only

** INDUSTRY CLASSIFICATION

	gen byte industry=.
	replace industry=1 if c16a_pkb >= 1 & c16a_pkb <= 9		// Agriculture
	replace industry=2 if c16a_pkb == 10 | c16a_pkb == 11		// Mining
	replace industry=3 if c16a_pkb>=15 & c16a_pkb <= 39		// Manufacturing
	replace industry=4 if c16a_pkb==40 | c16a_pkb==41			// Public Utility Services
	replace industry=5 if c16a_pkb==45						// Construction
	replace industry=6 if c16a_pkb >= 50 & c16a_pkb <= 55		// Commerce
	replace industry=7 if c16a_pkb >= 60 & c16a_pkb <= 64		// Transport + Communication
	replace industry=8 if c16a_pkb >= 65 & c16a_pkb <= 74		// Financial + Business Services
	replace industry=9 if c16a_pkb == 75						// Public Administration
	replace industry=10 if c16a_pkb>=76 & c16a_pkb <= 99 		// this includes education for now.
	label var industry "1 digit industry classification"

	* Comments include UN International Standard Industrial Classification associated categories (version 3.1)
	la de lblindustry 	1 "Agriculture" 	/// (01-05)
						2 "Mining" 			/// (10-14)
						3 "Manufacturing" 	/// (15-37)
						4 "Public Utility Services" /// (40-41)
						5 "Construction"  	/// (45)
						6 "Commerce" 	/// (50-55)
						7 "Transport and Communication" /// (60-64)
						8 "Financial and Business Services" /// (65-74)
						9 "Public Administration" /// (75)
						10 "Other Services, Unspecified" // (80-99)

	label values industry lblindustry
	replace industry=. if age < lb_mod_age // restrict universe to working age
	replace industry=. if lstatus!=1 		// restrict universe to employed only

** INDUSTRY 1
	gen byte industry1=industry
	recode industry1 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry1=. if lstatus!=1
	label var industry1 "1 digit industry classification (Broad Economic Activities)"
	la de lblindustry1 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1 lblindustry1
	replace industry1=. if age < lb_mod_age // restrict universe to working age
	replace industry1=. if lstatus!=1 		// restrict universe to employed only

**SURVEY SPECIFIC INDUSTRY CLASSIFICATION
	gen industry_orig=c16a_pkb
	replace industry_orig=. if lstatus!=1 		// restrict universe to employed only
	replace industry_orig=. if age < lb_mod_age // restrict universe to working age
	label var industry_orig "Original Industry Codes"


** OCCUPATION CLASSIFICATION
	* in 2003, raw variable is numeric

	* generate occupation variable
	gen byte occup=floor(c14a_procc/10)		// this handles most of recoding automatically.
	recode occup 0 = 10	if 	c14a_procc==1 	// recode "armed forces" to appropriate label
	recode occup 0 = 99	if 	(c14a_procc>=2 & c14a_procc <=9) ///
							| (c14a_procc >=94 & c14a_procc <= 99) // recode "Not classifiable occupations"

	/* Note that the raw variable, procc lists values, 94-99 for which there are no associated occupation
	   codes. Given that the raw data indicate that these individauls do have valid, non-missing occupations,
	   and that these occupations cannot be matched to our classificaitons with certainty, I have coded them as "other" */


	replace occup=. if lstatus!=1 		// restrict universe to employed only
	replace occup=. if age < lb_mod_age	// restrict universe to working age
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and sales workers" 6 "Skilled agricultural, forestry, and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations"  99 "Others"
	label values occup lbloccup


** SURVEY SPECIFIC OCCUPATION CLASSIFICATION
	gen occup_orig=c14a_procc
	replace occup_orig=. if lstatus!=1 			// restrict universe to employed only
	replace occup_orig=. if age < lb_mod_age	// restrict universe to working age
	label var occup_orig "Original Occupational Codes"


** FIRM SIZE
	gen byte firmsize_l=.
	replace firmsize_l=. if lstatus!=1 			// restrict universe to employed only
	label var firmsize_l "Firm size (lower bracket)"

	gen byte firmsize_u=.
	replace firmsize_u=. if lstatus!=1 			// restrict universe to employed only
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen whours= c20_phours
	replace whours=. if lstatus!=1 			// restrict universe to employed only
	replace whours=. if age < lb_mod_age	// restrict universe to working age
	label var whours "Hours of work in last week"
	replace whours=. if lstatus!=1


** WAGES
	gen double wage= c25_pbasic
	replace wage=. if lstatus!=1 			// restrict universe to employed only
	replace wage=. if age < lb_mod_age		// restrict universe to working age
	replace wage=. if empstat==1			// restrict universe to wage earners
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen byte unitwage=1
	replace unitwage=. if lstatus!=1 			// restrict universe to employed only
	replace unitwage=. if age < lb_mod_age		// restrict universe to working age
	replace unitwage=. if empstat==1			// restrict universe to wage earners
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage


** EMPLOYMENT STATUS - SECOND JOB
	gen byte empstat_2=.

	replace empstat_2=. if lstatus!=1 			// restrict universe to employed only
	replace empstat_2=. if age < lb_mod_age		// restrict universe to working age
	label var empstat_2 "Employment status - second job"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2


** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
	gen byte empstat_2_year=.

	replace empstat_2_year=. if lstatus!=1 				// restrict universe to employed only
	replace empstat_2_year=. if age < lb_mod_age		// restrict universe to working age
	label var empstat_2_year "Employment status - second job"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2_year  lblempstat_2_year


** INDUSTRY CLASSIFICATION - SECOND JOB
	gen byte industry_2=.

	replace industry_2=1 if c30a_okb >= 1 & c30a_okb <= 9		// Agriculture
	replace industry_2=2 if c30a_okb == 10 | c30a_okb == 11		// Mining
	replace industry_2=3 if c30a_okb>=15 & c30a_okb <= 39		// Manufacturing
	replace industry_2=4 if c30a_okb==40 | c30a_okb==41			// Public Utility Services
	replace industry_2=5 if c30a_okb==45						// Construction
	replace industry_2=6 if c30a_okb >= 50 & c30a_okb <= 55		// Commerce
	replace industry_2=7 if c30a_okb >= 60 & c30a_okb <= 64		// Transport + Communication
	replace industry_2=8 if c30a_okb >= 65 & c30a_okb <= 74		// Financial + Business Services
	replace industry_2=9 if c30a_okb == 75						// Public Administration
	replace industry_2=10 if c30a_okb>=76 & c30a_okb <= 99 		// this includes education for now.

	replace industry_2=. if lstatus!=1 				// restrict universe to employed only
	replace industry_2=. if age < lb_mod_age		// restrict universe to working age
	label var industry_2 "1 digit industry classification - second job"
	label values industry_2 lblindustry				// use same data labels as industry


** INDUSTRY 1 - SECOND JOB
	gen byte industry1_2=.
	recode industry1_2 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry1_2=. if lstatus!=1 				// restrict universe to employed only
	replace industry1_2=. if age < lb_mod_age			// restrict universe to working age
	label var industry1_2 "1 digit industry classification (Broad Economic Activities) - Second job"
	la de lblindustry1_2 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1_2 lblindustry1_2


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
	gen industry_orig_2=c30a_okb
	replace industry_orig_2=. if lstatus!=1 				// restrict universe to employed only
	replace industry_orig_2=. if age < lb_mod_age			// restrict universe to working age
	label var industry_orig_2 "Original Industry Codes - Second job"


** OCCUPATION CLASSIFICATION - SECOND JOB
	gen byte occup_2=floor(c28a_otocc/10)		// this handles most of recoding automatically.
	recode occup_2 0 = 10	if 	c28a_otocc==1 	// recode "armed forces" to appropriate label
	recode occup_2 0 = 99	if 	(c28a_otocc>=2 & c28a_otocc <=9) ///
							| (c28a_otocc >=94 & c28a_otocc <= 99) // recode "Not classifiable occupations"

	replace occup_2=. if lstatus!=1 		// restrict universe to employed only
	replace occup_2=. if age < lb_mod_age	// restrict universe to working age

	replace occup_2=. if lstatus!=1 				// restrict universe to employed only
	replace occup_2=. if age < lb_mod_age			// restrict universe to working age
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2


** WAGES - SECOND JOB
	gen double wage_2=c34_obasic
	replace wage_2=. if lstatus!=1 			// restrict universe to employed only
	replace wage_2=. if age < lb_mod_age		// restrict universe to working age
	replace wage_2=. if empstat==1			// restrict universe to wage earners
	label var wage_2 "Last wage payment - Second job"


** WAGES TIME UNIT - SECOND JOB
	gen byte unitwage_2=1
	replace unitwage_2=. if lstatus!=1 			// restrict universe to employed only
	replace unitwage_2=. if age < lb_mod_age		// restrict universe to working age
	replace unitwage_2=. if empstat==1			// restrict universe to wage earners
	label var unitwage_2 "Last wages time unit - Second job"
	la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_2 lblunitwage_2


** CONTRACT
	gen byte contract=.
	replace contract=0 if c08_conwr==2 | c08_conwr==8
	replace contract=1 if c08_conwr==1
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
	replace contract=. if lstatus!=1 				// restrict universe to employed only
	replace contract=. if age < lb_mod_age			// restrict universe to working age


** HEALTH INSURANCE
	gen byte healthins=.
	replace healthins=. if lstatus!=1 				// restrict universe to employed only
	replace healthins=. if age < lb_mod_age			// restrict universe to working age
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins


** SOCIAL SECURITY
	gen byte socialsec=.
	replace socialsec=. if lstatus!=1 				// restrict universe to employed only
	replace socialsec=. if age < lb_mod_age			// restrict universe to working age
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


** UNION MEMBERSHIP
	gen byte union=.
	replace union=. if lstatus!=1 				// restrict universe to employed only
	replace union=. if age < lb_mod_age			// restrict universe to working age
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion


/*****************************************************************************************************
*                                                                                                    *
                                   MIGRATION MODULE
*                                                                                                    *
*****************************************************************************************************/


**REGION OF BIRTH JURISDICTION
	gen byte rbirth_juris=.
	label var rbirth_juris "Region of birth jurisdiction"
	la de lblrbirth_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rbirth_juris lblrbirth_juris


**REGION OF BIRTH
	gen rbirth=.
	label var rbirth "Region of Birth"


** REGION OF PREVIOUS RESIDENCE JURISDICTION
	gen byte rprevious_juris=.
	label var rprevious_juris "Region of previous residence jurisdiction"
	la de lblrprevious_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rprevious_juris lblrprevious_juris


**REGION OF PREVIOUS RESIDENCE
	gen rprevious=.
	label var rprevious "Region of Previous residence"


** YEAR OF MOST RECENT MOVE
	gen int yrmove=.
	label var yrmove "Year of most recent move"


**TIME REFERENCE OF MIGRATION
	gen byte rprevious_time_ref=.
	label var rprevious_time_ref "Time reference of migration"
	la de lblrprevious_time_ref 99 "Previous migration"
	label values rprevious_time_ref lblrprevious_time_ref


/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** INCOME PER CAPITA
	gen double pci=.
	label var pci "Monthly income per capita"


** DECILES OF PER CAPITA INCOME
	gen pci_d=.
	label var pci_d "Income per capita deciles"


** CONSUMPTION PER CAPITA
	gen double pcc=.
	label var pcc "Monthly consumption per capita"


** DECILES OF PER CAPITA CONSUMPTION
	gen pcc_d=.
	label var pcc_d "Consumption per capita deciles"


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL
	keep sample ccode year intv_year month idh idp wgt strata psu urb ///
				reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
				cellphone computer internet hhsize head gender age soc marital ed_mod_age ///
				everattend atschool literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age ///
				lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason ///
				unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig ///
				firmsize_l firmsize_u whours wage unitwage contract  empstat_2 ///
				empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
				healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious ///
				yrmove rprevious_time_ref pci pci_d pcc pcc_d reg02_orig reg03_orig


** ORDER VARIABLES
	order sample ccode year intv_year month idh idp wgt strata psu urb	///
				reg01 reg02 reg03 reg04 reg02_orig reg03_orig  ///
				ownhouse water electricity toilet landphone ///
				cellphone computer internet hhsize head gender age soc marital ///
				ed_mod_age everattend atschool literacy educy edulevel1 edulevel2 ///
				edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year ///
				njobs njobs_year ocusec nlfreason unempldur_l unempldur_u industry ///
				industry1 industry_orig occup occup_orig firmsize_l firmsize_u ///
				whours wage unitwage contract empstat_2 empstat_2_year ///
				industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
				healthins socialsec union rbirth_juris rbirth rprevious_juris ///
				rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d

	compress


** DELETE MISSING VARIABLES
	local keep ""
	qui levelsof ccode, local(cty)
	foreach var of varlist urb - pcc_d {
	qui sum `var'
	scalar sclrc = r(mean)
	if sclrc==. {
	     display as txt "Variable " as result "`var'" as txt " for ccode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
	}
	else {
	     local keep `keep' `var'
	}
	}
	keep sample ccode year intv_year month  idh idp wgt strata psu `keep'



** MISSING VALUES
	*Declare varlist which cannot contain missings
	loc	nomissvars sample ccode year intv_year month idh idp wgt strata psu hhsize ed_mod_age lb_mod_age

	foreach var of local nomissvars {
		qui mdesc `var'
		loc nmiss = r(miss)
		cap assert r(miss) == 0
		if _rc {
			display as txt "Variable " as result "`var'" as txt " has `nmiss' observations."
		}
		else {
			display as txt "Variable " as result "`var'" as txt " has no missing observations."
		}
	}


	save `"`id_data'\\`cty3'_`surv_yr'_I2D2_LFS_JAN.dta"', replace

	log close


	clear





******************************  END OF DO-FILE  *****************************************************/
