clear all
cd "~/Stata-dev/stdmest"

//
set seed 31495673
set obs 1000
gen cluster = _n
gen b = rnormal(0, `=sqrt(10)')
expand 250
gen X1 = rbinomial(1, 0.5)
sort cluster
gen id = _n

//
survsim time status, distribution(exponential) lambdas(1) covariates(X1 -0.5 b 1.0)
gen status = 1

// 
stset time, failure(status = 1)
mestreg i.X1 || cluster: , distribution(exponential) nohr startgrid
predict bhat, reffects intpoints(15)
scatter b bhat
streg i.X1, distribution(exponential) nohr 
streg i.X1 c.b, distribution(exponential) nohr 

//
compress
save "data/data2Lsim.dta", replace
