clear all
cd "~/Stata-dev/stdmest"
set seed 2398472

// Simulate some data
set obs 500
gen cluster = _n
gen b = rnormal(0, 2)
expand 20
sort b
gen X1 = rbinomial(1, 0.5)
gen X2 = rnormal()
gen X3 = rnormal()
survsim time event, mixture distribution(weibull) lambdas(0.10 0.05) gammas(1.0 1.5) covariates(X1 -0.5 X2 0.1 X3 0.0 b 1.0) pmix(0.5) maxtime(50)

// KM to check simulate data
stset time, failure(event == 1)
sts graph, surv name("Survival")
sts graph, haz name("Hazard")
// -mestreg-

* Exponential, PH
quietly mestreg i.X1 c.X2 c.X3 || cluster: , dist(exp) nohr
predict b_exp_ph, reffects
predict xb_exp_ph, xb
predict S_exp_ph, surv conditional
gen S_exp_ph_byhand = exp(-exp(xb_exp_ph + b_exp_ph) * _t)
gen diff_exp_ph = S_exp_ph - S_exp_ph_byhand
assert diff_exp_ph <= 1e-6
capture drop *_exp_ph*

* Exponential, AFT
quietly mestreg i.X1 c.X2 c.X3 || cluster: , dist(exp) time
predict b_exp_aft, reffects
predict xb_exp_aft, xb
predict S_exp_aft, surv conditional
gen S_exp_aft_byhand = exp(-exp(-(xb_exp_aft + b_exp_aft)) * _t)
gen diff_exp_aft = S_exp_aft - S_exp_aft_byhand
assert diff_exp_aft <= 1e-6
capture drop *_exp_aft*

* Weibull, PH
quietly mestreg i.X1 c.X2 c.X3 || cluster: , dist(wei) nohr
predict b_wei_ph, reffects
predict xb_wei_ph, xb
predict S_wei_ph, surv conditional
local p = exp(_b[/:ln_p])
gen S_wei_ph_byhand = exp(-exp(xb_wei_ph + b_wei_ph) * _t^(`p'))
gen diff_wei_ph = S_wei_ph - S_wei_ph_byhand
assert diff_wei_ph <= 1e-6
capture drop *_wei_ph*

* Weibull, AFT
quietly mestreg i.X1 c.X2 c.X3 || cluster: , dist(wei) time
predict b_wei_aft, reffects
predict xb_wei_aft, xb
predict S_wei_aft, surv conditional
local p = exp(_b[/:ln_p])
gen S_wei_aft_byhand = exp(-exp(-`p' * (xb_wei_aft + b_wei_aft)) * _t^(`p'))
gen diff_wei_aft = S_wei_aft - S_wei_aft_byhand
assert diff_wei_aft <= 1e-6
capture drop *_wei_aft*

* Log-logistic
quietly mestreg i.X1 c.X2 c.X3 || cluster: , dist(logl) time
predict b_logl_aft, reffects
predict xb_logl_aft, xb
predict S_logl_aft, surv conditional
local s = exp(_b[/:logs])
gen z_logl_aft = xb_logl_aft + b_logl_aft
gen S_logl_aft_byhand = (1 + exp( ( log(_t) - z_logl_aft ) / `s' ) )^(-1)
gen diff_logl_aft = S_logl_aft - S_logl_aft_byhand
assert diff_logl_aft <= 1e-6
capture drop *_logl_aft*

* Log-normal
quietly mestreg i.X1 c.X2 c.X3 || cluster: , dist(logn) time
predict b_logn_aft, reffects
predict xb_logn_aft, xb
predict S_logn_aft, surv conditional
local s = exp(_b[/:logs])
gen z_logn_aft = xb_logn_aft + b_logn_aft
gen S_logn_aft_byhand = 1 - normal((log(_t) - z_logn_aft) / `s')
gen diff_logn_aft = S_logn_aft - S_logn_aft_byhand
assert diff_logn_aft <= 1e-6
capture drop *_logn_aft*

* Gamma
* -> omitted for now, as the survival function does not have closed form

// -stmixed-

* Exponential
quietly stmixed X1 X2 X3 || cluster:, dist(exponential)
gen b_exp_ph = 0 // because -stmixed- doesn't do conditional, so this will be comparable to fixedonly
predict xb_exp_ph, eta
predict S_exp_ph, surv // -stmixed- does fixedonly or marginal, not conditional on random effects
gen z_exp_ph = xb_exp_ph + b_exp_ph
gen S_exp_ph_byhand = exp(-exp(z_exp_ph) * _t)
gen diff_exp_ph = S_exp_ph - S_exp_ph_byhand
assert diff_exp_ph <= 1e-6
capture drop *_exp_ph*

* Weibull
quietly stmixed X1 X2 X3 || cluster:, dist(weibull)
gen b_wei_ph = 0 // because -stmixed- doesn't do conditional, so this will be comparable to fixedonly
predict xb_wei_ph, eta
predict S_wei_ph, surv // -stmixed- does fixedonly or marginal, not conditional on random effects
gen z_wei_ph = xb_wei_ph + b_wei_ph
local p = exp(_b[dap1_1:_cons])
gen S_wei_ph_byhand = exp(-exp(z_wei_ph) * (_t^`p'))
gen diff_wei_ph = S_wei_ph - S_wei_ph_byhand
assert diff_wei_ph <= 1e-6
capture drop *_wei_ph*

* Gompertz
quietly stmixed X1 X2 X3 || cluster:, dist(gompertz)
gen b_gom_ph = 0 // because -stmixed- doesn't do conditional, so this will be comparable to fixedonly
predict xb_gom_ph, eta
predict S_gom_ph, surv // -stmixed- does fixedonly or marginal, not conditional on random effects
gen z_gom_ph = xb_gom_ph + b_gom_ph
local gamma = _b[dap1_1:_cons]
gen S_gom_ph_byhand = exp(-exp(z_gom_ph) * (`gamma'^(-1)) * (exp(`gamma' * _t) - 1))
gen diff_gom_ph = S_gom_ph - S_gom_ph_byhand
assert diff_gom_ph <= 1e-6
capture drop *_gom_ph*

* RP
clear mata
mata
	void function my_rp_surv()
	{
		has_tvc = regexm(st_global("e(cmdline2)"), "tvc(")
		if (has_tvc == 1) {
			_error(198, "-stmixed- models with time-dependent effects are currently not supported.")
			// this would be easier to do if we sync with merlin utilities
		}
		t = st_data(. ,"_t")
		e_knots1 = st_global("e(knots1)")
		e_knots1 = tokens(e_knots1) // tokens() is equivalent to ustrsplit(, " "), invtokens() to concat
		e_knots1 = strtoreal(e_knots1)
		e_rcsrmat_1 = st_matrix("e(rcsrmat_1)")
		eb = st_matrix("e(b)")
		clabels = st_matrixcolstripe("e(b)")
		s = (clabels[,1] :== "_rcs1")
		s = selectindex(s)
		gamma = eb[., s]
		// check if splines were built with orthogonalisation
		// if e(rcsrmat_1) does not exist (is empty), then there was no ortogonalisation
		// then, call merlin_rcs without it
		if (length(e_rcsrmat_1) > 0) {
			// yes
			newspline = merlin_rcs(log(t), e_knots1, 0, e_rcsrmat_1)
		}
		else {
			// no
			newspline = merlin_rcs(log(t), e_knots1)
		}
		xb = st_data(., "z_rp_ph")
		S = exp(-exp(newspline * gamma' :+ xb))
		outi = st_addvar("double", "S_rp_ph_byhand")
		st_store(., outi, ., S)
	}
end

forvalues df = 1(1)10 {
	display "Doing df=`df'..."
	capture drop *_rp_ph*
	quietly stmixed X1 X2 X3 || cluster:, dist(rp) df(`df')
	gen b_rp_ph = 0 // because -stmixed- doesn't do conditional, so this will be comparable to fixedonly
	predict xb_rp_ph, eta
	predict S_rp_ph, surv // -stmixed- does fixedonly or marginal, not conditional on random effects
	gen z_rp_ph = xb_rp_ph + b_rp_ph
	capture drop S_rp_ph_byhand
	mata: my_rp_surv()
 	gen diff_rp_ph = S_rp_ph - S_rp_ph_byhand
 	assert diff_rp_ph <= 1e-6
	display "Okay!"
	capture drop *_rp_ph*
}

* RP, without orthogonalisation of the baseline hazard spline
forvalues df = 1(1)10 {
	display "Doing df=`df'..."
	capture drop *_rp_ph*
	quietly stmixed X1 X2 X3 || cluster:, dist(rp) df(`df') noorthog
	gen b_rp_ph = 0 // because -stmixed- doesn't do conditional, so this will be comparable to fixedonly
	predict xb_rp_ph, eta
	predict S_rp_ph, surv // -stmixed- does fixedonly or marginal, not conditional on random effects
	gen z_rp_ph = xb_rp_ph + b_rp_ph
	capture drop S_rp_ph_byhand
	mata: my_rp_surv()
 	gen diff_rp_ph = S_rp_ph - S_rp_ph_byhand
 	assert diff_rp_ph <= 1e-6
	display "Okay!"
	capture drop *_rp_ph*
}
