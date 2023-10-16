clear all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
clear all
// set trace on

// helpfile
help stdmest

// Two-levels model:
clear all
webuse catheter
mestreg age female || patient:, distribution(weibull)

capture drop aaa* 
capture drop aaa2*
local B = 1000
stdmest aaa, reps(`B') dots ci cinormal
stdmest aaa2, reps(`B') dots ci

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

// Help file examples:	
clear
webuse catheter
mestreg age female || patient:, distribution(weibull)
predict b, reffects reses(bse)

stdmest S1
twoway line S1 _t, sort

stdmest S2, ci
twoway ///
	(rarea S2_lower S2_upper _t, sort color(stblue%10)) ///
	(line S2 _t, sort lcolor(stblue))

stdmest S3, ci cinormal
twoway ///
	(rarea S3_lower S3_upper _t, sort color(stblue%10)) ///
	(line S3 _t, sort lcolor(stblue))
twoway ///
	(rarea S2_lower S2_upper _t, sort color(stblue%10)) ///
	(rarea S3_lower S3_upper _t, sort color(stgreen%10)) ///
	(line S2 _t, sort lcolor(stblue)) ///
	(line S3 _t, sort lcolor(stgreen))

range tt 0 100 5
stdmest S4, ci timevar(tt) reps(1000) dots
list tt S4* if tt != .

sort b
list b bse if _n == 1
stdmest S5, ci timevar(tt) reps(1000) dots contrast reat(-2.098768) reatse(.4285454)
sort tt
list tt S5* if tt != .
twoway ///
	(rarea S5_contrast_lower S5_contrast_upper tt, sort color(stred%10)) ///
	(line S5_contrast tt, sort lcolor(stred))



