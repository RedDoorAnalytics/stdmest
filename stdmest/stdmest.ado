*! version 0.0.0-9000 Alessandro Gasparini 07Sep2023

program define stdmest, sortpreserve
	// Version
	version 18

	// Syntax
	syntax newvarname [if] [in], [ ///
		REAT(real 0.0) ///
		REATRef(real 0.0) ///
		REATSE(real 0.0) ///
		REATSERef(real 0.0) ///
		TIMEVAR(string) ///
		FRAME(string) ///
		]

	marksample touse, novarlist
	local newvarname `varlist'

	// Also want to check that dataset is still stset
	st_is 2 analysis

	// Check that we run stdmest after mestreg
	if "`e(cmd2)'" != "mestreg" {
		display as error "This only works after fitting an mestreg model."
		exit 198
	}

	// Only support PH models (for now)
	if "`e(frm2)'" != "hazard" {
		display as error "Only proportional hazards models are supported."
		exit 198
	}

	// Only support exponential and Weibull distributions (for now)
	if "`e(distribution)'" != "exponential" & "`e(distribution)'" != "weibull" {
		display as error "Only exponential and Weibull baseline hazard distributions are supported."
		exit 198
	}

	// Number of levels for this specific model
	local nlevels = wordcount("`e(ivars)'")
	if (`nlevels' > 1) {
		display as error "Too many hierarchical levels:" ///
			_newline "Only models with two levels are supported."
		exit 198
	}

	// Process timevar
	tempvar tv
	if "`timevar'" == "" {
		display "'timevar' not specified, _t will be used instead"
		local timevar _t
		quietly generate double `tv' = _t
	}
	else {
		quietly generate double `tv' = `timevar'
	}

	// Report...
	display "Model formulation: `e(frm2)'"
    display "Baseline hazard distribution: `e(distribution)'"

	// Test
	tempvar xbname
	predict double `xbname', xb
	display "newvarname: `newvarname'"
	display "xbname: `xbname'"
	display "timevar: `timevar'"
	display "reat: `reat'"

	if ("`e(distribution)'" == "exponential") {
		mata: surv_exp("`newvarname'", "`xbname'", "`timevar'", `reat')
	}
	else if ("`e(distribution)'" == "weibull") {
		local lnp = _b["/:ln_p"]
		mata: surv_wei("`newvarname'", "`xbname'", "`timevar'", `reat', `lnp')
	}


/*
	for t in timevar {

	S(t, xb, bs, ancillary)

	surv_to_use = switch (e(distribution)) {
		"exp" = &surv_exp;
		"wei" = &surv_wei;
	}

	integrate &surv_to_use

	post to frame t S

	}
	// pass xb to mata
	// pass */

	/*
	// Create new frame for predictions
	if ("`frame'" == "") {
		local framename = "stdmest_pred"
	}
	else {
		local framename = "`frame'"
	}
	display "Frame name: `framename'"

	// Post timevar to new frame
	frame put `timevar', into(`framename')
	*/

end

version 18
mata:

void surv_exp (
	string scalar out,
	string scalar xb,
	string scalar timevar,
	real scalar reat)
{
	t = st_data(., timevar)
	xbb = st_data(., xb) :+ reat
	S = exp(-exp(xbb) :* t)
	// return
	outi = st_addvar("float", out)
	st_store(., outi, S)
}

void surv_wei (
	string scalar out,
	string scalar xb,
	string scalar timevar,
	real scalar reat,
	real scalar ln_p)
{
	p = exp(ln_p)
	t = st_data(., timevar)
	xbb = st_data(., xb) :+ reat
	S = exp(-exp(xbb) :* (t:^p))
	// return
	outi = st_addvar("float", out)
	st_store(., outi, S)
}

end
