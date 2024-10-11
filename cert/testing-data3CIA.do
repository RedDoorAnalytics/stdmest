clear all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
clear all
do ./build/buildmlib.do
mata mata clear

// seed, for reproducibility
set seed 347856

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

// without timevar
capture drop Smin*
capture drop Smin2*
timer on 1
stdmest Smin, reat(-1.006262) reatse(.2222539) reatref(0.0) reatseref(0.0) contrast verbose ci reps(100) cinormal
stdmest Smin2 if cohort == 18, reat(-1.006262) reatse(.2222539) reatref(0.0) reatseref(0.0) contrast verbose ci reps(100) cinormal
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
range tt 0 260.88 20

//
capture drop Smintt*
capture drop Smintt2*
timer on 1
stdmest Smintt, reat(-1.006262) reatse(.2222539) reatref(0.0) reatseref(0.0) timevar(tt) contrast verbose ci reps(100) cinormal
stdmest Smintt2 if cohort == 18, reat(-1.006262) reatse(.2222539) reatref(0.0) reatseref(0.0) timevar(tt) contrast verbose ci reps(100) cinormal
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

// Comparison with results from R:
// #    tt      Smin Smin_lower Smin_upper     Smin2 Smin2_lower Smin2_upper
// # 1   0 1.0000000  1.0000000  1.0000000 1.0000000   1.0000000   1.0000000
// # 2  50 0.9319127  0.8929531  0.9571315 0.9245237   0.8830277   0.9533136
// # 3 100 0.8373119  0.7583575  0.8940225 0.8198216   0.7327097   0.8853843
// # 4 150 0.7428443  0.6347484  0.8260286 0.7159733   0.5979398   0.8129497
// # 5 200 0.6561102  0.5315389  0.7571369 0.6216718   0.4896364   0.7419416
quietly {
	clear all
	cd "~/Stata-dev/stdmest"
	adopath ++ "stdmest"
	clear all
	use "data/data3CIA", clear
	stset months, failure(status == 1)
	mestreg c.age c.fev1pp ib0.mmrc || cohort: , dist(wei) nohr
	range tt 0 200 5
	stdmest Smin, reat(-1.006262) reatse(.2222539) reatref(0.0) reatseref(0.0) ci reps(2000) timevar(tt)
	stdmest Smin2 if cohort == 18, reat(-1.006262) reatse(.2222539) reatref(0.0) reatseref(0.0) ci reps(2000) timevar(tt)
}
list tt Smin Smin_lower Smin_upper Smin2 Smin2_lower Smin2_upper if tt != .
//       +-------------------------------------------------------------------------+
//       |  tt        Smin   Smin_l~r   Smin_u~r       Smin2   Smin2_l~   Smin2_u~ |
//       |-------------------------------------------------------------------------|
//    1. |   0           1          1          1           1          1          1 |
//    2. |  50    .9319127   .8908648   .9567641    .9245237   .8805603   .9523867 |
//    3. | 100   .83731194   .7529303   .8930812   .81982162   .7299135      .8818 |
//    4. | 150   .74284435   .6295867   .8252876   .71597334   .5951086   .8066548 |
//    5. | 200   .65611022   .5254201   .7584257   .62167184    .484746    .732971 |
//       +-------------------------------------------------------------------------+
