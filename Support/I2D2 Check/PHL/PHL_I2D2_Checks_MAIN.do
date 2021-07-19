/* ------- -------- ------ ------- --------- ------ ------ ------ ---- --- --- --- --- -- -- --- -- -- --
name: PHL_I2D2_Checks_MAIN.do
description: calls all PHL I2D2 scripts for I2D2+GLD

-- -- -- --- ---- ---- ---- ---- ------- -------- --------- --------- ------------- ---------------------*/



* Run settings
* 	Set to 1 to run, 0 otherwise
* ---------------------


forvalues year = 1997/2019 {
    do 	`"${clone}/gld/Support/I2D2 Check/PHL/PHL_`year'_I2D2_Check.do"'
}
