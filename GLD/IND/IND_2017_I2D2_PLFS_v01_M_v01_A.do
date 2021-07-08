/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	India
** COUNTRY ISO CODE	IND
** YEAR	2018
** SURVEY NAME	Periodic Labor Force Survey 2017-2018
** SURVEY AGENCY	
** SURVEY SOURCE	
** UNIT OF ANALYSIS	
** INPUT DATABASES
** RESPONSIBLE	

** Created	Jiang 2020.06
** Updated  Mario Gronert 2021.03

** Modified	
** NUMBER OF HOUSEHOLDS	
** NUMBER OF INDIVIDUALS	
** EXPANDED POPULATION	
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
	local path "Z:\__I2D2\India\2017\PLFS"


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	use "`path'\Original\personvisit1.dta", clear
	distinct hhid
/* -----------------------------
		 |     total   distinct
	------+----------------------
	hhid |    433339     102113
	-----------------------------  */

	distinct hhid personno, joint
/* ----------------------------------
           |     total   distinct
-----------+----------------------
 (jointly) |    433339     433339
---------------------------------- */
	
	merge m:1 hhid using "`path'\Original\hhvisit1.dta", assert(3)
	/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                           433,339  (_merge==3)
    -----------------------------------------	
	*/
	drop _merge
	
** COUNTRY
	gen ccode="IND"
	label var ccode "Country code"

** MONTH
	replace month=. if month==0
	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"

** YEAR
	gen year=2017
	label var year "Year of survey"


** YEAR OF INTERVIEW
	gen intv_year= 2017 if inlist(quarter, "Q1", "Q2")
	replace intv_year = 2018 if inlist(quarter, "Q3", "Q4")
	label var intv_year "Year of the interview"


** HOUSEHOLD IDENTIFICATION NUMBER
	egen idh = concat(hhid)
	label var idh "Household id"


** INDIVIDUAL IDENTIFICATION NUMBER
	egen idp = concat(hhid personno)
	label var idp "Individual id"
	isid idp


** HOUSEHOLD WEIGHTS
	gen wgt=hhwt
	label var wgt "Household sampling weight"


** STRATA
	gen strata=stratum
	label var strata "Strata"


** PSU
	gen psu=fsu
	destring psu , replace
	label var psu "Primary sampling units"


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	gen urb=.
	replace urb=1 if sector==2
	replace urb=2 if sector==1
	label var urb "Urban/Rural"
	la de lblurb 1 "Urban" 2 "Rural"
	label values urb lblurb


**REGIONAL AREAS
	clonevar reg01=nssregion
	label var reg01 "Macro regional areas"

** REGIONAL AREA 1 DIGIT ADMN LEVEL
	fre state
	/*
	Valid   1  Jammu & Kashmir   |      15520       3.58       3.58       3.58
			2  Himachal Pradesh  |       7648       1.76       1.76       5.35
			3  Punjab            |      13374       3.09       3.09       8.43
			4  Chandigarh        |       1389       0.32       0.32       8.75
			5  Uttrakhand        |       7003       1.62       1.62      10.37
			6  Haryana           |      12004       2.77       2.77      13.14
			7  Delhi             |       3956       0.91       0.91      14.05
			8  Rajasthan         |      20771       4.79       4.79      18.85
			9  Uttar Pradesh     |      44933      10.37      10.37      29.21
			10 Bihar             |      22080       5.10       5.10      34.31
			11 Sikkim            |       2627       0.61       0.61      34.92
			12 Arunachal Pradesh |       7320       1.69       1.69      36.61
			13 Nagaland          |       4576       1.06       1.06      37.66
			14 Manipur           |      11193       2.58       2.58      40.24
			15 Mizoram           |       6616       1.53       1.53      41.77
			16 Tripura           |       7150       1.65       1.65      43.42
			17 Meghalaya         |       5980       1.38       1.38      44.80
			18 Assam             |      14806       3.42       3.42      48.22
			19 West Bengal       |      25099       5.79       5.79      54.01
			20 Jharkhand         |      12575       2.90       2.90      56.91
			21 Odisha            |      15886       3.67       3.67      60.58
			22 Chhattisgarh      |      10253       2.37       2.37      62.94
			23 Madhya Pradesh    |      21389       4.94       4.94      67.88
			24 Gujarat           |      15969       3.69       3.69      71.56
			25 Daman & Diu       |        479       0.11       0.11      71.68
			26 D & N Haveli      |        708       0.16       0.16      71.84
			27 Maharashtra       |      33075       7.63       7.63      79.47
			28 Andhra Pradesh    |      14565       3.36       3.36      82.83
			29 Karnataka         |      16691       3.85       3.85      86.68
			30 Goa               |       1661       0.38       0.38      87.07
			31 Lakshadweep       |        638       0.15       0.15      87.21
			32 Kerala            |      17400       4.02       4.02      91.23
			33 Tamil Nadu        |      23614       5.45       5.45      96.68
			34 Puducherry        |       2075       0.48       0.48      97.16
			35 A & N Island      |       1863       0.43       0.43      97.59
			36 Telangana         |      10453       2.41       2.41     100.00
			Total                |     433339     100.00     100.00           	
	*/
	label define lblstate  28 "Andhra Pradesh"  18 "Assam"  10 "Bihar" 24 "Gujarat" 06 "Haryana"  02 "Himachal Pradesh" ///
	01 "Jammu & Kashmir" 29"Karnataka" 32 "Kerala" 23 "Madhya Pradesh" 27  "Maharashtra" ///  
	14 "Manipur"   17 "Meghalaya"  13 "Nagaland"  21 "Orissa"  03 "Punjab" 08 "Rajasthan" 11 "Sikkim" ///
	33 "Tamil Nadu"  16 "Tripura"  09 "Uttar Pradesh"  19 "West Bengal" 35 "A & N Islands" ///
	12 "Arunachal Pradesh"  4 "Chandigarh" 26 "Dadra & Nagar Haveli" 7 "Delhi"  30 "Goa" ///
	31 "Lakshdweep" 15 "Mizoram"  34 "Pondicherry"  25 "Daman & Diu" 22 "Chhattisgarh" 20 "Jharkhand" 5 "Uttaranchal"
	
	label values state lblstate
	
	clonevar reg02 = state
	label var reg02 "Region at 1 digit(ADMN1)"


** REGIONAL AREA 2 DIGITS ADM LEVEL (ADMN2)
	gen reg03=district
	label var reg03 "Region at 2 digits (ADMN2)"


** REGIONAL AREA 3 DIGITS ADM LEVEL (ADMN2)
	gen reg04=.
	label var reg04 "Region at 3 digits (ADMN3)"


** HOUSE OWNERSHIP
	gen ownhouse=.
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse

** WATER PUBLIC CONNECTION
	gen water=.
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
	/*
	gen one=1
	egen two=group(idp one)
	bys idh: egen hhsize= count(two) if rel_head>=1 & rel_head<=8
	label var hhsize "Household size"
	drop one two
	*/
	fre hhsize
	label var hhsize "Household size"

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	bys idh: gen one=1 if  relationtohead==1 
	bys idh: egen temp=count(one) 
	keep if temp==1

	gen head= relationtohead
	recode head (3 5 = 3) (7=4) (4 6 8 = 5) (9=6)
	label var head "Relationship to the head of household"
	la de lblhead  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values head  lblhead
	drop if head==.


** GENDER
	fre sex	/*55 obs with value 3*/
	
	gen gender= sex if inrange(sex, 1,2)
	label var gender "Gender"
	la de lblgender 1 "Male" 2 "Female"
	label values gender lblgender


** AGE
	fre age
	
	label var age "Individual age"
	replace age=98 if age>=98

	
** SOCIAL GROUP
	gen soc=religion
	label var soc "Social group"
	label define soc 1 "Hinduism" 2 "Islam" 3 "Christianity" 4 "Sikhism" 5 "Jainism" 6 "Buddhism" 7 "Zoroastrianism" 9 "Others"
	label values soc soc


** MARITAL STATUS
	gen marital=maritalstat
	recode marital (1=2) (2=1) (3=5)
	replace marital=. if maritalstat==0
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
	gen atschool=1  if currentattendancestat>=21 & currentattendancestat!=.
	replace atschool=0 if currentattendancestat<21 
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen literacy= 1 if inrange(geneducation,2,13)
	replace literacy = 0 if geneducation == 1
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen educy = noyrsformaled
	label var educy "Years of education"

** EDUCATIONAL LEVEL 1
	gen edulevel1=.
	replace edulevel1=1 if geneducation==1
	replace edulevel1=2 if geneducation==5
	replace edulevel1=3 if geneducation==6
	replace edulevel1=4 if geneducation==7|geneducation==8
	replace edulevel1=5 if geneducation==10
	replace edulevel1=7 if geneducation>=11 & geneducation!=.
	replace edulevel1=8 if geneducation==2 |geneducation==3|geneducation==4
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
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend

	replace educy=0 if everattend==0 
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
	gen lstatus=status_cws
	recode lstatus  11/72=1 81 82=2 91/98=3 99=.
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
	replace lstatus=. if  age<lb_mod_age


** LABOR STATUS LAST YEAR
	gen lstatus_year=status_prn
	recode lstatus_year  11/72=1 81 82=2 91/98=3 99=.
	label var lstatus_year "Labor status"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
	replace lstatus_year=. if  age<lb_mod_age


** EMPLOYMENT STATUS
	gen empstat=status_cws
	recode empstat 11=4 12=3 21=2 31 41 42 51 61 62 71 72=1 81/99=.
	replace empstat=. if lstatus!=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** EMPLOYMENT STATUS LAST YEAR
	gen empstat_year=status_prn
	recode empstat_year 11=4 12=3 21=2 31 41 51 61 62 71 72=1 81/99=.
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat_year lblempstat_year


** NUMBER OF JOBS
	gen njobs=.
	label var njobs "Number of jobs"


** NUMBER OF ADDITIONAL JOBS LAST YEAR
	gen byte njobs_year=.
	label var njobs_year "Number of jobs during last year"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	* Since salary information is based on current week, as do hours, but this information is only available from the 12 month recall, use only cases where they match.
	
	
	* Make all the NIC codes comparable
	gen nic_prn_standard = string(nic_prn,"%05.0f")
	gen nic_cws_standard = string(nic_cws,"%02.0f")
	gen nic_prn_reduced = substr(nic_prn_standard,1,2)
	
	gen same_nic = nic_prn_reduced == nic_cws_standard
	gen same_nco = nco_prn == nco_cws
	gen same_same = 1 if (same_nic == 1 & same_nco == 1) & lstatus == 1
	
/*
We lose 7% (11k if 142k) of the observations. 

. tab lstatus same_same,m

     Labor |       same_same
    status |         1          . |     Total
-----------+----------------------+----------
  Employed |   131,820     10,868 |   142,688 
Unemployed |    12,281      2,982 |    15,263 
    Non-LF |   242,415      2,811 |   245,226 
         . |    30,162          0 |    30,162 
-----------+----------------------+----------
     Total |   416,678     16,661 |   433,339 


What is worse, it is unclear whether this change is
random or not. You may say - I believe so - the people who switch jobs are more often than not
people who may struggle to hold a job, have less job security, and work in less formal sectors, 
occupations.

This is the occupation data from the 11K we are dropping (CWS)

tab occup_2

                         occup_2 |      Freq.     Percent        Cum.
---------------------------------+-----------------------------------
                Senior officials |        693        7.19        7.19
                   Professionals |        466        4.83       12.02
                     Technicians |        406        4.21       16.23
                          Clerks |        216        2.24       18.47
Service and market sales workers |        919        9.53       28.01
            Skilled agricultural |      2,772       28.75       56.76
                   Craft workers |      1,390       14.42       71.18
               Machine operators |        405        4.20       75.38
          Elementary occupations |      2,374       24.62      100.00
---------------------------------+-----------------------------------
                           Total |      9,641      100.00

						  
This is for all

. tab occup_2

                         occup_2 |      Freq.     Percent        Cum.
---------------------------------+-----------------------------------
                Senior officials |     11,970        8.46        8.46
                   Professionals |      8,229        5.82       14.28
                     Technicians |      7,633        5.40       19.67
                          Clerks |      4,261        3.01       22.69
Service and market sales workers |     17,788       12.57       35.26
            Skilled agricultural |     36,229       25.61       60.87
                   Craft workers |     18,118       12.81       73.68
               Machine operators |      9,580        6.77       80.45
          Elementary occupations |     27,653       19.55      100.00
---------------------------------+-----------------------------------
                           Total |    141,461      100.00



This is the industry breakdown

. tab industry if same_same == . & lstatus ==1

        1 digit industry classification |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                            Agriculture |      4,318       39.73       39.73
                                 Mining |         59        0.54       40.27
                          Manufacturing |      1,364       12.55       52.82
                       Public utilities |         64        0.59       53.41
                           Construction |      1,888       17.37       70.79
                               Commerce |      1,160       10.67       81.46
          Transports and comnunications |        450        4.14       85.60
Financial and business-oriented service |        436        4.01       89.61
                  Public Administration |        141        1.30       90.91
                                 Others |        988        9.09      100.00
----------------------------------------+-----------------------------------
                                  Total |     10,868      100.00

								  
This is for all
			  
. tab industry

        1 digit industry classification |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                            Agriculture |     48,876       34.25       34.25
                                 Mining |        642        0.45       34.70
                          Manufacturing |     18,624       13.05       47.76
                       Public utilities |      1,176        0.82       48.58
                           Construction |     15,237       10.68       59.26
                               Commerce |     21,759       15.25       74.51
          Transports and comnunications |      9,870        6.92       81.43
Financial and business-oriented service |      6,318        4.43       85.85
                  Public Administration |      4,215        2.95       88.81
                                 Others |     15,971       11.19      100.00
----------------------------------------+-----------------------------------
                                  Total |    142,688      100.00


Firm size no match
								  
. tab entwrk_prn if same_same == . & lstatus ==1

  (Principal) |
       No. Of |
   Workers In |
          The |
   Enterprise |
 B:5.1 I/C:10 |      Freq.     Percent        Cum.
--------------+-----------------------------------
   <6 workers |      2,894       55.50       55.50
  6-9 workers |        608       11.66       67.17
10-19 workers |        379        7.27       74.43
 >=20 workers |        715       13.71       88.15
   don't know |        618       11.85      100.00
--------------+-----------------------------------
        Total |      5,214      100.00
								  
								  
Firm size sizefor all							  

. tab entwrk_prn

  (Principal) |
       No. Of |
   Workers In |
          The |
   Enterprise |
 B:5.1 I/C:10 |      Freq.     Percent        Cum.
--------------+-----------------------------------
   <6 workers |     55,233       55.76       55.76
  6-9 workers |     10,893       11.00       66.76
10-19 workers |      7,449        7.52       74.28
 >=20 workers |     16,416       16.57       90.86
   don't know |      9,057        9.14      100.00
--------------+-----------------------------------
        Total |     99,048      100.00
								  
								  
To recap, we will keep salary, industry, and occupation from the weekly information so
this will not be biased. But information on the enterprise type and social security will be taken from
matching cases. So a breakdwon by those subgroups is potentially biasing the data to look better.
								  
*/

	
	gen ocusec=.
	replace ocusec=2 if  inlist(enttype_prn,1,2,3,4,10,11,12)
	replace ocusec=1 if  inlist(enttype_prn,5,7)
	replace ocusec=3 if  inlist(enttype_prn,6,8)
	replace ocusec=. if  enttype_prn==19 
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public Sector, Central Government, Army, NGO" 2 "Private" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1
	replace ocusec=. if same_same != 1 // dropping where it does not match


** REASONS NOT IN THE LABOR FORCE
	gen nlfreason=.
	replace nlfreason=1 if status_cws==91
	replace nlfreason=2 if status_cws==92|status_cws==93
	replace nlfreason=3 if status_cws==94
	replace nlfreason=4 if status_cws==95
	replace nlfreason=5 if status_cws==97 
	replace nlfreason=. if lstatus~=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disable" 5 "Other"
	
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen unempldur_l=.
	
	/*c51_21
	recode unempldur_l 1=0 2=1 4=7 5=10 6=.
	replace unempldur_l=. if lstatus!=2
	*/
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen unempldur_u=.
	
	/*c51_21
	recode unempldur_u 2=3 3=7 4=10 5=12 6=.
	replace unempldur_u=. if lstatus!=2
	*/
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	recode nic_cws (1/3 = 1) (5/9= 2) (10/33=3) (35/39=4) (41/43=5) (45 46 47 55 56 =6) (49/53 58/63=7) (64/82=8) (84=9) (85/99= 10), gen(industry)
	replace industry = . if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Public Administration" 10 "Others"
	label values industry lblindustry
	
	clonevar IND_1digit = industry
	
	clonevar IND_2digit = nic_cws
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
	clonevar industry_orig=nic_cws
	replace industry_orig=. if lstatus!=1
	label var industry_orig "Original Industry Codes"

	clonevar IND_full = industry_orig

** OCCUPATION CLASSIFICATION
	gen occup= int(nco_cws/100) 
	recode occup(0 = 99)
	replace occup = . if lstatus!=1
	label var occup "1 digit occupational classification"
	label define occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup


** SURVEY SPECIFIC OCCUPATION CLASSIFICATION
	clonevar occup_orig = nco_cws
	replace occup_orig=. if lstatus!=1
	label var occup_orig "Original Occupational Codes"

	clonevar occup_3 = nco_cws
	
** FIRM SIZE
	gen firmsize_l=.
	replace firmsize_l=1  if  entwrk_prn==1
	replace firmsize_l=6  if  entwrk_prn==2
	replace firmsize_l=10 if  entwrk_prn==3
	replace firmsize_l=20 if  entwrk_prn==4
	replace firmsize_l=.  if  entwrk_prn==9
	replace firmsize_l=.  if  lstatus!=1
	label var firmsize_l "Firm size (lower bracket)"
	

	gen firmsize_u=.
	replace firmsize_u=6  if entwrk_prn==1
	replace firmsize_u=9  if entwrk_prn==2
	replace firmsize_u=20 if entwrk_prn==3
	replace firmsize_u=.  if entwrk_prn==4 | entwrk_prn==9
	replace firmsize_u=.  if lstatus!=1
	label var firmsize_u "Firm size (upper bracket)"

	replace firmsize_l = . if same_same != 1
	replace firmsize_u = . if same_same != 1 // dropping where it does not match

** HOURS WORKED LAST WEEK
	egen whours = rowtotal(hrsactual_act1_day1 hrsactual_act1_day2 hrsactual_act1_day3 hrsactual_act1_day4 hrsactual_act1_day5 hrsactual_act1_day6 hrsactual_act1_day7)
	replace whours=. if lstatus!=1
	label var whours "Hours of work in last week"

** WAGES
/* There are three types of wage sources
	--> wages from wage earners (codes 31, 71, 72), at monthly level
	--> estimated wages from self-employed, wroking for HH enterprise 
	(codes 11, 12, 21, 61, 62) at monthly level
	--> wages from casual workers codes (41, 42, 51) summed up over days to weekly

*/

	egen wage_casual = rowtotal(wage_act1_day1 wage_act1_day2 wage_act1_day3 wage_act1_day4 wage_act1_day5 wage_act1_day6 wage_act1_day7)
	gen wage= earnings_monthly_wage if inlist(status_cws,31,71,72)
	replace wage= earning_monthly_selfempl if inlist(status_cws,11, 12, 21, 61, 62)
	replace wage= wage_casual if inlist(status_cws,41, 42, 51)
	replace wage=. if lstatus!=1
	replace wage=0 if empstat==2
	label var wage "Last wage payment"
	drop wage_casual

** WAGES TIME UNIT
	gen unitwage= 5
	replace unitwage=2 if inlist(status_cws,41, 42, 51) & !missing(wage)
	replace unitwage=. if lstatus!=1
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 
	label values unitwage lblunitwage


** EMPLOYMENT STATUS - SECOND JOB
	gen byte empstat_2=.
	label var empstat_2 "Employment status - second job"
				la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
				label values empstat_2 lblempstat_2


** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
	gen byte empstat_2_year=.
	label var empstat_2_year "Employment status - second job"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2


** INDUSTRY CLASSIFICATION - SECOND JOB
	gen industry_2=. 
	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2  lblindustry_2


** INDUSTRY 1 - SECOND JOB
	gen byte industry1_2=.
	label var industry1_2 "1 digit industry classification (Broad Economic Activities) - Second job"
	la de lblindustry1_2 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1_2 lblindustry1_2


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
	gen industry_orig_2=.
	label var industry_orig_2 "Original Industry Codes - Second job"
	la de lblindustry_orig_2 1""
	label values industry_orig_2 lblindustry_orig_2


** OCCUPATION CLASSIFICATION - SECOND JOB
	gen occup_2= .
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
				label values occup_2 lbloccup_2


** WAGES - SECOND JOB
	gen double wage_2= .
	label var wage_2 "Last wage payment - Second job"


** WAGES TIME UNIT - SECOND JOB
	gen unitwage_2=.
	label var unitwage_2 "Last wages time unit - Second job"
	la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_2 lblunitwage_2


** CONTRACT
	gen contract= jobcontract_prn
	recode contract (1=0) (2 3 4=1)
	replace contract=. if lstatus!=1
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
	replace contract = . if same_same != 1 // dropping where it does not match


** HEALTH INSURANCE
	gen healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins


** SOCIAL SECURITY
	gen socialsec=.
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


** UNION MEMBERSHIP
	gen union= .
	la de lblunion 0 "No member" 1 "Member"
	label var union "Union membership"
	label values union lblunion

	local lb_var "lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage  empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2  occup_2 wage_2 unitwage_2 contract healthins socialsec union"
	foreach v in `lb_var'{
	di "check `v' only for age>=lb_mod_age"

	replace `v'=. if( age<lb_mod_age & age!=.)
	}


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
	gen pcc=mpce_usual/hhsize
	label var pcc "Monthly consumption per capita"


** DECILES OF PER CAPITA CONSUMPTION
	xtile pcc_d=pcc[w=wgt], nq(10)
	label var pcc_d "Consumption per capita deciles"



/*****************************************************************************************************
*                                                                                                    *
                                   FINAL FIXES
*                                                                                                    *
*****************************************************************************************************/

	qui su wage
	replace wage=0 if empstat==2 & r(N)!=0
	replace ownhouse=. if head==6

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

	save "`path'\Processed\IND_2017_I2D2_PLFS_v01_M_v01_A.dta", replace
	*log close


******************************  END OF DO-FILE  *****************************************************/