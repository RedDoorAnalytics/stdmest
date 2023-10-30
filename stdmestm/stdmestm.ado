*! version 0.0.0-9000 Alessandro Gasparini 30Oct2023

program define stdmestm, sortpreserve
	// Version
	version 18.0

	// Check that erepost is installed
	capture which erepost
	if _rc > 0 {
		display as error "The -erepost- command is required for -stdmest- to function properly. You can install it using:"
		display as error ". {stata ssc install erepost}"
		exit  198
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

	// Also want to check that dataset is still stset
	st_is 2 analysis

	// Now, force `touse' to be zero if _st == 0
	quietly replace `touse' = 0 if _st == 0

	//
	local vartoint = _b[`varmargname']
	display `vartoint'

	//
	tempname kx kw
	mata: ghq(`nk', "`kx'", "`kw'")
	matrix list `kx'
	matrix list `kw'

end

mata:
	void ghq(real scalar nk, string scalar GHxname, string scalar GHwname) {
		GH = _gauss_hermite_nodes(nk)
		GHx = GH[1,]
		GHw = GH[2,]
		st_matrix(GHxname, GHx)
		st_matrix(GHwname, GHw)
	}
end
