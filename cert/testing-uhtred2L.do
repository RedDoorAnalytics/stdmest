//
set linesize 255
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
// use catheter.dta
webuse catheter
range tv 0 562 50
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

// ---
quietly uhtred (_t c.age i.female M1[patient]@1, family(rp, df(5) failure(_d)))
estimates store m_uhtred_rp5
predict br*, reffects
predict brse*, reses
list br1 brse1 if _n == 1 | _n == 3 | _n == 5
set seed 1993480
stdmest Sr1, reat(.73230028) reatse(.65218048) reatref(0.0) reatrefse(0.0) timevar(tv)
list tv Sr1* if tv != ., compress clean
stdmest Sr2, reat(.4095118) reatse(.72854335) reatref(0.0) reatrefse(0.0) timevar(tv)
list tv Sr2* if tv != ., compress clean
stdmest Sr3, reat(.13558991) reatse(.55946738) reatref(0.0) reatrefse(0.0) timevar(tv)
list tv Sr3* if tv != ., compress clean

// ---
twoway ///
	(line Sm tv, sort lcolor(black)) ///
	(line Su1 tv, sort lcolor(stred) lpattern(solid)) ///
	(line Su2 tv, sort lcolor(stblue) lpattern(solid))	///
	(line Su3 tv, sort lcolor(stgreen) lpattern(solid)) ///
	(line Sr1 tv, sort lcolor(stred) lpattern(dash)) ///
	(line Sr2 tv, sort lcolor(stblue) lpattern(dash))	///
	(line Sr3 tv, sort lcolor(stgreen) lpattern(dash)) ///
	, legend(order(1 "mestreg Weibull" 2 "uhtred Weibull ID=1" 3 "uhtred Weibull ID=3" 4 "uhtred Weibull ID=4" 5 "uhtred RP(5) ID=1" 6 "uhtred RP(5) ID=3" 7 "uhtred RP(7) ID=4" ))

// ---
list tv Sm* Su1* Su2* Su3* Sr1* Sr2* Sr3* if tv != ., compress clean
