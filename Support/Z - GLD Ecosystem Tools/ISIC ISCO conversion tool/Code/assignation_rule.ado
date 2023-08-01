********************************************************************************
* Program for industrial or occupational codes assignation
********************************************************************************

cap program drop assignation_rule
program define assignation_rule
{
syntax, id(varlist) origvar(str) classfrom(str) classto(str) [fullcorr(str) seed(int 1) section]

// Step 0: Preliminaries

*Optional Arguments
if !mi("`section'") local addsec section
if mi("`section'") local addsec
if !mi("`seed'") local addseed seed(`seed')
if mi("`seed'") local addseed 

*Id
set seed `seed'
sort `id', stable
isid `id', sort
egen toolid = group(`id')
sort toolid, stable
isid toolid, sort
gen origsample = !mi(toolid)

*Original Variable
gen l = length(`origvar')
qui sum l
if `r(max)' >= 4 & mi("`section'") gen raw_origvar = real(substr(string(real(`origvar')),1,4))
if `r(max)' == 3 & mi("`section'") gen raw_origvar = 10*real(substr(string(real(`origvar')),1,3))
if `r(max)' == 2 & mi("`section'") gen raw_origvar = 100*real(substr(string(real(`origvar')),1,2))
if `r(max)' == 1 & !mi("`addsec'") & regexm("`classfrom'","isic") gen raw_origvar = substr(`origvar',1,1)
if `r(max)' == 1 & mi("`addsec'") & regexm("`classfrom'","isco") gen raw_origvar = 1000 * real(substr(string(real(`origvar')),1,1))

// Step 1: Merge Classes

# d ;
merge_class, 
	id(`id') 
	origvar(raw_origvar) 
	classfrom(`classfrom') 
	`addseed'
	`addsec'
;
# d cr
local corrlist `r(clist)'

// Step 2: Merge Correspondences

di in red "### Matching Quality Report ###"
if mi("`section'") qui count if !mi(`classfrom'_4dig)
if !mi("`section'") qui count if !mi(`classfrom'_secdig)
di in red "Number of Non-Missing Classes: `r(N)'"	
foreach c of local corrlist{

	# d ;
		merge_correspondence, 
		id(`id') 
		origvar(`classfrom'_`c'dig) 
		classfrom(`classfrom') 
		classto(`classto') 
		dig(`c') 
		`addseed'
		`addsec'
	;
	# d cr
	di in red "# From `classfrom' to `classto' at Agreggation `c'#"	
	di in red "Number of One-to-One Matches: `r(one_to_one)'"
	di in red "Number of Many-to-One Matches: `r(many_to_one)'"
	
	cap gld_labels, classfrom(`classfrom') classto(`classto') dig(`c') // ISCO labels missing yet
	
}
di in red "###############################"

// Step 3: Clean-Up Stage
keep if origsample == 1
if  "`fullcorr'" == "no"{
	foreach var in toolid l raw_origvar ///
		isco_88_3dig isco_88_2dig isco_88_1dig ///
		isco_08_3dig isco_08_2dig isco_08_1dig ///
		isic_rev2_3dig isic_rev2_2dig isic_rev2_secdig ///
		isic_rev3_3dig isic_rev3_2dig isic_rev3_secdig ///
		isic_rev31_3dig isic_rev31_2dig isic_rev31_secdig ///	
		isic_rev4_3dig isic_rev4_2dig isic_rev4_secdig ///
		isco_88_3dig_label isco_88_2dig_label isco_88_1dig_label ///
		isco_08_3dig_label isco_08_2dig_label isco_08_1dig ///
		isic_rev2_3dig_label isic_rev2_2dig_label isic_rev2_secdig_label ///
		isic_rev3_3dig_label isic_rev3_2dig_label isic_rev3_secdig_label ///
		isic_rev31_3dig_label isic_rev31_2dig_label isic_rev31_secdig_label ///	
		isic_rev4_3dig_label isic_rev4_2dig_label isic_rev4_secdig_label origsample{
		cap drop `var'
	}
}

cap ren isic_rev*_*dig isic_*_*dig
cap ren isic_rev*_*dig_label isic_*_*dig_label

cap ren isco_88_*dig isco_1988_*dig
cap ren isco_88_*dig_label isco_1988_*dig_label

cap ren isco_08_*dig isco_2008_*dig  
cap ren isco_08_*dig_label isco_2008_*dig_label  

else if "`fullcorr'" == "yes"{
	foreach var in toolid raw_origvar l origsample{
		cap drop `var'
	}
}
}
end
