clear all
cd "~/Stata-dev/stdmest"
adopath ++ "modexpt"
clear all

//
help modexpt

//
clear all
webuse catheter
mestreg age female || patient:, distribution(weibull)
modexpt, filename("test.xlsx")
modexpt, filename("test.xlsx") replace
modexpt, filename("test.xlsx")

// 
clear all
webuse catheter
stmixed age female || patient:, distribution(weibull)
tempfile test
modexpt, filename(`test')
