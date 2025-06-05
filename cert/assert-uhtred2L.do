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
range tv 0 562 100

// -mestreg- model:
quietly mestreg c.age i.female || patient:, distribution(weibull)
stdmest Sm, reat(.7613212) reatse(.6750813) reatref(0.0) reatrefse(0.0) timevar(tv) contrast

// -uhtred- model:
quietly uhtred (_t c.age i.female M1[patient]@1, family(rp, df(1) failure(_d)))
stdmest Su, reat(.7613212) reatse(.6750813) reatref(0.0) reatrefse(0.0) timevar(tv) contrast

// ---
assert reldif(Sm, Su) <= 1e-6
assert reldif(Sm_ref, Su_ref) <= 1e-6
assert reldif(Sm_contrast, Su_contrast) <= 1e-6
