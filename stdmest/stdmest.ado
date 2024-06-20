*! version 0.0.1-9000 Alessandro Gasparini, Michael J. Crowther 19Jun2024

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
		Level(cilevel) ///
		REPs(integer 1000) ///
		DOTS ///
		]

	// Mark which rows to use
	// (useful, e.g., to standardise to a subset of the study data)
	marksample touse, novarlist
	local newvarname `varlist'

	// Now, force `touse' to be zero if _st == 0
	quietly replace `touse' = 0 if _st == 0

	// Count how many observations we are standardising over
	quietly count if `touse' == 1
	local NNN = `r(N)'

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
	local reatref_sum = 0
	foreach x of local reatref {
		local reatref_sum = `reatref_sum' + `x'
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

	// Create vectors with reat, reatse, reatref, reatseref
	local vreat: subinstr local reat " " ", ", all
	local vreatse: subinstr local reatse " " ", ", all
	if (`lreatref' == 0) {
		// if reatref or reatrefse are empty fill them with zeros
		forval i = 1/`lreat' {
			local reatref `reatref' 0
			local reatseref `reatseref' 0
		}
	}
	local vreatref : subinstr local reatref " " ", ", all
	local vreatseref : subinstr local reatseref " " ", ", all

	// Backup estimation results
	// (if we will calculate CIs)
	if "`ci'" != "" {
		tempname eb eV
		matrix `eb' = e(b)
		matrix `eV' = e(V)
		local eb_rown : rowfullnames e(b)
		local eb_coln : colfullnames e(b)
	}

	// Run algorithm in Mata
	mata: std_surv("`newvarname'", "`timevar'", `reat_sum', (`vreat'), (`vreatse'), "`ci'", "`cinormal'", `level', `reps', `NNN', "`contrast'", `reatref_sum', (`vreatref'), (`vreatseref'), "`dots'")

	// Restore estimation results after (possibly) fiddling with stuff in Mata
	if "`ci'" != "" {
		erepost b = `eb'
	}

end
