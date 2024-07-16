clear all
cd "~/Stata-dev/stdmest"
adopath ++ "modexpt"
clear all

//
rcof "modexpt, filename(test.xlsx)" == 301

//
clear all
webuse catheter
quietly mestreg age female || patient:, distribution(exponential)

//
modexpt, filename("test.xlsx")
assert fileexists("test.xlsx") == 1

//
rcof "modexpt, filename(test.xlsx)" == 602

//
modexpt, filename("test.xlsx") replace
rcof "modexpt, filename(test.xlsx) replace" == 0

//
rm "test.xlsx"
