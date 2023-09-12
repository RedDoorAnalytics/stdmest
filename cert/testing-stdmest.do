clear all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
clear all

// Two-levels model:

clear all
webuse catheter
mestreg age female || patient:, distribution(exp)
predict b, reffects
range tt 0 365 100

summ b

stdmest S_min, reat(-2.098768) timevar(tt)
stdmest S_zero, reat(0) timevar(tt)
stdmest S_max, reat(1.098787) timevar(tt)

twoway ///
	(line S_min tt, sort) ///
	(line S_zero tt, sort) ///
	(line S_max tt, sort) ///
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
