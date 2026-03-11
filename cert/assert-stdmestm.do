//
set linesize 255
clear all
// clear all is enough to 'refresh' in the same session
// -stdmest-
local drive = "~/Stata-dev"
cd "`drive'/stdmest"
adopath ++ "stdmest"
adopath ++ "stdmestm"
clear all
do ./build/buildmlib.do
mata mata clear

//
rcof "stdmestm" == 119

//
webuse jobhistory
gen tt = tend - tstart
stset tt, fail(failure)

// random time variable
// I *don't* set the seed to incorporate some randomness
// -> all test should pass no matter what
gen tv = runiform(0, 365)
replace tv = . if _n > 10
rcof "stdmestm" == 301

//
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential) time
rcof "stdmestm S0, reat(0.0) reatse(0.0) varmarg(.507621)" == 198
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(weibull) time
rcof "stdmestm S0, reat(0.0) reatse(0.0) varmarg(.507621)" == 198
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(loglogistic)
rcof "stdmestm S0, reat(0.0) reatse(0.0) varmarg(.507621)" == 198
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(lognormal)
matrix eb = e(b)
rcof "stdmestm S0, reat(0.0) reatse(0.0) varmar(.507621)" == 198
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(gamma) from(eb)
rcof "stdmestm S0, reat(0.0) reatse(0.0) varmarg(.507621)" == 198
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)
rcof "stdmestm S0, reat(0.0 0.0) reatse(0.0 0.0) varmarg(.507621)" == 198

//
quietly mestreg education njobs prestige i.female || id:, distribution(exponential)
rcof "stdmestm S0, reat(0.0) reatse(0.0) varmarg(.6186797)" == 198

//
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)
rcof "stdmestm S0, reat(0.0) reatse(0.0) varmarg(id)" == 198

//
quietly mestreg education njobs prestige i.female || birthyear: || id:, distribution(exponential)
stdmestm S1a, reat(-1.0) reatse(0.0) varmarg(.507621) timevar(tv)
stdmestm S1b, reat( 0.0) reatse(0.0) varmarg(.507621) timevar(tv)
stdmestm S1c, reat(+1.0) reatse(0.0) varmarg(.507621) timevar(tv)
assert S1a >= S1b
assert S1a >= S1c
assert S1b >= S1c
drop S1*

//
stdmestm S2a, reat(0.0) reatse(0.0) varmarg(.507621) timevar(tv) ci reps(10)
stdmestm S2b, reat(0.0) reatse(1.0) varmarg(.507621) timevar(tv) ci reps(10)
assert S2a == S2b
assert S2a_lci >= S2b_lci
assert S2a_uci <= S2b_uci
drop S2*

//
stdmestm S3a, reat(0.0) reatse(0.0) varmarg(.507621) timevar(tv)
stdmestm S3b, reat(0.0) reatse(0.0) varmarg(.507621) timevar(tv) nk(15)
stdmestm S3c, reat(0.0) reatse(0.0) varmarg(.507621) timevar(tv) nk(30)
stdmestm S3d, reat(0.0) reatse(0.0) varmarg(.507621) timevar(tv) nk(100)
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

//
stdmestm S4a, reat(0.0) reatse(0.0) varmarg(.507621) timevar(tv)
stdmest  S4b, reat(0.0 0.0) reatse(0.0 0.0) timevar(tv)
mkmat S4a, matrix(mS4a) nomissing
mkmat S4b, matrix(mS4b) nomissing
assert mreldif(mS4a, mS4b) != 0.0
drop S4*

//
set seed 3475
stdmestm S5a, reat(0.0) reatse(1.0) varmarg(.507621) timevar(tv) ci reps(10)
set seed 3475
stdmestm S5b, reat(0.0) reatse(1.0) varmarg(.507621) timevar(tv) ci reps(100)
assert S5a == S5b
mkmat S5a_lci, matrix(mS5al) nomissing
mkmat S5b_lci, matrix(mS5bl) nomissing
assert mreldif(mS5al, mS5bl) != 0.0
mkmat S5a_uci, matrix(mS5au) nomissing
mkmat S5b_uci, matrix(mS5bu) nomissing
assert mreldif(mS5au, mS5bu) != 0.0
drop S5*
