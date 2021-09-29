* illustration mvpatterns for STB

use \stata7\auto, clear
set seed 12345
sort make price
foreach v of varlist price-foreign {
	replace `v' = . if uniform() < 0.10
}

mvpatterns 

mvpatterns , skip sort minfreq(2)

