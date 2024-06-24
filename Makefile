.PHONY: vendor_data cert ex

vendor_data:
	cp ~/R-dev/stdmest/data-raw/data3CIA.dta ~/Stata-dev/stdmest/data/data3CIA.dta
	cp ~/R-dev/stdmest/data-raw/data3Lsim.dta ~/Stata-dev/stdmest/data/data3Lsim.dta

cert:
	cd cert && stata-mp -e assert-mestreg_export.do
	cd cert && stata-mp -e assert-stdmest.do
	cd cert && stata-mp -e assert-stdmestm.do

ex:
	cd cert && stata-mp -e testing-stdmest.do
	cd cert && stata-mp -e testing-stdmest-examples.do
	cd cert && stata-mp -e testing-stdmestm.do
	cd cert && stata-mp -e testing-stdmestm-examples.do
