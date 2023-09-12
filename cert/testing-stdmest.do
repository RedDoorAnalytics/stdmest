clear all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
clear all
// set trace on

// Two-levels model:

clear all
webuse catheter
mestreg age i.female || patient:, distribution(weibull)
ereturn list

capture drop aaa
stdmest aaa, ci dots
// stdmest aaa2, contrast

predict b, reffects reses(bse)
range tt 0 365 100

summ b

stdmest S_min, reat(-2.098768) reatse(.4285454) timevar(tt) contrast
stdmest S_zero, reat(0) reatse(0) timevar(tt) contrast
stdmest S_max, reat(1.098787) reatse(.7398818) timevar(tt) contrast

twoway ///
	(line S_min_contrast tt, sort) ///
	(line S_zero_contrast tt, sort) ///
	(line S_max_contrast tt, sort) ///
	, legend(order(1 "Min b" 2 "Zero b" 3 "Max b"))

// predict b, reffects
// mestreg age female || patient:, distribution(weibull) time
// stdmest
// mestreg age female || patient:, distribution(exponential) 
// stdmest
// mestreg age female || patient:, distribution(lognormal) 
// stdmest

// // Three-levels model:
// clear all
// webuse jobhistory
// gen t = tend - tstart
// stset t, fail(failure)
// mestreg education njobs prestige i.female || birthyear: || id:, distribution(weibull)
// stdmest
