
*******************************

*	I2D2 Checks

*******************************

cap log close
clear
set more off
set obs 500


*----------------------------------------------------------------------------------
* DATABASE INPUTS
*----------------------------------------------------------------------------------

local 	drive 	`"Y"'
local 	ccode 	`"PHL"'
local 	usr		`"551206_TM"'
local 	y       `"2008"'
local 	year 	"`drive':\GLD-Harmonization\\`usr'\\`ccode'\\`ccode'_`y'_LFS"
local 	i2d2	"`year'\\`ccode'_`y'_LFS_v01_M_v01_A_I2D2"
local 	id_data "`i2d2'\Data\Harmonized"


********************************************************************************************************
********************************************************************************************************
* DONT CHANGE ANYTHING BELOW THIS LINE!
********************************************************************************************************
********************************************************************************************************

use "`id_data'\\`ccode'_`y'_I2D2_LFS.dta", clear
log using "`i2d2'\Work\\`ccode'_`y'_I2D2_LFS_check.txt", replace


* Creating variables not available in the survey for check purposes.
foreach var in pci pcc urb reg01 reg02 reg03 reg04 ownhouse water electricity toilet landphone cellphone marital computer internet everattend atschool literacy educy edulevel1 edulevel2 edulevel3 lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason industry industry1 industry_orig occup occup_orig whours unitwage empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union  firmsize_l firmsize_u  unempldur_l unempldur_u  wage {
cap gen `var'=.
}


* COUNTRY/YEAR:
list ccode year in 1/1,noobs

*----------------------------------------------------------------------------------
* CHECK IDH AND IDP
*----------------------------------------------------------------------------------

* VARIABLES AS STRING

foreach v in idh idp {
                capture confirm string variable `v'
                if !_rc {
                }
                else {
di as error "`v' is not string"
                }
        }
* UNIQUE PERSON ID
bys idh idp: assert  _n==1

* NO MORE THAN 3% OF THE SAMPLE HAS THE SAME IDH

preserve
sort idh
su year
scalar N=r(N)
gen i=1
egen IDH=group(idh i)
bys idh: egen n=count(IDH)
gen N_idh=n/N
su N_idh
scalar max=r(max)
if max>.03{
di as error "More than 3% of the sample has the same idh value"
}

restore

* IDH MISSING

preserve
gen i=1
egen IDH=group(idh i)
gen miss=IDH==.
su miss
scalar missing=r(mean)
if missing!=0{

	     display as error "Missing values on idh detected"
}
restore

* Confirm that fewer than 5% of obs are missing idh

preserve
gen i=1
egen IDH=group(idh i)
gen miss=IDH==.
collapse (mean) miss

di "Missing idh"
sum miss
assert miss<=.05
restore



*----------------------------------------------------------------------------------
* DEMOGRAPHIC AND HOUSEHOLD VARIABLES
*----------------------------------------------------------------------------------
di "Hhsize"
preserve
su hhsize
scalar max=r(max)
if max>40{
di as error "There are obs with hhsize greater than 40"
restore
}
restore

di "Head"
assert head==1 | head==2 | head==3 |  head==4 | head==5 | head==6 | head==.

* Confirm that there's a head of hh in each hh

preserve

gen headhh=head==1
sort idh
gen i=1
egen IDH=group(idh i)
bys IDH: egen n=total(headhh)

di "Head variable has 1 obs with head==1"
assert n==1

restore

* Confirm that fewer than 3% of obs are missing head
preserve
gen miss=head==.
collapse (mean) miss

di "Missing Heads"
sum miss
assert miss<=.03
restore

di "Gender coding"
assert gender==1|gender==2|gender==.

* Confirm that fewer than 3% of obs are missing gender

preserve
gen miss=gender==.
collapse (mean) miss

di "Missing Gender"
sum miss
assert miss<=.03
restore
di "Urb"
assert urb==1 | urb==2 | urb==.

di "Ownhouse"
assert ownhouse==0 | ownhouse==1 | ownhouse==.

di "Water"
assert water==0 | water==1 | water==.

di "Electricity"
assert electricity==0 | electricity==1 | electricity==.

di "Toilet"
assert toilet==0 | toilet==1 | toilet==.

di "Landphone"
assert landphone==0 | landphone==1 | landphone==.

di "Cellphone"
assert cellphone==0 | cellphone==1 | cellphone==.

di "Computer"
assert computer==0 | computer==1 | computer==.

di "Internet"
assert internet==0 | internet==1 | internet==.

di "Age Limits"
assert age>=0 & age<=98 if age!=.

di "Check that hh variables have the same values for all hh"

preserve
foreach var in urb reg01 reg02 reg03 reg04 water electricity toilet landphone cellphone computer internet{

bys idh: egen `var'_mean=mean(`var')

di "`var'"
assert `var'==`var'_mean

}
restore

* Confirm that fewer than 3% of obs are missing age
preserve
gen miss=(age==.)
collapse (mean) miss

di "Missing Age"
sum miss
assert miss<=.03
restore

di "Marital"
assert marital==1 | marital==2 | marital==3 | marital==3 | marital==4 | marital==5 | marital==.

*check female head <50%

preserve
gen femalehd=head==1 & gender==2
collapse (mean)  femalehd

di "Female Heads < 50%"
assert femalehd<.5
restore

* CHECKS for head==6

preserve

bys idh: egen hhsize1_5=count(head) if head>=1 & head<=5
bys idh: egen hhsize15=max(hhsize1_5)

di "Checks for head==6"

di "Household Size"
assert hhsize==. | (hhsize>hhsize15  & hhsize!=1 & hhsize!=.) if head==6

di "Ownhouse"
assert ownhouse==. if head==6

restore

*----------------------------------------------------------------------------------
* EDUCATION VARIABLES
*----------------------------------------------------------------------------------

* CHECK for education variables missing for age<ed_mod_age

local ed_var "everattend atschool literacy educy edulevel1 edulevel2 edulevel3"

foreach v in `ed_var'{

di "check `v' only for age>=ed_mod_age"
replace `v'=. if age<ed_mod_age & age!=.
assert `v'==. if( age<ed_mod_age & age!=.)
}


di "Ever Attend"
assert everattend==0 | everattend==1 | everattend==.

di "At School"
assert atschool==0 | atschool==1 | atschool==.

di "Literacy"
assert literacy==0 | literacy==1 | literacy==.

di "Educ Years"
assert educy>=0 & educy<=30  | educy==.

di "Educ Level 1"
assert edulevel1==1 | edulevel1==2 | edulevel1==3 | edulevel1==4 | edulevel1==5 | edulevel1==6 | edulevel1==7 | edulevel1==8 | edulevel1==9 | edulevel1==.

di "Educ Level 2"
assert edulevel2==1 | edulevel2==2 | edulevel2==3 | edulevel2==4 | edulevel2==5 | edulevel2==.

di "Educ Level 3"
assert edulevel3==1 | edulevel3==2 | edulevel3==3 | edulevel3==4 | edulevel3==.

di "Ever attend vs At School (1)"
assert everattend==1 | everattend==. if atschool==1

di "Ever attend vs At School (0)"
assert atschool==0 if everattend==0 & atschool!=.

preserve

gen miss=everattend==.
su miss
scalar missing=r(mean)
if missing==1{

di "Check that Educy=0 if everattend==0"
assert educy==0 if everattend==0

foreach var in edulevel1 edulevel2 edulevel3{

di "Check that `var' reports No Education if everattend==0"

assert `var'==1 if everattend==0

}
}
restore

*----------------------------------------------------------------------------------
* LABOR VARIABLES
*----------------------------------------------------------------------------------

* Check missing obs in labor variables when age<lb_mod_age
	/*the original code assumes that all varialbes here are numeric in the original form, but that's not the case for
		occup_orig, so adding numeric filter*/

local lb_var "lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason industry industry1 industry_orig occup occup_orig whours unitwage empstat_2 empstat_2_year industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union  firmsize_l firmsize_u  unempldur_l unempldur_u  wage"

ds `lb_var', has(type numeric)
loc lb_var = r(varlist)


foreach v in `lb_var'{

di "check `v' only for age>=lb_mod_age"
assert `v'==. if( age<lb_mod_age & age!=.)
}

* CHECK missing obs in variables that require lstatus=1

local lb_var "empstat njobs ocusec industry industry1 occup firmsize_l firmsize_u whours wage unitwage contract healthins socialsec union"

foreach v in `lb_var'{

di "check `v' only for lstatus==1"
assert `v'==. if( lstatus!=1)
}

* CHECK missing obs in variables that require lstatus=2

local lb_var "unempldur_l unempldur_u"

foreach v in `lb_var'{

di "check `v' only for lstatus==2"
assert `v'==. if( lstatus!=2)
}

* CHECK missing obs in variables that require lstatus=3

local lb_var "nlfreason"

foreach v in `lb_var'{

di "check `v' only for lstatus==3"
assert `v'==. if( lstatus!=3)
}

* CHECK missing obs in variables that require lstatus_year=1

local lb_var "empstat_year njobs_year"

foreach v in `lb_var'{

di "check `v' only for lstatus_year==1"
assert `v'==. if( lstatus_year!=1)
}

* CHECK missing obs in variables that require njobs>0
	/* In most years, this variable is not provided even while employment status data are provided,
		so njobs will always be missing. We have to add a
	  	upper-level conditional that takes into account if the variable is always missing. */
preserve
gen 	jobs_var = .

mdesc 	njobs
if _N == r(miss) {
	replace jobs_var = 0		// the variable is entirely missing, indicate so
	}
else {
	replace jobs_var = 1		// otherwise, tell us that there are non missing values
	}


local lb_var "empstat_2 industry_2 industry1_2 industry_orig_2 occup_2 wage_2 unitwage_2"

foreach v in `lb_var'{

di "check `v' only for njobs>0"
assert `v'==. if( njobs==0 | njobs==.)	& jobs_var == 1		// only perform if njobs exists
}

*CHECK missing obs for empstat_2_year

di "check empstat_2_year only for njobs_year>0"

assert empstat_2_year==. if ( njobs_year==0 | njobs_year==.) & jobs_var == 1		// only perform if njobs exists


restore
* Check coding in labor variables

di "Lstatus"
assert lstatus==1 | lstatus==2 | lstatus==3 | lstatus==.

di "Lstatus_year"
assert lstatus_year==1 | lstatus_year==0 | lstatus_year==.

di "Empstat"
assert empstat==1 | empstat==2 | empstat==3 | empstat==4 | empstat==5 | empstat==.

di "Empstat_2"
assert empstat_2==1 | empstat_2==2 | empstat_2==3 | empstat_2==4 | empstat_2==5 | empstat_2==.

di "Empstat_year"
assert empstat_year==1 | empstat_year==2 | empstat_year==3 | empstat_year==4 | empstat_year==5 | empstat_year==.

di "Empstat_2_year"
assert empstat_2_year==1 | empstat_2_year==2 | empstat_2_year==3 | empstat_2_year==4 | empstat_2_year==5 | empstat_2_year==.

di "Njobs"
assert (njobs>=0 & njobs<=10) | njobs==.

di "Njobs_year"
assert (njobs_year>=0 & njobs_year<=10) | njobs_year==.

di "Ocusec"
assert ocusec==1 | ocusec==2 | ocusec==3 | ocusec==4 | ocusec==.

di "Nlfreason"
assert nlfreason==1 |  nlfreason==2 | nlfreason==3 | nlfreason==4 | nlfreason==5 | nlfreason==.

di "Industry"
assert industry==1 |  industry==2 | industry==3 | industry==4 | industry==5 | industry==6 | industry==7 | industry==8 | industry==9 | industry==10 | industry==.

di "Industry_2"
assert industry_2==1 |  industry_2==2 | industry_2==3 | industry_2==4 | industry_2==5 | industry_2==6 | industry_2==7 | industry_2==8 | industry_2==9 | industry_2==10 | industry_2==.

di "Industry1"
assert industry1==1 |  industry1==2 | industry1==3 | industry1==4 | industry1==.

di "Industry1_2"
assert industry1_2==1 |  industry1_2==2 | industry1_2==3 | industry1_2==4 | industry1_2==.

di "Occup"
assert occup==1 |  occup==2 | occup==3 | occup==4 | occup==5 | occup==6 | occup==7 | occup==8 | occup==9 | occup==10 | occup==99 | occup==.

di "Occup_2"
assert occup_2==1 |  occup_2==2 | occup_2==3 | occup_2==4 | occup_2==5 | occup_2==6 | occup_2==7 | occup_2==8 | occup_2==9 | occup_2==10 | occup_2==99 | occup_2==.

di "Whours"
assert (whours>=0 & whours<=168) | whours==.

di "Unitwage"
assert unitwage==1 | unitwage==2 | unitwage==3 | unitwage==4 | unitwage==5 | unitwage==6 | unitwage==7 | unitwage==8 |  unitwage==9 | unitwage==10 | unitwage==.

di "Unitwage_2"
assert unitwage_2==1 | unitwage_2==2 | unitwage_2==3 | unitwage_2==4 | unitwage_2==5 | unitwage_2==6 | unitwage_2==7 | unitwage_2==8 |  unitwage_2==9 | unitwage_2==10 | unitwage_2==.

di "Contract"
assert contract==0 | contract==1 | contract==.

di "Health Insurance"
assert healthins==0 | healthins==1 | healthins==.

di "Social Sec"
assert socialsec==0 | socialsec==1 | socialsec==.

di "Union"
assert union==0 | union==1 | union==.

di "Firmsize"
assert firmsize_l<=firmsize_u if firmsize_l!=. & firmsize_u!=.

di "Unemp. Dur"
assert unempldur_l<=unempldur_u

* OTHER CHECKS

* Variables for working people
di "Variables for working people"
gen byte flag1=empstat==. if lstatus==1
gen byte flag2=lstatus==. if empstat!=.
gen byte flag3=wage!=0 if empstat==2
gen byte flag4=empstat_year==. if lstatus_year==1
gen byte flag5=lstatus_year==. if empstat_year!=.
gen byte flag6=wage_2!=0 if empstat_2==2
gen byte flag7=empstat_2==. if (njobs>0 & njobs!=.)
gen byte flag8=njobs>0 & njobs!=. if empstat_2!=.
gen byte flag9=empstat_2_year==. if (njobs_year>0 & njobs_year!=.)
gen byte flag10=njobs_year>0 & njobs_year!=. if empstat_2_year!=.

* PROBLEMS WITH EMP STAT AND LSTATA WAGES
* SHOULD NOT BE MISSING EMPSTAT IF LSTAT=1
di "Problems with Empstat and lstatus, wages"
tab lstatus empstat       	if flag1==1,m
tab lstatus empstat  ,m
tab lstatus_year empstat_year       	if flag4==1,m
tab lstatus_year empstat_year  ,m
tab njobs empstat_2       	if flag7==1,m
tab njobs empstat_2  ,m
tab njobs_year empstat_2_year       	if flag9==1,m
tab njobs_year empstat_2_year  ,m


* SHOULD NOT BE MISSING LSTAT IF EMPSTAT=1
di "should not be missing if if empstat=1"
tab lstatus empstat       	if flag2==1,m
tab lstatus_year empstat_year       	if flag5==1,m
tab njobs empstat_2 if flag8==1,m
tab njobs empstat_2,m
tab njobs_year empstat_2_year if flag10==1,m
tab njobs_year empstat_2_year,m

* SHOULD WAGES=0 IF EMPSTAT==2 (Non-paid family workers should have no wage)
di "should not have wages if empstat=2"
tab wage empstat			if flag3==1,m
tab wage_2 empstat_2			if flag6==1,m

* CHECK IF % OF "OTHERS" in INDUSTRY and INDUSTRY_2 is HIGHER THAN 20%
preserve

gen others=(industry==10)
gen others2=(industry_2==10)
collapse (mean) others others2

di "Others category in Industry doesn't account for more than 20%"
sum others others2
assert others<=.2
assert others2<=.2
restore
*/
*----------------------------------------------------------------------------------
* INCOME AND CONSUMPTION VARIABLES
*----------------------------------------------------------------------------------


* Confirm than fewer than 10% of obs have missing pcc

preserve
gen miss=(pcc==.)
collapse (mean) miss

di "miss Consumption Variable"
sum miss
scalar N=r(N)
if N!=1{
scalar missing=r(mean)
if missing>.1{
di as error "pcc variable missing for more than 10% of the sample"
}
}

restore

*  Confirm that fewer than 5% of obs have the same consumption/income value

foreach x in pcc pci{
su `x'
scalar N=r(N)
scalar `x'_mean=r(mean)
if `x'_mean==0{
di as error "`x' has 0 mean"
}
else{
if N!=0{
preserve
sort `x'
drop if `x'==.
drop if `x'==0
duplicates tag `x', gen(TAG)
egen tag=max(TAG)
gen same_`x'=tag/_N

su same_`x'

assert same_`x'<0.05

restore

}
}
}
* Confirm than fewer than 15% of obs have missing pci

preserve
gen miss=(pci==.)
collapse (mean) miss

di "miss Consumption Variable"
sum miss
scalar N=r(N)
if N!=1{
scalar missing=r(mean)
if missing>.15{
di as error "pci variable missing for more than 15% of the sample"
}
}
restore

* Confirm that households have the same pci & pcc values

preserve

foreach x in pci pcc{

gen miss_`x'=`x'==.
su miss_`x'
scalar missing=r(mean)

if missing!=1{
di "Checks that `x' variable has the same values within HH"
sort idh
bysort idh: gen 	dif_`x'=(`x'!=`x'[_n+1] & idh==idh[_n+1] & head!=6 & head[_n+1]!=6)
			replace dif_`x'=1 if `x'!=`x'[_n-1] & idh==idh[_n-1] & head!=6 & head[_n-1]!=6
			replace dif_`x'=0 if `x'!=`x'[_n-1] & idh==idh[_n-1] & head==6 & `x'==.

bysort idh: egen DIF_`x'=max(dif_`x')
assert DIF_`x'==0
}
}

/* IN ORDER TO CHECK WHEN THIS ASSERTION IS FALSE, TEMPORARILY DELETE THE PRESERVE
THAT IS WRITTEN BEFORE THIS "FOREACH" AND REMOVE THE * BEFORE THE FOLLOWING LINE */

* br idh head pci DIF_pci if DIF_pci!=0

restore

* Confirm that if pcc or pci are available, pcc_d and pci_d are created and !=.

foreach x in pci pcc{
preserve
gen miss=`x'==.
su miss
scalar missing=r(mean)

di "Checks that `x'_d variable is created if `x' variable is available and nonmiss"

if missing!=1{
gen miss_d=`x'_d==.
su miss_d
scalar missing_d=r(mean)

if missing_d==1{
di as error "Variable `x'_d is not created while there is a nonmiss `x' variable"
}
}
else{
di as error "Variable `x' is missing"
}
restore
}

log off
log close
clear

************************************************************************************
* THE FOLLOWING SECTION CONTAINS CODING IN PREVIOUS VERSIONS OF CHECK1 THAT WERE
* ALREADY IGNORED (MEANING WITH AN * BEFORE THE LINE. THIS HAVE BEEN LEFT TO KEEP
* RECORD
************************************************************************************

*************** OTHER CHECKINGS ************************
/* Check if less than 5% of those with no eduaction (or zero years of schooling) have attended school*/
*preserve
* for data sets that do not have edulevel1, make up a data point so program still runs
*egen Nedulevel1=count(edulevel1)
*replace edulevel1=1 if everattend==0 & Nedulevel1==0
*keep if edulevel1==1
*collapse (mean)  everattend
*replace everattend=everattend*100
*replace everattend=round(everattend,.1)
*log on
************************************************************
************************************************************
* CHECK IF >5% OF CASES WHERE THOSE WITH NO EDUCATION REPORT HAVING ATTENDED SCHOOL
*list everattend,noobs
*log off
*restore

*preserve
*keep if educy==0
*collapse (mean)  everattend
*replace everattend=everattend*100
*replace everattend=round(everattend,.1)
*log on
************************************************************
************************************************************
* CHECK IF >5% OF CASES WHERE THOSE WITH YEAR EDUC=0 REPORT HAVING ATTENDED SCHOOL

*list everattend,noobs
*log off
*restore
