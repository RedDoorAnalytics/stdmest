clear all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
adopath ++ "stdmestm"
clear all
do ./build/buildmlib.do
mata mata clear

set seed 34587

webuse jobhistory
gen tt = tend - tstart
stset tt, fail(failure)
mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)
range tv 0 365 100

//
stdmest S, reat(-.4603618 1.0) reatse(.1427249 0.1) reatref(0.0 0.0) reatseref(0.0 0.0) timevar(tv) contrast ci reps(100) verbose

//
stdmestm Sm, reat(-.4603618) reatse(.1427249) varmargname(birthyear>id) timevar(tv) contrast ci reps(100) verbose

