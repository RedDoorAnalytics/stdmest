clear all
cd "~/Stata-dev/stdmest"
adopath ++ "mestreg_export"
clear all

//
clear all
webuse catheter
quietly mestreg age female || patient:, distribution(exponential)

// 
mestreg_export, filename("test.xlsx")
assert fileexists("test.xlsx") == 1

//
capture mestreg_export, filename("test.xlsx")
assert _rc > 0

//
capture mestreg_export, filename("test.xlsx") replace
assert _rc == 0

//
rm "test.xlsx"
