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
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)

stdmestm S, varmargname(/:var(_cons[birthyear>id]))
