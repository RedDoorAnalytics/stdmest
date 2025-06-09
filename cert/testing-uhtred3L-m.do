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
adopath ++ "stdmestm"
clear all
do ./build/buildmlib.do
mata mata clear

// ---
clear all
webuse jobhistory
gen tt = tend - tstart
stset tt, fail(failure)
capture drop tv
range tv 0 365 20

// ---
mestreg education njobs prestige i.female || birthyear: || id:, distribution(weibull) nohr
stdmestm Sm, reat(-.4603618) reatse(.1427249) varmarg(.8728384) timevar(tv) nk(15)
// predict bm*, reffects reses(bmse*)

// ---
// capture drop Sm*
// set seed 37246
// stdmest Sm, reat(-.0921738 -2.028026) reatse(.2263078 .5722969) timevar(tv) ci reps(2000)
// list tv Sm* if tv != .

// ---
uhtred (_t education njobs prestige i.female M1[birthyear]@1 M2[birthyear>id]@1, family(rp, df(1) failure(_d)))
stdmestm Su, reat(-.4603618) reatse(.1427249) varmarg(`=.9314487^2') timevar(tv) nk(15)

// ---
list tv Sm Su if tv != .
