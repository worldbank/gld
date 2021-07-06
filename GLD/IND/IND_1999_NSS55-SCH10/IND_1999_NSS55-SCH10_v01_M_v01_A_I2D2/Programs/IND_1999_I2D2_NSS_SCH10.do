/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	India
** COUNTRY ISO CODE	IND
** YEAR	2000
** SURVEY NAME	SOCIO-ECONOMIC SURVEY  FIFTY-FIFTH ROUND JULY 1999-JUNE 2000
*	HOUSEHOLD SCHEDULE 10.1 : EMPLOYMENT AND UNEMPLOYMENT
** SURVEY AGENCY	GOVERNMENT OF INDIA NATIONAL SAMPLE SURVEY ORGANISATION
** SURVEY SOURCE	
** UNIT OF ANALYSIS	
** INPUT DATABASES	C:\_I2D2\India\2000\Original\Data\DataOrig.dta
** RESPONSIBLE	Diego Calderón
** Created	12/10/2011
** Modified	"05/28/2013"
** NUMBER OF HOUSEHOLDS	119954
** NUMBER OF INDIVIDUALS	591389
** EXPANDED POPULATION	728583343
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
	local path "D:\__I2D2\India\1999\NSS_SCH10"


** LOG FILE
	log using "`path'\Processed\IND_1999_I2D2_NSS_SCH10.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	use "`path'\Original\Data\DataOrig.dta", clear


** COUNTRY
	gen ccode="IND"
	label var ccode "Country code"


** MONTH
	gen byte month=.
	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"


** YEAR
	gen year=1999
	label var year "Year of survey"
	
* YEAR OF INTERVIEW
	gen int intv_year=.
	label var intv_year "Year of the interview"

	tostring hid, gen(idh)

** HOUSEHOLD IDENTIFICATION NUMBER
	label var idh "Household id"


** INDIVIDUAL IDENTIFICATION NUMBER
	egen idp=concat(idh pno), p(-)
	label var idp "Individual id"
	isid idp


** HOUSEHOLD WEIGHTS
	gen wgt=mult
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
	replace urb=1 if rural==2
	replace urb=2 if rural==1
	label var urb "Urban/Rural"
	la de lblurb 1 "Urban" 2 "Rural"
	label values urb lblurb


***REGIONAL AREAS
	gen str2 state_str=substr(staterg, 1, 2)
	destring state_str, gen(state)
	label define state  2 "Andhra Pradesh"  4 "Assam"  5 "Bihar" 7 "Gujarat" 8 "Haryana"  9 "HimachalPradesh" ///
	10 "Jammu & Kashmir" 11"Karnataka" 12 "Kerala" 13 "Madhya Pradesh" 14  "Maharashtra" ///  
	15 "Manipur"   16 "Meghalaya"  18 "Nagaland"  19 "Orissa"  20 "Punjab" 21 "Rajasthan" 22 "Sikkim" ///
	23 "Tamil Nadu"  24 "Tripura"  25 "Uttar Pradesh"  26 "West Bengal" 27 "A & N Islands" ///
	3 "Arunachal Pradesh"  28 "Chandigarh" 29 "Dadra & Nagar Haveli" 31 "Delhi"  6 "Goa" ///
	32"Lakshdweep" 17 "Mizoram"  33 "Pondicherry"  30 "Daman & Diu"
	gen reg01=.
	label var reg01 "Macro regional areas"
	label values reg01 state


*** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen reg02=state
	label values reg02 state
	label var reg02 "Region at 1 digit(ADMN1)"


** REGIONAL AREA 2 DIGITS ADM LEVEL (ADMN2)
	gen reg03=.
	label var reg03 "Region at 2 digits (ADMN2)"


** REGIONAL AREA 3 DIGITS ADM LEVEL (ADMN2)
	gen reg04=.
	label var reg04 "Region at 3 digits (ADMN3)"


** HOUSE OWNERSHIP
	gen ownhouse=.
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"


** WATER PUBLIC CONNECTION
	label values ownhouse lblownhouse
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


**HOUSEHOLD SIZE

	bys idh: egen hhsize= count(B4_C3) if B4_C3>=1 & B4_C3<=8
	label var hhsize "Household size"


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	bys idh: gen one=1 if B4_C3==1 
	bys idh: egen temp=count(one) 
	keep if temp==1
	gen head=B4_C3
	recode head (3 5=3)(7=4) (4 6 8=5)(9=6) (0=.)
	label var head "Relationship to the head of household"
	la de lblhead  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values head  lblhead
	drop if head==.


** GENDER
	gen gender= B4_C4
	label var gender "Gender"
	la de lblgender 1 "Male" 2 "Female"
	label values gender lblgender


** AGE
	gen age= B4_C5
	replace age=98 if age>=98 & age!=.
	label var age "Individual age"


** SOCIAL GROUP

/*
The caste variable exist too, named " B3_C2"
*/
	gen soc=B3_C3
*  B3_C2
	label var soc "Social group"
	recode soc (0=.)
	label define soc 1 "Hinduism" 2 "Islam" 3 "Sikhism" 4 "Jainism" 5"Buddhism" 6"Zoroastrianism" 7"Others"  9"Others'
	label values soc soc


** MARITAL STATUS
	gen marital=.
	replace marital=1 if B4_C6==2
	replace marital=2 if B4_C6==1
	replace marital=4 if B4_C6==4
	replace marital=5 if B4_C6==3
	replace marital=. if B4_C6==0
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
	gen atschool=1  if B4_C9>=21 & B4_C9!=.
	replace atschool=0 if B4_C9<21 | B4_C9==.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen literacy=1 
	replace literacy=0 if B4_C7==1
	replace literacy=. if B4_C7==0 | B4_C7==.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen educy=.
	/* no education */
	replace educy=0 if B4_C7==01 | B4_C7==02 | B4_C7==03 | B4_C7==04 
	/* below primary */
	replace educy=1 if B4_C7==05
	/* primary */
	replace educy=5 if B4_C7==06
	/* middle */
	replace educy=8 if B4_C7==07
	/* secondary */
	replace educy=10 if B4_C7==8
	/* higher secondary */
	replace educy=12 if B4_C7==9
	/* graduate and above in agriculture, engineering/technology, medicine */
	replace educy=16 if B4_C7==10 | B4_C7==11 | B4_C7==12
	/* graduate and above in other subjects */
	replace educy=15 if B4_C7==13
	gen ageminus4=age-4
	replace educy=ageminus4 if (educy>ageminus4)& (educy>0) & (ageminus4>0) & (educy!=.)
	replace educy=0 if (educy>ageminus4) & (educy>0) &(ageminus4<=0) & (educy!=.)
	label var educy "Years of education"


** EDUCATIONAL LEVEL 1
	gen edulevel1=.
	replace edulevel1=1 if B4_C7==1
	replace edulevel1=2 if B4_C7==5
	replace edulevel1=3 if B4_C7==6
	replace edulevel1=4 if B4_C7==7|B4_C7==8
	replace edulevel1=5 if B4_C7==9
	replace edulevel1=7 if B4_C7>=10 & B4_C7!=.
	replace edulevel1=8 if B4_C7==2 |B4_C7==3|B4_C7==4
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
	gen lb_mod_age=0
	label var lb_mod_age "Labor module application age"

	gen lstatus=.

* LABOR STATUS
	gen lstatus=B51_C3
	recode lstatus 11/51=1 81=2 91/97=3 99=.
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
	
* LABOR STATUS LAST YEAR
	gen byte lstatus_year=.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Not employed" 
	label values lstatus_year lbllstatus_year
	
* EMPLOYMENT STATUS	
	gen empstat=B51_C3
	recode empstat 81/97 99=. 11=4 12=3 21=2 31/51=1
	replace empstat=. if lstatus!=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat
	
* EMPLOYMENT STATUS LAST YEAR
	gen byte empstat_year=.
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
	
* NUMBER OF ADDITIONAL JOBS
	gen njobs=B51_C8
	label var njobs "Number of additional jobs"
	
* NUMBER OF ADDITIONAL JOBS LAST YEAR
	gen byte njobs_year=.
	replace njobs_year=. if lstatus_year!=1
	label var njobs_year "Number of additional jobs during last year"
	
* SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen ocusec=.
	replace ocusec=1 if B51_C10==5
	replace ocusec=2 if  B51_C10==1| B51_C10==2| B51_C10==3| B51_C10==4
	replace ocusec=3 if B51_C10==6
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public Sector, Central Government, Army, NGO" 2 "Private" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1



** REASONS NOT IN THE LABOR FORCE
	gen nlfreason=.
	replace nlfreason=1 if B53_C20==91
	replace nlfreason=2 if B53_C20==92|B53_C20==93
	replace nlfreason=3 if B53_C20==94
	replace nlfreason=4 if B53_C20==95
	replace nlfreason=5 if B53_C20==96 |B53_C20==97|B53_C20==98
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen unempldur_l=.
	replace unempldur_l=0 if B6_C4<=3
	replace unempldur_l=1 if B6_C4==4
	replace unempldur_l=2 if B6_C4==5
	replace unempldur_l=3 if B6_C4==6
	replace unempldur_l=6 if B6_C4==7
	replace unempldur_l=12 if B6_C4==8
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen unempldur_u=.
	replace unempldur_u=1 if B6_C4<=3
	replace unempldur_u=2 if B6_C4==4
	replace unempldur_u=3 if B6_C4==5
	replace unempldur_u=6 if B6_C4==6
	replace unempldur_u=12 if B6_C4==7
	replace unempldur_u=. if B6_C4==8
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	gen industry=.
	destring B51_C5, replace
	replace industry=1 if B51_C5>=1110 & B51_C5<=5009
	replace industry=2 if B51_C5>=10100 & B51_C5<=14299
	replace industry=3 if B51_C5>=15110 & B51_C5<=37209
	replace industry=4 if B51_C5>=40100 & B51_C5<=41009
	replace industry=5 if B51_C5>=45100 & B51_C5<=45509
	replace industry=6 if B51_C5>=50100 & B51_C5<=55209
	replace industry=7 if B51_C5>=60100 & B51_C5<=64209
	replace industry=8 if B51_C5>=65190 & B51_C5<=74999
	replace industry=9 if B51_C5>=75110 & B51_C5<=85329
	replace industry=10 if B51_C5>=90000 & B51_C5<=99989
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transports and comnunications" 8 "Financial and business-oriented services" 9 "Community and family oriented services" 10 "Others"
	label values industry lblindustry
	replace industry=. if lstatus!=1


** INDUSTRY 1
	gen byte industry1=industry
	recode industry1 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry1=. if lstatus!=1
	label var industry1 "1 digit industry classification (Broad Economic Activities)"
	la de lblindustry1 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1 lblindustry1

*SURVEY SPECIFIC INDUSTRY CLASSIFICATION
	gen industry_orig=B51_C5
	replace industry_orig=. if lstatus!=1
	label var industry_orig "Original Industry Codes"

** OCCUPATION CLASSIFICATION

	gen str3 princocc_NCO =  B51_C6	
	gen princocc_CODE2=substr(princocc_NCO,1,2) 
	gen princocc_CODE3= princocc_NCO
	drop princocc_NCO
	gen occup=.

	*professional

	replace occup=2 if princocc_CODE3=="000" | princocc_CODE3=="001" | princocc_CODE3=="002" | princocc_CODE3=="003"
	replace occup=2 if princocc_CODE3=="004" | princocc_CODE3=="006" | princocc_CODE3=="008"
	replace occup=2 if princocc_CODE3=="020" | princocc_CODE3=="021" | princocc_CODE3=="022" | princocc_CODE3=="023"
	replace occup=2 if princocc_CODE3=="024" | princocc_CODE3=="025" | princocc_CODE3=="026" | princocc_CODE3=="027"
	replace occup=2 if princocc_CODE3=="050" | princocc_CODE3=="051" | princocc_CODE3=="052" | princocc_CODE3=="053"
	replace occup=2 if princocc_CODE3=="054" | princocc_CODE3=="057" 
	replace occup=2 if princocc_CODE3=="070" | princocc_CODE3=="071" | princocc_CODE3=="072" | princocc_CODE3=="073"
	replace occup=2 if princocc_CODE3=="074" | princocc_CODE3=="075" | princocc_CODE3=="076" | princocc_CODE3=="084"
	replace occup=2 if princocc_CODE3=="085"  | princocc_CODE3=="147"
	replace occup=2 if princocc_CODE3=="140" | princocc_CODE3=="141" | princocc_CODE3=="149" | princocc_CODE3=="180"
	replace occup=2 if princocc_CODE3=="181" | princocc_CODE3=="182" | princocc_CODE3=="183" | princocc_CODE3=="185"
	replace occup=2 if princocc_CODE3=="186" | princocc_CODE3=="187" | princocc_CODE3=="188" | princocc_CODE3=="189"
	replace occup=2 if princocc_CODE2=="10" | princocc_CODE2=="11" | princocc_CODE2=="12" | princocc_CODE2=="13"
	replace occup=2 if princocc_CODE2=="15" | princocc_CODE2=="16" | princocc_CODE2=="17" | princocc_CODE2=="19"

	*technician and associate pro

	replace occup=3 if princocc_CODE3=="009" | princocc_CODE3=="010" | princocc_CODE3=="019" | princocc_CODE3=="028"
	replace occup=3 if princocc_CODE3=="011" | princocc_CODE3=="012" | princocc_CODE3=="014" | princocc_CODE3=="015"
	replace occup=3 if princocc_CODE3=="017" | princocc_CODE3=="018" 
	replace occup=3 if princocc_CODE3=="029" | princocc_CODE3=="059" | princocc_CODE3=="077" | princocc_CODE3=="078"
	replace occup=3 if princocc_CODE3=="079" | princocc_CODE3=="080" | princocc_CODE3=="081" | princocc_CODE3=="082"
	replace occup=3 if princocc_CODE3=="083" | princocc_CODE3=="086" | princocc_CODE3=="087" | princocc_CODE3=="088"
	replace occup=3 if princocc_CODE3=="089" | princocc_CODE3=="142" | princocc_CODE3=="184" 

	replace occup=3 if princocc_CODE2=="03" | princocc_CODE2=="04" | princocc_CODE2=="06" | princocc_CODE2=="09"

	*legislators, senior officials and managers

	replace occup=1 if princocc_CODE2=="20" | princocc_CODE2=="21" | princocc_CODE2=="22" | princocc_CODE2=="23"
	replace occup=1 if princocc_CODE2=="24" | princocc_CODE2=="25" | princocc_CODE2=="26" | princocc_CODE2=="29" | princocc_CODE2=="27" | princocc_CODE2=="28"

	replace occup=1 if princocc_CODE2=="30" | princocc_CODE2=="31" | princocc_CODE2=="36"  | princocc_CODE2=="60" 

	*clerks

	replace occup=4 if princocc_CODE2=="32" | princocc_CODE2=="33" | princocc_CODE2=="34" | princocc_CODE2=="35"

	replace occup=4 if princocc_CODE2=="37" | princocc_CODE2=="38" | princocc_CODE2=="39" 

	replace occup=4 if princocc_CODE3=="302" 

	*Service workers and shop and market sales

	replace occup=5 if princocc_CODE2=="40" | princocc_CODE2=="41" | princocc_CODE2=="42" | princocc_CODE2=="43"
	replace occup=5 if princocc_CODE2=="44" | princocc_CODE2=="45" | princocc_CODE2=="49" | princocc_CODE2=="50"
	replace occup=5 if princocc_CODE2=="46" | princocc_CODE2=="47" | princocc_CODE2=="48" 
	replace occup=5 if princocc_CODE2=="51" | princocc_CODE2=="52" | princocc_CODE2=="53" | princocc_CODE2=="54"
	replace occup=5 if princocc_CODE2=="55" | princocc_CODE2=="56" | princocc_CODE2=="57" | princocc_CODE2=="58" | princocc_CODE2=="59"

	*skilled agricultural and fishery workers

	replace occup=6 if princocc_CODE2=="61" | princocc_CODE2=="62" | princocc_CODE2=="63" | princocc_CODE2=="64"
	replace occup=6 if princocc_CODE2=="65" | princocc_CODE2=="66" | princocc_CODE2=="67" | princocc_CODE2=="68" | princocc_CODE2=="69"

	*Craft and related trades

	replace occup=7 if princocc_CODE2=="71" | princocc_CODE2=="72" | princocc_CODE2=="73" | princocc_CODE2=="75" | princocc_CODE2=="70"
	replace occup=7 if princocc_CODE2=="76" | princocc_CODE2=="77" | princocc_CODE2=="78" | princocc_CODE2=="79"
	replace occup=7 if princocc_CODE2=="80" | princocc_CODE2=="81" | princocc_CODE2=="82" | princocc_CODE2=="92"
	replace occup=7 if princocc_CODE2=="93" | princocc_CODE2=="94" | princocc_CODE2=="95" 

	*Plant and machine operators and assemblers

	replace occup=8 if princocc_CODE2=="74" | princocc_CODE2=="83" | princocc_CODE2=="84" | princocc_CODE2=="85"
	replace occup=8 if princocc_CODE2=="86" | princocc_CODE2=="87" | princocc_CODE2=="88" | princocc_CODE2=="89"
	replace occup=8 if princocc_CODE2=="90" | princocc_CODE2=="91" | princocc_CODE2=="96" | princocc_CODE2=="97"
	replace occup=8 if princocc_CODE2=="98" 
	replace occup=8 if princocc_CODE3=="813" 

	*elementary occupations

	replace occup=9 if princocc_CODE2=="99" 

	*other/unspecified

	replace occup=99 if princocc_CODE2=="X0" | princocc_CODE2=="X1" | princocc_CODE2=="X9" 


	*legislators, senior officials and managers CONTT.

	replace occup=1 if princocc_CODE3=="710" | princocc_CODE3=="720" | princocc_CODE3=="730" | princocc_CODE3=="740"
	replace occup=1 if princocc_CODE3=="750" | princocc_CODE3=="760" | princocc_CODE3=="770" | princocc_CODE3=="780"  
	replace occup=1 if princocc_CODE3=="790" | princocc_CODE3=="800" | princocc_CODE3=="810" | princocc_CODE3=="820" 
	replace occup=1 if princocc_CODE3=="830" | princocc_CODE3=="840" | princocc_CODE3=="850" | princocc_CODE3=="860"  
	replace occup=1 if princocc_CODE3=="870" | princocc_CODE3=="880" | princocc_CODE3=="890" | princocc_CODE3=="900" 
	replace occup=1 if princocc_CODE3=="910" | princocc_CODE3=="920" | princocc_CODE3=="930" | princocc_CODE3=="940"  
	replace occup=1 if princocc_CODE3=="950" | princocc_CODE3=="960" | princocc_CODE3=="970" | princocc_CODE3=="980"

	drop  princocc_CODE2 princocc_CODE3

	label var occup "1 digit occupational classification"
	label define occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" ///
	5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" ///
	8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup
	replace occup=. if lstatus!=1
	drop princind_CODE princind_ISIC

	destring B51_C6, replace
* SURVEY SPECIFIC OCCUPATION CLASSIFICATION
	gen  occup_orig=B51_C6
	replace occup_orig=. if lstatus!=1
	label var occup_orig "Original Occupational Codes"

** FIRM SIZE
	gen firmsize_l=.
	replace  firmsize_l=1 if B51_C12==1
	replace  firmsize_l=6 if B51_C12==2
	replace  firmsize_l=10 if B51_C12==3
	replace  firmsize_l=20 if B51_C12==4
	replace  firmsize_l=. if B51_C12==9
	replace  firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket)"

	gen firmsize_u=.
	replace  firmsize_u=6 if B51_C12==1
	replace  firmsize_u=9 if B51_C12==2
	replace  firmsize_u=19 if B51_C12==3
	replace  firmsize_u=. if B51_C12==4|B51_C12==9
	replace  firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK

	gen HOURWRKMAIN_mon=.

	#delimit;
	gen mainhrs=.;
	forval i = 1/4 { ;
	replace mainhrs = B53_C14_`i' if B53_C20 == B53_C4_`i' & mi(mainhrs) & 
	inlist(B53_C4_`i', 11, 12, 21, 31, 41, 51);
	};
	#delimit cr
	replace mainhrs=. if lstatus!=1
	replace mainhrs=0 if lstatus==1 & mi(mainhrs)
	replace HOURWRKMAIN_mon=8*mainhrs*52/12
	drop mainhrs
	gen HOURWRKMAIN_week=HOURWRKMAIN_mon*12/52
	ren HOURWRKMAIN_week whours
	label var whours "Hours of work in last week"


** WAGES
	gen wage=B53_C15_1
	replace wage=. if lstatus!=1
	replace wage=0 if empstat==2
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen unitwage=.
	replace unitwage=1 if B53_C18_1==1|B53_C18_1==18
	replace unitwage=2 if B53_C18_1==2|B53_C18_1==22
	replace unitwage=3 if B53_C18_1==3|B53_C18_1==28
	replace unitwage=5 if B53_C18_1==9|B53_C18_1==29
	replace unitwage=. if lstatus!=1 |empstat!=1
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 
	label values unitwage lblunitwage

* EMPLOYMENT STATUS - SECOND JOB
	gen byte empstat_2=B52_C3_1
	recode empstat_2 11=4 12=3 21=2 31 41 51=1
	replace empstat_2=. if njobs==0 | njobs==.
	label var empstat_2 "Employment status - second job"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
	
* EMPLOYMENT STATUS - SECOND JOB LAST YEAR
	gen byte empstat_2_year=.
	replace empstat_2_year=. if njobs_year==0 | njobs_year==.
	label var empstat_2_year "Employment status - second job"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
	
* INDUSTRY CLASSIFICATION - SECOND JOB
	gen industry_2=.
	destring B52_C5_1, replace
	replace industry_2=1 if B52_C5_1>=1110 & B52_C5_1<=5009
	replace industry_2=2 if B52_C5_1>=10100 & B52_C5_1<=14299
	replace industry_2=3 if B52_C5_1>=15110 & B52_C5_1<=37209
	replace industry_2=4 if B52_C5_1>=40100 & B52_C5_1<=41009
	replace industry_2=5 if B52_C5_1>=45100 & B52_C5_1<=45509
	replace industry_2=6 if B52_C5_1>=50100 & B52_C5_1<=55209
	replace industry_2=7 if B52_C5_1>=60100 & B52_C5_1<=64209
	replace industry_2=8 if B52_C5_1>=65190 & B52_C5_1<=74999
	replace industry_2=9 if B52_C5_1>=75110 & B52_C5_1<=85329
	replace industry_2=10 if B52_C5_1>=90000 & B52_C5_1<=99989
	replace industry_2=. if njobs==0 | njobs==.
	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2  lblindustry_2
	
* INDUSTRY 1 - SECOND JOB
	gen byte industry1_2=industry_2
	recode industry1_2 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry1_2=. if njobs==0 | njobs==.
	label var industry1_2 "1 digit industry classification (Broad Economic Activities) - Second job"
	la de lblindustry1_2 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1_2 lblindustry1_2
	
*SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
	gen industry_orig_2=B52_C5_1
	replace industry_orig_2=. if njobs==0 | njobs==.
	label var industry_orig_2 "Original Industry Codes - Second job"
	la de lblindustry_orig_2 1""
	label values industry_orig_2 lblindustry_orig_2
	
* OCCUPATION CLASSIFICATION - SECOND JOB
	gen str3 princocc_NCO = B52_C6_1
	gen princocc_CODE2=substr(princocc_NCO,1,2) 
	gen princocc_CODE3= princocc_NCO
	drop princocc_NCO
	gen occup_2=.
	
	*professional
	
	replace occup_2=2 if princocc_CODE3=="000" | princocc_CODE3=="001" | princocc_CODE3=="002" | princocc_CODE3=="003"
	replace occup_2=2 if princocc_CODE3=="004" | princocc_CODE3=="006" | princocc_CODE3=="008"
	replace occup_2=2 if princocc_CODE3=="020" | princocc_CODE3=="021" | princocc_CODE3=="022" | princocc_CODE3=="023"
	replace occup_2=2 if princocc_CODE3=="024" | princocc_CODE3=="025" | princocc_CODE3=="026" | princocc_CODE3=="027"
	replace occup_2=2 if princocc_CODE3=="050" | princocc_CODE3=="051" | princocc_CODE3=="052" | princocc_CODE3=="053"
	replace occup_2=2 if princocc_CODE3=="054" | princocc_CODE3=="057" 
	replace occup_2=2 if princocc_CODE3=="070" | princocc_CODE3=="071" | princocc_CODE3=="072" | princocc_CODE3=="073"
	replace occup_2=2 if princocc_CODE3=="074" | princocc_CODE3=="075" | princocc_CODE3=="076" | princocc_CODE3=="084"
	replace occup_2=2 if princocc_CODE3=="085"  | princocc_CODE3=="147"
	replace occup_2=2 if princocc_CODE3=="140" | princocc_CODE3=="141" | princocc_CODE3=="149" | princocc_CODE3=="180"
	replace occup_2=2 if princocc_CODE3=="181" | princocc_CODE3=="182" | princocc_CODE3=="183" | princocc_CODE3=="185"
	replace occup_2=2 if princocc_CODE3=="186" | princocc_CODE3=="187" | princocc_CODE3=="188" | princocc_CODE3=="189"
	replace occup_2=2 if princocc_CODE2=="10" | princocc_CODE2=="11" | princocc_CODE2=="12" | princocc_CODE2=="13"
	replace occup_2=2 if princocc_CODE2=="15" | princocc_CODE2=="16" | princocc_CODE2=="17" | princocc_CODE2=="19"
	
	*technician and associate pro
	
	replace occup_2=3 if princocc_CODE3=="009" | princocc_CODE3=="010" | princocc_CODE3=="019" | princocc_CODE3=="028"
	replace occup_2=3 if princocc_CODE3=="011" | princocc_CODE3=="012" | princocc_CODE3=="014" | princocc_CODE3=="015"
	replace occup_2=3 if princocc_CODE3=="017" | princocc_CODE3=="018" 
	replace occup_2=3 if princocc_CODE3=="029" | princocc_CODE3=="059" | princocc_CODE3=="077" | princocc_CODE3=="078"
	replace occup_2=3 if princocc_CODE3=="079" | princocc_CODE3=="080" | princocc_CODE3=="081" | princocc_CODE3=="082"
	replace occup_2=3 if princocc_CODE3=="083" | princocc_CODE3=="086" | princocc_CODE3=="087" | princocc_CODE3=="088"
	replace occup_2=3 if princocc_CODE3=="089" | princocc_CODE3=="142" | princocc_CODE3=="184" 
	
	replace occup_2=3 if princocc_CODE2=="03" | princocc_CODE2=="04" | princocc_CODE2=="06" | princocc_CODE2=="09"
	
	*legislators, senior officials and managers
	
	replace occup_2=1 if princocc_CODE2=="20" | princocc_CODE2=="21" | princocc_CODE2=="22" | princocc_CODE2=="23"
	replace occup_2=1 if princocc_CODE2=="24" | princocc_CODE2=="25" | princocc_CODE2=="26" | princocc_CODE2=="29" | princocc_CODE2=="27" | princocc_CODE2=="28"
	
	replace occup_2=1 if princocc_CODE2=="30" | princocc_CODE2=="31" | princocc_CODE2=="36"  | princocc_CODE2=="60" 
	
	*clerks
	
	replace occup_2=4 if princocc_CODE2=="32" | princocc_CODE2=="33" | princocc_CODE2=="34" | princocc_CODE2=="35"
	
	replace occup_2=4 if princocc_CODE2=="37" | princocc_CODE2=="38" | princocc_CODE2=="39" 
	
	replace occup_2=4 if princocc_CODE3=="302" 
	
	*Service workers and shop and market sales
	
	replace occup_2=5 if princocc_CODE2=="40" | princocc_CODE2=="41" | princocc_CODE2=="42" | princocc_CODE2=="43"
	replace occup_2=5 if princocc_CODE2=="44" | princocc_CODE2=="45" | princocc_CODE2=="49" | princocc_CODE2=="50"
	replace occup_2=5 if princocc_CODE2=="46" | princocc_CODE2=="47" | princocc_CODE2=="48" 
	replace occup_2=5 if princocc_CODE2=="51" | princocc_CODE2=="52" | princocc_CODE2=="53" | princocc_CODE2=="54"
	replace occup_2=5 if princocc_CODE2=="55" | princocc_CODE2=="56" | princocc_CODE2=="57" | princocc_CODE2=="58" | princocc_CODE2=="59"
	
	*skilled agricultural and fishery workers
	
	replace occup_2=6 if princocc_CODE2=="61" | princocc_CODE2=="62" | princocc_CODE2=="63" | princocc_CODE2=="64"
	replace occup_2=6 if princocc_CODE2=="65" | princocc_CODE2=="66" | princocc_CODE2=="67" | princocc_CODE2=="68" | princocc_CODE2=="69"
	
	*Craft and related trades
	
	replace occup_2=7 if princocc_CODE2=="71" | princocc_CODE2=="72" | princocc_CODE2=="73" | princocc_CODE2=="75" | princocc_CODE2=="70"
	replace occup_2=7 if princocc_CODE2=="76" | princocc_CODE2=="77" | princocc_CODE2=="78" | princocc_CODE2=="79"
	replace occup_2=7 if princocc_CODE2=="80" | princocc_CODE2=="81" | princocc_CODE2=="82" | princocc_CODE2=="92"
	replace occup_2=7 if princocc_CODE2=="93" | princocc_CODE2=="94" | princocc_CODE2=="95" 
	
	*Plant and machine operators and assemblers
	
	replace occup_2=8 if princocc_CODE2=="74" | princocc_CODE2=="83" | princocc_CODE2=="84" | princocc_CODE2=="85"
	replace occup_2=8 if princocc_CODE2=="86" | princocc_CODE2=="87" | princocc_CODE2=="88" | princocc_CODE2=="89"
	replace occup_2=8 if princocc_CODE2=="90" | princocc_CODE2=="91" | princocc_CODE2=="96" | princocc_CODE2=="97"
	replace occup_2=8 if princocc_CODE2=="98" 
	replace occup_2=8 if princocc_CODE3=="813" 
	
	*elementary occup_2ations
	
	replace occup_2=9 if princocc_CODE2=="99" 
	
	*other/unspecified
	
	replace occup_2=99 if princocc_CODE2=="X0" | princocc_CODE2=="X1" | princocc_CODE2=="X9" 
	
	
	*legislators, senior officials and managers CONTT.
	
	replace occup_2=1 if princocc_CODE3=="710" | princocc_CODE3=="720" | princocc_CODE3=="730" | princocc_CODE3=="740"
	replace occup_2=1 if princocc_CODE3=="750" | princocc_CODE3=="760" | princocc_CODE3=="770" | princocc_CODE3=="780"  
	replace occup_2=1 if princocc_CODE3=="790" | princocc_CODE3=="800" | princocc_CODE3=="810" | princocc_CODE3=="820" 
	replace occup_2=1 if princocc_CODE3=="830" | princocc_CODE3=="840" | princocc_CODE3=="850" | princocc_CODE3=="860"  
	replace occup_2=1 if princocc_CODE3=="870" | princocc_CODE3=="880" | princocc_CODE3=="890" | princocc_CODE3=="900" 
	replace occup_2=1 if princocc_CODE3=="910" | princocc_CODE3=="920" | princocc_CODE3=="930" | princocc_CODE3=="940"  
	replace occup_2=1 if princocc_CODE3=="950" | princocc_CODE3=="960" | princocc_CODE3=="970" | princocc_CODE3=="980"
	
	drop  princocc_CODE2 princocc_CODE3
	replace occup_2=. if njobs==0 | njobs==.
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2
	
* WAGES - SECOND JOB
	gen double wage_2=B53_C15_2
	replace wage_2=. if njobs==0 | njobs==.
	label var wage_2 "Last wage payment - Second job"
	
* WAGES TIME UNIT - SECOND JOB
	gen unitwage_2=.
	replace unitwage_2=1 if B53_C18_2==1|B53_C18_2==18
	replace unitwage_2=2 if B53_C18_2==2|B53_C18_2==22
	replace unitwage_2=3 if B53_C18_2==3|B53_C18_2==28
	replace unitwage_2=5 if B53_C18_2==9|B53_C18_2==29
	replace unitwage_2=. if njobs==0 | njobs==.
	label var unitwage_2 "Last wages time unit - Second job"
	la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_2 lblunitwage_2

** CONTRACT
	gen contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract


** HEALTH INSURANCE
	gen healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins


** SOCIAL SECURITY
	gen socialsec=1 if B72_C8>=1 & B72_C8<=4
	replace socialsec=0 if B72_C8==5
	replace socialsec=. if B72_C8==0|B72_C8==6|B72_C8==7|B72_C8==8|B72_C8==9
	replace socialsec=. if lstatus!=1
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


** UNION MEMBERSHIP
	gen union=B72_C6  if lstatus==1
	label var union "Union membership"
	recode union (2=0)
	replace union=. if lstatus!=1
	la de lblunion 0 "No member" 1 "Member"
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

*REGION OF BIRTH JURISDICTION
	gen byte rbirth_juris=.
	label var rbirth_juris "Region of birth jurisdiction"
	la de lblrbirth_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rbirth_juris lblrbirth_juris
	
*REGION OF BIRTH
	gen  rbirth=.
	label var rbirth "Region of Birth"
	
* REGION OF PREVIOUS RESIDENCE JURISDICTION
	gen byte rprevious_juris=B4_C15
	recode rprevious_juris 0/6=9 7=5
	label var rprevious_juris "Region of previous residence jurisdiction"
	la de lblrprevious_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rprevious_juris lblrprevious_juris
	
*REGION OF PREVIOUS RESIDENCE
	recode B4_C17 0 1=.
	gen  rprevious=B4_C17 if B4_C17<=33
	gen aux=B4_C17
	recode aux 51=50 52=524 53=586 54=144 55=64 56 57 62/64=999 58=840 59=124 60=999 61=826 92=.
	replace rprevious=aux if rprevious_juris==5
	label var rprevious "Region of Previous residence"
	
* YEAR OF MOST RECENT MOVE
	gen int yrmove=1999-B4_C14
	label var yrmove "Year of most recent move"
	
*TIME REFERENCE OF MIGRATION
	gen byte rprevious_time_ref=99
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
	gen pcc=B3_C5/hhsize
	label var pcc "Monthly consumption per capita"


** DECILES OF PER CAPITA CONSUMPTION
	xtile pcc_d=pcc[w=wgt],nq(10)
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

* KEEP VARIABLES - ALL
	keep ccode year intv_year month idh idp wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     cellphone computer internet hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage       ///
		 empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2  occup_2 wage_2 unitwage_2 ///
	     contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d
	
* ORDER VARIABLES
	order ccode year intv_year month idh idp wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     cellphone computer internet hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage       ///
		 empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
	     contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d
	
	compress
	
* DELETE MISSING VARIABLES	local keep ""
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
	
	save "`path'\Processed\IND_1999_I2D2_NSS_SCH10.dta", replace
	save "D:\__CURRENT\IND_1999_I2D2_NSS_SCH10.dta", replace
	log close

















******************************  END OF DO-FILE  *****************************************************/
