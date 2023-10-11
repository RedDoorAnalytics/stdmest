*! version 0.0.0-9000 Alessandro Gasparini 11Oct2023

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
		quietly generate double `tv' = _t
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
	predict double `xbname', xb
	if ("`e(distribution)'" == "exponential") {
		mata: std_surv("`newvarname'", "`xbname'", "`timevar'", "`timevartouse'", `reat', 0.0, 1)
	}
	else if ("`e(distribution)'" == "weibull") {
		local lnp = _b["/:ln_p"]
		mata: std_surv("`newvarname'", "`xbname'", "`timevar'", "`timevartouse'", `reat', `lnp', 2)
	}

	// Create contrast if requested
	if ("`contrast'" != "") {
		// Reference
		if ("`e(distribution)'" == "exponential") {
			mata: std_surv("`newvarname'_ref", "`xbname'", "`timevar'", "`timevartouse'", `reatref', 0.0, 1)
		}
		else if ("`e(distribution)'" == "weibull") {
			local lnp = _b["/:ln_p"]
			mata: std_surv("`newvarname'_ref", "`xbname'", "`timevar'", "`timevartouse'", `reatref', `lnp', 2)
		}
		// Calculate contrast
		quietly generate `newvarname'_contrast = `newvarname' - `newvarname'_ref
	}

	// Confidence intervals using bootstrap-like procedure
	if ("`ci'" != "") {
		// Store original estimation results
		tempname eb eV neweb newreat newreatref
		matrix `eb' = e(b)
		matrix `eV' = e(V)
		local eb_rown: rowfullnames e(b)
		local eb_coln: colfullnames e(b)
		mata: draw_newpars(`reps', "`neweb'")
		mata: draw_newreat(`reps', `reat', `reatse', "`newreat'")
		mata: draw_newreat(`reps', `reatref', `reatseref', "`newreatref'")
		//
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
			predict double `new_xbname', xb
			// Predict using new xb and pars
			if ("`e(distribution)'" == "exponential") {
				mata: std_surv("tmp`newvarname'_b`b'", "`new_xbname'", "`timevar'", "`timevartouse'", `thisreat', 0.0, 1)
			}
			else if ("`e(distribution)'" == "weibull") {
				local lnp = _b["/:ln_p"]
				mata: std_surv("tmp`newvarname'_b`b'", "`new_xbname'", "`timevar'", "`timevartouse'", `thisreat', `lnp', 2)
			}
			// Contrasts
			if 	("`contrast'" != "") {
				// Reference
				if ("`e(distribution)'" == "exponential") {
					mata: std_surv("tmp`newvarname'_ref_b`b'", "`new_xbname'", "`timevar'", "`timevartouse'", `thisreatref', 0.0, 1)
				}
				else if ("`e(distribution)'" == "weibull") {
					local lnp = _b["/:ln_p"]
					mata: std_surv("tmp`newvarname'_ref_b`b'", "`new_xbname'", "`timevar'", "`timevartouse'", `thisreatref', `lnp', 2)
				}
				// Contrast
				quietly generate tmp`newvarname'_contrast_b`b' = tmp`newvarname'_b`b' - tmp`newvarname'_ref_b`b'
			}
			if ("`dots'" != "") {
				noisily _dots `b' 0
			}
		}
		if ("`cinormal'" == "") {
			display "CIs with percentile method."
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
			display "CIs with normal approximation method."
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
		}
		// Drop tmp variables
		capture drop tmp`newvarname'_b*
		capture drop tmp`newvarname'_ref_b*
		capture drop tmp`newvarname'_contrast_b*
		// If CIs with normal method, drop SEs
		if ("`cinormal'" == "") {
		}
		else {
			drop `newvarname'_se
			if ("`contrast'" != "") {
				drop `newvarname'_ref_se
				drop `newvarname'_contrast_se
			}
		}
		// Finally, restore estimation results
		erepost b = `eb'
	}

end

version 18.0
mata:

	void std_surv (
	string scalar out,
	string scalar xb,
	string scalar timevar,
	string scalar touse,
	real scalar reat,
	real scalar anc,
	real scalar distr
	)
	{
		// view on timevar
		st_view(t = ., ., timevar, touse)
		// view on linear predictor
		st_view(xbb = ., ., xb)
		// add fixed value of random intercept
		xbb = xbb :+ reat
		// do calculations for the std. survival, looping over time points
		Savg = J(length(t), 1, .)
		for (i = 1; i <= length(t); i++) {
			Savg[i] = mean(survfun(xbb, t[i], anc, distr))
		}
		outi = st_addvar("double", out)
		st_store(., outi, touse, Savg)
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
