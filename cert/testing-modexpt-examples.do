//
set linesize 255
clear all
local drive = "~/Stata-dev"
cd "`drive'/stdmest"
adopath ++ "modexpt"
clear all

//
help modexpt

//
clear all
webuse catheter
mestreg age female || patient:, distribution(weibull)
tempfile test1
modexpt, filename(`test1')
modexpt, filename(`test1') replace
capture noisily modexpt, filename(`test1')

//
clear all
webuse catheter
stmixed age female || patient:, distribution(weibull)
tempfile test2
modexpt, filename(`test2')
