*! version 0.0.0-9000 Alessandro Gasparini 16Apr2024

local RS real scalar
local RC real colvector
local RR real rowvector
local SS string scalar

version 18.0
mata:

void std_surv(
		`SS' out,
		`SS' xb,
		`SS' xbtouse,
		`SS' timevar,
		`SS' timevartouse,
		`RS' reat)
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
		s = (clabels[,2] :== "ln_p")'
		ln_p = select(eb, s)
	}
	// view on timevar
	st_view(t = ., ., timevar, timevartouse)
	order_of_t 	= order(t, 1)
	invorder_of_t 	= invorder(order_of_t)
	unique_t 	= uniqrows(t, 1)
	Nuniqt 		= rows(unique_t)
	// view on linear predictor
	st_view(xbb = ., ., xb, xbtouse)
	// add fixed value of random intercept
	xbb = xbb :+ reat	//!! be careful, this will update the Stata variable as well
	// do calculations for the std. survival, looping over timevar
	// actually, we loop over _unique_ values of timevar to be more efficient,
	unique_Savg = J(Nuniqt, 1, .)
	for (i = 1; i <= Nuniqt; i++) {
		unique_Savg[i] = mean(survfun(xbb, unique_t[i,1], ln_p))
	}
	// Return to original size
	Savg = J(rows(t), 1, .)
	counter = 1
	for (i = 1; i <= Nuniqt; i++) {
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

`RC' survfun (`RC' xb, `RS' t, `RS' anc)
{
	S = exp(-exp(xb) :* (t:^exp(anc)))
	return(S)
}

void draw_newpars (`RS' B, `SS' newebname)
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

void draw_newreat (`RS' B, `RR' reat, `RR' reatse, `SS' newreatname)
{
	Nc = cols(reat)
	fulldraw = J(B, Nc, .)
	for (i = 1; i <= Nc; i++) {
		fulldraw[.,i] = rnormal(B, 1, reat[i], reatse[i])
	}
	newreat = rowsum(fulldraw)
	st_matrix(newreatname, newreat)
}

end
