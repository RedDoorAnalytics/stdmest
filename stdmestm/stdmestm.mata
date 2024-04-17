*! version 0.0.0-9000 Alessandro Gasparini 16Apr2024

local RS real scalar
local RC real colvector
local RR real rowvector
local SS string scalar

version 18.0
mata:

void ghq(
	`RS' nk,
	`SS' GHxname,
	`SS' GHwname)
{
	GH = _gauss_hermite_nodes(nk)
	GHx = GH[1,]
	GHw = GH[2,]
	st_matrix(GHxname, GHx)
	st_matrix(GHwname, GHw)
}

void std_isurv(
	`SS' out,
	`SS' xb,
	`SS' xbtouse,
	`SS' timevar,
	`SS' timevartouse,
	`RS' reat,
	`RS' varmarg,
	`SS' GHxname,
	`SS' GHwname)
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

`RC' intsurvfun(
	`RC' xb,
	`RS' b,
	`RS' t,
	`RS' anc,
	`RS' varmarg,
	`RR' dnrm,
	`RR' GHx,
	`RR' GHw)
{
	S1 = J(rows(xb), cols(GHx), .)
	tmp = sqrt(varmarg) * sqrt(2)
	for (i = 1; i <= cols(S1); i++) {
		this_b = b + GHx[i] * tmp
        xbb = xb :+ this_b
		S1[,i] = survfun(xbb, t, anc) * dnrm[i]
	}
	Sint = tmp :* S1
	Sint = (tmp :* S1) * ((GHw :* exp(GHx:^2))')
	return(Sint)
}

end
