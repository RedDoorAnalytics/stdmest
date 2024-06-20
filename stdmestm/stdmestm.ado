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
	mata: std_isurv("`newvarname'", "`xbname'", "`touse'", "`timevar'", "`timevartouse'", `reat', `reatse', `reatref', `reatseref', `vartoint', `nk', `reps', "`ci'", "`cinormal'", `level', "`contrast'", "`dots'", `NNN')

	// Confidence intervals using bootstrap-like procedure
	/* if ("`ci'" != "") {
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
			// Pick new variance
			local this_vartoint = _b[/var(_cons[`varmargname'])]
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
			mata: std_isurv("`iter_`newvarname'_b`b''", "`new_xbname'", "`touse'", "`timevar'", "`timevartouse'", `thisreat', `this_vartoint', "`kx'", "`kw'")
			// Contrasts
			if 	("`contrast'" != "") {
				// Reference
				mata: std_isurv("`iter_`newvarname'_ref_b`b''", "`new_xbname'", "`touse'", "`timevar'", "`timevartouse'", `thisreatref', `this_vartoint', "`kx'", "`kw'")
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
			local plower = 100 * ((1 - (`level'/100)) / 2)
			local pupper = 100 * (1 - (1 - (`level'/100)) / 2)
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
			local crit = invnormal(1 - (1 - (`level'/100)) / 2)
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
				quietly count if `newvarname'_lower < 0 | (`newvarname'_upper > 1 & `newvarname'_upper != .)
				local errtxt "Warning: some CIs have a lower/upper bound outside of the range [0, 1]."
			}
			else {
				quietly count if `newvarname'_lower < 0 | `newvarname'_ref_lower < 0 | `newvarname'_contrast_lower < -1 | (`newvarname'_upper > 1 & `newvarname'_upper != .) | (`newvarname'_ref_upper > 1 & `newvarname'_ref_upper != .) | (`newvarname'_ref_upper > 1 & `newvarname'_ref_upper != .)
				local errtxt "Warning: some CIs have a lower/upper bound outside of the range [0, 1] (or [-1, 1] for contrasts)."
			}
			if (`r(N)' > 0) {
				display as error "`errtxt'"
			}
		}
		// Restore estimation results
		erepost b = `eb'
	} */

	// Restore estimation results after (possibly) fiddling with stuff in Mata
	if "`ci'" != "" {
		erepost b = `eb'
	}

end
