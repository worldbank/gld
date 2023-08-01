********************************************************************************
* ISIC-ISCO CORRESPONDENCE TOOL															   *
********************************************************************************

capture program drop isic_isco_correspondence
program define isic_isco_correspondence
{		
version 14.0	

syntax, ID(varlist) ORIGvar(str) CLASSFrom(str) CLASSTo(str) [FULLcorr(str) Seed(int 1) SECtion]
 

// 0. SETUP

**User written commands
cap qui ssc install filelist

**Current directory to save files
global outdir `c(pwd)'


// 1. SYNTAX ERRORS

**error: check for unique identifiers
tempvar dup
qui duplicates tag `id', gen(`dup')
qui count if `dup'>0 & `dup'!=.
if `r(N)'>1 {
   di as error "id() do not correspond to unique identifiers. Please check the help file for more information."
	exit 198	
}

**error: 'classfrom' and 'classto' are restricted to the followinf structure
if !inlist("`classfrom'","isic_2","isic_3","isic_3.1","isic_4","isco_1988","isco_2008") {
		di as error "classfrom() name does not match with ISIC or ISCO classifications, 'classfrom' is non-admisible. Please check the help file for more information."
		exit 198				
}
/*
*if !inlist("`classto'","isic_2","isic_3","isic_3.1","isic_4","isco_1988","isco_2008") {*
*		di as error "classto() name does not match with ISIC or ISCO classifications, 'classto' is non-admisible. Please check the help file for more information."
		exit 198				
}
*/
**error: 'classfrom' and 'classto' must use industrial or occupational classification in both arguments. 
if inlist("`classfrom'","isic_2","isic_3","isic_3.1","isic_4") & !inlist("`classto'","isic_2","isic_3","isic_3.1","isic_4") {
		di as error "If classfrom() correspond to an industrial classification, then classto() must also be an industrial classification. Please check the help file for more information."
		exit 198				
}

if inlist("`classfrom'","isco_1988","isco_2008") & !inlist("`classto'","isco_1988","isco_2008") {
		di as error "If classfrom() correspond to an occupational classification, then classto() must also be an occupational classification. Please check the help file for more information."
		exit 198				
}

**error: 'classfrom' and 'classto' must be different classifications. 
if "`classfrom'"=="`classto'" {
		di as error "classfrom() and classto() must be differet classifications. Please check the help file for more information."
		exit 198				
}

**error: 'fullcorr' only admits 'yes' and 'no' argumnents.
if !inlist("`fullcorr'","yes","no") {
		di as error "fullcorr() only admits 'yes' and 'no' arguments. Please check the help file for more information."
		exit 198				
}

	**Optional arguments
	
	*error: 'seed' is restricted to positive integers
	if !mi("`seed'"){
		if `seed'!=. & `seed'<0 {
			di as error "seed() is restricted to positive integers."
			exit 198
		}
		local numseed = `seed'
	}
	if mi("`seed'") local numseed = 123456789 // STATA's default seed
	set seed `numseed'
	
	*error: 'section' is restricted to industrial classification
	if  "`section'"!="" & regexm("`classfrom'","isco")==1 {
		di as error "'Section' option is restricted to industrial classifications. Please check help file for more details.'"
		exit 198
	} 
	*
	
	*error: 'section' cannot be coded with numbers
	count if regexm(`origvar',"[0-9]")==1
	if  "`section'"!="" & `r(N)' >0 & "`classfrom'" != "isic_2"{
		di as error "The original variable of industrial/occupational classification does not correspond to a classification at the 'Section' level. Please check help file for more details.'"
		exit 198
	} 
	
// 2.1. Recode Classes
	if "`classfrom'" == "isic_2" local classfrom_rec "isic_rev2"
	if "`classfrom'" == "isic_3" local classfrom_rec "isic_rev3"
	if "`classfrom'" == "isic_3.1" local classfrom_rec "isic_rev31"
	if "`classfrom'" == "isic_4" local classfrom_rec "isic_rev4"
	if "`classfrom'" == "isco_1988" local classfrom_rec "isco_88"
	if "`classfrom'" == "isco_2008" local classfrom_rec "isco_08"
	
	if "`classto'" == "isic_2" local classto_rec "isic_rev2"
	if "`classto'" == "isic_3" local classto_rec "isic_rev3"
	if "`classto'" == "isic_3.1" local classto_rec "isic_rev31"
	if "`classto'" == "isic_4" local classto_rec "isic_rev4"
	if "`classto'" == "isco_1988" local classto_rec "isco_88"
	if "`classto'" == "isco_2008" local classto_rec "isco_08"
	
	
// 2.2. ASSIGNATION RULE 
qui {
# d ;
	 assignation_rule, 
		id(`id') 
		origvar(`origvar') 
		classfrom(`classfrom_rec') 
		classto(`classto_rec') 
		fullcorr(`fullcorr')
		seed(`numseed') 
		`section'
	;
# d cr
}


}
end

