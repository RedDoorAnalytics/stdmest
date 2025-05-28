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
webuse catheter
gen tv = .
replace tv = 0 if _n == 1
replace tv = 1 if _n == 2
replace tv = 16 if _n == 3
replace tv = 38.5 if _n == 4
replace tv = 145 if _n == 5
replace tv = 562 if _n == 6
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
list bu1 buse1 if _n == 1
list bu1 buse1 if _n == 3
set seed 1993480
stdmest Su1, reat(.7613212) reatse(.6750813) reatref(0.0) reatrefse(0.0) timevar(tv)
list tv Su1* if tv != ., compress clean
stdmest Su2, reat(.54066342) reatse(.80845159) reatref(0.0) reatrefse(0.0) timevar(tv)
list tv Su2* if tv != ., compress clean
