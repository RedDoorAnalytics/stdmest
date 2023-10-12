clear all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
clear all

// data3CIA 
clear all
use "data/data3CIA", clear

// stset
stset months, failure(status == 1)

// mestreg Weibull model adjusting for age, FEV1, and dyspnea score
mestreg c.age c.fev1pp ib0.mmrc || cohort: , dist(wei) nohr

// predict random effect
predict b, reffects reses(bse)
sort b
list b bse if _n == 1 | _n == _N
//       +----------------------+
//       |         b        bse |
//       |----------------------|
//    1. | -1.006262   .2222539 |
// 8697. |   .995125   .1405887 |
//       +----------------------+

// seed
set seed 348756389

// without timevar
capture drop Smin*
capture drop Smin2*
timer on 1
stdmest Smin, reat(-1.006262) reatse(.2222539) contrast dots ci reps(20)
stdmest Smin2 if cohort == 18, reat(-1.006262) reatse(.2222539) contrast dots ci reps(20)
timer off 1
timer list 1

// list Smin Smin_ref Smin_contrast if tt != .
twoway ///
	(rarea Smin2_contrast_lower Smin2_contrast_upper _t, sort color(red%10)) ///
	(rarea Smin_contrast_lower Smin_contrast_upper _t, sort color(blue%10)) ///
	(line Smin2_contrast _t, sort lcolor(red)) ///
	(line Smin_contrast _t, sort lcolor(blue)) ///
	, name("no_timevar", replace)

// with timevar
range tt 0 200 10

// 
capture drop Smintt*
capture drop Smintt2*
timer on 1
stdmest Smintt, reat(-1.006262) reatse(.2222539) timevar(tt) contrast dots ci reps(20)
stdmest Smintt2 if cohort == 18, reat(-1.006262) reatse(.2222539) timevar(tt) contrast dots ci reps(20)
timer off 1
timer list 1

list Smintt Smintt2 if tt != .

// list Smin Smin_ref Smin_contrast if tt != .
twoway ///
	(rarea Smintt2_contrast_lower Smintt2_contrast_upper tt, sort color(red%10)) ///
	(rarea Smintt_contrast_lower Smintt_contrast_upper tt, sort color(blue%10)) ///
	(line Smintt2_contrast tt, sort lcolor(red)) ///
	(line Smintt_contrast tt, sort lcolor(blue)) ///
	, name("with_timevar", replace)
