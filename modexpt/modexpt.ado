*! version 0.0.1-9000  16Jul2024 AG

program define modexpt
	// Version
    version 18

	// Check that we run modexpt after mestreg or stmixed
	if ("`e(cmd2)'" != "mestreg") & ("`e(cmd2)'" != "stmixed") {
		display as error "This only works after fitting a model with {cmd: mestreg} or {cmd: stmixed}."
		exit 301
	}	

	// Syntax
	syntax , FILEName(string) [replace]

	// Local names
	tempname b V
	
	// Export e(b)
	capture putexcel set "`filename'", `replace' sheet("e(b)", replace)
	if _rc {
		display as error "File {cmd:`filename'} already exists; you might want to specify the {cmd:replace} option."
		exit 602
	}
	matrix `b' = e(b)
	putexcel A1 = matrix(`b'), names
	putexcel save

	// Add e(V) in a separate Excel sheet
	matrix `V' = e(V)
	putexcel set "`filename'", modify sheet("e(V)", replace)
	putexcel A1 = matrix(`V')
	putexcel save

	// Add family/distribution in a separate Excel sheet
	putexcel set "`filename'", modify sheet("family", replace)
	if "`e(cmd2)'" == "mestreg" {
		putexcel A1 = "`e(distribution)'"
	}
	else {
		putexcel A1 = "`e(family1)'"
	}
	putexcel save

	// Add cmdline in a separate Excel sheet
	putexcel set "`filename'", modify sheet("cmdline", replace)
	if "`e(cmd2)'" == "mestreg" {
		putexcel A1 = "`e(cmdline)'"
	}
	else {
		putexcel A1 = "`e(cmdline2)'"
	}
	putexcel save

	// If -stmixed- with distribution(rp), export stuff to rebuild the spline
	if ("`e(cmd2)'" == "stmixed") & ("`e(family1)'" == "rp") {
		putexcel set "`filename'", modify sheet("e(knots1)", replace)
		putexcel A1 = "`e(knots1)'"
		putexcel save		
		//
		putexcel set "`filename'", modify sheet("e(orthog1)", replace)
		putexcel A1 = "`e(orthog1)'"
		putexcel save
		//
		tempname rcsrmat
		matrix `rcsrmat' = e(rcsrmat_1)
		putexcel set "`filename'", modify sheet("e(rcsrmat_1)", replace)
		putexcel A1 = matrix(`rcsrmat')
		putexcel save
		//		
	}

end
