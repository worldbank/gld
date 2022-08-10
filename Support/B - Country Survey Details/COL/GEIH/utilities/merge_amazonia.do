
clear all

local year 2017

local path_original "Z:\GLD-Harmonization\xxx\COL\COL_`year'_GEIH\COL_`year'_GEIH_v01_M\Data\Stata\amazonia"

local path_stata "Z:\GLD-Harmonization\xxxx\COL\COL_`year'_GEIH\COL_`year'_GEIH_v01_M\Data\Stata\amazonia"

local folder "`path_original'"
	
	*** Individual files for all year
	*1
	use "`folder'/Caracteristicas generales (Personas).dta", clear
	rename _all, lower
	egen id = concat(directorio secuencia_p )
	egen idi = concat(directorio secuencia_p orden)
	tempfile c_`year'_1
	save `c_`year'_1'
	

	*2
	use "`folder'/Desocupados.dta", clear
	rename _all, lower
	egen id = concat(directorio secuencia_p )
	egen idi = concat(directorio secuencia_p orden)
	tempfile c_`year'_2
	save `c_`year'_2'

	
	*3
	use  "`folder'/Fuerza de trabajo.dta", clear
	rename _all, lower
	egen id = concat(directorio secuencia_p )
	egen idi = concat(directorio secuencia_p orden)
	tempfile c_`year'_3
	save `c_`year'_3'
	
	*4
	use "`folder'/Inactivos.dta", clear
	rename _all, lower
	egen id = concat(directorio secuencia_p)
	egen idi = concat(directorio secuencia_p orden)
	tempfile c_`year'_4
	save `c_`year'_4'
	
	*5
	use  "`folder'/Ocupados.dta", clear
	rename _all, lower
	egen id = concat(directorio secuencia_p )
	egen idi = concat(directorio secuencia_p orden)
	tempfile c_`year'_5
	save `c_`year'_5'
	
	*6
	use "`folder'/Otras actividades y ayudas en la semana.dta", clear
	rename _all, lower
	egen id = concat(directorio secuencia_p )
	egen idi = concat(directorio secuencia_p orden)
	tempfile c_`year'_6
	save `c_`year'_6'
	
	*7
	use "`folder'/Otros ingresos.dta", clear
	rename _all, lower
	egen id = concat(directorio secuencia_p )
	egen idi = concat(directorio secuencia_p orden)
	tempfile c_`year'_7
	save `c_`year'_7'
	
	*8
	use "`folder'/Vivienda y Hogares.dta", clear
	rename _all, lower
	egen id = concat(directorio secuencia_p )
	tempfile c_`year'_8
	save `c_`year'_8'
	
	
	* Merge indiv
	* Read in first
	use `c_`year'_1', clear
	* Loop over other individual level files
	forvalues j=2/7{
	   merge 1:1 idi using `c_`year'_`j'', nogen force
	}
	* Merge HH level info
	merge m:1 id using `c_`year'_8', nogen force
	
	save "`path_stata'\amazonia_2017.dta", replace

