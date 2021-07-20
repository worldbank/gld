/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	INDIA
** COUNTRY ISO CODE	IND
** YEAR	2011
** SURVEY NAME	NATIONAL SAMPLE SURVEY 68TH ROUND SCHEDULE 10
** SURVEY AGENCY	GOVERNMENT OF INDIA NATIONAL SAMPLE SURVEY ORGANISATION
** SURVEY SOURCE	
** UNIT OF ANALYSIS	Individuals
** INPUT DATABASES	C:\_I2D2\Dan\Beckup Data\SA\India\2009\Original\Data\India_NSS_2009_10_DataOrig.dta 
** RESPONSIBLE	Triana Yentzen

** Created	2013/07/31
** Updated  2021/02/09 by Mario Gronert

** Modified	41880

** NUMBER OF HOUSEHOLDS	101724
** NUMBER OF INDIVIDUALS	456999
** EXPANDED POPULATION	1088300000
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
	set mem 700m


** DIRECTORY
	*local path "E:\Project_Dino_Local\India State-Level Data Mapping-20200430\India State-Level Data Mapping\I2D2 Data\I2D2 Data\2011\NSS_SCH10"
	local path "Z:\__I2D2\India\2011\NSS_SCH10"


** LOG FILE
	*log using "`path'\Processed\IND_2011_I2D2_NSS_SCH10.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
** Read in Block 5_3 since it is the one not a HH or Indiv level but has several entries per Indiv
use "`path'\Original\IND_2011_NSS68-SCH10_v01_M_Stata8_Copy\IND_2011_NSS68-SCH10_v01_M_Stata8\NSS68_Sch10_bk_5-3.dta"

* Keep vars you need only
keep ID B4_v01 B53_v14 B53_v15 B53_v04 B53_v05 B53_v03

* reshape
reshape wide B53_v14 B53_v15 B53_v04 B53_v05, i( ID B4_v01) j( B53_v03)

** Merge Block 4 : Demographic particulars of HH members
merge 1:1 ID B4_v01 using "`path'\Original\IND_2011_NSS68-SCH10_v01_M_Stata8_Copy\IND_2011_NSS68-SCH10_v01_M_Stata8\NSS68_Sch10_bk_4.dta", assert(3) nogenerate

** Merge Blocks 5_1 (usual principal activity) and 5_2 (usual subsidiary activity)
merge 1:1 ID B4_v01 using "`path'\Original\IND_2011_NSS68-SCH10_v01_M_Stata8_Copy\IND_2011_NSS68-SCH10_v01_M_Stata8\NSS68_Sch10_bk_5-1.dta", assert(3) nogenerate

merge 1:1 ID B4_v01 using "`path'\Original\IND_2011_NSS68-SCH10_v01_M_Stata8_Copy\IND_2011_NSS68-SCH10_v01_M_Stata8\NSS68_Sch10_bk_5-2.dta", assert(1 3) nogenerate // assert 1 & 3 since subsidiary data is a subset for those with such a second job

** Merge Block 6 follow-up on availability for work, union, ... (also a subset of individuals)
merge 1:1 ID B4_v01 using "`path'\Original\IND_2011_NSS68-SCH10_v01_M_Stata8_Copy\IND_2011_NSS68-SCH10_v01_M_Stata8\NSS68_Sch10_bk_6.dta", assert(1 3) nogenerate

** Merge in Block : 3 HH characteristics
merge m:1 ID using "`path'\Original\IND_2011_NSS68-SCH10_v01_M_Stata8_Copy\IND_2011_NSS68-SCH10_v01_M_Stata8\NSS68_Sch10_bk_3.dta", assert(3) nogenerate
	
	
** Merge interview date info from Block 1_2
merge m:1 ID using "`path'\Original\IND_2011_NSS68-SCH10_v01_M_Stata8_Copy\IND_2011_NSS68-SCH10_v01_M_Stata8\NSS68_Sch10_bk_1_2.dta", assert(3) nogenerate keepusing(B2_v02a)



** COUNTRY
	gen ccode="IND"
	label var ccode "Country code"


** MONTH
	tostring B2_v02a, gen(date)
	gen test = length(date)
	gen  month= ""
	replace month = substr(date,2,2) if test == 5
	replace month = substr(date,3,2) if test == 6
	destring month, replace
	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"


** YEAR
	gen year=2011
	label var year "Year of survey"


** YEAR OF INTERVIEW
	gen intv_year= ""
	replace intv_year = substr(date,4,2) if test == 5
	replace intv_year = substr(date,5,2) if test == 6
	destring intv_year, replace
	replace intv_year = intv_year + 2000 if !missing(intv_year)
	label var intv_year "Year of the interview"
	
	drop date test
	

** HOUSEHOLD IDENTIFICATION NUMBER
	tostring ID, gen(idh) format(%9.0f)
	label var idh "Household id"


** INDIVIDUAL IDENTIFICATION NUMBER
	egen str idp =concat(idh B4_v01)
	label var idp "Individual id"


	isid idp


** HOUSEHOLD WEIGHTS
	gen wgt=hhwt
	label var wgt "Household sampling weight"


** STRATA
	gen strata=B1_v08
	label var strata "Strata"


** PSU
	gen psu=B1_v01 
	destring psu , replace
	label var psu "Primary sampling units"


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	gen urb=B1_v05
	recode urb (2=1) (1=2)

	label var urb "Urban/Rural"
	la de lblurb 1 "Urban" 2 "Rural"
	label values urb lblurb


	/*
	label define state  28 "Andhra Pradesh"  18 "Assam"  10 "Bihar" 24 "Gujarat" 06 "Haryana"  02 "Himachal Pradesh" ///
	01 "Jammu & Kashmir" 29"Karnataka" 32 "Kerala" 23 "Madhya Pradesh" 27  "Maharashtra" ///  
	14 "Manipur"   17 "Meghalaya"  13 "Nagaland"  21 "Orissa"  03 "Punjab" 08 "Rajasthan" 11 "Sikkim" ///
	33 "Tamil Nadu"  16 "Tripura"  09 "Uttar Pradesh"  19 "West Bengal" 35 "A & N Islands" ///
	12 "Arunachal Pradesh"  4 "Chandigarh" 26 "Dadra & Nagar Haveli" 7 "Delhi"  30 "Goa" ///
	31"Lakshdweep" 15 "Mizoram"  34 "Pondicherry"  25 "Daman & Diu" 22"Chhattisgarh" 20"Jharkhand" 5"Uttaranchal"
	
	label values state state
	*/
	
	clonevar reg02 = state	
	label var reg02 "Region at 1 digit(ADMN1)"

**REGIONAL AREAS
	clonevar reg01 = reg02
	label var reg01 "Macro regional areas"

** REGIONAL AREA 2 DIGITS ADM LEVEL (ADMN2)
	gen reg03=B1_v07
	label var reg03 "District (code running inside state) (ADMN2)"


** REGIONAL AREA 3 DIGITS ADM LEVEL (ADMN2)
	gen reg04=.
	label var reg04 "Region at 3 digits (ADMN3)"


** HOUSE OWNERSHIP
	gen ownhouse=.
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	gen water=. /* B7_v18 bringing water from outside premises */
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION
	gen electricity=.
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity


** TOILET PUBLIC CONNECTION
	gen toilet=.
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet


** LAND PHONE
	gen landphone=.
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone


** CEL PHONE
	gen cellphone=.
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone


** COMPUTER
	gen computer=.
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer


** INTERNET
	gen internet=.
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


**HOUSEHOLD SIZE
	gen hhsize = B3_v01
	label var hhsize "Household size"


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	bys idh: gen one=1 if B4_v03==1 
	bys idh: egen temp=count(one) 
	assert temp == 1

	gen head=B4_v03 
	recode head (3 5 = 3) (7=4) (4 6 8 = 5) (9=6)
	label var head "Relationship to the head of household"
	la de lblhead  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values head  lblhead


** GENDER
	gen gender=B4_v04
	label var gender "Gender"
	la de lblgender 1 "Male" 2 "Female"
	label values gender lblgender


** AGE
	gen age = B4_v05
	replace age=98 if age>=98
	label var age "Individual age"



** SOCIAL GROUP

/*
The variable caste exist too, named "B3_v06"
*/
	gen soc=B3_v05 
* B3_v06
	label var soc "Social group"
	label define soc 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 5 "Jainism" 6 "Buddhism" 7 "Zoroastrianism" 9 "Others"
	label values soc soc


** MARITAL STATUS
	gen marital=B4_v06 
	recode marital (1=2) (2=1) (3=5)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen ed_mod_age=0
	label var ed_mod_age "Education module application age"


** CURRENTLY AT SCHOOL
	gen atschool=.
	replace atschool=1 if inrange(B4_v09,21,43)
	replace atschool=0 if inrange(B4_v09,1,15)
	label var atschool "Attending school (ages 0-29)"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen literacy=.
	replace literacy = 0 if B4_v07 == 1
	replace literacy = 1 if inrange(B4_v07,2, 13)
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy

** YEARS OF EDUCATION COMPLETED
	gen educy=.
	/* no education */
	replace educy=0 if B4_v07==01 | B4_v07==02 | B4_v07==03 | B4_v07==04 
	/* below primary */
	replace educy=1 if B4_v07==05
	/* primary */
	replace educy=5 if B4_v07==06
	/* middle */
	replace educy=8 if B4_v07==07
	/* secondary */
	replace educy=10 if B4_v07==8
	/* higher secondary */
	replace educy=12 if B4_v07==10
	/* diploma , certificate - 2 years */
	replace educy=14 if B4_v07==11
	/* graduate  4 years */
	replace educy=16 if B4_v07==12
	/* postgraduate*/
	replace educy=18 if B4_v07==13
	
	* Use age to get in between categories using the ISCED 1997 mapping
	* (http://uis.unesco.org/en/isced-mappings)
	* Entry into primary is 6, entry into middle is at 11, 
	* entry into secondar7 is 14, entry into higher sec is at 16
	* Use age to adapt profile. For example a 17 year old with higher secondary
	* has 11 years of education, not 12
	
	* Primary kids, allow entry from 5
	replace educy = educy - (5 - (age - 5)) if B4_v07 ==06 & inrange(age,5,11)
	* Middle kids
	replace educy = educy - (3 - (age - 11)) if B4_v07 ==07 & inrange(age,11,14)
	* Secondary
	replace educy = educy - (2 - (age - 14)) if B4_v07 ==08 & inrange(age,14,16)
	* Higher secondary
	replace educy = educy - (2 - (age - 16)) if B4_v07 ==10 & inrange(age,16,18)
	
	* Correct if B4_v07 incorrect (e.g., a five year old high schooler)
	replace educy = educy - 4 if (educy > age) & (educy > 0) & !missing(educy) 
	replace educy = 0 if (educy > age) & (age < 4) & (educy > 0) & !missing(educy) 
	replace educy = educy - (8 - age) if (educy > age) & (age >= 4 & age <=8) & (educy > 0) & !missing(educy) 
	replace educy = 0 if educy < 0
	label var educy "Years of education"

** EDUCATIONAL LEVEL 1
	gen edulevel1=.
	replace edulevel1 = 1 if inrange(B4_v07,1,4) // No educ or no formal educ
	replace edulevel1 = 2 if B4_v07 == 6 & educy < 5 // Primary incomplete
	replace edulevel1 = 3 if B4_v07 == 6 & educy >= 5  // Primary complete
	replace edulevel1 = 4 if inrange(B4_v07,7,10) & educy < 12  // Secondary incomplete
	replace edulevel1 = 5 if B4_v07 == 10 & educy >= 12  // Secondary complete
	replace edulevel1=7 if B4_v07==11 | B4_v07==12 | B4_v07==13
	replace edulevel1=8 if  B4_v07==02 | B4_v07==03 | B4_v07==04
	label var edulevel1 "Level of education 1"
	la de lbledulevel1 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete" 8 "Other" 9 "Unstated"
	label values edulevel1 lbledulevel1


	
**EDUCATION LEVEL 2
	gen byte edulevel2=edulevel1
	recode edulevel2 4=3 5=4 6 7=5 8 9=.
	replace edulevel2=. if age<ed_mod_age & age!=.
	label var edulevel2 "Level of education 2"
	la de lbledulevel2 1 "No education" 2 "Primary incomplete"  3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
	label values edulevel2 lbledulevel2


** EDUCATION LEVEL 3
	gen byte edulevel3=edulevel1
	recode edulevel3 2 3=2 4 5=3 6 7=4 8 9=.
	label var edulevel3 "Level of education 3"
	la de lbledulevel3 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values edulevel3 lbledulevel3


** EVER ATTENDED SCHOOL
	gen byte everattend=.
	replace everattend=1 if edulevel3>=2 & edulevel3<=4
	replace everattend=0 if edulevel3==1
	replace everattend=1 if atschool==1
	replace everattend=0 if educy==0 
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend

	replace edulevel1=1 if everattend==0 
	replace edulevel2=1 if everattend==0 
	replace edulevel3=1 if everattend==0 
	
	local ed_var "everattend atschool literacy educy edulevel1 edulevel2 edulevel3"
	foreach v in `ed_var'{
	replace `v'=. if( age<ed_mod_age & age!=.)
	}


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen lb_mod_age=5
	label var lb_mod_age "Labor module application age"


** LABOR STATUS
	gen lstatus=.
	replace lstatus=1 if B51_v03>=11 & B51_v03<=51
	replace lstatus=2 if B51_v03==81
	replace lstatus=3 if B51_v03>=91 & B51_v03<=97
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
	replace lstatus=. if  age<lb_mod_age


** LABOR STATUS LAST YEAR
	gen byte lstatus_year=.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Not employed" 
	label values lstatus_year lbllstatus_year


** EMPLOYMENT STATUS
	gen empstat=.
	replace empstat=1  if B51_v03>=31 & B51_v03<=51
	replace empstat=3 if B51_v03==12
	replace empstat=4 if B51_v03==11
	replace empstat=2 if B51_v03==21 
	replace empstat=. if lstatus!=1 | age<lb_mod_age
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** EMPLOYMENT STATUS LAST YEAR
	gen byte empstat_year=.
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year


** NUMBER OF JOBS
	forval j=1/5{
		gen test_`j' = inrange(B53_v04`j',11,72)
		dis `j'
	}
	egen njobs = rowtotal(test_1 test_2 test_3 test_4 test_5)
	replace njobs = . if lstatus != 1
	replace njobs=1 if njobs==0 & lstatus==1
	label var njobs "Number of additional jobs"


** NUMBER OF JOBS LAST YEAR
	gen byte njobs_year=.
	replace njobs_year=. if lstatus_year!=1
	label var njobs_year "Number of additional jobs during last year"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen ocusec=.
	replace ocusec=1 if B51_v09==5 
	replace ocusec=2 if  B51_v09>=1 & B51_v09<=4 | B51_v09 == 7
	replace ocusec=2 if  B51_v09==8 
	replace ocusec=4 if B51_v09==6
	replace ocusec=. if  B51_v09==9 
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public Sector, Central Government, Army, NGO" 2 "Private" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1


** REASONS NOT IN THE LABOR FORCE
	gen nlfreason=.
	replace nlfreason=1 if B51_v03==91
	replace nlfreason=2 if B51_v03==92|B51_v03==93
	replace nlfreason=3 if B51_v03==94
	replace nlfreason=4 if B51_v03==95
	replace nlfreason=5 if B51_v03==97 
	replace nlfreason=. if lstatus~=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l=B51_v16
	recode unempldur_l 1=0 2=1 4=7 5=10 6=.
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen byte unempldur_u=B51_v16
	recode unempldur_u 2=3 3=7 4=10 5=12 6=.
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"


	tostring B51_v05, format("%05.0f") gen(helper_1)
	gen helper_2=real(substr(helper_1,1,2))


** INDUSTRY CLASSIFICATION
	gen industry=helper_2
	recode industry (1/3 = 1) (5/9= 2) (10/33=3) (35/39=4) (41/43=5) (45 46 47 55 56 =6) (49/53 58/63=7) (64/82=8) (84=9) (85/99= 10)
	replace industry = . if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Public Administration" 10 "Others"
	label values industry lblindustry

	clonevar IND_1digit = industry
	
	clonevar IND_2digit = helper_2
	replace IND_2digit=. if lstatus!=1	
		
** INDUSTRY 1
	gen byte industry1=industry
	recode industry1 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry1=. if lstatus!=1
	label var industry1 "1 digit industry classification (Broad Economic Activities)"
	la de lblindustry1 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1 lblindustry1

	clonevar IND = industry1
	
**SURVEY SPECIFIC INDUSTRY CLASSIFICATION
	gen industry_orig=B51_v05
	replace industry_orig=. if lstatus!=1
	label var industry_orig "Original Industry Codes - Indian NIC -2008"

	clonevar IND_full = industry_orig

** OCCUPATION CLASSIFICATION
	destring B51_v06, ignore(x X) gen(occ_main)
	gen occup= int(occ_main/100) 
	recode occup(0 = 99) // X cases
	replace occup = . if lstatus!=1
	label var occup "1 digit occupational classification"
	label define occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup


** SURVEY SPECIFIC OCCUPATION CLASSIFICATION
	gen occup_orig= B51_v06
	replace occup_orig = "" if lstatus != 1
	label var occup_orig "Original Occupational Codes - India NCO 2004"

	clonevar occup_3 = B51_v06

** FIRM SIZE
	gen firmsize_l=.
	replace firmsize_l=1 if B51_v11==1
	replace firmsize_l=6 if B51_v11==2
	replace firmsize_l=10 if B51_v11==3
	replace firmsize_l=20 if B51_v11==4
	replace firmsize_l=. if B51_v11==9
	label var firmsize_l "Firm size (lower bracket)"

	gen firmsize_u=.
	replace firmsize_u=6 if B51_v11==1
	replace firmsize_u=9 if B51_v11==2
	replace firmsize_u=20 if B51_v11==3
	replace firmsize_u=. if B51_v11==4 |B51_v11==9
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen whours=.
	gen mainhrs = B53_v141
	replace mainhrs=. if  lstatus==2 | lstatus==3
	* Since only day assume 8 hours per day
	replace whours=8*mainhrs
	drop mainhrs
	label var whours "Hours of work in last week"
	


** WAGES
	gen wage= B53_v151
	replace wage=. if lstatus!=1
	replace wage=0 if empstat==2
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen unitwage = .
	replace unitwage=2 if !missing(wage)
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly"
	label values unitwage lblunitwage


** EMPLOYMENT STATUS - SECOND JOB
		gen byte empstat_2=B52_v03
		recode empstat_2 11=4 12=3 21=2 31 41 51 61 62 71 72=1
		replace empstat_2=. if njobs==0 | njobs==.
		label var empstat_2 "Employment status - second job"
		la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
		label values empstat_2 lblempstat_2


			** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
				gen byte empstat_2_year=.
				replace empstat_2_year=. if njobs_year==0 | njobs_year==.
				label var empstat_2_year "Employment status - second job"
				la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
				label values empstat_2 lblempstat_2

		
** INDUSTRY CLASSIFICATION - SECOND JOB
			
	drop helper_1 helper_2
	tostring B52_v05, format("%05.0f") gen(helper_1)
	gen helper_2=real(substr(helper_1,1,2))
	gen industry_2 = helper_2
	recode industry_2 (1/3 = 1) (5/9= 2) (10/33=3) (35/39=4) (41/43=5) (45 46 47 55 56 =6) (49/53 58/63=7) (64/82=8) (84=9) (85/99= 10)
	replace industry_2=. if njobs==0 | njobs==.
	label var industry_2 "1 digit industry classification - second job"			
	label values industry_2  lblindustry


			** INDUSTRY 1 - SECOND JOB
				gen byte industry1_2=industry_2
				recode industry1_2 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
				replace industry1_2=. if njobs==0 | njobs==.
				label var industry1_2 "1 digit industry classification (Broad Economic Activities) - Second job"
				la de lblindustry1_2 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
				label values industry1_2 lblindustry1_2


			**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
				gen industry_orig_2=B52_v05
				replace industry_orig_2=. if njobs==0 | njobs==.
				label var industry_orig_2 "Original Industry Codes - Second job"
				la de lblindustry_orig_2 1""
				label values industry_orig_2 lblindustry_orig_2


			** OCCUPATION CLASSIFICATION - SECOND JOB
				destring B52_v06, ignore(x X) gen(occ_main_2)
				gen occup_2= int(occ_main_2/100) 
				recode occup_2 (0 = 99)
				replace occup_2=. if njobs==0 | njobs==.
				label var occup_2 "1 digit occupational classification - second job"
				la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
				label values occup_2 lbloccup_2


			** WAGES - SECOND JOB
				gen double wage_2= B53_v152
				replace wage_2 = . if lstatus!=1
				replace wage_2 =0 if empstat_2==2
				replace wage_2=. if njobs==0 | njobs==.
				label var wage_2 "Last wage payment - Second job"

				
** WAGES TIME UNIT
	gen unitwage_2 = .
	replace unitwage_2=2 if !missing(wage_2)
	label var unitwage_2 "Last wages time unit"
	la de unitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly"
	label values unitwage unitwage_2


** CONTRACT
	gen contract=B51_v12
	recode contract (1=0) (2 3 4=1)
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract


** HEALTH INSURANCE
	gen healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins


** SOCIAL SECURITY
	gen socialsec=. 
	replace socialsec = 1 if inrange(B51_v14,1,7)
	replace socialsec = 0 if B51_v14 == 8
	replace socialsec = . if lstatus != 1
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


** UNION MEMBERSHIP
	gen union= B6_v15
	recode union (2=0)
	replace union = 0 if inrange(B6_v14,2,9)
	replace union=. if lstatus!=1
	la de lblunion 0 "No member" 1 "Member"
	label var union "Union membership"
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
	gen  rbirth=.
	label var rbirth "Region of Birth"


** REGION OF PREVIOUS RESIDENCE JURISDICTION
	gen byte rprevious_juris=.
	label var rprevious_juris "Region of previous residence jurisdiction"
	la de lblrprevious_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rprevious_juris lblrprevious_juris


**REGION OF PREVIOUS RESIDENCE
	gen  rprevious=.
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
	gen pci=.
	label var pci "Monthly income per capita"


** DECILES OF PER CAPITA INCOME
	gen pci_d=.


** CONSUMPTION PER CAPITA
	gen pcc=.
	label var pcc "Monthly consumption per capita"


** DECILES OF PER CAPITA CONSUMPTION
	gen pcc_d=.
	label var pcc_d "Consumption per capita deciles"


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL FIXES
*                                                                                                    *
*****************************************************************************************************/

	qui su wage
	replace wage=0 if empstat==2 & r(N)!=0


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL
	keep ccode year intv_year month idh idp wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     cellphone computer internet hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage       ///
	empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2  occup_2 wage_2 unitwage_2 ///
	     contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d	///
		 state IND IND_1digit IND_2digit IND_full occup_3


** ORDER VARIABLES
	order ccode year intv_year month idh idp wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     cellphone computer internet hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage       ///
	empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
	     contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d	///
		 state IND IND_1digit IND_2digit IND_full occup_3

	compress


** DELETE MISSING VARIABLES
	local keep ""
	qui levelsof ccode, local(cty)
	foreach var of varlist urb - /*!!! pcc_d -> adjust to our case*/ occup_3 {
	qui sum `var'
	scalar sclrc = r(mean)
	if sclrc==. {
	     display as txt "Variable " as result "`var'" as txt " for ccode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
	}
	else {
	     local keep `keep' `var'
	}
	}
	keep ccode year month intv_year idh idp wgt strata psu `keep'


	save "`path'\Processed\IND_2011_I2D2_NSS-SCH10_v01_M_v02_A.dta", replace
	*save "Z:\__CURRENT\IND_2011_I2D2_NSS_SCH10.dta",replace
	*log close





******************************  END OF DO-FILE  *****************************************************/
