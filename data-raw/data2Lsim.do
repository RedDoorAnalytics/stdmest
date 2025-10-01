clear all
cd "~/Stata-dev/stdmest"

//
set seed 31495673
set obs 300
gen cluster = _n
gen tmp = 0
gen b = rnormal(0, `=sqrt(2)')
expand 300
gen X1 = rbinomial(1, 0.5)
sort cluster
gen id = _n
bysort cluster: replace tmp = 1 if _n == 1

//
survsim time status, distribution(exponential) lambdas(1) covariates(X1 -0.5 b 1.0)
gen status = 1

//
stset time, failure(status = 1)
sts graph, surv
mestreg i.X1 || cluster: , distribution(exponential) nohr
predict bhat, reffects intpoints(15)
scatter b bhat if tmp == 1
streg i.X1, distribution(exponential) nohr
streg i.X1 c.b, distribution(exponential) nohr

//
drop tmp
compress
save "data/data2Lsim.dta", replace
