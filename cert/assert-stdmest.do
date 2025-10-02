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

//
rcof "stdmest S0, reat(0.0) reatse(0.0)" == 119

//
clear
webuse catheter
rcof "stdmest S0, reat(0.0) reatse(0.0)" == 301

//
quietly mestreg age female || patient:, distribution(exponential) time
rcof "stdmest S0, reat(0.0) reatse(0.0)" == 198
quietly mestreg age female || patient:, distribution(weibull) time
rcof "stdmest S0, reat(0.0) reatse(0.0)" == 198
quietly mestreg age female || patient:, distribution(loglogistic)
rcof "stdmest S0, reat(0.0) reatse(0.0)" == 198
quietly mestreg age female || patient:, distribution(lognormal)
rcof "stdmest S0, reat(0.0) reatse(0.0)" == 198
quietly mestreg age female || patient:, distribution(gamma)
rcof "stdmest S0, reat(0.0) reatse(0.0)" == 198
quietly mestreg age female || patient:, distribution(exponential)
rcof "stdmest S0, reat(0.0 0.0) reatse(0.0 0.0)" == 198

//
clear
webuse catheter
quietly mestreg age female || patient:, distribution(exponential)

//
stdmest S1, reat(0.0) reatse(0.0) reatref(0.0) reatrefse(0.0) contrast
gen S1_exp = 0
mkmat S1_diff, matrix(S1_diff)
mkmat S1_exp, matrix(S1_exp)
assert mreldif(S1_diff, S1_exp) < 1e-16
drop S1*

//
range tt 0 365 100
replace tt = . if age < 45
stdmest S2 if age >= 45, reat(0.0) reatse(0.0) timevar(tt)
mkmat S2, matrix(S2_if) nomissing
drop if age < 45
stdmest S2_2, reat(0.0) reatse(0.0) timevar(tt)
mkmat S2_2, matrix(S2_keep) nomissing
assert mreldif(S2_if, S2_keep) < 1e-16
drop S2*

//
clear
webuse catheter
quietly mestreg age female || patient:, distribution(exponential)
stdmest S3a, reat(-1.0) reatse(0.0)
stdmest S3b, reat( 0.0) reatse(0.0)
stdmest S3c, reat(+1.0) reatse(0.0)
assert S3a >= S3b
assert S3a >= S3c
assert S3b >= S3c
drop S3*

//
stdmest S4a, reat(-1.0) reatse(0.0) reatref(0.0) reatrefse(0.0) contrast
stdmest S4b, reat(+1.0) reatse(0.0) reatref(0.0) reatrefse(0.0) contrast
assert S4a_diff >= 0
assert S4b_diff <= 0
drop S4*

//
gen t5 = 0
stdmest S5a, reat(-1.0) reatse(0.0) timevar(t5)
stdmest S5b, reat( 0.0) reatse(0.0) timevar(t5)
stdmest S5c, reat(+1.0) reatse(0.0) timevar(t5)
assert S5a == 1
assert S5b == 1
assert S5c == 1
drop S5* t5

//
predict S6a, surv conditional(fixedonly)
stdmest S6b if _n == 1, reat(0.0) reatse(0.0)
replace S6a = 0 if _n > 1
replace S6b = 0 if _n > 1
assert (S6a - S6b) < 1e-6
drop S6*

//
set seed 487
stdmest S7a, reat(0.0) reatse(0.0) ci reps(10)
set seed 487
stdmest S7b, reat(0.0) reatse(1.0) ci reps(10)
assert S7a_lci <= S7a
assert S7a <= S7a_uci
assert S7b_lci <= S7b
assert S7b <= S7b_uci
assert S7b_lci <= S7a_lci
assert S7a_uci <= S7b_uci
drop S7*

//
clear all
webuse jobhistory
gen tt = tend - tstart
stset tt, fail(failure)
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)

//
capture stdmest S8, reat(0.0) reatse(0.0)
assert _rc > 0
capture stdmest S8, reat(0.0 0.0 0.0) reatse(0.0 0.0 0.0)
assert _rc > 0

//
stdmest S9a, reat(-1.0 -1.0) reatse(0.0 0.0)
stdmest S9b, reat(-1.0  0.0) reatse(0.0 0.0)
stdmest S9c, reat( 0.0 -1.0) reatse(0.0 0.0)
assert S9a >= S9b
assert S9a >= S9c
drop S9*

//
clear
webuse catheter
quietly mestreg age female || patient:, distribution(exponential)
summ _t
// random time variable
// I *don't* set the seed to incorporate some randomness
// -> all test below should pass no matter what
gen tv = runiform(0, `r(mean)')
summ tv
local rmin = `r(min)'
local rmean = `r(mean)'
local rmax = `r(max)'
stdmest S10a, reat(`rmin') reatse(0.0) timevar(tv)
stdmest S10b, reat(`rmean') reatse(0.0) timevar(tv)
stdmest S10c, reat(`rmax') reatse(0.0) timevar(tv)
assert S10a >= S10b
assert S10a >= S10c
assert S10b >= S10c
drop S10* tv
