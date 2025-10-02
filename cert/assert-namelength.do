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
clear
webuse catheter

//
quietly mestreg age female || patient:, distribution(exponential) time
rcof "stdmest this_name_is_very_very_very_very_very_very_very_very_long, reat(0.0) reatse(0.0) reatref(0.0) reatrefse(0.0) contrast" == 198

//
webuse jobhistory
gen tt = tend - tstart
stset tt, fail(failure)

//
gen tv = runiform(0, 365)
replace tv = . if _n > 10
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)
rcof "stdmestm this_name_is_also_very_very_very_very_very_very_very_very_long, reat(-1.0) reatse(0.0) varmarg(.507621) timevar(tv)" == 198
