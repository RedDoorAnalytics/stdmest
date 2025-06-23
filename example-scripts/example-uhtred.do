//
set linesize 255
clear all
// clear all is enough to 'refresh' in the same session
// -uhtred-
cd "~/Stata-dev/uhtred"
adopath ++ "~/Stata-dev/uhtred"
clear all
adopath ++ "~/Stata-dev/uhtred/uhtred"
clear all
do ./build/buildmlib.do
mata mata clear
// -stdmest-
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
adopath ++ "stdmestm"
clear all
do ./build/buildmlib.do
mata mata clear

// ---
clear all
webuse jobhistory
gen tt = tend - tstart
stset tt, fail(failure)
capture drop tv
range tv 0 365 100

// RP(1) model
uhtred (_t education njobs prestige prestigenew i.female M1[birthyear]@1 M2[birthyear>id]@1, family(rp, df(1) failure(_d)))
predict b1*, reffects
predict b1se*, reses

// RP(3) model
uhtred (_t education njobs prestige prestigenew i.female M1[birthyear]@1 M2[birthyear>id]@1, family(rp, df(3) failure(_d)))
predict b3*, reffects
predict b3se*, reses

// Quite a big difference in terms of estimated variance of the random effects!

// seed, for reproducibility
set seed 34865

// Some predictions for ids within birthyear = 1953
// (won't do all ids, just a few)
// from model 1:
stdmest S11, reat(.47104539  .23917156) reatse(.16794033 .50571222) ci timevar(tv)
stdmest S12, reat(.47104539 -.15623883) reatse(.16794033 .39696077) ci timevar(tv)
stdmest S13, reat(.47104539 -.13912934) reatse(.16794033 .43361777) ci timevar(tv)
stdmest S14, reat(.47104539 -.00007211) reatse(.16794033 .45621589) ci timevar(tv)
stdmest S15, reat(.47104539  .17241641) reatse(.16794033 .44136413) ci timevar(tv)
stdmest S16, reat(.47104539  .13886972) reatse(.16794033 .43613425) ci timevar(tv)
// from model 2:
stdmest S31, reat(.41113506  .08177463) reatse(.14652838 .29972362) ci timevar(tv)
stdmest S32, reat(.41113506 -.07384040) reatse(.14652838 .26891628) ci timevar(tv)
stdmest S33, reat(.41113506 -.06129652) reatse(.14652838 .28058939) ci timevar(tv)
stdmest S34, reat(.41113506 -.00359351) reatse(.14652838 .28783859) ci timevar(tv)
stdmest S35, reat(.41113506  .07319414) reatse(.14652838 .28604685) ci timevar(tv)
stdmest S36, reat(.41113506  .03888327) reatse(.14652838 .28175031) ci timevar(tv)

// Marginal versions:
stdmestm S1m, reat(.47104539) reatse(.16794033) varmarg(`=.5112895^2') ci timevar(tv)
stdmestm S3m, reat(.41113506) reatse(.14652838) varmarg(`=.3010471^2') ci timevar(tv)

// Some plots:
twoway ///
	(line S11 tv, lcolor(black) lpattern(solid)) ///
	(line S12 tv, lcolor(black) lpattern(solid)) ///
	(line S13 tv, lcolor(black) lpattern(solid)) ///
	(line S14 tv, lcolor(black) lpattern(solid)) ///
	(line S15 tv, lcolor(black) lpattern(solid)) ///
	(line S16 tv, lcolor(black) lpattern(solid)) ///
	(line S1m tv, lcolor(blue) lpattern(solid) lwidth(thick)) ///
	, legend(off) name("S1", replace)
//	
twoway ///	
	(line S31 tv, lcolor(black) lpattern(dash)) ///
	(line S32 tv, lcolor(black) lpattern(dash)) ///
	(line S33 tv, lcolor(black) lpattern(dash)) ///
	(line S34 tv, lcolor(black) lpattern(dash)) ///
	(line S35 tv, lcolor(black) lpattern(dash)) ///
	(line S36 tv, lcolor(black) lpattern(dash)) ///
	(line S3m tv, lcolor(blue) lpattern(dash) lwidth(thick)) ///
	, legend(off) name("S3", replace)
//
twoway ///	
	(rarea S1m_lower S1m_upper tv, color(stblue%10)) ///
	(rarea S3m_lower S3m_upper tv, color(stred%10)) ///
	(line S1m tv, lcolor(stblue) lpattern(solid)) ///
	(line S3m tv, lcolor(stred) lpattern(dash)) ///
	, legend(order(3 "Weibull" 4 "RP(3)")) name("S1_vs_S3", replace)
