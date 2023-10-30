*! version 0.0.0-9000  27Oct2023 AG

program define mestreg_export
	// Version
    version 18

	// Check that we run stdmest after mestreg
	if "`e(cmd2)'" != "mestreg" {
		display as error "This only works after fitting a model with {cmd: mestreg}."
		exit 301
	}

	// Syntax
	syntax , FILEName(string) [replace]

	// Local names
	tempname b V

	// Export e(b)
	matrix `b' = e(b)
	capture putexcel set "`filename'", `replace' sheet("e(b)", replace)
	if _rc {
		display as error "File {cmd:`filename'} already exists; you might want to specify the {cmd:replace} option."
		exit 602
	}
	putexcel A1 = matrix(`b'), names
	putexcel save

	// Add e(V) in a separate Excel sheet
	matrix `V' = e(V)
	putexcel set "`filename'", modify sheet("e(V)", replace)
	putexcel A1 = matrix(`V')
	putexcel save

end
