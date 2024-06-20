*! version 0.0.1-9000 Alessandro Gasparini 20Jun2024

local RS real scalar
local RC real colvector
local RR real rowvector
local SS string scalar

version 18.0
mata:

	void std_isurv(
	`SS' out,
	`SS' timevar,
	`RS' reat,
	`RS' reatse,
	`RS' reatref,
	`RS' reatseref,
	`RS' varmarg,
	`RS' nk,
	`RS' B,
	`SS' ci,
	`SS' cinormal,
	`RS' level,
	`SS' contrast,
	`SS' dots,
	`RS' N)
	{
		// quadrature rule
		GH = _gauss_hermite_nodes(nk)
		GHx = GH[1,]
		GHw = GH[2,]
		// calculate dnrm, to be used later
		dnrm = normalden(GHx :* sqrt(varmarg) :* sqrt(2.0), 0, sqrt(varmarg))

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
		st_view(t = ., ., timevar, st_local("timevartouse"))
		order_of_t = order(t, 1)
		invorder_of_t = invorder(order_of_t)
		unique_t = uniqrows(t, 1)
		Nuniqt = rows(unique_t)
		// figure out whether we need CIs or not
		// if we do, we need to run the algorithm B + 1 times,
		// otherwise we just do it once
		if (ci != "") {
			Bp1 = B + 1
			// if we need CIs, draw new model parameters and random effects
			neweb = draw_newpars(B)
			newreat = draw_newreat(B, reat, reatse)
			if (contrast != "") {
				newreatref = draw_newreat(B, reatref, reatseref)
			}
			// bits for new model parameters
			eb_rown = st_local("eb_rown")
			eb_coln = st_local("eb_coln")
		}
		else {
			Bp1 = 1
		}
		// matrix to store the linear predictors across repetitions
		xbmat = J(N, Bp1, .)
		xbbmat = J(N, Bp1, .)
		if (contrast != "") {
			xbbmatref = J(N, Bp1, .)
		}
		// pickup rows to use
		st_view(touse, ., st_local("touse"))
		// temp column in data to use
		new_xbname = st_tempname()
		stata("tempvar " + new_xbname)
		// stata calls to drop old temp column (if any) and predict xb
		cmd_drop = "capture drop " + new_xbname
		cmd_predict = "quietly _predict double " + new_xbname + " if " + st_local("touse") + " == 1, xb"
		// iterate with dots (if required by the user)
		if (dots != "") {
			stata("noisily _dots 0, reps(" + strofreal(B) + ")")
		}

		// loop over Bp1
		for (i = 1; i <= Bp1; i++) {
			if (i > 1) {
				tmpname = st_tempname()
				st_matrix(tmpname, neweb[i - 1, ])
				stata("matrix rownames " + tmpname + " = " + eb_rown)
				stata("matrix colnames " + tmpname + " = " + eb_coln)
				stata("erepost b = " + tmpname)
			}
			stata(cmd_drop)
			stata(cmd_predict)
			xbmat[., i] = st_data(., new_xbname, st_local("touse")) // copy back into Mata – might be inefficient?
			if (i == 1) {
				xbbmat[., i] = xbmat[., i] :+ reat
				if (contrast != "") {
					xbbmatref[., i] = xbmat[., i] :+ reatref
				}
			}
			else {
				xbbmat[., i] = xbmat[., i] :+ newreat[i - 1]
				if (contrast != "") {
					xbbmatref[., i] = xbmat[., i] :+ newreatref[i - 1]
				}
			}
			// iterate dots
			if (dots != "") {
				stata("noisily _dots " + strofreal(i) + " 0")
			}
		}

		// do calculations for the std. integrated survival, looping over timevar
		// actually, we loop over _unique_ values of timevar to be more efficient,
		unique_Savg = J(Nuniqt, Bp1, .)
		if (contrast != "") {
			unique_Savgref = J(Nuniqt, Bp1, .)
		}
		for (c = 1; c <= Bp1; c++) {
			for (r = 1; r <= Nuniqt; r++) {
				unique_Savg[r, c] = mean(intsurvfun(xbbmat[.,c], unique_t[r,1], ln_p, varmarg, dnrm, GHx, GHw))
				if (contrast != "") {
					unique_Savgref[r, c] = mean(intsurvfun(xbbmatref[.,c], unique_t[r,1], ln_p, varmarg, dnrm, GHx, GHw))
				}
			}
		}
		// return to original size
		Savg = J(rows(t), Bp1, .)
		if (contrast != "") {
			Savgref = J(rows(t), Bp1, .)
		}
		for (c = 1; c <= Bp1; c++) {
			counter = 1
			for (i = 1; i <= Nuniqt; i++) {
				for (j = 1; j <= unique_t[i,2]; j++) {
					Savg[counter, c] = unique_Savg[i, c]
					if (contrast != "") {
						Savgref[counter, c] = unique_Savgref[i, c]
					}
					counter++
				}
			}
			Savg[., c] = Savg[invorder_of_t, c]
			if (contrast != "") {
				Savgref[., c] = Savgref[invorder_of_t, c]
			}
		}
		// write out results
		outi = st_addvar("double", out)
		st_store(., outi, st_local("timevartouse"), Savg[, 1])

		// confidence intervals, if requested
		if (ci != "") {
			// rescale level to 0-1
			level = level / 100
			// if we need CIs, compute
			Sci = Savg[|1,2 \ rows(t),Bp1|]
			Sci = Sci'
			// add variables
			outi_lower = st_addvar("double", out + "_lower")
			outi_upper = st_addvar("double", out + "_upper")
			if (cinormal == "") {
				// confidence intervals using the percentile method
				Sci_lower = mm_quantile(Sci, 1, (1 - level) / 2)
				Sci_upper = mm_quantile(Sci, 1, (1 - (1 - level) / 2))
				// transpose them
				Sci_lower = Sci_lower'
				Sci_upper = Sci_upper'
			}
			else {
				// otherwise, use the normal approximation method
				// (for symmetric CIs)
				crit = invnormal(1 - (1 - level) / 2)
				Sci_var = mm_colvar(Sci, 1)
				Sci_var = Sci_var'
				Sci_lower = Savg[, 1] :- crit * sqrt(Sci_var)
				Sci_upper = Savg[, 1] :+ crit * sqrt(Sci_var)
				// note: there is no guarantee that CIs are in the [0, 1] range
			}
			st_store(., outi_lower, st_local("timevartouse"), Sci_lower)
			st_store(., outi_upper, st_local("timevartouse"), Sci_upper)
		}
		if (contrast != "") {
			outiref = st_addvar("double", out + "_ref")
			st_store(., outiref, st_local("timevartouse"), Savgref[, 1])
			if (ci != "") {
				// no need to rescale level to 0-1,
				// should already be done above
				// if we need CIs, compute
				Sciref = Savgref[|1,2 \ rows(t),Bp1|]
				Sciref = Sciref'
				// add variables
				outiref_lower = st_addvar("double", out + "_ref_lower")
				outiref_upper = st_addvar("double", out + "_ref_upper")
				if (cinormal == "") {
					// confidence intervals using the percentile method
					Sciref_lower = mm_quantile(Sciref, 1, (1 - level) / 2)
					Sciref_upper = mm_quantile(Sciref, 1, (1 - (1 - level) / 2))
					// transpose them
					Sciref_lower = Sciref_lower'
					Sciref_upper = Sciref_upper'
				}
				else {
					// otherwise, use the normal approximation method
					// (for symmetric CIs)
					crit = invnormal(1 - (1 - level) / 2)
					Sciref_var = mm_colvar(Sciref, 1)
					Sciref_var = Sciref_var'
					Sciref_lower = Savgref[, 1] :- crit * sqrt(Sciref_var)
					Sciref_upper = Savgref[, 1] :+ crit * sqrt(Sciref_var)
					// note: there is no guarantee that CIs are in the [0, 1] range
				}
				st_store(., outiref_lower, st_local("timevartouse"), Sciref_lower)
				st_store(., outiref_upper, st_local("timevartouse"), Sciref_upper)
			}
			Savgcontrast = Savg :- Savgref
			outicontrast = st_addvar("double", out + "_contrast")
			st_store(., outicontrast, st_local("timevartouse"), Savgcontrast[, 1])
			if (ci != "") {
				// no need to rescale level to 0-1,
				// should already be done above
				// if we need CIs, compute
				Scicontrast = Savgcontrast[|1,2 \ rows(t),Bp1|]
				Scicontrast = Scicontrast'
				// add variables
				outicontrast_lower = st_addvar("double", out + "_contrast_lower")
				outicontrast_upper = st_addvar("double", out + "_contrast_upper")
				if (cinormal == "") {
					// confidence intervals using the percentile method
					Scicontrast_lower = mm_quantile(Scicontrast, 1, (1 - level) / 2)
					Scicontrast_upper = mm_quantile(Scicontrast, 1, (1 - (1 - level) / 2))
					// transpose them
					Scicontrast_lower = Scicontrast_lower'
					Scicontrast_upper = Scicontrast_upper'
				}
				else {
					// otherwise, use the normal approximation method
					// (for symmetric CIs)
					crit = invnormal(1 - (1 - level) / 2)
					Scicontrast_var = mm_colvar(Scicontrast, 1)
					Scicontrast_var = Scicontrast_var'
					Scicontrast_lower = Savgcontrast[, 1] :- crit * sqrt(Scicontrast_var)
					Scicontrast_upper = Savgcontrast[, 1] :+ crit * sqrt(Scicontrast_var)
					// note: there is no guarantee that CIs are in the [0, 1] range
				}
				st_store(., outicontrast_lower, st_local("timevartouse"), Scicontrast_lower)
				st_store(., outicontrast_upper, st_local("timevartouse"), Scicontrast_upper)
			}
		}
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
		tmp = sqrt(varmarg) * sqrt(2)
		for (i = 1; i <= cols(S1); i++) {
			this_b = GHx[i] * tmp
			xbbb = xbb :+ this_b
			S1[,i] = survfun(xbbb, t, anc) * dnrm[i]
		}
		Sint = tmp :* S1
		Sint = (tmp :* S1) * ((GHw :* exp(GHx:^2))')
		return(Sint)
	}

end
