clear all
local drive = "~/Stata-dev"
cd "`drive'/stdmest"
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
