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
set maxvar 120000

// data3CIA
clear all
use "data/data3Lsim", clear

// seed, for reproducibility
set seed 123

// stset
stset t, failure(d == 1)

// mestreg Weibull model
mestreg c.X1 c.X2 i.X3 || hospital_id: || provider_id:, dist(weibull)

// timevar
range tt 0 10 5

//
stdmest Sa1, reat(0.878 0.122) reatse(0.311 0.570) ci timevar(tt) verbose cinormal
stdmest Sa2, reat(2.65 -0.298) reatse(0.407 0.522) ci timevar(tt) verbose cinormal
list tt Sa1 Sa1_lower Sa1_upper Sa2 Sa2_lower Sa2_upper if tt != .

// "Partially marginal" version
stdmestm Sam, reat(0.878) reatse(0.311) varmarg(.4087721) timevar(tt) contrast ci verbose cinormal
list tt Sam Sam_lower Sam_upper Sam_ref Sam_ref_lower Sam_ref_upper Sam_contrast Sam_contrast_lower Sam_contrast_upper if tt != .
