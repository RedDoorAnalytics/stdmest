*! version 0.0.0-9000 Alessandro Gasparini 26Oct2023

program define stdmest, sortpreserve
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

	// Check that we run stdmest after mestreg
	if "`e(cmd2)'" != "mestreg" {
		display as error "This only works after fitting an mestreg model."
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

	// Syntax
	syntax newvarname [if] [in], [ ///
		REAT(numlist) ///
		REATRef(numlist) ///
		REATSE(numlist) ///
		REATSERef(numlist) ///
		TIMEvar(varname) ///
		CONTRast ///
		CI ///
		CINORMal ///
		CILEVel(real 0.95) ///
		REPs(real 100) ///
		DOTS ///
		]

	// Mark which rows to use
	// (useful to standardise to a subset of the study data)
	marksample touse, novarlist
	local newvarname `varlist'

	// Now, force `touse' to be zero if _st == 0
	quietly replace `touse' = 0 if _st == 0

	// Number of levels for this specific model
	local nlevels = wordcount("`e(ivars)'")

	// Check how many elements in reat, reatse, reatref, reatseref
	local lreat = wordcount("`reat'")
	local lreatse = wordcount("`reatse'")
	local lreatref = wordcount("`reatref'")
	local lreatseref = wordcount("`reatseref'")

	// nlevels must be the same as lreat, lreatse, lreatref, lreatseref
	if ("`contrast'" == "") {
		if `nlevels' != `lreat' | `nlevels' != `lreatse' {
			local numerr = 1
		}
	}
	else {
		if `nlevels' != `lreat' | `nlevels' != `lreatse' | `nlevels' != `lreatref' | `nlevels' != `lreatseref' {
			local numerr = 1
		}
	}
	if ("`numerr'" == "1") {
		display as error "The mestreg model has more levels than the number of values passed to 'reat', 'reatse' (or 'reatref', 'reatseref' if you are trying to calculate contrasts)." ///
			_newline "Please check your input, they all must have the same number of elements as there are levels."
		exit 198
	}

	// Process reat, reatref
	local reat_sum = 0
	foreach x of local reat {
		local reat_sum = `reat_sum' + `x'
	}
	if ("`contrast'" != "") {
		local reatref_sum = 0
		foreach x of local reatref {
			local reatref_sum = `reatref_sum' + `x'
		}
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
	// This is a bug in the -predict- post-estimation command for -mestreg-
	// The following line will be unnecessary once fixed
	quietly replace `xbname' = . if `touse' != 1
	mata: std_surv("`newvarname'", "`xbname'", "`touse'", "`timevar'", "`timevartouse'", `reat_sum')

	// Create contrast if requested
	if ("`contrast'" != "") {
		// Reference
		mata: std_surv("`newvarname'_ref", "`xbname'", "`touse'", "`timevar'", "`timevartouse'", `reatref_sum')
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
		local vreat: subinstr local reat " " ", ", all
		local vreatse: subinstr local reatse " " ", ", all
		mata: draw_newreat(`reps', (`vreat'), (`vreatse'), "`newreat'")
		if ("`contrast'" != "") {
			local vreatref: subinstr local reatref " " ", ", all
			local vreatseref: subinstr local reatseref " " ", ", all
			mata: draw_newreat(`reps', (`vreatref'), (`vreatseref'), "`newreatref'")
		}
		// Iterate with dots (if required by the user)
		if ("`dots'" != "") {
			noisily _dots 0, reps(`reps')
		}
		// Local macro with ALL variables names, passed to -egen- later on
		// These will be concat'd in the loop below
		local iter_names = ""
		local iter_names_ref = ""
		local iter_names_contrast = ""
		// Loop over iterations
		forval b = 1/`reps' {
			// Repost new results
			tempname this_eb
			// Setup iteration values
			matrix `this_eb' = `neweb'[`b',....]
			local thisreat = `newreat'[`b',1]
			matrix rownames `this_eb' = `eb_rown'
			matrix colnames `this_eb' = `eb_coln'
			erepost b = `this_eb'
			tempvar new_xbname iter_`newvarname'_b`b'
			if ("`contrast'" != "") {
				local thisreatref = `newreatref'[`b',1]
				tempvar iter_`newvarname'_ref_b`b' iter_`newvarname'_contrast_b`b'
			}
			// Now, do stuff
			predict double `new_xbname' if `touse' == 1, xb
			// Doing the following because predict, xb after mestreg does not respect the if statement
			// This is a bug in the -predict- post-estimation command for -mestreg-
			// The following line will be unnecessary once fixed
			quietly replace `new_xbname' = . if `touse' != 1
			// Predict using new xb and pars
			mata: std_surv("`iter_`newvarname'_b`b''", "`new_xbname'", "`touse'", "`timevar'", "`timevartouse'", `thisreat')
			// Contrasts
			if 	("`contrast'" != "") {
				// Reference
				mata: std_surv("`iter_`newvarname'_ref_b`b''", "`new_xbname'", "`touse'", "`timevar'", "`timevartouse'", `thisreatref')
				// Contrast
				quietly generate `iter_`newvarname'_contrast_b`b'' = `iter_`newvarname'_b`b'' - `iter_`newvarname'_ref_b`b''
			}
			// Drop linear predictors
			quietly drop `new_xbname'
			// Concat names
			local iter_names = "`iter_names' `iter_`newvarname'_b`b''"
			local iter_names_ref = "`iter_names_ref' `iter_`newvarname'_ref_b`b''"
			local iter_names_contrast = "`iter_names_contrast' `iter_`newvarname'_contrast_b`b''"
			// Iterate
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
			quietly egen `newvarname'_lower = rowpctile(`iter_names'), p(`plower')
			quietly egen `newvarname'_upper = rowpctile(`iter_names'), p(`pupper')
			if 	("`contrast'" != "") {
				// Ref
				quietly egen `newvarname'_ref_lower = rowpctile(`iter_names_ref'), p(`plower')
				quietly egen `newvarname'_ref_upper = rowpctile(`iter_names_ref'), p(`pupper')
				// Contrast
				quietly egen `newvarname'_contrast_lower = rowpctile(`iter_names_contrast'), p(`plower')
				quietly egen `newvarname'_contrast_upper = rowpctile(`iter_names_contrast'), p(`pupper')
			}
		}
		else {
			display _newline "CIs calculated using the normal approximation method."
			// Process critical values
			local crit = invnormal(1 - (1 - `cilevel') / 2)
			// Point estimate
			quietly egen `newvarname'_se = rowsd(`iter_names')
			quietly gen `newvarname'_lower = `newvarname' - `crit' * `newvarname'_se
			quietly gen `newvarname'_upper = `newvarname' + `crit' * `newvarname'_se
			if 	("`contrast'" != "") {
				// Ref
				quietly egen `newvarname'_ref_se = rowsd(`iter_names_ref')
				quietly gen `newvarname'_ref_lower = `newvarname'_ref - `crit' * `newvarname'_ref_se
				quietly gen `newvarname'_ref_upper = `newvarname'_ref + `crit' * `newvarname'_ref_se
				// Contrast
				quietly egen `newvarname'_contrast_se = rowsd(`iter_names_contrast')
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
				display as error "Warning: some CIs have a lower/upper bound outside of the range [0, 1]."
			}
		}
		// Restore estimation results
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
		order_of_t = order(t, 1)
		invorder_of_t = invorder(order_of_t)
		unique_t = uniqrows(t, 1)
		// view on linear predictor
		st_view(xbb = ., ., xb, xbtouse)
		// add fixed value of random intercept
		xbb = xbb :+ reat
		// do calculations for the std. survival, looping over timevar
		// actually, we loop over _unique_ values of timevar to be more efficient,
		unique_Savg = J(rows(unique_t), 1, .)
		for (i = 1; i <= rows(unique_Savg); i++) {
			unique_Savg[i] = mean(survfun(xbb, unique_t[i,1], ln_p))
		}
		// Return to original size
		Savg = J(rows(t), 1, .)
		counter = 1
		for (i = 1; i <= rows(unique_Savg); i++) {
			for (j = 1; j <= unique_t[i,2]; j++) {
				Savg[counter] = unique_Savg[i]
				counter++
			}
		}
		Savg = Savg[invorder_of_t]
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
		svd(eV, U = ., s = ., Vt = .)
		C = U * (diag(s):^(1/2))
		draw = rnormal(B, cols(eb), 0, 1)
		if (missing(draw) > 0) {
			errprintf("Invalid samples for the confidence intervals algorithm. Please try again.\n")
			exit(198)
		}
		neweb = draw * C'
		for (i = 1; i <= cols(eb); i++) {
			neweb[.,i] = neweb[.,i] :+ eb[i]
		}
		st_matrix(newebname, neweb)
	}

	void draw_newreat (real scalar B, real vector reat, real vector reatse, string scalar newreatname)
	{
		fulldraw = J(B, cols(reat), .)
		for (i = 1; i <= cols(reat); i++) {
			fulldraw[.,i] = rnormal(B, 1, reat[i], reatse[i])
		}
		newreat = rowsum(fulldraw)
		st_matrix(newreatname, newreat)
	}

end
