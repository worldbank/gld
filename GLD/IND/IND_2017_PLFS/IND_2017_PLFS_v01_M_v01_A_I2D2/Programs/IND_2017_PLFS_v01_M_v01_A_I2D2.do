/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	India
** COUNTRY ISO CODE	IND
** YEAR	2017
** SURVEY NAME	Periodic Labor Force Survey 2017-2018
** SURVEY AGENCY	
** SURVEY SOURCE	
** UNIT OF ANALYSIS	
** INPUT DATABASES
** RESPONSIBLE	

** Created	Jiang 2020.06
** Updated  Mario Gronert 2021.07

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
	local path_in "C:\Users\wb529026\OneDrive - WBG\Documents\Country Work\IND\IND_2017_PLFS\IND_2017_PLFS_v01_M"


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	use "`path_in'\Data\Stata\IND_2017_PLFS_raw_IND_Stata.dta", clear

	gen str1 h_1 = string(sample_sg_b_no,"%01.0f")
	gen str1 h_2 = string(ss_stratum,"%01.0f")
	gen str2 h_3 = string(hh_num,"%02.0f")

	egen str9 hh_key = concat(fsu h_1 h_2 h_3)
	drop h_*
	
	tempfile ind_file
	save `ind_file'
	
	use "`path_in'\Data\Stata\IND_2017_PLFS_raw_HH_Stata.dta", clear
	
	gen str1 h_1 = string(sample_sg_b_no,"%01.0f")
	gen str1 h_2 = string(ss_stratum,"%01.0f")
	gen str2 h_3 = string(hh_num,"%02.0f")

	egen str9 hh_key = concat(fsu h_1 h_2 h_3)
	drop h_*
	
	merge 1:m hh_key using `ind_file', assert(3)
	drop _merge hh_key
	
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
	gen str1 h_1 = string(sample_sg_b_no,"%01.0f")
	gen str1 h_2 = string(ss_stratum,"%01.0f")
	gen str2 h_3 = string(hh_num,"%02.0f")
	gen str2 h_4 = string(person_no,"%02.0f")

	egen str9 idh = concat(fsu h_1 h_2 h_3)
	label var idh "Household id"


** INDIVIDUAL IDENTIFICATION NUMBER
	egen idp = concat(idh h_4)
	label var idp "Individual id"
	isid idp
	drop h_*

** HOUSEHOLD WEIGHTS
	gen wgt= .
	destring mult, replace
	replace wgt = mult/400 if nss_code == nsc_code
	replace wgt = mult/800 if nss_code != nsc_code
	* Lakshadweep has only three quarters so divide by 200*3 instead of *4
	replace wgt = mult/600 if state == 31
	count if missing(wgt)
	assert `r(N)' == 0
	label var wgt "Household sampling weight"


** STRATA
	gen strata=stratum
	label var strata "Strata"


** PSU
	gen psu=fsu
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
	clonevar reg01 = state
	label var reg01 "Macro regional areas"

** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen reg02 = state
	label define lblreg02 01 "Jammu & Kashmir" 02 "Himachal Pradesh" 03 "Punjab" 04 "Chandigarh" 05 "Uttrakhand" 06 "Haryana" 07 "Delhi" 08 "Rajasthan" 09 "Uttar Pradesh" 10 "Bihar" 11 "Sikkim" 12 "Arunachal Pradesh" 13 "Nagaland" 14 "Manipur" 15 "Mizoram" 16 "Tripura" 17 "Meghalaya" 18 "Assam" 19 "West Bengal" 20 "Jharkhand" 21 "Odisha" 22 "Chhattisgarh" 23 "Madhya Pradesh" 24 "Gujarat" 25 "Daman & Diu" 26 "D & N Haveli" 27 "Maharashtra" 28 "Andhra Pradesh" 29 "Karnataka" 30 "Goa" 31 "Lakshadweep" 32 "Kerala" 33 "Tamil Nadu" 34 "Puducherry" 35 "A & N Island" 36 "Telangana"
	label values reg02 lblreg02
	label var reg02 "Region at 1 digits (ADMN1)"

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
	gen hhsize = hh_size 
	label var hhsize "Household size"

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	bys idh: gen one=1 if  rel_head==1 
	bys idh: egen temp=count(one) 
	keep if temp==1

	gen head= rel_head
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
	gen maritalstat = marital
	drop marital
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
	gen atschool=1  if current_attendance>=21 & current_attendance!=.
	replace atschool=0 if current_attendance<21 
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen literacy= 1 if inrange(general_ed,2,13)
	replace literacy = 0 if general_ed == 1
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen educy = years_formal_ed
	label var educy "Years of education"


** EDUCATIONAL LEVEL 1
	gen edulevel1=.
	replace edulevel1=1 if general_ed==1
	replace edulevel1=2 if general_ed==5
	replace edulevel1=3 if general_ed==6
	replace edulevel1=4 if general_ed==7|general_ed==8
	replace edulevel1=5 if general_ed==10
	replace edulevel1=7 if general_ed>=11 & general_ed!=.
	replace edulevel1=8 if general_ed==2 |general_ed==3|general_ed==4
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
	gen lstatus = cws
	recode lstatus  (11/72=1) (81 82=2) (91/98=3) (99=.)
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
	replace lstatus=. if  age<lb_mod_age


** LABOR STATUS LAST YEAR
	* We will code with "usual activity" as the indian ministry does. This is the
	* sum of primary and subsidiary
	gen prim=p_status_code
	recode prim  11/72=1 81 82=2 91/98=3 99=.
	gen sub=s_status_code
	recode sub  11/72=1 81 82=2 91/98=3 99=.
	tab prim sub,m
	drop prim sub
	* See that there are 4526 cases where primary is not employed but subsidiary is,
	* need to take into account
	
	gen lstatus_year=p_status_code
	recode lstatus_year  11/72=1 81 82=2 91/98=3 99=.
	* Bring in those in subsidiary status working
	replace lstatus_year = 1 if inrange(lstatus_year,2,3) & inrange(s_status_code,11,72)
	replace lstatus_year = 2 if lstatus_year == 3 & inrange(s_status_code,81,82)
	label var lstatus_year "Labor status"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus_year lbllstatus_year
	replace lstatus_year=. if  age<lb_mod_age


** EMPLOYMENT STATUS
	gen empstat=cws
	recode empstat (11=4) (12=3) (21 61 62=2) (31 41 42 51 71 72=1) (81/99=.)
	replace empstat=. if lstatus!=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** EMPLOYMENT STATUS LAST YEAR
	gen empstat_year=p_status_code
	recode empstat_year (11=4) (12=3) (21 61 62=2) (31 41 42 51 71 72=1) (81/99=.)
	gen subsid_helper = s_status_code if missing(empstat_year) & lstatus_year == 1
	recode subsid_helper (11=4) (12=3) (21 61 62=2) (31 41 42 51 71 72=1) (81/99=.)
	replace empstat_year = subsid_helper if missing(empstat_year) & lstatus_year == 1
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat_year lblempstat_year
	drop subsid_helper


** NUMBER OF JOBS
	gen njobs=.
	label var njobs "Number of jobs"


** NUMBER OF ADDITIONAL JOBS LAST YEAR
	gen byte njobs_year=.
	label var njobs_year "Number of jobs during last year"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
* Since salary information is based on current week, as do hours, but this information is only available from the 12 month recall, use only cases where they match.
	
	
	* Make all the NIC codes comparable
	gen nic_cws_standard = string(cws_nic,"%02.0f")
	gen nic_prn_reduced = substr(p_industry_code,1,2)
	
	gen same_nic = nic_prn_reduced == nic_cws_standard
	gen same_nco = p_occup_code == cws_noc
	gen same_same = 1 if (same_nic == 1 & same_nco == 1) & lstatus == 1
	
	gen prim=p_status_code
	recode prim  11/72=1 81 82=2 91/98=3 99=.
	gen sub=s_status_code
	recode sub  11/72=1 81 82=2 91/98=3 99=.
	
	gen helper_s_nic = substr(s_industry_nic_code,1,2)
	gen helper_nic_same_2 = helper_s_nic == nic_cws_standard if inrange(prim,2,3) & sub == 1
	gen helper_noc_same_2 = s_occupation_nco_code == cws_noc if inrange(prim,2,3) & sub == 1
	replace same_same = 1 if inrange(prim,2,3) & sub == 1 & (same_nic == 1 & same_nco == 1) & lstatus == 1
	drop prim sub same_nic same_nco helper_s_nic helper_nic_same_2 helper_noc_same_2
	
/*
We lose 7% (11k if 142k) of the observations. 

. tab lstatus same_same,m

     Labor |       same_same
    status |         1          . |     Total
-----------+----------------------+----------
  Employed |   131,820     10,868 |   142,688 
Unemployed |         0     15,263 |    15,263 
    Non-LF |         0    245,226 |   245,226 
         . |         0     30,162 |    30,162 
-----------+----------------------+----------
     Total |   131,820    301,519 |   433,339 


What is worse, it is unclear whether this change is
random or not. You may say - I believe so - the people who switch jobs are more often than not people who may struggle to hold a job, have less job security, and work in less formal sectors, 
occupations.

This is the occupation data from the 11K we are dropping (CWS) (developed below)

tab occup if same_same != 1

                         occup |      Freq.     Percent        Cum.
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

						  
This is for all (before applying same_same cut)

. tab occup

                         occup |      Freq.     Percent        Cum.
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
								  
. tab p_no_workrs_ent if same_same == . & lstatus ==1

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

. tab p_no_workrs_ent

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
	replace ocusec=2 if  inlist(p_ent_type_code,1,2,3,4,8,10,11,12)
	replace ocusec=1 if  inlist(p_ent_type_code,5,7)
	replace ocusec=3 if  inlist(p_ent_type_code,6)
	replace ocusec=. if  p_ent_type_code==19 
	
	* Now bring in subsidiary information
	gen prim=p_status_code
	recode prim  11/72=1 81 82=2 91/98=3 99=.
	gen sub=s_status_code
	recode sub  11/72=1 81 82=2 91/98=3 99=.
	gen subsid_helper = .
	replace subsid_helper=2 if inrange(prim,2,3) & sub == 1 & inlist(s_ent_type_code,1,2,3,4,8,10,11,12)
	replace subsid_helper=1 if inrange(prim,2,3) & sub == 1 & inlist(s_ent_type_code,5,7)
	replace subsid_helper=3 if inrange(prim,2,3) & sub == 1 & inlist(s_ent_type_code,6)
	replace subsid_helper=. if inrange(prim,2,3) & sub == 1 & s_ent_type_code==19 
	
	* Add in subsidiary info
	replace ocusec = subsid_helper if inrange(prim,2,3) & sub == 1
	drop prim sub subsid_helper
	
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public Sector, Central Government, Army, NGO" 2 "Private" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1
	replace ocusec=. if same_same != 1 // dropping where it does not match
	

** REASONS NOT IN THE LABOR FORCE
	gen nlfreason=.
	replace nlfreason=1 if cws==91
	replace nlfreason=2 if cws==92|cws==93
	replace nlfreason=3 if cws==94
	replace nlfreason=4 if cws==95
	replace nlfreason=5 if cws==97 
	replace nlfreason=. if lstatus~=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	recode cws_nic (1/3 = 1) (5/9= 2) (10/33=3) (35/39=4) (41/43=5) (45 46 47 55 56 =6) (49/53 58/63=7) (64/82=8) (84=9) (85/99= 10), gen(industry)
	replace industry = . if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Public Administration" 10 "Others"
	label values industry lblindustry
	replace industry=. if lstatus!=1	
		
** INDUSTRY 1
	gen byte industry1=industry
	recode industry1 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry1=. if lstatus!=1
	label var industry1 "1 digit industry classification (Broad Economic Activities)"
	la de lblindustry1 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1 lblindustry1
	

**SURVEY SPECIFIC INDUSTRY CLASSIFICATION
	clonevar industry_orig=cws_nic
	replace industry_orig=. if lstatus!=1
	label var industry_orig "NIC 2008 2 digit code"

	clonevar IND_full = industry_orig

** OCCUPATION CLASSIFICATION
	destring cws_noc, gen(occup)
	replace occup= int(occup/100) 
	replace occup = . if lstatus!=1
	label var occup "1 digit occupational classification"
	label define occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup


** SURVEY SPECIFIC OCCUPATION CLASSIFICATION
	gen occup_orig = cws_noc
	replace occup_orig="" if lstatus!=1
	label var occup_orig "Original Occupational Codes NCO 2004"


** FIRM SIZE
	gen firmsize_l=.
	replace firmsize_l=1  if  p_no_workrs_ent==1
	replace firmsize_l=6  if  p_no_workrs_ent==2
	replace firmsize_l=10 if  p_no_workrs_ent==3
	replace firmsize_l=20 if  p_no_workrs_ent==4
	replace firmsize_l=.  if  p_no_workrs_ent==9
	replace firmsize_l=.  if  lstatus!=1
	
	* Now bring in subsidiary information
	gen prim=p_status_code
	recode prim  11/72=1 81 82=2 91/98=3 99=.
	gen sub=s_status_code
	recode sub  11/72=1 81 82=2 91/98=3 99=.
	
	gen helper_l =.
	replace helper_l=1  if inrange(prim,2,3) & sub == 1 & s_no_workrs_ent==1
	replace helper_l=6  if inrange(prim,2,3) & sub == 1 & s_no_workrs_ent==2
	replace helper_l=10 if inrange(prim,2,3) & sub == 1 & s_no_workrs_ent==3
	replace helper_l=20 if inrange(prim,2,3) & sub == 1 & s_no_workrs_ent==4
	replace helper_l=.  if inrange(prim,2,3) & sub == 1 & s_no_workrs_ent==9

	replace firmsize_l = helper_l if inrange(prim,2,3) & sub == 1
	label var firmsize_l "Firm size (lower bracket)"
	
	gen firmsize_u=.
	replace firmsize_u=6  if p_no_workrs_ent==1
	replace firmsize_u=9  if p_no_workrs_ent==2
	replace firmsize_u=20 if p_no_workrs_ent==3
	replace firmsize_u=.  if p_no_workrs_ent==4 | p_no_workrs_ent==9
	replace firmsize_u=.  if lstatus!=1
	label var firmsize_u "Firm size (upper bracket)"

	gen helper_u =.
	replace helper_u=1  if inrange(prim,2,3) & sub == 1 & s_no_workrs_ent==1
	replace helper_u=6  if inrange(prim,2,3) & sub == 1 & s_no_workrs_ent==2
	replace helper_u=10 if inrange(prim,2,3) & sub == 1 & s_no_workrs_ent==3
	replace helper_u=20 if inrange(prim,2,3) & sub == 1 & s_no_workrs_ent==4
	replace helper_u=.  if inrange(prim,2,3) & sub == 1 & s_no_workrs_ent==9
	
	replace firmsize_l = helper_u if inrange(prim,2,3) & sub == 1
	label var firmsize_l "Firm size (lower bracket)"
	
	replace firmsize_l = . if same_same != 1
	replace firmsize_u = . if same_same != 1 // dropping where it does not match
	
	drop prim sub helper_l helper_u

** HOURS WORKED LAST WEEK
	* Hours worked is coded as line item, but there are two items, need
	* to make sure this is the same as cws. If the same, use the hours,
	* if not, check whether second activity matches, then add.
	gen whours = 0

	foreach num of numlist 1/7{
		
		gen act_1_eq_cws_`num' = status_code_act_1_day_`num' == cws
		gen act_2_eq_cws_`num' = status_code_act_2_day_`num' == cws
		replace whours = whours + hours_act_1_day_`num' if act_1_eq_cws_`num' == 1
		replace whours = whours + hours_act_2_day_`num' if act_1_eq_cws_`num' == 0 & act_2_eq_cws_`num' == 1
	 }
	replace whours=. if lstatus!=1
	label var whours "Hours of work in last week"
	
	
** WAGES
/* There are three types of wage sources
	--> wages from wage earners (codes 31, 71, 72), at monthly level
	--> estimated wages from self-employed, wroking for HH enterprise 
	(codes 11, 12, 21, 61, 62) at monthly level
	--> wages from casual workers codes (41, 42, 51) summed up over days to weekly
*/

	egen wage_casual = rowtotal(wage_act_1_day_7 wage_act_1_day_6 wage_act_1_day_5 wage_act_1_day_4 wage_act_1_day_3 wage_act_1_day_2 wage_act_1_day_1)
	gen wage= earnings_salaried if inlist(cws,31,71,72)
	replace wage= earnings_selfemp if inlist(cws,11, 12, 21, 61, 62)
	replace wage= wage_casual if inlist(cws,41, 42, 51)
	replace wage=. if lstatus!=1
	replace wage=0 if empstat==2
	replace wage=. if wage < 0 // 6 weird cases
	label var wage "Last wage payment"
	drop wage_casual

** WAGES TIME UNIT
	gen unitwage= 5
	replace unitwage=2 if inlist(cws,41, 42, 51) & !missing(wage)
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
	gen byte empstat_2_year = s_status_code if inrange(p_status_code,11,72)
	recode empstat_2_year (11=4) (12=3) (21 61 62=2) (31 41 42 51 71 72=1) (81/99=.)
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
	gen prim=p_status_code
	recode prim  11/72=1 81 82=2 91/98=3 99=.
	gen sub=s_status_code
	recode sub  11/72=1 81 82=2 91/98=3 99=.
	
	gen contract= p_type_contract
	recode contract (1=0) (2 3 4=1)
	replace contract=. if lstatus!=1
	
	gen helper_contract =  s_type_contract
	recode helper_contract (1=0) (2 3 4=1)

	replace contract = helper_contract if inrange(prim,2,3) & sub == 1
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
	replace contract = . if same_same != 1 // dropping where it does not match

	drop prim sub helper_contract
	
	
** HEALTH INSURANCE
	gen healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins


** SOCIAL SECURITY
	gen prim=p_status_code
	recode prim  11/72=1 81 82=2 91/98=3 99=.
	gen sub=s_status_code
	recode sub  11/72=1 81 82=2 91/98=3 99=.
	
	gen socialsec= p_social_sec
	recode socialsec (1/7=1) (8=0) (9=.)
	replace socialsec=. if lstatus!=1
	
	gen helper_socialsec =  s_social_sec
	recode helper_socialsec (1/7=1) (8=0) (9=.)

	replace socialsec = helper_socialsec if inrange(prim,2,3) & sub == 1
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec
	replace socialsec = . if same_same != 1 // dropping where it does not match

	drop prim sub helper_socialsec

	
** UNION MEMBERSHIP
	gen union= .
	la de lblunion 0 "No member" 1 "Member"
	label var union "Union membership"
	label values union lblunion

	local lb_numeric_var "lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason unempldur_l unempldur_u industry industry1 industry_orig occup firmsize_l firmsize_u whours wage unitwage  empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2  occup_2 wage_2 unitwage_2 contract healthins socialsec union"
	foreach v in `lb_var'{
	di "check `v' only for age>=lb_mod_age"

	replace `v'=. if( age<lb_mod_age & age!=.)
	}

	local lb_string_var "occup_orig"
	foreach v in `lb_var'{
	di "check `v' only for age>=lb_mod_age"

	replace `v'= "" if( age<lb_mod_age & age!=.)
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
	gen pcc=.
	label var pcc "Monthly consumption per capita"


** DECILES OF PER CAPITA CONSUMPTION
	gen pcc_d = .
	label var pcc_d "Consumption per capita deciles"


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
		 state


** ORDER VARIABLES
	order ccode year intv_year month idh idp wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     cellphone computer internet hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage       ///
	empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
	     contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d	///
		 state

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
	keep ccode year month intv_year idh idp wgt strata psu `keep'

	save "C:\Users\wb529026\OneDrive - WBG\Documents\Country Work\IND\IND_2017_PLFS\IND_2017_PLFS_v01_M_v01_A_I2D2\Data\Harmonized\IND_2017_PLFS_v01_M_v01_A_I2D2.dta", replace
	*log close


******************************  END OF DO-FILE  *****************************************************/