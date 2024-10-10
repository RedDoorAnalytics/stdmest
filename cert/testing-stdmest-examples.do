clear all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
clear all
do ./build/buildmlib.do
mata mata clear

//
help stdmest

// Two-levels example
clear
webuse catheter
mestreg age female || patient:, distribution(weibull)

predict b, reffects reses(bse)

stdmest S1, reat(0.0) reatse(0.0)
twoway line S1 _t, sort

stdmest S2, reat(0.0) reatse(0.0) ci
twoway (rarea S2_lower S2_upper _t, sort color(stblue%10)) (line S2 _t, sort lcolor(stblue))

stdmest S3, reat(0.0) reatse(0.0) ci cinormal
twoway (rarea S3_lower S3_upper _t, sort color(stgreen%10)) (line S3 _t, sort lcolor(stgreen))

range tt 0 100 5
stdmest S4, reat(0.0) reatse(0.0) ci timevar(tt) reps(1000) verbose
list tt S4* if tt != .

stdmest S4b, reat(0.0) reatse(0.0) ci timevar(tt) reps(1000) verbose dots

sort b
list b bse if _n == 1
stdmest S5, ci timevar(tt) reps(1000) verbose contrast reat(-2.098768) reatse(.4285454) reatref(0.0) reatseref(0.0)
sort tt
list tt S5* if tt != .

// Three-levels example
clear
webuse jobhistory
gen tt = tend - tstart
stset tt, fail(failure)
mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)

predict b*, reffects reses(bse*)
list b1 bse1 b2 bse2 if _n <= 2

stdmest S1, reat(-.0795512 -1.39209) reatse(.1930458 .4813395) ci
stdmest S2, reat(-.0795512 -.1309338) reatse(.1930458 .4605677) ci

//
twoway ///
	(rarea S1_lower S1_upper _t, sort color(stblue%10)) ///
	(rarea S2_lower S2_upper _t, sort color(stred%10)) ///
	(line S1 _t, sort lcolor(stblue)) ///
	(line S2 _t, sort lcolor(stred))

//
stdmest S3, reat(-.0795512 -1.39209) reatse(.1930458 .4813395) reatref(-.0795512 -.1309338) reatseref(.1930458 .4605677) ci contrast
twoway (rarea S3_contrast_lower S3_contrast_upper _t, sort color(stgreen%10)) (line S3_contrast _t, sort lcolor(stgreen))
