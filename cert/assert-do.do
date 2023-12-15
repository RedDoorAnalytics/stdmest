cd "~/Stata-dev/stdmest"

//
do cert/assert-mestreg_export.do
do cert/assert-stdmest.do
do cert/assert-stdmestm.do
