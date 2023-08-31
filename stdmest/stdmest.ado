*! version 0.0.0-9000  31aug2023 AG

program define stdmest
    version 18
	
	if "`e(cmd2)'" != "mestreg" {
		display as error "This only works after fitting an mestreg model."
		exit 198
	}

    display "Hey"

end
