*! version 0.0.1-9000 Alessandro Gasparini, Michael J. Crowther 20Jun2024

program define stdmestm, sortpreserve
	// Version
	version 18.0

	// Check that dataset is still stset
	st_is 2 analysis

	// Check that erepost is installed
	capture which erepost
	if _rc > 0 {
		display as error "The -erepost- command is required for -stdmest- to function properly. You can install it using:"
		display as error ". {stata ssc install erepost}"
		exit  198
	}

	// Check that moremata is installed
	capture findfile lmoremata.mlib
	if _rc > 0 {
		display as error "The -moremata- package is required for -stdmest- to function properly. You can install it using:"
		display as error ". {stata ssc install moremata}"
		exit  198
	}

	// Check that we run stdmest after mestreg
	if "`e(cmd2)'" != "mestreg" {
		display as error "This only works after fitting a mixed-effects survival model with -mestreg-."
		exit 301
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
	// Must be a three-levels model (nlevels == 2)
	local nlevels = wordcount("`e(ivars)'")
	if (`nlevels' != 2) {
		display as error "Only three-level models are supported – `=`nlevels'+1' were detected.
		exit 198
	}

	// Syntax
	syntax newvarname [if] [in], [ ///
		REAT(real 0.0) ///
		REATRef(real 0.0) ///
		REATSE(real 0.0) ///
		REATSERef(real 0.0) ///
		TIMEvar(varname) ///
		CONTRast ///
		CI ///
		CINORMal ///
		Level(cilevel) ///
		REPs(integer 1000) ///
		DOTS ///
		NK(integer 7) ///
		VARMARGname(string) ///
		]

	// The number of quadrature nodes nk must be greater than zero
	if (`nk' <= 0) {
		display as error "'nk' must be > 0."
		exit 198
	}

	// Mark which rows to use
	// (useful to standardise to a subset of the study data)
	marksample touse, novarlist
	local newvarname `varlist'

	// Now, force `touse' to be zero if _st == 0
	quietly replace `touse' = 0 if _st == 0

	// Pick variance of random effect to marginalise over
	capture local vartoint = _b[/var(_cons[`varmargname'])]
	if _rc > 0 {
		display as error "Could not pick the variance to marginalise over (I tried with /var(_cons[`varmargname']))."
		exit 198
	}

	// Process timevar
	tempvar tv
	if "`timevar'" == "" {
		display "timevar() not specified, _t will be used instead"
		local timevar _t
		quietly generate double `tv' = _t if `touse' == 1
	}
	else {
		quietly generate double `tv' = `timevar'
	}
	// Mark timevar rows to use
	tempvar timevartouse
	mark `timevartouse'
	markout `timevartouse' `timevar'

	// Count how many observations we are standardising over
	quietly count if `touse' == 1
	local NNN = `r(N)'

	// Backup estimation results
	// (if we will calculate CIs)
	if "`ci'" != "" {
		tempname eb eV
		matrix `eb' = e(b)
		matrix `eV' = e(V)
		local eb_rown : rowfullnames e(b)
		local eb_coln : colfullnames e(b)
	}

	// Point estimates
	tempvar xbname
	predict double `xbname' if `touse' == 1, xb
	// Doing the following because predict, xb after mestreg does not respect the if statement
	// This is a bug in the -predict- post-estimation command for -mestreg-
	// The following line will be unnecessary once fixed
	quietly replace `xbname' = . if `touse' != 1
	mata: std_isurv("`newvarname'", "`timevar'", `reat', `reatse', `reatref', `reatseref', `vartoint', `nk', `reps', "`ci'", "`cinormal'", `level', "`contrast'", "`dots'", `NNN')

	// Restore estimation results after (possibly) fiddling with stuff in Mata
	if "`ci'" != "" {
		erepost b = `eb'
	}

end
