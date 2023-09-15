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
// ereturn list

capture drop aaa* 
capture drop aaa2*
capture drop aaa3*
local B = 200
stdmest aaa, ci reps(`B') dots
stdmest aaa2, ci reps(`B') dots cipercentile

twoway ///
	(rarea aaa_lower aaa_upper _t, sort color(stblue%10)) ///
	(rarea aaa2_lower aaa2_upper _t, sort color(stred%10)) ///
	(line aaa _t, sort lcolor(stblue)) ///
	(line aaa2 _t, sort lcolor(stred)) ///
	, legend(order(3 "Normal CIs" 4 "Percentile CI"))


// Actual test
predict b, reffects reses(bse)
range tt 0 365 50
summ b

stdmest S_min, reat(-2.098768) reatse(.4285454) timevar(tt) contrast ci cipercentile reps(1000) dots
stdmest S_zero, reat(0) reatse(0) timevar(tt) contrast ci cipercentile reps(1000) dots
stdmest S_max, reat(1.098787) reatse(.7398818) timevar(tt) contrast ci cipercentile reps(1000) dots

twoway ///
	(rarea S_min_contrast_lower S_min_contrast_upper tt, sort color(stblue%10)) ///
	(rarea S_zero_contrast_lower S_zero_contrast_upper tt, sort color(stred%10)) ///
	(rarea S_max_contrast_lower S_max_contrast_upper tt, sort color(stgreen%10)) ///
	(line S_min_contrast tt, sort lcolor(stblue)) ///
	(line S_zero_contrast tt, sort lcolor(stred)) ///
	(line S_max_contrast tt, sort lcolor(stgreen)) ///
	, legend(order(4 "Min b" 5 "Zero b" 6 "Max b"))

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
