clear all
cd "~/Stata-dev/stdmest"
adopath ++ "mestreg_export"
clear all
do ./build/buildmlib.do
mata mata clear

//
rcof "mestreg_export, filename(test.xlsx)" == 301

//
clear all
webuse catheter
quietly mestreg age female || patient:, distribution(exponential)

// 
mestreg_export, filename("test.xlsx")
assert fileexists("test.xlsx") == 1

//
rcof "mestreg_export, filename(test.xlsx)" == 602

//
mestreg_export, filename("test.xlsx") replace
rcof "mestreg_export, filename(test.xlsx) replace" == 0

//
rm "test.xlsx"
