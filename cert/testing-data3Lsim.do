clear all
// clear all is enough to 'refresh' in the same session
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
clear all

// data3CIA 
clear all
use "data/data3Lsim", clear

// stset
stset t, failure(d == 1)

// mestreg Weibull model
mestreg c.X1 c.X2 i.X3 || hospital_id: || provider_id:, dist(weibull)

// predict random effect, with their SEs
predict b_hospital b_provider, reffects reses(bse_hospital bse_provider)
sort b_hospital b_provider
list b_hospital bse_hospital b_provider bse_provider if _n == 1 | _n == _N
//        +--------------------------------------------+
//        | b_hospi~l   bse_ho~l   b_prov~r   bse_pr~r |
//        |--------------------------------------------|
//     1. | -5.857953   1.022525   -.106435   .6153984 |
// 25000. |  7.244937   .3451288   1.062675   .5293473 |
//        +--------------------------------------------+

// timevar
range tt 0 10 5

