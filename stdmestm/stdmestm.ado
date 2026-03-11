*! version 0.2.0 Alessandro Gasparini, Michael J. Crowther 11Mar2026

program define stdmestm, sortpreserve
	// Version
	version 18.0

	// Check that dataset is still stset
	st_is 2 analysis

	// Check that -erepost- is installed
	capture which erepost
	if _rc > 0 {
		display as error "The -erepost- command is required for -stdmest- to function properly. You can install it using:"
		display as error ". {stata ssc install erepost}"
		exit  198
	}

	// Check that -uhtred- is installed
	capture which uhtred
	if _rc > 0 {
		display as error "The -uhtred- command is required for -stdmest- to function properly. You can install it using:"
		display as error ". {net install uhtred, from(https://raw.githubusercontent.com/RedDoorAnalytics/uhtred/main/)}"
		exit  198
	}

	// Check that -moremata- is installed
	capture findfile lmoremata.mlib
	if _rc > 0 {
		display as error "The -moremata- package is required for -stdmest- to function properly. You can install it using:"
		display as error ". {stata ssc install moremata}"
		exit  198
	}

	// Check that we run stdmest after -mestreg- or -uhtred-
	if !("`e(cmd)'" == "gsem" & "`e(cmd2)'" == "mestreg") & !("`e(cmd)'" == "uhtred") {
		display as error "This only works after fitting a mixed-effects survival model with -mestreg- or -uhtred-."
		exit 301
	}

	// Special checks for -mestreg-:
	if "`e(cmd)'" == "gsem" & "`e(cmd2)'" == "mestreg" {
		// Only support -mestreg- PH models
		if "`e(frm2)'" != "hazard" {
			display as error "Only proportional hazards models are supported."
			exit 198
		}
		// Only support exponential and Weibull distributions (for now)
		if "`e(distribution)'" != "exponential" & "`e(distribution)'" != "weibull" {
			display as error "Only exponential and Weibull baseline hazard distributions are supported."
			exit 198
		}
	}

	// Number of levels for this specific model
	if "`e(cmd)'" == "gsem" & "`e(cmd2)'" == "mestreg" {
		local nlevels = wordcount("`e(ivars)'") + 1
	}
	if "`e(cmd)'" == "uhtred" {
		local nlevels = `e(Nlevels)'
	}

	// Must be a three-levels model
	if (`nlevels' != 3) {
		display as error "Only three-level models are supported, but `nlevels' were detected.
		exit 198
	}

	// Syntax
	syntax newvarname [if] [in], [ ///
		REAT(real 0.0) ///
		REATREF(real 0.0) ///
		REATSE(real 0.0) ///
		REATREFSE(real 0.0) ///
		TIMEvar(varname) ///
		CONTRast ///
		CI ///
		CINORMal ///
		Level(cilevel) ///
		REPs(integer 1000) ///
		VERBose ///
		DOTS ///
		NK(integer 7) ///
		VARMARG(real 0.0) ///
		]

	// Check that 'newvarname' is not too long
	// (we will append up to 9 characters: e.g., _diff_lci)
	local newvarnamelength = strlen("`newvarname'")
	if (`newvarnamelength' > 23) {
		display as error "Name `newvarname' is likely too long: please use a shorter name to avoid hitting Stata's 32 characters limit."
		exit 198
	}

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
	capture local vartoint = `varmarg'

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

	// If -uhtred-, setup gml object
	if ("`e(cmd)'" == "uhtred") {
		// from: uhtred_p.ado
		tempname GML
		capture mata: rmexternal("`GML'")
		// Get coefficients and refill struct
		tempname best
		mat `best' = e(b)
		// Remove any options
		local cmd `e(cmdline)'
		gettoken uhtred cmd : cmd
        gettoken cmd rhs : cmd, parse(",") bind
        if substr("`rhs'",1,1) == "," {
			local opts substr("`rhs'",2,.)
			local 0 , `opts'
			syntax , [						///
				COVariance(passthru)		///
                REDISTribution(passthru)	///
                DF(passthru)				///
                Weights(passthru)			///
                *							///
            ]
            local opts `covariance' `redistribution' `df' `weights'
		}
		// Recall uhtred
		tempname tousem
		quietly `noisily' uhtred_parse `GML' ,          ///
			touse(`tousem') : `cmd' ///
            , 		///
            `opts'				///
            predict 			///
            predtouse(`touse')		///
            nogen 				///
			from(`best') 			///
			`intmethods' 			///
			`intpoints' 			///
			`pchintpoints'			///
			`ptvar'				///
			`standardise'			///
			`passtmat'			///
			`reffects'			///
			`reses'				///
			`devcodes'			///
			indicator(`e(indicator)')       ///
			`debug'                         //

        // Tidy up constraints
		local mlcns		`"`r(constr)'"'
		if "`mlcns'" != "" {
			cap constraint drop `mlcns'
		}
	}

	// Run algorithm in Mata
	mata: stdmest_wf("`GML'", "`newvarname'", `reat', `reatref', (`reat'), (`reatse'), (`reatref'), (`reatrefse'), 1.0)

	// Restore estimation results after (possibly) fiddling with stuff in Mata
	if "`ci'" != "" {
		erepost b = `eb'
	}

	// Tidy up after -uhtred-
	capture mata: rmexternal("`GML'")

end
