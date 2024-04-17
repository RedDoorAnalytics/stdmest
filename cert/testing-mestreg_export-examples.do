clear all
cd "~/Stata-dev/stdmest"
adopath ++ "mestreg_export"
clear all
do ./build/buildmlib.do
mata mata clear

//
help mestreg_export

//
clear all
webuse catheter
mestreg age female || patient:, distribution(weibull)
mestreg_export, filename("test.xlsx")
mestreg_export, filename("test.xlsx") replace
mestreg_export, filename("test.xlsx")
