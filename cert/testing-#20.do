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

// seed, for reproducibility
set seed 347856

// data3CIA
clear all
use "data/data3CIA", clear

// stset
stset months, failure(status == 1)

// -uhtred- model
quietly uhtred (_t c.age c.fev1pp ib0.mmrc M1[cohort]@1, family(rp, df(1) failure(_d)))

//
set seed 1
capture drop tv
range tv 0 100 10
capture drop S1*
stdmest S1, reat(1) reatse(0.1) reatref(0.0) reatrefse(0.0) timevar(tv) ci reps(1000) verbose dots

//
set seed 1
capture drop S2*
stdmest S2, reat(1) reatse(0.1) reatref(0.0) reatrefse(0.0) timevar(tv) ci reps(1000) verbose dots

//
list tv S1* S2* if tv != .
