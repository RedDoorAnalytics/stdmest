*! version 0.0.1-9000 Alessandro Gasparini 10Oct2024

local RS real scalar
local RC real colvector
local RR real rowvector
local SS string scalar
local RM real matrix

version 18.0
mata:

	void stdmest_wf(
	`SS' out,
	`RS' reat,
	`RS' reatref,
	`RR' vreat,
	`RR' vreatse,
	`RR' vreatref,
	`RR' vreatseref,
	`RS' integrate
	)
	{

		// read in locals from Stata
		// strings:
		timevar = st_local("timevar")
		timevartouse = st_local("timevartouse")
		// pickup rows to use
		touse = st_local("touse")
		// numbers:
		B = strtoreal(st_local("reps"))
		N = strtoreal(st_local("NNN"))
		level = strtoreal(st_local("level"))
		varmarg = strtoreal(st_local("vartoint"))
		nk = strtoreal(st_local("nk"))
		// flags
		hasci = st_local("ci") != ""
		hascinormal = st_local("cinormal") != ""
		hascontrast = st_local("contrast") != ""
		hasdots = st_local("dots") != ""

        // quadrature rule
        if (integrate) {
            GH = _gauss_hermite_nodes(nk)
		    GHx = GH[1,]
		    GHw = GH[2,]
		    // calculate dnrm, to be used later
		    dnrm = normalden(GHx :* sqrt(varmarg) :* sqrt(2.0), 0, sqrt(varmarg))
        }

		// view on timevar
		st_view(t = ., ., timevar, timevartouse)
		order_of_t = order(t, 1)
		invorder_of_t = invorder(order_of_t)
		unique_t = uniqrows(t, 1)
		Nuniqt = rows(unique_t)

		// figure out whether we need CIs or not
		// if we do, we need to run the algorithm B + 1 times,
		// otherwise we just do it once
		if (hasci) {
			Bp1 = B + 1
			// if we need CIs, draw new model parameters and random effects
			neweb = draw_newpars(B)
			newreat = draw_newreat(B, vreat, vreatse)
			newreat = rowsum(newreat)
			if (contrast != "") {
				newreatref = draw_newreat(B, vreatref, vreatseref)
				newreatref = rowsum(newreatref)
			}
			// bits for new model parameters
			eb_rown = st_local("eb_rown")
			eb_coln = st_local("eb_coln")
			// stack e(b) with neweb
			neweb = st_matrix("e(b)") \ neweb
		}
		else {
			neweb = st_matrix("e(b)")
			Bp1 = 1
		}

		// process ancillary parameter
		// (depending on baseline hazard distribution)
		distribution = st_global("e(distribution)")
		if (distribution == "exponential") {
			ln_p = J(Bp1, 1, 0.0)
		}
		else {
			clabels = st_matrixcolstripe("e(b)")
			s = (clabels[,2] :== "ln_p")'
			s = selectindex(s)
			ln_p = neweb[., s]
		}

		// matrix to store the linear predictors across repetitions
		xbmat = J(N, Bp1, .)
		xbbmat = J(N, Bp1, .)
		if (contrast != "") {
			xbbmatref = J(N, Bp1, .)
		}

		// temp column in data to use
		new_xbname = st_tempname()
		stata("tempvar " + new_xbname)

		// stata calls to drop old temp column (if any) and predict xb
		cmd_drop = "capture drop " + new_xbname
		cmd_predict = "quietly _predict double " + new_xbname + " if " + touse + " == 1, xb"

		// iterate with dots (if required by the user)
		if (dots != "") {
			stata("noisily _dots 0, reps(" + strofreal(B) + ")")
		}

		// loop over Bp1
		for (i = 1; i <= Bp1; i++) {
			if (i > 1) {
				tmpname = st_tempname()
				st_matrix(tmpname, neweb[i, ])
				stata("matrix rownames " + tmpname + " = " + eb_rown)
				stata("matrix colnames " + tmpname + " = " + eb_coln)
				stata("erepost b = " + tmpname)
			}
			stata(cmd_drop)
			stata(cmd_predict)
			xbmat[., i] = st_data(., new_xbname, touse) // copy back into Mata – might be inefficient?
			if (i == 1) {
				xbbmat[., i] = xbmat[., i] :+ reat
				if (hascontrast) {
					xbbmatref[., i] = xbmat[., i] :+ reatref
				}
			}
			else {
				xbbmat[., i] = xbmat[., i] :+ newreat[i - 1]
				if (hascontrast) {
					xbbmatref[., i] = xbmat[., i] :+ newreatref[i - 1]
				}
			}
			// iterate dots
			if (hasdots) {
				stata("noisily _dots " + strofreal(i) + " 0")
			}
		}

		// do calculations for the std. survival, looping over timevar
		// actually, we loop over _unique_ values of timevar to be more efficient
		unique_Savg = J(Nuniqt, Bp1, .)
		if (hascontrast) {
			unique_Savgref = J(Nuniqt, Bp1, .)
		}
		for (c = 1; c <= Bp1; c++) {
			for (r = 1; r <= Nuniqt; r++) {
                if (!integrate) {
                    unique_Savg[r, c] = mean(survfun(xbbmat[., c], unique_t[r, 1], ln_p[c, 1]))
                }
                else {
                    unique_Savg[r, c] = mean(intsurvfun(xbbmat[., c], unique_t[r, 1], ln_p[c, 1], varmarg, dnrm, GHx, GHw))
                }
				if (hascontrast) {
                    if (!integrate) {
                        unique_Savgref[r, c] = mean(survfun(xbbmatref[., c], unique_t[r, 1], ln_p[c, 1]))
                    }
                    else {
                        unique_Savgref[r, c] = mean(intsurvfun(xbbmatref[., c], unique_t[r, 1], ln_p[c, 1], varmarg, dnrm, GHx, GHw))
                    }
				}
			}
		}

		// return to original size
		Savg = J(rows(t), Bp1, .)
		if (hascontrast) {
			Savgref = J(rows(t), Bp1, .)
		}
		for (c = 1; c <= Bp1; c++) {
			counter = 1
			for (i = 1; i <= Nuniqt; i++) {
				for (j = 1; j <= unique_t[i, 2]; j++) {
					Savg[counter, c] = unique_Savg[i, c]
					if (hascontrast) {
						Savgref[counter, c] = unique_Savgref[i, c]
					}
					counter++
				}
			}
			Savg[., c] = Savg[invorder_of_t, c]
			if (hascontrast) {
				Savgref[., c] = Savgref[invorder_of_t, c]
			}
		}

		// write out results
		outi = st_addvar("double", out)
		st_store(., outi, timevartouse, Savg[, 1])

		// confidence intervals, if requested
		if (hasci) {
			// rescale level to 0-1
			level = level / 100
			// if we need CIs, compute
			Sci = Savg[|1,2 \ rows(t),Bp1|]
			_transpose(Sci)
			// add variables
			outi_lower = st_addvar("double", out + "_lower")
			outi_upper = st_addvar("double", out + "_upper")
			if (hascinormal) {
				// confidence intervals using the percentile method
				Sci_lower = mm_quantile(Sci, 1, (1 - level) / 2)
				Sci_upper = mm_quantile(Sci, 1, (1 - (1 - level) / 2))
				// transpose them
				_transpose(Sci_lower)
				_transpose(Sci_upper)
			}
			else {
				// otherwise, use the normal approximation method
				// (for symmetric CIs)
				crit = invnormal(1 - (1 - level) / 2)
				Sci_var = mm_colvar(Sci, 1)
				_transpose(Sci_var)
				Sci_lower = Savg[, 1] :- crit * sqrt(Sci_var)
				Sci_upper = Savg[, 1] :+ crit * sqrt(Sci_var)
				// note: there is no guarantee that CIs are in the [0, 1] range
			}
			st_store(., outi_lower, timevartouse, Sci_lower)
			st_store(., outi_upper, timevartouse, Sci_upper)
		}
		if (hascontrast) {
			outiref = st_addvar("double", out + "_ref")
			st_store(., outiref, timevartouse, Savgref[, 1])
			if (hasci) {
				// no need to rescale level to 0-1,
				// should already be done above
				// if we need CIs, compute
				Sciref = Savgref[|1,2 \ rows(t),Bp1|]
				_transpose(Sciref)
				// add variables
				outiref_lower = st_addvar("double", out + "_ref_lower")
				outiref_upper = st_addvar("double", out + "_ref_upper")
				if (hascinormal) {
					// confidence intervals using the percentile method
					Sciref_lower = mm_quantile(Sciref, 1, (1 - level) / 2)
					Sciref_upper = mm_quantile(Sciref, 1, (1 - (1 - level) / 2))
					// transpose them
					_transpose(Sciref_lower)
					_transpose(Sciref_upper)
				}
				else {
					// otherwise, use the normal approximation method
					// (for symmetric CIs)
					crit = invnormal(1 - (1 - level) / 2)
					Sciref_var = mm_colvar(Sciref, 1)
					_transpose(Sciref_var)
					Sciref_lower = Savgref[, 1] :- crit * sqrt(Sciref_var)
					Sciref_upper = Savgref[, 1] :+ crit * sqrt(Sciref_var)
					// note: there is no guarantee that CIs are in the [0, 1] range
				}
				st_store(., outiref_lower, timevartouse, Sciref_lower)
				st_store(., outiref_upper, timevartouse, Sciref_upper)
			}
			Savgcontrast = Savg :- Savgref
			outicontrast = st_addvar("double", out + "_contrast")
			st_store(., outicontrast, timevartouse, Savgcontrast[, 1])
			if (hasci) {
				// no need to rescale level to 0-1,
				// should already be done above
				// if we need CIs, compute
				Scicontrast = Savgcontrast[|1,2 \ rows(t),Bp1|]
				_transpose(Scicontrast)
				// add variables
				outicontrast_lower = st_addvar("double", out + "_contrast_lower")
				outicontrast_upper = st_addvar("double", out + "_contrast_upper")
				if (hascinormal) {
					// confidence intervals using the percentile method
					Scicontrast_lower = mm_quantile(Scicontrast, 1, (1 - level) / 2)
					Scicontrast_upper = mm_quantile(Scicontrast, 1, (1 - (1 - level) / 2))
					// transpose them
					_transpose(Scicontrast_lower)
					_transpose(Scicontrast_upper)
				}
				else {
					// otherwise, use the normal approximation method
					// (for symmetric CIs)
					crit = invnormal(1 - (1 - level) / 2)
					Scicontrast_var = mm_colvar(Scicontrast, 1)
					_transpose(Scicontrast_var)
					Scicontrast_lower = Savgcontrast[, 1] :- crit * sqrt(Scicontrast_var)
					Scicontrast_upper = Savgcontrast[, 1] :+ crit * sqrt(Scicontrast_var)
					// note: there is no guarantee that CIs are in the [0, 1] range
				}
				st_store(., outicontrast_lower, timevartouse, Scicontrast_lower)
				st_store(., outicontrast_upper, timevartouse, Scicontrast_upper)
			}
		}
	}

	`RC' survfun (`RC' xb, `RS' t, `RS' anc)
	{
		S = exp(-exp(xb) :* (t:^exp(anc)))
		return(S)
	}

	`RC' intsurvfun(
	`RC' xbb,
	`RS' t,
	`RS' anc,
	`RS' varmarg,
	`RR' dnrm,
	`RR' GHx,
	`RR' GHw)
	{
		S1 = J(rows(xbb), cols(GHx), .)
		tmp = log(sqrt(varmarg)) + log(sqrt(2))
		for (i = 1; i <= cols(S1); i++) {
			this_b = GHx[i] * exp(tmp)
			xbbb = xbb :+ this_b
			S1[,i] = survfun(xbbb, t, anc) * dnrm[i]
		}
		B = log(GHw) :+ (GHx:^2)
		B = exp(B)
		_transpose(B)
		Sint = exp(tmp) :* S1 * B
		return(Sint)
	}

	`RM' draw_newpars (`RS' B)
	{
		eb = st_matrix("e(b)")
		eV = st_matrix("e(V)")
		svd(eV, U = ., s = ., Vt = .)
		C = U * (diag(s):^(1/2))
		draw = rnormal(B, cols(eb), 0, 1)
		if (missing(draw)) {
			errprintf("Invalid samples for the confidence intervals algorithm. Please try again.\n")
			exit(198)
		}
		neweb = draw * C'
		for (i = 1; i <= cols(eb); i++) {
			neweb[.,i] = neweb[.,i] :+ eb[i]
		}
		return(neweb)
	}

	`RM' draw_newreat (`RS' B, `RR' reat, `RR' reatse)
	{
		Nc = cols(reat)
		fulldraw = J(B, Nc, .)
		for (i = 1; i <= Nc; i++) {
			fulldraw[.,i] = rnormal(B, 1, reat[i], reatse[i])
		}
		newreat = rowsum(fulldraw)
		return(newreat)
	}

end
