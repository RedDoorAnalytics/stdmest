*! version 0.0.0-9000 Alessandro Gasparini 07Sep2023

program define stdmest, sortpreserve
	// Version
	version 18.0

	// Syntax
	syntax newvarname [if] [in], [ ///
		REAT(real 0.0) ///
		REATRef(real 0.0) ///
		REATSE(real 0.0) ///
		REATSERef(real 0.0) ///
		TIMEvar(varname) ///
		CONTRast ///
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

	/* // Create matrices that will be used later on
		   tempname eb eV eX
		   matrix `eb' = e(b)
		   matrix `eV' = e(V)
		   xi: mkmat `e(covariates)' if e(sample), matrix(`eX')
		   matrix list `eb'
		   matrix list `eV'
	   matrix list `eX' */

	// Test
	tempvar xbname
	predict double `xbname', xb
	if ("`e(distribution)'" == "exponential") {
		mata: std_surv("`newvarname'", "`xbname'", "`timevar'", `reat', 0.0, 1)
	}
	else if ("`e(distribution)'" == "weibull") {
		local lnp = _b["/:ln_p"]
		mata: std_surv("`newvarname'", "`xbname'", "`timevar'", `reat', `lnp', 2)
	}

	// Create contrast if requested
	if ("`contrast'" != "") {
		// Reference
		if ("`e(distribution)'" == "exponential") {
			mata: std_surv("`newvarname'_ref", "`xbname'", "`timevar'", `reatref', 0.0, 1)
		}
		else if ("`e(distribution)'" == "weibull") {
			local lnp = _b["/:ln_p"]
			mata: std_surv("`newvarname'_ref", "`xbname'", "`timevar'", `reatref', `lnp', 2)
		}
		// Calculate contrast
		quietly generate `newvarname'_contrast = `newvarname' - `newvarname'_ref
	}

end

version 18
mata:

void std_surv (
	string scalar out,
	string scalar xb,
	string scalar timevar,
	real scalar reat,
	real scalar anc,
	real scalar distr
)
{
	t = st_data(., timevar)
	xbb = st_data(., xb) :+ reat
	t = st_data(., timevar)
	Savg = J(length(t), 1, .)
	for (i = 1; i <= length(t); i++) {
		Savg[i] = mean(survfun(xbb, t[i], anc, distr))
	}
	outi = st_addvar("float", out)
	st_store(., outi, Savg)
}

real vector survfun (real vector xb, real scalar t, real scalar anc, real scalar distr)
{
	if (distr == 1) {
	S = exp(-exp(xb) :* t)
	}
	else if (distr == 2) {
	   p = exp(anc)
	   S = exp(-exp(xb) :* (t:^p))
	}
	return(S)
}

end
