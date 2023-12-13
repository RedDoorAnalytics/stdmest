clear all
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
clear all

//
clear
webuse catheter
quietly mestreg age female || patient:, distribution(exponential) time
capture stdmest S0, reat(0.0) reatse(0.0) 
assert _rc > 0
quietly mestreg age female || patient:, distribution(weibull) time
capture stdmest S0, reat(0.0) reatse(0.0) 
assert _rc > 0
quietly mestreg age female || patient:, distribution(loglogistic)
capture stdmest S0, reat(0.0) reatse(0.0) 
assert _rc > 0
quietly mestreg age female || patient:, distribution(lognormal)
capture stdmest S0, reat(0.0) reatse(0.0) 
assert _rc > 0
quietly mestreg age female || patient:, distribution(gamma)
capture stdmest S0, reat(0.0) reatse(0.0) 
assert _rc > 0
quietly mestreg age female || patient:, distribution(exponential)
capture stdmest S0, reat(0.0 0.0) reatse(0.0 0.0) 
assert _rc > 0

// 
clear
webuse catheter
quietly mestreg age female || patient:, distribution(weibull)

// 
stdmest S1, reat(0.0) reatse(0.0) reatref(0.0) reatseref(0.0) contrast
gen S1_exp = 0
mkmat S1_contrast, matrix(S1_contrast)
mkmat S1_exp, matrix(S1_exp)
assert mreldif(S1_contrast, S1_exp) < 1e-16
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
quietly mestreg age female || patient:, distribution(weibull)
stdmest S3a, reat(-1.0) reatse(0.0)
stdmest S3b, reat( 0.0) reatse(0.0)
stdmest S3c, reat(+1.0) reatse(0.0)
assert S3a >= S3b 
assert S3a >= S3c
assert S3b >= S3c
drop S3*

//
stdmest S4a, reat(-1.0) reatse(0.0) reatref(0.0) reatseref(0.0) contrast
stdmest S4b, reat(+1.0) reatse(0.0) reatref(0.0) reatseref(0.0) contrast
assert S4a_contrast >= 0 
assert S4b_contrast <= 0 

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
assert (S6a - S6b) < 1e-16
drop S6*

//
set seed 487
stdmest S7a, reat(0.0) reatse(0.0) ci
set seed 487
stdmest S7b, reat(0.0) reatse(1.0) ci
assert S7a_lower <= S7a
assert S7a <= S7a_upper
assert S7b_lower <= S7b
assert S7b <= S7b_upper
assert S7b_lower <= S7a_lower
assert S7a_upper <= S7b_upper
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
