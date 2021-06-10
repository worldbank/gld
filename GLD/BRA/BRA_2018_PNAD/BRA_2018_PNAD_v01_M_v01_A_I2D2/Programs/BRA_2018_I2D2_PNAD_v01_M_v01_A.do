/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**         			INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                               **
**                                                                                                  **
** COUNTRY				Brazil
** COUNTRY ISO CODE		BRA
** YEAR					2018
** SURVEY NAME			PEQUISA NACIONAL POR AMOSTRA DE DOMICILIOS
** SURVEY AGENCY		Instituto Brasileiro de Geografia e Estatistica
** SURVEY SOURCE		LAC Database
** UNIT OF ANALYSIS		Household and Individual
** INPUT DATABASES		PNADC
** RESPONSIBLE			Alexandra Quinones (aquinonesnunura@worldbank.org)
** Created				22-05-2021
** Modified 			03-06-2021
** HOUSEHOLDS			151,979
** INDIVIDUALS			452,654
** EXPANDED POPULATION: 209,469,333 (from WB database)
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
	local path "C:\Users\xxxx\OneDrive - WBG\Surveys\BRA\BRA_2018_PNADC\BRA_2018_PNADC_v01_M\Data\Stata"
	
	local save "C:\Users\xxxx\OneDrive - WBG\Surveys\BRA\BRA_2018_PNADC\BRA_2018_PNADC_v01_M_v01_A_I2D2"
	
** LOG FILE
	log using "`save'\Programs\BRA_2018_I2D2_PNAD_v01_M_v01_A.log", replace

/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/

** DATABASE ASSEMBLENT
	use "`path'\BRA_2018_PNADC_v01_M.dta", clear
	
** COUNTRY
	gen str4 ccode="BRA"
	label var ccode "Country code"


** YEAR
	rename Ano Year
	label var Year "Year of survey"

** YEAR OF INTERVIEW
	gen int intv_year=2018
	label var intv_year "Year of the interview"


** MONTH
	gen byte month=.
	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"

** DESTRING VARIABLES

	quietly destring UPA V1008 V2005 V1022 UF S01017 S01009 S01014 S01011C S01022 S01028 V2009 V2007 V2010 V3002 V3001 V3005 VD3005 VD3004 V3008 V4009 V40081 V40082 V40083 V4013 V4010 V4018 V40181 V40182 V40183 V4039 V4043 V4044 V405112 V405122 V4097 V4032 V4025 V4026 V4027, replace force

** HOUSEHOLD IDENTIFICATION NUMBER

	gen double idh=UPA*100+V1008
	tostring idh, gen (idh2) format("%12.0f") 
	drop idh 
	rename idh2 idh 
	destring idh, replace force
	label var idh "Household id"
	
** NUMBER OF PEOPLE PER HOUSEHOLD	
	bys idh: gen inumber=_n

** INDIVIDUAL IDENTIFICATION NUMBER

	gen double idp=idh*100+inumber
	label var idp "Individual id"
	tostring idh, replace format(%15.0g)
	tostring idp, replace format(%17.0g)


** HOUSEHOLD WEIGHTS
	gen double wgt=round(V1032) 
	label var wgt "Household sampling weight"


** STRATA
	gen strata=Estrato
	label var strata "Strata"

** PSU
	gen psu=.
	label var psu "Primary sampling units"
	
** VARIABLE ABOUT HOUSEHOLD RELATIONSHIP
*this variable uses qv2005 data for the relationship to the hhead
	gen relationship=.

	replace relationship=1 if V2005==1
	
	forvalues i=2/3 {
		replace relationship=2 if V2005==`i'
	}
	
	foreach i in 4 5 6 10 11 {
		replace relationship=3 if V2005==`i'
	}
	
	foreach i in 7 8 9 13 {
		replace relationship=4 if V2005==`i'
	}
	
	foreach i in 12 14 17 {
		replace relationship=5 if V2005==`i'
	}
	
	foreach i in 15 16 18 19 {
		replace relationship=6 if V2005==`i'
	} 
	
/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	gen byte urb=V1022
	recode urb 0=2
	label var urb "Urban/Rural"
	la de lblurb 1 "Urban" 2 "Rural"
	label values urb lblurb


/**REGIONAL AREAS 
	gen byte reg01=region_est1
	la de lblreg01 1 "Norte" 2 "Nordeste" 3 "Sudeste" 4 "Sur" 5 "Centro-Oeste"
	label var reg01 "Macro regional areas"
	label values reg01 lblreg01*/


** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen byte reg02=UF
	la de lblreg02 11 "Rondonia" 12 "Acre" 13 "Amazonas" 14 "Roraima" 15 "Para" 16 "Amapa" 17 "Tocantins" 21 "Maranhao" 22 "Piaui" 23 "Ceara" 24 "Rio Grande do Norte" 25 "Paraiba" 26 "Pernambuco" 27 "Alagoas" 28 "Sergipe" 29 "Bahia" 31 "Minas Gerais" 32 "Espirito Santo" 33 "Rio de Janeiro" 35 "Sao Paulo" 41 "Parana" 42 "Santa Catarina" 43 "Rio Grande do Sul" 50 "Mato Grosso do Sul" 51 "Mato Grosso" 52 "Goias" 53 "Distrito Federal" 
	label var reg02 "Region at 1 digit (ADMN1)"
	label values reg02 lblreg02


** REGIONAL AREA 2 DIGITS ADM LEVEL (ADMN2)
	gen reg03=.
	label var reg03 "Region at 2 digits (ADMN2)"


** REGIONAL AREA 3 DIGITS ADM LEVEL (ADMN2)
	gen reg04=.
	label var reg04 "Region at 3 digits (ADMN3)"


 *HOUSE OWNERSHIP
	*property is an intermediate var that uses the data on qS01017
	gen property=.
	
	forvalues i=1/2 {
		replace property=1 if S01017==`i'
	}
	
	forvalues i=3/7 {
		replace property=0 if S01017==`i'
	}
	

	bysort idh : egen byte ownhouse= mean(property)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
	replace ownhouse=. if relationship==6


** WATER PUBLIC CONNECTION 
	recode S01009 .=2
	bysort idh : egen byte water=mean(S01009)
	recode water 2=0
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION
	recode S01014 2=0
	bysort idh: egen byte electricity=mean(S01014)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity


** TOILET PUBLIC CONNECTION 
	recode S01011C 2=0
	bysort idh: egen byte toilet=mean(S01011C)
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet


** LAND PHONE 
	recode S01022 2=0
	bysort idh : egen byte landphone=mean(S01022)
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone


/** CEL PHONE
	No information available
	bysort idh : egen byte cellphone=mean(celular)
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone*/


** COMPUTER 
	recode S01028 2=0
	bysort idh : egen byte computer=mean(S01028)
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer


/** INTERNET
	No information available
	egen byte internet=mean(internet), by(idh)
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet*/


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/

** AGE	
	gen age=V2009 
	replace age = 98 if age >98 & age !=.
	label var age "Individual age"

** GENDER 
	gen byte gender=V2007
	recode gender 2=0
	label var gender "Gender"
	la de lblgender 1 "Male" 0 "Female"
	label values gender lblgender
	

** HOUSEHOLD SIZE
	*In the var relationship 6 represents non-relatives, the hhsize var does not include them
	bys idh: gen hhsize= _N if relationship<6
	label var hhsize "Household size"


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen byte head=relationship
	label var head "Relationship to the head of household"
	la de lblhead  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other non-relatives"
	label values head lblhead
	*recode head 6=5
	*replace head=. if head==5
	*bys idh: egen hh=sum(head==1)
	*bys idh: egen maxage=max(age) if hh==0
	*replace head=1 if age==maxage & hh==0 & gender==1
	*drop hh
*	replace head=6 if ipcf==.
*	drop if hh!=1

** SOCIAL GROUP 
	gen byte soc=V2010
	recode soc 9=.
	label var soc "Social group"
	la de lblsoc 1 "White" 4 "Mestizo" 5 "Indigenous" 2 "Black" 3 "Asian"
	label values soc lblsoc


** MARITAL STATUS
	gen byte marital=.
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE 
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen byte ed_mod_age=5
	label var ed_mod_age "Education module application age"


** CURRENTLY AT SCHOOL
	gen byte atschool=V3002
	recode atschool 2=0
	replace atschool=. if age<ed_mod_age
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen byte literacy=V3001
	recode literacy 2=0
	replace literacy=. if age<ed_mod_age
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen byte educy=VD3005
	replace educy=. if age<ed_mod_age
	label var educy "Years of education"


** EDUCATIONAL LEVEL 1
	gen level=VD3004
	replace level=0 if level==.
	gen byte edulevel1=.
	replace edulevel1=1 if level==0
	replace edulevel1=2 if level==1
	replace edulevel1=3 if level==2
	replace edulevel1=4 if level==3
	replace edulevel1=5 if level==4

/*
not possible to distinguish university from non-university education.
*/
	replace edulevel1=7 if level==5 | level==6 | level==7
	replace edulevel1=. if age<ed_mod_age
	label var edulevel1 "Level of education 1"
	la de lbledulevel1 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete"  8 "Other" 9 "Unstated"
	label values edulevel1 lbledulevel1

** EDUCATION LEVEL 2
	gen byte edulevel2=edulevel1
	recode edulevel2 4=3 5=4 6 7=5 8 9=.
	replace edulevel2=. if age<ed_mod_age & age!=.
	label var edulevel2 "Level of education 2"
	la de lbledulevel2 1 "No education" 2 "Primary incomplete"  3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
	label values edulevel2 lbledulevel2
	
** EDUCATION LEVEL 3
	gen byte edulevel3=edulevel1
	recode edulevel3 3=2 4 5=3 6 7=4 8 9=.
	label var edulevel3 "Level of education 3"
	la de lbledulevel3 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values edulevel3 lbledulevel3

** EVER ATTENDED SCHOOL
	gen byte everattend=V3008
	recode everattend 2=0
	replace everattend=1 if atschool==1
	replace everattend=. if age<ed_mod_age
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
	replace educy=0 if everattend==0
	replace edulevel1=1 if everattend==0
	replace edulevel2=1 if everattend==0


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen byte lb_mod_age=14
	label var lb_mod_age "Labor module application age"
	tab VD4002, generate(oc)
	rename oc1 ocupado
	rename oc2 desocupado
	
	gen pea=VD4001
	destring pea, replace force
	recode pea 2=0 

** LABOR STATUS
	gen byte lstatus=.
	replace lstatus=1 if ocupado==1
	replace lstatus=2 if desocupado==1
	replace lstatus=3 if pea==0
	replace lstatus=. if age<lb_mod_age
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** LABOR STATUS LAST YEAR
	gen byte lstatus_year=.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 0 "Not employed"
	label values lstatus_year lbllstatus_year


** EMPLOYMENT STATUS

	gen relab=VD4007
	destring relab, replace force
	
	gen byte empstat=.
	replace empstat=1 if relab==2
	replace empstat=2 if relab==4
	replace empstat=3 if relab==1
	replace empstat=4 if relab==3
	replace empstat = . if lstatus !=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 4 "Non-paid employee" 2 "Employer" 3 "Self-employed"
	label values empstat lblempstat


** EMPLOYMENT STATUS LAST YEAR
	gen byte empstat_year=.
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year


** NUMBER OF ADDITIONAL JOBS
	gen byte njobs=V4009-1 if lstatus ==1
	recode njobs 1=0
	label var njobs "Number of additional jobs"
	la de njobs 2 "2 or more"
	label values njobs lblnjobs


** NUMBER OF ADDITIONAL JOBS LAST YEAR
	gen byte njobs_year=.
	replace njobs_year=. if lstatus_year!=1
	label var njobs_year "Number of additional jobs during last year"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen byte ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public Sector, Central Government, Army, NGO" 2 "Private" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec


** REASONS NOT IN THE LABOR FORCe
	gen byte nlfreason=.
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte durades2=V40082
	gen byte durades1=V40081
	gen byte durades3=V40083
	
	recode durades2 1=13 2=14 3=15 5=17 6=18 8=20 11=23 0=12
	recode durades3 2=24 3=36 4=48 5=60 7=84 8=96 9=108 10=120 12=144 15=180 17=204 20=240 22=264 25=300 30=360 32=384 6=72
	
	egen durades = rowmax(durades1 durades2 durades3)

	gen byte unempldur_l=durades if lstatus ==2
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen byte unempldur_u=durades if lstatus ==2 
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	gen byte industry=floor(V4013/1000)
	recode industry 1/4=1 5/9=2 10/33=3 35/39=4 41/43=5 45 48 55 56=6 49/53 58/63=7 64/82=8 84=9 85/99 0=10 
	replace industry =. if lstatus !=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry


** INDUSTRY 1
	gen byte industry1=industry
	recode industry1  3/5=2 6/9=3 10=4
	replace industry1=. if lstatus!=1
	label var industry1 "1 digit industry classification (Broad Economic Activities)"
	la de lblindustry1 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1 lblindustry1


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION

	local my_industry_orig "V4013"                                                                             
	clonevar industry_orig=`my_industry_orig'                                                                 
	capture confirm numeric format industry_orig                                                              
	if _rc {                                                                                                  
	       noi di "`my_industry_orig' is an string variable"                                                  
	       destring industry_orig, replace                                                                    
	       local industrystring "-was string"                                                                 
	}                                                                                                         
	local industrytemp : variable label `my_industry_orig'                                                    
	label var industry_orig `"Original Industry Code (`my_industry_orig'`industrystring':`industrytemp')"'    

	gen aux=floor(V4010/1000)

** OCCUPATION CLASSIFICATION
	gen byte occup=aux
	recode occup 0=10
	replace occup=99 if V4010==0
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup


** SURVEY SPECIFIC OCCUPATION CLASSIFICATION
	local my_occup_orig "V4010"                                                                   
	clonevar occup_orig=`my_occup_orig'                                                           
	capture confirm numeric format occup_orig                                                     
	if _rc {                                                                                      
	       noi di "`my_occup_orig' is an string variable"                                         
	       destring occup_orig, replace                                                           
	       local occupstring "-was string"                                                        
	}                                                                                             
	local occuptemp : variable label `my_occup_orig'                                              
	label var occup_orig `"Original Occupation Code (`my_occup_orig'`occupstring':`occuptemp')"'  


** FIRM SIZE

/*
ONLY PRIVATE SECTOR EMPLOYEES
*/
	gen byte firmsize_l=.
	replace firmsize_l=V40181
	replace firmsize_l=V40182 if firmsize_l==.
	replace firmsize_l=V40183 if firmsize_l==.
	replace firmsize_l=51 if V4018==4
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket)"

	gen byte firmsize_u=.

/*
ONLY PRIVATE SECTOR EMPLOYEES
*/
	replace firmsize_u=V40181
	replace firmsize_u=V40182 if firmsize_u==.
	replace firmsize_u=V40183 if firmsize_u==.
	replace firmsize_u=. if V4018==4
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen byte hstrp=V4039
	gen whours=hstrp
	label var whours "Hours of work in last week"

** ANNUAL SALARY

	gen wage = (V403312*12)/(hstrp*52)

** WAGES
	rename wage wage2
	gen double wage=wage2
	replace wage=0 if empstat==2
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen byte unitwage=.
	replace unitwage = 9 if lstatus ==1
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage


** EMPLOYMENT STATUS - SECOND JOB
	gen byte empstat_2=V4043
	recode empstat_2 3 4=1 7=2 5=3 6=4 2=5
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
	gen byte industry_2=floor(V4044/1000)
	recode industry_2 1/4=1 5/9=2 10/33=3 35/39=4 41/43=5 45 48 55 56=6 49/53 58/63=7 64/82=8 84=9 85/99 0=10 
	replace industry_2=. if njobs==0 | njobs==. | industry_2>30
	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2 lblindustry_2


** INDUSTRY 1 - SECOND JOB
	gen byte industry1_2=industry_2
	recode industry1_2  3/5=2 6/9=3 10=4
	replace industry1_2=. if njobs==0 | njobs==.
	label var industry1_2 "1 digit industry classification (Broad Economic Activities) - Second job"
	la de lblindustry1_2 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1_2 lblindustry1_2


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
	local my_industry_orig_2 "V4044"                                                                             
	clonevar industry_orig_2=`my_industry_orig_2'                                                                 
	capture confirm numeric format industry_orig_2
	if _rc {                                                                                                  
	       noi di "`my_industry_orig_2' is an string variable"
	       destring industry_orig_2, replace
	       local industrystring2 "-was string"
	}                                                                                                         
	local industrytemp2 : variable label `my_industry_orig_2'
	label var industry_orig_2 `"Original Industry Code (`my_industry_orig_2'`industrystring2':`industrytemp2') - second job"'

	destring V4041, replace force
	gen aux2=floor(V4041/1000)

** OCCUPATION CLASSIFICATION - SECOND JOB
	gen byte occup_2=aux2
	recode occup_2 0=10
	replace occup_2=. if njobs==0 | njobs==.
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2


** WAGES - SECOND JOB
	gen double wage_2=V405112
	replace wage_2=V405122 if wage_2==.
	replace wage_2=V405112+V405122 if V405112!=. & V405122!=.
	replace wage_2=0 if empstat_2==2
	replace wage_2=. if njobs==0 | njobs==. 
	label var wage_2 "Last wage payment - Second job"


** WAGES TIME UNIT - SECOND JOB
	gen byte unitwage_2=5
	replace unitwage_2=. if njobs==0 | njobs==.
	label var unitwage_2 "Last wages time unit - Second job"
	la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_2 lblunitwage_2


* CONTRACT
	gen byte contract=.
	replace contract=1 if V4025 ==1 | V4026==1 | V4027==1
	replace contract=0 if contract==.
	replace contract=. if age<lb_mod_age
	replace contract=1 if lstatus==1 /* Note that I am assuming that all people employed have a contract or service agreement*/
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract


/** HEALTH INSURANCE
	gen byte healthins=dsegsale
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins*/


** SOCIAL SECURITY
	gen byte socialsec=V4032
	recode socialsec 2=0
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


** UNION MEMBERSHIP
	gen byte union=V4097
	replace union=. if lstatus!=1
	recode union 2=0
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
	gen byte rbirth=.
	label var rbirth "Region of Birth"


** REGION OF PREVIOUS RESIDENCE JURISDICTION
	gen byte rprevious_juris=.
	label var rprevious_juris "Region of previous residence jurisdiction"
	la de lblrprevious_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rprevious_juris lblrprevious_juris


**REGION OF PREVIOUS RESIDENCE
	gen byte rprevious=.
	label var rprevious "Region of previous residence"


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


/** INCOME PER CAPITA
	gen double pci=ipcf
	label var pci "Monthly income per capita"*/


/** DECILES OF PER CAPITA INCOME
	 xtile pci_d=pci [w=wgt], nq(10) 
	label var pci_d "Income per capita deciles"*/


** CONSUMPTION PER CAPITA
	gen double pcc=.
	label var pcc "Monthly consumption per capita"


** DECILES OF PER CAPITA CONSUMPTION
	gen double pcc_d=.
	label var pcc_d "Consumption per capita deciles"


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL (modified)
	keep ccode Year intv_year month idh idp wgt strata psu urb reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	      computer hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage contract      ///
	empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
	     socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pcc pcc_d


** ORDER VARIABLES (modified)
	order ccode Year intv_year month idh idp wgt strata psu urb reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     computer hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage contract      ///
	empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
	     socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pcc pcc_d

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
	keep ccode Year intv_year month  idh idp wgt strata psu `keep'

	*save "`save'/Data/Harmonized/BRA_2018_I2D2_PNAD_v01_M_v01_A.dta", replace
	save "`save'\Data\Harmonized\BRA_2018_I2D2_PNAD_v01_M_v01_A.dta", replace

	log close


******************************  END OF DO-FILE  *****************************************************/
