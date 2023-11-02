*! version 0.0.0-9000 Alessandro Gasparini 02Nov2023

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

	// Number of levels for this specific model
	// Must be a three-levels model (nlevels == 2)
	local nlevels = wordcount("`e(ivars)'")
	if (`nlevels' != 2) {
		display as error "Only three-level models are supported – `=`nlevels'+1' were detected.
		exit 198
	}

	// TO CHECK: varmargname must be one of the names in _b

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
		REPs(integer 100) ///
		DOTS ///
		NK(integer 7) ///
		VARMARGname(string) ///
		]

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

	// Get nodes and weights for Gauss-Hermite quadrature
	tempname kx kw
	mata: ghq(`nk', "`kx'", "`kw'")

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
	mata: std_isurv("`newvarname'", "`xbname'", "`touse'", "`timevar'", "`timevartouse'", `reat', `vartoint', "`kx'", "`kw'")

end

version 18.0
mata:
	void ghq (
		real scalar nk,
		string scalar GHxname,
		string scalar GHwname
	)
	{
		GH = _gauss_hermite_nodes(nk)
		GHx = GH[1,]
		GHw = GH[2,]
		st_matrix(GHxname, GHx)
		st_matrix(GHwname, GHw)
	}

	void std_isurv (
	string scalar out,
	string scalar xb,
	string scalar xbtouse,
	string scalar timevar,
	string scalar timevartouse,
	real scalar reat,
	real scalar varmarg,
	string scalar GHxname,
	string scalar GHwname
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
		// pick quadrature nodes, weights
		GHx = st_matrix(GHxname)
		GHw = st_matrix(GHwname)
		// calculate dnrm, to be used later
		dnrm = normalden(GHx :* sqrt(varmarg) :* sqrt(2.0), 0, sqrt(varmarg))
		// do calculations for the std. integrated survival, looping over timevar
		// actually, we loop over _unique_ values of timevar to be more efficient,
		unique_Savg = J(rows(unique_t), 1, .)
		for (i = 1; i <= rows(unique_Savg); i++) {
			unique_Savg[i] = mean(intsurvfun(xbb, reat, unique_t[i,1], ln_p, varmarg, dnrm, GHx, GHw))
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

	real vector survfun (
	real vector xb,
	real scalar b,
	real scalar t,
	real scalar anc
	)
	{
		p = exp(anc)
		xbb = xb :+ b
		S = exp(-exp(xbb) :* (t:^p))
		return(S)
	}

	real vector intsurvfun (
	real vector xb,
	real scalar b,
	real scalar t,
	real scalar anc,
	real scalar varmarg,
	real vector dnrm,
	real vector GHx,
	real vector GHw
	)
	{
		S1 = J(rows(xb), cols(GHx), .)
		tmp = sqrt(varmarg) * sqrt(2)
		for (i = 1; i <= cols(S1); i++) {
			this_b = b + GHx[i] * tmp
			S1[,i] = survfun(xb, this_b, t, anc) * dnrm[i]
		}
		Sint = tmp :* S1
		Sint = (tmp :* S1) * ((GHw :* exp(GHx:^2))')
		return(Sint)
	}

end
