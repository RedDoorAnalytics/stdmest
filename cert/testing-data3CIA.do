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

// timevar
range tt 0 200 5

// 
timer on 1
stdmest Smin, reat(-1.006262) reatse(.2222539) timevar(tt) contrast dots ci reps(10)
stdmest Smin2 if cohort == 18, reat(-1.006262) reatse(.2222539) timevar(tt) contrast dots ci reps(10)
timer off 1
timer list 1

list Smin Smin2 if tt != .

// list Smin Smin_ref Smin_contrast if tt != .
twoway ///
	(rarea Smin2_contrast_lower Smin2_contrast_upper tt, sort color(red%10)) ///
	(rarea Smin_contrast_lower Smin_contrast_upper tt, sort color(blue%10)) ///
	(line Smin2_contrast tt, sort lcolor(red)) ///
	(line Smin_contrast tt, sort lcolor(blue))
