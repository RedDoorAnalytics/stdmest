.PHONY: vendor_data cert ex matalib release

vendor_data:
	cp ~/R-dev/stdmest/data-raw/data3CIA.dta ~/Stata-dev/stdmest/data/data3CIA.dta
	cp ~/R-dev/stdmest/data-raw/data3Lsim.dta ~/Stata-dev/stdmest/data/data3Lsim.dta

cert:
	cd cert && stata-mp -e assert-data2Lsim.do
	cd cert && stata-mp -e assert-modexpt.do
	cd cert && stata-mp -e assert-stdmest.do
	cd cert && stata-mp -e assert-stdmestm.do
	cd cert && stata-mp -e assert-uhtred2L.do
	cd cert && stata-mp -e assert-uhtred3L.do
	cd cert && stata-mp -e assert-uhtred3L-m.do

ex:
	cd cert && stata-mp -e testing-data3CIA.do
	cd cert && stata-mp -e testing-data3Lsim.do
	cd cert && stata-mp -e testing-modexpt-examples.do
	cd cert && stata-mp -e testing-stdmest.do
	cd cert && stata-mp -e testing-stdmest-examples.do
	cd cert && stata-mp -e testing-stdmestm.do
	cd cert && stata-mp -e testing-stdmestm-examples.do
	cd cert && stata-mp -e testing-verbose.do
	cd cert && stata-mp -e testing-#7.do
	cd cert && stata-mp -e testing-uhtred2L.do
	cd cert && stata-mp -e testing-uhtred3L.do
	cd cert && stata-mp -e testing-uhtred3L-m.do

matalib:
	cd build && stata-mp -e buildmlib.do

release:
	make matalib
	cd build && stata-mp -e buildrelease.do
