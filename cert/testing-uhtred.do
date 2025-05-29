clear all
// clear all is enough to 'refresh' in the same session
// -uhtred-
cd "~/Stata-dev/uhtred"
adopath ++ "~/Stata-dev/uhtred"
clear all
adopath ++ "~/Stata-dev/uhtred/uhtred"
clear all
do ./build/buildmlib.do
mata mata clear
// -stdmest-
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
clear all
do ./build/buildmlib.do
mata mata clear

// ---
clear all
use catheter.dta
gen tv = .
replace tv = 0 if _n == 1
replace tv = 1 if _n == 2
replace tv = 2 if _n == 3
replace tv = 5 if _n == 4
replace tv = 8 if _n == 5
replace tv = 16 if _n == 6
replace tv = 38.5 if _n == 7
replace tv = 145 if _n == 8
replace tv = 245 if _n == 9
replace tv = 447 if _n == 10
replace tv = 562 if _n == 11
quietly mestreg c.age i.female || patient:, distribution(weibull)
estimates store m_mestreg
predict bm*, reffects reses(bmse*)
list bm1 bmse1 if _n == 1 
set seed 1993480
stdmest Sm, reat(.7613212) reatse(.6750813) reatref(0.0) reatrefse(0.0) timevar(tv)
list tv Sm* if tv != ., compress clean

// ---
quietly uhtred (_t c.age i.female M1[patient]@1, family(rp, df(1) failure(_d)))
estimates store m_uhtred
predict bu*, reffects
predict buse*, reses
list bu1 buse1 if _n == 1 | _n == 3 | _n == 5
set seed 1993480
stdmest Su1, reat(.7613212) reatse(.6750813) reatref(0.0) reatrefse(0.0) timevar(tv)
list tv Su1* if tv != ., compress clean
stdmest Su2, reat(.54066342) reatse(.80845159) reatref(0.0) reatrefse(0.0) timevar(tv)
list tv Su2* if tv != ., compress clean
stdmest Su3, reat(.29053827) reatse(.60712034) reatref(0.0) reatrefse(0.0) timevar(tv)
list tv Su3* if tv != ., compress clean

twoway ///
	(line Sm tv, sort) ///
	(line Su1 tv, sort) ///
	(line Su2 tv, sort)	///
	(line Su3 tv, sort)
