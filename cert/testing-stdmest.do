clear all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
clear all
// set trace on

// helpfile
// help stdmest

// Two-levels model:
clear all
webuse jobhistory
gen gent = tend - tstart
stset gent, fail(failure)
mestreg education njobs prestige i.female || id:, distribution(weibull)
// ereturn list

capture drop aaa* 
capture drop aaa2*
local B = 1000
stdmest aaa, reps(`B') dots cinormal
stdmest aaa2, reps(`B') dots

twoway ///
	(line aaa _t, sort lcolor(stblue)) ///
	(line aaa2 _t, sort lcolor(stred))

twoway ///
	(rarea aaa_lower aaa_upper _t, sort color(stblue%10)) ///
	(rarea aaa2_lower aaa2_upper _t, sort color(stred%10)) ///
	(line aaa _t, sort lcolor(stblue)) ///
	(line aaa2 _t, sort lcolor(stred)) ///
	, legend(order(3 "Normal CIs" 4 "Percentile CI"))  name("Ssurv", replace)

// Actual test
predict b, reffects reses(bse)
range tt 0 365 100
summ b

stdmest S_min, reat(-2.152631) reatse(.5868556) timevar(tt) contrast ci cinormal reps(`B') dots
stdmest S_zero, reat(0) reatse(0) timevar(tt) contrast ci cinormal reps(`B') dots
stdmest S_max, reat(2.49625) reatse(.4376849) timevar(tt) contrast ci cinormal reps(`B') dots

twoway ///
	(rarea S_min_contrast_lower S_min_contrast_upper tt, sort color(stblue%10)) ///
	(rarea S_zero_contrast_lower S_zero_contrast_upper tt, sort color(stred%10)) ///
	(rarea S_max_contrast_lower S_max_contrast_upper tt, sort color(stgreen%10)) ///
	(line S_min_contrast tt, sort lcolor(stblue)) ///
	(line S_zero_contrast tt, sort lcolor(stred)) ///
	(line S_max_contrast tt, sort lcolor(stgreen)) ///
	, legend(order(4 "Min b" 5 "Zero b" 6 "Max b")) name("Scontrast", replace)

stdmest S_min_q, reat(-2.152631) reatse(.5868556) timevar(tt) contrast ci reps(`B') dots
stdmest S_zero_q, reat(0) reatse(0) timevar(tt) contrast ci reps(`B') dots
stdmest S_max_q, reat(2.49625) reatse(.4376849) timevar(tt) contrast ci reps(`B') dots

twoway ///
	(rarea S_min_q_contrast_lower S_min_q_contrast_upper tt, sort color(stblue%10)) ///
	(rarea S_zero_q_contrast_lower S_zero_q_contrast_upper tt, sort color(stred%10)) ///
	(rarea S_max_q_contrast_lower S_max_q_contrast_upper tt, sort color(stgreen%10)) ///
	(line S_min_q_contrast tt, sort lcolor(stblue)) ///
	(line S_zero_q_contrast tt, sort lcolor(stred)) ///
	(line S_max_q_contrast tt, sort lcolor(stgreen)) ///
	, legend(order(4 "Min b" 5 "Zero b" 6 "Max b"))  name("Scontrast_q", replace)
