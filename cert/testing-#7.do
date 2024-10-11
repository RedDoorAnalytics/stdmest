clear all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
adopath ++ "stdmestm"
clear all
do ./build/buildmlib.do
mata mata clear

// seed, for reproducibility
set seed 347856

// data
webuse jobhistory
gen tt = tend - tstart
stset tt, fail(failure)

// model
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)
predict b*, reffects reses(bse*)
sort b1 b2
list b1 bse1 b2 bse2 if _n == 1 | _n == _N

// error
capture noisily stdmest Stst, reat(-.4603618  -1.05416) reatse(.1427249 .5097189) ci reps(100) timevar(tt) contrast

// okay
capture noisily stdmest Stst, reat(-.4603618  -1.05416) reatse(.1427249 .5097189) ci reps(100) timevar(tt) contrast ///
	reatref(0.0 0.0) reatseref(0.0 0.0)
