*! version 0.0.1-9000 Alessandro Gasparini 27May2025

local RS real scalar
local RC real colvector
local RR real rowvector
local SS string scalar
local RM real matrix
local gml struct uhtred_struct scalar

version 18.0
mata:

	void stdmest_wf(
	`SS' object,
	`SS' out,
	`RS' reat,
	`RS' reatref,
	`RR' vreat,
	`RR' vreatse,
	`RR' vreatref,
	`RR' vreatrefse,
	`RS' integrate
	)
	{
		// model flags
		i_am_mestreg = (st_global("e(cmd)") == "gsem") & (st_global("e(cmd2)") == "mestreg")
		i_am_uhtred = st_global("e(cmd)") == "uhtred"

		if (i_am_uhtred) {
			// pick GML object
			`gml' gml
			swap(gml, *findexternal(object))
		}

		// read in locals from Stata
		// strings:
		timevar = st_local("timevar")
		timevartouse = st_local("timevartouse")
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
		hasverbose = st_local("verbose") != ""
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
			// random effects:
			newreat = draw_newreat(B, vreat, vreatse)
			newreat = rowsum(newreat)
			if (contrast != "") {
				newreatref = draw_newreat(B, vreatref, vreatrefse)
				newreatref = rowsum(newreatref)
			}
			// model coefficients:
			neweb = draw_newpars(B)
			// stack e(b) with neweb
			neweb = st_matrix("e(b)") \ neweb
			// stack reat with newreat
			newreat = reat \ newreat
			if (hascontrast) {
				newreatref = reatref \ newreatref
			}
		}
		else {
			Bp1 = 1
			neweb = st_matrix("e(b)")
			newreat = J(1, 1, reat)
			if (hascontrast) {
				newreatref = J(1, 1, reatref)
			}
		}

		// setup once rather than inside survfun()
		touse = st_local("touse")
		// temp column in data to use
		new_xbname = st_tempname()
		stata("tempvar " + new_xbname)
		// stata calls to drop old temp column (if any) and predict xb
		cmd_drop = "capture drop " + new_xbname
		cmd_predict = "quietly _predict double " + new_xbname + " if " + touse + " == 1, xb"

		// do calculations for the std. survival, looping over timevar
		// actually, we loop over _unique_ values of timevar to be more efficient
		unique_Savg = J(Nuniqt, Bp1, .)
		if (hascontrast) {
			unique_Savgref = J(Nuniqt, Bp1, .)
		}
		for (c = 1; c <= Bp1; c++) {
			if (c == 1) {
				if (hasverbose) {
					printf("\n{text:Deriving point estimates...}\n")
				}
			}
			else if (c == 2) {
				if (hasverbose & hasci) {
					if (hasdots) {
						stata("noisily _dots 0, title(Calculating standardised survival probabilities for the C.I. algorithm...) reps(" + strofreal(B) + ")")
					}
				}
			}
			for (r = 1; r <= Nuniqt; r++) {
                if (!integrate) {
                    unique_Savg[r, c] = mean(survfun(gml, newreat[c, 1], unique_t[r, 1], c, neweb, i_am_mestreg, i_am_uhtred, new_xbname, cmd_drop, cmd_predict))
                }
                else {
                    unique_Savg[r, c] = mean(intsurvfun(newreat[c, 1], unique_t[r, 1], c, neweb, varmarg, dnrm, GHx, GHw))
                }
				if (hascontrast) {
                    if (!integrate) {
                        unique_Savgref[r, c] = mean(survfun(gml, newreatref[c, 1], unique_t[r, 1], c, neweb, i_am_mestreg, i_am_uhtred, new_xbname, cmd_drop, cmd_predict))
                    }
                    else {
                        unique_Savgref[r, c] = mean(intsurvfun(newreatref[c, 1], unique_t[r, 1], c, neweb, varmarg, dnrm, GHx, GHw))
                    }
				}
			}
			// iterate
			if (hasverbose) {
				if (c > 1 & hasdots) {
					stata("noisily _dots " + strofreal(c - 1) + " 0")
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
			// display progress (if required by the user)
			if (hasverbose) {
				printf("\n{text:Deriving confidence intervals...}")
			}
			// rescale level to 0-1
			level = level / 100
			// if we need CIs, compute
			Sci = Savg[|1,2 \ rows(t),Bp1|]
			_transpose(Sci)
			// add variables
			outi_lower = st_addvar("double", out + "_lower")
			outi_upper = st_addvar("double", out + "_upper")
			if (hascinormal) {
				// use the normal approximation method
				// (for symmetric CIs)
				crit = invnormal(1 - (1 - level) / 2)
				Sci = cloglog(Sci)
				Sci_var = mm_colvar(Sci, 1)
				_transpose(Sci_var)
				Sci_lower = cloglog(Savg[, 1]) :- crit * sqrt(Sci_var)
				Sci_upper = cloglog(Savg[, 1]) :+ crit * sqrt(Sci_var)
				Sci_lower = invcloglog(Sci_lower)
				Sci_upper = invcloglog(Sci_upper)
				// cloglog is not defined for 0, 1 – deal with that by hand
				Sci_lower = mm_cond(Savg[, 1] :>= 1, 1, Sci_lower)
				Sci_upper = mm_cond(Savg[, 1] :>= 1, 1, Sci_upper)
				Sci_lower = mm_cond(Savg[, 1] :<= 0, 0, Sci_lower)
				Sci_upper = mm_cond(Savg[, 1] :<= 0, 0, Sci_upper)
			}
			else {
				// otherwise, confidence intervals using the percentile method
				// (the default)
				Sci_lower = mm_quantile(Sci, 1, (1 - level) / 2)
				Sci_upper = mm_quantile(Sci, 1, (1 - (1 - level) / 2))
				// transpose them
				_transpose(Sci_lower)
				_transpose(Sci_upper)
			}
			st_store(., outi_lower, timevartouse, Sci_lower)
			st_store(., outi_upper, timevartouse, Sci_upper)
		}
		if (hascontrast) {
			// display progress (if required by the user)
			if (hasverbose) {
				printf("\n{text:Deriving contrasts...}")
			}
			//
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
					// use the normal approximation method
					// (for symmetric CIs)
					crit = invnormal(1 - (1 - level) / 2)
					Sciref = cloglog(Sciref)
					Sciref_var = mm_colvar(Sciref, 1)
					_transpose(Sciref_var)
					Sciref_lower = cloglog(Savgref[, 1]) :- crit * sqrt(Sciref_var)
					Sciref_upper = cloglog(Savgref[, 1]) :+ crit * sqrt(Sciref_var)
					Sciref_lower = invcloglog(Sciref_lower)
					Sciref_upper = invcloglog(Sciref_upper)
					// cloglog is not defined for 0, 1 – deal with that by hand
					Sciref_lower = mm_cond(Savgref[, 1] :>= 1, 1, Sciref_lower)
					Sciref_upper = mm_cond(Savgref[, 1] :>= 1, 1, Sciref_upper)
					Sciref_lower = mm_cond(Savgref[, 1] :<= 0, 0, Sciref_lower)
					Sciref_upper = mm_cond(Savgref[, 1] :<= 0, 0, Sciref_upper)
				}
				else {
					// otherwise, confidence intervals using the percentile method
					// (the default)
					Sciref_lower = mm_quantile(Sciref, 1, (1 - level) / 2)
					Sciref_upper = mm_quantile(Sciref, 1, (1 - (1 - level) / 2))
					// transpose them
					_transpose(Sciref_lower)
					_transpose(Sciref_upper)
				}
				st_store(., outiref_lower, timevartouse, Sciref_lower)
				st_store(., outiref_upper, timevartouse, Sciref_upper)
			}
			Savgcontrast = Savg :- Savgref
			outicontrast = st_addvar("double", out + "_contrast")
			st_store(., outicontrast, timevartouse, Savgcontrast[, 1])
			if (hasci) {
				// display progress (if required by the user)
				if (hasverbose) {
					printf("\n{text:Deriving confidence intervals of contrasts...}")
				}
				// no need to rescale level to 0-1,
				// should already be done above
				// if we need CIs, compute
				Scicontrast = Savgcontrast[|1,2 \ rows(t),Bp1|]
				_transpose(Scicontrast)
				// add variables
				outicontrast_lower = st_addvar("double", out + "_contrast_lower")
				outicontrast_upper = st_addvar("double", out + "_contrast_upper")
				if (hascinormal) {
					// use the normal approximation method
					// (for symmetric CIs)
					crit = invnormal(1 - (1 - level) / 2)
					Scicontrast_var = mm_colvar(Scicontrast, 1)
					_transpose(Scicontrast_var)
					Scicontrast_lower = Savgcontrast[, 1] :- crit * sqrt(Scicontrast_var)
					Scicontrast_upper = Savgcontrast[, 1] :+ crit * sqrt(Scicontrast_var)
					// note: there is no guarantee that CIs are in the [-1, 1] range
				}
				else {
					// otherwise, confidence intervals using the percentile method
					// (the default)
					Scicontrast_lower = mm_quantile(Scicontrast, 1, (1 - level) / 2)
					Scicontrast_upper = mm_quantile(Scicontrast, 1, (1 - (1 - level) / 2))
					// transpose them
					_transpose(Scicontrast_lower)
					_transpose(Scicontrast_upper)
				}
				st_store(., outicontrast_lower, timevartouse, Scicontrast_lower)
				st_store(., outicontrast_upper, timevartouse, Scicontrast_upper)
			}
		}

		// display progress (if required by the user)
		if (hasverbose) {
			printf("\n{text:Done!}\n")
		}
	}

	`RC' survfun (
	`gml' gml,
	`RS' re,
	`RS' t,
	`RS' i,
	`RM' neweb,
	`RS' i_am_mestreg,
	`RS' i_am_uhtred,
	`SS' new_xbname,
	`SS' cmd_drop,
	`SS' cmd_predict)
	{
		// if t == 0 force survival to 1 and ignore the rest
		if (t == 0) {
			S = J(strtoreal(st_local("NNN")), 1, 1)
			return(S)
		}

		// If -mestreg-:
		if (i_am_mestreg) {
			// repost if doing CIs
			if (i > 1) {
				tmpname = st_tempname()
				st_matrix(tmpname, neweb[i, ])
				// bits for new model parameters
				eb_rown = st_local("eb_rown")
				eb_coln = st_local("eb_coln")
				stata("matrix rownames " + tmpname + " = " + eb_rown)
				stata("matrix colnames " + tmpname + " = " + eb_coln)
				stata("erepost b = " + tmpname)
			}
			// process ancillary parameter
			// (depending on baseline hazard distribution)
			distribution = st_global("e(distribution)")
			if (distribution == "exponential") {
				anc = 0.0
			}
			else {
				clabels = st_matrixcolstripe("e(b)")
				s = (clabels[,2] :== "ln_p")'
				s = selectindex(s)
				anc = neweb[i, s]
			}
			// pickup rows to use
			touse = st_local("touse")
			// drop old temp column (if any) and predict xb
			stata(cmd_drop)
			stata(cmd_predict)
			// get xb
			xb = J(strtoreal(st_local("NNN")), 1, .)
			xb = st_data(., new_xbname, touse)
			// combine xb with re
			xbb = xb :+ re
			// calculate survival for exponential/Weibull:
			S = exp(-exp(xbb) :* (t:^exp(anc)))
		}

		// If -uhtred-:
		if (i_am_uhtred) {
			gml.myb = neweb[i, ]
			// linear predictor
			xb = uhtred_util_p_xb(gml)
			// time component
			nobs = uhtred_util_nobs(gml)
			tb = uhtred_util_p_tb(gml, J(nobs, 1, t))
			xbbb = xb :+ tb :+ re
			// calculate survival
			S = exp(-exp(xbbb))
		}

		// Return survival
		return(S)
	}

	`RC' intsurvfun(
	`RS' re,
	`RS' t,
	`RS' i,
	`RM' neweb,
	`RS' varmarg,
	`RR' dnrm,
	`RR' GHx,
	`RR' GHw)
	{
		S1 = J(rows(xbb), cols(GHx), .)
		tmp = log(sqrt(varmarg)) + log(sqrt(2))
		for (j = 1; j <= cols(S1); j++) {
			this_b = GHx[j] * exp(tmp)
			this_b = this_b + re
			S1[,j] = survfun(this_b, t, i, neweb) * dnrm[j]
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
			errprintf("\nInvalid samples for the confidence intervals algorithm. Please try again.\n")
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
