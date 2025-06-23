clear all
// -uhtred-
cd "~/Stata-dev/uhtred"
adopath ++ "~/Stata-dev/uhtred"
clear all
adopath ++ "~/Stata-dev/uhtred/uhtred"
clear all
do ./build/buildmlib.do
mata mata clear
// -stdmest-
cd "~/Stata-dev/stdmest"
adopath ++ "stdmest"
adopath ++ "stdmestm"
clear all
// Mata
capture erase lstdmest.mlib
quietly {
    do "mata/stdmest-lib.mata"
    mata: mata mlib create lstdmest, dir(.)
    mata: mata mlib add lstdmest *(), dir(.)
    mata: mata d *()
    mata mata clear
    mata mata mlib index
}
