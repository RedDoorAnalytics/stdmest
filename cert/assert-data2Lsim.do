500489r all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
adopath ++ "stdmestm"
clear all
do ./build/buildmlib.do
mata mata clear

// data2Lsim
clear all
use "data/data2Lsim", clear

// mestreg exponential model

mestreg c.X1 || cluster:, dist(exponential) nohr

// Mixed-effects exponential PH regression         Number of obs     =    1000000
// Group variable: cluster                         Number of groups  =      1,000
//
//                                                 Obs per group:
//                                                               min =      1,000
//                                                               avg =    1,000.0
//                                                               max =      1,000
//
// Integration method: mvaghermite                 Integration pts.  =          7
//
//                                                 Wald chi2(1)      =   62553.76
// Log likelihood = -1234512.5                     Prob > chi2       =     0.0000
// ------------------------------------------------------------------------------
//           _t | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
// -------------+----------------------------------------------------------------
//           X1 |  -.5007131    .002002  -250.11   0.000    -.5046369   -.4967893
//        _cons |   .0194006   .0448248     0.43   0.665    -.0684545    .1072556
// -------------+----------------------------------------------------------------
// cluster      |
//    var(_cons)|   2.007918   .0898333                      1.839347    2.191938
// ------------------------------------------------------------------------------
// LR test vs. exponential model: chibar2(01) = 2.0e+06  Prob >= chibar2 = 0.0000

// timevar
capture drop tt
range tt 0 10 11

//
capture drop Sa1*
stdmest Sa1, reat(0) reatse(0) reatref(-2) reatseref(0) timevar(tt) contrast
list Sa1* tt if tt != .

//          +----------------------------------------+
//          |       Sa1     Sa1_ref   Sa1_con~t   tt |
//          |----------------------------------------|
//       1. |         1           1           0    0 |
//       2. | .44980254   .89541563   -.4456131    1 |
//       3. | .21026949   .80236105   -.5920916    2 |
//       4. | .10173044   .71950665   -.6177762    3 |
//       5. |  .0506473   .64568162   -.5950343    4 |
//          |----------------------------------------|
//       6. | .02578955   .57985454    -.554065    5 |
//       7. | .01335636   .52111629   -.5077599    6 |
//       8. | .00700291   .46866517   -.4616623    7 |
//       9. | .00370388   .42179382   -.4180899    8 |
//      10. | .00197093   .37987778   -.3779069    9 |
//          |----------------------------------------|
//      11. | .00105317    .3423655   -.3413123   10 |
//          +----------------------------------------+

* --> Calculate by hand
tab X1

//          X1 |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//           0 |    500,489       50.05       50.05
//           1 |    499,511       49.95      100.00
// ------------+-----------------------------------
//       Total |  1,000,000      100.00

// Sa1, for values of t:
forvalues t = 0(1)10 {
	mkmat Sa1 if tt == `t', matrix(ref)
	matrix test = 0.500489 * exp(-exp(_b[_cons] + 0 * _b[X1] + 0.0) * `t') + 0.499511 * exp(-exp(_b[_cons] + 1 * _b[X1] + 0.0) * `t')
	di mreldif(test, ref)
	assert mreldif(test, ref) < 1e-6
}

// Sa1_ref, for values of t:
forvalues t = 0(1)10 {
	mkmat Sa1_ref if tt == `t', matrix(ref)
	matrix test = 0.500489 * exp(-exp(_b[_cons] + 0 * _b[X1] - 2.0) * `t') + 0.499511 * exp(-exp(_b[_cons] + 1 * _b[X1] - 2.0) * `t')
	di mreldif(test, ref)
	assert mreldif(test, ref) < 1e-6
}

* --> With true model parameters:
// Sa1, for values of t:
forvalues t = 0(1)10 {
	mkmat Sa1 if tt == `t', matrix(ref)
	matrix test = 0.500489 * exp(-exp(0.0 + 0 * (-0.5) + 0.0) * `t') + 0.499511 * exp(-exp(0.0 + 1 * (-0.5) + 0.0) * `t')
	di mreldif(test, ref)
	assert mreldif(test, ref) < 1e-2
}

// Sa1_ref, for values of t:
forvalues t = 0(1)10 {
	mkmat Sa1_ref if tt == `t', matrix(ref)
	matrix test = 0.500489 * exp(-exp(0.0 + 0 * (-0.5) - 2.0) * `t') + 0.499511 * exp(-exp(0.0 + 1 * (-0.5) - 2.0) * `t')
	di mreldif(test, ref)
	assert mreldif(test, ref) < 1e-2
}
