*! version 0.0.0-9000 Alessandro Gasparini 12Oct2023

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
		CI ///
		CINORMal ///
		CILEVel(real 0.95) ///
		REPs(real 100) ///
		DOTS ///
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
		quietly generate double `tv' = _t if `touse' == 1
	}
	else {
		quietly generate double `tv' = `timevar'
	}
	// Mark timevar rows to use
	tempvar timevartouse
	mark `timevartouse'
	markout `timevartouse' `timevar'

	// Point estimates
	tempvar xbname
	predict double `xbname' if `touse' == 1, xb
	// Doing the following because predict, xb after mestreg does not respect the if statement
	// If a bug in predict, this will be unnecessary once fixed
	quietly replace `xbname' = . if `touse' != 1
	mata: std_surv("`newvarname'", "`xbname'", "`touse'", "`timevar'", "`timevartouse'", `reat')

	// Create contrast if requested
	if ("`contrast'" != "") {
		// Reference
		mata: std_surv("`newvarname'_ref", "`xbname'", "`touse'", "`timevar'", "`timevartouse'", `reatref')
		// Calculate contrast
		quietly generate `newvarname'_contrast = `newvarname' - `newvarname'_ref
	}

	// Confidence intervals using bootstrap-like procedure
	if ("`ci'" != "") {
		display "Calculating CIs..."
		// Store original estimation results
		tempname eb eV neweb newreat newreatref
		matrix `eb' = e(b)
		matrix `eV' = e(V)
		local eb_rown: rowfullnames e(b)
		local eb_coln: colfullnames e(b)
		mata: draw_newpars(`reps', "`neweb'")
		mata: draw_newreat(`reps', `reat', `reatse', "`newreat'")
		mata: draw_newreat(`reps', `reatref', `reatseref', "`newreatref'")
		// Iterate with dots (if required by the user)
		if ("`dots'" != "") {
			noisily _dots 0, reps(`reps')
		}
		forval b = 1/`reps' {
			// Repost new results
			tempname this_eb
			matrix `this_eb' = `neweb'[`b',....]
			local thisreat = `newreat'[`b',1]
			local thisreatref = `newreatref'[`b',1]
			matrix rownames `this_eb' = `eb_rown'
			matrix colnames `this_eb' = `eb_coln'
			erepost b = `this_eb'
			tempvar new_xbname
			predict double `new_xbname' if `touse' == 1, xb
			// Doing the following because predict, xb after mestreg does not respect the if statement
			// If a bug in predict, this will be unnecessary once fixed
			quietly replace `new_xbname' = . if `touse' != 1
			// Predict using new xb and pars
			mata: std_surv("tmp`newvarname'_b`b'", "`new_xbname'", "`touse'", "`timevar'", "`timevartouse'", `thisreat')
			// Contrasts
			if 	("`contrast'" != "") {
				// Reference
				mata: std_surv("tmp`newvarname'_ref_b`b'", "`new_xbname'", "`touse'", "`timevar'", "`timevartouse'", `thisreatref')
				// Contrast
				quietly generate tmp`newvarname'_contrast_b`b' = tmp`newvarname'_b`b' - tmp`newvarname'_ref_b`b'
			}
			if ("`dots'" != "") {
				noisily _dots `b' 0
			}
		}
		if ("`cinormal'" == "") {
			display _newline "CIs calculated using the percentile method."
			// Process ps
			local plower = 100 * ((1 - `cilevel') / 2)
			local pupper = 100 * (1 - (1 - `cilevel') / 2)
			// Point estimate
			quietly egen `newvarname'_lower = rowpctile(tmp`newvarname'_b*), p(`plower')
			quietly egen `newvarname'_upper = rowpctile(tmp`newvarname'_b*), p(`pupper')
			if 	("`contrast'" != "") {
				// Ref
				quietly egen `newvarname'_ref_lower = rowpctile(tmp`newvarname'_ref_b*), p(`plower')
				quietly egen `newvarname'_ref_upper = rowpctile(tmp`newvarname'_ref_b*), p(`pupper')
				// Contrast
				quietly egen `newvarname'_contrast_lower = rowpctile(tmp`newvarname'_contrast_b*), p(`plower')
				quietly egen `newvarname'_contrast_upper = rowpctile(tmp`newvarname'_contrast_b*), p(`pupper')
			}
		}
		else {
			display _newline "CIs calculated using the normal approximation method."
			// Process critical values
			local crit = invnormal(1 - (1 - `cilevel') / 2)
			// Point estimate
			quietly egen `newvarname'_se = rowsd(tmp`newvarname'_b*)
			quietly gen `newvarname'_lower = `newvarname' - `crit' * `newvarname'_se
			quietly gen `newvarname'_upper = `newvarname' + `crit' * `newvarname'_se
			if 	("`contrast'" != "") {
				// Ref
				quietly egen `newvarname'_ref_se = rowsd(tmp`newvarname'_ref_b*)
				quietly gen `newvarname'_ref_lower = `newvarname'_ref - `crit' * `newvarname'_ref_se
				quietly gen `newvarname'_ref_upper = `newvarname'_ref + `crit' * `newvarname'_ref_se
				// Contrast
				quietly egen `newvarname'_contrast_se = rowsd(tmp`newvarname'_contrast_b*)
				quietly gen `newvarname'_contrast_lower = `newvarname'_contrast - `crit' * `newvarname'_contrast_se
				quietly gen `newvarname'_contrast_upper = `newvarname'_contrast + `crit' * `newvarname'_contrast_se
			}
			// Check if lower, upper outside of the correct bounds
			if 	("`contrast'" == "") {
				quietly count if `newvarname'_lower < 0 | `newvarname'_upper > 1
			}
			else {
				quietly count if `newvarname'_lower < 0 | `newvarname'_ref_lower < 0 | `newvarname'_contrast_lower < 0 | `newvarname'_upper > 1 | `newvarname'_ref_upper > 1 | `newvarname'_contrast_upper > 1
			}
			if (`r(N)' > 0) {
				display as error "Warning: some CIs have a lower/upper bound outsixde of the range [0, 1]."
			}
		}
		// Drop tmp variables
		capture drop tmp`newvarname'_b*
		capture drop tmp`newvarname'_ref_b*
		capture drop tmp`newvarname'_contrast_b*
		// Finally, restore estimation results
		erepost b = `eb'
	}

end

version 18.0
mata:

	void std_surv (
	string scalar out,
	string scalar xb,
	string scalar xbtouse,
	string scalar timevar,
	string scalar timevartouse,
	real scalar reat
	)
	{
		// process ancillary parameter
		// (depending on baseline hazard distribution)
		distribution = st_global("e(distribution)")
		if (distribution == "exponential") {
			ln_p = 0.0
		}
		else {
			eb = st_matrix("e(b)")
			clabels = st_matrixcolstripe("e(b)")
			s = (clabels[,2] :== "ln_p")
			s = s'
			ln_p = select(eb, s)
		}
		// view on timevar
		st_view(t = ., ., timevar, timevartouse)
		// view on linear predictor
		st_view(xbb = ., ., xb, xbtouse)
		// add fixed value of random intercept
		xbb = xbb :+ reat
		// do calculations for the std. survival, looping over timevar
		Savg = J(length(t), 1, .)
		for (i = 1; i <= length(t); i++) {
			Savg[i] = mean(survfun(xbb, t[i], ln_p))
		}
		// write out results
		outi = st_addvar("double", out)
		st_store(., outi, timevartouse, Savg)
	}

	real vector survfun (real vector xb, real scalar t, real scalar anc)
	{
		p = exp(anc)
		S = exp(-exp(xb) :* (t:^p))
		return(S)
	}

	void draw_newpars (real scalar B, string scalar newebname)
	{
		eb = st_matrix("e(b)")
		eV = st_matrix("e(V)")
		sds = sqrt(diagonal(eV))'
		neweb = rnormal(B, 1, eb, sds)
		st_matrix(newebname, neweb)
	}

	void draw_newreat (real scalar B, real scalar reat, real scalar reatse, string scalar newreatname)
	{
		newreat = rnormal(B, 1, reat, reatse)
		st_matrix(newreatname, newreat)
	}

end
