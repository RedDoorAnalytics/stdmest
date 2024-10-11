.PHONY: vendor_data cert ex

vendor_data:
	cp ~/R-dev/stdmest/data-raw/data3CIA.dta ~/Stata-dev/stdmest/data/data3CIA.dta
	cp ~/R-dev/stdmest/data-raw/data3Lsim.dta ~/Stata-dev/stdmest/data/data3Lsim.dta

cert:
	make cert_modexpt
	make cert_stdmest
	make cert_stdmestm
	cd cert && stata-mp -e assert-data2Lsim.do

cert_modexpt:
	cd cert && stata-mp -e assert-modexpt.do

cert_stdmest:
	cd cert && stata-mp -e assert-stdmest.do

cert_stdmestm:
	cd cert && stata-mp -e assert-stdmestm.do

ex:
	cd cert && stata-mp -e testing-data3CIA.do
	cd cert && stata-mp -e testing-data3Lsim.do
	cd cert && stata-mp -e testing-modexpt-examples.do
	cd cert && stata-mp -e testing-stdmest.do
	cd cert && stata-mp -e testing-stdmest-examples.do
	cd cert && stata-mp -e testing-stdmestm.do
	cd cert && stata-mp -e testing-stdmestm-examples.do
	cd cert && stata-mp -e testing-verbose.do
