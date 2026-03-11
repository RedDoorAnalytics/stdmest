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
mestreg education njobs prestige i.female || birthyear: || id:, distribution(weibull) nohr
predict bm*, reffects reses(bmse*)

// ---
capture drop tv
range tv 0 365 10

// ---
capture drop Sm*
set seed 37246
stdmest Sm, reat(-.0921738 -2.028026) reatse(.2263078 .5722969) timevar(tv) ci reps(2000)
list tv Sm* if tv != .

// ---
uhtred (_t education njobs prestige i.female M1[birthyear]@1 M2[birthyear>id]@1, family(rp, df(1) failure(_d)))
predict bu*, reffects
predict buse*, reses
capture drop Su*
set seed 37246
stdmest Su, reat(-.0921738 -2.028026) reatse(.2263078 .5722969) timevar(tv) ci reps(2000)
list tv Su* Sm* if tv != .
