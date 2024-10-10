clear all
cd "~/Stata-dev/stdmest"

//
clear all
webuse jobhistory
gen tt = tend - tstart
stset tt, fail(failure)

//
mestreg education njobs prestige female || birthyear: || id:, distribution(exponential) startgrid intpoints(15)
estimates store m_exp_ph
mestreg education njobs prestige female || birthyear: || id:, distribution(exponential) time startgrid intpoints(15)
estimates store m_exp_aft

mestreg education njobs prestige female || birthyear: || id:, distribution(weibull) startgrid intpoints(15)
estimates store m_wei_ph
mestreg education njobs prestige female || birthyear: || id:, distribution(weibull) time startgrid intpoints(15)
estimates store m_wei_aft

mestreg education njobs prestige female || birthyear: || id:, distribution(loglogistic) startgrid intpoints(15)
estimates store m_ll_aft

mestreg education njobs prestige female || birthyear: || id:, distribution(lognormal) startgrid intpoints(15)
estimates store m_ln_aft

stmixed education njobs prestige female || birthyear: || id:, distribution(exponential) intpoints(15)
estimates store s_exp_ph

stmixed education njobs prestige female || birthyear: || id:, distribution(weibull) intpoints(15)
estimates store s_wei_ph

stmixed education njobs prestige female || birthyear: || id:, distribution(rp) df(3) intpoints(15)
estimates store s_rp3_ph

stmixed education njobs prestige female || birthyear: || id:, distribution(rp) df(5) intpoints(15)
estimates store s_rp5_ph

//
estimates stats m_* s_*

