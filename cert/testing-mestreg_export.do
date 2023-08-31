clear all
cd "~/Stata-dev/stdmest"
adopath ++ "mestreg_export"
clear all

//
clear all
webuse catheter
mestreg age female || patient:, distribution(exp)
mestreg_export, filename("test.xlsx") replace
mestreg_export, filename("test.xlsx")
