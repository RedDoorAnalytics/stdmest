clear all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmestm"
clear all
// set trace on

// helpfile
// help stdmestm

webuse jobhistory
gen tt = tend - tstart
stset tt, fail(failure)
mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)
range tv 0 365 200
stdmestm S, varmargname(birthyear>id) timevar(tv)

twoway (line S tv, sort)
