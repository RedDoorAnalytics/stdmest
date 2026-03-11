//
set linesize 255
clear all
// clear all is enough to 'refresh' in the same session
// -stdmest-
local drive = "~/Stata-dev"
cd "`drive'/stdmest"
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

// Mixed-effects exponential PH regression         Number of obs     =     90,000
// Group variable: cluster                         Number of groups  =        300
//
//                                                 Obs per group:
//                                                               min =        300
//                                                               avg =      300.0
//                                                               max =        300
//
// Integration method: mvaghermite                 Integration pts.  =          7
//
//                                                 Wald chi2(1)      =    5490.19
// Log likelihood = -110626.52                     Prob > chi2       =     0.0000
// ------------------------------------------------------------------------------
//           _t | Coefficient  Std. err.      z    P>|z|     [95% conf. interval]
// -------------+----------------------------------------------------------------
//           X1 |  -.4956912   .0066899   -74.10   0.000    -.5088031   -.4825793
//        _cons |   .0288104   .0840111     0.34   0.732    -.1358484    .1934692
// -------------+----------------------------------------------------------------
// cluster      |
//    var(_cons)|   2.113091   .1727567                       1.80023    2.480325
// ------------------------------------------------------------------------------
// LR test vs. exponential model: chibar2(01) = 1.9e+05  Prob >= chibar2 = 0.0000

// timevar
capture drop tt
range tt 0 10 11

//
capture drop Sa1*
stdmest Sa1, reat(0) reatse(0) reatref(-2) reatrefse(0) timevar(tt) contrast
list Sa1* tt if tt != .

//        +-----------------------------------------+
//        |       Sa1     Sa1_ref     Sa1_diff   tt |
//        |-----------------------------------------|
//     1. |         1           1            0    0 |
//     2. | .44553288   .89425334   -.44872046    1 |
//     3. |  .2063259   .80028137   -.59395547    2 |
//     4. | .09890216   .71671376    -.6178116    3 |
//     5. | .04879053   .64234527   -.59355475    4 |
//        |-----------------------------------------|
//     6. | .02461962   .57611538   -.55149576    5 |
//     7. |  .0126359   .51709042   -.50445452    6 |
//     8. | .00656584     .464448   -.45788216    7 |
//     9. | .00344167   .41746334   -.41402167    8 |
//    10. | .00181505   .37549736   -.37368231    9 |
//        |-----------------------------------------|
//    11. | .00096122   .33798623   -.33702501   10 |
//        +-----------------------------------------+


* --> Calculate by hand
tab X1

//          X1 |      Freq.     Percent        Cum.
// ------------+-----------------------------------
//           0 |     45,110       50.12       50.12
//           1 |     44,890       49.88      100.00
// ------------+-----------------------------------
//       Total |     90,000      100.00

// Sa1, for values of t:
forvalues t = 0(1)10 {
	mkmat Sa1 if tt == `t', matrix(ref)
	matrix test = 0.5012 * exp(-exp(_b[_cons] + 0 * _b[X1] + 0.0) * `t') + 0.4988 * exp(-exp(_b[_cons] + 1 * _b[X1] + 0.0) * `t')
	di mreldif(test, ref)
	assert mreldif(test, ref) < 1e-2
}

// Sa1_ref, for values of t:
forvalues t = 0(1)10 {
	mkmat Sa1_ref if tt == `t', matrix(ref)
	matrix test = 0.5012 * exp(-exp(_b[_cons] + 0 * _b[X1] - 2.0) * `t') + 0.4988 * exp(-exp(_b[_cons] + 1 * _b[X1] - 2.0) * `t')
	di mreldif(test, ref)
	assert mreldif(test, ref) < 1e-2
}

* --> With true model parameters:
// Sa1, for values of t:
forvalues t = 0(1)10 {
	mkmat Sa1 if tt == `t', matrix(ref)
	matrix test = 0.5012 * exp(-exp(0.0 + 0 * (-0.5) + 0.0) * `t') + 0.4988 * exp(-exp(0.0 + 1 * (-0.5) + 0.0) * `t')
	di mreldif(test, ref)
	assert mreldif(test, ref) < 1e-2
}

// Sa1_ref, for values of t:
forvalues t = 0(1)10 {
	mkmat Sa1_ref if tt == `t', matrix(ref)
	matrix test = 0.5012 * exp(-exp(0.0 + 0 * (-0.5) - 2.0) * `t') + 0.4988 * exp(-exp(0.0 + 1 * (-0.5) - 2.0) * `t')
	di mreldif(test, ref)
	assert mreldif(test, ref) < 1e-2
}
