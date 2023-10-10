PHONY: vendor_data

vendor_data:
	cp ~/R-dev/stdmest/data-raw/data3CIA.dta ~/Stata-dev/stdmest/data/data3CIA.dta
	cp ~/R-dev/stdmest/data-raw/data3Lsim.dta ~/Stata-dev/stdmest/data/data3Lsim.dta
