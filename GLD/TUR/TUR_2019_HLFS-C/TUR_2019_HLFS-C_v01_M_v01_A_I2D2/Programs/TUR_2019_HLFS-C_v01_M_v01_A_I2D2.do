/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	TURKEY
** COUNTRY ISO CODE	TUR
** YEAR	2019
** SURVEY NAME	HOUSEHOLD LABOUR FORCE SURVEY
** SURVEY AGENCY	Turkish Statistical Institute (TUIK)
** SURVEY SOURCE	Turkish Statistical Institute (TUIK)
** UNIT OF ANALYSIS	
** RESPONSIBLE	Mario Gronert
** Created	08/06/2021
** Modified	08/06/2021
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
	set mem 500m


** DIRECTORY
	local 	drive 	`"Y"'		// set this to where you mapped the GLD drive on your work computer
	local 	cty3 	"TUR" 	// set this to the three letter country/economy abbreviation
	local 	usr		`"529026_MG"' // set this to whatever Mario named your folder
	local 	surv_yr `"2019"'	// set this to the survey year 
	
** RUN SETTINGS
	local 	cb_pause = 1	// 1 to pause+edit the exported codebook for harmonizing varnames, else 0
	
	
	local 	year 	"`drive':\GLD-Harmonization\\`usr'\\`cty3'\\`cty3'_`surv_yr'_HLFS-C" // top data folder
	local 	main	"`year'\\`cty3'_2019_HLFS-C_v01_M"
	local 	stata	"`main'\data\stata"
	local 	gld 	"`year'\\`cty3'_2019_HLFS-C_v01_M_v01_A_GLD"
	local 	i2d2	"`year'\\`cty3'_2019_HLFS-C_v01_M_v01_A_I2D2"
	local 	code 	"`i2d2'\Programs"
	local 	id_data	"`i2d2'\Data\Harmonized"


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	use "`stata'\LFS2019_raw.dta"


** COUNTRY
	gen ccode = "TUR"
	label var ccode "Country code"


** YEAR
	gen year = 2019
	label var year "Year of survey"


** YEAR OF INTERVIEW
	gen int intv_year = referans_yil
	label var intv_year "Year of the interview"


** MONTH
	gen month=.
	la de lblmonth 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value month lblmonth
	label var month "Month of the interview"


** HOUSEHOLD IDENTIFICATION NUMBER
	tostring birimno, gen(idh)
	label var idh "Household id"



** INDIVIDUAL IDENTIFICATION NUMBER
	egen idp = concat(idh fertno)
	label var idp "Individual id"

	isid idp

** HOUSEHOLD WEIGHTS
	gen wgt=agirlik_katsayisi*1000 // Weight as done gives value in the thousands, need to multiply to have millions
	label var wgt "Household sampling weight"


** STRATA
	gen strata=.
	label var strata "Strata"


** PSU
	gen psu=.
	label var psu "Primary sampling units"


/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
	gen urb=.
	label var urb "Urban/Rural"
	la de lblurb 1 "Urban" 2 "Rural"
	label values urb lblurb


**REGIONAL AREAS
	gen reg01= .
	replace reg01 = 1 if ibbs_1 == "TR1"
	replace reg01 = 2 if ibbs_1 == "TR2"
	replace reg01 = 3 if ibbs_1 == "TR3"
	replace reg01 = 4 if ibbs_1 == "TR4"
	replace reg01 = 5 if ibbs_1 == "TR5"
	replace reg01 = 6 if ibbs_1 == "TR6"
	replace reg01 = 7 if ibbs_1 == "TR7"
	replace reg01 = 8 if ibbs_1 == "TR8"
	replace reg01 = 9 if ibbs_1 == "TR9"
	replace reg01 = 10 if ibbs_1 == "TRA"
	replace reg01 = 11 if ibbs_1 == "TRB"
	replace reg01 = 12 if ibbs_1 == "TRC"
	label var reg01 "Macro regional areas"
	label define reg01  01"Istanbul" 2"West Marmara" 3"Aegean" 4"East Marmara" 5"West Anatolia" 6"Mediterranean" 7"Central Anatolia" 8"West Black Sea" 9"East Black Sea" 10"Northeast Anatolia" 11"Middle East Anatolia" 12"Southeast Anatolia"
	label values reg01 reg01



** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen reg02= .
	replace reg02 = 1 if ibbs_1 == "TR1"
	replace reg02 = 2 if ibbs_1 == "TR2"
	replace reg02 = 3 if ibbs_1 == "TR3"
	replace reg02 = 4 if ibbs_1 == "TR4"
	replace reg02 = 5 if ibbs_1 == "TR5"
	replace reg02 = 6 if ibbs_1 == "TR6"
	replace reg02 = 7 if ibbs_1 == "TR7"
	replace reg02 = 8 if ibbs_1 == "TR8"
	replace reg02 = 9 if ibbs_1 == "TR9"
	replace reg02 = 10 if ibbs_1 == "TRA"
	replace reg02 = 11 if ibbs_1 == "TRB"
	replace reg02 = 12 if ibbs_1 == "TRC"
	label var reg02 "NUTS-1 Region"
	label define reg02  1"Istanbul" 2"West Marmara" 3"Aegean" 4"East Marmara" 5"West Anatolia" 6"Mediterranean" 7"Central Anatolia" 8"West Black Sea" 9"East Black Sea" 10"Northeast Anatolia" 11"Middle East Anatolia" 12"Southeast Anatolia"
	label values reg02 reg02


** REGIONAL AREA 2 DIGITS ADM LEVEL (ADMN2)
	gen reg03=.
	replace reg03 = 1 if ibbs_2 == "TR10"
	replace reg03 = 2 if ibbs_2 == "TR21"
	replace reg03 = 3 if ibbs_2 == "TR22"
	replace reg03 = 4 if ibbs_2 == "TR31"
	replace reg03 = 5 if ibbs_2 == "TR32"
	replace reg03 = 6 if ibbs_2 == "TR33"
	replace reg03 = 7 if ibbs_2 == "TR41"
	replace reg03 = 8 if ibbs_2 == "TR42"
	replace reg03 = 9 if ibbs_2 == "TR51"
	replace reg03 = 10 if ibbs_2 == "TR52"
	replace reg03 = 11 if ibbs_2 == "TR61"
	replace reg03 = 12 if ibbs_2 == "TR62"
	replace reg03 = 13 if ibbs_2 == "TR63"
	replace reg03 = 14 if ibbs_2 == "TR71"
	replace reg03 = 15 if ibbs_2 == "TR72"
	replace reg03 = 16 if ibbs_2 == "TR81"
	replace reg03 = 17 if ibbs_2 == "TR82"
	replace reg03 = 18 if ibbs_2 == "TR83"
	replace reg03 = 19 if ibbs_2 == "TR90"
	replace reg03 = 20 if ibbs_2 == "TRA1"
	replace reg03 = 21 if ibbs_2 == "TRA2"
	replace reg03 = 22 if ibbs_2 == "TRB1"
	replace reg03 = 23 if ibbs_2 == "TRB2"
	replace reg03 = 24 if ibbs_2 == "TRC1"
	replace reg03 = 25 if ibbs_2 == "TRC2"
	replace reg03 = 26 if ibbs_2 == "TRC3"
	label var reg03 "NUTS-2 Region"
	label define reg03  1 "Istanbul" 2 "Edirne, Tekirdağ, Kırklareli" 3 "Balıkesir, Çanakkale" 4 "İzmir" 5 "Denizli, Aydın, Muğla" 6 "Manisa, Afyonkarahisar, Kütahya, Uşak" 7 "Bursa, Eskişehir, Bilecik" 8 "Kocaeli, Sakarya, Düzce, Bolu, Yalova" 9 "Ankara" 10 "Konya, Karaman" 11 "Antalya, Isparta, Burdur" 12 "Adana, Mersin" 13 "Hatay, Kahramanmaraş, Osmaniye" 14 "Nevşehir, Aksaray, Niğde, Kırıkkale, Kırşehir" 15 "Kayseri, Sivas, Yozgat" 16 "Zonguldak, Karabük, Bartın" 17 "Kastamonu, Çankırı, Sinop" 18 "Samsun, Tokat, Çorum, Amasya" 19 "Trabzon, Ordu, Giresun, Rize, Artvin, Gümüşhane" 20 "Erzurum, Erzincan, Bayburt" 21 "Kars, Ağrı, Iğdır, Ardahan" 22 "Malatya, Elazığ, Bingöl, Tunceli" 23 "Van, Muş, Bitlis, Hakkari" 24 "Gaziantep, Adıyaman, Kilis" 25 "Diyarbakır, Şanlıurfa" 26 "Siirt, Mardin, Batman, Şırnak" 
	label values reg03 reg03


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


** HOUSEHOLD SIZE

	gen helper_housekeepers = yakinlik == 11
	gen hhsize = hane_buyukluk - helper_housekeepers // take out housekeepers staying at home
	label var hhsize "Household size"


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen head=yakinlik
	recode head 6/9=5 10 11=6
	label var head "Relationship to the head of household"
	la de lblhead  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Other and non-relatives"
	label values head  lblhead



** GENDER
	gen gender=cinsiyet
	label var gender "Gender"
	la de lblgender 1 "Male" 2 "Female"
	label values gender lblgender


** AGE
	gen age=yas
	replace age=98 if age>98 & age!=.
	label var age "Individual age"


** SOCIAL GROUP
	gen soc=.
	label var soc "Social group"
	la de lblsoc 1 ""
	label values soc lblsoc


** MARITAL STATUS

	gen marital = medeni_durum
	recode marital 1=2 2=1 3=4 4=5
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen ed_mod_age=5 
	*Note the data release we have has only 15 year old and older actual survey cut off is 5. A tad irrelevant but for completeness sake.
	label var ed_mod_age "Education module application age"


** EVER ATTENDED SCHOOL
	gen everattend = okul_biten_k != 0
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes", modify
	label values everattend lbleverattend



** CURRENTLY AT SCHOOL
	gen atschool=egitim_devam_k == 1
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool



** CAN READ AND WRITE
	gen literacy=okur_yazar != 2
	recode literacy (2=0)
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes", modify
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen educy=.
	label var educy "Years of education"


** EDUCATIONAL LEVEL 1
	gen edulevel1=.
	label var edulevel1 "Level of education 1"
	la de lbledulevel1 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7 "University incomplete or complete" 8 "Other" 9 "Unstated"
	label values edulevel1 lbledulevel1


** EDUCATION LEVEL 2
	gen edulevel2=.
	replace edulevel2 = 1 if okul_biten_k  == 0
	replace edulevel2 = 2 if okul_biten_k  == 1
	replace edulevel2 = 3 if okul_biten_k  == 2
	replace edulevel2 = 4 if okul_biten_k  == 31 | okul_biten_k  == 32
	replace edulevel2 = 5 if okul_biten_k  == 4 | okul_biten_k  == 5	
	label var edulevel2 "Level of education 2"
	la de lbledulevel2 1 "No education" 2 "Primary incomplete"  3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
	label values edulevel2 lbledulevel2


** EDUCATION LEVEL 3
	gen edulevel3= okul_biten_k if age>=ed_mod_age
	recode edulevel3 0=1 1=2 2 31/32=3 4/5=4
	label var edulevel3 "Level of education 3"
	la de lbledulevel3 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values edulevel3 lbledulevel3
	 
	 

/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen lb_mod_age=15
	*Note the data release we have has only 15 year old and older actual survey cut off is 15. A tad irrelevant but for completeness sake.
	label var lb_mod_age "Labor module application age"

	gen lstatus=durum
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
	gen empstat=isteki_durum_k
	recode empstat 2=3 3=4 4=2
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat


** EMPLOYMENT STATUS LAST YEAR
	gen byte empstat_year=.
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year


** NUMBER OF ADDITIONAL JOBS
	* question is do you nhave other. Assume that one job
	gen njobs=1 if durum == 1
	replace njobs = 2 if ekis_durum == 1
	label var njobs "Number of total jobs"


** NUMBER OF ADDITIONAL JOBS LAST YEAR
	gen byte njobs_year=.
	replace njobs_year=. if lstatus_year!=1
	label var njobs_year "Number of additional jobs during last year"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen ocusec=ozel_kamu
	recode ocusec (2=1) (1=2) (98=.)
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public Sector, Central Government, Army, NGO" 2 "Private" 3 "State owned" 4 "Public or State-owned, but cannot distinguish", modify
	label values ocusec lblocusec


** REASONS NOT IN THE LABOR FORCE
	gen nlfreason = ido_neden
	recode nlfreason (35=1) (34=2) (36=3) (37=4) (31 32 33 38 39 =5) 
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason
	replace nlfreason=. if lstatus==2


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen unempldur_l=. 
	replace unempldur_l = isara_sure if lstatus==2
	label var unempldur_l "Unemployment duration (month) lower bracket"

	gen unempldur_u=.
	replace unempldur_u = isara_sure if lstatus==2
	label var unempldur_u "Unemployment duration (month) upper bracket"

** INDUSTRY CLASSIFICATION
	gen industry=.
	replace industry = 1 if inrange(nace2_esas_k,1,3)
	replace industry = 2 if inrange(nace2_esas_k,5,9)
	replace industry = 3 if inrange(nace2_esas_k,10,33)
	replace industry = 4 if inrange(nace2_esas_k,35,39)
	replace industry = 5 if inrange(nace2_esas_k,41,43)
	replace industry = 6 if inrange(nace2_esas_k,45,47) | inrange(nace2_esas_k,55,56)
	replace industry = 7 if inrange(nace2_esas_k,49,53) | inrange(nace2_esas_k,58,63)
	replace industry = 8 if inrange(nace2_esas_k,64,82)
	replace industry = 9 if inrange(nace2_esas_k,84,84)
	replace industry = 10 if inrange(nace2_esas_k,85,99)
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry


** INDUSTRY 1
	gen byte industry1=industry
	recode industry1 (1=1)(2 3 4 5 =2)(6 7 8 9=3)(10=4)
	replace industry1=. if lstatus!=1
	label var industry1 "1 digit industry classification (Broad Economic Activities)"
	la de lblindustry1 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industry1 lblindustry1


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION
	gen industry_orig = string(nace2_esas_k,"%02.0f")
	replace industry_orig = "" if industry_orig == "."	
	replace industry_orig = industry_orig + "00" if !missing(industry_orig)
	replace industry_orig=. if lstatus!=1
	label var industry_orig "Original Industry Codes (NACE/ISIC code at Division Level)"


** OCCUPATION CLASSIFICATION
	gen occup=floor(isco08_esas_k/10)
	label var occup "1 digit occupational classification"
	label define occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup


** SURVEY SPECIFIC OCCUPATION CLASSIFICATION
	gen occup_orig = string(isco08_esas_k,"%02.0f")
	replace occup_orig = "" if occup_orig == "."	
	replace occup_orig = occup_orig + "00" if !missing(occup_orig)
	replace occup_orig="" if lstatus!=1
	label var occup_orig "Original Occupational Codes"

** FIRM SIZE
	gen firmsize_l=calisan_sayi_hh
	recode firmsize_l (1=.) (2=11) (3=20) (4=50) (5=11)
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket)"

	gen firmsize_u=calisan_sayi_hh
	recode firmsize_u (1=10) (2=19) (3=49) (4=.) (5=.)
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket)"

	
********************************************************************************************	
********************************************************************************************	
********************************************************************************************	
********************************************************************************************	
	
	
	
	
	
** HOURS WORKED LAST WEEK
	gen whours=s56a_top
	label var whours "Hours of work in last week"

** WAGES

	gen wage=s69
	replace wage=. if lstatus!=1
	label var wage "Last wage payment"

** WAGES TIME UNIT

	gen unitwage=5
	replace unitwage=. if lstatus!=1
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly"
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
	gen industry_orig_2=s53kod
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

	gen socialsec=.
	replace socialsec=1 if s42==1
	replace socialsec=0 if s42==2
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec

** UNION MEMBERSHIP

	gen union=.
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion


/*****************************************************************************************************
*                                                                                                    *
                                   MIGRATION MODULE
*                                                                                                    *
*****************************************************************************************************/


**REGION OF BIRTH JURISDICTION
	gen byte rbirth_juris=s7
	recode rbirth_juris 1=2 2=5
	label var rbirth_juris "Region of birth jurisdiction"
	la de lblrbirth_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rbirth_juris lblrbirth_juris


**REGION OF BIRTH
	gen rbirth=.
	label var rbirth "Region of Birth"


** REGION OF PREVIOUS RESIDENCE JURISDICTION
	gen byte rprevious_juris=s10a
	recode rprevious_juris 1=2 2=5
	label var rprevious_juris "Region of previous residence jurisdiction"
	la de lblrprevious_juris 1 "reg01" 2 "reg02" 3 "reg03" 5 "Other country"  9 "Other code"
	label values rprevious_juris lblrprevious_juris


**REGION OF PREVIOUS RESIDENCE
	gen rprevious=.
	label var rprevious "Region of Previous residence"


** YEAR OF MOST RECENT MOVE
	gen int yrmove=s9b
	label var yrmove "Year of most recent move"


**TIME REFERENCE OF MIGRATION
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
	label var pci_d "Income per capita deciles"


** CONSUMPTION PER CAPITA
	gen pcc=.
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
	keep ccode year intv_year month idh idp wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
	     cellphone computer internet hhsize head gender age soc marital ed_mod_age everattend atschool  ///
	     literacy educy edulevel1 edulevel2 edulevel3 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason                         ///
	     unempldur_l unempldur_u industry industry1 industry_orig occup occup_orig firmsize_l firmsize_u whours wage unitwage contract      ///
	empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 ///
	     healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove rprevious_time_ref pci pci_d pcc pcc_d


** ORDER VARIABLES
	order ccode year intv_year month idh idp wgt strata psu urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone      ///
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
	keep ccode year intv_year month  idh idp wgt strata psu `keep'


	save "`path'\Processed\TUR_2015_I2D2_HLFS.dta", replace
	save "D:\__CURRENT\TUR_2015_I2D2_HLFS.dta", replace
	log close





















******************************  END OF DO-FILE  *****************************************************/
