cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
clear all

// Two-levels model:
clear all
webuse catheter
mestreg age female || patient:, distribution(weibull)

// Three-levels model:
clear all
webuse jobhistory
gen t = tend - tstart
stset t, fail(failure)
mestreg education njobs prestige i.female || birthyear: || id:, distribution(weibull)
