/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY					South Africa
** COUNTRY ISO CODE			ZAF
** YEAR						2017
** SURVEY NAME				Labour Market Dynamics
** SURVEY AGENCY			Statistics South Africa (Stats SA)
** SURVEY SOURCE			DataFirst, https://www.datafirst.uct.ac.za/dataportal/index.php/catalog/727
** UNIT OF ANALYSIS			Household and individual
** INPUT DATABASES			Z:\_GLD-Harmonization\573465_JT\ZAF\ZAF_2017_LFS\ZAF_2017_LFS_v01_M\data\stata\lmdsa-2017-1.0-stata11.dta
** RESPONSIBLE				Wolrd Bank Job's Group
** Created					6/7/2021
** Modified					10/26/2021
** NUMBER OF HOUSEHOLDS		39,418
** NUMBER OF INDIVIDUALS	132,713
** EXPANDED POPULATION	 	55,891,484
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
	local 	drive 	`"Z"'
	local 	cty 	`"ZAF"'
	local 	usr		`"573465_JT"'
	local 	surv_yr `"2017"'
	local 	year 	"`drive':\GLD-Harmonization\\`usr'\\`cty'\\`cty'_`surv_yr'_LFS"
	local 	main	"`year'\\`cty'_`surv_yr'_LFS_v01_M"
	local 	stata	"`main'\data\stata"
	local 	gld 	"`year'\\`cty'_`surv_yr'_LFS_v01_M_v01_A_GLD"
	local 	i2d2	"`year'\\`cty'_`surv_yr'_LFS_v01_M_v01_A_I2D2"
	local 	code 	"`i2d2'\Programs"
	local 	id_data "`i2d2'\Data\Harmonized"

	local input "`stata'"
	local output "`id_data'"


** LOG FILE
	log using "`id_data'\ZAF_2017_QLFS_V01_M_v01_A_I2D2", replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

	use "`input'\lmdsa-2017-1.0-stata11.dta", clear


** COUNTRY
	gen str4 ccode="ZAF"
	label var ccode "Country code"


** YEAR
	gen int year=2017
	label var year "Year of survey"


** YEAR OF INTERVIEW
	gen int intv_year=.
	label var intv_year "Year of the interview"


** MONTH OF INTERVIEW
	gen byte month=.
	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"


** HOUSEHOLD IDENTIFICATION NUMBER
	gen idh=UQNO
	label var idh "Household id"

	tostring PERSONNO, gen(idp) format(%02.0f)
	tostring Qtr, gen(wave) format(%02.0f)
	replace wave="Q"+substr(wave, 2, 1)


** INDIVIDUAL IDENTIFICATION NUMBER
	replace idp=idh+idp
	label var idp "Individual id"


** HOUSEHOLD WEIGHTS
	gen double wgt=Weight
	label var wgt "Household sampling weight"


** STRATA
	gen strata=STRATUM
	label var strata "Strata"


** PSU

/*
Total psu: 3,556
Q1:3,249
Q2:3,254
Q3:3,244
Q4:3,224
*/
	gen psu=substr(UQNO, 1, 8)
	label var psu "Primary sampling units"

/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)

/* It is not clear how the three categories are defined because the code list in the
documentation does not match the raw dataset. According to QLFS documentation and
urbanization stats from:
 https://data.worldbank.org/indicator/SP.URB.TOTL.IN.ZS?locations=ZA,
the final code list should be
1=urban
2=traditional(rural)
3=farms/mining areas(rural)
*/
	gen byte urb=Geo_type_code
	recode urb 1=1 2/3=2
	label var urb "Urban/Rural"
	la de lblurb 1 "Urban" 2 "Rural"
	label values urb lblurb


**REGIONAL AREAS
	gen byte reg01=Province
	label var reg01 "Macro regional areas"
	label values reg01 Province


** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen byte reg02=Province
	label var reg02 "Region at 1 digit (ADMN1)"
	label values reg02 Province


** REGIONAL AREA 2 DIGITS ADM LEVEL (ADMN2)
	gen reg03=Metro_code
	label var reg03 "Region at 2 digits (ADMN2)"
	label values reg03 Metro_code


** REGIONAL AREA 3 DIGITS ADM LEVEL (ADMN2)
	gen reg04=.
	label var reg04 "Region at 3 digits (ADMN3)"


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


** CEL PHONE
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
	egen tag=tag(idp idh)
	egen hhsize=total(tag), by(idh)
	drop tag
	label var hhsize "Household size"


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD

/*
Not asked, all we know is that the person with personal number equal to 1 is the head, the problem is that in some cases that person is not present, probably because he/she didn't spend four nights or more in this household. In those cases I assigned the eldest adult male (or female absent male) present as the household head.
103 observations were dropped due to no male memeber or multiple same old male (or female) members.
Age of majority is 18 in South Africa.

DROPS:
OBS: 103
HH: 45
REGIONAL DISTRIBUTION:
Subnational ID at |
            First |
   Administrative |
            Level |      Freq.     Percent        Cum.
------------------+-----------------------------------
 1 - Western Cape |          5        4.85        4.85
 2 - Eastern Cape |         27       26.21       31.07
3 - Northern Cape |          1        0.97       32.04
   4 - Free State |          6        5.83       37.86
5 - KwaZulu-Natal |         21       20.39       58.25
   6 - North West |          4        3.88       62.14
      7 - Gauteng |         19       18.45       80.58
   8 - Mpumalanga |          6        5.83       86.41
      9 - Limpopo |         14       13.59      100.00
------------------+-----------------------------------
            Total |        103      100.00
*/

	gen byte head=1 if PERSONNO==1
	bys idh: egen hh=sum(head==1)
	bys idh: egen maxage=max(Q14AGE)
	replace maxage=. if maxage<18
	replace head=1 if hh==0 & Q14AGE==maxage
	bys idh: egen hh2=sum(head==1)
	drop hh
	preserve
	collapse (max) head, by(idp idh hh2)
	bys idh: egen hh3=sum(head)
	drop hh2
	tempfile head_collapse
	save `head_collapse'
	restore
	merge m:1 idh idp using `head_collapse'
	drop _merge
	replace head=. if hh3==2 & Q13GENDER==2 & head==1
	bys idh: egen hh4=sum(head==1)
	preserve
	collapse (max) head, by(idp idh hh4)
	bys idh: egen hh5=sum(head)
	save `head_collapse', replace
	restore
	merge m:1 idh idp using `head_collapse'
	drop _merge
	bys idh: egen male_present=max(Q13GENDER)
	replace male_present=0 if male_present==2
	replace head=1 if hh5==0 & maxage>=18 & maxage<. & Q14AGE==maxage & male_present==0
	preserve
	collapse (max) head, by(idp idh hh5)
	bys idh: egen hh6=sum(head)
	save `head_collapse', replace
	restore
	merge m:1 idh idp using `head_collapse'
	drop if hh6!=1
	bys idp: egen head_max=max(!missing(head))
	bys idp: egen head_min=min(!missing(head))
	replace head=1 if head_max==1&head_min==0
	drop _merge hh2 hh3 hh4 hh5 hh6 head_* _merge maxage male_present
	label var head "Relationship to the head of household"
	la de lblhead  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values head lblhead


** GENDER
	gen byte gender=Q13GENDER
	label var gender "Gender"
	la de lblgender 1 "Male" 2 "Female"
	label values gender lblgender


** AGE
	gen byte age=Q14AGE
	replace age=98 if age>98 & age!=.
	label var age "Individual age"


** SOCIAL GROUP
	gen byte soc=Q15POPULATION
	label var soc "Social group"
	la de lblsoc 1 ""
	label values soc Q15POPULATION


** MARITAL STATUS
	gen byte marital=Q16MARITALSTATUS
	recode marital 5=2 2=3 3=5
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen byte ed_mod_age=0
	label var ed_mod_age "Education module application age"


** CURRENTLY AT SCHOOL
	gen byte atschool=Q19ATTE
	recode atschool 2=0
	replace atschool=. if age<ed_mod_age & age!=.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen byte literacy=.
	replace literacy=. if age<ed_mod_age & age!=.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED

/*
The National Technical Certificate level 1, 2, and 3 are mapped to grade 10, 11, and 12
respectively. In South Africa, one option for students is to exit school with GETC
or grade 9 and enter a technical education program at N1, proceeding to N2.

57 observations' years of education exceed their age:

Individual |                      Highest education level
       age | Grade 7/S  Grade 8/S  Grade 9/S  Grade 10/  Grade 11/  Grade 12/ |     Total
-----------+------------------------------------------------------------------+----------
         6 |         2          4          3          1          1          0 |        11
         7 |         0          8          4          2          3          2 |        20
         8 |         0          0          6          3          2          3 |        14
         9 |         0          0          0          3          3          1 |         8
        10 |         0          0          0          0          1          1 |         2
        11 |         0          0          0          0          0          1 |         1
        13 |         0          0          0          0          0          0 |         1
-----------+------------------------------------------------------------------+----------
     Total |         2         12         13          9         10          8 |        57

Individual |     Highest education level
       age | NTC l/N1/   N5/NTC 5  Certifica |     Total
-----------+---------------------------------+----------
         6 |         0          0          0 |        11
         7 |         0          0          1 |        20
         8 |         0          0          0 |        14
         9 |         1          0          0 |         8
        10 |         0          0          0 |         2
        11 |         0          0          0 |         1
        13 |         0          1          0 |         1
-----------+---------------------------------+----------
     Total |         1          1          1 |        57
*/

	gen byte educy=Q17EDUCATION if inrange(Q17EDUCATION,0,12)
	replace educy=Q17EDUCATION-3 if inrange(Q17EDUCATION,13,18)
	replace educy=11 if inrange(Q17EDUCATION,19,20)
	replace educy=12 if inrange(Q17EDUCATION,21,22)
	replace educy=16 if inlist(Q17EDUCATION,23,25, 26)
	replace educy=19 if inlist(Q17EDUCATION,24,27,28)
	replace educy=. if inlist(Q17EDUCATION,29,30,31)
	replace educy=0 if Q17EDUCATION==98
	replace educy=. if age<ed_mod_age & age!=.
	replace educy=age if educy>age & !mi(educy) & !mi(age)
	label var educy "Years of education"


** EDUCATIONAL LEVEL 1
	gen byte edulevel1=Education_Status
	recode edulevel1 7=8
	replace edulevel1=7 if inrange(Q17EDUCATION,21,28)
	replace edulevel1=. if age<ed_mod_age & age!=.
	label var edulevel1 "Level of education 1"
	la de lbledulevel1 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete" 8 "Other" 9 "Unstated"
	label values edulevel1 lbledulevel1


**EDUCATION LEVEL 2
	gen byte edulevel2=edulevel1
	recode edulevel2 4=3 5=4 6 7=5 8=.
	replace edulevel2=. if age<ed_mod_age & age!=.
	label var edulevel2 "Level of education 2"
	la de lbledulevel2 1 "No education" 2 "Primary incomplete"  3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
	label values edulevel2 lbledulevel2


** EDUCATION LEVEL 3
	gen byte edulevel3=edulevel1
	recode edulevel3 3 4=2 5=3 6 7=4 8=.
	replace edulevel3=. if age<ed_mod_age & age!=.
	label var edulevel3 "Level of education 3"
	la de lbledulevel3 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values edulevel3 lbledulevel3


** EVER ATTENDED SCHOOL

/*
For those who are currently attending educational institution or variable "atschool" equals 1,
and have no education (no schooling) or "edulevel1" equals "edulevel2" equals "edulevel3" equals 1,
they are probably in creche or day care. Note that "Educational institution" covers a wide range of places
and ways of education.
*/

	gen byte everattend=Education_Status
	recode everattend 1=0 2/7=1
	replace everattend=1 if atschool==1
	replace everattend=. if age<ed_mod_age & age!=.
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
	replace edulevel1=1 if everattend==0
	replace edulevel2=1 if everattend==0
	replace edulevel3=1 if everattend==0


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen byte lb_mod_age=15
	label var lb_mod_age "Labor module application age"


** LABOR STATUS
	gen byte lstatus=Status
	recode lstatus 4=3
	replace lstatus=. if age<lb_mod_age & age!=.
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-in-labor force"
	label values lstatus lbllstatus


** LABOR STATUS LAST YEAR
	gen byte lstatus_year=.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 0 "Not employed"
	label values lstatus_year lbllstatus_year


** EMPLOYMENT STATUS
	gen byte empstat=Q45WRK4WHOM
	recode empstat 4=2 2=3 3=4
	replace empstat=. if lstatus!=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat lblempstat


** EMPLOYMENT STATUS LAST YEAR
	gen byte empstat_year=.
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year


** NUMBER OF TOTAL JOBS

/*
We do not know the number of total jobs a person has from the question
"In the last week did you have more than one job/business?". Hence observations
whose answers to this question are "Yes" were coded as missing values.
*/

	gen byte njobs=Q41MULTIPLEJOBS
	recode njobs 2=1
	recode njobs 1=.
	replace njobs=. if lstatus!=1
	label var njobs "Number of total jobs"


** NUMBER OF TOTAL JOBS LAST YEAR
	gen byte njobs_year=.
	replace njobs_year=. if lstatus_year!=1
	label var njobs_year "Number of total jobs during last year"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen byte ocusec=Q415TYPEBUSNS
	recode ocusec 4=1 3 5=2 2=3 6=.
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public Sector, Central Government, Army, NGO" 2 "Private" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec


** REASONS NOT IN THE LABOR FORCE
	gen byte nlfreason=Q35YNOTWRK
	recode nlfreason 4=3 8=4 3 5/7 9=5
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l=Q36TIMESEEK
	recode unempldur_l 1=0 2=3 3=6 4=9 5=12 6=36 7=61 8=.
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen byte unempldur_u=Q36TIMESEEK
	recode unempldur_u 1=2 2=5 3=8 4=11 5=35 6=60 7 8=.
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	gen byte industry=indus
	recode industry 9 11=10
	replace industry=9 if inrange(Q43INDUSTRY,911,917)
	replace industry=. if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry


** INDUSTRY 1
	gen byte industry1=industry
	recode industry1 2/5=2 6/9=3 10=4
	replace industry1=. if lstatus!=1
	label var industry1 "1 digit industry classification (Broad Economic Activities)"
	la de lblindustry1 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1 lblindustry1


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION
	gen industry_orig=Q43INDUSTRY
	replace industry_orig=. if lstatus!=1
	label var industry_orig "Original Industry Codes"


** OCCUPATION CLASSIFICATION
	recode occup 10=9 11=99
	replace occup=. if Q42OCCUPATION==9999
	replace occup=10 if Q42OCCUPATION==5164
	replace occup=. if lstatus!=1
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup


** SURVEY SPECIFIC OCCUPATION CLASSIFICATION
	gen occup_orig=Q42OCCUPATION
	replace occup_orig=. if lstatus!=1
	label var occup_orig "Original Occupational Codes"


** FIRM SIZE
	gen byte firmsize_l=Q416NRWORKERS
	recode firmsize_l 1=0 2=1 3=2 4=5 5=10 6=20 7=50 8 99=.
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket)"

	gen byte firmsize_u=Q416NRWORKERS
	recode firmsize_u 1=0 2=1 3=4 4=9 5=19 6=49 7 8 99=.
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
/*
Variable "Q418HRSWRK" is working hours for people who only have one job and it is missing for people who have more than one job.

Variable "Hrswrk" is equal to "Q418HRSWRK" for people who have one job and it is equal to variable "Q420TOTALHRSWRK" for thoes who have more than one job.

	egen primary=rowmax(Q420FIRSTHRSWRK Q420SECONDHRSWRK)
	replace primary=Q418HRSWRK if primary==. & Q418HRSWRK!=.
	gen first=1 if (primary==Q420FIRSTHRSWRK & primary !=.) | (primary==Q418HRSWRK & primary !=.)
	replace first=0 if primary!=. & primary==Q420SECONDHRSWRK

The main job was decided based on time spent.
0.13% of people who have jobs spend more time on their second job.

      first |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |         99        0.13        0.13
          1 |     73,390       99.87      100.00
------------+-----------------------------------
      Total |     73,489      100.00
*/

	gen whours=Q418HRSWRK
	egen primary=rowmax(Q420FIRSTHRSWRK Q420SECONDHRSWRK)
	replace whours=primary if Q418HRSWRK==.
	replace whours=. if lstatus!=1
	label var whours "Hours of work in last week"


** WAGES
	gen double wage=Q54a_monthly
	replace wage=Q57a_monthly if wage==.
	replace wage=. if lstatus!=1
	replace wage=0 if empstat==2
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen byte unitwage=5
	replace unitwage=. if lstatus!=1
	replace unitwage=. if empstat==2
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage


** EMPLOYMENT STATUS - SECOND JOB
	gen byte empstat_2=.
	replace empstat_2=. if njobs==0 | njobs==.
	label var empstat_2 "Employment status - second job"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2


** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
	gen byte empstat_2_year=.
	replace empstat_2_year=. if njobs_year==0 | njobs_year==.
	label var empstat_2_year "Employment status - second job"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2_year lblempstat_2_year


** INDUSTRY CLASSIFICATION - SECOND JOB
	gen byte industry_2=.
	replace industry_2=. if njobs==0 | njobs==.
	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2 lblindustry_2


** INDUSTRY 1 - SECOND JOB
	gen byte industry1_2=.
	replace industry1_2=. if njobs==0 | njobs==.
	label var industry1_2 "1 digit industry classification (Broad Economic Activities) - Second job"
	la de lblindustry1_2 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1_2 lblindustry1_2


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
	gen industry_orig_2=.
	replace industry_orig_2=. if njobs==0 | njobs==.
	label var industry_orig_2 "Original Industry Codes - Second job"


** OCCUPATION CLASSIFICATION - SECOND JOB
	gen byte occup_2=.
	replace occup_2=. if njobs==0 | njobs==.
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2


** WAGES - SECOND JOB
	gen double wage_2=.
	replace wage_2=. if njobs==0 | njobs==.
	label var wage_2 "Last wage payment - Second job"


** WAGES TIME UNIT - SECOND JOB
	gen byte unitwage_2=.
	replace unitwage_2=. if njobs==0 | njobs==.
	label var unitwage_2 "Last wages time unit - Second job"
	la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_2 lblunitwage_2


** CONTRACT
	gen byte contract=Q411CONTRACTTYPE
	recode contract 2=0
	replace contract=. if lstatus!=1
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract


** HEALTH INSURANCE
	gen byte healthins=Q49MEDICAL
	recode healthins 2=0 3=.
	replace healthins=. if lstatus!=1
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins


** SOCIAL SECURITY
	gen byte socialsec=Q46PENSION
	recode socialsec 2=0 3=.
	replace socialsec=. if lstatus!=1
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


** UNION MEMBERSHIP
	gen byte union= Q412BMEMUNION
	recode union 2=0 9 3=.
	replace union=. if lstatus!=1
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
	bys idh: egen hh_income=sum(wage)
	replace pci=hh_income/hhsize
	label var pci "Monthly income per capita"


** DECILES OF PER CAPITA INCOME
	xtile pci_d=pci [w=wgt], nq(10)
	label var pci_d "Income per capita deciles"


** CONSUMPTION PER CAPITA
	gen double pcc=.
	label var pcc "Monthly consumption per capita"

	gen pcc_d=.

** DECILES OF PER CAPITA CONSUMPTION
	*xtile pcc_d=pcc [w=wgt], nq(10)
	label var pcc_d "Consumption per capita deciles"


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL
	keep ccode year intv_year month idh idp wave wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     cellphone computer internet hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage contract      ///
	empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
	     healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d


** ORDER VARIABLES
	order ccode year intv_year month idh idp wave wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     cellphone computer internet hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage contract      ///
	empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
	     healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d

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
	keep ccode year intv_year month idh idp wave wgt strata psu `keep'


	save "`output'\ZAF_2017_QLFS_v01_M_v01_A_I2D2.dta", replace

	log close


















******************************  END OF DO-FILE  *****************************************************/
