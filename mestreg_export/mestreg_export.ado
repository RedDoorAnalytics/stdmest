*! version 0.0.0-9000  31aug2023 AG

program define mestreg_export
    version 18
	syntax , filename(string) [replace]

	// Check that we run stdmest after mestreg
	if "`e(cmd2)'" != "mestreg" {
		display as error "This only works after fitting an mestreg model."
		exit 198
	}

	// Local names
	tempname b V

	// Export e(b)
	matrix `b' = e(b)
	capture putexcel set "`filename'", `replace' sheet("e(b)", replace)
	if _rc {
		display as error "file {cmd:`filename'} already exists; you might want to specify the option {cmd:replace}"
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
