*! version 0.0.0-9000  31aug2023 AG

program define stdmest
    version 18


	// Check that we run stdmest after mestreg
	if "`e(cmd2)'" != "mestreg" {
		display as error "This only works after fitting an mestreg model."
		exit 198
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

    display "Model formulation: `e(frm2)'"
    display "Baseline hazard distribution: `e(distribution)'"

end
