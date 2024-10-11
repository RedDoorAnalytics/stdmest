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
mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)
range tv 0 365 100

//
stdmest S0a, reat(-.4603618 1.0) reatse(.1427249 0.1) reatref(0.0 0.0) reatseref(0.0 0.0) timevar(tv)
stdmest S0b, reat(-.4603618 1.0) reatse(.1427249 0.1) reatref(0.0 0.0) reatseref(0.0 0.0) timevar(tv) dots
stdmest S1a, reat(-.4603618 1.0) reatse(.1427249 0.1) reatref(0.0 0.0) reatseref(0.0 0.0) timevar(tv) verbose
stdmest S1b, reat(-.4603618 1.0) reatse(.1427249 0.1) reatref(0.0 0.0) reatseref(0.0 0.0) timevar(tv) verbose dots
stdmest S2a, reat(-.4603618 1.0) reatse(.1427249 0.1) reatref(0.0 0.0) reatseref(0.0 0.0) timevar(tv) contrast verbose
stdmest S2b, reat(-.4603618 1.0) reatse(.1427249 0.1) reatref(0.0 0.0) reatseref(0.0 0.0) timevar(tv) contrast verbose dots
stdmest S3a, reat(-.4603618 1.0) reatse(.1427249 0.1) reatref(0.0 0.0) reatseref(0.0 0.0) timevar(tv) contrast ci reps(200) verbose
stdmest S3b, reat(-.4603618 1.0) reatse(.1427249 0.1) reatref(0.0 0.0) reatseref(0.0 0.0) timevar(tv) contrast ci reps(200) verbose dots

//
stdmestm Sm0a, reat(-.4603618) reatse(.1427249) varmargname(birthyear>id) timevar(tv)
stdmestm Sm0b, reat(-.4603618) reatse(.1427249) varmargname(birthyear>id) timevar(tv) dots
stdmestm Sm1a, reat(-.4603618) reatse(.1427249) varmargname(birthyear>id) timevar(tv) verbose
stdmestm Sm1b, reat(-.4603618) reatse(.1427249) varmargname(birthyear>id) timevar(tv) verbose dots
stdmestm Sm2a, reat(-.4603618) reatse(.1427249) varmargname(birthyear>id) timevar(tv) contrast verbose
stdmestm Sm2b, reat(-.4603618) reatse(.1427249) varmargname(birthyear>id) timevar(tv) contrast verbose dots
stdmestm Sm3a, reat(-.4603618) reatse(.1427249) varmargname(birthyear>id) timevar(tv) contrast ci reps(200) verbose
stdmestm Sm3b, reat(-.4603618) reatse(.1427249) varmargname(birthyear>id) timevar(tv) contrast ci reps(200) verbose dots
