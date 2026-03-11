//
set linesize 255
clear all
// clear all is enough to 'refresh' in the same session
// -stdmest-
local drive = "~/Stata-dev"
cd "`drive'/stdmest"
adopath ++ "stdmest"
clear all
do ./build/buildmlib.do
mata mata clear

// ---
clear all
webuse jobhistory
gen tt = tend - tstart
stset tt, fail(failure)

// ---
capture drop tv
range tv 0 365 10

// ---
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(weibull) nohr
stdmest Sm, reat(-.0921738 -2.028026) reatse(.2263078 .5722969) reatref(0.0 0.0) reatrefse(0.0 0.0) timevar(tv) contrast

// ---
quietly uhtred (_t education njobs prestige i.female M1[birthyear]@1 M2[birthyear>id]@1, family(rp, df(1) failure(_d)))
stdmest Su, reat(-.0921738 -2.028026) reatse(.2263078 .5722969) reatref(0.0 0.0) reatrefse(0.0 0.0) timevar(tv) contrast

// ---
assert reldif(Sm, Su) <= 1e-3
assert reldif(Sm_ref, Su_ref) <= 1e-3
assert reldif(Sm_diff, Su_diff) <= 1e-3
