* Ensure wbopendata is installed
cap which wbopendata
if _rc ssc install wbopendata

* Modest timeouts for HTTP transfers (optional)
set timeout1 60
set timeout2 300

****************************************************
* 1) Total population (SP.POP.TOTL)
****************************************************
wbopendata, indicator(SP.POP.TOTL) country(PSE) clear
keep if inlist(countrycode, "PSE", "PS")
keep countrycode countryname yr1998-yr2014
foreach y of numlist 1998/2014 {
    capture confirm variable yr`y'
    if _rc==0 rename yr`y' TOT_`y'
}
tempfile tot
save `tot', replace

****************************************************
* 2) Female share of total (SP.POP.TOTL.FE.ZS)
****************************************************
wbopendata, indicator(SP.POP.TOTL.FE.ZS) country(PSE) clear
keep if inlist(countrycode, "PSE", "PS")
keep countrycode countryname yr1998-yr2014
foreach y of numlist 1998/2014 {
    capture confirm variable yr`y'
    if _rc==0 rename yr`y' FE_ZS_`y'
}
tempfile fe
save `fe', replace

****************************************************
* 3) 0–4 shares by sex (SP.POP.0004.FE.5Y, SP.POP.0004.MA.5Y)
****************************************************
wbopendata, indicator(SP.POP.0004.FE.5Y) country(PSE) clear
keep if inlist(countrycode, "PSE", "PS")
keep countrycode countryname yr1998-yr2014
foreach y of numlist 1998/2014 {
    capture confirm variable yr`y'
    if _rc==0 rename yr`y' FE0004_ZS_`y'
}
tempfile fe0004
save `fe0004', replace

wbopendata, indicator(SP.POP.0004.MA.5Y) country(PSE) clear
keep if inlist(countrycode, "PSE", "PS")
keep countrycode countryname yr1998-yr2014
foreach y of numlist 1998/2014 {
    capture confirm variable yr`y'
    if _rc==0 rename yr`y' MA0004_ZS_`y'
}
tempfile ma0004
save `ma0004', replace

****************************************************
* 4) 5–9 shares by sex (SP.POP.0509.FE.5Y, SP.POP.0509.MA.5Y)
****************************************************
wbopendata, indicator(SP.POP.0509.FE.5Y) country(PSE) clear
keep if inlist(countrycode, "PSE", "PS")
keep countrycode countryname yr1998-yr2014
foreach y of numlist 1998/2014 {
    capture confirm variable yr`y'
    if _rc==0 rename yr`y' FE0509_ZS_`y'
}
tempfile fe0509
save `fe0509', replace

wbopendata, indicator(SP.POP.0509.MA.5Y) country(PSE) clear
keep if inlist(countrycode, "PSE", "PS")
keep countrycode countryname yr1998-yr2014
foreach y of numlist 1998/2014 {
    capture confirm variable yr`y'
    if _rc==0 rename yr`y' MA0509_ZS_`y'
}
tempfile ma0509
save `ma0509', replace

****************************************************
* 5) Merge indicators
****************************************************
use `tot', clear
merge 1:1 countrycode using `fe',     nogen
merge 1:1 countrycode using `fe0004', nogen
merge 1:1 countrycode using `ma0004', nogen
merge 1:1 countrycode using `fe0509', nogen
merge 1:1 countrycode using `ma0509', nogen

****************************************************
* 6) Compute Pop(10+) for each year
* share(0–4) = female_share * share(0–4,female) + male_share * share(0–4,male)
* share(5–9) = female_share * share(5–9,female) + male_share * share(5–9,male)
* Pop10+ = Total * (1 - (share(0–4) + share(5–9)))
****************************************************
foreach y of numlist 1998/2014 {
    gen fe_share_`y'   = FE_ZS_`y'/100
    gen ma_share_`y'   = 1 - fe_share_`y'

    gen sh0004_`y'     = fe_share_`y' * (FE0004_ZS_`y'/100) + ma_share_`y' * (MA0004_ZS_`y'/100)
    gen sh0509_`y'     = fe_share_`y' * (FE0509_ZS_`y'/100) + ma_share_`y' * (MA0509_ZS_`y'/100)

    gen share10plus_`y' = 1 - (sh0004_`y' + sh0509_`y')
    gen pop10plus_`y'   = TOT_`y' * share10plus_`y'
}

****************************************************
* 7) Reshape to long and export CSV
****************************************************
reshape long TOT_ FE_ZS_ FE0004_ZS_ MA0004_ZS_ FE0509_ZS_ MA0509_ZS_ ///
             fe_share_ ma_share_ sh0004_ sh0509_ share10plus_ pop10plus_, ///
             i(countrycode) j(year)

order countrycode countryname year TOT_ pop10plus_ sh0004_ sh0509_ share10plus_
format TOT_ pop10plus_ %12.0fc

export delimited using "pop10plus_PSE_1998_2014.csv", replace

* Quick check
list in 1/10
summ pop10plus_

