clear all
cd "~/Stata-dev/stdmest"
adopath ++ "stdmestm"
clear all

//
webuse jobhistory
gen tt = tend - tstart
stset tt, fail(failure)
range tv 0 365 10

//
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential) time
capture stdmestm S0, reat(0.0) reatse(0.0) varmargname(birthyear>id)
assert _rc > 0 
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(weibull) time
capture stdmestm S0, reat(0.0) reatse(0.0) varmargname(birthyear>id)
assert _rc > 0 
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(loglogistic)
capture stdmestm S0, reat(0.0) reatse(0.0) varmargname(birthyear>id)
assert _rc > 0 
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(lognormal)
capture stdmestm S0, reat(0.0) reatse(0.0) varmargname(birthyear>id)
assert _rc > 0 
matrix eb = e(b)
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(gamma) from(eb)
capture stdmestm S0, reat(0.0) reatse(0.0) varmargname(birthyear>id)
assert _rc > 0 
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)
capture stdmestm S0, reat(0.0 0.0) reatse(0.0 0.0) varmargname(birthyear>id)
assert _rc > 0 

//
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)
stdmestm S1a, reat(-1.0) reatse(0.0) varmargname(birthyear>id) timevar(tv)
stdmestm S1b, reat( 0.0) reatse(0.0) varmargname(birthyear>id) timevar(tv)
stdmestm S1c, reat(+1.0) reatse(0.0) varmargname(birthyear>id) timevar(tv)
assert S1a >= S1b
assert S1a >= S1c
assert S1b >= S1c
drop S1*

//
stdmestm S2a, reat(0.0) reatse(0.0) varmargname(birthyear>id) timevar(tv) ci reps(10)
stdmestm S2b, reat(0.0) reatse(1.0) varmargname(birthyear>id) timevar(tv) ci reps(10)
assert S2a == S2b
assert S2a_lower >= S2b_lower
assert S2a_upper <= S2b_upper
drop S2*

//
stdmestm S3a, reat(0.0) reatse(0.0) varmargname(birthyear>id) timevar(tv)
stdmestm S3b, reat(0.0) reatse(0.0) varmargname(birthyear>id) timevar(tv) nk(15)
stdmestm S3c, reat(0.0) reatse(0.0) varmargname(birthyear>id) timevar(tv) nk(30)
stdmestm S3d, reat(0.0) reatse(0.0) varmargname(birthyear>id) timevar(tv) nk(100)
mkmat S3a, matrix(mS3a) nomissing
mkmat S3b, matrix(mS3b) nomissing
mkmat S3c, matrix(mS3c) nomissing
mkmat S3d, matrix(mS3d) nomissing
assert mreldif(mS3a, mS3b) < 1e-04
assert mreldif(mS3a, mS3c) < 1e-04
assert mreldif(mS3a, mS3d) < 1e-04
assert mreldif(mS3b, mS3c) < 1e-05
assert mreldif(mS3b, mS3d) < 1e-05
assert mreldif(mS3c, mS3d) < 1e-06
drop S3*
