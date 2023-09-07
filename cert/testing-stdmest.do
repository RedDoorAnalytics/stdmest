clear all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
clear all

// Two-levels model:

clear all
webuse catheter
mestreg age female || patient:, distribution(wei)
stdmest aaa
predict sss, surv cond(fixedonly)
gen diff = aaa - sss
summ diff

// predict b, reffects
// mestreg age female || patient:, distribution(weibull) time
// stdmest
// mestreg age female || patient:, distribution(exponential) 
// stdmest
// mestreg age female || patient:, distribution(lognormal) 
// stdmest

// Three-levels model:
clear all
webuse jobhistory
gen t = tend - tstart
stset t, fail(failure)
mestreg education njobs prestige i.female || birthyear: || id:, distribution(weibull)
stdmest
