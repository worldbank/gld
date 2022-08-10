


clear all

local year 2017

local path_original "Z:\GLD-Harmonization\xxx\COL\COL_`year'_GEIH\COL_`year'_GEIH_v01_M\Data\Original"
local path_stata "Z:\GLD-Harmonization\xxx\COL\COL_`year'_GEIH\COL_`year'_GEIH_v01_M\Data\Stata"

forvalues i = 1/8 {
	
	local folder "`path_original'/`i'"
	
	*** Cabecera
	* - 1
	import spss using "`folder'/Cabecera - Caracteristicas generales (Personas).sav", clear
	rename _all, lower
	
	egen id = concat(directorio secuencia_p)
	egen idi = concat(directorio secuencia_p orden)
	tempfile c_`year'_1_`i'
	save `c_`year'_1_`i''
	
	* - 2
	import spss using "`folder'/Cabecera - Desocupados.sav", clear
	rename _all, lower
	
	egen id = concat(directorio secuencia_p)
	egen idi = concat(directorio secuencia_p orden)
	tempfile c_`year'_2_`i'
	save `c_`year'_2_`i''
	
	* - 3
	import spss using "`folder'/Cabecera - Fuerza de trabajo.sav", clear
	rename _all, lower
	
	egen id = concat(directorio secuencia_p)
	egen idi = concat(directorio secuencia_p orden)
	tempfile c_`year'_3_`i'
	save `c_`year'_3_`i''
	
	* - 4
	import spss using "`folder'/Cabecera - Inactivos.sav", clear
	rename _all, lower
	
	egen id = concat(directorio secuencia_p mes)
	egen idi = concat(directorio secuencia_p orden)
	tempfile c_`year'_4_`i'
	save `c_`year'_4_`i''
	
	* - 5
	import spss using "`folder'/Cabecera - Ocupados.sav", clear
	rename _all, lower
	
	egen id = concat(directorio secuencia_p)
	egen idi = concat(directorio secuencia_p orden)
	tempfile c_`year'_5_`i'
	save `c_`year'_5_`i''
	
	* - 6
	import spss using "`folder'/Cabecera - Otras actividades y ayudas en la semana.sav", clear
	rename _all, lower
	
	egen id = concat(directorio secuencia_p)
	egen idi = concat(directorio secuencia_p orden)
	tempfile c_`year'_6_`i'
	save `c_`year'_6_`i''
	
	* - 7
	import spss using "`folder'/Cabecera - Otros ingresos.sav", clear
	rename _all, lower
	
	egen id = concat(directorio secuencia_p)
	egen idi = concat(directorio secuencia_p orden)
	tempfile c_`year'_7_`i'
	save `c_`year'_7_`i''
	
	* - 8
	import spss using "`folder'/Cabecera - Vivienda y Hogares.sav", clear
	rename _all, lower
	
	egen id = concat(directorio secuencia_p)
	tempfile c_`year'_8_`i'
	save `c_`year'_8_`i''
	
	* Merge cabeceras
	* Read in first
	use `c_`year'_1_`i'', clear
	* Loop over other individual level files
	forvalues j=2/7{
	    merge 1:1 idi using `c_`year'_`j'_`i'', assert(match master) nogen force
	}
	* Merge HH level info
	merge m:1 id using `c_`year'_8_`i'', assert(match) force
	
	* Save as tempfile
	tempfile c_`year'_`i'
	save `c_`year'_`i''
	
	
	*** Resto
	* - 1
	import spss using "`folder'/Resto - Caracteristicas generales (Personas).sav", clear
	rename _all, lower
	
	egen id = concat(directorio secuencia_p)
	egen idi = concat(directorio secuencia_p orden)
	tempfile r_`year'_1_`i'
	save `r_`year'_1_`i''
	
	* - 2
	import spss using "`folder'/Resto - Desocupados.sav", clear
	rename _all, lower
	
	egen id = concat(directorio secuencia_p)
	egen idi = concat(directorio secuencia_p orden)
	tempfile r_`year'_2_`i'
	save `r_`year'_2_`i''
	
	* - 3
	import spss using "`folder'/Resto - Fuerza de trabajo.sav", clear
	rename _all, lower
	
	egen id = concat(directorio secuencia_p)
	egen idi = concat(directorio secuencia_p orden)
	tempfile r_`year'_3_`i'
	save `r_`year'_3_`i''
	
	* - 4
	import spss using "`folder'/Resto - Inactivos.sav", clear
	rename _all, lower
	
	egen id = concat(directorio secuencia_p)
	egen idi = concat(directorio secuencia_p orden)
	tempfile r_`year'_4_`i'
	save `r_`year'_4_`i''
	
	* - 5
	import spss using "`folder'/Resto - Ocupados.sav", clear
	rename _all, lower
	
	egen id = concat(directorio secuencia_p)
	egen idi = concat(directorio secuencia_p orden)
	tempfile r_`year'_5_`i'
	save `r_`year'_5_`i''
	
	* - 6
	import spss using "`folder'/Resto - Otras actividades y ayudas en la semana.sav", clear
	rename _all, lower
	
	egen id = concat(directorio secuencia_p)
	egen idi = concat(directorio secuencia_p orden)
	tempfile r_`year'_6_`i'
	save `r_`year'_6_`i''
	
	* - 7
	import spss using "`folder'/Resto - Otros ingresos.sav", clear
	rename _all, lower
	
	egen id = concat(directorio secuencia_p)
	egen idi = concat(directorio secuencia_p orden)
	tempfile r_`year'_7_`i'
	save `r_`year'_7_`i''
	
	* - 8
	import spss using "`folder'/Resto - Vivienda y Hogares.sav", clear
	rename _all, lower
	
	egen id = concat(directorio secuencia_p)
	tempfile r_`year'_8_`i'
	save `r_`year'_8_`i''
	
	* Merge Restos
	* Read in first
	use `r_`year'_1_`i'', clear
	* Loop over other individual level files
	forvalues j=2/7{
	    merge 1:1 idi using `r_`year'_`j'_`i'', assert(match master) nogen force
	}
	* Merge HH level info
	merge m:1 id using `r_`year'_8_`i'', assert(match) force

	* Save as tempfile
	tempfile r_`year'_`i'
	save `r_`year'_`i''
	
	
	*** Append both, save out
	use `c_`year'_`i'', clear
	append using `r_`year'_`i''
	compress
	save "`path_stata'/GEIH_`year'_`i'.dta", replace
	
}
