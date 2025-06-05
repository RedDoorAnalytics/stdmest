cd "~/Stata-dev/stdmest"

//
do cert/assert-data2Lsim.do
do cert/assert-modexpt.do
do cert/assert-stdmest.do
do cert/assert-stdmestm.do
