clear all
cd "~/Stata-dev/stdmest"
adopath ++ "modexpt"
clear all

//
rcof "modexpt" == 301

//
tempfile test
rcof "modexpt, filename(`test')" == 301

//
clear all
webuse catheter
quietly streg age female, distribution(exponential)
rcof "modexpt, filename(`test')" == 301

//
clear all
webuse catheter
quietly stcox age female
rcof "modexpt, filename(`test')" == 301

//
clear all
webuse catheter
quietly mestreg age female || patient:, distribution(exponential)
tempfile test1

//
modexpt, filename("`test1'")
assert fileexists("`test1'") == 1

//
rcof "modexpt, filename(`test1')" == 602

//
modexpt, filename("`test1'") replace
rcof "modexpt, filename(`test1') replace" == 0

//
clear all
webuse catheter
quietly stmixed age female || patient:, distribution(exponential)
tempfile test2

//
modexpt, filename("`test2'")
assert fileexists("`test2'") == 1

//
rcof "modexpt, filename(`test2')" == 602

//
modexpt, filename("`test2'") replace
rcof "modexpt, filename(`test2') replace" == 0

//
clear all
webuse catheter
quietly stmixed age female || patient:, distribution(rp) df(3)
tempfile test3

//
modexpt, filename("`test3'")
assert fileexists("`test3'") == 1

//
rcof "modexpt, filename(`test3')" == 602

//
modexpt, filename("`test3'") replace
rcof "modexpt, filename(`test3') replace" == 0
