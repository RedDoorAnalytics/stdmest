clear all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
clear all
do ./build/buildmlib.do
mata mata clear

// helpfile
// help stdmest

//
clear all
webuse jobhistory
gen tt = tend - tstart
stset tt, fail(failure)
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)
predict b*, reffects reses(bse*)
sort b1 b2
list b1 bse1 b2 bse2 if _n == 1 | _n == _N

//
capture drop Stst*
capture drop tt
range tt 0 428 50
stdmest Stst1, reat(-.4603618  -1.05416) reatse(.1427249 .5097189) ci reps(100) timevar(tt)
stdmest Stst2, reat(.2269995 1.550484) reatse(.1666193 .4326237) ci reps(100) timevar(tt)

//
twoway ///
	(rarea Stst1_lower Stst1_upper tt, sort color(stblue%10)) ///
	(rarea Stst2_lower Stst2_upper tt, sort color(stred%10)) ///
	(line Stst1 tt, sort lcolor(stblue)) ///
	(line Stst2 tt, sort lcolor(stred)) ///
	, legend(order(3 "_n == 1" 4 "_n == _N"))  name("Stst12", replace)

//
capture drop Stst*
stdmest Stst, reat(-.4603618  -1.05416) reatse(.1427249 .5097189) reatref(0 0) reatseref(0 0) ci reps(100) timevar(tt) dots cinormal contrast

//
twoway ///
	(rarea Stst_contrast_lower Stst_contrast_upper tt, sort color(stblue%10)) ///
	(line Stst_contrast tt, sort lcolor(stblue)) ///
	, name("Ststcontrast", replace)
