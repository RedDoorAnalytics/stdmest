//
set linesize 255
clear all
// clear all is enough to 'refresh' in the same session
// -stdmest-
local drive = "~/Stata-dev"
cd "`drive'/stdmest"
adopath ++ "stdmest"
clear all
do ./build/buildmlib.do
mata mata clear

// seed, for reproducibility
set seed 347856

// data3CIA
clear all
use "data/data3CIA", clear

// round timevar (to speed up computations)
replace months = round(months)

// stset
stset months, failure(status == 1)

// mestreg Weibull model adjusting for age, FEV1, and dyspnea score
mestreg c.age c.fev1pp ib0.mmrc || cohort: , dist(wei) nohr

// predict random effect
predict b, reffects reses(bse)
sort b
list b bse if _n == 1 | _n == _N
//       +---------------------+
//       |        b        bse |
//       |---------------------|
//    1. | -1.00562   .2222489 |
// 8697. | .9954252   .1405902 |
//       +---------------------+

// without timevar
capture drop Smin*
capture drop Smin2*
timer on 1
stdmest Smin, reat(-1.00562) reatse(.2222489) reatref(0.0) reatrefse(0.0) contrast verbose ci cinormal
stdmest Smin2 if cohort == 18, reat(-1.00562) reatse(.2222489) reatref(0.0) reatrefse(0.0) contrast verbose ci cinormal
timer off 1
timer list 1

// list Smin Smin_ref Smin_diff if tt != .
twoway ///
	(rarea Smin2_diff_lci Smin2_diff_uci _t, sort color(red%10)) ///
	(rarea Smin_diff_lci Smin_diff_uci _t, sort color(blue%10)) ///
	(line Smin2_diff _t, sort lcolor(red)) ///
	(line Smin_diff _t, sort lcolor(blue)) ///
	, name("no_timevar", replace)

// with timevar
range tt 0 261 20

//
capture drop Smintt*
capture drop Smintt2*
timer on 1
stdmest Smintt, reat(-1.00562) reatse(.2222489) reatref(0.0) reatrefse(0.0) timevar(tt) contrast verbose ci cinormal
stdmest Smintt2 if cohort == 18, reat(-1.00562) reatse(.2222489) reatref(0.0) reatrefse(0.0) timevar(tt) contrast verbose ci cinormal
timer off 1
timer list 1

list Smintt Smintt2 if tt != .
list Smin Smin_ref Smin_diff if tt != .
twoway ///
	(rarea Smintt2_diff_lci Smintt2_diff_uci tt, sort color(red%10)) ///
	(rarea Smintt_diff_lci Smintt_diff_uci tt, sort color(blue%10)) ///
	(line Smintt2_diff tt, sort lcolor(red)) ///
	(line Smintt_diff tt, sort lcolor(blue)) ///
	, name("with_timevar", replace)

//
quietly {
	clear all
	cd "~/Stata-dev/stdmest"
	adopath ++ "stdmest"
	clear all
	use "data/data3CIA", clear
	stset months, failure(status == 1)
	mestreg c.age c.fev1pp ib0.mmrc || cohort: , dist(wei) nohr
	range tt 0 200 5
	stdmest Smin, reat(-1.00562) reatse(.2222489) reatref(0.0) reatrefse(0.0) ci timevar(tt)
	stdmest Smin2 if cohort == 18, reat(-1.00562) reatse(.2222489) reatref(0.0) reatrefse(0.0) ci timevar(tt)
}
list tt Smin Smin_lci Smin_uci Smin2 Smin2_lci Smin2_uci if tt != .
